
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
  800039:	68 02 04 80 00       	push   $0x800402
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
  800071:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8000a0:	e8 53 05 00 00       	call   8005f8 <close_all>
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
	// return value.
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
	// return value.
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
	// return value.
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
  800119:	68 ca 23 80 00       	push   $0x8023ca
  80011e:	6a 22                	push   $0x22
  800120:	68 e7 23 80 00       	push   $0x8023e7
  800125:	e8 7f 14 00 00       	call   8015a9 <_panic>

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
	// return value.
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
	// return value.
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
	// return value.
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
  80019a:	68 ca 23 80 00       	push   $0x8023ca
  80019f:	6a 22                	push   $0x22
  8001a1:	68 e7 23 80 00       	push   $0x8023e7
  8001a6:	e8 fe 13 00 00       	call   8015a9 <_panic>

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
	// return value.
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
  8001dc:	68 ca 23 80 00       	push   $0x8023ca
  8001e1:	6a 22                	push   $0x22
  8001e3:	68 e7 23 80 00       	push   $0x8023e7
  8001e8:	e8 bc 13 00 00       	call   8015a9 <_panic>

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
	// return value.
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
  80021e:	68 ca 23 80 00       	push   $0x8023ca
  800223:	6a 22                	push   $0x22
  800225:	68 e7 23 80 00       	push   $0x8023e7
  80022a:	e8 7a 13 00 00       	call   8015a9 <_panic>

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
	// return value.
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
  800260:	68 ca 23 80 00       	push   $0x8023ca
  800265:	6a 22                	push   $0x22
  800267:	68 e7 23 80 00       	push   $0x8023e7
  80026c:	e8 38 13 00 00       	call   8015a9 <_panic>
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
	// return value.
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
  8002a2:	68 ca 23 80 00       	push   $0x8023ca
  8002a7:	6a 22                	push   $0x22
  8002a9:	68 e7 23 80 00       	push   $0x8023e7
  8002ae:	e8 f6 12 00 00       	call   8015a9 <_panic>

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
	// return value.
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
  8002e4:	68 ca 23 80 00       	push   $0x8023ca
  8002e9:	6a 22                	push   $0x22
  8002eb:	68 e7 23 80 00       	push   $0x8023e7
  8002f0:	e8 b4 12 00 00       	call   8015a9 <_panic>

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
	// return value.
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
	// return value.
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
  800348:	68 ca 23 80 00       	push   $0x8023ca
  80034d:	6a 22                	push   $0x22
  80034f:	68 e7 23 80 00       	push   $0x8023e7
  800354:	e8 50 12 00 00       	call   8015a9 <_panic>

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

00800361 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800367:	ba 00 00 00 00       	mov    $0x0,%edx
  80036c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800371:	89 d1                	mov    %edx,%ecx
  800373:	89 d3                	mov    %edx,%ebx
  800375:	89 d7                	mov    %edx,%edi
  800377:	89 d6                	mov    %edx,%esi
  800379:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	57                   	push   %edi
  800384:	56                   	push   %esi
  800385:	53                   	push   %ebx
  800386:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800389:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800393:	8b 55 08             	mov    0x8(%ebp),%edx
  800396:	89 cb                	mov    %ecx,%ebx
  800398:	89 cf                	mov    %ecx,%edi
  80039a:	89 ce                	mov    %ecx,%esi
  80039c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	7e 17                	jle    8003b9 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a2:	83 ec 0c             	sub    $0xc,%esp
  8003a5:	50                   	push   %eax
  8003a6:	6a 0f                	push   $0xf
  8003a8:	68 ca 23 80 00       	push   $0x8023ca
  8003ad:	6a 22                	push   $0x22
  8003af:	68 e7 23 80 00       	push   $0x8023e7
  8003b4:	e8 f0 11 00 00       	call   8015a9 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003bc:	5b                   	pop    %ebx
  8003bd:	5e                   	pop    %esi
  8003be:	5f                   	pop    %edi
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <sys_recv>:

int
sys_recv(void *addr)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	57                   	push   %edi
  8003c5:	56                   	push   %esi
  8003c6:	53                   	push   %ebx
  8003c7:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8003ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cf:	b8 10 00 00 00       	mov    $0x10,%eax
  8003d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d7:	89 cb                	mov    %ecx,%ebx
  8003d9:	89 cf                	mov    %ecx,%edi
  8003db:	89 ce                	mov    %ecx,%esi
  8003dd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	7e 17                	jle    8003fa <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003e3:	83 ec 0c             	sub    $0xc,%esp
  8003e6:	50                   	push   %eax
  8003e7:	6a 10                	push   $0x10
  8003e9:	68 ca 23 80 00       	push   $0x8023ca
  8003ee:	6a 22                	push   $0x22
  8003f0:	68 e7 23 80 00       	push   $0x8023e7
  8003f5:	e8 af 11 00 00       	call   8015a9 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003fd:	5b                   	pop    %ebx
  8003fe:	5e                   	pop    %esi
  8003ff:	5f                   	pop    %edi
  800400:	5d                   	pop    %ebp
  800401:	c3                   	ret    

00800402 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800402:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800403:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  800408:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80040a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  80040d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  800412:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  800416:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  80041a:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  80041c:	83 c4 08             	add    $0x8,%esp
        popal
  80041f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800420:	83 c4 04             	add    $0x4,%esp
        popfl
  800423:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  800424:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800425:	c3                   	ret    

00800426 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800429:	8b 45 08             	mov    0x8(%ebp),%eax
  80042c:	05 00 00 00 30       	add    $0x30000000,%eax
  800431:	c1 e8 0c             	shr    $0xc,%eax
}
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800439:	8b 45 08             	mov    0x8(%ebp),%eax
  80043c:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800441:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800446:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80044b:	5d                   	pop    %ebp
  80044c:	c3                   	ret    

0080044d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80044d:	55                   	push   %ebp
  80044e:	89 e5                	mov    %esp,%ebp
  800450:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800453:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800458:	89 c2                	mov    %eax,%edx
  80045a:	c1 ea 16             	shr    $0x16,%edx
  80045d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800464:	f6 c2 01             	test   $0x1,%dl
  800467:	74 11                	je     80047a <fd_alloc+0x2d>
  800469:	89 c2                	mov    %eax,%edx
  80046b:	c1 ea 0c             	shr    $0xc,%edx
  80046e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800475:	f6 c2 01             	test   $0x1,%dl
  800478:	75 09                	jne    800483 <fd_alloc+0x36>
			*fd_store = fd;
  80047a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	eb 17                	jmp    80049a <fd_alloc+0x4d>
  800483:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800488:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80048d:	75 c9                	jne    800458 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80048f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800495:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80049a:	5d                   	pop    %ebp
  80049b:	c3                   	ret    

0080049c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004a2:	83 f8 1f             	cmp    $0x1f,%eax
  8004a5:	77 36                	ja     8004dd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004a7:	c1 e0 0c             	shl    $0xc,%eax
  8004aa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004af:	89 c2                	mov    %eax,%edx
  8004b1:	c1 ea 16             	shr    $0x16,%edx
  8004b4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004bb:	f6 c2 01             	test   $0x1,%dl
  8004be:	74 24                	je     8004e4 <fd_lookup+0x48>
  8004c0:	89 c2                	mov    %eax,%edx
  8004c2:	c1 ea 0c             	shr    $0xc,%edx
  8004c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004cc:	f6 c2 01             	test   $0x1,%dl
  8004cf:	74 1a                	je     8004eb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d4:	89 02                	mov    %eax,(%edx)
	return 0;
  8004d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004db:	eb 13                	jmp    8004f0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004e2:	eb 0c                	jmp    8004f0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004e9:	eb 05                	jmp    8004f0 <fd_lookup+0x54>
  8004eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004f0:	5d                   	pop    %ebp
  8004f1:	c3                   	ret    

008004f2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8004fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800500:	eb 13                	jmp    800515 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800502:	39 08                	cmp    %ecx,(%eax)
  800504:	75 0c                	jne    800512 <dev_lookup+0x20>
			*dev = devtab[i];
  800506:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800509:	89 01                	mov    %eax,(%ecx)
			return 0;
  80050b:	b8 00 00 00 00       	mov    $0x0,%eax
  800510:	eb 36                	jmp    800548 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800512:	83 c2 01             	add    $0x1,%edx
  800515:	8b 04 95 74 24 80 00 	mov    0x802474(,%edx,4),%eax
  80051c:	85 c0                	test   %eax,%eax
  80051e:	75 e2                	jne    800502 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800520:	a1 08 40 80 00       	mov    0x804008,%eax
  800525:	8b 40 48             	mov    0x48(%eax),%eax
  800528:	83 ec 04             	sub    $0x4,%esp
  80052b:	51                   	push   %ecx
  80052c:	50                   	push   %eax
  80052d:	68 f8 23 80 00       	push   $0x8023f8
  800532:	e8 4b 11 00 00       	call   801682 <cprintf>
	*dev = 0;
  800537:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800548:	c9                   	leave  
  800549:	c3                   	ret    

0080054a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80054a:	55                   	push   %ebp
  80054b:	89 e5                	mov    %esp,%ebp
  80054d:	56                   	push   %esi
  80054e:	53                   	push   %ebx
  80054f:	83 ec 10             	sub    $0x10,%esp
  800552:	8b 75 08             	mov    0x8(%ebp),%esi
  800555:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800558:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80055b:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80055c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800562:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800565:	50                   	push   %eax
  800566:	e8 31 ff ff ff       	call   80049c <fd_lookup>
  80056b:	83 c4 08             	add    $0x8,%esp
  80056e:	85 c0                	test   %eax,%eax
  800570:	78 05                	js     800577 <fd_close+0x2d>
	    || fd != fd2)
  800572:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800575:	74 0c                	je     800583 <fd_close+0x39>
		return (must_exist ? r : 0);
  800577:	84 db                	test   %bl,%bl
  800579:	ba 00 00 00 00       	mov    $0x0,%edx
  80057e:	0f 44 c2             	cmove  %edx,%eax
  800581:	eb 41                	jmp    8005c4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800589:	50                   	push   %eax
  80058a:	ff 36                	pushl  (%esi)
  80058c:	e8 61 ff ff ff       	call   8004f2 <dev_lookup>
  800591:	89 c3                	mov    %eax,%ebx
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	85 c0                	test   %eax,%eax
  800598:	78 1a                	js     8005b4 <fd_close+0x6a>
		if (dev->dev_close)
  80059a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80059d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8005a0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	74 0b                	je     8005b4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005a9:	83 ec 0c             	sub    $0xc,%esp
  8005ac:	56                   	push   %esi
  8005ad:	ff d0                	call   *%eax
  8005af:	89 c3                	mov    %eax,%ebx
  8005b1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	56                   	push   %esi
  8005b8:	6a 00                	push   $0x0
  8005ba:	e8 36 fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	89 d8                	mov    %ebx,%eax
}
  8005c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005c7:	5b                   	pop    %ebx
  8005c8:	5e                   	pop    %esi
  8005c9:	5d                   	pop    %ebp
  8005ca:	c3                   	ret    

008005cb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005cb:	55                   	push   %ebp
  8005cc:	89 e5                	mov    %esp,%ebp
  8005ce:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005d4:	50                   	push   %eax
  8005d5:	ff 75 08             	pushl  0x8(%ebp)
  8005d8:	e8 bf fe ff ff       	call   80049c <fd_lookup>
  8005dd:	89 c2                	mov    %eax,%edx
  8005df:	83 c4 08             	add    $0x8,%esp
  8005e2:	85 d2                	test   %edx,%edx
  8005e4:	78 10                	js     8005f6 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	6a 01                	push   $0x1
  8005eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8005ee:	e8 57 ff ff ff       	call   80054a <fd_close>
  8005f3:	83 c4 10             	add    $0x10,%esp
}
  8005f6:	c9                   	leave  
  8005f7:	c3                   	ret    

008005f8 <close_all>:

void
close_all(void)
{
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	53                   	push   %ebx
  8005fc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ff:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	53                   	push   %ebx
  800608:	e8 be ff ff ff       	call   8005cb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80060d:	83 c3 01             	add    $0x1,%ebx
  800610:	83 c4 10             	add    $0x10,%esp
  800613:	83 fb 20             	cmp    $0x20,%ebx
  800616:	75 ec                	jne    800604 <close_all+0xc>
		close(i);
}
  800618:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80061b:	c9                   	leave  
  80061c:	c3                   	ret    

