
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
  800075:	83 c4 10             	add    $0x10,%esp
}
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 89 04 00 00       	call   800513 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
  800094:	83 c4 10             	add    $0x10,%esp
}
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 0a 1e 80 00       	push   $0x801e0a
  800103:	6a 23                	push   $0x23
  800105:	68 27 1e 80 00       	push   $0x801e27
  80010a:	e8 44 0f 00 00       	call   801053 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 0a 1e 80 00       	push   $0x801e0a
  800184:	6a 23                	push   $0x23
  800186:	68 27 1e 80 00       	push   $0x801e27
  80018b:	e8 c3 0e 00 00       	call   801053 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 0a 1e 80 00       	push   $0x801e0a
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 27 1e 80 00       	push   $0x801e27
  8001cd:	e8 81 0e 00 00       	call   801053 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 0a 1e 80 00       	push   $0x801e0a
  800208:	6a 23                	push   $0x23
  80020a:	68 27 1e 80 00       	push   $0x801e27
  80020f:	e8 3f 0e 00 00       	call   801053 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 0a 1e 80 00       	push   $0x801e0a
  80024a:	6a 23                	push   $0x23
  80024c:	68 27 1e 80 00       	push   $0x801e27
  800251:	e8 fd 0d 00 00       	call   801053 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 09 00 00 00       	mov    $0x9,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 0a 1e 80 00       	push   $0x801e0a
  80028c:	6a 23                	push   $0x23
  80028e:	68 27 1e 80 00       	push   $0x801e27
  800293:	e8 bb 0d 00 00       	call   801053 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 0a                	push   $0xa
  8002c9:	68 0a 1e 80 00       	push   $0x801e0a
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 27 1e 80 00       	push   $0x801e27
  8002d5:	e8 79 0d 00 00       	call   801053 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 0a 1e 80 00       	push   $0x801e0a
  800332:	6a 23                	push   $0x23
  800334:	68 27 1e 80 00       	push   $0x801e27
  800339:	e8 15 0d 00 00       	call   801053 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	05 00 00 00 30       	add    $0x30000000,%eax
  800351:	c1 e8 0c             	shr    $0xc,%eax
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800361:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800366:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 ea 16             	shr    $0x16,%edx
  80037d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800384:	f6 c2 01             	test   $0x1,%dl
  800387:	74 11                	je     80039a <fd_alloc+0x2d>
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 0c             	shr    $0xc,%edx
  80038e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	75 09                	jne    8003a3 <fd_alloc+0x36>
			*fd_store = fd;
  80039a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039c:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a1:	eb 17                	jmp    8003ba <fd_alloc+0x4d>
  8003a3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ad:	75 c9                	jne    800378 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c2:	83 f8 1f             	cmp    $0x1f,%eax
  8003c5:	77 36                	ja     8003fd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
  8003ca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	c1 ea 16             	shr    $0x16,%edx
  8003d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	74 24                	je     800404 <fd_lookup+0x48>
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1a                	je     80040b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fb:	eb 13                	jmp    800410 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800402:	eb 0c                	jmp    800410 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb 05                	jmp    800410 <fd_lookup+0x54>
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800420:	eb 13                	jmp    800435 <dev_lookup+0x23>
  800422:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800425:	39 08                	cmp    %ecx,(%eax)
  800427:	75 0c                	jne    800435 <dev_lookup+0x23>
			*dev = devtab[i];
  800429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042e:	b8 00 00 00 00       	mov    $0x0,%eax
  800433:	eb 2e                	jmp    800463 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	85 c0                	test   %eax,%eax
  800439:	75 e7                	jne    800422 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043b:	a1 04 40 80 00       	mov    0x804004,%eax
  800440:	8b 40 48             	mov    0x48(%eax),%eax
  800443:	83 ec 04             	sub    $0x4,%esp
  800446:	51                   	push   %ecx
  800447:	50                   	push   %eax
  800448:	68 38 1e 80 00       	push   $0x801e38
  80044d:	e8 da 0c 00 00       	call   80112c <cprintf>
	*dev = 0;
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
  800455:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    

00800465 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	83 ec 10             	sub    $0x10,%esp
  80046d:	8b 75 08             	mov    0x8(%ebp),%esi
  800470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800476:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800477:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047d:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800480:	50                   	push   %eax
  800481:	e8 36 ff ff ff       	call   8003bc <fd_lookup>
  800486:	83 c4 08             	add    $0x8,%esp
  800489:	85 c0                	test   %eax,%eax
  80048b:	78 05                	js     800492 <fd_close+0x2d>
	    || fd != fd2)
  80048d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800490:	74 0c                	je     80049e <fd_close+0x39>
		return (must_exist ? r : 0);
  800492:	84 db                	test   %bl,%bl
  800494:	ba 00 00 00 00       	mov    $0x0,%edx
  800499:	0f 44 c2             	cmove  %edx,%eax
  80049c:	eb 41                	jmp    8004df <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a4:	50                   	push   %eax
  8004a5:	ff 36                	pushl  (%esi)
  8004a7:	e8 66 ff ff ff       	call   800412 <dev_lookup>
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 1a                	js     8004cf <fd_close+0x6a>
		if (dev->dev_close)
  8004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	74 0b                	je     8004cf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c4:	83 ec 0c             	sub    $0xc,%esp
  8004c7:	56                   	push   %esi
  8004c8:	ff d0                	call   *%eax
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	56                   	push   %esi
  8004d3:	6a 00                	push   $0x0
  8004d5:	e8 00 fd ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	89 d8                	mov    %ebx,%eax
}
  8004df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e2:	5b                   	pop    %ebx
  8004e3:	5e                   	pop    %esi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 c4 fe ff ff       	call   8003bc <fd_lookup>
  8004f8:	89 c2                	mov    %eax,%edx
  8004fa:	83 c4 08             	add    $0x8,%esp
  8004fd:	85 d2                	test   %edx,%edx
  8004ff:	78 10                	js     800511 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	6a 01                	push   $0x1
  800506:	ff 75 f4             	pushl  -0xc(%ebp)
  800509:	e8 57 ff ff ff       	call   800465 <fd_close>
  80050e:	83 c4 10             	add    $0x10,%esp
}
  800511:	c9                   	leave  
  800512:	c3                   	ret    

00800513 <close_all>:

void
close_all(void)
{
  800513:	55                   	push   %ebp
  800514:	89 e5                	mov    %esp,%ebp
  800516:	53                   	push   %ebx
  800517:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80051a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051f:	83 ec 0c             	sub    $0xc,%esp
  800522:	53                   	push   %ebx
  800523:	e8 be ff ff ff       	call   8004e6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800528:	83 c3 01             	add    $0x1,%ebx
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	83 fb 20             	cmp    $0x20,%ebx
  800531:	75 ec                	jne    80051f <close_all+0xc>
		close(i);
}
  800533:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800536:	c9                   	leave  
  800537:	c3                   	ret    

00800538 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	57                   	push   %edi
  80053c:	56                   	push   %esi
  80053d:	53                   	push   %ebx
  80053e:	83 ec 2c             	sub    $0x2c,%esp
  800541:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800544:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800547:	50                   	push   %eax
  800548:	ff 75 08             	pushl  0x8(%ebp)
  80054b:	e8 6c fe ff ff       	call   8003bc <fd_lookup>
  800550:	89 c2                	mov    %eax,%edx
  800552:	83 c4 08             	add    $0x8,%esp
  800555:	85 d2                	test   %edx,%edx
  800557:	0f 88 c1 00 00 00    	js     80061e <dup+0xe6>
		return r;
	close(newfdnum);
  80055d:	83 ec 0c             	sub    $0xc,%esp
  800560:	56                   	push   %esi
  800561:	e8 80 ff ff ff       	call   8004e6 <close>

	newfd = INDEX2FD(newfdnum);
  800566:	89 f3                	mov    %esi,%ebx
  800568:	c1 e3 0c             	shl    $0xc,%ebx
  80056b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800571:	83 c4 04             	add    $0x4,%esp
  800574:	ff 75 e4             	pushl  -0x1c(%ebp)
  800577:	e8 da fd ff ff       	call   800356 <fd2data>
  80057c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057e:	89 1c 24             	mov    %ebx,(%esp)
  800581:	e8 d0 fd ff ff       	call   800356 <fd2data>
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80058c:	89 f8                	mov    %edi,%eax
  80058e:	c1 e8 16             	shr    $0x16,%eax
  800591:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800598:	a8 01                	test   $0x1,%al
  80059a:	74 37                	je     8005d3 <dup+0x9b>
  80059c:	89 f8                	mov    %edi,%eax
  80059e:	c1 e8 0c             	shr    $0xc,%eax
  8005a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a8:	f6 c2 01             	test   $0x1,%dl
  8005ab:	74 26                	je     8005d3 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b4:	83 ec 0c             	sub    $0xc,%esp
  8005b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8005bc:	50                   	push   %eax
  8005bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c0:	6a 00                	push   $0x0
  8005c2:	57                   	push   %edi
  8005c3:	6a 00                	push   $0x0
  8005c5:	e8 ce fb ff ff       	call   800198 <sys_page_map>
  8005ca:	89 c7                	mov    %eax,%edi
  8005cc:	83 c4 20             	add    $0x20,%esp
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	78 2e                	js     800601 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d6:	89 d0                	mov    %edx,%eax
  8005d8:	c1 e8 0c             	shr    $0xc,%eax
  8005db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ea:	50                   	push   %eax
  8005eb:	53                   	push   %ebx
  8005ec:	6a 00                	push   $0x0
  8005ee:	52                   	push   %edx
  8005ef:	6a 00                	push   $0x0
  8005f1:	e8 a2 fb ff ff       	call   800198 <sys_page_map>
  8005f6:	89 c7                	mov    %eax,%edi
  8005f8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005fb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fd:	85 ff                	test   %edi,%edi
  8005ff:	79 1d                	jns    80061e <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 00                	push   $0x0
  800607:	e8 ce fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060c:	83 c4 08             	add    $0x8,%esp
  80060f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800612:	6a 00                	push   $0x0
  800614:	e8 c1 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	89 f8                	mov    %edi,%eax
}
  80061e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800621:	5b                   	pop    %ebx
  800622:	5e                   	pop    %esi
  800623:	5f                   	pop    %edi
  800624:	5d                   	pop    %ebp
  800625:	c3                   	ret    

00800626 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800626:	55                   	push   %ebp
  800627:	89 e5                	mov    %esp,%ebp
  800629:	53                   	push   %ebx
  80062a:	83 ec 14             	sub    $0x14,%esp
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800630:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800633:	50                   	push   %eax
  800634:	53                   	push   %ebx
  800635:	e8 82 fd ff ff       	call   8003bc <fd_lookup>
  80063a:	83 c4 08             	add    $0x8,%esp
  80063d:	89 c2                	mov    %eax,%edx
  80063f:	85 c0                	test   %eax,%eax
  800641:	78 6d                	js     8006b0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800649:	50                   	push   %eax
  80064a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064d:	ff 30                	pushl  (%eax)
  80064f:	e8 be fd ff ff       	call   800412 <dev_lookup>
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	85 c0                	test   %eax,%eax
  800659:	78 4c                	js     8006a7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80065b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065e:	8b 42 08             	mov    0x8(%edx),%eax
  800661:	83 e0 03             	and    $0x3,%eax
  800664:	83 f8 01             	cmp    $0x1,%eax
  800667:	75 21                	jne    80068a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800669:	a1 04 40 80 00       	mov    0x804004,%eax
  80066e:	8b 40 48             	mov    0x48(%eax),%eax
  800671:	83 ec 04             	sub    $0x4,%esp
  800674:	53                   	push   %ebx
  800675:	50                   	push   %eax
  800676:	68 79 1e 80 00       	push   $0x801e79
  80067b:	e8 ac 0a 00 00       	call   80112c <cprintf>
		return -E_INVAL;
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800688:	eb 26                	jmp    8006b0 <read+0x8a>
	}
	if (!dev->dev_read)
  80068a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068d:	8b 40 08             	mov    0x8(%eax),%eax
  800690:	85 c0                	test   %eax,%eax
  800692:	74 17                	je     8006ab <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800694:	83 ec 04             	sub    $0x4,%esp
  800697:	ff 75 10             	pushl  0x10(%ebp)
  80069a:	ff 75 0c             	pushl  0xc(%ebp)
  80069d:	52                   	push   %edx
  80069e:	ff d0                	call   *%eax
  8006a0:	89 c2                	mov    %eax,%edx
  8006a2:	83 c4 10             	add    $0x10,%esp
  8006a5:	eb 09                	jmp    8006b0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a7:	89 c2                	mov    %eax,%edx
  8006a9:	eb 05                	jmp    8006b0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b0:	89 d0                	mov    %edx,%eax
  8006b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b5:	c9                   	leave  
  8006b6:	c3                   	ret    

