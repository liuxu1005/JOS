
obj/user/softint.debug:     file format elf32-i386


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
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 89 04 00 00       	call   800514 <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
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
  8000ff:	68 0a 1e 80 00       	push   $0x801e0a
  800104:	6a 23                	push   $0x23
  800106:	68 27 1e 80 00       	push   $0x801e27
  80010b:	e8 44 0f 00 00       	call   801054 <_panic>

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
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800180:	68 0a 1e 80 00       	push   $0x801e0a
  800185:	6a 23                	push   $0x23
  800187:	68 27 1e 80 00       	push   $0x801e27
  80018c:	e8 c3 0e 00 00       	call   801054 <_panic>

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
  8001c2:	68 0a 1e 80 00       	push   $0x801e0a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 27 1e 80 00       	push   $0x801e27
  8001ce:	e8 81 0e 00 00       	call   801054 <_panic>

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
  800204:	68 0a 1e 80 00       	push   $0x801e0a
  800209:	6a 23                	push   $0x23
  80020b:	68 27 1e 80 00       	push   $0x801e27
  800210:	e8 3f 0e 00 00       	call   801054 <_panic>

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
  800246:	68 0a 1e 80 00       	push   $0x801e0a
  80024b:	6a 23                	push   $0x23
  80024d:	68 27 1e 80 00       	push   $0x801e27
  800252:	e8 fd 0d 00 00       	call   801054 <_panic>
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

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800280:	7e 17                	jle    800299 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 0a 1e 80 00       	push   $0x801e0a
  80028d:	6a 23                	push   $0x23
  80028f:	68 27 1e 80 00       	push   $0x801e27
  800294:	e8 bb 0d 00 00       	call   801054 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7e 17                	jle    8002db <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 0a                	push   $0xa
  8002ca:	68 0a 1e 80 00       	push   $0x801e0a
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 27 1e 80 00       	push   $0x801e27
  8002d6:	e8 79 0d 00 00       	call   801054 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	b8 0d 00 00 00       	mov    $0xd,%eax
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 17                	jle    80033f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0d                	push   $0xd
  80032e:	68 0a 1e 80 00       	push   $0x801e0a
  800333:	6a 23                	push   $0x23
  800335:	68 27 1e 80 00       	push   $0x801e27
  80033a:	e8 15 0d 00 00       	call   801054 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	05 00 00 00 30       	add    $0x30000000,%eax
  800352:	c1 e8 0c             	shr    $0xc,%eax
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800379:	89 c2                	mov    %eax,%edx
  80037b:	c1 ea 16             	shr    $0x16,%edx
  80037e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800385:	f6 c2 01             	test   $0x1,%dl
  800388:	74 11                	je     80039b <fd_alloc+0x2d>
  80038a:	89 c2                	mov    %eax,%edx
  80038c:	c1 ea 0c             	shr    $0xc,%edx
  80038f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800396:	f6 c2 01             	test   $0x1,%dl
  800399:	75 09                	jne    8003a4 <fd_alloc+0x36>
			*fd_store = fd;
  80039b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039d:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a2:	eb 17                	jmp    8003bb <fd_alloc+0x4d>
  8003a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ae:	75 c9                	jne    800379 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c3:	83 f8 1f             	cmp    $0x1f,%eax
  8003c6:	77 36                	ja     8003fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
  8003cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 24                	je     800405 <fd_lookup+0x48>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	74 1a                	je     80040c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	eb 13                	jmp    800411 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800403:	eb 0c                	jmp    800411 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040a:	eb 05                	jmp    800411 <fd_lookup+0x54>
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041c:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	eb 13                	jmp    800436 <dev_lookup+0x23>
  800423:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 08                	cmp    %ecx,(%eax)
  800428:	75 0c                	jne    800436 <dev_lookup+0x23>
			*dev = devtab[i];
  80042a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	eb 2e                	jmp    800464 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	85 c0                	test   %eax,%eax
  80043a:	75 e7                	jne    800423 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043c:	a1 04 40 80 00       	mov    0x804004,%eax
  800441:	8b 40 48             	mov    0x48(%eax),%eax
  800444:	83 ec 04             	sub    $0x4,%esp
  800447:	51                   	push   %ecx
  800448:	50                   	push   %eax
  800449:	68 38 1e 80 00       	push   $0x801e38
  80044e:	e8 da 0c 00 00       	call   80112d <cprintf>
	*dev = 0;
  800453:	8b 45 0c             	mov    0xc(%ebp),%eax
  800456:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800464:	c9                   	leave  
  800465:	c3                   	ret    

00800466 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	56                   	push   %esi
  80046a:	53                   	push   %ebx
  80046b:	83 ec 10             	sub    $0x10,%esp
  80046e:	8b 75 08             	mov    0x8(%ebp),%esi
  800471:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800477:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800478:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047e:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800481:	50                   	push   %eax
  800482:	e8 36 ff ff ff       	call   8003bd <fd_lookup>
  800487:	83 c4 08             	add    $0x8,%esp
  80048a:	85 c0                	test   %eax,%eax
  80048c:	78 05                	js     800493 <fd_close+0x2d>
	    || fd != fd2)
  80048e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800491:	74 0c                	je     80049f <fd_close+0x39>
		return (must_exist ? r : 0);
  800493:	84 db                	test   %bl,%bl
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
  80049a:	0f 44 c2             	cmove  %edx,%eax
  80049d:	eb 41                	jmp    8004e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a5:	50                   	push   %eax
  8004a6:	ff 36                	pushl  (%esi)
  8004a8:	e8 66 ff ff ff       	call   800413 <dev_lookup>
  8004ad:	89 c3                	mov    %eax,%ebx
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	78 1a                	js     8004d0 <fd_close+0x6a>
		if (dev->dev_close)
  8004b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	74 0b                	je     8004d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c5:	83 ec 0c             	sub    $0xc,%esp
  8004c8:	56                   	push   %esi
  8004c9:	ff d0                	call   *%eax
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	56                   	push   %esi
  8004d4:	6a 00                	push   $0x0
  8004d6:	e8 00 fd ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	89 d8                	mov    %ebx,%eax
}
  8004e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e3:	5b                   	pop    %ebx
  8004e4:	5e                   	pop    %esi
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f0:	50                   	push   %eax
  8004f1:	ff 75 08             	pushl  0x8(%ebp)
  8004f4:	e8 c4 fe ff ff       	call   8003bd <fd_lookup>
  8004f9:	89 c2                	mov    %eax,%edx
  8004fb:	83 c4 08             	add    $0x8,%esp
  8004fe:	85 d2                	test   %edx,%edx
  800500:	78 10                	js     800512 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	6a 01                	push   $0x1
  800507:	ff 75 f4             	pushl  -0xc(%ebp)
  80050a:	e8 57 ff ff ff       	call   800466 <fd_close>
  80050f:	83 c4 10             	add    $0x10,%esp
}
  800512:	c9                   	leave  
  800513:	c3                   	ret    

00800514 <close_all>:

void
close_all(void)
{
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
  800517:	53                   	push   %ebx
  800518:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80051b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800520:	83 ec 0c             	sub    $0xc,%esp
  800523:	53                   	push   %ebx
  800524:	e8 be ff ff ff       	call   8004e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800529:	83 c3 01             	add    $0x1,%ebx
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	83 fb 20             	cmp    $0x20,%ebx
  800532:	75 ec                	jne    800520 <close_all+0xc>
		close(i);
}
  800534:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800537:	c9                   	leave  
  800538:	c3                   	ret    

