
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80004d:	e8 c6 00 00 00       	call   800118 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
  80007e:	83 c4 10             	add    $0x10,%esp
}
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
  800095:	83 c4 10             	add    $0x10,%esp
}
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 8a 0f 80 00       	push   $0x800f8a
  800104:	6a 23                	push   $0x23
  800106:	68 a7 0f 80 00       	push   $0x800fa7
  80010b:	e8 f5 01 00 00       	call   800305 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0a 00 00 00       	mov    $0xa,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 8a 0f 80 00       	push   $0x800f8a
  800185:	6a 23                	push   $0x23
  800187:	68 a7 0f 80 00       	push   $0x800fa7
  80018c:	e8 74 01 00 00       	call   800305 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 8a 0f 80 00       	push   $0x800f8a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 a7 0f 80 00       	push   $0x800fa7
  8001ce:	e8 32 01 00 00       	call   800305 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 8a 0f 80 00       	push   $0x800f8a
  800209:	6a 23                	push   $0x23
  80020b:	68 a7 0f 80 00       	push   $0x800fa7
  800210:	e8 f0 00 00 00       	call   800305 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 8a 0f 80 00       	push   $0x800f8a
  80024b:	6a 23                	push   $0x23
  80024d:	68 a7 0f 80 00       	push   $0x800fa7
  800252:	e8 ae 00 00 00       	call   800305 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 8a 0f 80 00       	push   $0x800f8a
  80028d:	6a 23                	push   $0x23
  80028f:	68 a7 0f 80 00       	push   $0x800fa7
  800294:	e8 6c 00 00 00       	call   800305 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a7:	be 00 00 00 00       	mov    $0x0,%esi
  8002ac:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ba:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002bd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	89 cb                	mov    %ecx,%ebx
  8002dc:	89 cf                	mov    %ecx,%edi
  8002de:	89 ce                	mov    %ecx,%esi
  8002e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e2:	85 c0                	test   %eax,%eax
  8002e4:	7e 17                	jle    8002fd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e6:	83 ec 0c             	sub    $0xc,%esp
  8002e9:	50                   	push   %eax
  8002ea:	6a 0c                	push   $0xc
  8002ec:	68 8a 0f 80 00       	push   $0x800f8a
  8002f1:	6a 23                	push   $0x23
  8002f3:	68 a7 0f 80 00       	push   $0x800fa7
  8002f8:	e8 08 00 00 00       	call   800305 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80030a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80030d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800313:	e8 00 fe ff ff       	call   800118 <sys_getenvid>
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	ff 75 0c             	pushl  0xc(%ebp)
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	56                   	push   %esi
  800322:	50                   	push   %eax
  800323:	68 b8 0f 80 00       	push   $0x800fb8
  800328:	e8 b1 00 00 00       	call   8003de <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80032d:	83 c4 18             	add    $0x18,%esp
  800330:	53                   	push   %ebx
  800331:	ff 75 10             	pushl  0x10(%ebp)
  800334:	e8 54 00 00 00       	call   80038d <vcprintf>
	cprintf("\n");
  800339:	c7 04 24 dc 0f 80 00 	movl   $0x800fdc,(%esp)
  800340:	e8 99 00 00 00       	call   8003de <cprintf>
  800345:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800348:	cc                   	int3   
  800349:	eb fd                	jmp    800348 <_panic+0x43>

0080034b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	53                   	push   %ebx
  80034f:	83 ec 04             	sub    $0x4,%esp
  800352:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800355:	8b 13                	mov    (%ebx),%edx
  800357:	8d 42 01             	lea    0x1(%edx),%eax
  80035a:	89 03                	mov    %eax,(%ebx)
  80035c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800363:	3d ff 00 00 00       	cmp    $0xff,%eax
  800368:	75 1a                	jne    800384 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80036a:	83 ec 08             	sub    $0x8,%esp
  80036d:	68 ff 00 00 00       	push   $0xff
  800372:	8d 43 08             	lea    0x8(%ebx),%eax
  800375:	50                   	push   %eax
  800376:	e8 1f fd ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  80037b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800381:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800384:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80038b:	c9                   	leave  
  80038c:	c3                   	ret    

0080038d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800396:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80039d:	00 00 00 
	b.cnt = 0;
  8003a0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003aa:	ff 75 0c             	pushl  0xc(%ebp)
  8003ad:	ff 75 08             	pushl  0x8(%ebp)
  8003b0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b6:	50                   	push   %eax
  8003b7:	68 4b 03 80 00       	push   $0x80034b
  8003bc:	e8 4f 01 00 00       	call   800510 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c1:	83 c4 08             	add    $0x8,%esp
  8003c4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ca:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d0:	50                   	push   %eax
  8003d1:	e8 c4 fc ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8003d6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    

008003de <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e7:	50                   	push   %eax
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	e8 9d ff ff ff       	call   80038d <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    

