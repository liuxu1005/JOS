
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
  800060:	83 c4 10             	add    $0x10,%esp
}
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
  8000a1:	83 c4 10             	add    $0x10,%esp
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 89 04 00 00       	call   80053f <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
  8000c0:	83 c4 10             	add    $0x10,%esp
}
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 4a 1e 80 00       	push   $0x801e4a
  80012f:	6a 23                	push   $0x23
  800131:	68 67 1e 80 00       	push   $0x801e67
  800136:	e8 44 0f 00 00       	call   80107f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 4a 1e 80 00       	push   $0x801e4a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 67 1e 80 00       	push   $0x801e67
  8001b7:	e8 c3 0e 00 00       	call   80107f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 4a 1e 80 00       	push   $0x801e4a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 67 1e 80 00       	push   $0x801e67
  8001f9:	e8 81 0e 00 00       	call   80107f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 4a 1e 80 00       	push   $0x801e4a
  800234:	6a 23                	push   $0x23
  800236:	68 67 1e 80 00       	push   $0x801e67
  80023b:	e8 3f 0e 00 00       	call   80107f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 4a 1e 80 00       	push   $0x801e4a
  800276:	6a 23                	push   $0x23
  800278:	68 67 1e 80 00       	push   $0x801e67
  80027d:	e8 fd 0d 00 00       	call   80107f <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 4a 1e 80 00       	push   $0x801e4a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 67 1e 80 00       	push   $0x801e67
  8002bf:	e8 bb 0d 00 00       	call   80107f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 4a 1e 80 00       	push   $0x801e4a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 67 1e 80 00       	push   $0x801e67
  800301:	e8 79 0d 00 00       	call   80107f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 4a 1e 80 00       	push   $0x801e4a
  80035e:	6a 23                	push   $0x23
  800360:	68 67 1e 80 00       	push   $0x801e67
  800365:	e8 15 0d 00 00       	call   80107f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 11                	je     8003c6 <fd_alloc+0x2d>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	75 09                	jne    8003cf <fd_alloc+0x36>
			*fd_store = fd;
  8003c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cd:	eb 17                	jmp    8003e6 <fd_alloc+0x4d>
  8003cf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d9:	75 c9                	jne    8003a4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003db:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 f8 1f             	cmp    $0x1f,%eax
  8003f1:	77 36                	ja     800429 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	c1 e0 0c             	shl    $0xc,%eax
  8003f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 16             	shr    $0x16,%edx
  800400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 24                	je     800430 <fd_lookup+0x48>
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 0c             	shr    $0xc,%edx
  800411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 1a                	je     800437 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
	return 0;
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	eb 13                	jmp    80043c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042e:	eb 0c                	jmp    80043c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb 05                	jmp    80043c <fd_lookup+0x54>
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	ba f4 1e 80 00       	mov    $0x801ef4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044c:	eb 13                	jmp    800461 <dev_lookup+0x23>
  80044e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800451:	39 08                	cmp    %ecx,(%eax)
  800453:	75 0c                	jne    800461 <dev_lookup+0x23>
			*dev = devtab[i];
  800455:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800458:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	eb 2e                	jmp    80048f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	8b 02                	mov    (%edx),%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	75 e7                	jne    80044e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800467:	a1 04 40 80 00       	mov    0x804004,%eax
  80046c:	8b 40 48             	mov    0x48(%eax),%eax
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	51                   	push   %ecx
  800473:	50                   	push   %eax
  800474:	68 78 1e 80 00       	push   $0x801e78
  800479:	e8 da 0c 00 00       	call   801158 <cprintf>
	*dev = 0;
  80047e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800481:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 10             	sub    $0x10,%esp
  800499:	8b 75 08             	mov    0x8(%ebp),%esi
  80049c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a2:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004a3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a9:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004ac:	50                   	push   %eax
  8004ad:	e8 36 ff ff ff       	call   8003e8 <fd_lookup>
  8004b2:	83 c4 08             	add    $0x8,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	78 05                	js     8004be <fd_close+0x2d>
	    || fd != fd2)
  8004b9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bc:	74 0c                	je     8004ca <fd_close+0x39>
		return (must_exist ? r : 0);
  8004be:	84 db                	test   %bl,%bl
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c5:	0f 44 c2             	cmove  %edx,%eax
  8004c8:	eb 41                	jmp    80050b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff 36                	pushl  (%esi)
  8004d3:	e8 66 ff ff ff       	call   80043e <dev_lookup>
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	78 1a                	js     8004fb <fd_close+0x6a>
		if (dev->dev_close)
  8004e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	74 0b                	je     8004fb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f0:	83 ec 0c             	sub    $0xc,%esp
  8004f3:	56                   	push   %esi
  8004f4:	ff d0                	call   *%eax
  8004f6:	89 c3                	mov    %eax,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	56                   	push   %esi
  8004ff:	6a 00                	push   $0x0
  800501:	e8 00 fd ff ff       	call   800206 <sys_page_unmap>
	return r;
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	89 d8                	mov    %ebx,%eax
}
  80050b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051b:	50                   	push   %eax
  80051c:	ff 75 08             	pushl  0x8(%ebp)
  80051f:	e8 c4 fe ff ff       	call   8003e8 <fd_lookup>
  800524:	89 c2                	mov    %eax,%edx
  800526:	83 c4 08             	add    $0x8,%esp
  800529:	85 d2                	test   %edx,%edx
  80052b:	78 10                	js     80053d <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	6a 01                	push   $0x1
  800532:	ff 75 f4             	pushl  -0xc(%ebp)
  800535:	e8 57 ff ff ff       	call   800491 <fd_close>
  80053a:	83 c4 10             	add    $0x10,%esp
}
  80053d:	c9                   	leave  
  80053e:	c3                   	ret    

0080053f <close_all>:

void
close_all(void)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	53                   	push   %ebx
  800543:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800546:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80054b:	83 ec 0c             	sub    $0xc,%esp
  80054e:	53                   	push   %ebx
  80054f:	e8 be ff ff ff       	call   800512 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800554:	83 c3 01             	add    $0x1,%ebx
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	83 fb 20             	cmp    $0x20,%ebx
  80055d:	75 ec                	jne    80054b <close_all+0xc>
		close(i);
}
  80055f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800562:	c9                   	leave  
  800563:	c3                   	ret    

00800564 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	57                   	push   %edi
  800568:	56                   	push   %esi
  800569:	53                   	push   %ebx
  80056a:	83 ec 2c             	sub    $0x2c,%esp
  80056d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800570:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800573:	50                   	push   %eax
  800574:	ff 75 08             	pushl  0x8(%ebp)
  800577:	e8 6c fe ff ff       	call   8003e8 <fd_lookup>
  80057c:	89 c2                	mov    %eax,%edx
  80057e:	83 c4 08             	add    $0x8,%esp
  800581:	85 d2                	test   %edx,%edx
  800583:	0f 88 c1 00 00 00    	js     80064a <dup+0xe6>
		return r;
	close(newfdnum);
  800589:	83 ec 0c             	sub    $0xc,%esp
  80058c:	56                   	push   %esi
  80058d:	e8 80 ff ff ff       	call   800512 <close>

	newfd = INDEX2FD(newfdnum);
  800592:	89 f3                	mov    %esi,%ebx
  800594:	c1 e3 0c             	shl    $0xc,%ebx
  800597:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80059d:	83 c4 04             	add    $0x4,%esp
  8005a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005a3:	e8 da fd ff ff       	call   800382 <fd2data>
  8005a8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005aa:	89 1c 24             	mov    %ebx,(%esp)
  8005ad:	e8 d0 fd ff ff       	call   800382 <fd2data>
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b8:	89 f8                	mov    %edi,%eax
  8005ba:	c1 e8 16             	shr    $0x16,%eax
  8005bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c4:	a8 01                	test   $0x1,%al
  8005c6:	74 37                	je     8005ff <dup+0x9b>
  8005c8:	89 f8                	mov    %edi,%eax
  8005ca:	c1 e8 0c             	shr    $0xc,%eax
  8005cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d4:	f6 c2 01             	test   $0x1,%dl
  8005d7:	74 26                	je     8005ff <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e8:	50                   	push   %eax
  8005e9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ec:	6a 00                	push   $0x0
  8005ee:	57                   	push   %edi
  8005ef:	6a 00                	push   $0x0
  8005f1:	e8 ce fb ff ff       	call   8001c4 <sys_page_map>
  8005f6:	89 c7                	mov    %eax,%edi
  8005f8:	83 c4 20             	add    $0x20,%esp
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	78 2e                	js     80062d <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800602:	89 d0                	mov    %edx,%eax
  800604:	c1 e8 0c             	shr    $0xc,%eax
  800607:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060e:	83 ec 0c             	sub    $0xc,%esp
  800611:	25 07 0e 00 00       	and    $0xe07,%eax
  800616:	50                   	push   %eax
  800617:	53                   	push   %ebx
  800618:	6a 00                	push   $0x0
  80061a:	52                   	push   %edx
  80061b:	6a 00                	push   $0x0
  80061d:	e8 a2 fb ff ff       	call   8001c4 <sys_page_map>
  800622:	89 c7                	mov    %eax,%edi
  800624:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800627:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800629:	85 ff                	test   %edi,%edi
  80062b:	79 1d                	jns    80064a <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 00                	push   $0x0
  800633:	e8 ce fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800638:	83 c4 08             	add    $0x8,%esp
  80063b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063e:	6a 00                	push   $0x0
  800640:	e8 c1 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800645:	83 c4 10             	add    $0x10,%esp
  800648:	89 f8                	mov    %edi,%eax
}
  80064a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064d:	5b                   	pop    %ebx
  80064e:	5e                   	pop    %esi
  80064f:	5f                   	pop    %edi
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    

