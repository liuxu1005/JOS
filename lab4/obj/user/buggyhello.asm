
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 5d 00 00 00       	call   80009f <sys_cputs>
  800042:	83 c4 10             	add    $0x10,%esp
}
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800052:	e8 c6 00 00 00       	call   80011d <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
  800083:	83 c4 10             	add    $0x10,%esp
}
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800093:	6a 00                	push   $0x0
  800095:	e8 42 00 00 00       	call   8000dc <sys_env_destroy>
  80009a:	83 c4 10             	add    $0x10,%esp
}
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	89 c3                	mov    %eax,%ebx
  8000b2:	89 c7                	mov    %eax,%edi
  8000b4:	89 c6                	mov    %eax,%esi
  8000b6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b8:	5b                   	pop    %ebx
  8000b9:	5e                   	pop    %esi
  8000ba:	5f                   	pop    %edi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cd:	89 d1                	mov    %edx,%ecx
  8000cf:	89 d3                	mov    %edx,%ebx
  8000d1:	89 d7                	mov    %edx,%edi
  8000d3:	89 d6                	mov    %edx,%esi
  8000d5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
  8000e2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ea:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f2:	89 cb                	mov    %ecx,%ebx
  8000f4:	89 cf                	mov    %ecx,%edi
  8000f6:	89 ce                	mov    %ecx,%esi
  8000f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	7e 17                	jle    800115 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fe:	83 ec 0c             	sub    $0xc,%esp
  800101:	50                   	push   %eax
  800102:	6a 03                	push   $0x3
  800104:	68 8a 0f 80 00       	push   $0x800f8a
  800109:	6a 23                	push   $0x23
  80010b:	68 a7 0f 80 00       	push   $0x800fa7
  800110:	e8 f5 01 00 00       	call   80030a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800123:	ba 00 00 00 00       	mov    $0x0,%edx
  800128:	b8 02 00 00 00       	mov    $0x2,%eax
  80012d:	89 d1                	mov    %edx,%ecx
  80012f:	89 d3                	mov    %edx,%ebx
  800131:	89 d7                	mov    %edx,%edi
  800133:	89 d6                	mov    %edx,%esi
  800135:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <sys_yield>:

void
sys_yield(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014c:	89 d1                	mov    %edx,%ecx
  80014e:	89 d3                	mov    %edx,%ebx
  800150:	89 d7                	mov    %edx,%edi
  800152:	89 d6                	mov    %edx,%esi
  800154:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800164:	be 00 00 00 00       	mov    $0x0,%esi
  800169:	b8 04 00 00 00       	mov    $0x4,%eax
  80016e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800177:	89 f7                	mov    %esi,%edi
  800179:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017b:	85 c0                	test   %eax,%eax
  80017d:	7e 17                	jle    800196 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	50                   	push   %eax
  800183:	6a 04                	push   $0x4
  800185:	68 8a 0f 80 00       	push   $0x800f8a
  80018a:	6a 23                	push   $0x23
  80018c:	68 a7 0f 80 00       	push   $0x800fa7
  800191:	e8 74 01 00 00       	call   80030a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	57                   	push   %edi
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001af:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b8:	8b 75 18             	mov    0x18(%ebp),%esi
  8001bb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	7e 17                	jle    8001d8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c1:	83 ec 0c             	sub    $0xc,%esp
  8001c4:	50                   	push   %eax
  8001c5:	6a 05                	push   $0x5
  8001c7:	68 8a 0f 80 00       	push   $0x800f8a
  8001cc:	6a 23                	push   $0x23
  8001ce:	68 a7 0f 80 00       	push   $0x800fa7
  8001d3:	e8 32 01 00 00       	call   80030a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5f                   	pop    %edi
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f9:	89 df                	mov    %ebx,%edi
  8001fb:	89 de                	mov    %ebx,%esi
  8001fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ff:	85 c0                	test   %eax,%eax
  800201:	7e 17                	jle    80021a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800203:	83 ec 0c             	sub    $0xc,%esp
  800206:	50                   	push   %eax
  800207:	6a 06                	push   $0x6
  800209:	68 8a 0f 80 00       	push   $0x800f8a
  80020e:	6a 23                	push   $0x23
  800210:	68 a7 0f 80 00       	push   $0x800fa7
  800215:	e8 f0 00 00 00       	call   80030a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5f                   	pop    %edi
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    

00800222 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	57                   	push   %edi
  800226:	56                   	push   %esi
  800227:	53                   	push   %ebx
  800228:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800230:	b8 08 00 00 00       	mov    $0x8,%eax
  800235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	89 df                	mov    %ebx,%edi
  80023d:	89 de                	mov    %ebx,%esi
  80023f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	7e 17                	jle    80025c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	50                   	push   %eax
  800249:	6a 08                	push   $0x8
  80024b:	68 8a 0f 80 00       	push   $0x800f8a
  800250:	6a 23                	push   $0x23
  800252:	68 a7 0f 80 00       	push   $0x800fa7
  800257:	e8 ae 00 00 00       	call   80030a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	5f                   	pop    %edi
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    

00800264 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800272:	b8 09 00 00 00       	mov    $0x9,%eax
  800277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027a:	8b 55 08             	mov    0x8(%ebp),%edx
  80027d:	89 df                	mov    %ebx,%edi
  80027f:	89 de                	mov    %ebx,%esi
  800281:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800283:	85 c0                	test   %eax,%eax
  800285:	7e 17                	jle    80029e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	50                   	push   %eax
  80028b:	6a 09                	push   $0x9
  80028d:	68 8a 0f 80 00       	push   $0x800f8a
  800292:	6a 23                	push   $0x23
  800294:	68 a7 0f 80 00       	push   $0x800fa7
  800299:	e8 6c 00 00 00       	call   80030a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80029e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	57                   	push   %edi
  8002aa:	56                   	push   %esi
  8002ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ac:	be 00 00 00 00       	mov    $0x0,%esi
  8002b1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	57                   	push   %edi
  8002cd:	56                   	push   %esi
  8002ce:	53                   	push   %ebx
  8002cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	89 cb                	mov    %ecx,%ebx
  8002e1:	89 cf                	mov    %ecx,%edi
  8002e3:	89 ce                	mov    %ecx,%esi
  8002e5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	7e 17                	jle    800302 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002eb:	83 ec 0c             	sub    $0xc,%esp
  8002ee:	50                   	push   %eax
  8002ef:	6a 0c                	push   $0xc
  8002f1:	68 8a 0f 80 00       	push   $0x800f8a
  8002f6:	6a 23                	push   $0x23
  8002f8:	68 a7 0f 80 00       	push   $0x800fa7
  8002fd:	e8 08 00 00 00       	call   80030a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800302:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	56                   	push   %esi
  80030e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80030f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800312:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800318:	e8 00 fe ff ff       	call   80011d <sys_getenvid>
  80031d:	83 ec 0c             	sub    $0xc,%esp
  800320:	ff 75 0c             	pushl  0xc(%ebp)
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	56                   	push   %esi
  800327:	50                   	push   %eax
  800328:	68 b8 0f 80 00       	push   $0x800fb8
  80032d:	e8 b1 00 00 00       	call   8003e3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800332:	83 c4 18             	add    $0x18,%esp
  800335:	53                   	push   %ebx
  800336:	ff 75 10             	pushl  0x10(%ebp)
  800339:	e8 54 00 00 00       	call   800392 <vcprintf>
	cprintf("\n");
  80033e:	c7 04 24 dc 0f 80 00 	movl   $0x800fdc,(%esp)
  800345:	e8 99 00 00 00       	call   8003e3 <cprintf>
  80034a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80034d:	cc                   	int3   
  80034e:	eb fd                	jmp    80034d <_panic+0x43>

00800350 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	53                   	push   %ebx
  800354:	83 ec 04             	sub    $0x4,%esp
  800357:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035a:	8b 13                	mov    (%ebx),%edx
  80035c:	8d 42 01             	lea    0x1(%edx),%eax
  80035f:	89 03                	mov    %eax,(%ebx)
  800361:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800364:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800368:	3d ff 00 00 00       	cmp    $0xff,%eax
  80036d:	75 1a                	jne    800389 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	68 ff 00 00 00       	push   $0xff
  800377:	8d 43 08             	lea    0x8(%ebx),%eax
  80037a:	50                   	push   %eax
  80037b:	e8 1f fd ff ff       	call   80009f <sys_cputs>
		b->idx = 0;
  800380:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800386:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800389:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80038d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800390:	c9                   	leave  
  800391:	c3                   	ret    

00800392 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80039b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a2:	00 00 00 
	b.cnt = 0;
  8003a5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ac:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003af:	ff 75 0c             	pushl  0xc(%ebp)
  8003b2:	ff 75 08             	pushl  0x8(%ebp)
  8003b5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003bb:	50                   	push   %eax
  8003bc:	68 50 03 80 00       	push   $0x800350
  8003c1:	e8 4f 01 00 00       	call   800515 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c6:	83 c4 08             	add    $0x8,%esp
  8003c9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003cf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	e8 c4 fc ff ff       	call   80009f <sys_cputs>

	return b.cnt;
}
  8003db:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    

008003e3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ec:	50                   	push   %eax
  8003ed:	ff 75 08             	pushl  0x8(%ebp)
  8003f0:	e8 9d ff ff ff       	call   800392 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f5:	c9                   	leave  
  8003f6:	c3                   	ret    

