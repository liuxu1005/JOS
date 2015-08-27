
obj/user/faultevilhandler:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 32 01 00 00       	call   800179 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 2c 02 00 00       	call   800282 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
  800060:	83 c4 10             	add    $0x10,%esp
}
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800070:	e8 c6 00 00 00       	call   80013b <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
  8000a1:	83 c4 10             	add    $0x10,%esp
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 42 00 00 00       	call   8000fa <sys_env_destroy>
  8000b8:	83 c4 10             	add    $0x10,%esp
}
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 d1                	mov    %edx,%ecx
  8000ed:	89 d3                	mov    %edx,%ebx
  8000ef:	89 d7                	mov    %edx,%edi
  8000f1:	89 d6                	mov    %edx,%esi
  8000f3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800103:	b9 00 00 00 00       	mov    $0x0,%ecx
  800108:	b8 03 00 00 00       	mov    $0x3,%eax
  80010d:	8b 55 08             	mov    0x8(%ebp),%edx
  800110:	89 cb                	mov    %ecx,%ebx
  800112:	89 cf                	mov    %ecx,%edi
  800114:	89 ce                	mov    %ecx,%esi
  800116:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800118:	85 c0                	test   %eax,%eax
  80011a:	7e 17                	jle    800133 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011c:	83 ec 0c             	sub    $0xc,%esp
  80011f:	50                   	push   %eax
  800120:	6a 03                	push   $0x3
  800122:	68 aa 0f 80 00       	push   $0x800faa
  800127:	6a 23                	push   $0x23
  800129:	68 c7 0f 80 00       	push   $0x800fc7
  80012e:	e8 f5 01 00 00       	call   800328 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7e 17                	jle    8001b4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	83 ec 0c             	sub    $0xc,%esp
  8001a0:	50                   	push   %eax
  8001a1:	6a 04                	push   $0x4
  8001a3:	68 aa 0f 80 00       	push   $0x800faa
  8001a8:	6a 23                	push   $0x23
  8001aa:	68 c7 0f 80 00       	push   $0x800fc7
  8001af:	e8 74 01 00 00       	call   800328 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001db:	85 c0                	test   %eax,%eax
  8001dd:	7e 17                	jle    8001f6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	50                   	push   %eax
  8001e3:	6a 05                	push   $0x5
  8001e5:	68 aa 0f 80 00       	push   $0x800faa
  8001ea:	6a 23                	push   $0x23
  8001ec:	68 c7 0f 80 00       	push   $0x800fc7
  8001f1:	e8 32 01 00 00       	call   800328 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020c:	b8 06 00 00 00       	mov    $0x6,%eax
  800211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	89 df                	mov    %ebx,%edi
  800219:	89 de                	mov    %ebx,%esi
  80021b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80021d:	85 c0                	test   %eax,%eax
  80021f:	7e 17                	jle    800238 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800221:	83 ec 0c             	sub    $0xc,%esp
  800224:	50                   	push   %eax
  800225:	6a 06                	push   $0x6
  800227:	68 aa 0f 80 00       	push   $0x800faa
  80022c:	6a 23                	push   $0x23
  80022e:	68 c7 0f 80 00       	push   $0x800fc7
  800233:	e8 f0 00 00 00       	call   800328 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	b8 08 00 00 00       	mov    $0x8,%eax
  800253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	89 df                	mov    %ebx,%edi
  80025b:	89 de                	mov    %ebx,%esi
  80025d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80025f:	85 c0                	test   %eax,%eax
  800261:	7e 17                	jle    80027a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	50                   	push   %eax
  800267:	6a 08                	push   $0x8
  800269:	68 aa 0f 80 00       	push   $0x800faa
  80026e:	6a 23                	push   $0x23
  800270:	68 c7 0f 80 00       	push   $0x800fc7
  800275:	e8 ae 00 00 00       	call   800328 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800290:	b8 09 00 00 00       	mov    $0x9,%eax
  800295:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800298:	8b 55 08             	mov    0x8(%ebp),%edx
  80029b:	89 df                	mov    %ebx,%edi
  80029d:	89 de                	mov    %ebx,%esi
  80029f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	7e 17                	jle    8002bc <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a5:	83 ec 0c             	sub    $0xc,%esp
  8002a8:	50                   	push   %eax
  8002a9:	6a 09                	push   $0x9
  8002ab:	68 aa 0f 80 00       	push   $0x800faa
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 c7 0f 80 00       	push   $0x800fc7
  8002b7:	e8 6c 00 00 00       	call   800328 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ca:	be 00 00 00 00       	mov    $0x0,%esi
  8002cf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002dd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002e0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	89 cb                	mov    %ecx,%ebx
  8002ff:	89 cf                	mov    %ecx,%edi
  800301:	89 ce                	mov    %ecx,%esi
  800303:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800305:	85 c0                	test   %eax,%eax
  800307:	7e 17                	jle    800320 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800309:	83 ec 0c             	sub    $0xc,%esp
  80030c:	50                   	push   %eax
  80030d:	6a 0c                	push   $0xc
  80030f:	68 aa 0f 80 00       	push   $0x800faa
  800314:	6a 23                	push   $0x23
  800316:	68 c7 0f 80 00       	push   $0x800fc7
  80031b:	e8 08 00 00 00       	call   800328 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800320:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5f                   	pop    %edi
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80032d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800330:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800336:	e8 00 fe ff ff       	call   80013b <sys_getenvid>
  80033b:	83 ec 0c             	sub    $0xc,%esp
  80033e:	ff 75 0c             	pushl  0xc(%ebp)
  800341:	ff 75 08             	pushl  0x8(%ebp)
  800344:	56                   	push   %esi
  800345:	50                   	push   %eax
  800346:	68 d8 0f 80 00       	push   $0x800fd8
  80034b:	e8 b1 00 00 00       	call   800401 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800350:	83 c4 18             	add    $0x18,%esp
  800353:	53                   	push   %ebx
  800354:	ff 75 10             	pushl  0x10(%ebp)
  800357:	e8 54 00 00 00       	call   8003b0 <vcprintf>
	cprintf("\n");
  80035c:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  800363:	e8 99 00 00 00       	call   800401 <cprintf>
  800368:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80036b:	cc                   	int3   
  80036c:	eb fd                	jmp    80036b <_panic+0x43>

