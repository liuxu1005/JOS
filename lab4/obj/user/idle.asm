
obj/user/idle:     file format elf32-i386


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
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 20 80 00 80 	movl   $0x800f80,0x802000
  800040:	0f 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 f7 00 00 00       	call   80013f <sys_yield>
	}
  800048:	eb f9                	jmp    800043 <umain+0x10>

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
  800055:	e8 c6 00 00 00       	call   800120 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
  80009d:	83 c4 10             	add    $0x10,%esp
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 8f 0f 80 00       	push   $0x800f8f
  80010c:	6a 23                	push   $0x23
  80010e:	68 ac 0f 80 00       	push   $0x800fac
  800113:	e8 f5 01 00 00       	call   80030d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 8f 0f 80 00       	push   $0x800f8f
  80018d:	6a 23                	push   $0x23
  80018f:	68 ac 0f 80 00       	push   $0x800fac
  800194:	e8 74 01 00 00       	call   80030d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 8f 0f 80 00       	push   $0x800f8f
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 ac 0f 80 00       	push   $0x800fac
  8001d6:	e8 32 01 00 00       	call   80030d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 8f 0f 80 00       	push   $0x800f8f
  800211:	6a 23                	push   $0x23
  800213:	68 ac 0f 80 00       	push   $0x800fac
  800218:	e8 f0 00 00 00       	call   80030d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 8f 0f 80 00       	push   $0x800f8f
  800253:	6a 23                	push   $0x23
  800255:	68 ac 0f 80 00       	push   $0x800fac
  80025a:	e8 ae 00 00 00       	call   80030d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 8f 0f 80 00       	push   $0x800f8f
  800295:	6a 23                	push   $0x23
  800297:	68 ac 0f 80 00       	push   $0x800fac
  80029c:	e8 6c 00 00 00       	call   80030d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002af:	be 00 00 00 00       	mov    $0x0,%esi
  8002b4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002da:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002df:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e2:	89 cb                	mov    %ecx,%ebx
  8002e4:	89 cf                	mov    %ecx,%edi
  8002e6:	89 ce                	mov    %ecx,%esi
  8002e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7e 17                	jle    800305 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ee:	83 ec 0c             	sub    $0xc,%esp
  8002f1:	50                   	push   %eax
  8002f2:	6a 0c                	push   $0xc
  8002f4:	68 8f 0f 80 00       	push   $0x800f8f
  8002f9:	6a 23                	push   $0x23
  8002fb:	68 ac 0f 80 00       	push   $0x800fac
  800300:	e8 08 00 00 00       	call   80030d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800305:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800308:	5b                   	pop    %ebx
  800309:	5e                   	pop    %esi
  80030a:	5f                   	pop    %edi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800312:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800315:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80031b:	e8 00 fe ff ff       	call   800120 <sys_getenvid>
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	ff 75 0c             	pushl  0xc(%ebp)
  800326:	ff 75 08             	pushl  0x8(%ebp)
  800329:	56                   	push   %esi
  80032a:	50                   	push   %eax
  80032b:	68 bc 0f 80 00       	push   $0x800fbc
  800330:	e8 b1 00 00 00       	call   8003e6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800335:	83 c4 18             	add    $0x18,%esp
  800338:	53                   	push   %ebx
  800339:	ff 75 10             	pushl  0x10(%ebp)
  80033c:	e8 54 00 00 00       	call   800395 <vcprintf>
	cprintf("\n");
  800341:	c7 04 24 e0 0f 80 00 	movl   $0x800fe0,(%esp)
  800348:	e8 99 00 00 00       	call   8003e6 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800350:	cc                   	int3   
  800351:	eb fd                	jmp    800350 <_panic+0x43>

00800353 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	53                   	push   %ebx
  800357:	83 ec 04             	sub    $0x4,%esp
  80035a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035d:	8b 13                	mov    (%ebx),%edx
  80035f:	8d 42 01             	lea    0x1(%edx),%eax
  800362:	89 03                	mov    %eax,(%ebx)
  800364:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800367:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800370:	75 1a                	jne    80038c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	68 ff 00 00 00       	push   $0xff
  80037a:	8d 43 08             	lea    0x8(%ebx),%eax
  80037d:	50                   	push   %eax
  80037e:	e8 1f fd ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  800383:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800389:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80038c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800390:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800393:	c9                   	leave  
  800394:	c3                   	ret    

00800395 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80039e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a5:	00 00 00 
	b.cnt = 0;
  8003a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003af:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b2:	ff 75 0c             	pushl  0xc(%ebp)
  8003b5:	ff 75 08             	pushl  0x8(%ebp)
  8003b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003be:	50                   	push   %eax
  8003bf:	68 53 03 80 00       	push   $0x800353
  8003c4:	e8 4f 01 00 00       	call   800518 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c9:	83 c4 08             	add    $0x8,%esp
  8003cc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d8:	50                   	push   %eax
  8003d9:	e8 c4 fc ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8003de:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e4:	c9                   	leave  
  8003e5:	c3                   	ret    