0080061d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80061d:	55                   	push   %ebp
  80061e:	89 e5                	mov    %esp,%ebp
  800620:	57                   	push   %edi
  800621:	56                   	push   %esi
  800622:	53                   	push   %ebx
  800623:	83 ec 2c             	sub    $0x2c,%esp
  800626:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800629:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80062c:	50                   	push   %eax
  80062d:	ff 75 08             	pushl  0x8(%ebp)
  800630:	e8 67 fe ff ff       	call   80049c <fd_lookup>
  800635:	89 c2                	mov    %eax,%edx
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	85 d2                	test   %edx,%edx
  80063c:	0f 88 c1 00 00 00    	js     800703 <dup+0xe6>
		return r;
	close(newfdnum);
  800642:	83 ec 0c             	sub    $0xc,%esp
  800645:	56                   	push   %esi
  800646:	e8 80 ff ff ff       	call   8005cb <close>

	newfd = INDEX2FD(newfdnum);
  80064b:	89 f3                	mov    %esi,%ebx
  80064d:	c1 e3 0c             	shl    $0xc,%ebx
  800650:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800656:	83 c4 04             	add    $0x4,%esp
  800659:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065c:	e8 d5 fd ff ff       	call   800436 <fd2data>
  800661:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800663:	89 1c 24             	mov    %ebx,(%esp)
  800666:	e8 cb fd ff ff       	call   800436 <fd2data>
  80066b:	83 c4 10             	add    $0x10,%esp
  80066e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800671:	89 f8                	mov    %edi,%eax
  800673:	c1 e8 16             	shr    $0x16,%eax
  800676:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80067d:	a8 01                	test   $0x1,%al
  80067f:	74 37                	je     8006b8 <dup+0x9b>
  800681:	89 f8                	mov    %edi,%eax
  800683:	c1 e8 0c             	shr    $0xc,%eax
  800686:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80068d:	f6 c2 01             	test   $0x1,%dl
  800690:	74 26                	je     8006b8 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800692:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800699:	83 ec 0c             	sub    $0xc,%esp
  80069c:	25 07 0e 00 00       	and    $0xe07,%eax
  8006a1:	50                   	push   %eax
  8006a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006a5:	6a 00                	push   $0x0
  8006a7:	57                   	push   %edi
  8006a8:	6a 00                	push   $0x0
  8006aa:	e8 04 fb ff ff       	call   8001b3 <sys_page_map>
  8006af:	89 c7                	mov    %eax,%edi
  8006b1:	83 c4 20             	add    $0x20,%esp
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	78 2e                	js     8006e6 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006bb:	89 d0                	mov    %edx,%eax
  8006bd:	c1 e8 0c             	shr    $0xc,%eax
  8006c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8006cf:	50                   	push   %eax
  8006d0:	53                   	push   %ebx
  8006d1:	6a 00                	push   $0x0
  8006d3:	52                   	push   %edx
  8006d4:	6a 00                	push   $0x0
  8006d6:	e8 d8 fa ff ff       	call   8001b3 <sys_page_map>
  8006db:	89 c7                	mov    %eax,%edi
  8006dd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006e0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006e2:	85 ff                	test   %edi,%edi
  8006e4:	79 1d                	jns    800703 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	6a 00                	push   $0x0
  8006ec:	e8 04 fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006f1:	83 c4 08             	add    $0x8,%esp
  8006f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006f7:	6a 00                	push   $0x0
  8006f9:	e8 f7 fa ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	89 f8                	mov    %edi,%eax
}
  800703:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800706:	5b                   	pop    %ebx
  800707:	5e                   	pop    %esi
  800708:	5f                   	pop    %edi
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	53                   	push   %ebx
  80070f:	83 ec 14             	sub    $0x14,%esp
  800712:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800715:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800718:	50                   	push   %eax
  800719:	53                   	push   %ebx
  80071a:	e8 7d fd ff ff       	call   80049c <fd_lookup>
  80071f:	83 c4 08             	add    $0x8,%esp
  800722:	89 c2                	mov    %eax,%edx
  800724:	85 c0                	test   %eax,%eax
  800726:	78 6d                	js     800795 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072e:	50                   	push   %eax
  80072f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800732:	ff 30                	pushl  (%eax)
  800734:	e8 b9 fd ff ff       	call   8004f2 <dev_lookup>
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	85 c0                	test   %eax,%eax
  80073e:	78 4c                	js     80078c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800740:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800743:	8b 42 08             	mov    0x8(%edx),%eax
  800746:	83 e0 03             	and    $0x3,%eax
  800749:	83 f8 01             	cmp    $0x1,%eax
  80074c:	75 21                	jne    80076f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80074e:	a1 08 40 80 00       	mov    0x804008,%eax
  800753:	8b 40 48             	mov    0x48(%eax),%eax
  800756:	83 ec 04             	sub    $0x4,%esp
  800759:	53                   	push   %ebx
  80075a:	50                   	push   %eax
  80075b:	68 39 24 80 00       	push   $0x802439
  800760:	e8 1d 0f 00 00       	call   801682 <cprintf>
		return -E_INVAL;
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076d:	eb 26                	jmp    800795 <read+0x8a>
	}
	if (!dev->dev_read)
  80076f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800772:	8b 40 08             	mov    0x8(%eax),%eax
  800775:	85 c0                	test   %eax,%eax
  800777:	74 17                	je     800790 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800779:	83 ec 04             	sub    $0x4,%esp
  80077c:	ff 75 10             	pushl  0x10(%ebp)
  80077f:	ff 75 0c             	pushl  0xc(%ebp)
  800782:	52                   	push   %edx
  800783:	ff d0                	call   *%eax
  800785:	89 c2                	mov    %eax,%edx
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	eb 09                	jmp    800795 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078c:	89 c2                	mov    %eax,%edx
  80078e:	eb 05                	jmp    800795 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800790:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800795:	89 d0                	mov    %edx,%eax
  800797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	57                   	push   %edi
  8007a0:	56                   	push   %esi
  8007a1:	53                   	push   %ebx
  8007a2:	83 ec 0c             	sub    $0xc,%esp
  8007a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b0:	eb 21                	jmp    8007d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007b2:	83 ec 04             	sub    $0x4,%esp
  8007b5:	89 f0                	mov    %esi,%eax
  8007b7:	29 d8                	sub    %ebx,%eax
  8007b9:	50                   	push   %eax
  8007ba:	89 d8                	mov    %ebx,%eax
  8007bc:	03 45 0c             	add    0xc(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	57                   	push   %edi
  8007c1:	e8 45 ff ff ff       	call   80070b <read>
		if (m < 0)
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 0c                	js     8007d9 <readn+0x3d>
			return m;
		if (m == 0)
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	74 06                	je     8007d7 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007d1:	01 c3                	add    %eax,%ebx
  8007d3:	39 f3                	cmp    %esi,%ebx
  8007d5:	72 db                	jb     8007b2 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8007d7:	89 d8                	mov    %ebx,%eax
}
  8007d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5f                   	pop    %edi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	83 ec 14             	sub    $0x14,%esp
  8007e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ee:	50                   	push   %eax
  8007ef:	53                   	push   %ebx
  8007f0:	e8 a7 fc ff ff       	call   80049c <fd_lookup>
  8007f5:	83 c4 08             	add    $0x8,%esp
  8007f8:	89 c2                	mov    %eax,%edx
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	78 68                	js     800866 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800804:	50                   	push   %eax
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	ff 30                	pushl  (%eax)
  80080a:	e8 e3 fc ff ff       	call   8004f2 <dev_lookup>
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	85 c0                	test   %eax,%eax
  800814:	78 47                	js     80085d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800816:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800819:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80081d:	75 21                	jne    800840 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80081f:	a1 08 40 80 00       	mov    0x804008,%eax
  800824:	8b 40 48             	mov    0x48(%eax),%eax
  800827:	83 ec 04             	sub    $0x4,%esp
  80082a:	53                   	push   %ebx
  80082b:	50                   	push   %eax
  80082c:	68 55 24 80 00       	push   $0x802455
  800831:	e8 4c 0e 00 00       	call   801682 <cprintf>
		return -E_INVAL;
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083e:	eb 26                	jmp    800866 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800840:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800843:	8b 52 0c             	mov    0xc(%edx),%edx
  800846:	85 d2                	test   %edx,%edx
  800848:	74 17                	je     800861 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80084a:	83 ec 04             	sub    $0x4,%esp
  80084d:	ff 75 10             	pushl  0x10(%ebp)
  800850:	ff 75 0c             	pushl  0xc(%ebp)
  800853:	50                   	push   %eax
  800854:	ff d2                	call   *%edx
  800856:	89 c2                	mov    %eax,%edx
  800858:	83 c4 10             	add    $0x10,%esp
  80085b:	eb 09                	jmp    800866 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085d:	89 c2                	mov    %eax,%edx
  80085f:	eb 05                	jmp    800866 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800861:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800866:	89 d0                	mov    %edx,%eax
  800868:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <seek>:

int
seek(int fdnum, off_t offset)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800873:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800876:	50                   	push   %eax
  800877:	ff 75 08             	pushl  0x8(%ebp)
  80087a:	e8 1d fc ff ff       	call   80049c <fd_lookup>
  80087f:	83 c4 08             	add    $0x8,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 0e                	js     800894 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800886:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80088f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800894:	c9                   	leave  
  800895:	c3                   	ret    

00800896 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	83 ec 14             	sub    $0x14,%esp
  80089d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a3:	50                   	push   %eax
  8008a4:	53                   	push   %ebx
  8008a5:	e8 f2 fb ff ff       	call   80049c <fd_lookup>
  8008aa:	83 c4 08             	add    $0x8,%esp
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	85 c0                	test   %eax,%eax
  8008b1:	78 65                	js     800918 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b3:	83 ec 08             	sub    $0x8,%esp
  8008b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b9:	50                   	push   %eax
  8008ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008bd:	ff 30                	pushl  (%eax)
  8008bf:	e8 2e fc ff ff       	call   8004f2 <dev_lookup>
  8008c4:	83 c4 10             	add    $0x10,%esp
  8008c7:	85 c0                	test   %eax,%eax
  8008c9:	78 44                	js     80090f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ce:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008d2:	75 21                	jne    8008f5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008d4:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008d9:	8b 40 48             	mov    0x48(%eax),%eax
  8008dc:	83 ec 04             	sub    $0x4,%esp
  8008df:	53                   	push   %ebx
  8008e0:	50                   	push   %eax
  8008e1:	68 18 24 80 00       	push   $0x802418
  8008e6:	e8 97 0d 00 00       	call   801682 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008f3:	eb 23                	jmp    800918 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008f8:	8b 52 18             	mov    0x18(%edx),%edx
  8008fb:	85 d2                	test   %edx,%edx
  8008fd:	74 14                	je     800913 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	50                   	push   %eax
  800906:	ff d2                	call   *%edx
  800908:	89 c2                	mov    %eax,%edx
  80090a:	83 c4 10             	add    $0x10,%esp
  80090d:	eb 09                	jmp    800918 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80090f:	89 c2                	mov    %eax,%edx
  800911:	eb 05                	jmp    800918 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800913:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800918:	89 d0                	mov    %edx,%eax
  80091a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	53                   	push   %ebx
  800923:	83 ec 14             	sub    $0x14,%esp
  800926:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800929:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80092c:	50                   	push   %eax
  80092d:	ff 75 08             	pushl  0x8(%ebp)
  800930:	e8 67 fb ff ff       	call   80049c <fd_lookup>
  800935:	83 c4 08             	add    $0x8,%esp
  800938:	89 c2                	mov    %eax,%edx
  80093a:	85 c0                	test   %eax,%eax
  80093c:	78 58                	js     800996 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80093e:	83 ec 08             	sub    $0x8,%esp
  800941:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800944:	50                   	push   %eax
  800945:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800948:	ff 30                	pushl  (%eax)
  80094a:	e8 a3 fb ff ff       	call   8004f2 <dev_lookup>
  80094f:	83 c4 10             	add    $0x10,%esp
  800952:	85 c0                	test   %eax,%eax
  800954:	78 37                	js     80098d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800956:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800959:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80095d:	74 32                	je     800991 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80095f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800962:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800969:	00 00 00 
	stat->st_isdir = 0;
  80096c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800973:	00 00 00 
	stat->st_dev = dev;
  800976:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80097c:	83 ec 08             	sub    $0x8,%esp
  80097f:	53                   	push   %ebx
  800980:	ff 75 f0             	pushl  -0x10(%ebp)
  800983:	ff 50 14             	call   *0x14(%eax)
  800986:	89 c2                	mov    %eax,%edx
  800988:	83 c4 10             	add    $0x10,%esp
  80098b:	eb 09                	jmp    800996 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80098d:	89 c2                	mov    %eax,%edx
  80098f:	eb 05                	jmp    800996 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800991:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800996:	89 d0                	mov    %edx,%eax
  800998:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	6a 00                	push   $0x0
  8009a7:	ff 75 08             	pushl  0x8(%ebp)
  8009aa:	e8 09 02 00 00       	call   800bb8 <open>
  8009af:	89 c3                	mov    %eax,%ebx
  8009b1:	83 c4 10             	add    $0x10,%esp
  8009b4:	85 db                	test   %ebx,%ebx
  8009b6:	78 1b                	js     8009d3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8009b8:	83 ec 08             	sub    $0x8,%esp
  8009bb:	ff 75 0c             	pushl  0xc(%ebp)
  8009be:	53                   	push   %ebx
  8009bf:	e8 5b ff ff ff       	call   80091f <fstat>
  8009c4:	89 c6                	mov    %eax,%esi
	close(fd);
  8009c6:	89 1c 24             	mov    %ebx,(%esp)
  8009c9:	e8 fd fb ff ff       	call   8005cb <close>
	return r;
  8009ce:	83 c4 10             	add    $0x10,%esp
  8009d1:	89 f0                	mov    %esi,%eax
}
  8009d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	89 c6                	mov    %eax,%esi
  8009e1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009e3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009ea:	75 12                	jne    8009fe <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009ec:	83 ec 0c             	sub    $0xc,%esp
  8009ef:	6a 01                	push   $0x1
  8009f1:	e8 8c 16 00 00       	call   802082 <ipc_find_env>
  8009f6:	a3 00 40 80 00       	mov    %eax,0x804000
  8009fb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009fe:	6a 07                	push   $0x7
  800a00:	68 00 50 80 00       	push   $0x805000
  800a05:	56                   	push   %esi
  800a06:	ff 35 00 40 80 00    	pushl  0x804000
  800a0c:	e8 1d 16 00 00       	call   80202e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a11:	83 c4 0c             	add    $0xc,%esp
  800a14:	6a 00                	push   $0x0
  800a16:	53                   	push   %ebx
  800a17:	6a 00                	push   $0x0
  800a19:	e8 a7 15 00 00       	call   801fc5 <ipc_recv>
}
  800a1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a31:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a39:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a43:	b8 02 00 00 00       	mov    $0x2,%eax
  800a48:	e8 8d ff ff ff       	call   8009da <fsipc>
}
  800a4d:	c9                   	leave  
  800a4e:	c3                   	ret    

00800a4f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a60:	ba 00 00 00 00       	mov    $0x0,%edx
  800a65:	b8 06 00 00 00       	mov    $0x6,%eax
  800a6a:	e8 6b ff ff ff       	call   8009da <fsipc>
}
  800a6f:	c9                   	leave  
  800a70:	c3                   	ret    

00800a71 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	53                   	push   %ebx
  800a75:	83 ec 04             	sub    $0x4,%esp
  800a78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a81:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a86:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8b:	b8 05 00 00 00       	mov    $0x5,%eax
  800a90:	e8 45 ff ff ff       	call   8009da <fsipc>
  800a95:	89 c2                	mov    %eax,%edx
  800a97:	85 d2                	test   %edx,%edx
  800a99:	78 2c                	js     800ac7 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a9b:	83 ec 08             	sub    $0x8,%esp
  800a9e:	68 00 50 80 00       	push   $0x805000
  800aa3:	53                   	push   %ebx
  800aa4:	e8 60 11 00 00       	call   801c09 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800aa9:	a1 80 50 80 00       	mov    0x805080,%eax
  800aae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ab4:	a1 84 50 80 00       	mov    0x805084,%eax
  800ab9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800abf:	83 c4 10             	add    $0x10,%esp
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aca:	c9                   	leave  
  800acb:	c3                   	ret    

