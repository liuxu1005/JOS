
obj/user/breakpoint:     file format elf32-i386


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
  800044:	e8 c6 00 00 00       	call   80010f <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800082:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800085:	6a 00                	push   $0x0
  800087:	e8 42 00 00 00       	call   8000ce <sys_env_destroy>
  80008c:	83 c4 10             	add    $0x10,%esp
}
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	57                   	push   %edi
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800097:	b8 00 00 00 00       	mov    $0x0,%eax
  80009c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009f:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a2:	89 c3                	mov    %eax,%ebx
  8000a4:	89 c7                	mov    %eax,%edi
  8000a6:	89 c6                	mov    %eax,%esi
  8000a8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5f                   	pop    %edi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    

008000af <sys_cgetc>:

int
sys_cgetc(void)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bf:	89 d1                	mov    %edx,%ecx
  8000c1:	89 d3                	mov    %edx,%ebx
  8000c3:	89 d7                	mov    %edx,%edi
  8000c5:	89 d6                	mov    %edx,%esi
  8000c7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e4:	89 cb                	mov    %ecx,%ebx
  8000e6:	89 cf                	mov    %ecx,%edi
  8000e8:	89 ce                	mov    %ecx,%esi
  8000ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	7e 17                	jle    800107 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f0:	83 ec 0c             	sub    $0xc,%esp
  8000f3:	50                   	push   %eax
  8000f4:	6a 03                	push   $0x3
  8000f6:	68 6a 0f 80 00       	push   $0x800f6a
  8000fb:	6a 23                	push   $0x23
  8000fd:	68 87 0f 80 00       	push   $0x800f87
  800102:	e8 f5 01 00 00       	call   8002fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5f                   	pop    %edi
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	57                   	push   %edi
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800115:	ba 00 00 00 00       	mov    $0x0,%edx
  80011a:	b8 02 00 00 00       	mov    $0x2,%eax
  80011f:	89 d1                	mov    %edx,%ecx
  800121:	89 d3                	mov    %edx,%ebx
  800123:	89 d7                	mov    %edx,%edi
  800125:	89 d6                	mov    %edx,%esi
  800127:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <sys_yield>:

void
sys_yield(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	57                   	push   %edi
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	89 d6                	mov    %edx,%esi
  800146:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800156:	be 00 00 00 00       	mov    $0x0,%esi
  80015b:	b8 04 00 00 00       	mov    $0x4,%eax
  800160:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
  800166:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800169:	89 f7                	mov    %esi,%edi
  80016b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80016d:	85 c0                	test   %eax,%eax
  80016f:	7e 17                	jle    800188 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800171:	83 ec 0c             	sub    $0xc,%esp
  800174:	50                   	push   %eax
  800175:	6a 04                	push   $0x4
  800177:	68 6a 0f 80 00       	push   $0x800f6a
  80017c:	6a 23                	push   $0x23
  80017e:	68 87 0f 80 00       	push   $0x800f87
  800183:	e8 74 01 00 00       	call   8002fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	5f                   	pop    %edi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800199:	b8 05 00 00 00       	mov    $0x5,%eax
  80019e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001aa:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001af:	85 c0                	test   %eax,%eax
  8001b1:	7e 17                	jle    8001ca <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	50                   	push   %eax
  8001b7:	6a 05                	push   $0x5
  8001b9:	68 6a 0f 80 00       	push   $0x800f6a
  8001be:	6a 23                	push   $0x23
  8001c0:	68 87 0f 80 00       	push   $0x800f87
  8001c5:	e8 32 01 00 00       	call   8002fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	89 df                	mov    %ebx,%edi
  8001ed:	89 de                	mov    %ebx,%esi
  8001ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	7e 17                	jle    80020c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	50                   	push   %eax
  8001f9:	6a 06                	push   $0x6
  8001fb:	68 6a 0f 80 00       	push   $0x800f6a
  800200:	6a 23                	push   $0x23
  800202:	68 87 0f 80 00       	push   $0x800f87
  800207:	e8 f0 00 00 00       	call   8002fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800222:	b8 08 00 00 00       	mov    $0x8,%eax
  800227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	89 df                	mov    %ebx,%edi
  80022f:	89 de                	mov    %ebx,%esi
  800231:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800233:	85 c0                	test   %eax,%eax
  800235:	7e 17                	jle    80024e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	50                   	push   %eax
  80023b:	6a 08                	push   $0x8
  80023d:	68 6a 0f 80 00       	push   $0x800f6a
  800242:	6a 23                	push   $0x23
  800244:	68 87 0f 80 00       	push   $0x800f87
  800249:	e8 ae 00 00 00       	call   8002fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	57                   	push   %edi
  80025a:	56                   	push   %esi
  80025b:	53                   	push   %ebx
  80025c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800264:	b8 09 00 00 00       	mov    $0x9,%eax
  800269:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026c:	8b 55 08             	mov    0x8(%ebp),%edx
  80026f:	89 df                	mov    %ebx,%edi
  800271:	89 de                	mov    %ebx,%esi
  800273:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800275:	85 c0                	test   %eax,%eax
  800277:	7e 17                	jle    800290 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800279:	83 ec 0c             	sub    $0xc,%esp
  80027c:	50                   	push   %eax
  80027d:	6a 09                	push   $0x9
  80027f:	68 6a 0f 80 00       	push   $0x800f6a
  800284:	6a 23                	push   $0x23
  800286:	68 87 0f 80 00       	push   $0x800f87
  80028b:	e8 6c 00 00 00       	call   8002fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029e:	be 00 00 00 00       	mov    $0x0,%esi
  8002a3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  8002c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	89 cb                	mov    %ecx,%ebx
  8002d3:	89 cf                	mov    %ecx,%edi
  8002d5:	89 ce                	mov    %ecx,%esi
  8002d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d9:	85 c0                	test   %eax,%eax
  8002db:	7e 17                	jle    8002f4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dd:	83 ec 0c             	sub    $0xc,%esp
  8002e0:	50                   	push   %eax
  8002e1:	6a 0c                	push   $0xc
  8002e3:	68 6a 0f 80 00       	push   $0x800f6a
  8002e8:	6a 23                	push   $0x23
  8002ea:	68 87 0f 80 00       	push   $0x800f87
  8002ef:	e8 08 00 00 00       	call   8002fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f7:	5b                   	pop    %ebx
  8002f8:	5e                   	pop    %esi
  8002f9:	5f                   	pop    %edi
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	56                   	push   %esi
  800300:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800301:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800304:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030a:	e8 00 fe ff ff       	call   80010f <sys_getenvid>
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	ff 75 0c             	pushl  0xc(%ebp)
  800315:	ff 75 08             	pushl  0x8(%ebp)
  800318:	56                   	push   %esi
  800319:	50                   	push   %eax
  80031a:	68 98 0f 80 00       	push   $0x800f98
  80031f:	e8 b1 00 00 00       	call   8003d5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800324:	83 c4 18             	add    $0x18,%esp
  800327:	53                   	push   %ebx
  800328:	ff 75 10             	pushl  0x10(%ebp)
  80032b:	e8 54 00 00 00       	call   800384 <vcprintf>
	cprintf("\n");
  800330:	c7 04 24 bc 0f 80 00 	movl   $0x800fbc,(%esp)
  800337:	e8 99 00 00 00       	call   8003d5 <cprintf>
  80033c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80033f:	cc                   	int3   
  800340:	eb fd                	jmp    80033f <_panic+0x43>

00800342 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	53                   	push   %ebx
  800346:	83 ec 04             	sub    $0x4,%esp
  800349:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80034c:	8b 13                	mov    (%ebx),%edx
  80034e:	8d 42 01             	lea    0x1(%edx),%eax
  800351:	89 03                	mov    %eax,(%ebx)
  800353:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800356:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80035f:	75 1a                	jne    80037b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800361:	83 ec 08             	sub    $0x8,%esp
  800364:	68 ff 00 00 00       	push   $0xff
  800369:	8d 43 08             	lea    0x8(%ebx),%eax
  80036c:	50                   	push   %eax
  80036d:	e8 1f fd ff ff       	call   800091 <sys_cputs>
		b->idx = 0;
  800372:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800378:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80037b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80037f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80038d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800394:	00 00 00 
	b.cnt = 0;
  800397:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a1:	ff 75 0c             	pushl  0xc(%ebp)
  8003a4:	ff 75 08             	pushl  0x8(%ebp)
  8003a7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ad:	50                   	push   %eax
  8003ae:	68 42 03 80 00       	push   $0x800342
  8003b3:	e8 4f 01 00 00       	call   800507 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b8:	83 c4 08             	add    $0x8,%esp
  8003bb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c7:	50                   	push   %eax
  8003c8:	e8 c4 fc ff ff       	call   800091 <sys_cputs>

	return b.cnt;
}
  8003cd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d3:	c9                   	leave  
  8003d4:	c3                   	ret    

