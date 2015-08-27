
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 61 03 80 00       	push   $0x800361
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
  80004f:	83 c4 10             	add    $0x10,%esp
}
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
  800090:	83 c4 10             	add    $0x10,%esp
}
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 ad 04 00 00       	call   800552 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
  8000af:	83 c4 10             	add    $0x10,%esp
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 ca 1e 80 00       	push   $0x801eca
  80011e:	6a 23                	push   $0x23
  800120:	68 e7 1e 80 00       	push   $0x801ee7
  800125:	e8 68 0f 00 00       	call   801092 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 ca 1e 80 00       	push   $0x801eca
  80019f:	6a 23                	push   $0x23
  8001a1:	68 e7 1e 80 00       	push   $0x801ee7
  8001a6:	e8 e7 0e 00 00       	call   801092 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 ca 1e 80 00       	push   $0x801eca
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 e7 1e 80 00       	push   $0x801ee7
  8001e8:	e8 a5 0e 00 00       	call   801092 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 ca 1e 80 00       	push   $0x801eca
  800223:	6a 23                	push   $0x23
  800225:	68 e7 1e 80 00       	push   $0x801ee7
  80022a:	e8 63 0e 00 00       	call   801092 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 ca 1e 80 00       	push   $0x801eca
  800265:	6a 23                	push   $0x23
  800267:	68 e7 1e 80 00       	push   $0x801ee7
  80026c:	e8 21 0e 00 00       	call   801092 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 ca 1e 80 00       	push   $0x801eca
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 e7 1e 80 00       	push   $0x801ee7
  8002ae:	e8 df 0d 00 00       	call   801092 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 ca 1e 80 00       	push   $0x801eca
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 e7 1e 80 00       	push   $0x801ee7
  8002f0:	e8 9d 0d 00 00       	call   801092 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 ca 1e 80 00       	push   $0x801eca
  80034d:	6a 23                	push   $0x23
  80034f:	68 e7 1e 80 00       	push   $0x801ee7
  800354:	e8 39 0d 00 00       	call   801092 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800361:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800362:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800367:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  80036c:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  800371:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  800375:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  800379:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  80037b:	83 c4 08             	add    $0x8,%esp
        popal
  80037e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  80037f:	83 c4 04             	add    $0x4,%esp
        popfl
  800382:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  800383:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800384:	c3                   	ret    

00800385 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	05 00 00 00 30       	add    $0x30000000,%eax
  800390:	c1 e8 0c             	shr    $0xc,%eax
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
  80039b:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8003a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003a5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003b7:	89 c2                	mov    %eax,%edx
  8003b9:	c1 ea 16             	shr    $0x16,%edx
  8003bc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c3:	f6 c2 01             	test   $0x1,%dl
  8003c6:	74 11                	je     8003d9 <fd_alloc+0x2d>
  8003c8:	89 c2                	mov    %eax,%edx
  8003ca:	c1 ea 0c             	shr    $0xc,%edx
  8003cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d4:	f6 c2 01             	test   $0x1,%dl
  8003d7:	75 09                	jne    8003e2 <fd_alloc+0x36>
			*fd_store = fd;
  8003d9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003db:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e0:	eb 17                	jmp    8003f9 <fd_alloc+0x4d>
  8003e2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ec:	75 c9                	jne    8003b7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ee:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003f4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800401:	83 f8 1f             	cmp    $0x1f,%eax
  800404:	77 36                	ja     80043c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800406:	c1 e0 0c             	shl    $0xc,%eax
  800409:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80040e:	89 c2                	mov    %eax,%edx
  800410:	c1 ea 16             	shr    $0x16,%edx
  800413:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041a:	f6 c2 01             	test   $0x1,%dl
  80041d:	74 24                	je     800443 <fd_lookup+0x48>
  80041f:	89 c2                	mov    %eax,%edx
  800421:	c1 ea 0c             	shr    $0xc,%edx
  800424:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042b:	f6 c2 01             	test   $0x1,%dl
  80042e:	74 1a                	je     80044a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800430:	8b 55 0c             	mov    0xc(%ebp),%edx
  800433:	89 02                	mov    %eax,(%edx)
	return 0;
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
  80043a:	eb 13                	jmp    80044f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800441:	eb 0c                	jmp    80044f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800443:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800448:	eb 05                	jmp    80044f <fd_lookup+0x54>
  80044a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045a:	ba 74 1f 80 00       	mov    $0x801f74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80045f:	eb 13                	jmp    800474 <dev_lookup+0x23>
  800461:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800464:	39 08                	cmp    %ecx,(%eax)
  800466:	75 0c                	jne    800474 <dev_lookup+0x23>
			*dev = devtab[i];
  800468:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	eb 2e                	jmp    8004a2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800474:	8b 02                	mov    (%edx),%eax
  800476:	85 c0                	test   %eax,%eax
  800478:	75 e7                	jne    800461 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80047a:	a1 04 40 80 00       	mov    0x804004,%eax
  80047f:	8b 40 48             	mov    0x48(%eax),%eax
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	51                   	push   %ecx
  800486:	50                   	push   %eax
  800487:	68 f8 1e 80 00       	push   $0x801ef8
  80048c:	e8 da 0c 00 00       	call   80116b <cprintf>
	*dev = 0;
  800491:	8b 45 0c             	mov    0xc(%ebp),%eax
  800494:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004a2:	c9                   	leave  
  8004a3:	c3                   	ret    

008004a4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	56                   	push   %esi
  8004a8:	53                   	push   %ebx
  8004a9:	83 ec 10             	sub    $0x10,%esp
  8004ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b5:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004b6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004bc:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004bf:	50                   	push   %eax
  8004c0:	e8 36 ff ff ff       	call   8003fb <fd_lookup>
  8004c5:	83 c4 08             	add    $0x8,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	78 05                	js     8004d1 <fd_close+0x2d>
	    || fd != fd2)
  8004cc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004cf:	74 0c                	je     8004dd <fd_close+0x39>
		return (must_exist ? r : 0);
  8004d1:	84 db                	test   %bl,%bl
  8004d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d8:	0f 44 c2             	cmove  %edx,%eax
  8004db:	eb 41                	jmp    80051e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e3:	50                   	push   %eax
  8004e4:	ff 36                	pushl  (%esi)
  8004e6:	e8 66 ff ff ff       	call   800451 <dev_lookup>
  8004eb:	89 c3                	mov    %eax,%ebx
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	78 1a                	js     80050e <fd_close+0x6a>
		if (dev->dev_close)
  8004f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004f7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004fa:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ff:	85 c0                	test   %eax,%eax
  800501:	74 0b                	je     80050e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800503:	83 ec 0c             	sub    $0xc,%esp
  800506:	56                   	push   %esi
  800507:	ff d0                	call   *%eax
  800509:	89 c3                	mov    %eax,%ebx
  80050b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	56                   	push   %esi
  800512:	6a 00                	push   $0x0
  800514:	e8 dc fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	89 d8                	mov    %ebx,%eax
}
  80051e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800521:	5b                   	pop    %ebx
  800522:	5e                   	pop    %esi
  800523:	5d                   	pop    %ebp
  800524:	c3                   	ret    

00800525 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80052b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80052e:	50                   	push   %eax
  80052f:	ff 75 08             	pushl  0x8(%ebp)
  800532:	e8 c4 fe ff ff       	call   8003fb <fd_lookup>
  800537:	89 c2                	mov    %eax,%edx
  800539:	83 c4 08             	add    $0x8,%esp
  80053c:	85 d2                	test   %edx,%edx
  80053e:	78 10                	js     800550 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	6a 01                	push   $0x1
  800545:	ff 75 f4             	pushl  -0xc(%ebp)
  800548:	e8 57 ff ff ff       	call   8004a4 <fd_close>
  80054d:	83 c4 10             	add    $0x10,%esp
}
  800550:	c9                   	leave  
  800551:	c3                   	ret    

00800552 <close_all>:

void
close_all(void)
{
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	53                   	push   %ebx
  800556:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800559:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	53                   	push   %ebx
  800562:	e8 be ff ff ff       	call   800525 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800567:	83 c3 01             	add    $0x1,%ebx
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	83 fb 20             	cmp    $0x20,%ebx
  800570:	75 ec                	jne    80055e <close_all+0xc>
		close(i);
}
  800572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800575:	c9                   	leave  
  800576:	c3                   	ret    

00800577 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
  80057a:	57                   	push   %edi
  80057b:	56                   	push   %esi
  80057c:	53                   	push   %ebx
  80057d:	83 ec 2c             	sub    $0x2c,%esp
  800580:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800583:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800586:	50                   	push   %eax
  800587:	ff 75 08             	pushl  0x8(%ebp)
  80058a:	e8 6c fe ff ff       	call   8003fb <fd_lookup>
  80058f:	89 c2                	mov    %eax,%edx
  800591:	83 c4 08             	add    $0x8,%esp
  800594:	85 d2                	test   %edx,%edx
  800596:	0f 88 c1 00 00 00    	js     80065d <dup+0xe6>
		return r;
	close(newfdnum);
  80059c:	83 ec 0c             	sub    $0xc,%esp
  80059f:	56                   	push   %esi
  8005a0:	e8 80 ff ff ff       	call   800525 <close>

	newfd = INDEX2FD(newfdnum);
  8005a5:	89 f3                	mov    %esi,%ebx
  8005a7:	c1 e3 0c             	shl    $0xc,%ebx
  8005aa:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005b0:	83 c4 04             	add    $0x4,%esp
  8005b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b6:	e8 da fd ff ff       	call   800395 <fd2data>
  8005bb:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005bd:	89 1c 24             	mov    %ebx,(%esp)
  8005c0:	e8 d0 fd ff ff       	call   800395 <fd2data>
  8005c5:	83 c4 10             	add    $0x10,%esp
  8005c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005cb:	89 f8                	mov    %edi,%eax
  8005cd:	c1 e8 16             	shr    $0x16,%eax
  8005d0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005d7:	a8 01                	test   $0x1,%al
  8005d9:	74 37                	je     800612 <dup+0x9b>
  8005db:	89 f8                	mov    %edi,%eax
  8005dd:	c1 e8 0c             	shr    $0xc,%eax
  8005e0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005e7:	f6 c2 01             	test   $0x1,%dl
  8005ea:	74 26                	je     800612 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fb:	50                   	push   %eax
  8005fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ff:	6a 00                	push   $0x0
  800601:	57                   	push   %edi
  800602:	6a 00                	push   $0x0
  800604:	e8 aa fb ff ff       	call   8001b3 <sys_page_map>
  800609:	89 c7                	mov    %eax,%edi
  80060b:	83 c4 20             	add    $0x20,%esp
  80060e:	85 c0                	test   %eax,%eax
  800610:	78 2e                	js     800640 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800612:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800615:	89 d0                	mov    %edx,%eax
  800617:	c1 e8 0c             	shr    $0xc,%eax
  80061a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	25 07 0e 00 00       	and    $0xe07,%eax
  800629:	50                   	push   %eax
  80062a:	53                   	push   %ebx
  80062b:	6a 00                	push   $0x0
  80062d:	52                   	push   %edx
  80062e:	6a 00                	push   $0x0
  800630:	e8 7e fb ff ff       	call   8001b3 <sys_page_map>
  800635:	89 c7                	mov    %eax,%edi
  800637:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80063a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80063c:	85 ff                	test   %edi,%edi
  80063e:	79 1d                	jns    80065d <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	6a 00                	push   $0x0
  800646:	e8 aa fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800651:	6a 00                	push   $0x0
  800653:	e8 9d fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800658:	83 c4 10             	add    $0x10,%esp
  80065b:	89 f8                	mov    %edi,%eax
}
  80065d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800660:	5b                   	pop    %ebx
  800661:	5e                   	pop    %esi
  800662:	5f                   	pop    %edi
  800663:	5d                   	pop    %ebp
  800664:	c3                   	ret    