0080036e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	53                   	push   %ebx
  800372:	83 ec 04             	sub    $0x4,%esp
  800375:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800378:	8b 13                	mov    (%ebx),%edx
  80037a:	8d 42 01             	lea    0x1(%edx),%eax
  80037d:	89 03                	mov    %eax,(%ebx)
  80037f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800382:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800386:	3d ff 00 00 00       	cmp    $0xff,%eax
  80038b:	75 1a                	jne    8003a7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80038d:	83 ec 08             	sub    $0x8,%esp
  800390:	68 ff 00 00 00       	push   $0xff
  800395:	8d 43 08             	lea    0x8(%ebx),%eax
  800398:	50                   	push   %eax
  800399:	e8 1f fd ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  80039e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ae:	c9                   	leave  
  8003af:	c3                   	ret    

008003b0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c0:	00 00 00 
	b.cnt = 0;
  8003c3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003cd:	ff 75 0c             	pushl  0xc(%ebp)
  8003d0:	ff 75 08             	pushl  0x8(%ebp)
  8003d3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d9:	50                   	push   %eax
  8003da:	68 6e 03 80 00       	push   $0x80036e
  8003df:	e8 4f 01 00 00       	call   800533 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e4:	83 c4 08             	add    $0x8,%esp
  8003e7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ed:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f3:	50                   	push   %eax
  8003f4:	e8 c4 fc ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  8003f9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ff:	c9                   	leave  
  800400:	c3                   	ret    

00800401 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800407:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80040a:	50                   	push   %eax
  80040b:	ff 75 08             	pushl  0x8(%ebp)
  80040e:	e8 9d ff ff ff       	call   8003b0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800413:	c9                   	leave  
  800414:	c3                   	ret    

00800415 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	57                   	push   %edi
  800419:	56                   	push   %esi
  80041a:	53                   	push   %ebx
  80041b:	83 ec 1c             	sub    $0x1c,%esp
  80041e:	89 c7                	mov    %eax,%edi
  800420:	89 d6                	mov    %edx,%esi
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	8b 55 0c             	mov    0xc(%ebp),%edx
  800428:	89 d1                	mov    %edx,%ecx
  80042a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80042d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800430:	8b 45 10             	mov    0x10(%ebp),%eax
  800433:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800436:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800439:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800440:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800443:	72 05                	jb     80044a <printnum+0x35>
  800445:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800448:	77 3e                	ja     800488 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80044a:	83 ec 0c             	sub    $0xc,%esp
  80044d:	ff 75 18             	pushl  0x18(%ebp)
  800450:	83 eb 01             	sub    $0x1,%ebx
  800453:	53                   	push   %ebx
  800454:	50                   	push   %eax
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 e4             	pushl  -0x1c(%ebp)
  80045b:	ff 75 e0             	pushl  -0x20(%ebp)
  80045e:	ff 75 dc             	pushl  -0x24(%ebp)
  800461:	ff 75 d8             	pushl  -0x28(%ebp)
  800464:	e8 77 08 00 00       	call   800ce0 <__udivdi3>
  800469:	83 c4 18             	add    $0x18,%esp
  80046c:	52                   	push   %edx
  80046d:	50                   	push   %eax
  80046e:	89 f2                	mov    %esi,%edx
  800470:	89 f8                	mov    %edi,%eax
  800472:	e8 9e ff ff ff       	call   800415 <printnum>
  800477:	83 c4 20             	add    $0x20,%esp
  80047a:	eb 13                	jmp    80048f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	56                   	push   %esi
  800480:	ff 75 18             	pushl  0x18(%ebp)
  800483:	ff d7                	call   *%edi
  800485:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800488:	83 eb 01             	sub    $0x1,%ebx
  80048b:	85 db                	test   %ebx,%ebx
  80048d:	7f ed                	jg     80047c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	56                   	push   %esi
  800493:	83 ec 04             	sub    $0x4,%esp
  800496:	ff 75 e4             	pushl  -0x1c(%ebp)
  800499:	ff 75 e0             	pushl  -0x20(%ebp)
  80049c:	ff 75 dc             	pushl  -0x24(%ebp)
  80049f:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a2:	e8 69 09 00 00       	call   800e10 <__umoddi3>
  8004a7:	83 c4 14             	add    $0x14,%esp
  8004aa:	0f be 80 fe 0f 80 00 	movsbl 0x800ffe(%eax),%eax
  8004b1:	50                   	push   %eax
  8004b2:	ff d7                	call   *%edi
  8004b4:	83 c4 10             	add    $0x10,%esp
}
  8004b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ba:	5b                   	pop    %ebx
  8004bb:	5e                   	pop    %esi
  8004bc:	5f                   	pop    %edi
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c2:	83 fa 01             	cmp    $0x1,%edx
  8004c5:	7e 0e                	jle    8004d5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 02                	mov    (%edx),%eax
  8004d0:	8b 52 04             	mov    0x4(%edx),%edx
  8004d3:	eb 22                	jmp    8004f7 <getuint+0x38>
	else if (lflag)
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	74 10                	je     8004e9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d9:	8b 10                	mov    (%eax),%edx
  8004db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004de:	89 08                	mov    %ecx,(%eax)
  8004e0:	8b 02                	mov    (%edx),%eax
  8004e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e7:	eb 0e                	jmp    8004f7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e9:	8b 10                	mov    (%eax),%edx
  8004eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ee:	89 08                	mov    %ecx,(%eax)
  8004f0:	8b 02                	mov    (%edx),%eax
  8004f2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f7:	5d                   	pop    %ebp
  8004f8:	c3                   	ret    

008004f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f9:	55                   	push   %ebp
  8004fa:	89 e5                	mov    %esp,%ebp
  8004fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800503:	8b 10                	mov    (%eax),%edx
  800505:	3b 50 04             	cmp    0x4(%eax),%edx
  800508:	73 0a                	jae    800514 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050d:	89 08                	mov    %ecx,(%eax)
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	88 02                	mov    %al,(%edx)
}
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80051c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80051f:	50                   	push   %eax
  800520:	ff 75 10             	pushl  0x10(%ebp)
  800523:	ff 75 0c             	pushl  0xc(%ebp)
  800526:	ff 75 08             	pushl  0x8(%ebp)
  800529:	e8 05 00 00 00       	call   800533 <vprintfmt>
	va_end(ap);
  80052e:	83 c4 10             	add    $0x10,%esp
}
  800531:	c9                   	leave  
  800532:	c3                   	ret    