008006b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	57                   	push   %edi
  8006bb:	56                   	push   %esi
  8006bc:	53                   	push   %ebx
  8006bd:	83 ec 0c             	sub    $0xc,%esp
  8006c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cb:	eb 21                	jmp    8006ee <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006cd:	83 ec 04             	sub    $0x4,%esp
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	29 d8                	sub    %ebx,%eax
  8006d4:	50                   	push   %eax
  8006d5:	89 d8                	mov    %ebx,%eax
  8006d7:	03 45 0c             	add    0xc(%ebp),%eax
  8006da:	50                   	push   %eax
  8006db:	57                   	push   %edi
  8006dc:	e8 45 ff ff ff       	call   800626 <read>
		if (m < 0)
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	78 0c                	js     8006f4 <readn+0x3d>
			return m;
		if (m == 0)
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 06                	je     8006f2 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ec:	01 c3                	add    %eax,%ebx
  8006ee:	39 f3                	cmp    %esi,%ebx
  8006f0:	72 db                	jb     8006cd <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8006f2:	89 d8                	mov    %ebx,%eax
}
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	83 ec 14             	sub    $0x14,%esp
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	53                   	push   %ebx
  80070b:	e8 ac fc ff ff       	call   8003bc <fd_lookup>
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	89 c2                	mov    %eax,%edx
  800715:	85 c0                	test   %eax,%eax
  800717:	78 68                	js     800781 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800723:	ff 30                	pushl  (%eax)
  800725:	e8 e8 fc ff ff       	call   800412 <dev_lookup>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 47                	js     800778 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800738:	75 21                	jne    80075b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073a:	a1 04 40 80 00       	mov    0x804004,%eax
  80073f:	8b 40 48             	mov    0x48(%eax),%eax
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	53                   	push   %ebx
  800746:	50                   	push   %eax
  800747:	68 95 1e 80 00       	push   $0x801e95
  80074c:	e8 db 09 00 00       	call   80112c <cprintf>
		return -E_INVAL;
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800759:	eb 26                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075e:	8b 52 0c             	mov    0xc(%edx),%edx
  800761:	85 d2                	test   %edx,%edx
  800763:	74 17                	je     80077c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800765:	83 ec 04             	sub    $0x4,%esp
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	50                   	push   %eax
  80076f:	ff d2                	call   *%edx
  800771:	89 c2                	mov    %eax,%edx
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb 09                	jmp    800781 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800778:	89 c2                	mov    %eax,%edx
  80077a:	eb 05                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800781:	89 d0                	mov    %edx,%eax
  800783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <seek>:

int
seek(int fdnum, off_t offset)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	ff 75 08             	pushl  0x8(%ebp)
  800795:	e8 22 fc ff ff       	call   8003bc <fd_lookup>
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	85 c0                	test   %eax,%eax
  80079f:	78 0e                	js     8007af <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	83 ec 14             	sub    $0x14,%esp
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	53                   	push   %ebx
  8007c0:	e8 f7 fb ff ff       	call   8003bc <fd_lookup>
  8007c5:	83 c4 08             	add    $0x8,%esp
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 65                	js     800833 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d8:	ff 30                	pushl  (%eax)
  8007da:	e8 33 fc ff ff       	call   800412 <dev_lookup>
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	78 44                	js     80082a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ed:	75 21                	jne    800810 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007ef:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f4:	8b 40 48             	mov    0x48(%eax),%eax
  8007f7:	83 ec 04             	sub    $0x4,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	50                   	push   %eax
  8007fc:	68 58 1e 80 00       	push   $0x801e58
  800801:	e8 26 09 00 00       	call   80112c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080e:	eb 23                	jmp    800833 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800810:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800813:	8b 52 18             	mov    0x18(%edx),%edx
  800816:	85 d2                	test   %edx,%edx
  800818:	74 14                	je     80082e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	50                   	push   %eax
  800821:	ff d2                	call   *%edx
  800823:	89 c2                	mov    %eax,%edx
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	eb 09                	jmp    800833 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	eb 05                	jmp    800833 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800833:	89 d0                	mov    %edx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 6c fb ff ff       	call   8003bc <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	89 c2                	mov    %eax,%edx
  800855:	85 c0                	test   %eax,%eax
  800857:	78 58                	js     8008b1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085f:	50                   	push   %eax
  800860:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800863:	ff 30                	pushl  (%eax)
  800865:	e8 a8 fb ff ff       	call   800412 <dev_lookup>
  80086a:	83 c4 10             	add    $0x10,%esp
  80086d:	85 c0                	test   %eax,%eax
  80086f:	78 37                	js     8008a8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800871:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800874:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800878:	74 32                	je     8008ac <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800884:	00 00 00 
	stat->st_isdir = 0;
  800887:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088e:	00 00 00 
	stat->st_dev = dev;
  800891:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	ff 75 f0             	pushl  -0x10(%ebp)
  80089e:	ff 50 14             	call   *0x14(%eax)
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 09                	jmp    8008b1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	eb 05                	jmp    8008b1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	6a 00                	push   $0x0
  8008c2:	ff 75 08             	pushl  0x8(%ebp)
  8008c5:	e8 09 02 00 00       	call   800ad3 <open>
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	85 db                	test   %ebx,%ebx
  8008d1:	78 1b                	js     8008ee <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	ff 75 0c             	pushl  0xc(%ebp)
  8008d9:	53                   	push   %ebx
  8008da:	e8 5b ff ff ff       	call   80083a <fstat>
  8008df:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e1:	89 1c 24             	mov    %ebx,(%esp)
  8008e4:	e8 fd fb ff ff       	call   8004e6 <close>
	return r;
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	89 f0                	mov    %esi,%eax
}
  8008ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	89 c6                	mov    %eax,%esi
  8008fc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008fe:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800905:	75 12                	jne    800919 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	6a 01                	push   $0x1
  80090c:	e8 ac 11 00 00       	call   801abd <ipc_find_env>
  800911:	a3 00 40 80 00       	mov    %eax,0x804000
  800916:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800919:	6a 07                	push   $0x7
  80091b:	68 00 50 80 00       	push   $0x805000
  800920:	56                   	push   %esi
  800921:	ff 35 00 40 80 00    	pushl  0x804000
  800927:	e8 3d 11 00 00       	call   801a69 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80092c:	83 c4 0c             	add    $0xc,%esp
  80092f:	6a 00                	push   $0x0
  800931:	53                   	push   %ebx
  800932:	6a 00                	push   $0x0
  800934:	e8 c7 10 00 00       	call   801a00 <ipc_recv>
}
  800939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 40 0c             	mov    0xc(%eax),%eax
  80094c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800951:	8b 45 0c             	mov    0xc(%ebp),%eax
  800954:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	b8 02 00 00 00       	mov    $0x2,%eax
  800963:	e8 8d ff ff ff       	call   8008f5 <fsipc>
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 40 0c             	mov    0xc(%eax),%eax
  800976:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097b:	ba 00 00 00 00       	mov    $0x0,%edx
  800980:	b8 06 00 00 00       	mov    $0x6,%eax
  800985:	e8 6b ff ff ff       	call   8008f5 <fsipc>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	53                   	push   %ebx
  800990:	83 ec 04             	sub    $0x4,%esp
  800993:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 40 0c             	mov    0xc(%eax),%eax
  80099c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ab:	e8 45 ff ff ff       	call   8008f5 <fsipc>
  8009b0:	89 c2                	mov    %eax,%edx
  8009b2:	85 d2                	test   %edx,%edx
  8009b4:	78 2c                	js     8009e2 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b6:	83 ec 08             	sub    $0x8,%esp
  8009b9:	68 00 50 80 00       	push   $0x805000
  8009be:	53                   	push   %ebx
  8009bf:	e8 ef 0c 00 00       	call   8016b3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c4:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009cf:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009da:	83 c4 10             	add    $0x10,%esp
  8009dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	83 ec 0c             	sub    $0xc,%esp
  8009f0:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f9:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8009fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a01:	eb 3d                	jmp    800a40 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800a03:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800a09:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800a0e:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800a11:	83 ec 04             	sub    $0x4,%esp
  800a14:	57                   	push   %edi
  800a15:	53                   	push   %ebx
  800a16:	68 08 50 80 00       	push   $0x805008
  800a1b:	e8 25 0e 00 00       	call   801845 <memmove>
                fsipcbuf.write.req_n = tmp; 
  800a20:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a26:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800a30:	e8 c0 fe ff ff       	call   8008f5 <fsipc>
  800a35:	83 c4 10             	add    $0x10,%esp
  800a38:	85 c0                	test   %eax,%eax
  800a3a:	78 0d                	js     800a49 <devfile_write+0x62>
		        return r;
                n -= tmp;
  800a3c:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800a3e:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a40:	85 f6                	test   %esi,%esi
  800a42:	75 bf                	jne    800a03 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800a44:	89 d8                	mov    %ebx,%eax
  800a46:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800a49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5f                   	pop    %edi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
  800a56:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a64:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a74:	e8 7c fe ff ff       	call   8008f5 <fsipc>
  800a79:	89 c3                	mov    %eax,%ebx
  800a7b:	85 c0                	test   %eax,%eax
  800a7d:	78 4b                	js     800aca <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a7f:	39 c6                	cmp    %eax,%esi
  800a81:	73 16                	jae    800a99 <devfile_read+0x48>
  800a83:	68 c4 1e 80 00       	push   $0x801ec4
  800a88:	68 cb 1e 80 00       	push   $0x801ecb
  800a8d:	6a 7c                	push   $0x7c
  800a8f:	68 e0 1e 80 00       	push   $0x801ee0
  800a94:	e8 ba 05 00 00       	call   801053 <_panic>
	assert(r <= PGSIZE);
  800a99:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a9e:	7e 16                	jle    800ab6 <devfile_read+0x65>
  800aa0:	68 eb 1e 80 00       	push   $0x801eeb
  800aa5:	68 cb 1e 80 00       	push   $0x801ecb
  800aaa:	6a 7d                	push   $0x7d
  800aac:	68 e0 1e 80 00       	push   $0x801ee0
  800ab1:	e8 9d 05 00 00       	call   801053 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab6:	83 ec 04             	sub    $0x4,%esp
  800ab9:	50                   	push   %eax
  800aba:	68 00 50 80 00       	push   $0x805000
  800abf:	ff 75 0c             	pushl  0xc(%ebp)
  800ac2:	e8 7e 0d 00 00       	call   801845 <memmove>
	return r;
  800ac7:	83 c4 10             	add    $0x10,%esp
}
  800aca:	89 d8                	mov    %ebx,%eax
  800acc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	53                   	push   %ebx
  800ad7:	83 ec 20             	sub    $0x20,%esp
  800ada:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800add:	53                   	push   %ebx
  800ade:	e8 97 0b 00 00       	call   80167a <strlen>
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aeb:	7f 67                	jg     800b54 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aed:	83 ec 0c             	sub    $0xc,%esp
  800af0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af3:	50                   	push   %eax
  800af4:	e8 74 f8 ff ff       	call   80036d <fd_alloc>
  800af9:	83 c4 10             	add    $0x10,%esp
		return r;
  800afc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800afe:	85 c0                	test   %eax,%eax
  800b00:	78 57                	js     800b59 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b02:	83 ec 08             	sub    $0x8,%esp
  800b05:	53                   	push   %ebx
  800b06:	68 00 50 80 00       	push   $0x805000
  800b0b:	e8 a3 0b 00 00       	call   8016b3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b13:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b18:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	e8 d0 fd ff ff       	call   8008f5 <fsipc>
  800b25:	89 c3                	mov    %eax,%ebx
  800b27:	83 c4 10             	add    $0x10,%esp
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	79 14                	jns    800b42 <open+0x6f>
		fd_close(fd, 0);
  800b2e:	83 ec 08             	sub    $0x8,%esp
  800b31:	6a 00                	push   $0x0
  800b33:	ff 75 f4             	pushl  -0xc(%ebp)
  800b36:	e8 2a f9 ff ff       	call   800465 <fd_close>
		return r;
  800b3b:	83 c4 10             	add    $0x10,%esp
  800b3e:	89 da                	mov    %ebx,%edx
  800b40:	eb 17                	jmp    800b59 <open+0x86>
	}

	return fd2num(fd);
  800b42:	83 ec 0c             	sub    $0xc,%esp
  800b45:	ff 75 f4             	pushl  -0xc(%ebp)
  800b48:	e8 f9 f7 ff ff       	call   800346 <fd2num>
  800b4d:	89 c2                	mov    %eax,%edx
  800b4f:	83 c4 10             	add    $0x10,%esp
  800b52:	eb 05                	jmp    800b59 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b54:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b59:	89 d0                	mov    %edx,%eax
  800b5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b66:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6b:	b8 08 00 00 00       	mov    $0x8,%eax
  800b70:	e8 80 fd ff ff       	call   8008f5 <fsipc>
}
  800b75:	c9                   	leave  
  800b76:	c3                   	ret    

