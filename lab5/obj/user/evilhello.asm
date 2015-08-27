
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
  800067:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800096:	e8 89 04 00 00       	call   800524 <close_all>
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
  80010f:	68 0a 1e 80 00       	push   $0x801e0a
  800114:	6a 23                	push   $0x23
  800116:	68 27 1e 80 00       	push   $0x801e27
  80011b:	e8 44 0f 00 00       	call   801064 <_panic>

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
  800190:	68 0a 1e 80 00       	push   $0x801e0a
  800195:	6a 23                	push   $0x23
  800197:	68 27 1e 80 00       	push   $0x801e27
  80019c:	e8 c3 0e 00 00       	call   801064 <_panic>

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
  8001d2:	68 0a 1e 80 00       	push   $0x801e0a
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 27 1e 80 00       	push   $0x801e27
  8001de:	e8 81 0e 00 00       	call   801064 <_panic>

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
  800214:	68 0a 1e 80 00       	push   $0x801e0a
  800219:	6a 23                	push   $0x23
  80021b:	68 27 1e 80 00       	push   $0x801e27
  800220:	e8 3f 0e 00 00       	call   801064 <_panic>

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
  800256:	68 0a 1e 80 00       	push   $0x801e0a
  80025b:	6a 23                	push   $0x23
  80025d:	68 27 1e 80 00       	push   $0x801e27
  800262:	e8 fd 0d 00 00       	call   801064 <_panic>
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
  800298:	68 0a 1e 80 00       	push   $0x801e0a
  80029d:	6a 23                	push   $0x23
  80029f:	68 27 1e 80 00       	push   $0x801e27
  8002a4:	e8 bb 0d 00 00       	call   801064 <_panic>

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
  8002da:	68 0a 1e 80 00       	push   $0x801e0a
  8002df:	6a 23                	push   $0x23
  8002e1:	68 27 1e 80 00       	push   $0x801e27
  8002e6:	e8 79 0d 00 00       	call   801064 <_panic>

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
  80033e:	68 0a 1e 80 00       	push   $0x801e0a
  800343:	6a 23                	push   $0x23
  800345:	68 27 1e 80 00       	push   $0x801e27
  80034a:	e8 15 0d 00 00       	call   801064 <_panic>

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

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 11                	je     8003ab <fd_alloc+0x2d>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	75 09                	jne    8003b4 <fd_alloc+0x36>
			*fd_store = fd;
  8003ab:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	eb 17                	jmp    8003cb <fd_alloc+0x4d>
  8003b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003be:	75 c9                	jne    800389 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	eb 13                	jmp    800421 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb 0c                	jmp    800421 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb 05                	jmp    800421 <fd_lookup+0x54>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	eb 13                	jmp    800446 <dev_lookup+0x23>
  800433:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	75 0c                	jne    800446 <dev_lookup+0x23>
			*dev = devtab[i];
  80043a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb 2e                	jmp    800474 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	75 e7                	jne    800433 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80044c:	a1 04 40 80 00       	mov    0x804004,%eax
  800451:	8b 40 48             	mov    0x48(%eax),%eax
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	51                   	push   %ecx
  800458:	50                   	push   %eax
  800459:	68 38 1e 80 00       	push   $0x801e38
  80045e:	e8 da 0c 00 00       	call   80113d <cprintf>
	*dev = 0;
  800463:	8b 45 0c             	mov    0xc(%ebp),%eax
  800466:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	56                   	push   %esi
  80047a:	53                   	push   %ebx
  80047b:	83 ec 10             	sub    $0x10,%esp
  80047e:	8b 75 08             	mov    0x8(%ebp),%esi
  800481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800487:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800488:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800491:	50                   	push   %eax
  800492:	e8 36 ff ff ff       	call   8003cd <fd_lookup>
  800497:	83 c4 08             	add    $0x8,%esp
  80049a:	85 c0                	test   %eax,%eax
  80049c:	78 05                	js     8004a3 <fd_close+0x2d>
	    || fd != fd2)
  80049e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a1:	74 0c                	je     8004af <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a3:	84 db                	test   %bl,%bl
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	0f 44 c2             	cmove  %edx,%eax
  8004ad:	eb 41                	jmp    8004f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 66 ff ff ff       	call   800423 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 1a                	js     8004e0 <fd_close+0x6a>
		if (dev->dev_close)
  8004c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	74 0b                	je     8004e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	56                   	push   %esi
  8004d9:	ff d0                	call   *%eax
  8004db:	89 c3                	mov    %eax,%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	56                   	push   %esi
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 00 fd ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	89 d8                	mov    %ebx,%eax
}
  8004f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800500:	50                   	push   %eax
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 c4 fe ff ff       	call   8003cd <fd_lookup>
  800509:	89 c2                	mov    %eax,%edx
  80050b:	83 c4 08             	add    $0x8,%esp
  80050e:	85 d2                	test   %edx,%edx
  800510:	78 10                	js     800522 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800512:	83 ec 08             	sub    $0x8,%esp
  800515:	6a 01                	push   $0x1
  800517:	ff 75 f4             	pushl  -0xc(%ebp)
  80051a:	e8 57 ff ff ff       	call   800476 <fd_close>
  80051f:	83 c4 10             	add    $0x10,%esp
}
  800522:	c9                   	leave  
  800523:	c3                   	ret    

00800524 <close_all>:

void
close_all(void)
{
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	53                   	push   %ebx
  800528:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800530:	83 ec 0c             	sub    $0xc,%esp
  800533:	53                   	push   %ebx
  800534:	e8 be ff ff ff       	call   8004f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800539:	83 c3 01             	add    $0x1,%ebx
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	83 fb 20             	cmp    $0x20,%ebx
  800542:	75 ec                	jne    800530 <close_all+0xc>
		close(i);
}
  800544:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800547:	c9                   	leave  
  800548:	c3                   	ret    

00800549 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800549:	55                   	push   %ebp
  80054a:	89 e5                	mov    %esp,%ebp
  80054c:	57                   	push   %edi
  80054d:	56                   	push   %esi
  80054e:	53                   	push   %ebx
  80054f:	83 ec 2c             	sub    $0x2c,%esp
  800552:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800555:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800558:	50                   	push   %eax
  800559:	ff 75 08             	pushl  0x8(%ebp)
  80055c:	e8 6c fe ff ff       	call   8003cd <fd_lookup>
  800561:	89 c2                	mov    %eax,%edx
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	85 d2                	test   %edx,%edx
  800568:	0f 88 c1 00 00 00    	js     80062f <dup+0xe6>
		return r;
	close(newfdnum);
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	56                   	push   %esi
  800572:	e8 80 ff ff ff       	call   8004f7 <close>

	newfd = INDEX2FD(newfdnum);
  800577:	89 f3                	mov    %esi,%ebx
  800579:	c1 e3 0c             	shl    $0xc,%ebx
  80057c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800582:	83 c4 04             	add    $0x4,%esp
  800585:	ff 75 e4             	pushl  -0x1c(%ebp)
  800588:	e8 da fd ff ff       	call   800367 <fd2data>
  80058d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058f:	89 1c 24             	mov    %ebx,(%esp)
  800592:	e8 d0 fd ff ff       	call   800367 <fd2data>
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 16             	shr    $0x16,%eax
  8005a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a9:	a8 01                	test   $0x1,%al
  8005ab:	74 37                	je     8005e4 <dup+0x9b>
  8005ad:	89 f8                	mov    %edi,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b9:	f6 c2 01             	test   $0x1,%dl
  8005bc:	74 26                	je     8005e4 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005d1:	6a 00                	push   $0x0
  8005d3:	57                   	push   %edi
  8005d4:	6a 00                	push   $0x0
  8005d6:	e8 ce fb ff ff       	call   8001a9 <sys_page_map>
  8005db:	89 c7                	mov    %eax,%edi
  8005dd:	83 c4 20             	add    $0x20,%esp
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	78 2e                	js     800612 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e7:	89 d0                	mov    %edx,%eax
  8005e9:	c1 e8 0c             	shr    $0xc,%eax
  8005ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fb:	50                   	push   %eax
  8005fc:	53                   	push   %ebx
  8005fd:	6a 00                	push   $0x0
  8005ff:	52                   	push   %edx
  800600:	6a 00                	push   $0x0
  800602:	e8 a2 fb ff ff       	call   8001a9 <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80060c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	85 ff                	test   %edi,%edi
  800610:	79 1d                	jns    80062f <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 00                	push   $0x0
  800618:	e8 ce fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	ff 75 d4             	pushl  -0x2c(%ebp)
  800623:	6a 00                	push   $0x0
  800625:	e8 c1 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	89 f8                	mov    %edi,%eax
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 14             	sub    $0x14,%esp
  80063e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	53                   	push   %ebx
  800646:	e8 82 fd ff ff       	call   8003cd <fd_lookup>
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	89 c2                	mov    %eax,%edx
  800650:	85 c0                	test   %eax,%eax
  800652:	78 6d                	js     8006c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065a:	50                   	push   %eax
  80065b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065e:	ff 30                	pushl  (%eax)
  800660:	e8 be fd ff ff       	call   800423 <dev_lookup>
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	85 c0                	test   %eax,%eax
  80066a:	78 4c                	js     8006b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066f:	8b 42 08             	mov    0x8(%edx),%eax
  800672:	83 e0 03             	and    $0x3,%eax
  800675:	83 f8 01             	cmp    $0x1,%eax
  800678:	75 21                	jne    80069b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067a:	a1 04 40 80 00       	mov    0x804004,%eax
  80067f:	8b 40 48             	mov    0x48(%eax),%eax
  800682:	83 ec 04             	sub    $0x4,%esp
  800685:	53                   	push   %ebx
  800686:	50                   	push   %eax
  800687:	68 79 1e 80 00       	push   $0x801e79
  80068c:	e8 ac 0a 00 00       	call   80113d <cprintf>
		return -E_INVAL;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800699:	eb 26                	jmp    8006c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069e:	8b 40 08             	mov    0x8(%eax),%eax
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 17                	je     8006bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	ff 75 10             	pushl  0x10(%ebp)
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	52                   	push   %edx
  8006af:	ff d0                	call   *%eax
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 09                	jmp    8006c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b8:	89 c2                	mov    %eax,%edx
  8006ba:	eb 05                	jmp    8006c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006c1:	89 d0                	mov    %edx,%eax
  8006c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dc:	eb 21                	jmp    8006ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006de:	83 ec 04             	sub    $0x4,%esp
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	29 d8                	sub    %ebx,%eax
  8006e5:	50                   	push   %eax
  8006e6:	89 d8                	mov    %ebx,%eax
  8006e8:	03 45 0c             	add    0xc(%ebp),%eax
  8006eb:	50                   	push   %eax
  8006ec:	57                   	push   %edi
  8006ed:	e8 45 ff ff ff       	call   800637 <read>
		if (m < 0)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	78 0c                	js     800705 <readn+0x3d>
			return m;
		if (m == 0)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 06                	je     800703 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006fd:	01 c3                	add    %eax,%ebx
  8006ff:	39 f3                	cmp    %esi,%ebx
  800701:	72 db                	jb     8006de <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800703:	89 d8                	mov    %ebx,%eax
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	83 ec 14             	sub    $0x14,%esp
  800714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	53                   	push   %ebx
  80071c:	e8 ac fc ff ff       	call   8003cd <fd_lookup>
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	89 c2                	mov    %eax,%edx
  800726:	85 c0                	test   %eax,%eax
  800728:	78 68                	js     800792 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	ff 30                	pushl  (%eax)
  800736:	e8 e8 fc ff ff       	call   800423 <dev_lookup>
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 47                	js     800789 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800745:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800749:	75 21                	jne    80076c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 04 40 80 00       	mov    0x804004,%eax
  800750:	8b 40 48             	mov    0x48(%eax),%eax
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	53                   	push   %ebx
  800757:	50                   	push   %eax
  800758:	68 95 1e 80 00       	push   $0x801e95
  80075d:	e8 db 09 00 00       	call   80113d <cprintf>
		return -E_INVAL;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076a:	eb 26                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80076c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076f:	8b 52 0c             	mov    0xc(%edx),%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 17                	je     80078d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	50                   	push   %eax
  800780:	ff d2                	call   *%edx
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 09                	jmp    800792 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800789:	89 c2                	mov    %eax,%edx
  80078b:	eb 05                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800792:	89 d0                	mov    %edx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <seek>:

int
seek(int fdnum, off_t offset)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	ff 75 08             	pushl  0x8(%ebp)
  8007a6:	e8 22 fc ff ff       	call   8003cd <fd_lookup>
  8007ab:	83 c4 08             	add    $0x8,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 0e                	js     8007c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 14             	sub    $0x14,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	53                   	push   %ebx
  8007d1:	e8 f7 fb ff ff       	call   8003cd <fd_lookup>
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	78 65                	js     800844 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	ff 30                	pushl  (%eax)
  8007eb:	e8 33 fc ff ff       	call   800423 <dev_lookup>
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 44                	js     80083b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fe:	75 21                	jne    800821 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800800:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800805:	8b 40 48             	mov    0x48(%eax),%eax
  800808:	83 ec 04             	sub    $0x4,%esp
  80080b:	53                   	push   %ebx
  80080c:	50                   	push   %eax
  80080d:	68 58 1e 80 00       	push   $0x801e58
  800812:	e8 26 09 00 00       	call   80113d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081f:	eb 23                	jmp    800844 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800824:	8b 52 18             	mov    0x18(%edx),%edx
  800827:	85 d2                	test   %edx,%edx
  800829:	74 14                	je     80083f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	ff 75 0c             	pushl  0xc(%ebp)
  800831:	50                   	push   %eax
  800832:	ff d2                	call   *%edx
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	eb 09                	jmp    800844 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	eb 05                	jmp    800844 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800844:	89 d0                	mov    %edx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 14             	sub    $0x14,%esp
  800852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800858:	50                   	push   %eax
  800859:	ff 75 08             	pushl  0x8(%ebp)
  80085c:	e8 6c fb ff ff       	call   8003cd <fd_lookup>
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	89 c2                	mov    %eax,%edx
  800866:	85 c0                	test   %eax,%eax
  800868:	78 58                	js     8008c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800874:	ff 30                	pushl  (%eax)
  800876:	e8 a8 fb ff ff       	call   800423 <dev_lookup>
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 37                	js     8008b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800889:	74 32                	je     8008bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800895:	00 00 00 
	stat->st_isdir = 0;
  800898:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089f:	00 00 00 
	stat->st_dev = dev;
  8008a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8008af:	ff 50 14             	call   *0x14(%eax)
  8008b2:	89 c2                	mov    %eax,%edx
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 09                	jmp    8008c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b9:	89 c2                	mov    %eax,%edx
  8008bb:	eb 05                	jmp    8008c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c2:	89 d0                	mov    %edx,%eax
  8008c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	6a 00                	push   $0x0
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 09 02 00 00       	call   800ae4 <open>
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 db                	test   %ebx,%ebx
  8008e2:	78 1b                	js     8008ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	53                   	push   %ebx
  8008eb:	e8 5b ff ff ff       	call   80084b <fstat>
  8008f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	e8 fd fb ff ff       	call   8004f7 <close>
	return r;
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	89 f0                	mov    %esi,%eax
}
  8008ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	89 c6                	mov    %eax,%esi
  80090d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800916:	75 12                	jne    80092a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800918:	83 ec 0c             	sub    $0xc,%esp
  80091b:	6a 01                	push   $0x1
  80091d:	e8 ac 11 00 00       	call   801ace <ipc_find_env>
  800922:	a3 00 40 80 00       	mov    %eax,0x804000
  800927:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092a:	6a 07                	push   $0x7
  80092c:	68 00 50 80 00       	push   $0x805000
  800931:	56                   	push   %esi
  800932:	ff 35 00 40 80 00    	pushl  0x804000
  800938:	e8 3d 11 00 00       	call   801a7a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093d:	83 c4 0c             	add    $0xc,%esp
  800940:	6a 00                	push   $0x0
  800942:	53                   	push   %ebx
  800943:	6a 00                	push   $0x0
  800945:	e8 c7 10 00 00       	call   801a11 <ipc_recv>
}
  80094a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8d ff ff ff       	call   800906 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 6b ff ff ff       	call   800906 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 45 ff ff ff       	call   800906 <fsipc>
  8009c1:	89 c2                	mov    %eax,%edx
  8009c3:	85 d2                	test   %edx,%edx
  8009c5:	78 2c                	js     8009f3 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c7:	83 ec 08             	sub    $0x8,%esp
  8009ca:	68 00 50 80 00       	push   $0x805000
  8009cf:	53                   	push   %ebx
  8009d0:	e8 ef 0c 00 00       	call   8016c4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d5:	a1 80 50 80 00       	mov    0x805080,%eax
  8009da:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e0:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009eb:	83 c4 10             	add    $0x10,%esp
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f6:	c9                   	leave  
  8009f7:	c3                   	ret    

008009f8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	57                   	push   %edi
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
  8009fe:	83 ec 0c             	sub    $0xc,%esp
  800a01:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0a:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800a0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a12:	eb 3d                	jmp    800a51 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800a14:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800a1a:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800a1f:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800a22:	83 ec 04             	sub    $0x4,%esp
  800a25:	57                   	push   %edi
  800a26:	53                   	push   %ebx
  800a27:	68 08 50 80 00       	push   $0x805008
  800a2c:	e8 25 0e 00 00       	call   801856 <memmove>
                fsipcbuf.write.req_n = tmp; 
  800a31:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a37:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a41:	e8 c0 fe ff ff       	call   800906 <fsipc>
  800a46:	83 c4 10             	add    $0x10,%esp
  800a49:	85 c0                	test   %eax,%eax
  800a4b:	78 0d                	js     800a5a <devfile_write+0x62>
		        return r;
                n -= tmp;
  800a4d:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800a4f:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a51:	85 f6                	test   %esi,%esi
  800a53:	75 bf                	jne    800a14 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800a55:	89 d8                	mov    %ebx,%eax
  800a57:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800a5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5f                   	pop    %edi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
  800a67:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a70:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a75:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a80:	b8 03 00 00 00       	mov    $0x3,%eax
  800a85:	e8 7c fe ff ff       	call   800906 <fsipc>
  800a8a:	89 c3                	mov    %eax,%ebx
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	78 4b                	js     800adb <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a90:	39 c6                	cmp    %eax,%esi
  800a92:	73 16                	jae    800aaa <devfile_read+0x48>
  800a94:	68 c4 1e 80 00       	push   $0x801ec4
  800a99:	68 cb 1e 80 00       	push   $0x801ecb
  800a9e:	6a 7c                	push   $0x7c
  800aa0:	68 e0 1e 80 00       	push   $0x801ee0
  800aa5:	e8 ba 05 00 00       	call   801064 <_panic>
	assert(r <= PGSIZE);
  800aaa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aaf:	7e 16                	jle    800ac7 <devfile_read+0x65>
  800ab1:	68 eb 1e 80 00       	push   $0x801eeb
  800ab6:	68 cb 1e 80 00       	push   $0x801ecb
  800abb:	6a 7d                	push   $0x7d
  800abd:	68 e0 1e 80 00       	push   $0x801ee0
  800ac2:	e8 9d 05 00 00       	call   801064 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ac7:	83 ec 04             	sub    $0x4,%esp
  800aca:	50                   	push   %eax
  800acb:	68 00 50 80 00       	push   $0x805000
  800ad0:	ff 75 0c             	pushl  0xc(%ebp)
  800ad3:	e8 7e 0d 00 00       	call   801856 <memmove>
	return r;
  800ad8:	83 c4 10             	add    $0x10,%esp
}
  800adb:	89 d8                	mov    %ebx,%eax
  800add:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	53                   	push   %ebx
  800ae8:	83 ec 20             	sub    $0x20,%esp
  800aeb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aee:	53                   	push   %ebx
  800aef:	e8 97 0b 00 00       	call   80168b <strlen>
  800af4:	83 c4 10             	add    $0x10,%esp
  800af7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800afc:	7f 67                	jg     800b65 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800afe:	83 ec 0c             	sub    $0xc,%esp
  800b01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b04:	50                   	push   %eax
  800b05:	e8 74 f8 ff ff       	call   80037e <fd_alloc>
  800b0a:	83 c4 10             	add    $0x10,%esp
		return r;
  800b0d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0f:	85 c0                	test   %eax,%eax
  800b11:	78 57                	js     800b6a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b13:	83 ec 08             	sub    $0x8,%esp
  800b16:	53                   	push   %ebx
  800b17:	68 00 50 80 00       	push   $0x805000
  800b1c:	e8 a3 0b 00 00       	call   8016c4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b24:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b31:	e8 d0 fd ff ff       	call   800906 <fsipc>
  800b36:	89 c3                	mov    %eax,%ebx
  800b38:	83 c4 10             	add    $0x10,%esp
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	79 14                	jns    800b53 <open+0x6f>
		fd_close(fd, 0);
  800b3f:	83 ec 08             	sub    $0x8,%esp
  800b42:	6a 00                	push   $0x0
  800b44:	ff 75 f4             	pushl  -0xc(%ebp)
  800b47:	e8 2a f9 ff ff       	call   800476 <fd_close>
		return r;
  800b4c:	83 c4 10             	add    $0x10,%esp
  800b4f:	89 da                	mov    %ebx,%edx
  800b51:	eb 17                	jmp    800b6a <open+0x86>
	}

	return fd2num(fd);
  800b53:	83 ec 0c             	sub    $0xc,%esp
  800b56:	ff 75 f4             	pushl  -0xc(%ebp)
  800b59:	e8 f9 f7 ff ff       	call   800357 <fd2num>
  800b5e:	89 c2                	mov    %eax,%edx
  800b60:	83 c4 10             	add    $0x10,%esp
  800b63:	eb 05                	jmp    800b6a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b65:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b6a:	89 d0                	mov    %edx,%eax
  800b6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b6f:	c9                   	leave  
  800b70:	c3                   	ret    