00800652 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	53                   	push   %ebx
  800656:	83 ec 14             	sub    $0x14,%esp
  800659:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80065c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065f:	50                   	push   %eax
  800660:	53                   	push   %ebx
  800661:	e8 82 fd ff ff       	call   8003e8 <fd_lookup>
  800666:	83 c4 08             	add    $0x8,%esp
  800669:	89 c2                	mov    %eax,%edx
  80066b:	85 c0                	test   %eax,%eax
  80066d:	78 6d                	js     8006dc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800675:	50                   	push   %eax
  800676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800679:	ff 30                	pushl  (%eax)
  80067b:	e8 be fd ff ff       	call   80043e <dev_lookup>
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	85 c0                	test   %eax,%eax
  800685:	78 4c                	js     8006d3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800687:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80068a:	8b 42 08             	mov    0x8(%edx),%eax
  80068d:	83 e0 03             	and    $0x3,%eax
  800690:	83 f8 01             	cmp    $0x1,%eax
  800693:	75 21                	jne    8006b6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800695:	a1 04 40 80 00       	mov    0x804004,%eax
  80069a:	8b 40 48             	mov    0x48(%eax),%eax
  80069d:	83 ec 04             	sub    $0x4,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	50                   	push   %eax
  8006a2:	68 b9 1e 80 00       	push   $0x801eb9
  8006a7:	e8 ac 0a 00 00       	call   801158 <cprintf>
		return -E_INVAL;
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b4:	eb 26                	jmp    8006dc <read+0x8a>
	}
	if (!dev->dev_read)
  8006b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b9:	8b 40 08             	mov    0x8(%eax),%eax
  8006bc:	85 c0                	test   %eax,%eax
  8006be:	74 17                	je     8006d7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006c0:	83 ec 04             	sub    $0x4,%esp
  8006c3:	ff 75 10             	pushl  0x10(%ebp)
  8006c6:	ff 75 0c             	pushl  0xc(%ebp)
  8006c9:	52                   	push   %edx
  8006ca:	ff d0                	call   *%eax
  8006cc:	89 c2                	mov    %eax,%edx
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 09                	jmp    8006dc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d3:	89 c2                	mov    %eax,%edx
  8006d5:	eb 05                	jmp    8006dc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006dc:	89 d0                	mov    %edx,%eax
  8006de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	57                   	push   %edi
  8006e7:	56                   	push   %esi
  8006e8:	53                   	push   %ebx
  8006e9:	83 ec 0c             	sub    $0xc,%esp
  8006ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ef:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f7:	eb 21                	jmp    80071a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f9:	83 ec 04             	sub    $0x4,%esp
  8006fc:	89 f0                	mov    %esi,%eax
  8006fe:	29 d8                	sub    %ebx,%eax
  800700:	50                   	push   %eax
  800701:	89 d8                	mov    %ebx,%eax
  800703:	03 45 0c             	add    0xc(%ebp),%eax
  800706:	50                   	push   %eax
  800707:	57                   	push   %edi
  800708:	e8 45 ff ff ff       	call   800652 <read>
		if (m < 0)
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	85 c0                	test   %eax,%eax
  800712:	78 0c                	js     800720 <readn+0x3d>
			return m;
		if (m == 0)
  800714:	85 c0                	test   %eax,%eax
  800716:	74 06                	je     80071e <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800718:	01 c3                	add    %eax,%ebx
  80071a:	39 f3                	cmp    %esi,%ebx
  80071c:	72 db                	jb     8006f9 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80071e:	89 d8                	mov    %ebx,%eax
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 14             	sub    $0x14,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	53                   	push   %ebx
  800737:	e8 ac fc ff ff       	call   8003e8 <fd_lookup>
  80073c:	83 c4 08             	add    $0x8,%esp
  80073f:	89 c2                	mov    %eax,%edx
  800741:	85 c0                	test   %eax,%eax
  800743:	78 68                	js     8007ad <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	ff 30                	pushl  (%eax)
  800751:	e8 e8 fc ff ff       	call   80043e <dev_lookup>
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 47                	js     8007a4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800764:	75 21                	jne    800787 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 d5 1e 80 00       	push   $0x801ed5
  800778:	e8 db 09 00 00       	call   801158 <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800785:	eb 26                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078a:	8b 52 0c             	mov    0xc(%edx),%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 17                	je     8007a8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800791:	83 ec 04             	sub    $0x4,%esp
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	50                   	push   %eax
  80079b:	ff d2                	call   *%edx
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 09                	jmp    8007ad <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	eb 05                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ad:	89 d0                	mov    %edx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	ff 75 08             	pushl  0x8(%ebp)
  8007c1:	e8 22 fc ff ff       	call   8003e8 <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 0e                	js     8007db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 14             	sub    $0x14,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ea:	50                   	push   %eax
  8007eb:	53                   	push   %ebx
  8007ec:	e8 f7 fb ff ff       	call   8003e8 <fd_lookup>
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 65                	js     80085f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800804:	ff 30                	pushl  (%eax)
  800806:	e8 33 fc ff ff       	call   80043e <dev_lookup>
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 44                	js     800856 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800819:	75 21                	jne    80083c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800820:	8b 40 48             	mov    0x48(%eax),%eax
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	68 98 1e 80 00       	push   $0x801e98
  80082d:	e8 26 09 00 00       	call   801158 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083a:	eb 23                	jmp    80085f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083f:	8b 52 18             	mov    0x18(%edx),%edx
  800842:	85 d2                	test   %edx,%edx
  800844:	74 14                	je     80085a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	50                   	push   %eax
  80084d:	ff d2                	call   *%edx
  80084f:	89 c2                	mov    %eax,%edx
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	eb 09                	jmp    80085f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800856:	89 c2                	mov    %eax,%edx
  800858:	eb 05                	jmp    80085f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085f:	89 d0                	mov    %edx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 14             	sub    $0x14,%esp
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 6c fb ff ff       	call   8003e8 <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	89 c2                	mov    %eax,%edx
  800881:	85 c0                	test   %eax,%eax
  800883:	78 58                	js     8008dd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088f:	ff 30                	pushl  (%eax)
  800891:	e8 a8 fb ff ff       	call   80043e <dev_lookup>
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 37                	js     8008d4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a4:	74 32                	je     8008d8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b0:	00 00 00 
	stat->st_isdir = 0;
  8008b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ba:	00 00 00 
	stat->st_dev = dev;
  8008bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ca:	ff 50 14             	call   *0x14(%eax)
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	eb 09                	jmp    8008dd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	eb 05                	jmp    8008dd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	6a 00                	push   $0x0
  8008ee:	ff 75 08             	pushl  0x8(%ebp)
  8008f1:	e8 09 02 00 00       	call   800aff <open>
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	85 db                	test   %ebx,%ebx
  8008fd:	78 1b                	js     80091a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	53                   	push   %ebx
  800906:	e8 5b ff ff ff       	call   800866 <fstat>
  80090b:	89 c6                	mov    %eax,%esi
	close(fd);
  80090d:	89 1c 24             	mov    %ebx,(%esp)
  800910:	e8 fd fb ff ff       	call   800512 <close>
	return r;
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	89 f0                	mov    %esi,%eax
}
  80091a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	89 c6                	mov    %eax,%esi
  800928:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800931:	75 12                	jne    800945 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	6a 01                	push   $0x1
  800938:	e8 ac 11 00 00       	call   801ae9 <ipc_find_env>
  80093d:	a3 00 40 80 00       	mov    %eax,0x804000
  800942:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800945:	6a 07                	push   $0x7
  800947:	68 00 50 80 00       	push   $0x805000
  80094c:	56                   	push   %esi
  80094d:	ff 35 00 40 80 00    	pushl  0x804000
  800953:	e8 3d 11 00 00       	call   801a95 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800958:	83 c4 0c             	add    $0xc,%esp
  80095b:	6a 00                	push   $0x0
  80095d:	53                   	push   %ebx
  80095e:	6a 00                	push   $0x0
  800960:	e8 c7 10 00 00       	call   801a2c <ipc_recv>
}
  800965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 40 0c             	mov    0xc(%eax),%eax
  800978:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	b8 02 00 00 00       	mov    $0x2,%eax
  80098f:	e8 8d ff ff ff       	call   800921 <fsipc>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b1:	e8 6b ff ff ff       	call   800921 <fsipc>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	83 ec 04             	sub    $0x4,%esp
  8009bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d7:	e8 45 ff ff ff       	call   800921 <fsipc>
  8009dc:	89 c2                	mov    %eax,%edx
  8009de:	85 d2                	test   %edx,%edx
  8009e0:	78 2c                	js     800a0e <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e2:	83 ec 08             	sub    $0x8,%esp
  8009e5:	68 00 50 80 00       	push   $0x805000
  8009ea:	53                   	push   %ebx
  8009eb:	e8 ef 0c 00 00       	call   8016df <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009f0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009fb:	a1 84 50 80 00       	mov    0x805084,%eax
  800a00:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a06:	83 c4 10             	add    $0x10,%esp
  800a09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	83 ec 0c             	sub    $0xc,%esp
  800a1c:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 40 0c             	mov    0xc(%eax),%eax
  800a25:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800a2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a2d:	eb 3d                	jmp    800a6c <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800a2f:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800a35:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800a3a:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800a3d:	83 ec 04             	sub    $0x4,%esp
  800a40:	57                   	push   %edi
  800a41:	53                   	push   %ebx
  800a42:	68 08 50 80 00       	push   $0x805008
  800a47:	e8 25 0e 00 00       	call   801871 <memmove>
                fsipcbuf.write.req_n = tmp; 
  800a4c:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a52:	ba 00 00 00 00       	mov    $0x0,%edx
  800a57:	b8 04 00 00 00       	mov    $0x4,%eax
  800a5c:	e8 c0 fe ff ff       	call   800921 <fsipc>
  800a61:	83 c4 10             	add    $0x10,%esp
  800a64:	85 c0                	test   %eax,%eax
  800a66:	78 0d                	js     800a75 <devfile_write+0x62>
		        return r;
                n -= tmp;
  800a68:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800a6a:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a6c:	85 f6                	test   %esi,%esi
  800a6e:	75 bf                	jne    800a2f <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800a70:	89 d8                	mov    %ebx,%eax
  800a72:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800a75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a90:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a96:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa0:	e8 7c fe ff ff       	call   800921 <fsipc>
  800aa5:	89 c3                	mov    %eax,%ebx
  800aa7:	85 c0                	test   %eax,%eax
  800aa9:	78 4b                	js     800af6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aab:	39 c6                	cmp    %eax,%esi
  800aad:	73 16                	jae    800ac5 <devfile_read+0x48>
  800aaf:	68 04 1f 80 00       	push   $0x801f04
  800ab4:	68 0b 1f 80 00       	push   $0x801f0b
  800ab9:	6a 7c                	push   $0x7c
  800abb:	68 20 1f 80 00       	push   $0x801f20
  800ac0:	e8 ba 05 00 00       	call   80107f <_panic>
	assert(r <= PGSIZE);
  800ac5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aca:	7e 16                	jle    800ae2 <devfile_read+0x65>
  800acc:	68 2b 1f 80 00       	push   $0x801f2b
  800ad1:	68 0b 1f 80 00       	push   $0x801f0b
  800ad6:	6a 7d                	push   $0x7d
  800ad8:	68 20 1f 80 00       	push   $0x801f20
  800add:	e8 9d 05 00 00       	call   80107f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae2:	83 ec 04             	sub    $0x4,%esp
  800ae5:	50                   	push   %eax
  800ae6:	68 00 50 80 00       	push   $0x805000
  800aeb:	ff 75 0c             	pushl  0xc(%ebp)
  800aee:	e8 7e 0d 00 00       	call   801871 <memmove>
	return r;
  800af3:	83 c4 10             	add    $0x10,%esp
}
  800af6:	89 d8                	mov    %ebx,%eax
  800af8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	53                   	push   %ebx
  800b03:	83 ec 20             	sub    $0x20,%esp
  800b06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b09:	53                   	push   %ebx
  800b0a:	e8 97 0b 00 00       	call   8016a6 <strlen>
  800b0f:	83 c4 10             	add    $0x10,%esp
  800b12:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b17:	7f 67                	jg     800b80 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1f:	50                   	push   %eax
  800b20:	e8 74 f8 ff ff       	call   800399 <fd_alloc>
  800b25:	83 c4 10             	add    $0x10,%esp
		return r;
  800b28:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	78 57                	js     800b85 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b2e:	83 ec 08             	sub    $0x8,%esp
  800b31:	53                   	push   %ebx
  800b32:	68 00 50 80 00       	push   $0x805000
  800b37:	e8 a3 0b 00 00       	call   8016df <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b47:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4c:	e8 d0 fd ff ff       	call   800921 <fsipc>
  800b51:	89 c3                	mov    %eax,%ebx
  800b53:	83 c4 10             	add    $0x10,%esp
  800b56:	85 c0                	test   %eax,%eax
  800b58:	79 14                	jns    800b6e <open+0x6f>
		fd_close(fd, 0);
  800b5a:	83 ec 08             	sub    $0x8,%esp
  800b5d:	6a 00                	push   $0x0
  800b5f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b62:	e8 2a f9 ff ff       	call   800491 <fd_close>
		return r;
  800b67:	83 c4 10             	add    $0x10,%esp
  800b6a:	89 da                	mov    %ebx,%edx
  800b6c:	eb 17                	jmp    800b85 <open+0x86>
	}

	return fd2num(fd);
  800b6e:	83 ec 0c             	sub    $0xc,%esp
  800b71:	ff 75 f4             	pushl  -0xc(%ebp)
  800b74:	e8 f9 f7 ff ff       	call   800372 <fd2num>
  800b79:	89 c2                	mov    %eax,%edx
  800b7b:	83 c4 10             	add    $0x10,%esp
  800b7e:	eb 05                	jmp    800b85 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b80:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b85:	89 d0                	mov    %edx,%eax
  800b87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8a:	c9                   	leave  
  800b8b:	c3                   	ret    