008003f2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	57                   	push   %edi
  8003f6:	56                   	push   %esi
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 1c             	sub    $0x1c,%esp
  8003fb:	89 c7                	mov    %eax,%edi
  8003fd:	89 d6                	mov    %edx,%esi
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 d1                	mov    %edx,%ecx
  800407:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80040d:	8b 45 10             	mov    0x10(%ebp),%eax
  800410:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800413:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800416:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80041d:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800420:	72 05                	jb     800427 <printnum+0x35>
  800422:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800425:	77 3e                	ja     800465 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff 75 18             	pushl  0x18(%ebp)
  80042d:	83 eb 01             	sub    $0x1,%ebx
  800430:	53                   	push   %ebx
  800431:	50                   	push   %eax
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	ff 75 e4             	pushl  -0x1c(%ebp)
  800438:	ff 75 e0             	pushl  -0x20(%ebp)
  80043b:	ff 75 dc             	pushl  -0x24(%ebp)
  80043e:	ff 75 d8             	pushl  -0x28(%ebp)
  800441:	e8 7a 08 00 00       	call   800cc0 <__udivdi3>
  800446:	83 c4 18             	add    $0x18,%esp
  800449:	52                   	push   %edx
  80044a:	50                   	push   %eax
  80044b:	89 f2                	mov    %esi,%edx
  80044d:	89 f8                	mov    %edi,%eax
  80044f:	e8 9e ff ff ff       	call   8003f2 <printnum>
  800454:	83 c4 20             	add    $0x20,%esp
  800457:	eb 13                	jmp    80046c <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	56                   	push   %esi
  80045d:	ff 75 18             	pushl  0x18(%ebp)
  800460:	ff d7                	call   *%edi
  800462:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800465:	83 eb 01             	sub    $0x1,%ebx
  800468:	85 db                	test   %ebx,%ebx
  80046a:	7f ed                	jg     800459 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	56                   	push   %esi
  800470:	83 ec 04             	sub    $0x4,%esp
  800473:	ff 75 e4             	pushl  -0x1c(%ebp)
  800476:	ff 75 e0             	pushl  -0x20(%ebp)
  800479:	ff 75 dc             	pushl  -0x24(%ebp)
  80047c:	ff 75 d8             	pushl  -0x28(%ebp)
  80047f:	e8 6c 09 00 00       	call   800df0 <__umoddi3>
  800484:	83 c4 14             	add    $0x14,%esp
  800487:	0f be 80 de 0f 80 00 	movsbl 0x800fde(%eax),%eax
  80048e:	50                   	push   %eax
  80048f:	ff d7                	call   *%edi
  800491:	83 c4 10             	add    $0x10,%esp
}
  800494:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800497:	5b                   	pop    %ebx
  800498:	5e                   	pop    %esi
  800499:	5f                   	pop    %edi
  80049a:	5d                   	pop    %ebp
  80049b:	c3                   	ret    

0080049c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80049f:	83 fa 01             	cmp    $0x1,%edx
  8004a2:	7e 0e                	jle    8004b2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a4:	8b 10                	mov    (%eax),%edx
  8004a6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a9:	89 08                	mov    %ecx,(%eax)
  8004ab:	8b 02                	mov    (%edx),%eax
  8004ad:	8b 52 04             	mov    0x4(%edx),%edx
  8004b0:	eb 22                	jmp    8004d4 <getuint+0x38>
	else if (lflag)
  8004b2:	85 d2                	test   %edx,%edx
  8004b4:	74 10                	je     8004c6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004bb:	89 08                	mov    %ecx,(%eax)
  8004bd:	8b 02                	mov    (%edx),%eax
  8004bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c4:	eb 0e                	jmp    8004d4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c6:	8b 10                	mov    (%eax),%edx
  8004c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cb:	89 08                	mov    %ecx,(%eax)
  8004cd:	8b 02                	mov    (%edx),%eax
  8004cf:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004dc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e0:	8b 10                	mov    (%eax),%edx
  8004e2:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e5:	73 0a                	jae    8004f1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ea:	89 08                	mov    %ecx,(%eax)
  8004ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ef:	88 02                	mov    %al,(%edx)
}
  8004f1:	5d                   	pop    %ebp
  8004f2:	c3                   	ret    

008004f3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f3:	55                   	push   %ebp
  8004f4:	89 e5                	mov    %esp,%ebp
  8004f6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004fc:	50                   	push   %eax
  8004fd:	ff 75 10             	pushl  0x10(%ebp)
  800500:	ff 75 0c             	pushl  0xc(%ebp)
  800503:	ff 75 08             	pushl  0x8(%ebp)
  800506:	e8 05 00 00 00       	call   800510 <vprintfmt>
	va_end(ap);
  80050b:	83 c4 10             	add    $0x10,%esp
}
  80050e:	c9                   	leave  
  80050f:	c3                   	ret    