00800b71 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b81:	e8 80 fd ff ff       	call   800906 <fsipc>
}
  800b86:	c9                   	leave  
  800b87:	c3                   	ret    

00800b88 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
  800b8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	ff 75 08             	pushl  0x8(%ebp)
  800b96:	e8 cc f7 ff ff       	call   800367 <fd2data>
  800b9b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b9d:	83 c4 08             	add    $0x8,%esp
  800ba0:	68 f7 1e 80 00       	push   $0x801ef7
  800ba5:	53                   	push   %ebx
  800ba6:	e8 19 0b 00 00       	call   8016c4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bab:	8b 56 04             	mov    0x4(%esi),%edx
  800bae:	89 d0                	mov    %edx,%eax
  800bb0:	2b 06                	sub    (%esi),%eax
  800bb2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bbf:	00 00 00 
	stat->st_dev = &devpipe;
  800bc2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bc9:	30 80 00 
	return 0;
}
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be2:	53                   	push   %ebx
  800be3:	6a 00                	push   $0x0
  800be5:	e8 01 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bea:	89 1c 24             	mov    %ebx,(%esp)
  800bed:	e8 75 f7 ff ff       	call   800367 <fd2data>
  800bf2:	83 c4 08             	add    $0x8,%esp
  800bf5:	50                   	push   %eax
  800bf6:	6a 00                	push   $0x0
  800bf8:	e8 ee f5 ff ff       	call   8001eb <sys_page_unmap>
}
  800bfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 1c             	sub    $0x1c,%esp
  800c0b:	89 c6                	mov    %eax,%esi
  800c0d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c10:	a1 04 40 80 00       	mov    0x804004,%eax
  800c15:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	56                   	push   %esi
  800c1c:	e8 e5 0e 00 00       	call   801b06 <pageref>
  800c21:	89 c7                	mov    %eax,%edi
  800c23:	83 c4 04             	add    $0x4,%esp
  800c26:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c29:	e8 d8 0e 00 00       	call   801b06 <pageref>
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	39 c7                	cmp    %eax,%edi
  800c33:	0f 94 c2             	sete   %dl
  800c36:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800c39:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800c3f:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800c42:	39 fb                	cmp    %edi,%ebx
  800c44:	74 19                	je     800c5f <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  800c46:	84 d2                	test   %dl,%dl
  800c48:	74 c6                	je     800c10 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c4a:	8b 51 58             	mov    0x58(%ecx),%edx
  800c4d:	50                   	push   %eax
  800c4e:	52                   	push   %edx
  800c4f:	53                   	push   %ebx
  800c50:	68 fe 1e 80 00       	push   $0x801efe
  800c55:	e8 e3 04 00 00       	call   80113d <cprintf>
  800c5a:	83 c4 10             	add    $0x10,%esp
  800c5d:	eb b1                	jmp    800c10 <_pipeisclosed+0xe>
	}
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 28             	sub    $0x28,%esp
  800c70:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c73:	56                   	push   %esi
  800c74:	e8 ee f6 ff ff       	call   800367 <fd2data>
  800c79:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c7b:	83 c4 10             	add    $0x10,%esp
  800c7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c83:	eb 4b                	jmp    800cd0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c85:	89 da                	mov    %ebx,%edx
  800c87:	89 f0                	mov    %esi,%eax
  800c89:	e8 74 ff ff ff       	call   800c02 <_pipeisclosed>
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	75 48                	jne    800cda <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c92:	e8 b0 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c97:	8b 43 04             	mov    0x4(%ebx),%eax
  800c9a:	8b 0b                	mov    (%ebx),%ecx
  800c9c:	8d 51 20             	lea    0x20(%ecx),%edx
  800c9f:	39 d0                	cmp    %edx,%eax
  800ca1:	73 e2                	jae    800c85 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800caa:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cad:	89 c2                	mov    %eax,%edx
  800caf:	c1 fa 1f             	sar    $0x1f,%edx
  800cb2:	89 d1                	mov    %edx,%ecx
  800cb4:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cba:	83 e2 1f             	and    $0x1f,%edx
  800cbd:	29 ca                	sub    %ecx,%edx
  800cbf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cc3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc7:	83 c0 01             	add    $0x1,%eax
  800cca:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ccd:	83 c7 01             	add    $0x1,%edi
  800cd0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cd3:	75 c2                	jne    800c97 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cd5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd8:	eb 05                	jmp    800cdf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cda:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 18             	sub    $0x18,%esp
  800cf0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cf3:	57                   	push   %edi
  800cf4:	e8 6e f6 ff ff       	call   800367 <fd2data>
  800cf9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cfb:	83 c4 10             	add    $0x10,%esp
  800cfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d03:	eb 3d                	jmp    800d42 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d05:	85 db                	test   %ebx,%ebx
  800d07:	74 04                	je     800d0d <devpipe_read+0x26>
				return i;
  800d09:	89 d8                	mov    %ebx,%eax
  800d0b:	eb 44                	jmp    800d51 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d0d:	89 f2                	mov    %esi,%edx
  800d0f:	89 f8                	mov    %edi,%eax
  800d11:	e8 ec fe ff ff       	call   800c02 <_pipeisclosed>
  800d16:	85 c0                	test   %eax,%eax
  800d18:	75 32                	jne    800d4c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d1a:	e8 28 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d1f:	8b 06                	mov    (%esi),%eax
  800d21:	3b 46 04             	cmp    0x4(%esi),%eax
  800d24:	74 df                	je     800d05 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d26:	99                   	cltd   
  800d27:	c1 ea 1b             	shr    $0x1b,%edx
  800d2a:	01 d0                	add    %edx,%eax
  800d2c:	83 e0 1f             	and    $0x1f,%eax
  800d2f:	29 d0                	sub    %edx,%eax
  800d31:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d3c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d3f:	83 c3 01             	add    $0x1,%ebx
  800d42:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d45:	75 d8                	jne    800d1f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d47:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4a:	eb 05                	jmp    800d51 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d4c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
  800d5e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d64:	50                   	push   %eax
  800d65:	e8 14 f6 ff ff       	call   80037e <fd_alloc>
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	89 c2                	mov    %eax,%edx
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	0f 88 2c 01 00 00    	js     800ea3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d77:	83 ec 04             	sub    $0x4,%esp
  800d7a:	68 07 04 00 00       	push   $0x407
  800d7f:	ff 75 f4             	pushl  -0xc(%ebp)
  800d82:	6a 00                	push   $0x0
  800d84:	e8 dd f3 ff ff       	call   800166 <sys_page_alloc>
  800d89:	83 c4 10             	add    $0x10,%esp
  800d8c:	89 c2                	mov    %eax,%edx
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	0f 88 0d 01 00 00    	js     800ea3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d9c:	50                   	push   %eax
  800d9d:	e8 dc f5 ff ff       	call   80037e <fd_alloc>
  800da2:	89 c3                	mov    %eax,%ebx
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	0f 88 e2 00 00 00    	js     800e91 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800daf:	83 ec 04             	sub    $0x4,%esp
  800db2:	68 07 04 00 00       	push   $0x407
  800db7:	ff 75 f0             	pushl  -0x10(%ebp)
  800dba:	6a 00                	push   $0x0
  800dbc:	e8 a5 f3 ff ff       	call   800166 <sys_page_alloc>
  800dc1:	89 c3                	mov    %eax,%ebx
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	0f 88 c3 00 00 00    	js     800e91 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd4:	e8 8e f5 ff ff       	call   800367 <fd2data>
  800dd9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddb:	83 c4 0c             	add    $0xc,%esp
  800dde:	68 07 04 00 00       	push   $0x407
  800de3:	50                   	push   %eax
  800de4:	6a 00                	push   $0x0
  800de6:	e8 7b f3 ff ff       	call   800166 <sys_page_alloc>
  800deb:	89 c3                	mov    %eax,%ebx
  800ded:	83 c4 10             	add    $0x10,%esp
  800df0:	85 c0                	test   %eax,%eax
  800df2:	0f 88 89 00 00 00    	js     800e81 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	ff 75 f0             	pushl  -0x10(%ebp)
  800dfe:	e8 64 f5 ff ff       	call   800367 <fd2data>
  800e03:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e0a:	50                   	push   %eax
  800e0b:	6a 00                	push   $0x0
  800e0d:	56                   	push   %esi
  800e0e:	6a 00                	push   $0x0
  800e10:	e8 94 f3 ff ff       	call   8001a9 <sys_page_map>
  800e15:	89 c3                	mov    %eax,%ebx
  800e17:	83 c4 20             	add    $0x20,%esp
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	78 55                	js     800e73 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e1e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e27:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e33:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e41:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4e:	e8 04 f5 ff ff       	call   800357 <fd2num>
  800e53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e56:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e58:	83 c4 04             	add    $0x4,%esp
  800e5b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5e:	e8 f4 f4 ff ff       	call   800357 <fd2num>
  800e63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e66:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e71:	eb 30                	jmp    800ea3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e73:	83 ec 08             	sub    $0x8,%esp
  800e76:	56                   	push   %esi
  800e77:	6a 00                	push   $0x0
  800e79:	e8 6d f3 ff ff       	call   8001eb <sys_page_unmap>
  800e7e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e81:	83 ec 08             	sub    $0x8,%esp
  800e84:	ff 75 f0             	pushl  -0x10(%ebp)
  800e87:	6a 00                	push   $0x0
  800e89:	e8 5d f3 ff ff       	call   8001eb <sys_page_unmap>
  800e8e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	ff 75 f4             	pushl  -0xc(%ebp)
  800e97:	6a 00                	push   $0x0
  800e99:	e8 4d f3 ff ff       	call   8001eb <sys_page_unmap>
  800e9e:	83 c4 10             	add    $0x10,%esp
  800ea1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ea3:	89 d0                	mov    %edx,%eax
  800ea5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb5:	50                   	push   %eax
  800eb6:	ff 75 08             	pushl  0x8(%ebp)
  800eb9:	e8 0f f5 ff ff       	call   8003cd <fd_lookup>
  800ebe:	89 c2                	mov    %eax,%edx
  800ec0:	83 c4 10             	add    $0x10,%esp
  800ec3:	85 d2                	test   %edx,%edx
  800ec5:	78 18                	js     800edf <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	ff 75 f4             	pushl  -0xc(%ebp)
  800ecd:	e8 95 f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800ed2:	89 c2                	mov    %eax,%edx
  800ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed7:	e8 26 fd ff ff       	call   800c02 <_pipeisclosed>
  800edc:	83 c4 10             	add    $0x10,%esp
}
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    

