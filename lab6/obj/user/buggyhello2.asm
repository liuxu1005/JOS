
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
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80009a:	e8 2f 05 00 00       	call   8005ce <close_all>
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
	// return value.
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
	// return value.
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
	// return value.
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
  800113:	68 58 23 80 00       	push   $0x802358
  800118:	6a 22                	push   $0x22
  80011a:	68 75 23 80 00       	push   $0x802375
  80011f:	e8 5b 14 00 00       	call   80157f <_panic>

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
	// return value.
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
	// return value.
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
	// return value.
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
  800194:	68 58 23 80 00       	push   $0x802358
  800199:	6a 22                	push   $0x22
  80019b:	68 75 23 80 00       	push   $0x802375
  8001a0:	e8 da 13 00 00       	call   80157f <_panic>

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
	// return value.
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
  8001d6:	68 58 23 80 00       	push   $0x802358
  8001db:	6a 22                	push   $0x22
  8001dd:	68 75 23 80 00       	push   $0x802375
  8001e2:	e8 98 13 00 00       	call   80157f <_panic>

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
	// return value.
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
  800218:	68 58 23 80 00       	push   $0x802358
  80021d:	6a 22                	push   $0x22
  80021f:	68 75 23 80 00       	push   $0x802375
  800224:	e8 56 13 00 00       	call   80157f <_panic>

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
	// return value.
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
  80025a:	68 58 23 80 00       	push   $0x802358
  80025f:	6a 22                	push   $0x22
  800261:	68 75 23 80 00       	push   $0x802375
  800266:	e8 14 13 00 00       	call   80157f <_panic>
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
	// return value.
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
  80029c:	68 58 23 80 00       	push   $0x802358
  8002a1:	6a 22                	push   $0x22
  8002a3:	68 75 23 80 00       	push   $0x802375
  8002a8:	e8 d2 12 00 00       	call   80157f <_panic>

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
	// return value.
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
  8002de:	68 58 23 80 00       	push   $0x802358
  8002e3:	6a 22                	push   $0x22
  8002e5:	68 75 23 80 00       	push   $0x802375
  8002ea:	e8 90 12 00 00       	call   80157f <_panic>

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
	// return value.
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
	// return value.
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
  800342:	68 58 23 80 00       	push   $0x802358
  800347:	6a 22                	push   $0x22
  800349:	68 75 23 80 00       	push   $0x802375
  80034e:	e8 2c 12 00 00       	call   80157f <_panic>

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

0080035b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	b8 0e 00 00 00       	mov    $0xe,%eax
  80036b:	89 d1                	mov    %edx,%ecx
  80036d:	89 d3                	mov    %edx,%ebx
  80036f:	89 d7                	mov    %edx,%edi
  800371:	89 d6                	mov    %edx,%esi
  800373:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <sys_transmit>:

int
sys_transmit(void *addr)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	56                   	push   %esi
  80037f:	53                   	push   %ebx
  800380:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800383:	b9 00 00 00 00       	mov    $0x0,%ecx
  800388:	b8 0f 00 00 00       	mov    $0xf,%eax
  80038d:	8b 55 08             	mov    0x8(%ebp),%edx
  800390:	89 cb                	mov    %ecx,%ebx
  800392:	89 cf                	mov    %ecx,%edi
  800394:	89 ce                	mov    %ecx,%esi
  800396:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800398:	85 c0                	test   %eax,%eax
  80039a:	7e 17                	jle    8003b3 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	50                   	push   %eax
  8003a0:	6a 0f                	push   $0xf
  8003a2:	68 58 23 80 00       	push   $0x802358
  8003a7:	6a 22                	push   $0x22
  8003a9:	68 75 23 80 00       	push   $0x802375
  8003ae:	e8 cc 11 00 00       	call   80157f <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b6:	5b                   	pop    %ebx
  8003b7:	5e                   	pop    %esi
  8003b8:	5f                   	pop    %edi
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <sys_recv>:

int
sys_recv(void *addr)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	57                   	push   %edi
  8003bf:	56                   	push   %esi
  8003c0:	53                   	push   %ebx
  8003c1:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8003c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c9:	b8 10 00 00 00       	mov    $0x10,%eax
  8003ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d1:	89 cb                	mov    %ecx,%ebx
  8003d3:	89 cf                	mov    %ecx,%edi
  8003d5:	89 ce                	mov    %ecx,%esi
  8003d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003d9:	85 c0                	test   %eax,%eax
  8003db:	7e 17                	jle    8003f4 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003dd:	83 ec 0c             	sub    $0xc,%esp
  8003e0:	50                   	push   %eax
  8003e1:	6a 10                	push   $0x10
  8003e3:	68 58 23 80 00       	push   $0x802358
  8003e8:	6a 22                	push   $0x22
  8003ea:	68 75 23 80 00       	push   $0x802375
  8003ef:	e8 8b 11 00 00       	call   80157f <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f7:	5b                   	pop    %ebx
  8003f8:	5e                   	pop    %esi
  8003f9:	5f                   	pop    %edi
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	05 00 00 00 30       	add    $0x30000000,%eax
  800407:	c1 e8 0c             	shr    $0xc,%eax
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80040f:	8b 45 08             	mov    0x8(%ebp),%eax
  800412:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800417:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80041c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80042e:	89 c2                	mov    %eax,%edx
  800430:	c1 ea 16             	shr    $0x16,%edx
  800433:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80043a:	f6 c2 01             	test   $0x1,%dl
  80043d:	74 11                	je     800450 <fd_alloc+0x2d>
  80043f:	89 c2                	mov    %eax,%edx
  800441:	c1 ea 0c             	shr    $0xc,%edx
  800444:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044b:	f6 c2 01             	test   $0x1,%dl
  80044e:	75 09                	jne    800459 <fd_alloc+0x36>
			*fd_store = fd;
  800450:	89 01                	mov    %eax,(%ecx)
			return 0;
  800452:	b8 00 00 00 00       	mov    $0x0,%eax
  800457:	eb 17                	jmp    800470 <fd_alloc+0x4d>
  800459:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80045e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800463:	75 c9                	jne    80042e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800465:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80046b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800470:	5d                   	pop    %ebp
  800471:	c3                   	ret    

00800472 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
  800475:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800478:	83 f8 1f             	cmp    $0x1f,%eax
  80047b:	77 36                	ja     8004b3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80047d:	c1 e0 0c             	shl    $0xc,%eax
  800480:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800485:	89 c2                	mov    %eax,%edx
  800487:	c1 ea 16             	shr    $0x16,%edx
  80048a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800491:	f6 c2 01             	test   $0x1,%dl
  800494:	74 24                	je     8004ba <fd_lookup+0x48>
  800496:	89 c2                	mov    %eax,%edx
  800498:	c1 ea 0c             	shr    $0xc,%edx
  80049b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004a2:	f6 c2 01             	test   $0x1,%dl
  8004a5:	74 1a                	je     8004c1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004aa:	89 02                	mov    %eax,(%edx)
	return 0;
  8004ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b1:	eb 13                	jmp    8004c6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b8:	eb 0c                	jmp    8004c6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004bf:	eb 05                	jmp    8004c6 <fd_lookup+0x54>
  8004c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004c6:	5d                   	pop    %ebp
  8004c7:	c3                   	ret    

008004c8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	eb 13                	jmp    8004eb <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8004d8:	39 08                	cmp    %ecx,(%eax)
  8004da:	75 0c                	jne    8004e8 <dev_lookup+0x20>
			*dev = devtab[i];
  8004dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004df:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e6:	eb 36                	jmp    80051e <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004e8:	83 c2 01             	add    $0x1,%edx
  8004eb:	8b 04 95 00 24 80 00 	mov    0x802400(,%edx,4),%eax
  8004f2:	85 c0                	test   %eax,%eax
  8004f4:	75 e2                	jne    8004d8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8004fb:	8b 40 48             	mov    0x48(%eax),%eax
  8004fe:	83 ec 04             	sub    $0x4,%esp
  800501:	51                   	push   %ecx
  800502:	50                   	push   %eax
  800503:	68 84 23 80 00       	push   $0x802384
  800508:	e8 4b 11 00 00       	call   801658 <cprintf>
	*dev = 0;
  80050d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800510:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80051e:	c9                   	leave  
  80051f:	c3                   	ret    

00800520 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	56                   	push   %esi
  800524:	53                   	push   %ebx
  800525:	83 ec 10             	sub    $0x10,%esp
  800528:	8b 75 08             	mov    0x8(%ebp),%esi
  80052b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80052e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800531:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800532:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800538:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80053b:	50                   	push   %eax
  80053c:	e8 31 ff ff ff       	call   800472 <fd_lookup>
  800541:	83 c4 08             	add    $0x8,%esp
  800544:	85 c0                	test   %eax,%eax
  800546:	78 05                	js     80054d <fd_close+0x2d>
	    || fd != fd2)
  800548:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80054b:	74 0c                	je     800559 <fd_close+0x39>
		return (must_exist ? r : 0);
  80054d:	84 db                	test   %bl,%bl
  80054f:	ba 00 00 00 00       	mov    $0x0,%edx
  800554:	0f 44 c2             	cmove  %edx,%eax
  800557:	eb 41                	jmp    80059a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80055f:	50                   	push   %eax
  800560:	ff 36                	pushl  (%esi)
  800562:	e8 61 ff ff ff       	call   8004c8 <dev_lookup>
  800567:	89 c3                	mov    %eax,%ebx
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	85 c0                	test   %eax,%eax
  80056e:	78 1a                	js     80058a <fd_close+0x6a>
		if (dev->dev_close)
  800570:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800573:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80057b:	85 c0                	test   %eax,%eax
  80057d:	74 0b                	je     80058a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80057f:	83 ec 0c             	sub    $0xc,%esp
  800582:	56                   	push   %esi
  800583:	ff d0                	call   *%eax
  800585:	89 c3                	mov    %eax,%ebx
  800587:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80058a:	83 ec 08             	sub    $0x8,%esp
  80058d:	56                   	push   %esi
  80058e:	6a 00                	push   $0x0
  800590:	e8 5a fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  800595:	83 c4 10             	add    $0x10,%esp
  800598:	89 d8                	mov    %ebx,%eax
}
  80059a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80059d:	5b                   	pop    %ebx
  80059e:	5e                   	pop    %esi
  80059f:	5d                   	pop    %ebp
  8005a0:	c3                   	ret    

008005a1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005a1:	55                   	push   %ebp
  8005a2:	89 e5                	mov    %esp,%ebp
  8005a4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005aa:	50                   	push   %eax
  8005ab:	ff 75 08             	pushl  0x8(%ebp)
  8005ae:	e8 bf fe ff ff       	call   800472 <fd_lookup>
  8005b3:	89 c2                	mov    %eax,%edx
  8005b5:	83 c4 08             	add    $0x8,%esp
  8005b8:	85 d2                	test   %edx,%edx
  8005ba:	78 10                	js     8005cc <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8005bc:	83 ec 08             	sub    $0x8,%esp
  8005bf:	6a 01                	push   $0x1
  8005c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8005c4:	e8 57 ff ff ff       	call   800520 <fd_close>
  8005c9:	83 c4 10             	add    $0x10,%esp
}
  8005cc:	c9                   	leave  
  8005cd:	c3                   	ret    

008005ce <close_all>:

void
close_all(void)
{
  8005ce:	55                   	push   %ebp
  8005cf:	89 e5                	mov    %esp,%ebp
  8005d1:	53                   	push   %ebx
  8005d2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005d5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005da:	83 ec 0c             	sub    $0xc,%esp
  8005dd:	53                   	push   %ebx
  8005de:	e8 be ff ff ff       	call   8005a1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005e3:	83 c3 01             	add    $0x1,%ebx
  8005e6:	83 c4 10             	add    $0x10,%esp
  8005e9:	83 fb 20             	cmp    $0x20,%ebx
  8005ec:	75 ec                	jne    8005da <close_all+0xc>
		close(i);
}
  8005ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005f1:	c9                   	leave  
  8005f2:	c3                   	ret    

008005f3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005f3:	55                   	push   %ebp
  8005f4:	89 e5                	mov    %esp,%ebp
  8005f6:	57                   	push   %edi
  8005f7:	56                   	push   %esi
  8005f8:	53                   	push   %ebx
  8005f9:	83 ec 2c             	sub    $0x2c,%esp
  8005fc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800602:	50                   	push   %eax
  800603:	ff 75 08             	pushl  0x8(%ebp)
  800606:	e8 67 fe ff ff       	call   800472 <fd_lookup>
  80060b:	89 c2                	mov    %eax,%edx
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	85 d2                	test   %edx,%edx
  800612:	0f 88 c1 00 00 00    	js     8006d9 <dup+0xe6>
		return r;
	close(newfdnum);
  800618:	83 ec 0c             	sub    $0xc,%esp
  80061b:	56                   	push   %esi
  80061c:	e8 80 ff ff ff       	call   8005a1 <close>

	newfd = INDEX2FD(newfdnum);
  800621:	89 f3                	mov    %esi,%ebx
  800623:	c1 e3 0c             	shl    $0xc,%ebx
  800626:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80062c:	83 c4 04             	add    $0x4,%esp
  80062f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800632:	e8 d5 fd ff ff       	call   80040c <fd2data>
  800637:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800639:	89 1c 24             	mov    %ebx,(%esp)
  80063c:	e8 cb fd ff ff       	call   80040c <fd2data>
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800647:	89 f8                	mov    %edi,%eax
  800649:	c1 e8 16             	shr    $0x16,%eax
  80064c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800653:	a8 01                	test   $0x1,%al
  800655:	74 37                	je     80068e <dup+0x9b>
  800657:	89 f8                	mov    %edi,%eax
  800659:	c1 e8 0c             	shr    $0xc,%eax
  80065c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800663:	f6 c2 01             	test   $0x1,%dl
  800666:	74 26                	je     80068e <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800668:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80066f:	83 ec 0c             	sub    $0xc,%esp
  800672:	25 07 0e 00 00       	and    $0xe07,%eax
  800677:	50                   	push   %eax
  800678:	ff 75 d4             	pushl  -0x2c(%ebp)
  80067b:	6a 00                	push   $0x0
  80067d:	57                   	push   %edi
  80067e:	6a 00                	push   $0x0
  800680:	e8 28 fb ff ff       	call   8001ad <sys_page_map>
  800685:	89 c7                	mov    %eax,%edi
  800687:	83 c4 20             	add    $0x20,%esp
  80068a:	85 c0                	test   %eax,%eax
  80068c:	78 2e                	js     8006bc <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80068e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800691:	89 d0                	mov    %edx,%eax
  800693:	c1 e8 0c             	shr    $0xc,%eax
  800696:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80069d:	83 ec 0c             	sub    $0xc,%esp
  8006a0:	25 07 0e 00 00       	and    $0xe07,%eax
  8006a5:	50                   	push   %eax
  8006a6:	53                   	push   %ebx
  8006a7:	6a 00                	push   $0x0
  8006a9:	52                   	push   %edx
  8006aa:	6a 00                	push   $0x0
  8006ac:	e8 fc fa ff ff       	call   8001ad <sys_page_map>
  8006b1:	89 c7                	mov    %eax,%edi
  8006b3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006b6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006b8:	85 ff                	test   %edi,%edi
  8006ba:	79 1d                	jns    8006d9 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	6a 00                	push   $0x0
  8006c2:	e8 28 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006c7:	83 c4 08             	add    $0x8,%esp
  8006ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006cd:	6a 00                	push   $0x0
  8006cf:	e8 1b fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	89 f8                	mov    %edi,%eax
}
  8006d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006dc:	5b                   	pop    %ebx
  8006dd:	5e                   	pop    %esi
  8006de:	5f                   	pop    %edi
  8006df:	5d                   	pop    %ebp
  8006e0:	c3                   	ret    

