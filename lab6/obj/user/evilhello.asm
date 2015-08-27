
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 65 00 00 00       	call   8000aa <sys_cputs>
  800045:	83 c4 10             	add    $0x10,%esp
}
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
  800086:	83 c4 10             	add    $0x10,%esp
}
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 2f 05 00 00       	call   8005ca <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
  8000a5:	83 c4 10             	add    $0x10,%esp
}
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 4a 23 80 00       	push   $0x80234a
  800114:	6a 22                	push   $0x22
  800116:	68 67 23 80 00       	push   $0x802367
  80011b:	e8 5b 14 00 00       	call   80157b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{      
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 4a 23 80 00       	push   $0x80234a
  800195:	6a 22                	push   $0x22
  800197:	68 67 23 80 00       	push   $0x802367
  80019c:	e8 da 13 00 00       	call   80157b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 4a 23 80 00       	push   $0x80234a
  8001d7:	6a 22                	push   $0x22
  8001d9:	68 67 23 80 00       	push   $0x802367
  8001de:	e8 98 13 00 00       	call   80157b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 4a 23 80 00       	push   $0x80234a
  800219:	6a 22                	push   $0x22
  80021b:	68 67 23 80 00       	push   $0x802367
  800220:	e8 56 13 00 00       	call   80157b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 4a 23 80 00       	push   $0x80234a
  80025b:	6a 22                	push   $0x22
  80025d:	68 67 23 80 00       	push   $0x802367
  800262:	e8 14 13 00 00       	call   80157b <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 4a 23 80 00       	push   $0x80234a
  80029d:	6a 22                	push   $0x22
  80029f:	68 67 23 80 00       	push   $0x802367
  8002a4:	e8 d2 12 00 00       	call   80157b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 4a 23 80 00       	push   $0x80234a
  8002df:	6a 22                	push   $0x22
  8002e1:	68 67 23 80 00       	push   $0x802367
  8002e6:	e8 90 12 00 00       	call   80157b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 4a 23 80 00       	push   $0x80234a
  800343:	6a 22                	push   $0x22
  800345:	68 67 23 80 00       	push   $0x802367
  80034a:	e8 2c 12 00 00       	call   80157b <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	57                   	push   %edi
  80035b:	56                   	push   %esi
  80035c:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	b8 0e 00 00 00       	mov    $0xe,%eax
  800367:	89 d1                	mov    %edx,%ecx
  800369:	89 d3                	mov    %edx,%ebx
  80036b:	89 d7                	mov    %edx,%edi
  80036d:	89 d6                	mov    %edx,%esi
  80036f:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	57                   	push   %edi
  80037a:	56                   	push   %esi
  80037b:	53                   	push   %ebx
  80037c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80037f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800384:	b8 0f 00 00 00       	mov    $0xf,%eax
  800389:	8b 55 08             	mov    0x8(%ebp),%edx
  80038c:	89 cb                	mov    %ecx,%ebx
  80038e:	89 cf                	mov    %ecx,%edi
  800390:	89 ce                	mov    %ecx,%esi
  800392:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800394:	85 c0                	test   %eax,%eax
  800396:	7e 17                	jle    8003af <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800398:	83 ec 0c             	sub    $0xc,%esp
  80039b:	50                   	push   %eax
  80039c:	6a 0f                	push   $0xf
  80039e:	68 4a 23 80 00       	push   $0x80234a
  8003a3:	6a 22                	push   $0x22
  8003a5:	68 67 23 80 00       	push   $0x802367
  8003aa:	e8 cc 11 00 00       	call   80157b <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b2:	5b                   	pop    %ebx
  8003b3:	5e                   	pop    %esi
  8003b4:	5f                   	pop    %edi
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <sys_recv>:

int
sys_recv(void *addr)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	57                   	push   %edi
  8003bb:	56                   	push   %esi
  8003bc:	53                   	push   %ebx
  8003bd:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8003c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c5:	b8 10 00 00 00       	mov    $0x10,%eax
  8003ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8003cd:	89 cb                	mov    %ecx,%ebx
  8003cf:	89 cf                	mov    %ecx,%edi
  8003d1:	89 ce                	mov    %ecx,%esi
  8003d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003d5:	85 c0                	test   %eax,%eax
  8003d7:	7e 17                	jle    8003f0 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d9:	83 ec 0c             	sub    $0xc,%esp
  8003dc:	50                   	push   %eax
  8003dd:	6a 10                	push   $0x10
  8003df:	68 4a 23 80 00       	push   $0x80234a
  8003e4:	6a 22                	push   $0x22
  8003e6:	68 67 23 80 00       	push   $0x802367
  8003eb:	e8 8b 11 00 00       	call   80157b <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f3:	5b                   	pop    %ebx
  8003f4:	5e                   	pop    %esi
  8003f5:	5f                   	pop    %edi
  8003f6:	5d                   	pop    %ebp
  8003f7:	c3                   	ret    

008003f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	05 00 00 00 30       	add    $0x30000000,%eax
  800403:	c1 e8 0c             	shr    $0xc,%eax
}
  800406:	5d                   	pop    %ebp
  800407:	c3                   	ret    

00800408 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80040b:	8b 45 08             	mov    0x8(%ebp),%eax
  80040e:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800413:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800418:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800425:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80042a:	89 c2                	mov    %eax,%edx
  80042c:	c1 ea 16             	shr    $0x16,%edx
  80042f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800436:	f6 c2 01             	test   $0x1,%dl
  800439:	74 11                	je     80044c <fd_alloc+0x2d>
  80043b:	89 c2                	mov    %eax,%edx
  80043d:	c1 ea 0c             	shr    $0xc,%edx
  800440:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800447:	f6 c2 01             	test   $0x1,%dl
  80044a:	75 09                	jne    800455 <fd_alloc+0x36>
			*fd_store = fd;
  80044c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	eb 17                	jmp    80046c <fd_alloc+0x4d>
  800455:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80045a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80045f:	75 c9                	jne    80042a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800461:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800467:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800474:	83 f8 1f             	cmp    $0x1f,%eax
  800477:	77 36                	ja     8004af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800479:	c1 e0 0c             	shl    $0xc,%eax
  80047c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800481:	89 c2                	mov    %eax,%edx
  800483:	c1 ea 16             	shr    $0x16,%edx
  800486:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80048d:	f6 c2 01             	test   $0x1,%dl
  800490:	74 24                	je     8004b6 <fd_lookup+0x48>
  800492:	89 c2                	mov    %eax,%edx
  800494:	c1 ea 0c             	shr    $0xc,%edx
  800497:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80049e:	f6 c2 01             	test   $0x1,%dl
  8004a1:	74 1a                	je     8004bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8004a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ad:	eb 13                	jmp    8004c2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b4:	eb 0c                	jmp    8004c2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004bb:	eb 05                	jmp    8004c2 <fd_lookup+0x54>
  8004bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004c2:	5d                   	pop    %ebp
  8004c3:	c3                   	ret    

008004c4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8004cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d2:	eb 13                	jmp    8004e7 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8004d4:	39 08                	cmp    %ecx,(%eax)
  8004d6:	75 0c                	jne    8004e4 <dev_lookup+0x20>
			*dev = devtab[i];
  8004d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004db:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e2:	eb 36                	jmp    80051a <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004e4:	83 c2 01             	add    $0x1,%edx
  8004e7:	8b 04 95 f4 23 80 00 	mov    0x8023f4(,%edx,4),%eax
  8004ee:	85 c0                	test   %eax,%eax
  8004f0:	75 e2                	jne    8004d4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004f2:	a1 08 40 80 00       	mov    0x804008,%eax
  8004f7:	8b 40 48             	mov    0x48(%eax),%eax
  8004fa:	83 ec 04             	sub    $0x4,%esp
  8004fd:	51                   	push   %ecx
  8004fe:	50                   	push   %eax
  8004ff:	68 78 23 80 00       	push   $0x802378
  800504:	e8 4b 11 00 00       	call   801654 <cprintf>
	*dev = 0;
  800509:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80051a:	c9                   	leave  
  80051b:	c3                   	ret    

0080051c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	56                   	push   %esi
  800520:	53                   	push   %ebx
  800521:	83 ec 10             	sub    $0x10,%esp
  800524:	8b 75 08             	mov    0x8(%ebp),%esi
  800527:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80052a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80052d:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80052e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800534:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800537:	50                   	push   %eax
  800538:	e8 31 ff ff ff       	call   80046e <fd_lookup>
  80053d:	83 c4 08             	add    $0x8,%esp
  800540:	85 c0                	test   %eax,%eax
  800542:	78 05                	js     800549 <fd_close+0x2d>
	    || fd != fd2)
  800544:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800547:	74 0c                	je     800555 <fd_close+0x39>
		return (must_exist ? r : 0);
  800549:	84 db                	test   %bl,%bl
  80054b:	ba 00 00 00 00       	mov    $0x0,%edx
  800550:	0f 44 c2             	cmove  %edx,%eax
  800553:	eb 41                	jmp    800596 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80055b:	50                   	push   %eax
  80055c:	ff 36                	pushl  (%esi)
  80055e:	e8 61 ff ff ff       	call   8004c4 <dev_lookup>
  800563:	89 c3                	mov    %eax,%ebx
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	85 c0                	test   %eax,%eax
  80056a:	78 1a                	js     800586 <fd_close+0x6a>
		if (dev->dev_close)
  80056c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80056f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800572:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800577:	85 c0                	test   %eax,%eax
  800579:	74 0b                	je     800586 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80057b:	83 ec 0c             	sub    $0xc,%esp
  80057e:	56                   	push   %esi
  80057f:	ff d0                	call   *%eax
  800581:	89 c3                	mov    %eax,%ebx
  800583:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	56                   	push   %esi
  80058a:	6a 00                	push   $0x0
  80058c:	e8 5a fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800591:	83 c4 10             	add    $0x10,%esp
  800594:	89 d8                	mov    %ebx,%eax
}
  800596:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800599:	5b                   	pop    %ebx
  80059a:	5e                   	pop    %esi
  80059b:	5d                   	pop    %ebp
  80059c:	c3                   	ret    

0080059d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80059d:	55                   	push   %ebp
  80059e:	89 e5                	mov    %esp,%ebp
  8005a0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005a6:	50                   	push   %eax
  8005a7:	ff 75 08             	pushl  0x8(%ebp)
  8005aa:	e8 bf fe ff ff       	call   80046e <fd_lookup>
  8005af:	89 c2                	mov    %eax,%edx
  8005b1:	83 c4 08             	add    $0x8,%esp
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	78 10                	js     8005c8 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	6a 01                	push   $0x1
  8005bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8005c0:	e8 57 ff ff ff       	call   80051c <fd_close>
  8005c5:	83 c4 10             	add    $0x10,%esp
}
  8005c8:	c9                   	leave  
  8005c9:	c3                   	ret    

008005ca <close_all>:

void
close_all(void)
{
  8005ca:	55                   	push   %ebp
  8005cb:	89 e5                	mov    %esp,%ebp
  8005cd:	53                   	push   %ebx
  8005ce:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005d6:	83 ec 0c             	sub    $0xc,%esp
  8005d9:	53                   	push   %ebx
  8005da:	e8 be ff ff ff       	call   80059d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005df:	83 c3 01             	add    $0x1,%ebx
  8005e2:	83 c4 10             	add    $0x10,%esp
  8005e5:	83 fb 20             	cmp    $0x20,%ebx
  8005e8:	75 ec                	jne    8005d6 <close_all+0xc>
		close(i);
}
  8005ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005ed:	c9                   	leave  
  8005ee:	c3                   	ret    