00800acc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	83 ec 0c             	sub    $0xc,%esp
  800ad5:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8b 40 0c             	mov    0xc(%eax),%eax
  800ade:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800ae3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800ae6:	eb 3d                	jmp    800b25 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800ae8:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800aee:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800af3:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800af6:	83 ec 04             	sub    $0x4,%esp
  800af9:	57                   	push   %edi
  800afa:	53                   	push   %ebx
  800afb:	68 08 50 80 00       	push   $0x805008
  800b00:	e8 96 12 00 00       	call   801d9b <memmove>
                fsipcbuf.write.req_n = tmp; 
  800b05:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b10:	b8 04 00 00 00       	mov    $0x4,%eax
  800b15:	e8 c0 fe ff ff       	call   8009da <fsipc>
  800b1a:	83 c4 10             	add    $0x10,%esp
  800b1d:	85 c0                	test   %eax,%eax
  800b1f:	78 0d                	js     800b2e <devfile_write+0x62>
		        return r;
                n -= tmp;
  800b21:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800b23:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800b25:	85 f6                	test   %esi,%esi
  800b27:	75 bf                	jne    800ae8 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800b29:	89 d8                	mov    %ebx,%eax
  800b2b:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800b2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	8b 40 0c             	mov    0xc(%eax),%eax
  800b44:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b49:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b54:	b8 03 00 00 00       	mov    $0x3,%eax
  800b59:	e8 7c fe ff ff       	call   8009da <fsipc>
  800b5e:	89 c3                	mov    %eax,%ebx
  800b60:	85 c0                	test   %eax,%eax
  800b62:	78 4b                	js     800baf <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b64:	39 c6                	cmp    %eax,%esi
  800b66:	73 16                	jae    800b7e <devfile_read+0x48>
  800b68:	68 88 24 80 00       	push   $0x802488
  800b6d:	68 8f 24 80 00       	push   $0x80248f
  800b72:	6a 7c                	push   $0x7c
  800b74:	68 a4 24 80 00       	push   $0x8024a4
  800b79:	e8 2b 0a 00 00       	call   8015a9 <_panic>
	assert(r <= PGSIZE);
  800b7e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b83:	7e 16                	jle    800b9b <devfile_read+0x65>
  800b85:	68 af 24 80 00       	push   $0x8024af
  800b8a:	68 8f 24 80 00       	push   $0x80248f
  800b8f:	6a 7d                	push   $0x7d
  800b91:	68 a4 24 80 00       	push   $0x8024a4
  800b96:	e8 0e 0a 00 00       	call   8015a9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b9b:	83 ec 04             	sub    $0x4,%esp
  800b9e:	50                   	push   %eax
  800b9f:	68 00 50 80 00       	push   $0x805000
  800ba4:	ff 75 0c             	pushl  0xc(%ebp)
  800ba7:	e8 ef 11 00 00       	call   801d9b <memmove>
	return r;
  800bac:	83 c4 10             	add    $0x10,%esp
}
  800baf:	89 d8                	mov    %ebx,%eax
  800bb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 20             	sub    $0x20,%esp
  800bbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bc2:	53                   	push   %ebx
  800bc3:	e8 08 10 00 00       	call   801bd0 <strlen>
  800bc8:	83 c4 10             	add    $0x10,%esp
  800bcb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bd0:	7f 67                	jg     800c39 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bd8:	50                   	push   %eax
  800bd9:	e8 6f f8 ff ff       	call   80044d <fd_alloc>
  800bde:	83 c4 10             	add    $0x10,%esp
		return r;
  800be1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	78 57                	js     800c3e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800be7:	83 ec 08             	sub    $0x8,%esp
  800bea:	53                   	push   %ebx
  800beb:	68 00 50 80 00       	push   $0x805000
  800bf0:	e8 14 10 00 00       	call   801c09 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bfd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c00:	b8 01 00 00 00       	mov    $0x1,%eax
  800c05:	e8 d0 fd ff ff       	call   8009da <fsipc>
  800c0a:	89 c3                	mov    %eax,%ebx
  800c0c:	83 c4 10             	add    $0x10,%esp
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	79 14                	jns    800c27 <open+0x6f>
		fd_close(fd, 0);
  800c13:	83 ec 08             	sub    $0x8,%esp
  800c16:	6a 00                	push   $0x0
  800c18:	ff 75 f4             	pushl  -0xc(%ebp)
  800c1b:	e8 2a f9 ff ff       	call   80054a <fd_close>
		return r;
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	89 da                	mov    %ebx,%edx
  800c25:	eb 17                	jmp    800c3e <open+0x86>
	}

	return fd2num(fd);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	ff 75 f4             	pushl  -0xc(%ebp)
  800c2d:	e8 f4 f7 ff ff       	call   800426 <fd2num>
  800c32:	89 c2                	mov    %eax,%edx
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	eb 05                	jmp    800c3e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c39:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c3e:	89 d0                	mov    %edx,%eax
  800c40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 08 00 00 00       	mov    $0x8,%eax
  800c55:	e8 80 fd ff ff       	call   8009da <fsipc>
}
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c62:	68 bb 24 80 00       	push   $0x8024bb
  800c67:	ff 75 0c             	pushl  0xc(%ebp)
  800c6a:	e8 9a 0f 00 00       	call   801c09 <strcpy>
	return 0;
}
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c74:	c9                   	leave  
  800c75:	c3                   	ret    

00800c76 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 10             	sub    $0x10,%esp
  800c7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c80:	53                   	push   %ebx
  800c81:	e8 34 14 00 00       	call   8020ba <pageref>
  800c86:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c89:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c8e:	83 f8 01             	cmp    $0x1,%eax
  800c91:	75 10                	jne    800ca3 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	ff 73 0c             	pushl  0xc(%ebx)
  800c99:	e8 ca 02 00 00       	call   800f68 <nsipc_close>
  800c9e:	89 c2                	mov    %eax,%edx
  800ca0:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800ca3:	89 d0                	mov    %edx,%eax
  800ca5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ca8:	c9                   	leave  
  800ca9:	c3                   	ret    

00800caa <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800cb0:	6a 00                	push   $0x0
  800cb2:	ff 75 10             	pushl  0x10(%ebp)
  800cb5:	ff 75 0c             	pushl  0xc(%ebp)
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	ff 70 0c             	pushl  0xc(%eax)
  800cbe:	e8 82 03 00 00       	call   801045 <nsipc_send>
}
  800cc3:	c9                   	leave  
  800cc4:	c3                   	ret    

00800cc5 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800ccb:	6a 00                	push   $0x0
  800ccd:	ff 75 10             	pushl  0x10(%ebp)
  800cd0:	ff 75 0c             	pushl  0xc(%ebp)
  800cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd6:	ff 70 0c             	pushl  0xc(%eax)
  800cd9:	e8 fb 02 00 00       	call   800fd9 <nsipc_recv>
}
  800cde:	c9                   	leave  
  800cdf:	c3                   	ret    

00800ce0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800ce6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ce9:	52                   	push   %edx
  800cea:	50                   	push   %eax
  800ceb:	e8 ac f7 ff ff       	call   80049c <fd_lookup>
  800cf0:	83 c4 10             	add    $0x10,%esp
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	78 17                	js     800d0e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cfa:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800d00:	39 08                	cmp    %ecx,(%eax)
  800d02:	75 05                	jne    800d09 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800d04:	8b 40 0c             	mov    0xc(%eax),%eax
  800d07:	eb 05                	jmp    800d0e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800d09:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800d0e:	c9                   	leave  
  800d0f:	c3                   	ret    

00800d10 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 1c             	sub    $0x1c,%esp
  800d18:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800d1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d1d:	50                   	push   %eax
  800d1e:	e8 2a f7 ff ff       	call   80044d <fd_alloc>
  800d23:	89 c3                	mov    %eax,%ebx
  800d25:	83 c4 10             	add    $0x10,%esp
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	78 1b                	js     800d47 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800d2c:	83 ec 04             	sub    $0x4,%esp
  800d2f:	68 07 04 00 00       	push   $0x407
  800d34:	ff 75 f4             	pushl  -0xc(%ebp)
  800d37:	6a 00                	push   $0x0
  800d39:	e8 32 f4 ff ff       	call   800170 <sys_page_alloc>
  800d3e:	89 c3                	mov    %eax,%ebx
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	85 c0                	test   %eax,%eax
  800d45:	79 10                	jns    800d57 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	56                   	push   %esi
  800d4b:	e8 18 02 00 00       	call   800f68 <nsipc_close>
		return r;
  800d50:	83 c4 10             	add    $0x10,%esp
  800d53:	89 d8                	mov    %ebx,%eax
  800d55:	eb 24                	jmp    800d7b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d57:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d60:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d65:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  800d6c:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	52                   	push   %edx
  800d73:	e8 ae f6 ff ff       	call   800426 <fd2num>
  800d78:	83 c4 10             	add    $0x10,%esp
}
  800d7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	e8 50 ff ff ff       	call   800ce0 <fd2sockid>
		return r;
  800d90:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	78 1f                	js     800db5 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d96:	83 ec 04             	sub    $0x4,%esp
  800d99:	ff 75 10             	pushl  0x10(%ebp)
  800d9c:	ff 75 0c             	pushl  0xc(%ebp)
  800d9f:	50                   	push   %eax
  800da0:	e8 1c 01 00 00       	call   800ec1 <nsipc_accept>
  800da5:	83 c4 10             	add    $0x10,%esp
		return r;
  800da8:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	78 07                	js     800db5 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800dae:	e8 5d ff ff ff       	call   800d10 <alloc_sockfd>
  800db3:	89 c1                	mov    %eax,%ecx
}
  800db5:	89 c8                	mov    %ecx,%eax
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    

00800db9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc2:	e8 19 ff ff ff       	call   800ce0 <fd2sockid>
  800dc7:	89 c2                	mov    %eax,%edx
  800dc9:	85 d2                	test   %edx,%edx
  800dcb:	78 12                	js     800ddf <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  800dcd:	83 ec 04             	sub    $0x4,%esp
  800dd0:	ff 75 10             	pushl  0x10(%ebp)
  800dd3:	ff 75 0c             	pushl  0xc(%ebp)
  800dd6:	52                   	push   %edx
  800dd7:	e8 35 01 00 00       	call   800f11 <nsipc_bind>
  800ddc:	83 c4 10             	add    $0x10,%esp
}
  800ddf:	c9                   	leave  
  800de0:	c3                   	ret    

00800de1 <shutdown>:

int
shutdown(int s, int how)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800de7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dea:	e8 f1 fe ff ff       	call   800ce0 <fd2sockid>
  800def:	89 c2                	mov    %eax,%edx
  800df1:	85 d2                	test   %edx,%edx
  800df3:	78 0f                	js     800e04 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  800df5:	83 ec 08             	sub    $0x8,%esp
  800df8:	ff 75 0c             	pushl  0xc(%ebp)
  800dfb:	52                   	push   %edx
  800dfc:	e8 45 01 00 00       	call   800f46 <nsipc_shutdown>
  800e01:	83 c4 10             	add    $0x10,%esp
}
  800e04:	c9                   	leave  
  800e05:	c3                   	ret    

00800e06 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0f:	e8 cc fe ff ff       	call   800ce0 <fd2sockid>
  800e14:	89 c2                	mov    %eax,%edx
  800e16:	85 d2                	test   %edx,%edx
  800e18:	78 12                	js     800e2c <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  800e1a:	83 ec 04             	sub    $0x4,%esp
  800e1d:	ff 75 10             	pushl  0x10(%ebp)
  800e20:	ff 75 0c             	pushl  0xc(%ebp)
  800e23:	52                   	push   %edx
  800e24:	e8 59 01 00 00       	call   800f82 <nsipc_connect>
  800e29:	83 c4 10             	add    $0x10,%esp
}
  800e2c:	c9                   	leave  
  800e2d:	c3                   	ret    

00800e2e <listen>:

int
listen(int s, int backlog)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	e8 a4 fe ff ff       	call   800ce0 <fd2sockid>
  800e3c:	89 c2                	mov    %eax,%edx
  800e3e:	85 d2                	test   %edx,%edx
  800e40:	78 0f                	js     800e51 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  800e42:	83 ec 08             	sub    $0x8,%esp
  800e45:	ff 75 0c             	pushl  0xc(%ebp)
  800e48:	52                   	push   %edx
  800e49:	e8 69 01 00 00       	call   800fb7 <nsipc_listen>
  800e4e:	83 c4 10             	add    $0x10,%esp
}
  800e51:	c9                   	leave  
  800e52:	c3                   	ret    

00800e53 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e59:	ff 75 10             	pushl  0x10(%ebp)
  800e5c:	ff 75 0c             	pushl  0xc(%ebp)
  800e5f:	ff 75 08             	pushl  0x8(%ebp)
  800e62:	e8 3c 02 00 00       	call   8010a3 <nsipc_socket>
  800e67:	89 c2                	mov    %eax,%edx
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	85 d2                	test   %edx,%edx
  800e6e:	78 05                	js     800e75 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  800e70:	e8 9b fe ff ff       	call   800d10 <alloc_sockfd>
}
  800e75:	c9                   	leave  
  800e76:	c3                   	ret    

00800e77 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	53                   	push   %ebx
  800e7b:	83 ec 04             	sub    $0x4,%esp
  800e7e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e80:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e87:	75 12                	jne    800e9b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	6a 02                	push   $0x2
  800e8e:	e8 ef 11 00 00       	call   802082 <ipc_find_env>
  800e93:	a3 04 40 80 00       	mov    %eax,0x804004
  800e98:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e9b:	6a 07                	push   $0x7
  800e9d:	68 00 60 80 00       	push   $0x806000
  800ea2:	53                   	push   %ebx
  800ea3:	ff 35 04 40 80 00    	pushl  0x804004
  800ea9:	e8 80 11 00 00       	call   80202e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800eae:	83 c4 0c             	add    $0xc,%esp
  800eb1:	6a 00                	push   $0x0
  800eb3:	6a 00                	push   $0x0
  800eb5:	6a 00                	push   $0x0
  800eb7:	e8 09 11 00 00       	call   801fc5 <ipc_recv>
}
  800ebc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ebf:	c9                   	leave  
  800ec0:	c3                   	ret    

00800ec1 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	56                   	push   %esi
  800ec5:	53                   	push   %ebx
  800ec6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800ed1:	8b 06                	mov    (%esi),%eax
  800ed3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800ed8:	b8 01 00 00 00       	mov    $0x1,%eax
  800edd:	e8 95 ff ff ff       	call   800e77 <nsipc>
  800ee2:	89 c3                	mov    %eax,%ebx
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	78 20                	js     800f08 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800ee8:	83 ec 04             	sub    $0x4,%esp
  800eeb:	ff 35 10 60 80 00    	pushl  0x806010
  800ef1:	68 00 60 80 00       	push   $0x806000
  800ef6:	ff 75 0c             	pushl  0xc(%ebp)
  800ef9:	e8 9d 0e 00 00       	call   801d9b <memmove>
		*addrlen = ret->ret_addrlen;
  800efe:	a1 10 60 80 00       	mov    0x806010,%eax
  800f03:	89 06                	mov    %eax,(%esi)
  800f05:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800f08:	89 d8                	mov    %ebx,%eax
  800f0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	53                   	push   %ebx
  800f15:	83 ec 08             	sub    $0x8,%esp
  800f18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800f23:	53                   	push   %ebx
  800f24:	ff 75 0c             	pushl  0xc(%ebp)
  800f27:	68 04 60 80 00       	push   $0x806004
  800f2c:	e8 6a 0e 00 00       	call   801d9b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800f31:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800f37:	b8 02 00 00 00       	mov    $0x2,%eax
  800f3c:	e8 36 ff ff ff       	call   800e77 <nsipc>
}
  800f41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f44:	c9                   	leave  
  800f45:	c3                   	ret    

00800f46 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f57:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f5c:	b8 03 00 00 00       	mov    $0x3,%eax
  800f61:	e8 11 ff ff ff       	call   800e77 <nsipc>
}
  800f66:	c9                   	leave  
  800f67:	c3                   	ret    

00800f68 <nsipc_close>:

int
nsipc_close(int s)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f71:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f76:	b8 04 00 00 00       	mov    $0x4,%eax
  800f7b:	e8 f7 fe ff ff       	call   800e77 <nsipc>
}
  800f80:	c9                   	leave  
  800f81:	c3                   	ret    

00800f82 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	53                   	push   %ebx
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f94:	53                   	push   %ebx
  800f95:	ff 75 0c             	pushl  0xc(%ebp)
  800f98:	68 04 60 80 00       	push   $0x806004
  800f9d:	e8 f9 0d 00 00       	call   801d9b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800fa2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800fa8:	b8 05 00 00 00       	mov    $0x5,%eax
  800fad:	e8 c5 fe ff ff       	call   800e77 <nsipc>
}
  800fb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb5:	c9                   	leave  
  800fb6:	c3                   	ret    

00800fb7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800fcd:	b8 06 00 00 00       	mov    $0x6,%eax
  800fd2:	e8 a0 fe ff ff       	call   800e77 <nsipc>
}
  800fd7:	c9                   	leave  
  800fd8:	c3                   	ret    