008003e6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ec:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ef:	50                   	push   %eax
  8003f0:	ff 75 08             	pushl  0x8(%ebp)
  8003f3:	e8 9d ff ff ff       	call   800395 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f8:	c9                   	leave  
  8003f9:	c3                   	ret    

008003fa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	57                   	push   %edi
  8003fe:	56                   	push   %esi
  8003ff:	53                   	push   %ebx
  800400:	83 ec 1c             	sub    $0x1c,%esp
  800403:	89 c7                	mov    %eax,%edi
  800405:	89 d6                	mov    %edx,%esi
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
  80040a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040d:	89 d1                	mov    %edx,%ecx
  80040f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800412:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800415:	8b 45 10             	mov    0x10(%ebp),%eax
  800418:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80041b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800425:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800428:	72 05                	jb     80042f <printnum+0x35>
  80042a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80042d:	77 3e                	ja     80046d <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	83 eb 01             	sub    $0x1,%ebx
  800438:	53                   	push   %ebx
  800439:	50                   	push   %eax
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800440:	ff 75 e0             	pushl  -0x20(%ebp)
  800443:	ff 75 dc             	pushl  -0x24(%ebp)
  800446:	ff 75 d8             	pushl  -0x28(%ebp)
  800449:	e8 72 08 00 00       	call   800cc0 <__udivdi3>
  80044e:	83 c4 18             	add    $0x18,%esp
  800451:	52                   	push   %edx
  800452:	50                   	push   %eax
  800453:	89 f2                	mov    %esi,%edx
  800455:	89 f8                	mov    %edi,%eax
  800457:	e8 9e ff ff ff       	call   8003fa <printnum>
  80045c:	83 c4 20             	add    $0x20,%esp
  80045f:	eb 13                	jmp    800474 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	56                   	push   %esi
  800465:	ff 75 18             	pushl  0x18(%ebp)
  800468:	ff d7                	call   *%edi
  80046a:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80046d:	83 eb 01             	sub    $0x1,%ebx
  800470:	85 db                	test   %ebx,%ebx
  800472:	7f ed                	jg     800461 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	56                   	push   %esi
  800478:	83 ec 04             	sub    $0x4,%esp
  80047b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047e:	ff 75 e0             	pushl  -0x20(%ebp)
  800481:	ff 75 dc             	pushl  -0x24(%ebp)
  800484:	ff 75 d8             	pushl  -0x28(%ebp)
  800487:	e8 64 09 00 00       	call   800df0 <__umoddi3>
  80048c:	83 c4 14             	add    $0x14,%esp
  80048f:	0f be 80 e2 0f 80 00 	movsbl 0x800fe2(%eax),%eax
  800496:	50                   	push   %eax
  800497:	ff d7                	call   *%edi
  800499:	83 c4 10             	add    $0x10,%esp
}
  80049c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049f:	5b                   	pop    %ebx
  8004a0:	5e                   	pop    %esi
  8004a1:	5f                   	pop    %edi
  8004a2:	5d                   	pop    %ebp
  8004a3:	c3                   	ret    

008004a4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a7:	83 fa 01             	cmp    $0x1,%edx
  8004aa:	7e 0e                	jle    8004ba <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004ac:	8b 10                	mov    (%eax),%edx
  8004ae:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b1:	89 08                	mov    %ecx,(%eax)
  8004b3:	8b 02                	mov    (%edx),%eax
  8004b5:	8b 52 04             	mov    0x4(%edx),%edx
  8004b8:	eb 22                	jmp    8004dc <getuint+0x38>
	else if (lflag)
  8004ba:	85 d2                	test   %edx,%edx
  8004bc:	74 10                	je     8004ce <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004be:	8b 10                	mov    (%eax),%edx
  8004c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c3:	89 08                	mov    %ecx,(%eax)
  8004c5:	8b 02                	mov    (%edx),%eax
  8004c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8004cc:	eb 0e                	jmp    8004dc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ce:	8b 10                	mov    (%eax),%edx
  8004d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d3:	89 08                	mov    %ecx,(%eax)
  8004d5:	8b 02                	mov    (%edx),%eax
  8004d7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004dc:	5d                   	pop    %ebp
  8004dd:	c3                   	ret    