008006e1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	53                   	push   %ebx
  8006e5:	83 ec 14             	sub    $0x14,%esp
  8006e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006ee:	50                   	push   %eax
  8006ef:	53                   	push   %ebx
  8006f0:	e8 7d fd ff ff       	call   800472 <fd_lookup>
  8006f5:	83 c4 08             	add    $0x8,%esp
  8006f8:	89 c2                	mov    %eax,%edx
  8006fa:	85 c0                	test   %eax,%eax
  8006fc:	78 6d                	js     80076b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800704:	50                   	push   %eax
  800705:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800708:	ff 30                	pushl  (%eax)
  80070a:	e8 b9 fd ff ff       	call   8004c8 <dev_lookup>
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	85 c0                	test   %eax,%eax
  800714:	78 4c                	js     800762 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800716:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800719:	8b 42 08             	mov    0x8(%edx),%eax
  80071c:	83 e0 03             	and    $0x3,%eax
  80071f:	83 f8 01             	cmp    $0x1,%eax
  800722:	75 21                	jne    800745 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800724:	a1 08 40 80 00       	mov    0x804008,%eax
  800729:	8b 40 48             	mov    0x48(%eax),%eax
  80072c:	83 ec 04             	sub    $0x4,%esp
  80072f:	53                   	push   %ebx
  800730:	50                   	push   %eax
  800731:	68 c5 23 80 00       	push   $0x8023c5
  800736:	e8 1d 0f 00 00       	call   801658 <cprintf>
		return -E_INVAL;
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800743:	eb 26                	jmp    80076b <read+0x8a>
	}
	if (!dev->dev_read)
  800745:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800748:	8b 40 08             	mov    0x8(%eax),%eax
  80074b:	85 c0                	test   %eax,%eax
  80074d:	74 17                	je     800766 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80074f:	83 ec 04             	sub    $0x4,%esp
  800752:	ff 75 10             	pushl  0x10(%ebp)
  800755:	ff 75 0c             	pushl  0xc(%ebp)
  800758:	52                   	push   %edx
  800759:	ff d0                	call   *%eax
  80075b:	89 c2                	mov    %eax,%edx
  80075d:	83 c4 10             	add    $0x10,%esp
  800760:	eb 09                	jmp    80076b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800762:	89 c2                	mov    %eax,%edx
  800764:	eb 05                	jmp    80076b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800766:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80076b:	89 d0                	mov    %edx,%eax
  80076d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	57                   	push   %edi
  800776:	56                   	push   %esi
  800777:	53                   	push   %ebx
  800778:	83 ec 0c             	sub    $0xc,%esp
  80077b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80077e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800781:	bb 00 00 00 00       	mov    $0x0,%ebx
  800786:	eb 21                	jmp    8007a9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800788:	83 ec 04             	sub    $0x4,%esp
  80078b:	89 f0                	mov    %esi,%eax
  80078d:	29 d8                	sub    %ebx,%eax
  80078f:	50                   	push   %eax
  800790:	89 d8                	mov    %ebx,%eax
  800792:	03 45 0c             	add    0xc(%ebp),%eax
  800795:	50                   	push   %eax
  800796:	57                   	push   %edi
  800797:	e8 45 ff ff ff       	call   8006e1 <read>
		if (m < 0)
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	85 c0                	test   %eax,%eax
  8007a1:	78 0c                	js     8007af <readn+0x3d>
			return m;
		if (m == 0)
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	74 06                	je     8007ad <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007a7:	01 c3                	add    %eax,%ebx
  8007a9:	39 f3                	cmp    %esi,%ebx
  8007ab:	72 db                	jb     800788 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8007ad:	89 d8                	mov    %ebx,%eax
}
  8007af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b2:	5b                   	pop    %ebx
  8007b3:	5e                   	pop    %esi
  8007b4:	5f                   	pop    %edi
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	83 ec 14             	sub    $0x14,%esp
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c4:	50                   	push   %eax
  8007c5:	53                   	push   %ebx
  8007c6:	e8 a7 fc ff ff       	call   800472 <fd_lookup>
  8007cb:	83 c4 08             	add    $0x8,%esp
  8007ce:	89 c2                	mov    %eax,%edx
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	78 68                	js     80083c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d4:	83 ec 08             	sub    $0x8,%esp
  8007d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007da:	50                   	push   %eax
  8007db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007de:	ff 30                	pushl  (%eax)
  8007e0:	e8 e3 fc ff ff       	call   8004c8 <dev_lookup>
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	78 47                	js     800833 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ef:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f3:	75 21                	jne    800816 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007f5:	a1 08 40 80 00       	mov    0x804008,%eax
  8007fa:	8b 40 48             	mov    0x48(%eax),%eax
  8007fd:	83 ec 04             	sub    $0x4,%esp
  800800:	53                   	push   %ebx
  800801:	50                   	push   %eax
  800802:	68 e1 23 80 00       	push   $0x8023e1
  800807:	e8 4c 0e 00 00       	call   801658 <cprintf>
		return -E_INVAL;
  80080c:	83 c4 10             	add    $0x10,%esp
  80080f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800814:	eb 26                	jmp    80083c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800816:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800819:	8b 52 0c             	mov    0xc(%edx),%edx
  80081c:	85 d2                	test   %edx,%edx
  80081e:	74 17                	je     800837 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800820:	83 ec 04             	sub    $0x4,%esp
  800823:	ff 75 10             	pushl  0x10(%ebp)
  800826:	ff 75 0c             	pushl  0xc(%ebp)
  800829:	50                   	push   %eax
  80082a:	ff d2                	call   *%edx
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb 09                	jmp    80083c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800833:	89 c2                	mov    %eax,%edx
  800835:	eb 05                	jmp    80083c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800837:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80083c:	89 d0                	mov    %edx,%eax
  80083e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <seek>:

int
seek(int fdnum, off_t offset)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800849:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80084c:	50                   	push   %eax
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 1d fc ff ff       	call   800472 <fd_lookup>
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	85 c0                	test   %eax,%eax
  80085a:	78 0e                	js     80086a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80085c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80085f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800862:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800865:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086a:	c9                   	leave  
  80086b:	c3                   	ret    

0080086c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	53                   	push   %ebx
  800870:	83 ec 14             	sub    $0x14,%esp
  800873:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800876:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800879:	50                   	push   %eax
  80087a:	53                   	push   %ebx
  80087b:	e8 f2 fb ff ff       	call   800472 <fd_lookup>
  800880:	83 c4 08             	add    $0x8,%esp
  800883:	89 c2                	mov    %eax,%edx
  800885:	85 c0                	test   %eax,%eax
  800887:	78 65                	js     8008ee <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088f:	50                   	push   %eax
  800890:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800893:	ff 30                	pushl  (%eax)
  800895:	e8 2e fc ff ff       	call   8004c8 <dev_lookup>
  80089a:	83 c4 10             	add    $0x10,%esp
  80089d:	85 c0                	test   %eax,%eax
  80089f:	78 44                	js     8008e5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008a8:	75 21                	jne    8008cb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008aa:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008af:	8b 40 48             	mov    0x48(%eax),%eax
  8008b2:	83 ec 04             	sub    $0x4,%esp
  8008b5:	53                   	push   %ebx
  8008b6:	50                   	push   %eax
  8008b7:	68 a4 23 80 00       	push   $0x8023a4
  8008bc:	e8 97 0d 00 00       	call   801658 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008c1:	83 c4 10             	add    $0x10,%esp
  8008c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008c9:	eb 23                	jmp    8008ee <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008ce:	8b 52 18             	mov    0x18(%edx),%edx
  8008d1:	85 d2                	test   %edx,%edx
  8008d3:	74 14                	je     8008e9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	ff 75 0c             	pushl  0xc(%ebp)
  8008db:	50                   	push   %eax
  8008dc:	ff d2                	call   *%edx
  8008de:	89 c2                	mov    %eax,%edx
  8008e0:	83 c4 10             	add    $0x10,%esp
  8008e3:	eb 09                	jmp    8008ee <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e5:	89 c2                	mov    %eax,%edx
  8008e7:	eb 05                	jmp    8008ee <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008ee:	89 d0                	mov    %edx,%eax
  8008f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	53                   	push   %ebx
  8008f9:	83 ec 14             	sub    $0x14,%esp
  8008fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800902:	50                   	push   %eax
  800903:	ff 75 08             	pushl  0x8(%ebp)
  800906:	e8 67 fb ff ff       	call   800472 <fd_lookup>
  80090b:	83 c4 08             	add    $0x8,%esp
  80090e:	89 c2                	mov    %eax,%edx
  800910:	85 c0                	test   %eax,%eax
  800912:	78 58                	js     80096c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800914:	83 ec 08             	sub    $0x8,%esp
  800917:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80091a:	50                   	push   %eax
  80091b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80091e:	ff 30                	pushl  (%eax)
  800920:	e8 a3 fb ff ff       	call   8004c8 <dev_lookup>
  800925:	83 c4 10             	add    $0x10,%esp
  800928:	85 c0                	test   %eax,%eax
  80092a:	78 37                	js     800963 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80092c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80092f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800933:	74 32                	je     800967 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800935:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800938:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80093f:	00 00 00 
	stat->st_isdir = 0;
  800942:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800949:	00 00 00 
	stat->st_dev = dev;
  80094c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800952:	83 ec 08             	sub    $0x8,%esp
  800955:	53                   	push   %ebx
  800956:	ff 75 f0             	pushl  -0x10(%ebp)
  800959:	ff 50 14             	call   *0x14(%eax)
  80095c:	89 c2                	mov    %eax,%edx
  80095e:	83 c4 10             	add    $0x10,%esp
  800961:	eb 09                	jmp    80096c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800963:	89 c2                	mov    %eax,%edx
  800965:	eb 05                	jmp    80096c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800967:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80096c:	89 d0                	mov    %edx,%eax
  80096e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	56                   	push   %esi
  800977:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800978:	83 ec 08             	sub    $0x8,%esp
  80097b:	6a 00                	push   $0x0
  80097d:	ff 75 08             	pushl  0x8(%ebp)
  800980:	e8 09 02 00 00       	call   800b8e <open>
  800985:	89 c3                	mov    %eax,%ebx
  800987:	83 c4 10             	add    $0x10,%esp
  80098a:	85 db                	test   %ebx,%ebx
  80098c:	78 1b                	js     8009a9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80098e:	83 ec 08             	sub    $0x8,%esp
  800991:	ff 75 0c             	pushl  0xc(%ebp)
  800994:	53                   	push   %ebx
  800995:	e8 5b ff ff ff       	call   8008f5 <fstat>
  80099a:	89 c6                	mov    %eax,%esi
	close(fd);
  80099c:	89 1c 24             	mov    %ebx,(%esp)
  80099f:	e8 fd fb ff ff       	call   8005a1 <close>
	return r;
  8009a4:	83 c4 10             	add    $0x10,%esp
  8009a7:	89 f0                	mov    %esi,%eax
}
  8009a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009ac:	5b                   	pop    %ebx
  8009ad:	5e                   	pop    %esi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	89 c6                	mov    %eax,%esi
  8009b7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009b9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009c0:	75 12                	jne    8009d4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009c2:	83 ec 0c             	sub    $0xc,%esp
  8009c5:	6a 01                	push   $0x1
  8009c7:	e8 1d 16 00 00       	call   801fe9 <ipc_find_env>
  8009cc:	a3 00 40 80 00       	mov    %eax,0x804000
  8009d1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009d4:	6a 07                	push   $0x7
  8009d6:	68 00 50 80 00       	push   $0x805000
  8009db:	56                   	push   %esi
  8009dc:	ff 35 00 40 80 00    	pushl  0x804000
  8009e2:	e8 ae 15 00 00       	call   801f95 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009e7:	83 c4 0c             	add    $0xc,%esp
  8009ea:	6a 00                	push   $0x0
  8009ec:	53                   	push   %ebx
  8009ed:	6a 00                	push   $0x0
  8009ef:	e8 38 15 00 00       	call   801f2c <ipc_recv>
}
  8009f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	8b 40 0c             	mov    0xc(%eax),%eax
  800a07:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a14:	ba 00 00 00 00       	mov    $0x0,%edx
  800a19:	b8 02 00 00 00       	mov    $0x2,%eax
  800a1e:	e8 8d ff ff ff       	call   8009b0 <fsipc>
}
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    

00800a25 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a31:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a36:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3b:	b8 06 00 00 00       	mov    $0x6,%eax
  800a40:	e8 6b ff ff ff       	call   8009b0 <fsipc>
}
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    

00800a47 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	53                   	push   %ebx
  800a4b:	83 ec 04             	sub    $0x4,%esp
  800a4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	8b 40 0c             	mov    0xc(%eax),%eax
  800a57:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a61:	b8 05 00 00 00       	mov    $0x5,%eax
  800a66:	e8 45 ff ff ff       	call   8009b0 <fsipc>
  800a6b:	89 c2                	mov    %eax,%edx
  800a6d:	85 d2                	test   %edx,%edx
  800a6f:	78 2c                	js     800a9d <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a71:	83 ec 08             	sub    $0x8,%esp
  800a74:	68 00 50 80 00       	push   $0x805000
  800a79:	53                   	push   %ebx
  800a7a:	e8 60 11 00 00       	call   801bdf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a7f:	a1 80 50 80 00       	mov    0x805080,%eax
  800a84:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a8a:	a1 84 50 80 00       	mov    0x805084,%eax
  800a8f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a95:	83 c4 10             	add    $0x10,%esp
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    

