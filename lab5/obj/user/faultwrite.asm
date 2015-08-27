
obj/user/faultwrite.debug:     file format elf32-i386


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
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

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
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 89 04 00 00       	call   80051c <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
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
  800107:	68 0a 1e 80 00       	push   $0x801e0a
  80010c:	6a 23                	push   $0x23
  80010e:	68 27 1e 80 00       	push   $0x801e27
  800113:	e8 44 0f 00 00       	call   80105c <_panic>

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
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800188:	68 0a 1e 80 00       	push   $0x801e0a
  80018d:	6a 23                	push   $0x23
  80018f:	68 27 1e 80 00       	push   $0x801e27
  800194:	e8 c3 0e 00 00       	call   80105c <_panic>

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
  8001ca:	68 0a 1e 80 00       	push   $0x801e0a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 27 1e 80 00       	push   $0x801e27
  8001d6:	e8 81 0e 00 00       	call   80105c <_panic>

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
  80020c:	68 0a 1e 80 00       	push   $0x801e0a
  800211:	6a 23                	push   $0x23
  800213:	68 27 1e 80 00       	push   $0x801e27
  800218:	e8 3f 0e 00 00       	call   80105c <_panic>

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
  80024e:	68 0a 1e 80 00       	push   $0x801e0a
  800253:	6a 23                	push   $0x23
  800255:	68 27 1e 80 00       	push   $0x801e27
  80025a:	e8 fd 0d 00 00       	call   80105c <_panic>
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

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 0a 1e 80 00       	push   $0x801e0a
  800295:	6a 23                	push   $0x23
  800297:	68 27 1e 80 00       	push   $0x801e27
  80029c:	e8 bb 0d 00 00       	call   80105c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 0a 1e 80 00       	push   $0x801e0a
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 27 1e 80 00       	push   $0x801e27
  8002de:	e8 79 0d 00 00       	call   80105c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 0a 1e 80 00       	push   $0x801e0a
  80033b:	6a 23                	push   $0x23
  80033d:	68 27 1e 80 00       	push   $0x801e27
  800342:	e8 15 0d 00 00       	call   80105c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	05 00 00 00 30       	add    $0x30000000,%eax
  80035a:	c1 e8 0c             	shr    $0xc,%eax
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80036a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800381:	89 c2                	mov    %eax,%edx
  800383:	c1 ea 16             	shr    $0x16,%edx
  800386:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80038d:	f6 c2 01             	test   $0x1,%dl
  800390:	74 11                	je     8003a3 <fd_alloc+0x2d>
  800392:	89 c2                	mov    %eax,%edx
  800394:	c1 ea 0c             	shr    $0xc,%edx
  800397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039e:	f6 c2 01             	test   $0x1,%dl
  8003a1:	75 09                	jne    8003ac <fd_alloc+0x36>
			*fd_store = fd;
  8003a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003aa:	eb 17                	jmp    8003c3 <fd_alloc+0x4d>
  8003ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b6:	75 c9                	jne    800381 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003cb:	83 f8 1f             	cmp    $0x1f,%eax
  8003ce:	77 36                	ja     800406 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d0:	c1 e0 0c             	shl    $0xc,%eax
  8003d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 ea 16             	shr    $0x16,%edx
  8003dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	74 24                	je     80040d <fd_lookup+0x48>
  8003e9:	89 c2                	mov    %eax,%edx
  8003eb:	c1 ea 0c             	shr    $0xc,%edx
  8003ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f5:	f6 c2 01             	test   $0x1,%dl
  8003f8:	74 1a                	je     800414 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800404:	eb 13                	jmp    800419 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040b:	eb 0c                	jmp    800419 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800412:	eb 05                	jmp    800419 <fd_lookup+0x54>
  800414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800424:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800429:	eb 13                	jmp    80043e <dev_lookup+0x23>
  80042b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042e:	39 08                	cmp    %ecx,(%eax)
  800430:	75 0c                	jne    80043e <dev_lookup+0x23>
			*dev = devtab[i];
  800432:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800435:	89 01                	mov    %eax,(%ecx)
			return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	eb 2e                	jmp    80046c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	75 e7                	jne    80042b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800444:	a1 04 40 80 00       	mov    0x804004,%eax
  800449:	8b 40 48             	mov    0x48(%eax),%eax
  80044c:	83 ec 04             	sub    $0x4,%esp
  80044f:	51                   	push   %ecx
  800450:	50                   	push   %eax
  800451:	68 38 1e 80 00       	push   $0x801e38
  800456:	e8 da 0c 00 00       	call   801135 <cprintf>
	*dev = 0;
  80045b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 10             	sub    $0x10,%esp
  800476:	8b 75 08             	mov    0x8(%ebp),%esi
  800479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047f:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800480:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800486:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800489:	50                   	push   %eax
  80048a:	e8 36 ff ff ff       	call   8003c5 <fd_lookup>
  80048f:	83 c4 08             	add    $0x8,%esp
  800492:	85 c0                	test   %eax,%eax
  800494:	78 05                	js     80049b <fd_close+0x2d>
	    || fd != fd2)
  800496:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800499:	74 0c                	je     8004a7 <fd_close+0x39>
		return (must_exist ? r : 0);
  80049b:	84 db                	test   %bl,%bl
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a2:	0f 44 c2             	cmove  %edx,%eax
  8004a5:	eb 41                	jmp    8004e8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ad:	50                   	push   %eax
  8004ae:	ff 36                	pushl  (%esi)
  8004b0:	e8 66 ff ff ff       	call   80041b <dev_lookup>
  8004b5:	89 c3                	mov    %eax,%ebx
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	78 1a                	js     8004d8 <fd_close+0x6a>
		if (dev->dev_close)
  8004be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	74 0b                	je     8004d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004cd:	83 ec 0c             	sub    $0xc,%esp
  8004d0:	56                   	push   %esi
  8004d1:	ff d0                	call   *%eax
  8004d3:	89 c3                	mov    %eax,%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	56                   	push   %esi
  8004dc:	6a 00                	push   $0x0
  8004de:	e8 00 fd ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	89 d8                	mov    %ebx,%eax
}
  8004e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004eb:	5b                   	pop    %ebx
  8004ec:	5e                   	pop    %esi
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f8:	50                   	push   %eax
  8004f9:	ff 75 08             	pushl  0x8(%ebp)
  8004fc:	e8 c4 fe ff ff       	call   8003c5 <fd_lookup>
  800501:	89 c2                	mov    %eax,%edx
  800503:	83 c4 08             	add    $0x8,%esp
  800506:	85 d2                	test   %edx,%edx
  800508:	78 10                	js     80051a <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	6a 01                	push   $0x1
  80050f:	ff 75 f4             	pushl  -0xc(%ebp)
  800512:	e8 57 ff ff ff       	call   80046e <fd_close>
  800517:	83 c4 10             	add    $0x10,%esp
}
  80051a:	c9                   	leave  
  80051b:	c3                   	ret    

0080051c <close_all>:

void
close_all(void)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	53                   	push   %ebx
  800520:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800523:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800528:	83 ec 0c             	sub    $0xc,%esp
  80052b:	53                   	push   %ebx
  80052c:	e8 be ff ff ff       	call   8004ef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800531:	83 c3 01             	add    $0x1,%ebx
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	83 fb 20             	cmp    $0x20,%ebx
  80053a:	75 ec                	jne    800528 <close_all+0xc>
		close(i);
}
  80053c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053f:	c9                   	leave  
  800540:	c3                   	ret    

00800541 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	57                   	push   %edi
  800545:	56                   	push   %esi
  800546:	53                   	push   %ebx
  800547:	83 ec 2c             	sub    $0x2c,%esp
  80054a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800550:	50                   	push   %eax
  800551:	ff 75 08             	pushl  0x8(%ebp)
  800554:	e8 6c fe ff ff       	call   8003c5 <fd_lookup>
  800559:	89 c2                	mov    %eax,%edx
  80055b:	83 c4 08             	add    $0x8,%esp
  80055e:	85 d2                	test   %edx,%edx
  800560:	0f 88 c1 00 00 00    	js     800627 <dup+0xe6>
		return r;
	close(newfdnum);
  800566:	83 ec 0c             	sub    $0xc,%esp
  800569:	56                   	push   %esi
  80056a:	e8 80 ff ff ff       	call   8004ef <close>

	newfd = INDEX2FD(newfdnum);
  80056f:	89 f3                	mov    %esi,%ebx
  800571:	c1 e3 0c             	shl    $0xc,%ebx
  800574:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057a:	83 c4 04             	add    $0x4,%esp
  80057d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800580:	e8 da fd ff ff       	call   80035f <fd2data>
  800585:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800587:	89 1c 24             	mov    %ebx,(%esp)
  80058a:	e8 d0 fd ff ff       	call   80035f <fd2data>
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800595:	89 f8                	mov    %edi,%eax
  800597:	c1 e8 16             	shr    $0x16,%eax
  80059a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a1:	a8 01                	test   $0x1,%al
  8005a3:	74 37                	je     8005dc <dup+0x9b>
  8005a5:	89 f8                	mov    %edi,%eax
  8005a7:	c1 e8 0c             	shr    $0xc,%eax
  8005aa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b1:	f6 c2 01             	test   $0x1,%dl
  8005b4:	74 26                	je     8005dc <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005bd:	83 ec 0c             	sub    $0xc,%esp
  8005c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c5:	50                   	push   %eax
  8005c6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c9:	6a 00                	push   $0x0
  8005cb:	57                   	push   %edi
  8005cc:	6a 00                	push   $0x0
  8005ce:	e8 ce fb ff ff       	call   8001a1 <sys_page_map>
  8005d3:	89 c7                	mov    %eax,%edi
  8005d5:	83 c4 20             	add    $0x20,%esp
  8005d8:	85 c0                	test   %eax,%eax
  8005da:	78 2e                	js     80060a <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005df:	89 d0                	mov    %edx,%eax
  8005e1:	c1 e8 0c             	shr    $0xc,%eax
  8005e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005eb:	83 ec 0c             	sub    $0xc,%esp
  8005ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f3:	50                   	push   %eax
  8005f4:	53                   	push   %ebx
  8005f5:	6a 00                	push   $0x0
  8005f7:	52                   	push   %edx
  8005f8:	6a 00                	push   $0x0
  8005fa:	e8 a2 fb ff ff       	call   8001a1 <sys_page_map>
  8005ff:	89 c7                	mov    %eax,%edi
  800601:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800604:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800606:	85 ff                	test   %edi,%edi
  800608:	79 1d                	jns    800627 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 00                	push   $0x0
  800610:	e8 ce fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800615:	83 c4 08             	add    $0x8,%esp
  800618:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061b:	6a 00                	push   $0x0
  80061d:	e8 c1 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800622:	83 c4 10             	add    $0x10,%esp
  800625:	89 f8                	mov    %edi,%eax
}
  800627:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062a:	5b                   	pop    %ebx
  80062b:	5e                   	pop    %esi
  80062c:	5f                   	pop    %edi
  80062d:	5d                   	pop    %ebp
  80062e:	c3                   	ret    