00800533 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800533:	55                   	push   %ebp
  800534:	89 e5                	mov    %esp,%ebp
  800536:	57                   	push   %edi
  800537:	56                   	push   %esi
  800538:	53                   	push   %ebx
  800539:	83 ec 2c             	sub    $0x2c,%esp
  80053c:	8b 75 08             	mov    0x8(%ebp),%esi
  80053f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800542:	8b 7d 10             	mov    0x10(%ebp),%edi
  800545:	eb 12                	jmp    800559 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800547:	85 c0                	test   %eax,%eax
  800549:	0f 84 90 03 00 00    	je     8008df <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	53                   	push   %ebx
  800553:	50                   	push   %eax
  800554:	ff d6                	call   *%esi
  800556:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800559:	83 c7 01             	add    $0x1,%edi
  80055c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800560:	83 f8 25             	cmp    $0x25,%eax
  800563:	75 e2                	jne    800547 <vprintfmt+0x14>
  800565:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800569:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800570:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800577:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80057e:	ba 00 00 00 00       	mov    $0x0,%edx
  800583:	eb 07                	jmp    80058c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800585:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800588:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058c:	8d 47 01             	lea    0x1(%edi),%eax
  80058f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800592:	0f b6 07             	movzbl (%edi),%eax
  800595:	0f b6 c8             	movzbl %al,%ecx
  800598:	83 e8 23             	sub    $0x23,%eax
  80059b:	3c 55                	cmp    $0x55,%al
  80059d:	0f 87 21 03 00 00    	ja     8008c4 <vprintfmt+0x391>
  8005a3:	0f b6 c0             	movzbl %al,%eax
  8005a6:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8005ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b4:	eb d6                	jmp    80058c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005c8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005cb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005ce:	83 fa 09             	cmp    $0x9,%edx
  8005d1:	77 39                	ja     80060c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005d6:	eb e9                	jmp    8005c1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 48 04             	lea    0x4(%eax),%ecx
  8005de:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e9:	eb 27                	jmp    800612 <vprintfmt+0xdf>
  8005eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f5:	0f 49 c8             	cmovns %eax,%ecx
  8005f8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fe:	eb 8c                	jmp    80058c <vprintfmt+0x59>
  800600:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800603:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80060a:	eb 80                	jmp    80058c <vprintfmt+0x59>
  80060c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80060f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800612:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800616:	0f 89 70 ff ff ff    	jns    80058c <vprintfmt+0x59>
				width = precision, precision = -1;
  80061c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80061f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800622:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800629:	e9 5e ff ff ff       	jmp    80058c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80062e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800631:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800634:	e9 53 ff ff ff       	jmp    80058c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8d 50 04             	lea    0x4(%eax),%edx
  80063f:	89 55 14             	mov    %edx,0x14(%ebp)
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	53                   	push   %ebx
  800646:	ff 30                	pushl  (%eax)
  800648:	ff d6                	call   *%esi
			break;
  80064a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800650:	e9 04 ff ff ff       	jmp    800559 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 50 04             	lea    0x4(%eax),%edx
  80065b:	89 55 14             	mov    %edx,0x14(%ebp)
  80065e:	8b 00                	mov    (%eax),%eax
  800660:	99                   	cltd   
  800661:	31 d0                	xor    %edx,%eax
  800663:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800665:	83 f8 09             	cmp    $0x9,%eax
  800668:	7f 0b                	jg     800675 <vprintfmt+0x142>
  80066a:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	75 18                	jne    80068d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800675:	50                   	push   %eax
  800676:	68 16 10 80 00       	push   $0x801016
  80067b:	53                   	push   %ebx
  80067c:	56                   	push   %esi
  80067d:	e8 94 fe ff ff       	call   800516 <printfmt>
  800682:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800685:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800688:	e9 cc fe ff ff       	jmp    800559 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80068d:	52                   	push   %edx
  80068e:	68 1f 10 80 00       	push   $0x80101f
  800693:	53                   	push   %ebx
  800694:	56                   	push   %esi
  800695:	e8 7c fe ff ff       	call   800516 <printfmt>
  80069a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a0:	e9 b4 fe ff ff       	jmp    800559 <vprintfmt+0x26>
  8006a5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b9:	85 ff                	test   %edi,%edi
  8006bb:	ba 0f 10 80 00       	mov    $0x80100f,%edx
  8006c0:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8006c3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c7:	0f 84 92 00 00 00    	je     80075f <vprintfmt+0x22c>
  8006cd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006d1:	0f 8e 96 00 00 00    	jle    80076d <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	51                   	push   %ecx
  8006db:	57                   	push   %edi
  8006dc:	e8 86 02 00 00       	call   800967 <strnlen>
  8006e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006e4:	29 c1                	sub    %eax,%ecx
  8006e6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ec:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f8:	eb 0f                	jmp    800709 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800701:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800703:	83 ef 01             	sub    $0x1,%edi
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	85 ff                	test   %edi,%edi
  80070b:	7f ed                	jg     8006fa <vprintfmt+0x1c7>
  80070d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800710:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800713:	85 c9                	test   %ecx,%ecx
  800715:	b8 00 00 00 00       	mov    $0x0,%eax
  80071a:	0f 49 c1             	cmovns %ecx,%eax
  80071d:	29 c1                	sub    %eax,%ecx
  80071f:	89 75 08             	mov    %esi,0x8(%ebp)
  800722:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800725:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800728:	89 cb                	mov    %ecx,%ebx
  80072a:	eb 4d                	jmp    800779 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80072c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800730:	74 1b                	je     80074d <vprintfmt+0x21a>
  800732:	0f be c0             	movsbl %al,%eax
  800735:	83 e8 20             	sub    $0x20,%eax
  800738:	83 f8 5e             	cmp    $0x5e,%eax
  80073b:	76 10                	jbe    80074d <vprintfmt+0x21a>
					putch('?', putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	ff 75 0c             	pushl  0xc(%ebp)
  800743:	6a 3f                	push   $0x3f
  800745:	ff 55 08             	call   *0x8(%ebp)
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	eb 0d                	jmp    80075a <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	52                   	push   %edx
  800754:	ff 55 08             	call   *0x8(%ebp)
  800757:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80075a:	83 eb 01             	sub    $0x1,%ebx
  80075d:	eb 1a                	jmp    800779 <vprintfmt+0x246>
  80075f:	89 75 08             	mov    %esi,0x8(%ebp)
  800762:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800765:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800768:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80076b:	eb 0c                	jmp    800779 <vprintfmt+0x246>
  80076d:	89 75 08             	mov    %esi,0x8(%ebp)
  800770:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800773:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800776:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800779:	83 c7 01             	add    $0x1,%edi
  80077c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800780:	0f be d0             	movsbl %al,%edx
  800783:	85 d2                	test   %edx,%edx
  800785:	74 23                	je     8007aa <vprintfmt+0x277>
  800787:	85 f6                	test   %esi,%esi
  800789:	78 a1                	js     80072c <vprintfmt+0x1f9>
  80078b:	83 ee 01             	sub    $0x1,%esi
  80078e:	79 9c                	jns    80072c <vprintfmt+0x1f9>
  800790:	89 df                	mov    %ebx,%edi
  800792:	8b 75 08             	mov    0x8(%ebp),%esi
  800795:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800798:	eb 18                	jmp    8007b2 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80079a:	83 ec 08             	sub    $0x8,%esp
  80079d:	53                   	push   %ebx
  80079e:	6a 20                	push   $0x20
  8007a0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a2:	83 ef 01             	sub    $0x1,%edi
  8007a5:	83 c4 10             	add    $0x10,%esp
  8007a8:	eb 08                	jmp    8007b2 <vprintfmt+0x27f>
  8007aa:	89 df                	mov    %ebx,%edi
  8007ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8007af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b2:	85 ff                	test   %edi,%edi
  8007b4:	7f e4                	jg     80079a <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b9:	e9 9b fd ff ff       	jmp    800559 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007be:	83 fa 01             	cmp    $0x1,%edx
  8007c1:	7e 16                	jle    8007d9 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8d 50 08             	lea    0x8(%eax),%edx
  8007c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cc:	8b 50 04             	mov    0x4(%eax),%edx
  8007cf:	8b 00                	mov    (%eax),%eax
  8007d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d7:	eb 32                	jmp    80080b <vprintfmt+0x2d8>
	else if (lflag)
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	74 18                	je     8007f5 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e6:	8b 00                	mov    (%eax),%eax
  8007e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007eb:	89 c1                	mov    %eax,%ecx
  8007ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f3:	eb 16                	jmp    80080b <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8d 50 04             	lea    0x4(%eax),%edx
  8007fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fe:	8b 00                	mov    (%eax),%eax
  800800:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800803:	89 c1                	mov    %eax,%ecx
  800805:	c1 f9 1f             	sar    $0x1f,%ecx
  800808:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80080b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800811:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800816:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80081a:	79 74                	jns    800890 <vprintfmt+0x35d>
				putch('-', putdat);
  80081c:	83 ec 08             	sub    $0x8,%esp
  80081f:	53                   	push   %ebx
  800820:	6a 2d                	push   $0x2d
  800822:	ff d6                	call   *%esi
				num = -(long long) num;
  800824:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800827:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80082a:	f7 d8                	neg    %eax
  80082c:	83 d2 00             	adc    $0x0,%edx
  80082f:	f7 da                	neg    %edx
  800831:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800834:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800839:	eb 55                	jmp    800890 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80083b:	8d 45 14             	lea    0x14(%ebp),%eax
  80083e:	e8 7c fc ff ff       	call   8004bf <getuint>
			base = 10;
  800843:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800848:	eb 46                	jmp    800890 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80084a:	8d 45 14             	lea    0x14(%ebp),%eax
  80084d:	e8 6d fc ff ff       	call   8004bf <getuint>
                        base = 8;
  800852:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800857:	eb 37                	jmp    800890 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	53                   	push   %ebx
  80085d:	6a 30                	push   $0x30
  80085f:	ff d6                	call   *%esi
			putch('x', putdat);
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	53                   	push   %ebx
  800865:	6a 78                	push   $0x78
  800867:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800869:	8b 45 14             	mov    0x14(%ebp),%eax
  80086c:	8d 50 04             	lea    0x4(%eax),%edx
  80086f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800872:	8b 00                	mov    (%eax),%eax
  800874:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800879:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80087c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800881:	eb 0d                	jmp    800890 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800883:	8d 45 14             	lea    0x14(%ebp),%eax
  800886:	e8 34 fc ff ff       	call   8004bf <getuint>
			base = 16;
  80088b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800890:	83 ec 0c             	sub    $0xc,%esp
  800893:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800897:	57                   	push   %edi
  800898:	ff 75 e0             	pushl  -0x20(%ebp)
  80089b:	51                   	push   %ecx
  80089c:	52                   	push   %edx
  80089d:	50                   	push   %eax
  80089e:	89 da                	mov    %ebx,%edx
  8008a0:	89 f0                	mov    %esi,%eax
  8008a2:	e8 6e fb ff ff       	call   800415 <printnum>
			break;
  8008a7:	83 c4 20             	add    $0x20,%esp
  8008aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ad:	e9 a7 fc ff ff       	jmp    800559 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008b2:	83 ec 08             	sub    $0x8,%esp
  8008b5:	53                   	push   %ebx
  8008b6:	51                   	push   %ecx
  8008b7:	ff d6                	call   *%esi
			break;
  8008b9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008bf:	e9 95 fc ff ff       	jmp    800559 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008c4:	83 ec 08             	sub    $0x8,%esp
  8008c7:	53                   	push   %ebx
  8008c8:	6a 25                	push   $0x25
  8008ca:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	eb 03                	jmp    8008d4 <vprintfmt+0x3a1>
  8008d1:	83 ef 01             	sub    $0x1,%edi
  8008d4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008d8:	75 f7                	jne    8008d1 <vprintfmt+0x39e>
  8008da:	e9 7a fc ff ff       	jmp    800559 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5f                   	pop    %edi
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	83 ec 18             	sub    $0x18,%esp
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800904:	85 c0                	test   %eax,%eax
  800906:	74 26                	je     80092e <vsnprintf+0x47>
  800908:	85 d2                	test   %edx,%edx
  80090a:	7e 22                	jle    80092e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80090c:	ff 75 14             	pushl  0x14(%ebp)
  80090f:	ff 75 10             	pushl  0x10(%ebp)
  800912:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800915:	50                   	push   %eax
  800916:	68 f9 04 80 00       	push   $0x8004f9
  80091b:	e8 13 fc ff ff       	call   800533 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800920:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800923:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800926:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800929:	83 c4 10             	add    $0x10,%esp
  80092c:	eb 05                	jmp    800933 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80092e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800933:	c9                   	leave  
  800934:	c3                   	ret    

00800935 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80093b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80093e:	50                   	push   %eax
  80093f:	ff 75 10             	pushl  0x10(%ebp)
  800942:	ff 75 0c             	pushl  0xc(%ebp)
  800945:	ff 75 08             	pushl  0x8(%ebp)
  800948:	e8 9a ff ff ff       	call   8008e7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800955:	b8 00 00 00 00       	mov    $0x0,%eax
  80095a:	eb 03                	jmp    80095f <strlen+0x10>
		n++;
  80095c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80095f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800963:	75 f7                	jne    80095c <strlen+0xd>
		n++;
	return n;
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800970:	ba 00 00 00 00       	mov    $0x0,%edx
  800975:	eb 03                	jmp    80097a <strnlen+0x13>
		n++;
  800977:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80097a:	39 c2                	cmp    %eax,%edx
  80097c:	74 08                	je     800986 <strnlen+0x1f>
  80097e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800982:	75 f3                	jne    800977 <strnlen+0x10>
  800984:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	53                   	push   %ebx
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800992:	89 c2                	mov    %eax,%edx
  800994:	83 c2 01             	add    $0x1,%edx
  800997:	83 c1 01             	add    $0x1,%ecx
  80099a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80099e:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a1:	84 db                	test   %bl,%bl
  8009a3:	75 ef                	jne    800994 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009a5:	5b                   	pop    %ebx
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	53                   	push   %ebx
  8009ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009af:	53                   	push   %ebx
  8009b0:	e8 9a ff ff ff       	call   80094f <strlen>
  8009b5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009b8:	ff 75 0c             	pushl  0xc(%ebp)
  8009bb:	01 d8                	add    %ebx,%eax
  8009bd:	50                   	push   %eax
  8009be:	e8 c5 ff ff ff       	call   800988 <strcpy>
	return dst;
}
  8009c3:	89 d8                	mov    %ebx,%eax
  8009c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c8:	c9                   	leave  
  8009c9:	c3                   	ret    

