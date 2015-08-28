
Test Result:

	dumbfork: OK (1.9s) 
	Part A score: 5/5

	faultread: OK (1.4s) 
	faultwrite: OK (1.5s) 
    	(Old jos.out.faultwrite failure log removed)
	faultdie: OK (1.4s) 
	faultregs: OK (1.4s) 
	faultalloc: OK (2.1s) 
	faultallocbad: OK (1.5s) 
	faultnostack: OK (2.0s) 
	faultbadhandler: OK (2.4s) 
	faultevilhandler: OK (1.3s) 
	forktree: OK (2.1s) 
	Part B score: 50/50

	spin: OK (1.4s) 
	stresssched: OK (2.5s) 
	sendpage: OK (2.1s) 
	pingpong: OK (1.4s) 
	primes: OK (5.6s) 
	Part C score: 25/25

	Score: 80/80
	
Part A: Multiprocessor Support and Cooperative Multitasking

Multiprocessor Support

	mem_init_mp(void)
	{
        	int i;
        	for(i = 0; i < NCPU; i++) {
                	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE - i * (KSTKSIZE + KSTKGAP),
                	KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
        	}
	}

Application Processor Bootstrap

	void page_init(void)
	{
		size_t i;
		for (i = 0; i < npages; i++) {
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
        	pages[0].pp_ref = 1; 
		pages[1].pp_link = pages[0].pp_link;
         
        	uint32_t nextfreepa = PADDR(boot_alloc(0));         
        	struct PageInfo *p = pages[IOPHYSMEM/PGSIZE].pp_link;
        	for (i = IOPHYSMEM; i < nextfreepa; i += PGSIZE) { 
              		pages[i/PGSIZE].pp_ref = 1;  
              		pages[i/PGSIZE].pp_link = NULL;     
        	}      
        	pages[i/PGSIZE].pp_link = p;
        	p = pa2page(MPENTRY_PADDR);
        	(p + 1)->pp_link = p->pp_link;
        	p->pp_ref = 1;
        	p->pp_link = NULL;
	}
	
	void *
	mmio_map_region(physaddr_t pa, size_t size)
	{
		// Your code here:
        	size_t roundsize = ROUNDUP(size, PGSIZE);
        	if( base + roundsize >= MMIOLIM )
                	panic("Lapic required too much memory\n");
        	boot_map_region(kern_pgdir, base, roundsize, pa, PTE_PCD | PTE_PWT | PTE_W);
        	base += roundsize; 
        	return (void *)(base - roundsize);
	}
	
	void trap_init_percpu(void)
	{
		// when we trap to the kernel.
        	int cid = thiscpu->cpu_id;
		thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
		thiscpu->cpu_ts.ts_ss0 = GD_KD;

		// Initialize the TSS slot of the gdt.
		gdt[(GD_TSS0 >> 3) + cid] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
					sizeof(struct Taskstate) - 1, 0);
		gdt[(GD_TSS0 >> 3) + cid].sd_s = 0;

		// Load the TSS selector (like other segment selectors, the
		// bottom three bits are special; we leave them 0)
		ltr(GD_TSS0 + 8 * cid);
		// Load the IDT
		lidt(&idt_pd);
	}
	
Locking

Round-Robin Scheduling

	sched_yield(void)
	{
		struct Env *idle;
        	int i, cur=0;
        	if (curenv) cur=ENVX(curenv->env_id);
        	else cur = 0;
       
        	for (i = 0; i < NENV; ++i) {
                	int j = (cur+i) % NENV;
                	if (envs[j].env_status == ENV_RUNNABLE) {
                        	envs[j].env_cpunum == cpunum();
                        	env_run(envs + j);
                	}
        	}
        	if (curenv && curenv->env_status == ENV_RUNNING && cpunum() == curenv->env_cpunum) {
               		env_run(curenv);
        	}
		// sched_halt never returns
		sched_halt();
	}