008005ef <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005ef:	55                   	push   %ebp
  8005f0:	89 e5                	mov    %esp,%ebp
  8005f2:	57                   	push   %edi
  8005f3:	56                   	push   %esi
  8005f4:	53                   	push   %ebx
  8005f5:	83 ec 2c             	sub    $0x2c,%esp
  8005f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005fe:	50                   	push   %eax
  8005ff:	ff 75 08             	pushl  0x8(%ebp)
  800602:	e8 67 fe ff ff       	call   80046e <fd_lookup>
  800607:	89 c2                	mov    %eax,%edx
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	85 d2                	test   %edx,%edx
  80060e:	0f 88 c1 00 00 00    	js     8006d5 <dup+0xe6>
		return r;
	close(newfdnum);
  800614:	83 ec 0c             	sub    $0xc,%esp
  800617:	56                   	push   %esi
  800618:	e8 80 ff ff ff       	call   80059d <close>

	newfd = INDEX2FD(newfdnum);
  80061d:	89 f3                	mov    %esi,%ebx
  80061f:	c1 e3 0c             	shl    $0xc,%ebx
  800622:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800628:	83 c4 04             	add    $0x4,%esp
  80062b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80062e:	e8 d5 fd ff ff       	call   800408 <fd2data>
  800633:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800635:	89 1c 24             	mov    %ebx,(%esp)
  800638:	e8 cb fd ff ff       	call   800408 <fd2data>
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800643:	89 f8                	mov    %edi,%eax
  800645:	c1 e8 16             	shr    $0x16,%eax
  800648:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80064f:	a8 01                	test   $0x1,%al
  800651:	74 37                	je     80068a <dup+0x9b>
  800653:	89 f8                	mov    %edi,%eax
  800655:	c1 e8 0c             	shr    $0xc,%eax
  800658:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80065f:	f6 c2 01             	test   $0x1,%dl
  800662:	74 26                	je     80068a <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800664:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80066b:	83 ec 0c             	sub    $0xc,%esp
  80066e:	25 07 0e 00 00       	and    $0xe07,%eax
  800673:	50                   	push   %eax
  800674:	ff 75 d4             	pushl  -0x2c(%ebp)
  800677:	6a 00                	push   $0x0
  800679:	57                   	push   %edi
  80067a:	6a 00                	push   $0x0
  80067c:	e8 28 fb ff ff       	call   8001a9 <sys_page_map>
  800681:	89 c7                	mov    %eax,%edi
  800683:	83 c4 20             	add    $0x20,%esp
  800686:	85 c0                	test   %eax,%eax
  800688:	78 2e                	js     8006b8 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80068a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80068d:	89 d0                	mov    %edx,%eax
  80068f:	c1 e8 0c             	shr    $0xc,%eax
  800692:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800699:	83 ec 0c             	sub    $0xc,%esp
  80069c:	25 07 0e 00 00       	and    $0xe07,%eax
  8006a1:	50                   	push   %eax
  8006a2:	53                   	push   %ebx
  8006a3:	6a 00                	push   $0x0
  8006a5:	52                   	push   %edx
  8006a6:	6a 00                	push   $0x0
  8006a8:	e8 fc fa ff ff       	call   8001a9 <sys_page_map>
  8006ad:	89 c7                	mov    %eax,%edi
  8006af:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006b2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006b4:	85 ff                	test   %edi,%edi
  8006b6:	79 1d                	jns    8006d5 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	53                   	push   %ebx
  8006bc:	6a 00                	push   $0x0
  8006be:	e8 28 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006c3:	83 c4 08             	add    $0x8,%esp
  8006c6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006c9:	6a 00                	push   $0x0
  8006cb:	e8 1b fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	89 f8                	mov    %edi,%eax
}
  8006d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d8:	5b                   	pop    %ebx
  8006d9:	5e                   	pop    %esi
  8006da:	5f                   	pop    %edi
  8006db:	5d                   	pop    %ebp
  8006dc:	c3                   	ret    

008006dd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	53                   	push   %ebx
  8006e1:	83 ec 14             	sub    $0x14,%esp
  8006e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006ea:	50                   	push   %eax
  8006eb:	53                   	push   %ebx
  8006ec:	e8 7d fd ff ff       	call   80046e <fd_lookup>
  8006f1:	83 c4 08             	add    $0x8,%esp
  8006f4:	89 c2                	mov    %eax,%edx
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	78 6d                	js     800767 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800700:	50                   	push   %eax
  800701:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800704:	ff 30                	pushl  (%eax)
  800706:	e8 b9 fd ff ff       	call   8004c4 <dev_lookup>
  80070b:	83 c4 10             	add    $0x10,%esp
  80070e:	85 c0                	test   %eax,%eax
  800710:	78 4c                	js     80075e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800712:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800715:	8b 42 08             	mov    0x8(%edx),%eax
  800718:	83 e0 03             	and    $0x3,%eax
  80071b:	83 f8 01             	cmp    $0x1,%eax
  80071e:	75 21                	jne    800741 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800720:	a1 08 40 80 00       	mov    0x804008,%eax
  800725:	8b 40 48             	mov    0x48(%eax),%eax
  800728:	83 ec 04             	sub    $0x4,%esp
  80072b:	53                   	push   %ebx
  80072c:	50                   	push   %eax
  80072d:	68 b9 23 80 00       	push   $0x8023b9
  800732:	e8 1d 0f 00 00       	call   801654 <cprintf>
		return -E_INVAL;
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80073f:	eb 26                	jmp    800767 <read+0x8a>
	}
	if (!dev->dev_read)
  800741:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800744:	8b 40 08             	mov    0x8(%eax),%eax
  800747:	85 c0                	test   %eax,%eax
  800749:	74 17                	je     800762 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80074b:	83 ec 04             	sub    $0x4,%esp
  80074e:	ff 75 10             	pushl  0x10(%ebp)
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	52                   	push   %edx
  800755:	ff d0                	call   *%eax
  800757:	89 c2                	mov    %eax,%edx
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	eb 09                	jmp    800767 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80075e:	89 c2                	mov    %eax,%edx
  800760:	eb 05                	jmp    800767 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800762:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800767:	89 d0                	mov    %edx,%eax
  800769:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	57                   	push   %edi
  800772:	56                   	push   %esi
  800773:	53                   	push   %ebx
  800774:	83 ec 0c             	sub    $0xc,%esp
  800777:	8b 7d 08             	mov    0x8(%ebp),%edi
  80077a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80077d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800782:	eb 21                	jmp    8007a5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800784:	83 ec 04             	sub    $0x4,%esp
  800787:	89 f0                	mov    %esi,%eax
  800789:	29 d8                	sub    %ebx,%eax
  80078b:	50                   	push   %eax
  80078c:	89 d8                	mov    %ebx,%eax
  80078e:	03 45 0c             	add    0xc(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	57                   	push   %edi
  800793:	e8 45 ff ff ff       	call   8006dd <read>
		if (m < 0)
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	85 c0                	test   %eax,%eax
  80079d:	78 0c                	js     8007ab <readn+0x3d>
			return m;
		if (m == 0)
  80079f:	85 c0                	test   %eax,%eax
  8007a1:	74 06                	je     8007a9 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007a3:	01 c3                	add    %eax,%ebx
  8007a5:	39 f3                	cmp    %esi,%ebx
  8007a7:	72 db                	jb     800784 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8007a9:	89 d8                	mov    %ebx,%eax
}
  8007ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5f                   	pop    %edi
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	83 ec 14             	sub    $0x14,%esp
  8007ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c0:	50                   	push   %eax
  8007c1:	53                   	push   %ebx
  8007c2:	e8 a7 fc ff ff       	call   80046e <fd_lookup>
  8007c7:	83 c4 08             	add    $0x8,%esp
  8007ca:	89 c2                	mov    %eax,%edx
  8007cc:	85 c0                	test   %eax,%eax
  8007ce:	78 68                	js     800838 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d6:	50                   	push   %eax
  8007d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007da:	ff 30                	pushl  (%eax)
  8007dc:	e8 e3 fc ff ff       	call   8004c4 <dev_lookup>
  8007e1:	83 c4 10             	add    $0x10,%esp
  8007e4:	85 c0                	test   %eax,%eax
  8007e6:	78 47                	js     80082f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007eb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ef:	75 21                	jne    800812 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007f1:	a1 08 40 80 00       	mov    0x804008,%eax
  8007f6:	8b 40 48             	mov    0x48(%eax),%eax
  8007f9:	83 ec 04             	sub    $0x4,%esp
  8007fc:	53                   	push   %ebx
  8007fd:	50                   	push   %eax
  8007fe:	68 d5 23 80 00       	push   $0x8023d5
  800803:	e8 4c 0e 00 00       	call   801654 <cprintf>
		return -E_INVAL;
  800808:	83 c4 10             	add    $0x10,%esp
  80080b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800810:	eb 26                	jmp    800838 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800812:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800815:	8b 52 0c             	mov    0xc(%edx),%edx
  800818:	85 d2                	test   %edx,%edx
  80081a:	74 17                	je     800833 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80081c:	83 ec 04             	sub    $0x4,%esp
  80081f:	ff 75 10             	pushl  0x10(%ebp)
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	50                   	push   %eax
  800826:	ff d2                	call   *%edx
  800828:	89 c2                	mov    %eax,%edx
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	eb 09                	jmp    800838 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	89 c2                	mov    %eax,%edx
  800831:	eb 05                	jmp    800838 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800833:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800838:	89 d0                	mov    %edx,%eax
  80083a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <seek>:

int
seek(int fdnum, off_t offset)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800845:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	ff 75 08             	pushl  0x8(%ebp)
  80084c:	e8 1d fc ff ff       	call   80046e <fd_lookup>
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	85 c0                	test   %eax,%eax
  800856:	78 0e                	js     800866 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800858:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800866:	c9                   	leave  
  800867:	c3                   	ret    

00800868 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	83 ec 14             	sub    $0x14,%esp
  80086f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800872:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800875:	50                   	push   %eax
  800876:	53                   	push   %ebx
  800877:	e8 f2 fb ff ff       	call   80046e <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	89 c2                	mov    %eax,%edx
  800881:	85 c0                	test   %eax,%eax
  800883:	78 65                	js     8008ea <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088f:	ff 30                	pushl  (%eax)
  800891:	e8 2e fc ff ff       	call   8004c4 <dev_lookup>
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 44                	js     8008e1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80089d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008a4:	75 21                	jne    8008c7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008a6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008ab:	8b 40 48             	mov    0x48(%eax),%eax
  8008ae:	83 ec 04             	sub    $0x4,%esp
  8008b1:	53                   	push   %ebx
  8008b2:	50                   	push   %eax
  8008b3:	68 98 23 80 00       	push   $0x802398
  8008b8:	e8 97 0d 00 00       	call   801654 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008bd:	83 c4 10             	add    $0x10,%esp
  8008c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008c5:	eb 23                	jmp    8008ea <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008ca:	8b 52 18             	mov    0x18(%edx),%edx
  8008cd:	85 d2                	test   %edx,%edx
  8008cf:	74 14                	je     8008e5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008d1:	83 ec 08             	sub    $0x8,%esp
  8008d4:	ff 75 0c             	pushl  0xc(%ebp)
  8008d7:	50                   	push   %eax
  8008d8:	ff d2                	call   *%edx
  8008da:	89 c2                	mov    %eax,%edx
  8008dc:	83 c4 10             	add    $0x10,%esp
  8008df:	eb 09                	jmp    8008ea <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e1:	89 c2                	mov    %eax,%edx
  8008e3:	eb 05                	jmp    8008ea <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008ea:	89 d0                	mov    %edx,%eax
  8008ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	83 ec 14             	sub    $0x14,%esp
  8008f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008fe:	50                   	push   %eax
  8008ff:	ff 75 08             	pushl  0x8(%ebp)
  800902:	e8 67 fb ff ff       	call   80046e <fd_lookup>
  800907:	83 c4 08             	add    $0x8,%esp
  80090a:	89 c2                	mov    %eax,%edx
  80090c:	85 c0                	test   %eax,%eax
  80090e:	78 58                	js     800968 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800916:	50                   	push   %eax
  800917:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80091a:	ff 30                	pushl  (%eax)
  80091c:	e8 a3 fb ff ff       	call   8004c4 <dev_lookup>
  800921:	83 c4 10             	add    $0x10,%esp
  800924:	85 c0                	test   %eax,%eax
  800926:	78 37                	js     80095f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800928:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80092b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80092f:	74 32                	je     800963 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800931:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800934:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80093b:	00 00 00 
	stat->st_isdir = 0;
  80093e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800945:	00 00 00 
	stat->st_dev = dev;
  800948:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80094e:	83 ec 08             	sub    $0x8,%esp
  800951:	53                   	push   %ebx
  800952:	ff 75 f0             	pushl  -0x10(%ebp)
  800955:	ff 50 14             	call   *0x14(%eax)
  800958:	89 c2                	mov    %eax,%edx
  80095a:	83 c4 10             	add    $0x10,%esp
  80095d:	eb 09                	jmp    800968 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80095f:	89 c2                	mov    %eax,%edx
  800961:	eb 05                	jmp    800968 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800963:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800968:	89 d0                	mov    %edx,%eax
  80096a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	56                   	push   %esi
  800973:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800974:	83 ec 08             	sub    $0x8,%esp
  800977:	6a 00                	push   $0x0
  800979:	ff 75 08             	pushl  0x8(%ebp)
  80097c:	e8 09 02 00 00       	call   800b8a <open>
  800981:	89 c3                	mov    %eax,%ebx
  800983:	83 c4 10             	add    $0x10,%esp
  800986:	85 db                	test   %ebx,%ebx
  800988:	78 1b                	js     8009a5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80098a:	83 ec 08             	sub    $0x8,%esp
  80098d:	ff 75 0c             	pushl  0xc(%ebp)
  800990:	53                   	push   %ebx
  800991:	e8 5b ff ff ff       	call   8008f1 <fstat>
  800996:	89 c6                	mov    %eax,%esi
	close(fd);
  800998:	89 1c 24             	mov    %ebx,(%esp)
  80099b:	e8 fd fb ff ff       	call   80059d <close>
	return r;
  8009a0:	83 c4 10             	add    $0x10,%esp
  8009a3:	89 f0                	mov    %esi,%eax
}
  8009a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	89 c6                	mov    %eax,%esi
  8009b3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009b5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009bc:	75 12                	jne    8009d0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009be:	83 ec 0c             	sub    $0xc,%esp
  8009c1:	6a 01                	push   $0x1
  8009c3:	e8 1d 16 00 00       	call   801fe5 <ipc_find_env>
  8009c8:	a3 00 40 80 00       	mov    %eax,0x804000
  8009cd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009d0:	6a 07                	push   $0x7
  8009d2:	68 00 50 80 00       	push   $0x805000
  8009d7:	56                   	push   %esi
  8009d8:	ff 35 00 40 80 00    	pushl  0x804000
  8009de:	e8 ae 15 00 00       	call   801f91 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009e3:	83 c4 0c             	add    $0xc,%esp
  8009e6:	6a 00                	push   $0x0
  8009e8:	53                   	push   %ebx
  8009e9:	6a 00                	push   $0x0
  8009eb:	e8 38 15 00 00       	call   801f28 <ipc_recv>
}
  8009f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f3:	5b                   	pop    %ebx
  8009f4:	5e                   	pop    %esi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8b 40 0c             	mov    0xc(%eax),%eax
  800a03:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a10:	ba 00 00 00 00       	mov    $0x0,%edx
  800a15:	b8 02 00 00 00       	mov    $0x2,%eax
  800a1a:	e8 8d ff ff ff       	call   8009ac <fsipc>
}
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a32:	ba 00 00 00 00       	mov    $0x0,%edx
  800a37:	b8 06 00 00 00       	mov    $0x6,%eax
  800a3c:	e8 6b ff ff ff       	call   8009ac <fsipc>
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	53                   	push   %ebx
  800a47:	83 ec 04             	sub    $0x4,%esp
  800a4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	8b 40 0c             	mov    0xc(%eax),%eax
  800a53:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a58:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5d:	b8 05 00 00 00       	mov    $0x5,%eax
  800a62:	e8 45 ff ff ff       	call   8009ac <fsipc>
  800a67:	89 c2                	mov    %eax,%edx
  800a69:	85 d2                	test   %edx,%edx
  800a6b:	78 2c                	js     800a99 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a6d:	83 ec 08             	sub    $0x8,%esp
  800a70:	68 00 50 80 00       	push   $0x805000
  800a75:	53                   	push   %ebx
  800a76:	e8 60 11 00 00       	call   801bdb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a7b:	a1 80 50 80 00       	mov    0x805080,%eax
  800a80:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a86:	a1 84 50 80 00       	mov    0x805084,%eax
  800a8b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a91:	83 c4 10             	add    $0x10,%esp
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9c:	c9                   	leave  
  800a9d:	c3                   	ret    