00800b8c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b92:	ba 00 00 00 00       	mov    $0x0,%edx
  800b97:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9c:	e8 80 fd ff ff       	call   800921 <fsipc>
}
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bab:	83 ec 0c             	sub    $0xc,%esp
  800bae:	ff 75 08             	pushl  0x8(%ebp)
  800bb1:	e8 cc f7 ff ff       	call   800382 <fd2data>
  800bb6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bb8:	83 c4 08             	add    $0x8,%esp
  800bbb:	68 37 1f 80 00       	push   $0x801f37
  800bc0:	53                   	push   %ebx
  800bc1:	e8 19 0b 00 00       	call   8016df <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bc6:	8b 56 04             	mov    0x4(%esi),%edx
  800bc9:	89 d0                	mov    %edx,%eax
  800bcb:	2b 06                	sub    (%esi),%eax
  800bcd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bd3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bda:	00 00 00 
	stat->st_dev = &devpipe;
  800bdd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800be4:	30 80 00 
	return 0;
}
  800be7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
  800bfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bfd:	53                   	push   %ebx
  800bfe:	6a 00                	push   $0x0
  800c00:	e8 01 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c05:	89 1c 24             	mov    %ebx,(%esp)
  800c08:	e8 75 f7 ff ff       	call   800382 <fd2data>
  800c0d:	83 c4 08             	add    $0x8,%esp
  800c10:	50                   	push   %eax
  800c11:	6a 00                	push   $0x0
  800c13:	e8 ee f5 ff ff       	call   800206 <sys_page_unmap>
}
  800c18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 1c             	sub    $0x1c,%esp
  800c26:	89 c6                	mov    %eax,%esi
  800c28:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c2b:	a1 04 40 80 00       	mov    0x804004,%eax
  800c30:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	56                   	push   %esi
  800c37:	e8 e5 0e 00 00       	call   801b21 <pageref>
  800c3c:	89 c7                	mov    %eax,%edi
  800c3e:	83 c4 04             	add    $0x4,%esp
  800c41:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c44:	e8 d8 0e 00 00       	call   801b21 <pageref>
  800c49:	83 c4 10             	add    $0x10,%esp
  800c4c:	39 c7                	cmp    %eax,%edi
  800c4e:	0f 94 c2             	sete   %dl
  800c51:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800c54:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800c5a:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800c5d:	39 fb                	cmp    %edi,%ebx
  800c5f:	74 19                	je     800c7a <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  800c61:	84 d2                	test   %dl,%dl
  800c63:	74 c6                	je     800c2b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c65:	8b 51 58             	mov    0x58(%ecx),%edx
  800c68:	50                   	push   %eax
  800c69:	52                   	push   %edx
  800c6a:	53                   	push   %ebx
  800c6b:	68 3e 1f 80 00       	push   $0x801f3e
  800c70:	e8 e3 04 00 00       	call   801158 <cprintf>
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	eb b1                	jmp    800c2b <_pipeisclosed+0xe>
	}
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 28             	sub    $0x28,%esp
  800c8b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c8e:	56                   	push   %esi
  800c8f:	e8 ee f6 ff ff       	call   800382 <fd2data>
  800c94:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c96:	83 c4 10             	add    $0x10,%esp
  800c99:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9e:	eb 4b                	jmp    800ceb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800ca0:	89 da                	mov    %ebx,%edx
  800ca2:	89 f0                	mov    %esi,%eax
  800ca4:	e8 74 ff ff ff       	call   800c1d <_pipeisclosed>
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	75 48                	jne    800cf5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cad:	e8 b0 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cb2:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb5:	8b 0b                	mov    (%ebx),%ecx
  800cb7:	8d 51 20             	lea    0x20(%ecx),%edx
  800cba:	39 d0                	cmp    %edx,%eax
  800cbc:	73 e2                	jae    800ca0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cc5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cc8:	89 c2                	mov    %eax,%edx
  800cca:	c1 fa 1f             	sar    $0x1f,%edx
  800ccd:	89 d1                	mov    %edx,%ecx
  800ccf:	c1 e9 1b             	shr    $0x1b,%ecx
  800cd2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cd5:	83 e2 1f             	and    $0x1f,%edx
  800cd8:	29 ca                	sub    %ecx,%edx
  800cda:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cde:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ce2:	83 c0 01             	add    $0x1,%eax
  800ce5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce8:	83 c7 01             	add    $0x1,%edi
  800ceb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cee:	75 c2                	jne    800cb2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cf0:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf3:	eb 05                	jmp    800cfa <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	83 ec 18             	sub    $0x18,%esp
  800d0b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d0e:	57                   	push   %edi
  800d0f:	e8 6e f6 ff ff       	call   800382 <fd2data>
  800d14:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d16:	83 c4 10             	add    $0x10,%esp
  800d19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1e:	eb 3d                	jmp    800d5d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d20:	85 db                	test   %ebx,%ebx
  800d22:	74 04                	je     800d28 <devpipe_read+0x26>
				return i;
  800d24:	89 d8                	mov    %ebx,%eax
  800d26:	eb 44                	jmp    800d6c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d28:	89 f2                	mov    %esi,%edx
  800d2a:	89 f8                	mov    %edi,%eax
  800d2c:	e8 ec fe ff ff       	call   800c1d <_pipeisclosed>
  800d31:	85 c0                	test   %eax,%eax
  800d33:	75 32                	jne    800d67 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d35:	e8 28 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d3a:	8b 06                	mov    (%esi),%eax
  800d3c:	3b 46 04             	cmp    0x4(%esi),%eax
  800d3f:	74 df                	je     800d20 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d41:	99                   	cltd   
  800d42:	c1 ea 1b             	shr    $0x1b,%edx
  800d45:	01 d0                	add    %edx,%eax
  800d47:	83 e0 1f             	and    $0x1f,%eax
  800d4a:	29 d0                	sub    %edx,%eax
  800d4c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d54:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d57:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d5a:	83 c3 01             	add    $0x1,%ebx
  800d5d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d60:	75 d8                	jne    800d3a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d62:	8b 45 10             	mov    0x10(%ebp),%eax
  800d65:	eb 05                	jmp    800d6c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d67:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d7f:	50                   	push   %eax
  800d80:	e8 14 f6 ff ff       	call   800399 <fd_alloc>
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	89 c2                	mov    %eax,%edx
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	0f 88 2c 01 00 00    	js     800ebe <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d92:	83 ec 04             	sub    $0x4,%esp
  800d95:	68 07 04 00 00       	push   $0x407
  800d9a:	ff 75 f4             	pushl  -0xc(%ebp)
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 dd f3 ff ff       	call   800181 <sys_page_alloc>
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	89 c2                	mov    %eax,%edx
  800da9:	85 c0                	test   %eax,%eax
  800dab:	0f 88 0d 01 00 00    	js     800ebe <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800db7:	50                   	push   %eax
  800db8:	e8 dc f5 ff ff       	call   800399 <fd_alloc>
  800dbd:	89 c3                	mov    %eax,%ebx
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	0f 88 e2 00 00 00    	js     800eac <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dca:	83 ec 04             	sub    $0x4,%esp
  800dcd:	68 07 04 00 00       	push   $0x407
  800dd2:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd5:	6a 00                	push   $0x0
  800dd7:	e8 a5 f3 ff ff       	call   800181 <sys_page_alloc>
  800ddc:	89 c3                	mov    %eax,%ebx
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	85 c0                	test   %eax,%eax
  800de3:	0f 88 c3 00 00 00    	js     800eac <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800de9:	83 ec 0c             	sub    $0xc,%esp
  800dec:	ff 75 f4             	pushl  -0xc(%ebp)
  800def:	e8 8e f5 ff ff       	call   800382 <fd2data>
  800df4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df6:	83 c4 0c             	add    $0xc,%esp
  800df9:	68 07 04 00 00       	push   $0x407
  800dfe:	50                   	push   %eax
  800dff:	6a 00                	push   $0x0
  800e01:	e8 7b f3 ff ff       	call   800181 <sys_page_alloc>
  800e06:	89 c3                	mov    %eax,%ebx
  800e08:	83 c4 10             	add    $0x10,%esp
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	0f 88 89 00 00 00    	js     800e9c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	ff 75 f0             	pushl  -0x10(%ebp)
  800e19:	e8 64 f5 ff ff       	call   800382 <fd2data>
  800e1e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e25:	50                   	push   %eax
  800e26:	6a 00                	push   $0x0
  800e28:	56                   	push   %esi
  800e29:	6a 00                	push   $0x0
  800e2b:	e8 94 f3 ff ff       	call   8001c4 <sys_page_map>
  800e30:	89 c3                	mov    %eax,%ebx
  800e32:	83 c4 20             	add    $0x20,%esp
  800e35:	85 c0                	test   %eax,%eax
  800e37:	78 55                	js     800e8e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e39:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e42:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e47:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e4e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e57:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e63:	83 ec 0c             	sub    $0xc,%esp
  800e66:	ff 75 f4             	pushl  -0xc(%ebp)
  800e69:	e8 04 f5 ff ff       	call   800372 <fd2num>
  800e6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e71:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e73:	83 c4 04             	add    $0x4,%esp
  800e76:	ff 75 f0             	pushl  -0x10(%ebp)
  800e79:	e8 f4 f4 ff ff       	call   800372 <fd2num>
  800e7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e81:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8c:	eb 30                	jmp    800ebe <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e8e:	83 ec 08             	sub    $0x8,%esp
  800e91:	56                   	push   %esi
  800e92:	6a 00                	push   $0x0
  800e94:	e8 6d f3 ff ff       	call   800206 <sys_page_unmap>
  800e99:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e9c:	83 ec 08             	sub    $0x8,%esp
  800e9f:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea2:	6a 00                	push   $0x0
  800ea4:	e8 5d f3 ff ff       	call   800206 <sys_page_unmap>
  800ea9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eac:	83 ec 08             	sub    $0x8,%esp
  800eaf:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb2:	6a 00                	push   $0x0
  800eb4:	e8 4d f3 ff ff       	call   800206 <sys_page_unmap>
  800eb9:	83 c4 10             	add    $0x10,%esp
  800ebc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ebe:	89 d0                	mov    %edx,%eax
  800ec0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ecd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed0:	50                   	push   %eax
  800ed1:	ff 75 08             	pushl  0x8(%ebp)
  800ed4:	e8 0f f5 ff ff       	call   8003e8 <fd_lookup>
  800ed9:	89 c2                	mov    %eax,%edx
  800edb:	83 c4 10             	add    $0x10,%esp
  800ede:	85 d2                	test   %edx,%edx
  800ee0:	78 18                	js     800efa <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ee2:	83 ec 0c             	sub    $0xc,%esp
  800ee5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee8:	e8 95 f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800eed:	89 c2                	mov    %eax,%edx
  800eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef2:	e8 26 fd ff ff       	call   800c1d <_pipeisclosed>
  800ef7:	83 c4 10             	add    $0x10,%esp
}
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eff:	b8 00 00 00 00       	mov    $0x0,%eax
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f0c:	68 56 1f 80 00       	push   $0x801f56
  800f11:	ff 75 0c             	pushl  0xc(%ebp)
  800f14:	e8 c6 07 00 00       	call   8016df <strcpy>
	return 0;
}
  800f19:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1e:	c9                   	leave  
  800f1f:	c3                   	ret    

