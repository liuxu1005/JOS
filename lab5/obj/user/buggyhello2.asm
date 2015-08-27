
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
  800049:	83 c4 10             	add    $0x10,%esp
}
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
  80008a:	83 c4 10             	add    $0x10,%esp
}
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 89 04 00 00       	call   800528 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
  8000a9:	83 c4 10             	add    $0x10,%esp
}
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 18 1e 80 00       	push   $0x801e18
  800118:	6a 23                	push   $0x23
  80011a:	68 35 1e 80 00       	push   $0x801e35
  80011f:	e8 44 0f 00 00       	call   801068 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 18 1e 80 00       	push   $0x801e18
  800199:	6a 23                	push   $0x23
  80019b:	68 35 1e 80 00       	push   $0x801e35
  8001a0:	e8 c3 0e 00 00       	call   801068 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 18 1e 80 00       	push   $0x801e18
  8001db:	6a 23                	push   $0x23
  8001dd:	68 35 1e 80 00       	push   $0x801e35
  8001e2:	e8 81 0e 00 00       	call   801068 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 18 1e 80 00       	push   $0x801e18
  80021d:	6a 23                	push   $0x23
  80021f:	68 35 1e 80 00       	push   $0x801e35
  800224:	e8 3f 0e 00 00       	call   801068 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 18 1e 80 00       	push   $0x801e18
  80025f:	6a 23                	push   $0x23
  800261:	68 35 1e 80 00       	push   $0x801e35
  800266:	e8 fd 0d 00 00       	call   801068 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 18 1e 80 00       	push   $0x801e18
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 35 1e 80 00       	push   $0x801e35
  8002a8:	e8 bb 0d 00 00       	call   801068 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 18 1e 80 00       	push   $0x801e18
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 35 1e 80 00       	push   $0x801e35
  8002ea:	e8 79 0d 00 00       	call   801068 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 18 1e 80 00       	push   $0x801e18
  800347:	6a 23                	push   $0x23
  800349:	68 35 1e 80 00       	push   $0x801e35
  80034e:	e8 15 0d 00 00       	call   801068 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 16             	shr    $0x16,%edx
  800392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 11                	je     8003af <fd_alloc+0x2d>
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	75 09                	jne    8003b8 <fd_alloc+0x36>
			*fd_store = fd;
  8003af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b6:	eb 17                	jmp    8003cf <fd_alloc+0x4d>
  8003b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003c2:	75 c9                	jne    80038d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d7:	83 f8 1f             	cmp    $0x1f,%eax
  8003da:	77 36                	ja     800412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dc:	c1 e0 0c             	shl    $0xc,%eax
  8003df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 24                	je     800419 <fd_lookup+0x48>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 1a                	je     800420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 02                	mov    %eax,(%edx)
	return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	eb 13                	jmp    800425 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 0c                	jmp    800425 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb 05                	jmp    800425 <fd_lookup+0x54>
  800420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800430:	ba c0 1e 80 00       	mov    $0x801ec0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	eb 13                	jmp    80044a <dev_lookup+0x23>
  800437:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80043a:	39 08                	cmp    %ecx,(%eax)
  80043c:	75 0c                	jne    80044a <dev_lookup+0x23>
			*dev = devtab[i];
  80043e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800441:	89 01                	mov    %eax,(%ecx)
			return 0;
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	eb 2e                	jmp    800478 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	85 c0                	test   %eax,%eax
  80044e:	75 e7                	jne    800437 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800450:	a1 04 40 80 00       	mov    0x804004,%eax
  800455:	8b 40 48             	mov    0x48(%eax),%eax
  800458:	83 ec 04             	sub    $0x4,%esp
  80045b:	51                   	push   %ecx
  80045c:	50                   	push   %eax
  80045d:	68 44 1e 80 00       	push   $0x801e44
  800462:	e8 da 0c 00 00       	call   801141 <cprintf>
	*dev = 0;
  800467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 10             	sub    $0x10,%esp
  800482:	8b 75 08             	mov    0x8(%ebp),%esi
  800485:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80048b:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80048c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800495:	50                   	push   %eax
  800496:	e8 36 ff ff ff       	call   8003d1 <fd_lookup>
  80049b:	83 c4 08             	add    $0x8,%esp
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	78 05                	js     8004a7 <fd_close+0x2d>
	    || fd != fd2)
  8004a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a5:	74 0c                	je     8004b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a7:	84 db                	test   %bl,%bl
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	0f 44 c2             	cmove  %edx,%eax
  8004b1:	eb 41                	jmp    8004f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b9:	50                   	push   %eax
  8004ba:	ff 36                	pushl  (%esi)
  8004bc:	e8 66 ff ff ff       	call   800427 <dev_lookup>
  8004c1:	89 c3                	mov    %eax,%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	78 1a                	js     8004e4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 0b                	je     8004e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d9:	83 ec 0c             	sub    $0xc,%esp
  8004dc:	56                   	push   %esi
  8004dd:	ff d0                	call   *%eax
  8004df:	89 c3                	mov    %eax,%ebx
  8004e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	56                   	push   %esi
  8004e8:	6a 00                	push   $0x0
  8004ea:	e8 00 fd ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	89 d8                	mov    %ebx,%eax
}
  8004f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5e                   	pop    %esi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 c4 fe ff ff       	call   8003d1 <fd_lookup>
  80050d:	89 c2                	mov    %eax,%edx
  80050f:	83 c4 08             	add    $0x8,%esp
  800512:	85 d2                	test   %edx,%edx
  800514:	78 10                	js     800526 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	6a 01                	push   $0x1
  80051b:	ff 75 f4             	pushl  -0xc(%ebp)
  80051e:	e8 57 ff ff ff       	call   80047a <fd_close>
  800523:	83 c4 10             	add    $0x10,%esp
}
  800526:	c9                   	leave  
  800527:	c3                   	ret    

00800528 <close_all>:

void
close_all(void)
{
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	53                   	push   %ebx
  80052c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800534:	83 ec 0c             	sub    $0xc,%esp
  800537:	53                   	push   %ebx
  800538:	e8 be ff ff ff       	call   8004fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80053d:	83 c3 01             	add    $0x1,%ebx
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	83 fb 20             	cmp    $0x20,%ebx
  800546:	75 ec                	jne    800534 <close_all+0xc>
		close(i);
}
  800548:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80054b:	c9                   	leave  
  80054c:	c3                   	ret    

0080054d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054d:	55                   	push   %ebp
  80054e:	89 e5                	mov    %esp,%ebp
  800550:	57                   	push   %edi
  800551:	56                   	push   %esi
  800552:	53                   	push   %ebx
  800553:	83 ec 2c             	sub    $0x2c,%esp
  800556:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800559:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055c:	50                   	push   %eax
  80055d:	ff 75 08             	pushl  0x8(%ebp)
  800560:	e8 6c fe ff ff       	call   8003d1 <fd_lookup>
  800565:	89 c2                	mov    %eax,%edx
  800567:	83 c4 08             	add    $0x8,%esp
  80056a:	85 d2                	test   %edx,%edx
  80056c:	0f 88 c1 00 00 00    	js     800633 <dup+0xe6>
		return r;
	close(newfdnum);
  800572:	83 ec 0c             	sub    $0xc,%esp
  800575:	56                   	push   %esi
  800576:	e8 80 ff ff ff       	call   8004fb <close>

	newfd = INDEX2FD(newfdnum);
  80057b:	89 f3                	mov    %esi,%ebx
  80057d:	c1 e3 0c             	shl    $0xc,%ebx
  800580:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800586:	83 c4 04             	add    $0x4,%esp
  800589:	ff 75 e4             	pushl  -0x1c(%ebp)
  80058c:	e8 da fd ff ff       	call   80036b <fd2data>
  800591:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800593:	89 1c 24             	mov    %ebx,(%esp)
  800596:	e8 d0 fd ff ff       	call   80036b <fd2data>
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a1:	89 f8                	mov    %edi,%eax
  8005a3:	c1 e8 16             	shr    $0x16,%eax
  8005a6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ad:	a8 01                	test   $0x1,%al
  8005af:	74 37                	je     8005e8 <dup+0x9b>
  8005b1:	89 f8                	mov    %edi,%eax
  8005b3:	c1 e8 0c             	shr    $0xc,%eax
  8005b6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005bd:	f6 c2 01             	test   $0x1,%dl
  8005c0:	74 26                	je     8005e8 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c9:	83 ec 0c             	sub    $0xc,%esp
  8005cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d1:	50                   	push   %eax
  8005d2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005d5:	6a 00                	push   $0x0
  8005d7:	57                   	push   %edi
  8005d8:	6a 00                	push   $0x0
  8005da:	e8 ce fb ff ff       	call   8001ad <sys_page_map>
  8005df:	89 c7                	mov    %eax,%edi
  8005e1:	83 c4 20             	add    $0x20,%esp
  8005e4:	85 c0                	test   %eax,%eax
  8005e6:	78 2e                	js     800616 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005eb:	89 d0                	mov    %edx,%eax
  8005ed:	c1 e8 0c             	shr    $0xc,%eax
  8005f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f7:	83 ec 0c             	sub    $0xc,%esp
  8005fa:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ff:	50                   	push   %eax
  800600:	53                   	push   %ebx
  800601:	6a 00                	push   $0x0
  800603:	52                   	push   %edx
  800604:	6a 00                	push   $0x0
  800606:	e8 a2 fb ff ff       	call   8001ad <sys_page_map>
  80060b:	89 c7                	mov    %eax,%edi
  80060d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800610:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800612:	85 ff                	test   %edi,%edi
  800614:	79 1d                	jns    800633 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	6a 00                	push   $0x0
  80061c:	e8 ce fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  800621:	83 c4 08             	add    $0x8,%esp
  800624:	ff 75 d4             	pushl  -0x2c(%ebp)
  800627:	6a 00                	push   $0x0
  800629:	e8 c1 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	89 f8                	mov    %edi,%eax
}
  800633:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800636:	5b                   	pop    %ebx
  800637:	5e                   	pop    %esi
  800638:	5f                   	pop    %edi
  800639:	5d                   	pop    %ebp
  80063a:	c3                   	ret    

0080063b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	53                   	push   %ebx
  80063f:	83 ec 14             	sub    $0x14,%esp
  800642:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800645:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800648:	50                   	push   %eax
  800649:	53                   	push   %ebx
  80064a:	e8 82 fd ff ff       	call   8003d1 <fd_lookup>
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	89 c2                	mov    %eax,%edx
  800654:	85 c0                	test   %eax,%eax
  800656:	78 6d                	js     8006c5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065e:	50                   	push   %eax
  80065f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800662:	ff 30                	pushl  (%eax)
  800664:	e8 be fd ff ff       	call   800427 <dev_lookup>
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	85 c0                	test   %eax,%eax
  80066e:	78 4c                	js     8006bc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800670:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800673:	8b 42 08             	mov    0x8(%edx),%eax
  800676:	83 e0 03             	and    $0x3,%eax
  800679:	83 f8 01             	cmp    $0x1,%eax
  80067c:	75 21                	jne    80069f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067e:	a1 04 40 80 00       	mov    0x804004,%eax
  800683:	8b 40 48             	mov    0x48(%eax),%eax
  800686:	83 ec 04             	sub    $0x4,%esp
  800689:	53                   	push   %ebx
  80068a:	50                   	push   %eax
  80068b:	68 85 1e 80 00       	push   $0x801e85
  800690:	e8 ac 0a 00 00       	call   801141 <cprintf>
		return -E_INVAL;
  800695:	83 c4 10             	add    $0x10,%esp
  800698:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80069d:	eb 26                	jmp    8006c5 <read+0x8a>
	}
	if (!dev->dev_read)
  80069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a2:	8b 40 08             	mov    0x8(%eax),%eax
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	74 17                	je     8006c0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a9:	83 ec 04             	sub    $0x4,%esp
  8006ac:	ff 75 10             	pushl  0x10(%ebp)
  8006af:	ff 75 0c             	pushl  0xc(%ebp)
  8006b2:	52                   	push   %edx
  8006b3:	ff d0                	call   *%eax
  8006b5:	89 c2                	mov    %eax,%edx
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb 09                	jmp    8006c5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006bc:	89 c2                	mov    %eax,%edx
  8006be:	eb 05                	jmp    8006c5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006c0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006c5:	89 d0                	mov    %edx,%eax
  8006c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ca:	c9                   	leave  
  8006cb:	c3                   	ret    

