
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800049:	e8 c6 00 00 00       	call   800114 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
  80007a:	83 c4 10             	add    $0x10,%esp
}
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 42 00 00 00       	call   8000d3 <sys_env_destroy>
  800091:	83 c4 10             	add    $0x10,%esp
}
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7e 17                	jle    80010c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	6a 03                	push   $0x3
  8000fb:	68 6a 0f 80 00       	push   $0x800f6a
  800100:	6a 23                	push   $0x23
  800102:	68 87 0f 80 00       	push   $0x800f87
  800107:	e8 f5 01 00 00       	call   800301 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 02 00 00 00       	mov    $0x2,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_yield>:

void
sys_yield(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
  800158:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015b:	be 00 00 00 00       	mov    $0x0,%esi
  800160:	b8 04 00 00 00       	mov    $0x4,%eax
  800165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016e:	89 f7                	mov    %esi,%edi
  800170:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800172:	85 c0                	test   %eax,%eax
  800174:	7e 17                	jle    80018d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	50                   	push   %eax
  80017a:	6a 04                	push   $0x4
  80017c:	68 6a 0f 80 00       	push   $0x800f6a
  800181:	6a 23                	push   $0x23
  800183:	68 87 0f 80 00       	push   $0x800f87
  800188:	e8 74 01 00 00       	call   800301 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5f                   	pop    %edi
  800193:	5d                   	pop    %ebp
  800194:	c3                   	ret    

00800195 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019e:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001af:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	7e 17                	jle    8001cf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	50                   	push   %eax
  8001bc:	6a 05                	push   $0x5
  8001be:	68 6a 0f 80 00       	push   $0x800f6a
  8001c3:	6a 23                	push   $0x23
  8001c5:	68 87 0f 80 00       	push   $0x800f87
  8001ca:	e8 32 01 00 00       	call   800301 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5e                   	pop    %esi
  8001d4:	5f                   	pop    %edi
  8001d5:	5d                   	pop    %ebp
  8001d6:	c3                   	ret    

008001d7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	57                   	push   %edi
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	89 df                	mov    %ebx,%edi
  8001f2:	89 de                	mov    %ebx,%esi
  8001f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7e 17                	jle    800211 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	50                   	push   %eax
  8001fe:	6a 06                	push   $0x6
  800200:	68 6a 0f 80 00       	push   $0x800f6a
  800205:	6a 23                	push   $0x23
  800207:	68 87 0f 80 00       	push   $0x800f87
  80020c:	e8 f0 00 00 00       	call   800301 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800222:	bb 00 00 00 00       	mov    $0x0,%ebx
  800227:	b8 08 00 00 00       	mov    $0x8,%eax
  80022c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	89 df                	mov    %ebx,%edi
  800234:	89 de                	mov    %ebx,%esi
  800236:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800238:	85 c0                	test   %eax,%eax
  80023a:	7e 17                	jle    800253 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	50                   	push   %eax
  800240:	6a 08                	push   $0x8
  800242:	68 6a 0f 80 00       	push   $0x800f6a
  800247:	6a 23                	push   $0x23
  800249:	68 87 0f 80 00       	push   $0x800f87
  80024e:	e8 ae 00 00 00       	call   800301 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800253:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800256:	5b                   	pop    %ebx
  800257:	5e                   	pop    %esi
  800258:	5f                   	pop    %edi
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	b8 09 00 00 00       	mov    $0x9,%eax
  80026e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	89 df                	mov    %ebx,%edi
  800276:	89 de                	mov    %ebx,%esi
  800278:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027a:	85 c0                	test   %eax,%eax
  80027c:	7e 17                	jle    800295 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	50                   	push   %eax
  800282:	6a 09                	push   $0x9
  800284:	68 6a 0f 80 00       	push   $0x800f6a
  800289:	6a 23                	push   $0x23
  80028b:	68 87 0f 80 00       	push   $0x800f87
  800290:	e8 6c 00 00 00       	call   800301 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800295:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a3:	be 00 00 00 00       	mov    $0x0,%esi
  8002a8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002bb:	5b                   	pop    %ebx
  8002bc:	5e                   	pop    %esi
  8002bd:	5f                   	pop    %edi
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ce:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d6:	89 cb                	mov    %ecx,%ebx
  8002d8:	89 cf                	mov    %ecx,%edi
  8002da:	89 ce                	mov    %ecx,%esi
  8002dc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	7e 17                	jle    8002f9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	50                   	push   %eax
  8002e6:	6a 0c                	push   $0xc
  8002e8:	68 6a 0f 80 00       	push   $0x800f6a
  8002ed:	6a 23                	push   $0x23
  8002ef:	68 87 0f 80 00       	push   $0x800f87
  8002f4:	e8 08 00 00 00       	call   800301 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800306:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800309:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030f:	e8 00 fe ff ff       	call   800114 <sys_getenvid>
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	ff 75 0c             	pushl  0xc(%ebp)
  80031a:	ff 75 08             	pushl  0x8(%ebp)
  80031d:	56                   	push   %esi
  80031e:	50                   	push   %eax
  80031f:	68 98 0f 80 00       	push   $0x800f98
  800324:	e8 b1 00 00 00       	call   8003da <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800329:	83 c4 18             	add    $0x18,%esp
  80032c:	53                   	push   %ebx
  80032d:	ff 75 10             	pushl  0x10(%ebp)
  800330:	e8 54 00 00 00       	call   800389 <vcprintf>
	cprintf("\n");
  800335:	c7 04 24 bc 0f 80 00 	movl   $0x800fbc,(%esp)
  80033c:	e8 99 00 00 00       	call   8003da <cprintf>
  800341:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800344:	cc                   	int3   
  800345:	eb fd                	jmp    800344 <_panic+0x43>

00800347 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	53                   	push   %ebx
  80034b:	83 ec 04             	sub    $0x4,%esp
  80034e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800351:	8b 13                	mov    (%ebx),%edx
  800353:	8d 42 01             	lea    0x1(%edx),%eax
  800356:	89 03                	mov    %eax,(%ebx)
  800358:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800364:	75 1a                	jne    800380 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800366:	83 ec 08             	sub    $0x8,%esp
  800369:	68 ff 00 00 00       	push   $0xff
  80036e:	8d 43 08             	lea    0x8(%ebx),%eax
  800371:	50                   	push   %eax
  800372:	e8 1f fd ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  800377:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80037d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800380:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800392:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800399:	00 00 00 
	b.cnt = 0;
  80039c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a6:	ff 75 0c             	pushl  0xc(%ebp)
  8003a9:	ff 75 08             	pushl  0x8(%ebp)
  8003ac:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b2:	50                   	push   %eax
  8003b3:	68 47 03 80 00       	push   $0x800347
  8003b8:	e8 4f 01 00 00       	call   80050c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003bd:	83 c4 08             	add    $0x8,%esp
  8003c0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003cc:	50                   	push   %eax
  8003cd:	e8 c4 fc ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  8003d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    

008003da <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e3:	50                   	push   %eax
  8003e4:	ff 75 08             	pushl  0x8(%ebp)
  8003e7:	e8 9d ff ff ff       	call   800389 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 1c             	sub    $0x1c,%esp
  8003f7:	89 c7                	mov    %eax,%edi
  8003f9:	89 d6                	mov    %edx,%esi
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800401:	89 d1                	mov    %edx,%ecx
  800403:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800406:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800409:	8b 45 10             	mov    0x10(%ebp),%eax
  80040c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800412:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800419:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80041c:	72 05                	jb     800423 <printnum+0x35>
  80041e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800421:	77 3e                	ja     800461 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800423:	83 ec 0c             	sub    $0xc,%esp
  800426:	ff 75 18             	pushl  0x18(%ebp)
  800429:	83 eb 01             	sub    $0x1,%ebx
  80042c:	53                   	push   %ebx
  80042d:	50                   	push   %eax
  80042e:	83 ec 08             	sub    $0x8,%esp
  800431:	ff 75 e4             	pushl  -0x1c(%ebp)
  800434:	ff 75 e0             	pushl  -0x20(%ebp)
  800437:	ff 75 dc             	pushl  -0x24(%ebp)
  80043a:	ff 75 d8             	pushl  -0x28(%ebp)
  80043d:	e8 6e 08 00 00       	call   800cb0 <__udivdi3>
  800442:	83 c4 18             	add    $0x18,%esp
  800445:	52                   	push   %edx
  800446:	50                   	push   %eax
  800447:	89 f2                	mov    %esi,%edx
  800449:	89 f8                	mov    %edi,%eax
  80044b:	e8 9e ff ff ff       	call   8003ee <printnum>
  800450:	83 c4 20             	add    $0x20,%esp
  800453:	eb 13                	jmp    800468 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	56                   	push   %esi
  800459:	ff 75 18             	pushl  0x18(%ebp)
  80045c:	ff d7                	call   *%edi
  80045e:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800461:	83 eb 01             	sub    $0x1,%ebx
  800464:	85 db                	test   %ebx,%ebx
  800466:	7f ed                	jg     800455 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	56                   	push   %esi
  80046c:	83 ec 04             	sub    $0x4,%esp
  80046f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800472:	ff 75 e0             	pushl  -0x20(%ebp)
  800475:	ff 75 dc             	pushl  -0x24(%ebp)
  800478:	ff 75 d8             	pushl  -0x28(%ebp)
  80047b:	e8 60 09 00 00       	call   800de0 <__umoddi3>
  800480:	83 c4 14             	add    $0x14,%esp
  800483:	0f be 80 be 0f 80 00 	movsbl 0x800fbe(%eax),%eax
  80048a:	50                   	push   %eax
  80048b:	ff d7                	call   *%edi
  80048d:	83 c4 10             	add    $0x10,%esp
}
  800490:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800493:	5b                   	pop    %ebx
  800494:	5e                   	pop    %esi
  800495:	5f                   	pop    %edi
  800496:	5d                   	pop    %ebp
  800497:	c3                   	ret    