00800aa2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	83 ec 0c             	sub    $0xc,%esp
  800aab:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab4:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800ab9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800abc:	eb 3d                	jmp    800afb <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800abe:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800ac4:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800ac9:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800acc:	83 ec 04             	sub    $0x4,%esp
  800acf:	57                   	push   %edi
  800ad0:	53                   	push   %ebx
  800ad1:	68 08 50 80 00       	push   $0x805008
  800ad6:	e8 96 12 00 00       	call   801d71 <memmove>
                fsipcbuf.write.req_n = tmp; 
  800adb:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae6:	b8 04 00 00 00       	mov    $0x4,%eax
  800aeb:	e8 c0 fe ff ff       	call   8009b0 <fsipc>
  800af0:	83 c4 10             	add    $0x10,%esp
  800af3:	85 c0                	test   %eax,%eax
  800af5:	78 0d                	js     800b04 <devfile_write+0x62>
		        return r;
                n -= tmp;
  800af7:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800af9:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800afb:	85 f6                	test   %esi,%esi
  800afd:	75 bf                	jne    800abe <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800aff:	89 d8                	mov    %ebx,%eax
  800b01:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800b04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 40 0c             	mov    0xc(%eax),%eax
  800b1a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b1f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2f:	e8 7c fe ff ff       	call   8009b0 <fsipc>
  800b34:	89 c3                	mov    %eax,%ebx
  800b36:	85 c0                	test   %eax,%eax
  800b38:	78 4b                	js     800b85 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b3a:	39 c6                	cmp    %eax,%esi
  800b3c:	73 16                	jae    800b54 <devfile_read+0x48>
  800b3e:	68 14 24 80 00       	push   $0x802414
  800b43:	68 1b 24 80 00       	push   $0x80241b
  800b48:	6a 7c                	push   $0x7c
  800b4a:	68 30 24 80 00       	push   $0x802430
  800b4f:	e8 2b 0a 00 00       	call   80157f <_panic>
	assert(r <= PGSIZE);
  800b54:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b59:	7e 16                	jle    800b71 <devfile_read+0x65>
  800b5b:	68 3b 24 80 00       	push   $0x80243b
  800b60:	68 1b 24 80 00       	push   $0x80241b
  800b65:	6a 7d                	push   $0x7d
  800b67:	68 30 24 80 00       	push   $0x802430
  800b6c:	e8 0e 0a 00 00       	call   80157f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b71:	83 ec 04             	sub    $0x4,%esp
  800b74:	50                   	push   %eax
  800b75:	68 00 50 80 00       	push   $0x805000
  800b7a:	ff 75 0c             	pushl  0xc(%ebp)
  800b7d:	e8 ef 11 00 00       	call   801d71 <memmove>
	return r;
  800b82:	83 c4 10             	add    $0x10,%esp
}
  800b85:	89 d8                	mov    %ebx,%eax
  800b87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	53                   	push   %ebx
  800b92:	83 ec 20             	sub    $0x20,%esp
  800b95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b98:	53                   	push   %ebx
  800b99:	e8 08 10 00 00       	call   801ba6 <strlen>
  800b9e:	83 c4 10             	add    $0x10,%esp
  800ba1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ba6:	7f 67                	jg     800c0f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ba8:	83 ec 0c             	sub    $0xc,%esp
  800bab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bae:	50                   	push   %eax
  800baf:	e8 6f f8 ff ff       	call   800423 <fd_alloc>
  800bb4:	83 c4 10             	add    $0x10,%esp
		return r;
  800bb7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	78 57                	js     800c14 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bbd:	83 ec 08             	sub    $0x8,%esp
  800bc0:	53                   	push   %ebx
  800bc1:	68 00 50 80 00       	push   $0x805000
  800bc6:	e8 14 10 00 00       	call   801bdf <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bce:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bdb:	e8 d0 fd ff ff       	call   8009b0 <fsipc>
  800be0:	89 c3                	mov    %eax,%ebx
  800be2:	83 c4 10             	add    $0x10,%esp
  800be5:	85 c0                	test   %eax,%eax
  800be7:	79 14                	jns    800bfd <open+0x6f>
		fd_close(fd, 0);
  800be9:	83 ec 08             	sub    $0x8,%esp
  800bec:	6a 00                	push   $0x0
  800bee:	ff 75 f4             	pushl  -0xc(%ebp)
  800bf1:	e8 2a f9 ff ff       	call   800520 <fd_close>
		return r;
  800bf6:	83 c4 10             	add    $0x10,%esp
  800bf9:	89 da                	mov    %ebx,%edx
  800bfb:	eb 17                	jmp    800c14 <open+0x86>
	}

	return fd2num(fd);
  800bfd:	83 ec 0c             	sub    $0xc,%esp
  800c00:	ff 75 f4             	pushl  -0xc(%ebp)
  800c03:	e8 f4 f7 ff ff       	call   8003fc <fd2num>
  800c08:	89 c2                	mov    %eax,%edx
  800c0a:	83 c4 10             	add    $0x10,%esp
  800c0d:	eb 05                	jmp    800c14 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c0f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c14:	89 d0                	mov    %edx,%eax
  800c16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c19:	c9                   	leave  
  800c1a:	c3                   	ret    

00800c1b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c21:	ba 00 00 00 00       	mov    $0x0,%edx
  800c26:	b8 08 00 00 00       	mov    $0x8,%eax
  800c2b:	e8 80 fd ff ff       	call   8009b0 <fsipc>
}
  800c30:	c9                   	leave  
  800c31:	c3                   	ret    

00800c32 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c38:	68 47 24 80 00       	push   $0x802447
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	e8 9a 0f 00 00       	call   801bdf <strcpy>
	return 0;
}
  800c45:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4a:	c9                   	leave  
  800c4b:	c3                   	ret    

00800c4c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 10             	sub    $0x10,%esp
  800c53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c56:	53                   	push   %ebx
  800c57:	e8 c5 13 00 00       	call   802021 <pageref>
  800c5c:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c5f:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c64:	83 f8 01             	cmp    $0x1,%eax
  800c67:	75 10                	jne    800c79 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	ff 73 0c             	pushl  0xc(%ebx)
  800c6f:	e8 ca 02 00 00       	call   800f3e <nsipc_close>
  800c74:	89 c2                	mov    %eax,%edx
  800c76:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c79:	89 d0                	mov    %edx,%eax
  800c7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c7e:	c9                   	leave  
  800c7f:	c3                   	ret    

00800c80 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c86:	6a 00                	push   $0x0
  800c88:	ff 75 10             	pushl  0x10(%ebp)
  800c8b:	ff 75 0c             	pushl  0xc(%ebp)
  800c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c91:	ff 70 0c             	pushl  0xc(%eax)
  800c94:	e8 82 03 00 00       	call   80101b <nsipc_send>
}
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800ca1:	6a 00                	push   $0x0
  800ca3:	ff 75 10             	pushl  0x10(%ebp)
  800ca6:	ff 75 0c             	pushl  0xc(%ebp)
  800ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cac:	ff 70 0c             	pushl  0xc(%eax)
  800caf:	e8 fb 02 00 00       	call   800faf <nsipc_recv>
}
  800cb4:	c9                   	leave  
  800cb5:	c3                   	ret    

00800cb6 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800cbc:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800cbf:	52                   	push   %edx
  800cc0:	50                   	push   %eax
  800cc1:	e8 ac f7 ff ff       	call   800472 <fd_lookup>
  800cc6:	83 c4 10             	add    $0x10,%esp
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	78 17                	js     800ce4 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd0:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  800cd6:	39 08                	cmp    %ecx,(%eax)
  800cd8:	75 05                	jne    800cdf <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800cda:	8b 40 0c             	mov    0xc(%eax),%eax
  800cdd:	eb 05                	jmp    800ce4 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800cdf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800ce4:	c9                   	leave  
  800ce5:	c3                   	ret    

00800ce6 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 1c             	sub    $0x1c,%esp
  800cee:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800cf0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cf3:	50                   	push   %eax
  800cf4:	e8 2a f7 ff ff       	call   800423 <fd_alloc>
  800cf9:	89 c3                	mov    %eax,%ebx
  800cfb:	83 c4 10             	add    $0x10,%esp
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	78 1b                	js     800d1d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800d02:	83 ec 04             	sub    $0x4,%esp
  800d05:	68 07 04 00 00       	push   $0x407
  800d0a:	ff 75 f4             	pushl  -0xc(%ebp)
  800d0d:	6a 00                	push   $0x0
  800d0f:	e8 56 f4 ff ff       	call   80016a <sys_page_alloc>
  800d14:	89 c3                	mov    %eax,%ebx
  800d16:	83 c4 10             	add    $0x10,%esp
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	79 10                	jns    800d2d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	56                   	push   %esi
  800d21:	e8 18 02 00 00       	call   800f3e <nsipc_close>
		return r;
  800d26:	83 c4 10             	add    $0x10,%esp
  800d29:	89 d8                	mov    %ebx,%eax
  800d2b:	eb 24                	jmp    800d51 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d2d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d36:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d3b:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  800d42:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	52                   	push   %edx
  800d49:	e8 ae f6 ff ff       	call   8003fc <fd2num>
  800d4e:	83 c4 10             	add    $0x10,%esp
}
  800d51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d61:	e8 50 ff ff ff       	call   800cb6 <fd2sockid>
		return r;
  800d66:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	78 1f                	js     800d8b <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d6c:	83 ec 04             	sub    $0x4,%esp
  800d6f:	ff 75 10             	pushl  0x10(%ebp)
  800d72:	ff 75 0c             	pushl  0xc(%ebp)
  800d75:	50                   	push   %eax
  800d76:	e8 1c 01 00 00       	call   800e97 <nsipc_accept>
  800d7b:	83 c4 10             	add    $0x10,%esp
		return r;
  800d7e:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d80:	85 c0                	test   %eax,%eax
  800d82:	78 07                	js     800d8b <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d84:	e8 5d ff ff ff       	call   800ce6 <alloc_sockfd>
  800d89:	89 c1                	mov    %eax,%ecx
}
  800d8b:	89 c8                	mov    %ecx,%eax
  800d8d:	c9                   	leave  
  800d8e:	c3                   	ret    

00800d8f <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d95:	8b 45 08             	mov    0x8(%ebp),%eax
  800d98:	e8 19 ff ff ff       	call   800cb6 <fd2sockid>
  800d9d:	89 c2                	mov    %eax,%edx
  800d9f:	85 d2                	test   %edx,%edx
  800da1:	78 12                	js     800db5 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  800da3:	83 ec 04             	sub    $0x4,%esp
  800da6:	ff 75 10             	pushl  0x10(%ebp)
  800da9:	ff 75 0c             	pushl  0xc(%ebp)
  800dac:	52                   	push   %edx
  800dad:	e8 35 01 00 00       	call   800ee7 <nsipc_bind>
  800db2:	83 c4 10             	add    $0x10,%esp
}
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <shutdown>:

int
shutdown(int s, int how)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc0:	e8 f1 fe ff ff       	call   800cb6 <fd2sockid>
  800dc5:	89 c2                	mov    %eax,%edx
  800dc7:	85 d2                	test   %edx,%edx
  800dc9:	78 0f                	js     800dda <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  800dcb:	83 ec 08             	sub    $0x8,%esp
  800dce:	ff 75 0c             	pushl  0xc(%ebp)
  800dd1:	52                   	push   %edx
  800dd2:	e8 45 01 00 00       	call   800f1c <nsipc_shutdown>
  800dd7:	83 c4 10             	add    $0x10,%esp
}
  800dda:	c9                   	leave  
  800ddb:	c3                   	ret    

00800ddc <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800de2:	8b 45 08             	mov    0x8(%ebp),%eax
  800de5:	e8 cc fe ff ff       	call   800cb6 <fd2sockid>
  800dea:	89 c2                	mov    %eax,%edx
  800dec:	85 d2                	test   %edx,%edx
  800dee:	78 12                	js     800e02 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  800df0:	83 ec 04             	sub    $0x4,%esp
  800df3:	ff 75 10             	pushl  0x10(%ebp)
  800df6:	ff 75 0c             	pushl  0xc(%ebp)
  800df9:	52                   	push   %edx
  800dfa:	e8 59 01 00 00       	call   800f58 <nsipc_connect>
  800dff:	83 c4 10             	add    $0x10,%esp
}
  800e02:	c9                   	leave  
  800e03:	c3                   	ret    

00800e04 <listen>:

int
listen(int s, int backlog)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0d:	e8 a4 fe ff ff       	call   800cb6 <fd2sockid>
  800e12:	89 c2                	mov    %eax,%edx
  800e14:	85 d2                	test   %edx,%edx
  800e16:	78 0f                	js     800e27 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  800e18:	83 ec 08             	sub    $0x8,%esp
  800e1b:	ff 75 0c             	pushl  0xc(%ebp)
  800e1e:	52                   	push   %edx
  800e1f:	e8 69 01 00 00       	call   800f8d <nsipc_listen>
  800e24:	83 c4 10             	add    $0x10,%esp
}
  800e27:	c9                   	leave  
  800e28:	c3                   	ret    

00800e29 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e2f:	ff 75 10             	pushl  0x10(%ebp)
  800e32:	ff 75 0c             	pushl  0xc(%ebp)
  800e35:	ff 75 08             	pushl  0x8(%ebp)
  800e38:	e8 3c 02 00 00       	call   801079 <nsipc_socket>
  800e3d:	89 c2                	mov    %eax,%edx
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	85 d2                	test   %edx,%edx
  800e44:	78 05                	js     800e4b <socket+0x22>
		return r;
	return alloc_sockfd(r);
  800e46:	e8 9b fe ff ff       	call   800ce6 <alloc_sockfd>
}
  800e4b:	c9                   	leave  
  800e4c:	c3                   	ret    

00800e4d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	53                   	push   %ebx
  800e51:	83 ec 04             	sub    $0x4,%esp
  800e54:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e56:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e5d:	75 12                	jne    800e71 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	6a 02                	push   $0x2
  800e64:	e8 80 11 00 00       	call   801fe9 <ipc_find_env>
  800e69:	a3 04 40 80 00       	mov    %eax,0x804004
  800e6e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e71:	6a 07                	push   $0x7
  800e73:	68 00 60 80 00       	push   $0x806000
  800e78:	53                   	push   %ebx
  800e79:	ff 35 04 40 80 00    	pushl  0x804004
  800e7f:	e8 11 11 00 00       	call   801f95 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e84:	83 c4 0c             	add    $0xc,%esp
  800e87:	6a 00                	push   $0x0
  800e89:	6a 00                	push   $0x0
  800e8b:	6a 00                	push   $0x0
  800e8d:	e8 9a 10 00 00       	call   801f2c <ipc_recv>
}
  800e92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800ea7:	8b 06                	mov    (%esi),%eax
  800ea9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800eae:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb3:	e8 95 ff ff ff       	call   800e4d <nsipc>
  800eb8:	89 c3                	mov    %eax,%ebx
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	78 20                	js     800ede <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800ebe:	83 ec 04             	sub    $0x4,%esp
  800ec1:	ff 35 10 60 80 00    	pushl  0x806010
  800ec7:	68 00 60 80 00       	push   $0x806000
  800ecc:	ff 75 0c             	pushl  0xc(%ebp)
  800ecf:	e8 9d 0e 00 00       	call   801d71 <memmove>
		*addrlen = ret->ret_addrlen;
  800ed4:	a1 10 60 80 00       	mov    0x806010,%eax
  800ed9:	89 06                	mov    %eax,(%esi)
  800edb:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800ede:	89 d8                	mov    %ebx,%eax
  800ee0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 08             	sub    $0x8,%esp
  800eee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ef9:	53                   	push   %ebx
  800efa:	ff 75 0c             	pushl  0xc(%ebp)
  800efd:	68 04 60 80 00       	push   $0x806004
  800f02:	e8 6a 0e 00 00       	call   801d71 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800f07:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800f0d:	b8 02 00 00 00       	mov    $0x2,%eax
  800f12:	e8 36 ff ff ff       	call   800e4d <nsipc>
}
  800f17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1a:	c9                   	leave  
  800f1b:	c3                   	ret    

00800f1c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f22:	8b 45 08             	mov    0x8(%ebp),%eax
  800f25:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f32:	b8 03 00 00 00       	mov    $0x3,%eax
  800f37:	e8 11 ff ff ff       	call   800e4d <nsipc>
}
  800f3c:	c9                   	leave  
  800f3d:	c3                   	ret    

00800f3e <nsipc_close>:

int
nsipc_close(int s)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f44:	8b 45 08             	mov    0x8(%ebp),%eax
  800f47:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f4c:	b8 04 00 00 00       	mov    $0x4,%eax
  800f51:	e8 f7 fe ff ff       	call   800e4d <nsipc>
}
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	53                   	push   %ebx
  800f5c:	83 ec 08             	sub    $0x8,%esp
  800f5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f62:	8b 45 08             	mov    0x8(%ebp),%eax
  800f65:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f6a:	53                   	push   %ebx
  800f6b:	ff 75 0c             	pushl  0xc(%ebp)
  800f6e:	68 04 60 80 00       	push   $0x806004
  800f73:	e8 f9 0d 00 00       	call   801d71 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f78:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f7e:	b8 05 00 00 00       	mov    $0x5,%eax
  800f83:	e8 c5 fe ff ff       	call   800e4d <nsipc>
}
  800f88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f93:	8b 45 08             	mov    0x8(%ebp),%eax
  800f96:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800fa3:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa8:	e8 a0 fe ff ff       	call   800e4d <nsipc>
}
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    

00800faf <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	56                   	push   %esi
  800fb3:	53                   	push   %ebx
  800fb4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fba:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800fbf:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800fc5:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc8:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800fcd:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd2:	e8 76 fe ff ff       	call   800e4d <nsipc>
  800fd7:	89 c3                	mov    %eax,%ebx
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	78 35                	js     801012 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800fdd:	39 f0                	cmp    %esi,%eax
  800fdf:	7f 07                	jg     800fe8 <nsipc_recv+0x39>
  800fe1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800fe6:	7e 16                	jle    800ffe <nsipc_recv+0x4f>
  800fe8:	68 53 24 80 00       	push   $0x802453
  800fed:	68 1b 24 80 00       	push   $0x80241b
  800ff2:	6a 62                	push   $0x62
  800ff4:	68 68 24 80 00       	push   $0x802468
  800ff9:	e8 81 05 00 00       	call   80157f <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800ffe:	83 ec 04             	sub    $0x4,%esp
  801001:	50                   	push   %eax
  801002:	68 00 60 80 00       	push   $0x806000
  801007:	ff 75 0c             	pushl  0xc(%ebp)
  80100a:	e8 62 0d 00 00       	call   801d71 <memmove>
  80100f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801012:	89 d8                	mov    %ebx,%eax
  801014:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801017:	5b                   	pop    %ebx
  801018:	5e                   	pop    %esi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	53                   	push   %ebx
  80101f:	83 ec 04             	sub    $0x4,%esp
  801022:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801025:	8b 45 08             	mov    0x8(%ebp),%eax
  801028:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80102d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801033:	7e 16                	jle    80104b <nsipc_send+0x30>
  801035:	68 74 24 80 00       	push   $0x802474
  80103a:	68 1b 24 80 00       	push   $0x80241b
  80103f:	6a 6d                	push   $0x6d
  801041:	68 68 24 80 00       	push   $0x802468
  801046:	e8 34 05 00 00       	call   80157f <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80104b:	83 ec 04             	sub    $0x4,%esp
  80104e:	53                   	push   %ebx
  80104f:	ff 75 0c             	pushl  0xc(%ebp)
  801052:	68 0c 60 80 00       	push   $0x80600c
  801057:	e8 15 0d 00 00       	call   801d71 <memmove>
	nsipcbuf.send.req_size = size;
  80105c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801062:	8b 45 14             	mov    0x14(%ebp),%eax
  801065:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80106a:	b8 08 00 00 00       	mov    $0x8,%eax
  80106f:	e8 d9 fd ff ff       	call   800e4d <nsipc>
}
  801074:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801077:	c9                   	leave  
  801078:	c3                   	ret    

00801079 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80107f:	8b 45 08             	mov    0x8(%ebp),%eax
  801082:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801087:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80108f:	8b 45 10             	mov    0x10(%ebp),%eax
  801092:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801097:	b8 09 00 00 00       	mov    $0x9,%eax
  80109c:	e8 ac fd ff ff       	call   800e4d <nsipc>
}
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    

008010a3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	56                   	push   %esi
  8010a7:	53                   	push   %ebx
  8010a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	ff 75 08             	pushl  0x8(%ebp)
  8010b1:	e8 56 f3 ff ff       	call   80040c <fd2data>
  8010b6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010b8:	83 c4 08             	add    $0x8,%esp
  8010bb:	68 80 24 80 00       	push   $0x802480
  8010c0:	53                   	push   %ebx
  8010c1:	e8 19 0b 00 00       	call   801bdf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010c6:	8b 56 04             	mov    0x4(%esi),%edx
  8010c9:	89 d0                	mov    %edx,%eax
  8010cb:	2b 06                	sub    (%esi),%eax
  8010cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8010d3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8010da:	00 00 00 
	stat->st_dev = &devpipe;
  8010dd:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  8010e4:	30 80 00 
	return 0;
}
  8010e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    

008010f3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010fd:	53                   	push   %ebx
  8010fe:	6a 00                	push   $0x0
  801100:	e8 ea f0 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801105:	89 1c 24             	mov    %ebx,(%esp)
  801108:	e8 ff f2 ff ff       	call   80040c <fd2data>
  80110d:	83 c4 08             	add    $0x8,%esp
  801110:	50                   	push   %eax
  801111:	6a 00                	push   $0x0
  801113:	e8 d7 f0 ff ff       	call   8001ef <sys_page_unmap>
}
  801118:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80111b:	c9                   	leave  
  80111c:	c3                   	ret    

0080111d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	57                   	push   %edi
  801121:	56                   	push   %esi
  801122:	53                   	push   %ebx
  801123:	83 ec 1c             	sub    $0x1c,%esp
  801126:	89 c6                	mov    %eax,%esi
  801128:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80112b:	a1 08 40 80 00       	mov    0x804008,%eax
  801130:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801133:	83 ec 0c             	sub    $0xc,%esp
  801136:	56                   	push   %esi
  801137:	e8 e5 0e 00 00       	call   802021 <pageref>
  80113c:	89 c7                	mov    %eax,%edi
  80113e:	83 c4 04             	add    $0x4,%esp
  801141:	ff 75 e4             	pushl  -0x1c(%ebp)
  801144:	e8 d8 0e 00 00       	call   802021 <pageref>
  801149:	83 c4 10             	add    $0x10,%esp
  80114c:	39 c7                	cmp    %eax,%edi
  80114e:	0f 94 c2             	sete   %dl
  801151:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801154:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  80115a:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80115d:	39 fb                	cmp    %edi,%ebx
  80115f:	74 19                	je     80117a <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801161:	84 d2                	test   %dl,%dl
  801163:	74 c6                	je     80112b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801165:	8b 51 58             	mov    0x58(%ecx),%edx
  801168:	50                   	push   %eax
  801169:	52                   	push   %edx
  80116a:	53                   	push   %ebx
  80116b:	68 87 24 80 00       	push   $0x802487
  801170:	e8 e3 04 00 00       	call   801658 <cprintf>
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	eb b1                	jmp    80112b <_pipeisclosed+0xe>
	}
}
  80117a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117d:	5b                   	pop    %ebx
  80117e:	5e                   	pop    %esi
  80117f:	5f                   	pop    %edi
  801180:	5d                   	pop    %ebp
  801181:	c3                   	ret    

00801182 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	57                   	push   %edi
  801186:	56                   	push   %esi
  801187:	53                   	push   %ebx
  801188:	83 ec 28             	sub    $0x28,%esp
  80118b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80118e:	56                   	push   %esi
  80118f:	e8 78 f2 ff ff       	call   80040c <fd2data>
  801194:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	bf 00 00 00 00       	mov    $0x0,%edi
  80119e:	eb 4b                	jmp    8011eb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011a0:	89 da                	mov    %ebx,%edx
  8011a2:	89 f0                	mov    %esi,%eax
  8011a4:	e8 74 ff ff ff       	call   80111d <_pipeisclosed>
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	75 48                	jne    8011f5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011ad:	e8 99 ef ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011b2:	8b 43 04             	mov    0x4(%ebx),%eax
  8011b5:	8b 0b                	mov    (%ebx),%ecx
  8011b7:	8d 51 20             	lea    0x20(%ecx),%edx
  8011ba:	39 d0                	cmp    %edx,%eax
  8011bc:	73 e2                	jae    8011a0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011c5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8011c8:	89 c2                	mov    %eax,%edx
  8011ca:	c1 fa 1f             	sar    $0x1f,%edx
  8011cd:	89 d1                	mov    %edx,%ecx
  8011cf:	c1 e9 1b             	shr    $0x1b,%ecx
  8011d2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8011d5:	83 e2 1f             	and    $0x1f,%edx
  8011d8:	29 ca                	sub    %ecx,%edx
  8011da:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8011de:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011e2:	83 c0 01             	add    $0x1,%eax
  8011e5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011e8:	83 c7 01             	add    $0x1,%edi
  8011eb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011ee:	75 c2                	jne    8011b2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011f3:	eb 05                	jmp    8011fa <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011f5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fd:	5b                   	pop    %ebx
  8011fe:	5e                   	pop    %esi
  8011ff:	5f                   	pop    %edi
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	57                   	push   %edi
  801206:	56                   	push   %esi
  801207:	53                   	push   %ebx
  801208:	83 ec 18             	sub    $0x18,%esp
  80120b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80120e:	57                   	push   %edi
  80120f:	e8 f8 f1 ff ff       	call   80040c <fd2data>
  801214:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801216:	83 c4 10             	add    $0x10,%esp
  801219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121e:	eb 3d                	jmp    80125d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801220:	85 db                	test   %ebx,%ebx
  801222:	74 04                	je     801228 <devpipe_read+0x26>
				return i;
  801224:	89 d8                	mov    %ebx,%eax
  801226:	eb 44                	jmp    80126c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801228:	89 f2                	mov    %esi,%edx
  80122a:	89 f8                	mov    %edi,%eax
  80122c:	e8 ec fe ff ff       	call   80111d <_pipeisclosed>
  801231:	85 c0                	test   %eax,%eax
  801233:	75 32                	jne    801267 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801235:	e8 11 ef ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80123a:	8b 06                	mov    (%esi),%eax
  80123c:	3b 46 04             	cmp    0x4(%esi),%eax
  80123f:	74 df                	je     801220 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801241:	99                   	cltd   
  801242:	c1 ea 1b             	shr    $0x1b,%edx
  801245:	01 d0                	add    %edx,%eax
  801247:	83 e0 1f             	and    $0x1f,%eax
  80124a:	29 d0                	sub    %edx,%eax
  80124c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801251:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801254:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801257:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80125a:	83 c3 01             	add    $0x1,%ebx
  80125d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801260:	75 d8                	jne    80123a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801262:	8b 45 10             	mov    0x10(%ebp),%eax
  801265:	eb 05                	jmp    80126c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801267:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80126c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126f:	5b                   	pop    %ebx
  801270:	5e                   	pop    %esi
  801271:	5f                   	pop    %edi
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	56                   	push   %esi
  801278:	53                   	push   %ebx
  801279:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80127c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127f:	50                   	push   %eax
  801280:	e8 9e f1 ff ff       	call   800423 <fd_alloc>
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	89 c2                	mov    %eax,%edx
  80128a:	85 c0                	test   %eax,%eax
  80128c:	0f 88 2c 01 00 00    	js     8013be <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801292:	83 ec 04             	sub    $0x4,%esp
  801295:	68 07 04 00 00       	push   $0x407
  80129a:	ff 75 f4             	pushl  -0xc(%ebp)
  80129d:	6a 00                	push   $0x0
  80129f:	e8 c6 ee ff ff       	call   80016a <sys_page_alloc>
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	0f 88 0d 01 00 00    	js     8013be <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012b1:	83 ec 0c             	sub    $0xc,%esp
  8012b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b7:	50                   	push   %eax
  8012b8:	e8 66 f1 ff ff       	call   800423 <fd_alloc>
  8012bd:	89 c3                	mov    %eax,%ebx
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	0f 88 e2 00 00 00    	js     8013ac <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ca:	83 ec 04             	sub    $0x4,%esp
  8012cd:	68 07 04 00 00       	push   $0x407
  8012d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d5:	6a 00                	push   $0x0
  8012d7:	e8 8e ee ff ff       	call   80016a <sys_page_alloc>
  8012dc:	89 c3                	mov    %eax,%ebx
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	0f 88 c3 00 00 00    	js     8013ac <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012e9:	83 ec 0c             	sub    $0xc,%esp
  8012ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ef:	e8 18 f1 ff ff       	call   80040c <fd2data>
  8012f4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012f6:	83 c4 0c             	add    $0xc,%esp
  8012f9:	68 07 04 00 00       	push   $0x407
  8012fe:	50                   	push   %eax
  8012ff:	6a 00                	push   $0x0
  801301:	e8 64 ee ff ff       	call   80016a <sys_page_alloc>
  801306:	89 c3                	mov    %eax,%ebx
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	85 c0                	test   %eax,%eax
  80130d:	0f 88 89 00 00 00    	js     80139c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801313:	83 ec 0c             	sub    $0xc,%esp
  801316:	ff 75 f0             	pushl  -0x10(%ebp)
  801319:	e8 ee f0 ff ff       	call   80040c <fd2data>
  80131e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801325:	50                   	push   %eax
  801326:	6a 00                	push   $0x0
  801328:	56                   	push   %esi
  801329:	6a 00                	push   $0x0
  80132b:	e8 7d ee ff ff       	call   8001ad <sys_page_map>
  801330:	89 c3                	mov    %eax,%ebx
  801332:	83 c4 20             	add    $0x20,%esp
  801335:	85 c0                	test   %eax,%eax
  801337:	78 55                	js     80138e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801339:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80133f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801342:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801344:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801347:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80134e:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801357:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801359:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	ff 75 f4             	pushl  -0xc(%ebp)
  801369:	e8 8e f0 ff ff       	call   8003fc <fd2num>
  80136e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801371:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801373:	83 c4 04             	add    $0x4,%esp
  801376:	ff 75 f0             	pushl  -0x10(%ebp)
  801379:	e8 7e f0 ff ff       	call   8003fc <fd2num>
  80137e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801381:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	ba 00 00 00 00       	mov    $0x0,%edx
  80138c:	eb 30                	jmp    8013be <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80138e:	83 ec 08             	sub    $0x8,%esp
  801391:	56                   	push   %esi
  801392:	6a 00                	push   $0x0
  801394:	e8 56 ee ff ff       	call   8001ef <sys_page_unmap>
  801399:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a2:	6a 00                	push   $0x0
  8013a4:	e8 46 ee ff ff       	call   8001ef <sys_page_unmap>
  8013a9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b2:	6a 00                	push   $0x0
  8013b4:	e8 36 ee ff ff       	call   8001ef <sys_page_unmap>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013be:	89 d0                	mov    %edx,%eax
  8013c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    