00800665 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800665:	55                   	push   %ebp
  800666:	89 e5                	mov    %esp,%ebp
  800668:	53                   	push   %ebx
  800669:	83 ec 14             	sub    $0x14,%esp
  80066c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80066f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800672:	50                   	push   %eax
  800673:	53                   	push   %ebx
  800674:	e8 82 fd ff ff       	call   8003fb <fd_lookup>
  800679:	83 c4 08             	add    $0x8,%esp
  80067c:	89 c2                	mov    %eax,%edx
  80067e:	85 c0                	test   %eax,%eax
  800680:	78 6d                	js     8006ef <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800688:	50                   	push   %eax
  800689:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80068c:	ff 30                	pushl  (%eax)
  80068e:	e8 be fd ff ff       	call   800451 <dev_lookup>
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	85 c0                	test   %eax,%eax
  800698:	78 4c                	js     8006e6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80069a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80069d:	8b 42 08             	mov    0x8(%edx),%eax
  8006a0:	83 e0 03             	and    $0x3,%eax
  8006a3:	83 f8 01             	cmp    $0x1,%eax
  8006a6:	75 21                	jne    8006c9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8006ad:	8b 40 48             	mov    0x48(%eax),%eax
  8006b0:	83 ec 04             	sub    $0x4,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	50                   	push   %eax
  8006b5:	68 39 1f 80 00       	push   $0x801f39
  8006ba:	e8 ac 0a 00 00       	call   80116b <cprintf>
		return -E_INVAL;
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006c7:	eb 26                	jmp    8006ef <read+0x8a>
	}
	if (!dev->dev_read)
  8006c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cc:	8b 40 08             	mov    0x8(%eax),%eax
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 17                	je     8006ea <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d3:	83 ec 04             	sub    $0x4,%esp
  8006d6:	ff 75 10             	pushl  0x10(%ebp)
  8006d9:	ff 75 0c             	pushl  0xc(%ebp)
  8006dc:	52                   	push   %edx
  8006dd:	ff d0                	call   *%eax
  8006df:	89 c2                	mov    %eax,%edx
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	eb 09                	jmp    8006ef <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e6:	89 c2                	mov    %eax,%edx
  8006e8:	eb 05                	jmp    8006ef <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ef:	89 d0                	mov    %edx,%eax
  8006f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    

008006f6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	57                   	push   %edi
  8006fa:	56                   	push   %esi
  8006fb:	53                   	push   %ebx
  8006fc:	83 ec 0c             	sub    $0xc,%esp
  8006ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800702:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800705:	bb 00 00 00 00       	mov    $0x0,%ebx
  80070a:	eb 21                	jmp    80072d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80070c:	83 ec 04             	sub    $0x4,%esp
  80070f:	89 f0                	mov    %esi,%eax
  800711:	29 d8                	sub    %ebx,%eax
  800713:	50                   	push   %eax
  800714:	89 d8                	mov    %ebx,%eax
  800716:	03 45 0c             	add    0xc(%ebp),%eax
  800719:	50                   	push   %eax
  80071a:	57                   	push   %edi
  80071b:	e8 45 ff ff ff       	call   800665 <read>
		if (m < 0)
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	85 c0                	test   %eax,%eax
  800725:	78 0c                	js     800733 <readn+0x3d>
			return m;
		if (m == 0)
  800727:	85 c0                	test   %eax,%eax
  800729:	74 06                	je     800731 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80072b:	01 c3                	add    %eax,%ebx
  80072d:	39 f3                	cmp    %esi,%ebx
  80072f:	72 db                	jb     80070c <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800731:	89 d8                	mov    %ebx,%eax
}
  800733:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800736:	5b                   	pop    %ebx
  800737:	5e                   	pop    %esi
  800738:	5f                   	pop    %edi
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	83 ec 14             	sub    $0x14,%esp
  800742:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800745:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	53                   	push   %ebx
  80074a:	e8 ac fc ff ff       	call   8003fb <fd_lookup>
  80074f:	83 c4 08             	add    $0x8,%esp
  800752:	89 c2                	mov    %eax,%edx
  800754:	85 c0                	test   %eax,%eax
  800756:	78 68                	js     8007c0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80075e:	50                   	push   %eax
  80075f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800762:	ff 30                	pushl  (%eax)
  800764:	e8 e8 fc ff ff       	call   800451 <dev_lookup>
  800769:	83 c4 10             	add    $0x10,%esp
  80076c:	85 c0                	test   %eax,%eax
  80076e:	78 47                	js     8007b7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800773:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800777:	75 21                	jne    80079a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800779:	a1 04 40 80 00       	mov    0x804004,%eax
  80077e:	8b 40 48             	mov    0x48(%eax),%eax
  800781:	83 ec 04             	sub    $0x4,%esp
  800784:	53                   	push   %ebx
  800785:	50                   	push   %eax
  800786:	68 55 1f 80 00       	push   $0x801f55
  80078b:	e8 db 09 00 00       	call   80116b <cprintf>
		return -E_INVAL;
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800798:	eb 26                	jmp    8007c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80079d:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a0:	85 d2                	test   %edx,%edx
  8007a2:	74 17                	je     8007bb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a4:	83 ec 04             	sub    $0x4,%esp
  8007a7:	ff 75 10             	pushl  0x10(%ebp)
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	50                   	push   %eax
  8007ae:	ff d2                	call   *%edx
  8007b0:	89 c2                	mov    %eax,%edx
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb 09                	jmp    8007c0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b7:	89 c2                	mov    %eax,%edx
  8007b9:	eb 05                	jmp    8007c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c0:	89 d0                	mov    %edx,%eax
  8007c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007cd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	ff 75 08             	pushl  0x8(%ebp)
  8007d4:	e8 22 fc ff ff       	call   8003fb <fd_lookup>
  8007d9:	83 c4 08             	add    $0x8,%esp
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	78 0e                	js     8007ee <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	83 ec 14             	sub    $0x14,%esp
  8007f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fd:	50                   	push   %eax
  8007fe:	53                   	push   %ebx
  8007ff:	e8 f7 fb ff ff       	call   8003fb <fd_lookup>
  800804:	83 c4 08             	add    $0x8,%esp
  800807:	89 c2                	mov    %eax,%edx
  800809:	85 c0                	test   %eax,%eax
  80080b:	78 65                	js     800872 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800813:	50                   	push   %eax
  800814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800817:	ff 30                	pushl  (%eax)
  800819:	e8 33 fc ff ff       	call   800451 <dev_lookup>
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	85 c0                	test   %eax,%eax
  800823:	78 44                	js     800869 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800828:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082c:	75 21                	jne    80084f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80082e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800833:	8b 40 48             	mov    0x48(%eax),%eax
  800836:	83 ec 04             	sub    $0x4,%esp
  800839:	53                   	push   %ebx
  80083a:	50                   	push   %eax
  80083b:	68 18 1f 80 00       	push   $0x801f18
  800840:	e8 26 09 00 00       	call   80116b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80084d:	eb 23                	jmp    800872 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80084f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800852:	8b 52 18             	mov    0x18(%edx),%edx
  800855:	85 d2                	test   %edx,%edx
  800857:	74 14                	je     80086d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	50                   	push   %eax
  800860:	ff d2                	call   *%edx
  800862:	89 c2                	mov    %eax,%edx
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	eb 09                	jmp    800872 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800869:	89 c2                	mov    %eax,%edx
  80086b:	eb 05                	jmp    800872 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80086d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800872:	89 d0                	mov    %edx,%eax
  800874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	83 ec 14             	sub    $0x14,%esp
  800880:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800883:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	ff 75 08             	pushl  0x8(%ebp)
  80088a:	e8 6c fb ff ff       	call   8003fb <fd_lookup>
  80088f:	83 c4 08             	add    $0x8,%esp
  800892:	89 c2                	mov    %eax,%edx
  800894:	85 c0                	test   %eax,%eax
  800896:	78 58                	js     8008f0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089e:	50                   	push   %eax
  80089f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a2:	ff 30                	pushl  (%eax)
  8008a4:	e8 a8 fb ff ff       	call   800451 <dev_lookup>
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	78 37                	js     8008e7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b7:	74 32                	je     8008eb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008b9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008bc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c3:	00 00 00 
	stat->st_isdir = 0;
  8008c6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008cd:	00 00 00 
	stat->st_dev = dev;
  8008d0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	53                   	push   %ebx
  8008da:	ff 75 f0             	pushl  -0x10(%ebp)
  8008dd:	ff 50 14             	call   *0x14(%eax)
  8008e0:	89 c2                	mov    %eax,%edx
  8008e2:	83 c4 10             	add    $0x10,%esp
  8008e5:	eb 09                	jmp    8008f0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e7:	89 c2                	mov    %eax,%edx
  8008e9:	eb 05                	jmp    8008f0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	6a 00                	push   $0x0
  800901:	ff 75 08             	pushl  0x8(%ebp)
  800904:	e8 09 02 00 00       	call   800b12 <open>
  800909:	89 c3                	mov    %eax,%ebx
  80090b:	83 c4 10             	add    $0x10,%esp
  80090e:	85 db                	test   %ebx,%ebx
  800910:	78 1b                	js     80092d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800912:	83 ec 08             	sub    $0x8,%esp
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	53                   	push   %ebx
  800919:	e8 5b ff ff ff       	call   800879 <fstat>
  80091e:	89 c6                	mov    %eax,%esi
	close(fd);
  800920:	89 1c 24             	mov    %ebx,(%esp)
  800923:	e8 fd fb ff ff       	call   800525 <close>
	return r;
  800928:	83 c4 10             	add    $0x10,%esp
  80092b:	89 f0                	mov    %esi,%eax
}
  80092d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	89 c6                	mov    %eax,%esi
  80093b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800944:	75 12                	jne    800958 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800946:	83 ec 0c             	sub    $0xc,%esp
  800949:	6a 01                	push   $0x1
  80094b:	e8 1b 12 00 00       	call   801b6b <ipc_find_env>
  800950:	a3 00 40 80 00       	mov    %eax,0x804000
  800955:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800958:	6a 07                	push   $0x7
  80095a:	68 00 50 80 00       	push   $0x805000
  80095f:	56                   	push   %esi
  800960:	ff 35 00 40 80 00    	pushl  0x804000
  800966:	e8 ac 11 00 00       	call   801b17 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80096b:	83 c4 0c             	add    $0xc,%esp
  80096e:	6a 00                	push   $0x0
  800970:	53                   	push   %ebx
  800971:	6a 00                	push   $0x0
  800973:	e8 36 11 00 00       	call   801aae <ipc_recv>
}
  800978:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800990:	8b 45 0c             	mov    0xc(%ebp),%eax
  800993:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800998:	ba 00 00 00 00       	mov    $0x0,%edx
  80099d:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a2:	e8 8d ff ff ff       	call   800934 <fsipc>
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c4:	e8 6b ff ff ff       	call   800934 <fsipc>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	83 ec 04             	sub    $0x4,%esp
  8009d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009db:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ea:	e8 45 ff ff ff       	call   800934 <fsipc>
  8009ef:	89 c2                	mov    %eax,%edx
  8009f1:	85 d2                	test   %edx,%edx
  8009f3:	78 2c                	js     800a21 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f5:	83 ec 08             	sub    $0x8,%esp
  8009f8:	68 00 50 80 00       	push   $0x805000
  8009fd:	53                   	push   %ebx
  8009fe:	e8 ef 0c 00 00       	call   8016f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a03:	a1 80 50 80 00       	mov    0x805080,%eax
  800a08:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0e:	a1 84 50 80 00       	mov    0x805084,%eax
  800a13:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a19:	83 c4 10             	add    $0x10,%esp
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	83 ec 0c             	sub    $0xc,%esp
  800a2f:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	8b 40 0c             	mov    0xc(%eax),%eax
  800a38:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800a3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a40:	eb 3d                	jmp    800a7f <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800a42:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800a48:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800a4d:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800a50:	83 ec 04             	sub    $0x4,%esp
  800a53:	57                   	push   %edi
  800a54:	53                   	push   %ebx
  800a55:	68 08 50 80 00       	push   $0x805008
  800a5a:	e8 25 0e 00 00       	call   801884 <memmove>
                fsipcbuf.write.req_n = tmp; 
  800a5f:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a65:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6a:	b8 04 00 00 00       	mov    $0x4,%eax
  800a6f:	e8 c0 fe ff ff       	call   800934 <fsipc>
  800a74:	83 c4 10             	add    $0x10,%esp
  800a77:	85 c0                	test   %eax,%eax
  800a79:	78 0d                	js     800a88 <devfile_write+0x62>
		        return r;
                n -= tmp;
  800a7b:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800a7d:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a7f:	85 f6                	test   %esi,%esi
  800a81:	75 bf                	jne    800a42 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800a83:	89 d8                	mov    %ebx,%eax
  800a85:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800a88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a8b:	5b                   	pop    %ebx
  800a8c:	5e                   	pop    %esi
  800a8d:	5f                   	pop    %edi
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a9e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aa3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aae:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab3:	e8 7c fe ff ff       	call   800934 <fsipc>
  800ab8:	89 c3                	mov    %eax,%ebx
  800aba:	85 c0                	test   %eax,%eax
  800abc:	78 4b                	js     800b09 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800abe:	39 c6                	cmp    %eax,%esi
  800ac0:	73 16                	jae    800ad8 <devfile_read+0x48>
  800ac2:	68 84 1f 80 00       	push   $0x801f84
  800ac7:	68 8b 1f 80 00       	push   $0x801f8b
  800acc:	6a 7c                	push   $0x7c
  800ace:	68 a0 1f 80 00       	push   $0x801fa0
  800ad3:	e8 ba 05 00 00       	call   801092 <_panic>
	assert(r <= PGSIZE);
  800ad8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800add:	7e 16                	jle    800af5 <devfile_read+0x65>
  800adf:	68 ab 1f 80 00       	push   $0x801fab
  800ae4:	68 8b 1f 80 00       	push   $0x801f8b
  800ae9:	6a 7d                	push   $0x7d
  800aeb:	68 a0 1f 80 00       	push   $0x801fa0
  800af0:	e8 9d 05 00 00       	call   801092 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800af5:	83 ec 04             	sub    $0x4,%esp
  800af8:	50                   	push   %eax
  800af9:	68 00 50 80 00       	push   $0x805000
  800afe:	ff 75 0c             	pushl  0xc(%ebp)
  800b01:	e8 7e 0d 00 00       	call   801884 <memmove>
	return r;
  800b06:	83 c4 10             	add    $0x10,%esp
}
  800b09:	89 d8                	mov    %ebx,%eax
  800b0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	53                   	push   %ebx
  800b16:	83 ec 20             	sub    $0x20,%esp
  800b19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b1c:	53                   	push   %ebx
  800b1d:	e8 97 0b 00 00       	call   8016b9 <strlen>
  800b22:	83 c4 10             	add    $0x10,%esp
  800b25:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b2a:	7f 67                	jg     800b93 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2c:	83 ec 0c             	sub    $0xc,%esp
  800b2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b32:	50                   	push   %eax
  800b33:	e8 74 f8 ff ff       	call   8003ac <fd_alloc>
  800b38:	83 c4 10             	add    $0x10,%esp
		return r;
  800b3b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	78 57                	js     800b98 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b41:	83 ec 08             	sub    $0x8,%esp
  800b44:	53                   	push   %ebx
  800b45:	68 00 50 80 00       	push   $0x805000
  800b4a:	e8 a3 0b 00 00       	call   8016f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b52:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b57:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5f:	e8 d0 fd ff ff       	call   800934 <fsipc>
  800b64:	89 c3                	mov    %eax,%ebx
  800b66:	83 c4 10             	add    $0x10,%esp
  800b69:	85 c0                	test   %eax,%eax
  800b6b:	79 14                	jns    800b81 <open+0x6f>
		fd_close(fd, 0);
  800b6d:	83 ec 08             	sub    $0x8,%esp
  800b70:	6a 00                	push   $0x0
  800b72:	ff 75 f4             	pushl  -0xc(%ebp)
  800b75:	e8 2a f9 ff ff       	call   8004a4 <fd_close>
		return r;
  800b7a:	83 c4 10             	add    $0x10,%esp
  800b7d:	89 da                	mov    %ebx,%edx
  800b7f:	eb 17                	jmp    800b98 <open+0x86>
	}

	return fd2num(fd);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	ff 75 f4             	pushl  -0xc(%ebp)
  800b87:	e8 f9 f7 ff ff       	call   800385 <fd2num>
  800b8c:	89 c2                	mov    %eax,%edx
  800b8e:	83 c4 10             	add    $0x10,%esp
  800b91:	eb 05                	jmp    800b98 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b93:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b98:	89 d0                	mov    %edx,%eax
  800b9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  800baa:	b8 08 00 00 00       	mov    $0x8,%eax
  800baf:	e8 80 fd ff ff       	call   800934 <fsipc>
}
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    