00800a9e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	83 ec 0c             	sub    $0xc,%esp
  800aa7:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab0:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800ab5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800ab8:	eb 3d                	jmp    800af7 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800aba:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800ac0:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800ac5:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800ac8:	83 ec 04             	sub    $0x4,%esp
  800acb:	57                   	push   %edi
  800acc:	53                   	push   %ebx
  800acd:	68 08 50 80 00       	push   $0x805008
  800ad2:	e8 96 12 00 00       	call   801d6d <memmove>
                fsipcbuf.write.req_n = tmp; 
  800ad7:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ae7:	e8 c0 fe ff ff       	call   8009ac <fsipc>
  800aec:	83 c4 10             	add    $0x10,%esp
  800aef:	85 c0                	test   %eax,%eax
  800af1:	78 0d                	js     800b00 <devfile_write+0x62>
		        return r;
                n -= tmp;
  800af3:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800af5:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800af7:	85 f6                	test   %esi,%esi
  800af9:	75 bf                	jne    800aba <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800afb:	89 d8                	mov    %ebx,%eax
  800afd:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800b00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5f                   	pop    %edi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	8b 40 0c             	mov    0xc(%eax),%eax
  800b16:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b1b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2b:	e8 7c fe ff ff       	call   8009ac <fsipc>
  800b30:	89 c3                	mov    %eax,%ebx
  800b32:	85 c0                	test   %eax,%eax
  800b34:	78 4b                	js     800b81 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b36:	39 c6                	cmp    %eax,%esi
  800b38:	73 16                	jae    800b50 <devfile_read+0x48>
  800b3a:	68 08 24 80 00       	push   $0x802408
  800b3f:	68 0f 24 80 00       	push   $0x80240f
  800b44:	6a 7c                	push   $0x7c
  800b46:	68 24 24 80 00       	push   $0x802424
  800b4b:	e8 2b 0a 00 00       	call   80157b <_panic>
	assert(r <= PGSIZE);
  800b50:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b55:	7e 16                	jle    800b6d <devfile_read+0x65>
  800b57:	68 2f 24 80 00       	push   $0x80242f
  800b5c:	68 0f 24 80 00       	push   $0x80240f
  800b61:	6a 7d                	push   $0x7d
  800b63:	68 24 24 80 00       	push   $0x802424
  800b68:	e8 0e 0a 00 00       	call   80157b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b6d:	83 ec 04             	sub    $0x4,%esp
  800b70:	50                   	push   %eax
  800b71:	68 00 50 80 00       	push   $0x805000
  800b76:	ff 75 0c             	pushl  0xc(%ebp)
  800b79:	e8 ef 11 00 00       	call   801d6d <memmove>
	return r;
  800b7e:	83 c4 10             	add    $0x10,%esp
}
  800b81:	89 d8                	mov    %ebx,%eax
  800b83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	53                   	push   %ebx
  800b8e:	83 ec 20             	sub    $0x20,%esp
  800b91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b94:	53                   	push   %ebx
  800b95:	e8 08 10 00 00       	call   801ba2 <strlen>
  800b9a:	83 c4 10             	add    $0x10,%esp
  800b9d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ba2:	7f 67                	jg     800c0b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800baa:	50                   	push   %eax
  800bab:	e8 6f f8 ff ff       	call   80041f <fd_alloc>
  800bb0:	83 c4 10             	add    $0x10,%esp
		return r;
  800bb3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	78 57                	js     800c10 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bb9:	83 ec 08             	sub    $0x8,%esp
  800bbc:	53                   	push   %ebx
  800bbd:	68 00 50 80 00       	push   $0x805000
  800bc2:	e8 14 10 00 00       	call   801bdb <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bca:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bcf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bd2:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd7:	e8 d0 fd ff ff       	call   8009ac <fsipc>
  800bdc:	89 c3                	mov    %eax,%ebx
  800bde:	83 c4 10             	add    $0x10,%esp
  800be1:	85 c0                	test   %eax,%eax
  800be3:	79 14                	jns    800bf9 <open+0x6f>
		fd_close(fd, 0);
  800be5:	83 ec 08             	sub    $0x8,%esp
  800be8:	6a 00                	push   $0x0
  800bea:	ff 75 f4             	pushl  -0xc(%ebp)
  800bed:	e8 2a f9 ff ff       	call   80051c <fd_close>
		return r;
  800bf2:	83 c4 10             	add    $0x10,%esp
  800bf5:	89 da                	mov    %ebx,%edx
  800bf7:	eb 17                	jmp    800c10 <open+0x86>
	}

	return fd2num(fd);
  800bf9:	83 ec 0c             	sub    $0xc,%esp
  800bfc:	ff 75 f4             	pushl  -0xc(%ebp)
  800bff:	e8 f4 f7 ff ff       	call   8003f8 <fd2num>
  800c04:	89 c2                	mov    %eax,%edx
  800c06:	83 c4 10             	add    $0x10,%esp
  800c09:	eb 05                	jmp    800c10 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c0b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c10:	89 d0                	mov    %edx,%eax
  800c12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c22:	b8 08 00 00 00       	mov    $0x8,%eax
  800c27:	e8 80 fd ff ff       	call   8009ac <fsipc>
}
  800c2c:	c9                   	leave  
  800c2d:	c3                   	ret    

00800c2e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c34:	68 3b 24 80 00       	push   $0x80243b
  800c39:	ff 75 0c             	pushl  0xc(%ebp)
  800c3c:	e8 9a 0f 00 00       	call   801bdb <strcpy>
	return 0;
}
  800c41:	b8 00 00 00 00       	mov    $0x0,%eax
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    

00800c48 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 10             	sub    $0x10,%esp
  800c4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c52:	53                   	push   %ebx
  800c53:	e8 c5 13 00 00       	call   80201d <pageref>
  800c58:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c60:	83 f8 01             	cmp    $0x1,%eax
  800c63:	75 10                	jne    800c75 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	ff 73 0c             	pushl  0xc(%ebx)
  800c6b:	e8 ca 02 00 00       	call   800f3a <nsipc_close>
  800c70:	89 c2                	mov    %eax,%edx
  800c72:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c75:	89 d0                	mov    %edx,%eax
  800c77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c7a:	c9                   	leave  
  800c7b:	c3                   	ret    

00800c7c <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c82:	6a 00                	push   $0x0
  800c84:	ff 75 10             	pushl  0x10(%ebp)
  800c87:	ff 75 0c             	pushl  0xc(%ebp)
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	ff 70 0c             	pushl  0xc(%eax)
  800c90:	e8 82 03 00 00       	call   801017 <nsipc_send>
}
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c9d:	6a 00                	push   $0x0
  800c9f:	ff 75 10             	pushl  0x10(%ebp)
  800ca2:	ff 75 0c             	pushl  0xc(%ebp)
  800ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca8:	ff 70 0c             	pushl  0xc(%eax)
  800cab:	e8 fb 02 00 00       	call   800fab <nsipc_recv>
}
  800cb0:	c9                   	leave  
  800cb1:	c3                   	ret    

00800cb2 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800cb8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800cbb:	52                   	push   %edx
  800cbc:	50                   	push   %eax
  800cbd:	e8 ac f7 ff ff       	call   80046e <fd_lookup>
  800cc2:	83 c4 10             	add    $0x10,%esp
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	78 17                	js     800ce0 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ccc:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800cd2:	39 08                	cmp    %ecx,(%eax)
  800cd4:	75 05                	jne    800cdb <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800cd6:	8b 40 0c             	mov    0xc(%eax),%eax
  800cd9:	eb 05                	jmp    800ce0 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800cdb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    

00800ce2 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 1c             	sub    $0x1c,%esp
  800cea:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800cec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cef:	50                   	push   %eax
  800cf0:	e8 2a f7 ff ff       	call   80041f <fd_alloc>
  800cf5:	89 c3                	mov    %eax,%ebx
  800cf7:	83 c4 10             	add    $0x10,%esp
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	78 1b                	js     800d19 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cfe:	83 ec 04             	sub    $0x4,%esp
  800d01:	68 07 04 00 00       	push   $0x407
  800d06:	ff 75 f4             	pushl  -0xc(%ebp)
  800d09:	6a 00                	push   $0x0
  800d0b:	e8 56 f4 ff ff       	call   800166 <sys_page_alloc>
  800d10:	89 c3                	mov    %eax,%ebx
  800d12:	83 c4 10             	add    $0x10,%esp
  800d15:	85 c0                	test   %eax,%eax
  800d17:	79 10                	jns    800d29 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d19:	83 ec 0c             	sub    $0xc,%esp
  800d1c:	56                   	push   %esi
  800d1d:	e8 18 02 00 00       	call   800f3a <nsipc_close>
		return r;
  800d22:	83 c4 10             	add    $0x10,%esp
  800d25:	89 d8                	mov    %ebx,%eax
  800d27:	eb 24                	jmp    800d4d <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d29:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d32:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d37:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  800d3e:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	52                   	push   %edx
  800d45:	e8 ae f6 ff ff       	call   8003f8 <fd2num>
  800d4a:	83 c4 10             	add    $0x10,%esp
}
  800d4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5d:	e8 50 ff ff ff       	call   800cb2 <fd2sockid>
		return r;
  800d62:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d64:	85 c0                	test   %eax,%eax
  800d66:	78 1f                	js     800d87 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d68:	83 ec 04             	sub    $0x4,%esp
  800d6b:	ff 75 10             	pushl  0x10(%ebp)
  800d6e:	ff 75 0c             	pushl  0xc(%ebp)
  800d71:	50                   	push   %eax
  800d72:	e8 1c 01 00 00       	call   800e93 <nsipc_accept>
  800d77:	83 c4 10             	add    $0x10,%esp
		return r;
  800d7a:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	78 07                	js     800d87 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d80:	e8 5d ff ff ff       	call   800ce2 <alloc_sockfd>
  800d85:	89 c1                	mov    %eax,%ecx
}
  800d87:	89 c8                	mov    %ecx,%eax
  800d89:	c9                   	leave  
  800d8a:	c3                   	ret    

00800d8b <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	e8 19 ff ff ff       	call   800cb2 <fd2sockid>
  800d99:	89 c2                	mov    %eax,%edx
  800d9b:	85 d2                	test   %edx,%edx
  800d9d:	78 12                	js     800db1 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	ff 75 10             	pushl  0x10(%ebp)
  800da5:	ff 75 0c             	pushl  0xc(%ebp)
  800da8:	52                   	push   %edx
  800da9:	e8 35 01 00 00       	call   800ee3 <nsipc_bind>
  800dae:	83 c4 10             	add    $0x10,%esp
}
  800db1:	c9                   	leave  
  800db2:	c3                   	ret    

00800db3 <shutdown>:

int
shutdown(int s, int how)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	e8 f1 fe ff ff       	call   800cb2 <fd2sockid>
  800dc1:	89 c2                	mov    %eax,%edx
  800dc3:	85 d2                	test   %edx,%edx
  800dc5:	78 0f                	js     800dd6 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  800dc7:	83 ec 08             	sub    $0x8,%esp
  800dca:	ff 75 0c             	pushl  0xc(%ebp)
  800dcd:	52                   	push   %edx
  800dce:	e8 45 01 00 00       	call   800f18 <nsipc_shutdown>
  800dd3:	83 c4 10             	add    $0x10,%esp
}
  800dd6:	c9                   	leave  
  800dd7:	c3                   	ret    

00800dd8 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dde:	8b 45 08             	mov    0x8(%ebp),%eax
  800de1:	e8 cc fe ff ff       	call   800cb2 <fd2sockid>
  800de6:	89 c2                	mov    %eax,%edx
  800de8:	85 d2                	test   %edx,%edx
  800dea:	78 12                	js     800dfe <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  800dec:	83 ec 04             	sub    $0x4,%esp
  800def:	ff 75 10             	pushl  0x10(%ebp)
  800df2:	ff 75 0c             	pushl  0xc(%ebp)
  800df5:	52                   	push   %edx
  800df6:	e8 59 01 00 00       	call   800f54 <nsipc_connect>
  800dfb:	83 c4 10             	add    $0x10,%esp
}
  800dfe:	c9                   	leave  
  800dff:	c3                   	ret    