0080062f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	53                   	push   %ebx
  800633:	83 ec 14             	sub    $0x14,%esp
  800636:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800639:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063c:	50                   	push   %eax
  80063d:	53                   	push   %ebx
  80063e:	e8 82 fd ff ff       	call   8003c5 <fd_lookup>
  800643:	83 c4 08             	add    $0x8,%esp
  800646:	89 c2                	mov    %eax,%edx
  800648:	85 c0                	test   %eax,%eax
  80064a:	78 6d                	js     8006b9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800652:	50                   	push   %eax
  800653:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800656:	ff 30                	pushl  (%eax)
  800658:	e8 be fd ff ff       	call   80041b <dev_lookup>
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	85 c0                	test   %eax,%eax
  800662:	78 4c                	js     8006b0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800664:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800667:	8b 42 08             	mov    0x8(%edx),%eax
  80066a:	83 e0 03             	and    $0x3,%eax
  80066d:	83 f8 01             	cmp    $0x1,%eax
  800670:	75 21                	jne    800693 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800672:	a1 04 40 80 00       	mov    0x804004,%eax
  800677:	8b 40 48             	mov    0x48(%eax),%eax
  80067a:	83 ec 04             	sub    $0x4,%esp
  80067d:	53                   	push   %ebx
  80067e:	50                   	push   %eax
  80067f:	68 79 1e 80 00       	push   $0x801e79
  800684:	e8 ac 0a 00 00       	call   801135 <cprintf>
		return -E_INVAL;
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800691:	eb 26                	jmp    8006b9 <read+0x8a>
	}
	if (!dev->dev_read)
  800693:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800696:	8b 40 08             	mov    0x8(%eax),%eax
  800699:	85 c0                	test   %eax,%eax
  80069b:	74 17                	je     8006b4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80069d:	83 ec 04             	sub    $0x4,%esp
  8006a0:	ff 75 10             	pushl  0x10(%ebp)
  8006a3:	ff 75 0c             	pushl  0xc(%ebp)
  8006a6:	52                   	push   %edx
  8006a7:	ff d0                	call   *%eax
  8006a9:	89 c2                	mov    %eax,%edx
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	eb 09                	jmp    8006b9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b0:	89 c2                	mov    %eax,%edx
  8006b2:	eb 05                	jmp    8006b9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b9:	89 d0                	mov    %edx,%eax
  8006bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006be:	c9                   	leave  
  8006bf:	c3                   	ret    

008006c0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	57                   	push   %edi
  8006c4:	56                   	push   %esi
  8006c5:	53                   	push   %ebx
  8006c6:	83 ec 0c             	sub    $0xc,%esp
  8006c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d4:	eb 21                	jmp    8006f7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d6:	83 ec 04             	sub    $0x4,%esp
  8006d9:	89 f0                	mov    %esi,%eax
  8006db:	29 d8                	sub    %ebx,%eax
  8006dd:	50                   	push   %eax
  8006de:	89 d8                	mov    %ebx,%eax
  8006e0:	03 45 0c             	add    0xc(%ebp),%eax
  8006e3:	50                   	push   %eax
  8006e4:	57                   	push   %edi
  8006e5:	e8 45 ff ff ff       	call   80062f <read>
		if (m < 0)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	78 0c                	js     8006fd <readn+0x3d>
			return m;
		if (m == 0)
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	74 06                	je     8006fb <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f5:	01 c3                	add    %eax,%ebx
  8006f7:	39 f3                	cmp    %esi,%ebx
  8006f9:	72 db                	jb     8006d6 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8006fb:	89 d8                	mov    %ebx,%eax
}
  8006fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800700:	5b                   	pop    %ebx
  800701:	5e                   	pop    %esi
  800702:	5f                   	pop    %edi
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	53                   	push   %ebx
  800709:	83 ec 14             	sub    $0x14,%esp
  80070c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	53                   	push   %ebx
  800714:	e8 ac fc ff ff       	call   8003c5 <fd_lookup>
  800719:	83 c4 08             	add    $0x8,%esp
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	85 c0                	test   %eax,%eax
  800720:	78 68                	js     80078a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072c:	ff 30                	pushl  (%eax)
  80072e:	e8 e8 fc ff ff       	call   80041b <dev_lookup>
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	85 c0                	test   %eax,%eax
  800738:	78 47                	js     800781 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800741:	75 21                	jne    800764 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800743:	a1 04 40 80 00       	mov    0x804004,%eax
  800748:	8b 40 48             	mov    0x48(%eax),%eax
  80074b:	83 ec 04             	sub    $0x4,%esp
  80074e:	53                   	push   %ebx
  80074f:	50                   	push   %eax
  800750:	68 95 1e 80 00       	push   $0x801e95
  800755:	e8 db 09 00 00       	call   801135 <cprintf>
		return -E_INVAL;
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800762:	eb 26                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800764:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800767:	8b 52 0c             	mov    0xc(%edx),%edx
  80076a:	85 d2                	test   %edx,%edx
  80076c:	74 17                	je     800785 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	50                   	push   %eax
  800778:	ff d2                	call   *%edx
  80077a:	89 c2                	mov    %eax,%edx
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb 09                	jmp    80078a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800781:	89 c2                	mov    %eax,%edx
  800783:	eb 05                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800785:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078a:	89 d0                	mov    %edx,%eax
  80078c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <seek>:

int
seek(int fdnum, off_t offset)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800797:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079a:	50                   	push   %eax
  80079b:	ff 75 08             	pushl  0x8(%ebp)
  80079e:	e8 22 fc ff ff       	call   8003c5 <fd_lookup>
  8007a3:	83 c4 08             	add    $0x8,%esp
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 0e                	js     8007b8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	83 ec 14             	sub    $0x14,%esp
  8007c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	53                   	push   %ebx
  8007c9:	e8 f7 fb ff ff       	call   8003c5 <fd_lookup>
  8007ce:	83 c4 08             	add    $0x8,%esp
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	78 65                	js     80083c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d7:	83 ec 08             	sub    $0x8,%esp
  8007da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e1:	ff 30                	pushl  (%eax)
  8007e3:	e8 33 fc ff ff       	call   80041b <dev_lookup>
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	78 44                	js     800833 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f6:	75 21                	jne    800819 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007fd:	8b 40 48             	mov    0x48(%eax),%eax
  800800:	83 ec 04             	sub    $0x4,%esp
  800803:	53                   	push   %ebx
  800804:	50                   	push   %eax
  800805:	68 58 1e 80 00       	push   $0x801e58
  80080a:	e8 26 09 00 00       	call   801135 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800817:	eb 23                	jmp    80083c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800819:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80081c:	8b 52 18             	mov    0x18(%edx),%edx
  80081f:	85 d2                	test   %edx,%edx
  800821:	74 14                	je     800837 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	ff 75 0c             	pushl  0xc(%ebp)
  800829:	50                   	push   %eax
  80082a:	ff d2                	call   *%edx
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb 09                	jmp    80083c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800833:	89 c2                	mov    %eax,%edx
  800835:	eb 05                	jmp    80083c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800837:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80083c:	89 d0                	mov    %edx,%eax
  80083e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	83 ec 14             	sub    $0x14,%esp
  80084a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800850:	50                   	push   %eax
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 6c fb ff ff       	call   8003c5 <fd_lookup>
  800859:	83 c4 08             	add    $0x8,%esp
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	85 c0                	test   %eax,%eax
  800860:	78 58                	js     8008ba <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800868:	50                   	push   %eax
  800869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086c:	ff 30                	pushl  (%eax)
  80086e:	e8 a8 fb ff ff       	call   80041b <dev_lookup>
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	85 c0                	test   %eax,%eax
  800878:	78 37                	js     8008b1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800881:	74 32                	je     8008b5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800883:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800886:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088d:	00 00 00 
	stat->st_isdir = 0;
  800890:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800897:	00 00 00 
	stat->st_dev = dev;
  80089a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a7:	ff 50 14             	call   *0x14(%eax)
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	eb 09                	jmp    8008ba <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	eb 05                	jmp    8008ba <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008ba:	89 d0                	mov    %edx,%eax
  8008bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	6a 00                	push   $0x0
  8008cb:	ff 75 08             	pushl  0x8(%ebp)
  8008ce:	e8 09 02 00 00       	call   800adc <open>
  8008d3:	89 c3                	mov    %eax,%ebx
  8008d5:	83 c4 10             	add    $0x10,%esp
  8008d8:	85 db                	test   %ebx,%ebx
  8008da:	78 1b                	js     8008f7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	ff 75 0c             	pushl  0xc(%ebp)
  8008e2:	53                   	push   %ebx
  8008e3:	e8 5b ff ff ff       	call   800843 <fstat>
  8008e8:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ea:	89 1c 24             	mov    %ebx,(%esp)
  8008ed:	e8 fd fb ff ff       	call   8004ef <close>
	return r;
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	89 f0                	mov    %esi,%eax
}
  8008f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	89 c6                	mov    %eax,%esi
  800905:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800907:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090e:	75 12                	jne    800922 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800910:	83 ec 0c             	sub    $0xc,%esp
  800913:	6a 01                	push   $0x1
  800915:	e8 ac 11 00 00       	call   801ac6 <ipc_find_env>
  80091a:	a3 00 40 80 00       	mov    %eax,0x804000
  80091f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800922:	6a 07                	push   $0x7
  800924:	68 00 50 80 00       	push   $0x805000
  800929:	56                   	push   %esi
  80092a:	ff 35 00 40 80 00    	pushl  0x804000
  800930:	e8 3d 11 00 00       	call   801a72 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800935:	83 c4 0c             	add    $0xc,%esp
  800938:	6a 00                	push   $0x0
  80093a:	53                   	push   %ebx
  80093b:	6a 00                	push   $0x0
  80093d:	e8 c7 10 00 00       	call   801a09 <ipc_recv>
}
  800942:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 40 0c             	mov    0xc(%eax),%eax
  800955:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	b8 02 00 00 00       	mov    $0x2,%eax
  80096c:	e8 8d ff ff ff       	call   8008fe <fsipc>
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 40 0c             	mov    0xc(%eax),%eax
  80097f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800984:	ba 00 00 00 00       	mov    $0x0,%edx
  800989:	b8 06 00 00 00       	mov    $0x6,%eax
  80098e:	e8 6b ff ff ff       	call   8008fe <fsipc>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	53                   	push   %ebx
  800999:	83 ec 04             	sub    $0x4,%esp
  80099c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009af:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b4:	e8 45 ff ff ff       	call   8008fe <fsipc>
  8009b9:	89 c2                	mov    %eax,%edx
  8009bb:	85 d2                	test   %edx,%edx
  8009bd:	78 2c                	js     8009eb <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009bf:	83 ec 08             	sub    $0x8,%esp
  8009c2:	68 00 50 80 00       	push   $0x805000
  8009c7:	53                   	push   %ebx
  8009c8:	e8 ef 0c 00 00       	call   8016bc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009cd:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d8:	a1 84 50 80 00       	mov    0x805084,%eax
  8009dd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e3:	83 c4 10             	add    $0x10,%esp
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	57                   	push   %edi
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	83 ec 0c             	sub    $0xc,%esp
  8009f9:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 40 0c             	mov    0xc(%eax),%eax
  800a02:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800a07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a0a:	eb 3d                	jmp    800a49 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800a0c:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800a12:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800a17:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800a1a:	83 ec 04             	sub    $0x4,%esp
  800a1d:	57                   	push   %edi
  800a1e:	53                   	push   %ebx
  800a1f:	68 08 50 80 00       	push   $0x805008
  800a24:	e8 25 0e 00 00       	call   80184e <memmove>
                fsipcbuf.write.req_n = tmp; 
  800a29:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a34:	b8 04 00 00 00       	mov    $0x4,%eax
  800a39:	e8 c0 fe ff ff       	call   8008fe <fsipc>
  800a3e:	83 c4 10             	add    $0x10,%esp
  800a41:	85 c0                	test   %eax,%eax
  800a43:	78 0d                	js     800a52 <devfile_write+0x62>
		        return r;
                n -= tmp;
  800a45:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800a47:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a49:	85 f6                	test   %esi,%esi
  800a4b:	75 bf                	jne    800a0c <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800a4d:	89 d8                	mov    %ebx,%eax
  800a4f:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800a52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	8b 40 0c             	mov    0xc(%eax),%eax
  800a68:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a6d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a73:	ba 00 00 00 00       	mov    $0x0,%edx
  800a78:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7d:	e8 7c fe ff ff       	call   8008fe <fsipc>
  800a82:	89 c3                	mov    %eax,%ebx
  800a84:	85 c0                	test   %eax,%eax
  800a86:	78 4b                	js     800ad3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a88:	39 c6                	cmp    %eax,%esi
  800a8a:	73 16                	jae    800aa2 <devfile_read+0x48>
  800a8c:	68 c4 1e 80 00       	push   $0x801ec4
  800a91:	68 cb 1e 80 00       	push   $0x801ecb
  800a96:	6a 7c                	push   $0x7c
  800a98:	68 e0 1e 80 00       	push   $0x801ee0
  800a9d:	e8 ba 05 00 00       	call   80105c <_panic>
	assert(r <= PGSIZE);
  800aa2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa7:	7e 16                	jle    800abf <devfile_read+0x65>
  800aa9:	68 eb 1e 80 00       	push   $0x801eeb
  800aae:	68 cb 1e 80 00       	push   $0x801ecb
  800ab3:	6a 7d                	push   $0x7d
  800ab5:	68 e0 1e 80 00       	push   $0x801ee0
  800aba:	e8 9d 05 00 00       	call   80105c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800abf:	83 ec 04             	sub    $0x4,%esp
  800ac2:	50                   	push   %eax
  800ac3:	68 00 50 80 00       	push   $0x805000
  800ac8:	ff 75 0c             	pushl  0xc(%ebp)
  800acb:	e8 7e 0d 00 00       	call   80184e <memmove>
	return r;
  800ad0:	83 c4 10             	add    $0x10,%esp
}
  800ad3:	89 d8                	mov    %ebx,%eax
  800ad5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	53                   	push   %ebx
  800ae0:	83 ec 20             	sub    $0x20,%esp
  800ae3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae6:	53                   	push   %ebx
  800ae7:	e8 97 0b 00 00       	call   801683 <strlen>
  800aec:	83 c4 10             	add    $0x10,%esp
  800aef:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af4:	7f 67                	jg     800b5d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af6:	83 ec 0c             	sub    $0xc,%esp
  800af9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800afc:	50                   	push   %eax
  800afd:	e8 74 f8 ff ff       	call   800376 <fd_alloc>
  800b02:	83 c4 10             	add    $0x10,%esp
		return r;
  800b05:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b07:	85 c0                	test   %eax,%eax
  800b09:	78 57                	js     800b62 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b0b:	83 ec 08             	sub    $0x8,%esp
  800b0e:	53                   	push   %ebx
  800b0f:	68 00 50 80 00       	push   $0x805000
  800b14:	e8 a3 0b 00 00       	call   8016bc <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b21:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b24:	b8 01 00 00 00       	mov    $0x1,%eax
  800b29:	e8 d0 fd ff ff       	call   8008fe <fsipc>
  800b2e:	89 c3                	mov    %eax,%ebx
  800b30:	83 c4 10             	add    $0x10,%esp
  800b33:	85 c0                	test   %eax,%eax
  800b35:	79 14                	jns    800b4b <open+0x6f>
		fd_close(fd, 0);
  800b37:	83 ec 08             	sub    $0x8,%esp
  800b3a:	6a 00                	push   $0x0
  800b3c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3f:	e8 2a f9 ff ff       	call   80046e <fd_close>
		return r;
  800b44:	83 c4 10             	add    $0x10,%esp
  800b47:	89 da                	mov    %ebx,%edx
  800b49:	eb 17                	jmp    800b62 <open+0x86>
	}

	return fd2num(fd);
  800b4b:	83 ec 0c             	sub    $0xc,%esp
  800b4e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b51:	e8 f9 f7 ff ff       	call   80034f <fd2num>
  800b56:	89 c2                	mov    %eax,%edx
  800b58:	83 c4 10             	add    $0x10,%esp
  800b5b:	eb 05                	jmp    800b62 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b5d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b62:	89 d0                	mov    %edx,%eax
  800b64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b67:	c9                   	leave  
  800b68:	c3                   	ret    