008003f7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	57                   	push   %edi
  8003fb:	56                   	push   %esi
  8003fc:	53                   	push   %ebx
  8003fd:	83 ec 1c             	sub    $0x1c,%esp
  800400:	89 c7                	mov    %eax,%edi
  800402:	89 d6                	mov    %edx,%esi
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040a:	89 d1                	mov    %edx,%ecx
  80040c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800412:	8b 45 10             	mov    0x10(%ebp),%eax
  800415:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800422:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800425:	72 05                	jb     80042c <printnum+0x35>
  800427:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80042a:	77 3e                	ja     80046a <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042c:	83 ec 0c             	sub    $0xc,%esp
  80042f:	ff 75 18             	pushl  0x18(%ebp)
  800432:	83 eb 01             	sub    $0x1,%ebx
  800435:	53                   	push   %ebx
  800436:	50                   	push   %eax
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80043d:	ff 75 e0             	pushl  -0x20(%ebp)
  800440:	ff 75 dc             	pushl  -0x24(%ebp)
  800443:	ff 75 d8             	pushl  -0x28(%ebp)
  800446:	e8 75 08 00 00       	call   800cc0 <__udivdi3>
  80044b:	83 c4 18             	add    $0x18,%esp
  80044e:	52                   	push   %edx
  80044f:	50                   	push   %eax
  800450:	89 f2                	mov    %esi,%edx
  800452:	89 f8                	mov    %edi,%eax
  800454:	e8 9e ff ff ff       	call   8003f7 <printnum>
  800459:	83 c4 20             	add    $0x20,%esp
  80045c:	eb 13                	jmp    800471 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	56                   	push   %esi
  800462:	ff 75 18             	pushl  0x18(%ebp)
  800465:	ff d7                	call   *%edi
  800467:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80046a:	83 eb 01             	sub    $0x1,%ebx
  80046d:	85 db                	test   %ebx,%ebx
  80046f:	7f ed                	jg     80045e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	56                   	push   %esi
  800475:	83 ec 04             	sub    $0x4,%esp
  800478:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047b:	ff 75 e0             	pushl  -0x20(%ebp)
  80047e:	ff 75 dc             	pushl  -0x24(%ebp)
  800481:	ff 75 d8             	pushl  -0x28(%ebp)
  800484:	e8 67 09 00 00       	call   800df0 <__umoddi3>
  800489:	83 c4 14             	add    $0x14,%esp
  80048c:	0f be 80 de 0f 80 00 	movsbl 0x800fde(%eax),%eax
  800493:	50                   	push   %eax
  800494:	ff d7                	call   *%edi
  800496:	83 c4 10             	add    $0x10,%esp
}
  800499:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049c:	5b                   	pop    %ebx
  80049d:	5e                   	pop    %esi
  80049e:	5f                   	pop    %edi
  80049f:	5d                   	pop    %ebp
  8004a0:	c3                   	ret    

008004a1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a1:	55                   	push   %ebp
  8004a2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a4:	83 fa 01             	cmp    $0x1,%edx
  8004a7:	7e 0e                	jle    8004b7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a9:	8b 10                	mov    (%eax),%edx
  8004ab:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ae:	89 08                	mov    %ecx,(%eax)
  8004b0:	8b 02                	mov    (%edx),%eax
  8004b2:	8b 52 04             	mov    0x4(%edx),%edx
  8004b5:	eb 22                	jmp    8004d9 <getuint+0x38>
	else if (lflag)
  8004b7:	85 d2                	test   %edx,%edx
  8004b9:	74 10                	je     8004cb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004bb:	8b 10                	mov    (%eax),%edx
  8004bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c0:	89 08                	mov    %ecx,(%eax)
  8004c2:	8b 02                	mov    (%edx),%eax
  8004c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c9:	eb 0e                	jmp    8004d9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004cb:	8b 10                	mov    (%eax),%edx
  8004cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d0:	89 08                	mov    %ecx,(%eax)
  8004d2:	8b 02                	mov    (%edx),%eax
  8004d4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d9:	5d                   	pop    %ebp
  8004da:	c3                   	ret    

008004db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e5:	8b 10                	mov    (%eax),%edx
  8004e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ea:	73 0a                	jae    8004f6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ef:	89 08                	mov    %ecx,(%eax)
  8004f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f4:	88 02                	mov    %al,(%edx)
}
  8004f6:	5d                   	pop    %ebp
  8004f7:	c3                   	ret    

008004f8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800501:	50                   	push   %eax
  800502:	ff 75 10             	pushl  0x10(%ebp)
  800505:	ff 75 0c             	pushl  0xc(%ebp)
  800508:	ff 75 08             	pushl  0x8(%ebp)
  80050b:	e8 05 00 00 00       	call   800515 <vprintfmt>
	va_end(ap);
  800510:	83 c4 10             	add    $0x10,%esp
}
  800513:	c9                   	leave  
  800514:	c3                   	ret    