00800b77 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b7f:	83 ec 0c             	sub    $0xc,%esp
  800b82:	ff 75 08             	pushl  0x8(%ebp)
  800b85:	e8 cc f7 ff ff       	call   800356 <fd2data>
  800b8a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b8c:	83 c4 08             	add    $0x8,%esp
  800b8f:	68 f7 1e 80 00       	push   $0x801ef7
  800b94:	53                   	push   %ebx
  800b95:	e8 19 0b 00 00       	call   8016b3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b9a:	8b 56 04             	mov    0x4(%esi),%edx
  800b9d:	89 d0                	mov    %edx,%eax
  800b9f:	2b 06                	sub    (%esi),%eax
  800ba1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bae:	00 00 00 
	stat->st_dev = &devpipe;
  800bb1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb8:	30 80 00 
	return 0;
}
  800bbb:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 0c             	sub    $0xc,%esp
  800bce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd1:	53                   	push   %ebx
  800bd2:	6a 00                	push   $0x0
  800bd4:	e8 01 f6 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bd9:	89 1c 24             	mov    %ebx,(%esp)
  800bdc:	e8 75 f7 ff ff       	call   800356 <fd2data>
  800be1:	83 c4 08             	add    $0x8,%esp
  800be4:	50                   	push   %eax
  800be5:	6a 00                	push   $0x0
  800be7:	e8 ee f5 ff ff       	call   8001da <sys_page_unmap>
}
  800bec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bef:	c9                   	leave  
  800bf0:	c3                   	ret    

00800bf1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 1c             	sub    $0x1c,%esp
  800bfa:	89 c6                	mov    %eax,%esi
  800bfc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bff:	a1 04 40 80 00       	mov    0x804004,%eax
  800c04:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	56                   	push   %esi
  800c0b:	e8 e5 0e 00 00       	call   801af5 <pageref>
  800c10:	89 c7                	mov    %eax,%edi
  800c12:	83 c4 04             	add    $0x4,%esp
  800c15:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c18:	e8 d8 0e 00 00       	call   801af5 <pageref>
  800c1d:	83 c4 10             	add    $0x10,%esp
  800c20:	39 c7                	cmp    %eax,%edi
  800c22:	0f 94 c2             	sete   %dl
  800c25:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800c28:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800c2e:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800c31:	39 fb                	cmp    %edi,%ebx
  800c33:	74 19                	je     800c4e <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  800c35:	84 d2                	test   %dl,%dl
  800c37:	74 c6                	je     800bff <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c39:	8b 51 58             	mov    0x58(%ecx),%edx
  800c3c:	50                   	push   %eax
  800c3d:	52                   	push   %edx
  800c3e:	53                   	push   %ebx
  800c3f:	68 fe 1e 80 00       	push   $0x801efe
  800c44:	e8 e3 04 00 00       	call   80112c <cprintf>
  800c49:	83 c4 10             	add    $0x10,%esp
  800c4c:	eb b1                	jmp    800bff <_pipeisclosed+0xe>
	}
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 28             	sub    $0x28,%esp
  800c5f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c62:	56                   	push   %esi
  800c63:	e8 ee f6 ff ff       	call   800356 <fd2data>
  800c68:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c6a:	83 c4 10             	add    $0x10,%esp
  800c6d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c72:	eb 4b                	jmp    800cbf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c74:	89 da                	mov    %ebx,%edx
  800c76:	89 f0                	mov    %esi,%eax
  800c78:	e8 74 ff ff ff       	call   800bf1 <_pipeisclosed>
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	75 48                	jne    800cc9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c81:	e8 b0 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c86:	8b 43 04             	mov    0x4(%ebx),%eax
  800c89:	8b 0b                	mov    (%ebx),%ecx
  800c8b:	8d 51 20             	lea    0x20(%ecx),%edx
  800c8e:	39 d0                	cmp    %edx,%eax
  800c90:	73 e2                	jae    800c74 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c99:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c9c:	89 c2                	mov    %eax,%edx
  800c9e:	c1 fa 1f             	sar    $0x1f,%edx
  800ca1:	89 d1                	mov    %edx,%ecx
  800ca3:	c1 e9 1b             	shr    $0x1b,%ecx
  800ca6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ca9:	83 e2 1f             	and    $0x1f,%edx
  800cac:	29 ca                	sub    %ecx,%edx
  800cae:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cb6:	83 c0 01             	add    $0x1,%eax
  800cb9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cbc:	83 c7 01             	add    $0x1,%edi
  800cbf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cc2:	75 c2                	jne    800c86 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cc4:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc7:	eb 05                	jmp    800cce <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cc9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 18             	sub    $0x18,%esp
  800cdf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ce2:	57                   	push   %edi
  800ce3:	e8 6e f6 ff ff       	call   800356 <fd2data>
  800ce8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cea:	83 c4 10             	add    $0x10,%esp
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	eb 3d                	jmp    800d31 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cf4:	85 db                	test   %ebx,%ebx
  800cf6:	74 04                	je     800cfc <devpipe_read+0x26>
				return i;
  800cf8:	89 d8                	mov    %ebx,%eax
  800cfa:	eb 44                	jmp    800d40 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cfc:	89 f2                	mov    %esi,%edx
  800cfe:	89 f8                	mov    %edi,%eax
  800d00:	e8 ec fe ff ff       	call   800bf1 <_pipeisclosed>
  800d05:	85 c0                	test   %eax,%eax
  800d07:	75 32                	jne    800d3b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d09:	e8 28 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d0e:	8b 06                	mov    (%esi),%eax
  800d10:	3b 46 04             	cmp    0x4(%esi),%eax
  800d13:	74 df                	je     800cf4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d15:	99                   	cltd   
  800d16:	c1 ea 1b             	shr    $0x1b,%edx
  800d19:	01 d0                	add    %edx,%eax
  800d1b:	83 e0 1f             	and    $0x1f,%eax
  800d1e:	29 d0                	sub    %edx,%eax
  800d20:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d2b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d2e:	83 c3 01             	add    $0x1,%ebx
  800d31:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d34:	75 d8                	jne    800d0e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d36:	8b 45 10             	mov    0x10(%ebp),%eax
  800d39:	eb 05                	jmp    800d40 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d3b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d53:	50                   	push   %eax
  800d54:	e8 14 f6 ff ff       	call   80036d <fd_alloc>
  800d59:	83 c4 10             	add    $0x10,%esp
  800d5c:	89 c2                	mov    %eax,%edx
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	0f 88 2c 01 00 00    	js     800e92 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d66:	83 ec 04             	sub    $0x4,%esp
  800d69:	68 07 04 00 00       	push   $0x407
  800d6e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d71:	6a 00                	push   $0x0
  800d73:	e8 dd f3 ff ff       	call   800155 <sys_page_alloc>
  800d78:	83 c4 10             	add    $0x10,%esp
  800d7b:	89 c2                	mov    %eax,%edx
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	0f 88 0d 01 00 00    	js     800e92 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d85:	83 ec 0c             	sub    $0xc,%esp
  800d88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d8b:	50                   	push   %eax
  800d8c:	e8 dc f5 ff ff       	call   80036d <fd_alloc>
  800d91:	89 c3                	mov    %eax,%ebx
  800d93:	83 c4 10             	add    $0x10,%esp
  800d96:	85 c0                	test   %eax,%eax
  800d98:	0f 88 e2 00 00 00    	js     800e80 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9e:	83 ec 04             	sub    $0x4,%esp
  800da1:	68 07 04 00 00       	push   $0x407
  800da6:	ff 75 f0             	pushl  -0x10(%ebp)
  800da9:	6a 00                	push   $0x0
  800dab:	e8 a5 f3 ff ff       	call   800155 <sys_page_alloc>
  800db0:	89 c3                	mov    %eax,%ebx
  800db2:	83 c4 10             	add    $0x10,%esp
  800db5:	85 c0                	test   %eax,%eax
  800db7:	0f 88 c3 00 00 00    	js     800e80 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dbd:	83 ec 0c             	sub    $0xc,%esp
  800dc0:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc3:	e8 8e f5 ff ff       	call   800356 <fd2data>
  800dc8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dca:	83 c4 0c             	add    $0xc,%esp
  800dcd:	68 07 04 00 00       	push   $0x407
  800dd2:	50                   	push   %eax
  800dd3:	6a 00                	push   $0x0
  800dd5:	e8 7b f3 ff ff       	call   800155 <sys_page_alloc>
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	83 c4 10             	add    $0x10,%esp
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	0f 88 89 00 00 00    	js     800e70 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	ff 75 f0             	pushl  -0x10(%ebp)
  800ded:	e8 64 f5 ff ff       	call   800356 <fd2data>
  800df2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800df9:	50                   	push   %eax
  800dfa:	6a 00                	push   $0x0
  800dfc:	56                   	push   %esi
  800dfd:	6a 00                	push   $0x0
  800dff:	e8 94 f3 ff ff       	call   800198 <sys_page_map>
  800e04:	89 c3                	mov    %eax,%ebx
  800e06:	83 c4 20             	add    $0x20,%esp
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	78 55                	js     800e62 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e16:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e22:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e30:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3d:	e8 04 f5 ff ff       	call   800346 <fd2num>
  800e42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e45:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e47:	83 c4 04             	add    $0x4,%esp
  800e4a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4d:	e8 f4 f4 ff ff       	call   800346 <fd2num>
  800e52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e55:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e60:	eb 30                	jmp    800e92 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e62:	83 ec 08             	sub    $0x8,%esp
  800e65:	56                   	push   %esi
  800e66:	6a 00                	push   $0x0
  800e68:	e8 6d f3 ff ff       	call   8001da <sys_page_unmap>
  800e6d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e70:	83 ec 08             	sub    $0x8,%esp
  800e73:	ff 75 f0             	pushl  -0x10(%ebp)
  800e76:	6a 00                	push   $0x0
  800e78:	e8 5d f3 ff ff       	call   8001da <sys_page_unmap>
  800e7d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e80:	83 ec 08             	sub    $0x8,%esp
  800e83:	ff 75 f4             	pushl  -0xc(%ebp)
  800e86:	6a 00                	push   $0x0
  800e88:	e8 4d f3 ff ff       	call   8001da <sys_page_unmap>
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e92:	89 d0                	mov    %edx,%eax
  800e94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea4:	50                   	push   %eax
  800ea5:	ff 75 08             	pushl  0x8(%ebp)
  800ea8:	e8 0f f5 ff ff       	call   8003bc <fd_lookup>
  800ead:	89 c2                	mov    %eax,%edx
  800eaf:	83 c4 10             	add    $0x10,%esp
  800eb2:	85 d2                	test   %edx,%edx
  800eb4:	78 18                	js     800ece <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eb6:	83 ec 0c             	sub    $0xc,%esp
  800eb9:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebc:	e8 95 f4 ff ff       	call   800356 <fd2data>
	return _pipeisclosed(fd, p);
  800ec1:	89 c2                	mov    %eax,%edx
  800ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec6:	e8 26 fd ff ff       	call   800bf1 <_pipeisclosed>
  800ecb:	83 c4 10             	add    $0x10,%esp
}
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ed3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee0:	68 16 1f 80 00       	push   $0x801f16
  800ee5:	ff 75 0c             	pushl  0xc(%ebp)
  800ee8:	e8 c6 07 00 00       	call   8016b3 <strcpy>
	return 0;
}
  800eed:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
  800efa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f00:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f05:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f0b:	eb 2d                	jmp    800f3a <devcons_write+0x46>
		m = n - tot;
  800f0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f10:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f12:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f15:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f1a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f1d:	83 ec 04             	sub    $0x4,%esp
  800f20:	53                   	push   %ebx
  800f21:	03 45 0c             	add    0xc(%ebp),%eax
  800f24:	50                   	push   %eax
  800f25:	57                   	push   %edi
  800f26:	e8 1a 09 00 00       	call   801845 <memmove>
		sys_cputs(buf, m);
  800f2b:	83 c4 08             	add    $0x8,%esp
  800f2e:	53                   	push   %ebx
  800f2f:	57                   	push   %edi
  800f30:	e8 64 f1 ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f35:	01 de                	add    %ebx,%esi
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	89 f0                	mov    %esi,%eax
  800f3c:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f3f:	72 cc                	jb     800f0d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    