008004de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e8:	8b 10                	mov    (%eax),%edx
  8004ea:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ed:	73 0a                	jae    8004f9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f2:	89 08                	mov    %ecx,(%eax)
  8004f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f7:	88 02                	mov    %al,(%edx)
}
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800501:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800504:	50                   	push   %eax
  800505:	ff 75 10             	pushl  0x10(%ebp)
  800508:	ff 75 0c             	pushl  0xc(%ebp)
  80050b:	ff 75 08             	pushl  0x8(%ebp)
  80050e:	e8 05 00 00 00       	call   800518 <vprintfmt>
	va_end(ap);
  800513:	83 c4 10             	add    $0x10,%esp
}
  800516:	c9                   	leave  
  800517:	c3                   	ret    

00800518 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	57                   	push   %edi
  80051c:	56                   	push   %esi
  80051d:	53                   	push   %ebx
  80051e:	83 ec 2c             	sub    $0x2c,%esp
  800521:	8b 75 08             	mov    0x8(%ebp),%esi
  800524:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800527:	8b 7d 10             	mov    0x10(%ebp),%edi
  80052a:	eb 12                	jmp    80053e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80052c:	85 c0                	test   %eax,%eax
  80052e:	0f 84 90 03 00 00    	je     8008c4 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800534:	83 ec 08             	sub    $0x8,%esp
  800537:	53                   	push   %ebx
  800538:	50                   	push   %eax
  800539:	ff d6                	call   *%esi
  80053b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80053e:	83 c7 01             	add    $0x1,%edi
  800541:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800545:	83 f8 25             	cmp    $0x25,%eax
  800548:	75 e2                	jne    80052c <vprintfmt+0x14>
  80054a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80054e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800555:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80055c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800563:	ba 00 00 00 00       	mov    $0x0,%edx
  800568:	eb 07                	jmp    800571 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80056d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8d 47 01             	lea    0x1(%edi),%eax
  800574:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800577:	0f b6 07             	movzbl (%edi),%eax
  80057a:	0f b6 c8             	movzbl %al,%ecx
  80057d:	83 e8 23             	sub    $0x23,%eax
  800580:	3c 55                	cmp    $0x55,%al
  800582:	0f 87 21 03 00 00    	ja     8008a9 <vprintfmt+0x391>
  800588:	0f b6 c0             	movzbl %al,%eax
  80058b:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800595:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800599:	eb d6                	jmp    800571 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059e:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005ad:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005b0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005b3:	83 fa 09             	cmp    $0x9,%edx
  8005b6:	77 39                	ja     8005f1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005bb:	eb e9                	jmp    8005a6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005c6:	8b 00                	mov    (%eax),%eax
  8005c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ce:	eb 27                	jmp    8005f7 <vprintfmt+0xdf>
  8005d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005da:	0f 49 c8             	cmovns %eax,%ecx
  8005dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e3:	eb 8c                	jmp    800571 <vprintfmt+0x59>
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ef:	eb 80                	jmp    800571 <vprintfmt+0x59>
  8005f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005fb:	0f 89 70 ff ff ff    	jns    800571 <vprintfmt+0x59>
				width = precision, precision = -1;
  800601:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800604:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800607:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80060e:	e9 5e ff ff ff       	jmp    800571 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800613:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800619:	e9 53 ff ff ff       	jmp    800571 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 50 04             	lea    0x4(%eax),%edx
  800624:	89 55 14             	mov    %edx,0x14(%ebp)
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	ff 30                	pushl  (%eax)
  80062d:	ff d6                	call   *%esi
			break;
  80062f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800635:	e9 04 ff ff ff       	jmp    80053e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	8b 00                	mov    (%eax),%eax
  800645:	99                   	cltd   
  800646:	31 d0                	xor    %edx,%eax
  800648:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064a:	83 f8 09             	cmp    $0x9,%eax
  80064d:	7f 0b                	jg     80065a <vprintfmt+0x142>
  80064f:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  800656:	85 d2                	test   %edx,%edx
  800658:	75 18                	jne    800672 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80065a:	50                   	push   %eax
  80065b:	68 fa 0f 80 00       	push   $0x800ffa
  800660:	53                   	push   %ebx
  800661:	56                   	push   %esi
  800662:	e8 94 fe ff ff       	call   8004fb <printfmt>
  800667:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80066d:	e9 cc fe ff ff       	jmp    80053e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800672:	52                   	push   %edx
  800673:	68 03 10 80 00       	push   $0x801003
  800678:	53                   	push   %ebx
  800679:	56                   	push   %esi
  80067a:	e8 7c fe ff ff       	call   8004fb <printfmt>
  80067f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800682:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800685:	e9 b4 fe ff ff       	jmp    80053e <vprintfmt+0x26>
  80068a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80068d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800690:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8d 50 04             	lea    0x4(%eax),%edx
  800699:	89 55 14             	mov    %edx,0x14(%ebp)
  80069c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069e:	85 ff                	test   %edi,%edi
  8006a0:	ba f3 0f 80 00       	mov    $0x800ff3,%edx
  8006a5:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8006a8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006ac:	0f 84 92 00 00 00    	je     800744 <vprintfmt+0x22c>
  8006b2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006b6:	0f 8e 96 00 00 00    	jle    800752 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	51                   	push   %ecx
  8006c0:	57                   	push   %edi
  8006c1:	e8 86 02 00 00       	call   80094c <strnlen>
  8006c6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006c9:	29 c1                	sub    %eax,%ecx
  8006cb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006ce:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006db:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dd:	eb 0f                	jmp    8006ee <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e8:	83 ef 01             	sub    $0x1,%edi
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 ff                	test   %edi,%edi
  8006f0:	7f ed                	jg     8006df <vprintfmt+0x1c7>
  8006f2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006f8:	85 c9                	test   %ecx,%ecx
  8006fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ff:	0f 49 c1             	cmovns %ecx,%eax
  800702:	29 c1                	sub    %eax,%ecx
  800704:	89 75 08             	mov    %esi,0x8(%ebp)
  800707:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070d:	89 cb                	mov    %ecx,%ebx
  80070f:	eb 4d                	jmp    80075e <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800711:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800715:	74 1b                	je     800732 <vprintfmt+0x21a>
  800717:	0f be c0             	movsbl %al,%eax
  80071a:	83 e8 20             	sub    $0x20,%eax
  80071d:	83 f8 5e             	cmp    $0x5e,%eax
  800720:	76 10                	jbe    800732 <vprintfmt+0x21a>
					putch('?', putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	ff 75 0c             	pushl  0xc(%ebp)
  800728:	6a 3f                	push   $0x3f
  80072a:	ff 55 08             	call   *0x8(%ebp)
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	eb 0d                	jmp    80073f <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	ff 75 0c             	pushl  0xc(%ebp)
  800738:	52                   	push   %edx
  800739:	ff 55 08             	call   *0x8(%ebp)
  80073c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073f:	83 eb 01             	sub    $0x1,%ebx
  800742:	eb 1a                	jmp    80075e <vprintfmt+0x246>
  800744:	89 75 08             	mov    %esi,0x8(%ebp)
  800747:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800750:	eb 0c                	jmp    80075e <vprintfmt+0x246>
  800752:	89 75 08             	mov    %esi,0x8(%ebp)
  800755:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800758:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80075e:	83 c7 01             	add    $0x1,%edi
  800761:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800765:	0f be d0             	movsbl %al,%edx
  800768:	85 d2                	test   %edx,%edx
  80076a:	74 23                	je     80078f <vprintfmt+0x277>
  80076c:	85 f6                	test   %esi,%esi
  80076e:	78 a1                	js     800711 <vprintfmt+0x1f9>
  800770:	83 ee 01             	sub    $0x1,%esi
  800773:	79 9c                	jns    800711 <vprintfmt+0x1f9>
  800775:	89 df                	mov    %ebx,%edi
  800777:	8b 75 08             	mov    0x8(%ebp),%esi
  80077a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077d:	eb 18                	jmp    800797 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	53                   	push   %ebx
  800783:	6a 20                	push   $0x20
  800785:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800787:	83 ef 01             	sub    $0x1,%edi
  80078a:	83 c4 10             	add    $0x10,%esp
  80078d:	eb 08                	jmp    800797 <vprintfmt+0x27f>
  80078f:	89 df                	mov    %ebx,%edi
  800791:	8b 75 08             	mov    0x8(%ebp),%esi
  800794:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800797:	85 ff                	test   %edi,%edi
  800799:	7f e4                	jg     80077f <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079e:	e9 9b fd ff ff       	jmp    80053e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a3:	83 fa 01             	cmp    $0x1,%edx
  8007a6:	7e 16                	jle    8007be <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8d 50 08             	lea    0x8(%eax),%edx
  8007ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b1:	8b 50 04             	mov    0x4(%eax),%edx
  8007b4:	8b 00                	mov    (%eax),%eax
  8007b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007bc:	eb 32                	jmp    8007f0 <vprintfmt+0x2d8>
	else if (lflag)
  8007be:	85 d2                	test   %edx,%edx
  8007c0:	74 18                	je     8007da <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8d 50 04             	lea    0x4(%eax),%edx
  8007c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cb:	8b 00                	mov    (%eax),%eax
  8007cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d0:	89 c1                	mov    %eax,%ecx
  8007d2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007d8:	eb 16                	jmp    8007f0 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8d 50 04             	lea    0x4(%eax),%edx
  8007e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e3:	8b 00                	mov    (%eax),%eax
  8007e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e8:	89 c1                	mov    %eax,%ecx
  8007ea:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007fb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ff:	79 74                	jns    800875 <vprintfmt+0x35d>
				putch('-', putdat);
  800801:	83 ec 08             	sub    $0x8,%esp
  800804:	53                   	push   %ebx
  800805:	6a 2d                	push   $0x2d
  800807:	ff d6                	call   *%esi
				num = -(long long) num;
  800809:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80080f:	f7 d8                	neg    %eax
  800811:	83 d2 00             	adc    $0x0,%edx
  800814:	f7 da                	neg    %edx
  800816:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800819:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80081e:	eb 55                	jmp    800875 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800820:	8d 45 14             	lea    0x14(%ebp),%eax
  800823:	e8 7c fc ff ff       	call   8004a4 <getuint>
			base = 10;
  800828:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80082d:	eb 46                	jmp    800875 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80082f:	8d 45 14             	lea    0x14(%ebp),%eax
  800832:	e8 6d fc ff ff       	call   8004a4 <getuint>
                        base = 8;
  800837:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80083c:	eb 37                	jmp    800875 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	53                   	push   %ebx
  800842:	6a 30                	push   $0x30
  800844:	ff d6                	call   *%esi
			putch('x', putdat);
  800846:	83 c4 08             	add    $0x8,%esp
  800849:	53                   	push   %ebx
  80084a:	6a 78                	push   $0x78
  80084c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80084e:	8b 45 14             	mov    0x14(%ebp),%eax
  800851:	8d 50 04             	lea    0x4(%eax),%edx
  800854:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800857:	8b 00                	mov    (%eax),%eax
  800859:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80085e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800861:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800866:	eb 0d                	jmp    800875 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800868:	8d 45 14             	lea    0x14(%ebp),%eax
  80086b:	e8 34 fc ff ff       	call   8004a4 <getuint>
			base = 16;
  800870:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800875:	83 ec 0c             	sub    $0xc,%esp
  800878:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80087c:	57                   	push   %edi
  80087d:	ff 75 e0             	pushl  -0x20(%ebp)
  800880:	51                   	push   %ecx
  800881:	52                   	push   %edx
  800882:	50                   	push   %eax
  800883:	89 da                	mov    %ebx,%edx
  800885:	89 f0                	mov    %esi,%eax
  800887:	e8 6e fb ff ff       	call   8003fa <printnum>
			break;
  80088c:	83 c4 20             	add    $0x20,%esp
  80088f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800892:	e9 a7 fc ff ff       	jmp    80053e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	51                   	push   %ecx
  80089c:	ff d6                	call   *%esi
			break;
  80089e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a4:	e9 95 fc ff ff       	jmp    80053e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008a9:	83 ec 08             	sub    $0x8,%esp
  8008ac:	53                   	push   %ebx
  8008ad:	6a 25                	push   $0x25
  8008af:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 03                	jmp    8008b9 <vprintfmt+0x3a1>
  8008b6:	83 ef 01             	sub    $0x1,%edi
  8008b9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008bd:	75 f7                	jne    8008b6 <vprintfmt+0x39e>
  8008bf:	e9 7a fc ff ff       	jmp    80053e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c7:	5b                   	pop    %ebx
  8008c8:	5e                   	pop    %esi
  8008c9:	5f                   	pop    %edi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	83 ec 18             	sub    $0x18,%esp
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008db:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008df:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008e9:	85 c0                	test   %eax,%eax
  8008eb:	74 26                	je     800913 <vsnprintf+0x47>
  8008ed:	85 d2                	test   %edx,%edx
  8008ef:	7e 22                	jle    800913 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f1:	ff 75 14             	pushl  0x14(%ebp)
  8008f4:	ff 75 10             	pushl  0x10(%ebp)
  8008f7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008fa:	50                   	push   %eax
  8008fb:	68 de 04 80 00       	push   $0x8004de
  800900:	e8 13 fc ff ff       	call   800518 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800905:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800908:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	eb 05                	jmp    800918 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800913:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800918:	c9                   	leave  
  800919:	c3                   	ret    

0080091a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800920:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800923:	50                   	push   %eax
  800924:	ff 75 10             	pushl  0x10(%ebp)
  800927:	ff 75 0c             	pushl  0xc(%ebp)
  80092a:	ff 75 08             	pushl  0x8(%ebp)
  80092d:	e8 9a ff ff ff       	call   8008cc <vsnprintf>
	va_end(ap);

	return rc;
}
  800932:	c9                   	leave  
  800933:	c3                   	ret    

