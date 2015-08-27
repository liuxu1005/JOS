
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800045:	e8 c6 00 00 00       	call   800110 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
  800076:	83 c4 10             	add    $0x10,%esp
}
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 42 00 00 00       	call   8000cf <sys_env_destroy>
  80008d:	83 c4 10             	add    $0x10,%esp
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800098:	b8 00 00 00 00       	mov    $0x0,%eax
  80009d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a3:	89 c3                	mov    %eax,%ebx
  8000a5:	89 c7                	mov    %eax,%edi
  8000a7:	89 c6                	mov    %eax,%esi
  8000a9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5f                   	pop    %edi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c0:	89 d1                	mov    %edx,%ecx
  8000c2:	89 d3                	mov    %edx,%ebx
  8000c4:	89 d7                	mov    %edx,%edi
  8000c6:	89 d6                	mov    %edx,%esi
  8000c8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e5:	89 cb                	mov    %ecx,%ebx
  8000e7:	89 cf                	mov    %ecx,%edi
  8000e9:	89 ce                	mov    %ecx,%esi
  8000eb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	7e 17                	jle    800108 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	50                   	push   %eax
  8000f5:	6a 03                	push   $0x3
  8000f7:	68 6a 0f 80 00       	push   $0x800f6a
  8000fc:	6a 23                	push   $0x23
  8000fe:	68 87 0f 80 00       	push   $0x800f87
  800103:	e8 f5 01 00 00       	call   8002fd <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5e                   	pop    %esi
  80010d:	5f                   	pop    %edi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 02 00 00 00       	mov    $0x2,%eax
  800120:	89 d1                	mov    %edx,%ecx
  800122:	89 d3                	mov    %edx,%ebx
  800124:	89 d7                	mov    %edx,%edi
  800126:	89 d6                	mov    %edx,%esi
  800128:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_yield>:

void
sys_yield(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
  800154:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	be 00 00 00 00       	mov    $0x0,%esi
  80015c:	b8 04 00 00 00       	mov    $0x4,%eax
  800161:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016a:	89 f7                	mov    %esi,%edi
  80016c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 17                	jle    800189 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	50                   	push   %eax
  800176:	6a 04                	push   $0x4
  800178:	68 6a 0f 80 00       	push   $0x800f6a
  80017d:	6a 23                	push   $0x23
  80017f:	68 87 0f 80 00       	push   $0x800f87
  800184:	e8 74 01 00 00       	call   8002fd <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800189:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019a:	b8 05 00 00 00       	mov    $0x5,%eax
  80019f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ab:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	7e 17                	jle    8001cb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	50                   	push   %eax
  8001b8:	6a 05                	push   $0x5
  8001ba:	68 6a 0f 80 00       	push   $0x800f6a
  8001bf:	6a 23                	push   $0x23
  8001c1:	68 87 0f 80 00       	push   $0x800f87
  8001c6:	e8 32 01 00 00       	call   8002fd <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ce:	5b                   	pop    %ebx
  8001cf:	5e                   	pop    %esi
  8001d0:	5f                   	pop    %edi
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    

008001d3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	57                   	push   %edi
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	89 df                	mov    %ebx,%edi
  8001ee:	89 de                	mov    %ebx,%esi
  8001f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7e 17                	jle    80020d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f6:	83 ec 0c             	sub    $0xc,%esp
  8001f9:	50                   	push   %eax
  8001fa:	6a 06                	push   $0x6
  8001fc:	68 6a 0f 80 00       	push   $0x800f6a
  800201:	6a 23                	push   $0x23
  800203:	68 87 0f 80 00       	push   $0x800f87
  800208:	e8 f0 00 00 00       	call   8002fd <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800210:	5b                   	pop    %ebx
  800211:	5e                   	pop    %esi
  800212:	5f                   	pop    %edi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    

00800215 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	57                   	push   %edi
  800219:	56                   	push   %esi
  80021a:	53                   	push   %ebx
  80021b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	b8 08 00 00 00       	mov    $0x8,%eax
  800228:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022b:	8b 55 08             	mov    0x8(%ebp),%edx
  80022e:	89 df                	mov    %ebx,%edi
  800230:	89 de                	mov    %ebx,%esi
  800232:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800234:	85 c0                	test   %eax,%eax
  800236:	7e 17                	jle    80024f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	50                   	push   %eax
  80023c:	6a 08                	push   $0x8
  80023e:	68 6a 0f 80 00       	push   $0x800f6a
  800243:	6a 23                	push   $0x23
  800245:	68 87 0f 80 00       	push   $0x800f87
  80024a:	e8 ae 00 00 00       	call   8002fd <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800260:	bb 00 00 00 00       	mov    $0x0,%ebx
  800265:	b8 09 00 00 00       	mov    $0x9,%eax
  80026a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026d:	8b 55 08             	mov    0x8(%ebp),%edx
  800270:	89 df                	mov    %ebx,%edi
  800272:	89 de                	mov    %ebx,%esi
  800274:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800276:	85 c0                	test   %eax,%eax
  800278:	7e 17                	jle    800291 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	50                   	push   %eax
  80027e:	6a 09                	push   $0x9
  800280:	68 6a 0f 80 00       	push   $0x800f6a
  800285:	6a 23                	push   $0x23
  800287:	68 87 0f 80 00       	push   $0x800f87
  80028c:	e8 6c 00 00 00       	call   8002fd <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800291:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800294:	5b                   	pop    %ebx
  800295:	5e                   	pop    %esi
  800296:	5f                   	pop    %edi
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029f:	be 00 00 00 00       	mov    $0x0,%esi
  8002a4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8002af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ca:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d2:	89 cb                	mov    %ecx,%ebx
  8002d4:	89 cf                	mov    %ecx,%edi
  8002d6:	89 ce                	mov    %ecx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0c                	push   $0xc
  8002e4:	68 6a 0f 80 00       	push   $0x800f6a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 87 0f 80 00       	push   $0x800f87
  8002f0:	e8 08 00 00 00       	call   8002fd <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800302:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800305:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030b:	e8 00 fe ff ff       	call   800110 <sys_getenvid>
  800310:	83 ec 0c             	sub    $0xc,%esp
  800313:	ff 75 0c             	pushl  0xc(%ebp)
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	56                   	push   %esi
  80031a:	50                   	push   %eax
  80031b:	68 98 0f 80 00       	push   $0x800f98
  800320:	e8 b1 00 00 00       	call   8003d6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800325:	83 c4 18             	add    $0x18,%esp
  800328:	53                   	push   %ebx
  800329:	ff 75 10             	pushl  0x10(%ebp)
  80032c:	e8 54 00 00 00       	call   800385 <vcprintf>
	cprintf("\n");
  800331:	c7 04 24 bc 0f 80 00 	movl   $0x800fbc,(%esp)
  800338:	e8 99 00 00 00       	call   8003d6 <cprintf>
  80033d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800340:	cc                   	int3   
  800341:	eb fd                	jmp    800340 <_panic+0x43>

00800343 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	53                   	push   %ebx
  800347:	83 ec 04             	sub    $0x4,%esp
  80034a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80034d:	8b 13                	mov    (%ebx),%edx
  80034f:	8d 42 01             	lea    0x1(%edx),%eax
  800352:	89 03                	mov    %eax,(%ebx)
  800354:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800357:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800360:	75 1a                	jne    80037c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800362:	83 ec 08             	sub    $0x8,%esp
  800365:	68 ff 00 00 00       	push   $0xff
  80036a:	8d 43 08             	lea    0x8(%ebx),%eax
  80036d:	50                   	push   %eax
  80036e:	e8 1f fd ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  800373:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800379:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80037c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80038e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800395:	00 00 00 
	b.cnt = 0;
  800398:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a2:	ff 75 0c             	pushl  0xc(%ebp)
  8003a5:	ff 75 08             	pushl  0x8(%ebp)
  8003a8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ae:	50                   	push   %eax
  8003af:	68 43 03 80 00       	push   $0x800343
  8003b4:	e8 4f 01 00 00       	call   800508 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b9:	83 c4 08             	add    $0x8,%esp
  8003bc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 c4 fc ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  8003ce:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d4:	c9                   	leave  
  8003d5:	c3                   	ret    

008003d6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003dc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003df:	50                   	push   %eax
  8003e0:	ff 75 08             	pushl  0x8(%ebp)
  8003e3:	e8 9d ff ff ff       	call   800385 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e8:	c9                   	leave  
  8003e9:	c3                   	ret    

008003ea <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	57                   	push   %edi
  8003ee:	56                   	push   %esi
  8003ef:	53                   	push   %ebx
  8003f0:	83 ec 1c             	sub    $0x1c,%esp
  8003f3:	89 c7                	mov    %eax,%edi
  8003f5:	89 d6                	mov    %edx,%esi
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 d1                	mov    %edx,%ecx
  8003ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800402:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800405:	8b 45 10             	mov    0x10(%ebp),%eax
  800408:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800415:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800418:	72 05                	jb     80041f <printnum+0x35>
  80041a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80041d:	77 3e                	ja     80045d <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041f:	83 ec 0c             	sub    $0xc,%esp
  800422:	ff 75 18             	pushl  0x18(%ebp)
  800425:	83 eb 01             	sub    $0x1,%ebx
  800428:	53                   	push   %ebx
  800429:	50                   	push   %eax
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800430:	ff 75 e0             	pushl  -0x20(%ebp)
  800433:	ff 75 dc             	pushl  -0x24(%ebp)
  800436:	ff 75 d8             	pushl  -0x28(%ebp)
  800439:	e8 72 08 00 00       	call   800cb0 <__udivdi3>
  80043e:	83 c4 18             	add    $0x18,%esp
  800441:	52                   	push   %edx
  800442:	50                   	push   %eax
  800443:	89 f2                	mov    %esi,%edx
  800445:	89 f8                	mov    %edi,%eax
  800447:	e8 9e ff ff ff       	call   8003ea <printnum>
  80044c:	83 c4 20             	add    $0x20,%esp
  80044f:	eb 13                	jmp    800464 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	56                   	push   %esi
  800455:	ff 75 18             	pushl  0x18(%ebp)
  800458:	ff d7                	call   *%edi
  80045a:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80045d:	83 eb 01             	sub    $0x1,%ebx
  800460:	85 db                	test   %ebx,%ebx
  800462:	7f ed                	jg     800451 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	56                   	push   %esi
  800468:	83 ec 04             	sub    $0x4,%esp
  80046b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046e:	ff 75 e0             	pushl  -0x20(%ebp)
  800471:	ff 75 dc             	pushl  -0x24(%ebp)
  800474:	ff 75 d8             	pushl  -0x28(%ebp)
  800477:	e8 64 09 00 00       	call   800de0 <__umoddi3>
  80047c:	83 c4 14             	add    $0x14,%esp
  80047f:	0f be 80 be 0f 80 00 	movsbl 0x800fbe(%eax),%eax
  800486:	50                   	push   %eax
  800487:	ff d7                	call   *%edi
  800489:	83 c4 10             	add    $0x10,%esp
}
  80048c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048f:	5b                   	pop    %ebx
  800490:	5e                   	pop    %esi
  800491:	5f                   	pop    %edi
  800492:	5d                   	pop    %ebp
  800493:	c3                   	ret    

