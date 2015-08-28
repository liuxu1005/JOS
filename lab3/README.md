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
	
	static void region_alloc(struct Env *e, void *va, size_t len)
	{
        	void *start, *end;
        	struct PageInfo *newpage;
        	start = ROUNDDOWN(va, PGSIZE);
        	end = ROUNDUP(va + len, PGSIZE);
        	for(; start < end; start += PGSIZE) {
                	if((newpage = page_alloc(0)) == NULL)
                        	cprintf("page_alloc return null\n");
                	if(page_insert(e->env_pgdir, newpage, start, PTE_U | PTE_W) < 0)
                        	cprintf("insert failing\n");
        		}
	}

	static void load_icode(struct Env *e, uint8_t *binary)
	{
		// LAB 3: Your code here.
        	struct Elf *elf_img = (struct Elf *)binary;
        	struct Proghdr *ph, *eph;
        	if (elf_img->e_magic != ELF_MAGIC)
                	panic("Not executable!");
        	ph = (struct Proghdr *)(binary + elf_img->e_phoff);
        	eph = ph + elf_img->e_phnum;
        	lcr3(PADDR(e->env_pgdir));
        
        	for(; ph < eph; ph++) {
                	region_alloc(e, (void *)ph->p_va, ph->p_memsz);
                	memset((void *)ph->p_va, 0, ph->p_memsz);
                	memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
        	}
        	lcr3(PADDR(kern_pgdir));
        	e->env_tf.tf_eip = elf_img->e_entry;
		// Now map one page for the program's initial stack
		// at virtual address USTACKTOP - PGSIZE.
        	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
	}

	void env_create(uint8_t *binary, enum EnvType type)
	{
		// LAB 3: Your code here.
        	struct Env *e;
        	if(env_alloc(&e, 0) != 0)
                	panic("evn create fails!\n");
        	e->env_type =type;
        	load_icode(e, binary);
	}

	void env_run(struct Env *e)
	{
 
        	if( e != curenv) {
                
             	//   if(curenv->env_status == ENV_RUNNING)
             	//           curenv->env_status = ENV_RUNNABLE;
        		curenv = e;
                	curenv->env_runs++;
                	curenv->env_status = ENV_RUNNING;
                	lcr3(PADDR(curenv->env_pgdir));
		}
        	env_pop_tf(&curenv->env_tf);
        }

Handling Interrupts and Exceptions