00800fd9 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	56                   	push   %esi
  800fdd:	53                   	push   %ebx
  800fde:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800fe9:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800fef:	8b 45 14             	mov    0x14(%ebp),%eax
  800ff2:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800ff7:	b8 07 00 00 00       	mov    $0x7,%eax
  800ffc:	e8 76 fe ff ff       	call   800e77 <nsipc>
  801001:	89 c3                	mov    %eax,%ebx
  801003:	85 c0                	test   %eax,%eax
  801005:	78 35                	js     80103c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801007:	39 f0                	cmp    %esi,%eax
  801009:	7f 07                	jg     801012 <nsipc_recv+0x39>
  80100b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801010:	7e 16                	jle    801028 <nsipc_recv+0x4f>
  801012:	68 c7 24 80 00       	push   $0x8024c7
  801017:	68 8f 24 80 00       	push   $0x80248f
  80101c:	6a 62                	push   $0x62
  80101e:	68 dc 24 80 00       	push   $0x8024dc
  801023:	e8 81 05 00 00       	call   8015a9 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801028:	83 ec 04             	sub    $0x4,%esp
  80102b:	50                   	push   %eax
  80102c:	68 00 60 80 00       	push   $0x806000
  801031:	ff 75 0c             	pushl  0xc(%ebp)
  801034:	e8 62 0d 00 00       	call   801d9b <memmove>
  801039:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80103c:	89 d8                	mov    %ebx,%eax
  80103e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    

00801045 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	53                   	push   %ebx
  801049:	83 ec 04             	sub    $0x4,%esp
  80104c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80104f:	8b 45 08             	mov    0x8(%ebp),%eax
  801052:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801057:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80105d:	7e 16                	jle    801075 <nsipc_send+0x30>
  80105f:	68 e8 24 80 00       	push   $0x8024e8
  801064:	68 8f 24 80 00       	push   $0x80248f
  801069:	6a 6d                	push   $0x6d
  80106b:	68 dc 24 80 00       	push   $0x8024dc
  801070:	e8 34 05 00 00       	call   8015a9 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801075:	83 ec 04             	sub    $0x4,%esp
  801078:	53                   	push   %ebx
  801079:	ff 75 0c             	pushl  0xc(%ebp)
  80107c:	68 0c 60 80 00       	push   $0x80600c
  801081:	e8 15 0d 00 00       	call   801d9b <memmove>
	nsipcbuf.send.req_size = size;
  801086:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80108c:	8b 45 14             	mov    0x14(%ebp),%eax
  80108f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801094:	b8 08 00 00 00       	mov    $0x8,%eax
  801099:	e8 d9 fd ff ff       	call   800e77 <nsipc>
}
  80109e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    

008010a3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8010a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ac:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8010b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8010b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8010bc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8010c1:	b8 09 00 00 00       	mov    $0x9,%eax
  8010c6:	e8 ac fd ff ff       	call   800e77 <nsipc>
}
  8010cb:	c9                   	leave  
  8010cc:	c3                   	ret    

008010cd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	56                   	push   %esi
  8010d1:	53                   	push   %ebx
  8010d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	ff 75 08             	pushl  0x8(%ebp)
  8010db:	e8 56 f3 ff ff       	call   800436 <fd2data>
  8010e0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010e2:	83 c4 08             	add    $0x8,%esp
  8010e5:	68 f4 24 80 00       	push   $0x8024f4
  8010ea:	53                   	push   %ebx
  8010eb:	e8 19 0b 00 00       	call   801c09 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010f0:	8b 56 04             	mov    0x4(%esi),%edx
  8010f3:	89 d0                	mov    %edx,%eax
  8010f5:	2b 06                	sub    (%esi),%eax
  8010f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8010fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801104:	00 00 00 
	stat->st_dev = &devpipe;
  801107:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80110e:	30 80 00 
	return 0;
}
  801111:	b8 00 00 00 00       	mov    $0x0,%eax
  801116:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    

0080111d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	53                   	push   %ebx
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801127:	53                   	push   %ebx
  801128:	6a 00                	push   $0x0
  80112a:	e8 c6 f0 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80112f:	89 1c 24             	mov    %ebx,(%esp)
  801132:	e8 ff f2 ff ff       	call   800436 <fd2data>
  801137:	83 c4 08             	add    $0x8,%esp
  80113a:	50                   	push   %eax
  80113b:	6a 00                	push   $0x0
  80113d:	e8 b3 f0 ff ff       	call   8001f5 <sys_page_unmap>
}
  801142:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801145:	c9                   	leave  
  801146:	c3                   	ret    

00801147 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	57                   	push   %edi
  80114b:	56                   	push   %esi
  80114c:	53                   	push   %ebx
  80114d:	83 ec 1c             	sub    $0x1c,%esp
  801150:	89 c6                	mov    %eax,%esi
  801152:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801155:	a1 08 40 80 00       	mov    0x804008,%eax
  80115a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	56                   	push   %esi
  801161:	e8 54 0f 00 00       	call   8020ba <pageref>
  801166:	89 c7                	mov    %eax,%edi
  801168:	83 c4 04             	add    $0x4,%esp
  80116b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116e:	e8 47 0f 00 00       	call   8020ba <pageref>
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	39 c7                	cmp    %eax,%edi
  801178:	0f 94 c2             	sete   %dl
  80117b:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80117e:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801184:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801187:	39 fb                	cmp    %edi,%ebx
  801189:	74 19                	je     8011a4 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  80118b:	84 d2                	test   %dl,%dl
  80118d:	74 c6                	je     801155 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80118f:	8b 51 58             	mov    0x58(%ecx),%edx
  801192:	50                   	push   %eax
  801193:	52                   	push   %edx
  801194:	53                   	push   %ebx
  801195:	68 fb 24 80 00       	push   $0x8024fb
  80119a:	e8 e3 04 00 00       	call   801682 <cprintf>
  80119f:	83 c4 10             	add    $0x10,%esp
  8011a2:	eb b1                	jmp    801155 <_pipeisclosed+0xe>
	}
}
  8011a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a7:	5b                   	pop    %ebx
  8011a8:	5e                   	pop    %esi
  8011a9:	5f                   	pop    %edi
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	57                   	push   %edi
  8011b0:	56                   	push   %esi
  8011b1:	53                   	push   %ebx
  8011b2:	83 ec 28             	sub    $0x28,%esp
  8011b5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011b8:	56                   	push   %esi
  8011b9:	e8 78 f2 ff ff       	call   800436 <fd2data>
  8011be:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	bf 00 00 00 00       	mov    $0x0,%edi
  8011c8:	eb 4b                	jmp    801215 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011ca:	89 da                	mov    %ebx,%edx
  8011cc:	89 f0                	mov    %esi,%eax
  8011ce:	e8 74 ff ff ff       	call   801147 <_pipeisclosed>
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	75 48                	jne    80121f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011d7:	e8 75 ef ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011dc:	8b 43 04             	mov    0x4(%ebx),%eax
  8011df:	8b 0b                	mov    (%ebx),%ecx
  8011e1:	8d 51 20             	lea    0x20(%ecx),%edx
  8011e4:	39 d0                	cmp    %edx,%eax
  8011e6:	73 e2                	jae    8011ca <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011eb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011ef:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8011f2:	89 c2                	mov    %eax,%edx
  8011f4:	c1 fa 1f             	sar    $0x1f,%edx
  8011f7:	89 d1                	mov    %edx,%ecx
  8011f9:	c1 e9 1b             	shr    $0x1b,%ecx
  8011fc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8011ff:	83 e2 1f             	and    $0x1f,%edx
  801202:	29 ca                	sub    %ecx,%edx
  801204:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801208:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80120c:	83 c0 01             	add    $0x1,%eax
  80120f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801212:	83 c7 01             	add    $0x1,%edi
  801215:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801218:	75 c2                	jne    8011dc <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80121a:	8b 45 10             	mov    0x10(%ebp),%eax
  80121d:	eb 05                	jmp    801224 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80121f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801224:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801227:	5b                   	pop    %ebx
  801228:	5e                   	pop    %esi
  801229:	5f                   	pop    %edi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	57                   	push   %edi
  801230:	56                   	push   %esi
  801231:	53                   	push   %ebx
  801232:	83 ec 18             	sub    $0x18,%esp
  801235:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801238:	57                   	push   %edi
  801239:	e8 f8 f1 ff ff       	call   800436 <fd2data>
  80123e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	bb 00 00 00 00       	mov    $0x0,%ebx
  801248:	eb 3d                	jmp    801287 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80124a:	85 db                	test   %ebx,%ebx
  80124c:	74 04                	je     801252 <devpipe_read+0x26>
				return i;
  80124e:	89 d8                	mov    %ebx,%eax
  801250:	eb 44                	jmp    801296 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801252:	89 f2                	mov    %esi,%edx
  801254:	89 f8                	mov    %edi,%eax
  801256:	e8 ec fe ff ff       	call   801147 <_pipeisclosed>
  80125b:	85 c0                	test   %eax,%eax
  80125d:	75 32                	jne    801291 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80125f:	e8 ed ee ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801264:	8b 06                	mov    (%esi),%eax
  801266:	3b 46 04             	cmp    0x4(%esi),%eax
  801269:	74 df                	je     80124a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80126b:	99                   	cltd   
  80126c:	c1 ea 1b             	shr    $0x1b,%edx
  80126f:	01 d0                	add    %edx,%eax
  801271:	83 e0 1f             	and    $0x1f,%eax
  801274:	29 d0                	sub    %edx,%eax
  801276:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80127b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801281:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801284:	83 c3 01             	add    $0x1,%ebx
  801287:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80128a:	75 d8                	jne    801264 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80128c:	8b 45 10             	mov    0x10(%ebp),%eax
  80128f:	eb 05                	jmp    801296 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801299:	5b                   	pop    %ebx
  80129a:	5e                   	pop    %esi
  80129b:	5f                   	pop    %edi
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	56                   	push   %esi
  8012a2:	53                   	push   %ebx
  8012a3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a9:	50                   	push   %eax
  8012aa:	e8 9e f1 ff ff       	call   80044d <fd_alloc>
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	89 c2                	mov    %eax,%edx
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	0f 88 2c 01 00 00    	js     8013e8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012bc:	83 ec 04             	sub    $0x4,%esp
  8012bf:	68 07 04 00 00       	push   $0x407
  8012c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c7:	6a 00                	push   $0x0
  8012c9:	e8 a2 ee ff ff       	call   800170 <sys_page_alloc>
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	89 c2                	mov    %eax,%edx
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	0f 88 0d 01 00 00    	js     8013e8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012db:	83 ec 0c             	sub    $0xc,%esp
  8012de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	e8 66 f1 ff ff       	call   80044d <fd_alloc>
  8012e7:	89 c3                	mov    %eax,%ebx
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	0f 88 e2 00 00 00    	js     8013d6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012f4:	83 ec 04             	sub    $0x4,%esp
  8012f7:	68 07 04 00 00       	push   $0x407
  8012fc:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ff:	6a 00                	push   $0x0
  801301:	e8 6a ee ff ff       	call   800170 <sys_page_alloc>
  801306:	89 c3                	mov    %eax,%ebx
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	85 c0                	test   %eax,%eax
  80130d:	0f 88 c3 00 00 00    	js     8013d6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801313:	83 ec 0c             	sub    $0xc,%esp
  801316:	ff 75 f4             	pushl  -0xc(%ebp)
  801319:	e8 18 f1 ff ff       	call   800436 <fd2data>
  80131e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801320:	83 c4 0c             	add    $0xc,%esp
  801323:	68 07 04 00 00       	push   $0x407
  801328:	50                   	push   %eax
  801329:	6a 00                	push   $0x0
  80132b:	e8 40 ee ff ff       	call   800170 <sys_page_alloc>
  801330:	89 c3                	mov    %eax,%ebx
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	85 c0                	test   %eax,%eax
  801337:	0f 88 89 00 00 00    	js     8013c6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80133d:	83 ec 0c             	sub    $0xc,%esp
  801340:	ff 75 f0             	pushl  -0x10(%ebp)
  801343:	e8 ee f0 ff ff       	call   800436 <fd2data>
  801348:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80134f:	50                   	push   %eax
  801350:	6a 00                	push   $0x0
  801352:	56                   	push   %esi
  801353:	6a 00                	push   $0x0
  801355:	e8 59 ee ff ff       	call   8001b3 <sys_page_map>
  80135a:	89 c3                	mov    %eax,%ebx
  80135c:	83 c4 20             	add    $0x20,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 55                	js     8013b8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801363:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801369:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80136e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801371:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801378:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80137e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801381:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801383:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801386:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80138d:	83 ec 0c             	sub    $0xc,%esp
  801390:	ff 75 f4             	pushl  -0xc(%ebp)
  801393:	e8 8e f0 ff ff       	call   800426 <fd2num>
  801398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80139d:	83 c4 04             	add    $0x4,%esp
  8013a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a3:	e8 7e f0 ff ff       	call   800426 <fd2num>
  8013a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ab:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b6:	eb 30                	jmp    8013e8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	56                   	push   %esi
  8013bc:	6a 00                	push   $0x0
  8013be:	e8 32 ee ff ff       	call   8001f5 <sys_page_unmap>
  8013c3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8013cc:	6a 00                	push   $0x0
  8013ce:	e8 22 ee ff ff       	call   8001f5 <sys_page_unmap>
  8013d3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013d6:	83 ec 08             	sub    $0x8,%esp
  8013d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8013dc:	6a 00                	push   $0x0
  8013de:	e8 12 ee ff ff       	call   8001f5 <sys_page_unmap>
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013e8:	89 d0                	mov    %edx,%eax
  8013ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ed:	5b                   	pop    %ebx
  8013ee:	5e                   	pop    %esi
  8013ef:	5d                   	pop    %ebp
  8013f0:	c3                   	ret    

008013f1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fa:	50                   	push   %eax
  8013fb:	ff 75 08             	pushl  0x8(%ebp)
  8013fe:	e8 99 f0 ff ff       	call   80049c <fd_lookup>
  801403:	89 c2                	mov    %eax,%edx
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	85 d2                	test   %edx,%edx
  80140a:	78 18                	js     801424 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80140c:	83 ec 0c             	sub    $0xc,%esp
  80140f:	ff 75 f4             	pushl  -0xc(%ebp)
  801412:	e8 1f f0 ff ff       	call   800436 <fd2data>
	return _pipeisclosed(fd, p);
  801417:	89 c2                	mov    %eax,%edx
  801419:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141c:	e8 26 fd ff ff       	call   801147 <_pipeisclosed>
  801421:	83 c4 10             	add    $0x10,%esp
}
  801424:	c9                   	leave  
  801425:	c3                   	ret    

00801426 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801429:	b8 00 00 00 00       	mov    $0x0,%eax
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801436:	68 13 25 80 00       	push   $0x802513
  80143b:	ff 75 0c             	pushl  0xc(%ebp)
  80143e:	e8 c6 07 00 00       	call   801c09 <strcpy>
	return 0;
}
  801443:	b8 00 00 00 00       	mov    $0x0,%eax
  801448:	c9                   	leave  
  801449:	c3                   	ret    