00800e00 <listen>:

int
listen(int s, int backlog)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	e8 a4 fe ff ff       	call   800cb2 <fd2sockid>
  800e0e:	89 c2                	mov    %eax,%edx
  800e10:	85 d2                	test   %edx,%edx
  800e12:	78 0f                	js     800e23 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  800e14:	83 ec 08             	sub    $0x8,%esp
  800e17:	ff 75 0c             	pushl  0xc(%ebp)
  800e1a:	52                   	push   %edx
  800e1b:	e8 69 01 00 00       	call   800f89 <nsipc_listen>
  800e20:	83 c4 10             	add    $0x10,%esp
}
  800e23:	c9                   	leave  
  800e24:	c3                   	ret    

00800e25 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e2b:	ff 75 10             	pushl  0x10(%ebp)
  800e2e:	ff 75 0c             	pushl  0xc(%ebp)
  800e31:	ff 75 08             	pushl  0x8(%ebp)
  800e34:	e8 3c 02 00 00       	call   801075 <nsipc_socket>
  800e39:	89 c2                	mov    %eax,%edx
  800e3b:	83 c4 10             	add    $0x10,%esp
  800e3e:	85 d2                	test   %edx,%edx
  800e40:	78 05                	js     800e47 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  800e42:	e8 9b fe ff ff       	call   800ce2 <alloc_sockfd>
}
  800e47:	c9                   	leave  
  800e48:	c3                   	ret    

00800e49 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e52:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e59:	75 12                	jne    800e6d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	6a 02                	push   $0x2
  800e60:	e8 80 11 00 00       	call   801fe5 <ipc_find_env>
  800e65:	a3 04 40 80 00       	mov    %eax,0x804004
  800e6a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e6d:	6a 07                	push   $0x7
  800e6f:	68 00 60 80 00       	push   $0x806000
  800e74:	53                   	push   %ebx
  800e75:	ff 35 04 40 80 00    	pushl  0x804004
  800e7b:	e8 11 11 00 00       	call   801f91 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e80:	83 c4 0c             	add    $0xc,%esp
  800e83:	6a 00                	push   $0x0
  800e85:	6a 00                	push   $0x0
  800e87:	6a 00                	push   $0x0
  800e89:	e8 9a 10 00 00       	call   801f28 <ipc_recv>
}
  800e8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e91:	c9                   	leave  
  800e92:	c3                   	ret    

00800e93 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800ea3:	8b 06                	mov    (%esi),%eax
  800ea5:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800eaa:	b8 01 00 00 00       	mov    $0x1,%eax
  800eaf:	e8 95 ff ff ff       	call   800e49 <nsipc>
  800eb4:	89 c3                	mov    %eax,%ebx
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	78 20                	js     800eda <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800eba:	83 ec 04             	sub    $0x4,%esp
  800ebd:	ff 35 10 60 80 00    	pushl  0x806010
  800ec3:	68 00 60 80 00       	push   $0x806000
  800ec8:	ff 75 0c             	pushl  0xc(%ebp)
  800ecb:	e8 9d 0e 00 00       	call   801d6d <memmove>
		*addrlen = ret->ret_addrlen;
  800ed0:	a1 10 60 80 00       	mov    0x806010,%eax
  800ed5:	89 06                	mov    %eax,(%esi)
  800ed7:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800eda:	89 d8                	mov    %ebx,%eax
  800edc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800edf:	5b                   	pop    %ebx
  800ee0:	5e                   	pop    %esi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	53                   	push   %ebx
  800ee7:	83 ec 08             	sub    $0x8,%esp
  800eea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ef5:	53                   	push   %ebx
  800ef6:	ff 75 0c             	pushl  0xc(%ebp)
  800ef9:	68 04 60 80 00       	push   $0x806004
  800efe:	e8 6a 0e 00 00       	call   801d6d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800f03:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800f09:	b8 02 00 00 00       	mov    $0x2,%eax
  800f0e:	e8 36 ff ff ff       	call   800e49 <nsipc>
}
  800f13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f16:	c9                   	leave  
  800f17:	c3                   	ret    

00800f18 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f21:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f29:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800f33:	e8 11 ff ff ff       	call   800e49 <nsipc>
}
  800f38:	c9                   	leave  
  800f39:	c3                   	ret    

00800f3a <nsipc_close>:

int
nsipc_close(int s)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f40:	8b 45 08             	mov    0x8(%ebp),%eax
  800f43:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f48:	b8 04 00 00 00       	mov    $0x4,%eax
  800f4d:	e8 f7 fe ff ff       	call   800e49 <nsipc>
}
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	53                   	push   %ebx
  800f58:	83 ec 08             	sub    $0x8,%esp
  800f5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f61:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f66:	53                   	push   %ebx
  800f67:	ff 75 0c             	pushl  0xc(%ebp)
  800f6a:	68 04 60 80 00       	push   $0x806004
  800f6f:	e8 f9 0d 00 00       	call   801d6d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f74:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f7a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f7f:	e8 c5 fe ff ff       	call   800e49 <nsipc>
}
  800f84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f87:	c9                   	leave  
  800f88:	c3                   	ret    

00800f89 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f92:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f9f:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa4:	e8 a0 fe ff ff       	call   800e49 <nsipc>
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800fbb:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800fc1:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc4:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800fc9:	b8 07 00 00 00       	mov    $0x7,%eax
  800fce:	e8 76 fe ff ff       	call   800e49 <nsipc>
  800fd3:	89 c3                	mov    %eax,%ebx
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	78 35                	js     80100e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800fd9:	39 f0                	cmp    %esi,%eax
  800fdb:	7f 07                	jg     800fe4 <nsipc_recv+0x39>
  800fdd:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800fe2:	7e 16                	jle    800ffa <nsipc_recv+0x4f>
  800fe4:	68 47 24 80 00       	push   $0x802447
  800fe9:	68 0f 24 80 00       	push   $0x80240f
  800fee:	6a 62                	push   $0x62
  800ff0:	68 5c 24 80 00       	push   $0x80245c
  800ff5:	e8 81 05 00 00       	call   80157b <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800ffa:	83 ec 04             	sub    $0x4,%esp
  800ffd:	50                   	push   %eax
  800ffe:	68 00 60 80 00       	push   $0x806000
  801003:	ff 75 0c             	pushl  0xc(%ebp)
  801006:	e8 62 0d 00 00       	call   801d6d <memmove>
  80100b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80100e:	89 d8                	mov    %ebx,%eax
  801010:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    

00801017 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	53                   	push   %ebx
  80101b:	83 ec 04             	sub    $0x4,%esp
  80101e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801021:	8b 45 08             	mov    0x8(%ebp),%eax
  801024:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801029:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80102f:	7e 16                	jle    801047 <nsipc_send+0x30>
  801031:	68 68 24 80 00       	push   $0x802468
  801036:	68 0f 24 80 00       	push   $0x80240f
  80103b:	6a 6d                	push   $0x6d
  80103d:	68 5c 24 80 00       	push   $0x80245c
  801042:	e8 34 05 00 00       	call   80157b <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801047:	83 ec 04             	sub    $0x4,%esp
  80104a:	53                   	push   %ebx
  80104b:	ff 75 0c             	pushl  0xc(%ebp)
  80104e:	68 0c 60 80 00       	push   $0x80600c
  801053:	e8 15 0d 00 00       	call   801d6d <memmove>
	nsipcbuf.send.req_size = size;
  801058:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80105e:	8b 45 14             	mov    0x14(%ebp),%eax
  801061:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801066:	b8 08 00 00 00       	mov    $0x8,%eax
  80106b:	e8 d9 fd ff ff       	call   800e49 <nsipc>
}
  801070:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801073:	c9                   	leave  
  801074:	c3                   	ret    

00801075 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80107b:	8b 45 08             	mov    0x8(%ebp),%eax
  80107e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801083:	8b 45 0c             	mov    0xc(%ebp),%eax
  801086:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80108b:	8b 45 10             	mov    0x10(%ebp),%eax
  80108e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801093:	b8 09 00 00 00       	mov    $0x9,%eax
  801098:	e8 ac fd ff ff       	call   800e49 <nsipc>
}
  80109d:	c9                   	leave  
  80109e:	c3                   	ret    

0080109f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	56                   	push   %esi
  8010a3:	53                   	push   %ebx
  8010a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010a7:	83 ec 0c             	sub    $0xc,%esp
  8010aa:	ff 75 08             	pushl  0x8(%ebp)
  8010ad:	e8 56 f3 ff ff       	call   800408 <fd2data>
  8010b2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010b4:	83 c4 08             	add    $0x8,%esp
  8010b7:	68 74 24 80 00       	push   $0x802474
  8010bc:	53                   	push   %ebx
  8010bd:	e8 19 0b 00 00       	call   801bdb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010c2:	8b 56 04             	mov    0x4(%esi),%edx
  8010c5:	89 d0                	mov    %edx,%eax
  8010c7:	2b 06                	sub    (%esi),%eax
  8010c9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8010cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8010d6:	00 00 00 
	stat->st_dev = &devpipe;
  8010d9:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8010e0:	30 80 00 
	return 0;
}
  8010e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5d                   	pop    %ebp
  8010ee:	c3                   	ret    

008010ef <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010f9:	53                   	push   %ebx
  8010fa:	6a 00                	push   $0x0
  8010fc:	e8 ea f0 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801101:	89 1c 24             	mov    %ebx,(%esp)
  801104:	e8 ff f2 ff ff       	call   800408 <fd2data>
  801109:	83 c4 08             	add    $0x8,%esp
  80110c:	50                   	push   %eax
  80110d:	6a 00                	push   $0x0
  80110f:	e8 d7 f0 ff ff       	call   8001eb <sys_page_unmap>
}
  801114:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801117:	c9                   	leave  
  801118:	c3                   	ret    