Set up IDT

	TRAPHANDLER_NOEC(i0, T_DIVIDE)
	TRAPHANDLER_NOEC(i1, T_DEBUG)
	TRAPHANDLER_NOEC(i2, T_NMI)
	TRAPHANDLER_NOEC(i3, T_BRKPT)
	TRAPHANDLER_NOEC(i4, T_OFLOW)
	TRAPHANDLER_NOEC(i5, T_BOUND)
	TRAPHANDLER_NOEC(i6, T_ILLOP)
	TRAPHANDLER_NOEC(i7, T_DEVICE)
	TRAPHANDLER(i8, T_DBLFLT)
	TRAPHANDLER_NOEC(i9, 9)
	TRAPHANDLER(i10, T_TSS)
	TRAPHANDLER(i11, T_SEGNP)
	TRAPHANDLER(i12, T_STACK)
	TRAPHANDLER(i13, T_GPFLT)
	TRAPHANDLER(i14, T_PGFLT)
	TRAPHANDLER_NOEC(i15, 15)
	TRAPHANDLER_NOEC(i16, T_FPERR)
	TRAPHANDLER(i17, T_ALIGN)
	TRAPHANDLER_NOEC(i18, T_MCHK)
	TRAPHANDLER_NOEC(i19, T_SIMDERR)
	TRAPHANDLER_NOEC(i20, T_SYSCALL)

	_alltraps:
        	pushl %ds
        	pushl %es
        	pushal
        	pushl $GD_KD
        	popl %ds
        	pushl $GD_KD
        	popl %es
        	pushl %esp
        	call trap
        	popl %esp
        	popal
        	popl %es
        	popl %ds
        	iret

	extern void i0();
        extern void i1();
        extern void i2();
        extern void i3();
        extern void i4();
        extern void i5();
        extern void i6();
        extern void i7();
        extern void i8();
        extern void i9();
        extern void i10();
        extern void i11();
        extern void i12();
        extern void i13();
        extern void i14();
        extern void i15();
        extern void i16();
        extern void i17();
        extern void i18();
        extern void i19();
        extern void i20();
	
        SETGATE(idt[0], 0, GD_KT, i0, 0);
        SETGATE(idt[1], 0, GD_KT, i1, 0);
        SETGATE(idt[2], 0, GD_KT, i2, 0);
        SETGATE(idt[3], 0, GD_KT, i3, 3);
        SETGATE(idt[4], 0, GD_KT, i4, 0);
        SETGATE(idt[5], 0, GD_KT, i5, 0);
        SETGATE(idt[6], 0, GD_KT, i6, 0);
        SETGATE(idt[7], 0, GD_KT, i7, 0);
        SETGATE(idt[8], 0, GD_KT, i8, 0);
        SETGATE(idt[9], 0, GD_KT, i9, 0);
        SETGATE(idt[10], 0, GD_KT, i10, 0);
        SETGATE(idt[11], 0, GD_KT, i11, 0);
        SETGATE(idt[12], 0, GD_KT, i12, 0);
        SETGATE(idt[13], 0, GD_KT, i13, 0);
        SETGATE(idt[14], 0, GD_KT, i14, 0);
        SETGATE(idt[16], 0, GD_KT, i16, 0);
        SETGATE(idt[17], 0, GD_KT, i17, 0);
        SETGATE(idt[18], 0, GD_KT, i18, 0);
        SETGATE(idt[19], 0, GD_KT, i19, 0);
        SETGATE(idt[48], 0, GD_KT, i20, 3);

Part B: Page Faults, Breakpoints Exceptions, and System Calls

	if(tf->tf_trapno == T_PGFLT ) {
                page_fault_handler(tf);
                return;
        } 
       
        if(tf->tf_trapno == T_BRKPT ) { 
                monitor(tf);
                return;
        }
        if(tf->tf_trapno == T_SYSCALL ) { 
                tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
                tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
                return;
        }
        
        int32_t
	syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
	{
        	int32_t rslt;
		switch (syscallno) {
        	case SYS_cputs:
        	        sys_cputs((char *)a1, a2);
                	rslt = 0;
                	break;
		case SYS_cgetc:
                	rslt = sys_cgetc();
                	break;
		case SYS_getenvid:
                	rslt = sys_getenvid();
                	break;
		case SYS_env_destroy:
                	rslt = sys_env_destroy(a1);
	        	break;
		default:
			return -E_NO_SYS;
		}
        	return rslt;
	}
	
Page faults and memory protection

	user_mem_check(struct Env *env, const void *va, size_t len, int perm)
	{
		// LAB 3: Your code here.
        	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
        	uint32_t end = (uint32_t) (va+len);
        	uint32_t i;
        	for (i = begin; i < end; i+=PGSIZE) {
                	pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
       
                	if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
                      		user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
                      		return -E_FAULT;
                	}
		}
        	cprintf("user_mem_check success va: %x, len: %x\n", va, len);
		return 0;
	}
	
	void page_fault_handler(struct Trapframe *tf)
	{
		uint32_t fault_va;

		// Read processor's CR2 register to find the faulting address
		fault_va = rcr2();

		// Handle kernel-mode page faults.
        	if ((tf->tf_cs & 3) == 0)  
                	panic("Kernel page fault!");
	 
		cprintf("[%08x] user fault va %08x ip %08x\n",
		curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
		env_destroy(curenv);
	}