00800494 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800497:	83 fa 01             	cmp    $0x1,%edx
  80049a:	7e 0e                	jle    8004aa <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80049c:	8b 10                	mov    (%eax),%edx
  80049e:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a1:	89 08                	mov    %ecx,(%eax)
  8004a3:	8b 02                	mov    (%edx),%eax
  8004a5:	8b 52 04             	mov    0x4(%edx),%edx
  8004a8:	eb 22                	jmp    8004cc <getuint+0x38>
	else if (lflag)
  8004aa:	85 d2                	test   %edx,%edx
  8004ac:	74 10                	je     8004be <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ae:	8b 10                	mov    (%eax),%edx
  8004b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b3:	89 08                	mov    %ecx,(%eax)
  8004b5:	8b 02                	mov    (%edx),%eax
  8004b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8004bc:	eb 0e                	jmp    8004cc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004be:	8b 10                	mov    (%eax),%edx
  8004c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c3:	89 08                	mov    %ecx,(%eax)
  8004c5:	8b 02                	mov    (%edx),%eax
  8004c7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004cc:	5d                   	pop    %ebp
  8004cd:	c3                   	ret    

008004ce <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
  8004d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d8:	8b 10                	mov    (%eax),%edx
  8004da:	3b 50 04             	cmp    0x4(%eax),%edx
  8004dd:	73 0a                	jae    8004e9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004df:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e2:	89 08                	mov    %ecx,(%eax)
  8004e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e7:	88 02                	mov    %al,(%edx)
}
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f4:	50                   	push   %eax
  8004f5:	ff 75 10             	pushl  0x10(%ebp)
  8004f8:	ff 75 0c             	pushl  0xc(%ebp)
  8004fb:	ff 75 08             	pushl  0x8(%ebp)
  8004fe:	e8 05 00 00 00       	call   800508 <vprintfmt>
	va_end(ap);
  800503:	83 c4 10             	add    $0x10,%esp
}
  800506:	c9                   	leave  
  800507:	c3                   	ret    