00800b69 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	b8 08 00 00 00       	mov    $0x8,%eax
  800b79:	e8 80 fd ff ff       	call   8008fe <fsipc>
}
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	ff 75 08             	pushl  0x8(%ebp)
  800b8e:	e8 cc f7 ff ff       	call   80035f <fd2data>
  800b93:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b95:	83 c4 08             	add    $0x8,%esp
  800b98:	68 f7 1e 80 00       	push   $0x801ef7
  800b9d:	53                   	push   %ebx
  800b9e:	e8 19 0b 00 00       	call   8016bc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba3:	8b 56 04             	mov    0x4(%esi),%edx
  800ba6:	89 d0                	mov    %edx,%eax
  800ba8:	2b 06                	sub    (%esi),%eax
  800baa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb7:	00 00 00 
	stat->st_dev = &devpipe;
  800bba:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bc1:	30 80 00 
	return 0;
}
  800bc4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
  800bd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bda:	53                   	push   %ebx
  800bdb:	6a 00                	push   $0x0
  800bdd:	e8 01 f6 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800be2:	89 1c 24             	mov    %ebx,(%esp)
  800be5:	e8 75 f7 ff ff       	call   80035f <fd2data>
  800bea:	83 c4 08             	add    $0x8,%esp
  800bed:	50                   	push   %eax
  800bee:	6a 00                	push   $0x0
  800bf0:	e8 ee f5 ff ff       	call   8001e3 <sys_page_unmap>
}
  800bf5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf8:	c9                   	leave  
  800bf9:	c3                   	ret    

00800bfa <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	83 ec 1c             	sub    $0x1c,%esp
  800c03:	89 c6                	mov    %eax,%esi
  800c05:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c08:	a1 04 40 80 00       	mov    0x804004,%eax
  800c0d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c10:	83 ec 0c             	sub    $0xc,%esp
  800c13:	56                   	push   %esi
  800c14:	e8 e5 0e 00 00       	call   801afe <pageref>
  800c19:	89 c7                	mov    %eax,%edi
  800c1b:	83 c4 04             	add    $0x4,%esp
  800c1e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c21:	e8 d8 0e 00 00       	call   801afe <pageref>
  800c26:	83 c4 10             	add    $0x10,%esp
  800c29:	39 c7                	cmp    %eax,%edi
  800c2b:	0f 94 c2             	sete   %dl
  800c2e:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800c31:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800c37:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800c3a:	39 fb                	cmp    %edi,%ebx
  800c3c:	74 19                	je     800c57 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  800c3e:	84 d2                	test   %dl,%dl
  800c40:	74 c6                	je     800c08 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c42:	8b 51 58             	mov    0x58(%ecx),%edx
  800c45:	50                   	push   %eax
  800c46:	52                   	push   %edx
  800c47:	53                   	push   %ebx
  800c48:	68 fe 1e 80 00       	push   $0x801efe
  800c4d:	e8 e3 04 00 00       	call   801135 <cprintf>
  800c52:	83 c4 10             	add    $0x10,%esp
  800c55:	eb b1                	jmp    800c08 <_pipeisclosed+0xe>
	}
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	83 ec 28             	sub    $0x28,%esp
  800c68:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c6b:	56                   	push   %esi
  800c6c:	e8 ee f6 ff ff       	call   80035f <fd2data>
  800c71:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7b:	eb 4b                	jmp    800cc8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c7d:	89 da                	mov    %ebx,%edx
  800c7f:	89 f0                	mov    %esi,%eax
  800c81:	e8 74 ff ff ff       	call   800bfa <_pipeisclosed>
  800c86:	85 c0                	test   %eax,%eax
  800c88:	75 48                	jne    800cd2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c8a:	e8 b0 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c8f:	8b 43 04             	mov    0x4(%ebx),%eax
  800c92:	8b 0b                	mov    (%ebx),%ecx
  800c94:	8d 51 20             	lea    0x20(%ecx),%edx
  800c97:	39 d0                	cmp    %edx,%eax
  800c99:	73 e2                	jae    800c7d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca5:	89 c2                	mov    %eax,%edx
  800ca7:	c1 fa 1f             	sar    $0x1f,%edx
  800caa:	89 d1                	mov    %edx,%ecx
  800cac:	c1 e9 1b             	shr    $0x1b,%ecx
  800caf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb2:	83 e2 1f             	and    $0x1f,%edx
  800cb5:	29 ca                	sub    %ecx,%edx
  800cb7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cbb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cbf:	83 c0 01             	add    $0x1,%eax
  800cc2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc5:	83 c7 01             	add    $0x1,%edi
  800cc8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ccb:	75 c2                	jne    800c8f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ccd:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd0:	eb 05                	jmp    800cd7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 18             	sub    $0x18,%esp
  800ce8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ceb:	57                   	push   %edi
  800cec:	e8 6e f6 ff ff       	call   80035f <fd2data>
  800cf1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf3:	83 c4 10             	add    $0x10,%esp
  800cf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfb:	eb 3d                	jmp    800d3a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cfd:	85 db                	test   %ebx,%ebx
  800cff:	74 04                	je     800d05 <devpipe_read+0x26>
				return i;
  800d01:	89 d8                	mov    %ebx,%eax
  800d03:	eb 44                	jmp    800d49 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d05:	89 f2                	mov    %esi,%edx
  800d07:	89 f8                	mov    %edi,%eax
  800d09:	e8 ec fe ff ff       	call   800bfa <_pipeisclosed>
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	75 32                	jne    800d44 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d12:	e8 28 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d17:	8b 06                	mov    (%esi),%eax
  800d19:	3b 46 04             	cmp    0x4(%esi),%eax
  800d1c:	74 df                	je     800cfd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d1e:	99                   	cltd   
  800d1f:	c1 ea 1b             	shr    $0x1b,%edx
  800d22:	01 d0                	add    %edx,%eax
  800d24:	83 e0 1f             	and    $0x1f,%eax
  800d27:	29 d0                	sub    %edx,%eax
  800d29:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d34:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d37:	83 c3 01             	add    $0x1,%ebx
  800d3a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d3d:	75 d8                	jne    800d17 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d3f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d42:	eb 05                	jmp    800d49 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d44:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5c:	50                   	push   %eax
  800d5d:	e8 14 f6 ff ff       	call   800376 <fd_alloc>
  800d62:	83 c4 10             	add    $0x10,%esp
  800d65:	89 c2                	mov    %eax,%edx
  800d67:	85 c0                	test   %eax,%eax
  800d69:	0f 88 2c 01 00 00    	js     800e9b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d6f:	83 ec 04             	sub    $0x4,%esp
  800d72:	68 07 04 00 00       	push   $0x407
  800d77:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7a:	6a 00                	push   $0x0
  800d7c:	e8 dd f3 ff ff       	call   80015e <sys_page_alloc>
  800d81:	83 c4 10             	add    $0x10,%esp
  800d84:	89 c2                	mov    %eax,%edx
  800d86:	85 c0                	test   %eax,%eax
  800d88:	0f 88 0d 01 00 00    	js     800e9b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d94:	50                   	push   %eax
  800d95:	e8 dc f5 ff ff       	call   800376 <fd_alloc>
  800d9a:	89 c3                	mov    %eax,%ebx
  800d9c:	83 c4 10             	add    $0x10,%esp
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	0f 88 e2 00 00 00    	js     800e89 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da7:	83 ec 04             	sub    $0x4,%esp
  800daa:	68 07 04 00 00       	push   $0x407
  800daf:	ff 75 f0             	pushl  -0x10(%ebp)
  800db2:	6a 00                	push   $0x0
  800db4:	e8 a5 f3 ff ff       	call   80015e <sys_page_alloc>
  800db9:	89 c3                	mov    %eax,%ebx
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	0f 88 c3 00 00 00    	js     800e89 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	ff 75 f4             	pushl  -0xc(%ebp)
  800dcc:	e8 8e f5 ff ff       	call   80035f <fd2data>
  800dd1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd3:	83 c4 0c             	add    $0xc,%esp
  800dd6:	68 07 04 00 00       	push   $0x407
  800ddb:	50                   	push   %eax
  800ddc:	6a 00                	push   $0x0
  800dde:	e8 7b f3 ff ff       	call   80015e <sys_page_alloc>
  800de3:	89 c3                	mov    %eax,%ebx
  800de5:	83 c4 10             	add    $0x10,%esp
  800de8:	85 c0                	test   %eax,%eax
  800dea:	0f 88 89 00 00 00    	js     800e79 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df0:	83 ec 0c             	sub    $0xc,%esp
  800df3:	ff 75 f0             	pushl  -0x10(%ebp)
  800df6:	e8 64 f5 ff ff       	call   80035f <fd2data>
  800dfb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e02:	50                   	push   %eax
  800e03:	6a 00                	push   $0x0
  800e05:	56                   	push   %esi
  800e06:	6a 00                	push   $0x0
  800e08:	e8 94 f3 ff ff       	call   8001a1 <sys_page_map>
  800e0d:	89 c3                	mov    %eax,%ebx
  800e0f:	83 c4 20             	add    $0x20,%esp
  800e12:	85 c0                	test   %eax,%eax
  800e14:	78 55                	js     800e6b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e16:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e24:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e2b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e34:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e39:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e40:	83 ec 0c             	sub    $0xc,%esp
  800e43:	ff 75 f4             	pushl  -0xc(%ebp)
  800e46:	e8 04 f5 ff ff       	call   80034f <fd2num>
  800e4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e50:	83 c4 04             	add    $0x4,%esp
  800e53:	ff 75 f0             	pushl  -0x10(%ebp)
  800e56:	e8 f4 f4 ff ff       	call   80034f <fd2num>
  800e5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	ba 00 00 00 00       	mov    $0x0,%edx
  800e69:	eb 30                	jmp    800e9b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e6b:	83 ec 08             	sub    $0x8,%esp
  800e6e:	56                   	push   %esi
  800e6f:	6a 00                	push   $0x0
  800e71:	e8 6d f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e76:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e79:	83 ec 08             	sub    $0x8,%esp
  800e7c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7f:	6a 00                	push   $0x0
  800e81:	e8 5d f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e86:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e89:	83 ec 08             	sub    $0x8,%esp
  800e8c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8f:	6a 00                	push   $0x0
  800e91:	e8 4d f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e96:	83 c4 10             	add    $0x10,%esp
  800e99:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e9b:	89 d0                	mov    %edx,%eax
  800e9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eaa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ead:	50                   	push   %eax
  800eae:	ff 75 08             	pushl  0x8(%ebp)
  800eb1:	e8 0f f5 ff ff       	call   8003c5 <fd_lookup>
  800eb6:	89 c2                	mov    %eax,%edx
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	85 d2                	test   %edx,%edx
  800ebd:	78 18                	js     800ed7 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec5:	e8 95 f4 ff ff       	call   80035f <fd2data>
	return _pipeisclosed(fd, p);
  800eca:	89 c2                	mov    %eax,%edx
  800ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ecf:	e8 26 fd ff ff       	call   800bfa <_pipeisclosed>
  800ed4:	83 c4 10             	add    $0x10,%esp
}
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    