00800ee1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ee4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ef1:	68 16 1f 80 00       	push   $0x801f16
  800ef6:	ff 75 0c             	pushl  0xc(%ebp)
  800ef9:	e8 c6 07 00 00       	call   8016c4 <strcpy>
	return 0;
}
  800efe:	b8 00 00 00 00       	mov    $0x0,%eax
  800f03:	c9                   	leave  
  800f04:	c3                   	ret    

00800f05 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
  800f0b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f11:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f16:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f1c:	eb 2d                	jmp    800f4b <devcons_write+0x46>
		m = n - tot;
  800f1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f21:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f23:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f26:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f2b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	53                   	push   %ebx
  800f32:	03 45 0c             	add    0xc(%ebp),%eax
  800f35:	50                   	push   %eax
  800f36:	57                   	push   %edi
  800f37:	e8 1a 09 00 00       	call   801856 <memmove>
		sys_cputs(buf, m);
  800f3c:	83 c4 08             	add    $0x8,%esp
  800f3f:	53                   	push   %ebx
  800f40:	57                   	push   %edi
  800f41:	e8 64 f1 ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f46:	01 de                	add    %ebx,%esi
  800f48:	83 c4 10             	add    $0x10,%esp
  800f4b:	89 f0                	mov    %esi,%eax
  800f4d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f50:	72 cc                	jb     800f1e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f60:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f69:	75 07                	jne    800f72 <devcons_read+0x18>
  800f6b:	eb 28                	jmp    800f95 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f6d:	e8 d5 f1 ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f72:	e8 51 f1 ff ff       	call   8000c8 <sys_cgetc>
  800f77:	85 c0                	test   %eax,%eax
  800f79:	74 f2                	je     800f6d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	78 16                	js     800f95 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f7f:	83 f8 04             	cmp    $0x4,%eax
  800f82:	74 0c                	je     800f90 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f87:	88 02                	mov    %al,(%edx)
	return 1;
  800f89:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8e:	eb 05                	jmp    800f95 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f90:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f95:	c9                   	leave  
  800f96:	c3                   	ret    

00800f97 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fa3:	6a 01                	push   $0x1
  800fa5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa8:	50                   	push   %eax
  800fa9:	e8 fc f0 ff ff       	call   8000aa <sys_cputs>
  800fae:	83 c4 10             	add    $0x10,%esp
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <getchar>:

int
getchar(void)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fb9:	6a 01                	push   $0x1
  800fbb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbe:	50                   	push   %eax
  800fbf:	6a 00                	push   $0x0
  800fc1:	e8 71 f6 ff ff       	call   800637 <read>
	if (r < 0)
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	78 0f                	js     800fdc <getchar+0x29>
		return r;
	if (r < 1)
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	7e 06                	jle    800fd7 <getchar+0x24>
		return -E_EOF;
	return c;
  800fd1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fd5:	eb 05                	jmp    800fdc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fd7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fdc:	c9                   	leave  
  800fdd:	c3                   	ret    

00800fde <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe7:	50                   	push   %eax
  800fe8:	ff 75 08             	pushl  0x8(%ebp)
  800feb:	e8 dd f3 ff ff       	call   8003cd <fd_lookup>
  800ff0:	83 c4 10             	add    $0x10,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 11                	js     801008 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801000:	39 10                	cmp    %edx,(%eax)
  801002:	0f 94 c0             	sete   %al
  801005:	0f b6 c0             	movzbl %al,%eax
}
  801008:	c9                   	leave  
  801009:	c3                   	ret    

0080100a <opencons>:

int
opencons(void)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801010:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801013:	50                   	push   %eax
  801014:	e8 65 f3 ff ff       	call   80037e <fd_alloc>
  801019:	83 c4 10             	add    $0x10,%esp
		return r;
  80101c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80101e:	85 c0                	test   %eax,%eax
  801020:	78 3e                	js     801060 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801022:	83 ec 04             	sub    $0x4,%esp
  801025:	68 07 04 00 00       	push   $0x407
  80102a:	ff 75 f4             	pushl  -0xc(%ebp)
  80102d:	6a 00                	push   $0x0
  80102f:	e8 32 f1 ff ff       	call   800166 <sys_page_alloc>
  801034:	83 c4 10             	add    $0x10,%esp
		return r;
  801037:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801039:	85 c0                	test   %eax,%eax
  80103b:	78 23                	js     801060 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80103d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801043:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801046:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801048:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801052:	83 ec 0c             	sub    $0xc,%esp
  801055:	50                   	push   %eax
  801056:	e8 fc f2 ff ff       	call   800357 <fd2num>
  80105b:	89 c2                	mov    %eax,%edx
  80105d:	83 c4 10             	add    $0x10,%esp
}
  801060:	89 d0                	mov    %edx,%eax
  801062:	c9                   	leave  
  801063:	c3                   	ret    

00801064 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	56                   	push   %esi
  801068:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801069:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80106c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801072:	e8 b1 f0 ff ff       	call   800128 <sys_getenvid>
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	ff 75 0c             	pushl  0xc(%ebp)
  80107d:	ff 75 08             	pushl  0x8(%ebp)
  801080:	56                   	push   %esi
  801081:	50                   	push   %eax
  801082:	68 24 1f 80 00       	push   $0x801f24
  801087:	e8 b1 00 00 00       	call   80113d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80108c:	83 c4 18             	add    $0x18,%esp
  80108f:	53                   	push   %ebx
  801090:	ff 75 10             	pushl  0x10(%ebp)
  801093:	e8 54 00 00 00       	call   8010ec <vcprintf>
	cprintf("\n");
  801098:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  80109f:	e8 99 00 00 00       	call   80113d <cprintf>
  8010a4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010a7:	cc                   	int3   
  8010a8:	eb fd                	jmp    8010a7 <_panic+0x43>

008010aa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	53                   	push   %ebx
  8010ae:	83 ec 04             	sub    $0x4,%esp
  8010b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010b4:	8b 13                	mov    (%ebx),%edx
  8010b6:	8d 42 01             	lea    0x1(%edx),%eax
  8010b9:	89 03                	mov    %eax,(%ebx)
  8010bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010be:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010c7:	75 1a                	jne    8010e3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010c9:	83 ec 08             	sub    $0x8,%esp
  8010cc:	68 ff 00 00 00       	push   $0xff
  8010d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8010d4:	50                   	push   %eax
  8010d5:	e8 d0 ef ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8010da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010e0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010e3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ea:	c9                   	leave  
  8010eb:	c3                   	ret    

008010ec <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010f5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010fc:	00 00 00 
	b.cnt = 0;
  8010ff:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801106:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801109:	ff 75 0c             	pushl  0xc(%ebp)
  80110c:	ff 75 08             	pushl  0x8(%ebp)
  80110f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801115:	50                   	push   %eax
  801116:	68 aa 10 80 00       	push   $0x8010aa
  80111b:	e8 4f 01 00 00       	call   80126f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801120:	83 c4 08             	add    $0x8,%esp
  801123:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801129:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80112f:	50                   	push   %eax
  801130:	e8 75 ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  801135:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80113b:	c9                   	leave  
  80113c:	c3                   	ret    