00800539 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  80053c:	57                   	push   %edi
  80053d:	56                   	push   %esi
  80053e:	53                   	push   %ebx
  80053f:	83 ec 2c             	sub    $0x2c,%esp
  800542:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800545:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800548:	50                   	push   %eax
  800549:	ff 75 08             	pushl  0x8(%ebp)
  80054c:	e8 6c fe ff ff       	call   8003bd <fd_lookup>
  800551:	89 c2                	mov    %eax,%edx
  800553:	83 c4 08             	add    $0x8,%esp
  800556:	85 d2                	test   %edx,%edx
  800558:	0f 88 c1 00 00 00    	js     80061f <dup+0xe6>
		return r;
	close(newfdnum);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	56                   	push   %esi
  800562:	e8 80 ff ff ff       	call   8004e7 <close>

	newfd = INDEX2FD(newfdnum);
  800567:	89 f3                	mov    %esi,%ebx
  800569:	c1 e3 0c             	shl    $0xc,%ebx
  80056c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800572:	83 c4 04             	add    $0x4,%esp
  800575:	ff 75 e4             	pushl  -0x1c(%ebp)
  800578:	e8 da fd ff ff       	call   800357 <fd2data>
  80057d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057f:	89 1c 24             	mov    %ebx,(%esp)
  800582:	e8 d0 fd ff ff       	call   800357 <fd2data>
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80058d:	89 f8                	mov    %edi,%eax
  80058f:	c1 e8 16             	shr    $0x16,%eax
  800592:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800599:	a8 01                	test   $0x1,%al
  80059b:	74 37                	je     8005d4 <dup+0x9b>
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 0c             	shr    $0xc,%eax
  8005a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a9:	f6 c2 01             	test   $0x1,%dl
  8005ac:	74 26                	je     8005d4 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b5:	83 ec 0c             	sub    $0xc,%esp
  8005b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005bd:	50                   	push   %eax
  8005be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c1:	6a 00                	push   $0x0
  8005c3:	57                   	push   %edi
  8005c4:	6a 00                	push   $0x0
  8005c6:	e8 ce fb ff ff       	call   800199 <sys_page_map>
  8005cb:	89 c7                	mov    %eax,%edi
  8005cd:	83 c4 20             	add    $0x20,%esp
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	78 2e                	js     800602 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d7:	89 d0                	mov    %edx,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005eb:	50                   	push   %eax
  8005ec:	53                   	push   %ebx
  8005ed:	6a 00                	push   $0x0
  8005ef:	52                   	push   %edx
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 a2 fb ff ff       	call   800199 <sys_page_map>
  8005f7:	89 c7                	mov    %eax,%edi
  8005f9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005fc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fe:	85 ff                	test   %edi,%edi
  800600:	79 1d                	jns    80061f <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 00                	push   $0x0
  800608:	e8 ce fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	ff 75 d4             	pushl  -0x2c(%ebp)
  800613:	6a 00                	push   $0x0
  800615:	e8 c1 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	89 f8                	mov    %edi,%eax
}
  80061f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800622:	5b                   	pop    %ebx
  800623:	5e                   	pop    %esi
  800624:	5f                   	pop    %edi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	53                   	push   %ebx
  80062b:	83 ec 14             	sub    $0x14,%esp
  80062e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	53                   	push   %ebx
  800636:	e8 82 fd ff ff       	call   8003bd <fd_lookup>
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	89 c2                	mov    %eax,%edx
  800640:	85 c0                	test   %eax,%eax
  800642:	78 6d                	js     8006b1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064a:	50                   	push   %eax
  80064b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064e:	ff 30                	pushl  (%eax)
  800650:	e8 be fd ff ff       	call   800413 <dev_lookup>
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 c0                	test   %eax,%eax
  80065a:	78 4c                	js     8006a8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80065c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065f:	8b 42 08             	mov    0x8(%edx),%eax
  800662:	83 e0 03             	and    $0x3,%eax
  800665:	83 f8 01             	cmp    $0x1,%eax
  800668:	75 21                	jne    80068b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066a:	a1 04 40 80 00       	mov    0x804004,%eax
  80066f:	8b 40 48             	mov    0x48(%eax),%eax
  800672:	83 ec 04             	sub    $0x4,%esp
  800675:	53                   	push   %ebx
  800676:	50                   	push   %eax
  800677:	68 79 1e 80 00       	push   $0x801e79
  80067c:	e8 ac 0a 00 00       	call   80112d <cprintf>
		return -E_INVAL;
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800689:	eb 26                	jmp    8006b1 <read+0x8a>
	}
	if (!dev->dev_read)
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	8b 40 08             	mov    0x8(%eax),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	74 17                	je     8006ac <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	ff 75 0c             	pushl  0xc(%ebp)
  80069e:	52                   	push   %edx
  80069f:	ff d0                	call   *%eax
  8006a1:	89 c2                	mov    %eax,%edx
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 09                	jmp    8006b1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a8:	89 c2                	mov    %eax,%edx
  8006aa:	eb 05                	jmp    8006b1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b1:	89 d0                	mov    %edx,%eax
  8006b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cc:	eb 21                	jmp    8006ef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ce:	83 ec 04             	sub    $0x4,%esp
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	29 d8                	sub    %ebx,%eax
  8006d5:	50                   	push   %eax
  8006d6:	89 d8                	mov    %ebx,%eax
  8006d8:	03 45 0c             	add    0xc(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	57                   	push   %edi
  8006dd:	e8 45 ff ff ff       	call   800627 <read>
		if (m < 0)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	78 0c                	js     8006f5 <readn+0x3d>
			return m;
		if (m == 0)
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 06                	je     8006f3 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ed:	01 c3                	add    %eax,%ebx
  8006ef:	39 f3                	cmp    %esi,%ebx
  8006f1:	72 db                	jb     8006ce <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8006f3:	89 d8                	mov    %ebx,%eax
}
  8006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	53                   	push   %ebx
  800701:	83 ec 14             	sub    $0x14,%esp
  800704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800707:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	53                   	push   %ebx
  80070c:	e8 ac fc ff ff       	call   8003bd <fd_lookup>
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	89 c2                	mov    %eax,%edx
  800716:	85 c0                	test   %eax,%eax
  800718:	78 68                	js     800782 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800720:	50                   	push   %eax
  800721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800724:	ff 30                	pushl  (%eax)
  800726:	e8 e8 fc ff ff       	call   800413 <dev_lookup>
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	85 c0                	test   %eax,%eax
  800730:	78 47                	js     800779 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800739:	75 21                	jne    80075c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073b:	a1 04 40 80 00       	mov    0x804004,%eax
  800740:	8b 40 48             	mov    0x48(%eax),%eax
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	53                   	push   %ebx
  800747:	50                   	push   %eax
  800748:	68 95 1e 80 00       	push   $0x801e95
  80074d:	e8 db 09 00 00       	call   80112d <cprintf>
		return -E_INVAL;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075a:	eb 26                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075f:	8b 52 0c             	mov    0xc(%edx),%edx
  800762:	85 d2                	test   %edx,%edx
  800764:	74 17                	je     80077d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	50                   	push   %eax
  800770:	ff d2                	call   *%edx
  800772:	89 c2                	mov    %eax,%edx
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb 09                	jmp    800782 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800779:	89 c2                	mov    %eax,%edx
  80077b:	eb 05                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800782:	89 d0                	mov    %edx,%eax
  800784:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <seek>:

int
seek(int fdnum, off_t offset)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	ff 75 08             	pushl  0x8(%ebp)
  800796:	e8 22 fc ff ff       	call   8003bd <fd_lookup>
  80079b:	83 c4 08             	add    $0x8,%esp
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	78 0e                	js     8007b0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	83 ec 14             	sub    $0x14,%esp
  8007b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	53                   	push   %ebx
  8007c1:	e8 f7 fb ff ff       	call   8003bd <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	89 c2                	mov    %eax,%edx
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 65                	js     800834 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	ff 30                	pushl  (%eax)
  8007db:	e8 33 fc ff ff       	call   800413 <dev_lookup>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 44                	js     80082b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ee:	75 21                	jne    800811 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f5:	8b 40 48             	mov    0x48(%eax),%eax
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	53                   	push   %ebx
  8007fc:	50                   	push   %eax
  8007fd:	68 58 1e 80 00       	push   $0x801e58
  800802:	e8 26 09 00 00       	call   80112d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080f:	eb 23                	jmp    800834 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800811:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800814:	8b 52 18             	mov    0x18(%edx),%edx
  800817:	85 d2                	test   %edx,%edx
  800819:	74 14                	je     80082f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	ff 75 0c             	pushl  0xc(%ebp)
  800821:	50                   	push   %eax
  800822:	ff d2                	call   *%edx
  800824:	89 c2                	mov    %eax,%edx
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	eb 09                	jmp    800834 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082b:	89 c2                	mov    %eax,%edx
  80082d:	eb 05                	jmp    800834 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800834:	89 d0                	mov    %edx,%eax
  800836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 14             	sub    $0x14,%esp
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800845:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	ff 75 08             	pushl  0x8(%ebp)
  80084c:	e8 6c fb ff ff       	call   8003bd <fd_lookup>
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	89 c2                	mov    %eax,%edx
  800856:	85 c0                	test   %eax,%eax
  800858:	78 58                	js     8008b2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800860:	50                   	push   %eax
  800861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800864:	ff 30                	pushl  (%eax)
  800866:	e8 a8 fb ff ff       	call   800413 <dev_lookup>
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	85 c0                	test   %eax,%eax
  800870:	78 37                	js     8008a9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800875:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800879:	74 32                	je     8008ad <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800885:	00 00 00 
	stat->st_isdir = 0;
  800888:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088f:	00 00 00 
	stat->st_dev = dev;
  800892:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	53                   	push   %ebx
  80089c:	ff 75 f0             	pushl  -0x10(%ebp)
  80089f:	ff 50 14             	call   *0x14(%eax)
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	eb 09                	jmp    8008b2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a9:	89 c2                	mov    %eax,%edx
  8008ab:	eb 05                	jmp    8008b2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b2:	89 d0                	mov    %edx,%eax
  8008b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	6a 00                	push   $0x0
  8008c3:	ff 75 08             	pushl  0x8(%ebp)
  8008c6:	e8 09 02 00 00       	call   800ad4 <open>
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	85 db                	test   %ebx,%ebx
  8008d2:	78 1b                	js     8008ef <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	53                   	push   %ebx
  8008db:	e8 5b ff ff ff       	call   80083b <fstat>
  8008e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e2:	89 1c 24             	mov    %ebx,(%esp)
  8008e5:	e8 fd fb ff ff       	call   8004e7 <close>
	return r;
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	89 f0                	mov    %esi,%eax
}
  8008ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	89 c6                	mov    %eax,%esi
  8008fd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008ff:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800906:	75 12                	jne    80091a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800908:	83 ec 0c             	sub    $0xc,%esp
  80090b:	6a 01                	push   $0x1
  80090d:	e8 ac 11 00 00       	call   801abe <ipc_find_env>
  800912:	a3 00 40 80 00       	mov    %eax,0x804000
  800917:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091a:	6a 07                	push   $0x7
  80091c:	68 00 50 80 00       	push   $0x805000
  800921:	56                   	push   %esi
  800922:	ff 35 00 40 80 00    	pushl  0x804000
  800928:	e8 3d 11 00 00       	call   801a6a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80092d:	83 c4 0c             	add    $0xc,%esp
  800930:	6a 00                	push   $0x0
  800932:	53                   	push   %ebx
  800933:	6a 00                	push   $0x0
  800935:	e8 c7 10 00 00       	call   801a01 <ipc_recv>
}
  80093a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 40 0c             	mov    0xc(%eax),%eax
  80094d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	b8 02 00 00 00       	mov    $0x2,%eax
  800964:	e8 8d ff ff ff       	call   8008f6 <fsipc>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 40 0c             	mov    0xc(%eax),%eax
  800977:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
  800981:	b8 06 00 00 00       	mov    $0x6,%eax
  800986:	e8 6b ff ff ff       	call   8008f6 <fsipc>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	83 ec 04             	sub    $0x4,%esp
  800994:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 40 0c             	mov    0xc(%eax),%eax
  80099d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ac:	e8 45 ff ff ff       	call   8008f6 <fsipc>
  8009b1:	89 c2                	mov    %eax,%edx
  8009b3:	85 d2                	test   %edx,%edx
  8009b5:	78 2c                	js     8009e3 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b7:	83 ec 08             	sub    $0x8,%esp
  8009ba:	68 00 50 80 00       	push   $0x805000
  8009bf:	53                   	push   %ebx
  8009c0:	e8 ef 0c 00 00       	call   8016b4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c5:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ca:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d0:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009db:	83 c4 10             	add    $0x10,%esp
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e6:	c9                   	leave  
  8009e7:	c3                   	ret    

