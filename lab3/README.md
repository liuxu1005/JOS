Test Result:

	divzero: OK (1.3s) 	
	softint: OK (0.9s) 
	badsegment: OK (0.9s) 
	Part A score: 30/30

	faultread: OK (0.9s) 
	faultreadkernel: OK (1.0s) 
	faultwrite: OK (1.1s) 
	faultwritekernel: OK (1.8s) 
	breakpoint: OK (2.3s) 
	testbss: OK (1.9s) 
	hello: OK (2.1s) 
	buggyhello: OK (0.9s) 
	buggyhello2: OK (1.6s) 
	evilhello: OK (1.3s) 
	Part B score: 50/50

	Score: 80/80

Part A: User Environments and Exception Handling

Allocating the Environments Array

	envs = boot_alloc(NENV * sizeof(struct Env));
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
	
Creating and Running Environments

	void env_init(void)
	{
		// Set up envs array
		// LAB 3: Your code here.
		size_t i;
        	//has been set to 0 when allocated?
		for(i = NENV - 1; i >= 1; i--) {
                	envs[i].env_link = envs + i -1;
                	envs[i].env_id = 0;
        	}
        	envs[0].env_id = 0;
        	env_free_list = envs;
		// Per-CPU part of the initialization
		env_init_percpu();
	}
	

	static int env_setup_vm(struct Env *e)
	{
		int i;
		struct PageInfo *p = NULL;

		// Allocate a page for the page directory
		if (!(p = page_alloc(ALLOC_ZERO)))
			return -E_NO_MEM;
        		p->pp_ref++;
        		e->env_pgdir = page2kva(p);    
        		memcpy(e->env_pgdir, kern_pgdir, PGSIZE);  
			// UVPT maps the env's own page table read-only.
			// Permissions: kernel R, user R
			e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;

		return 0;
	}
	
	