00800508 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	57                   	push   %edi
  80050c:	56                   	push   %esi
  80050d:	53                   	push   %ebx
  80050e:	83 ec 2c             	sub    $0x2c,%esp
  800511:	8b 75 08             	mov    0x8(%ebp),%esi
  800514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800517:	8b 7d 10             	mov    0x10(%ebp),%edi
  80051a:	eb 12                	jmp    80052e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80051c:	85 c0                	test   %eax,%eax
  80051e:	0f 84 90 03 00 00    	je     8008b4 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	53                   	push   %ebx
  800528:	50                   	push   %eax
  800529:	ff d6                	call   *%esi
  80052b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80052e:	83 c7 01             	add    $0x1,%edi
  800531:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800535:	83 f8 25             	cmp    $0x25,%eax
  800538:	75 e2                	jne    80051c <vprintfmt+0x14>
  80053a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80053e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800545:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800553:	ba 00 00 00 00       	mov    $0x0,%edx
  800558:	eb 07                	jmp    800561 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80055d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800561:	8d 47 01             	lea    0x1(%edi),%eax
  800564:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800567:	0f b6 07             	movzbl (%edi),%eax
  80056a:	0f b6 c8             	movzbl %al,%ecx
  80056d:	83 e8 23             	sub    $0x23,%eax
  800570:	3c 55                	cmp    $0x55,%al
  800572:	0f 87 21 03 00 00    	ja     800899 <vprintfmt+0x391>
  800578:	0f b6 c0             	movzbl %al,%eax
  80057b:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  800582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800585:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800589:	eb d6                	jmp    800561 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058e:	b8 00 00 00 00       	mov    $0x0,%eax
  800593:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800596:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800599:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80059d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005a0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005a3:	83 fa 09             	cmp    $0x9,%edx
  8005a6:	77 39                	ja     8005e1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ab:	eb e9                	jmp    800596 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 48 04             	lea    0x4(%eax),%ecx
  8005b3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005b6:	8b 00                	mov    (%eax),%eax
  8005b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005be:	eb 27                	jmp    8005e7 <vprintfmt+0xdf>
  8005c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c3:	85 c0                	test   %eax,%eax
  8005c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ca:	0f 49 c8             	cmovns %eax,%ecx
  8005cd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d3:	eb 8c                	jmp    800561 <vprintfmt+0x59>
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005df:	eb 80                	jmp    800561 <vprintfmt+0x59>
  8005e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005eb:	0f 89 70 ff ff ff    	jns    800561 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005fe:	e9 5e ff ff ff       	jmp    800561 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800603:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800609:	e9 53 ff ff ff       	jmp    800561 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	ff 30                	pushl  (%eax)
  80061d:	ff d6                	call   *%esi
			break;
  80061f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800622:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800625:	e9 04 ff ff ff       	jmp    80052e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 50 04             	lea    0x4(%eax),%edx
  800630:	89 55 14             	mov    %edx,0x14(%ebp)
  800633:	8b 00                	mov    (%eax),%eax
  800635:	99                   	cltd   
  800636:	31 d0                	xor    %edx,%eax
  800638:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063a:	83 f8 09             	cmp    $0x9,%eax
  80063d:	7f 0b                	jg     80064a <vprintfmt+0x142>
  80063f:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  800646:	85 d2                	test   %edx,%edx
  800648:	75 18                	jne    800662 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80064a:	50                   	push   %eax
  80064b:	68 d6 0f 80 00       	push   $0x800fd6
  800650:	53                   	push   %ebx
  800651:	56                   	push   %esi
  800652:	e8 94 fe ff ff       	call   8004eb <printfmt>
  800657:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80065d:	e9 cc fe ff ff       	jmp    80052e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800662:	52                   	push   %edx
  800663:	68 df 0f 80 00       	push   $0x800fdf
  800668:	53                   	push   %ebx
  800669:	56                   	push   %esi
  80066a:	e8 7c fe ff ff       	call   8004eb <printfmt>
  80066f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800675:	e9 b4 fe ff ff       	jmp    80052e <vprintfmt+0x26>
  80067a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80067d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800680:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 50 04             	lea    0x4(%eax),%edx
  800689:	89 55 14             	mov    %edx,0x14(%ebp)
  80068c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80068e:	85 ff                	test   %edi,%edi
  800690:	ba cf 0f 80 00       	mov    $0x800fcf,%edx
  800695:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800698:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80069c:	0f 84 92 00 00 00    	je     800734 <vprintfmt+0x22c>
  8006a2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006a6:	0f 8e 96 00 00 00    	jle    800742 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	51                   	push   %ecx
  8006b0:	57                   	push   %edi
  8006b1:	e8 86 02 00 00       	call   80093c <strnlen>
  8006b6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006b9:	29 c1                	sub    %eax,%ecx
  8006bb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006be:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006c1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006cb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cd:	eb 0f                	jmp    8006de <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d8:	83 ef 01             	sub    $0x1,%edi
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	85 ff                	test   %edi,%edi
  8006e0:	7f ed                	jg     8006cf <vprintfmt+0x1c7>
  8006e2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006e5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006e8:	85 c9                	test   %ecx,%ecx
  8006ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ef:	0f 49 c1             	cmovns %ecx,%eax
  8006f2:	29 c1                	sub    %eax,%ecx
  8006f4:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006fd:	89 cb                	mov    %ecx,%ebx
  8006ff:	eb 4d                	jmp    80074e <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800701:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800705:	74 1b                	je     800722 <vprintfmt+0x21a>
  800707:	0f be c0             	movsbl %al,%eax
  80070a:	83 e8 20             	sub    $0x20,%eax
  80070d:	83 f8 5e             	cmp    $0x5e,%eax
  800710:	76 10                	jbe    800722 <vprintfmt+0x21a>
					putch('?', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	ff 75 0c             	pushl  0xc(%ebp)
  800718:	6a 3f                	push   $0x3f
  80071a:	ff 55 08             	call   *0x8(%ebp)
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	eb 0d                	jmp    80072f <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	ff 75 0c             	pushl  0xc(%ebp)
  800728:	52                   	push   %edx
  800729:	ff 55 08             	call   *0x8(%ebp)
  80072c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072f:	83 eb 01             	sub    $0x1,%ebx
  800732:	eb 1a                	jmp    80074e <vprintfmt+0x246>
  800734:	89 75 08             	mov    %esi,0x8(%ebp)
  800737:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80073a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800740:	eb 0c                	jmp    80074e <vprintfmt+0x246>
  800742:	89 75 08             	mov    %esi,0x8(%ebp)
  800745:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800748:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80074e:	83 c7 01             	add    $0x1,%edi
  800751:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800755:	0f be d0             	movsbl %al,%edx
  800758:	85 d2                	test   %edx,%edx
  80075a:	74 23                	je     80077f <vprintfmt+0x277>
  80075c:	85 f6                	test   %esi,%esi
  80075e:	78 a1                	js     800701 <vprintfmt+0x1f9>
  800760:	83 ee 01             	sub    $0x1,%esi
  800763:	79 9c                	jns    800701 <vprintfmt+0x1f9>
  800765:	89 df                	mov    %ebx,%edi
  800767:	8b 75 08             	mov    0x8(%ebp),%esi
  80076a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076d:	eb 18                	jmp    800787 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 20                	push   $0x20
  800775:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800777:	83 ef 01             	sub    $0x1,%edi
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	eb 08                	jmp    800787 <vprintfmt+0x27f>
  80077f:	89 df                	mov    %ebx,%edi
  800781:	8b 75 08             	mov    0x8(%ebp),%esi
  800784:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800787:	85 ff                	test   %edi,%edi
  800789:	7f e4                	jg     80076f <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80078e:	e9 9b fd ff ff       	jmp    80052e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800793:	83 fa 01             	cmp    $0x1,%edx
  800796:	7e 16                	jle    8007ae <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8d 50 08             	lea    0x8(%eax),%edx
  80079e:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a1:	8b 50 04             	mov    0x4(%eax),%edx
  8007a4:	8b 00                	mov    (%eax),%eax
  8007a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ac:	eb 32                	jmp    8007e0 <vprintfmt+0x2d8>
	else if (lflag)
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	74 18                	je     8007ca <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8d 50 04             	lea    0x4(%eax),%edx
  8007b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bb:	8b 00                	mov    (%eax),%eax
  8007bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c0:	89 c1                	mov    %eax,%ecx
  8007c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c8:	eb 16                	jmp    8007e0 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	8d 50 04             	lea    0x4(%eax),%edx
  8007d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d3:	8b 00                	mov    (%eax),%eax
  8007d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d8:	89 c1                	mov    %eax,%ecx
  8007da:	c1 f9 1f             	sar    $0x1f,%ecx
  8007dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007eb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ef:	79 74                	jns    800865 <vprintfmt+0x35d>
				putch('-', putdat);
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	53                   	push   %ebx
  8007f5:	6a 2d                	push   $0x2d
  8007f7:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007ff:	f7 d8                	neg    %eax
  800801:	83 d2 00             	adc    $0x0,%edx
  800804:	f7 da                	neg    %edx
  800806:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800809:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80080e:	eb 55                	jmp    800865 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800810:	8d 45 14             	lea    0x14(%ebp),%eax
  800813:	e8 7c fc ff ff       	call   800494 <getuint>
			base = 10;
  800818:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80081d:	eb 46                	jmp    800865 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80081f:	8d 45 14             	lea    0x14(%ebp),%eax
  800822:	e8 6d fc ff ff       	call   800494 <getuint>
                        base = 8;
  800827:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80082c:	eb 37                	jmp    800865 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80082e:	83 ec 08             	sub    $0x8,%esp
  800831:	53                   	push   %ebx
  800832:	6a 30                	push   $0x30
  800834:	ff d6                	call   *%esi
			putch('x', putdat);
  800836:	83 c4 08             	add    $0x8,%esp
  800839:	53                   	push   %ebx
  80083a:	6a 78                	push   $0x78
  80083c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8d 50 04             	lea    0x4(%eax),%edx
  800844:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800847:	8b 00                	mov    (%eax),%eax
  800849:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80084e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800851:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800856:	eb 0d                	jmp    800865 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800858:	8d 45 14             	lea    0x14(%ebp),%eax
  80085b:	e8 34 fc ff ff       	call   800494 <getuint>
			base = 16;
  800860:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800865:	83 ec 0c             	sub    $0xc,%esp
  800868:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80086c:	57                   	push   %edi
  80086d:	ff 75 e0             	pushl  -0x20(%ebp)
  800870:	51                   	push   %ecx
  800871:	52                   	push   %edx
  800872:	50                   	push   %eax
  800873:	89 da                	mov    %ebx,%edx
  800875:	89 f0                	mov    %esi,%eax
  800877:	e8 6e fb ff ff       	call   8003ea <printnum>
			break;
  80087c:	83 c4 20             	add    $0x20,%esp
  80087f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800882:	e9 a7 fc ff ff       	jmp    80052e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800887:	83 ec 08             	sub    $0x8,%esp
  80088a:	53                   	push   %ebx
  80088b:	51                   	push   %ecx
  80088c:	ff d6                	call   *%esi
			break;
  80088e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800891:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800894:	e9 95 fc ff ff       	jmp    80052e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800899:	83 ec 08             	sub    $0x8,%esp
  80089c:	53                   	push   %ebx
  80089d:	6a 25                	push   $0x25
  80089f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008a1:	83 c4 10             	add    $0x10,%esp
  8008a4:	eb 03                	jmp    8008a9 <vprintfmt+0x3a1>
  8008a6:	83 ef 01             	sub    $0x1,%edi
  8008a9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008ad:	75 f7                	jne    8008a6 <vprintfmt+0x39e>
  8008af:	e9 7a fc ff ff       	jmp    80052e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008b7:	5b                   	pop    %ebx
  8008b8:	5e                   	pop    %esi
  8008b9:	5f                   	pop    %edi
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	83 ec 18             	sub    $0x18,%esp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008d9:	85 c0                	test   %eax,%eax
  8008db:	74 26                	je     800903 <vsnprintf+0x47>
  8008dd:	85 d2                	test   %edx,%edx
  8008df:	7e 22                	jle    800903 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008e1:	ff 75 14             	pushl  0x14(%ebp)
  8008e4:	ff 75 10             	pushl  0x10(%ebp)
  8008e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ea:	50                   	push   %eax
  8008eb:	68 ce 04 80 00       	push   $0x8004ce
  8008f0:	e8 13 fc ff ff       	call   800508 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	eb 05                	jmp    800908 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800903:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800908:	c9                   	leave  
  800909:	c3                   	ret    

0080090a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800910:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800913:	50                   	push   %eax
  800914:	ff 75 10             	pushl  0x10(%ebp)
  800917:	ff 75 0c             	pushl  0xc(%ebp)
  80091a:	ff 75 08             	pushl  0x8(%ebp)
  80091d:	e8 9a ff ff ff       	call   8008bc <vsnprintf>
	va_end(ap);

	return rc;
}
  800922:	c9                   	leave  
  800923:	c3                   	ret    