00800510 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	57                   	push   %edi
  800514:	56                   	push   %esi
  800515:	53                   	push   %ebx
  800516:	83 ec 2c             	sub    $0x2c,%esp
  800519:	8b 75 08             	mov    0x8(%ebp),%esi
  80051c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800522:	eb 12                	jmp    800536 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800524:	85 c0                	test   %eax,%eax
  800526:	0f 84 90 03 00 00    	je     8008bc <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	53                   	push   %ebx
  800530:	50                   	push   %eax
  800531:	ff d6                	call   *%esi
  800533:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800536:	83 c7 01             	add    $0x1,%edi
  800539:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053d:	83 f8 25             	cmp    $0x25,%eax
  800540:	75 e2                	jne    800524 <vprintfmt+0x14>
  800542:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800546:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80054d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800554:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80055b:	ba 00 00 00 00       	mov    $0x0,%edx
  800560:	eb 07                	jmp    800569 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800565:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800569:	8d 47 01             	lea    0x1(%edi),%eax
  80056c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056f:	0f b6 07             	movzbl (%edi),%eax
  800572:	0f b6 c8             	movzbl %al,%ecx
  800575:	83 e8 23             	sub    $0x23,%eax
  800578:	3c 55                	cmp    $0x55,%al
  80057a:	0f 87 21 03 00 00    	ja     8008a1 <vprintfmt+0x391>
  800580:	0f b6 c0             	movzbl %al,%eax
  800583:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80058d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800591:	eb d6                	jmp    800569 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800593:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800596:	b8 00 00 00 00       	mov    $0x0,%eax
  80059b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80059e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005a5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005a8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005ab:	83 fa 09             	cmp    $0x9,%edx
  8005ae:	77 39                	ja     8005e9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005b3:	eb e9                	jmp    80059e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 48 04             	lea    0x4(%eax),%ecx
  8005bb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005be:	8b 00                	mov    (%eax),%eax
  8005c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005c6:	eb 27                	jmp    8005ef <vprintfmt+0xdf>
  8005c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d2:	0f 49 c8             	cmovns %eax,%ecx
  8005d5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005db:	eb 8c                	jmp    800569 <vprintfmt+0x59>
  8005dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005e7:	eb 80                	jmp    800569 <vprintfmt+0x59>
  8005e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ec:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f3:	0f 89 70 ff ff ff    	jns    800569 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ff:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800606:	e9 5e ff ff ff       	jmp    800569 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80060b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800611:	e9 53 ff ff ff       	jmp    800569 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 50 04             	lea    0x4(%eax),%edx
  80061c:	89 55 14             	mov    %edx,0x14(%ebp)
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	ff 30                	pushl  (%eax)
  800625:	ff d6                	call   *%esi
			break;
  800627:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80062d:	e9 04 ff ff ff       	jmp    800536 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 04             	lea    0x4(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	99                   	cltd   
  80063e:	31 d0                	xor    %edx,%eax
  800640:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800642:	83 f8 09             	cmp    $0x9,%eax
  800645:	7f 0b                	jg     800652 <vprintfmt+0x142>
  800647:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  80064e:	85 d2                	test   %edx,%edx
  800650:	75 18                	jne    80066a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800652:	50                   	push   %eax
  800653:	68 f6 0f 80 00       	push   $0x800ff6
  800658:	53                   	push   %ebx
  800659:	56                   	push   %esi
  80065a:	e8 94 fe ff ff       	call   8004f3 <printfmt>
  80065f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800665:	e9 cc fe ff ff       	jmp    800536 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80066a:	52                   	push   %edx
  80066b:	68 ff 0f 80 00       	push   $0x800fff
  800670:	53                   	push   %ebx
  800671:	56                   	push   %esi
  800672:	e8 7c fe ff ff       	call   8004f3 <printfmt>
  800677:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067d:	e9 b4 fe ff ff       	jmp    800536 <vprintfmt+0x26>
  800682:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800685:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800688:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 50 04             	lea    0x4(%eax),%edx
  800691:	89 55 14             	mov    %edx,0x14(%ebp)
  800694:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800696:	85 ff                	test   %edi,%edi
  800698:	ba ef 0f 80 00       	mov    $0x800fef,%edx
  80069d:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8006a0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006a4:	0f 84 92 00 00 00    	je     80073c <vprintfmt+0x22c>
  8006aa:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006ae:	0f 8e 96 00 00 00    	jle    80074a <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	51                   	push   %ecx
  8006b8:	57                   	push   %edi
  8006b9:	e8 86 02 00 00       	call   800944 <strnlen>
  8006be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006c1:	29 c1                	sub    %eax,%ecx
  8006c3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006c6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006c9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006d3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d5:	eb 0f                	jmp    8006e6 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	53                   	push   %ebx
  8006db:	ff 75 e0             	pushl  -0x20(%ebp)
  8006de:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e0:	83 ef 01             	sub    $0x1,%edi
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	85 ff                	test   %edi,%edi
  8006e8:	7f ed                	jg     8006d7 <vprintfmt+0x1c7>
  8006ea:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ed:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006f0:	85 c9                	test   %ecx,%ecx
  8006f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f7:	0f 49 c1             	cmovns %ecx,%eax
  8006fa:	29 c1                	sub    %eax,%ecx
  8006fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800702:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800705:	89 cb                	mov    %ecx,%ebx
  800707:	eb 4d                	jmp    800756 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800709:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80070d:	74 1b                	je     80072a <vprintfmt+0x21a>
  80070f:	0f be c0             	movsbl %al,%eax
  800712:	83 e8 20             	sub    $0x20,%eax
  800715:	83 f8 5e             	cmp    $0x5e,%eax
  800718:	76 10                	jbe    80072a <vprintfmt+0x21a>
					putch('?', putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	ff 75 0c             	pushl  0xc(%ebp)
  800720:	6a 3f                	push   $0x3f
  800722:	ff 55 08             	call   *0x8(%ebp)
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	eb 0d                	jmp    800737 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	52                   	push   %edx
  800731:	ff 55 08             	call   *0x8(%ebp)
  800734:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800737:	83 eb 01             	sub    $0x1,%ebx
  80073a:	eb 1a                	jmp    800756 <vprintfmt+0x246>
  80073c:	89 75 08             	mov    %esi,0x8(%ebp)
  80073f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800742:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800745:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800748:	eb 0c                	jmp    800756 <vprintfmt+0x246>
  80074a:	89 75 08             	mov    %esi,0x8(%ebp)
  80074d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800750:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800753:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800756:	83 c7 01             	add    $0x1,%edi
  800759:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80075d:	0f be d0             	movsbl %al,%edx
  800760:	85 d2                	test   %edx,%edx
  800762:	74 23                	je     800787 <vprintfmt+0x277>
  800764:	85 f6                	test   %esi,%esi
  800766:	78 a1                	js     800709 <vprintfmt+0x1f9>
  800768:	83 ee 01             	sub    $0x1,%esi
  80076b:	79 9c                	jns    800709 <vprintfmt+0x1f9>
  80076d:	89 df                	mov    %ebx,%edi
  80076f:	8b 75 08             	mov    0x8(%ebp),%esi
  800772:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800775:	eb 18                	jmp    80078f <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800777:	83 ec 08             	sub    $0x8,%esp
  80077a:	53                   	push   %ebx
  80077b:	6a 20                	push   $0x20
  80077d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80077f:	83 ef 01             	sub    $0x1,%edi
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	eb 08                	jmp    80078f <vprintfmt+0x27f>
  800787:	89 df                	mov    %ebx,%edi
  800789:	8b 75 08             	mov    0x8(%ebp),%esi
  80078c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80078f:	85 ff                	test   %edi,%edi
  800791:	7f e4                	jg     800777 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800793:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800796:	e9 9b fd ff ff       	jmp    800536 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80079b:	83 fa 01             	cmp    $0x1,%edx
  80079e:	7e 16                	jle    8007b6 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8d 50 08             	lea    0x8(%eax),%edx
  8007a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a9:	8b 50 04             	mov    0x4(%eax),%edx
  8007ac:	8b 00                	mov    (%eax),%eax
  8007ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007b4:	eb 32                	jmp    8007e8 <vprintfmt+0x2d8>
	else if (lflag)
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	74 18                	je     8007d2 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8d 50 04             	lea    0x4(%eax),%edx
  8007c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c3:	8b 00                	mov    (%eax),%eax
  8007c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c8:	89 c1                	mov    %eax,%ecx
  8007ca:	c1 f9 1f             	sar    $0x1f,%ecx
  8007cd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007d0:	eb 16                	jmp    8007e8 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8d 50 04             	lea    0x4(%eax),%edx
  8007d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e0:	89 c1                	mov    %eax,%ecx
  8007e2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007eb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007f7:	79 74                	jns    80086d <vprintfmt+0x35d>
				putch('-', putdat);
  8007f9:	83 ec 08             	sub    $0x8,%esp
  8007fc:	53                   	push   %ebx
  8007fd:	6a 2d                	push   $0x2d
  8007ff:	ff d6                	call   *%esi
				num = -(long long) num;
  800801:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800804:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800807:	f7 d8                	neg    %eax
  800809:	83 d2 00             	adc    $0x0,%edx
  80080c:	f7 da                	neg    %edx
  80080e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800811:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800816:	eb 55                	jmp    80086d <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800818:	8d 45 14             	lea    0x14(%ebp),%eax
  80081b:	e8 7c fc ff ff       	call   80049c <getuint>
			base = 10;
  800820:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800825:	eb 46                	jmp    80086d <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800827:	8d 45 14             	lea    0x14(%ebp),%eax
  80082a:	e8 6d fc ff ff       	call   80049c <getuint>
                        base = 8;
  80082f:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800834:	eb 37                	jmp    80086d <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800836:	83 ec 08             	sub    $0x8,%esp
  800839:	53                   	push   %ebx
  80083a:	6a 30                	push   $0x30
  80083c:	ff d6                	call   *%esi
			putch('x', putdat);
  80083e:	83 c4 08             	add    $0x8,%esp
  800841:	53                   	push   %ebx
  800842:	6a 78                	push   $0x78
  800844:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8d 50 04             	lea    0x4(%eax),%edx
  80084c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80084f:	8b 00                	mov    (%eax),%eax
  800851:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800856:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800859:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80085e:	eb 0d                	jmp    80086d <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800860:	8d 45 14             	lea    0x14(%ebp),%eax
  800863:	e8 34 fc ff ff       	call   80049c <getuint>
			base = 16;
  800868:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80086d:	83 ec 0c             	sub    $0xc,%esp
  800870:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800874:	57                   	push   %edi
  800875:	ff 75 e0             	pushl  -0x20(%ebp)
  800878:	51                   	push   %ecx
  800879:	52                   	push   %edx
  80087a:	50                   	push   %eax
  80087b:	89 da                	mov    %ebx,%edx
  80087d:	89 f0                	mov    %esi,%eax
  80087f:	e8 6e fb ff ff       	call   8003f2 <printnum>
			break;
  800884:	83 c4 20             	add    $0x20,%esp
  800887:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088a:	e9 a7 fc ff ff       	jmp    800536 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	53                   	push   %ebx
  800893:	51                   	push   %ecx
  800894:	ff d6                	call   *%esi
			break;
  800896:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800899:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80089c:	e9 95 fc ff ff       	jmp    800536 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	53                   	push   %ebx
  8008a5:	6a 25                	push   $0x25
  8008a7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	eb 03                	jmp    8008b1 <vprintfmt+0x3a1>
  8008ae:	83 ef 01             	sub    $0x1,%edi
  8008b1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008b5:	75 f7                	jne    8008ae <vprintfmt+0x39e>
  8008b7:	e9 7a fc ff ff       	jmp    800536 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008bf:	5b                   	pop    %ebx
  8008c0:	5e                   	pop    %esi
  8008c1:	5f                   	pop    %edi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	83 ec 18             	sub    $0x18,%esp
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008d3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008d7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008e1:	85 c0                	test   %eax,%eax
  8008e3:	74 26                	je     80090b <vsnprintf+0x47>
  8008e5:	85 d2                	test   %edx,%edx
  8008e7:	7e 22                	jle    80090b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008e9:	ff 75 14             	pushl  0x14(%ebp)
  8008ec:	ff 75 10             	pushl  0x10(%ebp)
  8008ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008f2:	50                   	push   %eax
  8008f3:	68 d6 04 80 00       	push   $0x8004d6
  8008f8:	e8 13 fc ff ff       	call   800510 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800900:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800903:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800906:	83 c4 10             	add    $0x10,%esp
  800909:	eb 05                	jmp    800910 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80090b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800910:	c9                   	leave  
  800911:	c3                   	ret    

00800912 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800918:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80091b:	50                   	push   %eax
  80091c:	ff 75 10             	pushl  0x10(%ebp)
  80091f:	ff 75 0c             	pushl  0xc(%ebp)
  800922:	ff 75 08             	pushl  0x8(%ebp)
  800925:	e8 9a ff ff ff       	call   8008c4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
  800937:	eb 03                	jmp    80093c <strlen+0x10>
		n++;
  800939:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80093c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800940:	75 f7                	jne    800939 <strlen+0xd>
		n++;
	return n;
}
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094d:	ba 00 00 00 00       	mov    $0x0,%edx
  800952:	eb 03                	jmp    800957 <strnlen+0x13>
		n++;
  800954:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800957:	39 c2                	cmp    %eax,%edx
  800959:	74 08                	je     800963 <strnlen+0x1f>
  80095b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80095f:	75 f3                	jne    800954 <strnlen+0x10>
  800961:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	53                   	push   %ebx
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80096f:	89 c2                	mov    %eax,%edx
  800971:	83 c2 01             	add    $0x1,%edx
  800974:	83 c1 01             	add    $0x1,%ecx
  800977:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80097b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80097e:	84 db                	test   %bl,%bl
  800980:	75 ef                	jne    800971 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800982:	5b                   	pop    %ebx
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	53                   	push   %ebx
  800989:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80098c:	53                   	push   %ebx
  80098d:	e8 9a ff ff ff       	call   80092c <strlen>
  800992:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800995:	ff 75 0c             	pushl  0xc(%ebp)
  800998:	01 d8                	add    %ebx,%eax
  80099a:	50                   	push   %eax
  80099b:	e8 c5 ff ff ff       	call   800965 <strcpy>
	return dst;
}
  8009a0:	89 d8                	mov    %ebx,%eax
  8009a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8009af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b2:	89 f3                	mov    %esi,%ebx
  8009b4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b7:	89 f2                	mov    %esi,%edx
  8009b9:	eb 0f                	jmp    8009ca <strncpy+0x23>
		*dst++ = *src;
  8009bb:	83 c2 01             	add    $0x1,%edx
  8009be:	0f b6 01             	movzbl (%ecx),%eax
  8009c1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c4:	80 39 01             	cmpb   $0x1,(%ecx)
  8009c7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ca:	39 da                	cmp    %ebx,%edx
  8009cc:	75 ed                	jne    8009bb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009ce:	89 f0                	mov    %esi,%eax
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009df:	8b 55 10             	mov    0x10(%ebp),%edx
  8009e2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e4:	85 d2                	test   %edx,%edx
  8009e6:	74 21                	je     800a09 <strlcpy+0x35>
  8009e8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009ec:	89 f2                	mov    %esi,%edx
  8009ee:	eb 09                	jmp    8009f9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009f0:	83 c2 01             	add    $0x1,%edx
  8009f3:	83 c1 01             	add    $0x1,%ecx
  8009f6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f9:	39 c2                	cmp    %eax,%edx
  8009fb:	74 09                	je     800a06 <strlcpy+0x32>
  8009fd:	0f b6 19             	movzbl (%ecx),%ebx
  800a00:	84 db                	test   %bl,%bl
  800a02:	75 ec                	jne    8009f0 <strlcpy+0x1c>
  800a04:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a06:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a09:	29 f0                	sub    %esi,%eax
}
  800a0b:	5b                   	pop    %ebx
  800a0c:	5e                   	pop    %esi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a15:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a18:	eb 06                	jmp    800a20 <strcmp+0x11>
		p++, q++;
  800a1a:	83 c1 01             	add    $0x1,%ecx
  800a1d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a20:	0f b6 01             	movzbl (%ecx),%eax
  800a23:	84 c0                	test   %al,%al
  800a25:	74 04                	je     800a2b <strcmp+0x1c>
  800a27:	3a 02                	cmp    (%edx),%al
  800a29:	74 ef                	je     800a1a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2b:	0f b6 c0             	movzbl %al,%eax
  800a2e:	0f b6 12             	movzbl (%edx),%edx
  800a31:	29 d0                	sub    %edx,%eax
}
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	53                   	push   %ebx
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3f:	89 c3                	mov    %eax,%ebx
  800a41:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a44:	eb 06                	jmp    800a4c <strncmp+0x17>
		n--, p++, q++;
  800a46:	83 c0 01             	add    $0x1,%eax
  800a49:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a4c:	39 d8                	cmp    %ebx,%eax
  800a4e:	74 15                	je     800a65 <strncmp+0x30>
  800a50:	0f b6 08             	movzbl (%eax),%ecx
  800a53:	84 c9                	test   %cl,%cl
  800a55:	74 04                	je     800a5b <strncmp+0x26>
  800a57:	3a 0a                	cmp    (%edx),%cl
  800a59:	74 eb                	je     800a46 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5b:	0f b6 00             	movzbl (%eax),%eax
  800a5e:	0f b6 12             	movzbl (%edx),%edx
  800a61:	29 d0                	sub    %edx,%eax
  800a63:	eb 05                	jmp    800a6a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a65:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a6a:	5b                   	pop    %ebx
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a77:	eb 07                	jmp    800a80 <strchr+0x13>
		if (*s == c)
  800a79:	38 ca                	cmp    %cl,%dl
  800a7b:	74 0f                	je     800a8c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a7d:	83 c0 01             	add    $0x1,%eax
  800a80:	0f b6 10             	movzbl (%eax),%edx
  800a83:	84 d2                	test   %dl,%dl
  800a85:	75 f2                	jne    800a79 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a98:	eb 03                	jmp    800a9d <strfind+0xf>
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	74 04                	je     800aa8 <strfind+0x1a>
  800aa4:	38 ca                	cmp    %cl,%dl
  800aa6:	75 f2                	jne    800a9a <strfind+0xc>
			break;
	return (char *) s;
}
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab6:	85 c9                	test   %ecx,%ecx
  800ab8:	74 36                	je     800af0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aba:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac0:	75 28                	jne    800aea <memset+0x40>
  800ac2:	f6 c1 03             	test   $0x3,%cl
  800ac5:	75 23                	jne    800aea <memset+0x40>
		c &= 0xFF;
  800ac7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800acb:	89 d3                	mov    %edx,%ebx
  800acd:	c1 e3 08             	shl    $0x8,%ebx
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	c1 e6 18             	shl    $0x18,%esi
  800ad5:	89 d0                	mov    %edx,%eax
  800ad7:	c1 e0 10             	shl    $0x10,%eax
  800ada:	09 f0                	or     %esi,%eax
  800adc:	09 c2                	or     %eax,%edx
  800ade:	89 d0                	mov    %edx,%eax
  800ae0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ae2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ae5:	fc                   	cld    
  800ae6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae8:	eb 06                	jmp    800af0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	fc                   	cld    
  800aee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af0:	89 f8                	mov    %edi,%eax
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b05:	39 c6                	cmp    %eax,%esi
  800b07:	73 35                	jae    800b3e <memmove+0x47>
  800b09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b0c:	39 d0                	cmp    %edx,%eax
  800b0e:	73 2e                	jae    800b3e <memmove+0x47>
		s += n;
		d += n;
  800b10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b13:	89 d6                	mov    %edx,%esi
  800b15:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b17:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b1d:	75 13                	jne    800b32 <memmove+0x3b>
  800b1f:	f6 c1 03             	test   $0x3,%cl
  800b22:	75 0e                	jne    800b32 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b24:	83 ef 04             	sub    $0x4,%edi
  800b27:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b2a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b2d:	fd                   	std    
  800b2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b30:	eb 09                	jmp    800b3b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b32:	83 ef 01             	sub    $0x1,%edi
  800b35:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b38:	fd                   	std    
  800b39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b3b:	fc                   	cld    
  800b3c:	eb 1d                	jmp    800b5b <memmove+0x64>
  800b3e:	89 f2                	mov    %esi,%edx
  800b40:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b42:	f6 c2 03             	test   $0x3,%dl
  800b45:	75 0f                	jne    800b56 <memmove+0x5f>
  800b47:	f6 c1 03             	test   $0x3,%cl
  800b4a:	75 0a                	jne    800b56 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b4c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b4f:	89 c7                	mov    %eax,%edi
  800b51:	fc                   	cld    
  800b52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b54:	eb 05                	jmp    800b5b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b56:	89 c7                	mov    %eax,%edi
  800b58:	fc                   	cld    
  800b59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b62:	ff 75 10             	pushl  0x10(%ebp)
  800b65:	ff 75 0c             	pushl  0xc(%ebp)
  800b68:	ff 75 08             	pushl  0x8(%ebp)
  800b6b:	e8 87 ff ff ff       	call   800af7 <memmove>
}
  800b70:	c9                   	leave  
  800b71:	c3                   	ret    