008009e8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	57                   	push   %edi
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	83 ec 0c             	sub    $0xc,%esp
  8009f1:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fa:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8009ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a02:	eb 3d                	jmp    800a41 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800a04:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800a0a:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800a0f:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800a12:	83 ec 04             	sub    $0x4,%esp
  800a15:	57                   	push   %edi
  800a16:	53                   	push   %ebx
  800a17:	68 08 50 80 00       	push   $0x805008
  800a1c:	e8 25 0e 00 00       	call   801846 <memmove>
                fsipcbuf.write.req_n = tmp; 
  800a21:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a27:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a31:	e8 c0 fe ff ff       	call   8008f6 <fsipc>
  800a36:	83 c4 10             	add    $0x10,%esp
  800a39:	85 c0                	test   %eax,%eax
  800a3b:	78 0d                	js     800a4a <devfile_write+0x62>
		        return r;
                n -= tmp;
  800a3d:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800a3f:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a41:	85 f6                	test   %esi,%esi
  800a43:	75 bf                	jne    800a04 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800a45:	89 d8                	mov    %ebx,%eax
  800a47:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800a4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a60:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a65:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a70:	b8 03 00 00 00       	mov    $0x3,%eax
  800a75:	e8 7c fe ff ff       	call   8008f6 <fsipc>
  800a7a:	89 c3                	mov    %eax,%ebx
  800a7c:	85 c0                	test   %eax,%eax
  800a7e:	78 4b                	js     800acb <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a80:	39 c6                	cmp    %eax,%esi
  800a82:	73 16                	jae    800a9a <devfile_read+0x48>
  800a84:	68 c4 1e 80 00       	push   $0x801ec4
  800a89:	68 cb 1e 80 00       	push   $0x801ecb
  800a8e:	6a 7c                	push   $0x7c
  800a90:	68 e0 1e 80 00       	push   $0x801ee0
  800a95:	e8 ba 05 00 00       	call   801054 <_panic>
	assert(r <= PGSIZE);
  800a9a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a9f:	7e 16                	jle    800ab7 <devfile_read+0x65>
  800aa1:	68 eb 1e 80 00       	push   $0x801eeb
  800aa6:	68 cb 1e 80 00       	push   $0x801ecb
  800aab:	6a 7d                	push   $0x7d
  800aad:	68 e0 1e 80 00       	push   $0x801ee0
  800ab2:	e8 9d 05 00 00       	call   801054 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab7:	83 ec 04             	sub    $0x4,%esp
  800aba:	50                   	push   %eax
  800abb:	68 00 50 80 00       	push   $0x805000
  800ac0:	ff 75 0c             	pushl  0xc(%ebp)
  800ac3:	e8 7e 0d 00 00       	call   801846 <memmove>
	return r;
  800ac8:	83 c4 10             	add    $0x10,%esp
}
  800acb:	89 d8                	mov    %ebx,%eax
  800acd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	53                   	push   %ebx
  800ad8:	83 ec 20             	sub    $0x20,%esp
  800adb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ade:	53                   	push   %ebx
  800adf:	e8 97 0b 00 00       	call   80167b <strlen>
  800ae4:	83 c4 10             	add    $0x10,%esp
  800ae7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aec:	7f 67                	jg     800b55 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aee:	83 ec 0c             	sub    $0xc,%esp
  800af1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af4:	50                   	push   %eax
  800af5:	e8 74 f8 ff ff       	call   80036e <fd_alloc>
  800afa:	83 c4 10             	add    $0x10,%esp
		return r;
  800afd:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aff:	85 c0                	test   %eax,%eax
  800b01:	78 57                	js     800b5a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b03:	83 ec 08             	sub    $0x8,%esp
  800b06:	53                   	push   %ebx
  800b07:	68 00 50 80 00       	push   $0x805000
  800b0c:	e8 a3 0b 00 00       	call   8016b4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b14:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b21:	e8 d0 fd ff ff       	call   8008f6 <fsipc>
  800b26:	89 c3                	mov    %eax,%ebx
  800b28:	83 c4 10             	add    $0x10,%esp
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	79 14                	jns    800b43 <open+0x6f>
		fd_close(fd, 0);
  800b2f:	83 ec 08             	sub    $0x8,%esp
  800b32:	6a 00                	push   $0x0
  800b34:	ff 75 f4             	pushl  -0xc(%ebp)
  800b37:	e8 2a f9 ff ff       	call   800466 <fd_close>
		return r;
  800b3c:	83 c4 10             	add    $0x10,%esp
  800b3f:	89 da                	mov    %ebx,%edx
  800b41:	eb 17                	jmp    800b5a <open+0x86>
	}

	return fd2num(fd);
  800b43:	83 ec 0c             	sub    $0xc,%esp
  800b46:	ff 75 f4             	pushl  -0xc(%ebp)
  800b49:	e8 f9 f7 ff ff       	call   800347 <fd2num>
  800b4e:	89 c2                	mov    %eax,%edx
  800b50:	83 c4 10             	add    $0x10,%esp
  800b53:	eb 05                	jmp    800b5a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b55:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b5a:	89 d0                	mov    %edx,%eax
  800b5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b71:	e8 80 fd ff ff       	call   8008f6 <fsipc>
}
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	ff 75 08             	pushl  0x8(%ebp)
  800b86:	e8 cc f7 ff ff       	call   800357 <fd2data>
  800b8b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b8d:	83 c4 08             	add    $0x8,%esp
  800b90:	68 f7 1e 80 00       	push   $0x801ef7
  800b95:	53                   	push   %ebx
  800b96:	e8 19 0b 00 00       	call   8016b4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b9b:	8b 56 04             	mov    0x4(%esi),%edx
  800b9e:	89 d0                	mov    %edx,%eax
  800ba0:	2b 06                	sub    (%esi),%eax
  800ba2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800baf:	00 00 00 
	stat->st_dev = &devpipe;
  800bb2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb9:	30 80 00 
	return 0;
}
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd2:	53                   	push   %ebx
  800bd3:	6a 00                	push   $0x0
  800bd5:	e8 01 f6 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bda:	89 1c 24             	mov    %ebx,(%esp)
  800bdd:	e8 75 f7 ff ff       	call   800357 <fd2data>
  800be2:	83 c4 08             	add    $0x8,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 00                	push   $0x0
  800be8:	e8 ee f5 ff ff       	call   8001db <sys_page_unmap>
}
  800bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    