0080113d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801143:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801146:	50                   	push   %eax
  801147:	ff 75 08             	pushl  0x8(%ebp)
  80114a:	e8 9d ff ff ff       	call   8010ec <vcprintf>
	va_end(ap);

	return cnt;
}
  80114f:	c9                   	leave  
  801150:	c3                   	ret    

00801151 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	57                   	push   %edi
  801155:	56                   	push   %esi
  801156:	53                   	push   %ebx
  801157:	83 ec 1c             	sub    $0x1c,%esp
  80115a:	89 c7                	mov    %eax,%edi
  80115c:	89 d6                	mov    %edx,%esi
  80115e:	8b 45 08             	mov    0x8(%ebp),%eax
  801161:	8b 55 0c             	mov    0xc(%ebp),%edx
  801164:	89 d1                	mov    %edx,%ecx
  801166:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801169:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80116c:	8b 45 10             	mov    0x10(%ebp),%eax
  80116f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801172:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801175:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80117c:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80117f:	72 05                	jb     801186 <printnum+0x35>
  801181:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801184:	77 3e                	ja     8011c4 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801186:	83 ec 0c             	sub    $0xc,%esp
  801189:	ff 75 18             	pushl  0x18(%ebp)
  80118c:	83 eb 01             	sub    $0x1,%ebx
  80118f:	53                   	push   %ebx
  801190:	50                   	push   %eax
  801191:	83 ec 08             	sub    $0x8,%esp
  801194:	ff 75 e4             	pushl  -0x1c(%ebp)
  801197:	ff 75 e0             	pushl  -0x20(%ebp)
  80119a:	ff 75 dc             	pushl  -0x24(%ebp)
  80119d:	ff 75 d8             	pushl  -0x28(%ebp)
  8011a0:	e8 ab 09 00 00       	call   801b50 <__udivdi3>
  8011a5:	83 c4 18             	add    $0x18,%esp
  8011a8:	52                   	push   %edx
  8011a9:	50                   	push   %eax
  8011aa:	89 f2                	mov    %esi,%edx
  8011ac:	89 f8                	mov    %edi,%eax
  8011ae:	e8 9e ff ff ff       	call   801151 <printnum>
  8011b3:	83 c4 20             	add    $0x20,%esp
  8011b6:	eb 13                	jmp    8011cb <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011b8:	83 ec 08             	sub    $0x8,%esp
  8011bb:	56                   	push   %esi
  8011bc:	ff 75 18             	pushl  0x18(%ebp)
  8011bf:	ff d7                	call   *%edi
  8011c1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011c4:	83 eb 01             	sub    $0x1,%ebx
  8011c7:	85 db                	test   %ebx,%ebx
  8011c9:	7f ed                	jg     8011b8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011cb:	83 ec 08             	sub    $0x8,%esp
  8011ce:	56                   	push   %esi
  8011cf:	83 ec 04             	sub    $0x4,%esp
  8011d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8011db:	ff 75 d8             	pushl  -0x28(%ebp)
  8011de:	e8 9d 0a 00 00       	call   801c80 <__umoddi3>
  8011e3:	83 c4 14             	add    $0x14,%esp
  8011e6:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  8011ed:	50                   	push   %eax
  8011ee:	ff d7                	call   *%edi
  8011f0:	83 c4 10             	add    $0x10,%esp
}
  8011f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f6:	5b                   	pop    %ebx
  8011f7:	5e                   	pop    %esi
  8011f8:	5f                   	pop    %edi
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011fe:	83 fa 01             	cmp    $0x1,%edx
  801201:	7e 0e                	jle    801211 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801203:	8b 10                	mov    (%eax),%edx
  801205:	8d 4a 08             	lea    0x8(%edx),%ecx
  801208:	89 08                	mov    %ecx,(%eax)
  80120a:	8b 02                	mov    (%edx),%eax
  80120c:	8b 52 04             	mov    0x4(%edx),%edx
  80120f:	eb 22                	jmp    801233 <getuint+0x38>
	else if (lflag)
  801211:	85 d2                	test   %edx,%edx
  801213:	74 10                	je     801225 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801215:	8b 10                	mov    (%eax),%edx
  801217:	8d 4a 04             	lea    0x4(%edx),%ecx
  80121a:	89 08                	mov    %ecx,(%eax)
  80121c:	8b 02                	mov    (%edx),%eax
  80121e:	ba 00 00 00 00       	mov    $0x0,%edx
  801223:	eb 0e                	jmp    801233 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801225:	8b 10                	mov    (%eax),%edx
  801227:	8d 4a 04             	lea    0x4(%edx),%ecx
  80122a:	89 08                	mov    %ecx,(%eax)
  80122c:	8b 02                	mov    (%edx),%eax
  80122e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    