00800515 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800515:	55                   	push   %ebp
  800516:	89 e5                	mov    %esp,%ebp
  800518:	57                   	push   %edi
  800519:	56                   	push   %esi
  80051a:	53                   	push   %ebx
  80051b:	83 ec 2c             	sub    $0x2c,%esp
  80051e:	8b 75 08             	mov    0x8(%ebp),%esi
  800521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800524:	8b 7d 10             	mov    0x10(%ebp),%edi
  800527:	eb 12                	jmp    80053b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800529:	85 c0                	test   %eax,%eax
  80052b:	0f 84 90 03 00 00    	je     8008c1 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	53                   	push   %ebx
  800535:	50                   	push   %eax
  800536:	ff d6                	call   *%esi
  800538:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80053b:	83 c7 01             	add    $0x1,%edi
  80053e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800542:	83 f8 25             	cmp    $0x25,%eax
  800545:	75 e2                	jne    800529 <vprintfmt+0x14>
  800547:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80054b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800552:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800559:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800560:	ba 00 00 00 00       	mov    $0x0,%edx
  800565:	eb 07                	jmp    80056e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80056a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8d 47 01             	lea    0x1(%edi),%eax
  800571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800574:	0f b6 07             	movzbl (%edi),%eax
  800577:	0f b6 c8             	movzbl %al,%ecx
  80057a:	83 e8 23             	sub    $0x23,%eax
  80057d:	3c 55                	cmp    $0x55,%al
  80057f:	0f 87 21 03 00 00    	ja     8008a6 <vprintfmt+0x391>
  800585:	0f b6 c0             	movzbl %al,%eax
  800588:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800592:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800596:	eb d6                	jmp    80056e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059b:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005aa:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005ad:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005b0:	83 fa 09             	cmp    $0x9,%edx
  8005b3:	77 39                	ja     8005ee <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005b8:	eb e9                	jmp    8005a3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005cb:	eb 27                	jmp    8005f4 <vprintfmt+0xdf>
  8005cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d7:	0f 49 c8             	cmovns %eax,%ecx
  8005da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e0:	eb 8c                	jmp    80056e <vprintfmt+0x59>
  8005e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ec:	eb 80                	jmp    80056e <vprintfmt+0x59>
  8005ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f8:	0f 89 70 ff ff ff    	jns    80056e <vprintfmt+0x59>
				width = precision, precision = -1;
  8005fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800601:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800604:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80060b:	e9 5e ff ff ff       	jmp    80056e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800610:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800616:	e9 53 ff ff ff       	jmp    80056e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	ff 30                	pushl  (%eax)
  80062a:	ff d6                	call   *%esi
			break;
  80062c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800632:	e9 04 ff ff ff       	jmp    80053b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8d 50 04             	lea    0x4(%eax),%edx
  80063d:	89 55 14             	mov    %edx,0x14(%ebp)
  800640:	8b 00                	mov    (%eax),%eax
  800642:	99                   	cltd   
  800643:	31 d0                	xor    %edx,%eax
  800645:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800647:	83 f8 09             	cmp    $0x9,%eax
  80064a:	7f 0b                	jg     800657 <vprintfmt+0x142>
  80064c:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  800653:	85 d2                	test   %edx,%edx
  800655:	75 18                	jne    80066f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800657:	50                   	push   %eax
  800658:	68 f6 0f 80 00       	push   $0x800ff6
  80065d:	53                   	push   %ebx
  80065e:	56                   	push   %esi
  80065f:	e8 94 fe ff ff       	call   8004f8 <printfmt>
  800664:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80066a:	e9 cc fe ff ff       	jmp    80053b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80066f:	52                   	push   %edx
  800670:	68 ff 0f 80 00       	push   $0x800fff
  800675:	53                   	push   %ebx
  800676:	56                   	push   %esi
  800677:	e8 7c fe ff ff       	call   8004f8 <printfmt>
  80067c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800682:	e9 b4 fe ff ff       	jmp    80053b <vprintfmt+0x26>
  800687:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80068a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80068d:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 50 04             	lea    0x4(%eax),%edx
  800696:	89 55 14             	mov    %edx,0x14(%ebp)
  800699:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069b:	85 ff                	test   %edi,%edi
  80069d:	ba ef 0f 80 00       	mov    $0x800fef,%edx
  8006a2:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8006a5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006a9:	0f 84 92 00 00 00    	je     800741 <vprintfmt+0x22c>
  8006af:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006b3:	0f 8e 96 00 00 00    	jle    80074f <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	51                   	push   %ecx
  8006bd:	57                   	push   %edi
  8006be:	e8 86 02 00 00       	call   800949 <strnlen>
  8006c3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006c6:	29 c1                	sub    %eax,%ecx
  8006c8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006cb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ce:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006d8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006da:	eb 0f                	jmp    8006eb <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006dc:	83 ec 08             	sub    $0x8,%esp
  8006df:	53                   	push   %ebx
  8006e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e5:	83 ef 01             	sub    $0x1,%edi
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	85 ff                	test   %edi,%edi
  8006ed:	7f ed                	jg     8006dc <vprintfmt+0x1c7>
  8006ef:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006f5:	85 c9                	test   %ecx,%ecx
  8006f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fc:	0f 49 c1             	cmovns %ecx,%eax
  8006ff:	29 c1                	sub    %eax,%ecx
  800701:	89 75 08             	mov    %esi,0x8(%ebp)
  800704:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800707:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070a:	89 cb                	mov    %ecx,%ebx
  80070c:	eb 4d                	jmp    80075b <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80070e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800712:	74 1b                	je     80072f <vprintfmt+0x21a>
  800714:	0f be c0             	movsbl %al,%eax
  800717:	83 e8 20             	sub    $0x20,%eax
  80071a:	83 f8 5e             	cmp    $0x5e,%eax
  80071d:	76 10                	jbe    80072f <vprintfmt+0x21a>
					putch('?', putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	ff 75 0c             	pushl  0xc(%ebp)
  800725:	6a 3f                	push   $0x3f
  800727:	ff 55 08             	call   *0x8(%ebp)
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	eb 0d                	jmp    80073c <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	ff 75 0c             	pushl  0xc(%ebp)
  800735:	52                   	push   %edx
  800736:	ff 55 08             	call   *0x8(%ebp)
  800739:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073c:	83 eb 01             	sub    $0x1,%ebx
  80073f:	eb 1a                	jmp    80075b <vprintfmt+0x246>
  800741:	89 75 08             	mov    %esi,0x8(%ebp)
  800744:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800747:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80074d:	eb 0c                	jmp    80075b <vprintfmt+0x246>
  80074f:	89 75 08             	mov    %esi,0x8(%ebp)
  800752:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800755:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800758:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80075b:	83 c7 01             	add    $0x1,%edi
  80075e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800762:	0f be d0             	movsbl %al,%edx
  800765:	85 d2                	test   %edx,%edx
  800767:	74 23                	je     80078c <vprintfmt+0x277>
  800769:	85 f6                	test   %esi,%esi
  80076b:	78 a1                	js     80070e <vprintfmt+0x1f9>
  80076d:	83 ee 01             	sub    $0x1,%esi
  800770:	79 9c                	jns    80070e <vprintfmt+0x1f9>
  800772:	89 df                	mov    %ebx,%edi
  800774:	8b 75 08             	mov    0x8(%ebp),%esi
  800777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077a:	eb 18                	jmp    800794 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	6a 20                	push   $0x20
  800782:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800784:	83 ef 01             	sub    $0x1,%edi
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	eb 08                	jmp    800794 <vprintfmt+0x27f>
  80078c:	89 df                	mov    %ebx,%edi
  80078e:	8b 75 08             	mov    0x8(%ebp),%esi
  800791:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800794:	85 ff                	test   %edi,%edi
  800796:	7f e4                	jg     80077c <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800798:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079b:	e9 9b fd ff ff       	jmp    80053b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a0:	83 fa 01             	cmp    $0x1,%edx
  8007a3:	7e 16                	jle    8007bb <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8d 50 08             	lea    0x8(%eax),%edx
  8007ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ae:	8b 50 04             	mov    0x4(%eax),%edx
  8007b1:	8b 00                	mov    (%eax),%eax
  8007b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007b9:	eb 32                	jmp    8007ed <vprintfmt+0x2d8>
	else if (lflag)
  8007bb:	85 d2                	test   %edx,%edx
  8007bd:	74 18                	je     8007d7 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8d 50 04             	lea    0x4(%eax),%edx
  8007c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c8:	8b 00                	mov    (%eax),%eax
  8007ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cd:	89 c1                	mov    %eax,%ecx
  8007cf:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007d5:	eb 16                	jmp    8007ed <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e5:	89 c1                	mov    %eax,%ecx
  8007e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007fc:	79 74                	jns    800872 <vprintfmt+0x35d>
				putch('-', putdat);
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	53                   	push   %ebx
  800802:	6a 2d                	push   $0x2d
  800804:	ff d6                	call   *%esi
				num = -(long long) num;
  800806:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800809:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80080c:	f7 d8                	neg    %eax
  80080e:	83 d2 00             	adc    $0x0,%edx
  800811:	f7 da                	neg    %edx
  800813:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800816:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80081b:	eb 55                	jmp    800872 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80081d:	8d 45 14             	lea    0x14(%ebp),%eax
  800820:	e8 7c fc ff ff       	call   8004a1 <getuint>
			base = 10;
  800825:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80082a:	eb 46                	jmp    800872 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80082c:	8d 45 14             	lea    0x14(%ebp),%eax
  80082f:	e8 6d fc ff ff       	call   8004a1 <getuint>
                        base = 8;
  800834:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800839:	eb 37                	jmp    800872 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80083b:	83 ec 08             	sub    $0x8,%esp
  80083e:	53                   	push   %ebx
  80083f:	6a 30                	push   $0x30
  800841:	ff d6                	call   *%esi
			putch('x', putdat);
  800843:	83 c4 08             	add    $0x8,%esp
  800846:	53                   	push   %ebx
  800847:	6a 78                	push   $0x78
  800849:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80084b:	8b 45 14             	mov    0x14(%ebp),%eax
  80084e:	8d 50 04             	lea    0x4(%eax),%edx
  800851:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800854:	8b 00                	mov    (%eax),%eax
  800856:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80085b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80085e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800863:	eb 0d                	jmp    800872 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800865:	8d 45 14             	lea    0x14(%ebp),%eax
  800868:	e8 34 fc ff ff       	call   8004a1 <getuint>
			base = 16;
  80086d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800872:	83 ec 0c             	sub    $0xc,%esp
  800875:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800879:	57                   	push   %edi
  80087a:	ff 75 e0             	pushl  -0x20(%ebp)
  80087d:	51                   	push   %ecx
  80087e:	52                   	push   %edx
  80087f:	50                   	push   %eax
  800880:	89 da                	mov    %ebx,%edx
  800882:	89 f0                	mov    %esi,%eax
  800884:	e8 6e fb ff ff       	call   8003f7 <printnum>
			break;
  800889:	83 c4 20             	add    $0x20,%esp
  80088c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088f:	e9 a7 fc ff ff       	jmp    80053b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800894:	83 ec 08             	sub    $0x8,%esp
  800897:	53                   	push   %ebx
  800898:	51                   	push   %ecx
  800899:	ff d6                	call   *%esi
			break;
  80089b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a1:	e9 95 fc ff ff       	jmp    80053b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008a6:	83 ec 08             	sub    $0x8,%esp
  8008a9:	53                   	push   %ebx
  8008aa:	6a 25                	push   $0x25
  8008ac:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	eb 03                	jmp    8008b6 <vprintfmt+0x3a1>
  8008b3:	83 ef 01             	sub    $0x1,%edi
  8008b6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008ba:	75 f7                	jne    8008b3 <vprintfmt+0x39e>
  8008bc:	e9 7a fc ff ff       	jmp    80053b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c4:	5b                   	pop    %ebx
  8008c5:	5e                   	pop    %esi
  8008c6:	5f                   	pop    %edi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	83 ec 18             	sub    $0x18,%esp
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008d8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008dc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008e6:	85 c0                	test   %eax,%eax
  8008e8:	74 26                	je     800910 <vsnprintf+0x47>
  8008ea:	85 d2                	test   %edx,%edx
  8008ec:	7e 22                	jle    800910 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ee:	ff 75 14             	pushl  0x14(%ebp)
  8008f1:	ff 75 10             	pushl  0x10(%ebp)
  8008f4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008f7:	50                   	push   %eax
  8008f8:	68 db 04 80 00       	push   $0x8004db
  8008fd:	e8 13 fc ff ff       	call   800515 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800902:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800905:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800908:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090b:	83 c4 10             	add    $0x10,%esp
  80090e:	eb 05                	jmp    800915 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800910:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80091d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800920:	50                   	push   %eax
  800921:	ff 75 10             	pushl  0x10(%ebp)
  800924:	ff 75 0c             	pushl  0xc(%ebp)
  800927:	ff 75 08             	pushl  0x8(%ebp)
  80092a:	e8 9a ff ff ff       	call   8008c9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80092f:	c9                   	leave  
  800930:	c3                   	ret    

00800931 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
  80093c:	eb 03                	jmp    800941 <strlen+0x10>
		n++;
  80093e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800941:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800945:	75 f7                	jne    80093e <strlen+0xd>
		n++;
	return n;
}
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800952:	ba 00 00 00 00       	mov    $0x0,%edx
  800957:	eb 03                	jmp    80095c <strnlen+0x13>
		n++;
  800959:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095c:	39 c2                	cmp    %eax,%edx
  80095e:	74 08                	je     800968 <strnlen+0x1f>
  800960:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800964:	75 f3                	jne    800959 <strnlen+0x10>
  800966:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	53                   	push   %ebx
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800974:	89 c2                	mov    %eax,%edx
  800976:	83 c2 01             	add    $0x1,%edx
  800979:	83 c1 01             	add    $0x1,%ecx
  80097c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800980:	88 5a ff             	mov    %bl,-0x1(%edx)
  800983:	84 db                	test   %bl,%bl
  800985:	75 ef                	jne    800976 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800987:	5b                   	pop    %ebx
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	53                   	push   %ebx
  80098e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800991:	53                   	push   %ebx
  800992:	e8 9a ff ff ff       	call   800931 <strlen>
  800997:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80099a:	ff 75 0c             	pushl  0xc(%ebp)
  80099d:	01 d8                	add    %ebx,%eax
  80099f:	50                   	push   %eax
  8009a0:	e8 c5 ff ff ff       	call   80096a <strcpy>
	return dst;
}
  8009a5:	89 d8                	mov    %ebx,%eax
  8009a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b7:	89 f3                	mov    %esi,%ebx
  8009b9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009bc:	89 f2                	mov    %esi,%edx
  8009be:	eb 0f                	jmp    8009cf <strncpy+0x23>
		*dst++ = *src;
  8009c0:	83 c2 01             	add    $0x1,%edx
  8009c3:	0f b6 01             	movzbl (%ecx),%eax
  8009c6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c9:	80 39 01             	cmpb   $0x1,(%ecx)
  8009cc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009cf:	39 da                	cmp    %ebx,%edx
  8009d1:	75 ed                	jne    8009c0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d3:	89 f0                	mov    %esi,%eax
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	56                   	push   %esi
  8009dd:	53                   	push   %ebx
  8009de:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e4:	8b 55 10             	mov    0x10(%ebp),%edx
  8009e7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e9:	85 d2                	test   %edx,%edx
  8009eb:	74 21                	je     800a0e <strlcpy+0x35>
  8009ed:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009f1:	89 f2                	mov    %esi,%edx
  8009f3:	eb 09                	jmp    8009fe <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009f5:	83 c2 01             	add    $0x1,%edx
  8009f8:	83 c1 01             	add    $0x1,%ecx
  8009fb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009fe:	39 c2                	cmp    %eax,%edx
  800a00:	74 09                	je     800a0b <strlcpy+0x32>
  800a02:	0f b6 19             	movzbl (%ecx),%ebx
  800a05:	84 db                	test   %bl,%bl
  800a07:	75 ec                	jne    8009f5 <strlcpy+0x1c>
  800a09:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a0b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a0e:	29 f0                	sub    %esi,%eax
}
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a1d:	eb 06                	jmp    800a25 <strcmp+0x11>
		p++, q++;
  800a1f:	83 c1 01             	add    $0x1,%ecx
  800a22:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	84 c0                	test   %al,%al
  800a2a:	74 04                	je     800a30 <strcmp+0x1c>
  800a2c:	3a 02                	cmp    (%edx),%al
  800a2e:	74 ef                	je     800a1f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a30:	0f b6 c0             	movzbl %al,%eax
  800a33:	0f b6 12             	movzbl (%edx),%edx
  800a36:	29 d0                	sub    %edx,%eax
}
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	53                   	push   %ebx
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a44:	89 c3                	mov    %eax,%ebx
  800a46:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a49:	eb 06                	jmp    800a51 <strncmp+0x17>
		n--, p++, q++;
  800a4b:	83 c0 01             	add    $0x1,%eax
  800a4e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a51:	39 d8                	cmp    %ebx,%eax
  800a53:	74 15                	je     800a6a <strncmp+0x30>
  800a55:	0f b6 08             	movzbl (%eax),%ecx
  800a58:	84 c9                	test   %cl,%cl
  800a5a:	74 04                	je     800a60 <strncmp+0x26>
  800a5c:	3a 0a                	cmp    (%edx),%cl
  800a5e:	74 eb                	je     800a4b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a60:	0f b6 00             	movzbl (%eax),%eax
  800a63:	0f b6 12             	movzbl (%edx),%edx
  800a66:	29 d0                	sub    %edx,%eax
  800a68:	eb 05                	jmp    800a6f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a6f:	5b                   	pop    %ebx
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a7c:	eb 07                	jmp    800a85 <strchr+0x13>
		if (*s == c)
  800a7e:	38 ca                	cmp    %cl,%dl
  800a80:	74 0f                	je     800a91 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a82:	83 c0 01             	add    $0x1,%eax
  800a85:	0f b6 10             	movzbl (%eax),%edx
  800a88:	84 d2                	test   %dl,%dl
  800a8a:	75 f2                	jne    800a7e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a9d:	eb 03                	jmp    800aa2 <strfind+0xf>
  800a9f:	83 c0 01             	add    $0x1,%eax
  800aa2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aa5:	84 d2                	test   %dl,%dl
  800aa7:	74 04                	je     800aad <strfind+0x1a>
  800aa9:	38 ca                	cmp    %cl,%dl
  800aab:	75 f2                	jne    800a9f <strfind+0xc>
			break;
	return (char *) s;
}
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	57                   	push   %edi
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800abb:	85 c9                	test   %ecx,%ecx
  800abd:	74 36                	je     800af5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800abf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac5:	75 28                	jne    800aef <memset+0x40>
  800ac7:	f6 c1 03             	test   $0x3,%cl
  800aca:	75 23                	jne    800aef <memset+0x40>
		c &= 0xFF;
  800acc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	c1 e3 08             	shl    $0x8,%ebx
  800ad5:	89 d6                	mov    %edx,%esi
  800ad7:	c1 e6 18             	shl    $0x18,%esi
  800ada:	89 d0                	mov    %edx,%eax
  800adc:	c1 e0 10             	shl    $0x10,%eax
  800adf:	09 f0                	or     %esi,%eax
  800ae1:	09 c2                	or     %eax,%edx
  800ae3:	89 d0                	mov    %edx,%eax
  800ae5:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ae7:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aea:	fc                   	cld    
  800aeb:	f3 ab                	rep stos %eax,%es:(%edi)
  800aed:	eb 06                	jmp    800af5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af2:	fc                   	cld    
  800af3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af5:	89 f8                	mov    %edi,%eax
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	8b 45 08             	mov    0x8(%ebp),%eax
  800b04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b0a:	39 c6                	cmp    %eax,%esi
  800b0c:	73 35                	jae    800b43 <memmove+0x47>
  800b0e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b11:	39 d0                	cmp    %edx,%eax
  800b13:	73 2e                	jae    800b43 <memmove+0x47>
		s += n;
		d += n;
  800b15:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b22:	75 13                	jne    800b37 <memmove+0x3b>
  800b24:	f6 c1 03             	test   $0x3,%cl
  800b27:	75 0e                	jne    800b37 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b29:	83 ef 04             	sub    $0x4,%edi
  800b2c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b2f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b32:	fd                   	std    
  800b33:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b35:	eb 09                	jmp    800b40 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b37:	83 ef 01             	sub    $0x1,%edi
  800b3a:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3d:	fd                   	std    
  800b3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b40:	fc                   	cld    
  800b41:	eb 1d                	jmp    800b60 <memmove+0x64>
  800b43:	89 f2                	mov    %esi,%edx
  800b45:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b47:	f6 c2 03             	test   $0x3,%dl
  800b4a:	75 0f                	jne    800b5b <memmove+0x5f>
  800b4c:	f6 c1 03             	test   $0x3,%cl
  800b4f:	75 0a                	jne    800b5b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b51:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b54:	89 c7                	mov    %eax,%edi
  800b56:	fc                   	cld    
  800b57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b59:	eb 05                	jmp    800b60 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b5b:	89 c7                	mov    %eax,%edi
  800b5d:	fc                   	cld    
  800b5e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b67:	ff 75 10             	pushl  0x10(%ebp)
  800b6a:	ff 75 0c             	pushl  0xc(%ebp)
  800b6d:	ff 75 08             	pushl  0x8(%ebp)
  800b70:	e8 87 ff ff ff       	call   800afc <memmove>
}
  800b75:	c9                   	leave  
  800b76:	c3                   	ret    