00800924 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
  80092f:	eb 03                	jmp    800934 <strlen+0x10>
		n++;
  800931:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800934:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800938:	75 f7                	jne    800931 <strlen+0xd>
		n++;
	return n;
}
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800942:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800945:	ba 00 00 00 00       	mov    $0x0,%edx
  80094a:	eb 03                	jmp    80094f <strnlen+0x13>
		n++;
  80094c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094f:	39 c2                	cmp    %eax,%edx
  800951:	74 08                	je     80095b <strnlen+0x1f>
  800953:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800957:	75 f3                	jne    80094c <strnlen+0x10>
  800959:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	53                   	push   %ebx
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800967:	89 c2                	mov    %eax,%edx
  800969:	83 c2 01             	add    $0x1,%edx
  80096c:	83 c1 01             	add    $0x1,%ecx
  80096f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800973:	88 5a ff             	mov    %bl,-0x1(%edx)
  800976:	84 db                	test   %bl,%bl
  800978:	75 ef                	jne    800969 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80097a:	5b                   	pop    %ebx
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	53                   	push   %ebx
  800981:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800984:	53                   	push   %ebx
  800985:	e8 9a ff ff ff       	call   800924 <strlen>
  80098a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80098d:	ff 75 0c             	pushl  0xc(%ebp)
  800990:	01 d8                	add    %ebx,%eax
  800992:	50                   	push   %eax
  800993:	e8 c5 ff ff ff       	call   80095d <strcpy>
	return dst;
}
  800998:	89 d8                	mov    %ebx,%eax
  80099a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    