00801235 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80123b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80123f:	8b 10                	mov    (%eax),%edx
  801241:	3b 50 04             	cmp    0x4(%eax),%edx
  801244:	73 0a                	jae    801250 <sprintputch+0x1b>
		*b->buf++ = ch;
  801246:	8d 4a 01             	lea    0x1(%edx),%ecx
  801249:	89 08                	mov    %ecx,(%eax)
  80124b:	8b 45 08             	mov    0x8(%ebp),%eax
  80124e:	88 02                	mov    %al,(%edx)
}
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801258:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80125b:	50                   	push   %eax
  80125c:	ff 75 10             	pushl  0x10(%ebp)
  80125f:	ff 75 0c             	pushl  0xc(%ebp)
  801262:	ff 75 08             	pushl  0x8(%ebp)
  801265:	e8 05 00 00 00       	call   80126f <vprintfmt>
	va_end(ap);
  80126a:	83 c4 10             	add    $0x10,%esp
}
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	57                   	push   %edi
  801273:	56                   	push   %esi
  801274:	53                   	push   %ebx
  801275:	83 ec 2c             	sub    $0x2c,%esp
  801278:	8b 75 08             	mov    0x8(%ebp),%esi
  80127b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80127e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801281:	eb 12                	jmp    801295 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801283:	85 c0                	test   %eax,%eax
  801285:	0f 84 90 03 00 00    	je     80161b <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	53                   	push   %ebx
  80128f:	50                   	push   %eax
  801290:	ff d6                	call   *%esi
  801292:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801295:	83 c7 01             	add    $0x1,%edi
  801298:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80129c:	83 f8 25             	cmp    $0x25,%eax
  80129f:	75 e2                	jne    801283 <vprintfmt+0x14>
  8012a1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012a5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012ac:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012b3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8012bf:	eb 07                	jmp    8012c8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012c4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c8:	8d 47 01             	lea    0x1(%edi),%eax
  8012cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ce:	0f b6 07             	movzbl (%edi),%eax
  8012d1:	0f b6 c8             	movzbl %al,%ecx
  8012d4:	83 e8 23             	sub    $0x23,%eax
  8012d7:	3c 55                	cmp    $0x55,%al
  8012d9:	0f 87 21 03 00 00    	ja     801600 <vprintfmt+0x391>
  8012df:	0f b6 c0             	movzbl %al,%eax
  8012e2:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8012e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012ec:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012f0:	eb d6                	jmp    8012c8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012fd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801300:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801304:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801307:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80130a:	83 fa 09             	cmp    $0x9,%edx
  80130d:	77 39                	ja     801348 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80130f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801312:	eb e9                	jmp    8012fd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801314:	8b 45 14             	mov    0x14(%ebp),%eax
  801317:	8d 48 04             	lea    0x4(%eax),%ecx
  80131a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80131d:	8b 00                	mov    (%eax),%eax
  80131f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801325:	eb 27                	jmp    80134e <vprintfmt+0xdf>
  801327:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132a:	85 c0                	test   %eax,%eax
  80132c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801331:	0f 49 c8             	cmovns %eax,%ecx
  801334:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80133a:	eb 8c                	jmp    8012c8 <vprintfmt+0x59>
  80133c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80133f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801346:	eb 80                	jmp    8012c8 <vprintfmt+0x59>
  801348:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80134b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80134e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801352:	0f 89 70 ff ff ff    	jns    8012c8 <vprintfmt+0x59>
				width = precision, precision = -1;
  801358:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80135b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80135e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801365:	e9 5e ff ff ff       	jmp    8012c8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80136a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801370:	e9 53 ff ff ff       	jmp    8012c8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801375:	8b 45 14             	mov    0x14(%ebp),%eax
  801378:	8d 50 04             	lea    0x4(%eax),%edx
  80137b:	89 55 14             	mov    %edx,0x14(%ebp)
  80137e:	83 ec 08             	sub    $0x8,%esp
  801381:	53                   	push   %ebx
  801382:	ff 30                	pushl  (%eax)
  801384:	ff d6                	call   *%esi
			break;
  801386:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80138c:	e9 04 ff ff ff       	jmp    801295 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801391:	8b 45 14             	mov    0x14(%ebp),%eax
  801394:	8d 50 04             	lea    0x4(%eax),%edx
  801397:	89 55 14             	mov    %edx,0x14(%ebp)
  80139a:	8b 00                	mov    (%eax),%eax
  80139c:	99                   	cltd   
  80139d:	31 d0                	xor    %edx,%eax
  80139f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013a1:	83 f8 0f             	cmp    $0xf,%eax
  8013a4:	7f 0b                	jg     8013b1 <vprintfmt+0x142>
  8013a6:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  8013ad:	85 d2                	test   %edx,%edx
  8013af:	75 18                	jne    8013c9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013b1:	50                   	push   %eax
  8013b2:	68 5f 1f 80 00       	push   $0x801f5f
  8013b7:	53                   	push   %ebx
  8013b8:	56                   	push   %esi
  8013b9:	e8 94 fe ff ff       	call   801252 <printfmt>
  8013be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013c4:	e9 cc fe ff ff       	jmp    801295 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013c9:	52                   	push   %edx
  8013ca:	68 dd 1e 80 00       	push   $0x801edd
  8013cf:	53                   	push   %ebx
  8013d0:	56                   	push   %esi
  8013d1:	e8 7c fe ff ff       	call   801252 <printfmt>
  8013d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013dc:	e9 b4 fe ff ff       	jmp    801295 <vprintfmt+0x26>
  8013e1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ed:	8d 50 04             	lea    0x4(%eax),%edx
  8013f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013f3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013f5:	85 ff                	test   %edi,%edi
  8013f7:	ba 58 1f 80 00       	mov    $0x801f58,%edx
  8013fc:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8013ff:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801403:	0f 84 92 00 00 00    	je     80149b <vprintfmt+0x22c>
  801409:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80140d:	0f 8e 96 00 00 00    	jle    8014a9 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801413:	83 ec 08             	sub    $0x8,%esp
  801416:	51                   	push   %ecx
  801417:	57                   	push   %edi
  801418:	e8 86 02 00 00       	call   8016a3 <strnlen>
  80141d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801420:	29 c1                	sub    %eax,%ecx
  801422:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801425:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801428:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80142c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80142f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801432:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801434:	eb 0f                	jmp    801445 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	53                   	push   %ebx
  80143a:	ff 75 e0             	pushl  -0x20(%ebp)
  80143d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80143f:	83 ef 01             	sub    $0x1,%edi
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	85 ff                	test   %edi,%edi
  801447:	7f ed                	jg     801436 <vprintfmt+0x1c7>
  801449:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80144c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80144f:	85 c9                	test   %ecx,%ecx
  801451:	b8 00 00 00 00       	mov    $0x0,%eax
  801456:	0f 49 c1             	cmovns %ecx,%eax
  801459:	29 c1                	sub    %eax,%ecx
  80145b:	89 75 08             	mov    %esi,0x8(%ebp)
  80145e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801461:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801464:	89 cb                	mov    %ecx,%ebx
  801466:	eb 4d                	jmp    8014b5 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801468:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80146c:	74 1b                	je     801489 <vprintfmt+0x21a>
  80146e:	0f be c0             	movsbl %al,%eax
  801471:	83 e8 20             	sub    $0x20,%eax
  801474:	83 f8 5e             	cmp    $0x5e,%eax
  801477:	76 10                	jbe    801489 <vprintfmt+0x21a>
					putch('?', putdat);
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	ff 75 0c             	pushl  0xc(%ebp)
  80147f:	6a 3f                	push   $0x3f
  801481:	ff 55 08             	call   *0x8(%ebp)
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	eb 0d                	jmp    801496 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801489:	83 ec 08             	sub    $0x8,%esp
  80148c:	ff 75 0c             	pushl  0xc(%ebp)
  80148f:	52                   	push   %edx
  801490:	ff 55 08             	call   *0x8(%ebp)
  801493:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801496:	83 eb 01             	sub    $0x1,%ebx
  801499:	eb 1a                	jmp    8014b5 <vprintfmt+0x246>
  80149b:	89 75 08             	mov    %esi,0x8(%ebp)
  80149e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a7:	eb 0c                	jmp    8014b5 <vprintfmt+0x246>
  8014a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8014ac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014b2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014b5:	83 c7 01             	add    $0x1,%edi
  8014b8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014bc:	0f be d0             	movsbl %al,%edx
  8014bf:	85 d2                	test   %edx,%edx
  8014c1:	74 23                	je     8014e6 <vprintfmt+0x277>
  8014c3:	85 f6                	test   %esi,%esi
  8014c5:	78 a1                	js     801468 <vprintfmt+0x1f9>
  8014c7:	83 ee 01             	sub    $0x1,%esi
  8014ca:	79 9c                	jns    801468 <vprintfmt+0x1f9>
  8014cc:	89 df                	mov    %ebx,%edi
  8014ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d4:	eb 18                	jmp    8014ee <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	53                   	push   %ebx
  8014da:	6a 20                	push   $0x20
  8014dc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014de:	83 ef 01             	sub    $0x1,%edi
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	eb 08                	jmp    8014ee <vprintfmt+0x27f>
  8014e6:	89 df                	mov    %ebx,%edi
  8014e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8014eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014ee:	85 ff                	test   %edi,%edi
  8014f0:	7f e4                	jg     8014d6 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014f5:	e9 9b fd ff ff       	jmp    801295 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014fa:	83 fa 01             	cmp    $0x1,%edx
  8014fd:	7e 16                	jle    801515 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8014ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801502:	8d 50 08             	lea    0x8(%eax),%edx
  801505:	89 55 14             	mov    %edx,0x14(%ebp)
  801508:	8b 50 04             	mov    0x4(%eax),%edx
  80150b:	8b 00                	mov    (%eax),%eax
  80150d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801510:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801513:	eb 32                	jmp    801547 <vprintfmt+0x2d8>
	else if (lflag)
  801515:	85 d2                	test   %edx,%edx
  801517:	74 18                	je     801531 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801519:	8b 45 14             	mov    0x14(%ebp),%eax
  80151c:	8d 50 04             	lea    0x4(%eax),%edx
  80151f:	89 55 14             	mov    %edx,0x14(%ebp)
  801522:	8b 00                	mov    (%eax),%eax
  801524:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801527:	89 c1                	mov    %eax,%ecx
  801529:	c1 f9 1f             	sar    $0x1f,%ecx
  80152c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80152f:	eb 16                	jmp    801547 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801531:	8b 45 14             	mov    0x14(%ebp),%eax
  801534:	8d 50 04             	lea    0x4(%eax),%edx
  801537:	89 55 14             	mov    %edx,0x14(%ebp)
  80153a:	8b 00                	mov    (%eax),%eax
  80153c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153f:	89 c1                	mov    %eax,%ecx
  801541:	c1 f9 1f             	sar    $0x1f,%ecx
  801544:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801547:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80154a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80154d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801552:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801556:	79 74                	jns    8015cc <vprintfmt+0x35d>
				putch('-', putdat);
  801558:	83 ec 08             	sub    $0x8,%esp
  80155b:	53                   	push   %ebx
  80155c:	6a 2d                	push   $0x2d
  80155e:	ff d6                	call   *%esi
				num = -(long long) num;
  801560:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801563:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801566:	f7 d8                	neg    %eax
  801568:	83 d2 00             	adc    $0x0,%edx
  80156b:	f7 da                	neg    %edx
  80156d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801570:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801575:	eb 55                	jmp    8015cc <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801577:	8d 45 14             	lea    0x14(%ebp),%eax
  80157a:	e8 7c fc ff ff       	call   8011fb <getuint>
			base = 10;
  80157f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801584:	eb 46                	jmp    8015cc <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801586:	8d 45 14             	lea    0x14(%ebp),%eax
  801589:	e8 6d fc ff ff       	call   8011fb <getuint>
                        base = 8;
  80158e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801593:	eb 37                	jmp    8015cc <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801595:	83 ec 08             	sub    $0x8,%esp
  801598:	53                   	push   %ebx
  801599:	6a 30                	push   $0x30
  80159b:	ff d6                	call   *%esi
			putch('x', putdat);
  80159d:	83 c4 08             	add    $0x8,%esp
  8015a0:	53                   	push   %ebx
  8015a1:	6a 78                	push   $0x78
  8015a3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a8:	8d 50 04             	lea    0x4(%eax),%edx
  8015ab:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015ae:	8b 00                	mov    (%eax),%eax
  8015b0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015b5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015b8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015bd:	eb 0d                	jmp    8015cc <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8015c2:	e8 34 fc ff ff       	call   8011fb <getuint>
			base = 16;
  8015c7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015cc:	83 ec 0c             	sub    $0xc,%esp
  8015cf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015d3:	57                   	push   %edi
  8015d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d7:	51                   	push   %ecx
  8015d8:	52                   	push   %edx
  8015d9:	50                   	push   %eax
  8015da:	89 da                	mov    %ebx,%edx
  8015dc:	89 f0                	mov    %esi,%eax
  8015de:	e8 6e fb ff ff       	call   801151 <printnum>
			break;
  8015e3:	83 c4 20             	add    $0x20,%esp
  8015e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015e9:	e9 a7 fc ff ff       	jmp    801295 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015ee:	83 ec 08             	sub    $0x8,%esp
  8015f1:	53                   	push   %ebx
  8015f2:	51                   	push   %ecx
  8015f3:	ff d6                	call   *%esi
			break;
  8015f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015fb:	e9 95 fc ff ff       	jmp    801295 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	53                   	push   %ebx
  801604:	6a 25                	push   $0x25
  801606:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	eb 03                	jmp    801610 <vprintfmt+0x3a1>
  80160d:	83 ef 01             	sub    $0x1,%edi
  801610:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801614:	75 f7                	jne    80160d <vprintfmt+0x39e>
  801616:	e9 7a fc ff ff       	jmp    801295 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80161b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161e:	5b                   	pop    %ebx
  80161f:	5e                   	pop    %esi
  801620:	5f                   	pop    %edi
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    

00801623 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	83 ec 18             	sub    $0x18,%esp
  801629:	8b 45 08             	mov    0x8(%ebp),%eax
  80162c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80162f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801632:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801636:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801639:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801640:	85 c0                	test   %eax,%eax
  801642:	74 26                	je     80166a <vsnprintf+0x47>
  801644:	85 d2                	test   %edx,%edx
  801646:	7e 22                	jle    80166a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801648:	ff 75 14             	pushl  0x14(%ebp)
  80164b:	ff 75 10             	pushl  0x10(%ebp)
  80164e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801651:	50                   	push   %eax
  801652:	68 35 12 80 00       	push   $0x801235
  801657:	e8 13 fc ff ff       	call   80126f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80165c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80165f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801662:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	eb 05                	jmp    80166f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80166a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801677:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80167a:	50                   	push   %eax
  80167b:	ff 75 10             	pushl  0x10(%ebp)
  80167e:	ff 75 0c             	pushl  0xc(%ebp)
  801681:	ff 75 08             	pushl  0x8(%ebp)
  801684:	e8 9a ff ff ff       	call   801623 <vsnprintf>
	va_end(ap);

	return rc;
}
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801691:	b8 00 00 00 00       	mov    $0x0,%eax
  801696:	eb 03                	jmp    80169b <strlen+0x10>
		n++;
  801698:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80169b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80169f:	75 f7                	jne    801698 <strlen+0xd>
		n++;
	return n;
}
  8016a1:	5d                   	pop    %ebp
  8016a2:	c3                   	ret    

