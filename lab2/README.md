Test Result:

running JOS: (0.9s)

  Physical page allocator: OK 
  
  Page management: OK 
  
  Kernel page directory: OK 
  
  Page management 2: OK 
  
Score: 70/70

Code:

Part 1: Physical Page Managment

Exercise 1. In the file kern/pmap.c, you must implement code for the following functions (probably in the order given).

	// LAB 2: Your code here.
	if (n > 0) {
		// Round-up alloc_size promises round-up nextfree.
		uint32_t alloc_size = ROUNDUP(n, PGSIZE);

		result = nextfree;
		nextfree += alloc_size;

		// Because in the beginning phase of booting,
		// only 4MB physical memory is mapped.
		// Memory allocation cannot exceeds the limit.
		if ((uint32_t)nextfree >= 0xf0400000) {
		     nextfree = result;
                     result = NULL;
                     panic("boot_alloc: out of memory");
                }

        
	} else {
		result = nextfree;
	}
	return result;

fragment of mem_init

	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
	memset(kern_pgdir, 0, PGSIZE);
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
	pages = boot_alloc(npages * sizeof(struct PageInfo));
	memset(pages, 0, npages * sizeof(struct PageInfo));
        
fragment of page_init

	size_t i;
	for (i = 0; i < npages; i++) {
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	pages[0].pp_ref = 1;
	pages[1].pp_link = pages[0].pp_link;
        uint32_t nextfreepa = PADDR(boot_alloc(0)); 
        void *p = pages[IOPHYSMEM/PGSIZE].pp_link;
        for (i = IOPHYSMEM; i < nextfreepa; i += PGSIZE) { 
        	pages[i/PGSIZE].pp_ref = 1;  
                pages[i/PGSIZE].pp_link = NULL;     
        }      
        pages[i/PGSIZE].pp_link = p;

page_alloc
	
	struct PageInfo *
	page_alloc(int alloc_flags)
	{
		// Fill this function in
		if ( page_free_list ) {
			if(alloc_flags & ALLOC_ZERO) 
				memset(page2kva(page_free_list), 0, PGSIZE);
                        struct PageInfo *tmp = page_free_list;
                        page_free_list = page_free_list->pp_link;
		        tmp->pp_link = NULL;
                        return tmp; 
        	}
		return NULL;
	}

page_free

	void page_free(struct PageInfo *pp)
	{
		if(pp == NULL) return;
        	if (pp->pp_ref != 0 || pp->pp_link != NULL)
        		panic("page_free: invalid page free\n");
        	else {
            		pp->pp_link = page_free_list;
            		page_free_list = pp;
        	}
	}

Part 2: Virtual Memory

Page Table Managemnet

	pte_t *pgdir_walk(pde_t *pgdir, const void *va, int create)
	{
		// Fill this function in
        	pte_t * pte;
        	if ((pgdir[PDX(va)] & PTE_P) != 0) {
        	        pte =(pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)]));
        	        return pte + PTX(va);  
        	} 
        
        	if(create != 0) {
               		struct PageInfo *tmp;
               		tmp = page_alloc(1);
       
               		if(tmp != NULL) {
                       		tmp->pp_ref += 1;
                       		tmp->pp_link = NULL;
                       		pgdir[PDX(va)] = page2pa(tmp) | PTE_U | PTE_W | PTE_P;
                       		pte = (pte_t *)KADDR(page2pa(tmp));
                       		return pte+PTX(va);
               	}
        }
		return NULL;
	}
	
	static void
	boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
	{
		// Fill this function in
	   	size = ROUNDUP(size, PGSIZE);
	 	pte_t *tmp;
        	int i ;
        	for( i = 0; i < size; i += PGSIZE) { 
              		tmp = pgdir_walk(pgdir, (void *)(va + i), 1);  
              		if ( tmp == NULL ) {
                     		panic("boot_map_region: fail\n");
                     		return;
              		}
              		*tmp = (pa + i) | perm | PTE_P; 
 
        	}
	}

	int
	page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	{
		// Fill this function in
		pte_t *tmp = pgdir_walk(pgdir, va, 1);
         
        	if( tmp == NULL )
                	return -E_NO_MEM;
		pp->pp_ref += 1;
        	if( (*tmp & PTE_P) != 0 )
                page_remove(pgdir, va);
        	*tmp = page2pa(pp) | perm | PTE_P;
        	pp->pp_link = NULL;
		return 0;
	}
	
	struct PageInfo *
	page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
	{
		// Fill this function in
        	pte_t *tmp = pgdir_walk(pgdir, va, 0);
        	if ( tmp != NULL && (*tmp & PTE_P)) {
                	if(pte_store != NULL) 
                        	*pte_store = tmp;
                	return (struct PageInfo *)pa2page(*tmp);

        	}
		return NULL;
	}
	
	void
	page_remove(pde_t *pgdir, void *va)
	{
		// Fill this function in
        	pte_t *tmppte;
        	struct PageInfo *tmp = page_lookup(pgdir, va, &tmppte);
        	if( tmp != NULL && (*tmppte & PTE_P)) {
                	page_decref(tmp);
                	*tmppte = 0;
		}
        	tlb_invalidate(pgdir, va);
	}
	
Part 3: Kernal Address Space:
fragment of mem_init

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
	boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
	
