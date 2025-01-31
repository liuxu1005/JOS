// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
                panic("sys_page_alloc fails\n");
        memmove(PFTEMP, radd, PGSIZE);
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
                panic("sys_page_map fails\n");
        sys_page_unmap(0, PFTEMP); 
               
	//panic("pgfault not implemented");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
        if(uvpt[pn] & PTE_SHARE) {
                 if((r = sys_page_map(0, add, envid, add, uvpt[pn]&PTE_SYSCALL)) < 0)
                        panic("sys_page_map on new page fails %d \n", r);
        } else if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
                        panic("sys_page_map on new page fails %d \n", r);
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
                        panic("sys_page_map on current page fails %d\n", r);
        } else if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
                        panic("sys_page_map on new page fails %d\n", r);
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
        envid_t forkid = sys_exofork();
        if (forkid < 0)
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
                panic("user stack alloc failure\n");	
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
                panic("set pgfault upcall fails %d\n", forkid);
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
                panic("set %d runnable fails\n", forkid);
        return forkid;
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