00800bf2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 1c             	sub    $0x1c,%esp
  800bfb:	89 c6                	mov    %eax,%esi
  800bfd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c00:	a1 04 40 80 00       	mov    0x804004,%eax
  800c05:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c08:	83 ec 0c             	sub    $0xc,%esp
  800c0b:	56                   	push   %esi
  800c0c:	e8 e5 0e 00 00       	call   801af6 <pageref>
  800c11:	89 c7                	mov    %eax,%edi
  800c13:	83 c4 04             	add    $0x4,%esp
  800c16:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c19:	e8 d8 0e 00 00       	call   801af6 <pageref>
  800c1e:	83 c4 10             	add    $0x10,%esp
  800c21:	39 c7                	cmp    %eax,%edi
  800c23:	0f 94 c2             	sete   %dl
  800c26:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800c29:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800c2f:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800c32:	39 fb                	cmp    %edi,%ebx
  800c34:	74 19                	je     800c4f <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  800c36:	84 d2                	test   %dl,%dl
  800c38:	74 c6                	je     800c00 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c3a:	8b 51 58             	mov    0x58(%ecx),%edx
  800c3d:	50                   	push   %eax
  800c3e:	52                   	push   %edx
  800c3f:	53                   	push   %ebx
  800c40:	68 fe 1e 80 00       	push   $0x801efe
  800c45:	e8 e3 04 00 00       	call   80112d <cprintf>
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	eb b1                	jmp    800c00 <_pipeisclosed+0xe>
	}
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 28             	sub    $0x28,%esp
  800c60:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c63:	56                   	push   %esi
  800c64:	e8 ee f6 ff ff       	call   800357 <fd2data>
  800c69:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c6b:	83 c4 10             	add    $0x10,%esp
  800c6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c73:	eb 4b                	jmp    800cc0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c75:	89 da                	mov    %ebx,%edx
  800c77:	89 f0                	mov    %esi,%eax
  800c79:	e8 74 ff ff ff       	call   800bf2 <_pipeisclosed>
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	75 48                	jne    800cca <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c82:	e8 b0 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c87:	8b 43 04             	mov    0x4(%ebx),%eax
  800c8a:	8b 0b                	mov    (%ebx),%ecx
  800c8c:	8d 51 20             	lea    0x20(%ecx),%edx
  800c8f:	39 d0                	cmp    %edx,%eax
  800c91:	73 e2                	jae    800c75 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c9a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c9d:	89 c2                	mov    %eax,%edx
  800c9f:	c1 fa 1f             	sar    $0x1f,%edx
  800ca2:	89 d1                	mov    %edx,%ecx
  800ca4:	c1 e9 1b             	shr    $0x1b,%ecx
  800ca7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800caa:	83 e2 1f             	and    $0x1f,%edx
  800cad:	29 ca                	sub    %ecx,%edx
  800caf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cb7:	83 c0 01             	add    $0x1,%eax
  800cba:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cbd:	83 c7 01             	add    $0x1,%edi
  800cc0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cc3:	75 c2                	jne    800c87 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cc5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc8:	eb 05                	jmp    800ccf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cca:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 18             	sub    $0x18,%esp
  800ce0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ce3:	57                   	push   %edi
  800ce4:	e8 6e f6 ff ff       	call   800357 <fd2data>
  800ce9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ceb:	83 c4 10             	add    $0x10,%esp
  800cee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf3:	eb 3d                	jmp    800d32 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cf5:	85 db                	test   %ebx,%ebx
  800cf7:	74 04                	je     800cfd <devpipe_read+0x26>
				return i;
  800cf9:	89 d8                	mov    %ebx,%eax
  800cfb:	eb 44                	jmp    800d41 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cfd:	89 f2                	mov    %esi,%edx
  800cff:	89 f8                	mov    %edi,%eax
  800d01:	e8 ec fe ff ff       	call   800bf2 <_pipeisclosed>
  800d06:	85 c0                	test   %eax,%eax
  800d08:	75 32                	jne    800d3c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d0a:	e8 28 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d0f:	8b 06                	mov    (%esi),%eax
  800d11:	3b 46 04             	cmp    0x4(%esi),%eax
  800d14:	74 df                	je     800cf5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d16:	99                   	cltd   
  800d17:	c1 ea 1b             	shr    $0x1b,%edx
  800d1a:	01 d0                	add    %edx,%eax
  800d1c:	83 e0 1f             	and    $0x1f,%eax
  800d1f:	29 d0                	sub    %edx,%eax
  800d21:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d2c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d2f:	83 c3 01             	add    $0x1,%ebx
  800d32:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d35:	75 d8                	jne    800d0f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d37:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3a:	eb 05                	jmp    800d41 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d3c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d54:	50                   	push   %eax
  800d55:	e8 14 f6 ff ff       	call   80036e <fd_alloc>
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	89 c2                	mov    %eax,%edx
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	0f 88 2c 01 00 00    	js     800e93 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d67:	83 ec 04             	sub    $0x4,%esp
  800d6a:	68 07 04 00 00       	push   $0x407
  800d6f:	ff 75 f4             	pushl  -0xc(%ebp)
  800d72:	6a 00                	push   $0x0
  800d74:	e8 dd f3 ff ff       	call   800156 <sys_page_alloc>
  800d79:	83 c4 10             	add    $0x10,%esp
  800d7c:	89 c2                	mov    %eax,%edx
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	0f 88 0d 01 00 00    	js     800e93 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d8c:	50                   	push   %eax
  800d8d:	e8 dc f5 ff ff       	call   80036e <fd_alloc>
  800d92:	89 c3                	mov    %eax,%ebx
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	0f 88 e2 00 00 00    	js     800e81 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	68 07 04 00 00       	push   $0x407
  800da7:	ff 75 f0             	pushl  -0x10(%ebp)
  800daa:	6a 00                	push   $0x0
  800dac:	e8 a5 f3 ff ff       	call   800156 <sys_page_alloc>
  800db1:	89 c3                	mov    %eax,%ebx
  800db3:	83 c4 10             	add    $0x10,%esp
  800db6:	85 c0                	test   %eax,%eax
  800db8:	0f 88 c3 00 00 00    	js     800e81 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc4:	e8 8e f5 ff ff       	call   800357 <fd2data>
  800dc9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcb:	83 c4 0c             	add    $0xc,%esp
  800dce:	68 07 04 00 00       	push   $0x407
  800dd3:	50                   	push   %eax
  800dd4:	6a 00                	push   $0x0
  800dd6:	e8 7b f3 ff ff       	call   800156 <sys_page_alloc>
  800ddb:	89 c3                	mov    %eax,%ebx
  800ddd:	83 c4 10             	add    $0x10,%esp
  800de0:	85 c0                	test   %eax,%eax
  800de2:	0f 88 89 00 00 00    	js     800e71 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	ff 75 f0             	pushl  -0x10(%ebp)
  800dee:	e8 64 f5 ff ff       	call   800357 <fd2data>
  800df3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dfa:	50                   	push   %eax
  800dfb:	6a 00                	push   $0x0
  800dfd:	56                   	push   %esi
  800dfe:	6a 00                	push   $0x0
  800e00:	e8 94 f3 ff ff       	call   800199 <sys_page_map>
  800e05:	89 c3                	mov    %eax,%ebx
  800e07:	83 c4 20             	add    $0x20,%esp
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	78 55                	js     800e63 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e0e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e17:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e23:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e31:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e38:	83 ec 0c             	sub    $0xc,%esp
  800e3b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3e:	e8 04 f5 ff ff       	call   800347 <fd2num>
  800e43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e46:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e48:	83 c4 04             	add    $0x4,%esp
  800e4b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4e:	e8 f4 f4 ff ff       	call   800347 <fd2num>
  800e53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e56:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e59:	83 c4 10             	add    $0x10,%esp
  800e5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e61:	eb 30                	jmp    800e93 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e63:	83 ec 08             	sub    $0x8,%esp
  800e66:	56                   	push   %esi
  800e67:	6a 00                	push   $0x0
  800e69:	e8 6d f3 ff ff       	call   8001db <sys_page_unmap>
  800e6e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e71:	83 ec 08             	sub    $0x8,%esp
  800e74:	ff 75 f0             	pushl  -0x10(%ebp)
  800e77:	6a 00                	push   $0x0
  800e79:	e8 5d f3 ff ff       	call   8001db <sys_page_unmap>
  800e7e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e81:	83 ec 08             	sub    $0x8,%esp
  800e84:	ff 75 f4             	pushl  -0xc(%ebp)
  800e87:	6a 00                	push   $0x0
  800e89:	e8 4d f3 ff ff       	call   8001db <sys_page_unmap>
  800e8e:	83 c4 10             	add    $0x10,%esp
  800e91:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e93:	89 d0                	mov    %edx,%eax
  800e95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea5:	50                   	push   %eax
  800ea6:	ff 75 08             	pushl  0x8(%ebp)
  800ea9:	e8 0f f5 ff ff       	call   8003bd <fd_lookup>
  800eae:	89 c2                	mov    %eax,%edx
  800eb0:	83 c4 10             	add    $0x10,%esp
  800eb3:	85 d2                	test   %edx,%edx
  800eb5:	78 18                	js     800ecf <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eb7:	83 ec 0c             	sub    $0xc,%esp
  800eba:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebd:	e8 95 f4 ff ff       	call   800357 <fd2data>
	return _pipeisclosed(fd, p);
  800ec2:	89 c2                	mov    %eax,%edx
  800ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec7:	e8 26 fd ff ff       	call   800bf2 <_pipeisclosed>
  800ecc:	83 c4 10             	add    $0x10,%esp
}
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ed4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee1:	68 16 1f 80 00       	push   $0x801f16
  800ee6:	ff 75 0c             	pushl  0xc(%ebp)
  800ee9:	e8 c6 07 00 00       	call   8016b4 <strcpy>
	return 0;
}
  800eee:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    

00800ef5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	57                   	push   %edi
  800ef9:	56                   	push   %esi
  800efa:	53                   	push   %ebx
  800efb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f01:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f06:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f0c:	eb 2d                	jmp    800f3b <devcons_write+0x46>
		m = n - tot;
  800f0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f11:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f13:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f16:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f1b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f1e:	83 ec 04             	sub    $0x4,%esp
  800f21:	53                   	push   %ebx
  800f22:	03 45 0c             	add    0xc(%ebp),%eax
  800f25:	50                   	push   %eax
  800f26:	57                   	push   %edi
  800f27:	e8 1a 09 00 00       	call   801846 <memmove>
		sys_cputs(buf, m);
  800f2c:	83 c4 08             	add    $0x8,%esp
  800f2f:	53                   	push   %ebx
  800f30:	57                   	push   %edi
  800f31:	e8 64 f1 ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f36:	01 de                	add    %ebx,%esi
  800f38:	83 c4 10             	add    $0x10,%esp
  800f3b:	89 f0                	mov    %esi,%eax
  800f3d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f40:	72 cc                	jb     800f0e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f50:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f55:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f59:	75 07                	jne    800f62 <devcons_read+0x18>
  800f5b:	eb 28                	jmp    800f85 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f5d:	e8 d5 f1 ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f62:	e8 51 f1 ff ff       	call   8000b8 <sys_cgetc>
  800f67:	85 c0                	test   %eax,%eax
  800f69:	74 f2                	je     800f5d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	78 16                	js     800f85 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f6f:	83 f8 04             	cmp    $0x4,%eax
  800f72:	74 0c                	je     800f80 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f77:	88 02                	mov    %al,(%edx)
	return 1;
  800f79:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7e:	eb 05                	jmp    800f85 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f80:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f90:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f93:	6a 01                	push   $0x1
  800f95:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f98:	50                   	push   %eax
  800f99:	e8 fc f0 ff ff       	call   80009a <sys_cputs>
  800f9e:	83 c4 10             	add    $0x10,%esp
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <getchar>:

int
getchar(void)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fa9:	6a 01                	push   $0x1
  800fab:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fae:	50                   	push   %eax
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 71 f6 ff ff       	call   800627 <read>
	if (r < 0)
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	78 0f                	js     800fcc <getchar+0x29>
		return r;
	if (r < 1)
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	7e 06                	jle    800fc7 <getchar+0x24>
		return -E_EOF;
	return c;
  800fc1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fc5:	eb 05                	jmp    800fcc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fc7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	ff 75 08             	pushl  0x8(%ebp)
  800fdb:	e8 dd f3 ff ff       	call   8003bd <fd_lookup>
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	78 11                	js     800ff8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fea:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff0:	39 10                	cmp    %edx,(%eax)
  800ff2:	0f 94 c0             	sete   %al
  800ff5:	0f b6 c0             	movzbl %al,%eax
}
  800ff8:	c9                   	leave  
  800ff9:	c3                   	ret    

00800ffa <opencons>:

int
opencons(void)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801000:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801003:	50                   	push   %eax
  801004:	e8 65 f3 ff ff       	call   80036e <fd_alloc>
  801009:	83 c4 10             	add    $0x10,%esp
		return r;
  80100c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80100e:	85 c0                	test   %eax,%eax
  801010:	78 3e                	js     801050 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801012:	83 ec 04             	sub    $0x4,%esp
  801015:	68 07 04 00 00       	push   $0x407
  80101a:	ff 75 f4             	pushl  -0xc(%ebp)
  80101d:	6a 00                	push   $0x0
  80101f:	e8 32 f1 ff ff       	call   800156 <sys_page_alloc>
  801024:	83 c4 10             	add    $0x10,%esp
		return r;
  801027:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801029:	85 c0                	test   %eax,%eax
  80102b:	78 23                	js     801050 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80102d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801033:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801036:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801042:	83 ec 0c             	sub    $0xc,%esp
  801045:	50                   	push   %eax
  801046:	e8 fc f2 ff ff       	call   800347 <fd2num>
  80104b:	89 c2                	mov    %eax,%edx
  80104d:	83 c4 10             	add    $0x10,%esp
}
  801050:	89 d0                	mov    %edx,%eax
  801052:	c9                   	leave  
  801053:	c3                   	ret    

00801054 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801059:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80105c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801062:	e8 b1 f0 ff ff       	call   800118 <sys_getenvid>
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	ff 75 0c             	pushl  0xc(%ebp)
  80106d:	ff 75 08             	pushl  0x8(%ebp)
  801070:	56                   	push   %esi
  801071:	50                   	push   %eax
  801072:	68 24 1f 80 00       	push   $0x801f24
  801077:	e8 b1 00 00 00       	call   80112d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80107c:	83 c4 18             	add    $0x18,%esp
  80107f:	53                   	push   %ebx
  801080:	ff 75 10             	pushl  0x10(%ebp)
  801083:	e8 54 00 00 00       	call   8010dc <vcprintf>
	cprintf("\n");
  801088:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  80108f:	e8 99 00 00 00       	call   80112d <cprintf>
  801094:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801097:	cc                   	int3   
  801098:	eb fd                	jmp    801097 <_panic+0x43>