008009ca <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	56                   	push   %esi
  8009ce:	53                   	push   %ebx
  8009cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d5:	89 f3                	mov    %esi,%ebx
  8009d7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009da:	89 f2                	mov    %esi,%edx
  8009dc:	eb 0f                	jmp    8009ed <strncpy+0x23>
		*dst++ = *src;
  8009de:	83 c2 01             	add    $0x1,%edx
  8009e1:	0f b6 01             	movzbl (%ecx),%eax
  8009e4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009e7:	80 39 01             	cmpb   $0x1,(%ecx)
  8009ea:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ed:	39 da                	cmp    %ebx,%edx
  8009ef:	75 ed                	jne    8009de <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009f1:	89 f0                	mov    %esi,%eax
  8009f3:	5b                   	pop    %ebx
  8009f4:	5e                   	pop    %esi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a02:	8b 55 10             	mov    0x10(%ebp),%edx
  800a05:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a07:	85 d2                	test   %edx,%edx
  800a09:	74 21                	je     800a2c <strlcpy+0x35>
  800a0b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a0f:	89 f2                	mov    %esi,%edx
  800a11:	eb 09                	jmp    800a1c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a13:	83 c2 01             	add    $0x1,%edx
  800a16:	83 c1 01             	add    $0x1,%ecx
  800a19:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a1c:	39 c2                	cmp    %eax,%edx
  800a1e:	74 09                	je     800a29 <strlcpy+0x32>
  800a20:	0f b6 19             	movzbl (%ecx),%ebx
  800a23:	84 db                	test   %bl,%bl
  800a25:	75 ec                	jne    800a13 <strlcpy+0x1c>
  800a27:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a29:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a2c:	29 f0                	sub    %esi,%eax
}
  800a2e:	5b                   	pop    %ebx
  800a2f:	5e                   	pop    %esi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a38:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a3b:	eb 06                	jmp    800a43 <strcmp+0x11>
		p++, q++;
  800a3d:	83 c1 01             	add    $0x1,%ecx
  800a40:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a43:	0f b6 01             	movzbl (%ecx),%eax
  800a46:	84 c0                	test   %al,%al
  800a48:	74 04                	je     800a4e <strcmp+0x1c>
  800a4a:	3a 02                	cmp    (%edx),%al
  800a4c:	74 ef                	je     800a3d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4e:	0f b6 c0             	movzbl %al,%eax
  800a51:	0f b6 12             	movzbl (%edx),%edx
  800a54:	29 d0                	sub    %edx,%eax
}
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	53                   	push   %ebx
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a62:	89 c3                	mov    %eax,%ebx
  800a64:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a67:	eb 06                	jmp    800a6f <strncmp+0x17>
		n--, p++, q++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a6f:	39 d8                	cmp    %ebx,%eax
  800a71:	74 15                	je     800a88 <strncmp+0x30>
  800a73:	0f b6 08             	movzbl (%eax),%ecx
  800a76:	84 c9                	test   %cl,%cl
  800a78:	74 04                	je     800a7e <strncmp+0x26>
  800a7a:	3a 0a                	cmp    (%edx),%cl
  800a7c:	74 eb                	je     800a69 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7e:	0f b6 00             	movzbl (%eax),%eax
  800a81:	0f b6 12             	movzbl (%edx),%edx
  800a84:	29 d0                	sub    %edx,%eax
  800a86:	eb 05                	jmp    800a8d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a88:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a9a:	eb 07                	jmp    800aa3 <strchr+0x13>
		if (*s == c)
  800a9c:	38 ca                	cmp    %cl,%dl
  800a9e:	74 0f                	je     800aaf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aa0:	83 c0 01             	add    $0x1,%eax
  800aa3:	0f b6 10             	movzbl (%eax),%edx
  800aa6:	84 d2                	test   %dl,%dl
  800aa8:	75 f2                	jne    800a9c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800abb:	eb 03                	jmp    800ac0 <strfind+0xf>
  800abd:	83 c0 01             	add    $0x1,%eax
  800ac0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ac3:	84 d2                	test   %dl,%dl
  800ac5:	74 04                	je     800acb <strfind+0x1a>
  800ac7:	38 ca                	cmp    %cl,%dl
  800ac9:	75 f2                	jne    800abd <strfind+0xc>
			break;
	return (char *) s;
}
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad9:	85 c9                	test   %ecx,%ecx
  800adb:	74 36                	je     800b13 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800add:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae3:	75 28                	jne    800b0d <memset+0x40>
  800ae5:	f6 c1 03             	test   $0x3,%cl
  800ae8:	75 23                	jne    800b0d <memset+0x40>
		c &= 0xFF;
  800aea:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aee:	89 d3                	mov    %edx,%ebx
  800af0:	c1 e3 08             	shl    $0x8,%ebx
  800af3:	89 d6                	mov    %edx,%esi
  800af5:	c1 e6 18             	shl    $0x18,%esi
  800af8:	89 d0                	mov    %edx,%eax
  800afa:	c1 e0 10             	shl    $0x10,%eax
  800afd:	09 f0                	or     %esi,%eax
  800aff:	09 c2                	or     %eax,%edx
  800b01:	89 d0                	mov    %edx,%eax
  800b03:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b05:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b08:	fc                   	cld    
  800b09:	f3 ab                	rep stos %eax,%es:(%edi)
  800b0b:	eb 06                	jmp    800b13 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b10:	fc                   	cld    
  800b11:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b13:	89 f8                	mov    %edi,%eax
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b28:	39 c6                	cmp    %eax,%esi
  800b2a:	73 35                	jae    800b61 <memmove+0x47>
  800b2c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b2f:	39 d0                	cmp    %edx,%eax
  800b31:	73 2e                	jae    800b61 <memmove+0x47>
		s += n;
		d += n;
  800b33:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b36:	89 d6                	mov    %edx,%esi
  800b38:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b40:	75 13                	jne    800b55 <memmove+0x3b>
  800b42:	f6 c1 03             	test   $0x3,%cl
  800b45:	75 0e                	jne    800b55 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b47:	83 ef 04             	sub    $0x4,%edi
  800b4a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b4d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b50:	fd                   	std    
  800b51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b53:	eb 09                	jmp    800b5e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b55:	83 ef 01             	sub    $0x1,%edi
  800b58:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b5b:	fd                   	std    
  800b5c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b5e:	fc                   	cld    
  800b5f:	eb 1d                	jmp    800b7e <memmove+0x64>
  800b61:	89 f2                	mov    %esi,%edx
  800b63:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b65:	f6 c2 03             	test   $0x3,%dl
  800b68:	75 0f                	jne    800b79 <memmove+0x5f>
  800b6a:	f6 c1 03             	test   $0x3,%cl
  800b6d:	75 0a                	jne    800b79 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b6f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b72:	89 c7                	mov    %eax,%edi
  800b74:	fc                   	cld    
  800b75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b77:	eb 05                	jmp    800b7e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b79:	89 c7                	mov    %eax,%edi
  800b7b:	fc                   	cld    
  800b7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b85:	ff 75 10             	pushl  0x10(%ebp)
  800b88:	ff 75 0c             	pushl  0xc(%ebp)
  800b8b:	ff 75 08             	pushl  0x8(%ebp)
  800b8e:	e8 87 ff ff ff       	call   800b1a <memmove>
}
  800b93:	c9                   	leave  
  800b94:	c3                   	ret    