008013c7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d0:	50                   	push   %eax
  8013d1:	ff 75 08             	pushl  0x8(%ebp)
  8013d4:	e8 99 f0 ff ff       	call   800472 <fd_lookup>
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	85 d2                	test   %edx,%edx
  8013e0:	78 18                	js     8013fa <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013e2:	83 ec 0c             	sub    $0xc,%esp
  8013e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e8:	e8 1f f0 ff ff       	call   80040c <fd2data>
	return _pipeisclosed(fd, p);
  8013ed:	89 c2                	mov    %eax,%edx
  8013ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f2:	e8 26 fd ff ff       	call   80111d <_pipeisclosed>
  8013f7:	83 c4 10             	add    $0x10,%esp
}
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80140c:	68 9f 24 80 00       	push   $0x80249f
  801411:	ff 75 0c             	pushl  0xc(%ebp)
  801414:	e8 c6 07 00 00       	call   801bdf <strcpy>
	return 0;
}
  801419:	b8 00 00 00 00       	mov    $0x0,%eax
  80141e:	c9                   	leave  
  80141f:	c3                   	ret    

00801420 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	57                   	push   %edi
  801424:	56                   	push   %esi
  801425:	53                   	push   %ebx
  801426:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80142c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801431:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801437:	eb 2d                	jmp    801466 <devcons_write+0x46>
		m = n - tot;
  801439:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80143c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80143e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801441:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801446:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801449:	83 ec 04             	sub    $0x4,%esp
  80144c:	53                   	push   %ebx
  80144d:	03 45 0c             	add    0xc(%ebp),%eax
  801450:	50                   	push   %eax
  801451:	57                   	push   %edi
  801452:	e8 1a 09 00 00       	call   801d71 <memmove>
		sys_cputs(buf, m);
  801457:	83 c4 08             	add    $0x8,%esp
  80145a:	53                   	push   %ebx
  80145b:	57                   	push   %edi
  80145c:	e8 4d ec ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801461:	01 de                	add    %ebx,%esi
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	89 f0                	mov    %esi,%eax
  801468:	3b 75 10             	cmp    0x10(%ebp),%esi
  80146b:	72 cc                	jb     801439 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80146d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801470:	5b                   	pop    %ebx
  801471:	5e                   	pop    %esi
  801472:	5f                   	pop    %edi
  801473:	5d                   	pop    %ebp
  801474:	c3                   	ret    

00801475 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80147b:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801480:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801484:	75 07                	jne    80148d <devcons_read+0x18>
  801486:	eb 28                	jmp    8014b0 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801488:	e8 be ec ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80148d:	e8 3a ec ff ff       	call   8000cc <sys_cgetc>
  801492:	85 c0                	test   %eax,%eax
  801494:	74 f2                	je     801488 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801496:	85 c0                	test   %eax,%eax
  801498:	78 16                	js     8014b0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80149a:	83 f8 04             	cmp    $0x4,%eax
  80149d:	74 0c                	je     8014ab <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80149f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014a2:	88 02                	mov    %al,(%edx)
	return 1;
  8014a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014a9:	eb 05                	jmp    8014b0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014ab:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014b0:	c9                   	leave  
  8014b1:	c3                   	ret    

008014b2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014be:	6a 01                	push   $0x1
  8014c0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014c3:	50                   	push   %eax
  8014c4:	e8 e5 eb ff ff       	call   8000ae <sys_cputs>
  8014c9:	83 c4 10             	add    $0x10,%esp
}
  8014cc:	c9                   	leave  
  8014cd:	c3                   	ret    

008014ce <getchar>:

int
getchar(void)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014d4:	6a 01                	push   $0x1
  8014d6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014d9:	50                   	push   %eax
  8014da:	6a 00                	push   $0x0
  8014dc:	e8 00 f2 ff ff       	call   8006e1 <read>
	if (r < 0)
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 0f                	js     8014f7 <getchar+0x29>
		return r;
	if (r < 1)
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	7e 06                	jle    8014f2 <getchar+0x24>
		return -E_EOF;
	return c;
  8014ec:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014f0:	eb 05                	jmp    8014f7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014f2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014f7:	c9                   	leave  
  8014f8:	c3                   	ret    

008014f9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801502:	50                   	push   %eax
  801503:	ff 75 08             	pushl  0x8(%ebp)
  801506:	e8 67 ef ff ff       	call   800472 <fd_lookup>
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 11                	js     801523 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801512:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801515:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80151b:	39 10                	cmp    %edx,(%eax)
  80151d:	0f 94 c0             	sete   %al
  801520:	0f b6 c0             	movzbl %al,%eax
}
  801523:	c9                   	leave  
  801524:	c3                   	ret    

00801525 <opencons>:

int
opencons(void)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80152b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152e:	50                   	push   %eax
  80152f:	e8 ef ee ff ff       	call   800423 <fd_alloc>
  801534:	83 c4 10             	add    $0x10,%esp
		return r;
  801537:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 3e                	js     80157b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80153d:	83 ec 04             	sub    $0x4,%esp
  801540:	68 07 04 00 00       	push   $0x407
  801545:	ff 75 f4             	pushl  -0xc(%ebp)
  801548:	6a 00                	push   $0x0
  80154a:	e8 1b ec ff ff       	call   80016a <sys_page_alloc>
  80154f:	83 c4 10             	add    $0x10,%esp
		return r;
  801552:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801554:	85 c0                	test   %eax,%eax
  801556:	78 23                	js     80157b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801558:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80155e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801561:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801563:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801566:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80156d:	83 ec 0c             	sub    $0xc,%esp
  801570:	50                   	push   %eax
  801571:	e8 86 ee ff ff       	call   8003fc <fd2num>
  801576:	89 c2                	mov    %eax,%edx
  801578:	83 c4 10             	add    $0x10,%esp
}
  80157b:	89 d0                	mov    %edx,%eax
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	56                   	push   %esi
  801583:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801584:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801587:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80158d:	e8 9a eb ff ff       	call   80012c <sys_getenvid>
  801592:	83 ec 0c             	sub    $0xc,%esp
  801595:	ff 75 0c             	pushl  0xc(%ebp)
  801598:	ff 75 08             	pushl  0x8(%ebp)
  80159b:	56                   	push   %esi
  80159c:	50                   	push   %eax
  80159d:	68 ac 24 80 00       	push   $0x8024ac
  8015a2:	e8 b1 00 00 00       	call   801658 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015a7:	83 c4 18             	add    $0x18,%esp
  8015aa:	53                   	push   %ebx
  8015ab:	ff 75 10             	pushl  0x10(%ebp)
  8015ae:	e8 54 00 00 00       	call   801607 <vcprintf>
	cprintf("\n");
  8015b3:	c7 04 24 98 24 80 00 	movl   $0x802498,(%esp)
  8015ba:	e8 99 00 00 00       	call   801658 <cprintf>
  8015bf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015c2:	cc                   	int3   
  8015c3:	eb fd                	jmp    8015c2 <_panic+0x43>

008015c5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 04             	sub    $0x4,%esp
  8015cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015cf:	8b 13                	mov    (%ebx),%edx
  8015d1:	8d 42 01             	lea    0x1(%edx),%eax
  8015d4:	89 03                	mov    %eax,(%ebx)
  8015d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015d9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8015dd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015e2:	75 1a                	jne    8015fe <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8015e4:	83 ec 08             	sub    $0x8,%esp
  8015e7:	68 ff 00 00 00       	push   $0xff
  8015ec:	8d 43 08             	lea    0x8(%ebx),%eax
  8015ef:	50                   	push   %eax
  8015f0:	e8 b9 ea ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  8015f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015fb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015fe:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801602:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801610:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801617:	00 00 00 
	b.cnt = 0;
  80161a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801621:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801624:	ff 75 0c             	pushl  0xc(%ebp)
  801627:	ff 75 08             	pushl  0x8(%ebp)
  80162a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801630:	50                   	push   %eax
  801631:	68 c5 15 80 00       	push   $0x8015c5
  801636:	e8 4f 01 00 00       	call   80178a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80163b:	83 c4 08             	add    $0x8,%esp
  80163e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801644:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	e8 5e ea ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  801650:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801656:	c9                   	leave  
  801657:	c3                   	ret    

00801658 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80165e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801661:	50                   	push   %eax
  801662:	ff 75 08             	pushl  0x8(%ebp)
  801665:	e8 9d ff ff ff       	call   801607 <vcprintf>
	va_end(ap);

	return cnt;
}
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	57                   	push   %edi
  801670:	56                   	push   %esi
  801671:	53                   	push   %ebx
  801672:	83 ec 1c             	sub    $0x1c,%esp
  801675:	89 c7                	mov    %eax,%edi
  801677:	89 d6                	mov    %edx,%esi
  801679:	8b 45 08             	mov    0x8(%ebp),%eax
  80167c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167f:	89 d1                	mov    %edx,%ecx
  801681:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801684:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801687:	8b 45 10             	mov    0x10(%ebp),%eax
  80168a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80168d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801690:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801697:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80169a:	72 05                	jb     8016a1 <printnum+0x35>
  80169c:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80169f:	77 3e                	ja     8016df <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016a1:	83 ec 0c             	sub    $0xc,%esp
  8016a4:	ff 75 18             	pushl  0x18(%ebp)
  8016a7:	83 eb 01             	sub    $0x1,%ebx
  8016aa:	53                   	push   %ebx
  8016ab:	50                   	push   %eax
  8016ac:	83 ec 08             	sub    $0x8,%esp
  8016af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8016b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8016b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8016bb:	e8 a0 09 00 00       	call   802060 <__udivdi3>
  8016c0:	83 c4 18             	add    $0x18,%esp
  8016c3:	52                   	push   %edx
  8016c4:	50                   	push   %eax
  8016c5:	89 f2                	mov    %esi,%edx
  8016c7:	89 f8                	mov    %edi,%eax
  8016c9:	e8 9e ff ff ff       	call   80166c <printnum>
  8016ce:	83 c4 20             	add    $0x20,%esp
  8016d1:	eb 13                	jmp    8016e6 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8016d3:	83 ec 08             	sub    $0x8,%esp
  8016d6:	56                   	push   %esi
  8016d7:	ff 75 18             	pushl  0x18(%ebp)
  8016da:	ff d7                	call   *%edi
  8016dc:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8016df:	83 eb 01             	sub    $0x1,%ebx
  8016e2:	85 db                	test   %ebx,%ebx
  8016e4:	7f ed                	jg     8016d3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	56                   	push   %esi
  8016ea:	83 ec 04             	sub    $0x4,%esp
  8016ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8016f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8016f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8016f9:	e8 92 0a 00 00       	call   802190 <__umoddi3>
  8016fe:	83 c4 14             	add    $0x14,%esp
  801701:	0f be 80 cf 24 80 00 	movsbl 0x8024cf(%eax),%eax
  801708:	50                   	push   %eax
  801709:	ff d7                	call   *%edi
  80170b:	83 c4 10             	add    $0x10,%esp
}
  80170e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801711:	5b                   	pop    %ebx
  801712:	5e                   	pop    %esi
  801713:	5f                   	pop    %edi
  801714:	5d                   	pop    %ebp
  801715:	c3                   	ret    

00801716 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801719:	83 fa 01             	cmp    $0x1,%edx
  80171c:	7e 0e                	jle    80172c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80171e:	8b 10                	mov    (%eax),%edx
  801720:	8d 4a 08             	lea    0x8(%edx),%ecx
  801723:	89 08                	mov    %ecx,(%eax)
  801725:	8b 02                	mov    (%edx),%eax
  801727:	8b 52 04             	mov    0x4(%edx),%edx
  80172a:	eb 22                	jmp    80174e <getuint+0x38>
	else if (lflag)
  80172c:	85 d2                	test   %edx,%edx
  80172e:	74 10                	je     801740 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801730:	8b 10                	mov    (%eax),%edx
  801732:	8d 4a 04             	lea    0x4(%edx),%ecx
  801735:	89 08                	mov    %ecx,(%eax)
  801737:	8b 02                	mov    (%edx),%eax
  801739:	ba 00 00 00 00       	mov    $0x0,%edx
  80173e:	eb 0e                	jmp    80174e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801740:	8b 10                	mov    (%eax),%edx
  801742:	8d 4a 04             	lea    0x4(%edx),%ecx
  801745:	89 08                	mov    %ecx,(%eax)
  801747:	8b 02                	mov    (%edx),%eax
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80174e:	5d                   	pop    %ebp
  80174f:	c3                   	ret    

00801750 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801756:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80175a:	8b 10                	mov    (%eax),%edx
  80175c:	3b 50 04             	cmp    0x4(%eax),%edx
  80175f:	73 0a                	jae    80176b <sprintputch+0x1b>
		*b->buf++ = ch;
  801761:	8d 4a 01             	lea    0x1(%edx),%ecx
  801764:	89 08                	mov    %ecx,(%eax)
  801766:	8b 45 08             	mov    0x8(%ebp),%eax
  801769:	88 02                	mov    %al,(%edx)
}
  80176b:	5d                   	pop    %ebp
  80176c:	c3                   	ret    

0080176d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801773:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801776:	50                   	push   %eax
  801777:	ff 75 10             	pushl  0x10(%ebp)
  80177a:	ff 75 0c             	pushl  0xc(%ebp)
  80177d:	ff 75 08             	pushl  0x8(%ebp)
  801780:	e8 05 00 00 00       	call   80178a <vprintfmt>
	va_end(ap);
  801785:	83 c4 10             	add    $0x10,%esp
}
  801788:	c9                   	leave  
  801789:	c3                   	ret    