00800934 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80093a:	b8 00 00 00 00       	mov    $0x0,%eax
  80093f:	eb 03                	jmp    800944 <strlen+0x10>
		n++;
  800941:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800944:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800948:	75 f7                	jne    800941 <strlen+0xd>
		n++;
	return n;
}
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800955:	ba 00 00 00 00       	mov    $0x0,%edx
  80095a:	eb 03                	jmp    80095f <strnlen+0x13>
		n++;
  80095c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095f:	39 c2                	cmp    %eax,%edx
  800961:	74 08                	je     80096b <strnlen+0x1f>
  800963:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800967:	75 f3                	jne    80095c <strnlen+0x10>
  800969:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	53                   	push   %ebx
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800977:	89 c2                	mov    %eax,%edx
  800979:	83 c2 01             	add    $0x1,%edx
  80097c:	83 c1 01             	add    $0x1,%ecx
  80097f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800983:	88 5a ff             	mov    %bl,-0x1(%edx)
  800986:	84 db                	test   %bl,%bl
  800988:	75 ef                	jne    800979 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80098a:	5b                   	pop    %ebx
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800994:	53                   	push   %ebx
  800995:	e8 9a ff ff ff       	call   800934 <strlen>
  80099a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80099d:	ff 75 0c             	pushl  0xc(%ebp)
  8009a0:	01 d8                	add    %ebx,%eax
  8009a2:	50                   	push   %eax
  8009a3:	e8 c5 ff ff ff       	call   80096d <strcpy>
	return dst;
}
  8009a8:	89 d8                	mov    %ebx,%eax
  8009aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ba:	89 f3                	mov    %esi,%ebx
  8009bc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009bf:	89 f2                	mov    %esi,%edx
  8009c1:	eb 0f                	jmp    8009d2 <strncpy+0x23>
		*dst++ = *src;
  8009c3:	83 c2 01             	add    $0x1,%edx
  8009c6:	0f b6 01             	movzbl (%ecx),%eax
  8009c9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009cc:	80 39 01             	cmpb   $0x1,(%ecx)
  8009cf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d2:	39 da                	cmp    %ebx,%edx
  8009d4:	75 ed                	jne    8009c3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d6:	89 f0                	mov    %esi,%eax
  8009d8:	5b                   	pop    %ebx
  8009d9:	5e                   	pop    %esi
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e7:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ea:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ec:	85 d2                	test   %edx,%edx
  8009ee:	74 21                	je     800a11 <strlcpy+0x35>
  8009f0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009f4:	89 f2                	mov    %esi,%edx
  8009f6:	eb 09                	jmp    800a01 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009f8:	83 c2 01             	add    $0x1,%edx
  8009fb:	83 c1 01             	add    $0x1,%ecx
  8009fe:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a01:	39 c2                	cmp    %eax,%edx
  800a03:	74 09                	je     800a0e <strlcpy+0x32>
  800a05:	0f b6 19             	movzbl (%ecx),%ebx
  800a08:	84 db                	test   %bl,%bl
  800a0a:	75 ec                	jne    8009f8 <strlcpy+0x1c>
  800a0c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a0e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a11:	29 f0                	sub    %esi,%eax
}
  800a13:	5b                   	pop    %ebx
  800a14:	5e                   	pop    %esi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a20:	eb 06                	jmp    800a28 <strcmp+0x11>
		p++, q++;
  800a22:	83 c1 01             	add    $0x1,%ecx
  800a25:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a28:	0f b6 01             	movzbl (%ecx),%eax
  800a2b:	84 c0                	test   %al,%al
  800a2d:	74 04                	je     800a33 <strcmp+0x1c>
  800a2f:	3a 02                	cmp    (%edx),%al
  800a31:	74 ef                	je     800a22 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a33:	0f b6 c0             	movzbl %al,%eax
  800a36:	0f b6 12             	movzbl (%edx),%edx
  800a39:	29 d0                	sub    %edx,%eax
}
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	53                   	push   %ebx
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a47:	89 c3                	mov    %eax,%ebx
  800a49:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a4c:	eb 06                	jmp    800a54 <strncmp+0x17>
		n--, p++, q++;
  800a4e:	83 c0 01             	add    $0x1,%eax
  800a51:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a54:	39 d8                	cmp    %ebx,%eax
  800a56:	74 15                	je     800a6d <strncmp+0x30>
  800a58:	0f b6 08             	movzbl (%eax),%ecx
  800a5b:	84 c9                	test   %cl,%cl
  800a5d:	74 04                	je     800a63 <strncmp+0x26>
  800a5f:	3a 0a                	cmp    (%edx),%cl
  800a61:	74 eb                	je     800a4e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a63:	0f b6 00             	movzbl (%eax),%eax
  800a66:	0f b6 12             	movzbl (%edx),%edx
  800a69:	29 d0                	sub    %edx,%eax
  800a6b:	eb 05                	jmp    800a72 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a72:	5b                   	pop    %ebx
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a7f:	eb 07                	jmp    800a88 <strchr+0x13>
		if (*s == c)
  800a81:	38 ca                	cmp    %cl,%dl
  800a83:	74 0f                	je     800a94 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a85:	83 c0 01             	add    $0x1,%eax
  800a88:	0f b6 10             	movzbl (%eax),%edx
  800a8b:	84 d2                	test   %dl,%dl
  800a8d:	75 f2                	jne    800a81 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa0:	eb 03                	jmp    800aa5 <strfind+0xf>
  800aa2:	83 c0 01             	add    $0x1,%eax
  800aa5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	74 04                	je     800ab0 <strfind+0x1a>
  800aac:	38 ca                	cmp    %cl,%dl
  800aae:	75 f2                	jne    800aa2 <strfind+0xc>
			break;
	return (char *) s;
}
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
  800ab8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800abb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800abe:	85 c9                	test   %ecx,%ecx
  800ac0:	74 36                	je     800af8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac8:	75 28                	jne    800af2 <memset+0x40>
  800aca:	f6 c1 03             	test   $0x3,%cl
  800acd:	75 23                	jne    800af2 <memset+0x40>
		c &= 0xFF;
  800acf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad3:	89 d3                	mov    %edx,%ebx
  800ad5:	c1 e3 08             	shl    $0x8,%ebx
  800ad8:	89 d6                	mov    %edx,%esi
  800ada:	c1 e6 18             	shl    $0x18,%esi
  800add:	89 d0                	mov    %edx,%eax
  800adf:	c1 e0 10             	shl    $0x10,%eax
  800ae2:	09 f0                	or     %esi,%eax
  800ae4:	09 c2                	or     %eax,%edx
  800ae6:	89 d0                	mov    %edx,%eax
  800ae8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aea:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aed:	fc                   	cld    
  800aee:	f3 ab                	rep stos %eax,%es:(%edi)
  800af0:	eb 06                	jmp    800af8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af5:	fc                   	cld    
  800af6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af8:	89 f8                	mov    %edi,%eax
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b0d:	39 c6                	cmp    %eax,%esi
  800b0f:	73 35                	jae    800b46 <memmove+0x47>
  800b11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b14:	39 d0                	cmp    %edx,%eax
  800b16:	73 2e                	jae    800b46 <memmove+0x47>
		s += n;
		d += n;
  800b18:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b1b:	89 d6                	mov    %edx,%esi
  800b1d:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b25:	75 13                	jne    800b3a <memmove+0x3b>
  800b27:	f6 c1 03             	test   $0x3,%cl
  800b2a:	75 0e                	jne    800b3a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b2c:	83 ef 04             	sub    $0x4,%edi
  800b2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b32:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b35:	fd                   	std    
  800b36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b38:	eb 09                	jmp    800b43 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b3a:	83 ef 01             	sub    $0x1,%edi
  800b3d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b40:	fd                   	std    
  800b41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b43:	fc                   	cld    
  800b44:	eb 1d                	jmp    800b63 <memmove+0x64>
  800b46:	89 f2                	mov    %esi,%edx
  800b48:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4a:	f6 c2 03             	test   $0x3,%dl
  800b4d:	75 0f                	jne    800b5e <memmove+0x5f>
  800b4f:	f6 c1 03             	test   $0x3,%cl
  800b52:	75 0a                	jne    800b5e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b54:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b57:	89 c7                	mov    %eax,%edi
  800b59:	fc                   	cld    
  800b5a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5c:	eb 05                	jmp    800b63 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b5e:	89 c7                	mov    %eax,%edi
  800b60:	fc                   	cld    
  800b61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b6a:	ff 75 10             	pushl  0x10(%ebp)
  800b6d:	ff 75 0c             	pushl  0xc(%ebp)
  800b70:	ff 75 08             	pushl  0x8(%ebp)
  800b73:	e8 87 ff ff ff       	call   800aff <memmove>
}
  800b78:	c9                   	leave  
  800b79:	c3                   	ret    