0080109a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	53                   	push   %ebx
  80109e:	83 ec 04             	sub    $0x4,%esp
  8010a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010a4:	8b 13                	mov    (%ebx),%edx
  8010a6:	8d 42 01             	lea    0x1(%edx),%eax
  8010a9:	89 03                	mov    %eax,(%ebx)
  8010ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010b7:	75 1a                	jne    8010d3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010b9:	83 ec 08             	sub    $0x8,%esp
  8010bc:	68 ff 00 00 00       	push   $0xff
  8010c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8010c4:	50                   	push   %eax
  8010c5:	e8 d0 ef ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8010ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010d0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010d3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010e5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ec:	00 00 00 
	b.cnt = 0;
  8010ef:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010f6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010f9:	ff 75 0c             	pushl  0xc(%ebp)
  8010fc:	ff 75 08             	pushl  0x8(%ebp)
  8010ff:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801105:	50                   	push   %eax
  801106:	68 9a 10 80 00       	push   $0x80109a
  80110b:	e8 4f 01 00 00       	call   80125f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801110:	83 c4 08             	add    $0x8,%esp
  801113:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801119:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80111f:	50                   	push   %eax
  801120:	e8 75 ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  801125:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80112b:	c9                   	leave  
  80112c:	c3                   	ret    

0080112d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801133:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801136:	50                   	push   %eax
  801137:	ff 75 08             	pushl  0x8(%ebp)
  80113a:	e8 9d ff ff ff       	call   8010dc <vcprintf>
	va_end(ap);

	return cnt;
}
  80113f:	c9                   	leave  
  801140:	c3                   	ret    

00801141 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	57                   	push   %edi
  801145:	56                   	push   %esi
  801146:	53                   	push   %ebx
  801147:	83 ec 1c             	sub    $0x1c,%esp
  80114a:	89 c7                	mov    %eax,%edi
  80114c:	89 d6                	mov    %edx,%esi
  80114e:	8b 45 08             	mov    0x8(%ebp),%eax
  801151:	8b 55 0c             	mov    0xc(%ebp),%edx
  801154:	89 d1                	mov    %edx,%ecx
  801156:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801159:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80115c:	8b 45 10             	mov    0x10(%ebp),%eax
  80115f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801162:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801165:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80116c:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80116f:	72 05                	jb     801176 <printnum+0x35>
  801171:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801174:	77 3e                	ja     8011b4 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	ff 75 18             	pushl  0x18(%ebp)
  80117c:	83 eb 01             	sub    $0x1,%ebx
  80117f:	53                   	push   %ebx
  801180:	50                   	push   %eax
  801181:	83 ec 08             	sub    $0x8,%esp
  801184:	ff 75 e4             	pushl  -0x1c(%ebp)
  801187:	ff 75 e0             	pushl  -0x20(%ebp)
  80118a:	ff 75 dc             	pushl  -0x24(%ebp)
  80118d:	ff 75 d8             	pushl  -0x28(%ebp)
  801190:	e8 ab 09 00 00       	call   801b40 <__udivdi3>
  801195:	83 c4 18             	add    $0x18,%esp
  801198:	52                   	push   %edx
  801199:	50                   	push   %eax
  80119a:	89 f2                	mov    %esi,%edx
  80119c:	89 f8                	mov    %edi,%eax
  80119e:	e8 9e ff ff ff       	call   801141 <printnum>
  8011a3:	83 c4 20             	add    $0x20,%esp
  8011a6:	eb 13                	jmp    8011bb <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011a8:	83 ec 08             	sub    $0x8,%esp
  8011ab:	56                   	push   %esi
  8011ac:	ff 75 18             	pushl  0x18(%ebp)
  8011af:	ff d7                	call   *%edi
  8011b1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011b4:	83 eb 01             	sub    $0x1,%ebx
  8011b7:	85 db                	test   %ebx,%ebx
  8011b9:	7f ed                	jg     8011a8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011bb:	83 ec 08             	sub    $0x8,%esp
  8011be:	56                   	push   %esi
  8011bf:	83 ec 04             	sub    $0x4,%esp
  8011c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8011cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ce:	e8 9d 0a 00 00       	call   801c70 <__umoddi3>
  8011d3:	83 c4 14             	add    $0x14,%esp
  8011d6:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  8011dd:	50                   	push   %eax
  8011de:	ff d7                	call   *%edi
  8011e0:	83 c4 10             	add    $0x10,%esp
}
  8011e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011ee:	83 fa 01             	cmp    $0x1,%edx
  8011f1:	7e 0e                	jle    801201 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011f3:	8b 10                	mov    (%eax),%edx
  8011f5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011f8:	89 08                	mov    %ecx,(%eax)
  8011fa:	8b 02                	mov    (%edx),%eax
  8011fc:	8b 52 04             	mov    0x4(%edx),%edx
  8011ff:	eb 22                	jmp    801223 <getuint+0x38>
	else if (lflag)
  801201:	85 d2                	test   %edx,%edx
  801203:	74 10                	je     801215 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801205:	8b 10                	mov    (%eax),%edx
  801207:	8d 4a 04             	lea    0x4(%edx),%ecx
  80120a:	89 08                	mov    %ecx,(%eax)
  80120c:	8b 02                	mov    (%edx),%eax
  80120e:	ba 00 00 00 00       	mov    $0x0,%edx
  801213:	eb 0e                	jmp    801223 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801215:	8b 10                	mov    (%eax),%edx
  801217:	8d 4a 04             	lea    0x4(%edx),%ecx
  80121a:	89 08                	mov    %ecx,(%eax)
  80121c:	8b 02                	mov    (%edx),%eax
  80121e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80122b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80122f:	8b 10                	mov    (%eax),%edx
  801231:	3b 50 04             	cmp    0x4(%eax),%edx
  801234:	73 0a                	jae    801240 <sprintputch+0x1b>
		*b->buf++ = ch;
  801236:	8d 4a 01             	lea    0x1(%edx),%ecx
  801239:	89 08                	mov    %ecx,(%eax)
  80123b:	8b 45 08             	mov    0x8(%ebp),%eax
  80123e:	88 02                	mov    %al,(%edx)
}
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801248:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80124b:	50                   	push   %eax
  80124c:	ff 75 10             	pushl  0x10(%ebp)
  80124f:	ff 75 0c             	pushl  0xc(%ebp)
  801252:	ff 75 08             	pushl  0x8(%ebp)
  801255:	e8 05 00 00 00       	call   80125f <vprintfmt>
	va_end(ap);
  80125a:	83 c4 10             	add    $0x10,%esp
}
  80125d:	c9                   	leave  
  80125e:	c3                   	ret    