0080178a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	57                   	push   %edi
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	83 ec 2c             	sub    $0x2c,%esp
  801793:	8b 75 08             	mov    0x8(%ebp),%esi
  801796:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801799:	8b 7d 10             	mov    0x10(%ebp),%edi
  80179c:	eb 12                	jmp    8017b0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	0f 84 90 03 00 00    	je     801b36 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8017a6:	83 ec 08             	sub    $0x8,%esp
  8017a9:	53                   	push   %ebx
  8017aa:	50                   	push   %eax
  8017ab:	ff d6                	call   *%esi
  8017ad:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017b0:	83 c7 01             	add    $0x1,%edi
  8017b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017b7:	83 f8 25             	cmp    $0x25,%eax
  8017ba:	75 e2                	jne    80179e <vprintfmt+0x14>
  8017bc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017c0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8017c7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8017d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017da:	eb 07                	jmp    8017e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8017df:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017e3:	8d 47 01             	lea    0x1(%edi),%eax
  8017e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017e9:	0f b6 07             	movzbl (%edi),%eax
  8017ec:	0f b6 c8             	movzbl %al,%ecx
  8017ef:	83 e8 23             	sub    $0x23,%eax
  8017f2:	3c 55                	cmp    $0x55,%al
  8017f4:	0f 87 21 03 00 00    	ja     801b1b <vprintfmt+0x391>
  8017fa:	0f b6 c0             	movzbl %al,%eax
  8017fd:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  801804:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801807:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80180b:	eb d6                	jmp    8017e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801810:	b8 00 00 00 00       	mov    $0x0,%eax
  801815:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801818:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80181b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80181f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801822:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801825:	83 fa 09             	cmp    $0x9,%edx
  801828:	77 39                	ja     801863 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80182a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80182d:	eb e9                	jmp    801818 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80182f:	8b 45 14             	mov    0x14(%ebp),%eax
  801832:	8d 48 04             	lea    0x4(%eax),%ecx
  801835:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801838:	8b 00                	mov    (%eax),%eax
  80183a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801840:	eb 27                	jmp    801869 <vprintfmt+0xdf>
  801842:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801845:	85 c0                	test   %eax,%eax
  801847:	b9 00 00 00 00       	mov    $0x0,%ecx
  80184c:	0f 49 c8             	cmovns %eax,%ecx
  80184f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801852:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801855:	eb 8c                	jmp    8017e3 <vprintfmt+0x59>
  801857:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80185a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801861:	eb 80                	jmp    8017e3 <vprintfmt+0x59>
  801863:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801866:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801869:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80186d:	0f 89 70 ff ff ff    	jns    8017e3 <vprintfmt+0x59>
				width = precision, precision = -1;
  801873:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801876:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801879:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801880:	e9 5e ff ff ff       	jmp    8017e3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801885:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801888:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80188b:	e9 53 ff ff ff       	jmp    8017e3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801890:	8b 45 14             	mov    0x14(%ebp),%eax
  801893:	8d 50 04             	lea    0x4(%eax),%edx
  801896:	89 55 14             	mov    %edx,0x14(%ebp)
  801899:	83 ec 08             	sub    $0x8,%esp
  80189c:	53                   	push   %ebx
  80189d:	ff 30                	pushl  (%eax)
  80189f:	ff d6                	call   *%esi
			break;
  8018a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018a7:	e9 04 ff ff ff       	jmp    8017b0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8018af:	8d 50 04             	lea    0x4(%eax),%edx
  8018b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8018b5:	8b 00                	mov    (%eax),%eax
  8018b7:	99                   	cltd   
  8018b8:	31 d0                	xor    %edx,%eax
  8018ba:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018bc:	83 f8 0f             	cmp    $0xf,%eax
  8018bf:	7f 0b                	jg     8018cc <vprintfmt+0x142>
  8018c1:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  8018c8:	85 d2                	test   %edx,%edx
  8018ca:	75 18                	jne    8018e4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8018cc:	50                   	push   %eax
  8018cd:	68 e7 24 80 00       	push   $0x8024e7
  8018d2:	53                   	push   %ebx
  8018d3:	56                   	push   %esi
  8018d4:	e8 94 fe ff ff       	call   80176d <printfmt>
  8018d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8018df:	e9 cc fe ff ff       	jmp    8017b0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018e4:	52                   	push   %edx
  8018e5:	68 2d 24 80 00       	push   $0x80242d
  8018ea:	53                   	push   %ebx
  8018eb:	56                   	push   %esi
  8018ec:	e8 7c fe ff ff       	call   80176d <printfmt>
  8018f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018f7:	e9 b4 fe ff ff       	jmp    8017b0 <vprintfmt+0x26>
  8018fc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8018ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801902:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801905:	8b 45 14             	mov    0x14(%ebp),%eax
  801908:	8d 50 04             	lea    0x4(%eax),%edx
  80190b:	89 55 14             	mov    %edx,0x14(%ebp)
  80190e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801910:	85 ff                	test   %edi,%edi
  801912:	ba e0 24 80 00       	mov    $0x8024e0,%edx
  801917:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80191a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80191e:	0f 84 92 00 00 00    	je     8019b6 <vprintfmt+0x22c>
  801924:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801928:	0f 8e 96 00 00 00    	jle    8019c4 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80192e:	83 ec 08             	sub    $0x8,%esp
  801931:	51                   	push   %ecx
  801932:	57                   	push   %edi
  801933:	e8 86 02 00 00       	call   801bbe <strnlen>
  801938:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80193b:	29 c1                	sub    %eax,%ecx
  80193d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801940:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801943:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801947:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80194a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80194d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80194f:	eb 0f                	jmp    801960 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	53                   	push   %ebx
  801955:	ff 75 e0             	pushl  -0x20(%ebp)
  801958:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80195a:	83 ef 01             	sub    $0x1,%edi
  80195d:	83 c4 10             	add    $0x10,%esp
  801960:	85 ff                	test   %edi,%edi
  801962:	7f ed                	jg     801951 <vprintfmt+0x1c7>
  801964:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801967:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80196a:	85 c9                	test   %ecx,%ecx
  80196c:	b8 00 00 00 00       	mov    $0x0,%eax
  801971:	0f 49 c1             	cmovns %ecx,%eax
  801974:	29 c1                	sub    %eax,%ecx
  801976:	89 75 08             	mov    %esi,0x8(%ebp)
  801979:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80197c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80197f:	89 cb                	mov    %ecx,%ebx
  801981:	eb 4d                	jmp    8019d0 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801983:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801987:	74 1b                	je     8019a4 <vprintfmt+0x21a>
  801989:	0f be c0             	movsbl %al,%eax
  80198c:	83 e8 20             	sub    $0x20,%eax
  80198f:	83 f8 5e             	cmp    $0x5e,%eax
  801992:	76 10                	jbe    8019a4 <vprintfmt+0x21a>
					putch('?', putdat);
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	ff 75 0c             	pushl  0xc(%ebp)
  80199a:	6a 3f                	push   $0x3f
  80199c:	ff 55 08             	call   *0x8(%ebp)
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	eb 0d                	jmp    8019b1 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8019a4:	83 ec 08             	sub    $0x8,%esp
  8019a7:	ff 75 0c             	pushl  0xc(%ebp)
  8019aa:	52                   	push   %edx
  8019ab:	ff 55 08             	call   *0x8(%ebp)
  8019ae:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019b1:	83 eb 01             	sub    $0x1,%ebx
  8019b4:	eb 1a                	jmp    8019d0 <vprintfmt+0x246>
  8019b6:	89 75 08             	mov    %esi,0x8(%ebp)
  8019b9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019bc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019bf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019c2:	eb 0c                	jmp    8019d0 <vprintfmt+0x246>
  8019c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8019c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019cd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019d0:	83 c7 01             	add    $0x1,%edi
  8019d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019d7:	0f be d0             	movsbl %al,%edx
  8019da:	85 d2                	test   %edx,%edx
  8019dc:	74 23                	je     801a01 <vprintfmt+0x277>
  8019de:	85 f6                	test   %esi,%esi
  8019e0:	78 a1                	js     801983 <vprintfmt+0x1f9>
  8019e2:	83 ee 01             	sub    $0x1,%esi
  8019e5:	79 9c                	jns    801983 <vprintfmt+0x1f9>
  8019e7:	89 df                	mov    %ebx,%edi
  8019e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8019ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ef:	eb 18                	jmp    801a09 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019f1:	83 ec 08             	sub    $0x8,%esp
  8019f4:	53                   	push   %ebx
  8019f5:	6a 20                	push   $0x20
  8019f7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019f9:	83 ef 01             	sub    $0x1,%edi
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	eb 08                	jmp    801a09 <vprintfmt+0x27f>
  801a01:	89 df                	mov    %ebx,%edi
  801a03:	8b 75 08             	mov    0x8(%ebp),%esi
  801a06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a09:	85 ff                	test   %edi,%edi
  801a0b:	7f e4                	jg     8019f1 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a10:	e9 9b fd ff ff       	jmp    8017b0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a15:	83 fa 01             	cmp    $0x1,%edx
  801a18:	7e 16                	jle    801a30 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801a1a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1d:	8d 50 08             	lea    0x8(%eax),%edx
  801a20:	89 55 14             	mov    %edx,0x14(%ebp)
  801a23:	8b 50 04             	mov    0x4(%eax),%edx
  801a26:	8b 00                	mov    (%eax),%eax
  801a28:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a2b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a2e:	eb 32                	jmp    801a62 <vprintfmt+0x2d8>
	else if (lflag)
  801a30:	85 d2                	test   %edx,%edx
  801a32:	74 18                	je     801a4c <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801a34:	8b 45 14             	mov    0x14(%ebp),%eax
  801a37:	8d 50 04             	lea    0x4(%eax),%edx
  801a3a:	89 55 14             	mov    %edx,0x14(%ebp)
  801a3d:	8b 00                	mov    (%eax),%eax
  801a3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a42:	89 c1                	mov    %eax,%ecx
  801a44:	c1 f9 1f             	sar    $0x1f,%ecx
  801a47:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a4a:	eb 16                	jmp    801a62 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801a4c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a4f:	8d 50 04             	lea    0x4(%eax),%edx
  801a52:	89 55 14             	mov    %edx,0x14(%ebp)
  801a55:	8b 00                	mov    (%eax),%eax
  801a57:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a5a:	89 c1                	mov    %eax,%ecx
  801a5c:	c1 f9 1f             	sar    $0x1f,%ecx
  801a5f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a62:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a65:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a68:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a6d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a71:	79 74                	jns    801ae7 <vprintfmt+0x35d>
				putch('-', putdat);
  801a73:	83 ec 08             	sub    $0x8,%esp
  801a76:	53                   	push   %ebx
  801a77:	6a 2d                	push   $0x2d
  801a79:	ff d6                	call   *%esi
				num = -(long long) num;
  801a7b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a7e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a81:	f7 d8                	neg    %eax
  801a83:	83 d2 00             	adc    $0x0,%edx
  801a86:	f7 da                	neg    %edx
  801a88:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a8b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a90:	eb 55                	jmp    801ae7 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a92:	8d 45 14             	lea    0x14(%ebp),%eax
  801a95:	e8 7c fc ff ff       	call   801716 <getuint>
			base = 10;
  801a9a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a9f:	eb 46                	jmp    801ae7 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801aa1:	8d 45 14             	lea    0x14(%ebp),%eax
  801aa4:	e8 6d fc ff ff       	call   801716 <getuint>
                        base = 8;
  801aa9:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801aae:	eb 37                	jmp    801ae7 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801ab0:	83 ec 08             	sub    $0x8,%esp
  801ab3:	53                   	push   %ebx
  801ab4:	6a 30                	push   $0x30
  801ab6:	ff d6                	call   *%esi
			putch('x', putdat);
  801ab8:	83 c4 08             	add    $0x8,%esp
  801abb:	53                   	push   %ebx
  801abc:	6a 78                	push   $0x78
  801abe:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801ac0:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac3:	8d 50 04             	lea    0x4(%eax),%edx
  801ac6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ac9:	8b 00                	mov    (%eax),%eax
  801acb:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ad0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ad3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ad8:	eb 0d                	jmp    801ae7 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ada:	8d 45 14             	lea    0x14(%ebp),%eax
  801add:	e8 34 fc ff ff       	call   801716 <getuint>
			base = 16;
  801ae2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ae7:	83 ec 0c             	sub    $0xc,%esp
  801aea:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801aee:	57                   	push   %edi
  801aef:	ff 75 e0             	pushl  -0x20(%ebp)
  801af2:	51                   	push   %ecx
  801af3:	52                   	push   %edx
  801af4:	50                   	push   %eax
  801af5:	89 da                	mov    %ebx,%edx
  801af7:	89 f0                	mov    %esi,%eax
  801af9:	e8 6e fb ff ff       	call   80166c <printnum>
			break;
  801afe:	83 c4 20             	add    $0x20,%esp
  801b01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b04:	e9 a7 fc ff ff       	jmp    8017b0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b09:	83 ec 08             	sub    $0x8,%esp
  801b0c:	53                   	push   %ebx
  801b0d:	51                   	push   %ecx
  801b0e:	ff d6                	call   *%esi
			break;
  801b10:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b16:	e9 95 fc ff ff       	jmp    8017b0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b1b:	83 ec 08             	sub    $0x8,%esp
  801b1e:	53                   	push   %ebx
  801b1f:	6a 25                	push   $0x25
  801b21:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	eb 03                	jmp    801b2b <vprintfmt+0x3a1>
  801b28:	83 ef 01             	sub    $0x1,%edi
  801b2b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b2f:	75 f7                	jne    801b28 <vprintfmt+0x39e>
  801b31:	e9 7a fc ff ff       	jmp    8017b0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5f                   	pop    %edi
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	83 ec 18             	sub    $0x18,%esp
  801b44:	8b 45 08             	mov    0x8(%ebp),%eax
  801b47:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b4d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b51:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b5b:	85 c0                	test   %eax,%eax
  801b5d:	74 26                	je     801b85 <vsnprintf+0x47>
  801b5f:	85 d2                	test   %edx,%edx
  801b61:	7e 22                	jle    801b85 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b63:	ff 75 14             	pushl  0x14(%ebp)
  801b66:	ff 75 10             	pushl  0x10(%ebp)
  801b69:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b6c:	50                   	push   %eax
  801b6d:	68 50 17 80 00       	push   $0x801750
  801b72:	e8 13 fc ff ff       	call   80178a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b77:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b7a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	eb 05                	jmp    801b8a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b92:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b95:	50                   	push   %eax
  801b96:	ff 75 10             	pushl  0x10(%ebp)
  801b99:	ff 75 0c             	pushl  0xc(%ebp)
  801b9c:	ff 75 08             	pushl  0x8(%ebp)
  801b9f:	e8 9a ff ff ff       	call   801b3e <vsnprintf>
	va_end(ap);

	return rc;
}
  801ba4:	c9                   	leave  
  801ba5:	c3                   	ret    

00801ba6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
  801ba9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bac:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb1:	eb 03                	jmp    801bb6 <strlen+0x10>
		n++;
  801bb3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801bb6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bba:	75 f7                	jne    801bb3 <strlen+0xd>
		n++;
	return n;
}
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bcc:	eb 03                	jmp    801bd1 <strnlen+0x13>
		n++;
  801bce:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bd1:	39 c2                	cmp    %eax,%edx
  801bd3:	74 08                	je     801bdd <strnlen+0x1f>
  801bd5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bd9:	75 f3                	jne    801bce <strnlen+0x10>
  801bdb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	53                   	push   %ebx
  801be3:	8b 45 08             	mov    0x8(%ebp),%eax
  801be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801be9:	89 c2                	mov    %eax,%edx
  801beb:	83 c2 01             	add    $0x1,%edx
  801bee:	83 c1 01             	add    $0x1,%ecx
  801bf1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bf5:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bf8:	84 db                	test   %bl,%bl
  801bfa:	75 ef                	jne    801beb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bfc:	5b                   	pop    %ebx
  801bfd:	5d                   	pop    %ebp
  801bfe:	c3                   	ret    

00801bff <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	53                   	push   %ebx
  801c03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c06:	53                   	push   %ebx
  801c07:	e8 9a ff ff ff       	call   801ba6 <strlen>
  801c0c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c0f:	ff 75 0c             	pushl  0xc(%ebp)
  801c12:	01 d8                	add    %ebx,%eax
  801c14:	50                   	push   %eax
  801c15:	e8 c5 ff ff ff       	call   801bdf <strcpy>
	return dst;
}
  801c1a:	89 d8                	mov    %ebx,%eax
  801c1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c1f:	c9                   	leave  
  801c20:	c3                   	ret    

00801c21 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	56                   	push   %esi
  801c25:	53                   	push   %ebx
  801c26:	8b 75 08             	mov    0x8(%ebp),%esi
  801c29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2c:	89 f3                	mov    %esi,%ebx
  801c2e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c31:	89 f2                	mov    %esi,%edx
  801c33:	eb 0f                	jmp    801c44 <strncpy+0x23>
		*dst++ = *src;
  801c35:	83 c2 01             	add    $0x1,%edx
  801c38:	0f b6 01             	movzbl (%ecx),%eax
  801c3b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c3e:	80 39 01             	cmpb   $0x1,(%ecx)
  801c41:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c44:	39 da                	cmp    %ebx,%edx
  801c46:	75 ed                	jne    801c35 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c48:	89 f0                	mov    %esi,%eax
  801c4a:	5b                   	pop    %ebx
  801c4b:	5e                   	pop    %esi
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    