00800bb6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	ff 75 08             	pushl  0x8(%ebp)
  800bc4:	e8 cc f7 ff ff       	call   800395 <fd2data>
  800bc9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bcb:	83 c4 08             	add    $0x8,%esp
  800bce:	68 b7 1f 80 00       	push   $0x801fb7
  800bd3:	53                   	push   %ebx
  800bd4:	e8 19 0b 00 00       	call   8016f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bd9:	8b 56 04             	mov    0x4(%esi),%edx
  800bdc:	89 d0                	mov    %edx,%eax
  800bde:	2b 06                	sub    (%esi),%eax
  800be0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800be6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bed:	00 00 00 
	stat->st_dev = &devpipe;
  800bf0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bf7:	30 80 00 
	return 0;
}
  800bfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800bff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c10:	53                   	push   %ebx
  800c11:	6a 00                	push   $0x0
  800c13:	e8 dd f5 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c18:	89 1c 24             	mov    %ebx,(%esp)
  800c1b:	e8 75 f7 ff ff       	call   800395 <fd2data>
  800c20:	83 c4 08             	add    $0x8,%esp
  800c23:	50                   	push   %eax
  800c24:	6a 00                	push   $0x0
  800c26:	e8 ca f5 ff ff       	call   8001f5 <sys_page_unmap>
}
  800c2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c2e:	c9                   	leave  
  800c2f:	c3                   	ret    

00800c30 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
  800c36:	83 ec 1c             	sub    $0x1c,%esp
  800c39:	89 c6                	mov    %eax,%esi
  800c3b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c3e:	a1 04 40 80 00       	mov    0x804004,%eax
  800c43:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	56                   	push   %esi
  800c4a:	e8 54 0f 00 00       	call   801ba3 <pageref>
  800c4f:	89 c7                	mov    %eax,%edi
  800c51:	83 c4 04             	add    $0x4,%esp
  800c54:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c57:	e8 47 0f 00 00       	call   801ba3 <pageref>
  800c5c:	83 c4 10             	add    $0x10,%esp
  800c5f:	39 c7                	cmp    %eax,%edi
  800c61:	0f 94 c2             	sete   %dl
  800c64:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800c67:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800c6d:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800c70:	39 fb                	cmp    %edi,%ebx
  800c72:	74 19                	je     800c8d <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  800c74:	84 d2                	test   %dl,%dl
  800c76:	74 c6                	je     800c3e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c78:	8b 51 58             	mov    0x58(%ecx),%edx
  800c7b:	50                   	push   %eax
  800c7c:	52                   	push   %edx
  800c7d:	53                   	push   %ebx
  800c7e:	68 be 1f 80 00       	push   $0x801fbe
  800c83:	e8 e3 04 00 00       	call   80116b <cprintf>
  800c88:	83 c4 10             	add    $0x10,%esp
  800c8b:	eb b1                	jmp    800c3e <_pipeisclosed+0xe>
	}
}
  800c8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 28             	sub    $0x28,%esp
  800c9e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800ca1:	56                   	push   %esi
  800ca2:	e8 ee f6 ff ff       	call   800395 <fd2data>
  800ca7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca9:	83 c4 10             	add    $0x10,%esp
  800cac:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb1:	eb 4b                	jmp    800cfe <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cb3:	89 da                	mov    %ebx,%edx
  800cb5:	89 f0                	mov    %esi,%eax
  800cb7:	e8 74 ff ff ff       	call   800c30 <_pipeisclosed>
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	75 48                	jne    800d08 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cc0:	e8 8c f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cc5:	8b 43 04             	mov    0x4(%ebx),%eax
  800cc8:	8b 0b                	mov    (%ebx),%ecx
  800cca:	8d 51 20             	lea    0x20(%ecx),%edx
  800ccd:	39 d0                	cmp    %edx,%eax
  800ccf:	73 e2                	jae    800cb3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cd8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cdb:	89 c2                	mov    %eax,%edx
  800cdd:	c1 fa 1f             	sar    $0x1f,%edx
  800ce0:	89 d1                	mov    %edx,%ecx
  800ce2:	c1 e9 1b             	shr    $0x1b,%ecx
  800ce5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ce8:	83 e2 1f             	and    $0x1f,%edx
  800ceb:	29 ca                	sub    %ecx,%edx
  800ced:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cf1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cf5:	83 c0 01             	add    $0x1,%eax
  800cf8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cfb:	83 c7 01             	add    $0x1,%edi
  800cfe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d01:	75 c2                	jne    800cc5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d03:	8b 45 10             	mov    0x10(%ebp),%eax
  800d06:	eb 05                	jmp    800d0d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d08:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	83 ec 18             	sub    $0x18,%esp
  800d1e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d21:	57                   	push   %edi
  800d22:	e8 6e f6 ff ff       	call   800395 <fd2data>
  800d27:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d29:	83 c4 10             	add    $0x10,%esp
  800d2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d31:	eb 3d                	jmp    800d70 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d33:	85 db                	test   %ebx,%ebx
  800d35:	74 04                	je     800d3b <devpipe_read+0x26>
				return i;
  800d37:	89 d8                	mov    %ebx,%eax
  800d39:	eb 44                	jmp    800d7f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d3b:	89 f2                	mov    %esi,%edx
  800d3d:	89 f8                	mov    %edi,%eax
  800d3f:	e8 ec fe ff ff       	call   800c30 <_pipeisclosed>
  800d44:	85 c0                	test   %eax,%eax
  800d46:	75 32                	jne    800d7a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d48:	e8 04 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d4d:	8b 06                	mov    (%esi),%eax
  800d4f:	3b 46 04             	cmp    0x4(%esi),%eax
  800d52:	74 df                	je     800d33 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d54:	99                   	cltd   
  800d55:	c1 ea 1b             	shr    $0x1b,%edx
  800d58:	01 d0                	add    %edx,%eax
  800d5a:	83 e0 1f             	and    $0x1f,%eax
  800d5d:	29 d0                	sub    %edx,%eax
  800d5f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d67:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d6a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d6d:	83 c3 01             	add    $0x1,%ebx
  800d70:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d73:	75 d8                	jne    800d4d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d75:	8b 45 10             	mov    0x10(%ebp),%eax
  800d78:	eb 05                	jmp    800d7f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d7a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d92:	50                   	push   %eax
  800d93:	e8 14 f6 ff ff       	call   8003ac <fd_alloc>
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	89 c2                	mov    %eax,%edx
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	0f 88 2c 01 00 00    	js     800ed1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da5:	83 ec 04             	sub    $0x4,%esp
  800da8:	68 07 04 00 00       	push   $0x407
  800dad:	ff 75 f4             	pushl  -0xc(%ebp)
  800db0:	6a 00                	push   $0x0
  800db2:	e8 b9 f3 ff ff       	call   800170 <sys_page_alloc>
  800db7:	83 c4 10             	add    $0x10,%esp
  800dba:	89 c2                	mov    %eax,%edx
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	0f 88 0d 01 00 00    	js     800ed1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dca:	50                   	push   %eax
  800dcb:	e8 dc f5 ff ff       	call   8003ac <fd_alloc>
  800dd0:	89 c3                	mov    %eax,%ebx
  800dd2:	83 c4 10             	add    $0x10,%esp
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	0f 88 e2 00 00 00    	js     800ebf <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddd:	83 ec 04             	sub    $0x4,%esp
  800de0:	68 07 04 00 00       	push   $0x407
  800de5:	ff 75 f0             	pushl  -0x10(%ebp)
  800de8:	6a 00                	push   $0x0
  800dea:	e8 81 f3 ff ff       	call   800170 <sys_page_alloc>
  800def:	89 c3                	mov    %eax,%ebx
  800df1:	83 c4 10             	add    $0x10,%esp
  800df4:	85 c0                	test   %eax,%eax
  800df6:	0f 88 c3 00 00 00    	js     800ebf <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dfc:	83 ec 0c             	sub    $0xc,%esp
  800dff:	ff 75 f4             	pushl  -0xc(%ebp)
  800e02:	e8 8e f5 ff ff       	call   800395 <fd2data>
  800e07:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e09:	83 c4 0c             	add    $0xc,%esp
  800e0c:	68 07 04 00 00       	push   $0x407
  800e11:	50                   	push   %eax
  800e12:	6a 00                	push   $0x0
  800e14:	e8 57 f3 ff ff       	call   800170 <sys_page_alloc>
  800e19:	89 c3                	mov    %eax,%ebx
  800e1b:	83 c4 10             	add    $0x10,%esp
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	0f 88 89 00 00 00    	js     800eaf <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2c:	e8 64 f5 ff ff       	call   800395 <fd2data>
  800e31:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e38:	50                   	push   %eax
  800e39:	6a 00                	push   $0x0
  800e3b:	56                   	push   %esi
  800e3c:	6a 00                	push   $0x0
  800e3e:	e8 70 f3 ff ff       	call   8001b3 <sys_page_map>
  800e43:	89 c3                	mov    %eax,%ebx
  800e45:	83 c4 20             	add    $0x20,%esp
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	78 55                	js     800ea1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e4c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e55:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e5a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e61:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e6a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e6f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e76:	83 ec 0c             	sub    $0xc,%esp
  800e79:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7c:	e8 04 f5 ff ff       	call   800385 <fd2num>
  800e81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e84:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e86:	83 c4 04             	add    $0x4,%esp
  800e89:	ff 75 f0             	pushl  -0x10(%ebp)
  800e8c:	e8 f4 f4 ff ff       	call   800385 <fd2num>
  800e91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e94:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e97:	83 c4 10             	add    $0x10,%esp
  800e9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9f:	eb 30                	jmp    800ed1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800ea1:	83 ec 08             	sub    $0x8,%esp
  800ea4:	56                   	push   %esi
  800ea5:	6a 00                	push   $0x0
  800ea7:	e8 49 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800eac:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	ff 75 f0             	pushl  -0x10(%ebp)
  800eb5:	6a 00                	push   $0x0
  800eb7:	e8 39 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ebc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ebf:	83 ec 08             	sub    $0x8,%esp
  800ec2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec5:	6a 00                	push   $0x0
  800ec7:	e8 29 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ecc:	83 c4 10             	add    $0x10,%esp
  800ecf:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ed1:	89 d0                	mov    %edx,%eax
  800ed3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ee0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee3:	50                   	push   %eax
  800ee4:	ff 75 08             	pushl  0x8(%ebp)
  800ee7:	e8 0f f5 ff ff       	call   8003fb <fd_lookup>
  800eec:	89 c2                	mov    %eax,%edx
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	85 d2                	test   %edx,%edx
  800ef3:	78 18                	js     800f0d <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ef5:	83 ec 0c             	sub    $0xc,%esp
  800ef8:	ff 75 f4             	pushl  -0xc(%ebp)
  800efb:	e8 95 f4 ff ff       	call   800395 <fd2data>
	return _pipeisclosed(fd, p);
  800f00:	89 c2                	mov    %eax,%edx
  800f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f05:	e8 26 fd ff ff       	call   800c30 <_pipeisclosed>
  800f0a:	83 c4 10             	add    $0x10,%esp
}
  800f0d:	c9                   	leave  
  800f0e:	c3                   	ret    