0080099f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009aa:	89 f3                	mov    %esi,%ebx
  8009ac:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009af:	89 f2                	mov    %esi,%edx
  8009b1:	eb 0f                	jmp    8009c2 <strncpy+0x23>
		*dst++ = *src;
  8009b3:	83 c2 01             	add    $0x1,%edx
  8009b6:	0f b6 01             	movzbl (%ecx),%eax
  8009b9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009bc:	80 39 01             	cmpb   $0x1,(%ecx)
  8009bf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c2:	39 da                	cmp    %ebx,%edx
  8009c4:	75 ed                	jne    8009b3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c6:	89 f0                	mov    %esi,%eax
  8009c8:	5b                   	pop    %ebx
  8009c9:	5e                   	pop    %esi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d7:	8b 55 10             	mov    0x10(%ebp),%edx
  8009da:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009dc:	85 d2                	test   %edx,%edx
  8009de:	74 21                	je     800a01 <strlcpy+0x35>
  8009e0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009e4:	89 f2                	mov    %esi,%edx
  8009e6:	eb 09                	jmp    8009f1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e8:	83 c2 01             	add    $0x1,%edx
  8009eb:	83 c1 01             	add    $0x1,%ecx
  8009ee:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f1:	39 c2                	cmp    %eax,%edx
  8009f3:	74 09                	je     8009fe <strlcpy+0x32>
  8009f5:	0f b6 19             	movzbl (%ecx),%ebx
  8009f8:	84 db                	test   %bl,%bl
  8009fa:	75 ec                	jne    8009e8 <strlcpy+0x1c>
  8009fc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009fe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a01:	29 f0                	sub    %esi,%eax
}
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a10:	eb 06                	jmp    800a18 <strcmp+0x11>
		p++, q++;
  800a12:	83 c1 01             	add    $0x1,%ecx
  800a15:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a18:	0f b6 01             	movzbl (%ecx),%eax
  800a1b:	84 c0                	test   %al,%al
  800a1d:	74 04                	je     800a23 <strcmp+0x1c>
  800a1f:	3a 02                	cmp    (%edx),%al
  800a21:	74 ef                	je     800a12 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a23:	0f b6 c0             	movzbl %al,%eax
  800a26:	0f b6 12             	movzbl (%edx),%edx
  800a29:	29 d0                	sub    %edx,%eax
}
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	53                   	push   %ebx
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a37:	89 c3                	mov    %eax,%ebx
  800a39:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a3c:	eb 06                	jmp    800a44 <strncmp+0x17>
		n--, p++, q++;
  800a3e:	83 c0 01             	add    $0x1,%eax
  800a41:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a44:	39 d8                	cmp    %ebx,%eax
  800a46:	74 15                	je     800a5d <strncmp+0x30>
  800a48:	0f b6 08             	movzbl (%eax),%ecx
  800a4b:	84 c9                	test   %cl,%cl
  800a4d:	74 04                	je     800a53 <strncmp+0x26>
  800a4f:	3a 0a                	cmp    (%edx),%cl
  800a51:	74 eb                	je     800a3e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a53:	0f b6 00             	movzbl (%eax),%eax
  800a56:	0f b6 12             	movzbl (%edx),%edx
  800a59:	29 d0                	sub    %edx,%eax
  800a5b:	eb 05                	jmp    800a62 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a5d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a62:	5b                   	pop    %ebx
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6f:	eb 07                	jmp    800a78 <strchr+0x13>
		if (*s == c)
  800a71:	38 ca                	cmp    %cl,%dl
  800a73:	74 0f                	je     800a84 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a75:	83 c0 01             	add    $0x1,%eax
  800a78:	0f b6 10             	movzbl (%eax),%edx
  800a7b:	84 d2                	test   %dl,%dl
  800a7d:	75 f2                	jne    800a71 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a90:	eb 03                	jmp    800a95 <strfind+0xf>
  800a92:	83 c0 01             	add    $0x1,%eax
  800a95:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a98:	84 d2                	test   %dl,%dl
  800a9a:	74 04                	je     800aa0 <strfind+0x1a>
  800a9c:	38 ca                	cmp    %cl,%dl
  800a9e:	75 f2                	jne    800a92 <strfind+0xc>
			break;
	return (char *) s;
}
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aae:	85 c9                	test   %ecx,%ecx
  800ab0:	74 36                	je     800ae8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab8:	75 28                	jne    800ae2 <memset+0x40>
  800aba:	f6 c1 03             	test   $0x3,%cl
  800abd:	75 23                	jne    800ae2 <memset+0x40>
		c &= 0xFF;
  800abf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac3:	89 d3                	mov    %edx,%ebx
  800ac5:	c1 e3 08             	shl    $0x8,%ebx
  800ac8:	89 d6                	mov    %edx,%esi
  800aca:	c1 e6 18             	shl    $0x18,%esi
  800acd:	89 d0                	mov    %edx,%eax
  800acf:	c1 e0 10             	shl    $0x10,%eax
  800ad2:	09 f0                	or     %esi,%eax
  800ad4:	09 c2                	or     %eax,%edx
  800ad6:	89 d0                	mov    %edx,%eax
  800ad8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ada:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800add:	fc                   	cld    
  800ade:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae0:	eb 06                	jmp    800ae8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae5:	fc                   	cld    
  800ae6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ae8:	89 f8                	mov    %edi,%eax
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800afd:	39 c6                	cmp    %eax,%esi
  800aff:	73 35                	jae    800b36 <memmove+0x47>
  800b01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b04:	39 d0                	cmp    %edx,%eax
  800b06:	73 2e                	jae    800b36 <memmove+0x47>
		s += n;
		d += n;
  800b08:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b0b:	89 d6                	mov    %edx,%esi
  800b0d:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b15:	75 13                	jne    800b2a <memmove+0x3b>
  800b17:	f6 c1 03             	test   $0x3,%cl
  800b1a:	75 0e                	jne    800b2a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b1c:	83 ef 04             	sub    $0x4,%edi
  800b1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b22:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b25:	fd                   	std    
  800b26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b28:	eb 09                	jmp    800b33 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b2a:	83 ef 01             	sub    $0x1,%edi
  800b2d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b30:	fd                   	std    
  800b31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b33:	fc                   	cld    
  800b34:	eb 1d                	jmp    800b53 <memmove+0x64>
  800b36:	89 f2                	mov    %esi,%edx
  800b38:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3a:	f6 c2 03             	test   $0x3,%dl
  800b3d:	75 0f                	jne    800b4e <memmove+0x5f>
  800b3f:	f6 c1 03             	test   $0x3,%cl
  800b42:	75 0a                	jne    800b4e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b44:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	fc                   	cld    
  800b4a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4c:	eb 05                	jmp    800b53 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b4e:	89 c7                	mov    %eax,%edi
  800b50:	fc                   	cld    
  800b51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b5a:	ff 75 10             	pushl  0x10(%ebp)
  800b5d:	ff 75 0c             	pushl  0xc(%ebp)
  800b60:	ff 75 08             	pushl  0x8(%ebp)
  800b63:	e8 87 ff ff ff       	call   800aef <memmove>
}
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b75:	89 c6                	mov    %eax,%esi
  800b77:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7a:	eb 1a                	jmp    800b96 <memcmp+0x2c>
		if (*s1 != *s2)
  800b7c:	0f b6 08             	movzbl (%eax),%ecx
  800b7f:	0f b6 1a             	movzbl (%edx),%ebx
  800b82:	38 d9                	cmp    %bl,%cl
  800b84:	74 0a                	je     800b90 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b86:	0f b6 c1             	movzbl %cl,%eax
  800b89:	0f b6 db             	movzbl %bl,%ebx
  800b8c:	29 d8                	sub    %ebx,%eax
  800b8e:	eb 0f                	jmp    800b9f <memcmp+0x35>
		s1++, s2++;
  800b90:	83 c0 01             	add    $0x1,%eax
  800b93:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b96:	39 f0                	cmp    %esi,%eax
  800b98:	75 e2                	jne    800b7c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bac:	89 c2                	mov    %eax,%edx
  800bae:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb1:	eb 07                	jmp    800bba <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb3:	38 08                	cmp    %cl,(%eax)
  800bb5:	74 07                	je     800bbe <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb7:	83 c0 01             	add    $0x1,%eax
  800bba:	39 d0                	cmp    %edx,%eax
  800bbc:	72 f5                	jb     800bb3 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcc:	eb 03                	jmp    800bd1 <strtol+0x11>
		s++;
  800bce:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd1:	0f b6 01             	movzbl (%ecx),%eax
  800bd4:	3c 09                	cmp    $0x9,%al
  800bd6:	74 f6                	je     800bce <strtol+0xe>
  800bd8:	3c 20                	cmp    $0x20,%al
  800bda:	74 f2                	je     800bce <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bdc:	3c 2b                	cmp    $0x2b,%al
  800bde:	75 0a                	jne    800bea <strtol+0x2a>
		s++;
  800be0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be3:	bf 00 00 00 00       	mov    $0x0,%edi
  800be8:	eb 10                	jmp    800bfa <strtol+0x3a>
  800bea:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bef:	3c 2d                	cmp    $0x2d,%al
  800bf1:	75 07                	jne    800bfa <strtol+0x3a>
		s++, neg = 1;
  800bf3:	8d 49 01             	lea    0x1(%ecx),%ecx
  800bf6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bfa:	85 db                	test   %ebx,%ebx
  800bfc:	0f 94 c0             	sete   %al
  800bff:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c05:	75 19                	jne    800c20 <strtol+0x60>
  800c07:	80 39 30             	cmpb   $0x30,(%ecx)
  800c0a:	75 14                	jne    800c20 <strtol+0x60>
  800c0c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c10:	0f 85 82 00 00 00    	jne    800c98 <strtol+0xd8>
		s += 2, base = 16;
  800c16:	83 c1 02             	add    $0x2,%ecx
  800c19:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c1e:	eb 16                	jmp    800c36 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c20:	84 c0                	test   %al,%al
  800c22:	74 12                	je     800c36 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c24:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c29:	80 39 30             	cmpb   $0x30,(%ecx)
  800c2c:	75 08                	jne    800c36 <strtol+0x76>
		s++, base = 8;
  800c2e:	83 c1 01             	add    $0x1,%ecx
  800c31:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c36:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c3e:	0f b6 11             	movzbl (%ecx),%edx
  800c41:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c44:	89 f3                	mov    %esi,%ebx
  800c46:	80 fb 09             	cmp    $0x9,%bl
  800c49:	77 08                	ja     800c53 <strtol+0x93>
			dig = *s - '0';
  800c4b:	0f be d2             	movsbl %dl,%edx
  800c4e:	83 ea 30             	sub    $0x30,%edx
  800c51:	eb 22                	jmp    800c75 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c53:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c56:	89 f3                	mov    %esi,%ebx
  800c58:	80 fb 19             	cmp    $0x19,%bl
  800c5b:	77 08                	ja     800c65 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c5d:	0f be d2             	movsbl %dl,%edx
  800c60:	83 ea 57             	sub    $0x57,%edx
  800c63:	eb 10                	jmp    800c75 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c65:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c68:	89 f3                	mov    %esi,%ebx
  800c6a:	80 fb 19             	cmp    $0x19,%bl
  800c6d:	77 16                	ja     800c85 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c6f:	0f be d2             	movsbl %dl,%edx
  800c72:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c75:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c78:	7d 0f                	jge    800c89 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c7a:	83 c1 01             	add    $0x1,%ecx
  800c7d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c81:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c83:	eb b9                	jmp    800c3e <strtol+0x7e>
  800c85:	89 c2                	mov    %eax,%edx
  800c87:	eb 02                	jmp    800c8b <strtol+0xcb>
  800c89:	89 c2                	mov    %eax,%edx

	if (endptr)
  800c8b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c8f:	74 0d                	je     800c9e <strtol+0xde>
		*endptr = (char *) s;
  800c91:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c94:	89 0e                	mov    %ecx,(%esi)
  800c96:	eb 06                	jmp    800c9e <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c98:	84 c0                	test   %al,%al
  800c9a:	75 92                	jne    800c2e <strtol+0x6e>
  800c9c:	eb 98                	jmp    800c36 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c9e:	f7 da                	neg    %edx
  800ca0:	85 ff                	test   %edi,%edi
  800ca2:	0f 45 c2             	cmovne %edx,%eax
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    
  800caa:	66 90                	xchg   %ax,%ax
  800cac:	66 90                	xchg   %ax,%ax
  800cae:	66 90                	xchg   %ax,%ax