008006cc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	57                   	push   %edi
  8006d0:	56                   	push   %esi
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 0c             	sub    $0xc,%esp
  8006d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e0:	eb 21                	jmp    800703 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e2:	83 ec 04             	sub    $0x4,%esp
  8006e5:	89 f0                	mov    %esi,%eax
  8006e7:	29 d8                	sub    %ebx,%eax
  8006e9:	50                   	push   %eax
  8006ea:	89 d8                	mov    %ebx,%eax
  8006ec:	03 45 0c             	add    0xc(%ebp),%eax
  8006ef:	50                   	push   %eax
  8006f0:	57                   	push   %edi
  8006f1:	e8 45 ff ff ff       	call   80063b <read>
		if (m < 0)
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	78 0c                	js     800709 <readn+0x3d>
			return m;
		if (m == 0)
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	74 06                	je     800707 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800701:	01 c3                	add    %eax,%ebx
  800703:	39 f3                	cmp    %esi,%ebx
  800705:	72 db                	jb     8006e2 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800707:	89 d8                	mov    %ebx,%eax
}
  800709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	83 ec 14             	sub    $0x14,%esp
  800718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	53                   	push   %ebx
  800720:	e8 ac fc ff ff       	call   8003d1 <fd_lookup>
  800725:	83 c4 08             	add    $0x8,%esp
  800728:	89 c2                	mov    %eax,%edx
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 68                	js     800796 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800738:	ff 30                	pushl  (%eax)
  80073a:	e8 e8 fc ff ff       	call   800427 <dev_lookup>
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	85 c0                	test   %eax,%eax
  800744:	78 47                	js     80078d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074d:	75 21                	jne    800770 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074f:	a1 04 40 80 00       	mov    0x804004,%eax
  800754:	8b 40 48             	mov    0x48(%eax),%eax
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	53                   	push   %ebx
  80075b:	50                   	push   %eax
  80075c:	68 a1 1e 80 00       	push   $0x801ea1
  800761:	e8 db 09 00 00       	call   801141 <cprintf>
		return -E_INVAL;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076e:	eb 26                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800773:	8b 52 0c             	mov    0xc(%edx),%edx
  800776:	85 d2                	test   %edx,%edx
  800778:	74 17                	je     800791 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80077a:	83 ec 04             	sub    $0x4,%esp
  80077d:	ff 75 10             	pushl  0x10(%ebp)
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	50                   	push   %eax
  800784:	ff d2                	call   *%edx
  800786:	89 c2                	mov    %eax,%edx
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb 09                	jmp    800796 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	eb 05                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800791:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800796:	89 d0                	mov    %edx,%eax
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <seek>:

int
seek(int fdnum, off_t offset)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 22 fc ff ff       	call   8003d1 <fd_lookup>
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 0e                	js     8007c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	83 ec 14             	sub    $0x14,%esp
  8007cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	53                   	push   %ebx
  8007d5:	e8 f7 fb ff ff       	call   8003d1 <fd_lookup>
  8007da:	83 c4 08             	add    $0x8,%esp
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	78 65                	js     800848 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	ff 30                	pushl  (%eax)
  8007ef:	e8 33 fc ff ff       	call   800427 <dev_lookup>
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 44                	js     80083f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800802:	75 21                	jne    800825 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800804:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800809:	8b 40 48             	mov    0x48(%eax),%eax
  80080c:	83 ec 04             	sub    $0x4,%esp
  80080f:	53                   	push   %ebx
  800810:	50                   	push   %eax
  800811:	68 64 1e 80 00       	push   $0x801e64
  800816:	e8 26 09 00 00       	call   801141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800823:	eb 23                	jmp    800848 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800828:	8b 52 18             	mov    0x18(%edx),%edx
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 14                	je     800843 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	50                   	push   %eax
  800836:	ff d2                	call   *%edx
  800838:	89 c2                	mov    %eax,%edx
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 09                	jmp    800848 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 05                	jmp    800848 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800843:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800848:	89 d0                	mov    %edx,%eax
  80084a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	83 ec 14             	sub    $0x14,%esp
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085c:	50                   	push   %eax
  80085d:	ff 75 08             	pushl  0x8(%ebp)
  800860:	e8 6c fb ff ff       	call   8003d1 <fd_lookup>
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	89 c2                	mov    %eax,%edx
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 58                	js     8008c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 a8 fb ff ff       	call   800427 <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 37                	js     8008bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088d:	74 32                	je     8008c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800899:	00 00 00 
	stat->st_isdir = 0;
  80089c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a3:	00 00 00 
	stat->st_dev = dev;
  8008a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b3:	ff 50 14             	call   *0x14(%eax)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	eb 09                	jmp    8008c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	eb 05                	jmp    8008c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c6:	89 d0                	mov    %edx,%eax
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	6a 00                	push   $0x0
  8008d7:	ff 75 08             	pushl  0x8(%ebp)
  8008da:	e8 09 02 00 00       	call   800ae8 <open>
  8008df:	89 c3                	mov    %eax,%ebx
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	85 db                	test   %ebx,%ebx
  8008e6:	78 1b                	js     800903 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ee:	53                   	push   %ebx
  8008ef:	e8 5b ff ff ff       	call   80084f <fstat>
  8008f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f6:	89 1c 24             	mov    %ebx,(%esp)
  8008f9:	e8 fd fb ff ff       	call   8004fb <close>
	return r;
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	89 f0                	mov    %esi,%eax
}
  800903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	89 c6                	mov    %eax,%esi
  800911:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800913:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80091a:	75 12                	jne    80092e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091c:	83 ec 0c             	sub    $0xc,%esp
  80091f:	6a 01                	push   $0x1
  800921:	e8 ac 11 00 00       	call   801ad2 <ipc_find_env>
  800926:	a3 00 40 80 00       	mov    %eax,0x804000
  80092b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092e:	6a 07                	push   $0x7
  800930:	68 00 50 80 00       	push   $0x805000
  800935:	56                   	push   %esi
  800936:	ff 35 00 40 80 00    	pushl  0x804000
  80093c:	e8 3d 11 00 00       	call   801a7e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800941:	83 c4 0c             	add    $0xc,%esp
  800944:	6a 00                	push   $0x0
  800946:	53                   	push   %ebx
  800947:	6a 00                	push   $0x0
  800949:	e8 c7 10 00 00       	call   801a15 <ipc_recv>
}
  80094e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 40 0c             	mov    0xc(%eax),%eax
  800961:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 02 00 00 00       	mov    $0x2,%eax
  800978:	e8 8d ff ff ff       	call   80090a <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800990:	ba 00 00 00 00       	mov    $0x0,%edx
  800995:	b8 06 00 00 00       	mov    $0x6,%eax
  80099a:	e8 6b ff ff ff       	call   80090a <fsipc>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 04             	sub    $0x4,%esp
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c0:	e8 45 ff ff ff       	call   80090a <fsipc>
  8009c5:	89 c2                	mov    %eax,%edx
  8009c7:	85 d2                	test   %edx,%edx
  8009c9:	78 2c                	js     8009f7 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009cb:	83 ec 08             	sub    $0x8,%esp
  8009ce:	68 00 50 80 00       	push   $0x805000
  8009d3:	53                   	push   %ebx
  8009d4:	e8 ef 0c 00 00       	call   8016c8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d9:	a1 80 50 80 00       	mov    0x805080,%eax
  8009de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e4:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ef:	83 c4 10             	add    $0x10,%esp
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	83 ec 0c             	sub    $0xc,%esp
  800a05:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0e:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800a13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a16:	eb 3d                	jmp    800a55 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800a18:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800a1e:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800a23:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800a26:	83 ec 04             	sub    $0x4,%esp
  800a29:	57                   	push   %edi
  800a2a:	53                   	push   %ebx
  800a2b:	68 08 50 80 00       	push   $0x805008
  800a30:	e8 25 0e 00 00       	call   80185a <memmove>
                fsipcbuf.write.req_n = tmp; 
  800a35:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a40:	b8 04 00 00 00       	mov    $0x4,%eax
  800a45:	e8 c0 fe ff ff       	call   80090a <fsipc>
  800a4a:	83 c4 10             	add    $0x10,%esp
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	78 0d                	js     800a5e <devfile_write+0x62>
		        return r;
                n -= tmp;
  800a51:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800a53:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a55:	85 f6                	test   %esi,%esi
  800a57:	75 bf                	jne    800a18 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800a59:	89 d8                	mov    %ebx,%eax
  800a5b:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800a5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	8b 40 0c             	mov    0xc(%eax),%eax
  800a74:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a79:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a84:	b8 03 00 00 00       	mov    $0x3,%eax
  800a89:	e8 7c fe ff ff       	call   80090a <fsipc>
  800a8e:	89 c3                	mov    %eax,%ebx
  800a90:	85 c0                	test   %eax,%eax
  800a92:	78 4b                	js     800adf <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a94:	39 c6                	cmp    %eax,%esi
  800a96:	73 16                	jae    800aae <devfile_read+0x48>
  800a98:	68 d0 1e 80 00       	push   $0x801ed0
  800a9d:	68 d7 1e 80 00       	push   $0x801ed7
  800aa2:	6a 7c                	push   $0x7c
  800aa4:	68 ec 1e 80 00       	push   $0x801eec
  800aa9:	e8 ba 05 00 00       	call   801068 <_panic>
	assert(r <= PGSIZE);
  800aae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab3:	7e 16                	jle    800acb <devfile_read+0x65>
  800ab5:	68 f7 1e 80 00       	push   $0x801ef7
  800aba:	68 d7 1e 80 00       	push   $0x801ed7
  800abf:	6a 7d                	push   $0x7d
  800ac1:	68 ec 1e 80 00       	push   $0x801eec
  800ac6:	e8 9d 05 00 00       	call   801068 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800acb:	83 ec 04             	sub    $0x4,%esp
  800ace:	50                   	push   %eax
  800acf:	68 00 50 80 00       	push   $0x805000
  800ad4:	ff 75 0c             	pushl  0xc(%ebp)
  800ad7:	e8 7e 0d 00 00       	call   80185a <memmove>
	return r;
  800adc:	83 c4 10             	add    $0x10,%esp
}
  800adf:	89 d8                	mov    %ebx,%eax
  800ae1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	53                   	push   %ebx
  800aec:	83 ec 20             	sub    $0x20,%esp
  800aef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800af2:	53                   	push   %ebx
  800af3:	e8 97 0b 00 00       	call   80168f <strlen>
  800af8:	83 c4 10             	add    $0x10,%esp
  800afb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b00:	7f 67                	jg     800b69 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b02:	83 ec 0c             	sub    $0xc,%esp
  800b05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b08:	50                   	push   %eax
  800b09:	e8 74 f8 ff ff       	call   800382 <fd_alloc>
  800b0e:	83 c4 10             	add    $0x10,%esp
		return r;
  800b11:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b13:	85 c0                	test   %eax,%eax
  800b15:	78 57                	js     800b6e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b17:	83 ec 08             	sub    $0x8,%esp
  800b1a:	53                   	push   %ebx
  800b1b:	68 00 50 80 00       	push   $0x805000
  800b20:	e8 a3 0b 00 00       	call   8016c8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b28:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b30:	b8 01 00 00 00       	mov    $0x1,%eax
  800b35:	e8 d0 fd ff ff       	call   80090a <fsipc>
  800b3a:	89 c3                	mov    %eax,%ebx
  800b3c:	83 c4 10             	add    $0x10,%esp
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	79 14                	jns    800b57 <open+0x6f>
		fd_close(fd, 0);
  800b43:	83 ec 08             	sub    $0x8,%esp
  800b46:	6a 00                	push   $0x0
  800b48:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4b:	e8 2a f9 ff ff       	call   80047a <fd_close>
		return r;
  800b50:	83 c4 10             	add    $0x10,%esp
  800b53:	89 da                	mov    %ebx,%edx
  800b55:	eb 17                	jmp    800b6e <open+0x86>
	}

	return fd2num(fd);
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5d:	e8 f9 f7 ff ff       	call   80035b <fd2num>
  800b62:	89 c2                	mov    %eax,%edx
  800b64:	83 c4 10             	add    $0x10,%esp
  800b67:	eb 05                	jmp    800b6e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b69:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b6e:	89 d0                	mov    %edx,%eax
  800b70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b73:	c9                   	leave  
  800b74:	c3                   	ret    