00800f20 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
  800f26:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f2c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f31:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f37:	eb 2d                	jmp    800f66 <devcons_write+0x46>
		m = n - tot;
  800f39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f3e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f41:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f46:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f49:	83 ec 04             	sub    $0x4,%esp
  800f4c:	53                   	push   %ebx
  800f4d:	03 45 0c             	add    0xc(%ebp),%eax
  800f50:	50                   	push   %eax
  800f51:	57                   	push   %edi
  800f52:	e8 1a 09 00 00       	call   801871 <memmove>
		sys_cputs(buf, m);
  800f57:	83 c4 08             	add    $0x8,%esp
  800f5a:	53                   	push   %ebx
  800f5b:	57                   	push   %edi
  800f5c:	e8 64 f1 ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f61:	01 de                	add    %ebx,%esi
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	89 f0                	mov    %esi,%eax
  800f68:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f6b:	72 cc                	jb     800f39 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5f                   	pop    %edi
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    

00800f75 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f7b:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f84:	75 07                	jne    800f8d <devcons_read+0x18>
  800f86:	eb 28                	jmp    800fb0 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f88:	e8 d5 f1 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f8d:	e8 51 f1 ff ff       	call   8000e3 <sys_cgetc>
  800f92:	85 c0                	test   %eax,%eax
  800f94:	74 f2                	je     800f88 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f96:	85 c0                	test   %eax,%eax
  800f98:	78 16                	js     800fb0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f9a:	83 f8 04             	cmp    $0x4,%eax
  800f9d:	74 0c                	je     800fab <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa2:	88 02                	mov    %al,(%edx)
	return 1;
  800fa4:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa9:	eb 05                	jmp    800fb0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fab:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    

00800fb2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fbe:	6a 01                	push   $0x1
  800fc0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc3:	50                   	push   %eax
  800fc4:	e8 fc f0 ff ff       	call   8000c5 <sys_cputs>
  800fc9:	83 c4 10             	add    $0x10,%esp
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <getchar>:

int
getchar(void)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fd4:	6a 01                	push   $0x1
  800fd6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd9:	50                   	push   %eax
  800fda:	6a 00                	push   $0x0
  800fdc:	e8 71 f6 ff ff       	call   800652 <read>
	if (r < 0)
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	78 0f                	js     800ff7 <getchar+0x29>
		return r;
	if (r < 1)
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	7e 06                	jle    800ff2 <getchar+0x24>
		return -E_EOF;
	return c;
  800fec:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ff0:	eb 05                	jmp    800ff7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ff2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801002:	50                   	push   %eax
  801003:	ff 75 08             	pushl  0x8(%ebp)
  801006:	e8 dd f3 ff ff       	call   8003e8 <fd_lookup>
  80100b:	83 c4 10             	add    $0x10,%esp
  80100e:	85 c0                	test   %eax,%eax
  801010:	78 11                	js     801023 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801012:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801015:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80101b:	39 10                	cmp    %edx,(%eax)
  80101d:	0f 94 c0             	sete   %al
  801020:	0f b6 c0             	movzbl %al,%eax
}
  801023:	c9                   	leave  
  801024:	c3                   	ret    

00801025 <opencons>:

int
opencons(void)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80102b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102e:	50                   	push   %eax
  80102f:	e8 65 f3 ff ff       	call   800399 <fd_alloc>
  801034:	83 c4 10             	add    $0x10,%esp
		return r;
  801037:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801039:	85 c0                	test   %eax,%eax
  80103b:	78 3e                	js     80107b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80103d:	83 ec 04             	sub    $0x4,%esp
  801040:	68 07 04 00 00       	push   $0x407
  801045:	ff 75 f4             	pushl  -0xc(%ebp)
  801048:	6a 00                	push   $0x0
  80104a:	e8 32 f1 ff ff       	call   800181 <sys_page_alloc>
  80104f:	83 c4 10             	add    $0x10,%esp
		return r;
  801052:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801054:	85 c0                	test   %eax,%eax
  801056:	78 23                	js     80107b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801058:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80105e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801061:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801063:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801066:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	50                   	push   %eax
  801071:	e8 fc f2 ff ff       	call   800372 <fd2num>
  801076:	89 c2                	mov    %eax,%edx
  801078:	83 c4 10             	add    $0x10,%esp
}
  80107b:	89 d0                	mov    %edx,%eax
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	56                   	push   %esi
  801083:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801084:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801087:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80108d:	e8 b1 f0 ff ff       	call   800143 <sys_getenvid>
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	ff 75 0c             	pushl  0xc(%ebp)
  801098:	ff 75 08             	pushl  0x8(%ebp)
  80109b:	56                   	push   %esi
  80109c:	50                   	push   %eax
  80109d:	68 64 1f 80 00       	push   $0x801f64
  8010a2:	e8 b1 00 00 00       	call   801158 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a7:	83 c4 18             	add    $0x18,%esp
  8010aa:	53                   	push   %ebx
  8010ab:	ff 75 10             	pushl  0x10(%ebp)
  8010ae:	e8 54 00 00 00       	call   801107 <vcprintf>
	cprintf("\n");
  8010b3:	c7 04 24 4f 1f 80 00 	movl   $0x801f4f,(%esp)
  8010ba:	e8 99 00 00 00       	call   801158 <cprintf>
  8010bf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010c2:	cc                   	int3   
  8010c3:	eb fd                	jmp    8010c2 <_panic+0x43>

008010c5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	53                   	push   %ebx
  8010c9:	83 ec 04             	sub    $0x4,%esp
  8010cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010cf:	8b 13                	mov    (%ebx),%edx
  8010d1:	8d 42 01             	lea    0x1(%edx),%eax
  8010d4:	89 03                	mov    %eax,(%ebx)
  8010d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010dd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010e2:	75 1a                	jne    8010fe <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010e4:	83 ec 08             	sub    $0x8,%esp
  8010e7:	68 ff 00 00 00       	push   $0xff
  8010ec:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ef:	50                   	push   %eax
  8010f0:	e8 d0 ef ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8010f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010fb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010fe:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801105:	c9                   	leave  
  801106:	c3                   	ret    

00801107 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801110:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801117:	00 00 00 
	b.cnt = 0;
  80111a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801121:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801124:	ff 75 0c             	pushl  0xc(%ebp)
  801127:	ff 75 08             	pushl  0x8(%ebp)
  80112a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801130:	50                   	push   %eax
  801131:	68 c5 10 80 00       	push   $0x8010c5
  801136:	e8 4f 01 00 00       	call   80128a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80113b:	83 c4 08             	add    $0x8,%esp
  80113e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801144:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80114a:	50                   	push   %eax
  80114b:	e8 75 ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  801150:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801156:	c9                   	leave  
  801157:	c3                   	ret    

00801158 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80115e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801161:	50                   	push   %eax
  801162:	ff 75 08             	pushl  0x8(%ebp)
  801165:	e8 9d ff ff ff       	call   801107 <vcprintf>
	va_end(ap);

	return cnt;
}
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    

0080116c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	57                   	push   %edi
  801170:	56                   	push   %esi
  801171:	53                   	push   %ebx
  801172:	83 ec 1c             	sub    $0x1c,%esp
  801175:	89 c7                	mov    %eax,%edi
  801177:	89 d6                	mov    %edx,%esi
  801179:	8b 45 08             	mov    0x8(%ebp),%eax
  80117c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117f:	89 d1                	mov    %edx,%ecx
  801181:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801184:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801187:	8b 45 10             	mov    0x10(%ebp),%eax
  80118a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80118d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801190:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801197:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80119a:	72 05                	jb     8011a1 <printnum+0x35>
  80119c:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80119f:	77 3e                	ja     8011df <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	ff 75 18             	pushl  0x18(%ebp)
  8011a7:	83 eb 01             	sub    $0x1,%ebx
  8011aa:	53                   	push   %ebx
  8011ab:	50                   	push   %eax
  8011ac:	83 ec 08             	sub    $0x8,%esp
  8011af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8011bb:	e8 a0 09 00 00       	call   801b60 <__udivdi3>
  8011c0:	83 c4 18             	add    $0x18,%esp
  8011c3:	52                   	push   %edx
  8011c4:	50                   	push   %eax
  8011c5:	89 f2                	mov    %esi,%edx
  8011c7:	89 f8                	mov    %edi,%eax
  8011c9:	e8 9e ff ff ff       	call   80116c <printnum>
  8011ce:	83 c4 20             	add    $0x20,%esp
  8011d1:	eb 13                	jmp    8011e6 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011d3:	83 ec 08             	sub    $0x8,%esp
  8011d6:	56                   	push   %esi
  8011d7:	ff 75 18             	pushl  0x18(%ebp)
  8011da:	ff d7                	call   *%edi
  8011dc:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011df:	83 eb 01             	sub    $0x1,%ebx
  8011e2:	85 db                	test   %ebx,%ebx
  8011e4:	7f ed                	jg     8011d3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e6:	83 ec 08             	sub    $0x8,%esp
  8011e9:	56                   	push   %esi
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f9:	e8 92 0a 00 00       	call   801c90 <__umoddi3>
  8011fe:	83 c4 14             	add    $0x14,%esp
  801201:	0f be 80 87 1f 80 00 	movsbl 0x801f87(%eax),%eax
  801208:	50                   	push   %eax
  801209:	ff d7                	call   *%edi
  80120b:	83 c4 10             	add    $0x10,%esp
}
  80120e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801211:	5b                   	pop    %ebx
  801212:	5e                   	pop    %esi
  801213:	5f                   	pop    %edi
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801219:	83 fa 01             	cmp    $0x1,%edx
  80121c:	7e 0e                	jle    80122c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80121e:	8b 10                	mov    (%eax),%edx
  801220:	8d 4a 08             	lea    0x8(%edx),%ecx
  801223:	89 08                	mov    %ecx,(%eax)
  801225:	8b 02                	mov    (%edx),%eax
  801227:	8b 52 04             	mov    0x4(%edx),%edx
  80122a:	eb 22                	jmp    80124e <getuint+0x38>
	else if (lflag)
  80122c:	85 d2                	test   %edx,%edx
  80122e:	74 10                	je     801240 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801230:	8b 10                	mov    (%eax),%edx
  801232:	8d 4a 04             	lea    0x4(%edx),%ecx
  801235:	89 08                	mov    %ecx,(%eax)
  801237:	8b 02                	mov    (%edx),%eax
  801239:	ba 00 00 00 00       	mov    $0x0,%edx
  80123e:	eb 0e                	jmp    80124e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801240:	8b 10                	mov    (%eax),%edx
  801242:	8d 4a 04             	lea    0x4(%edx),%ecx
  801245:	89 08                	mov    %ecx,(%eax)
  801247:	8b 02                	mov    (%edx),%eax
  801249:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801256:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80125a:	8b 10                	mov    (%eax),%edx
  80125c:	3b 50 04             	cmp    0x4(%eax),%edx
  80125f:	73 0a                	jae    80126b <sprintputch+0x1b>
		*b->buf++ = ch;
  801261:	8d 4a 01             	lea    0x1(%edx),%ecx
  801264:	89 08                	mov    %ecx,(%eax)
  801266:	8b 45 08             	mov    0x8(%ebp),%eax
  801269:	88 02                	mov    %al,(%edx)
}
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801273:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801276:	50                   	push   %eax
  801277:	ff 75 10             	pushl  0x10(%ebp)
  80127a:	ff 75 0c             	pushl  0xc(%ebp)
  80127d:	ff 75 08             	pushl  0x8(%ebp)
  801280:	e8 05 00 00 00       	call   80128a <vprintfmt>
	va_end(ap);
  801285:	83 c4 10             	add    $0x10,%esp
}
  801288:	c9                   	leave  
  801289:	c3                   	ret    