00800f0f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f1f:	68 d6 1f 80 00       	push   $0x801fd6
  800f24:	ff 75 0c             	pushl  0xc(%ebp)
  800f27:	e8 c6 07 00 00       	call   8016f2 <strcpy>
	return 0;
}
  800f2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f31:	c9                   	leave  
  800f32:	c3                   	ret    

00800f33 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	57                   	push   %edi
  800f37:	56                   	push   %esi
  800f38:	53                   	push   %ebx
  800f39:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f44:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f4a:	eb 2d                	jmp    800f79 <devcons_write+0x46>
		m = n - tot;
  800f4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f51:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f54:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f59:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f5c:	83 ec 04             	sub    $0x4,%esp
  800f5f:	53                   	push   %ebx
  800f60:	03 45 0c             	add    0xc(%ebp),%eax
  800f63:	50                   	push   %eax
  800f64:	57                   	push   %edi
  800f65:	e8 1a 09 00 00       	call   801884 <memmove>
		sys_cputs(buf, m);
  800f6a:	83 c4 08             	add    $0x8,%esp
  800f6d:	53                   	push   %ebx
  800f6e:	57                   	push   %edi
  800f6f:	e8 40 f1 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f74:	01 de                	add    %ebx,%esi
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	89 f0                	mov    %esi,%eax
  800f7b:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f7e:	72 cc                	jb     800f4c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f8e:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f93:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f97:	75 07                	jne    800fa0 <devcons_read+0x18>
  800f99:	eb 28                	jmp    800fc3 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f9b:	e8 b1 f1 ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800fa0:	e8 2d f1 ff ff       	call   8000d2 <sys_cgetc>
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	74 f2                	je     800f9b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 16                	js     800fc3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fad:	83 f8 04             	cmp    $0x4,%eax
  800fb0:	74 0c                	je     800fbe <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb5:	88 02                	mov    %al,(%edx)
	return 1;
  800fb7:	b8 01 00 00 00       	mov    $0x1,%eax
  800fbc:	eb 05                	jmp    800fc3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fbe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fc3:	c9                   	leave  
  800fc4:	c3                   	ret    

00800fc5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fce:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fd1:	6a 01                	push   $0x1
  800fd3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd6:	50                   	push   %eax
  800fd7:	e8 d8 f0 ff ff       	call   8000b4 <sys_cputs>
  800fdc:	83 c4 10             	add    $0x10,%esp
}
  800fdf:	c9                   	leave  
  800fe0:	c3                   	ret    

00800fe1 <getchar>:

int
getchar(void)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fe7:	6a 01                	push   $0x1
  800fe9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fec:	50                   	push   %eax
  800fed:	6a 00                	push   $0x0
  800fef:	e8 71 f6 ff ff       	call   800665 <read>
	if (r < 0)
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 0f                	js     80100a <getchar+0x29>
		return r;
	if (r < 1)
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	7e 06                	jle    801005 <getchar+0x24>
		return -E_EOF;
	return c;
  800fff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801003:	eb 05                	jmp    80100a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801005:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801012:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801015:	50                   	push   %eax
  801016:	ff 75 08             	pushl  0x8(%ebp)
  801019:	e8 dd f3 ff ff       	call   8003fb <fd_lookup>
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	78 11                	js     801036 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801025:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801028:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80102e:	39 10                	cmp    %edx,(%eax)
  801030:	0f 94 c0             	sete   %al
  801033:	0f b6 c0             	movzbl %al,%eax
}
  801036:	c9                   	leave  
  801037:	c3                   	ret    

00801038 <opencons>:

int
opencons(void)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80103e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801041:	50                   	push   %eax
  801042:	e8 65 f3 ff ff       	call   8003ac <fd_alloc>
  801047:	83 c4 10             	add    $0x10,%esp
		return r;
  80104a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80104c:	85 c0                	test   %eax,%eax
  80104e:	78 3e                	js     80108e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801050:	83 ec 04             	sub    $0x4,%esp
  801053:	68 07 04 00 00       	push   $0x407
  801058:	ff 75 f4             	pushl  -0xc(%ebp)
  80105b:	6a 00                	push   $0x0
  80105d:	e8 0e f1 ff ff       	call   800170 <sys_page_alloc>
  801062:	83 c4 10             	add    $0x10,%esp
		return r;
  801065:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801067:	85 c0                	test   %eax,%eax
  801069:	78 23                	js     80108e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80106b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801071:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801074:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801076:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801079:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801080:	83 ec 0c             	sub    $0xc,%esp
  801083:	50                   	push   %eax
  801084:	e8 fc f2 ff ff       	call   800385 <fd2num>
  801089:	89 c2                	mov    %eax,%edx
  80108b:	83 c4 10             	add    $0x10,%esp
}
  80108e:	89 d0                	mov    %edx,%eax
  801090:	c9                   	leave  
  801091:	c3                   	ret    

00801092 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	56                   	push   %esi
  801096:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801097:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80109a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010a0:	e8 8d f0 ff ff       	call   800132 <sys_getenvid>
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	ff 75 0c             	pushl  0xc(%ebp)
  8010ab:	ff 75 08             	pushl  0x8(%ebp)
  8010ae:	56                   	push   %esi
  8010af:	50                   	push   %eax
  8010b0:	68 e4 1f 80 00       	push   $0x801fe4
  8010b5:	e8 b1 00 00 00       	call   80116b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010ba:	83 c4 18             	add    $0x18,%esp
  8010bd:	53                   	push   %ebx
  8010be:	ff 75 10             	pushl  0x10(%ebp)
  8010c1:	e8 54 00 00 00       	call   80111a <vcprintf>
	cprintf("\n");
  8010c6:	c7 04 24 cf 1f 80 00 	movl   $0x801fcf,(%esp)
  8010cd:	e8 99 00 00 00       	call   80116b <cprintf>
  8010d2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010d5:	cc                   	int3   
  8010d6:	eb fd                	jmp    8010d5 <_panic+0x43>

008010d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	53                   	push   %ebx
  8010dc:	83 ec 04             	sub    $0x4,%esp
  8010df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010e2:	8b 13                	mov    (%ebx),%edx
  8010e4:	8d 42 01             	lea    0x1(%edx),%eax
  8010e7:	89 03                	mov    %eax,(%ebx)
  8010e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010f5:	75 1a                	jne    801111 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010f7:	83 ec 08             	sub    $0x8,%esp
  8010fa:	68 ff 00 00 00       	push   $0xff
  8010ff:	8d 43 08             	lea    0x8(%ebx),%eax
  801102:	50                   	push   %eax
  801103:	e8 ac ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  801108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80110e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801111:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801118:	c9                   	leave  
  801119:	c3                   	ret    

0080111a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801123:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80112a:	00 00 00 
	b.cnt = 0;
  80112d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801134:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801137:	ff 75 0c             	pushl  0xc(%ebp)
  80113a:	ff 75 08             	pushl  0x8(%ebp)
  80113d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801143:	50                   	push   %eax
  801144:	68 d8 10 80 00       	push   $0x8010d8
  801149:	e8 4f 01 00 00       	call   80129d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80114e:	83 c4 08             	add    $0x8,%esp
  801151:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801157:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80115d:	50                   	push   %eax
  80115e:	e8 51 ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  801163:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801169:	c9                   	leave  
  80116a:	c3                   	ret    

0080116b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801171:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801174:	50                   	push   %eax
  801175:	ff 75 08             	pushl  0x8(%ebp)
  801178:	e8 9d ff ff ff       	call   80111a <vcprintf>
	va_end(ap);

	return cnt;
}
  80117d:	c9                   	leave  
  80117e:	c3                   	ret    