00800b75 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	b8 08 00 00 00       	mov    $0x8,%eax
  800b85:	e8 80 fd ff ff       	call   80090a <fsipc>
}
  800b8a:	c9                   	leave  
  800b8b:	c3                   	ret    

00800b8c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b94:	83 ec 0c             	sub    $0xc,%esp
  800b97:	ff 75 08             	pushl  0x8(%ebp)
  800b9a:	e8 cc f7 ff ff       	call   80036b <fd2data>
  800b9f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ba1:	83 c4 08             	add    $0x8,%esp
  800ba4:	68 03 1f 80 00       	push   $0x801f03
  800ba9:	53                   	push   %ebx
  800baa:	e8 19 0b 00 00       	call   8016c8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800baf:	8b 56 04             	mov    0x4(%esi),%edx
  800bb2:	89 d0                	mov    %edx,%eax
  800bb4:	2b 06                	sub    (%esi),%eax
  800bb6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bbc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bc3:	00 00 00 
	stat->st_dev = &devpipe;
  800bc6:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800bcd:	30 80 00 
	return 0;
}
  800bd0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be6:	53                   	push   %ebx
  800be7:	6a 00                	push   $0x0
  800be9:	e8 01 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bee:	89 1c 24             	mov    %ebx,(%esp)
  800bf1:	e8 75 f7 ff ff       	call   80036b <fd2data>
  800bf6:	83 c4 08             	add    $0x8,%esp
  800bf9:	50                   	push   %eax
  800bfa:	6a 00                	push   $0x0
  800bfc:	e8 ee f5 ff ff       	call   8001ef <sys_page_unmap>
}
  800c01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 1c             	sub    $0x1c,%esp
  800c0f:	89 c6                	mov    %eax,%esi
  800c11:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c14:	a1 04 40 80 00       	mov    0x804004,%eax
  800c19:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	56                   	push   %esi
  800c20:	e8 e5 0e 00 00       	call   801b0a <pageref>
  800c25:	89 c7                	mov    %eax,%edi
  800c27:	83 c4 04             	add    $0x4,%esp
  800c2a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c2d:	e8 d8 0e 00 00       	call   801b0a <pageref>
  800c32:	83 c4 10             	add    $0x10,%esp
  800c35:	39 c7                	cmp    %eax,%edi
  800c37:	0f 94 c2             	sete   %dl
  800c3a:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800c3d:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800c43:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800c46:	39 fb                	cmp    %edi,%ebx
  800c48:	74 19                	je     800c63 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  800c4a:	84 d2                	test   %dl,%dl
  800c4c:	74 c6                	je     800c14 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c4e:	8b 51 58             	mov    0x58(%ecx),%edx
  800c51:	50                   	push   %eax
  800c52:	52                   	push   %edx
  800c53:	53                   	push   %ebx
  800c54:	68 0a 1f 80 00       	push   $0x801f0a
  800c59:	e8 e3 04 00 00       	call   801141 <cprintf>
  800c5e:	83 c4 10             	add    $0x10,%esp
  800c61:	eb b1                	jmp    800c14 <_pipeisclosed+0xe>
	}
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 28             	sub    $0x28,%esp
  800c74:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c77:	56                   	push   %esi
  800c78:	e8 ee f6 ff ff       	call   80036b <fd2data>
  800c7d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c7f:	83 c4 10             	add    $0x10,%esp
  800c82:	bf 00 00 00 00       	mov    $0x0,%edi
  800c87:	eb 4b                	jmp    800cd4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c89:	89 da                	mov    %ebx,%edx
  800c8b:	89 f0                	mov    %esi,%eax
  800c8d:	e8 74 ff ff ff       	call   800c06 <_pipeisclosed>
  800c92:	85 c0                	test   %eax,%eax
  800c94:	75 48                	jne    800cde <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c96:	e8 b0 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c9b:	8b 43 04             	mov    0x4(%ebx),%eax
  800c9e:	8b 0b                	mov    (%ebx),%ecx
  800ca0:	8d 51 20             	lea    0x20(%ecx),%edx
  800ca3:	39 d0                	cmp    %edx,%eax
  800ca5:	73 e2                	jae    800c89 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cae:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cb1:	89 c2                	mov    %eax,%edx
  800cb3:	c1 fa 1f             	sar    $0x1f,%edx
  800cb6:	89 d1                	mov    %edx,%ecx
  800cb8:	c1 e9 1b             	shr    $0x1b,%ecx
  800cbb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cbe:	83 e2 1f             	and    $0x1f,%edx
  800cc1:	29 ca                	sub    %ecx,%edx
  800cc3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cc7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ccb:	83 c0 01             	add    $0x1,%eax
  800cce:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd1:	83 c7 01             	add    $0x1,%edi
  800cd4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cd7:	75 c2                	jne    800c9b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cd9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cdc:	eb 05                	jmp    800ce3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cde:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
  800cf1:	83 ec 18             	sub    $0x18,%esp
  800cf4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cf7:	57                   	push   %edi
  800cf8:	e8 6e f6 ff ff       	call   80036b <fd2data>
  800cfd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cff:	83 c4 10             	add    $0x10,%esp
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	eb 3d                	jmp    800d46 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d09:	85 db                	test   %ebx,%ebx
  800d0b:	74 04                	je     800d11 <devpipe_read+0x26>
				return i;
  800d0d:	89 d8                	mov    %ebx,%eax
  800d0f:	eb 44                	jmp    800d55 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d11:	89 f2                	mov    %esi,%edx
  800d13:	89 f8                	mov    %edi,%eax
  800d15:	e8 ec fe ff ff       	call   800c06 <_pipeisclosed>
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	75 32                	jne    800d50 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d1e:	e8 28 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d23:	8b 06                	mov    (%esi),%eax
  800d25:	3b 46 04             	cmp    0x4(%esi),%eax
  800d28:	74 df                	je     800d09 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d2a:	99                   	cltd   
  800d2b:	c1 ea 1b             	shr    $0x1b,%edx
  800d2e:	01 d0                	add    %edx,%eax
  800d30:	83 e0 1f             	and    $0x1f,%eax
  800d33:	29 d0                	sub    %edx,%eax
  800d35:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d40:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d43:	83 c3 01             	add    $0x1,%ebx
  800d46:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d49:	75 d8                	jne    800d23 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4e:	eb 05                	jmp    800d55 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d50:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
  800d62:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d68:	50                   	push   %eax
  800d69:	e8 14 f6 ff ff       	call   800382 <fd_alloc>
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	89 c2                	mov    %eax,%edx
  800d73:	85 c0                	test   %eax,%eax
  800d75:	0f 88 2c 01 00 00    	js     800ea7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7b:	83 ec 04             	sub    $0x4,%esp
  800d7e:	68 07 04 00 00       	push   $0x407
  800d83:	ff 75 f4             	pushl  -0xc(%ebp)
  800d86:	6a 00                	push   $0x0
  800d88:	e8 dd f3 ff ff       	call   80016a <sys_page_alloc>
  800d8d:	83 c4 10             	add    $0x10,%esp
  800d90:	89 c2                	mov    %eax,%edx
  800d92:	85 c0                	test   %eax,%eax
  800d94:	0f 88 0d 01 00 00    	js     800ea7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d9a:	83 ec 0c             	sub    $0xc,%esp
  800d9d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800da0:	50                   	push   %eax
  800da1:	e8 dc f5 ff ff       	call   800382 <fd_alloc>
  800da6:	89 c3                	mov    %eax,%ebx
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	85 c0                	test   %eax,%eax
  800dad:	0f 88 e2 00 00 00    	js     800e95 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db3:	83 ec 04             	sub    $0x4,%esp
  800db6:	68 07 04 00 00       	push   $0x407
  800dbb:	ff 75 f0             	pushl  -0x10(%ebp)
  800dbe:	6a 00                	push   $0x0
  800dc0:	e8 a5 f3 ff ff       	call   80016a <sys_page_alloc>
  800dc5:	89 c3                	mov    %eax,%ebx
  800dc7:	83 c4 10             	add    $0x10,%esp
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	0f 88 c3 00 00 00    	js     800e95 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dd2:	83 ec 0c             	sub    $0xc,%esp
  800dd5:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd8:	e8 8e f5 ff ff       	call   80036b <fd2data>
  800ddd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddf:	83 c4 0c             	add    $0xc,%esp
  800de2:	68 07 04 00 00       	push   $0x407
  800de7:	50                   	push   %eax
  800de8:	6a 00                	push   $0x0
  800dea:	e8 7b f3 ff ff       	call   80016a <sys_page_alloc>
  800def:	89 c3                	mov    %eax,%ebx
  800df1:	83 c4 10             	add    $0x10,%esp
  800df4:	85 c0                	test   %eax,%eax
  800df6:	0f 88 89 00 00 00    	js     800e85 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dfc:	83 ec 0c             	sub    $0xc,%esp
  800dff:	ff 75 f0             	pushl  -0x10(%ebp)
  800e02:	e8 64 f5 ff ff       	call   80036b <fd2data>
  800e07:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e0e:	50                   	push   %eax
  800e0f:	6a 00                	push   $0x0
  800e11:	56                   	push   %esi
  800e12:	6a 00                	push   $0x0
  800e14:	e8 94 f3 ff ff       	call   8001ad <sys_page_map>
  800e19:	89 c3                	mov    %eax,%ebx
  800e1b:	83 c4 20             	add    $0x20,%esp
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	78 55                	js     800e77 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e22:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e30:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e37:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e40:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e45:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e4c:	83 ec 0c             	sub    $0xc,%esp
  800e4f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e52:	e8 04 f5 ff ff       	call   80035b <fd2num>
  800e57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e5c:	83 c4 04             	add    $0x4,%esp
  800e5f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e62:	e8 f4 f4 ff ff       	call   80035b <fd2num>
  800e67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	ba 00 00 00 00       	mov    $0x0,%edx
  800e75:	eb 30                	jmp    800ea7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e77:	83 ec 08             	sub    $0x8,%esp
  800e7a:	56                   	push   %esi
  800e7b:	6a 00                	push   $0x0
  800e7d:	e8 6d f3 ff ff       	call   8001ef <sys_page_unmap>
  800e82:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	ff 75 f0             	pushl  -0x10(%ebp)
  800e8b:	6a 00                	push   $0x0
  800e8d:	e8 5d f3 ff ff       	call   8001ef <sys_page_unmap>
  800e92:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e95:	83 ec 08             	sub    $0x8,%esp
  800e98:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9b:	6a 00                	push   $0x0
  800e9d:	e8 4d f3 ff ff       	call   8001ef <sys_page_unmap>
  800ea2:	83 c4 10             	add    $0x10,%esp
  800ea5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ea7:	89 d0                	mov    %edx,%eax
  800ea9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eac:	5b                   	pop    %ebx
  800ead:	5e                   	pop    %esi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb9:	50                   	push   %eax
  800eba:	ff 75 08             	pushl  0x8(%ebp)
  800ebd:	e8 0f f5 ff ff       	call   8003d1 <fd_lookup>
  800ec2:	89 c2                	mov    %eax,%edx
  800ec4:	83 c4 10             	add    $0x10,%esp
  800ec7:	85 d2                	test   %edx,%edx
  800ec9:	78 18                	js     800ee3 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ecb:	83 ec 0c             	sub    $0xc,%esp
  800ece:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed1:	e8 95 f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800ed6:	89 c2                	mov    %eax,%edx
  800ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800edb:	e8 26 fd ff ff       	call   800c06 <_pipeisclosed>
  800ee0:	83 c4 10             	add    $0x10,%esp
}
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    