00800498 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80049b:	83 fa 01             	cmp    $0x1,%edx
  80049e:	7e 0e                	jle    8004ae <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a0:	8b 10                	mov    (%eax),%edx
  8004a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a5:	89 08                	mov    %ecx,(%eax)
  8004a7:	8b 02                	mov    (%edx),%eax
  8004a9:	8b 52 04             	mov    0x4(%edx),%edx
  8004ac:	eb 22                	jmp    8004d0 <getuint+0x38>
	else if (lflag)
  8004ae:	85 d2                	test   %edx,%edx
  8004b0:	74 10                	je     8004c2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b2:	8b 10                	mov    (%eax),%edx
  8004b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b7:	89 08                	mov    %ecx,(%eax)
  8004b9:	8b 02                	mov    (%edx),%eax
  8004bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c0:	eb 0e                	jmp    8004d0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c7:	89 08                	mov    %ecx,(%eax)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004dc:	8b 10                	mov    (%eax),%edx
  8004de:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e1:	73 0a                	jae    8004ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e6:	89 08                	mov    %ecx,(%eax)
  8004e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004eb:	88 02                	mov    %al,(%edx)
}
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f8:	50                   	push   %eax
  8004f9:	ff 75 10             	pushl  0x10(%ebp)
  8004fc:	ff 75 0c             	pushl  0xc(%ebp)
  8004ff:	ff 75 08             	pushl  0x8(%ebp)
  800502:	e8 05 00 00 00       	call   80050c <vprintfmt>
	va_end(ap);
  800507:	83 c4 10             	add    $0x10,%esp
}
  80050a:	c9                   	leave  
  80050b:	c3                   	ret    

