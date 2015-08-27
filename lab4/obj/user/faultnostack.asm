
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 17 03 80 00       	push   $0x800317
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
  80004f:	83 c4 10             	add    $0x10,%esp
}
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
  800090:	83 c4 10             	add    $0x10,%esp
}
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
  8000a7:	83 c4 10             	add    $0x10,%esp
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 2a 10 80 00       	push   $0x80102a
  800116:	6a 23                	push   $0x23
  800118:	68 47 10 80 00       	push   $0x801047
  80011d:	e8 19 02 00 00       	call   80033b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7e 17                	jle    8001a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 2a 10 80 00       	push   $0x80102a
  800197:	6a 23                	push   $0x23
  800199:	68 47 10 80 00       	push   $0x801047
  80019e:	e8 98 01 00 00       	call   80033b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7e 17                	jle    8001e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 2a 10 80 00       	push   $0x80102a
  8001d9:	6a 23                	push   $0x23
  8001db:	68 47 10 80 00       	push   $0x801047
  8001e0:	e8 56 01 00 00       	call   80033b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 2a 10 80 00       	push   $0x80102a
  80021b:	6a 23                	push   $0x23
  80021d:	68 47 10 80 00       	push   $0x801047
  800222:	e8 14 01 00 00       	call   80033b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 17                	jle    800269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 2a 10 80 00       	push   $0x80102a
  80025d:	6a 23                	push   $0x23
  80025f:	68 47 10 80 00       	push   $0x801047
  800264:	e8 d2 00 00 00       	call   80033b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5e                   	pop    %esi
  80026e:	5f                   	pop    %edi
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7e 17                	jle    8002ab <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 2a 10 80 00       	push   $0x80102a
  80029f:	6a 23                	push   $0x23
  8002a1:	68 47 10 80 00       	push   $0x801047
  8002a6:	e8 90 00 00 00       	call   80033b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b9:	be 00 00 00 00       	mov    $0x0,%esi
  8002be:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7e 17                	jle    80030f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0c                	push   $0xc
  8002fe:	68 2a 10 80 00       	push   $0x80102a
  800303:	6a 23                	push   $0x23
  800305:	68 47 10 80 00       	push   $0x801047
  80030a:	e8 2c 00 00 00       	call   80033b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80030f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800317:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800318:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80031d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  800322:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  800327:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  80032b:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  80032f:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  800331:	83 c4 08             	add    $0x8,%esp
        popal
  800334:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800335:	83 c4 04             	add    $0x4,%esp
        popfl
  800338:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  800339:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  80033a:	c3                   	ret    

0080033b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800340:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800343:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800349:	e8 dc fd ff ff       	call   80012a <sys_getenvid>
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	ff 75 0c             	pushl  0xc(%ebp)
  800354:	ff 75 08             	pushl  0x8(%ebp)
  800357:	56                   	push   %esi
  800358:	50                   	push   %eax
  800359:	68 58 10 80 00       	push   $0x801058
  80035e:	e8 b1 00 00 00       	call   800414 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800363:	83 c4 18             	add    $0x18,%esp
  800366:	53                   	push   %ebx
  800367:	ff 75 10             	pushl  0x10(%ebp)
  80036a:	e8 54 00 00 00       	call   8003c3 <vcprintf>
	cprintf("\n");
  80036f:	c7 04 24 7b 10 80 00 	movl   $0x80107b,(%esp)
  800376:	e8 99 00 00 00       	call   800414 <cprintf>
  80037b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037e:	cc                   	int3   
  80037f:	eb fd                	jmp    80037e <_panic+0x43>

00800381 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	53                   	push   %ebx
  800385:	83 ec 04             	sub    $0x4,%esp
  800388:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038b:	8b 13                	mov    (%ebx),%edx
  80038d:	8d 42 01             	lea    0x1(%edx),%eax
  800390:	89 03                	mov    %eax,(%ebx)
  800392:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800395:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800399:	3d ff 00 00 00       	cmp    $0xff,%eax
  80039e:	75 1a                	jne    8003ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003a0:	83 ec 08             	sub    $0x8,%esp
  8003a3:	68 ff 00 00 00       	push   $0xff
  8003a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ab:	50                   	push   %eax
  8003ac:	e8 fb fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d3:	00 00 00 
	b.cnt = 0;
  8003d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e0:	ff 75 0c             	pushl  0xc(%ebp)
  8003e3:	ff 75 08             	pushl  0x8(%ebp)
  8003e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ec:	50                   	push   %eax
  8003ed:	68 81 03 80 00       	push   $0x800381
  8003f2:	e8 4f 01 00 00       	call   800546 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f7:	83 c4 08             	add    $0x8,%esp
  8003fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800400:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800406:	50                   	push   %eax
  800407:	e8 a0 fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80040c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800412:	c9                   	leave  
  800413:	c3                   	ret    