0080128a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	57                   	push   %edi
  80128e:	56                   	push   %esi
  80128f:	53                   	push   %ebx
  801290:	83 ec 2c             	sub    $0x2c,%esp
  801293:	8b 75 08             	mov    0x8(%ebp),%esi
  801296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801299:	8b 7d 10             	mov    0x10(%ebp),%edi
  80129c:	eb 12                	jmp    8012b0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	0f 84 90 03 00 00    	je     801636 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8012a6:	83 ec 08             	sub    $0x8,%esp
  8012a9:	53                   	push   %ebx
  8012aa:	50                   	push   %eax
  8012ab:	ff d6                	call   *%esi
  8012ad:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012b0:	83 c7 01             	add    $0x1,%edi
  8012b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012b7:	83 f8 25             	cmp    $0x25,%eax
  8012ba:	75 e2                	jne    80129e <vprintfmt+0x14>
  8012bc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012c0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012c7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012da:	eb 07                	jmp    8012e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012df:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e3:	8d 47 01             	lea    0x1(%edi),%eax
  8012e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e9:	0f b6 07             	movzbl (%edi),%eax
  8012ec:	0f b6 c8             	movzbl %al,%ecx
  8012ef:	83 e8 23             	sub    $0x23,%eax
  8012f2:	3c 55                	cmp    $0x55,%al
  8012f4:	0f 87 21 03 00 00    	ja     80161b <vprintfmt+0x391>
  8012fa:	0f b6 c0             	movzbl %al,%eax
  8012fd:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  801304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801307:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80130b:	eb d6                	jmp    8012e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801310:	b8 00 00 00 00       	mov    $0x0,%eax
  801315:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801318:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80131b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80131f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801322:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801325:	83 fa 09             	cmp    $0x9,%edx
  801328:	77 39                	ja     801363 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80132a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80132d:	eb e9                	jmp    801318 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80132f:	8b 45 14             	mov    0x14(%ebp),%eax
  801332:	8d 48 04             	lea    0x4(%eax),%ecx
  801335:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801338:	8b 00                	mov    (%eax),%eax
  80133a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801340:	eb 27                	jmp    801369 <vprintfmt+0xdf>
  801342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801345:	85 c0                	test   %eax,%eax
  801347:	b9 00 00 00 00       	mov    $0x0,%ecx
  80134c:	0f 49 c8             	cmovns %eax,%ecx
  80134f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801355:	eb 8c                	jmp    8012e3 <vprintfmt+0x59>
  801357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80135a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801361:	eb 80                	jmp    8012e3 <vprintfmt+0x59>
  801363:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801366:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801369:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80136d:	0f 89 70 ff ff ff    	jns    8012e3 <vprintfmt+0x59>
				width = precision, precision = -1;
  801373:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801376:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801379:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801380:	e9 5e ff ff ff       	jmp    8012e3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801385:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80138b:	e9 53 ff ff ff       	jmp    8012e3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801390:	8b 45 14             	mov    0x14(%ebp),%eax
  801393:	8d 50 04             	lea    0x4(%eax),%edx
  801396:	89 55 14             	mov    %edx,0x14(%ebp)
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	53                   	push   %ebx
  80139d:	ff 30                	pushl  (%eax)
  80139f:	ff d6                	call   *%esi
			break;
  8013a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013a7:	e9 04 ff ff ff       	jmp    8012b0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8013af:	8d 50 04             	lea    0x4(%eax),%edx
  8013b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b5:	8b 00                	mov    (%eax),%eax
  8013b7:	99                   	cltd   
  8013b8:	31 d0                	xor    %edx,%eax
  8013ba:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013bc:	83 f8 0f             	cmp    $0xf,%eax
  8013bf:	7f 0b                	jg     8013cc <vprintfmt+0x142>
  8013c1:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  8013c8:	85 d2                	test   %edx,%edx
  8013ca:	75 18                	jne    8013e4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013cc:	50                   	push   %eax
  8013cd:	68 9f 1f 80 00       	push   $0x801f9f
  8013d2:	53                   	push   %ebx
  8013d3:	56                   	push   %esi
  8013d4:	e8 94 fe ff ff       	call   80126d <printfmt>
  8013d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013df:	e9 cc fe ff ff       	jmp    8012b0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013e4:	52                   	push   %edx
  8013e5:	68 1d 1f 80 00       	push   $0x801f1d
  8013ea:	53                   	push   %ebx
  8013eb:	56                   	push   %esi
  8013ec:	e8 7c fe ff ff       	call   80126d <printfmt>
  8013f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013f7:	e9 b4 fe ff ff       	jmp    8012b0 <vprintfmt+0x26>
  8013fc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801402:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801405:	8b 45 14             	mov    0x14(%ebp),%eax
  801408:	8d 50 04             	lea    0x4(%eax),%edx
  80140b:	89 55 14             	mov    %edx,0x14(%ebp)
  80140e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801410:	85 ff                	test   %edi,%edi
  801412:	ba 98 1f 80 00       	mov    $0x801f98,%edx
  801417:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80141a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80141e:	0f 84 92 00 00 00    	je     8014b6 <vprintfmt+0x22c>
  801424:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801428:	0f 8e 96 00 00 00    	jle    8014c4 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	51                   	push   %ecx
  801432:	57                   	push   %edi
  801433:	e8 86 02 00 00       	call   8016be <strnlen>
  801438:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80143b:	29 c1                	sub    %eax,%ecx
  80143d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801440:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801443:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801447:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80144a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80144d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80144f:	eb 0f                	jmp    801460 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	53                   	push   %ebx
  801455:	ff 75 e0             	pushl  -0x20(%ebp)
  801458:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80145a:	83 ef 01             	sub    $0x1,%edi
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	85 ff                	test   %edi,%edi
  801462:	7f ed                	jg     801451 <vprintfmt+0x1c7>
  801464:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801467:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80146a:	85 c9                	test   %ecx,%ecx
  80146c:	b8 00 00 00 00       	mov    $0x0,%eax
  801471:	0f 49 c1             	cmovns %ecx,%eax
  801474:	29 c1                	sub    %eax,%ecx
  801476:	89 75 08             	mov    %esi,0x8(%ebp)
  801479:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80147c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147f:	89 cb                	mov    %ecx,%ebx
  801481:	eb 4d                	jmp    8014d0 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801483:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801487:	74 1b                	je     8014a4 <vprintfmt+0x21a>
  801489:	0f be c0             	movsbl %al,%eax
  80148c:	83 e8 20             	sub    $0x20,%eax
  80148f:	83 f8 5e             	cmp    $0x5e,%eax
  801492:	76 10                	jbe    8014a4 <vprintfmt+0x21a>
					putch('?', putdat);
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	ff 75 0c             	pushl  0xc(%ebp)
  80149a:	6a 3f                	push   $0x3f
  80149c:	ff 55 08             	call   *0x8(%ebp)
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	eb 0d                	jmp    8014b1 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	ff 75 0c             	pushl  0xc(%ebp)
  8014aa:	52                   	push   %edx
  8014ab:	ff 55 08             	call   *0x8(%ebp)
  8014ae:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014b1:	83 eb 01             	sub    $0x1,%ebx
  8014b4:	eb 1a                	jmp    8014d0 <vprintfmt+0x246>
  8014b6:	89 75 08             	mov    %esi,0x8(%ebp)
  8014b9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014bc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014bf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014c2:	eb 0c                	jmp    8014d0 <vprintfmt+0x246>
  8014c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8014c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014cd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014d0:	83 c7 01             	add    $0x1,%edi
  8014d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014d7:	0f be d0             	movsbl %al,%edx
  8014da:	85 d2                	test   %edx,%edx
  8014dc:	74 23                	je     801501 <vprintfmt+0x277>
  8014de:	85 f6                	test   %esi,%esi
  8014e0:	78 a1                	js     801483 <vprintfmt+0x1f9>
  8014e2:	83 ee 01             	sub    $0x1,%esi
  8014e5:	79 9c                	jns    801483 <vprintfmt+0x1f9>
  8014e7:	89 df                	mov    %ebx,%edi
  8014e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014ef:	eb 18                	jmp    801509 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014f1:	83 ec 08             	sub    $0x8,%esp
  8014f4:	53                   	push   %ebx
  8014f5:	6a 20                	push   $0x20
  8014f7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014f9:	83 ef 01             	sub    $0x1,%edi
  8014fc:	83 c4 10             	add    $0x10,%esp
  8014ff:	eb 08                	jmp    801509 <vprintfmt+0x27f>
  801501:	89 df                	mov    %ebx,%edi
  801503:	8b 75 08             	mov    0x8(%ebp),%esi
  801506:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801509:	85 ff                	test   %edi,%edi
  80150b:	7f e4                	jg     8014f1 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80150d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801510:	e9 9b fd ff ff       	jmp    8012b0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801515:	83 fa 01             	cmp    $0x1,%edx
  801518:	7e 16                	jle    801530 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80151a:	8b 45 14             	mov    0x14(%ebp),%eax
  80151d:	8d 50 08             	lea    0x8(%eax),%edx
  801520:	89 55 14             	mov    %edx,0x14(%ebp)
  801523:	8b 50 04             	mov    0x4(%eax),%edx
  801526:	8b 00                	mov    (%eax),%eax
  801528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80152b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80152e:	eb 32                	jmp    801562 <vprintfmt+0x2d8>
	else if (lflag)
  801530:	85 d2                	test   %edx,%edx
  801532:	74 18                	je     80154c <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801534:	8b 45 14             	mov    0x14(%ebp),%eax
  801537:	8d 50 04             	lea    0x4(%eax),%edx
  80153a:	89 55 14             	mov    %edx,0x14(%ebp)
  80153d:	8b 00                	mov    (%eax),%eax
  80153f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801542:	89 c1                	mov    %eax,%ecx
  801544:	c1 f9 1f             	sar    $0x1f,%ecx
  801547:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80154a:	eb 16                	jmp    801562 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80154c:	8b 45 14             	mov    0x14(%ebp),%eax
  80154f:	8d 50 04             	lea    0x4(%eax),%edx
  801552:	89 55 14             	mov    %edx,0x14(%ebp)
  801555:	8b 00                	mov    (%eax),%eax
  801557:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80155a:	89 c1                	mov    %eax,%ecx
  80155c:	c1 f9 1f             	sar    $0x1f,%ecx
  80155f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801562:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801565:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801568:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80156d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801571:	79 74                	jns    8015e7 <vprintfmt+0x35d>
				putch('-', putdat);
  801573:	83 ec 08             	sub    $0x8,%esp
  801576:	53                   	push   %ebx
  801577:	6a 2d                	push   $0x2d
  801579:	ff d6                	call   *%esi
				num = -(long long) num;
  80157b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80157e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801581:	f7 d8                	neg    %eax
  801583:	83 d2 00             	adc    $0x0,%edx
  801586:	f7 da                	neg    %edx
  801588:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80158b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801590:	eb 55                	jmp    8015e7 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801592:	8d 45 14             	lea    0x14(%ebp),%eax
  801595:	e8 7c fc ff ff       	call   801216 <getuint>
			base = 10;
  80159a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80159f:	eb 46                	jmp    8015e7 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8015a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a4:	e8 6d fc ff ff       	call   801216 <getuint>
                        base = 8;
  8015a9:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8015ae:	eb 37                	jmp    8015e7 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	53                   	push   %ebx
  8015b4:	6a 30                	push   $0x30
  8015b6:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b8:	83 c4 08             	add    $0x8,%esp
  8015bb:	53                   	push   %ebx
  8015bc:	6a 78                	push   $0x78
  8015be:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c3:	8d 50 04             	lea    0x4(%eax),%edx
  8015c6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015c9:	8b 00                	mov    (%eax),%eax
  8015cb:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015d0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015d3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015d8:	eb 0d                	jmp    8015e7 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015da:	8d 45 14             	lea    0x14(%ebp),%eax
  8015dd:	e8 34 fc ff ff       	call   801216 <getuint>
			base = 16;
  8015e2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015ee:	57                   	push   %edi
  8015ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f2:	51                   	push   %ecx
  8015f3:	52                   	push   %edx
  8015f4:	50                   	push   %eax
  8015f5:	89 da                	mov    %ebx,%edx
  8015f7:	89 f0                	mov    %esi,%eax
  8015f9:	e8 6e fb ff ff       	call   80116c <printnum>
			break;
  8015fe:	83 c4 20             	add    $0x20,%esp
  801601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801604:	e9 a7 fc ff ff       	jmp    8012b0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	53                   	push   %ebx
  80160d:	51                   	push   %ecx
  80160e:	ff d6                	call   *%esi
			break;
  801610:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801616:	e9 95 fc ff ff       	jmp    8012b0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	53                   	push   %ebx
  80161f:	6a 25                	push   $0x25
  801621:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	eb 03                	jmp    80162b <vprintfmt+0x3a1>
  801628:	83 ef 01             	sub    $0x1,%edi
  80162b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80162f:	75 f7                	jne    801628 <vprintfmt+0x39e>
  801631:	e9 7a fc ff ff       	jmp    8012b0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801636:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801639:	5b                   	pop    %ebx
  80163a:	5e                   	pop    %esi
  80163b:	5f                   	pop    %edi
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	83 ec 18             	sub    $0x18,%esp
  801644:	8b 45 08             	mov    0x8(%ebp),%eax
  801647:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80164a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80164d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801651:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801654:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80165b:	85 c0                	test   %eax,%eax
  80165d:	74 26                	je     801685 <vsnprintf+0x47>
  80165f:	85 d2                	test   %edx,%edx
  801661:	7e 22                	jle    801685 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801663:	ff 75 14             	pushl  0x14(%ebp)
  801666:	ff 75 10             	pushl  0x10(%ebp)
  801669:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	68 50 12 80 00       	push   $0x801250
  801672:	e8 13 fc ff ff       	call   80128a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801677:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80167a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80167d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	eb 05                	jmp    80168a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801685:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801692:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801695:	50                   	push   %eax
  801696:	ff 75 10             	pushl  0x10(%ebp)
  801699:	ff 75 0c             	pushl  0xc(%ebp)
  80169c:	ff 75 08             	pushl  0x8(%ebp)
  80169f:	e8 9a ff ff ff       	call   80163e <vsnprintf>
	va_end(ap);

	return rc;
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b1:	eb 03                	jmp    8016b6 <strlen+0x10>
		n++;
  8016b3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016ba:	75 f7                	jne    8016b3 <strlen+0xd>
		n++;
	return n;
}
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cc:	eb 03                	jmp    8016d1 <strnlen+0x13>
		n++;
  8016ce:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d1:	39 c2                	cmp    %eax,%edx
  8016d3:	74 08                	je     8016dd <strnlen+0x1f>
  8016d5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016d9:	75 f3                	jne    8016ce <strnlen+0x10>
  8016db:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016dd:	5d                   	pop    %ebp
  8016de:	c3                   	ret    