0080117f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	57                   	push   %edi
  801183:	56                   	push   %esi
  801184:	53                   	push   %ebx
  801185:	83 ec 1c             	sub    $0x1c,%esp
  801188:	89 c7                	mov    %eax,%edi
  80118a:	89 d6                	mov    %edx,%esi
  80118c:	8b 45 08             	mov    0x8(%ebp),%eax
  80118f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801192:	89 d1                	mov    %edx,%ecx
  801194:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801197:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80119a:	8b 45 10             	mov    0x10(%ebp),%eax
  80119d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011a3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011aa:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8011ad:	72 05                	jb     8011b4 <printnum+0x35>
  8011af:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8011b2:	77 3e                	ja     8011f2 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011b4:	83 ec 0c             	sub    $0xc,%esp
  8011b7:	ff 75 18             	pushl  0x18(%ebp)
  8011ba:	83 eb 01             	sub    $0x1,%ebx
  8011bd:	53                   	push   %ebx
  8011be:	50                   	push   %eax
  8011bf:	83 ec 08             	sub    $0x8,%esp
  8011c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8011cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ce:	e8 0d 0a 00 00       	call   801be0 <__udivdi3>
  8011d3:	83 c4 18             	add    $0x18,%esp
  8011d6:	52                   	push   %edx
  8011d7:	50                   	push   %eax
  8011d8:	89 f2                	mov    %esi,%edx
  8011da:	89 f8                	mov    %edi,%eax
  8011dc:	e8 9e ff ff ff       	call   80117f <printnum>
  8011e1:	83 c4 20             	add    $0x20,%esp
  8011e4:	eb 13                	jmp    8011f9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011e6:	83 ec 08             	sub    $0x8,%esp
  8011e9:	56                   	push   %esi
  8011ea:	ff 75 18             	pushl  0x18(%ebp)
  8011ed:	ff d7                	call   *%edi
  8011ef:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011f2:	83 eb 01             	sub    $0x1,%ebx
  8011f5:	85 db                	test   %ebx,%ebx
  8011f7:	7f ed                	jg     8011e6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	56                   	push   %esi
  8011fd:	83 ec 04             	sub    $0x4,%esp
  801200:	ff 75 e4             	pushl  -0x1c(%ebp)
  801203:	ff 75 e0             	pushl  -0x20(%ebp)
  801206:	ff 75 dc             	pushl  -0x24(%ebp)
  801209:	ff 75 d8             	pushl  -0x28(%ebp)
  80120c:	e8 ff 0a 00 00       	call   801d10 <__umoddi3>
  801211:	83 c4 14             	add    $0x14,%esp
  801214:	0f be 80 07 20 80 00 	movsbl 0x802007(%eax),%eax
  80121b:	50                   	push   %eax
  80121c:	ff d7                	call   *%edi
  80121e:	83 c4 10             	add    $0x10,%esp
}
  801221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5f                   	pop    %edi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80122c:	83 fa 01             	cmp    $0x1,%edx
  80122f:	7e 0e                	jle    80123f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801231:	8b 10                	mov    (%eax),%edx
  801233:	8d 4a 08             	lea    0x8(%edx),%ecx
  801236:	89 08                	mov    %ecx,(%eax)
  801238:	8b 02                	mov    (%edx),%eax
  80123a:	8b 52 04             	mov    0x4(%edx),%edx
  80123d:	eb 22                	jmp    801261 <getuint+0x38>
	else if (lflag)
  80123f:	85 d2                	test   %edx,%edx
  801241:	74 10                	je     801253 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801243:	8b 10                	mov    (%eax),%edx
  801245:	8d 4a 04             	lea    0x4(%edx),%ecx
  801248:	89 08                	mov    %ecx,(%eax)
  80124a:	8b 02                	mov    (%edx),%eax
  80124c:	ba 00 00 00 00       	mov    $0x0,%edx
  801251:	eb 0e                	jmp    801261 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801253:	8b 10                	mov    (%eax),%edx
  801255:	8d 4a 04             	lea    0x4(%edx),%ecx
  801258:	89 08                	mov    %ecx,(%eax)
  80125a:	8b 02                	mov    (%edx),%eax
  80125c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801269:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80126d:	8b 10                	mov    (%eax),%edx
  80126f:	3b 50 04             	cmp    0x4(%eax),%edx
  801272:	73 0a                	jae    80127e <sprintputch+0x1b>
		*b->buf++ = ch;
  801274:	8d 4a 01             	lea    0x1(%edx),%ecx
  801277:	89 08                	mov    %ecx,(%eax)
  801279:	8b 45 08             	mov    0x8(%ebp),%eax
  80127c:	88 02                	mov    %al,(%edx)
}
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801286:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801289:	50                   	push   %eax
  80128a:	ff 75 10             	pushl  0x10(%ebp)
  80128d:	ff 75 0c             	pushl  0xc(%ebp)
  801290:	ff 75 08             	pushl  0x8(%ebp)
  801293:	e8 05 00 00 00       	call   80129d <vprintfmt>
	va_end(ap);
  801298:	83 c4 10             	add    $0x10,%esp
}
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	57                   	push   %edi
  8012a1:	56                   	push   %esi
  8012a2:	53                   	push   %ebx
  8012a3:	83 ec 2c             	sub    $0x2c,%esp
  8012a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012ac:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012af:	eb 12                	jmp    8012c3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	0f 84 90 03 00 00    	je     801649 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8012b9:	83 ec 08             	sub    $0x8,%esp
  8012bc:	53                   	push   %ebx
  8012bd:	50                   	push   %eax
  8012be:	ff d6                	call   *%esi
  8012c0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012c3:	83 c7 01             	add    $0x1,%edi
  8012c6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012ca:	83 f8 25             	cmp    $0x25,%eax
  8012cd:	75 e2                	jne    8012b1 <vprintfmt+0x14>
  8012cf:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012d3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012e1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ed:	eb 07                	jmp    8012f6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012f2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f6:	8d 47 01             	lea    0x1(%edi),%eax
  8012f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012fc:	0f b6 07             	movzbl (%edi),%eax
  8012ff:	0f b6 c8             	movzbl %al,%ecx
  801302:	83 e8 23             	sub    $0x23,%eax
  801305:	3c 55                	cmp    $0x55,%al
  801307:	0f 87 21 03 00 00    	ja     80162e <vprintfmt+0x391>
  80130d:	0f b6 c0             	movzbl %al,%eax
  801310:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
  801317:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80131a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80131e:	eb d6                	jmp    8012f6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801323:	b8 00 00 00 00       	mov    $0x0,%eax
  801328:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80132b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80132e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801332:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801335:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801338:	83 fa 09             	cmp    $0x9,%edx
  80133b:	77 39                	ja     801376 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80133d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801340:	eb e9                	jmp    80132b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801342:	8b 45 14             	mov    0x14(%ebp),%eax
  801345:	8d 48 04             	lea    0x4(%eax),%ecx
  801348:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80134b:	8b 00                	mov    (%eax),%eax
  80134d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801353:	eb 27                	jmp    80137c <vprintfmt+0xdf>
  801355:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801358:	85 c0                	test   %eax,%eax
  80135a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80135f:	0f 49 c8             	cmovns %eax,%ecx
  801362:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801368:	eb 8c                	jmp    8012f6 <vprintfmt+0x59>
  80136a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80136d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801374:	eb 80                	jmp    8012f6 <vprintfmt+0x59>
  801376:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801379:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80137c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801380:	0f 89 70 ff ff ff    	jns    8012f6 <vprintfmt+0x59>
				width = precision, precision = -1;
  801386:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801389:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80138c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801393:	e9 5e ff ff ff       	jmp    8012f6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801398:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80139e:	e9 53 ff ff ff       	jmp    8012f6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8013a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a6:	8d 50 04             	lea    0x4(%eax),%edx
  8013a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	53                   	push   %ebx
  8013b0:	ff 30                	pushl  (%eax)
  8013b2:	ff d6                	call   *%esi
			break;
  8013b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013ba:	e9 04 ff ff ff       	jmp    8012c3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c2:	8d 50 04             	lea    0x4(%eax),%edx
  8013c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c8:	8b 00                	mov    (%eax),%eax
  8013ca:	99                   	cltd   
  8013cb:	31 d0                	xor    %edx,%eax
  8013cd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013cf:	83 f8 0f             	cmp    $0xf,%eax
  8013d2:	7f 0b                	jg     8013df <vprintfmt+0x142>
  8013d4:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8013db:	85 d2                	test   %edx,%edx
  8013dd:	75 18                	jne    8013f7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013df:	50                   	push   %eax
  8013e0:	68 1f 20 80 00       	push   $0x80201f
  8013e5:	53                   	push   %ebx
  8013e6:	56                   	push   %esi
  8013e7:	e8 94 fe ff ff       	call   801280 <printfmt>
  8013ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013f2:	e9 cc fe ff ff       	jmp    8012c3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013f7:	52                   	push   %edx
  8013f8:	68 9d 1f 80 00       	push   $0x801f9d
  8013fd:	53                   	push   %ebx
  8013fe:	56                   	push   %esi
  8013ff:	e8 7c fe ff ff       	call   801280 <printfmt>
  801404:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80140a:	e9 b4 fe ff ff       	jmp    8012c3 <vprintfmt+0x26>
  80140f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801412:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801415:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801418:	8b 45 14             	mov    0x14(%ebp),%eax
  80141b:	8d 50 04             	lea    0x4(%eax),%edx
  80141e:	89 55 14             	mov    %edx,0x14(%ebp)
  801421:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801423:	85 ff                	test   %edi,%edi
  801425:	ba 18 20 80 00       	mov    $0x802018,%edx
  80142a:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80142d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801431:	0f 84 92 00 00 00    	je     8014c9 <vprintfmt+0x22c>
  801437:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80143b:	0f 8e 96 00 00 00    	jle    8014d7 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801441:	83 ec 08             	sub    $0x8,%esp
  801444:	51                   	push   %ecx
  801445:	57                   	push   %edi
  801446:	e8 86 02 00 00       	call   8016d1 <strnlen>
  80144b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80144e:	29 c1                	sub    %eax,%ecx
  801450:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801453:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801456:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80145a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80145d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801460:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801462:	eb 0f                	jmp    801473 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801464:	83 ec 08             	sub    $0x8,%esp
  801467:	53                   	push   %ebx
  801468:	ff 75 e0             	pushl  -0x20(%ebp)
  80146b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80146d:	83 ef 01             	sub    $0x1,%edi
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	85 ff                	test   %edi,%edi
  801475:	7f ed                	jg     801464 <vprintfmt+0x1c7>
  801477:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80147a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80147d:	85 c9                	test   %ecx,%ecx
  80147f:	b8 00 00 00 00       	mov    $0x0,%eax
  801484:	0f 49 c1             	cmovns %ecx,%eax
  801487:	29 c1                	sub    %eax,%ecx
  801489:	89 75 08             	mov    %esi,0x8(%ebp)
  80148c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80148f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801492:	89 cb                	mov    %ecx,%ebx
  801494:	eb 4d                	jmp    8014e3 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801496:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80149a:	74 1b                	je     8014b7 <vprintfmt+0x21a>
  80149c:	0f be c0             	movsbl %al,%eax
  80149f:	83 e8 20             	sub    $0x20,%eax
  8014a2:	83 f8 5e             	cmp    $0x5e,%eax
  8014a5:	76 10                	jbe    8014b7 <vprintfmt+0x21a>
					putch('?', putdat);
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	ff 75 0c             	pushl  0xc(%ebp)
  8014ad:	6a 3f                	push   $0x3f
  8014af:	ff 55 08             	call   *0x8(%ebp)
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	eb 0d                	jmp    8014c4 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8014b7:	83 ec 08             	sub    $0x8,%esp
  8014ba:	ff 75 0c             	pushl  0xc(%ebp)
  8014bd:	52                   	push   %edx
  8014be:	ff 55 08             	call   *0x8(%ebp)
  8014c1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014c4:	83 eb 01             	sub    $0x1,%ebx
  8014c7:	eb 1a                	jmp    8014e3 <vprintfmt+0x246>
  8014c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8014cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014d5:	eb 0c                	jmp    8014e3 <vprintfmt+0x246>
  8014d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8014da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014e0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014e3:	83 c7 01             	add    $0x1,%edi
  8014e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014ea:	0f be d0             	movsbl %al,%edx
  8014ed:	85 d2                	test   %edx,%edx
  8014ef:	74 23                	je     801514 <vprintfmt+0x277>
  8014f1:	85 f6                	test   %esi,%esi
  8014f3:	78 a1                	js     801496 <vprintfmt+0x1f9>
  8014f5:	83 ee 01             	sub    $0x1,%esi
  8014f8:	79 9c                	jns    801496 <vprintfmt+0x1f9>
  8014fa:	89 df                	mov    %ebx,%edi
  8014fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801502:	eb 18                	jmp    80151c <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	53                   	push   %ebx
  801508:	6a 20                	push   $0x20
  80150a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80150c:	83 ef 01             	sub    $0x1,%edi
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	eb 08                	jmp    80151c <vprintfmt+0x27f>
  801514:	89 df                	mov    %ebx,%edi
  801516:	8b 75 08             	mov    0x8(%ebp),%esi
  801519:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80151c:	85 ff                	test   %edi,%edi
  80151e:	7f e4                	jg     801504 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801520:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801523:	e9 9b fd ff ff       	jmp    8012c3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801528:	83 fa 01             	cmp    $0x1,%edx
  80152b:	7e 16                	jle    801543 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80152d:	8b 45 14             	mov    0x14(%ebp),%eax
  801530:	8d 50 08             	lea    0x8(%eax),%edx
  801533:	89 55 14             	mov    %edx,0x14(%ebp)
  801536:	8b 50 04             	mov    0x4(%eax),%edx
  801539:	8b 00                	mov    (%eax),%eax
  80153b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801541:	eb 32                	jmp    801575 <vprintfmt+0x2d8>
	else if (lflag)
  801543:	85 d2                	test   %edx,%edx
  801545:	74 18                	je     80155f <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801547:	8b 45 14             	mov    0x14(%ebp),%eax
  80154a:	8d 50 04             	lea    0x4(%eax),%edx
  80154d:	89 55 14             	mov    %edx,0x14(%ebp)
  801550:	8b 00                	mov    (%eax),%eax
  801552:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801555:	89 c1                	mov    %eax,%ecx
  801557:	c1 f9 1f             	sar    $0x1f,%ecx
  80155a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80155d:	eb 16                	jmp    801575 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80155f:	8b 45 14             	mov    0x14(%ebp),%eax
  801562:	8d 50 04             	lea    0x4(%eax),%edx
  801565:	89 55 14             	mov    %edx,0x14(%ebp)
  801568:	8b 00                	mov    (%eax),%eax
  80156a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80156d:	89 c1                	mov    %eax,%ecx
  80156f:	c1 f9 1f             	sar    $0x1f,%ecx
  801572:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801575:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801578:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80157b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801580:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801584:	79 74                	jns    8015fa <vprintfmt+0x35d>
				putch('-', putdat);
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	53                   	push   %ebx
  80158a:	6a 2d                	push   $0x2d
  80158c:	ff d6                	call   *%esi
				num = -(long long) num;
  80158e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801591:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801594:	f7 d8                	neg    %eax
  801596:	83 d2 00             	adc    $0x0,%edx
  801599:	f7 da                	neg    %edx
  80159b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80159e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8015a3:	eb 55                	jmp    8015fa <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8015a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a8:	e8 7c fc ff ff       	call   801229 <getuint>
			base = 10;
  8015ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015b2:	eb 46                	jmp    8015fa <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8015b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b7:	e8 6d fc ff ff       	call   801229 <getuint>
                        base = 8;
  8015bc:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8015c1:	eb 37                	jmp    8015fa <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	53                   	push   %ebx
  8015c7:	6a 30                	push   $0x30
  8015c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8015cb:	83 c4 08             	add    $0x8,%esp
  8015ce:	53                   	push   %ebx
  8015cf:	6a 78                	push   $0x78
  8015d1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d6:	8d 50 04             	lea    0x4(%eax),%edx
  8015d9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015dc:	8b 00                	mov    (%eax),%eax
  8015de:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015e3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015e6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015eb:	eb 0d                	jmp    8015fa <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8015f0:	e8 34 fc ff ff       	call   801229 <getuint>
			base = 16;
  8015f5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015fa:	83 ec 0c             	sub    $0xc,%esp
  8015fd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801601:	57                   	push   %edi
  801602:	ff 75 e0             	pushl  -0x20(%ebp)
  801605:	51                   	push   %ecx
  801606:	52                   	push   %edx
  801607:	50                   	push   %eax
  801608:	89 da                	mov    %ebx,%edx
  80160a:	89 f0                	mov    %esi,%eax
  80160c:	e8 6e fb ff ff       	call   80117f <printnum>
			break;
  801611:	83 c4 20             	add    $0x20,%esp
  801614:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801617:	e9 a7 fc ff ff       	jmp    8012c3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	53                   	push   %ebx
  801620:	51                   	push   %ecx
  801621:	ff d6                	call   *%esi
			break;
  801623:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801629:	e9 95 fc ff ff       	jmp    8012c3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80162e:	83 ec 08             	sub    $0x8,%esp
  801631:	53                   	push   %ebx
  801632:	6a 25                	push   $0x25
  801634:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	eb 03                	jmp    80163e <vprintfmt+0x3a1>
  80163b:	83 ef 01             	sub    $0x1,%edi
  80163e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801642:	75 f7                	jne    80163b <vprintfmt+0x39e>
  801644:	e9 7a fc ff ff       	jmp    8012c3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801649:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	5f                   	pop    %edi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    

