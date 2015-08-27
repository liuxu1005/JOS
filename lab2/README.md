Test Result:

running JOS: (0.9s) 
  Physical page allocator: OK 
  Page management: OK 
  Kernel page directory: OK 
  Page management 2: OK 
Score: 70/70

Code:

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
        pages = boot_alloc(npages * sizeof(struct PageInfo));
        memset(pages, 0, npages * sizeof(struct PageInfo));
        
fragment of page_init