System Calls for Environment Creation

	static envid_t sys_exofork(void)
	{
        	struct Env *newenv;
        	int ret;
        	if((ret = env_alloc(&newenv, curenv->env_id)) != 0)  
                	return ret;
        	newenv->env_status = ENV_NOT_RUNNABLE;
        	newenv->env_tf = curenv->env_tf; 
        	newenv->env_tf.tf_regs.reg_eax = 0;
        	return newenv->env_id;
	}

	static int sys_env_set_status(envid_t envid, int status)
	{
		// LAB 4: Your code here.
        	struct Env *tmp;
        	int rslt;
        	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
                	return -E_INVAL;
        	if((rslt = envid2env(envid, &tmp, 1)) == 0)
                	tmp->env_status = status;
        	return rslt;     
	}

	static int sys_page_alloc(envid_t envid, void *va, int perm)
	{
		// LAB 4: Your code here.
	        int rslt;
	        struct Env *tmp;
	        struct PageInfo *p = NULL;
	        if((rslt = envid2env(envid, &tmp, 1)) != 0)
	                return rslt;
	        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
	                return -E_INVAL;
	        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
	                return -E_INVAL;
	        if((p = page_alloc(1)) == (void*)NULL)
	                return -E_NO_MEM;
	        if((rslt = page_insert(tmp->env_pgdir, p, va, perm)) != 0) 
	                page_free(p);
	        return rslt;
	
		//panic("sys_page_alloc not implemented");
	}

 
	static int sys_page_map(envid_t srcenvid, void *srcva,
		     envid_t dstenvid, void *dstva, int perm)
	{
	        int rslt;
	        struct Env *src, *dst;
	        pte_t *srcpte;
	        struct PageInfo *pg;
	        if((rslt = envid2env(srcenvid, &src, 1)) != 0)
	                return rslt;
	        if((rslt = envid2env(dstenvid, &dst, 1)) != 0)
	                return rslt;
	        if(srcva >= (void *)UTOP || (((size_t)srcva % PGSIZE) != 0))
	                return -E_INVAL;
		if(dstva >= (void *)UTOP || (((size_t)dstva % PGSIZE) != 0))
	                return -E_INVAL;
	        if((pg = page_lookup(src->env_pgdir, srcva, &srcpte)) == NULL || !(*srcpte & PTE_P))
	                return 	-E_INVAL;
	        if((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
	                return -E_INVAL;
	        if((perm & PTE_W) && !(*srcpte & PTE_W))
	                return -E_INVAL;
	        rslt =  page_insert(dst->env_pgdir, pg, dstva, perm);
	        return rslt;
	}

 
	static int sys_page_unmap(envid_t envid, void *va)
	{
		// Hint: This function is a wrapper around page_remove().
	
		// LAB 4: Your code here.
	        int rslt;
	        struct Env *tmp;
	        pte_t *srcpte;
	        struct PageInfo *pg;
	        if((rslt = envid2env(envid, &tmp, 1)) != 0)
	                return rslt;  
	        if(va >= (void *)UTOP || (((size_t)va % PGSIZE) != 0))
	                return -E_INVAL; 
	        page_remove(tmp->env_pgdir, va);
	        return 0;
		//panic("sys_page_unmap not implemented");
	}

 
 
	static int
	sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
	{
		// LAB 4: Your code here.
		//panic("sys_ipc_try_send not implemented");
	        struct Env *target;
	        if(envid2env(envid, &target, 0) < 0)
	                return -E_BAD_ENV;
	        if(target->env_ipc_recving == 0 || target->env_ipc_from != 0)
	                return -E_IPC_NOT_RECV;
	        
	        if(srcva < (void *)UTOP) {
	                if((size_t)srcva % PGSIZE)
	                        return -E_INVAL;
	                if((perm & (PTE_P | PTE_U )) != (PTE_P | PTE_U ))
	                        return -E_INVAL;
	                pte_t *pte;
	                struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
	                if(!pg) return -E_INVAL;
	                if( (perm & PTE_W) && !(*pte & PTE_W))
	                        return -E_INVAL;
	                if (target->env_ipc_dstva && target->env_ipc_dstva < (void *)UTOP) {
	                        if(page_insert(target->env_pgdir, pg, target->env_ipc_dstva, perm) < 0)
	                                return -E_NO_MEM;
	                        target->env_ipc_perm = perm;
	                }
	        }
	        target->env_ipc_recving = 0;
	        target->env_ipc_value = value;
	        target->env_ipc_from = curenv->env_id;
	        target->env_tf.tf_regs.reg_eax = 0;
	        target->env_status = ENV_RUNNABLE;
	
	        return 0;
	
	}

	static int sys_ipc_recv(void *dstva)
	{
		// LAB 4: Your code here.
		//panic("sys_ipc_recv not implemented");
	        if((dstva < (void *)UTOP) && ((size_t)dstva % PGSIZE))
	                        return -E_INVAL;
	        curenv->env_ipc_recving = 1;
	        curenv->env_status = ENV_NOT_RUNNABLE;
	        curenv->env_ipc_dstva = dstva;
	        curenv->env_ipc_from = 0;
	        sys_yield();
		return 0;
	}

Part B: Copy-on-Write Fork

	static int sys_env_set_pgfault_upcall(envid_t envid, void *func)
	{
		// LAB 4: Your code here.
        	int rslt;
        	struct Env *tmp;
        	if((rslt = envid2env(envid, &tmp, 1)) == 0)
                	tmp->env_pgfault_upcall = func;
        	return rslt;
	}
	
	void page_fault_handler(struct Trapframe *tf)
	{
		uint32_t fault_va;
		fault_va = rcr2();
		// LAB 3: Your code here.
	        if ((tf->tf_cs & 3) == 0)
	                panic("Kernel page fault!");
	        if(curenv->env_pgfault_upcall) {
	                struct UTrapframe *utf;
	                if(tf->tf_esp >= UXSTACKTOP-PGSIZE &&  tf->tf_esp <= UXSTACKTOP-1)  
	                        utf = (struct UTrapframe *) ((void *)tf->tf_esp - sizeof(struct UTrapframe) -4);
	                else
	                        utf = (struct UTrapframe *) ((void *)UXSTACKTOP - sizeof(struct UTrapframe));
	                user_mem_assert(curenv, utf, sizeof(struct UTrapframe), PTE_P | PTE_W);
	                utf->utf_fault_va = fault_va;
	                utf->utf_err = tf->tf_err;
	                utf->utf_regs = tf->tf_regs;
	                utf->utf_eip = tf->tf_eip;
	                utf->utf_eflags = tf->tf_eflags;
	                utf->utf_esp = tf->tf_esp;
	                tf->tf_eip = (uintptr_t)(curenv->env_pgfault_upcall);
	                tf->tf_esp = (uintptr_t)utf;
	                env_run(curenv);
	        } else {
	                cprintf("curenv->env_pgfault_upcall is NULL\n");
	        }
	               
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
		env_destroy(curenv);
	}
	
User-mode Page Fault Entrypoint

	.text
	.globl _pgfault_upcall
	_pgfault_upcall:
		// Call the C page fault handler.
		pushl %esp			// function argument: pointer to UTF
		movl _pgfault_handler, %eax
		call *%eax
		addl $4, %esp			// pop function argument
		
		// LAB 4: Your code here.
	        subl $0x4, 0x30(%esp)
	        movl 0x30(%esp), %eax
	        movl 0x28(%esp), %edx
	        movl %edx, (%eax)
	        
		// Restore the trap-time registers.  After you do this, you
		// can no longer modify any general-purpose registers.
		// LAB 4: Your code here.
	        addl $0x8, %esp
	        popal
		// Restore eflags from the stack.  After you do this, you can
		// no longer use arithmetic operations or anything else that
		// modifies eflags.
		// LAB 4: Your code here.
	        addl $0x4, %esp
	        popfl
		// Switch back to the adjusted trap-time stack.
		// LAB 4: Your code here.
	        pop %esp
		// Return to re-execute the instruction that faulted.
		// LAB 4: Your code here.
	        ret