008003d5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003db:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003de:	50                   	push   %eax
  8003df:	ff 75 08             	pushl  0x8(%ebp)
  8003e2:	e8 9d ff ff ff       	call   800384 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e7:	c9                   	leave  
  8003e8:	c3                   	ret    

008003e9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	57                   	push   %edi
  8003ed:	56                   	push   %esi
  8003ee:	53                   	push   %ebx
  8003ef:	83 ec 1c             	sub    $0x1c,%esp
  8003f2:	89 c7                	mov    %eax,%edi
  8003f4:	89 d6                	mov    %edx,%esi
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fc:	89 d1                	mov    %edx,%ecx
  8003fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800401:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800404:	8b 45 10             	mov    0x10(%ebp),%eax
  800407:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800414:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800417:	72 05                	jb     80041e <printnum+0x35>
  800419:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80041c:	77 3e                	ja     80045c <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041e:	83 ec 0c             	sub    $0xc,%esp
  800421:	ff 75 18             	pushl  0x18(%ebp)
  800424:	83 eb 01             	sub    $0x1,%ebx
  800427:	53                   	push   %ebx
  800428:	50                   	push   %eax
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80042f:	ff 75 e0             	pushl  -0x20(%ebp)
  800432:	ff 75 dc             	pushl  -0x24(%ebp)
  800435:	ff 75 d8             	pushl  -0x28(%ebp)
  800438:	e8 73 08 00 00       	call   800cb0 <__udivdi3>
  80043d:	83 c4 18             	add    $0x18,%esp
  800440:	52                   	push   %edx
  800441:	50                   	push   %eax
  800442:	89 f2                	mov    %esi,%edx
  800444:	89 f8                	mov    %edi,%eax
  800446:	e8 9e ff ff ff       	call   8003e9 <printnum>
  80044b:	83 c4 20             	add    $0x20,%esp
  80044e:	eb 13                	jmp    800463 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	56                   	push   %esi
  800454:	ff 75 18             	pushl  0x18(%ebp)
  800457:	ff d7                	call   *%edi
  800459:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80045c:	83 eb 01             	sub    $0x1,%ebx
  80045f:	85 db                	test   %ebx,%ebx
  800461:	7f ed                	jg     800450 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	56                   	push   %esi
  800467:	83 ec 04             	sub    $0x4,%esp
  80046a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046d:	ff 75 e0             	pushl  -0x20(%ebp)
  800470:	ff 75 dc             	pushl  -0x24(%ebp)
  800473:	ff 75 d8             	pushl  -0x28(%ebp)
  800476:	e8 65 09 00 00       	call   800de0 <__umoddi3>
  80047b:	83 c4 14             	add    $0x14,%esp
  80047e:	0f be 80 be 0f 80 00 	movsbl 0x800fbe(%eax),%eax
  800485:	50                   	push   %eax
  800486:	ff d7                	call   *%edi
  800488:	83 c4 10             	add    $0x10,%esp
}
  80048b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048e:	5b                   	pop    %ebx
  80048f:	5e                   	pop    %esi
  800490:	5f                   	pop    %edi
  800491:	5d                   	pop    %ebp
  800492:	c3                   	ret    

00800493 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800493:	55                   	push   %ebp
  800494:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800496:	83 fa 01             	cmp    $0x1,%edx
  800499:	7e 0e                	jle    8004a9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80049b:	8b 10                	mov    (%eax),%edx
  80049d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a0:	89 08                	mov    %ecx,(%eax)
  8004a2:	8b 02                	mov    (%edx),%eax
  8004a4:	8b 52 04             	mov    0x4(%edx),%edx
  8004a7:	eb 22                	jmp    8004cb <getuint+0x38>
	else if (lflag)
  8004a9:	85 d2                	test   %edx,%edx
  8004ab:	74 10                	je     8004bd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ad:	8b 10                	mov    (%eax),%edx
  8004af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b2:	89 08                	mov    %ecx,(%eax)
  8004b4:	8b 02                	mov    (%edx),%eax
  8004b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8004bb:	eb 0e                	jmp    8004cb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004bd:	8b 10                	mov    (%eax),%edx
  8004bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c2:	89 08                	mov    %ecx,(%eax)
  8004c4:	8b 02                	mov    (%edx),%eax
  8004c6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004cb:	5d                   	pop    %ebp
  8004cc:	c3                   	ret    