00800cb0 <__udivdi3>:
  800cb0:	55                   	push   %ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	83 ec 10             	sub    $0x10,%esp
  800cb6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800cba:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800cbe:	8b 74 24 24          	mov    0x24(%esp),%esi
  800cc2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800cc6:	85 d2                	test   %edx,%edx
  800cc8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ccc:	89 34 24             	mov    %esi,(%esp)
  800ccf:	89 c8                	mov    %ecx,%eax
  800cd1:	75 35                	jne    800d08 <__udivdi3+0x58>
  800cd3:	39 f1                	cmp    %esi,%ecx
  800cd5:	0f 87 bd 00 00 00    	ja     800d98 <__udivdi3+0xe8>
  800cdb:	85 c9                	test   %ecx,%ecx
  800cdd:	89 cd                	mov    %ecx,%ebp
  800cdf:	75 0b                	jne    800cec <__udivdi3+0x3c>
  800ce1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce6:	31 d2                	xor    %edx,%edx
  800ce8:	f7 f1                	div    %ecx
  800cea:	89 c5                	mov    %eax,%ebp
  800cec:	89 f0                	mov    %esi,%eax
  800cee:	31 d2                	xor    %edx,%edx
  800cf0:	f7 f5                	div    %ebp
  800cf2:	89 c6                	mov    %eax,%esi
  800cf4:	89 f8                	mov    %edi,%eax
  800cf6:	f7 f5                	div    %ebp
  800cf8:	89 f2                	mov    %esi,%edx
  800cfa:	83 c4 10             	add    $0x10,%esp
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    
  800d01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d08:	3b 14 24             	cmp    (%esp),%edx
  800d0b:	77 7b                	ja     800d88 <__udivdi3+0xd8>
  800d0d:	0f bd f2             	bsr    %edx,%esi
  800d10:	83 f6 1f             	xor    $0x1f,%esi
  800d13:	0f 84 97 00 00 00    	je     800db0 <__udivdi3+0x100>
  800d19:	bd 20 00 00 00       	mov    $0x20,%ebp
  800d1e:	89 d7                	mov    %edx,%edi
  800d20:	89 f1                	mov    %esi,%ecx
  800d22:	29 f5                	sub    %esi,%ebp
  800d24:	d3 e7                	shl    %cl,%edi
  800d26:	89 c2                	mov    %eax,%edx
  800d28:	89 e9                	mov    %ebp,%ecx
  800d2a:	d3 ea                	shr    %cl,%edx
  800d2c:	89 f1                	mov    %esi,%ecx
  800d2e:	09 fa                	or     %edi,%edx
  800d30:	8b 3c 24             	mov    (%esp),%edi
  800d33:	d3 e0                	shl    %cl,%eax
  800d35:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d39:	89 e9                	mov    %ebp,%ecx
  800d3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d3f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d43:	89 fa                	mov    %edi,%edx
  800d45:	d3 ea                	shr    %cl,%edx
  800d47:	89 f1                	mov    %esi,%ecx
  800d49:	d3 e7                	shl    %cl,%edi
  800d4b:	89 e9                	mov    %ebp,%ecx
  800d4d:	d3 e8                	shr    %cl,%eax
  800d4f:	09 c7                	or     %eax,%edi
  800d51:	89 f8                	mov    %edi,%eax
  800d53:	f7 74 24 08          	divl   0x8(%esp)
  800d57:	89 d5                	mov    %edx,%ebp
  800d59:	89 c7                	mov    %eax,%edi
  800d5b:	f7 64 24 0c          	mull   0xc(%esp)
  800d5f:	39 d5                	cmp    %edx,%ebp
  800d61:	89 14 24             	mov    %edx,(%esp)
  800d64:	72 11                	jb     800d77 <__udivdi3+0xc7>
  800d66:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d6a:	89 f1                	mov    %esi,%ecx
  800d6c:	d3 e2                	shl    %cl,%edx
  800d6e:	39 c2                	cmp    %eax,%edx
  800d70:	73 5e                	jae    800dd0 <__udivdi3+0x120>
  800d72:	3b 2c 24             	cmp    (%esp),%ebp
  800d75:	75 59                	jne    800dd0 <__udivdi3+0x120>
  800d77:	8d 47 ff             	lea    -0x1(%edi),%eax
  800d7a:	31 f6                	xor    %esi,%esi
  800d7c:	89 f2                	mov    %esi,%edx
  800d7e:	83 c4 10             	add    $0x10,%esp
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
  800d85:	8d 76 00             	lea    0x0(%esi),%esi
  800d88:	31 f6                	xor    %esi,%esi
  800d8a:	31 c0                	xor    %eax,%eax
  800d8c:	89 f2                	mov    %esi,%edx
  800d8e:	83 c4 10             	add    $0x10,%esp
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
  800d98:	89 f2                	mov    %esi,%edx
  800d9a:	31 f6                	xor    %esi,%esi
  800d9c:	89 f8                	mov    %edi,%eax
  800d9e:	f7 f1                	div    %ecx
  800da0:	89 f2                	mov    %esi,%edx
  800da2:	83 c4 10             	add    $0x10,%esp
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    
  800da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800db4:	76 0b                	jbe    800dc1 <__udivdi3+0x111>
  800db6:	31 c0                	xor    %eax,%eax
  800db8:	3b 14 24             	cmp    (%esp),%edx
  800dbb:	0f 83 37 ff ff ff    	jae    800cf8 <__udivdi3+0x48>
  800dc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc6:	e9 2d ff ff ff       	jmp    800cf8 <__udivdi3+0x48>
  800dcb:	90                   	nop
  800dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dd0:	89 f8                	mov    %edi,%eax
  800dd2:	31 f6                	xor    %esi,%esi
  800dd4:	e9 1f ff ff ff       	jmp    800cf8 <__udivdi3+0x48>
  800dd9:	66 90                	xchg   %ax,%ax
  800ddb:	66 90                	xchg   %ax,%ax
  800ddd:	66 90                	xchg   %ax,%ax
  800ddf:	90                   	nop