00801119 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 1c             	sub    $0x1c,%esp
  801122:	89 c6                	mov    %eax,%esi
  801124:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801127:	a1 08 40 80 00       	mov    0x804008,%eax
  80112c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	56                   	push   %esi
  801133:	e8 e5 0e 00 00       	call   80201d <pageref>
  801138:	89 c7                	mov    %eax,%edi
  80113a:	83 c4 04             	add    $0x4,%esp
  80113d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801140:	e8 d8 0e 00 00       	call   80201d <pageref>
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	39 c7                	cmp    %eax,%edi
  80114a:	0f 94 c2             	sete   %dl
  80114d:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801150:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801156:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801159:	39 fb                	cmp    %edi,%ebx
  80115b:	74 19                	je     801176 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  80115d:	84 d2                	test   %dl,%dl
  80115f:	74 c6                	je     801127 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801161:	8b 51 58             	mov    0x58(%ecx),%edx
  801164:	50                   	push   %eax
  801165:	52                   	push   %edx
  801166:	53                   	push   %ebx
  801167:	68 7b 24 80 00       	push   $0x80247b
  80116c:	e8 e3 04 00 00       	call   801654 <cprintf>
  801171:	83 c4 10             	add    $0x10,%esp
  801174:	eb b1                	jmp    801127 <_pipeisclosed+0xe>
	}
}
  801176:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801179:	5b                   	pop    %ebx
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 28             	sub    $0x28,%esp
  801187:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80118a:	56                   	push   %esi
  80118b:	e8 78 f2 ff ff       	call   800408 <fd2data>
  801190:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	bf 00 00 00 00       	mov    $0x0,%edi
  80119a:	eb 4b                	jmp    8011e7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80119c:	89 da                	mov    %ebx,%edx
  80119e:	89 f0                	mov    %esi,%eax
  8011a0:	e8 74 ff ff ff       	call   801119 <_pipeisclosed>
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	75 48                	jne    8011f1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011a9:	e8 99 ef ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011ae:	8b 43 04             	mov    0x4(%ebx),%eax
  8011b1:	8b 0b                	mov    (%ebx),%ecx
  8011b3:	8d 51 20             	lea    0x20(%ecx),%edx
  8011b6:	39 d0                	cmp    %edx,%eax
  8011b8:	73 e2                	jae    80119c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011c1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8011c4:	89 c2                	mov    %eax,%edx
  8011c6:	c1 fa 1f             	sar    $0x1f,%edx
  8011c9:	89 d1                	mov    %edx,%ecx
  8011cb:	c1 e9 1b             	shr    $0x1b,%ecx
  8011ce:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8011d1:	83 e2 1f             	and    $0x1f,%edx
  8011d4:	29 ca                	sub    %ecx,%edx
  8011d6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8011da:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011de:	83 c0 01             	add    $0x1,%eax
  8011e1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011e4:	83 c7 01             	add    $0x1,%edi
  8011e7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011ea:	75 c2                	jne    8011ae <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ef:	eb 05                	jmp    8011f6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011f1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f9:	5b                   	pop    %ebx
  8011fa:	5e                   	pop    %esi
  8011fb:	5f                   	pop    %edi
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	83 ec 18             	sub    $0x18,%esp
  801207:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80120a:	57                   	push   %edi
  80120b:	e8 f8 f1 ff ff       	call   800408 <fd2data>
  801210:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121a:	eb 3d                	jmp    801259 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80121c:	85 db                	test   %ebx,%ebx
  80121e:	74 04                	je     801224 <devpipe_read+0x26>
				return i;
  801220:	89 d8                	mov    %ebx,%eax
  801222:	eb 44                	jmp    801268 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801224:	89 f2                	mov    %esi,%edx
  801226:	89 f8                	mov    %edi,%eax
  801228:	e8 ec fe ff ff       	call   801119 <_pipeisclosed>
  80122d:	85 c0                	test   %eax,%eax
  80122f:	75 32                	jne    801263 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801231:	e8 11 ef ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801236:	8b 06                	mov    (%esi),%eax
  801238:	3b 46 04             	cmp    0x4(%esi),%eax
  80123b:	74 df                	je     80121c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80123d:	99                   	cltd   
  80123e:	c1 ea 1b             	shr    $0x1b,%edx
  801241:	01 d0                	add    %edx,%eax
  801243:	83 e0 1f             	and    $0x1f,%eax
  801246:	29 d0                	sub    %edx,%eax
  801248:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80124d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801250:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801253:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801256:	83 c3 01             	add    $0x1,%ebx
  801259:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80125c:	75 d8                	jne    801236 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80125e:	8b 45 10             	mov    0x10(%ebp),%eax
  801261:	eb 05                	jmp    801268 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801263:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801268:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126b:	5b                   	pop    %ebx
  80126c:	5e                   	pop    %esi
  80126d:	5f                   	pop    %edi
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	56                   	push   %esi
  801274:	53                   	push   %ebx
  801275:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801278:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	e8 9e f1 ff ff       	call   80041f <fd_alloc>
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	89 c2                	mov    %eax,%edx
  801286:	85 c0                	test   %eax,%eax
  801288:	0f 88 2c 01 00 00    	js     8013ba <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128e:	83 ec 04             	sub    $0x4,%esp
  801291:	68 07 04 00 00       	push   $0x407
  801296:	ff 75 f4             	pushl  -0xc(%ebp)
  801299:	6a 00                	push   $0x0
  80129b:	e8 c6 ee ff ff       	call   800166 <sys_page_alloc>
  8012a0:	83 c4 10             	add    $0x10,%esp
  8012a3:	89 c2                	mov    %eax,%edx
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	0f 88 0d 01 00 00    	js     8013ba <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012ad:	83 ec 0c             	sub    $0xc,%esp
  8012b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	e8 66 f1 ff ff       	call   80041f <fd_alloc>
  8012b9:	89 c3                	mov    %eax,%ebx
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	0f 88 e2 00 00 00    	js     8013a8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012c6:	83 ec 04             	sub    $0x4,%esp
  8012c9:	68 07 04 00 00       	push   $0x407
  8012ce:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d1:	6a 00                	push   $0x0
  8012d3:	e8 8e ee ff ff       	call   800166 <sys_page_alloc>
  8012d8:	89 c3                	mov    %eax,%ebx
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	0f 88 c3 00 00 00    	js     8013a8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012e5:	83 ec 0c             	sub    $0xc,%esp
  8012e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8012eb:	e8 18 f1 ff ff       	call   800408 <fd2data>
  8012f0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012f2:	83 c4 0c             	add    $0xc,%esp
  8012f5:	68 07 04 00 00       	push   $0x407
  8012fa:	50                   	push   %eax
  8012fb:	6a 00                	push   $0x0
  8012fd:	e8 64 ee ff ff       	call   800166 <sys_page_alloc>
  801302:	89 c3                	mov    %eax,%ebx
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	0f 88 89 00 00 00    	js     801398 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80130f:	83 ec 0c             	sub    $0xc,%esp
  801312:	ff 75 f0             	pushl  -0x10(%ebp)
  801315:	e8 ee f0 ff ff       	call   800408 <fd2data>
  80131a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801321:	50                   	push   %eax
  801322:	6a 00                	push   $0x0
  801324:	56                   	push   %esi
  801325:	6a 00                	push   $0x0
  801327:	e8 7d ee ff ff       	call   8001a9 <sys_page_map>
  80132c:	89 c3                	mov    %eax,%ebx
  80132e:	83 c4 20             	add    $0x20,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	78 55                	js     80138a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801335:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80133b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801340:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801343:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80134a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801350:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801353:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801355:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801358:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80135f:	83 ec 0c             	sub    $0xc,%esp
  801362:	ff 75 f4             	pushl  -0xc(%ebp)
  801365:	e8 8e f0 ff ff       	call   8003f8 <fd2num>
  80136a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80136d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80136f:	83 c4 04             	add    $0x4,%esp
  801372:	ff 75 f0             	pushl  -0x10(%ebp)
  801375:	e8 7e f0 ff ff       	call   8003f8 <fd2num>
  80137a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80137d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	ba 00 00 00 00       	mov    $0x0,%edx
  801388:	eb 30                	jmp    8013ba <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	56                   	push   %esi
  80138e:	6a 00                	push   $0x0
  801390:	e8 56 ee ff ff       	call   8001eb <sys_page_unmap>
  801395:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801398:	83 ec 08             	sub    $0x8,%esp
  80139b:	ff 75 f0             	pushl  -0x10(%ebp)
  80139e:	6a 00                	push   $0x0
  8013a0:	e8 46 ee ff ff       	call   8001eb <sys_page_unmap>
  8013a5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ae:	6a 00                	push   $0x0
  8013b0:	e8 36 ee ff ff       	call   8001eb <sys_page_unmap>
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013ba:	89 d0                	mov    %edx,%eax
  8013bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    

008013c3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cc:	50                   	push   %eax
  8013cd:	ff 75 08             	pushl  0x8(%ebp)
  8013d0:	e8 99 f0 ff ff       	call   80046e <fd_lookup>
  8013d5:	89 c2                	mov    %eax,%edx
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	85 d2                	test   %edx,%edx
  8013dc:	78 18                	js     8013f6 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013de:	83 ec 0c             	sub    $0xc,%esp
  8013e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e4:	e8 1f f0 ff ff       	call   800408 <fd2data>
	return _pipeisclosed(fd, p);
  8013e9:	89 c2                	mov    %eax,%edx
  8013eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ee:	e8 26 fd ff ff       	call   801119 <_pipeisclosed>
  8013f3:	83 c4 10             	add    $0x10,%esp
}
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801400:	5d                   	pop    %ebp
  801401:	c3                   	ret    

00801402 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801408:	68 93 24 80 00       	push   $0x802493
  80140d:	ff 75 0c             	pushl  0xc(%ebp)
  801410:	e8 c6 07 00 00       	call   801bdb <strcpy>
	return 0;
}
  801415:	b8 00 00 00 00       	mov    $0x0,%eax
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	57                   	push   %edi
  801420:	56                   	push   %esi
  801421:	53                   	push   %ebx
  801422:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801428:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80142d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801433:	eb 2d                	jmp    801462 <devcons_write+0x46>
		m = n - tot;
  801435:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801438:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80143a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80143d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801442:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801445:	83 ec 04             	sub    $0x4,%esp
  801448:	53                   	push   %ebx
  801449:	03 45 0c             	add    0xc(%ebp),%eax
  80144c:	50                   	push   %eax
  80144d:	57                   	push   %edi
  80144e:	e8 1a 09 00 00       	call   801d6d <memmove>
		sys_cputs(buf, m);
  801453:	83 c4 08             	add    $0x8,%esp
  801456:	53                   	push   %ebx
  801457:	57                   	push   %edi
  801458:	e8 4d ec ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80145d:	01 de                	add    %ebx,%esi
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	89 f0                	mov    %esi,%eax
  801464:	3b 75 10             	cmp    0x10(%ebp),%esi
  801467:	72 cc                	jb     801435 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801469:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146c:	5b                   	pop    %ebx
  80146d:	5e                   	pop    %esi
  80146e:	5f                   	pop    %edi
  80146f:	5d                   	pop    %ebp
  801470:	c3                   	ret    

00801471 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801477:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80147c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801480:	75 07                	jne    801489 <devcons_read+0x18>
  801482:	eb 28                	jmp    8014ac <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801484:	e8 be ec ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801489:	e8 3a ec ff ff       	call   8000c8 <sys_cgetc>
  80148e:	85 c0                	test   %eax,%eax
  801490:	74 f2                	je     801484 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801492:	85 c0                	test   %eax,%eax
  801494:	78 16                	js     8014ac <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801496:	83 f8 04             	cmp    $0x4,%eax
  801499:	74 0c                	je     8014a7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80149b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149e:	88 02                	mov    %al,(%edx)
	return 1;
  8014a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8014a5:	eb 05                	jmp    8014ac <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014a7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014ac:	c9                   	leave  
  8014ad:	c3                   	ret    

008014ae <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014ba:	6a 01                	push   $0x1
  8014bc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	e8 e5 eb ff ff       	call   8000aa <sys_cputs>
  8014c5:	83 c4 10             	add    $0x10,%esp
}
  8014c8:	c9                   	leave  
  8014c9:	c3                   	ret    

008014ca <getchar>:

int
getchar(void)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014d0:	6a 01                	push   $0x1
  8014d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014d5:	50                   	push   %eax
  8014d6:	6a 00                	push   $0x0
  8014d8:	e8 00 f2 ff ff       	call   8006dd <read>
	if (r < 0)
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 0f                	js     8014f3 <getchar+0x29>
		return r;
	if (r < 1)
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	7e 06                	jle    8014ee <getchar+0x24>
		return -E_EOF;
	return c;
  8014e8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014ec:	eb 05                	jmp    8014f3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014ee:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014f3:	c9                   	leave  
  8014f4:	c3                   	ret    

008014f5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	ff 75 08             	pushl  0x8(%ebp)
  801502:	e8 67 ef ff ff       	call   80046e <fd_lookup>
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 11                	js     80151f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80150e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801511:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801517:	39 10                	cmp    %edx,(%eax)
  801519:	0f 94 c0             	sete   %al
  80151c:	0f b6 c0             	movzbl %al,%eax
}
  80151f:	c9                   	leave  
  801520:	c3                   	ret    

00801521 <opencons>:

int
opencons(void)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801527:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	e8 ef ee ff ff       	call   80041f <fd_alloc>
  801530:	83 c4 10             	add    $0x10,%esp
		return r;
  801533:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801535:	85 c0                	test   %eax,%eax
  801537:	78 3e                	js     801577 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801539:	83 ec 04             	sub    $0x4,%esp
  80153c:	68 07 04 00 00       	push   $0x407
  801541:	ff 75 f4             	pushl  -0xc(%ebp)
  801544:	6a 00                	push   $0x0
  801546:	e8 1b ec ff ff       	call   800166 <sys_page_alloc>
  80154b:	83 c4 10             	add    $0x10,%esp
		return r;
  80154e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801550:	85 c0                	test   %eax,%eax
  801552:	78 23                	js     801577 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801554:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80155a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80155f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801562:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801569:	83 ec 0c             	sub    $0xc,%esp
  80156c:	50                   	push   %eax
  80156d:	e8 86 ee ff ff       	call   8003f8 <fd2num>
  801572:	89 c2                	mov    %eax,%edx
  801574:	83 c4 10             	add    $0x10,%esp
}
  801577:	89 d0                	mov    %edx,%eax
  801579:	c9                   	leave  
  80157a:	c3                   	ret    

0080157b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	56                   	push   %esi
  80157f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801580:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801583:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801589:	e8 9a eb ff ff       	call   800128 <sys_getenvid>
  80158e:	83 ec 0c             	sub    $0xc,%esp
  801591:	ff 75 0c             	pushl  0xc(%ebp)
  801594:	ff 75 08             	pushl  0x8(%ebp)
  801597:	56                   	push   %esi
  801598:	50                   	push   %eax
  801599:	68 a0 24 80 00       	push   $0x8024a0
  80159e:	e8 b1 00 00 00       	call   801654 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015a3:	83 c4 18             	add    $0x18,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	ff 75 10             	pushl  0x10(%ebp)
  8015aa:	e8 54 00 00 00       	call   801603 <vcprintf>
	cprintf("\n");
  8015af:	c7 04 24 8c 24 80 00 	movl   $0x80248c,(%esp)
  8015b6:	e8 99 00 00 00       	call   801654 <cprintf>
  8015bb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015be:	cc                   	int3   
  8015bf:	eb fd                	jmp    8015be <_panic+0x43>

008015c1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	53                   	push   %ebx
  8015c5:	83 ec 04             	sub    $0x4,%esp
  8015c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015cb:	8b 13                	mov    (%ebx),%edx
  8015cd:	8d 42 01             	lea    0x1(%edx),%eax
  8015d0:	89 03                	mov    %eax,(%ebx)
  8015d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015d5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8015d9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015de:	75 1a                	jne    8015fa <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	68 ff 00 00 00       	push   $0xff
  8015e8:	8d 43 08             	lea    0x8(%ebx),%eax
  8015eb:	50                   	push   %eax
  8015ec:	e8 b9 ea ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8015f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015f7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015fa:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801601:	c9                   	leave  
  801602:	c3                   	ret    