00800ed9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee9:	68 16 1f 80 00       	push   $0x801f16
  800eee:	ff 75 0c             	pushl  0xc(%ebp)
  800ef1:	e8 c6 07 00 00       	call   8016bc <strcpy>
	return 0;
}
  800ef6:	b8 00 00 00 00       	mov    $0x0,%eax
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    

00800efd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	53                   	push   %ebx
  800f03:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f09:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f14:	eb 2d                	jmp    800f43 <devcons_write+0x46>
		m = n - tot;
  800f16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f19:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f1b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f1e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f23:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f26:	83 ec 04             	sub    $0x4,%esp
  800f29:	53                   	push   %ebx
  800f2a:	03 45 0c             	add    0xc(%ebp),%eax
  800f2d:	50                   	push   %eax
  800f2e:	57                   	push   %edi
  800f2f:	e8 1a 09 00 00       	call   80184e <memmove>
		sys_cputs(buf, m);
  800f34:	83 c4 08             	add    $0x8,%esp
  800f37:	53                   	push   %ebx
  800f38:	57                   	push   %edi
  800f39:	e8 64 f1 ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3e:	01 de                	add    %ebx,%esi
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	89 f0                	mov    %esi,%eax
  800f45:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f48:	72 cc                	jb     800f16 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f58:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f61:	75 07                	jne    800f6a <devcons_read+0x18>
  800f63:	eb 28                	jmp    800f8d <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f65:	e8 d5 f1 ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f6a:	e8 51 f1 ff ff       	call   8000c0 <sys_cgetc>
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	74 f2                	je     800f65 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f73:	85 c0                	test   %eax,%eax
  800f75:	78 16                	js     800f8d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f77:	83 f8 04             	cmp    $0x4,%eax
  800f7a:	74 0c                	je     800f88 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7f:	88 02                	mov    %al,(%edx)
	return 1;
  800f81:	b8 01 00 00 00       	mov    $0x1,%eax
  800f86:	eb 05                	jmp    800f8d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f88:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    

00800f8f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f95:	8b 45 08             	mov    0x8(%ebp),%eax
  800f98:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f9b:	6a 01                	push   $0x1
  800f9d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa0:	50                   	push   %eax
  800fa1:	e8 fc f0 ff ff       	call   8000a2 <sys_cputs>
  800fa6:	83 c4 10             	add    $0x10,%esp
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <getchar>:

int
getchar(void)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fb1:	6a 01                	push   $0x1
  800fb3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb6:	50                   	push   %eax
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 71 f6 ff ff       	call   80062f <read>
	if (r < 0)
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 0f                	js     800fd4 <getchar+0x29>
		return r;
	if (r < 1)
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	7e 06                	jle    800fcf <getchar+0x24>
		return -E_EOF;
	return c;
  800fc9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fcd:	eb 05                	jmp    800fd4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fcf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	ff 75 08             	pushl  0x8(%ebp)
  800fe3:	e8 dd f3 ff ff       	call   8003c5 <fd_lookup>
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 11                	js     801000 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff8:	39 10                	cmp    %edx,(%eax)
  800ffa:	0f 94 c0             	sete   %al
  800ffd:	0f b6 c0             	movzbl %al,%eax
}
  801000:	c9                   	leave  
  801001:	c3                   	ret    

00801002 <opencons>:

int
opencons(void)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801008:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100b:	50                   	push   %eax
  80100c:	e8 65 f3 ff ff       	call   800376 <fd_alloc>
  801011:	83 c4 10             	add    $0x10,%esp
		return r;
  801014:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801016:	85 c0                	test   %eax,%eax
  801018:	78 3e                	js     801058 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80101a:	83 ec 04             	sub    $0x4,%esp
  80101d:	68 07 04 00 00       	push   $0x407
  801022:	ff 75 f4             	pushl  -0xc(%ebp)
  801025:	6a 00                	push   $0x0
  801027:	e8 32 f1 ff ff       	call   80015e <sys_page_alloc>
  80102c:	83 c4 10             	add    $0x10,%esp
		return r;
  80102f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801031:	85 c0                	test   %eax,%eax
  801033:	78 23                	js     801058 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801035:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80103b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801040:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801043:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	50                   	push   %eax
  80104e:	e8 fc f2 ff ff       	call   80034f <fd2num>
  801053:	89 c2                	mov    %eax,%edx
  801055:	83 c4 10             	add    $0x10,%esp
}
  801058:	89 d0                	mov    %edx,%eax
  80105a:	c9                   	leave  
  80105b:	c3                   	ret    

0080105c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801061:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801064:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80106a:	e8 b1 f0 ff ff       	call   800120 <sys_getenvid>
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	ff 75 0c             	pushl  0xc(%ebp)
  801075:	ff 75 08             	pushl  0x8(%ebp)
  801078:	56                   	push   %esi
  801079:	50                   	push   %eax
  80107a:	68 24 1f 80 00       	push   $0x801f24
  80107f:	e8 b1 00 00 00       	call   801135 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801084:	83 c4 18             	add    $0x18,%esp
  801087:	53                   	push   %ebx
  801088:	ff 75 10             	pushl  0x10(%ebp)
  80108b:	e8 54 00 00 00       	call   8010e4 <vcprintf>
	cprintf("\n");
  801090:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  801097:	e8 99 00 00 00       	call   801135 <cprintf>
  80109c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80109f:	cc                   	int3   
  8010a0:	eb fd                	jmp    80109f <_panic+0x43>

008010a2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 04             	sub    $0x4,%esp
  8010a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010ac:	8b 13                	mov    (%ebx),%edx
  8010ae:	8d 42 01             	lea    0x1(%edx),%eax
  8010b1:	89 03                	mov    %eax,(%ebx)
  8010b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010bf:	75 1a                	jne    8010db <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010c1:	83 ec 08             	sub    $0x8,%esp
  8010c4:	68 ff 00 00 00       	push   $0xff
  8010c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8010cc:	50                   	push   %eax
  8010cd:	e8 d0 ef ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8010d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010d8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010db:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010ed:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010f4:	00 00 00 
	b.cnt = 0;
  8010f7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010fe:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801101:	ff 75 0c             	pushl  0xc(%ebp)
  801104:	ff 75 08             	pushl  0x8(%ebp)
  801107:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80110d:	50                   	push   %eax
  80110e:	68 a2 10 80 00       	push   $0x8010a2
  801113:	e8 4f 01 00 00       	call   801267 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801118:	83 c4 08             	add    $0x8,%esp
  80111b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801121:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801127:	50                   	push   %eax
  801128:	e8 75 ef ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  80112d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80113b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80113e:	50                   	push   %eax
  80113f:	ff 75 08             	pushl  0x8(%ebp)
  801142:	e8 9d ff ff ff       	call   8010e4 <vcprintf>
	va_end(ap);

	return cnt;
}
  801147:	c9                   	leave  
  801148:	c3                   	ret    