008016a3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b1:	eb 03                	jmp    8016b6 <strnlen+0x13>
		n++;
  8016b3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b6:	39 c2                	cmp    %eax,%edx
  8016b8:	74 08                	je     8016c2 <strnlen+0x1f>
  8016ba:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016be:	75 f3                	jne    8016b3 <strnlen+0x10>
  8016c0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	53                   	push   %ebx
  8016c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ce:	89 c2                	mov    %eax,%edx
  8016d0:	83 c2 01             	add    $0x1,%edx
  8016d3:	83 c1 01             	add    $0x1,%ecx
  8016d6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016da:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016dd:	84 db                	test   %bl,%bl
  8016df:	75 ef                	jne    8016d0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016e1:	5b                   	pop    %ebx
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    

008016e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	53                   	push   %ebx
  8016e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016eb:	53                   	push   %ebx
  8016ec:	e8 9a ff ff ff       	call   80168b <strlen>
  8016f1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016f4:	ff 75 0c             	pushl  0xc(%ebp)
  8016f7:	01 d8                	add    %ebx,%eax
  8016f9:	50                   	push   %eax
  8016fa:	e8 c5 ff ff ff       	call   8016c4 <strcpy>
	return dst;
}
  8016ff:	89 d8                	mov    %ebx,%eax
  801701:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	56                   	push   %esi
  80170a:	53                   	push   %ebx
  80170b:	8b 75 08             	mov    0x8(%ebp),%esi
  80170e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801711:	89 f3                	mov    %esi,%ebx
  801713:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801716:	89 f2                	mov    %esi,%edx
  801718:	eb 0f                	jmp    801729 <strncpy+0x23>
		*dst++ = *src;
  80171a:	83 c2 01             	add    $0x1,%edx
  80171d:	0f b6 01             	movzbl (%ecx),%eax
  801720:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801723:	80 39 01             	cmpb   $0x1,(%ecx)
  801726:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801729:	39 da                	cmp    %ebx,%edx
  80172b:	75 ed                	jne    80171a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80172d:	89 f0                	mov    %esi,%eax
  80172f:	5b                   	pop    %ebx
  801730:	5e                   	pop    %esi
  801731:	5d                   	pop    %ebp
  801732:	c3                   	ret    

00801733 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	56                   	push   %esi
  801737:	53                   	push   %ebx
  801738:	8b 75 08             	mov    0x8(%ebp),%esi
  80173b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173e:	8b 55 10             	mov    0x10(%ebp),%edx
  801741:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801743:	85 d2                	test   %edx,%edx
  801745:	74 21                	je     801768 <strlcpy+0x35>
  801747:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80174b:	89 f2                	mov    %esi,%edx
  80174d:	eb 09                	jmp    801758 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80174f:	83 c2 01             	add    $0x1,%edx
  801752:	83 c1 01             	add    $0x1,%ecx
  801755:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801758:	39 c2                	cmp    %eax,%edx
  80175a:	74 09                	je     801765 <strlcpy+0x32>
  80175c:	0f b6 19             	movzbl (%ecx),%ebx
  80175f:	84 db                	test   %bl,%bl
  801761:	75 ec                	jne    80174f <strlcpy+0x1c>
  801763:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801765:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801768:	29 f0                	sub    %esi,%eax
}
  80176a:	5b                   	pop    %ebx
  80176b:	5e                   	pop    %esi
  80176c:	5d                   	pop    %ebp
  80176d:	c3                   	ret    

0080176e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801774:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801777:	eb 06                	jmp    80177f <strcmp+0x11>
		p++, q++;
  801779:	83 c1 01             	add    $0x1,%ecx
  80177c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80177f:	0f b6 01             	movzbl (%ecx),%eax
  801782:	84 c0                	test   %al,%al
  801784:	74 04                	je     80178a <strcmp+0x1c>
  801786:	3a 02                	cmp    (%edx),%al
  801788:	74 ef                	je     801779 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80178a:	0f b6 c0             	movzbl %al,%eax
  80178d:	0f b6 12             	movzbl (%edx),%edx
  801790:	29 d0                	sub    %edx,%eax
}
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	53                   	push   %ebx
  801798:	8b 45 08             	mov    0x8(%ebp),%eax
  80179b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017a3:	eb 06                	jmp    8017ab <strncmp+0x17>
		n--, p++, q++;
  8017a5:	83 c0 01             	add    $0x1,%eax
  8017a8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017ab:	39 d8                	cmp    %ebx,%eax
  8017ad:	74 15                	je     8017c4 <strncmp+0x30>
  8017af:	0f b6 08             	movzbl (%eax),%ecx
  8017b2:	84 c9                	test   %cl,%cl
  8017b4:	74 04                	je     8017ba <strncmp+0x26>
  8017b6:	3a 0a                	cmp    (%edx),%cl
  8017b8:	74 eb                	je     8017a5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ba:	0f b6 00             	movzbl (%eax),%eax
  8017bd:	0f b6 12             	movzbl (%edx),%edx
  8017c0:	29 d0                	sub    %edx,%eax
  8017c2:	eb 05                	jmp    8017c9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017c4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017c9:	5b                   	pop    %ebx
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017d6:	eb 07                	jmp    8017df <strchr+0x13>
		if (*s == c)
  8017d8:	38 ca                	cmp    %cl,%dl
  8017da:	74 0f                	je     8017eb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017dc:	83 c0 01             	add    $0x1,%eax
  8017df:	0f b6 10             	movzbl (%eax),%edx
  8017e2:	84 d2                	test   %dl,%dl
  8017e4:	75 f2                	jne    8017d8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    

008017ed <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f7:	eb 03                	jmp    8017fc <strfind+0xf>
  8017f9:	83 c0 01             	add    $0x1,%eax
  8017fc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017ff:	84 d2                	test   %dl,%dl
  801801:	74 04                	je     801807 <strfind+0x1a>
  801803:	38 ca                	cmp    %cl,%dl
  801805:	75 f2                	jne    8017f9 <strfind+0xc>
			break;
	return (char *) s;
}
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    

00801809 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	57                   	push   %edi
  80180d:	56                   	push   %esi
  80180e:	53                   	push   %ebx
  80180f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801812:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801815:	85 c9                	test   %ecx,%ecx
  801817:	74 36                	je     80184f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801819:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80181f:	75 28                	jne    801849 <memset+0x40>
  801821:	f6 c1 03             	test   $0x3,%cl
  801824:	75 23                	jne    801849 <memset+0x40>
		c &= 0xFF;
  801826:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80182a:	89 d3                	mov    %edx,%ebx
  80182c:	c1 e3 08             	shl    $0x8,%ebx
  80182f:	89 d6                	mov    %edx,%esi
  801831:	c1 e6 18             	shl    $0x18,%esi
  801834:	89 d0                	mov    %edx,%eax
  801836:	c1 e0 10             	shl    $0x10,%eax
  801839:	09 f0                	or     %esi,%eax
  80183b:	09 c2                	or     %eax,%edx
  80183d:	89 d0                	mov    %edx,%eax
  80183f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801841:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801844:	fc                   	cld    
  801845:	f3 ab                	rep stos %eax,%es:(%edi)
  801847:	eb 06                	jmp    80184f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801849:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184c:	fc                   	cld    
  80184d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80184f:	89 f8                	mov    %edi,%eax
  801851:	5b                   	pop    %ebx
  801852:	5e                   	pop    %esi
  801853:	5f                   	pop    %edi
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    

00801856 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	57                   	push   %edi
  80185a:	56                   	push   %esi
  80185b:	8b 45 08             	mov    0x8(%ebp),%eax
  80185e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801861:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801864:	39 c6                	cmp    %eax,%esi
  801866:	73 35                	jae    80189d <memmove+0x47>
  801868:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80186b:	39 d0                	cmp    %edx,%eax
  80186d:	73 2e                	jae    80189d <memmove+0x47>
		s += n;
		d += n;
  80186f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801872:	89 d6                	mov    %edx,%esi
  801874:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801876:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80187c:	75 13                	jne    801891 <memmove+0x3b>
  80187e:	f6 c1 03             	test   $0x3,%cl
  801881:	75 0e                	jne    801891 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801883:	83 ef 04             	sub    $0x4,%edi
  801886:	8d 72 fc             	lea    -0x4(%edx),%esi
  801889:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80188c:	fd                   	std    
  80188d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80188f:	eb 09                	jmp    80189a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801891:	83 ef 01             	sub    $0x1,%edi
  801894:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801897:	fd                   	std    
  801898:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80189a:	fc                   	cld    
  80189b:	eb 1d                	jmp    8018ba <memmove+0x64>
  80189d:	89 f2                	mov    %esi,%edx
  80189f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a1:	f6 c2 03             	test   $0x3,%dl
  8018a4:	75 0f                	jne    8018b5 <memmove+0x5f>
  8018a6:	f6 c1 03             	test   $0x3,%cl
  8018a9:	75 0a                	jne    8018b5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018ab:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018ae:	89 c7                	mov    %eax,%edi
  8018b0:	fc                   	cld    
  8018b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b3:	eb 05                	jmp    8018ba <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018b5:	89 c7                	mov    %eax,%edi
  8018b7:	fc                   	cld    
  8018b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ba:	5e                   	pop    %esi
  8018bb:	5f                   	pop    %edi
  8018bc:	5d                   	pop    %ebp
  8018bd:	c3                   	ret    