00801603 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80160c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801613:	00 00 00 
	b.cnt = 0;
  801616:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80161d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801620:	ff 75 0c             	pushl  0xc(%ebp)
  801623:	ff 75 08             	pushl  0x8(%ebp)
  801626:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	68 c1 15 80 00       	push   $0x8015c1
  801632:	e8 4f 01 00 00       	call   801786 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801637:	83 c4 08             	add    $0x8,%esp
  80163a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801640:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801646:	50                   	push   %eax
  801647:	e8 5e ea ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  80164c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80165a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80165d:	50                   	push   %eax
  80165e:	ff 75 08             	pushl  0x8(%ebp)
  801661:	e8 9d ff ff ff       	call   801603 <vcprintf>
	va_end(ap);

	return cnt;
}
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	57                   	push   %edi
  80166c:	56                   	push   %esi
  80166d:	53                   	push   %ebx
  80166e:	83 ec 1c             	sub    $0x1c,%esp
  801671:	89 c7                	mov    %eax,%edi
  801673:	89 d6                	mov    %edx,%esi
  801675:	8b 45 08             	mov    0x8(%ebp),%eax
  801678:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167b:	89 d1                	mov    %edx,%ecx
  80167d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801680:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801683:	8b 45 10             	mov    0x10(%ebp),%eax
  801686:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801689:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80168c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801693:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801696:	72 05                	jb     80169d <printnum+0x35>
  801698:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80169b:	77 3e                	ja     8016db <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80169d:	83 ec 0c             	sub    $0xc,%esp
  8016a0:	ff 75 18             	pushl  0x18(%ebp)
  8016a3:	83 eb 01             	sub    $0x1,%ebx
  8016a6:	53                   	push   %ebx
  8016a7:	50                   	push   %eax
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8016b1:	ff 75 dc             	pushl  -0x24(%ebp)
  8016b4:	ff 75 d8             	pushl  -0x28(%ebp)
  8016b7:	e8 a4 09 00 00       	call   802060 <__udivdi3>
  8016bc:	83 c4 18             	add    $0x18,%esp
  8016bf:	52                   	push   %edx
  8016c0:	50                   	push   %eax
  8016c1:	89 f2                	mov    %esi,%edx
  8016c3:	89 f8                	mov    %edi,%eax
  8016c5:	e8 9e ff ff ff       	call   801668 <printnum>
  8016ca:	83 c4 20             	add    $0x20,%esp
  8016cd:	eb 13                	jmp    8016e2 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8016cf:	83 ec 08             	sub    $0x8,%esp
  8016d2:	56                   	push   %esi
  8016d3:	ff 75 18             	pushl  0x18(%ebp)
  8016d6:	ff d7                	call   *%edi
  8016d8:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8016db:	83 eb 01             	sub    $0x1,%ebx
  8016de:	85 db                	test   %ebx,%ebx
  8016e0:	7f ed                	jg     8016cf <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	56                   	push   %esi
  8016e6:	83 ec 04             	sub    $0x4,%esp
  8016e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8016f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8016f5:	e8 96 0a 00 00       	call   802190 <__umoddi3>
  8016fa:	83 c4 14             	add    $0x14,%esp
  8016fd:	0f be 80 c3 24 80 00 	movsbl 0x8024c3(%eax),%eax
  801704:	50                   	push   %eax
  801705:	ff d7                	call   *%edi
  801707:	83 c4 10             	add    $0x10,%esp
}
  80170a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	5f                   	pop    %edi
  801710:	5d                   	pop    %ebp
  801711:	c3                   	ret    

00801712 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801715:	83 fa 01             	cmp    $0x1,%edx
  801718:	7e 0e                	jle    801728 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80171a:	8b 10                	mov    (%eax),%edx
  80171c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80171f:	89 08                	mov    %ecx,(%eax)
  801721:	8b 02                	mov    (%edx),%eax
  801723:	8b 52 04             	mov    0x4(%edx),%edx
  801726:	eb 22                	jmp    80174a <getuint+0x38>
	else if (lflag)
  801728:	85 d2                	test   %edx,%edx
  80172a:	74 10                	je     80173c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80172c:	8b 10                	mov    (%eax),%edx
  80172e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801731:	89 08                	mov    %ecx,(%eax)
  801733:	8b 02                	mov    (%edx),%eax
  801735:	ba 00 00 00 00       	mov    $0x0,%edx
  80173a:	eb 0e                	jmp    80174a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80173c:	8b 10                	mov    (%eax),%edx
  80173e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801741:	89 08                	mov    %ecx,(%eax)
  801743:	8b 02                	mov    (%edx),%eax
  801745:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    

0080174c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801752:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801756:	8b 10                	mov    (%eax),%edx
  801758:	3b 50 04             	cmp    0x4(%eax),%edx
  80175b:	73 0a                	jae    801767 <sprintputch+0x1b>
		*b->buf++ = ch;
  80175d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801760:	89 08                	mov    %ecx,(%eax)
  801762:	8b 45 08             	mov    0x8(%ebp),%eax
  801765:	88 02                	mov    %al,(%edx)
}
  801767:	5d                   	pop    %ebp
  801768:	c3                   	ret    

00801769 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80176f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801772:	50                   	push   %eax
  801773:	ff 75 10             	pushl  0x10(%ebp)
  801776:	ff 75 0c             	pushl  0xc(%ebp)
  801779:	ff 75 08             	pushl  0x8(%ebp)
  80177c:	e8 05 00 00 00       	call   801786 <vprintfmt>
	va_end(ap);
  801781:	83 c4 10             	add    $0x10,%esp
}
  801784:	c9                   	leave  
  801785:	c3                   	ret    

00801786 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	57                   	push   %edi
  80178a:	56                   	push   %esi
  80178b:	53                   	push   %ebx
  80178c:	83 ec 2c             	sub    $0x2c,%esp
  80178f:	8b 75 08             	mov    0x8(%ebp),%esi
  801792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801795:	8b 7d 10             	mov    0x10(%ebp),%edi
  801798:	eb 12                	jmp    8017ac <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80179a:	85 c0                	test   %eax,%eax
  80179c:	0f 84 90 03 00 00    	je     801b32 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	53                   	push   %ebx
  8017a6:	50                   	push   %eax
  8017a7:	ff d6                	call   *%esi
  8017a9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017ac:	83 c7 01             	add    $0x1,%edi
  8017af:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017b3:	83 f8 25             	cmp    $0x25,%eax
  8017b6:	75 e2                	jne    80179a <vprintfmt+0x14>
  8017b8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017bc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8017c3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017ca:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8017d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d6:	eb 07                	jmp    8017df <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8017db:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017df:	8d 47 01             	lea    0x1(%edi),%eax
  8017e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017e5:	0f b6 07             	movzbl (%edi),%eax
  8017e8:	0f b6 c8             	movzbl %al,%ecx
  8017eb:	83 e8 23             	sub    $0x23,%eax
  8017ee:	3c 55                	cmp    $0x55,%al
  8017f0:	0f 87 21 03 00 00    	ja     801b17 <vprintfmt+0x391>
  8017f6:	0f b6 c0             	movzbl %al,%eax
  8017f9:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  801800:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801803:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801807:	eb d6                	jmp    8017df <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801809:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80180c:	b8 00 00 00 00       	mov    $0x0,%eax
  801811:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801814:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801817:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80181b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80181e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801821:	83 fa 09             	cmp    $0x9,%edx
  801824:	77 39                	ja     80185f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801826:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801829:	eb e9                	jmp    801814 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80182b:	8b 45 14             	mov    0x14(%ebp),%eax
  80182e:	8d 48 04             	lea    0x4(%eax),%ecx
  801831:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801834:	8b 00                	mov    (%eax),%eax
  801836:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801839:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80183c:	eb 27                	jmp    801865 <vprintfmt+0xdf>
  80183e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801841:	85 c0                	test   %eax,%eax
  801843:	b9 00 00 00 00       	mov    $0x0,%ecx
  801848:	0f 49 c8             	cmovns %eax,%ecx
  80184b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801851:	eb 8c                	jmp    8017df <vprintfmt+0x59>
  801853:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801856:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80185d:	eb 80                	jmp    8017df <vprintfmt+0x59>
  80185f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801862:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801865:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801869:	0f 89 70 ff ff ff    	jns    8017df <vprintfmt+0x59>
				width = precision, precision = -1;
  80186f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801872:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801875:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80187c:	e9 5e ff ff ff       	jmp    8017df <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801881:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801884:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801887:	e9 53 ff ff ff       	jmp    8017df <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80188c:	8b 45 14             	mov    0x14(%ebp),%eax
  80188f:	8d 50 04             	lea    0x4(%eax),%edx
  801892:	89 55 14             	mov    %edx,0x14(%ebp)
  801895:	83 ec 08             	sub    $0x8,%esp
  801898:	53                   	push   %ebx
  801899:	ff 30                	pushl  (%eax)
  80189b:	ff d6                	call   *%esi
			break;
  80189d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018a3:	e9 04 ff ff ff       	jmp    8017ac <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ab:	8d 50 04             	lea    0x4(%eax),%edx
  8018ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8018b1:	8b 00                	mov    (%eax),%eax
  8018b3:	99                   	cltd   
  8018b4:	31 d0                	xor    %edx,%eax
  8018b6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018b8:	83 f8 0f             	cmp    $0xf,%eax
  8018bb:	7f 0b                	jg     8018c8 <vprintfmt+0x142>
  8018bd:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  8018c4:	85 d2                	test   %edx,%edx
  8018c6:	75 18                	jne    8018e0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8018c8:	50                   	push   %eax
  8018c9:	68 db 24 80 00       	push   $0x8024db
  8018ce:	53                   	push   %ebx
  8018cf:	56                   	push   %esi
  8018d0:	e8 94 fe ff ff       	call   801769 <printfmt>
  8018d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8018db:	e9 cc fe ff ff       	jmp    8017ac <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018e0:	52                   	push   %edx
  8018e1:	68 21 24 80 00       	push   $0x802421
  8018e6:	53                   	push   %ebx
  8018e7:	56                   	push   %esi
  8018e8:	e8 7c fe ff ff       	call   801769 <printfmt>
  8018ed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018f3:	e9 b4 fe ff ff       	jmp    8017ac <vprintfmt+0x26>
  8018f8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8018fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018fe:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801901:	8b 45 14             	mov    0x14(%ebp),%eax
  801904:	8d 50 04             	lea    0x4(%eax),%edx
  801907:	89 55 14             	mov    %edx,0x14(%ebp)
  80190a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80190c:	85 ff                	test   %edi,%edi
  80190e:	ba d4 24 80 00       	mov    $0x8024d4,%edx
  801913:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  801916:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80191a:	0f 84 92 00 00 00    	je     8019b2 <vprintfmt+0x22c>
  801920:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801924:	0f 8e 96 00 00 00    	jle    8019c0 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	51                   	push   %ecx
  80192e:	57                   	push   %edi
  80192f:	e8 86 02 00 00       	call   801bba <strnlen>
  801934:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801937:	29 c1                	sub    %eax,%ecx
  801939:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80193c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80193f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801943:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801946:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801949:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80194b:	eb 0f                	jmp    80195c <vprintfmt+0x1d6>
					putch(padc, putdat);
  80194d:	83 ec 08             	sub    $0x8,%esp
  801950:	53                   	push   %ebx
  801951:	ff 75 e0             	pushl  -0x20(%ebp)
  801954:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801956:	83 ef 01             	sub    $0x1,%edi
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	85 ff                	test   %edi,%edi
  80195e:	7f ed                	jg     80194d <vprintfmt+0x1c7>
  801960:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801963:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801966:	85 c9                	test   %ecx,%ecx
  801968:	b8 00 00 00 00       	mov    $0x0,%eax
  80196d:	0f 49 c1             	cmovns %ecx,%eax
  801970:	29 c1                	sub    %eax,%ecx
  801972:	89 75 08             	mov    %esi,0x8(%ebp)
  801975:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801978:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80197b:	89 cb                	mov    %ecx,%ebx
  80197d:	eb 4d                	jmp    8019cc <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80197f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801983:	74 1b                	je     8019a0 <vprintfmt+0x21a>
  801985:	0f be c0             	movsbl %al,%eax
  801988:	83 e8 20             	sub    $0x20,%eax
  80198b:	83 f8 5e             	cmp    $0x5e,%eax
  80198e:	76 10                	jbe    8019a0 <vprintfmt+0x21a>
					putch('?', putdat);
  801990:	83 ec 08             	sub    $0x8,%esp
  801993:	ff 75 0c             	pushl  0xc(%ebp)
  801996:	6a 3f                	push   $0x3f
  801998:	ff 55 08             	call   *0x8(%ebp)
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	eb 0d                	jmp    8019ad <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8019a0:	83 ec 08             	sub    $0x8,%esp
  8019a3:	ff 75 0c             	pushl  0xc(%ebp)
  8019a6:	52                   	push   %edx
  8019a7:	ff 55 08             	call   *0x8(%ebp)
  8019aa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019ad:	83 eb 01             	sub    $0x1,%ebx
  8019b0:	eb 1a                	jmp    8019cc <vprintfmt+0x246>
  8019b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8019b5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019bb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019be:	eb 0c                	jmp    8019cc <vprintfmt+0x246>
  8019c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8019c3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019c9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019cc:	83 c7 01             	add    $0x1,%edi
  8019cf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019d3:	0f be d0             	movsbl %al,%edx
  8019d6:	85 d2                	test   %edx,%edx
  8019d8:	74 23                	je     8019fd <vprintfmt+0x277>
  8019da:	85 f6                	test   %esi,%esi
  8019dc:	78 a1                	js     80197f <vprintfmt+0x1f9>
  8019de:	83 ee 01             	sub    $0x1,%esi
  8019e1:	79 9c                	jns    80197f <vprintfmt+0x1f9>
  8019e3:	89 df                	mov    %ebx,%edi
  8019e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019eb:	eb 18                	jmp    801a05 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019ed:	83 ec 08             	sub    $0x8,%esp
  8019f0:	53                   	push   %ebx
  8019f1:	6a 20                	push   $0x20
  8019f3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019f5:	83 ef 01             	sub    $0x1,%edi
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	eb 08                	jmp    801a05 <vprintfmt+0x27f>
  8019fd:	89 df                	mov    %ebx,%edi
  8019ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801a02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a05:	85 ff                	test   %edi,%edi
  801a07:	7f e4                	jg     8019ed <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a0c:	e9 9b fd ff ff       	jmp    8017ac <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a11:	83 fa 01             	cmp    $0x1,%edx
  801a14:	7e 16                	jle    801a2c <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801a16:	8b 45 14             	mov    0x14(%ebp),%eax
  801a19:	8d 50 08             	lea    0x8(%eax),%edx
  801a1c:	89 55 14             	mov    %edx,0x14(%ebp)
  801a1f:	8b 50 04             	mov    0x4(%eax),%edx
  801a22:	8b 00                	mov    (%eax),%eax
  801a24:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a27:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a2a:	eb 32                	jmp    801a5e <vprintfmt+0x2d8>
	else if (lflag)
  801a2c:	85 d2                	test   %edx,%edx
  801a2e:	74 18                	je     801a48 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801a30:	8b 45 14             	mov    0x14(%ebp),%eax
  801a33:	8d 50 04             	lea    0x4(%eax),%edx
  801a36:	89 55 14             	mov    %edx,0x14(%ebp)
  801a39:	8b 00                	mov    (%eax),%eax
  801a3b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a3e:	89 c1                	mov    %eax,%ecx
  801a40:	c1 f9 1f             	sar    $0x1f,%ecx
  801a43:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a46:	eb 16                	jmp    801a5e <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801a48:	8b 45 14             	mov    0x14(%ebp),%eax
  801a4b:	8d 50 04             	lea    0x4(%eax),%edx
  801a4e:	89 55 14             	mov    %edx,0x14(%ebp)
  801a51:	8b 00                	mov    (%eax),%eax
  801a53:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a56:	89 c1                	mov    %eax,%ecx
  801a58:	c1 f9 1f             	sar    $0x1f,%ecx
  801a5b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a5e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a61:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a64:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a69:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a6d:	79 74                	jns    801ae3 <vprintfmt+0x35d>
				putch('-', putdat);
  801a6f:	83 ec 08             	sub    $0x8,%esp
  801a72:	53                   	push   %ebx
  801a73:	6a 2d                	push   $0x2d
  801a75:	ff d6                	call   *%esi
				num = -(long long) num;
  801a77:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a7a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a7d:	f7 d8                	neg    %eax
  801a7f:	83 d2 00             	adc    $0x0,%edx
  801a82:	f7 da                	neg    %edx
  801a84:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a87:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a8c:	eb 55                	jmp    801ae3 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a8e:	8d 45 14             	lea    0x14(%ebp),%eax
  801a91:	e8 7c fc ff ff       	call   801712 <getuint>
			base = 10;
  801a96:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a9b:	eb 46                	jmp    801ae3 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a9d:	8d 45 14             	lea    0x14(%ebp),%eax
  801aa0:	e8 6d fc ff ff       	call   801712 <getuint>
                        base = 8;
  801aa5:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801aaa:	eb 37                	jmp    801ae3 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801aac:	83 ec 08             	sub    $0x8,%esp
  801aaf:	53                   	push   %ebx
  801ab0:	6a 30                	push   $0x30
  801ab2:	ff d6                	call   *%esi
			putch('x', putdat);
  801ab4:	83 c4 08             	add    $0x8,%esp
  801ab7:	53                   	push   %ebx
  801ab8:	6a 78                	push   $0x78
  801aba:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801abc:	8b 45 14             	mov    0x14(%ebp),%eax
  801abf:	8d 50 04             	lea    0x4(%eax),%edx
  801ac2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ac5:	8b 00                	mov    (%eax),%eax
  801ac7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801acc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801acf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ad4:	eb 0d                	jmp    801ae3 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ad6:	8d 45 14             	lea    0x14(%ebp),%eax
  801ad9:	e8 34 fc ff ff       	call   801712 <getuint>
			base = 16;
  801ade:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ae3:	83 ec 0c             	sub    $0xc,%esp
  801ae6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801aea:	57                   	push   %edi
  801aeb:	ff 75 e0             	pushl  -0x20(%ebp)
  801aee:	51                   	push   %ecx
  801aef:	52                   	push   %edx
  801af0:	50                   	push   %eax
  801af1:	89 da                	mov    %ebx,%edx
  801af3:	89 f0                	mov    %esi,%eax
  801af5:	e8 6e fb ff ff       	call   801668 <printnum>
			break;
  801afa:	83 c4 20             	add    $0x20,%esp
  801afd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b00:	e9 a7 fc ff ff       	jmp    8017ac <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b05:	83 ec 08             	sub    $0x8,%esp
  801b08:	53                   	push   %ebx
  801b09:	51                   	push   %ecx
  801b0a:	ff d6                	call   *%esi
			break;
  801b0c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b12:	e9 95 fc ff ff       	jmp    8017ac <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b17:	83 ec 08             	sub    $0x8,%esp
  801b1a:	53                   	push   %ebx
  801b1b:	6a 25                	push   $0x25
  801b1d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	eb 03                	jmp    801b27 <vprintfmt+0x3a1>
  801b24:	83 ef 01             	sub    $0x1,%edi
  801b27:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b2b:	75 f7                	jne    801b24 <vprintfmt+0x39e>
  801b2d:	e9 7a fc ff ff       	jmp    8017ac <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5f                   	pop    %edi
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    