00800f49 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f4f:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f54:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f58:	75 07                	jne    800f61 <devcons_read+0x18>
  800f5a:	eb 28                	jmp    800f84 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f5c:	e8 d5 f1 ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f61:	e8 51 f1 ff ff       	call   8000b7 <sys_cgetc>
  800f66:	85 c0                	test   %eax,%eax
  800f68:	74 f2                	je     800f5c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	78 16                	js     800f84 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f6e:	83 f8 04             	cmp    $0x4,%eax
  800f71:	74 0c                	je     800f7f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f76:	88 02                	mov    %al,(%edx)
	return 1;
  800f78:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7d:	eb 05                	jmp    800f84 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f7f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f84:	c9                   	leave  
  800f85:	c3                   	ret    

00800f86 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f92:	6a 01                	push   $0x1
  800f94:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f97:	50                   	push   %eax
  800f98:	e8 fc f0 ff ff       	call   800099 <sys_cputs>
  800f9d:	83 c4 10             	add    $0x10,%esp
}
  800fa0:	c9                   	leave  
  800fa1:	c3                   	ret    

00800fa2 <getchar>:

int
getchar(void)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fa8:	6a 01                	push   $0x1
  800faa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fad:	50                   	push   %eax
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 71 f6 ff ff       	call   800626 <read>
	if (r < 0)
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 0f                	js     800fcb <getchar+0x29>
		return r;
	if (r < 1)
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	7e 06                	jle    800fc6 <getchar+0x24>
		return -E_EOF;
	return c;
  800fc0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fc4:	eb 05                	jmp    800fcb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fc6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fcb:	c9                   	leave  
  800fcc:	c3                   	ret    

00800fcd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd6:	50                   	push   %eax
  800fd7:	ff 75 08             	pushl  0x8(%ebp)
  800fda:	e8 dd f3 ff ff       	call   8003bc <fd_lookup>
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 11                	js     800ff7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fef:	39 10                	cmp    %edx,(%eax)
  800ff1:	0f 94 c0             	sete   %al
  800ff4:	0f b6 c0             	movzbl %al,%eax
}
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <opencons>:

int
opencons(void)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801002:	50                   	push   %eax
  801003:	e8 65 f3 ff ff       	call   80036d <fd_alloc>
  801008:	83 c4 10             	add    $0x10,%esp
		return r;
  80100b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 3e                	js     80104f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801011:	83 ec 04             	sub    $0x4,%esp
  801014:	68 07 04 00 00       	push   $0x407
  801019:	ff 75 f4             	pushl  -0xc(%ebp)
  80101c:	6a 00                	push   $0x0
  80101e:	e8 32 f1 ff ff       	call   800155 <sys_page_alloc>
  801023:	83 c4 10             	add    $0x10,%esp
		return r;
  801026:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801028:	85 c0                	test   %eax,%eax
  80102a:	78 23                	js     80104f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80102c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801032:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801035:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801037:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	50                   	push   %eax
  801045:	e8 fc f2 ff ff       	call   800346 <fd2num>
  80104a:	89 c2                	mov    %eax,%edx
  80104c:	83 c4 10             	add    $0x10,%esp
}
  80104f:	89 d0                	mov    %edx,%eax
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801058:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80105b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801061:	e8 b1 f0 ff ff       	call   800117 <sys_getenvid>
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	ff 75 0c             	pushl  0xc(%ebp)
  80106c:	ff 75 08             	pushl  0x8(%ebp)
  80106f:	56                   	push   %esi
  801070:	50                   	push   %eax
  801071:	68 24 1f 80 00       	push   $0x801f24
  801076:	e8 b1 00 00 00       	call   80112c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80107b:	83 c4 18             	add    $0x18,%esp
  80107e:	53                   	push   %ebx
  80107f:	ff 75 10             	pushl  0x10(%ebp)
  801082:	e8 54 00 00 00       	call   8010db <vcprintf>
	cprintf("\n");
  801087:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  80108e:	e8 99 00 00 00       	call   80112c <cprintf>
  801093:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801096:	cc                   	int3   
  801097:	eb fd                	jmp    801096 <_panic+0x43>

00801099 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	53                   	push   %ebx
  80109d:	83 ec 04             	sub    $0x4,%esp
  8010a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010a3:	8b 13                	mov    (%ebx),%edx
  8010a5:	8d 42 01             	lea    0x1(%edx),%eax
  8010a8:	89 03                	mov    %eax,(%ebx)
  8010aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010b1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010b6:	75 1a                	jne    8010d2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010b8:	83 ec 08             	sub    $0x8,%esp
  8010bb:	68 ff 00 00 00       	push   $0xff
  8010c0:	8d 43 08             	lea    0x8(%ebx),%eax
  8010c3:	50                   	push   %eax
  8010c4:	e8 d0 ef ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8010c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010cf:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010d2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010e4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010eb:	00 00 00 
	b.cnt = 0;
  8010ee:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010f5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010f8:	ff 75 0c             	pushl  0xc(%ebp)
  8010fb:	ff 75 08             	pushl  0x8(%ebp)
  8010fe:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801104:	50                   	push   %eax
  801105:	68 99 10 80 00       	push   $0x801099
  80110a:	e8 4f 01 00 00       	call   80125e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80110f:	83 c4 08             	add    $0x8,%esp
  801112:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801118:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80111e:	50                   	push   %eax
  80111f:	e8 75 ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  801124:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80112a:	c9                   	leave  
  80112b:	c3                   	ret    

0080112c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801132:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801135:	50                   	push   %eax
  801136:	ff 75 08             	pushl  0x8(%ebp)
  801139:	e8 9d ff ff ff       	call   8010db <vcprintf>
	va_end(ap);

	return cnt;
}
  80113e:	c9                   	leave  
  80113f:	c3                   	ret    

00801140 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
  801146:	83 ec 1c             	sub    $0x1c,%esp
  801149:	89 c7                	mov    %eax,%edi
  80114b:	89 d6                	mov    %edx,%esi
  80114d:	8b 45 08             	mov    0x8(%ebp),%eax
  801150:	8b 55 0c             	mov    0xc(%ebp),%edx
  801153:	89 d1                	mov    %edx,%ecx
  801155:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801158:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80115b:	8b 45 10             	mov    0x10(%ebp),%eax
  80115e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801161:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801164:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80116b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80116e:	72 05                	jb     801175 <printnum+0x35>
  801170:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801173:	77 3e                	ja     8011b3 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801175:	83 ec 0c             	sub    $0xc,%esp
  801178:	ff 75 18             	pushl  0x18(%ebp)
  80117b:	83 eb 01             	sub    $0x1,%ebx
  80117e:	53                   	push   %ebx
  80117f:	50                   	push   %eax
  801180:	83 ec 08             	sub    $0x8,%esp
  801183:	ff 75 e4             	pushl  -0x1c(%ebp)
  801186:	ff 75 e0             	pushl  -0x20(%ebp)
  801189:	ff 75 dc             	pushl  -0x24(%ebp)
  80118c:	ff 75 d8             	pushl  -0x28(%ebp)
  80118f:	e8 9c 09 00 00       	call   801b30 <__udivdi3>
  801194:	83 c4 18             	add    $0x18,%esp
  801197:	52                   	push   %edx
  801198:	50                   	push   %eax
  801199:	89 f2                	mov    %esi,%edx
  80119b:	89 f8                	mov    %edi,%eax
  80119d:	e8 9e ff ff ff       	call   801140 <printnum>
  8011a2:	83 c4 20             	add    $0x20,%esp
  8011a5:	eb 13                	jmp    8011ba <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011a7:	83 ec 08             	sub    $0x8,%esp
  8011aa:	56                   	push   %esi
  8011ab:	ff 75 18             	pushl  0x18(%ebp)
  8011ae:	ff d7                	call   *%edi
  8011b0:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011b3:	83 eb 01             	sub    $0x1,%ebx
  8011b6:	85 db                	test   %ebx,%ebx
  8011b8:	7f ed                	jg     8011a7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	56                   	push   %esi
  8011be:	83 ec 04             	sub    $0x4,%esp
  8011c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8011cd:	e8 8e 0a 00 00       	call   801c60 <__umoddi3>
  8011d2:	83 c4 14             	add    $0x14,%esp
  8011d5:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  8011dc:	50                   	push   %eax
  8011dd:	ff d7                	call   *%edi
  8011df:	83 c4 10             	add    $0x10,%esp
}
  8011e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e5:	5b                   	pop    %ebx
  8011e6:	5e                   	pop    %esi
  8011e7:	5f                   	pop    %edi
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011ed:	83 fa 01             	cmp    $0x1,%edx
  8011f0:	7e 0e                	jle    801200 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011f2:	8b 10                	mov    (%eax),%edx
  8011f4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011f7:	89 08                	mov    %ecx,(%eax)
  8011f9:	8b 02                	mov    (%edx),%eax
  8011fb:	8b 52 04             	mov    0x4(%edx),%edx
  8011fe:	eb 22                	jmp    801222 <getuint+0x38>
	else if (lflag)
  801200:	85 d2                	test   %edx,%edx
  801202:	74 10                	je     801214 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801204:	8b 10                	mov    (%eax),%edx
  801206:	8d 4a 04             	lea    0x4(%edx),%ecx
  801209:	89 08                	mov    %ecx,(%eax)
  80120b:	8b 02                	mov    (%edx),%eax
  80120d:	ba 00 00 00 00       	mov    $0x0,%edx
  801212:	eb 0e                	jmp    801222 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801214:	8b 10                	mov    (%eax),%edx
  801216:	8d 4a 04             	lea    0x4(%edx),%ecx
  801219:	89 08                	mov    %ecx,(%eax)
  80121b:	8b 02                	mov    (%edx),%eax
  80121d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80122a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80122e:	8b 10                	mov    (%eax),%edx
  801230:	3b 50 04             	cmp    0x4(%eax),%edx
  801233:	73 0a                	jae    80123f <sprintputch+0x1b>
		*b->buf++ = ch;
  801235:	8d 4a 01             	lea    0x1(%edx),%ecx
  801238:	89 08                	mov    %ecx,(%eax)
  80123a:	8b 45 08             	mov    0x8(%ebp),%eax
  80123d:	88 02                	mov    %al,(%edx)
}
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801247:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80124a:	50                   	push   %eax
  80124b:	ff 75 10             	pushl  0x10(%ebp)
  80124e:	ff 75 0c             	pushl  0xc(%ebp)
  801251:	ff 75 08             	pushl  0x8(%ebp)
  801254:	e8 05 00 00 00       	call   80125e <vprintfmt>
	va_end(ap);
  801259:	83 c4 10             	add    $0x10,%esp
}
  80125c:	c9                   	leave  
  80125d:	c3                   	ret    