008018be <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018c1:	ff 75 10             	pushl  0x10(%ebp)
  8018c4:	ff 75 0c             	pushl  0xc(%ebp)
  8018c7:	ff 75 08             	pushl  0x8(%ebp)
  8018ca:	e8 87 ff ff ff       	call   801856 <memmove>
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018dc:	89 c6                	mov    %eax,%esi
  8018de:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e1:	eb 1a                	jmp    8018fd <memcmp+0x2c>
		if (*s1 != *s2)
  8018e3:	0f b6 08             	movzbl (%eax),%ecx
  8018e6:	0f b6 1a             	movzbl (%edx),%ebx
  8018e9:	38 d9                	cmp    %bl,%cl
  8018eb:	74 0a                	je     8018f7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018ed:	0f b6 c1             	movzbl %cl,%eax
  8018f0:	0f b6 db             	movzbl %bl,%ebx
  8018f3:	29 d8                	sub    %ebx,%eax
  8018f5:	eb 0f                	jmp    801906 <memcmp+0x35>
		s1++, s2++;
  8018f7:	83 c0 01             	add    $0x1,%eax
  8018fa:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018fd:	39 f0                	cmp    %esi,%eax
  8018ff:	75 e2                	jne    8018e3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801901:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	8b 45 08             	mov    0x8(%ebp),%eax
  801910:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801913:	89 c2                	mov    %eax,%edx
  801915:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801918:	eb 07                	jmp    801921 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80191a:	38 08                	cmp    %cl,(%eax)
  80191c:	74 07                	je     801925 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80191e:	83 c0 01             	add    $0x1,%eax
  801921:	39 d0                	cmp    %edx,%eax
  801923:	72 f5                	jb     80191a <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801925:	5d                   	pop    %ebp
  801926:	c3                   	ret    

00801927 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	57                   	push   %edi
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801930:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801933:	eb 03                	jmp    801938 <strtol+0x11>
		s++;
  801935:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801938:	0f b6 01             	movzbl (%ecx),%eax
  80193b:	3c 09                	cmp    $0x9,%al
  80193d:	74 f6                	je     801935 <strtol+0xe>
  80193f:	3c 20                	cmp    $0x20,%al
  801941:	74 f2                	je     801935 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801943:	3c 2b                	cmp    $0x2b,%al
  801945:	75 0a                	jne    801951 <strtol+0x2a>
		s++;
  801947:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80194a:	bf 00 00 00 00       	mov    $0x0,%edi
  80194f:	eb 10                	jmp    801961 <strtol+0x3a>
  801951:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801956:	3c 2d                	cmp    $0x2d,%al
  801958:	75 07                	jne    801961 <strtol+0x3a>
		s++, neg = 1;
  80195a:	8d 49 01             	lea    0x1(%ecx),%ecx
  80195d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801961:	85 db                	test   %ebx,%ebx
  801963:	0f 94 c0             	sete   %al
  801966:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80196c:	75 19                	jne    801987 <strtol+0x60>
  80196e:	80 39 30             	cmpb   $0x30,(%ecx)
  801971:	75 14                	jne    801987 <strtol+0x60>
  801973:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801977:	0f 85 82 00 00 00    	jne    8019ff <strtol+0xd8>
		s += 2, base = 16;
  80197d:	83 c1 02             	add    $0x2,%ecx
  801980:	bb 10 00 00 00       	mov    $0x10,%ebx
  801985:	eb 16                	jmp    80199d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801987:	84 c0                	test   %al,%al
  801989:	74 12                	je     80199d <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80198b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801990:	80 39 30             	cmpb   $0x30,(%ecx)
  801993:	75 08                	jne    80199d <strtol+0x76>
		s++, base = 8;
  801995:	83 c1 01             	add    $0x1,%ecx
  801998:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80199d:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019a5:	0f b6 11             	movzbl (%ecx),%edx
  8019a8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019ab:	89 f3                	mov    %esi,%ebx
  8019ad:	80 fb 09             	cmp    $0x9,%bl
  8019b0:	77 08                	ja     8019ba <strtol+0x93>
			dig = *s - '0';
  8019b2:	0f be d2             	movsbl %dl,%edx
  8019b5:	83 ea 30             	sub    $0x30,%edx
  8019b8:	eb 22                	jmp    8019dc <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019ba:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019bd:	89 f3                	mov    %esi,%ebx
  8019bf:	80 fb 19             	cmp    $0x19,%bl
  8019c2:	77 08                	ja     8019cc <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019c4:	0f be d2             	movsbl %dl,%edx
  8019c7:	83 ea 57             	sub    $0x57,%edx
  8019ca:	eb 10                	jmp    8019dc <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019cc:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019cf:	89 f3                	mov    %esi,%ebx
  8019d1:	80 fb 19             	cmp    $0x19,%bl
  8019d4:	77 16                	ja     8019ec <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019d6:	0f be d2             	movsbl %dl,%edx
  8019d9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019dc:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019df:	7d 0f                	jge    8019f0 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019e1:	83 c1 01             	add    $0x1,%ecx
  8019e4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019e8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019ea:	eb b9                	jmp    8019a5 <strtol+0x7e>
  8019ec:	89 c2                	mov    %eax,%edx
  8019ee:	eb 02                	jmp    8019f2 <strtol+0xcb>
  8019f0:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019f6:	74 0d                	je     801a05 <strtol+0xde>
		*endptr = (char *) s;
  8019f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019fb:	89 0e                	mov    %ecx,(%esi)
  8019fd:	eb 06                	jmp    801a05 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ff:	84 c0                	test   %al,%al
  801a01:	75 92                	jne    801995 <strtol+0x6e>
  801a03:	eb 98                	jmp    80199d <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a05:	f7 da                	neg    %edx
  801a07:	85 ff                	test   %edi,%edi
  801a09:	0f 45 c2             	cmovne %edx,%eax
}
  801a0c:	5b                   	pop    %ebx
  801a0d:	5e                   	pop    %esi
  801a0e:	5f                   	pop    %edi
  801a0f:	5d                   	pop    %ebp
  801a10:	c3                   	ret    

00801a11 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	8b 75 08             	mov    0x8(%ebp),%esi
  801a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a26:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	50                   	push   %eax
  801a2d:	e8 e4 e8 ff ff       	call   800316 <sys_ipc_recv>
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	85 c0                	test   %eax,%eax
  801a37:	79 16                	jns    801a4f <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801a39:	85 f6                	test   %esi,%esi
  801a3b:	74 06                	je     801a43 <ipc_recv+0x32>
  801a3d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801a43:	85 db                	test   %ebx,%ebx
  801a45:	74 2c                	je     801a73 <ipc_recv+0x62>
  801a47:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a4d:	eb 24                	jmp    801a73 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a4f:	85 f6                	test   %esi,%esi
  801a51:	74 0a                	je     801a5d <ipc_recv+0x4c>
  801a53:	a1 04 40 80 00       	mov    0x804004,%eax
  801a58:	8b 40 74             	mov    0x74(%eax),%eax
  801a5b:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801a5d:	85 db                	test   %ebx,%ebx
  801a5f:	74 0a                	je     801a6b <ipc_recv+0x5a>
  801a61:	a1 04 40 80 00       	mov    0x804004,%eax
  801a66:	8b 40 78             	mov    0x78(%eax),%eax
  801a69:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801a6b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a70:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5d                   	pop    %ebp
  801a79:	c3                   	ret    

00801a7a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	57                   	push   %edi
  801a7e:	56                   	push   %esi
  801a7f:	53                   	push   %ebx
  801a80:	83 ec 0c             	sub    $0xc,%esp
  801a83:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a86:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801a8c:	85 db                	test   %ebx,%ebx
  801a8e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a93:	0f 44 d8             	cmove  %eax,%ebx
  801a96:	eb 1c                	jmp    801ab4 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801a98:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a9b:	74 12                	je     801aaf <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801a9d:	50                   	push   %eax
  801a9e:	68 60 22 80 00       	push   $0x802260
  801aa3:	6a 39                	push   $0x39
  801aa5:	68 7b 22 80 00       	push   $0x80227b
  801aaa:	e8 b5 f5 ff ff       	call   801064 <_panic>
                 sys_yield();
  801aaf:	e8 93 e6 ff ff       	call   800147 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ab4:	ff 75 14             	pushl  0x14(%ebp)
  801ab7:	53                   	push   %ebx
  801ab8:	56                   	push   %esi
  801ab9:	57                   	push   %edi
  801aba:	e8 34 e8 ff ff       	call   8002f3 <sys_ipc_try_send>
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 d2                	js     801a98 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801ac6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac9:	5b                   	pop    %ebx
  801aca:	5e                   	pop    %esi
  801acb:	5f                   	pop    %edi
  801acc:	5d                   	pop    %ebp
  801acd:	c3                   	ret    

00801ace <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ad4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ad9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801adc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ae2:	8b 52 50             	mov    0x50(%edx),%edx
  801ae5:	39 ca                	cmp    %ecx,%edx
  801ae7:	75 0d                	jne    801af6 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ae9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aec:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801af1:	8b 40 08             	mov    0x8(%eax),%eax
  801af4:	eb 0e                	jmp    801b04 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af6:	83 c0 01             	add    $0x1,%eax
  801af9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801afe:	75 d9                	jne    801ad9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b00:	66 b8 00 00          	mov    $0x0,%ax
}
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0c:	89 d0                	mov    %edx,%eax
  801b0e:	c1 e8 16             	shr    $0x16,%eax
  801b11:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b18:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1d:	f6 c1 01             	test   $0x1,%cl
  801b20:	74 1d                	je     801b3f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b22:	c1 ea 0c             	shr    $0xc,%edx
  801b25:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b2c:	f6 c2 01             	test   $0x1,%dl
  801b2f:	74 0e                	je     801b3f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b31:	c1 ea 0c             	shr    $0xc,%edx
  801b34:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b3b:	ef 
  801b3c:	0f b7 c0             	movzwl %ax,%eax
}
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    
  801b41:	66 90                	xchg   %ax,%ax
  801b43:	66 90                	xchg   %ax,%ax
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