00800414 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80041d:	50                   	push   %eax
  80041e:	ff 75 08             	pushl  0x8(%ebp)
  800421:	e8 9d ff ff ff       	call   8003c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 1c             	sub    $0x1c,%esp
  800431:	89 c7                	mov    %eax,%edi
  800433:	89 d6                	mov    %edx,%esi
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
  800438:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043b:	89 d1                	mov    %edx,%ecx
  80043d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800440:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800443:	8b 45 10             	mov    0x10(%ebp),%eax
  800446:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800453:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800456:	72 05                	jb     80045d <printnum+0x35>
  800458:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80045b:	77 3e                	ja     80049b <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80045d:	83 ec 0c             	sub    $0xc,%esp
  800460:	ff 75 18             	pushl  0x18(%ebp)
  800463:	83 eb 01             	sub    $0x1,%ebx
  800466:	53                   	push   %ebx
  800467:	50                   	push   %eax
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046e:	ff 75 e0             	pushl  -0x20(%ebp)
  800471:	ff 75 dc             	pushl  -0x24(%ebp)
  800474:	ff 75 d8             	pushl  -0x28(%ebp)
  800477:	e8 e4 08 00 00       	call   800d60 <__udivdi3>
  80047c:	83 c4 18             	add    $0x18,%esp
  80047f:	52                   	push   %edx
  800480:	50                   	push   %eax
  800481:	89 f2                	mov    %esi,%edx
  800483:	89 f8                	mov    %edi,%eax
  800485:	e8 9e ff ff ff       	call   800428 <printnum>
  80048a:	83 c4 20             	add    $0x20,%esp
  80048d:	eb 13                	jmp    8004a2 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	56                   	push   %esi
  800493:	ff 75 18             	pushl  0x18(%ebp)
  800496:	ff d7                	call   *%edi
  800498:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80049b:	83 eb 01             	sub    $0x1,%ebx
  80049e:	85 db                	test   %ebx,%ebx
  8004a0:	7f ed                	jg     80048f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	56                   	push   %esi
  8004a6:	83 ec 04             	sub    $0x4,%esp
  8004a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8004af:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b5:	e8 d6 09 00 00       	call   800e90 <__umoddi3>
  8004ba:	83 c4 14             	add    $0x14,%esp
  8004bd:	0f be 80 7d 10 80 00 	movsbl 0x80107d(%eax),%eax
  8004c4:	50                   	push   %eax
  8004c5:	ff d7                	call   *%edi
  8004c7:	83 c4 10             	add    $0x10,%esp
}
  8004ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004cd:	5b                   	pop    %ebx
  8004ce:	5e                   	pop    %esi
  8004cf:	5f                   	pop    %edi
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d5:	83 fa 01             	cmp    $0x1,%edx
  8004d8:	7e 0e                	jle    8004e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	8b 52 04             	mov    0x4(%edx),%edx
  8004e6:	eb 22                	jmp    80050a <getuint+0x38>
	else if (lflag)
  8004e8:	85 d2                	test   %edx,%edx
  8004ea:	74 10                	je     8004fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ec:	8b 10                	mov    (%eax),%edx
  8004ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f1:	89 08                	mov    %ecx,(%eax)
  8004f3:	8b 02                	mov    (%edx),%eax
  8004f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fa:	eb 0e                	jmp    80050a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004fc:	8b 10                	mov    (%eax),%edx
  8004fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800501:	89 08                	mov    %ecx,(%eax)
  800503:	8b 02                	mov    (%edx),%eax
  800505:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80050a:	5d                   	pop    %ebp
  80050b:	c3                   	ret    

0080050c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80050c:	55                   	push   %ebp
  80050d:	89 e5                	mov    %esp,%ebp
  80050f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800512:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800516:	8b 10                	mov    (%eax),%edx
  800518:	3b 50 04             	cmp    0x4(%eax),%edx
  80051b:	73 0a                	jae    800527 <sprintputch+0x1b>
		*b->buf++ = ch;
  80051d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800520:	89 08                	mov    %ecx,(%eax)
  800522:	8b 45 08             	mov    0x8(%ebp),%eax
  800525:	88 02                	mov    %al,(%edx)
}
  800527:	5d                   	pop    %ebp
  800528:	c3                   	ret    

00800529 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800529:	55                   	push   %ebp
  80052a:	89 e5                	mov    %esp,%ebp
  80052c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80052f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800532:	50                   	push   %eax
  800533:	ff 75 10             	pushl  0x10(%ebp)
  800536:	ff 75 0c             	pushl  0xc(%ebp)
  800539:	ff 75 08             	pushl  0x8(%ebp)
  80053c:	e8 05 00 00 00       	call   800546 <vprintfmt>
	va_end(ap);
  800541:	83 c4 10             	add    $0x10,%esp
}
  800544:	c9                   	leave  
  800545:	c3                   	ret    