00801651 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	83 ec 18             	sub    $0x18,%esp
  801657:	8b 45 08             	mov    0x8(%ebp),%eax
  80165a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80165d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801660:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801664:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801667:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80166e:	85 c0                	test   %eax,%eax
  801670:	74 26                	je     801698 <vsnprintf+0x47>
  801672:	85 d2                	test   %edx,%edx
  801674:	7e 22                	jle    801698 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801676:	ff 75 14             	pushl  0x14(%ebp)
  801679:	ff 75 10             	pushl  0x10(%ebp)
  80167c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80167f:	50                   	push   %eax
  801680:	68 63 12 80 00       	push   $0x801263
  801685:	e8 13 fc ff ff       	call   80129d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80168a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80168d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801690:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	eb 05                	jmp    80169d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801698:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016a8:	50                   	push   %eax
  8016a9:	ff 75 10             	pushl  0x10(%ebp)
  8016ac:	ff 75 0c             	pushl  0xc(%ebp)
  8016af:	ff 75 08             	pushl  0x8(%ebp)
  8016b2:	e8 9a ff ff ff       	call   801651 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016b7:	c9                   	leave  
  8016b8:	c3                   	ret    

008016b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c4:	eb 03                	jmp    8016c9 <strlen+0x10>
		n++;
  8016c6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016cd:	75 f7                	jne    8016c6 <strlen+0xd>
		n++;
	return n;
}
  8016cf:	5d                   	pop    %ebp
  8016d0:	c3                   	ret    

008016d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016da:	ba 00 00 00 00       	mov    $0x0,%edx
  8016df:	eb 03                	jmp    8016e4 <strnlen+0x13>
		n++;
  8016e1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016e4:	39 c2                	cmp    %eax,%edx
  8016e6:	74 08                	je     8016f0 <strnlen+0x1f>
  8016e8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016ec:	75 f3                	jne    8016e1 <strnlen+0x10>
  8016ee:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016f0:	5d                   	pop    %ebp
  8016f1:	c3                   	ret    

008016f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	53                   	push   %ebx
  8016f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016fc:	89 c2                	mov    %eax,%edx
  8016fe:	83 c2 01             	add    $0x1,%edx
  801701:	83 c1 01             	add    $0x1,%ecx
  801704:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801708:	88 5a ff             	mov    %bl,-0x1(%edx)
  80170b:	84 db                	test   %bl,%bl
  80170d:	75 ef                	jne    8016fe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80170f:	5b                   	pop    %ebx
  801710:	5d                   	pop    %ebp
  801711:	c3                   	ret    

00801712 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	53                   	push   %ebx
  801716:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801719:	53                   	push   %ebx
  80171a:	e8 9a ff ff ff       	call   8016b9 <strlen>
  80171f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801722:	ff 75 0c             	pushl  0xc(%ebp)
  801725:	01 d8                	add    %ebx,%eax
  801727:	50                   	push   %eax
  801728:	e8 c5 ff ff ff       	call   8016f2 <strcpy>
	return dst;
}
  80172d:	89 d8                	mov    %ebx,%eax
  80172f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	56                   	push   %esi
  801738:	53                   	push   %ebx
  801739:	8b 75 08             	mov    0x8(%ebp),%esi
  80173c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173f:	89 f3                	mov    %esi,%ebx
  801741:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801744:	89 f2                	mov    %esi,%edx
  801746:	eb 0f                	jmp    801757 <strncpy+0x23>
		*dst++ = *src;
  801748:	83 c2 01             	add    $0x1,%edx
  80174b:	0f b6 01             	movzbl (%ecx),%eax
  80174e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801751:	80 39 01             	cmpb   $0x1,(%ecx)
  801754:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801757:	39 da                	cmp    %ebx,%edx
  801759:	75 ed                	jne    801748 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80175b:	89 f0                	mov    %esi,%eax
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	56                   	push   %esi
  801765:	53                   	push   %ebx
  801766:	8b 75 08             	mov    0x8(%ebp),%esi
  801769:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176c:	8b 55 10             	mov    0x10(%ebp),%edx
  80176f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801771:	85 d2                	test   %edx,%edx
  801773:	74 21                	je     801796 <strlcpy+0x35>
  801775:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801779:	89 f2                	mov    %esi,%edx
  80177b:	eb 09                	jmp    801786 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80177d:	83 c2 01             	add    $0x1,%edx
  801780:	83 c1 01             	add    $0x1,%ecx
  801783:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801786:	39 c2                	cmp    %eax,%edx
  801788:	74 09                	je     801793 <strlcpy+0x32>
  80178a:	0f b6 19             	movzbl (%ecx),%ebx
  80178d:	84 db                	test   %bl,%bl
  80178f:	75 ec                	jne    80177d <strlcpy+0x1c>
  801791:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801793:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801796:	29 f0                	sub    %esi,%eax
}
  801798:	5b                   	pop    %ebx
  801799:	5e                   	pop    %esi
  80179a:	5d                   	pop    %ebp
  80179b:	c3                   	ret    

0080179c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017a5:	eb 06                	jmp    8017ad <strcmp+0x11>
		p++, q++;
  8017a7:	83 c1 01             	add    $0x1,%ecx
  8017aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017ad:	0f b6 01             	movzbl (%ecx),%eax
  8017b0:	84 c0                	test   %al,%al
  8017b2:	74 04                	je     8017b8 <strcmp+0x1c>
  8017b4:	3a 02                	cmp    (%edx),%al
  8017b6:	74 ef                	je     8017a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b8:	0f b6 c0             	movzbl %al,%eax
  8017bb:	0f b6 12             	movzbl (%edx),%edx
  8017be:	29 d0                	sub    %edx,%eax
}
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	53                   	push   %ebx
  8017c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017cc:	89 c3                	mov    %eax,%ebx
  8017ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017d1:	eb 06                	jmp    8017d9 <strncmp+0x17>
		n--, p++, q++;
  8017d3:	83 c0 01             	add    $0x1,%eax
  8017d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017d9:	39 d8                	cmp    %ebx,%eax
  8017db:	74 15                	je     8017f2 <strncmp+0x30>
  8017dd:	0f b6 08             	movzbl (%eax),%ecx
  8017e0:	84 c9                	test   %cl,%cl
  8017e2:	74 04                	je     8017e8 <strncmp+0x26>
  8017e4:	3a 0a                	cmp    (%edx),%cl
  8017e6:	74 eb                	je     8017d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e8:	0f b6 00             	movzbl (%eax),%eax
  8017eb:	0f b6 12             	movzbl (%edx),%edx
  8017ee:	29 d0                	sub    %edx,%eax
  8017f0:	eb 05                	jmp    8017f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017f7:	5b                   	pop    %ebx
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801800:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801804:	eb 07                	jmp    80180d <strchr+0x13>
		if (*s == c)
  801806:	38 ca                	cmp    %cl,%dl
  801808:	74 0f                	je     801819 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80180a:	83 c0 01             	add    $0x1,%eax
  80180d:	0f b6 10             	movzbl (%eax),%edx
  801810:	84 d2                	test   %dl,%dl
  801812:	75 f2                	jne    801806 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801814:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	8b 45 08             	mov    0x8(%ebp),%eax
  801821:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801825:	eb 03                	jmp    80182a <strfind+0xf>
  801827:	83 c0 01             	add    $0x1,%eax
  80182a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80182d:	84 d2                	test   %dl,%dl
  80182f:	74 04                	je     801835 <strfind+0x1a>
  801831:	38 ca                	cmp    %cl,%dl
  801833:	75 f2                	jne    801827 <strfind+0xc>
			break;
	return (char *) s;
}
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	57                   	push   %edi
  80183b:	56                   	push   %esi
  80183c:	53                   	push   %ebx
  80183d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801840:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801843:	85 c9                	test   %ecx,%ecx
  801845:	74 36                	je     80187d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801847:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80184d:	75 28                	jne    801877 <memset+0x40>
  80184f:	f6 c1 03             	test   $0x3,%cl
  801852:	75 23                	jne    801877 <memset+0x40>
		c &= 0xFF;
  801854:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801858:	89 d3                	mov    %edx,%ebx
  80185a:	c1 e3 08             	shl    $0x8,%ebx
  80185d:	89 d6                	mov    %edx,%esi
  80185f:	c1 e6 18             	shl    $0x18,%esi
  801862:	89 d0                	mov    %edx,%eax
  801864:	c1 e0 10             	shl    $0x10,%eax
  801867:	09 f0                	or     %esi,%eax
  801869:	09 c2                	or     %eax,%edx
  80186b:	89 d0                	mov    %edx,%eax
  80186d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80186f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801872:	fc                   	cld    
  801873:	f3 ab                	rep stos %eax,%es:(%edi)
  801875:	eb 06                	jmp    80187d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187a:	fc                   	cld    
  80187b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80187d:	89 f8                	mov    %edi,%eax
  80187f:	5b                   	pop    %ebx
  801880:	5e                   	pop    %esi
  801881:	5f                   	pop    %edi
  801882:	5d                   	pop    %ebp
  801883:	c3                   	ret    