00800b95 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba0:	89 c6                	mov    %eax,%esi
  800ba2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba5:	eb 1a                	jmp    800bc1 <memcmp+0x2c>
		if (*s1 != *s2)
  800ba7:	0f b6 08             	movzbl (%eax),%ecx
  800baa:	0f b6 1a             	movzbl (%edx),%ebx
  800bad:	38 d9                	cmp    %bl,%cl
  800baf:	74 0a                	je     800bbb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bb1:	0f b6 c1             	movzbl %cl,%eax
  800bb4:	0f b6 db             	movzbl %bl,%ebx
  800bb7:	29 d8                	sub    %ebx,%eax
  800bb9:	eb 0f                	jmp    800bca <memcmp+0x35>
		s1++, s2++;
  800bbb:	83 c0 01             	add    $0x1,%eax
  800bbe:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc1:	39 f0                	cmp    %esi,%eax
  800bc3:	75 e2                	jne    800ba7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bd7:	89 c2                	mov    %eax,%edx
  800bd9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bdc:	eb 07                	jmp    800be5 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bde:	38 08                	cmp    %cl,(%eax)
  800be0:	74 07                	je     800be9 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be2:	83 c0 01             	add    $0x1,%eax
  800be5:	39 d0                	cmp    %edx,%eax
  800be7:	72 f5                	jb     800bde <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf7:	eb 03                	jmp    800bfc <strtol+0x11>
		s++;
  800bf9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfc:	0f b6 01             	movzbl (%ecx),%eax
  800bff:	3c 09                	cmp    $0x9,%al
  800c01:	74 f6                	je     800bf9 <strtol+0xe>
  800c03:	3c 20                	cmp    $0x20,%al
  800c05:	74 f2                	je     800bf9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c07:	3c 2b                	cmp    $0x2b,%al
  800c09:	75 0a                	jne    800c15 <strtol+0x2a>
		s++;
  800c0b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c13:	eb 10                	jmp    800c25 <strtol+0x3a>
  800c15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c1a:	3c 2d                	cmp    $0x2d,%al
  800c1c:	75 07                	jne    800c25 <strtol+0x3a>
		s++, neg = 1;
  800c1e:	8d 49 01             	lea    0x1(%ecx),%ecx
  800c21:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c25:	85 db                	test   %ebx,%ebx
  800c27:	0f 94 c0             	sete   %al
  800c2a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c30:	75 19                	jne    800c4b <strtol+0x60>
  800c32:	80 39 30             	cmpb   $0x30,(%ecx)
  800c35:	75 14                	jne    800c4b <strtol+0x60>
  800c37:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c3b:	0f 85 82 00 00 00    	jne    800cc3 <strtol+0xd8>
		s += 2, base = 16;
  800c41:	83 c1 02             	add    $0x2,%ecx
  800c44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c49:	eb 16                	jmp    800c61 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c4b:	84 c0                	test   %al,%al
  800c4d:	74 12                	je     800c61 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c4f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c54:	80 39 30             	cmpb   $0x30,(%ecx)
  800c57:	75 08                	jne    800c61 <strtol+0x76>
		s++, base = 8;
  800c59:	83 c1 01             	add    $0x1,%ecx
  800c5c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c61:	b8 00 00 00 00       	mov    $0x0,%eax
  800c66:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c69:	0f b6 11             	movzbl (%ecx),%edx
  800c6c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c6f:	89 f3                	mov    %esi,%ebx
  800c71:	80 fb 09             	cmp    $0x9,%bl
  800c74:	77 08                	ja     800c7e <strtol+0x93>
			dig = *s - '0';
  800c76:	0f be d2             	movsbl %dl,%edx
  800c79:	83 ea 30             	sub    $0x30,%edx
  800c7c:	eb 22                	jmp    800ca0 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c7e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c81:	89 f3                	mov    %esi,%ebx
  800c83:	80 fb 19             	cmp    $0x19,%bl
  800c86:	77 08                	ja     800c90 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c88:	0f be d2             	movsbl %dl,%edx
  800c8b:	83 ea 57             	sub    $0x57,%edx
  800c8e:	eb 10                	jmp    800ca0 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c90:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c93:	89 f3                	mov    %esi,%ebx
  800c95:	80 fb 19             	cmp    $0x19,%bl
  800c98:	77 16                	ja     800cb0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c9a:	0f be d2             	movsbl %dl,%edx
  800c9d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ca0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ca3:	7d 0f                	jge    800cb4 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ca5:	83 c1 01             	add    $0x1,%ecx
  800ca8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cac:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cae:	eb b9                	jmp    800c69 <strtol+0x7e>
  800cb0:	89 c2                	mov    %eax,%edx
  800cb2:	eb 02                	jmp    800cb6 <strtol+0xcb>
  800cb4:	89 c2                	mov    %eax,%edx

	if (endptr)
  800cb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cba:	74 0d                	je     800cc9 <strtol+0xde>
		*endptr = (char *) s;
  800cbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbf:	89 0e                	mov    %ecx,(%esi)
  800cc1:	eb 06                	jmp    800cc9 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc3:	84 c0                	test   %al,%al
  800cc5:	75 92                	jne    800c59 <strtol+0x6e>
  800cc7:	eb 98                	jmp    800c61 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cc9:	f7 da                	neg    %edx
  800ccb:	85 ff                	test   %edi,%edi
  800ccd:	0f 45 c2             	cmovne %edx,%eax
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    
  800cd5:	66 90                	xchg   %ax,%ax
  800cd7:	66 90                	xchg   %ax,%ax
  800cd9:	66 90                	xchg   %ax,%ax
  800cdb:	66 90                	xchg   %ax,%ax
  800cdd:	66 90                	xchg   %ax,%ax
  800cdf:	90                   	nop