0080144a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	57                   	push   %edi
  80144e:	56                   	push   %esi
  80144f:	53                   	push   %ebx
  801450:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801456:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80145b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801461:	eb 2d                	jmp    801490 <devcons_write+0x46>
		m = n - tot;
  801463:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801466:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801468:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80146b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801470:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801473:	83 ec 04             	sub    $0x4,%esp
  801476:	53                   	push   %ebx
  801477:	03 45 0c             	add    0xc(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	57                   	push   %edi
  80147c:	e8 1a 09 00 00       	call   801d9b <memmove>
		sys_cputs(buf, m);
  801481:	83 c4 08             	add    $0x8,%esp
  801484:	53                   	push   %ebx
  801485:	57                   	push   %edi
  801486:	e8 29 ec ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80148b:	01 de                	add    %ebx,%esi
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	89 f0                	mov    %esi,%eax
  801492:	3b 75 10             	cmp    0x10(%ebp),%esi
  801495:	72 cc                	jb     801463 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801497:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5f                   	pop    %edi
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    

0080149f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8014a5:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8014aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014ae:	75 07                	jne    8014b7 <devcons_read+0x18>
  8014b0:	eb 28                	jmp    8014da <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014b2:	e8 9a ec ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014b7:	e8 16 ec ff ff       	call   8000d2 <sys_cgetc>
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	74 f2                	je     8014b2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 16                	js     8014da <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014c4:	83 f8 04             	cmp    $0x4,%eax
  8014c7:	74 0c                	je     8014d5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014cc:	88 02                	mov    %al,(%edx)
	return 1;
  8014ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8014d3:	eb 05                	jmp    8014da <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014d5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014da:	c9                   	leave  
  8014db:	c3                   	ret    

008014dc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014e8:	6a 01                	push   $0x1
  8014ea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014ed:	50                   	push   %eax
  8014ee:	e8 c1 eb ff ff       	call   8000b4 <sys_cputs>
  8014f3:	83 c4 10             	add    $0x10,%esp
}
  8014f6:	c9                   	leave  
  8014f7:	c3                   	ret    

008014f8 <getchar>:

int
getchar(void)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014fe:	6a 01                	push   $0x1
  801500:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801503:	50                   	push   %eax
  801504:	6a 00                	push   $0x0
  801506:	e8 00 f2 ff ff       	call   80070b <read>
	if (r < 0)
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 0f                	js     801521 <getchar+0x29>
		return r;
	if (r < 1)
  801512:	85 c0                	test   %eax,%eax
  801514:	7e 06                	jle    80151c <getchar+0x24>
		return -E_EOF;
	return c;
  801516:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80151a:	eb 05                	jmp    801521 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80151c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801529:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152c:	50                   	push   %eax
  80152d:	ff 75 08             	pushl  0x8(%ebp)
  801530:	e8 67 ef ff ff       	call   80049c <fd_lookup>
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 11                	js     80154d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80153c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801545:	39 10                	cmp    %edx,(%eax)
  801547:	0f 94 c0             	sete   %al
  80154a:	0f b6 c0             	movzbl %al,%eax
}
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <opencons>:

int
opencons(void)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801555:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	e8 ef ee ff ff       	call   80044d <fd_alloc>
  80155e:	83 c4 10             	add    $0x10,%esp
		return r;
  801561:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801563:	85 c0                	test   %eax,%eax
  801565:	78 3e                	js     8015a5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	68 07 04 00 00       	push   $0x407
  80156f:	ff 75 f4             	pushl  -0xc(%ebp)
  801572:	6a 00                	push   $0x0
  801574:	e8 f7 eb ff ff       	call   800170 <sys_page_alloc>
  801579:	83 c4 10             	add    $0x10,%esp
		return r;
  80157c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 23                	js     8015a5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801582:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801588:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80158d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801590:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801597:	83 ec 0c             	sub    $0xc,%esp
  80159a:	50                   	push   %eax
  80159b:	e8 86 ee ff ff       	call   800426 <fd2num>
  8015a0:	89 c2                	mov    %eax,%edx
  8015a2:	83 c4 10             	add    $0x10,%esp
}
  8015a5:	89 d0                	mov    %edx,%eax
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	56                   	push   %esi
  8015ad:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015ae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015b1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015b7:	e8 76 eb ff ff       	call   800132 <sys_getenvid>
  8015bc:	83 ec 0c             	sub    $0xc,%esp
  8015bf:	ff 75 0c             	pushl  0xc(%ebp)
  8015c2:	ff 75 08             	pushl  0x8(%ebp)
  8015c5:	56                   	push   %esi
  8015c6:	50                   	push   %eax
  8015c7:	68 20 25 80 00       	push   $0x802520
  8015cc:	e8 b1 00 00 00       	call   801682 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015d1:	83 c4 18             	add    $0x18,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	ff 75 10             	pushl  0x10(%ebp)
  8015d8:	e8 54 00 00 00       	call   801631 <vcprintf>
	cprintf("\n");
  8015dd:	c7 04 24 0c 25 80 00 	movl   $0x80250c,(%esp)
  8015e4:	e8 99 00 00 00       	call   801682 <cprintf>
  8015e9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015ec:	cc                   	int3   
  8015ed:	eb fd                	jmp    8015ec <_panic+0x43>

008015ef <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	53                   	push   %ebx
  8015f3:	83 ec 04             	sub    $0x4,%esp
  8015f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015f9:	8b 13                	mov    (%ebx),%edx
  8015fb:	8d 42 01             	lea    0x1(%edx),%eax
  8015fe:	89 03                	mov    %eax,(%ebx)
  801600:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801603:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801607:	3d ff 00 00 00       	cmp    $0xff,%eax
  80160c:	75 1a                	jne    801628 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	68 ff 00 00 00       	push   $0xff
  801616:	8d 43 08             	lea    0x8(%ebx),%eax
  801619:	50                   	push   %eax
  80161a:	e8 95 ea ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  80161f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801625:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801628:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80162c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80163a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801641:	00 00 00 
	b.cnt = 0;
  801644:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80164b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80164e:	ff 75 0c             	pushl  0xc(%ebp)
  801651:	ff 75 08             	pushl  0x8(%ebp)
  801654:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80165a:	50                   	push   %eax
  80165b:	68 ef 15 80 00       	push   $0x8015ef
  801660:	e8 4f 01 00 00       	call   8017b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801665:	83 c4 08             	add    $0x8,%esp
  801668:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80166e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801674:	50                   	push   %eax
  801675:	e8 3a ea ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  80167a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801688:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80168b:	50                   	push   %eax
  80168c:	ff 75 08             	pushl  0x8(%ebp)
  80168f:	e8 9d ff ff ff       	call   801631 <vcprintf>
	va_end(ap);

	return cnt;
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	57                   	push   %edi
  80169a:	56                   	push   %esi
  80169b:	53                   	push   %ebx
  80169c:	83 ec 1c             	sub    $0x1c,%esp
  80169f:	89 c7                	mov    %eax,%edi
  8016a1:	89 d6                	mov    %edx,%esi
  8016a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a9:	89 d1                	mov    %edx,%ecx
  8016ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016ae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8016b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8016b4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8016c1:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8016c4:	72 05                	jb     8016cb <printnum+0x35>
  8016c6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8016c9:	77 3e                	ja     801709 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016cb:	83 ec 0c             	sub    $0xc,%esp
  8016ce:	ff 75 18             	pushl  0x18(%ebp)
  8016d1:	83 eb 01             	sub    $0x1,%ebx
  8016d4:	53                   	push   %ebx
  8016d5:	50                   	push   %eax
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8016df:	ff 75 dc             	pushl  -0x24(%ebp)
  8016e2:	ff 75 d8             	pushl  -0x28(%ebp)
  8016e5:	e8 16 0a 00 00       	call   802100 <__udivdi3>
  8016ea:	83 c4 18             	add    $0x18,%esp
  8016ed:	52                   	push   %edx
  8016ee:	50                   	push   %eax
  8016ef:	89 f2                	mov    %esi,%edx
  8016f1:	89 f8                	mov    %edi,%eax
  8016f3:	e8 9e ff ff ff       	call   801696 <printnum>
  8016f8:	83 c4 20             	add    $0x20,%esp
  8016fb:	eb 13                	jmp    801710 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	56                   	push   %esi
  801701:	ff 75 18             	pushl  0x18(%ebp)
  801704:	ff d7                	call   *%edi
  801706:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801709:	83 eb 01             	sub    $0x1,%ebx
  80170c:	85 db                	test   %ebx,%ebx
  80170e:	7f ed                	jg     8016fd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	56                   	push   %esi
  801714:	83 ec 04             	sub    $0x4,%esp
  801717:	ff 75 e4             	pushl  -0x1c(%ebp)
  80171a:	ff 75 e0             	pushl  -0x20(%ebp)
  80171d:	ff 75 dc             	pushl  -0x24(%ebp)
  801720:	ff 75 d8             	pushl  -0x28(%ebp)
  801723:	e8 08 0b 00 00       	call   802230 <__umoddi3>
  801728:	83 c4 14             	add    $0x14,%esp
  80172b:	0f be 80 43 25 80 00 	movsbl 0x802543(%eax),%eax
  801732:	50                   	push   %eax
  801733:	ff d7                	call   *%edi
  801735:	83 c4 10             	add    $0x10,%esp
}
  801738:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80173b:	5b                   	pop    %ebx
  80173c:	5e                   	pop    %esi
  80173d:	5f                   	pop    %edi
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801743:	83 fa 01             	cmp    $0x1,%edx
  801746:	7e 0e                	jle    801756 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801748:	8b 10                	mov    (%eax),%edx
  80174a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80174d:	89 08                	mov    %ecx,(%eax)
  80174f:	8b 02                	mov    (%edx),%eax
  801751:	8b 52 04             	mov    0x4(%edx),%edx
  801754:	eb 22                	jmp    801778 <getuint+0x38>
	else if (lflag)
  801756:	85 d2                	test   %edx,%edx
  801758:	74 10                	je     80176a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80175a:	8b 10                	mov    (%eax),%edx
  80175c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80175f:	89 08                	mov    %ecx,(%eax)
  801761:	8b 02                	mov    (%edx),%eax
  801763:	ba 00 00 00 00       	mov    $0x0,%edx
  801768:	eb 0e                	jmp    801778 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80176a:	8b 10                	mov    (%eax),%edx
  80176c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80176f:	89 08                	mov    %ecx,(%eax)
  801771:	8b 02                	mov    (%edx),%eax
  801773:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801780:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801784:	8b 10                	mov    (%eax),%edx
  801786:	3b 50 04             	cmp    0x4(%eax),%edx
  801789:	73 0a                	jae    801795 <sprintputch+0x1b>
		*b->buf++ = ch;
  80178b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80178e:	89 08                	mov    %ecx,(%eax)
  801790:	8b 45 08             	mov    0x8(%ebp),%eax
  801793:	88 02                	mov    %al,(%edx)
}
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    

00801797 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80179d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017a0:	50                   	push   %eax
  8017a1:	ff 75 10             	pushl  0x10(%ebp)
  8017a4:	ff 75 0c             	pushl  0xc(%ebp)
  8017a7:	ff 75 08             	pushl  0x8(%ebp)
  8017aa:	e8 05 00 00 00       	call   8017b4 <vprintfmt>
	va_end(ap);
  8017af:	83 c4 10             	add    $0x10,%esp
}
  8017b2:	c9                   	leave  
  8017b3:	c3                   	ret    