00801c4e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	56                   	push   %esi
  801c52:	53                   	push   %ebx
  801c53:	8b 75 08             	mov    0x8(%ebp),%esi
  801c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c59:	8b 55 10             	mov    0x10(%ebp),%edx
  801c5c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c5e:	85 d2                	test   %edx,%edx
  801c60:	74 21                	je     801c83 <strlcpy+0x35>
  801c62:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c66:	89 f2                	mov    %esi,%edx
  801c68:	eb 09                	jmp    801c73 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c6a:	83 c2 01             	add    $0x1,%edx
  801c6d:	83 c1 01             	add    $0x1,%ecx
  801c70:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c73:	39 c2                	cmp    %eax,%edx
  801c75:	74 09                	je     801c80 <strlcpy+0x32>
  801c77:	0f b6 19             	movzbl (%ecx),%ebx
  801c7a:	84 db                	test   %bl,%bl
  801c7c:	75 ec                	jne    801c6a <strlcpy+0x1c>
  801c7e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c80:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c83:	29 f0                	sub    %esi,%eax
}
  801c85:	5b                   	pop    %ebx
  801c86:	5e                   	pop    %esi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    

00801c89 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c92:	eb 06                	jmp    801c9a <strcmp+0x11>
		p++, q++;
  801c94:	83 c1 01             	add    $0x1,%ecx
  801c97:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c9a:	0f b6 01             	movzbl (%ecx),%eax
  801c9d:	84 c0                	test   %al,%al
  801c9f:	74 04                	je     801ca5 <strcmp+0x1c>
  801ca1:	3a 02                	cmp    (%edx),%al
  801ca3:	74 ef                	je     801c94 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ca5:	0f b6 c0             	movzbl %al,%eax
  801ca8:	0f b6 12             	movzbl (%edx),%edx
  801cab:	29 d0                	sub    %edx,%eax
}
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	53                   	push   %ebx
  801cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb9:	89 c3                	mov    %eax,%ebx
  801cbb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cbe:	eb 06                	jmp    801cc6 <strncmp+0x17>
		n--, p++, q++;
  801cc0:	83 c0 01             	add    $0x1,%eax
  801cc3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cc6:	39 d8                	cmp    %ebx,%eax
  801cc8:	74 15                	je     801cdf <strncmp+0x30>
  801cca:	0f b6 08             	movzbl (%eax),%ecx
  801ccd:	84 c9                	test   %cl,%cl
  801ccf:	74 04                	je     801cd5 <strncmp+0x26>
  801cd1:	3a 0a                	cmp    (%edx),%cl
  801cd3:	74 eb                	je     801cc0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cd5:	0f b6 00             	movzbl (%eax),%eax
  801cd8:	0f b6 12             	movzbl (%edx),%edx
  801cdb:	29 d0                	sub    %edx,%eax
  801cdd:	eb 05                	jmp    801ce4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cdf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801ce4:	5b                   	pop    %ebx
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ced:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cf1:	eb 07                	jmp    801cfa <strchr+0x13>
		if (*s == c)
  801cf3:	38 ca                	cmp    %cl,%dl
  801cf5:	74 0f                	je     801d06 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801cf7:	83 c0 01             	add    $0x1,%eax
  801cfa:	0f b6 10             	movzbl (%eax),%edx
  801cfd:	84 d2                	test   %dl,%dl
  801cff:	75 f2                	jne    801cf3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    

00801d08 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d12:	eb 03                	jmp    801d17 <strfind+0xf>
  801d14:	83 c0 01             	add    $0x1,%eax
  801d17:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d1a:	84 d2                	test   %dl,%dl
  801d1c:	74 04                	je     801d22 <strfind+0x1a>
  801d1e:	38 ca                	cmp    %cl,%dl
  801d20:	75 f2                	jne    801d14 <strfind+0xc>
			break;
	return (char *) s;
}
  801d22:	5d                   	pop    %ebp
  801d23:	c3                   	ret    

00801d24 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	57                   	push   %edi
  801d28:	56                   	push   %esi
  801d29:	53                   	push   %ebx
  801d2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d30:	85 c9                	test   %ecx,%ecx
  801d32:	74 36                	je     801d6a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d3a:	75 28                	jne    801d64 <memset+0x40>
  801d3c:	f6 c1 03             	test   $0x3,%cl
  801d3f:	75 23                	jne    801d64 <memset+0x40>
		c &= 0xFF;
  801d41:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d45:	89 d3                	mov    %edx,%ebx
  801d47:	c1 e3 08             	shl    $0x8,%ebx
  801d4a:	89 d6                	mov    %edx,%esi
  801d4c:	c1 e6 18             	shl    $0x18,%esi
  801d4f:	89 d0                	mov    %edx,%eax
  801d51:	c1 e0 10             	shl    $0x10,%eax
  801d54:	09 f0                	or     %esi,%eax
  801d56:	09 c2                	or     %eax,%edx
  801d58:	89 d0                	mov    %edx,%eax
  801d5a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d5c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801d5f:	fc                   	cld    
  801d60:	f3 ab                	rep stos %eax,%es:(%edi)
  801d62:	eb 06                	jmp    801d6a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d67:	fc                   	cld    
  801d68:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d6a:	89 f8                	mov    %edi,%eax
  801d6c:	5b                   	pop    %ebx
  801d6d:	5e                   	pop    %esi
  801d6e:	5f                   	pop    %edi
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    

00801d71 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	57                   	push   %edi
  801d75:	56                   	push   %esi
  801d76:	8b 45 08             	mov    0x8(%ebp),%eax
  801d79:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d7c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d7f:	39 c6                	cmp    %eax,%esi
  801d81:	73 35                	jae    801db8 <memmove+0x47>
  801d83:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d86:	39 d0                	cmp    %edx,%eax
  801d88:	73 2e                	jae    801db8 <memmove+0x47>
		s += n;
		d += n;
  801d8a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801d8d:	89 d6                	mov    %edx,%esi
  801d8f:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d91:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d97:	75 13                	jne    801dac <memmove+0x3b>
  801d99:	f6 c1 03             	test   $0x3,%cl
  801d9c:	75 0e                	jne    801dac <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d9e:	83 ef 04             	sub    $0x4,%edi
  801da1:	8d 72 fc             	lea    -0x4(%edx),%esi
  801da4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801da7:	fd                   	std    
  801da8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801daa:	eb 09                	jmp    801db5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801dac:	83 ef 01             	sub    $0x1,%edi
  801daf:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801db2:	fd                   	std    
  801db3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801db5:	fc                   	cld    
  801db6:	eb 1d                	jmp    801dd5 <memmove+0x64>
  801db8:	89 f2                	mov    %esi,%edx
  801dba:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dbc:	f6 c2 03             	test   $0x3,%dl
  801dbf:	75 0f                	jne    801dd0 <memmove+0x5f>
  801dc1:	f6 c1 03             	test   $0x3,%cl
  801dc4:	75 0a                	jne    801dd0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801dc6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801dc9:	89 c7                	mov    %eax,%edi
  801dcb:	fc                   	cld    
  801dcc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dce:	eb 05                	jmp    801dd5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801dd0:	89 c7                	mov    %eax,%edi
  801dd2:	fc                   	cld    
  801dd3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dd5:	5e                   	pop    %esi
  801dd6:	5f                   	pop    %edi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    

00801dd9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801ddc:	ff 75 10             	pushl  0x10(%ebp)
  801ddf:	ff 75 0c             	pushl  0xc(%ebp)
  801de2:	ff 75 08             	pushl  0x8(%ebp)
  801de5:	e8 87 ff ff ff       	call   801d71 <memmove>
}
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    

00801dec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	56                   	push   %esi
  801df0:	53                   	push   %ebx
  801df1:	8b 45 08             	mov    0x8(%ebp),%eax
  801df4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df7:	89 c6                	mov    %eax,%esi
  801df9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dfc:	eb 1a                	jmp    801e18 <memcmp+0x2c>
		if (*s1 != *s2)
  801dfe:	0f b6 08             	movzbl (%eax),%ecx
  801e01:	0f b6 1a             	movzbl (%edx),%ebx
  801e04:	38 d9                	cmp    %bl,%cl
  801e06:	74 0a                	je     801e12 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e08:	0f b6 c1             	movzbl %cl,%eax
  801e0b:	0f b6 db             	movzbl %bl,%ebx
  801e0e:	29 d8                	sub    %ebx,%eax
  801e10:	eb 0f                	jmp    801e21 <memcmp+0x35>
		s1++, s2++;
  801e12:	83 c0 01             	add    $0x1,%eax
  801e15:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e18:	39 f0                	cmp    %esi,%eax
  801e1a:	75 e2                	jne    801dfe <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e21:	5b                   	pop    %ebx
  801e22:	5e                   	pop    %esi
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    

00801e25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801e2e:	89 c2                	mov    %eax,%edx
  801e30:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e33:	eb 07                	jmp    801e3c <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e35:	38 08                	cmp    %cl,(%eax)
  801e37:	74 07                	je     801e40 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e39:	83 c0 01             	add    $0x1,%eax
  801e3c:	39 d0                	cmp    %edx,%eax
  801e3e:	72 f5                	jb     801e35 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    

00801e42 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	57                   	push   %edi
  801e46:	56                   	push   %esi
  801e47:	53                   	push   %ebx
  801e48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e4e:	eb 03                	jmp    801e53 <strtol+0x11>
		s++;
  801e50:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e53:	0f b6 01             	movzbl (%ecx),%eax
  801e56:	3c 09                	cmp    $0x9,%al
  801e58:	74 f6                	je     801e50 <strtol+0xe>
  801e5a:	3c 20                	cmp    $0x20,%al
  801e5c:	74 f2                	je     801e50 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e5e:	3c 2b                	cmp    $0x2b,%al
  801e60:	75 0a                	jne    801e6c <strtol+0x2a>
		s++;
  801e62:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e65:	bf 00 00 00 00       	mov    $0x0,%edi
  801e6a:	eb 10                	jmp    801e7c <strtol+0x3a>
  801e6c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e71:	3c 2d                	cmp    $0x2d,%al
  801e73:	75 07                	jne    801e7c <strtol+0x3a>
		s++, neg = 1;
  801e75:	8d 49 01             	lea    0x1(%ecx),%ecx
  801e78:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e7c:	85 db                	test   %ebx,%ebx
  801e7e:	0f 94 c0             	sete   %al
  801e81:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e87:	75 19                	jne    801ea2 <strtol+0x60>
  801e89:	80 39 30             	cmpb   $0x30,(%ecx)
  801e8c:	75 14                	jne    801ea2 <strtol+0x60>
  801e8e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e92:	0f 85 82 00 00 00    	jne    801f1a <strtol+0xd8>
		s += 2, base = 16;
  801e98:	83 c1 02             	add    $0x2,%ecx
  801e9b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ea0:	eb 16                	jmp    801eb8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801ea2:	84 c0                	test   %al,%al
  801ea4:	74 12                	je     801eb8 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ea6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801eab:	80 39 30             	cmpb   $0x30,(%ecx)
  801eae:	75 08                	jne    801eb8 <strtol+0x76>
		s++, base = 8;
  801eb0:	83 c1 01             	add    $0x1,%ecx
  801eb3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ec0:	0f b6 11             	movzbl (%ecx),%edx
  801ec3:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ec6:	89 f3                	mov    %esi,%ebx
  801ec8:	80 fb 09             	cmp    $0x9,%bl
  801ecb:	77 08                	ja     801ed5 <strtol+0x93>
			dig = *s - '0';
  801ecd:	0f be d2             	movsbl %dl,%edx
  801ed0:	83 ea 30             	sub    $0x30,%edx
  801ed3:	eb 22                	jmp    801ef7 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  801ed5:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ed8:	89 f3                	mov    %esi,%ebx
  801eda:	80 fb 19             	cmp    $0x19,%bl
  801edd:	77 08                	ja     801ee7 <strtol+0xa5>
			dig = *s - 'a' + 10;
  801edf:	0f be d2             	movsbl %dl,%edx
  801ee2:	83 ea 57             	sub    $0x57,%edx
  801ee5:	eb 10                	jmp    801ef7 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  801ee7:	8d 72 bf             	lea    -0x41(%edx),%esi
  801eea:	89 f3                	mov    %esi,%ebx
  801eec:	80 fb 19             	cmp    $0x19,%bl
  801eef:	77 16                	ja     801f07 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801ef1:	0f be d2             	movsbl %dl,%edx
  801ef4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ef7:	3b 55 10             	cmp    0x10(%ebp),%edx
  801efa:	7d 0f                	jge    801f0b <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801efc:	83 c1 01             	add    $0x1,%ecx
  801eff:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f03:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f05:	eb b9                	jmp    801ec0 <strtol+0x7e>
  801f07:	89 c2                	mov    %eax,%edx
  801f09:	eb 02                	jmp    801f0d <strtol+0xcb>
  801f0b:	89 c2                	mov    %eax,%edx

	if (endptr)
  801f0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f11:	74 0d                	je     801f20 <strtol+0xde>
		*endptr = (char *) s;
  801f13:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f16:	89 0e                	mov    %ecx,(%esi)
  801f18:	eb 06                	jmp    801f20 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f1a:	84 c0                	test   %al,%al
  801f1c:	75 92                	jne    801eb0 <strtol+0x6e>
  801f1e:	eb 98                	jmp    801eb8 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f20:	f7 da                	neg    %edx
  801f22:	85 ff                	test   %edi,%edi
  801f24:	0f 45 c2             	cmovne %edx,%eax
}
  801f27:	5b                   	pop    %ebx
  801f28:	5e                   	pop    %esi
  801f29:	5f                   	pop    %edi
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    

00801f2c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	56                   	push   %esi
  801f30:	53                   	push   %ebx
  801f31:	8b 75 08             	mov    0x8(%ebp),%esi
  801f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f41:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f44:	83 ec 0c             	sub    $0xc,%esp
  801f47:	50                   	push   %eax
  801f48:	e8 cd e3 ff ff       	call   80031a <sys_ipc_recv>
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	85 c0                	test   %eax,%eax
  801f52:	79 16                	jns    801f6a <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801f54:	85 f6                	test   %esi,%esi
  801f56:	74 06                	je     801f5e <ipc_recv+0x32>
  801f58:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801f5e:	85 db                	test   %ebx,%ebx
  801f60:	74 2c                	je     801f8e <ipc_recv+0x62>
  801f62:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f68:	eb 24                	jmp    801f8e <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801f6a:	85 f6                	test   %esi,%esi
  801f6c:	74 0a                	je     801f78 <ipc_recv+0x4c>
  801f6e:	a1 08 40 80 00       	mov    0x804008,%eax
  801f73:	8b 40 74             	mov    0x74(%eax),%eax
  801f76:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801f78:	85 db                	test   %ebx,%ebx
  801f7a:	74 0a                	je     801f86 <ipc_recv+0x5a>
  801f7c:	a1 08 40 80 00       	mov    0x804008,%eax
  801f81:	8b 40 78             	mov    0x78(%eax),%eax
  801f84:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801f86:	a1 08 40 80 00       	mov    0x804008,%eax
  801f8b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f91:	5b                   	pop    %ebx
  801f92:	5e                   	pop    %esi
  801f93:	5d                   	pop    %ebp
  801f94:	c3                   	ret    