00800ee5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ee8:	b8 00 00 00 00       	mov    $0x0,%eax
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ef5:	68 22 1f 80 00       	push   $0x801f22
  800efa:	ff 75 0c             	pushl  0xc(%ebp)
  800efd:	e8 c6 07 00 00       	call   8016c8 <strcpy>
	return 0;
}
  800f02:	b8 00 00 00 00       	mov    $0x0,%eax
  800f07:	c9                   	leave  
  800f08:	c3                   	ret    

00800f09 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	57                   	push   %edi
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
  800f0f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f15:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f1a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f20:	eb 2d                	jmp    800f4f <devcons_write+0x46>
		m = n - tot;
  800f22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f25:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f27:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f2a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f2f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f32:	83 ec 04             	sub    $0x4,%esp
  800f35:	53                   	push   %ebx
  800f36:	03 45 0c             	add    0xc(%ebp),%eax
  800f39:	50                   	push   %eax
  800f3a:	57                   	push   %edi
  800f3b:	e8 1a 09 00 00       	call   80185a <memmove>
		sys_cputs(buf, m);
  800f40:	83 c4 08             	add    $0x8,%esp
  800f43:	53                   	push   %ebx
  800f44:	57                   	push   %edi
  800f45:	e8 64 f1 ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f4a:	01 de                	add    %ebx,%esi
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	89 f0                	mov    %esi,%eax
  800f51:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f54:	72 cc                	jb     800f22 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f59:	5b                   	pop    %ebx
  800f5a:	5e                   	pop    %esi
  800f5b:	5f                   	pop    %edi
  800f5c:	5d                   	pop    %ebp
  800f5d:	c3                   	ret    

00800f5e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f64:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f6d:	75 07                	jne    800f76 <devcons_read+0x18>
  800f6f:	eb 28                	jmp    800f99 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f71:	e8 d5 f1 ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f76:	e8 51 f1 ff ff       	call   8000cc <sys_cgetc>
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	74 f2                	je     800f71 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 16                	js     800f99 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f83:	83 f8 04             	cmp    $0x4,%eax
  800f86:	74 0c                	je     800f94 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f88:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8b:	88 02                	mov    %al,(%edx)
	return 1;
  800f8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f92:	eb 05                	jmp    800f99 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f94:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    

00800f9b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fa7:	6a 01                	push   $0x1
  800fa9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fac:	50                   	push   %eax
  800fad:	e8 fc f0 ff ff       	call   8000ae <sys_cputs>
  800fb2:	83 c4 10             	add    $0x10,%esp
}
  800fb5:	c9                   	leave  
  800fb6:	c3                   	ret    

00800fb7 <getchar>:

int
getchar(void)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fbd:	6a 01                	push   $0x1
  800fbf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc2:	50                   	push   %eax
  800fc3:	6a 00                	push   $0x0
  800fc5:	e8 71 f6 ff ff       	call   80063b <read>
	if (r < 0)
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 0f                	js     800fe0 <getchar+0x29>
		return r;
	if (r < 1)
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	7e 06                	jle    800fdb <getchar+0x24>
		return -E_EOF;
	return c;
  800fd5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fd9:	eb 05                	jmp    800fe0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fdb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    

00800fe2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800feb:	50                   	push   %eax
  800fec:	ff 75 08             	pushl  0x8(%ebp)
  800fef:	e8 dd f3 ff ff       	call   8003d1 <fd_lookup>
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 11                	js     80100c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffe:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801004:	39 10                	cmp    %edx,(%eax)
  801006:	0f 94 c0             	sete   %al
  801009:	0f b6 c0             	movzbl %al,%eax
}
  80100c:	c9                   	leave  
  80100d:	c3                   	ret    

0080100e <opencons>:

int
opencons(void)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801014:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801017:	50                   	push   %eax
  801018:	e8 65 f3 ff ff       	call   800382 <fd_alloc>
  80101d:	83 c4 10             	add    $0x10,%esp
		return r;
  801020:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801022:	85 c0                	test   %eax,%eax
  801024:	78 3e                	js     801064 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801026:	83 ec 04             	sub    $0x4,%esp
  801029:	68 07 04 00 00       	push   $0x407
  80102e:	ff 75 f4             	pushl  -0xc(%ebp)
  801031:	6a 00                	push   $0x0
  801033:	e8 32 f1 ff ff       	call   80016a <sys_page_alloc>
  801038:	83 c4 10             	add    $0x10,%esp
		return r;
  80103b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 23                	js     801064 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801041:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801047:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80104c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	50                   	push   %eax
  80105a:	e8 fc f2 ff ff       	call   80035b <fd2num>
  80105f:	89 c2                	mov    %eax,%edx
  801061:	83 c4 10             	add    $0x10,%esp
}
  801064:	89 d0                	mov    %edx,%eax
  801066:	c9                   	leave  
  801067:	c3                   	ret    

00801068 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	56                   	push   %esi
  80106c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80106d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801070:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801076:	e8 b1 f0 ff ff       	call   80012c <sys_getenvid>
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	ff 75 0c             	pushl  0xc(%ebp)
  801081:	ff 75 08             	pushl  0x8(%ebp)
  801084:	56                   	push   %esi
  801085:	50                   	push   %eax
  801086:	68 30 1f 80 00       	push   $0x801f30
  80108b:	e8 b1 00 00 00       	call   801141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801090:	83 c4 18             	add    $0x18,%esp
  801093:	53                   	push   %ebx
  801094:	ff 75 10             	pushl  0x10(%ebp)
  801097:	e8 54 00 00 00       	call   8010f0 <vcprintf>
	cprintf("\n");
  80109c:	c7 04 24 1b 1f 80 00 	movl   $0x801f1b,(%esp)
  8010a3:	e8 99 00 00 00       	call   801141 <cprintf>
  8010a8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ab:	cc                   	int3   
  8010ac:	eb fd                	jmp    8010ab <_panic+0x43>

008010ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	53                   	push   %ebx
  8010b2:	83 ec 04             	sub    $0x4,%esp
  8010b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010b8:	8b 13                	mov    (%ebx),%edx
  8010ba:	8d 42 01             	lea    0x1(%edx),%eax
  8010bd:	89 03                	mov    %eax,(%ebx)
  8010bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010cb:	75 1a                	jne    8010e7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010cd:	83 ec 08             	sub    $0x8,%esp
  8010d0:	68 ff 00 00 00       	push   $0xff
  8010d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8010d8:	50                   	push   %eax
  8010d9:	e8 d0 ef ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  8010de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ee:	c9                   	leave  
  8010ef:	c3                   	ret    

008010f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801100:	00 00 00 
	b.cnt = 0;
  801103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80110a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80110d:	ff 75 0c             	pushl  0xc(%ebp)
  801110:	ff 75 08             	pushl  0x8(%ebp)
  801113:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801119:	50                   	push   %eax
  80111a:	68 ae 10 80 00       	push   $0x8010ae
  80111f:	e8 4f 01 00 00       	call   801273 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801124:	83 c4 08             	add    $0x8,%esp
  801127:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80112d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801133:	50                   	push   %eax
  801134:	e8 75 ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  801139:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80113f:	c9                   	leave  
  801140:	c3                   	ret    

00801141 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801147:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80114a:	50                   	push   %eax
  80114b:	ff 75 08             	pushl  0x8(%ebp)
  80114e:	e8 9d ff ff ff       	call   8010f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  801153:	c9                   	leave  
  801154:	c3                   	ret    

00801155 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	57                   	push   %edi
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
  80115b:	83 ec 1c             	sub    $0x1c,%esp
  80115e:	89 c7                	mov    %eax,%edi
  801160:	89 d6                	mov    %edx,%esi
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
  801165:	8b 55 0c             	mov    0xc(%ebp),%edx
  801168:	89 d1                	mov    %edx,%ecx
  80116a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80116d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801170:	8b 45 10             	mov    0x10(%ebp),%eax
  801173:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801176:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801179:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801180:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801183:	72 05                	jb     80118a <printnum+0x35>
  801185:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801188:	77 3e                	ja     8011c8 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80118a:	83 ec 0c             	sub    $0xc,%esp
  80118d:	ff 75 18             	pushl  0x18(%ebp)
  801190:	83 eb 01             	sub    $0x1,%ebx
  801193:	53                   	push   %ebx
  801194:	50                   	push   %eax
  801195:	83 ec 08             	sub    $0x8,%esp
  801198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119b:	ff 75 e0             	pushl  -0x20(%ebp)
  80119e:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8011a4:	e8 a7 09 00 00       	call   801b50 <__udivdi3>
  8011a9:	83 c4 18             	add    $0x18,%esp
  8011ac:	52                   	push   %edx
  8011ad:	50                   	push   %eax
  8011ae:	89 f2                	mov    %esi,%edx
  8011b0:	89 f8                	mov    %edi,%eax
  8011b2:	e8 9e ff ff ff       	call   801155 <printnum>
  8011b7:	83 c4 20             	add    $0x20,%esp
  8011ba:	eb 13                	jmp    8011cf <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011bc:	83 ec 08             	sub    $0x8,%esp
  8011bf:	56                   	push   %esi
  8011c0:	ff 75 18             	pushl  0x18(%ebp)
  8011c3:	ff d7                	call   *%edi
  8011c5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011c8:	83 eb 01             	sub    $0x1,%ebx
  8011cb:	85 db                	test   %ebx,%ebx
  8011cd:	7f ed                	jg     8011bc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011cf:	83 ec 08             	sub    $0x8,%esp
  8011d2:	56                   	push   %esi
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8011dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8011df:	ff 75 d8             	pushl  -0x28(%ebp)
  8011e2:	e8 99 0a 00 00       	call   801c80 <__umoddi3>
  8011e7:	83 c4 14             	add    $0x14,%esp
  8011ea:	0f be 80 53 1f 80 00 	movsbl 0x801f53(%eax),%eax
  8011f1:	50                   	push   %eax
  8011f2:	ff d7                	call   *%edi
  8011f4:	83 c4 10             	add    $0x10,%esp
}
  8011f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fa:	5b                   	pop    %ebx
  8011fb:	5e                   	pop    %esi
  8011fc:	5f                   	pop    %edi
  8011fd:	5d                   	pop    %ebp
  8011fe:	c3                   	ret    