0080125e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
  801264:	83 ec 2c             	sub    $0x2c,%esp
  801267:	8b 75 08             	mov    0x8(%ebp),%esi
  80126a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80126d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801270:	eb 12                	jmp    801284 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801272:	85 c0                	test   %eax,%eax
  801274:	0f 84 90 03 00 00    	je     80160a <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80127a:	83 ec 08             	sub    $0x8,%esp
  80127d:	53                   	push   %ebx
  80127e:	50                   	push   %eax
  80127f:	ff d6                	call   *%esi
  801281:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801284:	83 c7 01             	add    $0x1,%edi
  801287:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80128b:	83 f8 25             	cmp    $0x25,%eax
  80128e:	75 e2                	jne    801272 <vprintfmt+0x14>
  801290:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801294:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80129b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012a2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ae:	eb 07                	jmp    8012b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012b3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b7:	8d 47 01             	lea    0x1(%edi),%eax
  8012ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012bd:	0f b6 07             	movzbl (%edi),%eax
  8012c0:	0f b6 c8             	movzbl %al,%ecx
  8012c3:	83 e8 23             	sub    $0x23,%eax
  8012c6:	3c 55                	cmp    $0x55,%al
  8012c8:	0f 87 21 03 00 00    	ja     8015ef <vprintfmt+0x391>
  8012ce:	0f b6 c0             	movzbl %al,%eax
  8012d1:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8012d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012db:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012df:	eb d6                	jmp    8012b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012ef:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012f3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012f6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012f9:	83 fa 09             	cmp    $0x9,%edx
  8012fc:	77 39                	ja     801337 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012fe:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801301:	eb e9                	jmp    8012ec <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801303:	8b 45 14             	mov    0x14(%ebp),%eax
  801306:	8d 48 04             	lea    0x4(%eax),%ecx
  801309:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80130c:	8b 00                	mov    (%eax),%eax
  80130e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801314:	eb 27                	jmp    80133d <vprintfmt+0xdf>
  801316:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801319:	85 c0                	test   %eax,%eax
  80131b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801320:	0f 49 c8             	cmovns %eax,%ecx
  801323:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801329:	eb 8c                	jmp    8012b7 <vprintfmt+0x59>
  80132b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80132e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801335:	eb 80                	jmp    8012b7 <vprintfmt+0x59>
  801337:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80133a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80133d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801341:	0f 89 70 ff ff ff    	jns    8012b7 <vprintfmt+0x59>
				width = precision, precision = -1;
  801347:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80134a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80134d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801354:	e9 5e ff ff ff       	jmp    8012b7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801359:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80135f:	e9 53 ff ff ff       	jmp    8012b7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801364:	8b 45 14             	mov    0x14(%ebp),%eax
  801367:	8d 50 04             	lea    0x4(%eax),%edx
  80136a:	89 55 14             	mov    %edx,0x14(%ebp)
  80136d:	83 ec 08             	sub    $0x8,%esp
  801370:	53                   	push   %ebx
  801371:	ff 30                	pushl  (%eax)
  801373:	ff d6                	call   *%esi
			break;
  801375:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80137b:	e9 04 ff ff ff       	jmp    801284 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801380:	8b 45 14             	mov    0x14(%ebp),%eax
  801383:	8d 50 04             	lea    0x4(%eax),%edx
  801386:	89 55 14             	mov    %edx,0x14(%ebp)
  801389:	8b 00                	mov    (%eax),%eax
  80138b:	99                   	cltd   
  80138c:	31 d0                	xor    %edx,%eax
  80138e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801390:	83 f8 0f             	cmp    $0xf,%eax
  801393:	7f 0b                	jg     8013a0 <vprintfmt+0x142>
  801395:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  80139c:	85 d2                	test   %edx,%edx
  80139e:	75 18                	jne    8013b8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013a0:	50                   	push   %eax
  8013a1:	68 5f 1f 80 00       	push   $0x801f5f
  8013a6:	53                   	push   %ebx
  8013a7:	56                   	push   %esi
  8013a8:	e8 94 fe ff ff       	call   801241 <printfmt>
  8013ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013b3:	e9 cc fe ff ff       	jmp    801284 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013b8:	52                   	push   %edx
  8013b9:	68 dd 1e 80 00       	push   $0x801edd
  8013be:	53                   	push   %ebx
  8013bf:	56                   	push   %esi
  8013c0:	e8 7c fe ff ff       	call   801241 <printfmt>
  8013c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013cb:	e9 b4 fe ff ff       	jmp    801284 <vprintfmt+0x26>
  8013d0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013d6:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8013dc:	8d 50 04             	lea    0x4(%eax),%edx
  8013df:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013e4:	85 ff                	test   %edi,%edi
  8013e6:	ba 58 1f 80 00       	mov    $0x801f58,%edx
  8013eb:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8013ee:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013f2:	0f 84 92 00 00 00    	je     80148a <vprintfmt+0x22c>
  8013f8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8013fc:	0f 8e 96 00 00 00    	jle    801498 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	51                   	push   %ecx
  801406:	57                   	push   %edi
  801407:	e8 86 02 00 00       	call   801692 <strnlen>
  80140c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80140f:	29 c1                	sub    %eax,%ecx
  801411:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801414:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801417:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80141b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80141e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801421:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801423:	eb 0f                	jmp    801434 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	53                   	push   %ebx
  801429:	ff 75 e0             	pushl  -0x20(%ebp)
  80142c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80142e:	83 ef 01             	sub    $0x1,%edi
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	85 ff                	test   %edi,%edi
  801436:	7f ed                	jg     801425 <vprintfmt+0x1c7>
  801438:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80143b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80143e:	85 c9                	test   %ecx,%ecx
  801440:	b8 00 00 00 00       	mov    $0x0,%eax
  801445:	0f 49 c1             	cmovns %ecx,%eax
  801448:	29 c1                	sub    %eax,%ecx
  80144a:	89 75 08             	mov    %esi,0x8(%ebp)
  80144d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801450:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801453:	89 cb                	mov    %ecx,%ebx
  801455:	eb 4d                	jmp    8014a4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801457:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80145b:	74 1b                	je     801478 <vprintfmt+0x21a>
  80145d:	0f be c0             	movsbl %al,%eax
  801460:	83 e8 20             	sub    $0x20,%eax
  801463:	83 f8 5e             	cmp    $0x5e,%eax
  801466:	76 10                	jbe    801478 <vprintfmt+0x21a>
					putch('?', putdat);
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	ff 75 0c             	pushl  0xc(%ebp)
  80146e:	6a 3f                	push   $0x3f
  801470:	ff 55 08             	call   *0x8(%ebp)
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	eb 0d                	jmp    801485 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	ff 75 0c             	pushl  0xc(%ebp)
  80147e:	52                   	push   %edx
  80147f:	ff 55 08             	call   *0x8(%ebp)
  801482:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801485:	83 eb 01             	sub    $0x1,%ebx
  801488:	eb 1a                	jmp    8014a4 <vprintfmt+0x246>
  80148a:	89 75 08             	mov    %esi,0x8(%ebp)
  80148d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801490:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801493:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801496:	eb 0c                	jmp    8014a4 <vprintfmt+0x246>
  801498:	89 75 08             	mov    %esi,0x8(%ebp)
  80149b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80149e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a4:	83 c7 01             	add    $0x1,%edi
  8014a7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014ab:	0f be d0             	movsbl %al,%edx
  8014ae:	85 d2                	test   %edx,%edx
  8014b0:	74 23                	je     8014d5 <vprintfmt+0x277>
  8014b2:	85 f6                	test   %esi,%esi
  8014b4:	78 a1                	js     801457 <vprintfmt+0x1f9>
  8014b6:	83 ee 01             	sub    $0x1,%esi
  8014b9:	79 9c                	jns    801457 <vprintfmt+0x1f9>
  8014bb:	89 df                	mov    %ebx,%edi
  8014bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c3:	eb 18                	jmp    8014dd <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014c5:	83 ec 08             	sub    $0x8,%esp
  8014c8:	53                   	push   %ebx
  8014c9:	6a 20                	push   $0x20
  8014cb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014cd:	83 ef 01             	sub    $0x1,%edi
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	eb 08                	jmp    8014dd <vprintfmt+0x27f>
  8014d5:	89 df                	mov    %ebx,%edi
  8014d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8014da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014dd:	85 ff                	test   %edi,%edi
  8014df:	7f e4                	jg     8014c5 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014e4:	e9 9b fd ff ff       	jmp    801284 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014e9:	83 fa 01             	cmp    $0x1,%edx
  8014ec:	7e 16                	jle    801504 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8014ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f1:	8d 50 08             	lea    0x8(%eax),%edx
  8014f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f7:	8b 50 04             	mov    0x4(%eax),%edx
  8014fa:	8b 00                	mov    (%eax),%eax
  8014fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801502:	eb 32                	jmp    801536 <vprintfmt+0x2d8>
	else if (lflag)
  801504:	85 d2                	test   %edx,%edx
  801506:	74 18                	je     801520 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801508:	8b 45 14             	mov    0x14(%ebp),%eax
  80150b:	8d 50 04             	lea    0x4(%eax),%edx
  80150e:	89 55 14             	mov    %edx,0x14(%ebp)
  801511:	8b 00                	mov    (%eax),%eax
  801513:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801516:	89 c1                	mov    %eax,%ecx
  801518:	c1 f9 1f             	sar    $0x1f,%ecx
  80151b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80151e:	eb 16                	jmp    801536 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801520:	8b 45 14             	mov    0x14(%ebp),%eax
  801523:	8d 50 04             	lea    0x4(%eax),%edx
  801526:	89 55 14             	mov    %edx,0x14(%ebp)
  801529:	8b 00                	mov    (%eax),%eax
  80152b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80152e:	89 c1                	mov    %eax,%ecx
  801530:	c1 f9 1f             	sar    $0x1f,%ecx
  801533:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801536:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801539:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80153c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801541:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801545:	79 74                	jns    8015bb <vprintfmt+0x35d>
				putch('-', putdat);
  801547:	83 ec 08             	sub    $0x8,%esp
  80154a:	53                   	push   %ebx
  80154b:	6a 2d                	push   $0x2d
  80154d:	ff d6                	call   *%esi
				num = -(long long) num;
  80154f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801552:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801555:	f7 d8                	neg    %eax
  801557:	83 d2 00             	adc    $0x0,%edx
  80155a:	f7 da                	neg    %edx
  80155c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80155f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801564:	eb 55                	jmp    8015bb <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801566:	8d 45 14             	lea    0x14(%ebp),%eax
  801569:	e8 7c fc ff ff       	call   8011ea <getuint>
			base = 10;
  80156e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801573:	eb 46                	jmp    8015bb <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801575:	8d 45 14             	lea    0x14(%ebp),%eax
  801578:	e8 6d fc ff ff       	call   8011ea <getuint>
                        base = 8;
  80157d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801582:	eb 37                	jmp    8015bb <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801584:	83 ec 08             	sub    $0x8,%esp
  801587:	53                   	push   %ebx
  801588:	6a 30                	push   $0x30
  80158a:	ff d6                	call   *%esi
			putch('x', putdat);
  80158c:	83 c4 08             	add    $0x8,%esp
  80158f:	53                   	push   %ebx
  801590:	6a 78                	push   $0x78
  801592:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801594:	8b 45 14             	mov    0x14(%ebp),%eax
  801597:	8d 50 04             	lea    0x4(%eax),%edx
  80159a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80159d:	8b 00                	mov    (%eax),%eax
  80159f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015a4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015a7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015ac:	eb 0d                	jmp    8015bb <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b1:	e8 34 fc ff ff       	call   8011ea <getuint>
			base = 16;
  8015b6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015c2:	57                   	push   %edi
  8015c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c6:	51                   	push   %ecx
  8015c7:	52                   	push   %edx
  8015c8:	50                   	push   %eax
  8015c9:	89 da                	mov    %ebx,%edx
  8015cb:	89 f0                	mov    %esi,%eax
  8015cd:	e8 6e fb ff ff       	call   801140 <printnum>
			break;
  8015d2:	83 c4 20             	add    $0x20,%esp
  8015d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015d8:	e9 a7 fc ff ff       	jmp    801284 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	51                   	push   %ecx
  8015e2:	ff d6                	call   *%esi
			break;
  8015e4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015ea:	e9 95 fc ff ff       	jmp    801284 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015ef:	83 ec 08             	sub    $0x8,%esp
  8015f2:	53                   	push   %ebx
  8015f3:	6a 25                	push   $0x25
  8015f5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	eb 03                	jmp    8015ff <vprintfmt+0x3a1>
  8015fc:	83 ef 01             	sub    $0x1,%edi
  8015ff:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801603:	75 f7                	jne    8015fc <vprintfmt+0x39e>
  801605:	e9 7a fc ff ff       	jmp    801284 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80160a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160d:	5b                   	pop    %ebx
  80160e:	5e                   	pop    %esi
  80160f:	5f                   	pop    %edi
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    