008017b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	57                   	push   %edi
  8017b8:	56                   	push   %esi
  8017b9:	53                   	push   %ebx
  8017ba:	83 ec 2c             	sub    $0x2c,%esp
  8017bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8017c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017c3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017c6:	eb 12                	jmp    8017da <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	0f 84 90 03 00 00    	je     801b60 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	53                   	push   %ebx
  8017d4:	50                   	push   %eax
  8017d5:	ff d6                	call   *%esi
  8017d7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017da:	83 c7 01             	add    $0x1,%edi
  8017dd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017e1:	83 f8 25             	cmp    $0x25,%eax
  8017e4:	75 e2                	jne    8017c8 <vprintfmt+0x14>
  8017e6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017ea:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8017f1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017f8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8017ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801804:	eb 07                	jmp    80180d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801806:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801809:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180d:	8d 47 01             	lea    0x1(%edi),%eax
  801810:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801813:	0f b6 07             	movzbl (%edi),%eax
  801816:	0f b6 c8             	movzbl %al,%ecx
  801819:	83 e8 23             	sub    $0x23,%eax
  80181c:	3c 55                	cmp    $0x55,%al
  80181e:	0f 87 21 03 00 00    	ja     801b45 <vprintfmt+0x391>
  801824:	0f b6 c0             	movzbl %al,%eax
  801827:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
  80182e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801831:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801835:	eb d6                	jmp    80180d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801837:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80183a:	b8 00 00 00 00       	mov    $0x0,%eax
  80183f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801842:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801845:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801849:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80184c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80184f:	83 fa 09             	cmp    $0x9,%edx
  801852:	77 39                	ja     80188d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801854:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801857:	eb e9                	jmp    801842 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801859:	8b 45 14             	mov    0x14(%ebp),%eax
  80185c:	8d 48 04             	lea    0x4(%eax),%ecx
  80185f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801862:	8b 00                	mov    (%eax),%eax
  801864:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801867:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80186a:	eb 27                	jmp    801893 <vprintfmt+0xdf>
  80186c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80186f:	85 c0                	test   %eax,%eax
  801871:	b9 00 00 00 00       	mov    $0x0,%ecx
  801876:	0f 49 c8             	cmovns %eax,%ecx
  801879:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80187c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80187f:	eb 8c                	jmp    80180d <vprintfmt+0x59>
  801881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801884:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80188b:	eb 80                	jmp    80180d <vprintfmt+0x59>
  80188d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801890:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801893:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801897:	0f 89 70 ff ff ff    	jns    80180d <vprintfmt+0x59>
				width = precision, precision = -1;
  80189d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018aa:	e9 5e ff ff ff       	jmp    80180d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018af:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018b5:	e9 53 ff ff ff       	jmp    80180d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8018bd:	8d 50 04             	lea    0x4(%eax),%edx
  8018c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8018c3:	83 ec 08             	sub    $0x8,%esp
  8018c6:	53                   	push   %ebx
  8018c7:	ff 30                	pushl  (%eax)
  8018c9:	ff d6                	call   *%esi
			break;
  8018cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018d1:	e9 04 ff ff ff       	jmp    8017da <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d9:	8d 50 04             	lea    0x4(%eax),%edx
  8018dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8018df:	8b 00                	mov    (%eax),%eax
  8018e1:	99                   	cltd   
  8018e2:	31 d0                	xor    %edx,%eax
  8018e4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018e6:	83 f8 0f             	cmp    $0xf,%eax
  8018e9:	7f 0b                	jg     8018f6 <vprintfmt+0x142>
  8018eb:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  8018f2:	85 d2                	test   %edx,%edx
  8018f4:	75 18                	jne    80190e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8018f6:	50                   	push   %eax
  8018f7:	68 5b 25 80 00       	push   $0x80255b
  8018fc:	53                   	push   %ebx
  8018fd:	56                   	push   %esi
  8018fe:	e8 94 fe ff ff       	call   801797 <printfmt>
  801903:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801906:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801909:	e9 cc fe ff ff       	jmp    8017da <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80190e:	52                   	push   %edx
  80190f:	68 a1 24 80 00       	push   $0x8024a1
  801914:	53                   	push   %ebx
  801915:	56                   	push   %esi
  801916:	e8 7c fe ff ff       	call   801797 <printfmt>
  80191b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80191e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801921:	e9 b4 fe ff ff       	jmp    8017da <vprintfmt+0x26>
  801926:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801929:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80192c:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80192f:	8b 45 14             	mov    0x14(%ebp),%eax
  801932:	8d 50 04             	lea    0x4(%eax),%edx
  801935:	89 55 14             	mov    %edx,0x14(%ebp)
  801938:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80193a:	85 ff                	test   %edi,%edi
  80193c:	ba 54 25 80 00       	mov    $0x802554,%edx
  801941:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  801944:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801948:	0f 84 92 00 00 00    	je     8019e0 <vprintfmt+0x22c>
  80194e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801952:	0f 8e 96 00 00 00    	jle    8019ee <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801958:	83 ec 08             	sub    $0x8,%esp
  80195b:	51                   	push   %ecx
  80195c:	57                   	push   %edi
  80195d:	e8 86 02 00 00       	call   801be8 <strnlen>
  801962:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801965:	29 c1                	sub    %eax,%ecx
  801967:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80196a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80196d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801971:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801974:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801977:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801979:	eb 0f                	jmp    80198a <vprintfmt+0x1d6>
					putch(padc, putdat);
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	53                   	push   %ebx
  80197f:	ff 75 e0             	pushl  -0x20(%ebp)
  801982:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801984:	83 ef 01             	sub    $0x1,%edi
  801987:	83 c4 10             	add    $0x10,%esp
  80198a:	85 ff                	test   %edi,%edi
  80198c:	7f ed                	jg     80197b <vprintfmt+0x1c7>
  80198e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801991:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801994:	85 c9                	test   %ecx,%ecx
  801996:	b8 00 00 00 00       	mov    $0x0,%eax
  80199b:	0f 49 c1             	cmovns %ecx,%eax
  80199e:	29 c1                	sub    %eax,%ecx
  8019a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8019a3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019a9:	89 cb                	mov    %ecx,%ebx
  8019ab:	eb 4d                	jmp    8019fa <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019b1:	74 1b                	je     8019ce <vprintfmt+0x21a>
  8019b3:	0f be c0             	movsbl %al,%eax
  8019b6:	83 e8 20             	sub    $0x20,%eax
  8019b9:	83 f8 5e             	cmp    $0x5e,%eax
  8019bc:	76 10                	jbe    8019ce <vprintfmt+0x21a>
					putch('?', putdat);
  8019be:	83 ec 08             	sub    $0x8,%esp
  8019c1:	ff 75 0c             	pushl  0xc(%ebp)
  8019c4:	6a 3f                	push   $0x3f
  8019c6:	ff 55 08             	call   *0x8(%ebp)
  8019c9:	83 c4 10             	add    $0x10,%esp
  8019cc:	eb 0d                	jmp    8019db <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8019ce:	83 ec 08             	sub    $0x8,%esp
  8019d1:	ff 75 0c             	pushl  0xc(%ebp)
  8019d4:	52                   	push   %edx
  8019d5:	ff 55 08             	call   *0x8(%ebp)
  8019d8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019db:	83 eb 01             	sub    $0x1,%ebx
  8019de:	eb 1a                	jmp    8019fa <vprintfmt+0x246>
  8019e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8019e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019e9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019ec:	eb 0c                	jmp    8019fa <vprintfmt+0x246>
  8019ee:	89 75 08             	mov    %esi,0x8(%ebp)
  8019f1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019f4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019f7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019fa:	83 c7 01             	add    $0x1,%edi
  8019fd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a01:	0f be d0             	movsbl %al,%edx
  801a04:	85 d2                	test   %edx,%edx
  801a06:	74 23                	je     801a2b <vprintfmt+0x277>
  801a08:	85 f6                	test   %esi,%esi
  801a0a:	78 a1                	js     8019ad <vprintfmt+0x1f9>
  801a0c:	83 ee 01             	sub    $0x1,%esi
  801a0f:	79 9c                	jns    8019ad <vprintfmt+0x1f9>
  801a11:	89 df                	mov    %ebx,%edi
  801a13:	8b 75 08             	mov    0x8(%ebp),%esi
  801a16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a19:	eb 18                	jmp    801a33 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a1b:	83 ec 08             	sub    $0x8,%esp
  801a1e:	53                   	push   %ebx
  801a1f:	6a 20                	push   $0x20
  801a21:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a23:	83 ef 01             	sub    $0x1,%edi
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	eb 08                	jmp    801a33 <vprintfmt+0x27f>
  801a2b:	89 df                	mov    %ebx,%edi
  801a2d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a33:	85 ff                	test   %edi,%edi
  801a35:	7f e4                	jg     801a1b <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a3a:	e9 9b fd ff ff       	jmp    8017da <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a3f:	83 fa 01             	cmp    $0x1,%edx
  801a42:	7e 16                	jle    801a5a <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801a44:	8b 45 14             	mov    0x14(%ebp),%eax
  801a47:	8d 50 08             	lea    0x8(%eax),%edx
  801a4a:	89 55 14             	mov    %edx,0x14(%ebp)
  801a4d:	8b 50 04             	mov    0x4(%eax),%edx
  801a50:	8b 00                	mov    (%eax),%eax
  801a52:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a55:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a58:	eb 32                	jmp    801a8c <vprintfmt+0x2d8>
	else if (lflag)
  801a5a:	85 d2                	test   %edx,%edx
  801a5c:	74 18                	je     801a76 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801a5e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a61:	8d 50 04             	lea    0x4(%eax),%edx
  801a64:	89 55 14             	mov    %edx,0x14(%ebp)
  801a67:	8b 00                	mov    (%eax),%eax
  801a69:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a6c:	89 c1                	mov    %eax,%ecx
  801a6e:	c1 f9 1f             	sar    $0x1f,%ecx
  801a71:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a74:	eb 16                	jmp    801a8c <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801a76:	8b 45 14             	mov    0x14(%ebp),%eax
  801a79:	8d 50 04             	lea    0x4(%eax),%edx
  801a7c:	89 55 14             	mov    %edx,0x14(%ebp)
  801a7f:	8b 00                	mov    (%eax),%eax
  801a81:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a84:	89 c1                	mov    %eax,%ecx
  801a86:	c1 f9 1f             	sar    $0x1f,%ecx
  801a89:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a8f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a92:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a97:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a9b:	79 74                	jns    801b11 <vprintfmt+0x35d>
				putch('-', putdat);
  801a9d:	83 ec 08             	sub    $0x8,%esp
  801aa0:	53                   	push   %ebx
  801aa1:	6a 2d                	push   $0x2d
  801aa3:	ff d6                	call   *%esi
				num = -(long long) num;
  801aa5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801aa8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801aab:	f7 d8                	neg    %eax
  801aad:	83 d2 00             	adc    $0x0,%edx
  801ab0:	f7 da                	neg    %edx
  801ab2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ab5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801aba:	eb 55                	jmp    801b11 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801abc:	8d 45 14             	lea    0x14(%ebp),%eax
  801abf:	e8 7c fc ff ff       	call   801740 <getuint>
			base = 10;
  801ac4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ac9:	eb 46                	jmp    801b11 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801acb:	8d 45 14             	lea    0x14(%ebp),%eax
  801ace:	e8 6d fc ff ff       	call   801740 <getuint>
                        base = 8;
  801ad3:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801ad8:	eb 37                	jmp    801b11 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801ada:	83 ec 08             	sub    $0x8,%esp
  801add:	53                   	push   %ebx
  801ade:	6a 30                	push   $0x30
  801ae0:	ff d6                	call   *%esi
			putch('x', putdat);
  801ae2:	83 c4 08             	add    $0x8,%esp
  801ae5:	53                   	push   %ebx
  801ae6:	6a 78                	push   $0x78
  801ae8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801aea:	8b 45 14             	mov    0x14(%ebp),%eax
  801aed:	8d 50 04             	lea    0x4(%eax),%edx
  801af0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801af3:	8b 00                	mov    (%eax),%eax
  801af5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801afa:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801afd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b02:	eb 0d                	jmp    801b11 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b04:	8d 45 14             	lea    0x14(%ebp),%eax
  801b07:	e8 34 fc ff ff       	call   801740 <getuint>
			base = 16;
  801b0c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b11:	83 ec 0c             	sub    $0xc,%esp
  801b14:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b18:	57                   	push   %edi
  801b19:	ff 75 e0             	pushl  -0x20(%ebp)
  801b1c:	51                   	push   %ecx
  801b1d:	52                   	push   %edx
  801b1e:	50                   	push   %eax
  801b1f:	89 da                	mov    %ebx,%edx
  801b21:	89 f0                	mov    %esi,%eax
  801b23:	e8 6e fb ff ff       	call   801696 <printnum>
			break;
  801b28:	83 c4 20             	add    $0x20,%esp
  801b2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b2e:	e9 a7 fc ff ff       	jmp    8017da <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b33:	83 ec 08             	sub    $0x8,%esp
  801b36:	53                   	push   %ebx
  801b37:	51                   	push   %ecx
  801b38:	ff d6                	call   *%esi
			break;
  801b3a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b40:	e9 95 fc ff ff       	jmp    8017da <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b45:	83 ec 08             	sub    $0x8,%esp
  801b48:	53                   	push   %ebx
  801b49:	6a 25                	push   $0x25
  801b4b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	eb 03                	jmp    801b55 <vprintfmt+0x3a1>
  801b52:	83 ef 01             	sub    $0x1,%edi
  801b55:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b59:	75 f7                	jne    801b52 <vprintfmt+0x39e>
  801b5b:	e9 7a fc ff ff       	jmp    8017da <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5f                   	pop    %edi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    

00801b68 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	83 ec 18             	sub    $0x18,%esp
  801b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b71:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b74:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b77:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b7b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b85:	85 c0                	test   %eax,%eax
  801b87:	74 26                	je     801baf <vsnprintf+0x47>
  801b89:	85 d2                	test   %edx,%edx
  801b8b:	7e 22                	jle    801baf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b8d:	ff 75 14             	pushl  0x14(%ebp)
  801b90:	ff 75 10             	pushl  0x10(%ebp)
  801b93:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b96:	50                   	push   %eax
  801b97:	68 7a 17 80 00       	push   $0x80177a
  801b9c:	e8 13 fc ff ff       	call   8017b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ba1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ba4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801baa:	83 c4 10             	add    $0x10,%esp
  801bad:	eb 05                	jmp    801bb4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801baf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    

00801bb6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bbc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bbf:	50                   	push   %eax
  801bc0:	ff 75 10             	pushl  0x10(%ebp)
  801bc3:	ff 75 0c             	pushl  0xc(%ebp)
  801bc6:	ff 75 08             	pushl  0x8(%ebp)
  801bc9:	e8 9a ff ff ff       	call   801b68 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bce:	c9                   	leave  
  801bcf:	c3                   	ret    

00801bd0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bdb:	eb 03                	jmp    801be0 <strlen+0x10>
		n++;
  801bdd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801be0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801be4:	75 f7                	jne    801bdd <strlen+0xd>
		n++;
	return n;
}
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bee:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bf1:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf6:	eb 03                	jmp    801bfb <strnlen+0x13>
		n++;
  801bf8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bfb:	39 c2                	cmp    %eax,%edx
  801bfd:	74 08                	je     801c07 <strnlen+0x1f>
  801bff:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c03:	75 f3                	jne    801bf8 <strnlen+0x10>
  801c05:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    

00801c09 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	53                   	push   %ebx
  801c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c13:	89 c2                	mov    %eax,%edx
  801c15:	83 c2 01             	add    $0x1,%edx
  801c18:	83 c1 01             	add    $0x1,%ecx
  801c1b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c1f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c22:	84 db                	test   %bl,%bl
  801c24:	75 ef                	jne    801c15 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c26:	5b                   	pop    %ebx
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	53                   	push   %ebx
  801c2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c30:	53                   	push   %ebx
  801c31:	e8 9a ff ff ff       	call   801bd0 <strlen>
  801c36:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c39:	ff 75 0c             	pushl  0xc(%ebp)
  801c3c:	01 d8                	add    %ebx,%eax
  801c3e:	50                   	push   %eax
  801c3f:	e8 c5 ff ff ff       	call   801c09 <strcpy>
	return dst;
}
  801c44:	89 d8                	mov    %ebx,%eax
  801c46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    

00801c4b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	56                   	push   %esi
  801c4f:	53                   	push   %ebx
  801c50:	8b 75 08             	mov    0x8(%ebp),%esi
  801c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c56:	89 f3                	mov    %esi,%ebx
  801c58:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c5b:	89 f2                	mov    %esi,%edx
  801c5d:	eb 0f                	jmp    801c6e <strncpy+0x23>
		*dst++ = *src;
  801c5f:	83 c2 01             	add    $0x1,%edx
  801c62:	0f b6 01             	movzbl (%ecx),%eax
  801c65:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c68:	80 39 01             	cmpb   $0x1,(%ecx)
  801c6b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c6e:	39 da                	cmp    %ebx,%edx
  801c70:	75 ed                	jne    801c5f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c72:	89 f0                	mov    %esi,%eax
  801c74:	5b                   	pop    %ebx
  801c75:	5e                   	pop    %esi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    

00801c78 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	56                   	push   %esi
  801c7c:	53                   	push   %ebx
  801c7d:	8b 75 08             	mov    0x8(%ebp),%esi
  801c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c83:	8b 55 10             	mov    0x10(%ebp),%edx
  801c86:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c88:	85 d2                	test   %edx,%edx
  801c8a:	74 21                	je     801cad <strlcpy+0x35>
  801c8c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c90:	89 f2                	mov    %esi,%edx
  801c92:	eb 09                	jmp    801c9d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c94:	83 c2 01             	add    $0x1,%edx
  801c97:	83 c1 01             	add    $0x1,%ecx
  801c9a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c9d:	39 c2                	cmp    %eax,%edx
  801c9f:	74 09                	je     801caa <strlcpy+0x32>
  801ca1:	0f b6 19             	movzbl (%ecx),%ebx
  801ca4:	84 db                	test   %bl,%bl
  801ca6:	75 ec                	jne    801c94 <strlcpy+0x1c>
  801ca8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801caa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cad:	29 f0                	sub    %esi,%eax
}
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5d                   	pop    %ebp
  801cb2:	c3                   	ret    

00801cb3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cbc:	eb 06                	jmp    801cc4 <strcmp+0x11>
		p++, q++;
  801cbe:	83 c1 01             	add    $0x1,%ecx
  801cc1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801cc4:	0f b6 01             	movzbl (%ecx),%eax
  801cc7:	84 c0                	test   %al,%al
  801cc9:	74 04                	je     801ccf <strcmp+0x1c>
  801ccb:	3a 02                	cmp    (%edx),%al
  801ccd:	74 ef                	je     801cbe <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ccf:	0f b6 c0             	movzbl %al,%eax
  801cd2:	0f b6 12             	movzbl (%edx),%edx
  801cd5:	29 d0                	sub    %edx,%eax
}
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    