008011ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801202:	83 fa 01             	cmp    $0x1,%edx
  801205:	7e 0e                	jle    801215 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801207:	8b 10                	mov    (%eax),%edx
  801209:	8d 4a 08             	lea    0x8(%edx),%ecx
  80120c:	89 08                	mov    %ecx,(%eax)
  80120e:	8b 02                	mov    (%edx),%eax
  801210:	8b 52 04             	mov    0x4(%edx),%edx
  801213:	eb 22                	jmp    801237 <getuint+0x38>
	else if (lflag)
  801215:	85 d2                	test   %edx,%edx
  801217:	74 10                	je     801229 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801219:	8b 10                	mov    (%eax),%edx
  80121b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80121e:	89 08                	mov    %ecx,(%eax)
  801220:	8b 02                	mov    (%edx),%eax
  801222:	ba 00 00 00 00       	mov    $0x0,%edx
  801227:	eb 0e                	jmp    801237 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801229:	8b 10                	mov    (%eax),%edx
  80122b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80122e:	89 08                	mov    %ecx,(%eax)
  801230:	8b 02                	mov    (%edx),%eax
  801232:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80123f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801243:	8b 10                	mov    (%eax),%edx
  801245:	3b 50 04             	cmp    0x4(%eax),%edx
  801248:	73 0a                	jae    801254 <sprintputch+0x1b>
		*b->buf++ = ch;
  80124a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80124d:	89 08                	mov    %ecx,(%eax)
  80124f:	8b 45 08             	mov    0x8(%ebp),%eax
  801252:	88 02                	mov    %al,(%edx)
}
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80125c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80125f:	50                   	push   %eax
  801260:	ff 75 10             	pushl  0x10(%ebp)
  801263:	ff 75 0c             	pushl  0xc(%ebp)
  801266:	ff 75 08             	pushl  0x8(%ebp)
  801269:	e8 05 00 00 00       	call   801273 <vprintfmt>
	va_end(ap);
  80126e:	83 c4 10             	add    $0x10,%esp
}
  801271:	c9                   	leave  
  801272:	c3                   	ret    

00801273 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	57                   	push   %edi
  801277:	56                   	push   %esi
  801278:	53                   	push   %ebx
  801279:	83 ec 2c             	sub    $0x2c,%esp
  80127c:	8b 75 08             	mov    0x8(%ebp),%esi
  80127f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801282:	8b 7d 10             	mov    0x10(%ebp),%edi
  801285:	eb 12                	jmp    801299 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801287:	85 c0                	test   %eax,%eax
  801289:	0f 84 90 03 00 00    	je     80161f <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80128f:	83 ec 08             	sub    $0x8,%esp
  801292:	53                   	push   %ebx
  801293:	50                   	push   %eax
  801294:	ff d6                	call   *%esi
  801296:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801299:	83 c7 01             	add    $0x1,%edi
  80129c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012a0:	83 f8 25             	cmp    $0x25,%eax
  8012a3:	75 e2                	jne    801287 <vprintfmt+0x14>
  8012a5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012a9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012be:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c3:	eb 07                	jmp    8012cc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012c8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cc:	8d 47 01             	lea    0x1(%edi),%eax
  8012cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012d2:	0f b6 07             	movzbl (%edi),%eax
  8012d5:	0f b6 c8             	movzbl %al,%ecx
  8012d8:	83 e8 23             	sub    $0x23,%eax
  8012db:	3c 55                	cmp    $0x55,%al
  8012dd:	0f 87 21 03 00 00    	ja     801604 <vprintfmt+0x391>
  8012e3:	0f b6 c0             	movzbl %al,%eax
  8012e6:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  8012ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012f0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012f4:	eb d6                	jmp    8012cc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801301:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801304:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801308:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80130b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80130e:	83 fa 09             	cmp    $0x9,%edx
  801311:	77 39                	ja     80134c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801313:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801316:	eb e9                	jmp    801301 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801318:	8b 45 14             	mov    0x14(%ebp),%eax
  80131b:	8d 48 04             	lea    0x4(%eax),%ecx
  80131e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801321:	8b 00                	mov    (%eax),%eax
  801323:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801329:	eb 27                	jmp    801352 <vprintfmt+0xdf>
  80132b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132e:	85 c0                	test   %eax,%eax
  801330:	b9 00 00 00 00       	mov    $0x0,%ecx
  801335:	0f 49 c8             	cmovns %eax,%ecx
  801338:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80133e:	eb 8c                	jmp    8012cc <vprintfmt+0x59>
  801340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801343:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80134a:	eb 80                	jmp    8012cc <vprintfmt+0x59>
  80134c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80134f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801352:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801356:	0f 89 70 ff ff ff    	jns    8012cc <vprintfmt+0x59>
				width = precision, precision = -1;
  80135c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80135f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801362:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801369:	e9 5e ff ff ff       	jmp    8012cc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80136e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801374:	e9 53 ff ff ff       	jmp    8012cc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801379:	8b 45 14             	mov    0x14(%ebp),%eax
  80137c:	8d 50 04             	lea    0x4(%eax),%edx
  80137f:	89 55 14             	mov    %edx,0x14(%ebp)
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	53                   	push   %ebx
  801386:	ff 30                	pushl  (%eax)
  801388:	ff d6                	call   *%esi
			break;
  80138a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801390:	e9 04 ff ff ff       	jmp    801299 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801395:	8b 45 14             	mov    0x14(%ebp),%eax
  801398:	8d 50 04             	lea    0x4(%eax),%edx
  80139b:	89 55 14             	mov    %edx,0x14(%ebp)
  80139e:	8b 00                	mov    (%eax),%eax
  8013a0:	99                   	cltd   
  8013a1:	31 d0                	xor    %edx,%eax
  8013a3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013a5:	83 f8 0f             	cmp    $0xf,%eax
  8013a8:	7f 0b                	jg     8013b5 <vprintfmt+0x142>
  8013aa:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  8013b1:	85 d2                	test   %edx,%edx
  8013b3:	75 18                	jne    8013cd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013b5:	50                   	push   %eax
  8013b6:	68 6b 1f 80 00       	push   $0x801f6b
  8013bb:	53                   	push   %ebx
  8013bc:	56                   	push   %esi
  8013bd:	e8 94 fe ff ff       	call   801256 <printfmt>
  8013c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013c8:	e9 cc fe ff ff       	jmp    801299 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013cd:	52                   	push   %edx
  8013ce:	68 e9 1e 80 00       	push   $0x801ee9
  8013d3:	53                   	push   %ebx
  8013d4:	56                   	push   %esi
  8013d5:	e8 7c fe ff ff       	call   801256 <printfmt>
  8013da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013e0:	e9 b4 fe ff ff       	jmp    801299 <vprintfmt+0x26>
  8013e5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f1:	8d 50 04             	lea    0x4(%eax),%edx
  8013f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8013f7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013f9:	85 ff                	test   %edi,%edi
  8013fb:	ba 64 1f 80 00       	mov    $0x801f64,%edx
  801400:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  801403:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801407:	0f 84 92 00 00 00    	je     80149f <vprintfmt+0x22c>
  80140d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801411:	0f 8e 96 00 00 00    	jle    8014ad <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	51                   	push   %ecx
  80141b:	57                   	push   %edi
  80141c:	e8 86 02 00 00       	call   8016a7 <strnlen>
  801421:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801424:	29 c1                	sub    %eax,%ecx
  801426:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801429:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80142c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801433:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801436:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801438:	eb 0f                	jmp    801449 <vprintfmt+0x1d6>
					putch(padc, putdat);
  80143a:	83 ec 08             	sub    $0x8,%esp
  80143d:	53                   	push   %ebx
  80143e:	ff 75 e0             	pushl  -0x20(%ebp)
  801441:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801443:	83 ef 01             	sub    $0x1,%edi
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 ff                	test   %edi,%edi
  80144b:	7f ed                	jg     80143a <vprintfmt+0x1c7>
  80144d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801450:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801453:	85 c9                	test   %ecx,%ecx
  801455:	b8 00 00 00 00       	mov    $0x0,%eax
  80145a:	0f 49 c1             	cmovns %ecx,%eax
  80145d:	29 c1                	sub    %eax,%ecx
  80145f:	89 75 08             	mov    %esi,0x8(%ebp)
  801462:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801465:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801468:	89 cb                	mov    %ecx,%ebx
  80146a:	eb 4d                	jmp    8014b9 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80146c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801470:	74 1b                	je     80148d <vprintfmt+0x21a>
  801472:	0f be c0             	movsbl %al,%eax
  801475:	83 e8 20             	sub    $0x20,%eax
  801478:	83 f8 5e             	cmp    $0x5e,%eax
  80147b:	76 10                	jbe    80148d <vprintfmt+0x21a>
					putch('?', putdat);
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	ff 75 0c             	pushl  0xc(%ebp)
  801483:	6a 3f                	push   $0x3f
  801485:	ff 55 08             	call   *0x8(%ebp)
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	eb 0d                	jmp    80149a <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80148d:	83 ec 08             	sub    $0x8,%esp
  801490:	ff 75 0c             	pushl  0xc(%ebp)
  801493:	52                   	push   %edx
  801494:	ff 55 08             	call   *0x8(%ebp)
  801497:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80149a:	83 eb 01             	sub    $0x1,%ebx
  80149d:	eb 1a                	jmp    8014b9 <vprintfmt+0x246>
  80149f:	89 75 08             	mov    %esi,0x8(%ebp)
  8014a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014ab:	eb 0c                	jmp    8014b9 <vprintfmt+0x246>
  8014ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8014b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014b9:	83 c7 01             	add    $0x1,%edi
  8014bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014c0:	0f be d0             	movsbl %al,%edx
  8014c3:	85 d2                	test   %edx,%edx
  8014c5:	74 23                	je     8014ea <vprintfmt+0x277>
  8014c7:	85 f6                	test   %esi,%esi
  8014c9:	78 a1                	js     80146c <vprintfmt+0x1f9>
  8014cb:	83 ee 01             	sub    $0x1,%esi
  8014ce:	79 9c                	jns    80146c <vprintfmt+0x1f9>
  8014d0:	89 df                	mov    %ebx,%edi
  8014d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d8:	eb 18                	jmp    8014f2 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	53                   	push   %ebx
  8014de:	6a 20                	push   $0x20
  8014e0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014e2:	83 ef 01             	sub    $0x1,%edi
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	eb 08                	jmp    8014f2 <vprintfmt+0x27f>
  8014ea:	89 df                	mov    %ebx,%edi
  8014ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014f2:	85 ff                	test   %edi,%edi
  8014f4:	7f e4                	jg     8014da <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014f9:	e9 9b fd ff ff       	jmp    801299 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014fe:	83 fa 01             	cmp    $0x1,%edx
  801501:	7e 16                	jle    801519 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801503:	8b 45 14             	mov    0x14(%ebp),%eax
  801506:	8d 50 08             	lea    0x8(%eax),%edx
  801509:	89 55 14             	mov    %edx,0x14(%ebp)
  80150c:	8b 50 04             	mov    0x4(%eax),%edx
  80150f:	8b 00                	mov    (%eax),%eax
  801511:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801514:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801517:	eb 32                	jmp    80154b <vprintfmt+0x2d8>
	else if (lflag)
  801519:	85 d2                	test   %edx,%edx
  80151b:	74 18                	je     801535 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80151d:	8b 45 14             	mov    0x14(%ebp),%eax
  801520:	8d 50 04             	lea    0x4(%eax),%edx
  801523:	89 55 14             	mov    %edx,0x14(%ebp)
  801526:	8b 00                	mov    (%eax),%eax
  801528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80152b:	89 c1                	mov    %eax,%ecx
  80152d:	c1 f9 1f             	sar    $0x1f,%ecx
  801530:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801533:	eb 16                	jmp    80154b <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801535:	8b 45 14             	mov    0x14(%ebp),%eax
  801538:	8d 50 04             	lea    0x4(%eax),%edx
  80153b:	89 55 14             	mov    %edx,0x14(%ebp)
  80153e:	8b 00                	mov    (%eax),%eax
  801540:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801543:	89 c1                	mov    %eax,%ecx
  801545:	c1 f9 1f             	sar    $0x1f,%ecx
  801548:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80154b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80154e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801551:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801556:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80155a:	79 74                	jns    8015d0 <vprintfmt+0x35d>
				putch('-', putdat);
  80155c:	83 ec 08             	sub    $0x8,%esp
  80155f:	53                   	push   %ebx
  801560:	6a 2d                	push   $0x2d
  801562:	ff d6                	call   *%esi
				num = -(long long) num;
  801564:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801567:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80156a:	f7 d8                	neg    %eax
  80156c:	83 d2 00             	adc    $0x0,%edx
  80156f:	f7 da                	neg    %edx
  801571:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801574:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801579:	eb 55                	jmp    8015d0 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80157b:	8d 45 14             	lea    0x14(%ebp),%eax
  80157e:	e8 7c fc ff ff       	call   8011ff <getuint>
			base = 10;
  801583:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801588:	eb 46                	jmp    8015d0 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80158a:	8d 45 14             	lea    0x14(%ebp),%eax
  80158d:	e8 6d fc ff ff       	call   8011ff <getuint>
                        base = 8;
  801592:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801597:	eb 37                	jmp    8015d0 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	53                   	push   %ebx
  80159d:	6a 30                	push   $0x30
  80159f:	ff d6                	call   *%esi
			putch('x', putdat);
  8015a1:	83 c4 08             	add    $0x8,%esp
  8015a4:	53                   	push   %ebx
  8015a5:	6a 78                	push   $0x78
  8015a7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ac:	8d 50 04             	lea    0x4(%eax),%edx
  8015af:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015b2:	8b 00                	mov    (%eax),%eax
  8015b4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015b9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015bc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015c1:	eb 0d                	jmp    8015d0 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8015c6:	e8 34 fc ff ff       	call   8011ff <getuint>
			base = 16;
  8015cb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015d0:	83 ec 0c             	sub    $0xc,%esp
  8015d3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015d7:	57                   	push   %edi
  8015d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015db:	51                   	push   %ecx
  8015dc:	52                   	push   %edx
  8015dd:	50                   	push   %eax
  8015de:	89 da                	mov    %ebx,%edx
  8015e0:	89 f0                	mov    %esi,%eax
  8015e2:	e8 6e fb ff ff       	call   801155 <printnum>
			break;
  8015e7:	83 c4 20             	add    $0x20,%esp
  8015ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015ed:	e9 a7 fc ff ff       	jmp    801299 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015f2:	83 ec 08             	sub    $0x8,%esp
  8015f5:	53                   	push   %ebx
  8015f6:	51                   	push   %ecx
  8015f7:	ff d6                	call   *%esi
			break;
  8015f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015ff:	e9 95 fc ff ff       	jmp    801299 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	53                   	push   %ebx
  801608:	6a 25                	push   $0x25
  80160a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	eb 03                	jmp    801614 <vprintfmt+0x3a1>
  801611:	83 ef 01             	sub    $0x1,%edi
  801614:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801618:	75 f7                	jne    801611 <vprintfmt+0x39e>
  80161a:	e9 7a fc ff ff       	jmp    801299 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80161f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801622:	5b                   	pop    %ebx
  801623:	5e                   	pop    %esi
  801624:	5f                   	pop    %edi
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	83 ec 18             	sub    $0x18,%esp
  80162d:	8b 45 08             	mov    0x8(%ebp),%eax
  801630:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801633:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801636:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80163a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80163d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801644:	85 c0                	test   %eax,%eax
  801646:	74 26                	je     80166e <vsnprintf+0x47>
  801648:	85 d2                	test   %edx,%edx
  80164a:	7e 22                	jle    80166e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80164c:	ff 75 14             	pushl  0x14(%ebp)
  80164f:	ff 75 10             	pushl  0x10(%ebp)
  801652:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801655:	50                   	push   %eax
  801656:	68 39 12 80 00       	push   $0x801239
  80165b:	e8 13 fc ff ff       	call   801273 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801660:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801663:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801666:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801669:	83 c4 10             	add    $0x10,%esp
  80166c:	eb 05                	jmp    801673 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80166e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80167b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80167e:	50                   	push   %eax
  80167f:	ff 75 10             	pushl  0x10(%ebp)
  801682:	ff 75 0c             	pushl  0xc(%ebp)
  801685:	ff 75 08             	pushl  0x8(%ebp)
  801688:	e8 9a ff ff ff       	call   801627 <vsnprintf>
	va_end(ap);

	return rc;
}
  80168d:	c9                   	leave  
  80168e:	c3                   	ret    