008016df <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	53                   	push   %ebx
  8016e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	83 c2 01             	add    $0x1,%edx
  8016ee:	83 c1 01             	add    $0x1,%ecx
  8016f1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016f5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016f8:	84 db                	test   %bl,%bl
  8016fa:	75 ef                	jne    8016eb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016fc:	5b                   	pop    %ebx
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    

008016ff <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	53                   	push   %ebx
  801703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801706:	53                   	push   %ebx
  801707:	e8 9a ff ff ff       	call   8016a6 <strlen>
  80170c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80170f:	ff 75 0c             	pushl  0xc(%ebp)
  801712:	01 d8                	add    %ebx,%eax
  801714:	50                   	push   %eax
  801715:	e8 c5 ff ff ff       	call   8016df <strcpy>
	return dst;
}
  80171a:	89 d8                	mov    %ebx,%eax
  80171c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	56                   	push   %esi
  801725:	53                   	push   %ebx
  801726:	8b 75 08             	mov    0x8(%ebp),%esi
  801729:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172c:	89 f3                	mov    %esi,%ebx
  80172e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801731:	89 f2                	mov    %esi,%edx
  801733:	eb 0f                	jmp    801744 <strncpy+0x23>
		*dst++ = *src;
  801735:	83 c2 01             	add    $0x1,%edx
  801738:	0f b6 01             	movzbl (%ecx),%eax
  80173b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80173e:	80 39 01             	cmpb   $0x1,(%ecx)
  801741:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801744:	39 da                	cmp    %ebx,%edx
  801746:	75 ed                	jne    801735 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801748:	89 f0                	mov    %esi,%eax
  80174a:	5b                   	pop    %ebx
  80174b:	5e                   	pop    %esi
  80174c:	5d                   	pop    %ebp
  80174d:	c3                   	ret    

0080174e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	56                   	push   %esi
  801752:	53                   	push   %ebx
  801753:	8b 75 08             	mov    0x8(%ebp),%esi
  801756:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801759:	8b 55 10             	mov    0x10(%ebp),%edx
  80175c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80175e:	85 d2                	test   %edx,%edx
  801760:	74 21                	je     801783 <strlcpy+0x35>
  801762:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801766:	89 f2                	mov    %esi,%edx
  801768:	eb 09                	jmp    801773 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80176a:	83 c2 01             	add    $0x1,%edx
  80176d:	83 c1 01             	add    $0x1,%ecx
  801770:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801773:	39 c2                	cmp    %eax,%edx
  801775:	74 09                	je     801780 <strlcpy+0x32>
  801777:	0f b6 19             	movzbl (%ecx),%ebx
  80177a:	84 db                	test   %bl,%bl
  80177c:	75 ec                	jne    80176a <strlcpy+0x1c>
  80177e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801780:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801783:	29 f0                	sub    %esi,%eax
}
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801792:	eb 06                	jmp    80179a <strcmp+0x11>
		p++, q++;
  801794:	83 c1 01             	add    $0x1,%ecx
  801797:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80179a:	0f b6 01             	movzbl (%ecx),%eax
  80179d:	84 c0                	test   %al,%al
  80179f:	74 04                	je     8017a5 <strcmp+0x1c>
  8017a1:	3a 02                	cmp    (%edx),%al
  8017a3:	74 ef                	je     801794 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a5:	0f b6 c0             	movzbl %al,%eax
  8017a8:	0f b6 12             	movzbl (%edx),%edx
  8017ab:	29 d0                	sub    %edx,%eax
}
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	53                   	push   %ebx
  8017b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b9:	89 c3                	mov    %eax,%ebx
  8017bb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017be:	eb 06                	jmp    8017c6 <strncmp+0x17>
		n--, p++, q++;
  8017c0:	83 c0 01             	add    $0x1,%eax
  8017c3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017c6:	39 d8                	cmp    %ebx,%eax
  8017c8:	74 15                	je     8017df <strncmp+0x30>
  8017ca:	0f b6 08             	movzbl (%eax),%ecx
  8017cd:	84 c9                	test   %cl,%cl
  8017cf:	74 04                	je     8017d5 <strncmp+0x26>
  8017d1:	3a 0a                	cmp    (%edx),%cl
  8017d3:	74 eb                	je     8017c0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d5:	0f b6 00             	movzbl (%eax),%eax
  8017d8:	0f b6 12             	movzbl (%edx),%edx
  8017db:	29 d0                	sub    %edx,%eax
  8017dd:	eb 05                	jmp    8017e4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017df:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017e4:	5b                   	pop    %ebx
  8017e5:	5d                   	pop    %ebp
  8017e6:	c3                   	ret    

008017e7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f1:	eb 07                	jmp    8017fa <strchr+0x13>
		if (*s == c)
  8017f3:	38 ca                	cmp    %cl,%dl
  8017f5:	74 0f                	je     801806 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017f7:	83 c0 01             	add    $0x1,%eax
  8017fa:	0f b6 10             	movzbl (%eax),%edx
  8017fd:	84 d2                	test   %dl,%dl
  8017ff:	75 f2                	jne    8017f3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801801:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    

00801808 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801812:	eb 03                	jmp    801817 <strfind+0xf>
  801814:	83 c0 01             	add    $0x1,%eax
  801817:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80181a:	84 d2                	test   %dl,%dl
  80181c:	74 04                	je     801822 <strfind+0x1a>
  80181e:	38 ca                	cmp    %cl,%dl
  801820:	75 f2                	jne    801814 <strfind+0xc>
			break;
	return (char *) s;
}
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	57                   	push   %edi
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80182d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801830:	85 c9                	test   %ecx,%ecx
  801832:	74 36                	je     80186a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801834:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80183a:	75 28                	jne    801864 <memset+0x40>
  80183c:	f6 c1 03             	test   $0x3,%cl
  80183f:	75 23                	jne    801864 <memset+0x40>
		c &= 0xFF;
  801841:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801845:	89 d3                	mov    %edx,%ebx
  801847:	c1 e3 08             	shl    $0x8,%ebx
  80184a:	89 d6                	mov    %edx,%esi
  80184c:	c1 e6 18             	shl    $0x18,%esi
  80184f:	89 d0                	mov    %edx,%eax
  801851:	c1 e0 10             	shl    $0x10,%eax
  801854:	09 f0                	or     %esi,%eax
  801856:	09 c2                	or     %eax,%edx
  801858:	89 d0                	mov    %edx,%eax
  80185a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80185c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80185f:	fc                   	cld    
  801860:	f3 ab                	rep stos %eax,%es:(%edi)
  801862:	eb 06                	jmp    80186a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801864:	8b 45 0c             	mov    0xc(%ebp),%eax
  801867:	fc                   	cld    
  801868:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80186a:	89 f8                	mov    %edi,%eax
  80186c:	5b                   	pop    %ebx
  80186d:	5e                   	pop    %esi
  80186e:	5f                   	pop    %edi
  80186f:	5d                   	pop    %ebp
  801870:	c3                   	ret    

00801871 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	57                   	push   %edi
  801875:	56                   	push   %esi
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	8b 75 0c             	mov    0xc(%ebp),%esi
  80187c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80187f:	39 c6                	cmp    %eax,%esi
  801881:	73 35                	jae    8018b8 <memmove+0x47>
  801883:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801886:	39 d0                	cmp    %edx,%eax
  801888:	73 2e                	jae    8018b8 <memmove+0x47>
		s += n;
		d += n;
  80188a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80188d:	89 d6                	mov    %edx,%esi
  80188f:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801891:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801897:	75 13                	jne    8018ac <memmove+0x3b>
  801899:	f6 c1 03             	test   $0x3,%cl
  80189c:	75 0e                	jne    8018ac <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80189e:	83 ef 04             	sub    $0x4,%edi
  8018a1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8018a7:	fd                   	std    
  8018a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018aa:	eb 09                	jmp    8018b5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018ac:	83 ef 01             	sub    $0x1,%edi
  8018af:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018b2:	fd                   	std    
  8018b3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b5:	fc                   	cld    
  8018b6:	eb 1d                	jmp    8018d5 <memmove+0x64>
  8018b8:	89 f2                	mov    %esi,%edx
  8018ba:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018bc:	f6 c2 03             	test   $0x3,%dl
  8018bf:	75 0f                	jne    8018d0 <memmove+0x5f>
  8018c1:	f6 c1 03             	test   $0x3,%cl
  8018c4:	75 0a                	jne    8018d0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018c6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018c9:	89 c7                	mov    %eax,%edi
  8018cb:	fc                   	cld    
  8018cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ce:	eb 05                	jmp    8018d5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d0:	89 c7                	mov    %eax,%edi
  8018d2:	fc                   	cld    
  8018d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d5:	5e                   	pop    %esi
  8018d6:	5f                   	pop    %edi
  8018d7:	5d                   	pop    %ebp
  8018d8:	c3                   	ret    