00801cd9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	53                   	push   %ebx
  801cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce3:	89 c3                	mov    %eax,%ebx
  801ce5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ce8:	eb 06                	jmp    801cf0 <strncmp+0x17>
		n--, p++, q++;
  801cea:	83 c0 01             	add    $0x1,%eax
  801ced:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cf0:	39 d8                	cmp    %ebx,%eax
  801cf2:	74 15                	je     801d09 <strncmp+0x30>
  801cf4:	0f b6 08             	movzbl (%eax),%ecx
  801cf7:	84 c9                	test   %cl,%cl
  801cf9:	74 04                	je     801cff <strncmp+0x26>
  801cfb:	3a 0a                	cmp    (%edx),%cl
  801cfd:	74 eb                	je     801cea <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cff:	0f b6 00             	movzbl (%eax),%eax
  801d02:	0f b6 12             	movzbl (%edx),%edx
  801d05:	29 d0                	sub    %edx,%eax
  801d07:	eb 05                	jmp    801d0e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d09:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d0e:	5b                   	pop    %ebx
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	8b 45 08             	mov    0x8(%ebp),%eax
  801d17:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d1b:	eb 07                	jmp    801d24 <strchr+0x13>
		if (*s == c)
  801d1d:	38 ca                	cmp    %cl,%dl
  801d1f:	74 0f                	je     801d30 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d21:	83 c0 01             	add    $0x1,%eax
  801d24:	0f b6 10             	movzbl (%eax),%edx
  801d27:	84 d2                	test   %dl,%dl
  801d29:	75 f2                	jne    801d1d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    

00801d32 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	8b 45 08             	mov    0x8(%ebp),%eax
  801d38:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d3c:	eb 03                	jmp    801d41 <strfind+0xf>
  801d3e:	83 c0 01             	add    $0x1,%eax
  801d41:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d44:	84 d2                	test   %dl,%dl
  801d46:	74 04                	je     801d4c <strfind+0x1a>
  801d48:	38 ca                	cmp    %cl,%dl
  801d4a:	75 f2                	jne    801d3e <strfind+0xc>
			break;
	return (char *) s;
}
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d5a:	85 c9                	test   %ecx,%ecx
  801d5c:	74 36                	je     801d94 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d5e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d64:	75 28                	jne    801d8e <memset+0x40>
  801d66:	f6 c1 03             	test   $0x3,%cl
  801d69:	75 23                	jne    801d8e <memset+0x40>
		c &= 0xFF;
  801d6b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d6f:	89 d3                	mov    %edx,%ebx
  801d71:	c1 e3 08             	shl    $0x8,%ebx
  801d74:	89 d6                	mov    %edx,%esi
  801d76:	c1 e6 18             	shl    $0x18,%esi
  801d79:	89 d0                	mov    %edx,%eax
  801d7b:	c1 e0 10             	shl    $0x10,%eax
  801d7e:	09 f0                	or     %esi,%eax
  801d80:	09 c2                	or     %eax,%edx
  801d82:	89 d0                	mov    %edx,%eax
  801d84:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d86:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801d89:	fc                   	cld    
  801d8a:	f3 ab                	rep stos %eax,%es:(%edi)
  801d8c:	eb 06                	jmp    801d94 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d91:	fc                   	cld    
  801d92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d94:	89 f8                	mov    %edi,%eax
  801d96:	5b                   	pop    %ebx
  801d97:	5e                   	pop    %esi
  801d98:	5f                   	pop    %edi
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	57                   	push   %edi
  801d9f:	56                   	push   %esi
  801da0:	8b 45 08             	mov    0x8(%ebp),%eax
  801da3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801da6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801da9:	39 c6                	cmp    %eax,%esi
  801dab:	73 35                	jae    801de2 <memmove+0x47>
  801dad:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801db0:	39 d0                	cmp    %edx,%eax
  801db2:	73 2e                	jae    801de2 <memmove+0x47>
		s += n;
		d += n;
  801db4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801db7:	89 d6                	mov    %edx,%esi
  801db9:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dbb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801dc1:	75 13                	jne    801dd6 <memmove+0x3b>
  801dc3:	f6 c1 03             	test   $0x3,%cl
  801dc6:	75 0e                	jne    801dd6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801dc8:	83 ef 04             	sub    $0x4,%edi
  801dcb:	8d 72 fc             	lea    -0x4(%edx),%esi
  801dce:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801dd1:	fd                   	std    
  801dd2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dd4:	eb 09                	jmp    801ddf <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801dd6:	83 ef 01             	sub    $0x1,%edi
  801dd9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801ddc:	fd                   	std    
  801ddd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801ddf:	fc                   	cld    
  801de0:	eb 1d                	jmp    801dff <memmove+0x64>
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801de6:	f6 c2 03             	test   $0x3,%dl
  801de9:	75 0f                	jne    801dfa <memmove+0x5f>
  801deb:	f6 c1 03             	test   $0x3,%cl
  801dee:	75 0a                	jne    801dfa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801df0:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801df3:	89 c7                	mov    %eax,%edi
  801df5:	fc                   	cld    
  801df6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801df8:	eb 05                	jmp    801dff <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801dfa:	89 c7                	mov    %eax,%edi
  801dfc:	fc                   	cld    
  801dfd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dff:	5e                   	pop    %esi
  801e00:	5f                   	pop    %edi
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    

00801e03 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e06:	ff 75 10             	pushl  0x10(%ebp)
  801e09:	ff 75 0c             	pushl  0xc(%ebp)
  801e0c:	ff 75 08             	pushl  0x8(%ebp)
  801e0f:	e8 87 ff ff ff       	call   801d9b <memmove>
}
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	56                   	push   %esi
  801e1a:	53                   	push   %ebx
  801e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e21:	89 c6                	mov    %eax,%esi
  801e23:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e26:	eb 1a                	jmp    801e42 <memcmp+0x2c>
		if (*s1 != *s2)
  801e28:	0f b6 08             	movzbl (%eax),%ecx
  801e2b:	0f b6 1a             	movzbl (%edx),%ebx
  801e2e:	38 d9                	cmp    %bl,%cl
  801e30:	74 0a                	je     801e3c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e32:	0f b6 c1             	movzbl %cl,%eax
  801e35:	0f b6 db             	movzbl %bl,%ebx
  801e38:	29 d8                	sub    %ebx,%eax
  801e3a:	eb 0f                	jmp    801e4b <memcmp+0x35>
		s1++, s2++;
  801e3c:	83 c0 01             	add    $0x1,%eax
  801e3f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e42:	39 f0                	cmp    %esi,%eax
  801e44:	75 e2                	jne    801e28 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e4b:	5b                   	pop    %ebx
  801e4c:	5e                   	pop    %esi
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	8b 45 08             	mov    0x8(%ebp),%eax
  801e55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801e58:	89 c2                	mov    %eax,%edx
  801e5a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e5d:	eb 07                	jmp    801e66 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e5f:	38 08                	cmp    %cl,(%eax)
  801e61:	74 07                	je     801e6a <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e63:	83 c0 01             	add    $0x1,%eax
  801e66:	39 d0                	cmp    %edx,%eax
  801e68:	72 f5                	jb     801e5f <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    

00801e6c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	57                   	push   %edi
  801e70:	56                   	push   %esi
  801e71:	53                   	push   %ebx
  801e72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e78:	eb 03                	jmp    801e7d <strtol+0x11>
		s++;
  801e7a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e7d:	0f b6 01             	movzbl (%ecx),%eax
  801e80:	3c 09                	cmp    $0x9,%al
  801e82:	74 f6                	je     801e7a <strtol+0xe>
  801e84:	3c 20                	cmp    $0x20,%al
  801e86:	74 f2                	je     801e7a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e88:	3c 2b                	cmp    $0x2b,%al
  801e8a:	75 0a                	jne    801e96 <strtol+0x2a>
		s++;
  801e8c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e8f:	bf 00 00 00 00       	mov    $0x0,%edi
  801e94:	eb 10                	jmp    801ea6 <strtol+0x3a>
  801e96:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e9b:	3c 2d                	cmp    $0x2d,%al
  801e9d:	75 07                	jne    801ea6 <strtol+0x3a>
		s++, neg = 1;
  801e9f:	8d 49 01             	lea    0x1(%ecx),%ecx
  801ea2:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ea6:	85 db                	test   %ebx,%ebx
  801ea8:	0f 94 c0             	sete   %al
  801eab:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801eb1:	75 19                	jne    801ecc <strtol+0x60>
  801eb3:	80 39 30             	cmpb   $0x30,(%ecx)
  801eb6:	75 14                	jne    801ecc <strtol+0x60>
  801eb8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ebc:	0f 85 82 00 00 00    	jne    801f44 <strtol+0xd8>
		s += 2, base = 16;
  801ec2:	83 c1 02             	add    $0x2,%ecx
  801ec5:	bb 10 00 00 00       	mov    $0x10,%ebx
  801eca:	eb 16                	jmp    801ee2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801ecc:	84 c0                	test   %al,%al
  801ece:	74 12                	je     801ee2 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ed0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ed5:	80 39 30             	cmpb   $0x30,(%ecx)
  801ed8:	75 08                	jne    801ee2 <strtol+0x76>
		s++, base = 8;
  801eda:	83 c1 01             	add    $0x1,%ecx
  801edd:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ee2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801eea:	0f b6 11             	movzbl (%ecx),%edx
  801eed:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ef0:	89 f3                	mov    %esi,%ebx
  801ef2:	80 fb 09             	cmp    $0x9,%bl
  801ef5:	77 08                	ja     801eff <strtol+0x93>
			dig = *s - '0';
  801ef7:	0f be d2             	movsbl %dl,%edx
  801efa:	83 ea 30             	sub    $0x30,%edx
  801efd:	eb 22                	jmp    801f21 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  801eff:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f02:	89 f3                	mov    %esi,%ebx
  801f04:	80 fb 19             	cmp    $0x19,%bl
  801f07:	77 08                	ja     801f11 <strtol+0xa5>
			dig = *s - 'a' + 10;
  801f09:	0f be d2             	movsbl %dl,%edx
  801f0c:	83 ea 57             	sub    $0x57,%edx
  801f0f:	eb 10                	jmp    801f21 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  801f11:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f14:	89 f3                	mov    %esi,%ebx
  801f16:	80 fb 19             	cmp    $0x19,%bl
  801f19:	77 16                	ja     801f31 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801f1b:	0f be d2             	movsbl %dl,%edx
  801f1e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f21:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f24:	7d 0f                	jge    801f35 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801f26:	83 c1 01             	add    $0x1,%ecx
  801f29:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f2d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f2f:	eb b9                	jmp    801eea <strtol+0x7e>
  801f31:	89 c2                	mov    %eax,%edx
  801f33:	eb 02                	jmp    801f37 <strtol+0xcb>
  801f35:	89 c2                	mov    %eax,%edx

	if (endptr)
  801f37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f3b:	74 0d                	je     801f4a <strtol+0xde>
		*endptr = (char *) s;
  801f3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f40:	89 0e                	mov    %ecx,(%esi)
  801f42:	eb 06                	jmp    801f4a <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f44:	84 c0                	test   %al,%al
  801f46:	75 92                	jne    801eda <strtol+0x6e>
  801f48:	eb 98                	jmp    801ee2 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f4a:	f7 da                	neg    %edx
  801f4c:	85 ff                	test   %edi,%edi
  801f4e:	0f 45 c2             	cmovne %edx,%eax
}
  801f51:	5b                   	pop    %ebx
  801f52:	5e                   	pop    %esi
  801f53:	5f                   	pop    %edi
  801f54:	5d                   	pop    %ebp
  801f55:	c3                   	ret    

00801f56 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f5c:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801f63:	75 2c                	jne    801f91 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  801f65:	83 ec 04             	sub    $0x4,%esp
  801f68:	6a 07                	push   $0x7
  801f6a:	68 00 f0 bf ee       	push   $0xeebff000
  801f6f:	6a 00                	push   $0x0
  801f71:	e8 fa e1 ff ff       	call   800170 <sys_page_alloc>
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	74 14                	je     801f91 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  801f7d:	83 ec 04             	sub    $0x4,%esp
  801f80:	68 60 28 80 00       	push   $0x802860
  801f85:	6a 21                	push   $0x21
  801f87:	68 c4 28 80 00       	push   $0x8028c4
  801f8c:	e8 18 f6 ff ff       	call   8015a9 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f91:	8b 45 08             	mov    0x8(%ebp),%eax
  801f94:	a3 00 70 80 00       	mov    %eax,0x807000
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801f99:	83 ec 08             	sub    $0x8,%esp
  801f9c:	68 02 04 80 00       	push   $0x800402
  801fa1:	6a 00                	push   $0x0
  801fa3:	e8 13 e3 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801fa8:	83 c4 10             	add    $0x10,%esp
  801fab:	85 c0                	test   %eax,%eax
  801fad:	79 14                	jns    801fc3 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801faf:	83 ec 04             	sub    $0x4,%esp
  801fb2:	68 8c 28 80 00       	push   $0x80288c
  801fb7:	6a 29                	push   $0x29
  801fb9:	68 c4 28 80 00       	push   $0x8028c4
  801fbe:	e8 e6 f5 ff ff       	call   8015a9 <_panic>
}
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	56                   	push   %esi
  801fc9:	53                   	push   %ebx
  801fca:	8b 75 08             	mov    0x8(%ebp),%esi
  801fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fda:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801fdd:	83 ec 0c             	sub    $0xc,%esp
  801fe0:	50                   	push   %eax
  801fe1:	e8 3a e3 ff ff       	call   800320 <sys_ipc_recv>
  801fe6:	83 c4 10             	add    $0x10,%esp
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	79 16                	jns    802003 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801fed:	85 f6                	test   %esi,%esi
  801fef:	74 06                	je     801ff7 <ipc_recv+0x32>
  801ff1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801ff7:	85 db                	test   %ebx,%ebx
  801ff9:	74 2c                	je     802027 <ipc_recv+0x62>
  801ffb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802001:	eb 24                	jmp    802027 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802003:	85 f6                	test   %esi,%esi
  802005:	74 0a                	je     802011 <ipc_recv+0x4c>
  802007:	a1 08 40 80 00       	mov    0x804008,%eax
  80200c:	8b 40 74             	mov    0x74(%eax),%eax
  80200f:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802011:	85 db                	test   %ebx,%ebx
  802013:	74 0a                	je     80201f <ipc_recv+0x5a>
  802015:	a1 08 40 80 00       	mov    0x804008,%eax
  80201a:	8b 40 78             	mov    0x78(%eax),%eax
  80201d:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  80201f:	a1 08 40 80 00       	mov    0x804008,%eax
  802024:	8b 40 70             	mov    0x70(%eax),%eax
}
  802027:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80202a:	5b                   	pop    %ebx
  80202b:	5e                   	pop    %esi
  80202c:	5d                   	pop    %ebp
  80202d:	c3                   	ret    

0080202e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80202e:	55                   	push   %ebp
  80202f:	89 e5                	mov    %esp,%ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 0c             	sub    $0xc,%esp
  802037:	8b 7d 08             	mov    0x8(%ebp),%edi
  80203a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80203d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802040:	85 db                	test   %ebx,%ebx
  802042:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802047:	0f 44 d8             	cmove  %eax,%ebx
  80204a:	eb 1c                	jmp    802068 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  80204c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80204f:	74 12                	je     802063 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  802051:	50                   	push   %eax
  802052:	68 d2 28 80 00       	push   $0x8028d2
  802057:	6a 39                	push   $0x39
  802059:	68 ed 28 80 00       	push   $0x8028ed
  80205e:	e8 46 f5 ff ff       	call   8015a9 <_panic>
                 sys_yield();
  802063:	e8 e9 e0 ff ff       	call   800151 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802068:	ff 75 14             	pushl  0x14(%ebp)
  80206b:	53                   	push   %ebx
  80206c:	56                   	push   %esi
  80206d:	57                   	push   %edi
  80206e:	e8 8a e2 ff ff       	call   8002fd <sys_ipc_try_send>
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	85 c0                	test   %eax,%eax
  802078:	78 d2                	js     80204c <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  80207a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    