00800b72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7d:	89 c6                	mov    %eax,%esi
  800b7f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b82:	eb 1a                	jmp    800b9e <memcmp+0x2c>
		if (*s1 != *s2)
  800b84:	0f b6 08             	movzbl (%eax),%ecx
  800b87:	0f b6 1a             	movzbl (%edx),%ebx
  800b8a:	38 d9                	cmp    %bl,%cl
  800b8c:	74 0a                	je     800b98 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b8e:	0f b6 c1             	movzbl %cl,%eax
  800b91:	0f b6 db             	movzbl %bl,%ebx
  800b94:	29 d8                	sub    %ebx,%eax
  800b96:	eb 0f                	jmp    800ba7 <memcmp+0x35>
		s1++, s2++;
  800b98:	83 c0 01             	add    $0x1,%eax
  800b9b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9e:	39 f0                	cmp    %esi,%eax
  800ba0:	75 e2                	jne    800b84 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bb4:	89 c2                	mov    %eax,%edx
  800bb6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb9:	eb 07                	jmp    800bc2 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bbb:	38 08                	cmp    %cl,(%eax)
  800bbd:	74 07                	je     800bc6 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bbf:	83 c0 01             	add    $0x1,%eax
  800bc2:	39 d0                	cmp    %edx,%eax
  800bc4:	72 f5                	jb     800bbb <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd4:	eb 03                	jmp    800bd9 <strtol+0x11>
		s++;
  800bd6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd9:	0f b6 01             	movzbl (%ecx),%eax
  800bdc:	3c 09                	cmp    $0x9,%al
  800bde:	74 f6                	je     800bd6 <strtol+0xe>
  800be0:	3c 20                	cmp    $0x20,%al
  800be2:	74 f2                	je     800bd6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800be4:	3c 2b                	cmp    $0x2b,%al
  800be6:	75 0a                	jne    800bf2 <strtol+0x2a>
		s++;
  800be8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800beb:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf0:	eb 10                	jmp    800c02 <strtol+0x3a>
  800bf2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bf7:	3c 2d                	cmp    $0x2d,%al
  800bf9:	75 07                	jne    800c02 <strtol+0x3a>
		s++, neg = 1;
  800bfb:	8d 49 01             	lea    0x1(%ecx),%ecx
  800bfe:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c02:	85 db                	test   %ebx,%ebx
  800c04:	0f 94 c0             	sete   %al
  800c07:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c0d:	75 19                	jne    800c28 <strtol+0x60>
  800c0f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c12:	75 14                	jne    800c28 <strtol+0x60>
  800c14:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c18:	0f 85 82 00 00 00    	jne    800ca0 <strtol+0xd8>
		s += 2, base = 16;
  800c1e:	83 c1 02             	add    $0x2,%ecx
  800c21:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c26:	eb 16                	jmp    800c3e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c28:	84 c0                	test   %al,%al
  800c2a:	74 12                	je     800c3e <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c2c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c31:	80 39 30             	cmpb   $0x30,(%ecx)
  800c34:	75 08                	jne    800c3e <strtol+0x76>
		s++, base = 8;
  800c36:	83 c1 01             	add    $0x1,%ecx
  800c39:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c43:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c46:	0f b6 11             	movzbl (%ecx),%edx
  800c49:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c4c:	89 f3                	mov    %esi,%ebx
  800c4e:	80 fb 09             	cmp    $0x9,%bl
  800c51:	77 08                	ja     800c5b <strtol+0x93>
			dig = *s - '0';
  800c53:	0f be d2             	movsbl %dl,%edx
  800c56:	83 ea 30             	sub    $0x30,%edx
  800c59:	eb 22                	jmp    800c7d <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c5b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c5e:	89 f3                	mov    %esi,%ebx
  800c60:	80 fb 19             	cmp    $0x19,%bl
  800c63:	77 08                	ja     800c6d <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c65:	0f be d2             	movsbl %dl,%edx
  800c68:	83 ea 57             	sub    $0x57,%edx
  800c6b:	eb 10                	jmp    800c7d <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c6d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c70:	89 f3                	mov    %esi,%ebx
  800c72:	80 fb 19             	cmp    $0x19,%bl
  800c75:	77 16                	ja     800c8d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c77:	0f be d2             	movsbl %dl,%edx
  800c7a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c7d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c80:	7d 0f                	jge    800c91 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c82:	83 c1 01             	add    $0x1,%ecx
  800c85:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c89:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c8b:	eb b9                	jmp    800c46 <strtol+0x7e>
  800c8d:	89 c2                	mov    %eax,%edx
  800c8f:	eb 02                	jmp    800c93 <strtol+0xcb>
  800c91:	89 c2                	mov    %eax,%edx

	if (endptr)
  800c93:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c97:	74 0d                	je     800ca6 <strtol+0xde>
		*endptr = (char *) s;
  800c99:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9c:	89 0e                	mov    %ecx,(%esi)
  800c9e:	eb 06                	jmp    800ca6 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca0:	84 c0                	test   %al,%al
  800ca2:	75 92                	jne    800c36 <strtol+0x6e>
  800ca4:	eb 98                	jmp    800c3e <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ca6:	f7 da                	neg    %edx
  800ca8:	85 ff                	test   %edi,%edi
  800caa:	0f 45 c2             	cmovne %edx,%eax
}
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    
  800cb2:	66 90                	xchg   %ax,%ax
  800cb4:	66 90                	xchg   %ax,%ax
  800cb6:	66 90                	xchg   %ax,%ax
  800cb8:	66 90                	xchg   %ax,%ax
  800cba:	66 90                	xchg   %ax,%ax
  800cbc:	66 90                	xchg   %ax,%ax
  800cbe:	66 90                	xchg   %ax,%ax