00801149 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	57                   	push   %edi
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
  80114f:	83 ec 1c             	sub    $0x1c,%esp
  801152:	89 c7                	mov    %eax,%edi
  801154:	89 d6                	mov    %edx,%esi
  801156:	8b 45 08             	mov    0x8(%ebp),%eax
  801159:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115c:	89 d1                	mov    %edx,%ecx
  80115e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801161:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801164:	8b 45 10             	mov    0x10(%ebp),%eax
  801167:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80116a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80116d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801174:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801177:	72 05                	jb     80117e <printnum+0x35>
  801179:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80117c:	77 3e                	ja     8011bc <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80117e:	83 ec 0c             	sub    $0xc,%esp
  801181:	ff 75 18             	pushl  0x18(%ebp)
  801184:	83 eb 01             	sub    $0x1,%ebx
  801187:	53                   	push   %ebx
  801188:	50                   	push   %eax
  801189:	83 ec 08             	sub    $0x8,%esp
  80118c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118f:	ff 75 e0             	pushl  -0x20(%ebp)
  801192:	ff 75 dc             	pushl  -0x24(%ebp)
  801195:	ff 75 d8             	pushl  -0x28(%ebp)
  801198:	e8 a3 09 00 00       	call   801b40 <__udivdi3>
  80119d:	83 c4 18             	add    $0x18,%esp
  8011a0:	52                   	push   %edx
  8011a1:	50                   	push   %eax
  8011a2:	89 f2                	mov    %esi,%edx
  8011a4:	89 f8                	mov    %edi,%eax
  8011a6:	e8 9e ff ff ff       	call   801149 <printnum>
  8011ab:	83 c4 20             	add    $0x20,%esp
  8011ae:	eb 13                	jmp    8011c3 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011b0:	83 ec 08             	sub    $0x8,%esp
  8011b3:	56                   	push   %esi
  8011b4:	ff 75 18             	pushl  0x18(%ebp)
  8011b7:	ff d7                	call   *%edi
  8011b9:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011bc:	83 eb 01             	sub    $0x1,%ebx
  8011bf:	85 db                	test   %ebx,%ebx
  8011c1:	7f ed                	jg     8011b0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	56                   	push   %esi
  8011c7:	83 ec 04             	sub    $0x4,%esp
  8011ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011d6:	e8 95 0a 00 00       	call   801c70 <__umoddi3>
  8011db:	83 c4 14             	add    $0x14,%esp
  8011de:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  8011e5:	50                   	push   %eax
  8011e6:	ff d7                	call   *%edi
  8011e8:	83 c4 10             	add    $0x10,%esp
}
  8011eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ee:	5b                   	pop    %ebx
  8011ef:	5e                   	pop    %esi
  8011f0:	5f                   	pop    %edi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011f6:	83 fa 01             	cmp    $0x1,%edx
  8011f9:	7e 0e                	jle    801209 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011fb:	8b 10                	mov    (%eax),%edx
  8011fd:	8d 4a 08             	lea    0x8(%edx),%ecx
  801200:	89 08                	mov    %ecx,(%eax)
  801202:	8b 02                	mov    (%edx),%eax
  801204:	8b 52 04             	mov    0x4(%edx),%edx
  801207:	eb 22                	jmp    80122b <getuint+0x38>
	else if (lflag)
  801209:	85 d2                	test   %edx,%edx
  80120b:	74 10                	je     80121d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80120d:	8b 10                	mov    (%eax),%edx
  80120f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801212:	89 08                	mov    %ecx,(%eax)
  801214:	8b 02                	mov    (%edx),%eax
  801216:	ba 00 00 00 00       	mov    $0x0,%edx
  80121b:	eb 0e                	jmp    80122b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80121d:	8b 10                	mov    (%eax),%edx
  80121f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801222:	89 08                	mov    %ecx,(%eax)
  801224:	8b 02                	mov    (%edx),%eax
  801226:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801233:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801237:	8b 10                	mov    (%eax),%edx
  801239:	3b 50 04             	cmp    0x4(%eax),%edx
  80123c:	73 0a                	jae    801248 <sprintputch+0x1b>
		*b->buf++ = ch;
  80123e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801241:	89 08                	mov    %ecx,(%eax)
  801243:	8b 45 08             	mov    0x8(%ebp),%eax
  801246:	88 02                	mov    %al,(%edx)
}
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801250:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801253:	50                   	push   %eax
  801254:	ff 75 10             	pushl  0x10(%ebp)
  801257:	ff 75 0c             	pushl  0xc(%ebp)
  80125a:	ff 75 08             	pushl  0x8(%ebp)
  80125d:	e8 05 00 00 00       	call   801267 <vprintfmt>
	va_end(ap);
  801262:	83 c4 10             	add    $0x10,%esp
}
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	57                   	push   %edi
  80126b:	56                   	push   %esi
  80126c:	53                   	push   %ebx
  80126d:	83 ec 2c             	sub    $0x2c,%esp
  801270:	8b 75 08             	mov    0x8(%ebp),%esi
  801273:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801276:	8b 7d 10             	mov    0x10(%ebp),%edi
  801279:	eb 12                	jmp    80128d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80127b:	85 c0                	test   %eax,%eax
  80127d:	0f 84 90 03 00 00    	je     801613 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  801283:	83 ec 08             	sub    $0x8,%esp
  801286:	53                   	push   %ebx
  801287:	50                   	push   %eax
  801288:	ff d6                	call   *%esi
  80128a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80128d:	83 c7 01             	add    $0x1,%edi
  801290:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801294:	83 f8 25             	cmp    $0x25,%eax
  801297:	75 e2                	jne    80127b <vprintfmt+0x14>
  801299:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80129d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012a4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012ab:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b7:	eb 07                	jmp    8012c0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012bc:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c0:	8d 47 01             	lea    0x1(%edi),%eax
  8012c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c6:	0f b6 07             	movzbl (%edi),%eax
  8012c9:	0f b6 c8             	movzbl %al,%ecx
  8012cc:	83 e8 23             	sub    $0x23,%eax
  8012cf:	3c 55                	cmp    $0x55,%al
  8012d1:	0f 87 21 03 00 00    	ja     8015f8 <vprintfmt+0x391>
  8012d7:	0f b6 c0             	movzbl %al,%eax
  8012da:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8012e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012e4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012e8:	eb d6                	jmp    8012c0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012f5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012f8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012fc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012ff:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801302:	83 fa 09             	cmp    $0x9,%edx
  801305:	77 39                	ja     801340 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801307:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80130a:	eb e9                	jmp    8012f5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80130c:	8b 45 14             	mov    0x14(%ebp),%eax
  80130f:	8d 48 04             	lea    0x4(%eax),%ecx
  801312:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801315:	8b 00                	mov    (%eax),%eax
  801317:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80131d:	eb 27                	jmp    801346 <vprintfmt+0xdf>
  80131f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801322:	85 c0                	test   %eax,%eax
  801324:	b9 00 00 00 00       	mov    $0x0,%ecx
  801329:	0f 49 c8             	cmovns %eax,%ecx
  80132c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801332:	eb 8c                	jmp    8012c0 <vprintfmt+0x59>
  801334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801337:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80133e:	eb 80                	jmp    8012c0 <vprintfmt+0x59>
  801340:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801343:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801346:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80134a:	0f 89 70 ff ff ff    	jns    8012c0 <vprintfmt+0x59>
				width = precision, precision = -1;
  801350:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801353:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801356:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80135d:	e9 5e ff ff ff       	jmp    8012c0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801362:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801368:	e9 53 ff ff ff       	jmp    8012c0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80136d:	8b 45 14             	mov    0x14(%ebp),%eax
  801370:	8d 50 04             	lea    0x4(%eax),%edx
  801373:	89 55 14             	mov    %edx,0x14(%ebp)
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	53                   	push   %ebx
  80137a:	ff 30                	pushl  (%eax)
  80137c:	ff d6                	call   *%esi
			break;
  80137e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801384:	e9 04 ff ff ff       	jmp    80128d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801389:	8b 45 14             	mov    0x14(%ebp),%eax
  80138c:	8d 50 04             	lea    0x4(%eax),%edx
  80138f:	89 55 14             	mov    %edx,0x14(%ebp)
  801392:	8b 00                	mov    (%eax),%eax
  801394:	99                   	cltd   
  801395:	31 d0                	xor    %edx,%eax
  801397:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801399:	83 f8 0f             	cmp    $0xf,%eax
  80139c:	7f 0b                	jg     8013a9 <vprintfmt+0x142>
  80139e:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  8013a5:	85 d2                	test   %edx,%edx
  8013a7:	75 18                	jne    8013c1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013a9:	50                   	push   %eax
  8013aa:	68 5f 1f 80 00       	push   $0x801f5f
  8013af:	53                   	push   %ebx
  8013b0:	56                   	push   %esi
  8013b1:	e8 94 fe ff ff       	call   80124a <printfmt>
  8013b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013bc:	e9 cc fe ff ff       	jmp    80128d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013c1:	52                   	push   %edx
  8013c2:	68 dd 1e 80 00       	push   $0x801edd
  8013c7:	53                   	push   %ebx
  8013c8:	56                   	push   %esi
  8013c9:	e8 7c fe ff ff       	call   80124a <printfmt>
  8013ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013d4:	e9 b4 fe ff ff       	jmp    80128d <vprintfmt+0x26>
  8013d9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013df:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e5:	8d 50 04             	lea    0x4(%eax),%edx
  8013e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8013eb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013ed:	85 ff                	test   %edi,%edi
  8013ef:	ba 58 1f 80 00       	mov    $0x801f58,%edx
  8013f4:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8013f7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013fb:	0f 84 92 00 00 00    	je     801493 <vprintfmt+0x22c>
  801401:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801405:	0f 8e 96 00 00 00    	jle    8014a1 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	51                   	push   %ecx
  80140f:	57                   	push   %edi
  801410:	e8 86 02 00 00       	call   80169b <strnlen>
  801415:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801418:	29 c1                	sub    %eax,%ecx
  80141a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80141d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801420:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801424:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801427:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80142a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80142c:	eb 0f                	jmp    80143d <vprintfmt+0x1d6>
					putch(padc, putdat);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	53                   	push   %ebx
  801432:	ff 75 e0             	pushl  -0x20(%ebp)
  801435:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801437:	83 ef 01             	sub    $0x1,%edi
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	85 ff                	test   %edi,%edi
  80143f:	7f ed                	jg     80142e <vprintfmt+0x1c7>
  801441:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801444:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801447:	85 c9                	test   %ecx,%ecx
  801449:	b8 00 00 00 00       	mov    $0x0,%eax
  80144e:	0f 49 c1             	cmovns %ecx,%eax
  801451:	29 c1                	sub    %eax,%ecx
  801453:	89 75 08             	mov    %esi,0x8(%ebp)
  801456:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801459:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80145c:	89 cb                	mov    %ecx,%ebx
  80145e:	eb 4d                	jmp    8014ad <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801460:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801464:	74 1b                	je     801481 <vprintfmt+0x21a>
  801466:	0f be c0             	movsbl %al,%eax
  801469:	83 e8 20             	sub    $0x20,%eax
  80146c:	83 f8 5e             	cmp    $0x5e,%eax
  80146f:	76 10                	jbe    801481 <vprintfmt+0x21a>
					putch('?', putdat);
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	ff 75 0c             	pushl  0xc(%ebp)
  801477:	6a 3f                	push   $0x3f
  801479:	ff 55 08             	call   *0x8(%ebp)
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	eb 0d                	jmp    80148e <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	ff 75 0c             	pushl  0xc(%ebp)
  801487:	52                   	push   %edx
  801488:	ff 55 08             	call   *0x8(%ebp)
  80148b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80148e:	83 eb 01             	sub    $0x1,%ebx
  801491:	eb 1a                	jmp    8014ad <vprintfmt+0x246>
  801493:	89 75 08             	mov    %esi,0x8(%ebp)
  801496:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801499:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80149c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80149f:	eb 0c                	jmp    8014ad <vprintfmt+0x246>
  8014a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8014a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014ad:	83 c7 01             	add    $0x1,%edi
  8014b0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014b4:	0f be d0             	movsbl %al,%edx
  8014b7:	85 d2                	test   %edx,%edx
  8014b9:	74 23                	je     8014de <vprintfmt+0x277>
  8014bb:	85 f6                	test   %esi,%esi
  8014bd:	78 a1                	js     801460 <vprintfmt+0x1f9>
  8014bf:	83 ee 01             	sub    $0x1,%esi
  8014c2:	79 9c                	jns    801460 <vprintfmt+0x1f9>
  8014c4:	89 df                	mov    %ebx,%edi
  8014c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014cc:	eb 18                	jmp    8014e6 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	53                   	push   %ebx
  8014d2:	6a 20                	push   $0x20
  8014d4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014d6:	83 ef 01             	sub    $0x1,%edi
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	eb 08                	jmp    8014e6 <vprintfmt+0x27f>
  8014de:	89 df                	mov    %ebx,%edi
  8014e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e6:	85 ff                	test   %edi,%edi
  8014e8:	7f e4                	jg     8014ce <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014ed:	e9 9b fd ff ff       	jmp    80128d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014f2:	83 fa 01             	cmp    $0x1,%edx
  8014f5:	7e 16                	jle    80150d <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8014f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fa:	8d 50 08             	lea    0x8(%eax),%edx
  8014fd:	89 55 14             	mov    %edx,0x14(%ebp)
  801500:	8b 50 04             	mov    0x4(%eax),%edx
  801503:	8b 00                	mov    (%eax),%eax
  801505:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801508:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80150b:	eb 32                	jmp    80153f <vprintfmt+0x2d8>
	else if (lflag)
  80150d:	85 d2                	test   %edx,%edx
  80150f:	74 18                	je     801529 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801511:	8b 45 14             	mov    0x14(%ebp),%eax
  801514:	8d 50 04             	lea    0x4(%eax),%edx
  801517:	89 55 14             	mov    %edx,0x14(%ebp)
  80151a:	8b 00                	mov    (%eax),%eax
  80151c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151f:	89 c1                	mov    %eax,%ecx
  801521:	c1 f9 1f             	sar    $0x1f,%ecx
  801524:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801527:	eb 16                	jmp    80153f <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801529:	8b 45 14             	mov    0x14(%ebp),%eax
  80152c:	8d 50 04             	lea    0x4(%eax),%edx
  80152f:	89 55 14             	mov    %edx,0x14(%ebp)
  801532:	8b 00                	mov    (%eax),%eax
  801534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801537:	89 c1                	mov    %eax,%ecx
  801539:	c1 f9 1f             	sar    $0x1f,%ecx
  80153c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80153f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801542:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801545:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80154a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80154e:	79 74                	jns    8015c4 <vprintfmt+0x35d>
				putch('-', putdat);
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	53                   	push   %ebx
  801554:	6a 2d                	push   $0x2d
  801556:	ff d6                	call   *%esi
				num = -(long long) num;
  801558:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80155b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80155e:	f7 d8                	neg    %eax
  801560:	83 d2 00             	adc    $0x0,%edx
  801563:	f7 da                	neg    %edx
  801565:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801568:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80156d:	eb 55                	jmp    8015c4 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80156f:	8d 45 14             	lea    0x14(%ebp),%eax
  801572:	e8 7c fc ff ff       	call   8011f3 <getuint>
			base = 10;
  801577:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80157c:	eb 46                	jmp    8015c4 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80157e:	8d 45 14             	lea    0x14(%ebp),%eax
  801581:	e8 6d fc ff ff       	call   8011f3 <getuint>
                        base = 8;
  801586:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80158b:	eb 37                	jmp    8015c4 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	53                   	push   %ebx
  801591:	6a 30                	push   $0x30
  801593:	ff d6                	call   *%esi
			putch('x', putdat);
  801595:	83 c4 08             	add    $0x8,%esp
  801598:	53                   	push   %ebx
  801599:	6a 78                	push   $0x78
  80159b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80159d:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a0:	8d 50 04             	lea    0x4(%eax),%edx
  8015a3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015a6:	8b 00                	mov    (%eax),%eax
  8015a8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015ad:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015b0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015b5:	eb 0d                	jmp    8015c4 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015ba:	e8 34 fc ff ff       	call   8011f3 <getuint>
			base = 16;
  8015bf:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015c4:	83 ec 0c             	sub    $0xc,%esp
  8015c7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015cb:	57                   	push   %edi
  8015cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8015cf:	51                   	push   %ecx
  8015d0:	52                   	push   %edx
  8015d1:	50                   	push   %eax
  8015d2:	89 da                	mov    %ebx,%edx
  8015d4:	89 f0                	mov    %esi,%eax
  8015d6:	e8 6e fb ff ff       	call   801149 <printnum>
			break;
  8015db:	83 c4 20             	add    $0x20,%esp
  8015de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015e1:	e9 a7 fc ff ff       	jmp    80128d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	53                   	push   %ebx
  8015ea:	51                   	push   %ecx
  8015eb:	ff d6                	call   *%esi
			break;
  8015ed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015f3:	e9 95 fc ff ff       	jmp    80128d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	53                   	push   %ebx
  8015fc:	6a 25                	push   $0x25
  8015fe:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	eb 03                	jmp    801608 <vprintfmt+0x3a1>
  801605:	83 ef 01             	sub    $0x1,%edi
  801608:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80160c:	75 f7                	jne    801605 <vprintfmt+0x39e>
  80160e:	e9 7a fc ff ff       	jmp    80128d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801613:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801616:	5b                   	pop    %ebx
  801617:	5e                   	pop    %esi
  801618:	5f                   	pop    %edi
  801619:	5d                   	pop    %ebp
  80161a:	c3                   	ret    