008004cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004cd:	55                   	push   %ebp
  8004ce:	89 e5                	mov    %esp,%ebp
  8004d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d7:	8b 10                	mov    (%eax),%edx
  8004d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004dc:	73 0a                	jae    8004e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e1:	89 08                	mov    %ecx,(%eax)
  8004e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e6:	88 02                	mov    %al,(%edx)
}
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f3:	50                   	push   %eax
  8004f4:	ff 75 10             	pushl  0x10(%ebp)
  8004f7:	ff 75 0c             	pushl  0xc(%ebp)
  8004fa:	ff 75 08             	pushl  0x8(%ebp)
  8004fd:	e8 05 00 00 00       	call   800507 <vprintfmt>
	va_end(ap);
  800502:	83 c4 10             	add    $0x10,%esp
}
  800505:	c9                   	leave  
  800506:	c3                   	ret    

00800507 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800507:	55                   	push   %ebp
  800508:	89 e5                	mov    %esp,%ebp
  80050a:	57                   	push   %edi
  80050b:	56                   	push   %esi
  80050c:	53                   	push   %ebx
  80050d:	83 ec 2c             	sub    $0x2c,%esp
  800510:	8b 75 08             	mov    0x8(%ebp),%esi
  800513:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800516:	8b 7d 10             	mov    0x10(%ebp),%edi
  800519:	eb 12                	jmp    80052d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80051b:	85 c0                	test   %eax,%eax
  80051d:	0f 84 90 03 00 00    	je     8008b3 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	53                   	push   %ebx
  800527:	50                   	push   %eax
  800528:	ff d6                	call   *%esi
  80052a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80052d:	83 c7 01             	add    $0x1,%edi
  800530:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800534:	83 f8 25             	cmp    $0x25,%eax
  800537:	75 e2                	jne    80051b <vprintfmt+0x14>
  800539:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80053d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800544:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800552:	ba 00 00 00 00       	mov    $0x0,%edx
  800557:	eb 07                	jmp    800560 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800559:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80055c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8d 47 01             	lea    0x1(%edi),%eax
  800563:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800566:	0f b6 07             	movzbl (%edi),%eax
  800569:	0f b6 c8             	movzbl %al,%ecx
  80056c:	83 e8 23             	sub    $0x23,%eax
  80056f:	3c 55                	cmp    $0x55,%al
  800571:	0f 87 21 03 00 00    	ja     800898 <vprintfmt+0x391>
  800577:	0f b6 c0             	movzbl %al,%eax
  80057a:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800584:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800588:	eb d6                	jmp    800560 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058d:	b8 00 00 00 00       	mov    $0x0,%eax
  800592:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800595:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800598:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80059c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80059f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005a2:	83 fa 09             	cmp    $0x9,%edx
  8005a5:	77 39                	ja     8005e0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005aa:	eb e9                	jmp    800595 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 48 04             	lea    0x4(%eax),%ecx
  8005b2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005b5:	8b 00                	mov    (%eax),%eax
  8005b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005bd:	eb 27                	jmp    8005e6 <vprintfmt+0xdf>
  8005bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c2:	85 c0                	test   %eax,%eax
  8005c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c9:	0f 49 c8             	cmovns %eax,%ecx
  8005cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d2:	eb 8c                	jmp    800560 <vprintfmt+0x59>
  8005d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005de:	eb 80                	jmp    800560 <vprintfmt+0x59>
  8005e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ea:	0f 89 70 ff ff ff    	jns    800560 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005fd:	e9 5e ff ff ff       	jmp    800560 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800602:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800605:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800608:	e9 53 ff ff ff       	jmp    800560 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 04             	lea    0x4(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	ff 30                	pushl  (%eax)
  80061c:	ff d6                	call   *%esi
			break;
  80061e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800621:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800624:	e9 04 ff ff ff       	jmp    80052d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 50 04             	lea    0x4(%eax),%edx
  80062f:	89 55 14             	mov    %edx,0x14(%ebp)
  800632:	8b 00                	mov    (%eax),%eax
  800634:	99                   	cltd   
  800635:	31 d0                	xor    %edx,%eax
  800637:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800639:	83 f8 09             	cmp    $0x9,%eax
  80063c:	7f 0b                	jg     800649 <vprintfmt+0x142>
  80063e:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  800645:	85 d2                	test   %edx,%edx
  800647:	75 18                	jne    800661 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800649:	50                   	push   %eax
  80064a:	68 d6 0f 80 00       	push   $0x800fd6
  80064f:	53                   	push   %ebx
  800650:	56                   	push   %esi
  800651:	e8 94 fe ff ff       	call   8004ea <printfmt>
  800656:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800659:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80065c:	e9 cc fe ff ff       	jmp    80052d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800661:	52                   	push   %edx
  800662:	68 df 0f 80 00       	push   $0x800fdf
  800667:	53                   	push   %ebx
  800668:	56                   	push   %esi
  800669:	e8 7c fe ff ff       	call   8004ea <printfmt>
  80066e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800674:	e9 b4 fe ff ff       	jmp    80052d <vprintfmt+0x26>
  800679:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80067c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80067f:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 50 04             	lea    0x4(%eax),%edx
  800688:	89 55 14             	mov    %edx,0x14(%ebp)
  80068b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80068d:	85 ff                	test   %edi,%edi
  80068f:	ba cf 0f 80 00       	mov    $0x800fcf,%edx
  800694:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800697:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80069b:	0f 84 92 00 00 00    	je     800733 <vprintfmt+0x22c>
  8006a1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006a5:	0f 8e 96 00 00 00    	jle    800741 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	51                   	push   %ecx
  8006af:	57                   	push   %edi
  8006b0:	e8 86 02 00 00       	call   80093b <strnlen>
  8006b5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006b8:	29 c1                	sub    %eax,%ecx
  8006ba:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006bd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006c0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006ca:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cc:	eb 0f                	jmp    8006dd <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d7:	83 ef 01             	sub    $0x1,%edi
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	85 ff                	test   %edi,%edi
  8006df:	7f ed                	jg     8006ce <vprintfmt+0x1c7>
  8006e1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006e4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006e7:	85 c9                	test   %ecx,%ecx
  8006e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ee:	0f 49 c1             	cmovns %ecx,%eax
  8006f1:	29 c1                	sub    %eax,%ecx
  8006f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006fc:	89 cb                	mov    %ecx,%ebx
  8006fe:	eb 4d                	jmp    80074d <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800700:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800704:	74 1b                	je     800721 <vprintfmt+0x21a>
  800706:	0f be c0             	movsbl %al,%eax
  800709:	83 e8 20             	sub    $0x20,%eax
  80070c:	83 f8 5e             	cmp    $0x5e,%eax
  80070f:	76 10                	jbe    800721 <vprintfmt+0x21a>
					putch('?', putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	ff 75 0c             	pushl  0xc(%ebp)
  800717:	6a 3f                	push   $0x3f
  800719:	ff 55 08             	call   *0x8(%ebp)
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	eb 0d                	jmp    80072e <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	ff 75 0c             	pushl  0xc(%ebp)
  800727:	52                   	push   %edx
  800728:	ff 55 08             	call   *0x8(%ebp)
  80072b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072e:	83 eb 01             	sub    $0x1,%ebx
  800731:	eb 1a                	jmp    80074d <vprintfmt+0x246>
  800733:	89 75 08             	mov    %esi,0x8(%ebp)
  800736:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800739:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80073f:	eb 0c                	jmp    80074d <vprintfmt+0x246>
  800741:	89 75 08             	mov    %esi,0x8(%ebp)
  800744:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800747:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80074d:	83 c7 01             	add    $0x1,%edi
  800750:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800754:	0f be d0             	movsbl %al,%edx
  800757:	85 d2                	test   %edx,%edx
  800759:	74 23                	je     80077e <vprintfmt+0x277>
  80075b:	85 f6                	test   %esi,%esi
  80075d:	78 a1                	js     800700 <vprintfmt+0x1f9>
  80075f:	83 ee 01             	sub    $0x1,%esi
  800762:	79 9c                	jns    800700 <vprintfmt+0x1f9>
  800764:	89 df                	mov    %ebx,%edi
  800766:	8b 75 08             	mov    0x8(%ebp),%esi
  800769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076c:	eb 18                	jmp    800786 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80076e:	83 ec 08             	sub    $0x8,%esp
  800771:	53                   	push   %ebx
  800772:	6a 20                	push   $0x20
  800774:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800776:	83 ef 01             	sub    $0x1,%edi
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	eb 08                	jmp    800786 <vprintfmt+0x27f>
  80077e:	89 df                	mov    %ebx,%edi
  800780:	8b 75 08             	mov    0x8(%ebp),%esi
  800783:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800786:	85 ff                	test   %edi,%edi
  800788:	7f e4                	jg     80076e <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80078d:	e9 9b fd ff ff       	jmp    80052d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800792:	83 fa 01             	cmp    $0x1,%edx
  800795:	7e 16                	jle    8007ad <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 50 08             	lea    0x8(%eax),%edx
  80079d:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a0:	8b 50 04             	mov    0x4(%eax),%edx
  8007a3:	8b 00                	mov    (%eax),%eax
  8007a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ab:	eb 32                	jmp    8007df <vprintfmt+0x2d8>
	else if (lflag)
  8007ad:	85 d2                	test   %edx,%edx
  8007af:	74 18                	je     8007c9 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	8d 50 04             	lea    0x4(%eax),%edx
  8007b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ba:	8b 00                	mov    (%eax),%eax
  8007bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bf:	89 c1                	mov    %eax,%ecx
  8007c1:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c7:	eb 16                	jmp    8007df <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8d 50 04             	lea    0x4(%eax),%edx
  8007cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d2:	8b 00                	mov    (%eax),%eax
  8007d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d7:	89 c1                	mov    %eax,%ecx
  8007d9:	c1 f9 1f             	sar    $0x1f,%ecx
  8007dc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007ea:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ee:	79 74                	jns    800864 <vprintfmt+0x35d>
				putch('-', putdat);
  8007f0:	83 ec 08             	sub    $0x8,%esp
  8007f3:	53                   	push   %ebx
  8007f4:	6a 2d                	push   $0x2d
  8007f6:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007fe:	f7 d8                	neg    %eax
  800800:	83 d2 00             	adc    $0x0,%edx
  800803:	f7 da                	neg    %edx
  800805:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800808:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80080d:	eb 55                	jmp    800864 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80080f:	8d 45 14             	lea    0x14(%ebp),%eax
  800812:	e8 7c fc ff ff       	call   800493 <getuint>
			base = 10;
  800817:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80081c:	eb 46                	jmp    800864 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80081e:	8d 45 14             	lea    0x14(%ebp),%eax
  800821:	e8 6d fc ff ff       	call   800493 <getuint>
                        base = 8;
  800826:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80082b:	eb 37                	jmp    800864 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80082d:	83 ec 08             	sub    $0x8,%esp
  800830:	53                   	push   %ebx
  800831:	6a 30                	push   $0x30
  800833:	ff d6                	call   *%esi
			putch('x', putdat);
  800835:	83 c4 08             	add    $0x8,%esp
  800838:	53                   	push   %ebx
  800839:	6a 78                	push   $0x78
  80083b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80083d:	8b 45 14             	mov    0x14(%ebp),%eax
  800840:	8d 50 04             	lea    0x4(%eax),%edx
  800843:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800846:	8b 00                	mov    (%eax),%eax
  800848:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80084d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800850:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800855:	eb 0d                	jmp    800864 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800857:	8d 45 14             	lea    0x14(%ebp),%eax
  80085a:	e8 34 fc ff ff       	call   800493 <getuint>
			base = 16;
  80085f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800864:	83 ec 0c             	sub    $0xc,%esp
  800867:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80086b:	57                   	push   %edi
  80086c:	ff 75 e0             	pushl  -0x20(%ebp)
  80086f:	51                   	push   %ecx
  800870:	52                   	push   %edx
  800871:	50                   	push   %eax
  800872:	89 da                	mov    %ebx,%edx
  800874:	89 f0                	mov    %esi,%eax
  800876:	e8 6e fb ff ff       	call   8003e9 <printnum>
			break;
  80087b:	83 c4 20             	add    $0x20,%esp
  80087e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800881:	e9 a7 fc ff ff       	jmp    80052d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	53                   	push   %ebx
  80088a:	51                   	push   %ecx
  80088b:	ff d6                	call   *%esi
			break;
  80088d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800890:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800893:	e9 95 fc ff ff       	jmp    80052d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	53                   	push   %ebx
  80089c:	6a 25                	push   $0x25
  80089e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008a0:	83 c4 10             	add    $0x10,%esp
  8008a3:	eb 03                	jmp    8008a8 <vprintfmt+0x3a1>
  8008a5:	83 ef 01             	sub    $0x1,%edi
  8008a8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008ac:	75 f7                	jne    8008a5 <vprintfmt+0x39e>
  8008ae:	e9 7a fc ff ff       	jmp    80052d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5f                   	pop    %edi
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	83 ec 18             	sub    $0x18,%esp
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ca:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008ce:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008d8:	85 c0                	test   %eax,%eax
  8008da:	74 26                	je     800902 <vsnprintf+0x47>
  8008dc:	85 d2                	test   %edx,%edx
  8008de:	7e 22                	jle    800902 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008e0:	ff 75 14             	pushl  0x14(%ebp)
  8008e3:	ff 75 10             	pushl  0x10(%ebp)
  8008e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008e9:	50                   	push   %eax
  8008ea:	68 cd 04 80 00       	push   $0x8004cd
  8008ef:	e8 13 fc ff ff       	call   800507 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008fd:	83 c4 10             	add    $0x10,%esp
  800900:	eb 05                	jmp    800907 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800902:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800907:	c9                   	leave  
  800908:	c3                   	ret    

00800909 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800912:	50                   	push   %eax
  800913:	ff 75 10             	pushl  0x10(%ebp)
  800916:	ff 75 0c             	pushl  0xc(%ebp)
  800919:	ff 75 08             	pushl  0x8(%ebp)
  80091c:	e8 9a ff ff ff       	call   8008bb <vsnprintf>
	va_end(ap);

	return rc;
}
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800929:	b8 00 00 00 00       	mov    $0x0,%eax
  80092e:	eb 03                	jmp    800933 <strlen+0x10>
		n++;
  800930:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800933:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800937:	75 f7                	jne    800930 <strlen+0xd>
		n++;
	return n;
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800941:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800944:	ba 00 00 00 00       	mov    $0x0,%edx
  800949:	eb 03                	jmp    80094e <strnlen+0x13>
		n++;
  80094b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094e:	39 c2                	cmp    %eax,%edx
  800950:	74 08                	je     80095a <strnlen+0x1f>
  800952:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800956:	75 f3                	jne    80094b <strnlen+0x10>
  800958:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	53                   	push   %ebx
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800966:	89 c2                	mov    %eax,%edx
  800968:	83 c2 01             	add    $0x1,%edx
  80096b:	83 c1 01             	add    $0x1,%ecx
  80096e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800972:	88 5a ff             	mov    %bl,-0x1(%edx)
  800975:	84 db                	test   %bl,%bl
  800977:	75 ef                	jne    800968 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800979:	5b                   	pop    %ebx
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	53                   	push   %ebx
  800980:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800983:	53                   	push   %ebx
  800984:	e8 9a ff ff ff       	call   800923 <strlen>
  800989:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80098c:	ff 75 0c             	pushl  0xc(%ebp)
  80098f:	01 d8                	add    %ebx,%eax
  800991:	50                   	push   %eax
  800992:	e8 c5 ff ff ff       	call   80095c <strcpy>
	return dst;
}
  800997:	89 d8                	mov    %ebx,%eax
  800999:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a9:	89 f3                	mov    %esi,%ebx
  8009ab:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ae:	89 f2                	mov    %esi,%edx
  8009b0:	eb 0f                	jmp    8009c1 <strncpy+0x23>
		*dst++ = *src;
  8009b2:	83 c2 01             	add    $0x1,%edx
  8009b5:	0f b6 01             	movzbl (%ecx),%eax
  8009b8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009bb:	80 39 01             	cmpb   $0x1,(%ecx)
  8009be:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c1:	39 da                	cmp    %ebx,%edx
  8009c3:	75 ed                	jne    8009b2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c5:	89 f0                	mov    %esi,%eax
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d6:	8b 55 10             	mov    0x10(%ebp),%edx
  8009d9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009db:	85 d2                	test   %edx,%edx
  8009dd:	74 21                	je     800a00 <strlcpy+0x35>
  8009df:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009e3:	89 f2                	mov    %esi,%edx
  8009e5:	eb 09                	jmp    8009f0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e7:	83 c2 01             	add    $0x1,%edx
  8009ea:	83 c1 01             	add    $0x1,%ecx
  8009ed:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f0:	39 c2                	cmp    %eax,%edx
  8009f2:	74 09                	je     8009fd <strlcpy+0x32>
  8009f4:	0f b6 19             	movzbl (%ecx),%ebx
  8009f7:	84 db                	test   %bl,%bl
  8009f9:	75 ec                	jne    8009e7 <strlcpy+0x1c>
  8009fb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009fd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a00:	29 f0                	sub    %esi,%eax
}
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a0f:	eb 06                	jmp    800a17 <strcmp+0x11>
		p++, q++;
  800a11:	83 c1 01             	add    $0x1,%ecx
  800a14:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a17:	0f b6 01             	movzbl (%ecx),%eax
  800a1a:	84 c0                	test   %al,%al
  800a1c:	74 04                	je     800a22 <strcmp+0x1c>
  800a1e:	3a 02                	cmp    (%edx),%al
  800a20:	74 ef                	je     800a11 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a22:	0f b6 c0             	movzbl %al,%eax
  800a25:	0f b6 12             	movzbl (%edx),%edx
  800a28:	29 d0                	sub    %edx,%eax
}
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	53                   	push   %ebx
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a36:	89 c3                	mov    %eax,%ebx
  800a38:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a3b:	eb 06                	jmp    800a43 <strncmp+0x17>
		n--, p++, q++;
  800a3d:	83 c0 01             	add    $0x1,%eax
  800a40:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a43:	39 d8                	cmp    %ebx,%eax
  800a45:	74 15                	je     800a5c <strncmp+0x30>
  800a47:	0f b6 08             	movzbl (%eax),%ecx
  800a4a:	84 c9                	test   %cl,%cl
  800a4c:	74 04                	je     800a52 <strncmp+0x26>
  800a4e:	3a 0a                	cmp    (%edx),%cl
  800a50:	74 eb                	je     800a3d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a52:	0f b6 00             	movzbl (%eax),%eax
  800a55:	0f b6 12             	movzbl (%edx),%edx
  800a58:	29 d0                	sub    %edx,%eax
  800a5a:	eb 05                	jmp    800a61 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a61:	5b                   	pop    %ebx
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6e:	eb 07                	jmp    800a77 <strchr+0x13>
		if (*s == c)
  800a70:	38 ca                	cmp    %cl,%dl
  800a72:	74 0f                	je     800a83 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a74:	83 c0 01             	add    $0x1,%eax
  800a77:	0f b6 10             	movzbl (%eax),%edx
  800a7a:	84 d2                	test   %dl,%dl
  800a7c:	75 f2                	jne    800a70 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a8f:	eb 03                	jmp    800a94 <strfind+0xf>
  800a91:	83 c0 01             	add    $0x1,%eax
  800a94:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a97:	84 d2                	test   %dl,%dl
  800a99:	74 04                	je     800a9f <strfind+0x1a>
  800a9b:	38 ca                	cmp    %cl,%dl
  800a9d:	75 f2                	jne    800a91 <strfind+0xc>
			break;
	return (char *) s;
}
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
  800aa7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aaa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aad:	85 c9                	test   %ecx,%ecx
  800aaf:	74 36                	je     800ae7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab7:	75 28                	jne    800ae1 <memset+0x40>
  800ab9:	f6 c1 03             	test   $0x3,%cl
  800abc:	75 23                	jne    800ae1 <memset+0x40>
		c &= 0xFF;
  800abe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac2:	89 d3                	mov    %edx,%ebx
  800ac4:	c1 e3 08             	shl    $0x8,%ebx
  800ac7:	89 d6                	mov    %edx,%esi
  800ac9:	c1 e6 18             	shl    $0x18,%esi
  800acc:	89 d0                	mov    %edx,%eax
  800ace:	c1 e0 10             	shl    $0x10,%eax
  800ad1:	09 f0                	or     %esi,%eax
  800ad3:	09 c2                	or     %eax,%edx
  800ad5:	89 d0                	mov    %edx,%eax
  800ad7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ad9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800adc:	fc                   	cld    
  800add:	f3 ab                	rep stos %eax,%es:(%edi)
  800adf:	eb 06                	jmp    800ae7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae4:	fc                   	cld    
  800ae5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ae7:	89 f8                	mov    %edi,%eax
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800afc:	39 c6                	cmp    %eax,%esi
  800afe:	73 35                	jae    800b35 <memmove+0x47>
  800b00:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b03:	39 d0                	cmp    %edx,%eax
  800b05:	73 2e                	jae    800b35 <memmove+0x47>
		s += n;
		d += n;
  800b07:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b0a:	89 d6                	mov    %edx,%esi
  800b0c:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b14:	75 13                	jne    800b29 <memmove+0x3b>
  800b16:	f6 c1 03             	test   $0x3,%cl
  800b19:	75 0e                	jne    800b29 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b1b:	83 ef 04             	sub    $0x4,%edi
  800b1e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b21:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b24:	fd                   	std    
  800b25:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b27:	eb 09                	jmp    800b32 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b29:	83 ef 01             	sub    $0x1,%edi
  800b2c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b2f:	fd                   	std    
  800b30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b32:	fc                   	cld    
  800b33:	eb 1d                	jmp    800b52 <memmove+0x64>
  800b35:	89 f2                	mov    %esi,%edx
  800b37:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b39:	f6 c2 03             	test   $0x3,%dl
  800b3c:	75 0f                	jne    800b4d <memmove+0x5f>
  800b3e:	f6 c1 03             	test   $0x3,%cl
  800b41:	75 0a                	jne    800b4d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b43:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b46:	89 c7                	mov    %eax,%edi
  800b48:	fc                   	cld    
  800b49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4b:	eb 05                	jmp    800b52 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b4d:	89 c7                	mov    %eax,%edi
  800b4f:	fc                   	cld    
  800b50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b59:	ff 75 10             	pushl  0x10(%ebp)
  800b5c:	ff 75 0c             	pushl  0xc(%ebp)
  800b5f:	ff 75 08             	pushl  0x8(%ebp)
  800b62:	e8 87 ff ff ff       	call   800aee <memmove>
}
  800b67:	c9                   	leave  
  800b68:	c3                   	ret    