00800ce0 <__udivdi3>:
  800ce0:	55                   	push   %ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	83 ec 10             	sub    $0x10,%esp
  800ce6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800cea:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800cee:	8b 74 24 24          	mov    0x24(%esp),%esi
  800cf2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800cf6:	85 d2                	test   %edx,%edx
  800cf8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cfc:	89 34 24             	mov    %esi,(%esp)
  800cff:	89 c8                	mov    %ecx,%eax
  800d01:	75 35                	jne    800d38 <__udivdi3+0x58>
  800d03:	39 f1                	cmp    %esi,%ecx
  800d05:	0f 87 bd 00 00 00    	ja     800dc8 <__udivdi3+0xe8>
  800d0b:	85 c9                	test   %ecx,%ecx
  800d0d:	89 cd                	mov    %ecx,%ebp
  800d0f:	75 0b                	jne    800d1c <__udivdi3+0x3c>
  800d11:	b8 01 00 00 00       	mov    $0x1,%eax
  800d16:	31 d2                	xor    %edx,%edx
  800d18:	f7 f1                	div    %ecx
  800d1a:	89 c5                	mov    %eax,%ebp
  800d1c:	89 f0                	mov    %esi,%eax
  800d1e:	31 d2                	xor    %edx,%edx
  800d20:	f7 f5                	div    %ebp
  800d22:	89 c6                	mov    %eax,%esi
  800d24:	89 f8                	mov    %edi,%eax
  800d26:	f7 f5                	div    %ebp
  800d28:	89 f2                	mov    %esi,%edx
  800d2a:	83 c4 10             	add    $0x10,%esp
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    
  800d31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d38:	3b 14 24             	cmp    (%esp),%edx
  800d3b:	77 7b                	ja     800db8 <__udivdi3+0xd8>
  800d3d:	0f bd f2             	bsr    %edx,%esi
  800d40:	83 f6 1f             	xor    $0x1f,%esi
  800d43:	0f 84 97 00 00 00    	je     800de0 <__udivdi3+0x100>
  800d49:	bd 20 00 00 00       	mov    $0x20,%ebp
  800d4e:	89 d7                	mov    %edx,%edi
  800d50:	89 f1                	mov    %esi,%ecx
  800d52:	29 f5                	sub    %esi,%ebp
  800d54:	d3 e7                	shl    %cl,%edi
  800d56:	89 c2                	mov    %eax,%edx
  800d58:	89 e9                	mov    %ebp,%ecx
  800d5a:	d3 ea                	shr    %cl,%edx
  800d5c:	89 f1                	mov    %esi,%ecx
  800d5e:	09 fa                	or     %edi,%edx
  800d60:	8b 3c 24             	mov    (%esp),%edi
  800d63:	d3 e0                	shl    %cl,%eax
  800d65:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d69:	89 e9                	mov    %ebp,%ecx
  800d6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d6f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d73:	89 fa                	mov    %edi,%edx
  800d75:	d3 ea                	shr    %cl,%edx
  800d77:	89 f1                	mov    %esi,%ecx
  800d79:	d3 e7                	shl    %cl,%edi
  800d7b:	89 e9                	mov    %ebp,%ecx
  800d7d:	d3 e8                	shr    %cl,%eax
  800d7f:	09 c7                	or     %eax,%edi
  800d81:	89 f8                	mov    %edi,%eax
  800d83:	f7 74 24 08          	divl   0x8(%esp)
  800d87:	89 d5                	mov    %edx,%ebp
  800d89:	89 c7                	mov    %eax,%edi
  800d8b:	f7 64 24 0c          	mull   0xc(%esp)
  800d8f:	39 d5                	cmp    %edx,%ebp
  800d91:	89 14 24             	mov    %edx,(%esp)
  800d94:	72 11                	jb     800da7 <__udivdi3+0xc7>
  800d96:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d9a:	89 f1                	mov    %esi,%ecx
  800d9c:	d3 e2                	shl    %cl,%edx
  800d9e:	39 c2                	cmp    %eax,%edx
  800da0:	73 5e                	jae    800e00 <__udivdi3+0x120>
  800da2:	3b 2c 24             	cmp    (%esp),%ebp
  800da5:	75 59                	jne    800e00 <__udivdi3+0x120>
  800da7:	8d 47 ff             	lea    -0x1(%edi),%eax
  800daa:	31 f6                	xor    %esi,%esi
  800dac:	89 f2                	mov    %esi,%edx
  800dae:	83 c4 10             	add    $0x10,%esp
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    
  800db5:	8d 76 00             	lea    0x0(%esi),%esi
  800db8:	31 f6                	xor    %esi,%esi
  800dba:	31 c0                	xor    %eax,%eax
  800dbc:	89 f2                	mov    %esi,%edx
  800dbe:	83 c4 10             	add    $0x10,%esp
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    
  800dc5:	8d 76 00             	lea    0x0(%esi),%esi
  800dc8:	89 f2                	mov    %esi,%edx
  800dca:	31 f6                	xor    %esi,%esi
  800dcc:	89 f8                	mov    %edi,%eax
  800dce:	f7 f1                	div    %ecx
  800dd0:	89 f2                	mov    %esi,%edx
  800dd2:	83 c4 10             	add    $0x10,%esp
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    
  800dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800de0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800de4:	76 0b                	jbe    800df1 <__udivdi3+0x111>
  800de6:	31 c0                	xor    %eax,%eax
  800de8:	3b 14 24             	cmp    (%esp),%edx
  800deb:	0f 83 37 ff ff ff    	jae    800d28 <__udivdi3+0x48>
  800df1:	b8 01 00 00 00       	mov    $0x1,%eax
  800df6:	e9 2d ff ff ff       	jmp    800d28 <__udivdi3+0x48>
  800dfb:	90                   	nop
  800dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e00:	89 f8                	mov    %edi,%eax
  800e02:	31 f6                	xor    %esi,%esi
  800e04:	e9 1f ff ff ff       	jmp    800d28 <__udivdi3+0x48>
  800e09:	66 90                	xchg   %ax,%ax
  800e0b:	66 90                	xchg   %ax,%ax
  800e0d:	66 90                	xchg   %ax,%ax
  800e0f:	90                   	nop