0080050c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80050c:	55                   	push   %ebp
  80050d:	89 e5                	mov    %esp,%ebp
  80050f:	57                   	push   %edi
  800510:	56                   	push   %esi
  800511:	53                   	push   %ebx
  800512:	83 ec 2c             	sub    $0x2c,%esp
  800515:	8b 75 08             	mov    0x8(%ebp),%esi
  800518:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80051e:	eb 12                	jmp    800532 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800520:	85 c0                	test   %eax,%eax
  800522:	0f 84 90 03 00 00    	je     8008b8 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	50                   	push   %eax
  80052d:	ff d6                	call   *%esi
  80052f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800532:	83 c7 01             	add    $0x1,%edi
  800535:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800539:	83 f8 25             	cmp    $0x25,%eax
  80053c:	75 e2                	jne    800520 <vprintfmt+0x14>
  80053e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800542:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800549:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800550:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800557:	ba 00 00 00 00       	mov    $0x0,%edx
  80055c:	eb 07                	jmp    800565 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800561:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8d 47 01             	lea    0x1(%edi),%eax
  800568:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056b:	0f b6 07             	movzbl (%edi),%eax
  80056e:	0f b6 c8             	movzbl %al,%ecx
  800571:	83 e8 23             	sub    $0x23,%eax
  800574:	3c 55                	cmp    $0x55,%al
  800576:	0f 87 21 03 00 00    	ja     80089d <vprintfmt+0x391>
  80057c:	0f b6 c0             	movzbl %al,%eax
  80057f:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800589:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80058d:	eb d6                	jmp    800565 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800592:	b8 00 00 00 00       	mov    $0x0,%eax
  800597:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80059a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80059d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005a1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005a4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005a7:	83 fa 09             	cmp    $0x9,%edx
  8005aa:	77 39                	ja     8005e5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005af:	eb e9                	jmp    80059a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 48 04             	lea    0x4(%eax),%ecx
  8005b7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005c2:	eb 27                	jmp    8005eb <vprintfmt+0xdf>
  8005c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ce:	0f 49 c8             	cmovns %eax,%ecx
  8005d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d7:	eb 8c                	jmp    800565 <vprintfmt+0x59>
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005dc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005e3:	eb 80                	jmp    800565 <vprintfmt+0x59>
  8005e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ef:	0f 89 70 ff ff ff    	jns    800565 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800602:	e9 5e ff ff ff       	jmp    800565 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800607:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80060d:	e9 53 ff ff ff       	jmp    800565 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	ff 30                	pushl  (%eax)
  800621:	ff d6                	call   *%esi
			break;
  800623:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800629:	e9 04 ff ff ff       	jmp    800532 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 00                	mov    (%eax),%eax
  800639:	99                   	cltd   
  80063a:	31 d0                	xor    %edx,%eax
  80063c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063e:	83 f8 09             	cmp    $0x9,%eax
  800641:	7f 0b                	jg     80064e <vprintfmt+0x142>
  800643:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  80064a:	85 d2                	test   %edx,%edx
  80064c:	75 18                	jne    800666 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80064e:	50                   	push   %eax
  80064f:	68 d6 0f 80 00       	push   $0x800fd6
  800654:	53                   	push   %ebx
  800655:	56                   	push   %esi
  800656:	e8 94 fe ff ff       	call   8004ef <printfmt>
  80065b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800661:	e9 cc fe ff ff       	jmp    800532 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800666:	52                   	push   %edx
  800667:	68 df 0f 80 00       	push   $0x800fdf
  80066c:	53                   	push   %ebx
  80066d:	56                   	push   %esi
  80066e:	e8 7c fe ff ff       	call   8004ef <printfmt>
  800673:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800679:	e9 b4 fe ff ff       	jmp    800532 <vprintfmt+0x26>
  80067e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800681:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800684:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8d 50 04             	lea    0x4(%eax),%edx
  80068d:	89 55 14             	mov    %edx,0x14(%ebp)
  800690:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800692:	85 ff                	test   %edi,%edi
  800694:	ba cf 0f 80 00       	mov    $0x800fcf,%edx
  800699:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80069c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006a0:	0f 84 92 00 00 00    	je     800738 <vprintfmt+0x22c>
  8006a6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006aa:	0f 8e 96 00 00 00    	jle    800746 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	51                   	push   %ecx
  8006b4:	57                   	push   %edi
  8006b5:	e8 86 02 00 00       	call   800940 <strnlen>
  8006ba:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006bd:	29 c1                	sub    %eax,%ecx
  8006bf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006c2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006c5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006cc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006cf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d1:	eb 0f                	jmp    8006e2 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006da:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dc:	83 ef 01             	sub    $0x1,%edi
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	85 ff                	test   %edi,%edi
  8006e4:	7f ed                	jg     8006d3 <vprintfmt+0x1c7>
  8006e6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006e9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006ec:	85 c9                	test   %ecx,%ecx
  8006ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f3:	0f 49 c1             	cmovns %ecx,%eax
  8006f6:	29 c1                	sub    %eax,%ecx
  8006f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8006fb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800701:	89 cb                	mov    %ecx,%ebx
  800703:	eb 4d                	jmp    800752 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800705:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800709:	74 1b                	je     800726 <vprintfmt+0x21a>
  80070b:	0f be c0             	movsbl %al,%eax
  80070e:	83 e8 20             	sub    $0x20,%eax
  800711:	83 f8 5e             	cmp    $0x5e,%eax
  800714:	76 10                	jbe    800726 <vprintfmt+0x21a>
					putch('?', putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	ff 75 0c             	pushl  0xc(%ebp)
  80071c:	6a 3f                	push   $0x3f
  80071e:	ff 55 08             	call   *0x8(%ebp)
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	eb 0d                	jmp    800733 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	ff 75 0c             	pushl  0xc(%ebp)
  80072c:	52                   	push   %edx
  80072d:	ff 55 08             	call   *0x8(%ebp)
  800730:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800733:	83 eb 01             	sub    $0x1,%ebx
  800736:	eb 1a                	jmp    800752 <vprintfmt+0x246>
  800738:	89 75 08             	mov    %esi,0x8(%ebp)
  80073b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80073e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800741:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800744:	eb 0c                	jmp    800752 <vprintfmt+0x246>
  800746:	89 75 08             	mov    %esi,0x8(%ebp)
  800749:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800752:	83 c7 01             	add    $0x1,%edi
  800755:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800759:	0f be d0             	movsbl %al,%edx
  80075c:	85 d2                	test   %edx,%edx
  80075e:	74 23                	je     800783 <vprintfmt+0x277>
  800760:	85 f6                	test   %esi,%esi
  800762:	78 a1                	js     800705 <vprintfmt+0x1f9>
  800764:	83 ee 01             	sub    $0x1,%esi
  800767:	79 9c                	jns    800705 <vprintfmt+0x1f9>
  800769:	89 df                	mov    %ebx,%edi
  80076b:	8b 75 08             	mov    0x8(%ebp),%esi
  80076e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800771:	eb 18                	jmp    80078b <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 20                	push   $0x20
  800779:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80077b:	83 ef 01             	sub    $0x1,%edi
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	eb 08                	jmp    80078b <vprintfmt+0x27f>
  800783:	89 df                	mov    %ebx,%edi
  800785:	8b 75 08             	mov    0x8(%ebp),%esi
  800788:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80078b:	85 ff                	test   %edi,%edi
  80078d:	7f e4                	jg     800773 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800792:	e9 9b fd ff ff       	jmp    800532 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800797:	83 fa 01             	cmp    $0x1,%edx
  80079a:	7e 16                	jle    8007b2 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	8d 50 08             	lea    0x8(%eax),%edx
  8007a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a5:	8b 50 04             	mov    0x4(%eax),%edx
  8007a8:	8b 00                	mov    (%eax),%eax
  8007aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007b0:	eb 32                	jmp    8007e4 <vprintfmt+0x2d8>
	else if (lflag)
  8007b2:	85 d2                	test   %edx,%edx
  8007b4:	74 18                	je     8007ce <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8d 50 04             	lea    0x4(%eax),%edx
  8007bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bf:	8b 00                	mov    (%eax),%eax
  8007c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c4:	89 c1                	mov    %eax,%ecx
  8007c6:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007cc:	eb 16                	jmp    8007e4 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8007ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d1:	8d 50 04             	lea    0x4(%eax),%edx
  8007d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d7:	8b 00                	mov    (%eax),%eax
  8007d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007dc:	89 c1                	mov    %eax,%ecx
  8007de:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ea:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007ef:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007f3:	79 74                	jns    800869 <vprintfmt+0x35d>
				putch('-', putdat);
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	53                   	push   %ebx
  8007f9:	6a 2d                	push   $0x2d
  8007fb:	ff d6                	call   *%esi
				num = -(long long) num;
  8007fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800800:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800803:	f7 d8                	neg    %eax
  800805:	83 d2 00             	adc    $0x0,%edx
  800808:	f7 da                	neg    %edx
  80080a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80080d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800812:	eb 55                	jmp    800869 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800814:	8d 45 14             	lea    0x14(%ebp),%eax
  800817:	e8 7c fc ff ff       	call   800498 <getuint>
			base = 10;
  80081c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800821:	eb 46                	jmp    800869 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
  800826:	e8 6d fc ff ff       	call   800498 <getuint>
                        base = 8;
  80082b:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800830:	eb 37                	jmp    800869 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800832:	83 ec 08             	sub    $0x8,%esp
  800835:	53                   	push   %ebx
  800836:	6a 30                	push   $0x30
  800838:	ff d6                	call   *%esi
			putch('x', putdat);
  80083a:	83 c4 08             	add    $0x8,%esp
  80083d:	53                   	push   %ebx
  80083e:	6a 78                	push   $0x78
  800840:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8d 50 04             	lea    0x4(%eax),%edx
  800848:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80084b:	8b 00                	mov    (%eax),%eax
  80084d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800852:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800855:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80085a:	eb 0d                	jmp    800869 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80085c:	8d 45 14             	lea    0x14(%ebp),%eax
  80085f:	e8 34 fc ff ff       	call   800498 <getuint>
			base = 16;
  800864:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800869:	83 ec 0c             	sub    $0xc,%esp
  80086c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800870:	57                   	push   %edi
  800871:	ff 75 e0             	pushl  -0x20(%ebp)
  800874:	51                   	push   %ecx
  800875:	52                   	push   %edx
  800876:	50                   	push   %eax
  800877:	89 da                	mov    %ebx,%edx
  800879:	89 f0                	mov    %esi,%eax
  80087b:	e8 6e fb ff ff       	call   8003ee <printnum>
			break;
  800880:	83 c4 20             	add    $0x20,%esp
  800883:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800886:	e9 a7 fc ff ff       	jmp    800532 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80088b:	83 ec 08             	sub    $0x8,%esp
  80088e:	53                   	push   %ebx
  80088f:	51                   	push   %ecx
  800890:	ff d6                	call   *%esi
			break;
  800892:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800895:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800898:	e9 95 fc ff ff       	jmp    800532 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	53                   	push   %ebx
  8008a1:	6a 25                	push   $0x25
  8008a3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008a5:	83 c4 10             	add    $0x10,%esp
  8008a8:	eb 03                	jmp    8008ad <vprintfmt+0x3a1>
  8008aa:	83 ef 01             	sub    $0x1,%edi
  8008ad:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008b1:	75 f7                	jne    8008aa <vprintfmt+0x39e>
  8008b3:	e9 7a fc ff ff       	jmp    800532 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008bb:	5b                   	pop    %ebx
  8008bc:	5e                   	pop    %esi
  8008bd:	5f                   	pop    %edi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	83 ec 18             	sub    $0x18,%esp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008cf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008d3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	74 26                	je     800907 <vsnprintf+0x47>
  8008e1:	85 d2                	test   %edx,%edx
  8008e3:	7e 22                	jle    800907 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008e5:	ff 75 14             	pushl  0x14(%ebp)
  8008e8:	ff 75 10             	pushl  0x10(%ebp)
  8008eb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ee:	50                   	push   %eax
  8008ef:	68 d2 04 80 00       	push   $0x8004d2
  8008f4:	e8 13 fc ff ff       	call   80050c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008fc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb 05                	jmp    80090c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800907:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80090c:	c9                   	leave  
  80090d:	c3                   	ret    

0080090e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800914:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800917:	50                   	push   %eax
  800918:	ff 75 10             	pushl  0x10(%ebp)
  80091b:	ff 75 0c             	pushl  0xc(%ebp)
  80091e:	ff 75 08             	pushl  0x8(%ebp)
  800921:	e8 9a ff ff ff       	call   8008c0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800926:	c9                   	leave  
  800927:	c3                   	ret    

00800928 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
  800933:	eb 03                	jmp    800938 <strlen+0x10>
		n++;
  800935:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800938:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80093c:	75 f7                	jne    800935 <strlen+0xd>
		n++;
	return n;
}
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800946:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800949:	ba 00 00 00 00       	mov    $0x0,%edx
  80094e:	eb 03                	jmp    800953 <strnlen+0x13>
		n++;
  800950:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800953:	39 c2                	cmp    %eax,%edx
  800955:	74 08                	je     80095f <strnlen+0x1f>
  800957:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80095b:	75 f3                	jne    800950 <strnlen+0x10>
  80095d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	53                   	push   %ebx
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80096b:	89 c2                	mov    %eax,%edx
  80096d:	83 c2 01             	add    $0x1,%edx
  800970:	83 c1 01             	add    $0x1,%ecx
  800973:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800977:	88 5a ff             	mov    %bl,-0x1(%edx)
  80097a:	84 db                	test   %bl,%bl
  80097c:	75 ef                	jne    80096d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80097e:	5b                   	pop    %ebx
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	53                   	push   %ebx
  800985:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800988:	53                   	push   %ebx
  800989:	e8 9a ff ff ff       	call   800928 <strlen>
  80098e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800991:	ff 75 0c             	pushl  0xc(%ebp)
  800994:	01 d8                	add    %ebx,%eax
  800996:	50                   	push   %eax
  800997:	e8 c5 ff ff ff       	call   800961 <strcpy>
	return dst;
}
  80099c:	89 d8                	mov    %ebx,%eax
  80099e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ae:	89 f3                	mov    %esi,%ebx
  8009b0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b3:	89 f2                	mov    %esi,%edx
  8009b5:	eb 0f                	jmp    8009c6 <strncpy+0x23>
		*dst++ = *src;
  8009b7:	83 c2 01             	add    $0x1,%edx
  8009ba:	0f b6 01             	movzbl (%ecx),%eax
  8009bd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c0:	80 39 01             	cmpb   $0x1,(%ecx)
  8009c3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c6:	39 da                	cmp    %ebx,%edx
  8009c8:	75 ed                	jne    8009b7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009ca:	89 f0                	mov    %esi,%eax
  8009cc:	5b                   	pop    %ebx
  8009cd:	5e                   	pop    %esi
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009db:	8b 55 10             	mov    0x10(%ebp),%edx
  8009de:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e0:	85 d2                	test   %edx,%edx
  8009e2:	74 21                	je     800a05 <strlcpy+0x35>
  8009e4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009e8:	89 f2                	mov    %esi,%edx
  8009ea:	eb 09                	jmp    8009f5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ec:	83 c2 01             	add    $0x1,%edx
  8009ef:	83 c1 01             	add    $0x1,%ecx
  8009f2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f5:	39 c2                	cmp    %eax,%edx
  8009f7:	74 09                	je     800a02 <strlcpy+0x32>
  8009f9:	0f b6 19             	movzbl (%ecx),%ebx
  8009fc:	84 db                	test   %bl,%bl
  8009fe:	75 ec                	jne    8009ec <strlcpy+0x1c>
  800a00:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a02:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a05:	29 f0                	sub    %esi,%eax
}
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a11:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a14:	eb 06                	jmp    800a1c <strcmp+0x11>
		p++, q++;
  800a16:	83 c1 01             	add    $0x1,%ecx
  800a19:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a1c:	0f b6 01             	movzbl (%ecx),%eax
  800a1f:	84 c0                	test   %al,%al
  800a21:	74 04                	je     800a27 <strcmp+0x1c>
  800a23:	3a 02                	cmp    (%edx),%al
  800a25:	74 ef                	je     800a16 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a27:	0f b6 c0             	movzbl %al,%eax
  800a2a:	0f b6 12             	movzbl (%edx),%edx
  800a2d:	29 d0                	sub    %edx,%eax
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	53                   	push   %ebx
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
  800a38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3b:	89 c3                	mov    %eax,%ebx
  800a3d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a40:	eb 06                	jmp    800a48 <strncmp+0x17>
		n--, p++, q++;
  800a42:	83 c0 01             	add    $0x1,%eax
  800a45:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a48:	39 d8                	cmp    %ebx,%eax
  800a4a:	74 15                	je     800a61 <strncmp+0x30>
  800a4c:	0f b6 08             	movzbl (%eax),%ecx
  800a4f:	84 c9                	test   %cl,%cl
  800a51:	74 04                	je     800a57 <strncmp+0x26>
  800a53:	3a 0a                	cmp    (%edx),%cl
  800a55:	74 eb                	je     800a42 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a57:	0f b6 00             	movzbl (%eax),%eax
  800a5a:	0f b6 12             	movzbl (%edx),%edx
  800a5d:	29 d0                	sub    %edx,%eax
  800a5f:	eb 05                	jmp    800a66 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a61:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a66:	5b                   	pop    %ebx
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a73:	eb 07                	jmp    800a7c <strchr+0x13>
		if (*s == c)
  800a75:	38 ca                	cmp    %cl,%dl
  800a77:	74 0f                	je     800a88 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a79:	83 c0 01             	add    $0x1,%eax
  800a7c:	0f b6 10             	movzbl (%eax),%edx
  800a7f:	84 d2                	test   %dl,%dl
  800a81:	75 f2                	jne    800a75 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a94:	eb 03                	jmp    800a99 <strfind+0xf>
  800a96:	83 c0 01             	add    $0x1,%eax
  800a99:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a9c:	84 d2                	test   %dl,%dl
  800a9e:	74 04                	je     800aa4 <strfind+0x1a>
  800aa0:	38 ca                	cmp    %cl,%dl
  800aa2:	75 f2                	jne    800a96 <strfind+0xc>
			break;
	return (char *) s;
}
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aaf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab2:	85 c9                	test   %ecx,%ecx
  800ab4:	74 36                	je     800aec <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800abc:	75 28                	jne    800ae6 <memset+0x40>
  800abe:	f6 c1 03             	test   $0x3,%cl
  800ac1:	75 23                	jne    800ae6 <memset+0x40>
		c &= 0xFF;
  800ac3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac7:	89 d3                	mov    %edx,%ebx
  800ac9:	c1 e3 08             	shl    $0x8,%ebx
  800acc:	89 d6                	mov    %edx,%esi
  800ace:	c1 e6 18             	shl    $0x18,%esi
  800ad1:	89 d0                	mov    %edx,%eax
  800ad3:	c1 e0 10             	shl    $0x10,%eax
  800ad6:	09 f0                	or     %esi,%eax
  800ad8:	09 c2                	or     %eax,%edx
  800ada:	89 d0                	mov    %edx,%eax
  800adc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ade:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ae1:	fc                   	cld    
  800ae2:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae4:	eb 06                	jmp    800aec <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae9:	fc                   	cld    
  800aea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aec:	89 f8                	mov    %edi,%eax
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b01:	39 c6                	cmp    %eax,%esi
  800b03:	73 35                	jae    800b3a <memmove+0x47>
  800b05:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b08:	39 d0                	cmp    %edx,%eax
  800b0a:	73 2e                	jae    800b3a <memmove+0x47>
		s += n;
		d += n;
  800b0c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b0f:	89 d6                	mov    %edx,%esi
  800b11:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b13:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b19:	75 13                	jne    800b2e <memmove+0x3b>
  800b1b:	f6 c1 03             	test   $0x3,%cl
  800b1e:	75 0e                	jne    800b2e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b20:	83 ef 04             	sub    $0x4,%edi
  800b23:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b26:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b29:	fd                   	std    
  800b2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2c:	eb 09                	jmp    800b37 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b2e:	83 ef 01             	sub    $0x1,%edi
  800b31:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b34:	fd                   	std    
  800b35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b37:	fc                   	cld    
  800b38:	eb 1d                	jmp    800b57 <memmove+0x64>
  800b3a:	89 f2                	mov    %esi,%edx
  800b3c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3e:	f6 c2 03             	test   $0x3,%dl
  800b41:	75 0f                	jne    800b52 <memmove+0x5f>
  800b43:	f6 c1 03             	test   $0x3,%cl
  800b46:	75 0a                	jne    800b52 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b48:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	fc                   	cld    
  800b4e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b50:	eb 05                	jmp    800b57 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b52:	89 c7                	mov    %eax,%edi
  800b54:	fc                   	cld    
  800b55:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b5e:	ff 75 10             	pushl  0x10(%ebp)
  800b61:	ff 75 0c             	pushl  0xc(%ebp)
  800b64:	ff 75 08             	pushl  0x8(%ebp)
  800b67:	e8 87 ff ff ff       	call   800af3 <memmove>
}
  800b6c:	c9                   	leave  
  800b6d:	c3                   	ret    