00801b3a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	83 ec 18             	sub    $0x18,%esp
  801b40:	8b 45 08             	mov    0x8(%ebp),%eax
  801b43:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b46:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b49:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b4d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b57:	85 c0                	test   %eax,%eax
  801b59:	74 26                	je     801b81 <vsnprintf+0x47>
  801b5b:	85 d2                	test   %edx,%edx
  801b5d:	7e 22                	jle    801b81 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b5f:	ff 75 14             	pushl  0x14(%ebp)
  801b62:	ff 75 10             	pushl  0x10(%ebp)
  801b65:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b68:	50                   	push   %eax
  801b69:	68 4c 17 80 00       	push   $0x80174c
  801b6e:	e8 13 fc ff ff       	call   801786 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b73:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b76:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	eb 05                	jmp    801b86 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b86:	c9                   	leave  
  801b87:	c3                   	ret    

00801b88 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b8e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b91:	50                   	push   %eax
  801b92:	ff 75 10             	pushl  0x10(%ebp)
  801b95:	ff 75 0c             	pushl  0xc(%ebp)
  801b98:	ff 75 08             	pushl  0x8(%ebp)
  801b9b:	e8 9a ff ff ff       	call   801b3a <vsnprintf>
	va_end(ap);

	return rc;
}
  801ba0:	c9                   	leave  
  801ba1:	c3                   	ret    

00801ba2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bad:	eb 03                	jmp    801bb2 <strlen+0x10>
		n++;
  801baf:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801bb2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bb6:	75 f7                	jne    801baf <strlen+0xd>
		n++;
	return n;
}
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    

00801bba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bc3:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc8:	eb 03                	jmp    801bcd <strnlen+0x13>
		n++;
  801bca:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bcd:	39 c2                	cmp    %eax,%edx
  801bcf:	74 08                	je     801bd9 <strnlen+0x1f>
  801bd1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bd5:	75 f3                	jne    801bca <strnlen+0x10>
  801bd7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	53                   	push   %ebx
  801bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801be5:	89 c2                	mov    %eax,%edx
  801be7:	83 c2 01             	add    $0x1,%edx
  801bea:	83 c1 01             	add    $0x1,%ecx
  801bed:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bf1:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bf4:	84 db                	test   %bl,%bl
  801bf6:	75 ef                	jne    801be7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bf8:	5b                   	pop    %ebx
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	53                   	push   %ebx
  801bff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c02:	53                   	push   %ebx
  801c03:	e8 9a ff ff ff       	call   801ba2 <strlen>
  801c08:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c0b:	ff 75 0c             	pushl  0xc(%ebp)
  801c0e:	01 d8                	add    %ebx,%eax
  801c10:	50                   	push   %eax
  801c11:	e8 c5 ff ff ff       	call   801bdb <strcpy>
	return dst;
}
  801c16:	89 d8                	mov    %ebx,%eax
  801c18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    

00801c1d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	56                   	push   %esi
  801c21:	53                   	push   %ebx
  801c22:	8b 75 08             	mov    0x8(%ebp),%esi
  801c25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c28:	89 f3                	mov    %esi,%ebx
  801c2a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c2d:	89 f2                	mov    %esi,%edx
  801c2f:	eb 0f                	jmp    801c40 <strncpy+0x23>
		*dst++ = *src;
  801c31:	83 c2 01             	add    $0x1,%edx
  801c34:	0f b6 01             	movzbl (%ecx),%eax
  801c37:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c3a:	80 39 01             	cmpb   $0x1,(%ecx)
  801c3d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c40:	39 da                	cmp    %ebx,%edx
  801c42:	75 ed                	jne    801c31 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c44:	89 f0                	mov    %esi,%eax
  801c46:	5b                   	pop    %ebx
  801c47:	5e                   	pop    %esi
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	56                   	push   %esi
  801c4e:	53                   	push   %ebx
  801c4f:	8b 75 08             	mov    0x8(%ebp),%esi
  801c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c55:	8b 55 10             	mov    0x10(%ebp),%edx
  801c58:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c5a:	85 d2                	test   %edx,%edx
  801c5c:	74 21                	je     801c7f <strlcpy+0x35>
  801c5e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c62:	89 f2                	mov    %esi,%edx
  801c64:	eb 09                	jmp    801c6f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c66:	83 c2 01             	add    $0x1,%edx
  801c69:	83 c1 01             	add    $0x1,%ecx
  801c6c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c6f:	39 c2                	cmp    %eax,%edx
  801c71:	74 09                	je     801c7c <strlcpy+0x32>
  801c73:	0f b6 19             	movzbl (%ecx),%ebx
  801c76:	84 db                	test   %bl,%bl
  801c78:	75 ec                	jne    801c66 <strlcpy+0x1c>
  801c7a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c7c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c7f:	29 f0                	sub    %esi,%eax
}
  801c81:	5b                   	pop    %ebx
  801c82:	5e                   	pop    %esi
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    

00801c85 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c8e:	eb 06                	jmp    801c96 <strcmp+0x11>
		p++, q++;
  801c90:	83 c1 01             	add    $0x1,%ecx
  801c93:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c96:	0f b6 01             	movzbl (%ecx),%eax
  801c99:	84 c0                	test   %al,%al
  801c9b:	74 04                	je     801ca1 <strcmp+0x1c>
  801c9d:	3a 02                	cmp    (%edx),%al
  801c9f:	74 ef                	je     801c90 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ca1:	0f b6 c0             	movzbl %al,%eax
  801ca4:	0f b6 12             	movzbl (%edx),%edx
  801ca7:	29 d0                	sub    %edx,%eax
}
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    

00801cab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	53                   	push   %ebx
  801caf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb5:	89 c3                	mov    %eax,%ebx
  801cb7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cba:	eb 06                	jmp    801cc2 <strncmp+0x17>
		n--, p++, q++;
  801cbc:	83 c0 01             	add    $0x1,%eax
  801cbf:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cc2:	39 d8                	cmp    %ebx,%eax
  801cc4:	74 15                	je     801cdb <strncmp+0x30>
  801cc6:	0f b6 08             	movzbl (%eax),%ecx
  801cc9:	84 c9                	test   %cl,%cl
  801ccb:	74 04                	je     801cd1 <strncmp+0x26>
  801ccd:	3a 0a                	cmp    (%edx),%cl
  801ccf:	74 eb                	je     801cbc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cd1:	0f b6 00             	movzbl (%eax),%eax
  801cd4:	0f b6 12             	movzbl (%edx),%edx
  801cd7:	29 d0                	sub    %edx,%eax
  801cd9:	eb 05                	jmp    801ce0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cdb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801ce0:	5b                   	pop    %ebx
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    

00801ce3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ced:	eb 07                	jmp    801cf6 <strchr+0x13>
		if (*s == c)
  801cef:	38 ca                	cmp    %cl,%dl
  801cf1:	74 0f                	je     801d02 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801cf3:	83 c0 01             	add    $0x1,%eax
  801cf6:	0f b6 10             	movzbl (%eax),%edx
  801cf9:	84 d2                	test   %dl,%dl
  801cfb:	75 f2                	jne    801cef <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d02:	5d                   	pop    %ebp
  801d03:	c3                   	ret    

00801d04 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d0e:	eb 03                	jmp    801d13 <strfind+0xf>
  801d10:	83 c0 01             	add    $0x1,%eax
  801d13:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d16:	84 d2                	test   %dl,%dl
  801d18:	74 04                	je     801d1e <strfind+0x1a>
  801d1a:	38 ca                	cmp    %cl,%dl
  801d1c:	75 f2                	jne    801d10 <strfind+0xc>
			break;
	return (char *) s;
}
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    