0080168f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801695:	b8 00 00 00 00       	mov    $0x0,%eax
  80169a:	eb 03                	jmp    80169f <strlen+0x10>
		n++;
  80169c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80169f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016a3:	75 f7                	jne    80169c <strlen+0xd>
		n++;
	return n;
}
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b5:	eb 03                	jmp    8016ba <strnlen+0x13>
		n++;
  8016b7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ba:	39 c2                	cmp    %eax,%edx
  8016bc:	74 08                	je     8016c6 <strnlen+0x1f>
  8016be:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016c2:	75 f3                	jne    8016b7 <strnlen+0x10>
  8016c4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016d2:	89 c2                	mov    %eax,%edx
  8016d4:	83 c2 01             	add    $0x1,%edx
  8016d7:	83 c1 01             	add    $0x1,%ecx
  8016da:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016de:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016e1:	84 db                	test   %bl,%bl
  8016e3:	75 ef                	jne    8016d4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016e5:	5b                   	pop    %ebx
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    

008016e8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	53                   	push   %ebx
  8016ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016ef:	53                   	push   %ebx
  8016f0:	e8 9a ff ff ff       	call   80168f <strlen>
  8016f5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016f8:	ff 75 0c             	pushl  0xc(%ebp)
  8016fb:	01 d8                	add    %ebx,%eax
  8016fd:	50                   	push   %eax
  8016fe:	e8 c5 ff ff ff       	call   8016c8 <strcpy>
	return dst;
}
  801703:	89 d8                	mov    %ebx,%eax
  801705:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	56                   	push   %esi
  80170e:	53                   	push   %ebx
  80170f:	8b 75 08             	mov    0x8(%ebp),%esi
  801712:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801715:	89 f3                	mov    %esi,%ebx
  801717:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80171a:	89 f2                	mov    %esi,%edx
  80171c:	eb 0f                	jmp    80172d <strncpy+0x23>
		*dst++ = *src;
  80171e:	83 c2 01             	add    $0x1,%edx
  801721:	0f b6 01             	movzbl (%ecx),%eax
  801724:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801727:	80 39 01             	cmpb   $0x1,(%ecx)
  80172a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80172d:	39 da                	cmp    %ebx,%edx
  80172f:	75 ed                	jne    80171e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801731:	89 f0                	mov    %esi,%eax
  801733:	5b                   	pop    %ebx
  801734:	5e                   	pop    %esi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	8b 75 08             	mov    0x8(%ebp),%esi
  80173f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801742:	8b 55 10             	mov    0x10(%ebp),%edx
  801745:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801747:	85 d2                	test   %edx,%edx
  801749:	74 21                	je     80176c <strlcpy+0x35>
  80174b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80174f:	89 f2                	mov    %esi,%edx
  801751:	eb 09                	jmp    80175c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801753:	83 c2 01             	add    $0x1,%edx
  801756:	83 c1 01             	add    $0x1,%ecx
  801759:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80175c:	39 c2                	cmp    %eax,%edx
  80175e:	74 09                	je     801769 <strlcpy+0x32>
  801760:	0f b6 19             	movzbl (%ecx),%ebx
  801763:	84 db                	test   %bl,%bl
  801765:	75 ec                	jne    801753 <strlcpy+0x1c>
  801767:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801769:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80176c:	29 f0                	sub    %esi,%eax
}
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801778:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80177b:	eb 06                	jmp    801783 <strcmp+0x11>
		p++, q++;
  80177d:	83 c1 01             	add    $0x1,%ecx
  801780:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801783:	0f b6 01             	movzbl (%ecx),%eax
  801786:	84 c0                	test   %al,%al
  801788:	74 04                	je     80178e <strcmp+0x1c>
  80178a:	3a 02                	cmp    (%edx),%al
  80178c:	74 ef                	je     80177d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80178e:	0f b6 c0             	movzbl %al,%eax
  801791:	0f b6 12             	movzbl (%edx),%edx
  801794:	29 d0                	sub    %edx,%eax
}
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	53                   	push   %ebx
  80179c:	8b 45 08             	mov    0x8(%ebp),%eax
  80179f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a2:	89 c3                	mov    %eax,%ebx
  8017a4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017a7:	eb 06                	jmp    8017af <strncmp+0x17>
		n--, p++, q++;
  8017a9:	83 c0 01             	add    $0x1,%eax
  8017ac:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017af:	39 d8                	cmp    %ebx,%eax
  8017b1:	74 15                	je     8017c8 <strncmp+0x30>
  8017b3:	0f b6 08             	movzbl (%eax),%ecx
  8017b6:	84 c9                	test   %cl,%cl
  8017b8:	74 04                	je     8017be <strncmp+0x26>
  8017ba:	3a 0a                	cmp    (%edx),%cl
  8017bc:	74 eb                	je     8017a9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017be:	0f b6 00             	movzbl (%eax),%eax
  8017c1:	0f b6 12             	movzbl (%edx),%edx
  8017c4:	29 d0                	sub    %edx,%eax
  8017c6:	eb 05                	jmp    8017cd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017c8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017cd:	5b                   	pop    %ebx
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017da:	eb 07                	jmp    8017e3 <strchr+0x13>
		if (*s == c)
  8017dc:	38 ca                	cmp    %cl,%dl
  8017de:	74 0f                	je     8017ef <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017e0:	83 c0 01             	add    $0x1,%eax
  8017e3:	0f b6 10             	movzbl (%eax),%edx
  8017e6:	84 d2                	test   %dl,%dl
  8017e8:	75 f2                	jne    8017dc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ef:	5d                   	pop    %ebp
  8017f0:	c3                   	ret    

008017f1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017fb:	eb 03                	jmp    801800 <strfind+0xf>
  8017fd:	83 c0 01             	add    $0x1,%eax
  801800:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801803:	84 d2                	test   %dl,%dl
  801805:	74 04                	je     80180b <strfind+0x1a>
  801807:	38 ca                	cmp    %cl,%dl
  801809:	75 f2                	jne    8017fd <strfind+0xc>
			break;
	return (char *) s;
}
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	57                   	push   %edi
  801811:	56                   	push   %esi
  801812:	53                   	push   %ebx
  801813:	8b 7d 08             	mov    0x8(%ebp),%edi
  801816:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801819:	85 c9                	test   %ecx,%ecx
  80181b:	74 36                	je     801853 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80181d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801823:	75 28                	jne    80184d <memset+0x40>
  801825:	f6 c1 03             	test   $0x3,%cl
  801828:	75 23                	jne    80184d <memset+0x40>
		c &= 0xFF;
  80182a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80182e:	89 d3                	mov    %edx,%ebx
  801830:	c1 e3 08             	shl    $0x8,%ebx
  801833:	89 d6                	mov    %edx,%esi
  801835:	c1 e6 18             	shl    $0x18,%esi
  801838:	89 d0                	mov    %edx,%eax
  80183a:	c1 e0 10             	shl    $0x10,%eax
  80183d:	09 f0                	or     %esi,%eax
  80183f:	09 c2                	or     %eax,%edx
  801841:	89 d0                	mov    %edx,%eax
  801843:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801845:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801848:	fc                   	cld    
  801849:	f3 ab                	rep stos %eax,%es:(%edi)
  80184b:	eb 06                	jmp    801853 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80184d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801850:	fc                   	cld    
  801851:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801853:	89 f8                	mov    %edi,%eax
  801855:	5b                   	pop    %ebx
  801856:	5e                   	pop    %esi
  801857:	5f                   	pop    %edi
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    

