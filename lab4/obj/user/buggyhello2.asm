
obj/user/buggyhello2:     file format elf32-i386


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
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 5d 00 00 00       	call   8000a6 <sys_cputs>
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
  800059:	e8 c6 00 00 00       	call   800124 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 20 80 00       	mov    %eax,0x802004

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
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 42 00 00 00       	call   8000e3 <sys_env_destroy>
  8000a1:	83 c4 10             	add    $0x10,%esp
}
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f9:	89 cb                	mov    %ecx,%ebx
  8000fb:	89 cf                	mov    %ecx,%edi
  8000fd:	89 ce                	mov    %ecx,%esi
  8000ff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7e 17                	jle    80011c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	50                   	push   %eax
  800109:	6a 03                	push   $0x3
  80010b:	68 98 0f 80 00       	push   $0x800f98
  800110:	6a 23                	push   $0x23
  800112:	68 b5 0f 80 00       	push   $0x800fb5
  800117:	e8 f5 01 00 00       	call   800311 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 02 00 00 00       	mov    $0x2,%eax
  800134:	89 d1                	mov    %edx,%ecx
  800136:	89 d3                	mov    %edx,%ebx
  800138:	89 d7                	mov    %edx,%edi
  80013a:	89 d6                	mov    %edx,%esi
  80013c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_yield>:

void
sys_yield(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016b:	be 00 00 00 00       	mov    $0x0,%esi
  800170:	b8 04 00 00 00       	mov    $0x4,%eax
  800175:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017e:	89 f7                	mov    %esi,%edi
  800180:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7e 17                	jle    80019d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	50                   	push   %eax
  80018a:	6a 04                	push   $0x4
  80018c:	68 98 0f 80 00       	push   $0x800f98
  800191:	6a 23                	push   $0x23
  800193:	68 b5 0f 80 00       	push   $0x800fb5
  800198:	e8 74 01 00 00       	call   800311 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5f                   	pop    %edi
  8001a3:	5d                   	pop    %ebp
  8001a4:	c3                   	ret    

008001a5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ae:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c4:	85 c0                	test   %eax,%eax
  8001c6:	7e 17                	jle    8001df <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	50                   	push   %eax
  8001cc:	6a 05                	push   $0x5
  8001ce:	68 98 0f 80 00       	push   $0x800f98
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 b5 0f 80 00       	push   $0x800fb5
  8001da:	e8 32 01 00 00       	call   800311 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5f                   	pop    %edi
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800200:	89 df                	mov    %ebx,%edi
  800202:	89 de                	mov    %ebx,%esi
  800204:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7e 17                	jle    800221 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 06                	push   $0x6
  800210:	68 98 0f 80 00       	push   $0x800f98
  800215:	6a 23                	push   $0x23
  800217:	68 b5 0f 80 00       	push   $0x800fb5
  80021c:	e8 f0 00 00 00       	call   800311 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800232:	bb 00 00 00 00       	mov    $0x0,%ebx
  800237:	b8 08 00 00 00       	mov    $0x8,%eax
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	89 df                	mov    %ebx,%edi
  800244:	89 de                	mov    %ebx,%esi
  800246:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7e 17                	jle    800263 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 08                	push   $0x8
  800252:	68 98 0f 80 00       	push   $0x800f98
  800257:	6a 23                	push   $0x23
  800259:	68 b5 0f 80 00       	push   $0x800fb5
  80025e:	e8 ae 00 00 00       	call   800311 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	b8 09 00 00 00       	mov    $0x9,%eax
  80027e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	89 df                	mov    %ebx,%edi
  800286:	89 de                	mov    %ebx,%esi
  800288:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7e 17                	jle    8002a5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 09                	push   $0x9
  800294:	68 98 0f 80 00       	push   $0x800f98
  800299:	6a 23                	push   $0x23
  80029b:	68 b5 0f 80 00       	push   $0x800fb5
  8002a0:	e8 6c 00 00 00       	call   800311 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b3:	be 00 00 00 00       	mov    $0x0,%esi
  8002b8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002de:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e6:	89 cb                	mov    %ecx,%ebx
  8002e8:	89 cf                	mov    %ecx,%edi
  8002ea:	89 ce                	mov    %ecx,%esi
  8002ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	7e 17                	jle    800309 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f2:	83 ec 0c             	sub    $0xc,%esp
  8002f5:	50                   	push   %eax
  8002f6:	6a 0c                	push   $0xc
  8002f8:	68 98 0f 80 00       	push   $0x800f98
  8002fd:	6a 23                	push   $0x23
  8002ff:	68 b5 0f 80 00       	push   $0x800fb5
  800304:	e8 08 00 00 00       	call   800311 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800309:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800316:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800319:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80031f:	e8 00 fe ff ff       	call   800124 <sys_getenvid>
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	56                   	push   %esi
  80032e:	50                   	push   %eax
  80032f:	68 c4 0f 80 00       	push   $0x800fc4
  800334:	e8 b1 00 00 00       	call   8003ea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800339:	83 c4 18             	add    $0x18,%esp
  80033c:	53                   	push   %ebx
  80033d:	ff 75 10             	pushl  0x10(%ebp)
  800340:	e8 54 00 00 00       	call   800399 <vcprintf>
	cprintf("\n");
  800345:	c7 04 24 8c 0f 80 00 	movl   $0x800f8c,(%esp)
  80034c:	e8 99 00 00 00       	call   8003ea <cprintf>
  800351:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800354:	cc                   	int3   
  800355:	eb fd                	jmp    800354 <_panic+0x43>

00800357 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	53                   	push   %ebx
  80035b:	83 ec 04             	sub    $0x4,%esp
  80035e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800361:	8b 13                	mov    (%ebx),%edx
  800363:	8d 42 01             	lea    0x1(%edx),%eax
  800366:	89 03                	mov    %eax,(%ebx)
  800368:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800374:	75 1a                	jne    800390 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800376:	83 ec 08             	sub    $0x8,%esp
  800379:	68 ff 00 00 00       	push   $0xff
  80037e:	8d 43 08             	lea    0x8(%ebx),%eax
  800381:	50                   	push   %eax
  800382:	e8 1f fd ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  800387:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800390:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800394:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800397:	c9                   	leave  
  800398:	c3                   	ret    

00800399 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a9:	00 00 00 
	b.cnt = 0;
  8003ac:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b6:	ff 75 0c             	pushl  0xc(%ebp)
  8003b9:	ff 75 08             	pushl  0x8(%ebp)
  8003bc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c2:	50                   	push   %eax
  8003c3:	68 57 03 80 00       	push   $0x800357
  8003c8:	e8 4f 01 00 00       	call   80051c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003cd:	83 c4 08             	add    $0x8,%esp
  8003d0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dc:	50                   	push   %eax
  8003dd:	e8 c4 fc ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  8003e2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e8:	c9                   	leave  
  8003e9:	c3                   	ret    

008003ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f3:	50                   	push   %eax
  8003f4:	ff 75 08             	pushl  0x8(%ebp)
  8003f7:	e8 9d ff ff ff       	call   800399 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	57                   	push   %edi
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
  800404:	83 ec 1c             	sub    $0x1c,%esp
  800407:	89 c7                	mov    %eax,%edi
  800409:	89 d6                	mov    %edx,%esi
  80040b:	8b 45 08             	mov    0x8(%ebp),%eax
  80040e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800411:	89 d1                	mov    %edx,%ecx
  800413:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800416:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800419:	8b 45 10             	mov    0x10(%ebp),%eax
  80041c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80041f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800422:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800429:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80042c:	72 05                	jb     800433 <printnum+0x35>
  80042e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800431:	77 3e                	ja     800471 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800433:	83 ec 0c             	sub    $0xc,%esp
  800436:	ff 75 18             	pushl  0x18(%ebp)
  800439:	83 eb 01             	sub    $0x1,%ebx
  80043c:	53                   	push   %ebx
  80043d:	50                   	push   %eax
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	ff 75 e4             	pushl  -0x1c(%ebp)
  800444:	ff 75 e0             	pushl  -0x20(%ebp)
  800447:	ff 75 dc             	pushl  -0x24(%ebp)
  80044a:	ff 75 d8             	pushl  -0x28(%ebp)
  80044d:	e8 6e 08 00 00       	call   800cc0 <__udivdi3>
  800452:	83 c4 18             	add    $0x18,%esp
  800455:	52                   	push   %edx
  800456:	50                   	push   %eax
  800457:	89 f2                	mov    %esi,%edx
  800459:	89 f8                	mov    %edi,%eax
  80045b:	e8 9e ff ff ff       	call   8003fe <printnum>
  800460:	83 c4 20             	add    $0x20,%esp
  800463:	eb 13                	jmp    800478 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	56                   	push   %esi
  800469:	ff 75 18             	pushl  0x18(%ebp)
  80046c:	ff d7                	call   *%edi
  80046e:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800471:	83 eb 01             	sub    $0x1,%ebx
  800474:	85 db                	test   %ebx,%ebx
  800476:	7f ed                	jg     800465 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	83 ec 04             	sub    $0x4,%esp
  80047f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800482:	ff 75 e0             	pushl  -0x20(%ebp)
  800485:	ff 75 dc             	pushl  -0x24(%ebp)
  800488:	ff 75 d8             	pushl  -0x28(%ebp)
  80048b:	e8 60 09 00 00       	call   800df0 <__umoddi3>
  800490:	83 c4 14             	add    $0x14,%esp
  800493:	0f be 80 e8 0f 80 00 	movsbl 0x800fe8(%eax),%eax
  80049a:	50                   	push   %eax
  80049b:	ff d7                	call   *%edi
  80049d:	83 c4 10             	add    $0x10,%esp
}
  8004a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a3:	5b                   	pop    %ebx
  8004a4:	5e                   	pop    %esi
  8004a5:	5f                   	pop    %edi
  8004a6:	5d                   	pop    %ebp
  8004a7:	c3                   	ret    