00800b7a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b85:	89 c6                	mov    %eax,%esi
  800b87:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8a:	eb 1a                	jmp    800ba6 <memcmp+0x2c>
		if (*s1 != *s2)
  800b8c:	0f b6 08             	movzbl (%eax),%ecx
  800b8f:	0f b6 1a             	movzbl (%edx),%ebx
  800b92:	38 d9                	cmp    %bl,%cl
  800b94:	74 0a                	je     800ba0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b96:	0f b6 c1             	movzbl %cl,%eax
  800b99:	0f b6 db             	movzbl %bl,%ebx
  800b9c:	29 d8                	sub    %ebx,%eax
  800b9e:	eb 0f                	jmp    800baf <memcmp+0x35>
		s1++, s2++;
  800ba0:	83 c0 01             	add    $0x1,%eax
  800ba3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba6:	39 f0                	cmp    %esi,%eax
  800ba8:	75 e2                	jne    800b8c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800baa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bbc:	89 c2                	mov    %eax,%edx
  800bbe:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc1:	eb 07                	jmp    800bca <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc3:	38 08                	cmp    %cl,(%eax)
  800bc5:	74 07                	je     800bce <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc7:	83 c0 01             	add    $0x1,%eax
  800bca:	39 d0                	cmp    %edx,%eax
  800bcc:	72 f5                	jb     800bc3 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bdc:	eb 03                	jmp    800be1 <strtol+0x11>
		s++;
  800bde:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be1:	0f b6 01             	movzbl (%ecx),%eax
  800be4:	3c 09                	cmp    $0x9,%al
  800be6:	74 f6                	je     800bde <strtol+0xe>
  800be8:	3c 20                	cmp    $0x20,%al
  800bea:	74 f2                	je     800bde <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bec:	3c 2b                	cmp    $0x2b,%al
  800bee:	75 0a                	jne    800bfa <strtol+0x2a>
		s++;
  800bf0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf3:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf8:	eb 10                	jmp    800c0a <strtol+0x3a>
  800bfa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bff:	3c 2d                	cmp    $0x2d,%al
  800c01:	75 07                	jne    800c0a <strtol+0x3a>
		s++, neg = 1;
  800c03:	8d 49 01             	lea    0x1(%ecx),%ecx
  800c06:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0a:	85 db                	test   %ebx,%ebx
  800c0c:	0f 94 c0             	sete   %al
  800c0f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c15:	75 19                	jne    800c30 <strtol+0x60>
  800c17:	80 39 30             	cmpb   $0x30,(%ecx)
  800c1a:	75 14                	jne    800c30 <strtol+0x60>
  800c1c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c20:	0f 85 82 00 00 00    	jne    800ca8 <strtol+0xd8>
		s += 2, base = 16;
  800c26:	83 c1 02             	add    $0x2,%ecx
  800c29:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c2e:	eb 16                	jmp    800c46 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c30:	84 c0                	test   %al,%al
  800c32:	74 12                	je     800c46 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c34:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c39:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3c:	75 08                	jne    800c46 <strtol+0x76>
		s++, base = 8;
  800c3e:	83 c1 01             	add    $0x1,%ecx
  800c41:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c46:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c4e:	0f b6 11             	movzbl (%ecx),%edx
  800c51:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c54:	89 f3                	mov    %esi,%ebx
  800c56:	80 fb 09             	cmp    $0x9,%bl
  800c59:	77 08                	ja     800c63 <strtol+0x93>
			dig = *s - '0';
  800c5b:	0f be d2             	movsbl %dl,%edx
  800c5e:	83 ea 30             	sub    $0x30,%edx
  800c61:	eb 22                	jmp    800c85 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c63:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c66:	89 f3                	mov    %esi,%ebx
  800c68:	80 fb 19             	cmp    $0x19,%bl
  800c6b:	77 08                	ja     800c75 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c6d:	0f be d2             	movsbl %dl,%edx
  800c70:	83 ea 57             	sub    $0x57,%edx
  800c73:	eb 10                	jmp    800c85 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c75:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c78:	89 f3                	mov    %esi,%ebx
  800c7a:	80 fb 19             	cmp    $0x19,%bl
  800c7d:	77 16                	ja     800c95 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c7f:	0f be d2             	movsbl %dl,%edx
  800c82:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c85:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c88:	7d 0f                	jge    800c99 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c8a:	83 c1 01             	add    $0x1,%ecx
  800c8d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c91:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c93:	eb b9                	jmp    800c4e <strtol+0x7e>
  800c95:	89 c2                	mov    %eax,%edx
  800c97:	eb 02                	jmp    800c9b <strtol+0xcb>
  800c99:	89 c2                	mov    %eax,%edx

	if (endptr)
  800c9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9f:	74 0d                	je     800cae <strtol+0xde>
		*endptr = (char *) s;
  800ca1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca4:	89 0e                	mov    %ecx,(%esi)
  800ca6:	eb 06                	jmp    800cae <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca8:	84 c0                	test   %al,%al
  800caa:	75 92                	jne    800c3e <strtol+0x6e>
  800cac:	eb 98                	jmp    800c46 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cae:	f7 da                	neg    %edx
  800cb0:	85 ff                	test   %edi,%edi
  800cb2:	0f 45 c2             	cmovne %edx,%eax
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    
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