00801d20 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	57                   	push   %edi
  801d24:	56                   	push   %esi
  801d25:	53                   	push   %ebx
  801d26:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d29:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d2c:	85 c9                	test   %ecx,%ecx
  801d2e:	74 36                	je     801d66 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d30:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d36:	75 28                	jne    801d60 <memset+0x40>
  801d38:	f6 c1 03             	test   $0x3,%cl
  801d3b:	75 23                	jne    801d60 <memset+0x40>
		c &= 0xFF;
  801d3d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d41:	89 d3                	mov    %edx,%ebx
  801d43:	c1 e3 08             	shl    $0x8,%ebx
  801d46:	89 d6                	mov    %edx,%esi
  801d48:	c1 e6 18             	shl    $0x18,%esi
  801d4b:	89 d0                	mov    %edx,%eax
  801d4d:	c1 e0 10             	shl    $0x10,%eax
  801d50:	09 f0                	or     %esi,%eax
  801d52:	09 c2                	or     %eax,%edx
  801d54:	89 d0                	mov    %edx,%eax
  801d56:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d58:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801d5b:	fc                   	cld    
  801d5c:	f3 ab                	rep stos %eax,%es:(%edi)
  801d5e:	eb 06                	jmp    801d66 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d63:	fc                   	cld    
  801d64:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d66:	89 f8                	mov    %edi,%eax
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    

00801d6d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d6d:	55                   	push   %ebp
  801d6e:	89 e5                	mov    %esp,%ebp
  801d70:	57                   	push   %edi
  801d71:	56                   	push   %esi
  801d72:	8b 45 08             	mov    0x8(%ebp),%eax
  801d75:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d78:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d7b:	39 c6                	cmp    %eax,%esi
  801d7d:	73 35                	jae    801db4 <memmove+0x47>
  801d7f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d82:	39 d0                	cmp    %edx,%eax
  801d84:	73 2e                	jae    801db4 <memmove+0x47>
		s += n;
		d += n;
  801d86:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801d89:	89 d6                	mov    %edx,%esi
  801d8b:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d8d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d93:	75 13                	jne    801da8 <memmove+0x3b>
  801d95:	f6 c1 03             	test   $0x3,%cl
  801d98:	75 0e                	jne    801da8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d9a:	83 ef 04             	sub    $0x4,%edi
  801d9d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801da0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801da3:	fd                   	std    
  801da4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801da6:	eb 09                	jmp    801db1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801da8:	83 ef 01             	sub    $0x1,%edi
  801dab:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801dae:	fd                   	std    
  801daf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801db1:	fc                   	cld    
  801db2:	eb 1d                	jmp    801dd1 <memmove+0x64>
  801db4:	89 f2                	mov    %esi,%edx
  801db6:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801db8:	f6 c2 03             	test   $0x3,%dl
  801dbb:	75 0f                	jne    801dcc <memmove+0x5f>
  801dbd:	f6 c1 03             	test   $0x3,%cl
  801dc0:	75 0a                	jne    801dcc <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801dc2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801dc5:	89 c7                	mov    %eax,%edi
  801dc7:	fc                   	cld    
  801dc8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dca:	eb 05                	jmp    801dd1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801dcc:	89 c7                	mov    %eax,%edi
  801dce:	fc                   	cld    
  801dcf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    

00801dd5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801dd8:	ff 75 10             	pushl  0x10(%ebp)
  801ddb:	ff 75 0c             	pushl  0xc(%ebp)
  801dde:	ff 75 08             	pushl  0x8(%ebp)
  801de1:	e8 87 ff ff ff       	call   801d6d <memmove>
}
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	56                   	push   %esi
  801dec:	53                   	push   %ebx
  801ded:	8b 45 08             	mov    0x8(%ebp),%eax
  801df0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df3:	89 c6                	mov    %eax,%esi
  801df5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801df8:	eb 1a                	jmp    801e14 <memcmp+0x2c>
		if (*s1 != *s2)
  801dfa:	0f b6 08             	movzbl (%eax),%ecx
  801dfd:	0f b6 1a             	movzbl (%edx),%ebx
  801e00:	38 d9                	cmp    %bl,%cl
  801e02:	74 0a                	je     801e0e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e04:	0f b6 c1             	movzbl %cl,%eax
  801e07:	0f b6 db             	movzbl %bl,%ebx
  801e0a:	29 d8                	sub    %ebx,%eax
  801e0c:	eb 0f                	jmp    801e1d <memcmp+0x35>
		s1++, s2++;
  801e0e:	83 c0 01             	add    $0x1,%eax
  801e11:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e14:	39 f0                	cmp    %esi,%eax
  801e16:	75 e2                	jne    801dfa <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e1d:	5b                   	pop    %ebx
  801e1e:	5e                   	pop    %esi
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    

00801e21 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	8b 45 08             	mov    0x8(%ebp),%eax
  801e27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801e2a:	89 c2                	mov    %eax,%edx
  801e2c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e2f:	eb 07                	jmp    801e38 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e31:	38 08                	cmp    %cl,(%eax)
  801e33:	74 07                	je     801e3c <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e35:	83 c0 01             	add    $0x1,%eax
  801e38:	39 d0                	cmp    %edx,%eax
  801e3a:	72 f5                	jb     801e31 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e3c:	5d                   	pop    %ebp
  801e3d:	c3                   	ret    

00801e3e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	57                   	push   %edi
  801e42:	56                   	push   %esi
  801e43:	53                   	push   %ebx
  801e44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e4a:	eb 03                	jmp    801e4f <strtol+0x11>
		s++;
  801e4c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e4f:	0f b6 01             	movzbl (%ecx),%eax
  801e52:	3c 09                	cmp    $0x9,%al
  801e54:	74 f6                	je     801e4c <strtol+0xe>
  801e56:	3c 20                	cmp    $0x20,%al
  801e58:	74 f2                	je     801e4c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e5a:	3c 2b                	cmp    $0x2b,%al
  801e5c:	75 0a                	jne    801e68 <strtol+0x2a>
		s++;
  801e5e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e61:	bf 00 00 00 00       	mov    $0x0,%edi
  801e66:	eb 10                	jmp    801e78 <strtol+0x3a>
  801e68:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e6d:	3c 2d                	cmp    $0x2d,%al
  801e6f:	75 07                	jne    801e78 <strtol+0x3a>
		s++, neg = 1;
  801e71:	8d 49 01             	lea    0x1(%ecx),%ecx
  801e74:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e78:	85 db                	test   %ebx,%ebx
  801e7a:	0f 94 c0             	sete   %al
  801e7d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e83:	75 19                	jne    801e9e <strtol+0x60>
  801e85:	80 39 30             	cmpb   $0x30,(%ecx)
  801e88:	75 14                	jne    801e9e <strtol+0x60>
  801e8a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e8e:	0f 85 82 00 00 00    	jne    801f16 <strtol+0xd8>
		s += 2, base = 16;
  801e94:	83 c1 02             	add    $0x2,%ecx
  801e97:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e9c:	eb 16                	jmp    801eb4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801e9e:	84 c0                	test   %al,%al
  801ea0:	74 12                	je     801eb4 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ea2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ea7:	80 39 30             	cmpb   $0x30,(%ecx)
  801eaa:	75 08                	jne    801eb4 <strtol+0x76>
		s++, base = 8;
  801eac:	83 c1 01             	add    $0x1,%ecx
  801eaf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801eb4:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ebc:	0f b6 11             	movzbl (%ecx),%edx
  801ebf:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ec2:	89 f3                	mov    %esi,%ebx
  801ec4:	80 fb 09             	cmp    $0x9,%bl
  801ec7:	77 08                	ja     801ed1 <strtol+0x93>
			dig = *s - '0';
  801ec9:	0f be d2             	movsbl %dl,%edx
  801ecc:	83 ea 30             	sub    $0x30,%edx
  801ecf:	eb 22                	jmp    801ef3 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  801ed1:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ed4:	89 f3                	mov    %esi,%ebx
  801ed6:	80 fb 19             	cmp    $0x19,%bl
  801ed9:	77 08                	ja     801ee3 <strtol+0xa5>
			dig = *s - 'a' + 10;
  801edb:	0f be d2             	movsbl %dl,%edx
  801ede:	83 ea 57             	sub    $0x57,%edx
  801ee1:	eb 10                	jmp    801ef3 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  801ee3:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ee6:	89 f3                	mov    %esi,%ebx
  801ee8:	80 fb 19             	cmp    $0x19,%bl
  801eeb:	77 16                	ja     801f03 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801eed:	0f be d2             	movsbl %dl,%edx
  801ef0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ef3:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ef6:	7d 0f                	jge    801f07 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801ef8:	83 c1 01             	add    $0x1,%ecx
  801efb:	0f af 45 10          	imul   0x10(%ebp),%eax
  801eff:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f01:	eb b9                	jmp    801ebc <strtol+0x7e>
  801f03:	89 c2                	mov    %eax,%edx
  801f05:	eb 02                	jmp    801f09 <strtol+0xcb>
  801f07:	89 c2                	mov    %eax,%edx

	if (endptr)
  801f09:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f0d:	74 0d                	je     801f1c <strtol+0xde>
		*endptr = (char *) s;
  801f0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f12:	89 0e                	mov    %ecx,(%esi)
  801f14:	eb 06                	jmp    801f1c <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f16:	84 c0                	test   %al,%al
  801f18:	75 92                	jne    801eac <strtol+0x6e>
  801f1a:	eb 98                	jmp    801eb4 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f1c:	f7 da                	neg    %edx
  801f1e:	85 ff                	test   %edi,%edi
  801f20:	0f 45 c2             	cmovne %edx,%eax
}
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5f                   	pop    %edi
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    

00801f28 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	56                   	push   %esi
  801f2c:	53                   	push   %ebx
  801f2d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f36:	85 c0                	test   %eax,%eax
  801f38:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f3d:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f40:	83 ec 0c             	sub    $0xc,%esp
  801f43:	50                   	push   %eax
  801f44:	e8 cd e3 ff ff       	call   800316 <sys_ipc_recv>
  801f49:	83 c4 10             	add    $0x10,%esp
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	79 16                	jns    801f66 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801f50:	85 f6                	test   %esi,%esi
  801f52:	74 06                	je     801f5a <ipc_recv+0x32>
  801f54:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801f5a:	85 db                	test   %ebx,%ebx
  801f5c:	74 2c                	je     801f8a <ipc_recv+0x62>
  801f5e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f64:	eb 24                	jmp    801f8a <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801f66:	85 f6                	test   %esi,%esi
  801f68:	74 0a                	je     801f74 <ipc_recv+0x4c>
  801f6a:	a1 08 40 80 00       	mov    0x804008,%eax
  801f6f:	8b 40 74             	mov    0x74(%eax),%eax
  801f72:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801f74:	85 db                	test   %ebx,%ebx
  801f76:	74 0a                	je     801f82 <ipc_recv+0x5a>
  801f78:	a1 08 40 80 00       	mov    0x804008,%eax
  801f7d:	8b 40 78             	mov    0x78(%eax),%eax
  801f80:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801f82:	a1 08 40 80 00       	mov    0x804008,%eax
  801f87:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5d                   	pop    %ebp
  801f90:	c3                   	ret    

00801f91 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	57                   	push   %edi
  801f95:	56                   	push   %esi
  801f96:	53                   	push   %ebx
  801f97:	83 ec 0c             	sub    $0xc,%esp
  801f9a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801fa3:	85 db                	test   %ebx,%ebx
  801fa5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801faa:	0f 44 d8             	cmove  %eax,%ebx
  801fad:	eb 1c                	jmp    801fcb <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801faf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fb2:	74 12                	je     801fc6 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801fb4:	50                   	push   %eax
  801fb5:	68 e0 27 80 00       	push   $0x8027e0
  801fba:	6a 39                	push   $0x39
  801fbc:	68 fb 27 80 00       	push   $0x8027fb
  801fc1:	e8 b5 f5 ff ff       	call   80157b <_panic>
                 sys_yield();
  801fc6:	e8 7c e1 ff ff       	call   800147 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801fcb:	ff 75 14             	pushl  0x14(%ebp)
  801fce:	53                   	push   %ebx
  801fcf:	56                   	push   %esi
  801fd0:	57                   	push   %edi
  801fd1:	e8 1d e3 ff ff       	call   8002f3 <sys_ipc_try_send>
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	78 d2                	js     801faf <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801fdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe0:	5b                   	pop    %ebx
  801fe1:	5e                   	pop    %esi
  801fe2:	5f                   	pop    %edi
  801fe3:	5d                   	pop    %ebp
  801fe4:	c3                   	ret    

00801fe5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801feb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ff0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ff3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ff9:	8b 52 50             	mov    0x50(%edx),%edx
  801ffc:	39 ca                	cmp    %ecx,%edx
  801ffe:	75 0d                	jne    80200d <ipc_find_env+0x28>
			return envs[i].env_id;
  802000:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802003:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802008:	8b 40 08             	mov    0x8(%eax),%eax
  80200b:	eb 0e                	jmp    80201b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80200d:	83 c0 01             	add    $0x1,%eax
  802010:	3d 00 04 00 00       	cmp    $0x400,%eax
  802015:	75 d9                	jne    801ff0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802017:	66 b8 00 00          	mov    $0x0,%ax
}
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    

0080201d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802023:	89 d0                	mov    %edx,%eax
  802025:	c1 e8 16             	shr    $0x16,%eax
  802028:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80202f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802034:	f6 c1 01             	test   $0x1,%cl
  802037:	74 1d                	je     802056 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802039:	c1 ea 0c             	shr    $0xc,%edx
  80203c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802043:	f6 c2 01             	test   $0x1,%dl
  802046:	74 0e                	je     802056 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802048:	c1 ea 0c             	shr    $0xc,%edx
  80204b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802052:	ef 
  802053:	0f b7 c0             	movzwl %ax,%eax
}
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
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