00800de0 <__umoddi3>:
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	83 ec 20             	sub    $0x20,%esp
  800de6:	8b 44 24 34          	mov    0x34(%esp),%eax
  800dea:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800dee:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800df2:	89 c6                	mov    %eax,%esi
  800df4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800dfc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800e00:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e04:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800e08:	89 74 24 18          	mov    %esi,0x18(%esp)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	89 c2                	mov    %eax,%edx
  800e10:	75 1e                	jne    800e30 <__umoddi3+0x50>
  800e12:	39 f7                	cmp    %esi,%edi
  800e14:	76 52                	jbe    800e68 <__umoddi3+0x88>
  800e16:	89 c8                	mov    %ecx,%eax
  800e18:	89 f2                	mov    %esi,%edx
  800e1a:	f7 f7                	div    %edi
  800e1c:	89 d0                	mov    %edx,%eax
  800e1e:	31 d2                	xor    %edx,%edx
  800e20:	83 c4 20             	add    $0x20,%esp
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    
  800e27:	89 f6                	mov    %esi,%esi
  800e29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e30:	39 f0                	cmp    %esi,%eax
  800e32:	77 5c                	ja     800e90 <__umoddi3+0xb0>
  800e34:	0f bd e8             	bsr    %eax,%ebp
  800e37:	83 f5 1f             	xor    $0x1f,%ebp
  800e3a:	75 64                	jne    800ea0 <__umoddi3+0xc0>
  800e3c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800e40:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800e44:	0f 86 f6 00 00 00    	jbe    800f40 <__umoddi3+0x160>
  800e4a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800e4e:	0f 82 ec 00 00 00    	jb     800f40 <__umoddi3+0x160>
  800e54:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e58:	8b 54 24 18          	mov    0x18(%esp),%edx
  800e5c:	83 c4 20             	add    $0x20,%esp
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    
  800e63:	90                   	nop
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	85 ff                	test   %edi,%edi
  800e6a:	89 fd                	mov    %edi,%ebp
  800e6c:	75 0b                	jne    800e79 <__umoddi3+0x99>
  800e6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e73:	31 d2                	xor    %edx,%edx
  800e75:	f7 f7                	div    %edi
  800e77:	89 c5                	mov    %eax,%ebp
  800e79:	8b 44 24 10          	mov    0x10(%esp),%eax
  800e7d:	31 d2                	xor    %edx,%edx
  800e7f:	f7 f5                	div    %ebp
  800e81:	89 c8                	mov    %ecx,%eax
  800e83:	f7 f5                	div    %ebp
  800e85:	eb 95                	jmp    800e1c <__umoddi3+0x3c>
  800e87:	89 f6                	mov    %esi,%esi
  800e89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e90:	89 c8                	mov    %ecx,%eax
  800e92:	89 f2                	mov    %esi,%edx
  800e94:	83 c4 20             	add    $0x20,%esp
  800e97:	5e                   	pop    %esi
  800e98:	5f                   	pop    %edi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    
  800e9b:	90                   	nop
  800e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea5:	89 e9                	mov    %ebp,%ecx
  800ea7:	29 e8                	sub    %ebp,%eax
  800ea9:	d3 e2                	shl    %cl,%edx
  800eab:	89 c7                	mov    %eax,%edi
  800ead:	89 44 24 18          	mov    %eax,0x18(%esp)
  800eb1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eb5:	89 f9                	mov    %edi,%ecx
  800eb7:	d3 e8                	shr    %cl,%eax
  800eb9:	89 c1                	mov    %eax,%ecx
  800ebb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ebf:	09 d1                	or     %edx,%ecx
  800ec1:	89 fa                	mov    %edi,%edx
  800ec3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ec7:	89 e9                	mov    %ebp,%ecx
  800ec9:	d3 e0                	shl    %cl,%eax
  800ecb:	89 f9                	mov    %edi,%ecx
  800ecd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	d3 e8                	shr    %cl,%eax
  800ed5:	89 e9                	mov    %ebp,%ecx
  800ed7:	89 c7                	mov    %eax,%edi
  800ed9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800edd:	d3 e6                	shl    %cl,%esi
  800edf:	89 d1                	mov    %edx,%ecx
  800ee1:	89 fa                	mov    %edi,%edx
  800ee3:	d3 e8                	shr    %cl,%eax
  800ee5:	89 e9                	mov    %ebp,%ecx
  800ee7:	09 f0                	or     %esi,%eax
  800ee9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800eed:	f7 74 24 10          	divl   0x10(%esp)
  800ef1:	d3 e6                	shl    %cl,%esi
  800ef3:	89 d1                	mov    %edx,%ecx
  800ef5:	f7 64 24 0c          	mull   0xc(%esp)
  800ef9:	39 d1                	cmp    %edx,%ecx
  800efb:	89 74 24 14          	mov    %esi,0x14(%esp)
  800eff:	89 d7                	mov    %edx,%edi
  800f01:	89 c6                	mov    %eax,%esi
  800f03:	72 0a                	jb     800f0f <__umoddi3+0x12f>
  800f05:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800f09:	73 10                	jae    800f1b <__umoddi3+0x13b>
  800f0b:	39 d1                	cmp    %edx,%ecx
  800f0d:	75 0c                	jne    800f1b <__umoddi3+0x13b>
  800f0f:	89 d7                	mov    %edx,%edi
  800f11:	89 c6                	mov    %eax,%esi
  800f13:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800f17:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800f1b:	89 ca                	mov    %ecx,%edx
  800f1d:	89 e9                	mov    %ebp,%ecx
  800f1f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f23:	29 f0                	sub    %esi,%eax
  800f25:	19 fa                	sbb    %edi,%edx
  800f27:	d3 e8                	shr    %cl,%eax
  800f29:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800f2e:	89 d7                	mov    %edx,%edi
  800f30:	d3 e7                	shl    %cl,%edi
  800f32:	89 e9                	mov    %ebp,%ecx
  800f34:	09 f8                	or     %edi,%eax
  800f36:	d3 ea                	shr    %cl,%edx
  800f38:	83 c4 20             	add    $0x20,%esp
  800f3b:	5e                   	pop    %esi
  800f3c:	5f                   	pop    %edi
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    
  800f3f:	90                   	nop
  800f40:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f44:	29 f9                	sub    %edi,%ecx
  800f46:	19 c6                	sbb    %eax,%esi
  800f48:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800f4c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f50:	e9 ff fe ff ff       	jmp    800e54 <__umoddi3+0x74>