00801612 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	83 ec 18             	sub    $0x18,%esp
  801618:	8b 45 08             	mov    0x8(%ebp),%eax
  80161b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80161e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801621:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801625:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801628:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80162f:	85 c0                	test   %eax,%eax
  801631:	74 26                	je     801659 <vsnprintf+0x47>
  801633:	85 d2                	test   %edx,%edx
  801635:	7e 22                	jle    801659 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801637:	ff 75 14             	pushl  0x14(%ebp)
  80163a:	ff 75 10             	pushl  0x10(%ebp)
  80163d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801640:	50                   	push   %eax
  801641:	68 24 12 80 00       	push   $0x801224
  801646:	e8 13 fc ff ff       	call   80125e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80164b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80164e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801651:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	eb 05                	jmp    80165e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801659:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801666:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801669:	50                   	push   %eax
  80166a:	ff 75 10             	pushl  0x10(%ebp)
  80166d:	ff 75 0c             	pushl  0xc(%ebp)
  801670:	ff 75 08             	pushl  0x8(%ebp)
  801673:	e8 9a ff ff ff       	call   801612 <vsnprintf>
	va_end(ap);

	return rc;
}
  801678:	c9                   	leave  
  801679:	c3                   	ret    

0080167a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801680:	b8 00 00 00 00       	mov    $0x0,%eax
  801685:	eb 03                	jmp    80168a <strlen+0x10>
		n++;
  801687:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80168a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80168e:	75 f7                	jne    801687 <strlen+0xd>
		n++;
	return n;
}
  801690:	5d                   	pop    %ebp
  801691:	c3                   	ret    

00801692 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801698:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169b:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a0:	eb 03                	jmp    8016a5 <strnlen+0x13>
		n++;
  8016a2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a5:	39 c2                	cmp    %eax,%edx
  8016a7:	74 08                	je     8016b1 <strnlen+0x1f>
  8016a9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016ad:	75 f3                	jne    8016a2 <strnlen+0x10>
  8016af:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016b1:	5d                   	pop    %ebp
  8016b2:	c3                   	ret    

008016b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	53                   	push   %ebx
  8016b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016bd:	89 c2                	mov    %eax,%edx
  8016bf:	83 c2 01             	add    $0x1,%edx
  8016c2:	83 c1 01             	add    $0x1,%ecx
  8016c5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016c9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016cc:	84 db                	test   %bl,%bl
  8016ce:	75 ef                	jne    8016bf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016d0:	5b                   	pop    %ebx
  8016d1:	5d                   	pop    %ebp
  8016d2:	c3                   	ret    

008016d3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	53                   	push   %ebx
  8016d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016da:	53                   	push   %ebx
  8016db:	e8 9a ff ff ff       	call   80167a <strlen>
  8016e0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016e3:	ff 75 0c             	pushl  0xc(%ebp)
  8016e6:	01 d8                	add    %ebx,%eax
  8016e8:	50                   	push   %eax
  8016e9:	e8 c5 ff ff ff       	call   8016b3 <strcpy>
	return dst;
}
  8016ee:	89 d8                	mov    %ebx,%eax
  8016f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f3:	c9                   	leave  
  8016f4:	c3                   	ret    

008016f5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	56                   	push   %esi
  8016f9:	53                   	push   %ebx
  8016fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801700:	89 f3                	mov    %esi,%ebx
  801702:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801705:	89 f2                	mov    %esi,%edx
  801707:	eb 0f                	jmp    801718 <strncpy+0x23>
		*dst++ = *src;
  801709:	83 c2 01             	add    $0x1,%edx
  80170c:	0f b6 01             	movzbl (%ecx),%eax
  80170f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801712:	80 39 01             	cmpb   $0x1,(%ecx)
  801715:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801718:	39 da                	cmp    %ebx,%edx
  80171a:	75 ed                	jne    801709 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80171c:	89 f0                	mov    %esi,%eax
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	56                   	push   %esi
  801726:	53                   	push   %ebx
  801727:	8b 75 08             	mov    0x8(%ebp),%esi
  80172a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172d:	8b 55 10             	mov    0x10(%ebp),%edx
  801730:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801732:	85 d2                	test   %edx,%edx
  801734:	74 21                	je     801757 <strlcpy+0x35>
  801736:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80173a:	89 f2                	mov    %esi,%edx
  80173c:	eb 09                	jmp    801747 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80173e:	83 c2 01             	add    $0x1,%edx
  801741:	83 c1 01             	add    $0x1,%ecx
  801744:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801747:	39 c2                	cmp    %eax,%edx
  801749:	74 09                	je     801754 <strlcpy+0x32>
  80174b:	0f b6 19             	movzbl (%ecx),%ebx
  80174e:	84 db                	test   %bl,%bl
  801750:	75 ec                	jne    80173e <strlcpy+0x1c>
  801752:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801754:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801757:	29 f0                	sub    %esi,%eax
}
  801759:	5b                   	pop    %ebx
  80175a:	5e                   	pop    %esi
  80175b:	5d                   	pop    %ebp
  80175c:	c3                   	ret    

0080175d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801763:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801766:	eb 06                	jmp    80176e <strcmp+0x11>
		p++, q++;
  801768:	83 c1 01             	add    $0x1,%ecx
  80176b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80176e:	0f b6 01             	movzbl (%ecx),%eax
  801771:	84 c0                	test   %al,%al
  801773:	74 04                	je     801779 <strcmp+0x1c>
  801775:	3a 02                	cmp    (%edx),%al
  801777:	74 ef                	je     801768 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801779:	0f b6 c0             	movzbl %al,%eax
  80177c:	0f b6 12             	movzbl (%edx),%edx
  80177f:	29 d0                	sub    %edx,%eax
}
  801781:	5d                   	pop    %ebp
  801782:	c3                   	ret    

00801783 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	53                   	push   %ebx
  801787:	8b 45 08             	mov    0x8(%ebp),%eax
  80178a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178d:	89 c3                	mov    %eax,%ebx
  80178f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801792:	eb 06                	jmp    80179a <strncmp+0x17>
		n--, p++, q++;
  801794:	83 c0 01             	add    $0x1,%eax
  801797:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80179a:	39 d8                	cmp    %ebx,%eax
  80179c:	74 15                	je     8017b3 <strncmp+0x30>
  80179e:	0f b6 08             	movzbl (%eax),%ecx
  8017a1:	84 c9                	test   %cl,%cl
  8017a3:	74 04                	je     8017a9 <strncmp+0x26>
  8017a5:	3a 0a                	cmp    (%edx),%cl
  8017a7:	74 eb                	je     801794 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a9:	0f b6 00             	movzbl (%eax),%eax
  8017ac:	0f b6 12             	movzbl (%edx),%edx
  8017af:	29 d0                	sub    %edx,%eax
  8017b1:	eb 05                	jmp    8017b8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017b8:	5b                   	pop    %ebx
  8017b9:	5d                   	pop    %ebp
  8017ba:	c3                   	ret    

008017bb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c5:	eb 07                	jmp    8017ce <strchr+0x13>
		if (*s == c)
  8017c7:	38 ca                	cmp    %cl,%dl
  8017c9:	74 0f                	je     8017da <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017cb:	83 c0 01             	add    $0x1,%eax
  8017ce:	0f b6 10             	movzbl (%eax),%edx
  8017d1:	84 d2                	test   %dl,%dl
  8017d3:	75 f2                	jne    8017c7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e6:	eb 03                	jmp    8017eb <strfind+0xf>
  8017e8:	83 c0 01             	add    $0x1,%eax
  8017eb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017ee:	84 d2                	test   %dl,%dl
  8017f0:	74 04                	je     8017f6 <strfind+0x1a>
  8017f2:	38 ca                	cmp    %cl,%dl
  8017f4:	75 f2                	jne    8017e8 <strfind+0xc>
			break;
	return (char *) s;
}
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	57                   	push   %edi
  8017fc:	56                   	push   %esi
  8017fd:	53                   	push   %ebx
  8017fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801801:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801804:	85 c9                	test   %ecx,%ecx
  801806:	74 36                	je     80183e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801808:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80180e:	75 28                	jne    801838 <memset+0x40>
  801810:	f6 c1 03             	test   $0x3,%cl
  801813:	75 23                	jne    801838 <memset+0x40>
		c &= 0xFF;
  801815:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801819:	89 d3                	mov    %edx,%ebx
  80181b:	c1 e3 08             	shl    $0x8,%ebx
  80181e:	89 d6                	mov    %edx,%esi
  801820:	c1 e6 18             	shl    $0x18,%esi
  801823:	89 d0                	mov    %edx,%eax
  801825:	c1 e0 10             	shl    $0x10,%eax
  801828:	09 f0                	or     %esi,%eax
  80182a:	09 c2                	or     %eax,%edx
  80182c:	89 d0                	mov    %edx,%eax
  80182e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801830:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801833:	fc                   	cld    
  801834:	f3 ab                	rep stos %eax,%es:(%edi)
  801836:	eb 06                	jmp    80183e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801838:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183b:	fc                   	cld    
  80183c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80183e:	89 f8                	mov    %edi,%eax
  801840:	5b                   	pop    %ebx
  801841:	5e                   	pop    %esi
  801842:	5f                   	pop    %edi
  801843:	5d                   	pop    %ebp
  801844:	c3                   	ret    