00800546 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	57                   	push   %edi
  80054a:	56                   	push   %esi
  80054b:	53                   	push   %ebx
  80054c:	83 ec 2c             	sub    $0x2c,%esp
  80054f:	8b 75 08             	mov    0x8(%ebp),%esi
  800552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800555:	8b 7d 10             	mov    0x10(%ebp),%edi
  800558:	eb 12                	jmp    80056c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80055a:	85 c0                	test   %eax,%eax
  80055c:	0f 84 90 03 00 00    	je     8008f2 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	53                   	push   %ebx
  800566:	50                   	push   %eax
  800567:	ff d6                	call   *%esi
  800569:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80056c:	83 c7 01             	add    $0x1,%edi
  80056f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800573:	83 f8 25             	cmp    $0x25,%eax
  800576:	75 e2                	jne    80055a <vprintfmt+0x14>
  800578:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80057c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800583:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80058a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800591:	ba 00 00 00 00       	mov    $0x0,%edx
  800596:	eb 07                	jmp    80059f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80059b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8d 47 01             	lea    0x1(%edi),%eax
  8005a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a5:	0f b6 07             	movzbl (%edi),%eax
  8005a8:	0f b6 c8             	movzbl %al,%ecx
  8005ab:	83 e8 23             	sub    $0x23,%eax
  8005ae:	3c 55                	cmp    $0x55,%al
  8005b0:	0f 87 21 03 00 00    	ja     8008d7 <vprintfmt+0x391>
  8005b6:	0f b6 c0             	movzbl %al,%eax
  8005b9:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  8005c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005c7:	eb d6                	jmp    80059f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005d7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005db:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005de:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005e1:	83 fa 09             	cmp    $0x9,%edx
  8005e4:	77 39                	ja     80061f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005e9:	eb e9                	jmp    8005d4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 48 04             	lea    0x4(%eax),%ecx
  8005f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005fc:	eb 27                	jmp    800625 <vprintfmt+0xdf>
  8005fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800601:	85 c0                	test   %eax,%eax
  800603:	b9 00 00 00 00       	mov    $0x0,%ecx
  800608:	0f 49 c8             	cmovns %eax,%ecx
  80060b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800611:	eb 8c                	jmp    80059f <vprintfmt+0x59>
  800613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800616:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80061d:	eb 80                	jmp    80059f <vprintfmt+0x59>
  80061f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800622:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800625:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800629:	0f 89 70 ff ff ff    	jns    80059f <vprintfmt+0x59>
				width = precision, precision = -1;
  80062f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800632:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800635:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80063c:	e9 5e ff ff ff       	jmp    80059f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800641:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800647:	e9 53 ff ff ff       	jmp    80059f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 04             	lea    0x4(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	ff 30                	pushl  (%eax)
  80065b:	ff d6                	call   *%esi
			break;
  80065d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800660:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800663:	e9 04 ff ff ff       	jmp    80056c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)
  800671:	8b 00                	mov    (%eax),%eax
  800673:	99                   	cltd   
  800674:	31 d0                	xor    %edx,%eax
  800676:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800678:	83 f8 09             	cmp    $0x9,%eax
  80067b:	7f 0b                	jg     800688 <vprintfmt+0x142>
  80067d:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  800684:	85 d2                	test   %edx,%edx
  800686:	75 18                	jne    8006a0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800688:	50                   	push   %eax
  800689:	68 95 10 80 00       	push   $0x801095
  80068e:	53                   	push   %ebx
  80068f:	56                   	push   %esi
  800690:	e8 94 fe ff ff       	call   800529 <printfmt>
  800695:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80069b:	e9 cc fe ff ff       	jmp    80056c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006a0:	52                   	push   %edx
  8006a1:	68 9e 10 80 00       	push   $0x80109e
  8006a6:	53                   	push   %ebx
  8006a7:	56                   	push   %esi
  8006a8:	e8 7c fe ff ff       	call   800529 <printfmt>
  8006ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b3:	e9 b4 fe ff ff       	jmp    80056c <vprintfmt+0x26>
  8006b8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006be:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8d 50 04             	lea    0x4(%eax),%edx
  8006c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ca:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006cc:	85 ff                	test   %edi,%edi
  8006ce:	ba 8e 10 80 00       	mov    $0x80108e,%edx
  8006d3:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8006d6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006da:	0f 84 92 00 00 00    	je     800772 <vprintfmt+0x22c>
  8006e0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006e4:	0f 8e 96 00 00 00    	jle    800780 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	51                   	push   %ecx
  8006ee:	57                   	push   %edi
  8006ef:	e8 86 02 00 00       	call   80097a <strnlen>
  8006f4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006f7:	29 c1                	sub    %eax,%ecx
  8006f9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006fc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ff:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800703:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800706:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800709:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070b:	eb 0f                	jmp    80071c <vprintfmt+0x1d6>
					putch(padc, putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	ff 75 e0             	pushl  -0x20(%ebp)
  800714:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800716:	83 ef 01             	sub    $0x1,%edi
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	85 ff                	test   %edi,%edi
  80071e:	7f ed                	jg     80070d <vprintfmt+0x1c7>
  800720:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800723:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800726:	85 c9                	test   %ecx,%ecx
  800728:	b8 00 00 00 00       	mov    $0x0,%eax
  80072d:	0f 49 c1             	cmovns %ecx,%eax
  800730:	29 c1                	sub    %eax,%ecx
  800732:	89 75 08             	mov    %esi,0x8(%ebp)
  800735:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800738:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073b:	89 cb                	mov    %ecx,%ebx
  80073d:	eb 4d                	jmp    80078c <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80073f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800743:	74 1b                	je     800760 <vprintfmt+0x21a>
  800745:	0f be c0             	movsbl %al,%eax
  800748:	83 e8 20             	sub    $0x20,%eax
  80074b:	83 f8 5e             	cmp    $0x5e,%eax
  80074e:	76 10                	jbe    800760 <vprintfmt+0x21a>
					putch('?', putdat);
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	ff 75 0c             	pushl  0xc(%ebp)
  800756:	6a 3f                	push   $0x3f
  800758:	ff 55 08             	call   *0x8(%ebp)
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	eb 0d                	jmp    80076d <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	ff 75 0c             	pushl  0xc(%ebp)
  800766:	52                   	push   %edx
  800767:	ff 55 08             	call   *0x8(%ebp)
  80076a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076d:	83 eb 01             	sub    $0x1,%ebx
  800770:	eb 1a                	jmp    80078c <vprintfmt+0x246>
  800772:	89 75 08             	mov    %esi,0x8(%ebp)
  800775:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800778:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80077b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80077e:	eb 0c                	jmp    80078c <vprintfmt+0x246>
  800780:	89 75 08             	mov    %esi,0x8(%ebp)
  800783:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800786:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800789:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80078c:	83 c7 01             	add    $0x1,%edi
  80078f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800793:	0f be d0             	movsbl %al,%edx
  800796:	85 d2                	test   %edx,%edx
  800798:	74 23                	je     8007bd <vprintfmt+0x277>
  80079a:	85 f6                	test   %esi,%esi
  80079c:	78 a1                	js     80073f <vprintfmt+0x1f9>
  80079e:	83 ee 01             	sub    $0x1,%esi
  8007a1:	79 9c                	jns    80073f <vprintfmt+0x1f9>
  8007a3:	89 df                	mov    %ebx,%edi
  8007a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ab:	eb 18                	jmp    8007c5 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	53                   	push   %ebx
  8007b1:	6a 20                	push   $0x20
  8007b3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b5:	83 ef 01             	sub    $0x1,%edi
  8007b8:	83 c4 10             	add    $0x10,%esp
  8007bb:	eb 08                	jmp    8007c5 <vprintfmt+0x27f>
  8007bd:	89 df                	mov    %ebx,%edi
  8007bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c5:	85 ff                	test   %edi,%edi
  8007c7:	7f e4                	jg     8007ad <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007cc:	e9 9b fd ff ff       	jmp    80056c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d1:	83 fa 01             	cmp    $0x1,%edx
  8007d4:	7e 16                	jle    8007ec <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8007d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d9:	8d 50 08             	lea    0x8(%eax),%edx
  8007dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007df:	8b 50 04             	mov    0x4(%eax),%edx
  8007e2:	8b 00                	mov    (%eax),%eax
  8007e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ea:	eb 32                	jmp    80081e <vprintfmt+0x2d8>
	else if (lflag)
  8007ec:	85 d2                	test   %edx,%edx
  8007ee:	74 18                	je     800808 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	8d 50 04             	lea    0x4(%eax),%edx
  8007f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f9:	8b 00                	mov    (%eax),%eax
  8007fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fe:	89 c1                	mov    %eax,%ecx
  800800:	c1 f9 1f             	sar    $0x1f,%ecx
  800803:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800806:	eb 16                	jmp    80081e <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8d 50 04             	lea    0x4(%eax),%edx
  80080e:	89 55 14             	mov    %edx,0x14(%ebp)
  800811:	8b 00                	mov    (%eax),%eax
  800813:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800816:	89 c1                	mov    %eax,%ecx
  800818:	c1 f9 1f             	sar    $0x1f,%ecx
  80081b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80081e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800821:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800824:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800829:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80082d:	79 74                	jns    8008a3 <vprintfmt+0x35d>
				putch('-', putdat);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	53                   	push   %ebx
  800833:	6a 2d                	push   $0x2d
  800835:	ff d6                	call   *%esi
				num = -(long long) num;
  800837:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80083a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80083d:	f7 d8                	neg    %eax
  80083f:	83 d2 00             	adc    $0x0,%edx
  800842:	f7 da                	neg    %edx
  800844:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800847:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80084c:	eb 55                	jmp    8008a3 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80084e:	8d 45 14             	lea    0x14(%ebp),%eax
  800851:	e8 7c fc ff ff       	call   8004d2 <getuint>
			base = 10;
  800856:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80085b:	eb 46                	jmp    8008a3 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80085d:	8d 45 14             	lea    0x14(%ebp),%eax
  800860:	e8 6d fc ff ff       	call   8004d2 <getuint>
                        base = 8;
  800865:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80086a:	eb 37                	jmp    8008a3 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80086c:	83 ec 08             	sub    $0x8,%esp
  80086f:	53                   	push   %ebx
  800870:	6a 30                	push   $0x30
  800872:	ff d6                	call   *%esi
			putch('x', putdat);
  800874:	83 c4 08             	add    $0x8,%esp
  800877:	53                   	push   %ebx
  800878:	6a 78                	push   $0x78
  80087a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087c:	8b 45 14             	mov    0x14(%ebp),%eax
  80087f:	8d 50 04             	lea    0x4(%eax),%edx
  800882:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800885:	8b 00                	mov    (%eax),%eax
  800887:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80088c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80088f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800894:	eb 0d                	jmp    8008a3 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800896:	8d 45 14             	lea    0x14(%ebp),%eax
  800899:	e8 34 fc ff ff       	call   8004d2 <getuint>
			base = 16;
  80089e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a3:	83 ec 0c             	sub    $0xc,%esp
  8008a6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008aa:	57                   	push   %edi
  8008ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ae:	51                   	push   %ecx
  8008af:	52                   	push   %edx
  8008b0:	50                   	push   %eax
  8008b1:	89 da                	mov    %ebx,%edx
  8008b3:	89 f0                	mov    %esi,%eax
  8008b5:	e8 6e fb ff ff       	call   800428 <printnum>
			break;
  8008ba:	83 c4 20             	add    $0x20,%esp
  8008bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c0:	e9 a7 fc ff ff       	jmp    80056c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c5:	83 ec 08             	sub    $0x8,%esp
  8008c8:	53                   	push   %ebx
  8008c9:	51                   	push   %ecx
  8008ca:	ff d6                	call   *%esi
			break;
  8008cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d2:	e9 95 fc ff ff       	jmp    80056c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	53                   	push   %ebx
  8008db:	6a 25                	push   $0x25
  8008dd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008df:	83 c4 10             	add    $0x10,%esp
  8008e2:	eb 03                	jmp    8008e7 <vprintfmt+0x3a1>
  8008e4:	83 ef 01             	sub    $0x1,%edi
  8008e7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008eb:	75 f7                	jne    8008e4 <vprintfmt+0x39e>
  8008ed:	e9 7a fc ff ff       	jmp    80056c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5f                   	pop    %edi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	83 ec 18             	sub    $0x18,%esp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800906:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800909:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80090d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800910:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800917:	85 c0                	test   %eax,%eax
  800919:	74 26                	je     800941 <vsnprintf+0x47>
  80091b:	85 d2                	test   %edx,%edx
  80091d:	7e 22                	jle    800941 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80091f:	ff 75 14             	pushl  0x14(%ebp)
  800922:	ff 75 10             	pushl  0x10(%ebp)
  800925:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800928:	50                   	push   %eax
  800929:	68 0c 05 80 00       	push   $0x80050c
  80092e:	e8 13 fc ff ff       	call   800546 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800933:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800936:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800939:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80093c:	83 c4 10             	add    $0x10,%esp
  80093f:	eb 05                	jmp    800946 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800941:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800946:	c9                   	leave  
  800947:	c3                   	ret    

00800948 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80094e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800951:	50                   	push   %eax
  800952:	ff 75 10             	pushl  0x10(%ebp)
  800955:	ff 75 0c             	pushl  0xc(%ebp)
  800958:	ff 75 08             	pushl  0x8(%ebp)
  80095b:	e8 9a ff ff ff       	call   8008fa <vsnprintf>
	va_end(ap);

	return rc;
}
  800960:	c9                   	leave  
  800961:	c3                   	ret    