008004a8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ab:	83 fa 01             	cmp    $0x1,%edx
  8004ae:	7e 0e                	jle    8004be <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b0:	8b 10                	mov    (%eax),%edx
  8004b2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b5:	89 08                	mov    %ecx,(%eax)
  8004b7:	8b 02                	mov    (%edx),%eax
  8004b9:	8b 52 04             	mov    0x4(%edx),%edx
  8004bc:	eb 22                	jmp    8004e0 <getuint+0x38>
	else if (lflag)
  8004be:	85 d2                	test   %edx,%edx
  8004c0:	74 10                	je     8004d2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c7:	89 08                	mov    %ecx,(%eax)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d0:	eb 0e                	jmp    8004e0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d2:	8b 10                	mov    (%eax),%edx
  8004d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d7:	89 08                	mov    %ecx,(%eax)
  8004d9:	8b 02                	mov    (%edx),%eax
  8004db:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e0:	5d                   	pop    %ebp
  8004e1:	c3                   	ret    

008004e2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ec:	8b 10                	mov    (%eax),%edx
  8004ee:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f1:	73 0a                	jae    8004fd <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f6:	89 08                	mov    %ecx,(%eax)
  8004f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fb:	88 02                	mov    %al,(%edx)
}
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800505:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800508:	50                   	push   %eax
  800509:	ff 75 10             	pushl  0x10(%ebp)
  80050c:	ff 75 0c             	pushl  0xc(%ebp)
  80050f:	ff 75 08             	pushl  0x8(%ebp)
  800512:	e8 05 00 00 00       	call   80051c <vprintfmt>
	va_end(ap);
  800517:	83 c4 10             	add    $0x10,%esp
}
  80051a:	c9                   	leave  
  80051b:	c3                   	ret    