0080185a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	57                   	push   %edi
  80185e:	56                   	push   %esi
  80185f:	8b 45 08             	mov    0x8(%ebp),%eax
  801862:	8b 75 0c             	mov    0xc(%ebp),%esi
  801865:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801868:	39 c6                	cmp    %eax,%esi
  80186a:	73 35                	jae    8018a1 <memmove+0x47>
  80186c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80186f:	39 d0                	cmp    %edx,%eax
  801871:	73 2e                	jae    8018a1 <memmove+0x47>
		s += n;
		d += n;
  801873:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801876:	89 d6                	mov    %edx,%esi
  801878:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80187a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801880:	75 13                	jne    801895 <memmove+0x3b>
  801882:	f6 c1 03             	test   $0x3,%cl
  801885:	75 0e                	jne    801895 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801887:	83 ef 04             	sub    $0x4,%edi
  80188a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80188d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801890:	fd                   	std    
  801891:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801893:	eb 09                	jmp    80189e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801895:	83 ef 01             	sub    $0x1,%edi
  801898:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80189b:	fd                   	std    
  80189c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80189e:	fc                   	cld    
  80189f:	eb 1d                	jmp    8018be <memmove+0x64>
  8018a1:	89 f2                	mov    %esi,%edx
  8018a3:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a5:	f6 c2 03             	test   $0x3,%dl
  8018a8:	75 0f                	jne    8018b9 <memmove+0x5f>
  8018aa:	f6 c1 03             	test   $0x3,%cl
  8018ad:	75 0a                	jne    8018b9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018af:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018b2:	89 c7                	mov    %eax,%edi
  8018b4:	fc                   	cld    
  8018b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b7:	eb 05                	jmp    8018be <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018b9:	89 c7                	mov    %eax,%edi
  8018bb:	fc                   	cld    
  8018bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018be:	5e                   	pop    %esi
  8018bf:	5f                   	pop    %edi
  8018c0:	5d                   	pop    %ebp
  8018c1:	c3                   	ret    

008018c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018c5:	ff 75 10             	pushl  0x10(%ebp)
  8018c8:	ff 75 0c             	pushl  0xc(%ebp)
  8018cb:	ff 75 08             	pushl  0x8(%ebp)
  8018ce:	e8 87 ff ff ff       	call   80185a <memmove>
}
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e0:	89 c6                	mov    %eax,%esi
  8018e2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e5:	eb 1a                	jmp    801901 <memcmp+0x2c>
		if (*s1 != *s2)
  8018e7:	0f b6 08             	movzbl (%eax),%ecx
  8018ea:	0f b6 1a             	movzbl (%edx),%ebx
  8018ed:	38 d9                	cmp    %bl,%cl
  8018ef:	74 0a                	je     8018fb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018f1:	0f b6 c1             	movzbl %cl,%eax
  8018f4:	0f b6 db             	movzbl %bl,%ebx
  8018f7:	29 d8                	sub    %ebx,%eax
  8018f9:	eb 0f                	jmp    80190a <memcmp+0x35>
		s1++, s2++;
  8018fb:	83 c0 01             	add    $0x1,%eax
  8018fe:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801901:	39 f0                	cmp    %esi,%eax
  801903:	75 e2                	jne    8018e7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190a:	5b                   	pop    %ebx
  80190b:	5e                   	pop    %esi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	8b 45 08             	mov    0x8(%ebp),%eax
  801914:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801917:	89 c2                	mov    %eax,%edx
  801919:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80191c:	eb 07                	jmp    801925 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80191e:	38 08                	cmp    %cl,(%eax)
  801920:	74 07                	je     801929 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801922:	83 c0 01             	add    $0x1,%eax
  801925:	39 d0                	cmp    %edx,%eax
  801927:	72 f5                	jb     80191e <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	57                   	push   %edi
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801934:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801937:	eb 03                	jmp    80193c <strtol+0x11>
		s++;
  801939:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80193c:	0f b6 01             	movzbl (%ecx),%eax
  80193f:	3c 09                	cmp    $0x9,%al
  801941:	74 f6                	je     801939 <strtol+0xe>
  801943:	3c 20                	cmp    $0x20,%al
  801945:	74 f2                	je     801939 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801947:	3c 2b                	cmp    $0x2b,%al
  801949:	75 0a                	jne    801955 <strtol+0x2a>
		s++;
  80194b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80194e:	bf 00 00 00 00       	mov    $0x0,%edi
  801953:	eb 10                	jmp    801965 <strtol+0x3a>
  801955:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80195a:	3c 2d                	cmp    $0x2d,%al
  80195c:	75 07                	jne    801965 <strtol+0x3a>
		s++, neg = 1;
  80195e:	8d 49 01             	lea    0x1(%ecx),%ecx
  801961:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801965:	85 db                	test   %ebx,%ebx
  801967:	0f 94 c0             	sete   %al
  80196a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801970:	75 19                	jne    80198b <strtol+0x60>
  801972:	80 39 30             	cmpb   $0x30,(%ecx)
  801975:	75 14                	jne    80198b <strtol+0x60>
  801977:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80197b:	0f 85 82 00 00 00    	jne    801a03 <strtol+0xd8>
		s += 2, base = 16;
  801981:	83 c1 02             	add    $0x2,%ecx
  801984:	bb 10 00 00 00       	mov    $0x10,%ebx
  801989:	eb 16                	jmp    8019a1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80198b:	84 c0                	test   %al,%al
  80198d:	74 12                	je     8019a1 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80198f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801994:	80 39 30             	cmpb   $0x30,(%ecx)
  801997:	75 08                	jne    8019a1 <strtol+0x76>
		s++, base = 8;
  801999:	83 c1 01             	add    $0x1,%ecx
  80199c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019a9:	0f b6 11             	movzbl (%ecx),%edx
  8019ac:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019af:	89 f3                	mov    %esi,%ebx
  8019b1:	80 fb 09             	cmp    $0x9,%bl
  8019b4:	77 08                	ja     8019be <strtol+0x93>
			dig = *s - '0';
  8019b6:	0f be d2             	movsbl %dl,%edx
  8019b9:	83 ea 30             	sub    $0x30,%edx
  8019bc:	eb 22                	jmp    8019e0 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019be:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019c1:	89 f3                	mov    %esi,%ebx
  8019c3:	80 fb 19             	cmp    $0x19,%bl
  8019c6:	77 08                	ja     8019d0 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019c8:	0f be d2             	movsbl %dl,%edx
  8019cb:	83 ea 57             	sub    $0x57,%edx
  8019ce:	eb 10                	jmp    8019e0 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019d0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019d3:	89 f3                	mov    %esi,%ebx
  8019d5:	80 fb 19             	cmp    $0x19,%bl
  8019d8:	77 16                	ja     8019f0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019da:	0f be d2             	movsbl %dl,%edx
  8019dd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019e0:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019e3:	7d 0f                	jge    8019f4 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019e5:	83 c1 01             	add    $0x1,%ecx
  8019e8:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019ec:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019ee:	eb b9                	jmp    8019a9 <strtol+0x7e>
  8019f0:	89 c2                	mov    %eax,%edx
  8019f2:	eb 02                	jmp    8019f6 <strtol+0xcb>
  8019f4:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019fa:	74 0d                	je     801a09 <strtol+0xde>
		*endptr = (char *) s;
  8019fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019ff:	89 0e                	mov    %ecx,(%esi)
  801a01:	eb 06                	jmp    801a09 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a03:	84 c0                	test   %al,%al
  801a05:	75 92                	jne    801999 <strtol+0x6e>
  801a07:	eb 98                	jmp    8019a1 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a09:	f7 da                	neg    %edx
  801a0b:	85 ff                	test   %edi,%edi
  801a0d:	0f 45 c2             	cmovne %edx,%eax
}
  801a10:	5b                   	pop    %ebx
  801a11:	5e                   	pop    %esi
  801a12:	5f                   	pop    %edi
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    

00801a15 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	56                   	push   %esi
  801a19:	53                   	push   %ebx
  801a1a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801a23:	85 c0                	test   %eax,%eax
  801a25:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a2a:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801a2d:	83 ec 0c             	sub    $0xc,%esp
  801a30:	50                   	push   %eax
  801a31:	e8 e4 e8 ff ff       	call   80031a <sys_ipc_recv>
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	79 16                	jns    801a53 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801a3d:	85 f6                	test   %esi,%esi
  801a3f:	74 06                	je     801a47 <ipc_recv+0x32>
  801a41:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801a47:	85 db                	test   %ebx,%ebx
  801a49:	74 2c                	je     801a77 <ipc_recv+0x62>
  801a4b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a51:	eb 24                	jmp    801a77 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a53:	85 f6                	test   %esi,%esi
  801a55:	74 0a                	je     801a61 <ipc_recv+0x4c>
  801a57:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5c:	8b 40 74             	mov    0x74(%eax),%eax
  801a5f:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801a61:	85 db                	test   %ebx,%ebx
  801a63:	74 0a                	je     801a6f <ipc_recv+0x5a>
  801a65:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6a:	8b 40 78             	mov    0x78(%eax),%eax
  801a6d:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801a6f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a74:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5e                   	pop    %esi
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	57                   	push   %edi
  801a82:	56                   	push   %esi
  801a83:	53                   	push   %ebx
  801a84:	83 ec 0c             	sub    $0xc,%esp
  801a87:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801a90:	85 db                	test   %ebx,%ebx
  801a92:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a97:	0f 44 d8             	cmove  %eax,%ebx
  801a9a:	eb 1c                	jmp    801ab8 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801a9c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a9f:	74 12                	je     801ab3 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801aa1:	50                   	push   %eax
  801aa2:	68 a0 22 80 00       	push   $0x8022a0
  801aa7:	6a 39                	push   $0x39
  801aa9:	68 bb 22 80 00       	push   $0x8022bb
  801aae:	e8 b5 f5 ff ff       	call   801068 <_panic>
                 sys_yield();
  801ab3:	e8 93 e6 ff ff       	call   80014b <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ab8:	ff 75 14             	pushl  0x14(%ebp)
  801abb:	53                   	push   %ebx
  801abc:	56                   	push   %esi
  801abd:	57                   	push   %edi
  801abe:	e8 34 e8 ff ff       	call   8002f7 <sys_ipc_try_send>
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	78 d2                	js     801a9c <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801aca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acd:	5b                   	pop    %ebx
  801ace:	5e                   	pop    %esi
  801acf:	5f                   	pop    %edi
  801ad0:	5d                   	pop    %ebp
  801ad1:	c3                   	ret    

00801ad2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ad8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801add:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ae0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ae6:	8b 52 50             	mov    0x50(%edx),%edx
  801ae9:	39 ca                	cmp    %ecx,%edx
  801aeb:	75 0d                	jne    801afa <ipc_find_env+0x28>
			return envs[i].env_id;
  801aed:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801af0:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801af5:	8b 40 08             	mov    0x8(%eax),%eax
  801af8:	eb 0e                	jmp    801b08 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801afa:	83 c0 01             	add    $0x1,%eax
  801afd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b02:	75 d9                	jne    801add <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b04:	66 b8 00 00          	mov    $0x0,%ax
}
  801b08:	5d                   	pop    %ebp
  801b09:	c3                   	ret    

00801b0a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b10:	89 d0                	mov    %edx,%eax
  801b12:	c1 e8 16             	shr    $0x16,%eax
  801b15:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b21:	f6 c1 01             	test   $0x1,%cl
  801b24:	74 1d                	je     801b43 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b26:	c1 ea 0c             	shr    $0xc,%edx
  801b29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b30:	f6 c2 01             	test   $0x1,%dl
  801b33:	74 0e                	je     801b43 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b35:	c1 ea 0c             	shr    $0xc,%edx
  801b38:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b3f:	ef 
  801b40:	0f b7 c0             	movzwl %ax,%eax
}
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    
  801b45:	66 90                	xchg   %ax,%ax
  801b47:	66 90                	xchg   %ax,%ax
  801b49:	66 90                	xchg   %ax,%ax
  801b4b:	66 90                	xchg   %ax,%ax
  801b4d:	66 90                	xchg   %ax,%ax
  801b4f:	90                   	nop