00800962 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800968:	b8 00 00 00 00       	mov    $0x0,%eax
  80096d:	eb 03                	jmp    800972 <strlen+0x10>
		n++;
  80096f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800972:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800976:	75 f7                	jne    80096f <strlen+0xd>
		n++;
	return n;
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800980:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800983:	ba 00 00 00 00       	mov    $0x0,%edx
  800988:	eb 03                	jmp    80098d <strnlen+0x13>
		n++;
  80098a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098d:	39 c2                	cmp    %eax,%edx
  80098f:	74 08                	je     800999 <strnlen+0x1f>
  800991:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800995:	75 f3                	jne    80098a <strnlen+0x10>
  800997:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a5:	89 c2                	mov    %eax,%edx
  8009a7:	83 c2 01             	add    $0x1,%edx
  8009aa:	83 c1 01             	add    $0x1,%ecx
  8009ad:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009b1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009b4:	84 db                	test   %bl,%bl
  8009b6:	75 ef                	jne    8009a7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c2:	53                   	push   %ebx
  8009c3:	e8 9a ff ff ff       	call   800962 <strlen>
  8009c8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009cb:	ff 75 0c             	pushl  0xc(%ebp)
  8009ce:	01 d8                	add    %ebx,%eax
  8009d0:	50                   	push   %eax
  8009d1:	e8 c5 ff ff ff       	call   80099b <strcpy>
	return dst;
}
  8009d6:	89 d8                	mov    %ebx,%eax
  8009d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e8:	89 f3                	mov    %esi,%ebx
  8009ea:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ed:	89 f2                	mov    %esi,%edx
  8009ef:	eb 0f                	jmp    800a00 <strncpy+0x23>
		*dst++ = *src;
  8009f1:	83 c2 01             	add    $0x1,%edx
  8009f4:	0f b6 01             	movzbl (%ecx),%eax
  8009f7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009fa:	80 39 01             	cmpb   $0x1,(%ecx)
  8009fd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a00:	39 da                	cmp    %ebx,%edx
  800a02:	75 ed                	jne    8009f1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a04:	89 f0                	mov    %esi,%eax
  800a06:	5b                   	pop    %ebx
  800a07:	5e                   	pop    %esi
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	56                   	push   %esi
  800a0e:	53                   	push   %ebx
  800a0f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a15:	8b 55 10             	mov    0x10(%ebp),%edx
  800a18:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a1a:	85 d2                	test   %edx,%edx
  800a1c:	74 21                	je     800a3f <strlcpy+0x35>
  800a1e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a22:	89 f2                	mov    %esi,%edx
  800a24:	eb 09                	jmp    800a2f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a26:	83 c2 01             	add    $0x1,%edx
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a2f:	39 c2                	cmp    %eax,%edx
  800a31:	74 09                	je     800a3c <strlcpy+0x32>
  800a33:	0f b6 19             	movzbl (%ecx),%ebx
  800a36:	84 db                	test   %bl,%bl
  800a38:	75 ec                	jne    800a26 <strlcpy+0x1c>
  800a3a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a3c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a3f:	29 f0                	sub    %esi,%eax
}
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a4e:	eb 06                	jmp    800a56 <strcmp+0x11>
		p++, q++;
  800a50:	83 c1 01             	add    $0x1,%ecx
  800a53:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a56:	0f b6 01             	movzbl (%ecx),%eax
  800a59:	84 c0                	test   %al,%al
  800a5b:	74 04                	je     800a61 <strcmp+0x1c>
  800a5d:	3a 02                	cmp    (%edx),%al
  800a5f:	74 ef                	je     800a50 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a61:	0f b6 c0             	movzbl %al,%eax
  800a64:	0f b6 12             	movzbl (%edx),%edx
  800a67:	29 d0                	sub    %edx,%eax
}
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	53                   	push   %ebx
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a75:	89 c3                	mov    %eax,%ebx
  800a77:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a7a:	eb 06                	jmp    800a82 <strncmp+0x17>
		n--, p++, q++;
  800a7c:	83 c0 01             	add    $0x1,%eax
  800a7f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a82:	39 d8                	cmp    %ebx,%eax
  800a84:	74 15                	je     800a9b <strncmp+0x30>
  800a86:	0f b6 08             	movzbl (%eax),%ecx
  800a89:	84 c9                	test   %cl,%cl
  800a8b:	74 04                	je     800a91 <strncmp+0x26>
  800a8d:	3a 0a                	cmp    (%edx),%cl
  800a8f:	74 eb                	je     800a7c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a91:	0f b6 00             	movzbl (%eax),%eax
  800a94:	0f b6 12             	movzbl (%edx),%edx
  800a97:	29 d0                	sub    %edx,%eax
  800a99:	eb 05                	jmp    800aa0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aad:	eb 07                	jmp    800ab6 <strchr+0x13>
		if (*s == c)
  800aaf:	38 ca                	cmp    %cl,%dl
  800ab1:	74 0f                	je     800ac2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ab3:	83 c0 01             	add    $0x1,%eax
  800ab6:	0f b6 10             	movzbl (%eax),%edx
  800ab9:	84 d2                	test   %dl,%dl
  800abb:	75 f2                	jne    800aaf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ace:	eb 03                	jmp    800ad3 <strfind+0xf>
  800ad0:	83 c0 01             	add    $0x1,%eax
  800ad3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ad6:	84 d2                	test   %dl,%dl
  800ad8:	74 04                	je     800ade <strfind+0x1a>
  800ada:	38 ca                	cmp    %cl,%dl
  800adc:	75 f2                	jne    800ad0 <strfind+0xc>
			break;
	return (char *) s;
}
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
  800ae6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aec:	85 c9                	test   %ecx,%ecx
  800aee:	74 36                	je     800b26 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af6:	75 28                	jne    800b20 <memset+0x40>
  800af8:	f6 c1 03             	test   $0x3,%cl
  800afb:	75 23                	jne    800b20 <memset+0x40>
		c &= 0xFF;
  800afd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b01:	89 d3                	mov    %edx,%ebx
  800b03:	c1 e3 08             	shl    $0x8,%ebx
  800b06:	89 d6                	mov    %edx,%esi
  800b08:	c1 e6 18             	shl    $0x18,%esi
  800b0b:	89 d0                	mov    %edx,%eax
  800b0d:	c1 e0 10             	shl    $0x10,%eax
  800b10:	09 f0                	or     %esi,%eax
  800b12:	09 c2                	or     %eax,%edx
  800b14:	89 d0                	mov    %edx,%eax
  800b16:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b18:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b1b:	fc                   	cld    
  800b1c:	f3 ab                	rep stos %eax,%es:(%edi)
  800b1e:	eb 06                	jmp    800b26 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b23:	fc                   	cld    
  800b24:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b26:	89 f8                	mov    %edi,%eax
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	8b 45 08             	mov    0x8(%ebp),%eax
  800b35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b3b:	39 c6                	cmp    %eax,%esi
  800b3d:	73 35                	jae    800b74 <memmove+0x47>
  800b3f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b42:	39 d0                	cmp    %edx,%eax
  800b44:	73 2e                	jae    800b74 <memmove+0x47>
		s += n;
		d += n;
  800b46:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b49:	89 d6                	mov    %edx,%esi
  800b4b:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b53:	75 13                	jne    800b68 <memmove+0x3b>
  800b55:	f6 c1 03             	test   $0x3,%cl
  800b58:	75 0e                	jne    800b68 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b5a:	83 ef 04             	sub    $0x4,%edi
  800b5d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b60:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b63:	fd                   	std    
  800b64:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b66:	eb 09                	jmp    800b71 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b68:	83 ef 01             	sub    $0x1,%edi
  800b6b:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b6e:	fd                   	std    
  800b6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b71:	fc                   	cld    
  800b72:	eb 1d                	jmp    800b91 <memmove+0x64>
  800b74:	89 f2                	mov    %esi,%edx
  800b76:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b78:	f6 c2 03             	test   $0x3,%dl
  800b7b:	75 0f                	jne    800b8c <memmove+0x5f>
  800b7d:	f6 c1 03             	test   $0x3,%cl
  800b80:	75 0a                	jne    800b8c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b82:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b85:	89 c7                	mov    %eax,%edi
  800b87:	fc                   	cld    
  800b88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8a:	eb 05                	jmp    800b91 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b8c:	89 c7                	mov    %eax,%edi
  800b8e:	fc                   	cld    
  800b8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b98:	ff 75 10             	pushl  0x10(%ebp)
  800b9b:	ff 75 0c             	pushl  0xc(%ebp)
  800b9e:	ff 75 08             	pushl  0x8(%ebp)
  800ba1:	e8 87 ff ff ff       	call   800b2d <memmove>
}
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb3:	89 c6                	mov    %eax,%esi
  800bb5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb8:	eb 1a                	jmp    800bd4 <memcmp+0x2c>
		if (*s1 != *s2)
  800bba:	0f b6 08             	movzbl (%eax),%ecx
  800bbd:	0f b6 1a             	movzbl (%edx),%ebx
  800bc0:	38 d9                	cmp    %bl,%cl
  800bc2:	74 0a                	je     800bce <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bc4:	0f b6 c1             	movzbl %cl,%eax
  800bc7:	0f b6 db             	movzbl %bl,%ebx
  800bca:	29 d8                	sub    %ebx,%eax
  800bcc:	eb 0f                	jmp    800bdd <memcmp+0x35>
		s1++, s2++;
  800bce:	83 c0 01             	add    $0x1,%eax
  800bd1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd4:	39 f0                	cmp    %esi,%eax
  800bd6:	75 e2                	jne    800bba <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	8b 45 08             	mov    0x8(%ebp),%eax
  800be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bea:	89 c2                	mov    %eax,%edx
  800bec:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bef:	eb 07                	jmp    800bf8 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf1:	38 08                	cmp    %cl,(%eax)
  800bf3:	74 07                	je     800bfc <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf5:	83 c0 01             	add    $0x1,%eax
  800bf8:	39 d0                	cmp    %edx,%eax
  800bfa:	72 f5                	jb     800bf1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0a:	eb 03                	jmp    800c0f <strtol+0x11>
		s++;
  800c0c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0f:	0f b6 01             	movzbl (%ecx),%eax
  800c12:	3c 09                	cmp    $0x9,%al
  800c14:	74 f6                	je     800c0c <strtol+0xe>
  800c16:	3c 20                	cmp    $0x20,%al
  800c18:	74 f2                	je     800c0c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c1a:	3c 2b                	cmp    $0x2b,%al
  800c1c:	75 0a                	jne    800c28 <strtol+0x2a>
		s++;
  800c1e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c21:	bf 00 00 00 00       	mov    $0x0,%edi
  800c26:	eb 10                	jmp    800c38 <strtol+0x3a>
  800c28:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c2d:	3c 2d                	cmp    $0x2d,%al
  800c2f:	75 07                	jne    800c38 <strtol+0x3a>
		s++, neg = 1;
  800c31:	8d 49 01             	lea    0x1(%ecx),%ecx
  800c34:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c38:	85 db                	test   %ebx,%ebx
  800c3a:	0f 94 c0             	sete   %al
  800c3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c43:	75 19                	jne    800c5e <strtol+0x60>
  800c45:	80 39 30             	cmpb   $0x30,(%ecx)
  800c48:	75 14                	jne    800c5e <strtol+0x60>
  800c4a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c4e:	0f 85 82 00 00 00    	jne    800cd6 <strtol+0xd8>
		s += 2, base = 16;
  800c54:	83 c1 02             	add    $0x2,%ecx
  800c57:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c5c:	eb 16                	jmp    800c74 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c5e:	84 c0                	test   %al,%al
  800c60:	74 12                	je     800c74 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c62:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c67:	80 39 30             	cmpb   $0x30,(%ecx)
  800c6a:	75 08                	jne    800c74 <strtol+0x76>
		s++, base = 8;
  800c6c:	83 c1 01             	add    $0x1,%ecx
  800c6f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c74:	b8 00 00 00 00       	mov    $0x0,%eax
  800c79:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c7c:	0f b6 11             	movzbl (%ecx),%edx
  800c7f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c82:	89 f3                	mov    %esi,%ebx
  800c84:	80 fb 09             	cmp    $0x9,%bl
  800c87:	77 08                	ja     800c91 <strtol+0x93>
			dig = *s - '0';
  800c89:	0f be d2             	movsbl %dl,%edx
  800c8c:	83 ea 30             	sub    $0x30,%edx
  800c8f:	eb 22                	jmp    800cb3 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c91:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c94:	89 f3                	mov    %esi,%ebx
  800c96:	80 fb 19             	cmp    $0x19,%bl
  800c99:	77 08                	ja     800ca3 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c9b:	0f be d2             	movsbl %dl,%edx
  800c9e:	83 ea 57             	sub    $0x57,%edx
  800ca1:	eb 10                	jmp    800cb3 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800ca3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca6:	89 f3                	mov    %esi,%ebx
  800ca8:	80 fb 19             	cmp    $0x19,%bl
  800cab:	77 16                	ja     800cc3 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800cad:	0f be d2             	movsbl %dl,%edx
  800cb0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cb3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cb6:	7d 0f                	jge    800cc7 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800cb8:	83 c1 01             	add    $0x1,%ecx
  800cbb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cbf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cc1:	eb b9                	jmp    800c7c <strtol+0x7e>
  800cc3:	89 c2                	mov    %eax,%edx
  800cc5:	eb 02                	jmp    800cc9 <strtol+0xcb>
  800cc7:	89 c2                	mov    %eax,%edx

	if (endptr)
  800cc9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ccd:	74 0d                	je     800cdc <strtol+0xde>
		*endptr = (char *) s;
  800ccf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd2:	89 0e                	mov    %ecx,(%esi)
  800cd4:	eb 06                	jmp    800cdc <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd6:	84 c0                	test   %al,%al
  800cd8:	75 92                	jne    800c6c <strtol+0x6e>
  800cda:	eb 98                	jmp    800c74 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cdc:	f7 da                	neg    %edx
  800cde:	85 ff                	test   %edi,%edi
  800ce0:	0f 45 c2             	cmovne %edx,%eax
}
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cee:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cf5:	75 2c                	jne    800d23 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  800cf7:	83 ec 04             	sub    $0x4,%esp
  800cfa:	6a 07                	push   $0x7
  800cfc:	68 00 f0 bf ee       	push   $0xeebff000
  800d01:	6a 00                	push   $0x0
  800d03:	e8 60 f4 ff ff       	call   800168 <sys_page_alloc>
  800d08:	83 c4 10             	add    $0x10,%esp
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	74 14                	je     800d23 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  800d0f:	83 ec 04             	sub    $0x4,%esp
  800d12:	68 c8 12 80 00       	push   $0x8012c8
  800d17:	6a 21                	push   $0x21
  800d19:	68 2c 13 80 00       	push   $0x80132c
  800d1e:	e8 18 f6 ff ff       	call   80033b <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	a3 08 20 80 00       	mov    %eax,0x802008
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800d2b:	83 ec 08             	sub    $0x8,%esp
  800d2e:	68 17 03 80 00       	push   $0x800317
  800d33:	6a 00                	push   $0x0
  800d35:	e8 37 f5 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
  800d3a:	83 c4 10             	add    $0x10,%esp
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	79 14                	jns    800d55 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800d41:	83 ec 04             	sub    $0x4,%esp
  800d44:	68 f4 12 80 00       	push   $0x8012f4
  800d49:	6a 29                	push   $0x29
  800d4b:	68 2c 13 80 00       	push   $0x80132c
  800d50:	e8 e6 f5 ff ff       	call   80033b <_panic>
}
  800d55:	c9                   	leave  
  800d56:	c3                   	ret    
  800d57:	66 90                	xchg   %ax,%ax
  800d59:	66 90                	xchg   %ax,%ax
  800d5b:	66 90                	xchg   %ax,%ax
  800d5d:	66 90                	xchg   %ax,%ax
  800d5f:	90                   	nop