0080051c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	57                   	push   %edi
  800520:	56                   	push   %esi
  800521:	53                   	push   %ebx
  800522:	83 ec 2c             	sub    $0x2c,%esp
  800525:	8b 75 08             	mov    0x8(%ebp),%esi
  800528:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80052e:	eb 12                	jmp    800542 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800530:	85 c0                	test   %eax,%eax
  800532:	0f 84 90 03 00 00    	je     8008c8 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	53                   	push   %ebx
  80053c:	50                   	push   %eax
  80053d:	ff d6                	call   *%esi
  80053f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800542:	83 c7 01             	add    $0x1,%edi
  800545:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800549:	83 f8 25             	cmp    $0x25,%eax
  80054c:	75 e2                	jne    800530 <vprintfmt+0x14>
  80054e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800552:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800559:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800560:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800567:	ba 00 00 00 00       	mov    $0x0,%edx
  80056c:	eb 07                	jmp    800575 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800571:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8d 47 01             	lea    0x1(%edi),%eax
  800578:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057b:	0f b6 07             	movzbl (%edi),%eax
  80057e:	0f b6 c8             	movzbl %al,%ecx
  800581:	83 e8 23             	sub    $0x23,%eax
  800584:	3c 55                	cmp    $0x55,%al
  800586:	0f 87 21 03 00 00    	ja     8008ad <vprintfmt+0x391>
  80058c:	0f b6 c0             	movzbl %al,%eax
  80058f:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  800596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800599:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80059d:	eb d6                	jmp    800575 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005aa:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ad:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005b4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005b7:	83 fa 09             	cmp    $0x9,%edx
  8005ba:	77 39                	ja     8005f5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005bc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005bf:	eb e9                	jmp    8005aa <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d2:	eb 27                	jmp    8005fb <vprintfmt+0xdf>
  8005d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005de:	0f 49 c8             	cmovns %eax,%ecx
  8005e1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	eb 8c                	jmp    800575 <vprintfmt+0x59>
  8005e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ec:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f3:	eb 80                	jmp    800575 <vprintfmt+0x59>
  8005f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ff:	0f 89 70 ff ff ff    	jns    800575 <vprintfmt+0x59>
				width = precision, precision = -1;
  800605:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800608:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800612:	e9 5e ff ff ff       	jmp    800575 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800617:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80061d:	e9 53 ff ff ff       	jmp    800575 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	ff 30                	pushl  (%eax)
  800631:	ff d6                	call   *%esi
			break;
  800633:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800639:	e9 04 ff ff ff       	jmp    800542 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	8b 00                	mov    (%eax),%eax
  800649:	99                   	cltd   
  80064a:	31 d0                	xor    %edx,%eax
  80064c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064e:	83 f8 09             	cmp    $0x9,%eax
  800651:	7f 0b                	jg     80065e <vprintfmt+0x142>
  800653:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  80065a:	85 d2                	test   %edx,%edx
  80065c:	75 18                	jne    800676 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80065e:	50                   	push   %eax
  80065f:	68 00 10 80 00       	push   $0x801000
  800664:	53                   	push   %ebx
  800665:	56                   	push   %esi
  800666:	e8 94 fe ff ff       	call   8004ff <printfmt>
  80066b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800671:	e9 cc fe ff ff       	jmp    800542 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800676:	52                   	push   %edx
  800677:	68 09 10 80 00       	push   $0x801009
  80067c:	53                   	push   %ebx
  80067d:	56                   	push   %esi
  80067e:	e8 7c fe ff ff       	call   8004ff <printfmt>
  800683:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800689:	e9 b4 fe ff ff       	jmp    800542 <vprintfmt+0x26>
  80068e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800691:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800694:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006a2:	85 ff                	test   %edi,%edi
  8006a4:	ba f9 0f 80 00       	mov    $0x800ff9,%edx
  8006a9:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8006ac:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b0:	0f 84 92 00 00 00    	je     800748 <vprintfmt+0x22c>
  8006b6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006ba:	0f 8e 96 00 00 00    	jle    800756 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	51                   	push   %ecx
  8006c4:	57                   	push   %edi
  8006c5:	e8 86 02 00 00       	call   800950 <strnlen>
  8006ca:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006cd:	29 c1                	sub    %eax,%ecx
  8006cf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006d2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006dc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006df:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e1:	eb 0f                	jmp    8006f2 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ea:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ec:	83 ef 01             	sub    $0x1,%edi
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	85 ff                	test   %edi,%edi
  8006f4:	7f ed                	jg     8006e3 <vprintfmt+0x1c7>
  8006f6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006fc:	85 c9                	test   %ecx,%ecx
  8006fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800703:	0f 49 c1             	cmovns %ecx,%eax
  800706:	29 c1                	sub    %eax,%ecx
  800708:	89 75 08             	mov    %esi,0x8(%ebp)
  80070b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800711:	89 cb                	mov    %ecx,%ebx
  800713:	eb 4d                	jmp    800762 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800715:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800719:	74 1b                	je     800736 <vprintfmt+0x21a>
  80071b:	0f be c0             	movsbl %al,%eax
  80071e:	83 e8 20             	sub    $0x20,%eax
  800721:	83 f8 5e             	cmp    $0x5e,%eax
  800724:	76 10                	jbe    800736 <vprintfmt+0x21a>
					putch('?', putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	ff 75 0c             	pushl  0xc(%ebp)
  80072c:	6a 3f                	push   $0x3f
  80072e:	ff 55 08             	call   *0x8(%ebp)
  800731:	83 c4 10             	add    $0x10,%esp
  800734:	eb 0d                	jmp    800743 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	ff 75 0c             	pushl  0xc(%ebp)
  80073c:	52                   	push   %edx
  80073d:	ff 55 08             	call   *0x8(%ebp)
  800740:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800743:	83 eb 01             	sub    $0x1,%ebx
  800746:	eb 1a                	jmp    800762 <vprintfmt+0x246>
  800748:	89 75 08             	mov    %esi,0x8(%ebp)
  80074b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800751:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800754:	eb 0c                	jmp    800762 <vprintfmt+0x246>
  800756:	89 75 08             	mov    %esi,0x8(%ebp)
  800759:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800762:	83 c7 01             	add    $0x1,%edi
  800765:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800769:	0f be d0             	movsbl %al,%edx
  80076c:	85 d2                	test   %edx,%edx
  80076e:	74 23                	je     800793 <vprintfmt+0x277>
  800770:	85 f6                	test   %esi,%esi
  800772:	78 a1                	js     800715 <vprintfmt+0x1f9>
  800774:	83 ee 01             	sub    $0x1,%esi
  800777:	79 9c                	jns    800715 <vprintfmt+0x1f9>
  800779:	89 df                	mov    %ebx,%edi
  80077b:	8b 75 08             	mov    0x8(%ebp),%esi
  80077e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800781:	eb 18                	jmp    80079b <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800783:	83 ec 08             	sub    $0x8,%esp
  800786:	53                   	push   %ebx
  800787:	6a 20                	push   $0x20
  800789:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078b:	83 ef 01             	sub    $0x1,%edi
  80078e:	83 c4 10             	add    $0x10,%esp
  800791:	eb 08                	jmp    80079b <vprintfmt+0x27f>
  800793:	89 df                	mov    %ebx,%edi
  800795:	8b 75 08             	mov    0x8(%ebp),%esi
  800798:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079b:	85 ff                	test   %edi,%edi
  80079d:	7f e4                	jg     800783 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a2:	e9 9b fd ff ff       	jmp    800542 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a7:	83 fa 01             	cmp    $0x1,%edx
  8007aa:	7e 16                	jle    8007c2 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8007ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8007af:	8d 50 08             	lea    0x8(%eax),%edx
  8007b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b5:	8b 50 04             	mov    0x4(%eax),%edx
  8007b8:	8b 00                	mov    (%eax),%eax
  8007ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c0:	eb 32                	jmp    8007f4 <vprintfmt+0x2d8>
	else if (lflag)
  8007c2:	85 d2                	test   %edx,%edx
  8007c4:	74 18                	je     8007de <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8d 50 04             	lea    0x4(%eax),%edx
  8007cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cf:	8b 00                	mov    (%eax),%eax
  8007d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d4:	89 c1                	mov    %eax,%ecx
  8007d6:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007dc:	eb 16                	jmp    8007f4 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8d 50 04             	lea    0x4(%eax),%edx
  8007e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e7:	8b 00                	mov    (%eax),%eax
  8007e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ec:	89 c1                	mov    %eax,%ecx
  8007ee:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007fa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007ff:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800803:	79 74                	jns    800879 <vprintfmt+0x35d>
				putch('-', putdat);
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	53                   	push   %ebx
  800809:	6a 2d                	push   $0x2d
  80080b:	ff d6                	call   *%esi
				num = -(long long) num;
  80080d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800810:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800813:	f7 d8                	neg    %eax
  800815:	83 d2 00             	adc    $0x0,%edx
  800818:	f7 da                	neg    %edx
  80081a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800822:	eb 55                	jmp    800879 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800824:	8d 45 14             	lea    0x14(%ebp),%eax
  800827:	e8 7c fc ff ff       	call   8004a8 <getuint>
			base = 10;
  80082c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800831:	eb 46                	jmp    800879 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800833:	8d 45 14             	lea    0x14(%ebp),%eax
  800836:	e8 6d fc ff ff       	call   8004a8 <getuint>
                        base = 8;
  80083b:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800840:	eb 37                	jmp    800879 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	53                   	push   %ebx
  800846:	6a 30                	push   $0x30
  800848:	ff d6                	call   *%esi
			putch('x', putdat);
  80084a:	83 c4 08             	add    $0x8,%esp
  80084d:	53                   	push   %ebx
  80084e:	6a 78                	push   $0x78
  800850:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800852:	8b 45 14             	mov    0x14(%ebp),%eax
  800855:	8d 50 04             	lea    0x4(%eax),%edx
  800858:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80085b:	8b 00                	mov    (%eax),%eax
  80085d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800862:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800865:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80086a:	eb 0d                	jmp    800879 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80086c:	8d 45 14             	lea    0x14(%ebp),%eax
  80086f:	e8 34 fc ff ff       	call   8004a8 <getuint>
			base = 16;
  800874:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800879:	83 ec 0c             	sub    $0xc,%esp
  80087c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800880:	57                   	push   %edi
  800881:	ff 75 e0             	pushl  -0x20(%ebp)
  800884:	51                   	push   %ecx
  800885:	52                   	push   %edx
  800886:	50                   	push   %eax
  800887:	89 da                	mov    %ebx,%edx
  800889:	89 f0                	mov    %esi,%eax
  80088b:	e8 6e fb ff ff       	call   8003fe <printnum>
			break;
  800890:	83 c4 20             	add    $0x20,%esp
  800893:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800896:	e9 a7 fc ff ff       	jmp    800542 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	53                   	push   %ebx
  80089f:	51                   	push   %ecx
  8008a0:	ff d6                	call   *%esi
			break;
  8008a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a8:	e9 95 fc ff ff       	jmp    800542 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	53                   	push   %ebx
  8008b1:	6a 25                	push   $0x25
  8008b3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	eb 03                	jmp    8008bd <vprintfmt+0x3a1>
  8008ba:	83 ef 01             	sub    $0x1,%edi
  8008bd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008c1:	75 f7                	jne    8008ba <vprintfmt+0x39e>
  8008c3:	e9 7a fc ff ff       	jmp    800542 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008cb:	5b                   	pop    %ebx
  8008cc:	5e                   	pop    %esi
  8008cd:	5f                   	pop    %edi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	83 ec 18             	sub    $0x18,%esp
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008df:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ed:	85 c0                	test   %eax,%eax
  8008ef:	74 26                	je     800917 <vsnprintf+0x47>
  8008f1:	85 d2                	test   %edx,%edx
  8008f3:	7e 22                	jle    800917 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f5:	ff 75 14             	pushl  0x14(%ebp)
  8008f8:	ff 75 10             	pushl  0x10(%ebp)
  8008fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008fe:	50                   	push   %eax
  8008ff:	68 e2 04 80 00       	push   $0x8004e2
  800904:	e8 13 fc ff ff       	call   80051c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800909:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	eb 05                	jmp    80091c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800917:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800924:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800927:	50                   	push   %eax
  800928:	ff 75 10             	pushl  0x10(%ebp)
  80092b:	ff 75 0c             	pushl  0xc(%ebp)
  80092e:	ff 75 08             	pushl  0x8(%ebp)
  800931:	e8 9a ff ff ff       	call   8008d0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80093e:	b8 00 00 00 00       	mov    $0x0,%eax
  800943:	eb 03                	jmp    800948 <strlen+0x10>
		n++;
  800945:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800948:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80094c:	75 f7                	jne    800945 <strlen+0xd>
		n++;
	return n;
}
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	eb 03                	jmp    800963 <strnlen+0x13>
		n++;
  800960:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800963:	39 c2                	cmp    %eax,%edx
  800965:	74 08                	je     80096f <strnlen+0x1f>
  800967:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80096b:	75 f3                	jne    800960 <strnlen+0x10>
  80096d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	53                   	push   %ebx
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097b:	89 c2                	mov    %eax,%edx
  80097d:	83 c2 01             	add    $0x1,%edx
  800980:	83 c1 01             	add    $0x1,%ecx
  800983:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800987:	88 5a ff             	mov    %bl,-0x1(%edx)
  80098a:	84 db                	test   %bl,%bl
  80098c:	75 ef                	jne    80097d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80098e:	5b                   	pop    %ebx
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800998:	53                   	push   %ebx
  800999:	e8 9a ff ff ff       	call   800938 <strlen>
  80099e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009a1:	ff 75 0c             	pushl  0xc(%ebp)
  8009a4:	01 d8                	add    %ebx,%eax
  8009a6:	50                   	push   %eax
  8009a7:	e8 c5 ff ff ff       	call   800971 <strcpy>
	return dst;
}
  8009ac:	89 d8                	mov    %ebx,%eax
  8009ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	56                   	push   %esi
  8009b7:	53                   	push   %ebx
  8009b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009be:	89 f3                	mov    %esi,%ebx
  8009c0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c3:	89 f2                	mov    %esi,%edx
  8009c5:	eb 0f                	jmp    8009d6 <strncpy+0x23>
		*dst++ = *src;
  8009c7:	83 c2 01             	add    $0x1,%edx
  8009ca:	0f b6 01             	movzbl (%ecx),%eax
  8009cd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d0:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d6:	39 da                	cmp    %ebx,%edx
  8009d8:	75 ed                	jne    8009c7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009da:	89 f0                	mov    %esi,%eax
  8009dc:	5b                   	pop    %ebx
  8009dd:	5e                   	pop    %esi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009eb:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ee:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f0:	85 d2                	test   %edx,%edx
  8009f2:	74 21                	je     800a15 <strlcpy+0x35>
  8009f4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009f8:	89 f2                	mov    %esi,%edx
  8009fa:	eb 09                	jmp    800a05 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009fc:	83 c2 01             	add    $0x1,%edx
  8009ff:	83 c1 01             	add    $0x1,%ecx
  800a02:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a05:	39 c2                	cmp    %eax,%edx
  800a07:	74 09                	je     800a12 <strlcpy+0x32>
  800a09:	0f b6 19             	movzbl (%ecx),%ebx
  800a0c:	84 db                	test   %bl,%bl
  800a0e:	75 ec                	jne    8009fc <strlcpy+0x1c>
  800a10:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a12:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a15:	29 f0                	sub    %esi,%eax
}
  800a17:	5b                   	pop    %ebx
  800a18:	5e                   	pop    %esi
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a21:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a24:	eb 06                	jmp    800a2c <strcmp+0x11>
		p++, q++;
  800a26:	83 c1 01             	add    $0x1,%ecx
  800a29:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2c:	0f b6 01             	movzbl (%ecx),%eax
  800a2f:	84 c0                	test   %al,%al
  800a31:	74 04                	je     800a37 <strcmp+0x1c>
  800a33:	3a 02                	cmp    (%edx),%al
  800a35:	74 ef                	je     800a26 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a37:	0f b6 c0             	movzbl %al,%eax
  800a3a:	0f b6 12             	movzbl (%edx),%edx
  800a3d:	29 d0                	sub    %edx,%eax
}
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	53                   	push   %ebx
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4b:	89 c3                	mov    %eax,%ebx
  800a4d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a50:	eb 06                	jmp    800a58 <strncmp+0x17>
		n--, p++, q++;
  800a52:	83 c0 01             	add    $0x1,%eax
  800a55:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a58:	39 d8                	cmp    %ebx,%eax
  800a5a:	74 15                	je     800a71 <strncmp+0x30>
  800a5c:	0f b6 08             	movzbl (%eax),%ecx
  800a5f:	84 c9                	test   %cl,%cl
  800a61:	74 04                	je     800a67 <strncmp+0x26>
  800a63:	3a 0a                	cmp    (%edx),%cl
  800a65:	74 eb                	je     800a52 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a67:	0f b6 00             	movzbl (%eax),%eax
  800a6a:	0f b6 12             	movzbl (%edx),%edx
  800a6d:	29 d0                	sub    %edx,%eax
  800a6f:	eb 05                	jmp    800a76 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a76:	5b                   	pop    %ebx
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a83:	eb 07                	jmp    800a8c <strchr+0x13>
		if (*s == c)
  800a85:	38 ca                	cmp    %cl,%dl
  800a87:	74 0f                	je     800a98 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a89:	83 c0 01             	add    $0x1,%eax
  800a8c:	0f b6 10             	movzbl (%eax),%edx
  800a8f:	84 d2                	test   %dl,%dl
  800a91:	75 f2                	jne    800a85 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa4:	eb 03                	jmp    800aa9 <strfind+0xf>
  800aa6:	83 c0 01             	add    $0x1,%eax
  800aa9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aac:	84 d2                	test   %dl,%dl
  800aae:	74 04                	je     800ab4 <strfind+0x1a>
  800ab0:	38 ca                	cmp    %cl,%dl
  800ab2:	75 f2                	jne    800aa6 <strfind+0xc>
			break;
	return (char *) s;
}
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	57                   	push   %edi
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
  800abc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800abf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac2:	85 c9                	test   %ecx,%ecx
  800ac4:	74 36                	je     800afc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acc:	75 28                	jne    800af6 <memset+0x40>
  800ace:	f6 c1 03             	test   $0x3,%cl
  800ad1:	75 23                	jne    800af6 <memset+0x40>
		c &= 0xFF;
  800ad3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad7:	89 d3                	mov    %edx,%ebx
  800ad9:	c1 e3 08             	shl    $0x8,%ebx
  800adc:	89 d6                	mov    %edx,%esi
  800ade:	c1 e6 18             	shl    $0x18,%esi
  800ae1:	89 d0                	mov    %edx,%eax
  800ae3:	c1 e0 10             	shl    $0x10,%eax
  800ae6:	09 f0                	or     %esi,%eax
  800ae8:	09 c2                	or     %eax,%edx
  800aea:	89 d0                	mov    %edx,%eax
  800aec:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aee:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800af1:	fc                   	cld    
  800af2:	f3 ab                	rep stos %eax,%es:(%edi)
  800af4:	eb 06                	jmp    800afc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af9:	fc                   	cld    
  800afa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afc:	89 f8                	mov    %edi,%eax
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b11:	39 c6                	cmp    %eax,%esi
  800b13:	73 35                	jae    800b4a <memmove+0x47>
  800b15:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b18:	39 d0                	cmp    %edx,%eax
  800b1a:	73 2e                	jae    800b4a <memmove+0x47>
		s += n;
		d += n;
  800b1c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b1f:	89 d6                	mov    %edx,%esi
  800b21:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b23:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b29:	75 13                	jne    800b3e <memmove+0x3b>
  800b2b:	f6 c1 03             	test   $0x3,%cl
  800b2e:	75 0e                	jne    800b3e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b30:	83 ef 04             	sub    $0x4,%edi
  800b33:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b36:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b39:	fd                   	std    
  800b3a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3c:	eb 09                	jmp    800b47 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b3e:	83 ef 01             	sub    $0x1,%edi
  800b41:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b44:	fd                   	std    
  800b45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b47:	fc                   	cld    
  800b48:	eb 1d                	jmp    800b67 <memmove+0x64>
  800b4a:	89 f2                	mov    %esi,%edx
  800b4c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4e:	f6 c2 03             	test   $0x3,%dl
  800b51:	75 0f                	jne    800b62 <memmove+0x5f>
  800b53:	f6 c1 03             	test   $0x3,%cl
  800b56:	75 0a                	jne    800b62 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b58:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b5b:	89 c7                	mov    %eax,%edi
  800b5d:	fc                   	cld    
  800b5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b60:	eb 05                	jmp    800b67 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b62:	89 c7                	mov    %eax,%edi
  800b64:	fc                   	cld    
  800b65:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b6e:	ff 75 10             	pushl  0x10(%ebp)
  800b71:	ff 75 0c             	pushl  0xc(%ebp)
  800b74:	ff 75 08             	pushl  0x8(%ebp)
  800b77:	e8 87 ff ff ff       	call   800b03 <memmove>
}
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	8b 45 08             	mov    0x8(%ebp),%eax
  800b86:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b89:	89 c6                	mov    %eax,%esi
  800b8b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8e:	eb 1a                	jmp    800baa <memcmp+0x2c>
		if (*s1 != *s2)
  800b90:	0f b6 08             	movzbl (%eax),%ecx
  800b93:	0f b6 1a             	movzbl (%edx),%ebx
  800b96:	38 d9                	cmp    %bl,%cl
  800b98:	74 0a                	je     800ba4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b9a:	0f b6 c1             	movzbl %cl,%eax
  800b9d:	0f b6 db             	movzbl %bl,%ebx
  800ba0:	29 d8                	sub    %ebx,%eax
  800ba2:	eb 0f                	jmp    800bb3 <memcmp+0x35>
		s1++, s2++;
  800ba4:	83 c0 01             	add    $0x1,%eax
  800ba7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800baa:	39 f0                	cmp    %esi,%eax
  800bac:	75 e2                	jne    800b90 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bc0:	89 c2                	mov    %eax,%edx
  800bc2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc5:	eb 07                	jmp    800bce <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc7:	38 08                	cmp    %cl,(%eax)
  800bc9:	74 07                	je     800bd2 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bcb:	83 c0 01             	add    $0x1,%eax
  800bce:	39 d0                	cmp    %edx,%eax
  800bd0:	72 f5                	jb     800bc7 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be0:	eb 03                	jmp    800be5 <strtol+0x11>
		s++;
  800be2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be5:	0f b6 01             	movzbl (%ecx),%eax
  800be8:	3c 09                	cmp    $0x9,%al
  800bea:	74 f6                	je     800be2 <strtol+0xe>
  800bec:	3c 20                	cmp    $0x20,%al
  800bee:	74 f2                	je     800be2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf0:	3c 2b                	cmp    $0x2b,%al
  800bf2:	75 0a                	jne    800bfe <strtol+0x2a>
		s++;
  800bf4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bfc:	eb 10                	jmp    800c0e <strtol+0x3a>
  800bfe:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c03:	3c 2d                	cmp    $0x2d,%al
  800c05:	75 07                	jne    800c0e <strtol+0x3a>
		s++, neg = 1;
  800c07:	8d 49 01             	lea    0x1(%ecx),%ecx
  800c0a:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0e:	85 db                	test   %ebx,%ebx
  800c10:	0f 94 c0             	sete   %al
  800c13:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c19:	75 19                	jne    800c34 <strtol+0x60>
  800c1b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c1e:	75 14                	jne    800c34 <strtol+0x60>
  800c20:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c24:	0f 85 82 00 00 00    	jne    800cac <strtol+0xd8>
		s += 2, base = 16;
  800c2a:	83 c1 02             	add    $0x2,%ecx
  800c2d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c32:	eb 16                	jmp    800c4a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c34:	84 c0                	test   %al,%al
  800c36:	74 12                	je     800c4a <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c38:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c40:	75 08                	jne    800c4a <strtol+0x76>
		s++, base = 8;
  800c42:	83 c1 01             	add    $0x1,%ecx
  800c45:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c52:	0f b6 11             	movzbl (%ecx),%edx
  800c55:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c58:	89 f3                	mov    %esi,%ebx
  800c5a:	80 fb 09             	cmp    $0x9,%bl
  800c5d:	77 08                	ja     800c67 <strtol+0x93>
			dig = *s - '0';
  800c5f:	0f be d2             	movsbl %dl,%edx
  800c62:	83 ea 30             	sub    $0x30,%edx
  800c65:	eb 22                	jmp    800c89 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c67:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c6a:	89 f3                	mov    %esi,%ebx
  800c6c:	80 fb 19             	cmp    $0x19,%bl
  800c6f:	77 08                	ja     800c79 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c71:	0f be d2             	movsbl %dl,%edx
  800c74:	83 ea 57             	sub    $0x57,%edx
  800c77:	eb 10                	jmp    800c89 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c79:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c7c:	89 f3                	mov    %esi,%ebx
  800c7e:	80 fb 19             	cmp    $0x19,%bl
  800c81:	77 16                	ja     800c99 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c83:	0f be d2             	movsbl %dl,%edx
  800c86:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c89:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c8c:	7d 0f                	jge    800c9d <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c8e:	83 c1 01             	add    $0x1,%ecx
  800c91:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c95:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c97:	eb b9                	jmp    800c52 <strtol+0x7e>
  800c99:	89 c2                	mov    %eax,%edx
  800c9b:	eb 02                	jmp    800c9f <strtol+0xcb>
  800c9d:	89 c2                	mov    %eax,%edx

	if (endptr)
  800c9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca3:	74 0d                	je     800cb2 <strtol+0xde>
		*endptr = (char *) s;
  800ca5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca8:	89 0e                	mov    %ecx,(%esi)
  800caa:	eb 06                	jmp    800cb2 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cac:	84 c0                	test   %al,%al
  800cae:	75 92                	jne    800c42 <strtol+0x6e>
  800cb0:	eb 98                	jmp    800c4a <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cb2:	f7 da                	neg    %edx
  800cb4:	85 ff                	test   %edi,%edi
  800cb6:	0f 45 c2             	cmovne %edx,%eax
}
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    
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