00800b77 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b82:	89 c6                	mov    %eax,%esi
  800b84:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b87:	eb 1a                	jmp    800ba3 <memcmp+0x2c>
		if (*s1 != *s2)
  800b89:	0f b6 08             	movzbl (%eax),%ecx
  800b8c:	0f b6 1a             	movzbl (%edx),%ebx
  800b8f:	38 d9                	cmp    %bl,%cl
  800b91:	74 0a                	je     800b9d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b93:	0f b6 c1             	movzbl %cl,%eax
  800b96:	0f b6 db             	movzbl %bl,%ebx
  800b99:	29 d8                	sub    %ebx,%eax
  800b9b:	eb 0f                	jmp    800bac <memcmp+0x35>
		s1++, s2++;
  800b9d:	83 c0 01             	add    $0x1,%eax
  800ba0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba3:	39 f0                	cmp    %esi,%eax
  800ba5:	75 e2                	jne    800b89 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bb9:	89 c2                	mov    %eax,%edx
  800bbb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bbe:	eb 07                	jmp    800bc7 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc0:	38 08                	cmp    %cl,(%eax)
  800bc2:	74 07                	je     800bcb <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc4:	83 c0 01             	add    $0x1,%eax
  800bc7:	39 d0                	cmp    %edx,%eax
  800bc9:	72 f5                	jb     800bc0 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd9:	eb 03                	jmp    800bde <strtol+0x11>
		s++;
  800bdb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bde:	0f b6 01             	movzbl (%ecx),%eax
  800be1:	3c 09                	cmp    $0x9,%al
  800be3:	74 f6                	je     800bdb <strtol+0xe>
  800be5:	3c 20                	cmp    $0x20,%al
  800be7:	74 f2                	je     800bdb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800be9:	3c 2b                	cmp    $0x2b,%al
  800beb:	75 0a                	jne    800bf7 <strtol+0x2a>
		s++;
  800bed:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf5:	eb 10                	jmp    800c07 <strtol+0x3a>
  800bf7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bfc:	3c 2d                	cmp    $0x2d,%al
  800bfe:	75 07                	jne    800c07 <strtol+0x3a>
		s++, neg = 1;
  800c00:	8d 49 01             	lea    0x1(%ecx),%ecx
  800c03:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c07:	85 db                	test   %ebx,%ebx
  800c09:	0f 94 c0             	sete   %al
  800c0c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c12:	75 19                	jne    800c2d <strtol+0x60>
  800c14:	80 39 30             	cmpb   $0x30,(%ecx)
  800c17:	75 14                	jne    800c2d <strtol+0x60>
  800c19:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c1d:	0f 85 82 00 00 00    	jne    800ca5 <strtol+0xd8>
		s += 2, base = 16;
  800c23:	83 c1 02             	add    $0x2,%ecx
  800c26:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c2b:	eb 16                	jmp    800c43 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c2d:	84 c0                	test   %al,%al
  800c2f:	74 12                	je     800c43 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c31:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c36:	80 39 30             	cmpb   $0x30,(%ecx)
  800c39:	75 08                	jne    800c43 <strtol+0x76>
		s++, base = 8;
  800c3b:	83 c1 01             	add    $0x1,%ecx
  800c3e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c43:	b8 00 00 00 00       	mov    $0x0,%eax
  800c48:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c4b:	0f b6 11             	movzbl (%ecx),%edx
  800c4e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c51:	89 f3                	mov    %esi,%ebx
  800c53:	80 fb 09             	cmp    $0x9,%bl
  800c56:	77 08                	ja     800c60 <strtol+0x93>
			dig = *s - '0';
  800c58:	0f be d2             	movsbl %dl,%edx
  800c5b:	83 ea 30             	sub    $0x30,%edx
  800c5e:	eb 22                	jmp    800c82 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c60:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c63:	89 f3                	mov    %esi,%ebx
  800c65:	80 fb 19             	cmp    $0x19,%bl
  800c68:	77 08                	ja     800c72 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c6a:	0f be d2             	movsbl %dl,%edx
  800c6d:	83 ea 57             	sub    $0x57,%edx
  800c70:	eb 10                	jmp    800c82 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c72:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c75:	89 f3                	mov    %esi,%ebx
  800c77:	80 fb 19             	cmp    $0x19,%bl
  800c7a:	77 16                	ja     800c92 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c7c:	0f be d2             	movsbl %dl,%edx
  800c7f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c82:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c85:	7d 0f                	jge    800c96 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c87:	83 c1 01             	add    $0x1,%ecx
  800c8a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c8e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c90:	eb b9                	jmp    800c4b <strtol+0x7e>
  800c92:	89 c2                	mov    %eax,%edx
  800c94:	eb 02                	jmp    800c98 <strtol+0xcb>
  800c96:	89 c2                	mov    %eax,%edx

	if (endptr)
  800c98:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9c:	74 0d                	je     800cab <strtol+0xde>
		*endptr = (char *) s;
  800c9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca1:	89 0e                	mov    %ecx,(%esi)
  800ca3:	eb 06                	jmp    800cab <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca5:	84 c0                	test   %al,%al
  800ca7:	75 92                	jne    800c3b <strtol+0x6e>
  800ca9:	eb 98                	jmp    800c43 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cab:	f7 da                	neg    %edx
  800cad:	85 ff                	test   %edi,%edi
  800caf:	0f 45 c2             	cmovne %edx,%eax
}
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    
  800cb7:	66 90                	xchg   %ax,%ax
  800cb9:	66 90                	xchg   %ax,%ax
  800cbb:	66 90                	xchg   %ax,%ax
  800cbd:	66 90                	xchg   %ax,%ax
  800cbf:	90                   	nop

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