00802082 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802088:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80208d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802090:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802096:	8b 52 50             	mov    0x50(%edx),%edx
  802099:	39 ca                	cmp    %ecx,%edx
  80209b:	75 0d                	jne    8020aa <ipc_find_env+0x28>
			return envs[i].env_id;
  80209d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020a0:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8020a5:	8b 40 08             	mov    0x8(%eax),%eax
  8020a8:	eb 0e                	jmp    8020b8 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020aa:	83 c0 01             	add    $0x1,%eax
  8020ad:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020b2:	75 d9                	jne    80208d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020b4:	66 b8 00 00          	mov    $0x0,%ax
}
  8020b8:	5d                   	pop    %ebp
  8020b9:	c3                   	ret    

008020ba <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020ba:	55                   	push   %ebp
  8020bb:	89 e5                	mov    %esp,%ebp
  8020bd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020c0:	89 d0                	mov    %edx,%eax
  8020c2:	c1 e8 16             	shr    $0x16,%eax
  8020c5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020cc:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d1:	f6 c1 01             	test   $0x1,%cl
  8020d4:	74 1d                	je     8020f3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020d6:	c1 ea 0c             	shr    $0xc,%edx
  8020d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020e0:	f6 c2 01             	test   $0x1,%dl
  8020e3:	74 0e                	je     8020f3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020e5:	c1 ea 0c             	shr    $0xc,%edx
  8020e8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020ef:	ef 
  8020f0:	0f b7 c0             	movzwl %ax,%eax
}
  8020f3:	5d                   	pop    %ebp
  8020f4:	c3                   	ret    
  8020f5:	66 90                	xchg   %ax,%ax
  8020f7:	66 90                	xchg   %ax,%ax
  8020f9:	66 90                	xchg   %ax,%ax
  8020fb:	66 90                	xchg   %ax,%ax
  8020fd:	66 90                	xchg   %ax,%ax
  8020ff:	90                   	nop

00802100 <__udivdi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	83 ec 10             	sub    $0x10,%esp
  802106:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80210a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80210e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802112:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802116:	85 d2                	test   %edx,%edx
  802118:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80211c:	89 34 24             	mov    %esi,(%esp)
  80211f:	89 c8                	mov    %ecx,%eax
  802121:	75 35                	jne    802158 <__udivdi3+0x58>
  802123:	39 f1                	cmp    %esi,%ecx
  802125:	0f 87 bd 00 00 00    	ja     8021e8 <__udivdi3+0xe8>
  80212b:	85 c9                	test   %ecx,%ecx
  80212d:	89 cd                	mov    %ecx,%ebp
  80212f:	75 0b                	jne    80213c <__udivdi3+0x3c>
  802131:	b8 01 00 00 00       	mov    $0x1,%eax
  802136:	31 d2                	xor    %edx,%edx
  802138:	f7 f1                	div    %ecx
  80213a:	89 c5                	mov    %eax,%ebp
  80213c:	89 f0                	mov    %esi,%eax
  80213e:	31 d2                	xor    %edx,%edx
  802140:	f7 f5                	div    %ebp
  802142:	89 c6                	mov    %eax,%esi
  802144:	89 f8                	mov    %edi,%eax
  802146:	f7 f5                	div    %ebp
  802148:	89 f2                	mov    %esi,%edx
  80214a:	83 c4 10             	add    $0x10,%esp
  80214d:	5e                   	pop    %esi
  80214e:	5f                   	pop    %edi
  80214f:	5d                   	pop    %ebp
  802150:	c3                   	ret    
  802151:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802158:	3b 14 24             	cmp    (%esp),%edx
  80215b:	77 7b                	ja     8021d8 <__udivdi3+0xd8>
  80215d:	0f bd f2             	bsr    %edx,%esi
  802160:	83 f6 1f             	xor    $0x1f,%esi
  802163:	0f 84 97 00 00 00    	je     802200 <__udivdi3+0x100>
  802169:	bd 20 00 00 00       	mov    $0x20,%ebp
  80216e:	89 d7                	mov    %edx,%edi
  802170:	89 f1                	mov    %esi,%ecx
  802172:	29 f5                	sub    %esi,%ebp
  802174:	d3 e7                	shl    %cl,%edi
  802176:	89 c2                	mov    %eax,%edx
  802178:	89 e9                	mov    %ebp,%ecx
  80217a:	d3 ea                	shr    %cl,%edx
  80217c:	89 f1                	mov    %esi,%ecx
  80217e:	09 fa                	or     %edi,%edx
  802180:	8b 3c 24             	mov    (%esp),%edi
  802183:	d3 e0                	shl    %cl,%eax
  802185:	89 54 24 08          	mov    %edx,0x8(%esp)
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80218f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802193:	89 fa                	mov    %edi,%edx
  802195:	d3 ea                	shr    %cl,%edx
  802197:	89 f1                	mov    %esi,%ecx
  802199:	d3 e7                	shl    %cl,%edi
  80219b:	89 e9                	mov    %ebp,%ecx
  80219d:	d3 e8                	shr    %cl,%eax
  80219f:	09 c7                	or     %eax,%edi
  8021a1:	89 f8                	mov    %edi,%eax
  8021a3:	f7 74 24 08          	divl   0x8(%esp)
  8021a7:	89 d5                	mov    %edx,%ebp
  8021a9:	89 c7                	mov    %eax,%edi
  8021ab:	f7 64 24 0c          	mull   0xc(%esp)
  8021af:	39 d5                	cmp    %edx,%ebp
  8021b1:	89 14 24             	mov    %edx,(%esp)
  8021b4:	72 11                	jb     8021c7 <__udivdi3+0xc7>
  8021b6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021ba:	89 f1                	mov    %esi,%ecx
  8021bc:	d3 e2                	shl    %cl,%edx
  8021be:	39 c2                	cmp    %eax,%edx
  8021c0:	73 5e                	jae    802220 <__udivdi3+0x120>
  8021c2:	3b 2c 24             	cmp    (%esp),%ebp
  8021c5:	75 59                	jne    802220 <__udivdi3+0x120>
  8021c7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8021ca:	31 f6                	xor    %esi,%esi
  8021cc:	89 f2                	mov    %esi,%edx
  8021ce:	83 c4 10             	add    $0x10,%esp
  8021d1:	5e                   	pop    %esi
  8021d2:	5f                   	pop    %edi
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    
  8021d5:	8d 76 00             	lea    0x0(%esi),%esi
  8021d8:	31 f6                	xor    %esi,%esi
  8021da:	31 c0                	xor    %eax,%eax
  8021dc:	89 f2                	mov    %esi,%edx
  8021de:	83 c4 10             	add    $0x10,%esp
  8021e1:	5e                   	pop    %esi
  8021e2:	5f                   	pop    %edi
  8021e3:	5d                   	pop    %ebp
  8021e4:	c3                   	ret    
  8021e5:	8d 76 00             	lea    0x0(%esi),%esi
  8021e8:	89 f2                	mov    %esi,%edx
  8021ea:	31 f6                	xor    %esi,%esi
  8021ec:	89 f8                	mov    %edi,%eax
  8021ee:	f7 f1                	div    %ecx
  8021f0:	89 f2                	mov    %esi,%edx
  8021f2:	83 c4 10             	add    $0x10,%esp
  8021f5:	5e                   	pop    %esi
  8021f6:	5f                   	pop    %edi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802204:	76 0b                	jbe    802211 <__udivdi3+0x111>
  802206:	31 c0                	xor    %eax,%eax
  802208:	3b 14 24             	cmp    (%esp),%edx
  80220b:	0f 83 37 ff ff ff    	jae    802148 <__udivdi3+0x48>
  802211:	b8 01 00 00 00       	mov    $0x1,%eax
  802216:	e9 2d ff ff ff       	jmp    802148 <__udivdi3+0x48>
  80221b:	90                   	nop
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 f8                	mov    %edi,%eax
  802222:	31 f6                	xor    %esi,%esi
  802224:	e9 1f ff ff ff       	jmp    802148 <__udivdi3+0x48>
  802229:	66 90                	xchg   %ax,%ax
  80222b:	66 90                	xchg   %ax,%ax
  80222d:	66 90                	xchg   %ax,%ax
  80222f:	90                   	nop

00802230 <__umoddi3>:
  802230:	55                   	push   %ebp
  802231:	57                   	push   %edi
  802232:	56                   	push   %esi
  802233:	83 ec 20             	sub    $0x20,%esp
  802236:	8b 44 24 34          	mov    0x34(%esp),%eax
  80223a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80223e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802242:	89 c6                	mov    %eax,%esi
  802244:	89 44 24 10          	mov    %eax,0x10(%esp)
  802248:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80224c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802250:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802254:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802258:	89 74 24 18          	mov    %esi,0x18(%esp)
  80225c:	85 c0                	test   %eax,%eax
  80225e:	89 c2                	mov    %eax,%edx
  802260:	75 1e                	jne    802280 <__umoddi3+0x50>
  802262:	39 f7                	cmp    %esi,%edi
  802264:	76 52                	jbe    8022b8 <__umoddi3+0x88>
  802266:	89 c8                	mov    %ecx,%eax
  802268:	89 f2                	mov    %esi,%edx
  80226a:	f7 f7                	div    %edi
  80226c:	89 d0                	mov    %edx,%eax
  80226e:	31 d2                	xor    %edx,%edx
  802270:	83 c4 20             	add    $0x20,%esp
  802273:	5e                   	pop    %esi
  802274:	5f                   	pop    %edi
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    
  802277:	89 f6                	mov    %esi,%esi
  802279:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802280:	39 f0                	cmp    %esi,%eax
  802282:	77 5c                	ja     8022e0 <__umoddi3+0xb0>
  802284:	0f bd e8             	bsr    %eax,%ebp
  802287:	83 f5 1f             	xor    $0x1f,%ebp
  80228a:	75 64                	jne    8022f0 <__umoddi3+0xc0>
  80228c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802290:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802294:	0f 86 f6 00 00 00    	jbe    802390 <__umoddi3+0x160>
  80229a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80229e:	0f 82 ec 00 00 00    	jb     802390 <__umoddi3+0x160>
  8022a4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022a8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8022ac:	83 c4 20             	add    $0x20,%esp
  8022af:	5e                   	pop    %esi
  8022b0:	5f                   	pop    %edi
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    
  8022b3:	90                   	nop
  8022b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b8:	85 ff                	test   %edi,%edi
  8022ba:	89 fd                	mov    %edi,%ebp
  8022bc:	75 0b                	jne    8022c9 <__umoddi3+0x99>
  8022be:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c3:	31 d2                	xor    %edx,%edx
  8022c5:	f7 f7                	div    %edi
  8022c7:	89 c5                	mov    %eax,%ebp
  8022c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8022cd:	31 d2                	xor    %edx,%edx
  8022cf:	f7 f5                	div    %ebp
  8022d1:	89 c8                	mov    %ecx,%eax
  8022d3:	f7 f5                	div    %ebp
  8022d5:	eb 95                	jmp    80226c <__umoddi3+0x3c>
  8022d7:	89 f6                	mov    %esi,%esi
  8022d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	83 c4 20             	add    $0x20,%esp
  8022e7:	5e                   	pop    %esi
  8022e8:	5f                   	pop    %edi
  8022e9:	5d                   	pop    %ebp
  8022ea:	c3                   	ret    
  8022eb:	90                   	nop
  8022ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	b8 20 00 00 00       	mov    $0x20,%eax
  8022f5:	89 e9                	mov    %ebp,%ecx
  8022f7:	29 e8                	sub    %ebp,%eax
  8022f9:	d3 e2                	shl    %cl,%edx
  8022fb:	89 c7                	mov    %eax,%edi
  8022fd:	89 44 24 18          	mov    %eax,0x18(%esp)
  802301:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802305:	89 f9                	mov    %edi,%ecx
  802307:	d3 e8                	shr    %cl,%eax
  802309:	89 c1                	mov    %eax,%ecx
  80230b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80230f:	09 d1                	or     %edx,%ecx
  802311:	89 fa                	mov    %edi,%edx
  802313:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802317:	89 e9                	mov    %ebp,%ecx
  802319:	d3 e0                	shl    %cl,%eax
  80231b:	89 f9                	mov    %edi,%ecx
  80231d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802321:	89 f0                	mov    %esi,%eax
  802323:	d3 e8                	shr    %cl,%eax
  802325:	89 e9                	mov    %ebp,%ecx
  802327:	89 c7                	mov    %eax,%edi
  802329:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80232d:	d3 e6                	shl    %cl,%esi
  80232f:	89 d1                	mov    %edx,%ecx
  802331:	89 fa                	mov    %edi,%edx
  802333:	d3 e8                	shr    %cl,%eax
  802335:	89 e9                	mov    %ebp,%ecx
  802337:	09 f0                	or     %esi,%eax
  802339:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80233d:	f7 74 24 10          	divl   0x10(%esp)
  802341:	d3 e6                	shl    %cl,%esi
  802343:	89 d1                	mov    %edx,%ecx
  802345:	f7 64 24 0c          	mull   0xc(%esp)
  802349:	39 d1                	cmp    %edx,%ecx
  80234b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80234f:	89 d7                	mov    %edx,%edi
  802351:	89 c6                	mov    %eax,%esi
  802353:	72 0a                	jb     80235f <__umoddi3+0x12f>
  802355:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802359:	73 10                	jae    80236b <__umoddi3+0x13b>
  80235b:	39 d1                	cmp    %edx,%ecx
  80235d:	75 0c                	jne    80236b <__umoddi3+0x13b>
  80235f:	89 d7                	mov    %edx,%edi
  802361:	89 c6                	mov    %eax,%esi
  802363:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802367:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80236b:	89 ca                	mov    %ecx,%edx
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802373:	29 f0                	sub    %esi,%eax
  802375:	19 fa                	sbb    %edi,%edx
  802377:	d3 e8                	shr    %cl,%eax
  802379:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80237e:	89 d7                	mov    %edx,%edi
  802380:	d3 e7                	shl    %cl,%edi
  802382:	89 e9                	mov    %ebp,%ecx
  802384:	09 f8                	or     %edi,%eax
  802386:	d3 ea                	shr    %cl,%edx
  802388:	83 c4 20             	add    $0x20,%esp
  80238b:	5e                   	pop    %esi
  80238c:	5f                   	pop    %edi
  80238d:	5d                   	pop    %ebp
  80238e:	c3                   	ret    
  80238f:	90                   	nop
  802390:	8b 74 24 10          	mov    0x10(%esp),%esi
  802394:	29 f9                	sub    %edi,%ecx
  802396:	19 c6                	sbb    %eax,%esi
  802398:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80239c:	89 74 24 18          	mov    %esi,0x18(%esp)
  8023a0:	e9 ff fe ff ff       	jmp    8022a4 <__umoddi3+0x74>