00800b6e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	8b 45 08             	mov    0x8(%ebp),%eax
  800b76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b79:	89 c6                	mov    %eax,%esi
  800b7b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7e:	eb 1a                	jmp    800b9a <memcmp+0x2c>
		if (*s1 != *s2)
  800b80:	0f b6 08             	movzbl (%eax),%ecx
  800b83:	0f b6 1a             	movzbl (%edx),%ebx
  800b86:	38 d9                	cmp    %bl,%cl
  800b88:	74 0a                	je     800b94 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b8a:	0f b6 c1             	movzbl %cl,%eax
  800b8d:	0f b6 db             	movzbl %bl,%ebx
  800b90:	29 d8                	sub    %ebx,%eax
  800b92:	eb 0f                	jmp    800ba3 <memcmp+0x35>
		s1++, s2++;
  800b94:	83 c0 01             	add    $0x1,%eax
  800b97:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9a:	39 f0                	cmp    %esi,%eax
  800b9c:	75 e2                	jne    800b80 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bb0:	89 c2                	mov    %eax,%edx
  800bb2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb5:	eb 07                	jmp    800bbe <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb7:	38 08                	cmp    %cl,(%eax)
  800bb9:	74 07                	je     800bc2 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bbb:	83 c0 01             	add    $0x1,%eax
  800bbe:	39 d0                	cmp    %edx,%eax
  800bc0:	72 f5                	jb     800bb7 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd0:	eb 03                	jmp    800bd5 <strtol+0x11>
		s++;
  800bd2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd5:	0f b6 01             	movzbl (%ecx),%eax
  800bd8:	3c 09                	cmp    $0x9,%al
  800bda:	74 f6                	je     800bd2 <strtol+0xe>
  800bdc:	3c 20                	cmp    $0x20,%al
  800bde:	74 f2                	je     800bd2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800be0:	3c 2b                	cmp    $0x2b,%al
  800be2:	75 0a                	jne    800bee <strtol+0x2a>
		s++;
  800be4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bec:	eb 10                	jmp    800bfe <strtol+0x3a>
  800bee:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bf3:	3c 2d                	cmp    $0x2d,%al
  800bf5:	75 07                	jne    800bfe <strtol+0x3a>
		s++, neg = 1;
  800bf7:	8d 49 01             	lea    0x1(%ecx),%ecx
  800bfa:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bfe:	85 db                	test   %ebx,%ebx
  800c00:	0f 94 c0             	sete   %al
  800c03:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c09:	75 19                	jne    800c24 <strtol+0x60>
  800c0b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c0e:	75 14                	jne    800c24 <strtol+0x60>
  800c10:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c14:	0f 85 82 00 00 00    	jne    800c9c <strtol+0xd8>
		s += 2, base = 16;
  800c1a:	83 c1 02             	add    $0x2,%ecx
  800c1d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c22:	eb 16                	jmp    800c3a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c24:	84 c0                	test   %al,%al
  800c26:	74 12                	je     800c3a <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c28:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c30:	75 08                	jne    800c3a <strtol+0x76>
		s++, base = 8;
  800c32:	83 c1 01             	add    $0x1,%ecx
  800c35:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c42:	0f b6 11             	movzbl (%ecx),%edx
  800c45:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c48:	89 f3                	mov    %esi,%ebx
  800c4a:	80 fb 09             	cmp    $0x9,%bl
  800c4d:	77 08                	ja     800c57 <strtol+0x93>
			dig = *s - '0';
  800c4f:	0f be d2             	movsbl %dl,%edx
  800c52:	83 ea 30             	sub    $0x30,%edx
  800c55:	eb 22                	jmp    800c79 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c57:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c5a:	89 f3                	mov    %esi,%ebx
  800c5c:	80 fb 19             	cmp    $0x19,%bl
  800c5f:	77 08                	ja     800c69 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c61:	0f be d2             	movsbl %dl,%edx
  800c64:	83 ea 57             	sub    $0x57,%edx
  800c67:	eb 10                	jmp    800c79 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c69:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c6c:	89 f3                	mov    %esi,%ebx
  800c6e:	80 fb 19             	cmp    $0x19,%bl
  800c71:	77 16                	ja     800c89 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c73:	0f be d2             	movsbl %dl,%edx
  800c76:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c79:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c7c:	7d 0f                	jge    800c8d <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c7e:	83 c1 01             	add    $0x1,%ecx
  800c81:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c85:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c87:	eb b9                	jmp    800c42 <strtol+0x7e>
  800c89:	89 c2                	mov    %eax,%edx
  800c8b:	eb 02                	jmp    800c8f <strtol+0xcb>
  800c8d:	89 c2                	mov    %eax,%edx

	if (endptr)
  800c8f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c93:	74 0d                	je     800ca2 <strtol+0xde>
		*endptr = (char *) s;
  800c95:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c98:	89 0e                	mov    %ecx,(%esi)
  800c9a:	eb 06                	jmp    800ca2 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9c:	84 c0                	test   %al,%al
  800c9e:	75 92                	jne    800c32 <strtol+0x6e>
  800ca0:	eb 98                	jmp    800c3a <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ca2:	f7 da                	neg    %edx
  800ca4:	85 ff                	test   %edi,%edi
  800ca6:	0f 45 c2             	cmovne %edx,%eax
}
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    
  800cae:	66 90                	xchg   %ax,%ax

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