0080125f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	57                   	push   %edi
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	83 ec 2c             	sub    $0x2c,%esp
  801268:	8b 75 08             	mov    0x8(%ebp),%esi
  80126b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80126e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801271:	eb 12                	jmp    801285 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801273:	85 c0                	test   %eax,%eax
  801275:	0f 84 90 03 00 00    	je     80160b <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	53                   	push   %ebx
  80127f:	50                   	push   %eax
  801280:	ff d6                	call   *%esi
  801282:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801285:	83 c7 01             	add    $0x1,%edi
  801288:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80128c:	83 f8 25             	cmp    $0x25,%eax
  80128f:	75 e2                	jne    801273 <vprintfmt+0x14>
  801291:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801295:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80129c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012a3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8012af:	eb 07                	jmp    8012b8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012b4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b8:	8d 47 01             	lea    0x1(%edi),%eax
  8012bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012be:	0f b6 07             	movzbl (%edi),%eax
  8012c1:	0f b6 c8             	movzbl %al,%ecx
  8012c4:	83 e8 23             	sub    $0x23,%eax
  8012c7:	3c 55                	cmp    $0x55,%al
  8012c9:	0f 87 21 03 00 00    	ja     8015f0 <vprintfmt+0x391>
  8012cf:	0f b6 c0             	movzbl %al,%eax
  8012d2:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8012d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012dc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012e0:	eb d6                	jmp    8012b8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012ed:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012f0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012f4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012f7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012fa:	83 fa 09             	cmp    $0x9,%edx
  8012fd:	77 39                	ja     801338 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012ff:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801302:	eb e9                	jmp    8012ed <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801304:	8b 45 14             	mov    0x14(%ebp),%eax
  801307:	8d 48 04             	lea    0x4(%eax),%ecx
  80130a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80130d:	8b 00                	mov    (%eax),%eax
  80130f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801312:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801315:	eb 27                	jmp    80133e <vprintfmt+0xdf>
  801317:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80131a:	85 c0                	test   %eax,%eax
  80131c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801321:	0f 49 c8             	cmovns %eax,%ecx
  801324:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80132a:	eb 8c                	jmp    8012b8 <vprintfmt+0x59>
  80132c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80132f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801336:	eb 80                	jmp    8012b8 <vprintfmt+0x59>
  801338:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80133b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80133e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801342:	0f 89 70 ff ff ff    	jns    8012b8 <vprintfmt+0x59>
				width = precision, precision = -1;
  801348:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80134b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80134e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801355:	e9 5e ff ff ff       	jmp    8012b8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80135a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801360:	e9 53 ff ff ff       	jmp    8012b8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801365:	8b 45 14             	mov    0x14(%ebp),%eax
  801368:	8d 50 04             	lea    0x4(%eax),%edx
  80136b:	89 55 14             	mov    %edx,0x14(%ebp)
  80136e:	83 ec 08             	sub    $0x8,%esp
  801371:	53                   	push   %ebx
  801372:	ff 30                	pushl  (%eax)
  801374:	ff d6                	call   *%esi
			break;
  801376:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80137c:	e9 04 ff ff ff       	jmp    801285 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801381:	8b 45 14             	mov    0x14(%ebp),%eax
  801384:	8d 50 04             	lea    0x4(%eax),%edx
  801387:	89 55 14             	mov    %edx,0x14(%ebp)
  80138a:	8b 00                	mov    (%eax),%eax
  80138c:	99                   	cltd   
  80138d:	31 d0                	xor    %edx,%eax
  80138f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801391:	83 f8 0f             	cmp    $0xf,%eax
  801394:	7f 0b                	jg     8013a1 <vprintfmt+0x142>
  801396:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  80139d:	85 d2                	test   %edx,%edx
  80139f:	75 18                	jne    8013b9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013a1:	50                   	push   %eax
  8013a2:	68 5f 1f 80 00       	push   $0x801f5f
  8013a7:	53                   	push   %ebx
  8013a8:	56                   	push   %esi
  8013a9:	e8 94 fe ff ff       	call   801242 <printfmt>
  8013ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013b4:	e9 cc fe ff ff       	jmp    801285 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013b9:	52                   	push   %edx
  8013ba:	68 dd 1e 80 00       	push   $0x801edd
  8013bf:	53                   	push   %ebx
  8013c0:	56                   	push   %esi
  8013c1:	e8 7c fe ff ff       	call   801242 <printfmt>
  8013c6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013cc:	e9 b4 fe ff ff       	jmp    801285 <vprintfmt+0x26>
  8013d1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013d7:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013da:	8b 45 14             	mov    0x14(%ebp),%eax
  8013dd:	8d 50 04             	lea    0x4(%eax),%edx
  8013e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013e5:	85 ff                	test   %edi,%edi
  8013e7:	ba 58 1f 80 00       	mov    $0x801f58,%edx
  8013ec:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8013ef:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013f3:	0f 84 92 00 00 00    	je     80148b <vprintfmt+0x22c>
  8013f9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8013fd:	0f 8e 96 00 00 00    	jle    801499 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	51                   	push   %ecx
  801407:	57                   	push   %edi
  801408:	e8 86 02 00 00       	call   801693 <strnlen>
  80140d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801410:	29 c1                	sub    %eax,%ecx
  801412:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801415:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801418:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80141c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80141f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801422:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801424:	eb 0f                	jmp    801435 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	53                   	push   %ebx
  80142a:	ff 75 e0             	pushl  -0x20(%ebp)
  80142d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80142f:	83 ef 01             	sub    $0x1,%edi
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	85 ff                	test   %edi,%edi
  801437:	7f ed                	jg     801426 <vprintfmt+0x1c7>
  801439:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80143c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80143f:	85 c9                	test   %ecx,%ecx
  801441:	b8 00 00 00 00       	mov    $0x0,%eax
  801446:	0f 49 c1             	cmovns %ecx,%eax
  801449:	29 c1                	sub    %eax,%ecx
  80144b:	89 75 08             	mov    %esi,0x8(%ebp)
  80144e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801451:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801454:	89 cb                	mov    %ecx,%ebx
  801456:	eb 4d                	jmp    8014a5 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801458:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80145c:	74 1b                	je     801479 <vprintfmt+0x21a>
  80145e:	0f be c0             	movsbl %al,%eax
  801461:	83 e8 20             	sub    $0x20,%eax
  801464:	83 f8 5e             	cmp    $0x5e,%eax
  801467:	76 10                	jbe    801479 <vprintfmt+0x21a>
					putch('?', putdat);
  801469:	83 ec 08             	sub    $0x8,%esp
  80146c:	ff 75 0c             	pushl  0xc(%ebp)
  80146f:	6a 3f                	push   $0x3f
  801471:	ff 55 08             	call   *0x8(%ebp)
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	eb 0d                	jmp    801486 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	ff 75 0c             	pushl  0xc(%ebp)
  80147f:	52                   	push   %edx
  801480:	ff 55 08             	call   *0x8(%ebp)
  801483:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801486:	83 eb 01             	sub    $0x1,%ebx
  801489:	eb 1a                	jmp    8014a5 <vprintfmt+0x246>
  80148b:	89 75 08             	mov    %esi,0x8(%ebp)
  80148e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801491:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801494:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801497:	eb 0c                	jmp    8014a5 <vprintfmt+0x246>
  801499:	89 75 08             	mov    %esi,0x8(%ebp)
  80149c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80149f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a5:	83 c7 01             	add    $0x1,%edi
  8014a8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014ac:	0f be d0             	movsbl %al,%edx
  8014af:	85 d2                	test   %edx,%edx
  8014b1:	74 23                	je     8014d6 <vprintfmt+0x277>
  8014b3:	85 f6                	test   %esi,%esi
  8014b5:	78 a1                	js     801458 <vprintfmt+0x1f9>
  8014b7:	83 ee 01             	sub    $0x1,%esi
  8014ba:	79 9c                	jns    801458 <vprintfmt+0x1f9>
  8014bc:	89 df                	mov    %ebx,%edi
  8014be:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c4:	eb 18                	jmp    8014de <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014c6:	83 ec 08             	sub    $0x8,%esp
  8014c9:	53                   	push   %ebx
  8014ca:	6a 20                	push   $0x20
  8014cc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014ce:	83 ef 01             	sub    $0x1,%edi
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	eb 08                	jmp    8014de <vprintfmt+0x27f>
  8014d6:	89 df                	mov    %ebx,%edi
  8014d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8014db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014de:	85 ff                	test   %edi,%edi
  8014e0:	7f e4                	jg     8014c6 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014e5:	e9 9b fd ff ff       	jmp    801285 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014ea:	83 fa 01             	cmp    $0x1,%edx
  8014ed:	7e 16                	jle    801505 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8014ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f2:	8d 50 08             	lea    0x8(%eax),%edx
  8014f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f8:	8b 50 04             	mov    0x4(%eax),%edx
  8014fb:	8b 00                	mov    (%eax),%eax
  8014fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801500:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801503:	eb 32                	jmp    801537 <vprintfmt+0x2d8>
	else if (lflag)
  801505:	85 d2                	test   %edx,%edx
  801507:	74 18                	je     801521 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801509:	8b 45 14             	mov    0x14(%ebp),%eax
  80150c:	8d 50 04             	lea    0x4(%eax),%edx
  80150f:	89 55 14             	mov    %edx,0x14(%ebp)
  801512:	8b 00                	mov    (%eax),%eax
  801514:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801517:	89 c1                	mov    %eax,%ecx
  801519:	c1 f9 1f             	sar    $0x1f,%ecx
  80151c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80151f:	eb 16                	jmp    801537 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801521:	8b 45 14             	mov    0x14(%ebp),%eax
  801524:	8d 50 04             	lea    0x4(%eax),%edx
  801527:	89 55 14             	mov    %edx,0x14(%ebp)
  80152a:	8b 00                	mov    (%eax),%eax
  80152c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80152f:	89 c1                	mov    %eax,%ecx
  801531:	c1 f9 1f             	sar    $0x1f,%ecx
  801534:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801537:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80153a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80153d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801542:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801546:	79 74                	jns    8015bc <vprintfmt+0x35d>
				putch('-', putdat);
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	53                   	push   %ebx
  80154c:	6a 2d                	push   $0x2d
  80154e:	ff d6                	call   *%esi
				num = -(long long) num;
  801550:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801553:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801556:	f7 d8                	neg    %eax
  801558:	83 d2 00             	adc    $0x0,%edx
  80155b:	f7 da                	neg    %edx
  80155d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801560:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801565:	eb 55                	jmp    8015bc <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801567:	8d 45 14             	lea    0x14(%ebp),%eax
  80156a:	e8 7c fc ff ff       	call   8011eb <getuint>
			base = 10;
  80156f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801574:	eb 46                	jmp    8015bc <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801576:	8d 45 14             	lea    0x14(%ebp),%eax
  801579:	e8 6d fc ff ff       	call   8011eb <getuint>
                        base = 8;
  80157e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801583:	eb 37                	jmp    8015bc <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	53                   	push   %ebx
  801589:	6a 30                	push   $0x30
  80158b:	ff d6                	call   *%esi
			putch('x', putdat);
  80158d:	83 c4 08             	add    $0x8,%esp
  801590:	53                   	push   %ebx
  801591:	6a 78                	push   $0x78
  801593:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801595:	8b 45 14             	mov    0x14(%ebp),%eax
  801598:	8d 50 04             	lea    0x4(%eax),%edx
  80159b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80159e:	8b 00                	mov    (%eax),%eax
  8015a0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015a5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015a8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015ad:	eb 0d                	jmp    8015bc <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015af:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b2:	e8 34 fc ff ff       	call   8011eb <getuint>
			base = 16;
  8015b7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015bc:	83 ec 0c             	sub    $0xc,%esp
  8015bf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015c3:	57                   	push   %edi
  8015c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c7:	51                   	push   %ecx
  8015c8:	52                   	push   %edx
  8015c9:	50                   	push   %eax
  8015ca:	89 da                	mov    %ebx,%edx
  8015cc:	89 f0                	mov    %esi,%eax
  8015ce:	e8 6e fb ff ff       	call   801141 <printnum>
			break;
  8015d3:	83 c4 20             	add    $0x20,%esp
  8015d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015d9:	e9 a7 fc ff ff       	jmp    801285 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	53                   	push   %ebx
  8015e2:	51                   	push   %ecx
  8015e3:	ff d6                	call   *%esi
			break;
  8015e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015eb:	e9 95 fc ff ff       	jmp    801285 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015f0:	83 ec 08             	sub    $0x8,%esp
  8015f3:	53                   	push   %ebx
  8015f4:	6a 25                	push   $0x25
  8015f6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	eb 03                	jmp    801600 <vprintfmt+0x3a1>
  8015fd:	83 ef 01             	sub    $0x1,%edi
  801600:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801604:	75 f7                	jne    8015fd <vprintfmt+0x39e>
  801606:	e9 7a fc ff ff       	jmp    801285 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80160b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160e:	5b                   	pop    %ebx
  80160f:	5e                   	pop    %esi
  801610:	5f                   	pop    %edi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	83 ec 18             	sub    $0x18,%esp
  801619:	8b 45 08             	mov    0x8(%ebp),%eax
  80161c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80161f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801622:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801626:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801629:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801630:	85 c0                	test   %eax,%eax
  801632:	74 26                	je     80165a <vsnprintf+0x47>
  801634:	85 d2                	test   %edx,%edx
  801636:	7e 22                	jle    80165a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801638:	ff 75 14             	pushl  0x14(%ebp)
  80163b:	ff 75 10             	pushl  0x10(%ebp)
  80163e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801641:	50                   	push   %eax
  801642:	68 25 12 80 00       	push   $0x801225
  801647:	e8 13 fc ff ff       	call   80125f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80164c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80164f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801652:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	eb 05                	jmp    80165f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80165a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80165f:	c9                   	leave  
  801660:	c3                   	ret    