0080161b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	83 ec 18             	sub    $0x18,%esp
  801621:	8b 45 08             	mov    0x8(%ebp),%eax
  801624:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801627:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80162a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80162e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801631:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801638:	85 c0                	test   %eax,%eax
  80163a:	74 26                	je     801662 <vsnprintf+0x47>
  80163c:	85 d2                	test   %edx,%edx
  80163e:	7e 22                	jle    801662 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801640:	ff 75 14             	pushl  0x14(%ebp)
  801643:	ff 75 10             	pushl  0x10(%ebp)
  801646:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801649:	50                   	push   %eax
  80164a:	68 2d 12 80 00       	push   $0x80122d
  80164f:	e8 13 fc ff ff       	call   801267 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801654:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801657:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80165a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	eb 05                	jmp    801667 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801662:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801667:	c9                   	leave  
  801668:	c3                   	ret    

00801669 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80166f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801672:	50                   	push   %eax
  801673:	ff 75 10             	pushl  0x10(%ebp)
  801676:	ff 75 0c             	pushl  0xc(%ebp)
  801679:	ff 75 08             	pushl  0x8(%ebp)
  80167c:	e8 9a ff ff ff       	call   80161b <vsnprintf>
	va_end(ap);

	return rc;
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801689:	b8 00 00 00 00       	mov    $0x0,%eax
  80168e:	eb 03                	jmp    801693 <strlen+0x10>
		n++;
  801690:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801693:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801697:	75 f7                	jne    801690 <strlen+0xd>
		n++;
	return n;
}
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a9:	eb 03                	jmp    8016ae <strnlen+0x13>
		n++;
  8016ab:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ae:	39 c2                	cmp    %eax,%edx
  8016b0:	74 08                	je     8016ba <strnlen+0x1f>
  8016b2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016b6:	75 f3                	jne    8016ab <strnlen+0x10>
  8016b8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016ba:	5d                   	pop    %ebp
  8016bb:	c3                   	ret    

008016bc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	53                   	push   %ebx
  8016c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016c6:	89 c2                	mov    %eax,%edx
  8016c8:	83 c2 01             	add    $0x1,%edx
  8016cb:	83 c1 01             	add    $0x1,%ecx
  8016ce:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016d2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016d5:	84 db                	test   %bl,%bl
  8016d7:	75 ef                	jne    8016c8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016d9:	5b                   	pop    %ebx
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	53                   	push   %ebx
  8016e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016e3:	53                   	push   %ebx
  8016e4:	e8 9a ff ff ff       	call   801683 <strlen>
  8016e9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016ec:	ff 75 0c             	pushl  0xc(%ebp)
  8016ef:	01 d8                	add    %ebx,%eax
  8016f1:	50                   	push   %eax
  8016f2:	e8 c5 ff ff ff       	call   8016bc <strcpy>
	return dst;
}
  8016f7:	89 d8                	mov    %ebx,%eax
  8016f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
  801703:	8b 75 08             	mov    0x8(%ebp),%esi
  801706:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801709:	89 f3                	mov    %esi,%ebx
  80170b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170e:	89 f2                	mov    %esi,%edx
  801710:	eb 0f                	jmp    801721 <strncpy+0x23>
		*dst++ = *src;
  801712:	83 c2 01             	add    $0x1,%edx
  801715:	0f b6 01             	movzbl (%ecx),%eax
  801718:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80171b:	80 39 01             	cmpb   $0x1,(%ecx)
  80171e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801721:	39 da                	cmp    %ebx,%edx
  801723:	75 ed                	jne    801712 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801725:	89 f0                	mov    %esi,%eax
  801727:	5b                   	pop    %ebx
  801728:	5e                   	pop    %esi
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    

0080172b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	56                   	push   %esi
  80172f:	53                   	push   %ebx
  801730:	8b 75 08             	mov    0x8(%ebp),%esi
  801733:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801736:	8b 55 10             	mov    0x10(%ebp),%edx
  801739:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80173b:	85 d2                	test   %edx,%edx
  80173d:	74 21                	je     801760 <strlcpy+0x35>
  80173f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801743:	89 f2                	mov    %esi,%edx
  801745:	eb 09                	jmp    801750 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801747:	83 c2 01             	add    $0x1,%edx
  80174a:	83 c1 01             	add    $0x1,%ecx
  80174d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801750:	39 c2                	cmp    %eax,%edx
  801752:	74 09                	je     80175d <strlcpy+0x32>
  801754:	0f b6 19             	movzbl (%ecx),%ebx
  801757:	84 db                	test   %bl,%bl
  801759:	75 ec                	jne    801747 <strlcpy+0x1c>
  80175b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80175d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801760:	29 f0                	sub    %esi,%eax
}
  801762:	5b                   	pop    %ebx
  801763:	5e                   	pop    %esi
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80176f:	eb 06                	jmp    801777 <strcmp+0x11>
		p++, q++;
  801771:	83 c1 01             	add    $0x1,%ecx
  801774:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801777:	0f b6 01             	movzbl (%ecx),%eax
  80177a:	84 c0                	test   %al,%al
  80177c:	74 04                	je     801782 <strcmp+0x1c>
  80177e:	3a 02                	cmp    (%edx),%al
  801780:	74 ef                	je     801771 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801782:	0f b6 c0             	movzbl %al,%eax
  801785:	0f b6 12             	movzbl (%edx),%edx
  801788:	29 d0                	sub    %edx,%eax
}
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	53                   	push   %ebx
  801790:	8b 45 08             	mov    0x8(%ebp),%eax
  801793:	8b 55 0c             	mov    0xc(%ebp),%edx
  801796:	89 c3                	mov    %eax,%ebx
  801798:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80179b:	eb 06                	jmp    8017a3 <strncmp+0x17>
		n--, p++, q++;
  80179d:	83 c0 01             	add    $0x1,%eax
  8017a0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a3:	39 d8                	cmp    %ebx,%eax
  8017a5:	74 15                	je     8017bc <strncmp+0x30>
  8017a7:	0f b6 08             	movzbl (%eax),%ecx
  8017aa:	84 c9                	test   %cl,%cl
  8017ac:	74 04                	je     8017b2 <strncmp+0x26>
  8017ae:	3a 0a                	cmp    (%edx),%cl
  8017b0:	74 eb                	je     80179d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b2:	0f b6 00             	movzbl (%eax),%eax
  8017b5:	0f b6 12             	movzbl (%edx),%edx
  8017b8:	29 d0                	sub    %edx,%eax
  8017ba:	eb 05                	jmp    8017c1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017bc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017c1:	5b                   	pop    %ebx
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ce:	eb 07                	jmp    8017d7 <strchr+0x13>
		if (*s == c)
  8017d0:	38 ca                	cmp    %cl,%dl
  8017d2:	74 0f                	je     8017e3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017d4:	83 c0 01             	add    $0x1,%eax
  8017d7:	0f b6 10             	movzbl (%eax),%edx
  8017da:	84 d2                	test   %dl,%dl
  8017dc:	75 f2                	jne    8017d0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ef:	eb 03                	jmp    8017f4 <strfind+0xf>
  8017f1:	83 c0 01             	add    $0x1,%eax
  8017f4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f7:	84 d2                	test   %dl,%dl
  8017f9:	74 04                	je     8017ff <strfind+0x1a>
  8017fb:	38 ca                	cmp    %cl,%dl
  8017fd:	75 f2                	jne    8017f1 <strfind+0xc>
			break;
	return (char *) s;
}
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	57                   	push   %edi
  801805:	56                   	push   %esi
  801806:	53                   	push   %ebx
  801807:	8b 7d 08             	mov    0x8(%ebp),%edi
  80180a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80180d:	85 c9                	test   %ecx,%ecx
  80180f:	74 36                	je     801847 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801811:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801817:	75 28                	jne    801841 <memset+0x40>
  801819:	f6 c1 03             	test   $0x3,%cl
  80181c:	75 23                	jne    801841 <memset+0x40>
		c &= 0xFF;
  80181e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801822:	89 d3                	mov    %edx,%ebx
  801824:	c1 e3 08             	shl    $0x8,%ebx
  801827:	89 d6                	mov    %edx,%esi
  801829:	c1 e6 18             	shl    $0x18,%esi
  80182c:	89 d0                	mov    %edx,%eax
  80182e:	c1 e0 10             	shl    $0x10,%eax
  801831:	09 f0                	or     %esi,%eax
  801833:	09 c2                	or     %eax,%edx
  801835:	89 d0                	mov    %edx,%eax
  801837:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801839:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80183c:	fc                   	cld    
  80183d:	f3 ab                	rep stos %eax,%es:(%edi)
  80183f:	eb 06                	jmp    801847 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801841:	8b 45 0c             	mov    0xc(%ebp),%eax
  801844:	fc                   	cld    
  801845:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801847:	89 f8                	mov    %edi,%eax
  801849:	5b                   	pop    %ebx
  80184a:	5e                   	pop    %esi
  80184b:	5f                   	pop    %edi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	57                   	push   %edi
  801852:	56                   	push   %esi
  801853:	8b 45 08             	mov    0x8(%ebp),%eax
  801856:	8b 75 0c             	mov    0xc(%ebp),%esi
  801859:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80185c:	39 c6                	cmp    %eax,%esi
  80185e:	73 35                	jae    801895 <memmove+0x47>
  801860:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801863:	39 d0                	cmp    %edx,%eax
  801865:	73 2e                	jae    801895 <memmove+0x47>
		s += n;
		d += n;
  801867:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80186a:	89 d6                	mov    %edx,%esi
  80186c:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80186e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801874:	75 13                	jne    801889 <memmove+0x3b>
  801876:	f6 c1 03             	test   $0x3,%cl
  801879:	75 0e                	jne    801889 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80187b:	83 ef 04             	sub    $0x4,%edi
  80187e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801881:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801884:	fd                   	std    
  801885:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801887:	eb 09                	jmp    801892 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801889:	83 ef 01             	sub    $0x1,%edi
  80188c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80188f:	fd                   	std    
  801890:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801892:	fc                   	cld    
  801893:	eb 1d                	jmp    8018b2 <memmove+0x64>
  801895:	89 f2                	mov    %esi,%edx
  801897:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801899:	f6 c2 03             	test   $0x3,%dl
  80189c:	75 0f                	jne    8018ad <memmove+0x5f>
  80189e:	f6 c1 03             	test   $0x3,%cl
  8018a1:	75 0a                	jne    8018ad <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018a3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018a6:	89 c7                	mov    %eax,%edi
  8018a8:	fc                   	cld    
  8018a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ab:	eb 05                	jmp    8018b2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018ad:	89 c7                	mov    %eax,%edi
  8018af:	fc                   	cld    
  8018b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018b2:	5e                   	pop    %esi
  8018b3:	5f                   	pop    %edi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018b9:	ff 75 10             	pushl  0x10(%ebp)
  8018bc:	ff 75 0c             	pushl  0xc(%ebp)
  8018bf:	ff 75 08             	pushl  0x8(%ebp)
  8018c2:	e8 87 ff ff ff       	call   80184e <memmove>
}
  8018c7:	c9                   	leave  
  8018c8:	c3                   	ret    