00800b69 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b71:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b74:	89 c6                	mov    %eax,%esi
  800b76:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b79:	eb 1a                	jmp    800b95 <memcmp+0x2c>
		if (*s1 != *s2)
  800b7b:	0f b6 08             	movzbl (%eax),%ecx
  800b7e:	0f b6 1a             	movzbl (%edx),%ebx
  800b81:	38 d9                	cmp    %bl,%cl
  800b83:	74 0a                	je     800b8f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b85:	0f b6 c1             	movzbl %cl,%eax
  800b88:	0f b6 db             	movzbl %bl,%ebx
  800b8b:	29 d8                	sub    %ebx,%eax
  800b8d:	eb 0f                	jmp    800b9e <memcmp+0x35>
		s1++, s2++;
  800b8f:	83 c0 01             	add    $0x1,%eax
  800b92:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b95:	39 f0                	cmp    %esi,%eax
  800b97:	75 e2                	jne    800b7b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bab:	89 c2                	mov    %eax,%edx
  800bad:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb0:	eb 07                	jmp    800bb9 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb2:	38 08                	cmp    %cl,(%eax)
  800bb4:	74 07                	je     800bbd <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb6:	83 c0 01             	add    $0x1,%eax
  800bb9:	39 d0                	cmp    %edx,%eax
  800bbb:	72 f5                	jb     800bb2 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcb:	eb 03                	jmp    800bd0 <strtol+0x11>
		s++;
  800bcd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd0:	0f b6 01             	movzbl (%ecx),%eax
  800bd3:	3c 09                	cmp    $0x9,%al
  800bd5:	74 f6                	je     800bcd <strtol+0xe>
  800bd7:	3c 20                	cmp    $0x20,%al
  800bd9:	74 f2                	je     800bcd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bdb:	3c 2b                	cmp    $0x2b,%al
  800bdd:	75 0a                	jne    800be9 <strtol+0x2a>
		s++;
  800bdf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be2:	bf 00 00 00 00       	mov    $0x0,%edi
  800be7:	eb 10                	jmp    800bf9 <strtol+0x3a>
  800be9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bee:	3c 2d                	cmp    $0x2d,%al
  800bf0:	75 07                	jne    800bf9 <strtol+0x3a>
		s++, neg = 1;
  800bf2:	8d 49 01             	lea    0x1(%ecx),%ecx
  800bf5:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf9:	85 db                	test   %ebx,%ebx
  800bfb:	0f 94 c0             	sete   %al
  800bfe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c04:	75 19                	jne    800c1f <strtol+0x60>
  800c06:	80 39 30             	cmpb   $0x30,(%ecx)
  800c09:	75 14                	jne    800c1f <strtol+0x60>
  800c0b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c0f:	0f 85 82 00 00 00    	jne    800c97 <strtol+0xd8>
		s += 2, base = 16;
  800c15:	83 c1 02             	add    $0x2,%ecx
  800c18:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c1d:	eb 16                	jmp    800c35 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c1f:	84 c0                	test   %al,%al
  800c21:	74 12                	je     800c35 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c23:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c28:	80 39 30             	cmpb   $0x30,(%ecx)
  800c2b:	75 08                	jne    800c35 <strtol+0x76>
		s++, base = 8;
  800c2d:	83 c1 01             	add    $0x1,%ecx
  800c30:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c35:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c3d:	0f b6 11             	movzbl (%ecx),%edx
  800c40:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c43:	89 f3                	mov    %esi,%ebx
  800c45:	80 fb 09             	cmp    $0x9,%bl
  800c48:	77 08                	ja     800c52 <strtol+0x93>
			dig = *s - '0';
  800c4a:	0f be d2             	movsbl %dl,%edx
  800c4d:	83 ea 30             	sub    $0x30,%edx
  800c50:	eb 22                	jmp    800c74 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c52:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c55:	89 f3                	mov    %esi,%ebx
  800c57:	80 fb 19             	cmp    $0x19,%bl
  800c5a:	77 08                	ja     800c64 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c5c:	0f be d2             	movsbl %dl,%edx
  800c5f:	83 ea 57             	sub    $0x57,%edx
  800c62:	eb 10                	jmp    800c74 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c64:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c67:	89 f3                	mov    %esi,%ebx
  800c69:	80 fb 19             	cmp    $0x19,%bl
  800c6c:	77 16                	ja     800c84 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c6e:	0f be d2             	movsbl %dl,%edx
  800c71:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c74:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c77:	7d 0f                	jge    800c88 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c79:	83 c1 01             	add    $0x1,%ecx
  800c7c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c80:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c82:	eb b9                	jmp    800c3d <strtol+0x7e>
  800c84:	89 c2                	mov    %eax,%edx
  800c86:	eb 02                	jmp    800c8a <strtol+0xcb>
  800c88:	89 c2                	mov    %eax,%edx

	if (endptr)
  800c8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c8e:	74 0d                	je     800c9d <strtol+0xde>
		*endptr = (char *) s;
  800c90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c93:	89 0e                	mov    %ecx,(%esi)
  800c95:	eb 06                	jmp    800c9d <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c97:	84 c0                	test   %al,%al
  800c99:	75 92                	jne    800c2d <strtol+0x6e>
  800c9b:	eb 98                	jmp    800c35 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c9d:	f7 da                	neg    %edx
  800c9f:	85 ff                	test   %edi,%edi
  800ca1:	0f 45 c2             	cmovne %edx,%eax
}
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    
  800ca9:	66 90                	xchg   %ax,%ax
  800cab:	66 90                	xchg   %ax,%ax
  800cad:	66 90                	xchg   %ax,%ax
  800caf:	90                   	nop