00800cc0 <__udivdi3>:
  800cc0:	55                   	push   %ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	83 ec 10             	sub    $0x10,%esp
  800cc6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800cca:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800cce:	8b 74 24 24          	mov    0x24(%esp),%esi
  800cd2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800cd6:	85 d2                	test   %edx,%edx
  800cd8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cdc:	89 34 24             	mov    %esi,(%esp)
  800cdf:	89 c8                	mov    %ecx,%eax
  800ce1:	75 35                	jne    800d18 <__udivdi3+0x58>
  800ce3:	39 f1                	cmp    %esi,%ecx
  800ce5:	0f 87 bd 00 00 00    	ja     800da8 <__udivdi3+0xe8>
  800ceb:	85 c9                	test   %ecx,%ecx
  800ced:	89 cd                	mov    %ecx,%ebp
  800cef:	75 0b                	jne    800cfc <__udivdi3+0x3c>
  800cf1:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf6:	31 d2                	xor    %edx,%edx
  800cf8:	f7 f1                	div    %ecx
  800cfa:	89 c5                	mov    %eax,%ebp
  800cfc:	89 f0                	mov    %esi,%eax
  800cfe:	31 d2                	xor    %edx,%edx
  800d00:	f7 f5                	div    %ebp
  800d02:	89 c6                	mov    %eax,%esi
  800d04:	89 f8                	mov    %edi,%eax
  800d06:	f7 f5                	div    %ebp
  800d08:	89 f2                	mov    %esi,%edx
  800d0a:	83 c4 10             	add    $0x10,%esp
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    
  800d11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d18:	3b 14 24             	cmp    (%esp),%edx
  800d1b:	77 7b                	ja     800d98 <__udivdi3+0xd8>
  800d1d:	0f bd f2             	bsr    %edx,%esi
  800d20:	83 f6 1f             	xor    $0x1f,%esi
  800d23:	0f 84 97 00 00 00    	je     800dc0 <__udivdi3+0x100>
  800d29:	bd 20 00 00 00       	mov    $0x20,%ebp
  800d2e:	89 d7                	mov    %edx,%edi
  800d30:	89 f1                	mov    %esi,%ecx
  800d32:	29 f5                	sub    %esi,%ebp
  800d34:	d3 e7                	shl    %cl,%edi
  800d36:	89 c2                	mov    %eax,%edx
  800d38:	89 e9                	mov    %ebp,%ecx
  800d3a:	d3 ea                	shr    %cl,%edx
  800d3c:	89 f1                	mov    %esi,%ecx
  800d3e:	09 fa                	or     %edi,%edx
  800d40:	8b 3c 24             	mov    (%esp),%edi
  800d43:	d3 e0                	shl    %cl,%eax
  800d45:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d49:	89 e9                	mov    %ebp,%ecx
  800d4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d4f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d53:	89 fa                	mov    %edi,%edx
  800d55:	d3 ea                	shr    %cl,%edx
  800d57:	89 f1                	mov    %esi,%ecx
  800d59:	d3 e7                	shl    %cl,%edi
  800d5b:	89 e9                	mov    %ebp,%ecx
  800d5d:	d3 e8                	shr    %cl,%eax
  800d5f:	09 c7                	or     %eax,%edi
  800d61:	89 f8                	mov    %edi,%eax
  800d63:	f7 74 24 08          	divl   0x8(%esp)
  800d67:	89 d5                	mov    %edx,%ebp
  800d69:	89 c7                	mov    %eax,%edi
  800d6b:	f7 64 24 0c          	mull   0xc(%esp)
  800d6f:	39 d5                	cmp    %edx,%ebp
  800d71:	89 14 24             	mov    %edx,(%esp)
  800d74:	72 11                	jb     800d87 <__udivdi3+0xc7>
  800d76:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d7a:	89 f1                	mov    %esi,%ecx
  800d7c:	d3 e2                	shl    %cl,%edx
  800d7e:	39 c2                	cmp    %eax,%edx
  800d80:	73 5e                	jae    800de0 <__udivdi3+0x120>
  800d82:	3b 2c 24             	cmp    (%esp),%ebp
  800d85:	75 59                	jne    800de0 <__udivdi3+0x120>
  800d87:	8d 47 ff             	lea    -0x1(%edi),%eax
  800d8a:	31 f6                	xor    %esi,%esi
  800d8c:	89 f2                	mov    %esi,%edx
  800d8e:	83 c4 10             	add    $0x10,%esp
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
  800d98:	31 f6                	xor    %esi,%esi
  800d9a:	31 c0                	xor    %eax,%eax
  800d9c:	89 f2                	mov    %esi,%edx
  800d9e:	83 c4 10             	add    $0x10,%esp
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    
  800da5:	8d 76 00             	lea    0x0(%esi),%esi
  800da8:	89 f2                	mov    %esi,%edx
  800daa:	31 f6                	xor    %esi,%esi
  800dac:	89 f8                	mov    %edi,%eax
  800dae:	f7 f1                	div    %ecx
  800db0:	89 f2                	mov    %esi,%edx
  800db2:	83 c4 10             	add    $0x10,%esp
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    
  800db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dc4:	76 0b                	jbe    800dd1 <__udivdi3+0x111>
  800dc6:	31 c0                	xor    %eax,%eax
  800dc8:	3b 14 24             	cmp    (%esp),%edx
  800dcb:	0f 83 37 ff ff ff    	jae    800d08 <__udivdi3+0x48>
  800dd1:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd6:	e9 2d ff ff ff       	jmp    800d08 <__udivdi3+0x48>
  800ddb:	90                   	nop
  800ddc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800de0:	89 f8                	mov    %edi,%eax
  800de2:	31 f6                	xor    %esi,%esi
  800de4:	e9 1f ff ff ff       	jmp    800d08 <__udivdi3+0x48>
  800de9:	66 90                	xchg   %ax,%ax
  800deb:	66 90                	xchg   %ax,%ax
  800ded:	66 90                	xchg   %ax,%ax
  800def:	90                   	nop