008018c9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	56                   	push   %esi
  8018cd:	53                   	push   %ebx
  8018ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d4:	89 c6                	mov    %eax,%esi
  8018d6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d9:	eb 1a                	jmp    8018f5 <memcmp+0x2c>
		if (*s1 != *s2)
  8018db:	0f b6 08             	movzbl (%eax),%ecx
  8018de:	0f b6 1a             	movzbl (%edx),%ebx
  8018e1:	38 d9                	cmp    %bl,%cl
  8018e3:	74 0a                	je     8018ef <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018e5:	0f b6 c1             	movzbl %cl,%eax
  8018e8:	0f b6 db             	movzbl %bl,%ebx
  8018eb:	29 d8                	sub    %ebx,%eax
  8018ed:	eb 0f                	jmp    8018fe <memcmp+0x35>
		s1++, s2++;
  8018ef:	83 c0 01             	add    $0x1,%eax
  8018f2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f5:	39 f0                	cmp    %esi,%eax
  8018f7:	75 e2                	jne    8018db <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fe:	5b                   	pop    %ebx
  8018ff:	5e                   	pop    %esi
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    

00801902 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	8b 45 08             	mov    0x8(%ebp),%eax
  801908:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80190b:	89 c2                	mov    %eax,%edx
  80190d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801910:	eb 07                	jmp    801919 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801912:	38 08                	cmp    %cl,(%eax)
  801914:	74 07                	je     80191d <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801916:	83 c0 01             	add    $0x1,%eax
  801919:	39 d0                	cmp    %edx,%eax
  80191b:	72 f5                	jb     801912 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    

0080191f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	57                   	push   %edi
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801928:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80192b:	eb 03                	jmp    801930 <strtol+0x11>
		s++;
  80192d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801930:	0f b6 01             	movzbl (%ecx),%eax
  801933:	3c 09                	cmp    $0x9,%al
  801935:	74 f6                	je     80192d <strtol+0xe>
  801937:	3c 20                	cmp    $0x20,%al
  801939:	74 f2                	je     80192d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80193b:	3c 2b                	cmp    $0x2b,%al
  80193d:	75 0a                	jne    801949 <strtol+0x2a>
		s++;
  80193f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801942:	bf 00 00 00 00       	mov    $0x0,%edi
  801947:	eb 10                	jmp    801959 <strtol+0x3a>
  801949:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80194e:	3c 2d                	cmp    $0x2d,%al
  801950:	75 07                	jne    801959 <strtol+0x3a>
		s++, neg = 1;
  801952:	8d 49 01             	lea    0x1(%ecx),%ecx
  801955:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801959:	85 db                	test   %ebx,%ebx
  80195b:	0f 94 c0             	sete   %al
  80195e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801964:	75 19                	jne    80197f <strtol+0x60>
  801966:	80 39 30             	cmpb   $0x30,(%ecx)
  801969:	75 14                	jne    80197f <strtol+0x60>
  80196b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80196f:	0f 85 82 00 00 00    	jne    8019f7 <strtol+0xd8>
		s += 2, base = 16;
  801975:	83 c1 02             	add    $0x2,%ecx
  801978:	bb 10 00 00 00       	mov    $0x10,%ebx
  80197d:	eb 16                	jmp    801995 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80197f:	84 c0                	test   %al,%al
  801981:	74 12                	je     801995 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801983:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801988:	80 39 30             	cmpb   $0x30,(%ecx)
  80198b:	75 08                	jne    801995 <strtol+0x76>
		s++, base = 8;
  80198d:	83 c1 01             	add    $0x1,%ecx
  801990:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801995:	b8 00 00 00 00       	mov    $0x0,%eax
  80199a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80199d:	0f b6 11             	movzbl (%ecx),%edx
  8019a0:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019a3:	89 f3                	mov    %esi,%ebx
  8019a5:	80 fb 09             	cmp    $0x9,%bl
  8019a8:	77 08                	ja     8019b2 <strtol+0x93>
			dig = *s - '0';
  8019aa:	0f be d2             	movsbl %dl,%edx
  8019ad:	83 ea 30             	sub    $0x30,%edx
  8019b0:	eb 22                	jmp    8019d4 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019b2:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019b5:	89 f3                	mov    %esi,%ebx
  8019b7:	80 fb 19             	cmp    $0x19,%bl
  8019ba:	77 08                	ja     8019c4 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019bc:	0f be d2             	movsbl %dl,%edx
  8019bf:	83 ea 57             	sub    $0x57,%edx
  8019c2:	eb 10                	jmp    8019d4 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019c4:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019c7:	89 f3                	mov    %esi,%ebx
  8019c9:	80 fb 19             	cmp    $0x19,%bl
  8019cc:	77 16                	ja     8019e4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019ce:	0f be d2             	movsbl %dl,%edx
  8019d1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019d4:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d7:	7d 0f                	jge    8019e8 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019d9:	83 c1 01             	add    $0x1,%ecx
  8019dc:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019e0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019e2:	eb b9                	jmp    80199d <strtol+0x7e>
  8019e4:	89 c2                	mov    %eax,%edx
  8019e6:	eb 02                	jmp    8019ea <strtol+0xcb>
  8019e8:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019ee:	74 0d                	je     8019fd <strtol+0xde>
		*endptr = (char *) s;
  8019f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019f3:	89 0e                	mov    %ecx,(%esi)
  8019f5:	eb 06                	jmp    8019fd <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019f7:	84 c0                	test   %al,%al
  8019f9:	75 92                	jne    80198d <strtol+0x6e>
  8019fb:	eb 98                	jmp    801995 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019fd:	f7 da                	neg    %edx
  8019ff:	85 ff                	test   %edi,%edi
  801a01:	0f 45 c2             	cmovne %edx,%eax
}
  801a04:	5b                   	pop    %ebx
  801a05:	5e                   	pop    %esi
  801a06:	5f                   	pop    %edi
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	56                   	push   %esi
  801a0d:	53                   	push   %ebx
  801a0e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801a17:	85 c0                	test   %eax,%eax
  801a19:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a1e:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801a21:	83 ec 0c             	sub    $0xc,%esp
  801a24:	50                   	push   %eax
  801a25:	e8 e4 e8 ff ff       	call   80030e <sys_ipc_recv>
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	79 16                	jns    801a47 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801a31:	85 f6                	test   %esi,%esi
  801a33:	74 06                	je     801a3b <ipc_recv+0x32>
  801a35:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801a3b:	85 db                	test   %ebx,%ebx
  801a3d:	74 2c                	je     801a6b <ipc_recv+0x62>
  801a3f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a45:	eb 24                	jmp    801a6b <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a47:	85 f6                	test   %esi,%esi
  801a49:	74 0a                	je     801a55 <ipc_recv+0x4c>
  801a4b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a50:	8b 40 74             	mov    0x74(%eax),%eax
  801a53:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801a55:	85 db                	test   %ebx,%ebx
  801a57:	74 0a                	je     801a63 <ipc_recv+0x5a>
  801a59:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5e:	8b 40 78             	mov    0x78(%eax),%eax
  801a61:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801a63:	a1 04 40 80 00       	mov    0x804004,%eax
  801a68:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6e:	5b                   	pop    %ebx
  801a6f:	5e                   	pop    %esi
  801a70:	5d                   	pop    %ebp
  801a71:	c3                   	ret    

00801a72 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	57                   	push   %edi
  801a76:	56                   	push   %esi
  801a77:	53                   	push   %ebx
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801a84:	85 db                	test   %ebx,%ebx
  801a86:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a8b:	0f 44 d8             	cmove  %eax,%ebx
  801a8e:	eb 1c                	jmp    801aac <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801a90:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a93:	74 12                	je     801aa7 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801a95:	50                   	push   %eax
  801a96:	68 60 22 80 00       	push   $0x802260
  801a9b:	6a 39                	push   $0x39
  801a9d:	68 7b 22 80 00       	push   $0x80227b
  801aa2:	e8 b5 f5 ff ff       	call   80105c <_panic>
                 sys_yield();
  801aa7:	e8 93 e6 ff ff       	call   80013f <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801aac:	ff 75 14             	pushl  0x14(%ebp)
  801aaf:	53                   	push   %ebx
  801ab0:	56                   	push   %esi
  801ab1:	57                   	push   %edi
  801ab2:	e8 34 e8 ff ff       	call   8002eb <sys_ipc_try_send>
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	85 c0                	test   %eax,%eax
  801abc:	78 d2                	js     801a90 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801abe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac1:	5b                   	pop    %ebx
  801ac2:	5e                   	pop    %esi
  801ac3:	5f                   	pop    %edi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801acc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ad1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ad4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ada:	8b 52 50             	mov    0x50(%edx),%edx
  801add:	39 ca                	cmp    %ecx,%edx
  801adf:	75 0d                	jne    801aee <ipc_find_env+0x28>
			return envs[i].env_id;
  801ae1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ae4:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ae9:	8b 40 08             	mov    0x8(%eax),%eax
  801aec:	eb 0e                	jmp    801afc <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aee:	83 c0 01             	add    $0x1,%eax
  801af1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af6:	75 d9                	jne    801ad1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af8:	66 b8 00 00          	mov    $0x0,%ax
}
  801afc:	5d                   	pop    %ebp
  801afd:	c3                   	ret    

00801afe <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b04:	89 d0                	mov    %edx,%eax
  801b06:	c1 e8 16             	shr    $0x16,%eax
  801b09:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b10:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b15:	f6 c1 01             	test   $0x1,%cl
  801b18:	74 1d                	je     801b37 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b1a:	c1 ea 0c             	shr    $0xc,%edx
  801b1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b24:	f6 c2 01             	test   $0x1,%dl
  801b27:	74 0e                	je     801b37 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b29:	c1 ea 0c             	shr    $0xc,%edx
  801b2c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b33:	ef 
  801b34:	0f b7 c0             	movzwl %ax,%eax
}
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    
  801b39:	66 90                	xchg   %ax,%ax
  801b3b:	66 90                	xchg   %ax,%ax
  801b3d:	66 90                	xchg   %ax,%ax
  801b3f:	90                   	nop