00801661 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801667:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80166a:	50                   	push   %eax
  80166b:	ff 75 10             	pushl  0x10(%ebp)
  80166e:	ff 75 0c             	pushl  0xc(%ebp)
  801671:	ff 75 08             	pushl  0x8(%ebp)
  801674:	e8 9a ff ff ff       	call   801613 <vsnprintf>
	va_end(ap);

	return rc;
}
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801681:	b8 00 00 00 00       	mov    $0x0,%eax
  801686:	eb 03                	jmp    80168b <strlen+0x10>
		n++;
  801688:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80168b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80168f:	75 f7                	jne    801688 <strlen+0xd>
		n++;
	return n;
}
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    

00801693 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801699:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169c:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a1:	eb 03                	jmp    8016a6 <strnlen+0x13>
		n++;
  8016a3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a6:	39 c2                	cmp    %eax,%edx
  8016a8:	74 08                	je     8016b2 <strnlen+0x1f>
  8016aa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016ae:	75 f3                	jne    8016a3 <strnlen+0x10>
  8016b0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	53                   	push   %ebx
  8016b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016be:	89 c2                	mov    %eax,%edx
  8016c0:	83 c2 01             	add    $0x1,%edx
  8016c3:	83 c1 01             	add    $0x1,%ecx
  8016c6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016ca:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016cd:	84 db                	test   %bl,%bl
  8016cf:	75 ef                	jne    8016c0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016d1:	5b                   	pop    %ebx
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    

008016d4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	53                   	push   %ebx
  8016d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016db:	53                   	push   %ebx
  8016dc:	e8 9a ff ff ff       	call   80167b <strlen>
  8016e1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016e4:	ff 75 0c             	pushl  0xc(%ebp)
  8016e7:	01 d8                	add    %ebx,%eax
  8016e9:	50                   	push   %eax
  8016ea:	e8 c5 ff ff ff       	call   8016b4 <strcpy>
	return dst;
}
  8016ef:	89 d8                	mov    %ebx,%eax
  8016f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	56                   	push   %esi
  8016fa:	53                   	push   %ebx
  8016fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801701:	89 f3                	mov    %esi,%ebx
  801703:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801706:	89 f2                	mov    %esi,%edx
  801708:	eb 0f                	jmp    801719 <strncpy+0x23>
		*dst++ = *src;
  80170a:	83 c2 01             	add    $0x1,%edx
  80170d:	0f b6 01             	movzbl (%ecx),%eax
  801710:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801713:	80 39 01             	cmpb   $0x1,(%ecx)
  801716:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801719:	39 da                	cmp    %ebx,%edx
  80171b:	75 ed                	jne    80170a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80171d:	89 f0                	mov    %esi,%eax
  80171f:	5b                   	pop    %ebx
  801720:	5e                   	pop    %esi
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	56                   	push   %esi
  801727:	53                   	push   %ebx
  801728:	8b 75 08             	mov    0x8(%ebp),%esi
  80172b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172e:	8b 55 10             	mov    0x10(%ebp),%edx
  801731:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801733:	85 d2                	test   %edx,%edx
  801735:	74 21                	je     801758 <strlcpy+0x35>
  801737:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80173b:	89 f2                	mov    %esi,%edx
  80173d:	eb 09                	jmp    801748 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80173f:	83 c2 01             	add    $0x1,%edx
  801742:	83 c1 01             	add    $0x1,%ecx
  801745:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801748:	39 c2                	cmp    %eax,%edx
  80174a:	74 09                	je     801755 <strlcpy+0x32>
  80174c:	0f b6 19             	movzbl (%ecx),%ebx
  80174f:	84 db                	test   %bl,%bl
  801751:	75 ec                	jne    80173f <strlcpy+0x1c>
  801753:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801755:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801758:	29 f0                	sub    %esi,%eax
}
  80175a:	5b                   	pop    %ebx
  80175b:	5e                   	pop    %esi
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801764:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801767:	eb 06                	jmp    80176f <strcmp+0x11>
		p++, q++;
  801769:	83 c1 01             	add    $0x1,%ecx
  80176c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80176f:	0f b6 01             	movzbl (%ecx),%eax
  801772:	84 c0                	test   %al,%al
  801774:	74 04                	je     80177a <strcmp+0x1c>
  801776:	3a 02                	cmp    (%edx),%al
  801778:	74 ef                	je     801769 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80177a:	0f b6 c0             	movzbl %al,%eax
  80177d:	0f b6 12             	movzbl (%edx),%edx
  801780:	29 d0                	sub    %edx,%eax
}
  801782:	5d                   	pop    %ebp
  801783:	c3                   	ret    

00801784 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	53                   	push   %ebx
  801788:	8b 45 08             	mov    0x8(%ebp),%eax
  80178b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178e:	89 c3                	mov    %eax,%ebx
  801790:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801793:	eb 06                	jmp    80179b <strncmp+0x17>
		n--, p++, q++;
  801795:	83 c0 01             	add    $0x1,%eax
  801798:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80179b:	39 d8                	cmp    %ebx,%eax
  80179d:	74 15                	je     8017b4 <strncmp+0x30>
  80179f:	0f b6 08             	movzbl (%eax),%ecx
  8017a2:	84 c9                	test   %cl,%cl
  8017a4:	74 04                	je     8017aa <strncmp+0x26>
  8017a6:	3a 0a                	cmp    (%edx),%cl
  8017a8:	74 eb                	je     801795 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017aa:	0f b6 00             	movzbl (%eax),%eax
  8017ad:	0f b6 12             	movzbl (%edx),%edx
  8017b0:	29 d0                	sub    %edx,%eax
  8017b2:	eb 05                	jmp    8017b9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017b9:	5b                   	pop    %ebx
  8017ba:	5d                   	pop    %ebp
  8017bb:	c3                   	ret    

008017bc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c6:	eb 07                	jmp    8017cf <strchr+0x13>
		if (*s == c)
  8017c8:	38 ca                	cmp    %cl,%dl
  8017ca:	74 0f                	je     8017db <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017cc:	83 c0 01             	add    $0x1,%eax
  8017cf:	0f b6 10             	movzbl (%eax),%edx
  8017d2:	84 d2                	test   %dl,%dl
  8017d4:	75 f2                	jne    8017c8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    

008017dd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e7:	eb 03                	jmp    8017ec <strfind+0xf>
  8017e9:	83 c0 01             	add    $0x1,%eax
  8017ec:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017ef:	84 d2                	test   %dl,%dl
  8017f1:	74 04                	je     8017f7 <strfind+0x1a>
  8017f3:	38 ca                	cmp    %cl,%dl
  8017f5:	75 f2                	jne    8017e9 <strfind+0xc>
			break;
	return (char *) s;
}
  8017f7:	5d                   	pop    %ebp
  8017f8:	c3                   	ret    

008017f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	57                   	push   %edi
  8017fd:	56                   	push   %esi
  8017fe:	53                   	push   %ebx
  8017ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801802:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801805:	85 c9                	test   %ecx,%ecx
  801807:	74 36                	je     80183f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801809:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80180f:	75 28                	jne    801839 <memset+0x40>
  801811:	f6 c1 03             	test   $0x3,%cl
  801814:	75 23                	jne    801839 <memset+0x40>
		c &= 0xFF;
  801816:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80181a:	89 d3                	mov    %edx,%ebx
  80181c:	c1 e3 08             	shl    $0x8,%ebx
  80181f:	89 d6                	mov    %edx,%esi
  801821:	c1 e6 18             	shl    $0x18,%esi
  801824:	89 d0                	mov    %edx,%eax
  801826:	c1 e0 10             	shl    $0x10,%eax
  801829:	09 f0                	or     %esi,%eax
  80182b:	09 c2                	or     %eax,%edx
  80182d:	89 d0                	mov    %edx,%eax
  80182f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801831:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801834:	fc                   	cld    
  801835:	f3 ab                	rep stos %eax,%es:(%edi)
  801837:	eb 06                	jmp    80183f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801839:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183c:	fc                   	cld    
  80183d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80183f:	89 f8                	mov    %edi,%eax
  801841:	5b                   	pop    %ebx
  801842:	5e                   	pop    %esi
  801843:	5f                   	pop    %edi
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	57                   	push   %edi
  80184a:	56                   	push   %esi
  80184b:	8b 45 08             	mov    0x8(%ebp),%eax
  80184e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801851:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801854:	39 c6                	cmp    %eax,%esi
  801856:	73 35                	jae    80188d <memmove+0x47>
  801858:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80185b:	39 d0                	cmp    %edx,%eax
  80185d:	73 2e                	jae    80188d <memmove+0x47>
		s += n;
		d += n;
  80185f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801862:	89 d6                	mov    %edx,%esi
  801864:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801866:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80186c:	75 13                	jne    801881 <memmove+0x3b>
  80186e:	f6 c1 03             	test   $0x3,%cl
  801871:	75 0e                	jne    801881 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801873:	83 ef 04             	sub    $0x4,%edi
  801876:	8d 72 fc             	lea    -0x4(%edx),%esi
  801879:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80187c:	fd                   	std    
  80187d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80187f:	eb 09                	jmp    80188a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801881:	83 ef 01             	sub    $0x1,%edi
  801884:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801887:	fd                   	std    
  801888:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80188a:	fc                   	cld    
  80188b:	eb 1d                	jmp    8018aa <memmove+0x64>
  80188d:	89 f2                	mov    %esi,%edx
  80188f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801891:	f6 c2 03             	test   $0x3,%dl
  801894:	75 0f                	jne    8018a5 <memmove+0x5f>
  801896:	f6 c1 03             	test   $0x3,%cl
  801899:	75 0a                	jne    8018a5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80189b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80189e:	89 c7                	mov    %eax,%edi
  8018a0:	fc                   	cld    
  8018a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a3:	eb 05                	jmp    8018aa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018a5:	89 c7                	mov    %eax,%edi
  8018a7:	fc                   	cld    
  8018a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018aa:	5e                   	pop    %esi
  8018ab:	5f                   	pop    %edi
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018b1:	ff 75 10             	pushl  0x10(%ebp)
  8018b4:	ff 75 0c             	pushl  0xc(%ebp)
  8018b7:	ff 75 08             	pushl  0x8(%ebp)
  8018ba:	e8 87 ff ff ff       	call   801846 <memmove>
}
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	56                   	push   %esi
  8018c5:	53                   	push   %ebx
  8018c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018cc:	89 c6                	mov    %eax,%esi
  8018ce:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d1:	eb 1a                	jmp    8018ed <memcmp+0x2c>
		if (*s1 != *s2)
  8018d3:	0f b6 08             	movzbl (%eax),%ecx
  8018d6:	0f b6 1a             	movzbl (%edx),%ebx
  8018d9:	38 d9                	cmp    %bl,%cl
  8018db:	74 0a                	je     8018e7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018dd:	0f b6 c1             	movzbl %cl,%eax
  8018e0:	0f b6 db             	movzbl %bl,%ebx
  8018e3:	29 d8                	sub    %ebx,%eax
  8018e5:	eb 0f                	jmp    8018f6 <memcmp+0x35>
		s1++, s2++;
  8018e7:	83 c0 01             	add    $0x1,%eax
  8018ea:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ed:	39 f0                	cmp    %esi,%eax
  8018ef:	75 e2                	jne    8018d3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f6:	5b                   	pop    %ebx
  8018f7:	5e                   	pop    %esi
  8018f8:	5d                   	pop    %ebp
  8018f9:	c3                   	ret    