00800df0 <__umoddi3>:
  800df0:	55                   	push   %ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	83 ec 20             	sub    $0x20,%esp
  800df6:	8b 44 24 34          	mov    0x34(%esp),%eax
  800dfa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800dfe:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e02:	89 c6                	mov    %eax,%esi
  800e04:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e08:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800e0c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800e10:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e14:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800e18:	89 74 24 18          	mov    %esi,0x18(%esp)
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	89 c2                	mov    %eax,%edx
  800e20:	75 1e                	jne    800e40 <__umoddi3+0x50>
  800e22:	39 f7                	cmp    %esi,%edi
  800e24:	76 52                	jbe    800e78 <__umoddi3+0x88>
  800e26:	89 c8                	mov    %ecx,%eax
  800e28:	89 f2                	mov    %esi,%edx
  800e2a:	f7 f7                	div    %edi
  800e2c:	89 d0                	mov    %edx,%eax
  800e2e:	31 d2                	xor    %edx,%edx
  800e30:	83 c4 20             	add    $0x20,%esp
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    
  800e37:	89 f6                	mov    %esi,%esi
  800e39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e40:	39 f0                	cmp    %esi,%eax
  800e42:	77 5c                	ja     800ea0 <__umoddi3+0xb0>
  800e44:	0f bd e8             	bsr    %eax,%ebp
  800e47:	83 f5 1f             	xor    $0x1f,%ebp
  800e4a:	75 64                	jne    800eb0 <__umoddi3+0xc0>
  800e4c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800e50:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800e54:	0f 86 f6 00 00 00    	jbe    800f50 <__umoddi3+0x160>
  800e5a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800e5e:	0f 82 ec 00 00 00    	jb     800f50 <__umoddi3+0x160>
  800e64:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e68:	8b 54 24 18          	mov    0x18(%esp),%edx
  800e6c:	83 c4 20             	add    $0x20,%esp
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    
  800e73:	90                   	nop
  800e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e78:	85 ff                	test   %edi,%edi
  800e7a:	89 fd                	mov    %edi,%ebp
  800e7c:	75 0b                	jne    800e89 <__umoddi3+0x99>
  800e7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e83:	31 d2                	xor    %edx,%edx
  800e85:	f7 f7                	div    %edi
  800e87:	89 c5                	mov    %eax,%ebp
  800e89:	8b 44 24 10          	mov    0x10(%esp),%eax
  800e8d:	31 d2                	xor    %edx,%edx
  800e8f:	f7 f5                	div    %ebp
  800e91:	89 c8                	mov    %ecx,%eax
  800e93:	f7 f5                	div    %ebp
  800e95:	eb 95                	jmp    800e2c <__umoddi3+0x3c>
  800e97:	89 f6                	mov    %esi,%esi
  800e99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ea0:	89 c8                	mov    %ecx,%eax
  800ea2:	89 f2                	mov    %esi,%edx
  800ea4:	83 c4 20             	add    $0x20,%esp
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    
  800eab:	90                   	nop
  800eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	b8 20 00 00 00       	mov    $0x20,%eax
  800eb5:	89 e9                	mov    %ebp,%ecx
  800eb7:	29 e8                	sub    %ebp,%eax
  800eb9:	d3 e2                	shl    %cl,%edx
  800ebb:	89 c7                	mov    %eax,%edi
  800ebd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800ec1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ec5:	89 f9                	mov    %edi,%ecx
  800ec7:	d3 e8                	shr    %cl,%eax
  800ec9:	89 c1                	mov    %eax,%ecx
  800ecb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ecf:	09 d1                	or     %edx,%ecx
  800ed1:	89 fa                	mov    %edi,%edx
  800ed3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ed7:	89 e9                	mov    %ebp,%ecx
  800ed9:	d3 e0                	shl    %cl,%eax
  800edb:	89 f9                	mov    %edi,%ecx
  800edd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ee1:	89 f0                	mov    %esi,%eax
  800ee3:	d3 e8                	shr    %cl,%eax
  800ee5:	89 e9                	mov    %ebp,%ecx
  800ee7:	89 c7                	mov    %eax,%edi
  800ee9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800eed:	d3 e6                	shl    %cl,%esi
  800eef:	89 d1                	mov    %edx,%ecx
  800ef1:	89 fa                	mov    %edi,%edx
  800ef3:	d3 e8                	shr    %cl,%eax
  800ef5:	89 e9                	mov    %ebp,%ecx
  800ef7:	09 f0                	or     %esi,%eax
  800ef9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800efd:	f7 74 24 10          	divl   0x10(%esp)
  800f01:	d3 e6                	shl    %cl,%esi
  800f03:	89 d1                	mov    %edx,%ecx
  800f05:	f7 64 24 0c          	mull   0xc(%esp)
  800f09:	39 d1                	cmp    %edx,%ecx
  800f0b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800f0f:	89 d7                	mov    %edx,%edi
  800f11:	89 c6                	mov    %eax,%esi
  800f13:	72 0a                	jb     800f1f <__umoddi3+0x12f>
  800f15:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800f19:	73 10                	jae    800f2b <__umoddi3+0x13b>
  800f1b:	39 d1                	cmp    %edx,%ecx
  800f1d:	75 0c                	jne    800f2b <__umoddi3+0x13b>
  800f1f:	89 d7                	mov    %edx,%edi
  800f21:	89 c6                	mov    %eax,%esi
  800f23:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800f27:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800f2b:	89 ca                	mov    %ecx,%edx
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f33:	29 f0                	sub    %esi,%eax
  800f35:	19 fa                	sbb    %edi,%edx
  800f37:	d3 e8                	shr    %cl,%eax
  800f39:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800f3e:	89 d7                	mov    %edx,%edi
  800f40:	d3 e7                	shl    %cl,%edi
  800f42:	89 e9                	mov    %ebp,%ecx
  800f44:	09 f8                	or     %edi,%eax
  800f46:	d3 ea                	shr    %cl,%edx
  800f48:	83 c4 20             	add    $0x20,%esp
  800f4b:	5e                   	pop    %esi
  800f4c:	5f                   	pop    %edi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    
  800f4f:	90                   	nop
  800f50:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f54:	29 f9                	sub    %edi,%ecx
  800f56:	19 c6                	sbb    %eax,%esi
  800f58:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800f5c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f60:	e9 ff fe ff ff       	jmp    800e64 <__umoddi3+0x74>