00801b40 <__udivdi3>:
  801b40:	55                   	push   %ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	83 ec 10             	sub    $0x10,%esp
  801b46:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b4a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b4e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b52:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b56:	85 d2                	test   %edx,%edx
  801b58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b5c:	89 34 24             	mov    %esi,(%esp)
  801b5f:	89 c8                	mov    %ecx,%eax
  801b61:	75 35                	jne    801b98 <__udivdi3+0x58>
  801b63:	39 f1                	cmp    %esi,%ecx
  801b65:	0f 87 bd 00 00 00    	ja     801c28 <__udivdi3+0xe8>
  801b6b:	85 c9                	test   %ecx,%ecx
  801b6d:	89 cd                	mov    %ecx,%ebp
  801b6f:	75 0b                	jne    801b7c <__udivdi3+0x3c>
  801b71:	b8 01 00 00 00       	mov    $0x1,%eax
  801b76:	31 d2                	xor    %edx,%edx
  801b78:	f7 f1                	div    %ecx
  801b7a:	89 c5                	mov    %eax,%ebp
  801b7c:	89 f0                	mov    %esi,%eax
  801b7e:	31 d2                	xor    %edx,%edx
  801b80:	f7 f5                	div    %ebp
  801b82:	89 c6                	mov    %eax,%esi
  801b84:	89 f8                	mov    %edi,%eax
  801b86:	f7 f5                	div    %ebp
  801b88:	89 f2                	mov    %esi,%edx
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	5e                   	pop    %esi
  801b8e:	5f                   	pop    %edi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    
  801b91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b98:	3b 14 24             	cmp    (%esp),%edx
  801b9b:	77 7b                	ja     801c18 <__udivdi3+0xd8>
  801b9d:	0f bd f2             	bsr    %edx,%esi
  801ba0:	83 f6 1f             	xor    $0x1f,%esi
  801ba3:	0f 84 97 00 00 00    	je     801c40 <__udivdi3+0x100>
  801ba9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801bae:	89 d7                	mov    %edx,%edi
  801bb0:	89 f1                	mov    %esi,%ecx
  801bb2:	29 f5                	sub    %esi,%ebp
  801bb4:	d3 e7                	shl    %cl,%edi
  801bb6:	89 c2                	mov    %eax,%edx
  801bb8:	89 e9                	mov    %ebp,%ecx
  801bba:	d3 ea                	shr    %cl,%edx
  801bbc:	89 f1                	mov    %esi,%ecx
  801bbe:	09 fa                	or     %edi,%edx
  801bc0:	8b 3c 24             	mov    (%esp),%edi
  801bc3:	d3 e0                	shl    %cl,%eax
  801bc5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bc9:	89 e9                	mov    %ebp,%ecx
  801bcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bcf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801bd3:	89 fa                	mov    %edi,%edx
  801bd5:	d3 ea                	shr    %cl,%edx
  801bd7:	89 f1                	mov    %esi,%ecx
  801bd9:	d3 e7                	shl    %cl,%edi
  801bdb:	89 e9                	mov    %ebp,%ecx
  801bdd:	d3 e8                	shr    %cl,%eax
  801bdf:	09 c7                	or     %eax,%edi
  801be1:	89 f8                	mov    %edi,%eax
  801be3:	f7 74 24 08          	divl   0x8(%esp)
  801be7:	89 d5                	mov    %edx,%ebp
  801be9:	89 c7                	mov    %eax,%edi
  801beb:	f7 64 24 0c          	mull   0xc(%esp)
  801bef:	39 d5                	cmp    %edx,%ebp
  801bf1:	89 14 24             	mov    %edx,(%esp)
  801bf4:	72 11                	jb     801c07 <__udivdi3+0xc7>
  801bf6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801bfa:	89 f1                	mov    %esi,%ecx
  801bfc:	d3 e2                	shl    %cl,%edx
  801bfe:	39 c2                	cmp    %eax,%edx
  801c00:	73 5e                	jae    801c60 <__udivdi3+0x120>
  801c02:	3b 2c 24             	cmp    (%esp),%ebp
  801c05:	75 59                	jne    801c60 <__udivdi3+0x120>
  801c07:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c0a:	31 f6                	xor    %esi,%esi
  801c0c:	89 f2                	mov    %esi,%edx
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	5e                   	pop    %esi
  801c12:	5f                   	pop    %edi
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    
  801c15:	8d 76 00             	lea    0x0(%esi),%esi
  801c18:	31 f6                	xor    %esi,%esi
  801c1a:	31 c0                	xor    %eax,%eax
  801c1c:	89 f2                	mov    %esi,%edx
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    
  801c25:	8d 76 00             	lea    0x0(%esi),%esi
  801c28:	89 f2                	mov    %esi,%edx
  801c2a:	31 f6                	xor    %esi,%esi
  801c2c:	89 f8                	mov    %edi,%eax
  801c2e:	f7 f1                	div    %ecx
  801c30:	89 f2                	mov    %esi,%edx
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	5e                   	pop    %esi
  801c36:	5f                   	pop    %edi
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c44:	76 0b                	jbe    801c51 <__udivdi3+0x111>
  801c46:	31 c0                	xor    %eax,%eax
  801c48:	3b 14 24             	cmp    (%esp),%edx
  801c4b:	0f 83 37 ff ff ff    	jae    801b88 <__udivdi3+0x48>
  801c51:	b8 01 00 00 00       	mov    $0x1,%eax
  801c56:	e9 2d ff ff ff       	jmp    801b88 <__udivdi3+0x48>
  801c5b:	90                   	nop
  801c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c60:	89 f8                	mov    %edi,%eax
  801c62:	31 f6                	xor    %esi,%esi
  801c64:	e9 1f ff ff ff       	jmp    801b88 <__udivdi3+0x48>
  801c69:	66 90                	xchg   %ax,%ax
  801c6b:	66 90                	xchg   %ax,%ax
  801c6d:	66 90                	xchg   %ax,%ax
  801c6f:	90                   	nop

00801c70 <__umoddi3>:
  801c70:	55                   	push   %ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	83 ec 20             	sub    $0x20,%esp
  801c76:	8b 44 24 34          	mov    0x34(%esp),%eax
  801c7a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c7e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c82:	89 c6                	mov    %eax,%esi
  801c84:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c88:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c8c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801c90:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c94:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801c98:	89 74 24 18          	mov    %esi,0x18(%esp)
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	89 c2                	mov    %eax,%edx
  801ca0:	75 1e                	jne    801cc0 <__umoddi3+0x50>
  801ca2:	39 f7                	cmp    %esi,%edi
  801ca4:	76 52                	jbe    801cf8 <__umoddi3+0x88>
  801ca6:	89 c8                	mov    %ecx,%eax
  801ca8:	89 f2                	mov    %esi,%edx
  801caa:	f7 f7                	div    %edi
  801cac:	89 d0                	mov    %edx,%eax
  801cae:	31 d2                	xor    %edx,%edx
  801cb0:	83 c4 20             	add    $0x20,%esp
  801cb3:	5e                   	pop    %esi
  801cb4:	5f                   	pop    %edi
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    
  801cb7:	89 f6                	mov    %esi,%esi
  801cb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801cc0:	39 f0                	cmp    %esi,%eax
  801cc2:	77 5c                	ja     801d20 <__umoddi3+0xb0>
  801cc4:	0f bd e8             	bsr    %eax,%ebp
  801cc7:	83 f5 1f             	xor    $0x1f,%ebp
  801cca:	75 64                	jne    801d30 <__umoddi3+0xc0>
  801ccc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801cd0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801cd4:	0f 86 f6 00 00 00    	jbe    801dd0 <__umoddi3+0x160>
  801cda:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cde:	0f 82 ec 00 00 00    	jb     801dd0 <__umoddi3+0x160>
  801ce4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ce8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801cec:	83 c4 20             	add    $0x20,%esp
  801cef:	5e                   	pop    %esi
  801cf0:	5f                   	pop    %edi
  801cf1:	5d                   	pop    %ebp
  801cf2:	c3                   	ret    
  801cf3:	90                   	nop
  801cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	85 ff                	test   %edi,%edi
  801cfa:	89 fd                	mov    %edi,%ebp
  801cfc:	75 0b                	jne    801d09 <__umoddi3+0x99>
  801cfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801d03:	31 d2                	xor    %edx,%edx
  801d05:	f7 f7                	div    %edi
  801d07:	89 c5                	mov    %eax,%ebp
  801d09:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d0d:	31 d2                	xor    %edx,%edx
  801d0f:	f7 f5                	div    %ebp
  801d11:	89 c8                	mov    %ecx,%eax
  801d13:	f7 f5                	div    %ebp
  801d15:	eb 95                	jmp    801cac <__umoddi3+0x3c>
  801d17:	89 f6                	mov    %esi,%esi
  801d19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	83 c4 20             	add    $0x20,%esp
  801d27:	5e                   	pop    %esi
  801d28:	5f                   	pop    %edi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    
  801d2b:	90                   	nop
  801d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d30:	b8 20 00 00 00       	mov    $0x20,%eax
  801d35:	89 e9                	mov    %ebp,%ecx
  801d37:	29 e8                	sub    %ebp,%eax
  801d39:	d3 e2                	shl    %cl,%edx
  801d3b:	89 c7                	mov    %eax,%edi
  801d3d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d41:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	d3 e8                	shr    %cl,%eax
  801d49:	89 c1                	mov    %eax,%ecx
  801d4b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d4f:	09 d1                	or     %edx,%ecx
  801d51:	89 fa                	mov    %edi,%edx
  801d53:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d57:	89 e9                	mov    %ebp,%ecx
  801d59:	d3 e0                	shl    %cl,%eax
  801d5b:	89 f9                	mov    %edi,%ecx
  801d5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d61:	89 f0                	mov    %esi,%eax
  801d63:	d3 e8                	shr    %cl,%eax
  801d65:	89 e9                	mov    %ebp,%ecx
  801d67:	89 c7                	mov    %eax,%edi
  801d69:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d6d:	d3 e6                	shl    %cl,%esi
  801d6f:	89 d1                	mov    %edx,%ecx
  801d71:	89 fa                	mov    %edi,%edx
  801d73:	d3 e8                	shr    %cl,%eax
  801d75:	89 e9                	mov    %ebp,%ecx
  801d77:	09 f0                	or     %esi,%eax
  801d79:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801d7d:	f7 74 24 10          	divl   0x10(%esp)
  801d81:	d3 e6                	shl    %cl,%esi
  801d83:	89 d1                	mov    %edx,%ecx
  801d85:	f7 64 24 0c          	mull   0xc(%esp)
  801d89:	39 d1                	cmp    %edx,%ecx
  801d8b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801d8f:	89 d7                	mov    %edx,%edi
  801d91:	89 c6                	mov    %eax,%esi
  801d93:	72 0a                	jb     801d9f <__umoddi3+0x12f>
  801d95:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801d99:	73 10                	jae    801dab <__umoddi3+0x13b>
  801d9b:	39 d1                	cmp    %edx,%ecx
  801d9d:	75 0c                	jne    801dab <__umoddi3+0x13b>
  801d9f:	89 d7                	mov    %edx,%edi
  801da1:	89 c6                	mov    %eax,%esi
  801da3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801da7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801dab:	89 ca                	mov    %ecx,%edx
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801db3:	29 f0                	sub    %esi,%eax
  801db5:	19 fa                	sbb    %edi,%edx
  801db7:	d3 e8                	shr    %cl,%eax
  801db9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801dbe:	89 d7                	mov    %edx,%edi
  801dc0:	d3 e7                	shl    %cl,%edi
  801dc2:	89 e9                	mov    %ebp,%ecx
  801dc4:	09 f8                	or     %edi,%eax
  801dc6:	d3 ea                	shr    %cl,%edx
  801dc8:	83 c4 20             	add    $0x20,%esp
  801dcb:	5e                   	pop    %esi
  801dcc:	5f                   	pop    %edi
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    
  801dcf:	90                   	nop
  801dd0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801dd4:	29 f9                	sub    %edi,%ecx
  801dd6:	19 c6                	sbb    %eax,%esi
  801dd8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801ddc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801de0:	e9 ff fe ff ff       	jmp    801ce4 <__umoddi3+0x74>