00801f95 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	57                   	push   %edi
  801f99:	56                   	push   %esi
  801f9a:	53                   	push   %ebx
  801f9b:	83 ec 0c             	sub    $0xc,%esp
  801f9e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801fa7:	85 db                	test   %ebx,%ebx
  801fa9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fae:	0f 44 d8             	cmove  %eax,%ebx
  801fb1:	eb 1c                	jmp    801fcf <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801fb3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fb6:	74 12                	je     801fca <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801fb8:	50                   	push   %eax
  801fb9:	68 20 28 80 00       	push   $0x802820
  801fbe:	6a 39                	push   $0x39
  801fc0:	68 3b 28 80 00       	push   $0x80283b
  801fc5:	e8 b5 f5 ff ff       	call   80157f <_panic>
                 sys_yield();
  801fca:	e8 7c e1 ff ff       	call   80014b <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801fcf:	ff 75 14             	pushl  0x14(%ebp)
  801fd2:	53                   	push   %ebx
  801fd3:	56                   	push   %esi
  801fd4:	57                   	push   %edi
  801fd5:	e8 1d e3 ff ff       	call   8002f7 <sys_ipc_try_send>
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	78 d2                	js     801fb3 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801fe1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe4:	5b                   	pop    %ebx
  801fe5:	5e                   	pop    %esi
  801fe6:	5f                   	pop    %edi
  801fe7:	5d                   	pop    %ebp
  801fe8:	c3                   	ret    

00801fe9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fef:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ff4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ff7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ffd:	8b 52 50             	mov    0x50(%edx),%edx
  802000:	39 ca                	cmp    %ecx,%edx
  802002:	75 0d                	jne    802011 <ipc_find_env+0x28>
			return envs[i].env_id;
  802004:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802007:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80200c:	8b 40 08             	mov    0x8(%eax),%eax
  80200f:	eb 0e                	jmp    80201f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802011:	83 c0 01             	add    $0x1,%eax
  802014:	3d 00 04 00 00       	cmp    $0x400,%eax
  802019:	75 d9                	jne    801ff4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80201b:	66 b8 00 00          	mov    $0x0,%ax
}
  80201f:	5d                   	pop    %ebp
  802020:	c3                   	ret    

00802021 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802021:	55                   	push   %ebp
  802022:	89 e5                	mov    %esp,%ebp
  802024:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802027:	89 d0                	mov    %edx,%eax
  802029:	c1 e8 16             	shr    $0x16,%eax
  80202c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802033:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802038:	f6 c1 01             	test   $0x1,%cl
  80203b:	74 1d                	je     80205a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80203d:	c1 ea 0c             	shr    $0xc,%edx
  802040:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802047:	f6 c2 01             	test   $0x1,%dl
  80204a:	74 0e                	je     80205a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80204c:	c1 ea 0c             	shr    $0xc,%edx
  80204f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802056:	ef 
  802057:	0f b7 c0             	movzwl %ax,%eax
}
  80205a:	5d                   	pop    %ebp
  80205b:	c3                   	ret    
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	83 ec 10             	sub    $0x10,%esp
  802066:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80206a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80206e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802072:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802076:	85 d2                	test   %edx,%edx
  802078:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80207c:	89 34 24             	mov    %esi,(%esp)
  80207f:	89 c8                	mov    %ecx,%eax
  802081:	75 35                	jne    8020b8 <__udivdi3+0x58>
  802083:	39 f1                	cmp    %esi,%ecx
  802085:	0f 87 bd 00 00 00    	ja     802148 <__udivdi3+0xe8>
  80208b:	85 c9                	test   %ecx,%ecx
  80208d:	89 cd                	mov    %ecx,%ebp
  80208f:	75 0b                	jne    80209c <__udivdi3+0x3c>
  802091:	b8 01 00 00 00       	mov    $0x1,%eax
  802096:	31 d2                	xor    %edx,%edx
  802098:	f7 f1                	div    %ecx
  80209a:	89 c5                	mov    %eax,%ebp
  80209c:	89 f0                	mov    %esi,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f5                	div    %ebp
  8020a2:	89 c6                	mov    %eax,%esi
  8020a4:	89 f8                	mov    %edi,%eax
  8020a6:	f7 f5                	div    %ebp
  8020a8:	89 f2                	mov    %esi,%edx
  8020aa:	83 c4 10             	add    $0x10,%esp
  8020ad:	5e                   	pop    %esi
  8020ae:	5f                   	pop    %edi
  8020af:	5d                   	pop    %ebp
  8020b0:	c3                   	ret    
  8020b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	3b 14 24             	cmp    (%esp),%edx
  8020bb:	77 7b                	ja     802138 <__udivdi3+0xd8>
  8020bd:	0f bd f2             	bsr    %edx,%esi
  8020c0:	83 f6 1f             	xor    $0x1f,%esi
  8020c3:	0f 84 97 00 00 00    	je     802160 <__udivdi3+0x100>
  8020c9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020ce:	89 d7                	mov    %edx,%edi
  8020d0:	89 f1                	mov    %esi,%ecx
  8020d2:	29 f5                	sub    %esi,%ebp
  8020d4:	d3 e7                	shl    %cl,%edi
  8020d6:	89 c2                	mov    %eax,%edx
  8020d8:	89 e9                	mov    %ebp,%ecx
  8020da:	d3 ea                	shr    %cl,%edx
  8020dc:	89 f1                	mov    %esi,%ecx
  8020de:	09 fa                	or     %edi,%edx
  8020e0:	8b 3c 24             	mov    (%esp),%edi
  8020e3:	d3 e0                	shl    %cl,%eax
  8020e5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020e9:	89 e9                	mov    %ebp,%ecx
  8020eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ef:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020f3:	89 fa                	mov    %edi,%edx
  8020f5:	d3 ea                	shr    %cl,%edx
  8020f7:	89 f1                	mov    %esi,%ecx
  8020f9:	d3 e7                	shl    %cl,%edi
  8020fb:	89 e9                	mov    %ebp,%ecx
  8020fd:	d3 e8                	shr    %cl,%eax
  8020ff:	09 c7                	or     %eax,%edi
  802101:	89 f8                	mov    %edi,%eax
  802103:	f7 74 24 08          	divl   0x8(%esp)
  802107:	89 d5                	mov    %edx,%ebp
  802109:	89 c7                	mov    %eax,%edi
  80210b:	f7 64 24 0c          	mull   0xc(%esp)
  80210f:	39 d5                	cmp    %edx,%ebp
  802111:	89 14 24             	mov    %edx,(%esp)
  802114:	72 11                	jb     802127 <__udivdi3+0xc7>
  802116:	8b 54 24 04          	mov    0x4(%esp),%edx
  80211a:	89 f1                	mov    %esi,%ecx
  80211c:	d3 e2                	shl    %cl,%edx
  80211e:	39 c2                	cmp    %eax,%edx
  802120:	73 5e                	jae    802180 <__udivdi3+0x120>
  802122:	3b 2c 24             	cmp    (%esp),%ebp
  802125:	75 59                	jne    802180 <__udivdi3+0x120>
  802127:	8d 47 ff             	lea    -0x1(%edi),%eax
  80212a:	31 f6                	xor    %esi,%esi
  80212c:	89 f2                	mov    %esi,%edx
  80212e:	83 c4 10             	add    $0x10,%esp
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	31 f6                	xor    %esi,%esi
  80213a:	31 c0                	xor    %eax,%eax
  80213c:	89 f2                	mov    %esi,%edx
  80213e:	83 c4 10             	add    $0x10,%esp
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	89 f2                	mov    %esi,%edx
  80214a:	31 f6                	xor    %esi,%esi
  80214c:	89 f8                	mov    %edi,%eax
  80214e:	f7 f1                	div    %ecx
  802150:	89 f2                	mov    %esi,%edx
  802152:	83 c4 10             	add    $0x10,%esp
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802164:	76 0b                	jbe    802171 <__udivdi3+0x111>
  802166:	31 c0                	xor    %eax,%eax
  802168:	3b 14 24             	cmp    (%esp),%edx
  80216b:	0f 83 37 ff ff ff    	jae    8020a8 <__udivdi3+0x48>
  802171:	b8 01 00 00 00       	mov    $0x1,%eax
  802176:	e9 2d ff ff ff       	jmp    8020a8 <__udivdi3+0x48>
  80217b:	90                   	nop
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 f8                	mov    %edi,%eax
  802182:	31 f6                	xor    %esi,%esi
  802184:	e9 1f ff ff ff       	jmp    8020a8 <__udivdi3+0x48>
  802189:	66 90                	xchg   %ax,%ax
  80218b:	66 90                	xchg   %ax,%ax
  80218d:	66 90                	xchg   %ax,%ax
  80218f:	90                   	nop

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	83 ec 20             	sub    $0x20,%esp
  802196:	8b 44 24 34          	mov    0x34(%esp),%eax
  80219a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80219e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a2:	89 c6                	mov    %eax,%esi
  8021a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021a8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021ac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8021b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021b4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021b8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021bc:	85 c0                	test   %eax,%eax
  8021be:	89 c2                	mov    %eax,%edx
  8021c0:	75 1e                	jne    8021e0 <__umoddi3+0x50>
  8021c2:	39 f7                	cmp    %esi,%edi
  8021c4:	76 52                	jbe    802218 <__umoddi3+0x88>
  8021c6:	89 c8                	mov    %ecx,%eax
  8021c8:	89 f2                	mov    %esi,%edx
  8021ca:	f7 f7                	div    %edi
  8021cc:	89 d0                	mov    %edx,%eax
  8021ce:	31 d2                	xor    %edx,%edx
  8021d0:	83 c4 20             	add    $0x20,%esp
  8021d3:	5e                   	pop    %esi
  8021d4:	5f                   	pop    %edi
  8021d5:	5d                   	pop    %ebp
  8021d6:	c3                   	ret    
  8021d7:	89 f6                	mov    %esi,%esi
  8021d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021e0:	39 f0                	cmp    %esi,%eax
  8021e2:	77 5c                	ja     802240 <__umoddi3+0xb0>
  8021e4:	0f bd e8             	bsr    %eax,%ebp
  8021e7:	83 f5 1f             	xor    $0x1f,%ebp
  8021ea:	75 64                	jne    802250 <__umoddi3+0xc0>
  8021ec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8021f0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8021f4:	0f 86 f6 00 00 00    	jbe    8022f0 <__umoddi3+0x160>
  8021fa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8021fe:	0f 82 ec 00 00 00    	jb     8022f0 <__umoddi3+0x160>
  802204:	8b 44 24 14          	mov    0x14(%esp),%eax
  802208:	8b 54 24 18          	mov    0x18(%esp),%edx
  80220c:	83 c4 20             	add    $0x20,%esp
  80220f:	5e                   	pop    %esi
  802210:	5f                   	pop    %edi
  802211:	5d                   	pop    %ebp
  802212:	c3                   	ret    
  802213:	90                   	nop
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	85 ff                	test   %edi,%edi
  80221a:	89 fd                	mov    %edi,%ebp
  80221c:	75 0b                	jne    802229 <__umoddi3+0x99>
  80221e:	b8 01 00 00 00       	mov    $0x1,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f7                	div    %edi
  802227:	89 c5                	mov    %eax,%ebp
  802229:	8b 44 24 10          	mov    0x10(%esp),%eax
  80222d:	31 d2                	xor    %edx,%edx
  80222f:	f7 f5                	div    %ebp
  802231:	89 c8                	mov    %ecx,%eax
  802233:	f7 f5                	div    %ebp
  802235:	eb 95                	jmp    8021cc <__umoddi3+0x3c>
  802237:	89 f6                	mov    %esi,%esi
  802239:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 20             	add    $0x20,%esp
  802247:	5e                   	pop    %esi
  802248:	5f                   	pop    %edi
  802249:	5d                   	pop    %ebp
  80224a:	c3                   	ret    
  80224b:	90                   	nop
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	b8 20 00 00 00       	mov    $0x20,%eax
  802255:	89 e9                	mov    %ebp,%ecx
  802257:	29 e8                	sub    %ebp,%eax
  802259:	d3 e2                	shl    %cl,%edx
  80225b:	89 c7                	mov    %eax,%edi
  80225d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802261:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802265:	89 f9                	mov    %edi,%ecx
  802267:	d3 e8                	shr    %cl,%eax
  802269:	89 c1                	mov    %eax,%ecx
  80226b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80226f:	09 d1                	or     %edx,%ecx
  802271:	89 fa                	mov    %edi,%edx
  802273:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802277:	89 e9                	mov    %ebp,%ecx
  802279:	d3 e0                	shl    %cl,%eax
  80227b:	89 f9                	mov    %edi,%ecx
  80227d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802281:	89 f0                	mov    %esi,%eax
  802283:	d3 e8                	shr    %cl,%eax
  802285:	89 e9                	mov    %ebp,%ecx
  802287:	89 c7                	mov    %eax,%edi
  802289:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80228d:	d3 e6                	shl    %cl,%esi
  80228f:	89 d1                	mov    %edx,%ecx
  802291:	89 fa                	mov    %edi,%edx
  802293:	d3 e8                	shr    %cl,%eax
  802295:	89 e9                	mov    %ebp,%ecx
  802297:	09 f0                	or     %esi,%eax
  802299:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80229d:	f7 74 24 10          	divl   0x10(%esp)
  8022a1:	d3 e6                	shl    %cl,%esi
  8022a3:	89 d1                	mov    %edx,%ecx
  8022a5:	f7 64 24 0c          	mull   0xc(%esp)
  8022a9:	39 d1                	cmp    %edx,%ecx
  8022ab:	89 74 24 14          	mov    %esi,0x14(%esp)
  8022af:	89 d7                	mov    %edx,%edi
  8022b1:	89 c6                	mov    %eax,%esi
  8022b3:	72 0a                	jb     8022bf <__umoddi3+0x12f>
  8022b5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8022b9:	73 10                	jae    8022cb <__umoddi3+0x13b>
  8022bb:	39 d1                	cmp    %edx,%ecx
  8022bd:	75 0c                	jne    8022cb <__umoddi3+0x13b>
  8022bf:	89 d7                	mov    %edx,%edi
  8022c1:	89 c6                	mov    %eax,%esi
  8022c3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8022c7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8022cb:	89 ca                	mov    %ecx,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022d3:	29 f0                	sub    %esi,%eax
  8022d5:	19 fa                	sbb    %edi,%edx
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8022de:	89 d7                	mov    %edx,%edi
  8022e0:	d3 e7                	shl    %cl,%edi
  8022e2:	89 e9                	mov    %ebp,%ecx
  8022e4:	09 f8                	or     %edi,%eax
  8022e6:	d3 ea                	shr    %cl,%edx
  8022e8:	83 c4 20             	add    $0x20,%esp
  8022eb:	5e                   	pop    %esi
  8022ec:	5f                   	pop    %edi
  8022ed:	5d                   	pop    %ebp
  8022ee:	c3                   	ret    
  8022ef:	90                   	nop
  8022f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022f4:	29 f9                	sub    %edi,%ecx
  8022f6:	19 c6                	sbb    %eax,%esi
  8022f8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8022fc:	89 74 24 18          	mov    %esi,0x18(%esp)
  802300:	e9 ff fe ff ff       	jmp    802204 <__umoddi3+0x74>
