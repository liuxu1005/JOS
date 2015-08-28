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