00800d60 <__udivdi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	83 ec 10             	sub    $0x10,%esp
  800d66:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800d6a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800d6e:	8b 74 24 24          	mov    0x24(%esp),%esi
  800d72:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d76:	85 d2                	test   %edx,%edx
  800d78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d7c:	89 34 24             	mov    %esi,(%esp)
  800d7f:	89 c8                	mov    %ecx,%eax
  800d81:	75 35                	jne    800db8 <__udivdi3+0x58>
  800d83:	39 f1                	cmp    %esi,%ecx
  800d85:	0f 87 bd 00 00 00    	ja     800e48 <__udivdi3+0xe8>
  800d8b:	85 c9                	test   %ecx,%ecx
  800d8d:	89 cd                	mov    %ecx,%ebp
  800d8f:	75 0b                	jne    800d9c <__udivdi3+0x3c>
  800d91:	b8 01 00 00 00       	mov    $0x1,%eax
  800d96:	31 d2                	xor    %edx,%edx
  800d98:	f7 f1                	div    %ecx
  800d9a:	89 c5                	mov    %eax,%ebp
  800d9c:	89 f0                	mov    %esi,%eax
  800d9e:	31 d2                	xor    %edx,%edx
  800da0:	f7 f5                	div    %ebp
  800da2:	89 c6                	mov    %eax,%esi
  800da4:	89 f8                	mov    %edi,%eax
  800da6:	f7 f5                	div    %ebp
  800da8:	89 f2                	mov    %esi,%edx
  800daa:	83 c4 10             	add    $0x10,%esp
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    
  800db1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db8:	3b 14 24             	cmp    (%esp),%edx
  800dbb:	77 7b                	ja     800e38 <__udivdi3+0xd8>
  800dbd:	0f bd f2             	bsr    %edx,%esi
  800dc0:	83 f6 1f             	xor    $0x1f,%esi
  800dc3:	0f 84 97 00 00 00    	je     800e60 <__udivdi3+0x100>
  800dc9:	bd 20 00 00 00       	mov    $0x20,%ebp
  800dce:	89 d7                	mov    %edx,%edi
  800dd0:	89 f1                	mov    %esi,%ecx
  800dd2:	29 f5                	sub    %esi,%ebp
  800dd4:	d3 e7                	shl    %cl,%edi
  800dd6:	89 c2                	mov    %eax,%edx
  800dd8:	89 e9                	mov    %ebp,%ecx
  800dda:	d3 ea                	shr    %cl,%edx
  800ddc:	89 f1                	mov    %esi,%ecx
  800dde:	09 fa                	or     %edi,%edx
  800de0:	8b 3c 24             	mov    (%esp),%edi
  800de3:	d3 e0                	shl    %cl,%eax
  800de5:	89 54 24 08          	mov    %edx,0x8(%esp)
  800de9:	89 e9                	mov    %ebp,%ecx
  800deb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800def:	8b 44 24 04          	mov    0x4(%esp),%eax
  800df3:	89 fa                	mov    %edi,%edx
  800df5:	d3 ea                	shr    %cl,%edx
  800df7:	89 f1                	mov    %esi,%ecx
  800df9:	d3 e7                	shl    %cl,%edi
  800dfb:	89 e9                	mov    %ebp,%ecx
  800dfd:	d3 e8                	shr    %cl,%eax
  800dff:	09 c7                	or     %eax,%edi
  800e01:	89 f8                	mov    %edi,%eax
  800e03:	f7 74 24 08          	divl   0x8(%esp)
  800e07:	89 d5                	mov    %edx,%ebp
  800e09:	89 c7                	mov    %eax,%edi
  800e0b:	f7 64 24 0c          	mull   0xc(%esp)
  800e0f:	39 d5                	cmp    %edx,%ebp
  800e11:	89 14 24             	mov    %edx,(%esp)
  800e14:	72 11                	jb     800e27 <__udivdi3+0xc7>
  800e16:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e1a:	89 f1                	mov    %esi,%ecx
  800e1c:	d3 e2                	shl    %cl,%edx
  800e1e:	39 c2                	cmp    %eax,%edx
  800e20:	73 5e                	jae    800e80 <__udivdi3+0x120>
  800e22:	3b 2c 24             	cmp    (%esp),%ebp
  800e25:	75 59                	jne    800e80 <__udivdi3+0x120>
  800e27:	8d 47 ff             	lea    -0x1(%edi),%eax
  800e2a:	31 f6                	xor    %esi,%esi
  800e2c:	89 f2                	mov    %esi,%edx
  800e2e:	83 c4 10             	add    $0x10,%esp
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
  800e35:	8d 76 00             	lea    0x0(%esi),%esi
  800e38:	31 f6                	xor    %esi,%esi
  800e3a:	31 c0                	xor    %eax,%eax
  800e3c:	89 f2                	mov    %esi,%edx
  800e3e:	83 c4 10             	add    $0x10,%esp
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
  800e45:	8d 76 00             	lea    0x0(%esi),%esi
  800e48:	89 f2                	mov    %esi,%edx
  800e4a:	31 f6                	xor    %esi,%esi
  800e4c:	89 f8                	mov    %edi,%eax
  800e4e:	f7 f1                	div    %ecx
  800e50:	89 f2                	mov    %esi,%edx
  800e52:	83 c4 10             	add    $0x10,%esp
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e64:	76 0b                	jbe    800e71 <__udivdi3+0x111>
  800e66:	31 c0                	xor    %eax,%eax
  800e68:	3b 14 24             	cmp    (%esp),%edx
  800e6b:	0f 83 37 ff ff ff    	jae    800da8 <__udivdi3+0x48>
  800e71:	b8 01 00 00 00       	mov    $0x1,%eax
  800e76:	e9 2d ff ff ff       	jmp    800da8 <__udivdi3+0x48>
  800e7b:	90                   	nop
  800e7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 f8                	mov    %edi,%eax
  800e82:	31 f6                	xor    %esi,%esi
  800e84:	e9 1f ff ff ff       	jmp    800da8 <__udivdi3+0x48>
  800e89:	66 90                	xchg   %ax,%ax
  800e8b:	66 90                	xchg   %ax,%ax
  800e8d:	66 90                	xchg   %ax,%ax
  800e8f:	90                   	nop