00801884 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	57                   	push   %edi
  801888:	56                   	push   %esi
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80188f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801892:	39 c6                	cmp    %eax,%esi
  801894:	73 35                	jae    8018cb <memmove+0x47>
  801896:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801899:	39 d0                	cmp    %edx,%eax
  80189b:	73 2e                	jae    8018cb <memmove+0x47>
		s += n;
		d += n;
  80189d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8018a0:	89 d6                	mov    %edx,%esi
  8018a2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018aa:	75 13                	jne    8018bf <memmove+0x3b>
  8018ac:	f6 c1 03             	test   $0x3,%cl
  8018af:	75 0e                	jne    8018bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018b1:	83 ef 04             	sub    $0x4,%edi
  8018b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018b7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8018ba:	fd                   	std    
  8018bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018bd:	eb 09                	jmp    8018c8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018bf:	83 ef 01             	sub    $0x1,%edi
  8018c2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018c5:	fd                   	std    
  8018c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018c8:	fc                   	cld    
  8018c9:	eb 1d                	jmp    8018e8 <memmove+0x64>
  8018cb:	89 f2                	mov    %esi,%edx
  8018cd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018cf:	f6 c2 03             	test   $0x3,%dl
  8018d2:	75 0f                	jne    8018e3 <memmove+0x5f>
  8018d4:	f6 c1 03             	test   $0x3,%cl
  8018d7:	75 0a                	jne    8018e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018d9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018dc:	89 c7                	mov    %eax,%edi
  8018de:	fc                   	cld    
  8018df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e1:	eb 05                	jmp    8018e8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018e3:	89 c7                	mov    %eax,%edi
  8018e5:	fc                   	cld    
  8018e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e8:	5e                   	pop    %esi
  8018e9:	5f                   	pop    %edi
  8018ea:	5d                   	pop    %ebp
  8018eb:	c3                   	ret    

008018ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018ef:	ff 75 10             	pushl  0x10(%ebp)
  8018f2:	ff 75 0c             	pushl  0xc(%ebp)
  8018f5:	ff 75 08             	pushl  0x8(%ebp)
  8018f8:	e8 87 ff ff ff       	call   801884 <memmove>
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	56                   	push   %esi
  801903:	53                   	push   %ebx
  801904:	8b 45 08             	mov    0x8(%ebp),%eax
  801907:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190a:	89 c6                	mov    %eax,%esi
  80190c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80190f:	eb 1a                	jmp    80192b <memcmp+0x2c>
		if (*s1 != *s2)
  801911:	0f b6 08             	movzbl (%eax),%ecx
  801914:	0f b6 1a             	movzbl (%edx),%ebx
  801917:	38 d9                	cmp    %bl,%cl
  801919:	74 0a                	je     801925 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80191b:	0f b6 c1             	movzbl %cl,%eax
  80191e:	0f b6 db             	movzbl %bl,%ebx
  801921:	29 d8                	sub    %ebx,%eax
  801923:	eb 0f                	jmp    801934 <memcmp+0x35>
		s1++, s2++;
  801925:	83 c0 01             	add    $0x1,%eax
  801928:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80192b:	39 f0                	cmp    %esi,%eax
  80192d:	75 e2                	jne    801911 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80192f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801934:	5b                   	pop    %ebx
  801935:	5e                   	pop    %esi
  801936:	5d                   	pop    %ebp
  801937:	c3                   	ret    

00801938 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	8b 45 08             	mov    0x8(%ebp),%eax
  80193e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801941:	89 c2                	mov    %eax,%edx
  801943:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801946:	eb 07                	jmp    80194f <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801948:	38 08                	cmp    %cl,(%eax)
  80194a:	74 07                	je     801953 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80194c:	83 c0 01             	add    $0x1,%eax
  80194f:	39 d0                	cmp    %edx,%eax
  801951:	72 f5                	jb     801948 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    

00801955 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	57                   	push   %edi
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801961:	eb 03                	jmp    801966 <strtol+0x11>
		s++;
  801963:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801966:	0f b6 01             	movzbl (%ecx),%eax
  801969:	3c 09                	cmp    $0x9,%al
  80196b:	74 f6                	je     801963 <strtol+0xe>
  80196d:	3c 20                	cmp    $0x20,%al
  80196f:	74 f2                	je     801963 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801971:	3c 2b                	cmp    $0x2b,%al
  801973:	75 0a                	jne    80197f <strtol+0x2a>
		s++;
  801975:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801978:	bf 00 00 00 00       	mov    $0x0,%edi
  80197d:	eb 10                	jmp    80198f <strtol+0x3a>
  80197f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801984:	3c 2d                	cmp    $0x2d,%al
  801986:	75 07                	jne    80198f <strtol+0x3a>
		s++, neg = 1;
  801988:	8d 49 01             	lea    0x1(%ecx),%ecx
  80198b:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80198f:	85 db                	test   %ebx,%ebx
  801991:	0f 94 c0             	sete   %al
  801994:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80199a:	75 19                	jne    8019b5 <strtol+0x60>
  80199c:	80 39 30             	cmpb   $0x30,(%ecx)
  80199f:	75 14                	jne    8019b5 <strtol+0x60>
  8019a1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019a5:	0f 85 82 00 00 00    	jne    801a2d <strtol+0xd8>
		s += 2, base = 16;
  8019ab:	83 c1 02             	add    $0x2,%ecx
  8019ae:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019b3:	eb 16                	jmp    8019cb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019b5:	84 c0                	test   %al,%al
  8019b7:	74 12                	je     8019cb <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019b9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019be:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c1:	75 08                	jne    8019cb <strtol+0x76>
		s++, base = 8;
  8019c3:	83 c1 01             	add    $0x1,%ecx
  8019c6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019d3:	0f b6 11             	movzbl (%ecx),%edx
  8019d6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019d9:	89 f3                	mov    %esi,%ebx
  8019db:	80 fb 09             	cmp    $0x9,%bl
  8019de:	77 08                	ja     8019e8 <strtol+0x93>
			dig = *s - '0';
  8019e0:	0f be d2             	movsbl %dl,%edx
  8019e3:	83 ea 30             	sub    $0x30,%edx
  8019e6:	eb 22                	jmp    801a0a <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019e8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019eb:	89 f3                	mov    %esi,%ebx
  8019ed:	80 fb 19             	cmp    $0x19,%bl
  8019f0:	77 08                	ja     8019fa <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019f2:	0f be d2             	movsbl %dl,%edx
  8019f5:	83 ea 57             	sub    $0x57,%edx
  8019f8:	eb 10                	jmp    801a0a <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019fa:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019fd:	89 f3                	mov    %esi,%ebx
  8019ff:	80 fb 19             	cmp    $0x19,%bl
  801a02:	77 16                	ja     801a1a <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a04:	0f be d2             	movsbl %dl,%edx
  801a07:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a0a:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a0d:	7d 0f                	jge    801a1e <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801a0f:	83 c1 01             	add    $0x1,%ecx
  801a12:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a16:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a18:	eb b9                	jmp    8019d3 <strtol+0x7e>
  801a1a:	89 c2                	mov    %eax,%edx
  801a1c:	eb 02                	jmp    801a20 <strtol+0xcb>
  801a1e:	89 c2                	mov    %eax,%edx

	if (endptr)
  801a20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a24:	74 0d                	je     801a33 <strtol+0xde>
		*endptr = (char *) s;
  801a26:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a29:	89 0e                	mov    %ecx,(%esi)
  801a2b:	eb 06                	jmp    801a33 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a2d:	84 c0                	test   %al,%al
  801a2f:	75 92                	jne    8019c3 <strtol+0x6e>
  801a31:	eb 98                	jmp    8019cb <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a33:	f7 da                	neg    %edx
  801a35:	85 ff                	test   %edi,%edi
  801a37:	0f 45 c2             	cmovne %edx,%eax
}
  801a3a:	5b                   	pop    %ebx
  801a3b:	5e                   	pop    %esi
  801a3c:	5f                   	pop    %edi
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    

00801a3f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a45:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a4c:	75 2c                	jne    801a7a <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801a4e:	83 ec 04             	sub    $0x4,%esp
  801a51:	6a 07                	push   $0x7
  801a53:	68 00 f0 bf ee       	push   $0xeebff000
  801a58:	6a 00                	push   $0x0
  801a5a:	e8 11 e7 ff ff       	call   800170 <sys_page_alloc>
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	85 c0                	test   %eax,%eax
  801a64:	74 14                	je     801a7a <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801a66:	83 ec 04             	sub    $0x4,%esp
  801a69:	68 20 23 80 00       	push   $0x802320
  801a6e:	6a 21                	push   $0x21
  801a70:	68 84 23 80 00       	push   $0x802384
  801a75:	e8 18 f6 ff ff       	call   801092 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7d:	a3 00 60 80 00       	mov    %eax,0x806000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801a82:	83 ec 08             	sub    $0x8,%esp
  801a85:	68 61 03 80 00       	push   $0x800361
  801a8a:	6a 00                	push   $0x0
  801a8c:	e8 2a e8 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801a91:	83 c4 10             	add    $0x10,%esp
  801a94:	85 c0                	test   %eax,%eax
  801a96:	79 14                	jns    801aac <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801a98:	83 ec 04             	sub    $0x4,%esp
  801a9b:	68 4c 23 80 00       	push   $0x80234c
  801aa0:	6a 29                	push   $0x29
  801aa2:	68 84 23 80 00       	push   $0x802384
  801aa7:	e8 e6 f5 ff ff       	call   801092 <_panic>
}
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	56                   	push   %esi
  801ab2:	53                   	push   %ebx
  801ab3:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801abc:	85 c0                	test   %eax,%eax
  801abe:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ac3:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801ac6:	83 ec 0c             	sub    $0xc,%esp
  801ac9:	50                   	push   %eax
  801aca:	e8 51 e8 ff ff       	call   800320 <sys_ipc_recv>
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	79 16                	jns    801aec <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801ad6:	85 f6                	test   %esi,%esi
  801ad8:	74 06                	je     801ae0 <ipc_recv+0x32>
  801ada:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801ae0:	85 db                	test   %ebx,%ebx
  801ae2:	74 2c                	je     801b10 <ipc_recv+0x62>
  801ae4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aea:	eb 24                	jmp    801b10 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801aec:	85 f6                	test   %esi,%esi
  801aee:	74 0a                	je     801afa <ipc_recv+0x4c>
  801af0:	a1 04 40 80 00       	mov    0x804004,%eax
  801af5:	8b 40 74             	mov    0x74(%eax),%eax
  801af8:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801afa:	85 db                	test   %ebx,%ebx
  801afc:	74 0a                	je     801b08 <ipc_recv+0x5a>
  801afe:	a1 04 40 80 00       	mov    0x804004,%eax
  801b03:	8b 40 78             	mov    0x78(%eax),%eax
  801b06:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801b08:	a1 04 40 80 00       	mov    0x804004,%eax
  801b0d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    

00801b17 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	57                   	push   %edi
  801b1b:	56                   	push   %esi
  801b1c:	53                   	push   %ebx
  801b1d:	83 ec 0c             	sub    $0xc,%esp
  801b20:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b23:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801b29:	85 db                	test   %ebx,%ebx
  801b2b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b30:	0f 44 d8             	cmove  %eax,%ebx
  801b33:	eb 1c                	jmp    801b51 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801b35:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b38:	74 12                	je     801b4c <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801b3a:	50                   	push   %eax
  801b3b:	68 92 23 80 00       	push   $0x802392
  801b40:	6a 39                	push   $0x39
  801b42:	68 ad 23 80 00       	push   $0x8023ad
  801b47:	e8 46 f5 ff ff       	call   801092 <_panic>
                 sys_yield();
  801b4c:	e8 00 e6 ff ff       	call   800151 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b51:	ff 75 14             	pushl  0x14(%ebp)
  801b54:	53                   	push   %ebx
  801b55:	56                   	push   %esi
  801b56:	57                   	push   %edi
  801b57:	e8 a1 e7 ff ff       	call   8002fd <sys_ipc_try_send>
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	78 d2                	js     801b35 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801b63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b66:	5b                   	pop    %ebx
  801b67:	5e                   	pop    %esi
  801b68:	5f                   	pop    %edi
  801b69:	5d                   	pop    %ebp
  801b6a:	c3                   	ret    

00801b6b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b71:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b76:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b79:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b7f:	8b 52 50             	mov    0x50(%edx),%edx
  801b82:	39 ca                	cmp    %ecx,%edx
  801b84:	75 0d                	jne    801b93 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b86:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b89:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801b8e:	8b 40 08             	mov    0x8(%eax),%eax
  801b91:	eb 0e                	jmp    801ba1 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b93:	83 c0 01             	add    $0x1,%eax
  801b96:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b9b:	75 d9                	jne    801b76 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b9d:	66 b8 00 00          	mov    $0x0,%ax
}
  801ba1:	5d                   	pop    %ebp
  801ba2:	c3                   	ret    