00801845 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	57                   	push   %edi
  801849:	56                   	push   %esi
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801850:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801853:	39 c6                	cmp    %eax,%esi
  801855:	73 35                	jae    80188c <memmove+0x47>
  801857:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80185a:	39 d0                	cmp    %edx,%eax
  80185c:	73 2e                	jae    80188c <memmove+0x47>
		s += n;
		d += n;
  80185e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801861:	89 d6                	mov    %edx,%esi
  801863:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801865:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80186b:	75 13                	jne    801880 <memmove+0x3b>
  80186d:	f6 c1 03             	test   $0x3,%cl
  801870:	75 0e                	jne    801880 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801872:	83 ef 04             	sub    $0x4,%edi
  801875:	8d 72 fc             	lea    -0x4(%edx),%esi
  801878:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80187b:	fd                   	std    
  80187c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80187e:	eb 09                	jmp    801889 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801880:	83 ef 01             	sub    $0x1,%edi
  801883:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801886:	fd                   	std    
  801887:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801889:	fc                   	cld    
  80188a:	eb 1d                	jmp    8018a9 <memmove+0x64>
  80188c:	89 f2                	mov    %esi,%edx
  80188e:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801890:	f6 c2 03             	test   $0x3,%dl
  801893:	75 0f                	jne    8018a4 <memmove+0x5f>
  801895:	f6 c1 03             	test   $0x3,%cl
  801898:	75 0a                	jne    8018a4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80189a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80189d:	89 c7                	mov    %eax,%edi
  80189f:	fc                   	cld    
  8018a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a2:	eb 05                	jmp    8018a9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018a4:	89 c7                	mov    %eax,%edi
  8018a6:	fc                   	cld    
  8018a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018a9:	5e                   	pop    %esi
  8018aa:	5f                   	pop    %edi
  8018ab:	5d                   	pop    %ebp
  8018ac:	c3                   	ret    

008018ad <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018b0:	ff 75 10             	pushl  0x10(%ebp)
  8018b3:	ff 75 0c             	pushl  0xc(%ebp)
  8018b6:	ff 75 08             	pushl  0x8(%ebp)
  8018b9:	e8 87 ff ff ff       	call   801845 <memmove>
}
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	56                   	push   %esi
  8018c4:	53                   	push   %ebx
  8018c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018cb:	89 c6                	mov    %eax,%esi
  8018cd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d0:	eb 1a                	jmp    8018ec <memcmp+0x2c>
		if (*s1 != *s2)
  8018d2:	0f b6 08             	movzbl (%eax),%ecx
  8018d5:	0f b6 1a             	movzbl (%edx),%ebx
  8018d8:	38 d9                	cmp    %bl,%cl
  8018da:	74 0a                	je     8018e6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018dc:	0f b6 c1             	movzbl %cl,%eax
  8018df:	0f b6 db             	movzbl %bl,%ebx
  8018e2:	29 d8                	sub    %ebx,%eax
  8018e4:	eb 0f                	jmp    8018f5 <memcmp+0x35>
		s1++, s2++;
  8018e6:	83 c0 01             	add    $0x1,%eax
  8018e9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ec:	39 f0                	cmp    %esi,%eax
  8018ee:	75 e2                	jne    8018d2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f5:	5b                   	pop    %ebx
  8018f6:	5e                   	pop    %esi
  8018f7:	5d                   	pop    %ebp
  8018f8:	c3                   	ret    

008018f9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801902:	89 c2                	mov    %eax,%edx
  801904:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801907:	eb 07                	jmp    801910 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801909:	38 08                	cmp    %cl,(%eax)
  80190b:	74 07                	je     801914 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80190d:	83 c0 01             	add    $0x1,%eax
  801910:	39 d0                	cmp    %edx,%eax
  801912:	72 f5                	jb     801909 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	57                   	push   %edi
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
  80191c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80191f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801922:	eb 03                	jmp    801927 <strtol+0x11>
		s++;
  801924:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801927:	0f b6 01             	movzbl (%ecx),%eax
  80192a:	3c 09                	cmp    $0x9,%al
  80192c:	74 f6                	je     801924 <strtol+0xe>
  80192e:	3c 20                	cmp    $0x20,%al
  801930:	74 f2                	je     801924 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801932:	3c 2b                	cmp    $0x2b,%al
  801934:	75 0a                	jne    801940 <strtol+0x2a>
		s++;
  801936:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801939:	bf 00 00 00 00       	mov    $0x0,%edi
  80193e:	eb 10                	jmp    801950 <strtol+0x3a>
  801940:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801945:	3c 2d                	cmp    $0x2d,%al
  801947:	75 07                	jne    801950 <strtol+0x3a>
		s++, neg = 1;
  801949:	8d 49 01             	lea    0x1(%ecx),%ecx
  80194c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801950:	85 db                	test   %ebx,%ebx
  801952:	0f 94 c0             	sete   %al
  801955:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80195b:	75 19                	jne    801976 <strtol+0x60>
  80195d:	80 39 30             	cmpb   $0x30,(%ecx)
  801960:	75 14                	jne    801976 <strtol+0x60>
  801962:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801966:	0f 85 82 00 00 00    	jne    8019ee <strtol+0xd8>
		s += 2, base = 16;
  80196c:	83 c1 02             	add    $0x2,%ecx
  80196f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801974:	eb 16                	jmp    80198c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801976:	84 c0                	test   %al,%al
  801978:	74 12                	je     80198c <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80197a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80197f:	80 39 30             	cmpb   $0x30,(%ecx)
  801982:	75 08                	jne    80198c <strtol+0x76>
		s++, base = 8;
  801984:	83 c1 01             	add    $0x1,%ecx
  801987:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80198c:	b8 00 00 00 00       	mov    $0x0,%eax
  801991:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801994:	0f b6 11             	movzbl (%ecx),%edx
  801997:	8d 72 d0             	lea    -0x30(%edx),%esi
  80199a:	89 f3                	mov    %esi,%ebx
  80199c:	80 fb 09             	cmp    $0x9,%bl
  80199f:	77 08                	ja     8019a9 <strtol+0x93>
			dig = *s - '0';
  8019a1:	0f be d2             	movsbl %dl,%edx
  8019a4:	83 ea 30             	sub    $0x30,%edx
  8019a7:	eb 22                	jmp    8019cb <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019a9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019ac:	89 f3                	mov    %esi,%ebx
  8019ae:	80 fb 19             	cmp    $0x19,%bl
  8019b1:	77 08                	ja     8019bb <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019b3:	0f be d2             	movsbl %dl,%edx
  8019b6:	83 ea 57             	sub    $0x57,%edx
  8019b9:	eb 10                	jmp    8019cb <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019bb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019be:	89 f3                	mov    %esi,%ebx
  8019c0:	80 fb 19             	cmp    $0x19,%bl
  8019c3:	77 16                	ja     8019db <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019c5:	0f be d2             	movsbl %dl,%edx
  8019c8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019cb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019ce:	7d 0f                	jge    8019df <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019d0:	83 c1 01             	add    $0x1,%ecx
  8019d3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019d7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019d9:	eb b9                	jmp    801994 <strtol+0x7e>
  8019db:	89 c2                	mov    %eax,%edx
  8019dd:	eb 02                	jmp    8019e1 <strtol+0xcb>
  8019df:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019e5:	74 0d                	je     8019f4 <strtol+0xde>
		*endptr = (char *) s;
  8019e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019ea:	89 0e                	mov    %ecx,(%esi)
  8019ec:	eb 06                	jmp    8019f4 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ee:	84 c0                	test   %al,%al
  8019f0:	75 92                	jne    801984 <strtol+0x6e>
  8019f2:	eb 98                	jmp    80198c <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019f4:	f7 da                	neg    %edx
  8019f6:	85 ff                	test   %edi,%edi
  8019f8:	0f 45 c2             	cmovne %edx,%eax
}
  8019fb:	5b                   	pop    %ebx
  8019fc:	5e                   	pop    %esi
  8019fd:	5f                   	pop    %edi
  8019fe:	5d                   	pop    %ebp
  8019ff:	c3                   	ret    

00801a00 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	56                   	push   %esi
  801a04:	53                   	push   %ebx
  801a05:	8b 75 08             	mov    0x8(%ebp),%esi
  801a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a15:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	50                   	push   %eax
  801a1c:	e8 e4 e8 ff ff       	call   800305 <sys_ipc_recv>
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	85 c0                	test   %eax,%eax
  801a26:	79 16                	jns    801a3e <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801a28:	85 f6                	test   %esi,%esi
  801a2a:	74 06                	je     801a32 <ipc_recv+0x32>
  801a2c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801a32:	85 db                	test   %ebx,%ebx
  801a34:	74 2c                	je     801a62 <ipc_recv+0x62>
  801a36:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a3c:	eb 24                	jmp    801a62 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a3e:	85 f6                	test   %esi,%esi
  801a40:	74 0a                	je     801a4c <ipc_recv+0x4c>
  801a42:	a1 04 40 80 00       	mov    0x804004,%eax
  801a47:	8b 40 74             	mov    0x74(%eax),%eax
  801a4a:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801a4c:	85 db                	test   %ebx,%ebx
  801a4e:	74 0a                	je     801a5a <ipc_recv+0x5a>
  801a50:	a1 04 40 80 00       	mov    0x804004,%eax
  801a55:	8b 40 78             	mov    0x78(%eax),%eax
  801a58:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801a5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a65:	5b                   	pop    %ebx
  801a66:	5e                   	pop    %esi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    

00801a69 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	57                   	push   %edi
  801a6d:	56                   	push   %esi
  801a6e:	53                   	push   %ebx
  801a6f:	83 ec 0c             	sub    $0xc,%esp
  801a72:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a75:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801a7b:	85 db                	test   %ebx,%ebx
  801a7d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a82:	0f 44 d8             	cmove  %eax,%ebx
  801a85:	eb 1c                	jmp    801aa3 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801a87:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a8a:	74 12                	je     801a9e <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801a8c:	50                   	push   %eax
  801a8d:	68 60 22 80 00       	push   $0x802260
  801a92:	6a 39                	push   $0x39
  801a94:	68 7b 22 80 00       	push   $0x80227b
  801a99:	e8 b5 f5 ff ff       	call   801053 <_panic>
                 sys_yield();
  801a9e:	e8 93 e6 ff ff       	call   800136 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801aa3:	ff 75 14             	pushl  0x14(%ebp)
  801aa6:	53                   	push   %ebx
  801aa7:	56                   	push   %esi
  801aa8:	57                   	push   %edi
  801aa9:	e8 34 e8 ff ff       	call   8002e2 <sys_ipc_try_send>
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 d2                	js     801a87 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab8:	5b                   	pop    %ebx
  801ab9:	5e                   	pop    %esi
  801aba:	5f                   	pop    %edi
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    