00800cb0 <__udivdi3>:
  800cb0:	55                   	push   %ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	83 ec 10             	sub    $0x10,%esp
  800cb6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800cba:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800cbe:	8b 74 24 24          	mov    0x24(%esp),%esi
  800cc2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800cc6:	85 d2                	test   %edx,%edx
  800cc8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ccc:	89 34 24             	mov    %esi,(%esp)
  800ccf:	89 c8                	mov    %ecx,%eax
  800cd1:	75 35                	jne    800d08 <__udivdi3+0x58>
  800cd3:	39 f1                	cmp    %esi,%ecx
  800cd5:	0f 87 bd 00 00 00    	ja     800d98 <__udivdi3+0xe8>
  800cdb:	85 c9                	test   %ecx,%ecx
  800cdd:	89 cd                	mov    %ecx,%ebp
  800cdf:	75 0b                	jne    800cec <__udivdi3+0x3c>
  800ce1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce6:	31 d2                	xor    %edx,%edx
  800ce8:	f7 f1                	div    %ecx
  800cea:	89 c5                	mov    %eax,%ebp
  800cec:	89 f0                	mov    %esi,%eax
  800cee:	31 d2                	xor    %edx,%edx
  800cf0:	f7 f5                	div    %ebp
  800cf2:	89 c6                	mov    %eax,%esi
  800cf4:	89 f8                	mov    %edi,%eax
  800cf6:	f7 f5                	div    %ebp
  800cf8:	89 f2                	mov    %esi,%edx
  800cfa:	83 c4 10             	add    $0x10,%esp
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    
  800d01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d08:	3b 14 24             	cmp    (%esp),%edx
  800d0b:	77 7b                	ja     800d88 <__udivdi3+0xd8>
  800d0d:	0f bd f2             	bsr    %edx,%esi
  800d10:	83 f6 1f             	xor    $0x1f,%esi
  800d13:	0f 84 97 00 00 00    	je     800db0 <__udivdi3+0x100>
  800d19:	bd 20 00 00 00       	mov    $0x20,%ebp
  800d1e:	89 d7                	mov    %edx,%edi
  800d20:	89 f1                	mov    %esi,%ecx
  800d22:	29 f5                	sub    %esi,%ebp
  800d24:	d3 e7                	shl    %cl,%edi
  800d26:	89 c2                	mov    %eax,%edx
  800d28:	89 e9                	mov    %ebp,%ecx
  800d2a:	d3 ea                	shr    %cl,%edx
  800d2c:	89 f1                	mov    %esi,%ecx
  800d2e:	09 fa                	or     %edi,%edx
  800d30:	8b 3c 24             	mov    (%esp),%edi
  800d33:	d3 e0                	shl    %cl,%eax
  800d35:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d39:	89 e9                	mov    %ebp,%ecx
  800d3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d3f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d43:	89 fa                	mov    %edi,%edx
  800d45:	d3 ea                	shr    %cl,%edx
  800d47:	89 f1                	mov    %esi,%ecx
  800d49:	d3 e7                	shl    %cl,%edi
  800d4b:	89 e9                	mov    %ebp,%ecx
  800d4d:	d3 e8                	shr    %cl,%eax
  800d4f:	09 c7                	or     %eax,%edi
  800d51:	89 f8                	mov    %edi,%eax
  800d53:	f7 74 24 08          	divl   0x8(%esp)
  800d57:	89 d5                	mov    %edx,%ebp
  800d59:	89 c7                	mov    %eax,%edi
  800d5b:	f7 64 24 0c          	mull   0xc(%esp)
  800d5f:	39 d5                	cmp    %edx,%ebp
  800d61:	89 14 24             	mov    %edx,(%esp)
  800d64:	72 11                	jb     800d77 <__udivdi3+0xc7>
  800d66:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d6a:	89 f1                	mov    %esi,%ecx
  800d6c:	d3 e2                	shl    %cl,%edx
  800d6e:	39 c2                	cmp    %eax,%edx
  800d70:	73 5e                	jae    800dd0 <__udivdi3+0x120>
  800d72:	3b 2c 24             	cmp    (%esp),%ebp
  800d75:	75 59                	jne    800dd0 <__udivdi3+0x120>
  800d77:	8d 47 ff             	lea    -0x1(%edi),%eax
  800d7a:	31 f6                	xor    %esi,%esi
  800d7c:	89 f2                	mov    %esi,%edx
  800d7e:	83 c4 10             	add    $0x10,%esp
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
  800d85:	8d 76 00             	lea    0x0(%esi),%esi
  800d88:	31 f6                	xor    %esi,%esi
  800d8a:	31 c0                	xor    %eax,%eax
  800d8c:	89 f2                	mov    %esi,%edx
  800d8e:	83 c4 10             	add    $0x10,%esp
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
  800d98:	89 f2                	mov    %esi,%edx
  800d9a:	31 f6                	xor    %esi,%esi
  800d9c:	89 f8                	mov    %edi,%eax
  800d9e:	f7 f1                	div    %ecx
  800da0:	89 f2                	mov    %esi,%edx
  800da2:	83 c4 10             	add    $0x10,%esp
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    
  800da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800db4:	76 0b                	jbe    800dc1 <__udivdi3+0x111>
  800db6:	31 c0                	xor    %eax,%eax
  800db8:	3b 14 24             	cmp    (%esp),%edx
  800dbb:	0f 83 37 ff ff ff    	jae    800cf8 <__udivdi3+0x48>
  800dc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc6:	e9 2d ff ff ff       	jmp    800cf8 <__udivdi3+0x48>
  800dcb:	90                   	nop
  800dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dd0:	89 f8                	mov    %edi,%eax
  800dd2:	31 f6                	xor    %esi,%esi
  800dd4:	e9 1f ff ff ff       	jmp    800cf8 <__udivdi3+0x48>
  800dd9:	66 90                	xchg   %ax,%ax
  800ddb:	66 90                	xchg   %ax,%ax
  800ddd:	66 90                	xchg   %ax,%ax
  800ddf:	90                   	nop