00800e90 <__umoddi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	83 ec 20             	sub    $0x20,%esp
  800e96:	8b 44 24 34          	mov    0x34(%esp),%eax
  800e9a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e9e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ea2:	89 c6                	mov    %eax,%esi
  800ea4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800eac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800eb0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800eb4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800eb8:	89 74 24 18          	mov    %esi,0x18(%esp)
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	89 c2                	mov    %eax,%edx
  800ec0:	75 1e                	jne    800ee0 <__umoddi3+0x50>
  800ec2:	39 f7                	cmp    %esi,%edi
  800ec4:	76 52                	jbe    800f18 <__umoddi3+0x88>
  800ec6:	89 c8                	mov    %ecx,%eax
  800ec8:	89 f2                	mov    %esi,%edx
  800eca:	f7 f7                	div    %edi
  800ecc:	89 d0                	mov    %edx,%eax
  800ece:	31 d2                	xor    %edx,%edx
  800ed0:	83 c4 20             	add    $0x20,%esp
  800ed3:	5e                   	pop    %esi
  800ed4:	5f                   	pop    %edi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    
  800ed7:	89 f6                	mov    %esi,%esi
  800ed9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ee0:	39 f0                	cmp    %esi,%eax
  800ee2:	77 5c                	ja     800f40 <__umoddi3+0xb0>
  800ee4:	0f bd e8             	bsr    %eax,%ebp
  800ee7:	83 f5 1f             	xor    $0x1f,%ebp
  800eea:	75 64                	jne    800f50 <__umoddi3+0xc0>
  800eec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800ef0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800ef4:	0f 86 f6 00 00 00    	jbe    800ff0 <__umoddi3+0x160>
  800efa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800efe:	0f 82 ec 00 00 00    	jb     800ff0 <__umoddi3+0x160>
  800f04:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f08:	8b 54 24 18          	mov    0x18(%esp),%edx
  800f0c:	83 c4 20             	add    $0x20,%esp
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    
  800f13:	90                   	nop
  800f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f18:	85 ff                	test   %edi,%edi
  800f1a:	89 fd                	mov    %edi,%ebp
  800f1c:	75 0b                	jne    800f29 <__umoddi3+0x99>
  800f1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f23:	31 d2                	xor    %edx,%edx
  800f25:	f7 f7                	div    %edi
  800f27:	89 c5                	mov    %eax,%ebp
  800f29:	8b 44 24 10          	mov    0x10(%esp),%eax
  800f2d:	31 d2                	xor    %edx,%edx
  800f2f:	f7 f5                	div    %ebp
  800f31:	89 c8                	mov    %ecx,%eax
  800f33:	f7 f5                	div    %ebp
  800f35:	eb 95                	jmp    800ecc <__umoddi3+0x3c>
  800f37:	89 f6                	mov    %esi,%esi
  800f39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f40:	89 c8                	mov    %ecx,%eax
  800f42:	89 f2                	mov    %esi,%edx
  800f44:	83 c4 20             	add    $0x20,%esp
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    
  800f4b:	90                   	nop
  800f4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f50:	b8 20 00 00 00       	mov    $0x20,%eax
  800f55:	89 e9                	mov    %ebp,%ecx
  800f57:	29 e8                	sub    %ebp,%eax
  800f59:	d3 e2                	shl    %cl,%edx
  800f5b:	89 c7                	mov    %eax,%edi
  800f5d:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f61:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f65:	89 f9                	mov    %edi,%ecx
  800f67:	d3 e8                	shr    %cl,%eax
  800f69:	89 c1                	mov    %eax,%ecx
  800f6b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f6f:	09 d1                	or     %edx,%ecx
  800f71:	89 fa                	mov    %edi,%edx
  800f73:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f77:	89 e9                	mov    %ebp,%ecx
  800f79:	d3 e0                	shl    %cl,%eax
  800f7b:	89 f9                	mov    %edi,%ecx
  800f7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f81:	89 f0                	mov    %esi,%eax
  800f83:	d3 e8                	shr    %cl,%eax
  800f85:	89 e9                	mov    %ebp,%ecx
  800f87:	89 c7                	mov    %eax,%edi
  800f89:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f8d:	d3 e6                	shl    %cl,%esi
  800f8f:	89 d1                	mov    %edx,%ecx
  800f91:	89 fa                	mov    %edi,%edx
  800f93:	d3 e8                	shr    %cl,%eax
  800f95:	89 e9                	mov    %ebp,%ecx
  800f97:	09 f0                	or     %esi,%eax
  800f99:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800f9d:	f7 74 24 10          	divl   0x10(%esp)
  800fa1:	d3 e6                	shl    %cl,%esi
  800fa3:	89 d1                	mov    %edx,%ecx
  800fa5:	f7 64 24 0c          	mull   0xc(%esp)
  800fa9:	39 d1                	cmp    %edx,%ecx
  800fab:	89 74 24 14          	mov    %esi,0x14(%esp)
  800faf:	89 d7                	mov    %edx,%edi
  800fb1:	89 c6                	mov    %eax,%esi
  800fb3:	72 0a                	jb     800fbf <__umoddi3+0x12f>
  800fb5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800fb9:	73 10                	jae    800fcb <__umoddi3+0x13b>
  800fbb:	39 d1                	cmp    %edx,%ecx
  800fbd:	75 0c                	jne    800fcb <__umoddi3+0x13b>
  800fbf:	89 d7                	mov    %edx,%edi
  800fc1:	89 c6                	mov    %eax,%esi
  800fc3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800fc7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800fcb:	89 ca                	mov    %ecx,%edx
  800fcd:	89 e9                	mov    %ebp,%ecx
  800fcf:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fd3:	29 f0                	sub    %esi,%eax
  800fd5:	19 fa                	sbb    %edi,%edx
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800fde:	89 d7                	mov    %edx,%edi
  800fe0:	d3 e7                	shl    %cl,%edi
  800fe2:	89 e9                	mov    %ebp,%ecx
  800fe4:	09 f8                	or     %edi,%eax
  800fe6:	d3 ea                	shr    %cl,%edx
  800fe8:	83 c4 20             	add    $0x20,%esp
  800feb:	5e                   	pop    %esi
  800fec:	5f                   	pop    %edi
  800fed:	5d                   	pop    %ebp
  800fee:	c3                   	ret    
  800fef:	90                   	nop
  800ff0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ff4:	29 f9                	sub    %edi,%ecx
  800ff6:	19 c6                	sbb    %eax,%esi
  800ff8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800ffc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801000:	e9 ff fe ff ff       	jmp    800f04 <__umoddi3+0x74>
