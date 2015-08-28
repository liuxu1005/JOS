Test Result

	internal FS tests [fs/test.c]: OK (2.8s) 
  	fs i/o: OK 
  	check_bc: OK 
  	check_super: OK 
  	check_bitmap: OK 
  	alloc_block: OK 
  	file_open: OK 
  	file_get_block: OK 
  	file_flush/file_truncate/file rewrite: OK 
	testfile: OK (2.3s) 
  	serve_open/file_stat/file_close: OK 
  	file_read: OK 
  	file_write: OK 
  	file_read after file_write: OK 
  	open: OK 
  	large file: OK 
	spawn via spawnhello: OK (1.5s) 
	PTE_SHARE [testpteshare]: OK (2.6s) 
	PTE_SHARE [testfdsharing]: OK (1.6s) 
	start the shell [icode]: OK (2.3s) 
	testshell: OK (3.0s) 
	primespipe: OK (10.8s) 
	Score: 145/145

The File System

Disk Access

	void env_create(uint8_t *binary, enum EnvType type)
	{
		// LAB 3: Your code here.
	        struct Env *e;
	        int tmp;
	        if((tmp = env_alloc(&e, 0)) != 0)
	               panic("evn create fails!\n");
	       
	
		// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
		// LAB 5: Your code here.
	        if (type == ENV_TYPE_FS)
	                e->env_tf.tf_eflags |= FL_IOPL_MASK;
	        e->env_type =type;
	        load_icode(e, binary);
	 
	}

The Block Cache

	static void
	bc_pgfault(struct UTrapframe *utf)
	{
		void *addr = (void *) utf->utf_fault_va;
		uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
		int r;
	
		// Check that the fault was within the block cache region
		if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
			panic("page fault in FS: eip %08x, va %08x, err %04x",
			      utf->utf_eip, addr, utf->utf_err);
	
		// Sanity check the block number.
		if (super && blockno >= super->s_nblocks)
			panic("reading non-existent block %08x\n", blockno);
	
		// LAB 5: you code here:
	        addr = ROUNDDOWN(addr, PGSIZE);
	        if(sys_page_alloc(0, addr, PTE_U | PTE_W | PTE_P) < 0)
	                panic("alloc disk map page fails\n");
	        if ((r = ide_read(blockno*BLKSECTS, addr, BLKSECTS)) < 0) 
	                panic("ide_read: %e", r);
		// Clear the dirty bit for the disk block page since we just read the
		// block from disk
		if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
			panic("in bc_pgfault, sys_page_map: %e", r);
	
		// Check that the block we read was allocated. (exercise for
		// the reader: why do we do this *after* reading the block
		// in?)
		if (bitmap && block_is_free(blockno))
			panic("reading free block %08x\n", blockno);
	}
	
	void
	flush_block(void *addr)
	{
		uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	
		if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
			panic("flush_block of bad va %08x", addr);
	
		// LAB 5: Your code here.
	        if(va_is_mapped(addr) && va_is_dirty(addr)) {
	                int r;
	                addr = ROUNDDOWN(addr, PGSIZE);
	                if((r = ide_write(blockno*BLKSECTS, addr, BLKSECTS)) < 0)
	                        panic("ide_write: %e", r);
	                if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
			        panic("in flush_block, sys_page_map: %e", r);
	          //cprintf("after flush %d", uvpt[PGNUM(addr)] & PTE_D);
	        }
		//panic("flush_block not implemented");
	}

The file system interface

Spawning Processes

	sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
	{
		// LAB 5: Your code here.
		// Remember to check whether the user has supplied us with a good
		// address!
		//panic("sys_env_set_trapframe not implemented");
	        struct Env *newenv;
	        int ret;
	        if((ret = envid2env(envid, &newenv, 1)) < 0)  
	                return ret;
	        user_mem_assert(newenv, tf, sizeof(struct Trapframe), PTE_U);
	        newenv->env_tf = *tf;
		newenv->env_tf.tf_eflags |= FL_IF;
	        newenv->env_tf.tf_cs = GD_UT | 3;	
	        return 0;
	}