00801ba3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ba9:	89 d0                	mov    %edx,%eax
  801bab:	c1 e8 16             	shr    $0x16,%eax
  801bae:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bb5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bba:	f6 c1 01             	test   $0x1,%cl
  801bbd:	74 1d                	je     801bdc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bbf:	c1 ea 0c             	shr    $0xc,%edx
  801bc2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bc9:	f6 c2 01             	test   $0x1,%dl
  801bcc:	74 0e                	je     801bdc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bce:	c1 ea 0c             	shr    $0xc,%edx
  801bd1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bd8:	ef 
  801bd9:	0f b7 c0             	movzwl %ax,%eax
}
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    
  801bde:	66 90                	xchg   %ax,%ax

00801be0 <__udivdi3>:
  801be0:	55                   	push   %ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	83 ec 10             	sub    $0x10,%esp
  801be6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801bea:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801bee:	8b 74 24 24          	mov    0x24(%esp),%esi
  801bf2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801bf6:	85 d2                	test   %edx,%edx
  801bf8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bfc:	89 34 24             	mov    %esi,(%esp)
  801bff:	89 c8                	mov    %ecx,%eax
  801c01:	75 35                	jne    801c38 <__udivdi3+0x58>
  801c03:	39 f1                	cmp    %esi,%ecx
  801c05:	0f 87 bd 00 00 00    	ja     801cc8 <__udivdi3+0xe8>
  801c0b:	85 c9                	test   %ecx,%ecx
  801c0d:	89 cd                	mov    %ecx,%ebp
  801c0f:	75 0b                	jne    801c1c <__udivdi3+0x3c>
  801c11:	b8 01 00 00 00       	mov    $0x1,%eax
  801c16:	31 d2                	xor    %edx,%edx
  801c18:	f7 f1                	div    %ecx
  801c1a:	89 c5                	mov    %eax,%ebp
  801c1c:	89 f0                	mov    %esi,%eax
  801c1e:	31 d2                	xor    %edx,%edx
  801c20:	f7 f5                	div    %ebp
  801c22:	89 c6                	mov    %eax,%esi
  801c24:	89 f8                	mov    %edi,%eax
  801c26:	f7 f5                	div    %ebp
  801c28:	89 f2                	mov    %esi,%edx
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	5e                   	pop    %esi
  801c2e:	5f                   	pop    %edi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    
  801c31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c38:	3b 14 24             	cmp    (%esp),%edx
  801c3b:	77 7b                	ja     801cb8 <__udivdi3+0xd8>
  801c3d:	0f bd f2             	bsr    %edx,%esi
  801c40:	83 f6 1f             	xor    $0x1f,%esi
  801c43:	0f 84 97 00 00 00    	je     801ce0 <__udivdi3+0x100>
  801c49:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c4e:	89 d7                	mov    %edx,%edi
  801c50:	89 f1                	mov    %esi,%ecx
  801c52:	29 f5                	sub    %esi,%ebp
  801c54:	d3 e7                	shl    %cl,%edi
  801c56:	89 c2                	mov    %eax,%edx
  801c58:	89 e9                	mov    %ebp,%ecx
  801c5a:	d3 ea                	shr    %cl,%edx
  801c5c:	89 f1                	mov    %esi,%ecx
  801c5e:	09 fa                	or     %edi,%edx
  801c60:	8b 3c 24             	mov    (%esp),%edi
  801c63:	d3 e0                	shl    %cl,%eax
  801c65:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c69:	89 e9                	mov    %ebp,%ecx
  801c6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801c73:	89 fa                	mov    %edi,%edx
  801c75:	d3 ea                	shr    %cl,%edx
  801c77:	89 f1                	mov    %esi,%ecx
  801c79:	d3 e7                	shl    %cl,%edi
  801c7b:	89 e9                	mov    %ebp,%ecx
  801c7d:	d3 e8                	shr    %cl,%eax
  801c7f:	09 c7                	or     %eax,%edi
  801c81:	89 f8                	mov    %edi,%eax
  801c83:	f7 74 24 08          	divl   0x8(%esp)
  801c87:	89 d5                	mov    %edx,%ebp
  801c89:	89 c7                	mov    %eax,%edi
  801c8b:	f7 64 24 0c          	mull   0xc(%esp)
  801c8f:	39 d5                	cmp    %edx,%ebp
  801c91:	89 14 24             	mov    %edx,(%esp)
  801c94:	72 11                	jb     801ca7 <__udivdi3+0xc7>
  801c96:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c9a:	89 f1                	mov    %esi,%ecx
  801c9c:	d3 e2                	shl    %cl,%edx
  801c9e:	39 c2                	cmp    %eax,%edx
  801ca0:	73 5e                	jae    801d00 <__udivdi3+0x120>
  801ca2:	3b 2c 24             	cmp    (%esp),%ebp
  801ca5:	75 59                	jne    801d00 <__udivdi3+0x120>
  801ca7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801caa:	31 f6                	xor    %esi,%esi
  801cac:	89 f2                	mov    %esi,%edx
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	31 f6                	xor    %esi,%esi
  801cba:	31 c0                	xor    %eax,%eax
  801cbc:	89 f2                	mov    %esi,%edx
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    
  801cc5:	8d 76 00             	lea    0x0(%esi),%esi
  801cc8:	89 f2                	mov    %esi,%edx
  801cca:	31 f6                	xor    %esi,%esi
  801ccc:	89 f8                	mov    %edi,%eax
  801cce:	f7 f1                	div    %ecx
  801cd0:	89 f2                	mov    %esi,%edx
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	5e                   	pop    %esi
  801cd6:	5f                   	pop    %edi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801ce4:	76 0b                	jbe    801cf1 <__udivdi3+0x111>
  801ce6:	31 c0                	xor    %eax,%eax
  801ce8:	3b 14 24             	cmp    (%esp),%edx
  801ceb:	0f 83 37 ff ff ff    	jae    801c28 <__udivdi3+0x48>
  801cf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf6:	e9 2d ff ff ff       	jmp    801c28 <__udivdi3+0x48>
  801cfb:	90                   	nop
  801cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 f8                	mov    %edi,%eax
  801d02:	31 f6                	xor    %esi,%esi
  801d04:	e9 1f ff ff ff       	jmp    801c28 <__udivdi3+0x48>
  801d09:	66 90                	xchg   %ax,%ax
  801d0b:	66 90                	xchg   %ax,%ax
  801d0d:	66 90                	xchg   %ax,%ax
  801d0f:	90                   	nop

00801d10 <__umoddi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	83 ec 20             	sub    $0x20,%esp
  801d16:	8b 44 24 34          	mov    0x34(%esp),%eax
  801d1a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d1e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d22:	89 c6                	mov    %eax,%esi
  801d24:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d28:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d2c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801d30:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d34:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d38:	89 74 24 18          	mov    %esi,0x18(%esp)
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	89 c2                	mov    %eax,%edx
  801d40:	75 1e                	jne    801d60 <__umoddi3+0x50>
  801d42:	39 f7                	cmp    %esi,%edi
  801d44:	76 52                	jbe    801d98 <__umoddi3+0x88>
  801d46:	89 c8                	mov    %ecx,%eax
  801d48:	89 f2                	mov    %esi,%edx
  801d4a:	f7 f7                	div    %edi
  801d4c:	89 d0                	mov    %edx,%eax
  801d4e:	31 d2                	xor    %edx,%edx
  801d50:	83 c4 20             	add    $0x20,%esp
  801d53:	5e                   	pop    %esi
  801d54:	5f                   	pop    %edi
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    
  801d57:	89 f6                	mov    %esi,%esi
  801d59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d60:	39 f0                	cmp    %esi,%eax
  801d62:	77 5c                	ja     801dc0 <__umoddi3+0xb0>
  801d64:	0f bd e8             	bsr    %eax,%ebp
  801d67:	83 f5 1f             	xor    $0x1f,%ebp
  801d6a:	75 64                	jne    801dd0 <__umoddi3+0xc0>
  801d6c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801d70:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801d74:	0f 86 f6 00 00 00    	jbe    801e70 <__umoddi3+0x160>
  801d7a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801d7e:	0f 82 ec 00 00 00    	jb     801e70 <__umoddi3+0x160>
  801d84:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d88:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d8c:	83 c4 20             	add    $0x20,%esp
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    
  801d93:	90                   	nop
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	85 ff                	test   %edi,%edi
  801d9a:	89 fd                	mov    %edi,%ebp
  801d9c:	75 0b                	jne    801da9 <__umoddi3+0x99>
  801d9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801da3:	31 d2                	xor    %edx,%edx
  801da5:	f7 f7                	div    %edi
  801da7:	89 c5                	mov    %eax,%ebp
  801da9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801dad:	31 d2                	xor    %edx,%edx
  801daf:	f7 f5                	div    %ebp
  801db1:	89 c8                	mov    %ecx,%eax
  801db3:	f7 f5                	div    %ebp
  801db5:	eb 95                	jmp    801d4c <__umoddi3+0x3c>
  801db7:	89 f6                	mov    %esi,%esi
  801db9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	89 f2                	mov    %esi,%edx
  801dc4:	83 c4 20             	add    $0x20,%esp
  801dc7:	5e                   	pop    %esi
  801dc8:	5f                   	pop    %edi
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    
  801dcb:	90                   	nop
  801dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	b8 20 00 00 00       	mov    $0x20,%eax
  801dd5:	89 e9                	mov    %ebp,%ecx
  801dd7:	29 e8                	sub    %ebp,%eax
  801dd9:	d3 e2                	shl    %cl,%edx
  801ddb:	89 c7                	mov    %eax,%edi
  801ddd:	89 44 24 18          	mov    %eax,0x18(%esp)
  801de1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801de5:	89 f9                	mov    %edi,%ecx
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 c1                	mov    %eax,%ecx
  801deb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801def:	09 d1                	or     %edx,%ecx
  801df1:	89 fa                	mov    %edi,%edx
  801df3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801df7:	89 e9                	mov    %ebp,%ecx
  801df9:	d3 e0                	shl    %cl,%eax
  801dfb:	89 f9                	mov    %edi,%ecx
  801dfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e01:	89 f0                	mov    %esi,%eax
  801e03:	d3 e8                	shr    %cl,%eax
  801e05:	89 e9                	mov    %ebp,%ecx
  801e07:	89 c7                	mov    %eax,%edi
  801e09:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e0d:	d3 e6                	shl    %cl,%esi
  801e0f:	89 d1                	mov    %edx,%ecx
  801e11:	89 fa                	mov    %edi,%edx
  801e13:	d3 e8                	shr    %cl,%eax
  801e15:	89 e9                	mov    %ebp,%ecx
  801e17:	09 f0                	or     %esi,%eax
  801e19:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801e1d:	f7 74 24 10          	divl   0x10(%esp)
  801e21:	d3 e6                	shl    %cl,%esi
  801e23:	89 d1                	mov    %edx,%ecx
  801e25:	f7 64 24 0c          	mull   0xc(%esp)
  801e29:	39 d1                	cmp    %edx,%ecx
  801e2b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801e2f:	89 d7                	mov    %edx,%edi
  801e31:	89 c6                	mov    %eax,%esi
  801e33:	72 0a                	jb     801e3f <__umoddi3+0x12f>
  801e35:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801e39:	73 10                	jae    801e4b <__umoddi3+0x13b>
  801e3b:	39 d1                	cmp    %edx,%ecx
  801e3d:	75 0c                	jne    801e4b <__umoddi3+0x13b>
  801e3f:	89 d7                	mov    %edx,%edi
  801e41:	89 c6                	mov    %eax,%esi
  801e43:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801e47:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801e4b:	89 ca                	mov    %ecx,%edx
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e53:	29 f0                	sub    %esi,%eax
  801e55:	19 fa                	sbb    %edi,%edx
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801e5e:	89 d7                	mov    %edx,%edi
  801e60:	d3 e7                	shl    %cl,%edi
  801e62:	89 e9                	mov    %ebp,%ecx
  801e64:	09 f8                	or     %edi,%eax
  801e66:	d3 ea                	shr    %cl,%edx
  801e68:	83 c4 20             	add    $0x20,%esp
  801e6b:	5e                   	pop    %esi
  801e6c:	5f                   	pop    %edi
  801e6d:	5d                   	pop    %ebp
  801e6e:	c3                   	ret    
  801e6f:	90                   	nop
  801e70:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e74:	29 f9                	sub    %edi,%ecx
  801e76:	19 c6                	sbb    %eax,%esi
  801e78:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e7c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e80:	e9 ff fe ff ff       	jmp    801d84 <__umoddi3+0x74>