00801abd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ac8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801acb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad1:	8b 52 50             	mov    0x50(%edx),%edx
  801ad4:	39 ca                	cmp    %ecx,%edx
  801ad6:	75 0d                	jne    801ae5 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ad8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801adb:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ae0:	8b 40 08             	mov    0x8(%eax),%eax
  801ae3:	eb 0e                	jmp    801af3 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae5:	83 c0 01             	add    $0x1,%eax
  801ae8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801aed:	75 d9                	jne    801ac8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aef:	66 b8 00 00          	mov    $0x0,%ax
}
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afb:	89 d0                	mov    %edx,%eax
  801afd:	c1 e8 16             	shr    $0x16,%eax
  801b00:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b07:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0c:	f6 c1 01             	test   $0x1,%cl
  801b0f:	74 1d                	je     801b2e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b11:	c1 ea 0c             	shr    $0xc,%edx
  801b14:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b1b:	f6 c2 01             	test   $0x1,%dl
  801b1e:	74 0e                	je     801b2e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b20:	c1 ea 0c             	shr    $0xc,%edx
  801b23:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b2a:	ef 
  801b2b:	0f b7 c0             	movzwl %ax,%eax
}
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <__udivdi3>:
  801b30:	55                   	push   %ebp
  801b31:	57                   	push   %edi
  801b32:	56                   	push   %esi
  801b33:	83 ec 10             	sub    $0x10,%esp
  801b36:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b3a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b3e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b42:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b46:	85 d2                	test   %edx,%edx
  801b48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b4c:	89 34 24             	mov    %esi,(%esp)
  801b4f:	89 c8                	mov    %ecx,%eax
  801b51:	75 35                	jne    801b88 <__udivdi3+0x58>
  801b53:	39 f1                	cmp    %esi,%ecx
  801b55:	0f 87 bd 00 00 00    	ja     801c18 <__udivdi3+0xe8>
  801b5b:	85 c9                	test   %ecx,%ecx
  801b5d:	89 cd                	mov    %ecx,%ebp
  801b5f:	75 0b                	jne    801b6c <__udivdi3+0x3c>
  801b61:	b8 01 00 00 00       	mov    $0x1,%eax
  801b66:	31 d2                	xor    %edx,%edx
  801b68:	f7 f1                	div    %ecx
  801b6a:	89 c5                	mov    %eax,%ebp
  801b6c:	89 f0                	mov    %esi,%eax
  801b6e:	31 d2                	xor    %edx,%edx
  801b70:	f7 f5                	div    %ebp
  801b72:	89 c6                	mov    %eax,%esi
  801b74:	89 f8                	mov    %edi,%eax
  801b76:	f7 f5                	div    %ebp
  801b78:	89 f2                	mov    %esi,%edx
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	5e                   	pop    %esi
  801b7e:	5f                   	pop    %edi
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    
  801b81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b88:	3b 14 24             	cmp    (%esp),%edx
  801b8b:	77 7b                	ja     801c08 <__udivdi3+0xd8>
  801b8d:	0f bd f2             	bsr    %edx,%esi
  801b90:	83 f6 1f             	xor    $0x1f,%esi
  801b93:	0f 84 97 00 00 00    	je     801c30 <__udivdi3+0x100>
  801b99:	bd 20 00 00 00       	mov    $0x20,%ebp
  801b9e:	89 d7                	mov    %edx,%edi
  801ba0:	89 f1                	mov    %esi,%ecx
  801ba2:	29 f5                	sub    %esi,%ebp
  801ba4:	d3 e7                	shl    %cl,%edi
  801ba6:	89 c2                	mov    %eax,%edx
  801ba8:	89 e9                	mov    %ebp,%ecx
  801baa:	d3 ea                	shr    %cl,%edx
  801bac:	89 f1                	mov    %esi,%ecx
  801bae:	09 fa                	or     %edi,%edx
  801bb0:	8b 3c 24             	mov    (%esp),%edi
  801bb3:	d3 e0                	shl    %cl,%eax
  801bb5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bb9:	89 e9                	mov    %ebp,%ecx
  801bbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bbf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801bc3:	89 fa                	mov    %edi,%edx
  801bc5:	d3 ea                	shr    %cl,%edx
  801bc7:	89 f1                	mov    %esi,%ecx
  801bc9:	d3 e7                	shl    %cl,%edi
  801bcb:	89 e9                	mov    %ebp,%ecx
  801bcd:	d3 e8                	shr    %cl,%eax
  801bcf:	09 c7                	or     %eax,%edi
  801bd1:	89 f8                	mov    %edi,%eax
  801bd3:	f7 74 24 08          	divl   0x8(%esp)
  801bd7:	89 d5                	mov    %edx,%ebp
  801bd9:	89 c7                	mov    %eax,%edi
  801bdb:	f7 64 24 0c          	mull   0xc(%esp)
  801bdf:	39 d5                	cmp    %edx,%ebp
  801be1:	89 14 24             	mov    %edx,(%esp)
  801be4:	72 11                	jb     801bf7 <__udivdi3+0xc7>
  801be6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801bea:	89 f1                	mov    %esi,%ecx
  801bec:	d3 e2                	shl    %cl,%edx
  801bee:	39 c2                	cmp    %eax,%edx
  801bf0:	73 5e                	jae    801c50 <__udivdi3+0x120>
  801bf2:	3b 2c 24             	cmp    (%esp),%ebp
  801bf5:	75 59                	jne    801c50 <__udivdi3+0x120>
  801bf7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801bfa:	31 f6                	xor    %esi,%esi
  801bfc:	89 f2                	mov    %esi,%edx
  801bfe:	83 c4 10             	add    $0x10,%esp
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    
  801c05:	8d 76 00             	lea    0x0(%esi),%esi
  801c08:	31 f6                	xor    %esi,%esi
  801c0a:	31 c0                	xor    %eax,%eax
  801c0c:	89 f2                	mov    %esi,%edx
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	5e                   	pop    %esi
  801c12:	5f                   	pop    %edi
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    
  801c15:	8d 76 00             	lea    0x0(%esi),%esi
  801c18:	89 f2                	mov    %esi,%edx
  801c1a:	31 f6                	xor    %esi,%esi
  801c1c:	89 f8                	mov    %edi,%eax
  801c1e:	f7 f1                	div    %ecx
  801c20:	89 f2                	mov    %esi,%edx
  801c22:	83 c4 10             	add    $0x10,%esp
  801c25:	5e                   	pop    %esi
  801c26:	5f                   	pop    %edi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c34:	76 0b                	jbe    801c41 <__udivdi3+0x111>
  801c36:	31 c0                	xor    %eax,%eax
  801c38:	3b 14 24             	cmp    (%esp),%edx
  801c3b:	0f 83 37 ff ff ff    	jae    801b78 <__udivdi3+0x48>
  801c41:	b8 01 00 00 00       	mov    $0x1,%eax
  801c46:	e9 2d ff ff ff       	jmp    801b78 <__udivdi3+0x48>
  801c4b:	90                   	nop
  801c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c50:	89 f8                	mov    %edi,%eax
  801c52:	31 f6                	xor    %esi,%esi
  801c54:	e9 1f ff ff ff       	jmp    801b78 <__udivdi3+0x48>
  801c59:	66 90                	xchg   %ax,%ax
  801c5b:	66 90                	xchg   %ax,%ax
  801c5d:	66 90                	xchg   %ax,%ax
  801c5f:	90                   	nop

00801c60 <__umoddi3>:
  801c60:	55                   	push   %ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	83 ec 20             	sub    $0x20,%esp
  801c66:	8b 44 24 34          	mov    0x34(%esp),%eax
  801c6a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c6e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c72:	89 c6                	mov    %eax,%esi
  801c74:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c78:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c7c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801c80:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c84:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801c88:	89 74 24 18          	mov    %esi,0x18(%esp)
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	89 c2                	mov    %eax,%edx
  801c90:	75 1e                	jne    801cb0 <__umoddi3+0x50>
  801c92:	39 f7                	cmp    %esi,%edi
  801c94:	76 52                	jbe    801ce8 <__umoddi3+0x88>
  801c96:	89 c8                	mov    %ecx,%eax
  801c98:	89 f2                	mov    %esi,%edx
  801c9a:	f7 f7                	div    %edi
  801c9c:	89 d0                	mov    %edx,%eax
  801c9e:	31 d2                	xor    %edx,%edx
  801ca0:	83 c4 20             	add    $0x20,%esp
  801ca3:	5e                   	pop    %esi
  801ca4:	5f                   	pop    %edi
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    
  801ca7:	89 f6                	mov    %esi,%esi
  801ca9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801cb0:	39 f0                	cmp    %esi,%eax
  801cb2:	77 5c                	ja     801d10 <__umoddi3+0xb0>
  801cb4:	0f bd e8             	bsr    %eax,%ebp
  801cb7:	83 f5 1f             	xor    $0x1f,%ebp
  801cba:	75 64                	jne    801d20 <__umoddi3+0xc0>
  801cbc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801cc0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801cc4:	0f 86 f6 00 00 00    	jbe    801dc0 <__umoddi3+0x160>
  801cca:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cce:	0f 82 ec 00 00 00    	jb     801dc0 <__umoddi3+0x160>
  801cd4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801cd8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801cdc:	83 c4 20             	add    $0x20,%esp
  801cdf:	5e                   	pop    %esi
  801ce0:	5f                   	pop    %edi
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    
  801ce3:	90                   	nop
  801ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce8:	85 ff                	test   %edi,%edi
  801cea:	89 fd                	mov    %edi,%ebp
  801cec:	75 0b                	jne    801cf9 <__umoddi3+0x99>
  801cee:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf3:	31 d2                	xor    %edx,%edx
  801cf5:	f7 f7                	div    %edi
  801cf7:	89 c5                	mov    %eax,%ebp
  801cf9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801cfd:	31 d2                	xor    %edx,%edx
  801cff:	f7 f5                	div    %ebp
  801d01:	89 c8                	mov    %ecx,%eax
  801d03:	f7 f5                	div    %ebp
  801d05:	eb 95                	jmp    801c9c <__umoddi3+0x3c>
  801d07:	89 f6                	mov    %esi,%esi
  801d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	83 c4 20             	add    $0x20,%esp
  801d17:	5e                   	pop    %esi
  801d18:	5f                   	pop    %edi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    
  801d1b:	90                   	nop
  801d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d20:	b8 20 00 00 00       	mov    $0x20,%eax
  801d25:	89 e9                	mov    %ebp,%ecx
  801d27:	29 e8                	sub    %ebp,%eax
  801d29:	d3 e2                	shl    %cl,%edx
  801d2b:	89 c7                	mov    %eax,%edi
  801d2d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d31:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d35:	89 f9                	mov    %edi,%ecx
  801d37:	d3 e8                	shr    %cl,%eax
  801d39:	89 c1                	mov    %eax,%ecx
  801d3b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d3f:	09 d1                	or     %edx,%ecx
  801d41:	89 fa                	mov    %edi,%edx
  801d43:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d47:	89 e9                	mov    %ebp,%ecx
  801d49:	d3 e0                	shl    %cl,%eax
  801d4b:	89 f9                	mov    %edi,%ecx
  801d4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d51:	89 f0                	mov    %esi,%eax
  801d53:	d3 e8                	shr    %cl,%eax
  801d55:	89 e9                	mov    %ebp,%ecx
  801d57:	89 c7                	mov    %eax,%edi
  801d59:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d5d:	d3 e6                	shl    %cl,%esi
  801d5f:	89 d1                	mov    %edx,%ecx
  801d61:	89 fa                	mov    %edi,%edx
  801d63:	d3 e8                	shr    %cl,%eax
  801d65:	89 e9                	mov    %ebp,%ecx
  801d67:	09 f0                	or     %esi,%eax
  801d69:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801d6d:	f7 74 24 10          	divl   0x10(%esp)
  801d71:	d3 e6                	shl    %cl,%esi
  801d73:	89 d1                	mov    %edx,%ecx
  801d75:	f7 64 24 0c          	mull   0xc(%esp)
  801d79:	39 d1                	cmp    %edx,%ecx
  801d7b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801d7f:	89 d7                	mov    %edx,%edi
  801d81:	89 c6                	mov    %eax,%esi
  801d83:	72 0a                	jb     801d8f <__umoddi3+0x12f>
  801d85:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801d89:	73 10                	jae    801d9b <__umoddi3+0x13b>
  801d8b:	39 d1                	cmp    %edx,%ecx
  801d8d:	75 0c                	jne    801d9b <__umoddi3+0x13b>
  801d8f:	89 d7                	mov    %edx,%edi
  801d91:	89 c6                	mov    %eax,%esi
  801d93:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801d97:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801d9b:	89 ca                	mov    %ecx,%edx
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801da3:	29 f0                	sub    %esi,%eax
  801da5:	19 fa                	sbb    %edi,%edx
  801da7:	d3 e8                	shr    %cl,%eax
  801da9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801dae:	89 d7                	mov    %edx,%edi
  801db0:	d3 e7                	shl    %cl,%edi
  801db2:	89 e9                	mov    %ebp,%ecx
  801db4:	09 f8                	or     %edi,%eax
  801db6:	d3 ea                	shr    %cl,%edx
  801db8:	83 c4 20             	add    $0x20,%esp
  801dbb:	5e                   	pop    %esi
  801dbc:	5f                   	pop    %edi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    
  801dbf:	90                   	nop
  801dc0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801dc4:	29 f9                	sub    %edi,%ecx
  801dc6:	19 c6                	sbb    %eax,%esi
  801dc8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801dcc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801dd0:	e9 ff fe ff ff       	jmp    801cd4 <__umoddi3+0x74>