00800de0 <__umoddi3>:
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	83 ec 20             	sub    $0x20,%esp
  800de6:	8b 44 24 34          	mov    0x34(%esp),%eax
  800dea:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800dee:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800df2:	89 c6                	mov    %eax,%esi
  800df4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800dfc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800e00:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e04:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800e08:	89 74 24 18          	mov    %esi,0x18(%esp)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	89 c2                	mov    %eax,%edx
  800e10:	75 1e                	jne    800e30 <__umoddi3+0x50>
  800e12:	39 f7                	cmp    %esi,%edi
  800e14:	76 52                	jbe    800e68 <__umoddi3+0x88>
  800e16:	89 c8                	mov    %ecx,%eax
  800e18:	89 f2                	mov    %esi,%edx
  800e1a:	f7 f7                	div    %edi
  800e1c:	89 d0                	mov    %edx,%eax
  800e1e:	31 d2                	xor    %edx,%edx
  800e20:	83 c4 20             	add    $0x20,%esp
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    
  800e27:	89 f6                	mov    %esi,%esi
  800e29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e30:	39 f0                	cmp    %esi,%eax
  800e32:	77 5c                	ja     800e90 <__umoddi3+0xb0>
  800e34:	0f bd e8             	bsr    %eax,%ebp
  800e37:	83 f5 1f             	xor    $0x1f,%ebp
  800e3a:	75 64                	jne    800ea0 <__umoddi3+0xc0>
  800e3c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800e40:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800e44:	0f 86 f6 00 00 00    	jbe    800f40 <__umoddi3+0x160>
  800e4a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800e4e:	0f 82 ec 00 00 00    	jb     800f40 <__umoddi3+0x160>
  800e54:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e58:	8b 54 24 18          	mov    0x18(%esp),%edx
  800e5c:	83 c4 20             	add    $0x20,%esp
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    
  800e63:	90                   	nop
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	85 ff                	test   %edi,%edi
  800e6a:	89 fd                	mov    %edi,%ebp
  800e6c:	75 0b                	jne    800e79 <__umoddi3+0x99>
  800e6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e73:	31 d2                	xor    %edx,%edx
  800e75:	f7 f7                	div    %edi
  800e77:	89 c5                	mov    %eax,%ebp
  800e79:	8b 44 24 10          	mov    0x10(%esp),%eax
  800e7d:	31 d2                	xor    %edx,%edx
  800e7f:	f7 f5                	div    %ebp
  800e81:	89 c8                	mov    %ecx,%eax
  800e83:	f7 f5                	div    %ebp
  800e85:	eb 95                	jmp    800e1c <__umoddi3+0x3c>
  800e87:	89 f6                	mov    %esi,%esi
  800e89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e90:	89 c8                	mov    %ecx,%eax
  800e92:	89 f2                	mov    %esi,%edx
  800e94:	83 c4 20             	add    $0x20,%esp
  800e97:	5e                   	pop    %esi
  800e98:	5f                   	pop    %edi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    
  800e9b:	90                   	nop
  800e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea5:	89 e9                	mov    %ebp,%ecx
  800ea7:	29 e8                	sub    %ebp,%eax
  800ea9:	d3 e2                	shl    %cl,%edx
  800eab:	89 c7                	mov    %eax,%edi
  800ead:	89 44 24 18          	mov    %eax,0x18(%esp)
  800eb1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eb5:	89 f9                	mov    %edi,%ecx
  800eb7:	d3 e8                	shr    %cl,%eax
  800eb9:	89 c1                	mov    %eax,%ecx
  800ebb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ebf:	09 d1                	or     %edx,%ecx
  800ec1:	89 fa                	mov    %edi,%edx
  800ec3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ec7:	89 e9                	mov    %ebp,%ecx
  800ec9:	d3 e0                	shl    %cl,%eax
  800ecb:	89 f9                	mov    %edi,%ecx
  800ecd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	d3 e8                	shr    %cl,%eax
  800ed5:	89 e9                	mov    %ebp,%ecx
  800ed7:	89 c7                	mov    %eax,%edi
  800ed9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800edd:	d3 e6                	shl    %cl,%esi
  800edf:	89 d1                	mov    %edx,%ecx
  800ee1:	89 fa                	mov    %edi,%edx
  800ee3:	d3 e8                	shr    %cl,%eax
  800ee5:	89 e9                	mov    %ebp,%ecx
  800ee7:	09 f0                	or     %esi,%eax
  800ee9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800eed:	f7 74 24 10          	divl   0x10(%esp)
  800ef1:	d3 e6                	shl    %cl,%esi
  800ef3:	89 d1                	mov    %edx,%ecx
  800ef5:	f7 64 24 0c          	mull   0xc(%esp)
  800ef9:	39 d1                	cmp    %edx,%ecx
  800efb:	89 74 24 14          	mov    %esi,0x14(%esp)
  800eff:	89 d7                	mov    %edx,%edi
  800f01:	89 c6                	mov    %eax,%esi
  800f03:	72 0a                	jb     800f0f <__umoddi3+0x12f>
  800f05:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800f09:	73 10                	jae    800f1b <__umoddi3+0x13b>
  800f0b:	39 d1                	cmp    %edx,%ecx
  800f0d:	75 0c                	jne    800f1b <__umoddi3+0x13b>
  800f0f:	89 d7                	mov    %edx,%edi
  800f11:	89 c6                	mov    %eax,%esi
  800f13:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800f17:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800f1b:	89 ca                	mov    %ecx,%edx
  800f1d:	89 e9                	mov    %ebp,%ecx
  800f1f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f23:	29 f0                	sub    %esi,%eax
  800f25:	19 fa                	sbb    %edi,%edx
  800f27:	d3 e8                	shr    %cl,%eax
  800f29:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800f2e:	89 d7                	mov    %edx,%edi
  800f30:	d3 e7                	shl    %cl,%edi
  800f32:	89 e9                	mov    %ebp,%ecx
  800f34:	09 f8                	or     %edi,%eax
  800f36:	d3 ea                	shr    %cl,%edx
  800f38:	83 c4 20             	add    $0x20,%esp
  800f3b:	5e                   	pop    %esi
  800f3c:	5f                   	pop    %edi
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    
  800f3f:	90                   	nop
  800f40:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f44:	29 f9                	sub    %edi,%ecx
  800f46:	19 c6                	sbb    %eax,%esi
  800f48:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800f4c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f50:	e9 ff fe ff ff       	jmp    800e54 <__umoddi3+0x74>