008018d9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018dc:	ff 75 10             	pushl  0x10(%ebp)
  8018df:	ff 75 0c             	pushl  0xc(%ebp)
  8018e2:	ff 75 08             	pushl  0x8(%ebp)
  8018e5:	e8 87 ff ff ff       	call   801871 <memmove>
}
  8018ea:	c9                   	leave  
  8018eb:	c3                   	ret    

008018ec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f7:	89 c6                	mov    %eax,%esi
  8018f9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018fc:	eb 1a                	jmp    801918 <memcmp+0x2c>
		if (*s1 != *s2)
  8018fe:	0f b6 08             	movzbl (%eax),%ecx
  801901:	0f b6 1a             	movzbl (%edx),%ebx
  801904:	38 d9                	cmp    %bl,%cl
  801906:	74 0a                	je     801912 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801908:	0f b6 c1             	movzbl %cl,%eax
  80190b:	0f b6 db             	movzbl %bl,%ebx
  80190e:	29 d8                	sub    %ebx,%eax
  801910:	eb 0f                	jmp    801921 <memcmp+0x35>
		s1++, s2++;
  801912:	83 c0 01             	add    $0x1,%eax
  801915:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801918:	39 f0                	cmp    %esi,%eax
  80191a:	75 e2                	jne    8018fe <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80191c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801921:	5b                   	pop    %ebx
  801922:	5e                   	pop    %esi
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    

00801925 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	8b 45 08             	mov    0x8(%ebp),%eax
  80192b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80192e:	89 c2                	mov    %eax,%edx
  801930:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801933:	eb 07                	jmp    80193c <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801935:	38 08                	cmp    %cl,(%eax)
  801937:	74 07                	je     801940 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801939:	83 c0 01             	add    $0x1,%eax
  80193c:	39 d0                	cmp    %edx,%eax
  80193e:	72 f5                	jb     801935 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801940:	5d                   	pop    %ebp
  801941:	c3                   	ret    

00801942 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	57                   	push   %edi
  801946:	56                   	push   %esi
  801947:	53                   	push   %ebx
  801948:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80194e:	eb 03                	jmp    801953 <strtol+0x11>
		s++;
  801950:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801953:	0f b6 01             	movzbl (%ecx),%eax
  801956:	3c 09                	cmp    $0x9,%al
  801958:	74 f6                	je     801950 <strtol+0xe>
  80195a:	3c 20                	cmp    $0x20,%al
  80195c:	74 f2                	je     801950 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80195e:	3c 2b                	cmp    $0x2b,%al
  801960:	75 0a                	jne    80196c <strtol+0x2a>
		s++;
  801962:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801965:	bf 00 00 00 00       	mov    $0x0,%edi
  80196a:	eb 10                	jmp    80197c <strtol+0x3a>
  80196c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801971:	3c 2d                	cmp    $0x2d,%al
  801973:	75 07                	jne    80197c <strtol+0x3a>
		s++, neg = 1;
  801975:	8d 49 01             	lea    0x1(%ecx),%ecx
  801978:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197c:	85 db                	test   %ebx,%ebx
  80197e:	0f 94 c0             	sete   %al
  801981:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801987:	75 19                	jne    8019a2 <strtol+0x60>
  801989:	80 39 30             	cmpb   $0x30,(%ecx)
  80198c:	75 14                	jne    8019a2 <strtol+0x60>
  80198e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801992:	0f 85 82 00 00 00    	jne    801a1a <strtol+0xd8>
		s += 2, base = 16;
  801998:	83 c1 02             	add    $0x2,%ecx
  80199b:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a0:	eb 16                	jmp    8019b8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019a2:	84 c0                	test   %al,%al
  8019a4:	74 12                	je     8019b8 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019a6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ab:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ae:	75 08                	jne    8019b8 <strtol+0x76>
		s++, base = 8;
  8019b0:	83 c1 01             	add    $0x1,%ecx
  8019b3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019c0:	0f b6 11             	movzbl (%ecx),%edx
  8019c3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019c6:	89 f3                	mov    %esi,%ebx
  8019c8:	80 fb 09             	cmp    $0x9,%bl
  8019cb:	77 08                	ja     8019d5 <strtol+0x93>
			dig = *s - '0';
  8019cd:	0f be d2             	movsbl %dl,%edx
  8019d0:	83 ea 30             	sub    $0x30,%edx
  8019d3:	eb 22                	jmp    8019f7 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019d5:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019d8:	89 f3                	mov    %esi,%ebx
  8019da:	80 fb 19             	cmp    $0x19,%bl
  8019dd:	77 08                	ja     8019e7 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019df:	0f be d2             	movsbl %dl,%edx
  8019e2:	83 ea 57             	sub    $0x57,%edx
  8019e5:	eb 10                	jmp    8019f7 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019e7:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019ea:	89 f3                	mov    %esi,%ebx
  8019ec:	80 fb 19             	cmp    $0x19,%bl
  8019ef:	77 16                	ja     801a07 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019f1:	0f be d2             	movsbl %dl,%edx
  8019f4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019f7:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019fa:	7d 0f                	jge    801a0b <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019fc:	83 c1 01             	add    $0x1,%ecx
  8019ff:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a03:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a05:	eb b9                	jmp    8019c0 <strtol+0x7e>
  801a07:	89 c2                	mov    %eax,%edx
  801a09:	eb 02                	jmp    801a0d <strtol+0xcb>
  801a0b:	89 c2                	mov    %eax,%edx

	if (endptr)
  801a0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a11:	74 0d                	je     801a20 <strtol+0xde>
		*endptr = (char *) s;
  801a13:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a16:	89 0e                	mov    %ecx,(%esi)
  801a18:	eb 06                	jmp    801a20 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a1a:	84 c0                	test   %al,%al
  801a1c:	75 92                	jne    8019b0 <strtol+0x6e>
  801a1e:	eb 98                	jmp    8019b8 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a20:	f7 da                	neg    %edx
  801a22:	85 ff                	test   %edi,%edi
  801a24:	0f 45 c2             	cmovne %edx,%eax
}
  801a27:	5b                   	pop    %ebx
  801a28:	5e                   	pop    %esi
  801a29:	5f                   	pop    %edi
  801a2a:	5d                   	pop    %ebp
  801a2b:	c3                   	ret    

00801a2c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	56                   	push   %esi
  801a30:	53                   	push   %ebx
  801a31:	8b 75 08             	mov    0x8(%ebp),%esi
  801a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a41:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	50                   	push   %eax
  801a48:	e8 e4 e8 ff ff       	call   800331 <sys_ipc_recv>
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	85 c0                	test   %eax,%eax
  801a52:	79 16                	jns    801a6a <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801a54:	85 f6                	test   %esi,%esi
  801a56:	74 06                	je     801a5e <ipc_recv+0x32>
  801a58:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801a5e:	85 db                	test   %ebx,%ebx
  801a60:	74 2c                	je     801a8e <ipc_recv+0x62>
  801a62:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a68:	eb 24                	jmp    801a8e <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a6a:	85 f6                	test   %esi,%esi
  801a6c:	74 0a                	je     801a78 <ipc_recv+0x4c>
  801a6e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a73:	8b 40 74             	mov    0x74(%eax),%eax
  801a76:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801a78:	85 db                	test   %ebx,%ebx
  801a7a:	74 0a                	je     801a86 <ipc_recv+0x5a>
  801a7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a81:	8b 40 78             	mov    0x78(%eax),%eax
  801a84:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801a86:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5e                   	pop    %esi
  801a93:	5d                   	pop    %ebp
  801a94:	c3                   	ret    

00801a95 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	57                   	push   %edi
  801a99:	56                   	push   %esi
  801a9a:	53                   	push   %ebx
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801aa7:	85 db                	test   %ebx,%ebx
  801aa9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801aae:	0f 44 d8             	cmove  %eax,%ebx
  801ab1:	eb 1c                	jmp    801acf <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801ab3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ab6:	74 12                	je     801aca <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801ab8:	50                   	push   %eax
  801ab9:	68 a0 22 80 00       	push   $0x8022a0
  801abe:	6a 39                	push   $0x39
  801ac0:	68 bb 22 80 00       	push   $0x8022bb
  801ac5:	e8 b5 f5 ff ff       	call   80107f <_panic>
                 sys_yield();
  801aca:	e8 93 e6 ff ff       	call   800162 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801acf:	ff 75 14             	pushl  0x14(%ebp)
  801ad2:	53                   	push   %ebx
  801ad3:	56                   	push   %esi
  801ad4:	57                   	push   %edi
  801ad5:	e8 34 e8 ff ff       	call   80030e <sys_ipc_try_send>
  801ada:	83 c4 10             	add    $0x10,%esp
  801add:	85 c0                	test   %eax,%eax
  801adf:	78 d2                	js     801ab3 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801ae1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae4:	5b                   	pop    %ebx
  801ae5:	5e                   	pop    %esi
  801ae6:	5f                   	pop    %edi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801aef:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801af4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801af7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801afd:	8b 52 50             	mov    0x50(%edx),%edx
  801b00:	39 ca                	cmp    %ecx,%edx
  801b02:	75 0d                	jne    801b11 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b04:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b07:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801b0c:	8b 40 08             	mov    0x8(%eax),%eax
  801b0f:	eb 0e                	jmp    801b1f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b11:	83 c0 01             	add    $0x1,%eax
  801b14:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b19:	75 d9                	jne    801af4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b1b:	66 b8 00 00          	mov    $0x0,%ax
}
  801b1f:	5d                   	pop    %ebp
  801b20:	c3                   	ret    

00801b21 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b27:	89 d0                	mov    %edx,%eax
  801b29:	c1 e8 16             	shr    $0x16,%eax
  801b2c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b33:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b38:	f6 c1 01             	test   $0x1,%cl
  801b3b:	74 1d                	je     801b5a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b3d:	c1 ea 0c             	shr    $0xc,%edx
  801b40:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b47:	f6 c2 01             	test   $0x1,%dl
  801b4a:	74 0e                	je     801b5a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b4c:	c1 ea 0c             	shr    $0xc,%edx
  801b4f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b56:	ef 
  801b57:	0f b7 c0             	movzwl %ax,%eax
}
  801b5a:	5d                   	pop    %ebp
  801b5b:	c3                   	ret    
  801b5c:	66 90                	xchg   %ax,%ax
  801b5e:	66 90                	xchg   %ax,%ax