00801b50 <__udivdi3>:
  801b50:	55                   	push   %ebp
  801b51:	57                   	push   %edi
  801b52:	56                   	push   %esi
  801b53:	83 ec 10             	sub    $0x10,%esp
  801b56:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b5a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b5e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b66:	85 d2                	test   %edx,%edx
  801b68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b6c:	89 34 24             	mov    %esi,(%esp)
  801b6f:	89 c8                	mov    %ecx,%eax
  801b71:	75 35                	jne    801ba8 <__udivdi3+0x58>
  801b73:	39 f1                	cmp    %esi,%ecx
  801b75:	0f 87 bd 00 00 00    	ja     801c38 <__udivdi3+0xe8>
  801b7b:	85 c9                	test   %ecx,%ecx
  801b7d:	89 cd                	mov    %ecx,%ebp
  801b7f:	75 0b                	jne    801b8c <__udivdi3+0x3c>
  801b81:	b8 01 00 00 00       	mov    $0x1,%eax
  801b86:	31 d2                	xor    %edx,%edx
  801b88:	f7 f1                	div    %ecx
  801b8a:	89 c5                	mov    %eax,%ebp
  801b8c:	89 f0                	mov    %esi,%eax
  801b8e:	31 d2                	xor    %edx,%edx
  801b90:	f7 f5                	div    %ebp
  801b92:	89 c6                	mov    %eax,%esi
  801b94:	89 f8                	mov    %edi,%eax
  801b96:	f7 f5                	div    %ebp
  801b98:	89 f2                	mov    %esi,%edx
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	5e                   	pop    %esi
  801b9e:	5f                   	pop    %edi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    
  801ba1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ba8:	3b 14 24             	cmp    (%esp),%edx
  801bab:	77 7b                	ja     801c28 <__udivdi3+0xd8>
  801bad:	0f bd f2             	bsr    %edx,%esi
  801bb0:	83 f6 1f             	xor    $0x1f,%esi
  801bb3:	0f 84 97 00 00 00    	je     801c50 <__udivdi3+0x100>
  801bb9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801bbe:	89 d7                	mov    %edx,%edi
  801bc0:	89 f1                	mov    %esi,%ecx
  801bc2:	29 f5                	sub    %esi,%ebp
  801bc4:	d3 e7                	shl    %cl,%edi
  801bc6:	89 c2                	mov    %eax,%edx
  801bc8:	89 e9                	mov    %ebp,%ecx
  801bca:	d3 ea                	shr    %cl,%edx
  801bcc:	89 f1                	mov    %esi,%ecx
  801bce:	09 fa                	or     %edi,%edx
  801bd0:	8b 3c 24             	mov    (%esp),%edi
  801bd3:	d3 e0                	shl    %cl,%eax
  801bd5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bd9:	89 e9                	mov    %ebp,%ecx
  801bdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bdf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801be3:	89 fa                	mov    %edi,%edx
  801be5:	d3 ea                	shr    %cl,%edx
  801be7:	89 f1                	mov    %esi,%ecx
  801be9:	d3 e7                	shl    %cl,%edi
  801beb:	89 e9                	mov    %ebp,%ecx
  801bed:	d3 e8                	shr    %cl,%eax
  801bef:	09 c7                	or     %eax,%edi
  801bf1:	89 f8                	mov    %edi,%eax
  801bf3:	f7 74 24 08          	divl   0x8(%esp)
  801bf7:	89 d5                	mov    %edx,%ebp
  801bf9:	89 c7                	mov    %eax,%edi
  801bfb:	f7 64 24 0c          	mull   0xc(%esp)
  801bff:	39 d5                	cmp    %edx,%ebp
  801c01:	89 14 24             	mov    %edx,(%esp)
  801c04:	72 11                	jb     801c17 <__udivdi3+0xc7>
  801c06:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c0a:	89 f1                	mov    %esi,%ecx
  801c0c:	d3 e2                	shl    %cl,%edx
  801c0e:	39 c2                	cmp    %eax,%edx
  801c10:	73 5e                	jae    801c70 <__udivdi3+0x120>
  801c12:	3b 2c 24             	cmp    (%esp),%ebp
  801c15:	75 59                	jne    801c70 <__udivdi3+0x120>
  801c17:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c1a:	31 f6                	xor    %esi,%esi
  801c1c:	89 f2                	mov    %esi,%edx
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    
  801c25:	8d 76 00             	lea    0x0(%esi),%esi
  801c28:	31 f6                	xor    %esi,%esi
  801c2a:	31 c0                	xor    %eax,%eax
  801c2c:	89 f2                	mov    %esi,%edx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    
  801c35:	8d 76 00             	lea    0x0(%esi),%esi
  801c38:	89 f2                	mov    %esi,%edx
  801c3a:	31 f6                	xor    %esi,%esi
  801c3c:	89 f8                	mov    %edi,%eax
  801c3e:	f7 f1                	div    %ecx
  801c40:	89 f2                	mov    %esi,%edx
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	5e                   	pop    %esi
  801c46:	5f                   	pop    %edi
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c54:	76 0b                	jbe    801c61 <__udivdi3+0x111>
  801c56:	31 c0                	xor    %eax,%eax
  801c58:	3b 14 24             	cmp    (%esp),%edx
  801c5b:	0f 83 37 ff ff ff    	jae    801b98 <__udivdi3+0x48>
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	e9 2d ff ff ff       	jmp    801b98 <__udivdi3+0x48>
  801c6b:	90                   	nop
  801c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c70:	89 f8                	mov    %edi,%eax
  801c72:	31 f6                	xor    %esi,%esi
  801c74:	e9 1f ff ff ff       	jmp    801b98 <__udivdi3+0x48>
  801c79:	66 90                	xchg   %ax,%ax
  801c7b:	66 90                	xchg   %ax,%ax
  801c7d:	66 90                	xchg   %ax,%ax
  801c7f:	90                   	nop

00801c80 <__umoddi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	83 ec 20             	sub    $0x20,%esp
  801c86:	8b 44 24 34          	mov    0x34(%esp),%eax
  801c8a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c8e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c92:	89 c6                	mov    %eax,%esi
  801c94:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c98:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c9c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801ca0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ca4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801ca8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801cac:	85 c0                	test   %eax,%eax
  801cae:	89 c2                	mov    %eax,%edx
  801cb0:	75 1e                	jne    801cd0 <__umoddi3+0x50>
  801cb2:	39 f7                	cmp    %esi,%edi
  801cb4:	76 52                	jbe    801d08 <__umoddi3+0x88>
  801cb6:	89 c8                	mov    %ecx,%eax
  801cb8:	89 f2                	mov    %esi,%edx
  801cba:	f7 f7                	div    %edi
  801cbc:	89 d0                	mov    %edx,%eax
  801cbe:	31 d2                	xor    %edx,%edx
  801cc0:	83 c4 20             	add    $0x20,%esp
  801cc3:	5e                   	pop    %esi
  801cc4:	5f                   	pop    %edi
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    
  801cc7:	89 f6                	mov    %esi,%esi
  801cc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801cd0:	39 f0                	cmp    %esi,%eax
  801cd2:	77 5c                	ja     801d30 <__umoddi3+0xb0>
  801cd4:	0f bd e8             	bsr    %eax,%ebp
  801cd7:	83 f5 1f             	xor    $0x1f,%ebp
  801cda:	75 64                	jne    801d40 <__umoddi3+0xc0>
  801cdc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801ce0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801ce4:	0f 86 f6 00 00 00    	jbe    801de0 <__umoddi3+0x160>
  801cea:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cee:	0f 82 ec 00 00 00    	jb     801de0 <__umoddi3+0x160>
  801cf4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801cf8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801cfc:	83 c4 20             	add    $0x20,%esp
  801cff:	5e                   	pop    %esi
  801d00:	5f                   	pop    %edi
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    
  801d03:	90                   	nop
  801d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d08:	85 ff                	test   %edi,%edi
  801d0a:	89 fd                	mov    %edi,%ebp
  801d0c:	75 0b                	jne    801d19 <__umoddi3+0x99>
  801d0e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f7                	div    %edi
  801d17:	89 c5                	mov    %eax,%ebp
  801d19:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d1d:	31 d2                	xor    %edx,%edx
  801d1f:	f7 f5                	div    %ebp
  801d21:	89 c8                	mov    %ecx,%eax
  801d23:	f7 f5                	div    %ebp
  801d25:	eb 95                	jmp    801cbc <__umoddi3+0x3c>
  801d27:	89 f6                	mov    %esi,%esi
  801d29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	83 c4 20             	add    $0x20,%esp
  801d37:	5e                   	pop    %esi
  801d38:	5f                   	pop    %edi
  801d39:	5d                   	pop    %ebp
  801d3a:	c3                   	ret    
  801d3b:	90                   	nop
  801d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d40:	b8 20 00 00 00       	mov    $0x20,%eax
  801d45:	89 e9                	mov    %ebp,%ecx
  801d47:	29 e8                	sub    %ebp,%eax
  801d49:	d3 e2                	shl    %cl,%edx
  801d4b:	89 c7                	mov    %eax,%edi
  801d4d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d51:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d55:	89 f9                	mov    %edi,%ecx
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 c1                	mov    %eax,%ecx
  801d5b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d5f:	09 d1                	or     %edx,%ecx
  801d61:	89 fa                	mov    %edi,%edx
  801d63:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d67:	89 e9                	mov    %ebp,%ecx
  801d69:	d3 e0                	shl    %cl,%eax
  801d6b:	89 f9                	mov    %edi,%ecx
  801d6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	d3 e8                	shr    %cl,%eax
  801d75:	89 e9                	mov    %ebp,%ecx
  801d77:	89 c7                	mov    %eax,%edi
  801d79:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d7d:	d3 e6                	shl    %cl,%esi
  801d7f:	89 d1                	mov    %edx,%ecx
  801d81:	89 fa                	mov    %edi,%edx
  801d83:	d3 e8                	shr    %cl,%eax
  801d85:	89 e9                	mov    %ebp,%ecx
  801d87:	09 f0                	or     %esi,%eax
  801d89:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801d8d:	f7 74 24 10          	divl   0x10(%esp)
  801d91:	d3 e6                	shl    %cl,%esi
  801d93:	89 d1                	mov    %edx,%ecx
  801d95:	f7 64 24 0c          	mull   0xc(%esp)
  801d99:	39 d1                	cmp    %edx,%ecx
  801d9b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801d9f:	89 d7                	mov    %edx,%edi
  801da1:	89 c6                	mov    %eax,%esi
  801da3:	72 0a                	jb     801daf <__umoddi3+0x12f>
  801da5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801da9:	73 10                	jae    801dbb <__umoddi3+0x13b>
  801dab:	39 d1                	cmp    %edx,%ecx
  801dad:	75 0c                	jne    801dbb <__umoddi3+0x13b>
  801daf:	89 d7                	mov    %edx,%edi
  801db1:	89 c6                	mov    %eax,%esi
  801db3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801db7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801dbb:	89 ca                	mov    %ecx,%edx
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801dc3:	29 f0                	sub    %esi,%eax
  801dc5:	19 fa                	sbb    %edi,%edx
  801dc7:	d3 e8                	shr    %cl,%eax
  801dc9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801dce:	89 d7                	mov    %edx,%edi
  801dd0:	d3 e7                	shl    %cl,%edi
  801dd2:	89 e9                	mov    %ebp,%ecx
  801dd4:	09 f8                	or     %edi,%eax
  801dd6:	d3 ea                	shr    %cl,%edx
  801dd8:	83 c4 20             	add    $0x20,%esp
  801ddb:	5e                   	pop    %esi
  801ddc:	5f                   	pop    %edi
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    
  801ddf:	90                   	nop
  801de0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801de4:	29 f9                	sub    %edi,%ecx
  801de6:	19 c6                	sbb    %eax,%esi
  801de8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801dec:	89 74 24 18          	mov    %esi,0x18(%esp)
  801df0:	e9 ff fe ff ff       	jmp    801cf4 <__umoddi3+0x74>