00800e10 <__umoddi3>:
  800e10:	55                   	push   %ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	83 ec 20             	sub    $0x20,%esp
  800e16:	8b 44 24 34          	mov    0x34(%esp),%eax
  800e1a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e1e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e22:	89 c6                	mov    %eax,%esi
  800e24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e28:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800e2c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800e30:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e34:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800e38:	89 74 24 18          	mov    %esi,0x18(%esp)
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	89 c2                	mov    %eax,%edx
  800e40:	75 1e                	jne    800e60 <__umoddi3+0x50>
  800e42:	39 f7                	cmp    %esi,%edi
  800e44:	76 52                	jbe    800e98 <__umoddi3+0x88>
  800e46:	89 c8                	mov    %ecx,%eax
  800e48:	89 f2                	mov    %esi,%edx
  800e4a:	f7 f7                	div    %edi
  800e4c:	89 d0                	mov    %edx,%eax
  800e4e:	31 d2                	xor    %edx,%edx
  800e50:	83 c4 20             	add    $0x20,%esp
  800e53:	5e                   	pop    %esi
  800e54:	5f                   	pop    %edi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    
  800e57:	89 f6                	mov    %esi,%esi
  800e59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e60:	39 f0                	cmp    %esi,%eax
  800e62:	77 5c                	ja     800ec0 <__umoddi3+0xb0>
  800e64:	0f bd e8             	bsr    %eax,%ebp
  800e67:	83 f5 1f             	xor    $0x1f,%ebp
  800e6a:	75 64                	jne    800ed0 <__umoddi3+0xc0>
  800e6c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800e70:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800e74:	0f 86 f6 00 00 00    	jbe    800f70 <__umoddi3+0x160>
  800e7a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800e7e:	0f 82 ec 00 00 00    	jb     800f70 <__umoddi3+0x160>
  800e84:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e88:	8b 54 24 18          	mov    0x18(%esp),%edx
  800e8c:	83 c4 20             	add    $0x20,%esp
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    
  800e93:	90                   	nop
  800e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e98:	85 ff                	test   %edi,%edi
  800e9a:	89 fd                	mov    %edi,%ebp
  800e9c:	75 0b                	jne    800ea9 <__umoddi3+0x99>
  800e9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea3:	31 d2                	xor    %edx,%edx
  800ea5:	f7 f7                	div    %edi
  800ea7:	89 c5                	mov    %eax,%ebp
  800ea9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800ead:	31 d2                	xor    %edx,%edx
  800eaf:	f7 f5                	div    %ebp
  800eb1:	89 c8                	mov    %ecx,%eax
  800eb3:	f7 f5                	div    %ebp
  800eb5:	eb 95                	jmp    800e4c <__umoddi3+0x3c>
  800eb7:	89 f6                	mov    %esi,%esi
  800eb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ec0:	89 c8                	mov    %ecx,%eax
  800ec2:	89 f2                	mov    %esi,%edx
  800ec4:	83 c4 20             	add    $0x20,%esp
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    
  800ecb:	90                   	nop
  800ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	b8 20 00 00 00       	mov    $0x20,%eax
  800ed5:	89 e9                	mov    %ebp,%ecx
  800ed7:	29 e8                	sub    %ebp,%eax
  800ed9:	d3 e2                	shl    %cl,%edx
  800edb:	89 c7                	mov    %eax,%edi
  800edd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800ee1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ee5:	89 f9                	mov    %edi,%ecx
  800ee7:	d3 e8                	shr    %cl,%eax
  800ee9:	89 c1                	mov    %eax,%ecx
  800eeb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eef:	09 d1                	or     %edx,%ecx
  800ef1:	89 fa                	mov    %edi,%edx
  800ef3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ef7:	89 e9                	mov    %ebp,%ecx
  800ef9:	d3 e0                	shl    %cl,%eax
  800efb:	89 f9                	mov    %edi,%ecx
  800efd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f01:	89 f0                	mov    %esi,%eax
  800f03:	d3 e8                	shr    %cl,%eax
  800f05:	89 e9                	mov    %ebp,%ecx
  800f07:	89 c7                	mov    %eax,%edi
  800f09:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f0d:	d3 e6                	shl    %cl,%esi
  800f0f:	89 d1                	mov    %edx,%ecx
  800f11:	89 fa                	mov    %edi,%edx
  800f13:	d3 e8                	shr    %cl,%eax
  800f15:	89 e9                	mov    %ebp,%ecx
  800f17:	09 f0                	or     %esi,%eax
  800f19:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800f1d:	f7 74 24 10          	divl   0x10(%esp)
  800f21:	d3 e6                	shl    %cl,%esi
  800f23:	89 d1                	mov    %edx,%ecx
  800f25:	f7 64 24 0c          	mull   0xc(%esp)
  800f29:	39 d1                	cmp    %edx,%ecx
  800f2b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800f2f:	89 d7                	mov    %edx,%edi
  800f31:	89 c6                	mov    %eax,%esi
  800f33:	72 0a                	jb     800f3f <__umoddi3+0x12f>
  800f35:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800f39:	73 10                	jae    800f4b <__umoddi3+0x13b>
  800f3b:	39 d1                	cmp    %edx,%ecx
  800f3d:	75 0c                	jne    800f4b <__umoddi3+0x13b>
  800f3f:	89 d7                	mov    %edx,%edi
  800f41:	89 c6                	mov    %eax,%esi
  800f43:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800f47:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800f4b:	89 ca                	mov    %ecx,%edx
  800f4d:	89 e9                	mov    %ebp,%ecx
  800f4f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f53:	29 f0                	sub    %esi,%eax
  800f55:	19 fa                	sbb    %edi,%edx
  800f57:	d3 e8                	shr    %cl,%eax
  800f59:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800f5e:	89 d7                	mov    %edx,%edi
  800f60:	d3 e7                	shl    %cl,%edi
  800f62:	89 e9                	mov    %ebp,%ecx
  800f64:	09 f8                	or     %edi,%eax
  800f66:	d3 ea                	shr    %cl,%edx
  800f68:	83 c4 20             	add    $0x20,%esp
  800f6b:	5e                   	pop    %esi
  800f6c:	5f                   	pop    %edi
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    
  800f6f:	90                   	nop
  800f70:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f74:	29 f9                	sub    %edi,%ecx
  800f76:	19 c6                	sbb    %eax,%esi
  800f78:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800f7c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f80:	e9 ff fe ff ff       	jmp    800e84 <__umoddi3+0x74>