008018fa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801900:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801903:	89 c2                	mov    %eax,%edx
  801905:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801908:	eb 07                	jmp    801911 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80190a:	38 08                	cmp    %cl,(%eax)
  80190c:	74 07                	je     801915 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80190e:	83 c0 01             	add    $0x1,%eax
  801911:	39 d0                	cmp    %edx,%eax
  801913:	72 f5                	jb     80190a <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801915:	5d                   	pop    %ebp
  801916:	c3                   	ret    

00801917 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	57                   	push   %edi
  80191b:	56                   	push   %esi
  80191c:	53                   	push   %ebx
  80191d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801920:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801923:	eb 03                	jmp    801928 <strtol+0x11>
		s++;
  801925:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801928:	0f b6 01             	movzbl (%ecx),%eax
  80192b:	3c 09                	cmp    $0x9,%al
  80192d:	74 f6                	je     801925 <strtol+0xe>
  80192f:	3c 20                	cmp    $0x20,%al
  801931:	74 f2                	je     801925 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801933:	3c 2b                	cmp    $0x2b,%al
  801935:	75 0a                	jne    801941 <strtol+0x2a>
		s++;
  801937:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80193a:	bf 00 00 00 00       	mov    $0x0,%edi
  80193f:	eb 10                	jmp    801951 <strtol+0x3a>
  801941:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801946:	3c 2d                	cmp    $0x2d,%al
  801948:	75 07                	jne    801951 <strtol+0x3a>
		s++, neg = 1;
  80194a:	8d 49 01             	lea    0x1(%ecx),%ecx
  80194d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801951:	85 db                	test   %ebx,%ebx
  801953:	0f 94 c0             	sete   %al
  801956:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80195c:	75 19                	jne    801977 <strtol+0x60>
  80195e:	80 39 30             	cmpb   $0x30,(%ecx)
  801961:	75 14                	jne    801977 <strtol+0x60>
  801963:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801967:	0f 85 82 00 00 00    	jne    8019ef <strtol+0xd8>
		s += 2, base = 16;
  80196d:	83 c1 02             	add    $0x2,%ecx
  801970:	bb 10 00 00 00       	mov    $0x10,%ebx
  801975:	eb 16                	jmp    80198d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801977:	84 c0                	test   %al,%al
  801979:	74 12                	je     80198d <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80197b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801980:	80 39 30             	cmpb   $0x30,(%ecx)
  801983:	75 08                	jne    80198d <strtol+0x76>
		s++, base = 8;
  801985:	83 c1 01             	add    $0x1,%ecx
  801988:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80198d:	b8 00 00 00 00       	mov    $0x0,%eax
  801992:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801995:	0f b6 11             	movzbl (%ecx),%edx
  801998:	8d 72 d0             	lea    -0x30(%edx),%esi
  80199b:	89 f3                	mov    %esi,%ebx
  80199d:	80 fb 09             	cmp    $0x9,%bl
  8019a0:	77 08                	ja     8019aa <strtol+0x93>
			dig = *s - '0';
  8019a2:	0f be d2             	movsbl %dl,%edx
  8019a5:	83 ea 30             	sub    $0x30,%edx
  8019a8:	eb 22                	jmp    8019cc <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019aa:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019ad:	89 f3                	mov    %esi,%ebx
  8019af:	80 fb 19             	cmp    $0x19,%bl
  8019b2:	77 08                	ja     8019bc <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019b4:	0f be d2             	movsbl %dl,%edx
  8019b7:	83 ea 57             	sub    $0x57,%edx
  8019ba:	eb 10                	jmp    8019cc <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019bc:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019bf:	89 f3                	mov    %esi,%ebx
  8019c1:	80 fb 19             	cmp    $0x19,%bl
  8019c4:	77 16                	ja     8019dc <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019c6:	0f be d2             	movsbl %dl,%edx
  8019c9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019cc:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019cf:	7d 0f                	jge    8019e0 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019d1:	83 c1 01             	add    $0x1,%ecx
  8019d4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019d8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019da:	eb b9                	jmp    801995 <strtol+0x7e>
  8019dc:	89 c2                	mov    %eax,%edx
  8019de:	eb 02                	jmp    8019e2 <strtol+0xcb>
  8019e0:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019e6:	74 0d                	je     8019f5 <strtol+0xde>
		*endptr = (char *) s;
  8019e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019eb:	89 0e                	mov    %ecx,(%esi)
  8019ed:	eb 06                	jmp    8019f5 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ef:	84 c0                	test   %al,%al
  8019f1:	75 92                	jne    801985 <strtol+0x6e>
  8019f3:	eb 98                	jmp    80198d <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019f5:	f7 da                	neg    %edx
  8019f7:	85 ff                	test   %edi,%edi
  8019f9:	0f 45 c2             	cmovne %edx,%eax
}
  8019fc:	5b                   	pop    %ebx
  8019fd:	5e                   	pop    %esi
  8019fe:	5f                   	pop    %edi
  8019ff:	5d                   	pop    %ebp
  801a00:	c3                   	ret    

00801a01 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
  801a06:	8b 75 08             	mov    0x8(%ebp),%esi
  801a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a16:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	50                   	push   %eax
  801a1d:	e8 e4 e8 ff ff       	call   800306 <sys_ipc_recv>
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	85 c0                	test   %eax,%eax
  801a27:	79 16                	jns    801a3f <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801a29:	85 f6                	test   %esi,%esi
  801a2b:	74 06                	je     801a33 <ipc_recv+0x32>
  801a2d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801a33:	85 db                	test   %ebx,%ebx
  801a35:	74 2c                	je     801a63 <ipc_recv+0x62>
  801a37:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a3d:	eb 24                	jmp    801a63 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a3f:	85 f6                	test   %esi,%esi
  801a41:	74 0a                	je     801a4d <ipc_recv+0x4c>
  801a43:	a1 04 40 80 00       	mov    0x804004,%eax
  801a48:	8b 40 74             	mov    0x74(%eax),%eax
  801a4b:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801a4d:	85 db                	test   %ebx,%ebx
  801a4f:	74 0a                	je     801a5b <ipc_recv+0x5a>
  801a51:	a1 04 40 80 00       	mov    0x804004,%eax
  801a56:	8b 40 78             	mov    0x78(%eax),%eax
  801a59:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801a5b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a60:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a66:	5b                   	pop    %ebx
  801a67:	5e                   	pop    %esi
  801a68:	5d                   	pop    %ebp
  801a69:	c3                   	ret    

00801a6a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	57                   	push   %edi
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
  801a70:	83 ec 0c             	sub    $0xc,%esp
  801a73:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a76:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801a7c:	85 db                	test   %ebx,%ebx
  801a7e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a83:	0f 44 d8             	cmove  %eax,%ebx
  801a86:	eb 1c                	jmp    801aa4 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801a88:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a8b:	74 12                	je     801a9f <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801a8d:	50                   	push   %eax
  801a8e:	68 60 22 80 00       	push   $0x802260
  801a93:	6a 39                	push   $0x39
  801a95:	68 7b 22 80 00       	push   $0x80227b
  801a9a:	e8 b5 f5 ff ff       	call   801054 <_panic>
                 sys_yield();
  801a9f:	e8 93 e6 ff ff       	call   800137 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801aa4:	ff 75 14             	pushl  0x14(%ebp)
  801aa7:	53                   	push   %ebx
  801aa8:	56                   	push   %esi
  801aa9:	57                   	push   %edi
  801aaa:	e8 34 e8 ff ff       	call   8002e3 <sys_ipc_try_send>
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	78 d2                	js     801a88 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801ab6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab9:	5b                   	pop    %ebx
  801aba:	5e                   	pop    %esi
  801abb:	5f                   	pop    %edi
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    

00801abe <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ac9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801acc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad2:	8b 52 50             	mov    0x50(%edx),%edx
  801ad5:	39 ca                	cmp    %ecx,%edx
  801ad7:	75 0d                	jne    801ae6 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ad9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801adc:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ae1:	8b 40 08             	mov    0x8(%eax),%eax
  801ae4:	eb 0e                	jmp    801af4 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae6:	83 c0 01             	add    $0x1,%eax
  801ae9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801aee:	75 d9                	jne    801ac9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af0:	66 b8 00 00          	mov    $0x0,%ax
}
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afc:	89 d0                	mov    %edx,%eax
  801afe:	c1 e8 16             	shr    $0x16,%eax
  801b01:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b08:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0d:	f6 c1 01             	test   $0x1,%cl
  801b10:	74 1d                	je     801b2f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b12:	c1 ea 0c             	shr    $0xc,%edx
  801b15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b1c:	f6 c2 01             	test   $0x1,%dl
  801b1f:	74 0e                	je     801b2f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b21:	c1 ea 0c             	shr    $0xc,%edx
  801b24:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b2b:	ef 
  801b2c:	0f b7 c0             	movzwl %ax,%eax
}
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    
  801b31:	66 90                	xchg   %ax,%ax
  801b33:	66 90                	xchg   %ax,%ax
  801b35:	66 90                	xchg   %ax,%ax
  801b37:	66 90                	xchg   %ax,%ax
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