00801b60 <__udivdi3>:
  801b60:	55                   	push   %ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	83 ec 10             	sub    $0x10,%esp
  801b66:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b6a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b6e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b72:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b76:	85 d2                	test   %edx,%edx
  801b78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b7c:	89 34 24             	mov    %esi,(%esp)
  801b7f:	89 c8                	mov    %ecx,%eax
  801b81:	75 35                	jne    801bb8 <__udivdi3+0x58>
  801b83:	39 f1                	cmp    %esi,%ecx
  801b85:	0f 87 bd 00 00 00    	ja     801c48 <__udivdi3+0xe8>
  801b8b:	85 c9                	test   %ecx,%ecx
  801b8d:	89 cd                	mov    %ecx,%ebp
  801b8f:	75 0b                	jne    801b9c <__udivdi3+0x3c>
  801b91:	b8 01 00 00 00       	mov    $0x1,%eax
  801b96:	31 d2                	xor    %edx,%edx
  801b98:	f7 f1                	div    %ecx
  801b9a:	89 c5                	mov    %eax,%ebp
  801b9c:	89 f0                	mov    %esi,%eax
  801b9e:	31 d2                	xor    %edx,%edx
  801ba0:	f7 f5                	div    %ebp
  801ba2:	89 c6                	mov    %eax,%esi
  801ba4:	89 f8                	mov    %edi,%eax
  801ba6:	f7 f5                	div    %ebp
  801ba8:	89 f2                	mov    %esi,%edx
  801baa:	83 c4 10             	add    $0x10,%esp
  801bad:	5e                   	pop    %esi
  801bae:	5f                   	pop    %edi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    
  801bb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bb8:	3b 14 24             	cmp    (%esp),%edx
  801bbb:	77 7b                	ja     801c38 <__udivdi3+0xd8>
  801bbd:	0f bd f2             	bsr    %edx,%esi
  801bc0:	83 f6 1f             	xor    $0x1f,%esi
  801bc3:	0f 84 97 00 00 00    	je     801c60 <__udivdi3+0x100>
  801bc9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801bce:	89 d7                	mov    %edx,%edi
  801bd0:	89 f1                	mov    %esi,%ecx
  801bd2:	29 f5                	sub    %esi,%ebp
  801bd4:	d3 e7                	shl    %cl,%edi
  801bd6:	89 c2                	mov    %eax,%edx
  801bd8:	89 e9                	mov    %ebp,%ecx
  801bda:	d3 ea                	shr    %cl,%edx
  801bdc:	89 f1                	mov    %esi,%ecx
  801bde:	09 fa                	or     %edi,%edx
  801be0:	8b 3c 24             	mov    (%esp),%edi
  801be3:	d3 e0                	shl    %cl,%eax
  801be5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801be9:	89 e9                	mov    %ebp,%ecx
  801beb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bef:	8b 44 24 04          	mov    0x4(%esp),%eax
  801bf3:	89 fa                	mov    %edi,%edx
  801bf5:	d3 ea                	shr    %cl,%edx
  801bf7:	89 f1                	mov    %esi,%ecx
  801bf9:	d3 e7                	shl    %cl,%edi
  801bfb:	89 e9                	mov    %ebp,%ecx
  801bfd:	d3 e8                	shr    %cl,%eax
  801bff:	09 c7                	or     %eax,%edi
  801c01:	89 f8                	mov    %edi,%eax
  801c03:	f7 74 24 08          	divl   0x8(%esp)
  801c07:	89 d5                	mov    %edx,%ebp
  801c09:	89 c7                	mov    %eax,%edi
  801c0b:	f7 64 24 0c          	mull   0xc(%esp)
  801c0f:	39 d5                	cmp    %edx,%ebp
  801c11:	89 14 24             	mov    %edx,(%esp)
  801c14:	72 11                	jb     801c27 <__udivdi3+0xc7>
  801c16:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c1a:	89 f1                	mov    %esi,%ecx
  801c1c:	d3 e2                	shl    %cl,%edx
  801c1e:	39 c2                	cmp    %eax,%edx
  801c20:	73 5e                	jae    801c80 <__udivdi3+0x120>
  801c22:	3b 2c 24             	cmp    (%esp),%ebp
  801c25:	75 59                	jne    801c80 <__udivdi3+0x120>
  801c27:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c2a:	31 f6                	xor    %esi,%esi
  801c2c:	89 f2                	mov    %esi,%edx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    
  801c35:	8d 76 00             	lea    0x0(%esi),%esi
  801c38:	31 f6                	xor    %esi,%esi
  801c3a:	31 c0                	xor    %eax,%eax
  801c3c:	89 f2                	mov    %esi,%edx
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	5e                   	pop    %esi
  801c42:	5f                   	pop    %edi
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    
  801c45:	8d 76 00             	lea    0x0(%esi),%esi
  801c48:	89 f2                	mov    %esi,%edx
  801c4a:	31 f6                	xor    %esi,%esi
  801c4c:	89 f8                	mov    %edi,%eax
  801c4e:	f7 f1                	div    %ecx
  801c50:	89 f2                	mov    %esi,%edx
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	5e                   	pop    %esi
  801c56:	5f                   	pop    %edi
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    
  801c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c60:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c64:	76 0b                	jbe    801c71 <__udivdi3+0x111>
  801c66:	31 c0                	xor    %eax,%eax
  801c68:	3b 14 24             	cmp    (%esp),%edx
  801c6b:	0f 83 37 ff ff ff    	jae    801ba8 <__udivdi3+0x48>
  801c71:	b8 01 00 00 00       	mov    $0x1,%eax
  801c76:	e9 2d ff ff ff       	jmp    801ba8 <__udivdi3+0x48>
  801c7b:	90                   	nop
  801c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c80:	89 f8                	mov    %edi,%eax
  801c82:	31 f6                	xor    %esi,%esi
  801c84:	e9 1f ff ff ff       	jmp    801ba8 <__udivdi3+0x48>
  801c89:	66 90                	xchg   %ax,%ax
  801c8b:	66 90                	xchg   %ax,%ax
  801c8d:	66 90                	xchg   %ax,%ax
  801c8f:	90                   	nop

00801c90 <__umoddi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	83 ec 20             	sub    $0x20,%esp
  801c96:	8b 44 24 34          	mov    0x34(%esp),%eax
  801c9a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c9e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca2:	89 c6                	mov    %eax,%esi
  801ca4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ca8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801cb0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801cb4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801cb8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	89 c2                	mov    %eax,%edx
  801cc0:	75 1e                	jne    801ce0 <__umoddi3+0x50>
  801cc2:	39 f7                	cmp    %esi,%edi
  801cc4:	76 52                	jbe    801d18 <__umoddi3+0x88>
  801cc6:	89 c8                	mov    %ecx,%eax
  801cc8:	89 f2                	mov    %esi,%edx
  801cca:	f7 f7                	div    %edi
  801ccc:	89 d0                	mov    %edx,%eax
  801cce:	31 d2                	xor    %edx,%edx
  801cd0:	83 c4 20             	add    $0x20,%esp
  801cd3:	5e                   	pop    %esi
  801cd4:	5f                   	pop    %edi
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    
  801cd7:	89 f6                	mov    %esi,%esi
  801cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801ce0:	39 f0                	cmp    %esi,%eax
  801ce2:	77 5c                	ja     801d40 <__umoddi3+0xb0>
  801ce4:	0f bd e8             	bsr    %eax,%ebp
  801ce7:	83 f5 1f             	xor    $0x1f,%ebp
  801cea:	75 64                	jne    801d50 <__umoddi3+0xc0>
  801cec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801cf0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801cf4:	0f 86 f6 00 00 00    	jbe    801df0 <__umoddi3+0x160>
  801cfa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cfe:	0f 82 ec 00 00 00    	jb     801df0 <__umoddi3+0x160>
  801d04:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d08:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d0c:	83 c4 20             	add    $0x20,%esp
  801d0f:	5e                   	pop    %esi
  801d10:	5f                   	pop    %edi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    
  801d13:	90                   	nop
  801d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d18:	85 ff                	test   %edi,%edi
  801d1a:	89 fd                	mov    %edi,%ebp
  801d1c:	75 0b                	jne    801d29 <__umoddi3+0x99>
  801d1e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d23:	31 d2                	xor    %edx,%edx
  801d25:	f7 f7                	div    %edi
  801d27:	89 c5                	mov    %eax,%ebp
  801d29:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d2d:	31 d2                	xor    %edx,%edx
  801d2f:	f7 f5                	div    %ebp
  801d31:	89 c8                	mov    %ecx,%eax
  801d33:	f7 f5                	div    %ebp
  801d35:	eb 95                	jmp    801ccc <__umoddi3+0x3c>
  801d37:	89 f6                	mov    %esi,%esi
  801d39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d40:	89 c8                	mov    %ecx,%eax
  801d42:	89 f2                	mov    %esi,%edx
  801d44:	83 c4 20             	add    $0x20,%esp
  801d47:	5e                   	pop    %esi
  801d48:	5f                   	pop    %edi
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    
  801d4b:	90                   	nop
  801d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d50:	b8 20 00 00 00       	mov    $0x20,%eax
  801d55:	89 e9                	mov    %ebp,%ecx
  801d57:	29 e8                	sub    %ebp,%eax
  801d59:	d3 e2                	shl    %cl,%edx
  801d5b:	89 c7                	mov    %eax,%edi
  801d5d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d61:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d65:	89 f9                	mov    %edi,%ecx
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 c1                	mov    %eax,%ecx
  801d6b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d6f:	09 d1                	or     %edx,%ecx
  801d71:	89 fa                	mov    %edi,%edx
  801d73:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d77:	89 e9                	mov    %ebp,%ecx
  801d79:	d3 e0                	shl    %cl,%eax
  801d7b:	89 f9                	mov    %edi,%ecx
  801d7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	d3 e8                	shr    %cl,%eax
  801d85:	89 e9                	mov    %ebp,%ecx
  801d87:	89 c7                	mov    %eax,%edi
  801d89:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d8d:	d3 e6                	shl    %cl,%esi
  801d8f:	89 d1                	mov    %edx,%ecx
  801d91:	89 fa                	mov    %edi,%edx
  801d93:	d3 e8                	shr    %cl,%eax
  801d95:	89 e9                	mov    %ebp,%ecx
  801d97:	09 f0                	or     %esi,%eax
  801d99:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801d9d:	f7 74 24 10          	divl   0x10(%esp)
  801da1:	d3 e6                	shl    %cl,%esi
  801da3:	89 d1                	mov    %edx,%ecx
  801da5:	f7 64 24 0c          	mull   0xc(%esp)
  801da9:	39 d1                	cmp    %edx,%ecx
  801dab:	89 74 24 14          	mov    %esi,0x14(%esp)
  801daf:	89 d7                	mov    %edx,%edi
  801db1:	89 c6                	mov    %eax,%esi
  801db3:	72 0a                	jb     801dbf <__umoddi3+0x12f>
  801db5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801db9:	73 10                	jae    801dcb <__umoddi3+0x13b>
  801dbb:	39 d1                	cmp    %edx,%ecx
  801dbd:	75 0c                	jne    801dcb <__umoddi3+0x13b>
  801dbf:	89 d7                	mov    %edx,%edi
  801dc1:	89 c6                	mov    %eax,%esi
  801dc3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801dc7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801dcb:	89 ca                	mov    %ecx,%edx
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801dd3:	29 f0                	sub    %esi,%eax
  801dd5:	19 fa                	sbb    %edi,%edx
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801dde:	89 d7                	mov    %edx,%edi
  801de0:	d3 e7                	shl    %cl,%edi
  801de2:	89 e9                	mov    %ebp,%ecx
  801de4:	09 f8                	or     %edi,%eax
  801de6:	d3 ea                	shr    %cl,%edx
  801de8:	83 c4 20             	add    $0x20,%esp
  801deb:	5e                   	pop    %esi
  801dec:	5f                   	pop    %edi
  801ded:	5d                   	pop    %ebp
  801dee:	c3                   	ret    
  801def:	90                   	nop
  801df0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801df4:	29 f9                	sub    %edi,%ecx
  801df6:	19 c6                	sbb    %eax,%esi
  801df8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801dfc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e00:	e9 ff fe ff ff       	jmp    801d04 <__umoddi3+0x74>
