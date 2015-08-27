
obj/user/badsegment.debug:     file format elf32-i386


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
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 89 04 00 00       	call   800518 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
  800099:	83 c4 10             	add    $0x10,%esp
}
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 0a 1e 80 00       	push   $0x801e0a
  800108:	6a 23                	push   $0x23
  80010a:	68 27 1e 80 00       	push   $0x801e27
  80010f:	e8 44 0f 00 00       	call   801058 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 0a 1e 80 00       	push   $0x801e0a
  800189:	6a 23                	push   $0x23
  80018b:	68 27 1e 80 00       	push   $0x801e27
  800190:	e8 c3 0e 00 00       	call   801058 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 0a 1e 80 00       	push   $0x801e0a
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 27 1e 80 00       	push   $0x801e27
  8001d2:	e8 81 0e 00 00       	call   801058 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 0a 1e 80 00       	push   $0x801e0a
  80020d:	6a 23                	push   $0x23
  80020f:	68 27 1e 80 00       	push   $0x801e27
  800214:	e8 3f 0e 00 00       	call   801058 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 0a 1e 80 00       	push   $0x801e0a
  80024f:	6a 23                	push   $0x23
  800251:	68 27 1e 80 00       	push   $0x801e27
  800256:	e8 fd 0d 00 00       	call   801058 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 0a 1e 80 00       	push   $0x801e0a
  800291:	6a 23                	push   $0x23
  800293:	68 27 1e 80 00       	push   $0x801e27
  800298:	e8 bb 0d 00 00       	call   801058 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 0a 1e 80 00       	push   $0x801e0a
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 27 1e 80 00       	push   $0x801e27
  8002da:	e8 79 0d 00 00       	call   801058 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 0a 1e 80 00       	push   $0x801e0a
  800337:	6a 23                	push   $0x23
  800339:	68 27 1e 80 00       	push   $0x801e27
  80033e:	e8 15 0d 00 00       	call   801058 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	05 00 00 00 30       	add    $0x30000000,%eax
  800356:	c1 e8 0c             	shr    $0xc,%eax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800366:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800378:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037d:	89 c2                	mov    %eax,%edx
  80037f:	c1 ea 16             	shr    $0x16,%edx
  800382:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800389:	f6 c2 01             	test   $0x1,%dl
  80038c:	74 11                	je     80039f <fd_alloc+0x2d>
  80038e:	89 c2                	mov    %eax,%edx
  800390:	c1 ea 0c             	shr    $0xc,%edx
  800393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039a:	f6 c2 01             	test   $0x1,%dl
  80039d:	75 09                	jne    8003a8 <fd_alloc+0x36>
			*fd_store = fd;
  80039f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	eb 17                	jmp    8003bf <fd_alloc+0x4d>
  8003a8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b2:	75 c9                	jne    80037d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c7:	83 f8 1f             	cmp    $0x1f,%eax
  8003ca:	77 36                	ja     800402 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003cc:	c1 e0 0c             	shl    $0xc,%eax
  8003cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 16             	shr    $0x16,%edx
  8003d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	74 24                	je     800409 <fd_lookup+0x48>
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 ea 0c             	shr    $0xc,%edx
  8003ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f1:	f6 c2 01             	test   $0x1,%dl
  8003f4:	74 1a                	je     800410 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800400:	eb 13                	jmp    800415 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800407:	eb 0c                	jmp    800415 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800409:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040e:	eb 05                	jmp    800415 <fd_lookup+0x54>
  800410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800420:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800425:	eb 13                	jmp    80043a <dev_lookup+0x23>
  800427:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042a:	39 08                	cmp    %ecx,(%eax)
  80042c:	75 0c                	jne    80043a <dev_lookup+0x23>
			*dev = devtab[i];
  80042e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800431:	89 01                	mov    %eax,(%ecx)
			return 0;
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	eb 2e                	jmp    800468 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	85 c0                	test   %eax,%eax
  80043e:	75 e7                	jne    800427 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800440:	a1 04 40 80 00       	mov    0x804004,%eax
  800445:	8b 40 48             	mov    0x48(%eax),%eax
  800448:	83 ec 04             	sub    $0x4,%esp
  80044b:	51                   	push   %ecx
  80044c:	50                   	push   %eax
  80044d:	68 38 1e 80 00       	push   $0x801e38
  800452:	e8 da 0c 00 00       	call   801131 <cprintf>
	*dev = 0;
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800468:	c9                   	leave  
  800469:	c3                   	ret    

0080046a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 10             	sub    $0x10,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047b:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80047c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800482:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800485:	50                   	push   %eax
  800486:	e8 36 ff ff ff       	call   8003c1 <fd_lookup>
  80048b:	83 c4 08             	add    $0x8,%esp
  80048e:	85 c0                	test   %eax,%eax
  800490:	78 05                	js     800497 <fd_close+0x2d>
	    || fd != fd2)
  800492:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800495:	74 0c                	je     8004a3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800497:	84 db                	test   %bl,%bl
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	0f 44 c2             	cmove  %edx,%eax
  8004a1:	eb 41                	jmp    8004e4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a9:	50                   	push   %eax
  8004aa:	ff 36                	pushl  (%esi)
  8004ac:	e8 66 ff ff ff       	call   800417 <dev_lookup>
  8004b1:	89 c3                	mov    %eax,%ebx
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	78 1a                	js     8004d4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004bd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	74 0b                	je     8004d4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c9:	83 ec 0c             	sub    $0xc,%esp
  8004cc:	56                   	push   %esi
  8004cd:	ff d0                	call   *%eax
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	56                   	push   %esi
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 00 fd ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	89 d8                	mov    %ebx,%eax
}
  8004e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5e                   	pop    %esi
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f4:	50                   	push   %eax
  8004f5:	ff 75 08             	pushl  0x8(%ebp)
  8004f8:	e8 c4 fe ff ff       	call   8003c1 <fd_lookup>
  8004fd:	89 c2                	mov    %eax,%edx
  8004ff:	83 c4 08             	add    $0x8,%esp
  800502:	85 d2                	test   %edx,%edx
  800504:	78 10                	js     800516 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	6a 01                	push   $0x1
  80050b:	ff 75 f4             	pushl  -0xc(%ebp)
  80050e:	e8 57 ff ff ff       	call   80046a <fd_close>
  800513:	83 c4 10             	add    $0x10,%esp
}
  800516:	c9                   	leave  
  800517:	c3                   	ret    

00800518 <close_all>:

void
close_all(void)
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	53                   	push   %ebx
  80051c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80051f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800524:	83 ec 0c             	sub    $0xc,%esp
  800527:	53                   	push   %ebx
  800528:	e8 be ff ff ff       	call   8004eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052d:	83 c3 01             	add    $0x1,%ebx
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	83 fb 20             	cmp    $0x20,%ebx
  800536:	75 ec                	jne    800524 <close_all+0xc>
		close(i);
}
  800538:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	57                   	push   %edi
  800541:	56                   	push   %esi
  800542:	53                   	push   %ebx
  800543:	83 ec 2c             	sub    $0x2c,%esp
  800546:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800549:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054c:	50                   	push   %eax
  80054d:	ff 75 08             	pushl  0x8(%ebp)
  800550:	e8 6c fe ff ff       	call   8003c1 <fd_lookup>
  800555:	89 c2                	mov    %eax,%edx
  800557:	83 c4 08             	add    $0x8,%esp
  80055a:	85 d2                	test   %edx,%edx
  80055c:	0f 88 c1 00 00 00    	js     800623 <dup+0xe6>
		return r;
	close(newfdnum);
  800562:	83 ec 0c             	sub    $0xc,%esp
  800565:	56                   	push   %esi
  800566:	e8 80 ff ff ff       	call   8004eb <close>

	newfd = INDEX2FD(newfdnum);
  80056b:	89 f3                	mov    %esi,%ebx
  80056d:	c1 e3 0c             	shl    $0xc,%ebx
  800570:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800576:	83 c4 04             	add    $0x4,%esp
  800579:	ff 75 e4             	pushl  -0x1c(%ebp)
  80057c:	e8 da fd ff ff       	call   80035b <fd2data>
  800581:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800583:	89 1c 24             	mov    %ebx,(%esp)
  800586:	e8 d0 fd ff ff       	call   80035b <fd2data>
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800591:	89 f8                	mov    %edi,%eax
  800593:	c1 e8 16             	shr    $0x16,%eax
  800596:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80059d:	a8 01                	test   $0x1,%al
  80059f:	74 37                	je     8005d8 <dup+0x9b>
  8005a1:	89 f8                	mov    %edi,%eax
  8005a3:	c1 e8 0c             	shr    $0xc,%eax
  8005a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ad:	f6 c2 01             	test   $0x1,%dl
  8005b0:	74 26                	je     8005d8 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c5:	6a 00                	push   $0x0
  8005c7:	57                   	push   %edi
  8005c8:	6a 00                	push   $0x0
  8005ca:	e8 ce fb ff ff       	call   80019d <sys_page_map>
  8005cf:	89 c7                	mov    %eax,%edi
  8005d1:	83 c4 20             	add    $0x20,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	78 2e                	js     800606 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005db:	89 d0                	mov    %edx,%eax
  8005dd:	c1 e8 0c             	shr    $0xc,%eax
  8005e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ef:	50                   	push   %eax
  8005f0:	53                   	push   %ebx
  8005f1:	6a 00                	push   $0x0
  8005f3:	52                   	push   %edx
  8005f4:	6a 00                	push   $0x0
  8005f6:	e8 a2 fb ff ff       	call   80019d <sys_page_map>
  8005fb:	89 c7                	mov    %eax,%edi
  8005fd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800600:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800602:	85 ff                	test   %edi,%edi
  800604:	79 1d                	jns    800623 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 00                	push   $0x0
  80060c:	e8 ce fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	ff 75 d4             	pushl  -0x2c(%ebp)
  800617:	6a 00                	push   $0x0
  800619:	e8 c1 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	89 f8                	mov    %edi,%eax
}
  800623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800626:	5b                   	pop    %ebx
  800627:	5e                   	pop    %esi
  800628:	5f                   	pop    %edi
  800629:	5d                   	pop    %ebp
  80062a:	c3                   	ret    

0080062b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	53                   	push   %ebx
  80062f:	83 ec 14             	sub    $0x14,%esp
  800632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800638:	50                   	push   %eax
  800639:	53                   	push   %ebx
  80063a:	e8 82 fd ff ff       	call   8003c1 <fd_lookup>
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	89 c2                	mov    %eax,%edx
  800644:	85 c0                	test   %eax,%eax
  800646:	78 6d                	js     8006b5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800652:	ff 30                	pushl  (%eax)
  800654:	e8 be fd ff ff       	call   800417 <dev_lookup>
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	85 c0                	test   %eax,%eax
  80065e:	78 4c                	js     8006ac <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800663:	8b 42 08             	mov    0x8(%edx),%eax
  800666:	83 e0 03             	and    $0x3,%eax
  800669:	83 f8 01             	cmp    $0x1,%eax
  80066c:	75 21                	jne    80068f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066e:	a1 04 40 80 00       	mov    0x804004,%eax
  800673:	8b 40 48             	mov    0x48(%eax),%eax
  800676:	83 ec 04             	sub    $0x4,%esp
  800679:	53                   	push   %ebx
  80067a:	50                   	push   %eax
  80067b:	68 79 1e 80 00       	push   $0x801e79
  800680:	e8 ac 0a 00 00       	call   801131 <cprintf>
		return -E_INVAL;
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80068d:	eb 26                	jmp    8006b5 <read+0x8a>
	}
	if (!dev->dev_read)
  80068f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800692:	8b 40 08             	mov    0x8(%eax),%eax
  800695:	85 c0                	test   %eax,%eax
  800697:	74 17                	je     8006b0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	ff 75 10             	pushl  0x10(%ebp)
  80069f:	ff 75 0c             	pushl  0xc(%ebp)
  8006a2:	52                   	push   %edx
  8006a3:	ff d0                	call   *%eax
  8006a5:	89 c2                	mov    %eax,%edx
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 09                	jmp    8006b5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ac:	89 c2                	mov    %eax,%edx
  8006ae:	eb 05                	jmp    8006b5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b5:	89 d0                	mov    %edx,%eax
  8006b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	57                   	push   %edi
  8006c0:	56                   	push   %esi
  8006c1:	53                   	push   %ebx
  8006c2:	83 ec 0c             	sub    $0xc,%esp
  8006c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d0:	eb 21                	jmp    8006f3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	29 d8                	sub    %ebx,%eax
  8006d9:	50                   	push   %eax
  8006da:	89 d8                	mov    %ebx,%eax
  8006dc:	03 45 0c             	add    0xc(%ebp),%eax
  8006df:	50                   	push   %eax
  8006e0:	57                   	push   %edi
  8006e1:	e8 45 ff ff ff       	call   80062b <read>
		if (m < 0)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	78 0c                	js     8006f9 <readn+0x3d>
			return m;
		if (m == 0)
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	74 06                	je     8006f7 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f1:	01 c3                	add    %eax,%ebx
  8006f3:	39 f3                	cmp    %esi,%ebx
  8006f5:	72 db                	jb     8006d2 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8006f7:	89 d8                	mov    %ebx,%eax
}
  8006f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	53                   	push   %ebx
  800705:	83 ec 14             	sub    $0x14,%esp
  800708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	53                   	push   %ebx
  800710:	e8 ac fc ff ff       	call   8003c1 <fd_lookup>
  800715:	83 c4 08             	add    $0x8,%esp
  800718:	89 c2                	mov    %eax,%edx
  80071a:	85 c0                	test   %eax,%eax
  80071c:	78 68                	js     800786 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800728:	ff 30                	pushl  (%eax)
  80072a:	e8 e8 fc ff ff       	call   800417 <dev_lookup>
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	85 c0                	test   %eax,%eax
  800734:	78 47                	js     80077d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800739:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80073d:	75 21                	jne    800760 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073f:	a1 04 40 80 00       	mov    0x804004,%eax
  800744:	8b 40 48             	mov    0x48(%eax),%eax
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	53                   	push   %ebx
  80074b:	50                   	push   %eax
  80074c:	68 95 1e 80 00       	push   $0x801e95
  800751:	e8 db 09 00 00       	call   801131 <cprintf>
		return -E_INVAL;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075e:	eb 26                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800760:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800763:	8b 52 0c             	mov    0xc(%edx),%edx
  800766:	85 d2                	test   %edx,%edx
  800768:	74 17                	je     800781 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076a:	83 ec 04             	sub    $0x4,%esp
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	50                   	push   %eax
  800774:	ff d2                	call   *%edx
  800776:	89 c2                	mov    %eax,%edx
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 09                	jmp    800786 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	eb 05                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800781:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800786:	89 d0                	mov    %edx,%eax
  800788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <seek>:

int
seek(int fdnum, off_t offset)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800793:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	ff 75 08             	pushl  0x8(%ebp)
  80079a:	e8 22 fc ff ff       	call   8003c1 <fd_lookup>
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	78 0e                	js     8007b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	83 ec 14             	sub    $0x14,%esp
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	53                   	push   %ebx
  8007c5:	e8 f7 fb ff ff       	call   8003c1 <fd_lookup>
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	78 65                	js     800838 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dd:	ff 30                	pushl  (%eax)
  8007df:	e8 33 fc ff ff       	call   800417 <dev_lookup>
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 44                	js     80082f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f2:	75 21                	jne    800815 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f9:	8b 40 48             	mov    0x48(%eax),%eax
  8007fc:	83 ec 04             	sub    $0x4,%esp
  8007ff:	53                   	push   %ebx
  800800:	50                   	push   %eax
  800801:	68 58 1e 80 00       	push   $0x801e58
  800806:	e8 26 09 00 00       	call   801131 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800813:	eb 23                	jmp    800838 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800815:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800818:	8b 52 18             	mov    0x18(%edx),%edx
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 14                	je     800833 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	50                   	push   %eax
  800826:	ff d2                	call   *%edx
  800828:	89 c2                	mov    %eax,%edx
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	eb 09                	jmp    800838 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	89 c2                	mov    %eax,%edx
  800831:	eb 05                	jmp    800838 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800833:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800838:	89 d0                	mov    %edx,%eax
  80083a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	83 ec 14             	sub    $0x14,%esp
  800846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800849:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084c:	50                   	push   %eax
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 6c fb ff ff       	call   8003c1 <fd_lookup>
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	89 c2                	mov    %eax,%edx
  80085a:	85 c0                	test   %eax,%eax
  80085c:	78 58                	js     8008b6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800864:	50                   	push   %eax
  800865:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800868:	ff 30                	pushl  (%eax)
  80086a:	e8 a8 fb ff ff       	call   800417 <dev_lookup>
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	85 c0                	test   %eax,%eax
  800874:	78 37                	js     8008ad <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800879:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80087d:	74 32                	je     8008b1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800882:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800889:	00 00 00 
	stat->st_isdir = 0;
  80088c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800893:	00 00 00 
	stat->st_dev = dev;
  800896:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a3:	ff 50 14             	call   *0x14(%eax)
  8008a6:	89 c2                	mov    %eax,%edx
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	eb 09                	jmp    8008b6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	eb 05                	jmp    8008b6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b6:	89 d0                	mov    %edx,%eax
  8008b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	6a 00                	push   $0x0
  8008c7:	ff 75 08             	pushl  0x8(%ebp)
  8008ca:	e8 09 02 00 00       	call   800ad8 <open>
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	85 db                	test   %ebx,%ebx
  8008d6:	78 1b                	js     8008f3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	53                   	push   %ebx
  8008df:	e8 5b ff ff ff       	call   80083f <fstat>
  8008e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e6:	89 1c 24             	mov    %ebx,(%esp)
  8008e9:	e8 fd fb ff ff       	call   8004eb <close>
	return r;
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	89 f0                	mov    %esi,%eax
}
  8008f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	89 c6                	mov    %eax,%esi
  800901:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800903:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090a:	75 12                	jne    80091e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090c:	83 ec 0c             	sub    $0xc,%esp
  80090f:	6a 01                	push   $0x1
  800911:	e8 ac 11 00 00       	call   801ac2 <ipc_find_env>
  800916:	a3 00 40 80 00       	mov    %eax,0x804000
  80091b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091e:	6a 07                	push   $0x7
  800920:	68 00 50 80 00       	push   $0x805000
  800925:	56                   	push   %esi
  800926:	ff 35 00 40 80 00    	pushl  0x804000
  80092c:	e8 3d 11 00 00       	call   801a6e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800931:	83 c4 0c             	add    $0xc,%esp
  800934:	6a 00                	push   $0x0
  800936:	53                   	push   %ebx
  800937:	6a 00                	push   $0x0
  800939:	e8 c7 10 00 00       	call   801a05 <ipc_recv>
}
  80093e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 40 0c             	mov    0xc(%eax),%eax
  800951:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095e:	ba 00 00 00 00       	mov    $0x0,%edx
  800963:	b8 02 00 00 00       	mov    $0x2,%eax
  800968:	e8 8d ff ff ff       	call   8008fa <fsipc>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 40 0c             	mov    0xc(%eax),%eax
  80097b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800980:	ba 00 00 00 00       	mov    $0x0,%edx
  800985:	b8 06 00 00 00       	mov    $0x6,%eax
  80098a:	e8 6b ff ff ff       	call   8008fa <fsipc>
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	83 ec 04             	sub    $0x4,%esp
  800998:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b0:	e8 45 ff ff ff       	call   8008fa <fsipc>
  8009b5:	89 c2                	mov    %eax,%edx
  8009b7:	85 d2                	test   %edx,%edx
  8009b9:	78 2c                	js     8009e7 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009bb:	83 ec 08             	sub    $0x8,%esp
  8009be:	68 00 50 80 00       	push   $0x805000
  8009c3:	53                   	push   %ebx
  8009c4:	e8 ef 0c 00 00       	call   8016b8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c9:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d4:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009df:	83 c4 10             	add    $0x10,%esp
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ea:	c9                   	leave  
  8009eb:	c3                   	ret    

008009ec <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	83 ec 0c             	sub    $0xc,%esp
  8009f5:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fe:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800a03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a06:	eb 3d                	jmp    800a45 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800a08:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800a0e:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800a13:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800a16:	83 ec 04             	sub    $0x4,%esp
  800a19:	57                   	push   %edi
  800a1a:	53                   	push   %ebx
  800a1b:	68 08 50 80 00       	push   $0x805008
  800a20:	e8 25 0e 00 00       	call   80184a <memmove>
                fsipcbuf.write.req_n = tmp; 
  800a25:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a30:	b8 04 00 00 00       	mov    $0x4,%eax
  800a35:	e8 c0 fe ff ff       	call   8008fa <fsipc>
  800a3a:	83 c4 10             	add    $0x10,%esp
  800a3d:	85 c0                	test   %eax,%eax
  800a3f:	78 0d                	js     800a4e <devfile_write+0x62>
		        return r;
                n -= tmp;
  800a41:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800a43:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a45:	85 f6                	test   %esi,%esi
  800a47:	75 bf                	jne    800a08 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800a49:	89 d8                	mov    %ebx,%eax
  800a4b:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800a4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5f                   	pop    %edi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 40 0c             	mov    0xc(%eax),%eax
  800a64:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a69:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a74:	b8 03 00 00 00       	mov    $0x3,%eax
  800a79:	e8 7c fe ff ff       	call   8008fa <fsipc>
  800a7e:	89 c3                	mov    %eax,%ebx
  800a80:	85 c0                	test   %eax,%eax
  800a82:	78 4b                	js     800acf <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a84:	39 c6                	cmp    %eax,%esi
  800a86:	73 16                	jae    800a9e <devfile_read+0x48>
  800a88:	68 c4 1e 80 00       	push   $0x801ec4
  800a8d:	68 cb 1e 80 00       	push   $0x801ecb
  800a92:	6a 7c                	push   $0x7c
  800a94:	68 e0 1e 80 00       	push   $0x801ee0
  800a99:	e8 ba 05 00 00       	call   801058 <_panic>
	assert(r <= PGSIZE);
  800a9e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa3:	7e 16                	jle    800abb <devfile_read+0x65>
  800aa5:	68 eb 1e 80 00       	push   $0x801eeb
  800aaa:	68 cb 1e 80 00       	push   $0x801ecb
  800aaf:	6a 7d                	push   $0x7d
  800ab1:	68 e0 1e 80 00       	push   $0x801ee0
  800ab6:	e8 9d 05 00 00       	call   801058 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800abb:	83 ec 04             	sub    $0x4,%esp
  800abe:	50                   	push   %eax
  800abf:	68 00 50 80 00       	push   $0x805000
  800ac4:	ff 75 0c             	pushl  0xc(%ebp)
  800ac7:	e8 7e 0d 00 00       	call   80184a <memmove>
	return r;
  800acc:	83 c4 10             	add    $0x10,%esp
}
  800acf:	89 d8                	mov    %ebx,%eax
  800ad1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	53                   	push   %ebx
  800adc:	83 ec 20             	sub    $0x20,%esp
  800adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae2:	53                   	push   %ebx
  800ae3:	e8 97 0b 00 00       	call   80167f <strlen>
  800ae8:	83 c4 10             	add    $0x10,%esp
  800aeb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af0:	7f 67                	jg     800b59 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af2:	83 ec 0c             	sub    $0xc,%esp
  800af5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af8:	50                   	push   %eax
  800af9:	e8 74 f8 ff ff       	call   800372 <fd_alloc>
  800afe:	83 c4 10             	add    $0x10,%esp
		return r;
  800b01:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b03:	85 c0                	test   %eax,%eax
  800b05:	78 57                	js     800b5e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b07:	83 ec 08             	sub    $0x8,%esp
  800b0a:	53                   	push   %ebx
  800b0b:	68 00 50 80 00       	push   $0x805000
  800b10:	e8 a3 0b 00 00       	call   8016b8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b18:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b20:	b8 01 00 00 00       	mov    $0x1,%eax
  800b25:	e8 d0 fd ff ff       	call   8008fa <fsipc>
  800b2a:	89 c3                	mov    %eax,%ebx
  800b2c:	83 c4 10             	add    $0x10,%esp
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	79 14                	jns    800b47 <open+0x6f>
		fd_close(fd, 0);
  800b33:	83 ec 08             	sub    $0x8,%esp
  800b36:	6a 00                	push   $0x0
  800b38:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3b:	e8 2a f9 ff ff       	call   80046a <fd_close>
		return r;
  800b40:	83 c4 10             	add    $0x10,%esp
  800b43:	89 da                	mov    %ebx,%edx
  800b45:	eb 17                	jmp    800b5e <open+0x86>
	}

	return fd2num(fd);
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4d:	e8 f9 f7 ff ff       	call   80034b <fd2num>
  800b52:	89 c2                	mov    %eax,%edx
  800b54:	83 c4 10             	add    $0x10,%esp
  800b57:	eb 05                	jmp    800b5e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b59:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b5e:	89 d0                	mov    %edx,%eax
  800b60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b70:	b8 08 00 00 00       	mov    $0x8,%eax
  800b75:	e8 80 fd ff ff       	call   8008fa <fsipc>
}
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b84:	83 ec 0c             	sub    $0xc,%esp
  800b87:	ff 75 08             	pushl  0x8(%ebp)
  800b8a:	e8 cc f7 ff ff       	call   80035b <fd2data>
  800b8f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b91:	83 c4 08             	add    $0x8,%esp
  800b94:	68 f7 1e 80 00       	push   $0x801ef7
  800b99:	53                   	push   %ebx
  800b9a:	e8 19 0b 00 00       	call   8016b8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b9f:	8b 56 04             	mov    0x4(%esi),%edx
  800ba2:	89 d0                	mov    %edx,%eax
  800ba4:	2b 06                	sub    (%esi),%eax
  800ba6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb3:	00 00 00 
	stat->st_dev = &devpipe;
  800bb6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bbd:	30 80 00 
	return 0;
}
  800bc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	53                   	push   %ebx
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd6:	53                   	push   %ebx
  800bd7:	6a 00                	push   $0x0
  800bd9:	e8 01 f6 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bde:	89 1c 24             	mov    %ebx,(%esp)
  800be1:	e8 75 f7 ff ff       	call   80035b <fd2data>
  800be6:	83 c4 08             	add    $0x8,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 00                	push   $0x0
  800bec:	e8 ee f5 ff ff       	call   8001df <sys_page_unmap>
}
  800bf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf4:	c9                   	leave  
  800bf5:	c3                   	ret    

00800bf6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
  800bfc:	83 ec 1c             	sub    $0x1c,%esp
  800bff:	89 c6                	mov    %eax,%esi
  800c01:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c04:	a1 04 40 80 00       	mov    0x804004,%eax
  800c09:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	56                   	push   %esi
  800c10:	e8 e5 0e 00 00       	call   801afa <pageref>
  800c15:	89 c7                	mov    %eax,%edi
  800c17:	83 c4 04             	add    $0x4,%esp
  800c1a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c1d:	e8 d8 0e 00 00       	call   801afa <pageref>
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	39 c7                	cmp    %eax,%edi
  800c27:	0f 94 c2             	sete   %dl
  800c2a:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800c2d:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800c33:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800c36:	39 fb                	cmp    %edi,%ebx
  800c38:	74 19                	je     800c53 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  800c3a:	84 d2                	test   %dl,%dl
  800c3c:	74 c6                	je     800c04 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c3e:	8b 51 58             	mov    0x58(%ecx),%edx
  800c41:	50                   	push   %eax
  800c42:	52                   	push   %edx
  800c43:	53                   	push   %ebx
  800c44:	68 fe 1e 80 00       	push   $0x801efe
  800c49:	e8 e3 04 00 00       	call   801131 <cprintf>
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	eb b1                	jmp    800c04 <_pipeisclosed+0xe>
	}
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 28             	sub    $0x28,%esp
  800c64:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c67:	56                   	push   %esi
  800c68:	e8 ee f6 ff ff       	call   80035b <fd2data>
  800c6d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c6f:	83 c4 10             	add    $0x10,%esp
  800c72:	bf 00 00 00 00       	mov    $0x0,%edi
  800c77:	eb 4b                	jmp    800cc4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c79:	89 da                	mov    %ebx,%edx
  800c7b:	89 f0                	mov    %esi,%eax
  800c7d:	e8 74 ff ff ff       	call   800bf6 <_pipeisclosed>
  800c82:	85 c0                	test   %eax,%eax
  800c84:	75 48                	jne    800cce <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c86:	e8 b0 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c8b:	8b 43 04             	mov    0x4(%ebx),%eax
  800c8e:	8b 0b                	mov    (%ebx),%ecx
  800c90:	8d 51 20             	lea    0x20(%ecx),%edx
  800c93:	39 d0                	cmp    %edx,%eax
  800c95:	73 e2                	jae    800c79 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c9e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca1:	89 c2                	mov    %eax,%edx
  800ca3:	c1 fa 1f             	sar    $0x1f,%edx
  800ca6:	89 d1                	mov    %edx,%ecx
  800ca8:	c1 e9 1b             	shr    $0x1b,%ecx
  800cab:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cae:	83 e2 1f             	and    $0x1f,%edx
  800cb1:	29 ca                	sub    %ecx,%edx
  800cb3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cbb:	83 c0 01             	add    $0x1,%eax
  800cbe:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc1:	83 c7 01             	add    $0x1,%edi
  800cc4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cc7:	75 c2                	jne    800c8b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cc9:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccc:	eb 05                	jmp    800cd3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cce:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 18             	sub    $0x18,%esp
  800ce4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ce7:	57                   	push   %edi
  800ce8:	e8 6e f6 ff ff       	call   80035b <fd2data>
  800ced:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cef:	83 c4 10             	add    $0x10,%esp
  800cf2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf7:	eb 3d                	jmp    800d36 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cf9:	85 db                	test   %ebx,%ebx
  800cfb:	74 04                	je     800d01 <devpipe_read+0x26>
				return i;
  800cfd:	89 d8                	mov    %ebx,%eax
  800cff:	eb 44                	jmp    800d45 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d01:	89 f2                	mov    %esi,%edx
  800d03:	89 f8                	mov    %edi,%eax
  800d05:	e8 ec fe ff ff       	call   800bf6 <_pipeisclosed>
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	75 32                	jne    800d40 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d0e:	e8 28 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d13:	8b 06                	mov    (%esi),%eax
  800d15:	3b 46 04             	cmp    0x4(%esi),%eax
  800d18:	74 df                	je     800cf9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d1a:	99                   	cltd   
  800d1b:	c1 ea 1b             	shr    $0x1b,%edx
  800d1e:	01 d0                	add    %edx,%eax
  800d20:	83 e0 1f             	and    $0x1f,%eax
  800d23:	29 d0                	sub    %edx,%eax
  800d25:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d30:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d33:	83 c3 01             	add    $0x1,%ebx
  800d36:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d39:	75 d8                	jne    800d13 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3e:	eb 05                	jmp    800d45 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d40:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d58:	50                   	push   %eax
  800d59:	e8 14 f6 ff ff       	call   800372 <fd_alloc>
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	89 c2                	mov    %eax,%edx
  800d63:	85 c0                	test   %eax,%eax
  800d65:	0f 88 2c 01 00 00    	js     800e97 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d6b:	83 ec 04             	sub    $0x4,%esp
  800d6e:	68 07 04 00 00       	push   $0x407
  800d73:	ff 75 f4             	pushl  -0xc(%ebp)
  800d76:	6a 00                	push   $0x0
  800d78:	e8 dd f3 ff ff       	call   80015a <sys_page_alloc>
  800d7d:	83 c4 10             	add    $0x10,%esp
  800d80:	89 c2                	mov    %eax,%edx
  800d82:	85 c0                	test   %eax,%eax
  800d84:	0f 88 0d 01 00 00    	js     800e97 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d90:	50                   	push   %eax
  800d91:	e8 dc f5 ff ff       	call   800372 <fd_alloc>
  800d96:	89 c3                	mov    %eax,%ebx
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	0f 88 e2 00 00 00    	js     800e85 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da3:	83 ec 04             	sub    $0x4,%esp
  800da6:	68 07 04 00 00       	push   $0x407
  800dab:	ff 75 f0             	pushl  -0x10(%ebp)
  800dae:	6a 00                	push   $0x0
  800db0:	e8 a5 f3 ff ff       	call   80015a <sys_page_alloc>
  800db5:	89 c3                	mov    %eax,%ebx
  800db7:	83 c4 10             	add    $0x10,%esp
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	0f 88 c3 00 00 00    	js     800e85 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc8:	e8 8e f5 ff ff       	call   80035b <fd2data>
  800dcd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcf:	83 c4 0c             	add    $0xc,%esp
  800dd2:	68 07 04 00 00       	push   $0x407
  800dd7:	50                   	push   %eax
  800dd8:	6a 00                	push   $0x0
  800dda:	e8 7b f3 ff ff       	call   80015a <sys_page_alloc>
  800ddf:	89 c3                	mov    %eax,%ebx
  800de1:	83 c4 10             	add    $0x10,%esp
  800de4:	85 c0                	test   %eax,%eax
  800de6:	0f 88 89 00 00 00    	js     800e75 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	ff 75 f0             	pushl  -0x10(%ebp)
  800df2:	e8 64 f5 ff ff       	call   80035b <fd2data>
  800df7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dfe:	50                   	push   %eax
  800dff:	6a 00                	push   $0x0
  800e01:	56                   	push   %esi
  800e02:	6a 00                	push   $0x0
  800e04:	e8 94 f3 ff ff       	call   80019d <sys_page_map>
  800e09:	89 c3                	mov    %eax,%ebx
  800e0b:	83 c4 20             	add    $0x20,%esp
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	78 55                	js     800e67 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e12:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e20:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e27:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e30:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e35:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e3c:	83 ec 0c             	sub    $0xc,%esp
  800e3f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e42:	e8 04 f5 ff ff       	call   80034b <fd2num>
  800e47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e4c:	83 c4 04             	add    $0x4,%esp
  800e4f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e52:	e8 f4 f4 ff ff       	call   80034b <fd2num>
  800e57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e5d:	83 c4 10             	add    $0x10,%esp
  800e60:	ba 00 00 00 00       	mov    $0x0,%edx
  800e65:	eb 30                	jmp    800e97 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e67:	83 ec 08             	sub    $0x8,%esp
  800e6a:	56                   	push   %esi
  800e6b:	6a 00                	push   $0x0
  800e6d:	e8 6d f3 ff ff       	call   8001df <sys_page_unmap>
  800e72:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e75:	83 ec 08             	sub    $0x8,%esp
  800e78:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7b:	6a 00                	push   $0x0
  800e7d:	e8 5d f3 ff ff       	call   8001df <sys_page_unmap>
  800e82:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8b:	6a 00                	push   $0x0
  800e8d:	e8 4d f3 ff ff       	call   8001df <sys_page_unmap>
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e97:	89 d0                	mov    %edx,%eax
  800e99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea9:	50                   	push   %eax
  800eaa:	ff 75 08             	pushl  0x8(%ebp)
  800ead:	e8 0f f5 ff ff       	call   8003c1 <fd_lookup>
  800eb2:	89 c2                	mov    %eax,%edx
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	85 d2                	test   %edx,%edx
  800eb9:	78 18                	js     800ed3 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ebb:	83 ec 0c             	sub    $0xc,%esp
  800ebe:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec1:	e8 95 f4 ff ff       	call   80035b <fd2data>
	return _pipeisclosed(fd, p);
  800ec6:	89 c2                	mov    %eax,%edx
  800ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ecb:	e8 26 fd ff ff       	call   800bf6 <_pipeisclosed>
  800ed0:	83 c4 10             	add    $0x10,%esp
}
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    

00800ed5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee5:	68 16 1f 80 00       	push   $0x801f16
  800eea:	ff 75 0c             	pushl  0xc(%ebp)
  800eed:	e8 c6 07 00 00       	call   8016b8 <strcpy>
	return 0;
}
  800ef2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef7:	c9                   	leave  
  800ef8:	c3                   	ret    

00800ef9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f05:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f10:	eb 2d                	jmp    800f3f <devcons_write+0x46>
		m = n - tot;
  800f12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f15:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f17:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f1a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f1f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	53                   	push   %ebx
  800f26:	03 45 0c             	add    0xc(%ebp),%eax
  800f29:	50                   	push   %eax
  800f2a:	57                   	push   %edi
  800f2b:	e8 1a 09 00 00       	call   80184a <memmove>
		sys_cputs(buf, m);
  800f30:	83 c4 08             	add    $0x8,%esp
  800f33:	53                   	push   %ebx
  800f34:	57                   	push   %edi
  800f35:	e8 64 f1 ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3a:	01 de                	add    %ebx,%esi
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	89 f0                	mov    %esi,%eax
  800f41:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f44:	72 cc                	jb     800f12 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5f                   	pop    %edi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f54:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f59:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f5d:	75 07                	jne    800f66 <devcons_read+0x18>
  800f5f:	eb 28                	jmp    800f89 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f61:	e8 d5 f1 ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f66:	e8 51 f1 ff ff       	call   8000bc <sys_cgetc>
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	74 f2                	je     800f61 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 16                	js     800f89 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f73:	83 f8 04             	cmp    $0x4,%eax
  800f76:	74 0c                	je     800f84 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7b:	88 02                	mov    %al,(%edx)
	return 1;
  800f7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f82:	eb 05                	jmp    800f89 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f84:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f89:	c9                   	leave  
  800f8a:	c3                   	ret    

00800f8b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f91:	8b 45 08             	mov    0x8(%ebp),%eax
  800f94:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f97:	6a 01                	push   $0x1
  800f99:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9c:	50                   	push   %eax
  800f9d:	e8 fc f0 ff ff       	call   80009e <sys_cputs>
  800fa2:	83 c4 10             	add    $0x10,%esp
}
  800fa5:	c9                   	leave  
  800fa6:	c3                   	ret    

00800fa7 <getchar>:

int
getchar(void)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fad:	6a 01                	push   $0x1
  800faf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb2:	50                   	push   %eax
  800fb3:	6a 00                	push   $0x0
  800fb5:	e8 71 f6 ff ff       	call   80062b <read>
	if (r < 0)
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	78 0f                	js     800fd0 <getchar+0x29>
		return r;
	if (r < 1)
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	7e 06                	jle    800fcb <getchar+0x24>
		return -E_EOF;
	return c;
  800fc5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fc9:	eb 05                	jmp    800fd0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fcb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fd0:	c9                   	leave  
  800fd1:	c3                   	ret    

00800fd2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdb:	50                   	push   %eax
  800fdc:	ff 75 08             	pushl  0x8(%ebp)
  800fdf:	e8 dd f3 ff ff       	call   8003c1 <fd_lookup>
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 11                	js     800ffc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff4:	39 10                	cmp    %edx,(%eax)
  800ff6:	0f 94 c0             	sete   %al
  800ff9:	0f b6 c0             	movzbl %al,%eax
}
  800ffc:	c9                   	leave  
  800ffd:	c3                   	ret    

00800ffe <opencons>:

int
opencons(void)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801004:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801007:	50                   	push   %eax
  801008:	e8 65 f3 ff ff       	call   800372 <fd_alloc>
  80100d:	83 c4 10             	add    $0x10,%esp
		return r;
  801010:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801012:	85 c0                	test   %eax,%eax
  801014:	78 3e                	js     801054 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801016:	83 ec 04             	sub    $0x4,%esp
  801019:	68 07 04 00 00       	push   $0x407
  80101e:	ff 75 f4             	pushl  -0xc(%ebp)
  801021:	6a 00                	push   $0x0
  801023:	e8 32 f1 ff ff       	call   80015a <sys_page_alloc>
  801028:	83 c4 10             	add    $0x10,%esp
		return r;
  80102b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80102d:	85 c0                	test   %eax,%eax
  80102f:	78 23                	js     801054 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801031:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801037:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80103c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	50                   	push   %eax
  80104a:	e8 fc f2 ff ff       	call   80034b <fd2num>
  80104f:	89 c2                	mov    %eax,%edx
  801051:	83 c4 10             	add    $0x10,%esp
}
  801054:	89 d0                	mov    %edx,%eax
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80105d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801060:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801066:	e8 b1 f0 ff ff       	call   80011c <sys_getenvid>
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	ff 75 0c             	pushl  0xc(%ebp)
  801071:	ff 75 08             	pushl  0x8(%ebp)
  801074:	56                   	push   %esi
  801075:	50                   	push   %eax
  801076:	68 24 1f 80 00       	push   $0x801f24
  80107b:	e8 b1 00 00 00       	call   801131 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801080:	83 c4 18             	add    $0x18,%esp
  801083:	53                   	push   %ebx
  801084:	ff 75 10             	pushl  0x10(%ebp)
  801087:	e8 54 00 00 00       	call   8010e0 <vcprintf>
	cprintf("\n");
  80108c:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  801093:	e8 99 00 00 00       	call   801131 <cprintf>
  801098:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80109b:	cc                   	int3   
  80109c:	eb fd                	jmp    80109b <_panic+0x43>

0080109e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	53                   	push   %ebx
  8010a2:	83 ec 04             	sub    $0x4,%esp
  8010a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010a8:	8b 13                	mov    (%ebx),%edx
  8010aa:	8d 42 01             	lea    0x1(%edx),%eax
  8010ad:	89 03                	mov    %eax,(%ebx)
  8010af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010bb:	75 1a                	jne    8010d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010bd:	83 ec 08             	sub    $0x8,%esp
  8010c0:	68 ff 00 00 00       	push   $0xff
  8010c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8010c8:	50                   	push   %eax
  8010c9:	e8 d0 ef ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8010ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010de:	c9                   	leave  
  8010df:	c3                   	ret    

008010e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010f0:	00 00 00 
	b.cnt = 0;
  8010f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010fd:	ff 75 0c             	pushl  0xc(%ebp)
  801100:	ff 75 08             	pushl  0x8(%ebp)
  801103:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801109:	50                   	push   %eax
  80110a:	68 9e 10 80 00       	push   $0x80109e
  80110f:	e8 4f 01 00 00       	call   801263 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801114:	83 c4 08             	add    $0x8,%esp
  801117:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80111d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801123:	50                   	push   %eax
  801124:	e8 75 ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  801129:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80112f:	c9                   	leave  
  801130:	c3                   	ret    

00801131 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801137:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80113a:	50                   	push   %eax
  80113b:	ff 75 08             	pushl  0x8(%ebp)
  80113e:	e8 9d ff ff ff       	call   8010e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  801143:	c9                   	leave  
  801144:	c3                   	ret    

00801145 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	57                   	push   %edi
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
  80114b:	83 ec 1c             	sub    $0x1c,%esp
  80114e:	89 c7                	mov    %eax,%edi
  801150:	89 d6                	mov    %edx,%esi
  801152:	8b 45 08             	mov    0x8(%ebp),%eax
  801155:	8b 55 0c             	mov    0xc(%ebp),%edx
  801158:	89 d1                	mov    %edx,%ecx
  80115a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80115d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801160:	8b 45 10             	mov    0x10(%ebp),%eax
  801163:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801166:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801169:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801170:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801173:	72 05                	jb     80117a <printnum+0x35>
  801175:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801178:	77 3e                	ja     8011b8 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	ff 75 18             	pushl  0x18(%ebp)
  801180:	83 eb 01             	sub    $0x1,%ebx
  801183:	53                   	push   %ebx
  801184:	50                   	push   %eax
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118b:	ff 75 e0             	pushl  -0x20(%ebp)
  80118e:	ff 75 dc             	pushl  -0x24(%ebp)
  801191:	ff 75 d8             	pushl  -0x28(%ebp)
  801194:	e8 a7 09 00 00       	call   801b40 <__udivdi3>
  801199:	83 c4 18             	add    $0x18,%esp
  80119c:	52                   	push   %edx
  80119d:	50                   	push   %eax
  80119e:	89 f2                	mov    %esi,%edx
  8011a0:	89 f8                	mov    %edi,%eax
  8011a2:	e8 9e ff ff ff       	call   801145 <printnum>
  8011a7:	83 c4 20             	add    $0x20,%esp
  8011aa:	eb 13                	jmp    8011bf <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011ac:	83 ec 08             	sub    $0x8,%esp
  8011af:	56                   	push   %esi
  8011b0:	ff 75 18             	pushl  0x18(%ebp)
  8011b3:	ff d7                	call   *%edi
  8011b5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011b8:	83 eb 01             	sub    $0x1,%ebx
  8011bb:	85 db                	test   %ebx,%ebx
  8011bd:	7f ed                	jg     8011ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011bf:	83 ec 08             	sub    $0x8,%esp
  8011c2:	56                   	push   %esi
  8011c3:	83 ec 04             	sub    $0x4,%esp
  8011c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8011cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8011cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8011d2:	e8 99 0a 00 00       	call   801c70 <__umoddi3>
  8011d7:	83 c4 14             	add    $0x14,%esp
  8011da:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  8011e1:	50                   	push   %eax
  8011e2:	ff d7                	call   *%edi
  8011e4:	83 c4 10             	add    $0x10,%esp
}
  8011e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ea:	5b                   	pop    %ebx
  8011eb:	5e                   	pop    %esi
  8011ec:	5f                   	pop    %edi
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011f2:	83 fa 01             	cmp    $0x1,%edx
  8011f5:	7e 0e                	jle    801205 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011f7:	8b 10                	mov    (%eax),%edx
  8011f9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011fc:	89 08                	mov    %ecx,(%eax)
  8011fe:	8b 02                	mov    (%edx),%eax
  801200:	8b 52 04             	mov    0x4(%edx),%edx
  801203:	eb 22                	jmp    801227 <getuint+0x38>
	else if (lflag)
  801205:	85 d2                	test   %edx,%edx
  801207:	74 10                	je     801219 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801209:	8b 10                	mov    (%eax),%edx
  80120b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80120e:	89 08                	mov    %ecx,(%eax)
  801210:	8b 02                	mov    (%edx),%eax
  801212:	ba 00 00 00 00       	mov    $0x0,%edx
  801217:	eb 0e                	jmp    801227 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801219:	8b 10                	mov    (%eax),%edx
  80121b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80121e:	89 08                	mov    %ecx,(%eax)
  801220:	8b 02                	mov    (%edx),%eax
  801222:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80122f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801233:	8b 10                	mov    (%eax),%edx
  801235:	3b 50 04             	cmp    0x4(%eax),%edx
  801238:	73 0a                	jae    801244 <sprintputch+0x1b>
		*b->buf++ = ch;
  80123a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80123d:	89 08                	mov    %ecx,(%eax)
  80123f:	8b 45 08             	mov    0x8(%ebp),%eax
  801242:	88 02                	mov    %al,(%edx)
}
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    

00801246 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80124c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80124f:	50                   	push   %eax
  801250:	ff 75 10             	pushl  0x10(%ebp)
  801253:	ff 75 0c             	pushl  0xc(%ebp)
  801256:	ff 75 08             	pushl  0x8(%ebp)
  801259:	e8 05 00 00 00       	call   801263 <vprintfmt>
	va_end(ap);
  80125e:	83 c4 10             	add    $0x10,%esp
}
  801261:	c9                   	leave  
  801262:	c3                   	ret    

00801263 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	57                   	push   %edi
  801267:	56                   	push   %esi
  801268:	53                   	push   %ebx
  801269:	83 ec 2c             	sub    $0x2c,%esp
  80126c:	8b 75 08             	mov    0x8(%ebp),%esi
  80126f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801272:	8b 7d 10             	mov    0x10(%ebp),%edi
  801275:	eb 12                	jmp    801289 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801277:	85 c0                	test   %eax,%eax
  801279:	0f 84 90 03 00 00    	je     80160f <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	53                   	push   %ebx
  801283:	50                   	push   %eax
  801284:	ff d6                	call   *%esi
  801286:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801289:	83 c7 01             	add    $0x1,%edi
  80128c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801290:	83 f8 25             	cmp    $0x25,%eax
  801293:	75 e2                	jne    801277 <vprintfmt+0x14>
  801295:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801299:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012a0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012a7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b3:	eb 07                	jmp    8012bc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012b8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bc:	8d 47 01             	lea    0x1(%edi),%eax
  8012bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c2:	0f b6 07             	movzbl (%edi),%eax
  8012c5:	0f b6 c8             	movzbl %al,%ecx
  8012c8:	83 e8 23             	sub    $0x23,%eax
  8012cb:	3c 55                	cmp    $0x55,%al
  8012cd:	0f 87 21 03 00 00    	ja     8015f4 <vprintfmt+0x391>
  8012d3:	0f b6 c0             	movzbl %al,%eax
  8012d6:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8012dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012e0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012e4:	eb d6                	jmp    8012bc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012f1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012f4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012f8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012fb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012fe:	83 fa 09             	cmp    $0x9,%edx
  801301:	77 39                	ja     80133c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801303:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801306:	eb e9                	jmp    8012f1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801308:	8b 45 14             	mov    0x14(%ebp),%eax
  80130b:	8d 48 04             	lea    0x4(%eax),%ecx
  80130e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801311:	8b 00                	mov    (%eax),%eax
  801313:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801316:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801319:	eb 27                	jmp    801342 <vprintfmt+0xdf>
  80131b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80131e:	85 c0                	test   %eax,%eax
  801320:	b9 00 00 00 00       	mov    $0x0,%ecx
  801325:	0f 49 c8             	cmovns %eax,%ecx
  801328:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80132e:	eb 8c                	jmp    8012bc <vprintfmt+0x59>
  801330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801333:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80133a:	eb 80                	jmp    8012bc <vprintfmt+0x59>
  80133c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80133f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801342:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801346:	0f 89 70 ff ff ff    	jns    8012bc <vprintfmt+0x59>
				width = precision, precision = -1;
  80134c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80134f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801352:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801359:	e9 5e ff ff ff       	jmp    8012bc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80135e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801364:	e9 53 ff ff ff       	jmp    8012bc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801369:	8b 45 14             	mov    0x14(%ebp),%eax
  80136c:	8d 50 04             	lea    0x4(%eax),%edx
  80136f:	89 55 14             	mov    %edx,0x14(%ebp)
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	53                   	push   %ebx
  801376:	ff 30                	pushl  (%eax)
  801378:	ff d6                	call   *%esi
			break;
  80137a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801380:	e9 04 ff ff ff       	jmp    801289 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801385:	8b 45 14             	mov    0x14(%ebp),%eax
  801388:	8d 50 04             	lea    0x4(%eax),%edx
  80138b:	89 55 14             	mov    %edx,0x14(%ebp)
  80138e:	8b 00                	mov    (%eax),%eax
  801390:	99                   	cltd   
  801391:	31 d0                	xor    %edx,%eax
  801393:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801395:	83 f8 0f             	cmp    $0xf,%eax
  801398:	7f 0b                	jg     8013a5 <vprintfmt+0x142>
  80139a:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  8013a1:	85 d2                	test   %edx,%edx
  8013a3:	75 18                	jne    8013bd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013a5:	50                   	push   %eax
  8013a6:	68 5f 1f 80 00       	push   $0x801f5f
  8013ab:	53                   	push   %ebx
  8013ac:	56                   	push   %esi
  8013ad:	e8 94 fe ff ff       	call   801246 <printfmt>
  8013b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013b8:	e9 cc fe ff ff       	jmp    801289 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013bd:	52                   	push   %edx
  8013be:	68 dd 1e 80 00       	push   $0x801edd
  8013c3:	53                   	push   %ebx
  8013c4:	56                   	push   %esi
  8013c5:	e8 7c fe ff ff       	call   801246 <printfmt>
  8013ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013d0:	e9 b4 fe ff ff       	jmp    801289 <vprintfmt+0x26>
  8013d5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013db:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013de:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e1:	8d 50 04             	lea    0x4(%eax),%edx
  8013e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013e9:	85 ff                	test   %edi,%edi
  8013eb:	ba 58 1f 80 00       	mov    $0x801f58,%edx
  8013f0:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8013f3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013f7:	0f 84 92 00 00 00    	je     80148f <vprintfmt+0x22c>
  8013fd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801401:	0f 8e 96 00 00 00    	jle    80149d <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	51                   	push   %ecx
  80140b:	57                   	push   %edi
  80140c:	e8 86 02 00 00       	call   801697 <strnlen>
  801411:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801414:	29 c1                	sub    %eax,%ecx
  801416:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801419:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80141c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801420:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801423:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801426:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801428:	eb 0f                	jmp    801439 <vprintfmt+0x1d6>
					putch(padc, putdat);
  80142a:	83 ec 08             	sub    $0x8,%esp
  80142d:	53                   	push   %ebx
  80142e:	ff 75 e0             	pushl  -0x20(%ebp)
  801431:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801433:	83 ef 01             	sub    $0x1,%edi
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	85 ff                	test   %edi,%edi
  80143b:	7f ed                	jg     80142a <vprintfmt+0x1c7>
  80143d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801440:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801443:	85 c9                	test   %ecx,%ecx
  801445:	b8 00 00 00 00       	mov    $0x0,%eax
  80144a:	0f 49 c1             	cmovns %ecx,%eax
  80144d:	29 c1                	sub    %eax,%ecx
  80144f:	89 75 08             	mov    %esi,0x8(%ebp)
  801452:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801455:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801458:	89 cb                	mov    %ecx,%ebx
  80145a:	eb 4d                	jmp    8014a9 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80145c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801460:	74 1b                	je     80147d <vprintfmt+0x21a>
  801462:	0f be c0             	movsbl %al,%eax
  801465:	83 e8 20             	sub    $0x20,%eax
  801468:	83 f8 5e             	cmp    $0x5e,%eax
  80146b:	76 10                	jbe    80147d <vprintfmt+0x21a>
					putch('?', putdat);
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	ff 75 0c             	pushl  0xc(%ebp)
  801473:	6a 3f                	push   $0x3f
  801475:	ff 55 08             	call   *0x8(%ebp)
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	eb 0d                	jmp    80148a <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	ff 75 0c             	pushl  0xc(%ebp)
  801483:	52                   	push   %edx
  801484:	ff 55 08             	call   *0x8(%ebp)
  801487:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80148a:	83 eb 01             	sub    $0x1,%ebx
  80148d:	eb 1a                	jmp    8014a9 <vprintfmt+0x246>
  80148f:	89 75 08             	mov    %esi,0x8(%ebp)
  801492:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801498:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80149b:	eb 0c                	jmp    8014a9 <vprintfmt+0x246>
  80149d:	89 75 08             	mov    %esi,0x8(%ebp)
  8014a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a9:	83 c7 01             	add    $0x1,%edi
  8014ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014b0:	0f be d0             	movsbl %al,%edx
  8014b3:	85 d2                	test   %edx,%edx
  8014b5:	74 23                	je     8014da <vprintfmt+0x277>
  8014b7:	85 f6                	test   %esi,%esi
  8014b9:	78 a1                	js     80145c <vprintfmt+0x1f9>
  8014bb:	83 ee 01             	sub    $0x1,%esi
  8014be:	79 9c                	jns    80145c <vprintfmt+0x1f9>
  8014c0:	89 df                	mov    %ebx,%edi
  8014c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c8:	eb 18                	jmp    8014e2 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	53                   	push   %ebx
  8014ce:	6a 20                	push   $0x20
  8014d0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014d2:	83 ef 01             	sub    $0x1,%edi
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	eb 08                	jmp    8014e2 <vprintfmt+0x27f>
  8014da:	89 df                	mov    %ebx,%edi
  8014dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8014df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e2:	85 ff                	test   %edi,%edi
  8014e4:	7f e4                	jg     8014ca <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014e9:	e9 9b fd ff ff       	jmp    801289 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014ee:	83 fa 01             	cmp    $0x1,%edx
  8014f1:	7e 16                	jle    801509 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8014f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f6:	8d 50 08             	lea    0x8(%eax),%edx
  8014f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8014fc:	8b 50 04             	mov    0x4(%eax),%edx
  8014ff:	8b 00                	mov    (%eax),%eax
  801501:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801504:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801507:	eb 32                	jmp    80153b <vprintfmt+0x2d8>
	else if (lflag)
  801509:	85 d2                	test   %edx,%edx
  80150b:	74 18                	je     801525 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80150d:	8b 45 14             	mov    0x14(%ebp),%eax
  801510:	8d 50 04             	lea    0x4(%eax),%edx
  801513:	89 55 14             	mov    %edx,0x14(%ebp)
  801516:	8b 00                	mov    (%eax),%eax
  801518:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151b:	89 c1                	mov    %eax,%ecx
  80151d:	c1 f9 1f             	sar    $0x1f,%ecx
  801520:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801523:	eb 16                	jmp    80153b <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801525:	8b 45 14             	mov    0x14(%ebp),%eax
  801528:	8d 50 04             	lea    0x4(%eax),%edx
  80152b:	89 55 14             	mov    %edx,0x14(%ebp)
  80152e:	8b 00                	mov    (%eax),%eax
  801530:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801533:	89 c1                	mov    %eax,%ecx
  801535:	c1 f9 1f             	sar    $0x1f,%ecx
  801538:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80153b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80153e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801541:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801546:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80154a:	79 74                	jns    8015c0 <vprintfmt+0x35d>
				putch('-', putdat);
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	53                   	push   %ebx
  801550:	6a 2d                	push   $0x2d
  801552:	ff d6                	call   *%esi
				num = -(long long) num;
  801554:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801557:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80155a:	f7 d8                	neg    %eax
  80155c:	83 d2 00             	adc    $0x0,%edx
  80155f:	f7 da                	neg    %edx
  801561:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801564:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801569:	eb 55                	jmp    8015c0 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80156b:	8d 45 14             	lea    0x14(%ebp),%eax
  80156e:	e8 7c fc ff ff       	call   8011ef <getuint>
			base = 10;
  801573:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801578:	eb 46                	jmp    8015c0 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80157a:	8d 45 14             	lea    0x14(%ebp),%eax
  80157d:	e8 6d fc ff ff       	call   8011ef <getuint>
                        base = 8;
  801582:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801587:	eb 37                	jmp    8015c0 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	53                   	push   %ebx
  80158d:	6a 30                	push   $0x30
  80158f:	ff d6                	call   *%esi
			putch('x', putdat);
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	53                   	push   %ebx
  801595:	6a 78                	push   $0x78
  801597:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801599:	8b 45 14             	mov    0x14(%ebp),%eax
  80159c:	8d 50 04             	lea    0x4(%eax),%edx
  80159f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015a2:	8b 00                	mov    (%eax),%eax
  8015a4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015a9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015ac:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015b1:	eb 0d                	jmp    8015c0 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b6:	e8 34 fc ff ff       	call   8011ef <getuint>
			base = 16;
  8015bb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015c0:	83 ec 0c             	sub    $0xc,%esp
  8015c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015c7:	57                   	push   %edi
  8015c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015cb:	51                   	push   %ecx
  8015cc:	52                   	push   %edx
  8015cd:	50                   	push   %eax
  8015ce:	89 da                	mov    %ebx,%edx
  8015d0:	89 f0                	mov    %esi,%eax
  8015d2:	e8 6e fb ff ff       	call   801145 <printnum>
			break;
  8015d7:	83 c4 20             	add    $0x20,%esp
  8015da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015dd:	e9 a7 fc ff ff       	jmp    801289 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	53                   	push   %ebx
  8015e6:	51                   	push   %ecx
  8015e7:	ff d6                	call   *%esi
			break;
  8015e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015ef:	e9 95 fc ff ff       	jmp    801289 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	53                   	push   %ebx
  8015f8:	6a 25                	push   $0x25
  8015fa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	eb 03                	jmp    801604 <vprintfmt+0x3a1>
  801601:	83 ef 01             	sub    $0x1,%edi
  801604:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801608:	75 f7                	jne    801601 <vprintfmt+0x39e>
  80160a:	e9 7a fc ff ff       	jmp    801289 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80160f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801612:	5b                   	pop    %ebx
  801613:	5e                   	pop    %esi
  801614:	5f                   	pop    %edi
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    

00801617 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	83 ec 18             	sub    $0x18,%esp
  80161d:	8b 45 08             	mov    0x8(%ebp),%eax
  801620:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801623:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801626:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80162a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80162d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801634:	85 c0                	test   %eax,%eax
  801636:	74 26                	je     80165e <vsnprintf+0x47>
  801638:	85 d2                	test   %edx,%edx
  80163a:	7e 22                	jle    80165e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80163c:	ff 75 14             	pushl  0x14(%ebp)
  80163f:	ff 75 10             	pushl  0x10(%ebp)
  801642:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801645:	50                   	push   %eax
  801646:	68 29 12 80 00       	push   $0x801229
  80164b:	e8 13 fc ff ff       	call   801263 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801650:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801653:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	eb 05                	jmp    801663 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80165e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801663:	c9                   	leave  
  801664:	c3                   	ret    

00801665 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80166b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80166e:	50                   	push   %eax
  80166f:	ff 75 10             	pushl  0x10(%ebp)
  801672:	ff 75 0c             	pushl  0xc(%ebp)
  801675:	ff 75 08             	pushl  0x8(%ebp)
  801678:	e8 9a ff ff ff       	call   801617 <vsnprintf>
	va_end(ap);

	return rc;
}
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801685:	b8 00 00 00 00       	mov    $0x0,%eax
  80168a:	eb 03                	jmp    80168f <strlen+0x10>
		n++;
  80168c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80168f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801693:	75 f7                	jne    80168c <strlen+0xd>
		n++;
	return n;
}
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a5:	eb 03                	jmp    8016aa <strnlen+0x13>
		n++;
  8016a7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016aa:	39 c2                	cmp    %eax,%edx
  8016ac:	74 08                	je     8016b6 <strnlen+0x1f>
  8016ae:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016b2:	75 f3                	jne    8016a7 <strnlen+0x10>
  8016b4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016b6:	5d                   	pop    %ebp
  8016b7:	c3                   	ret    

008016b8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	53                   	push   %ebx
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	83 c2 01             	add    $0x1,%edx
  8016c7:	83 c1 01             	add    $0x1,%ecx
  8016ca:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016ce:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016d1:	84 db                	test   %bl,%bl
  8016d3:	75 ef                	jne    8016c4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016d5:	5b                   	pop    %ebx
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	53                   	push   %ebx
  8016dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016df:	53                   	push   %ebx
  8016e0:	e8 9a ff ff ff       	call   80167f <strlen>
  8016e5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016e8:	ff 75 0c             	pushl  0xc(%ebp)
  8016eb:	01 d8                	add    %ebx,%eax
  8016ed:	50                   	push   %eax
  8016ee:	e8 c5 ff ff ff       	call   8016b8 <strcpy>
	return dst;
}
  8016f3:	89 d8                	mov    %ebx,%eax
  8016f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	56                   	push   %esi
  8016fe:	53                   	push   %ebx
  8016ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801702:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801705:	89 f3                	mov    %esi,%ebx
  801707:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170a:	89 f2                	mov    %esi,%edx
  80170c:	eb 0f                	jmp    80171d <strncpy+0x23>
		*dst++ = *src;
  80170e:	83 c2 01             	add    $0x1,%edx
  801711:	0f b6 01             	movzbl (%ecx),%eax
  801714:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801717:	80 39 01             	cmpb   $0x1,(%ecx)
  80171a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80171d:	39 da                	cmp    %ebx,%edx
  80171f:	75 ed                	jne    80170e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801721:	89 f0                	mov    %esi,%eax
  801723:	5b                   	pop    %ebx
  801724:	5e                   	pop    %esi
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	56                   	push   %esi
  80172b:	53                   	push   %ebx
  80172c:	8b 75 08             	mov    0x8(%ebp),%esi
  80172f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801732:	8b 55 10             	mov    0x10(%ebp),%edx
  801735:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801737:	85 d2                	test   %edx,%edx
  801739:	74 21                	je     80175c <strlcpy+0x35>
  80173b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80173f:	89 f2                	mov    %esi,%edx
  801741:	eb 09                	jmp    80174c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801743:	83 c2 01             	add    $0x1,%edx
  801746:	83 c1 01             	add    $0x1,%ecx
  801749:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80174c:	39 c2                	cmp    %eax,%edx
  80174e:	74 09                	je     801759 <strlcpy+0x32>
  801750:	0f b6 19             	movzbl (%ecx),%ebx
  801753:	84 db                	test   %bl,%bl
  801755:	75 ec                	jne    801743 <strlcpy+0x1c>
  801757:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801759:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80175c:	29 f0                	sub    %esi,%eax
}
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801768:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80176b:	eb 06                	jmp    801773 <strcmp+0x11>
		p++, q++;
  80176d:	83 c1 01             	add    $0x1,%ecx
  801770:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801773:	0f b6 01             	movzbl (%ecx),%eax
  801776:	84 c0                	test   %al,%al
  801778:	74 04                	je     80177e <strcmp+0x1c>
  80177a:	3a 02                	cmp    (%edx),%al
  80177c:	74 ef                	je     80176d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80177e:	0f b6 c0             	movzbl %al,%eax
  801781:	0f b6 12             	movzbl (%edx),%edx
  801784:	29 d0                	sub    %edx,%eax
}
  801786:	5d                   	pop    %ebp
  801787:	c3                   	ret    

00801788 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801792:	89 c3                	mov    %eax,%ebx
  801794:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801797:	eb 06                	jmp    80179f <strncmp+0x17>
		n--, p++, q++;
  801799:	83 c0 01             	add    $0x1,%eax
  80179c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80179f:	39 d8                	cmp    %ebx,%eax
  8017a1:	74 15                	je     8017b8 <strncmp+0x30>
  8017a3:	0f b6 08             	movzbl (%eax),%ecx
  8017a6:	84 c9                	test   %cl,%cl
  8017a8:	74 04                	je     8017ae <strncmp+0x26>
  8017aa:	3a 0a                	cmp    (%edx),%cl
  8017ac:	74 eb                	je     801799 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ae:	0f b6 00             	movzbl (%eax),%eax
  8017b1:	0f b6 12             	movzbl (%edx),%edx
  8017b4:	29 d0                	sub    %edx,%eax
  8017b6:	eb 05                	jmp    8017bd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017bd:	5b                   	pop    %ebx
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ca:	eb 07                	jmp    8017d3 <strchr+0x13>
		if (*s == c)
  8017cc:	38 ca                	cmp    %cl,%dl
  8017ce:	74 0f                	je     8017df <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017d0:	83 c0 01             	add    $0x1,%eax
  8017d3:	0f b6 10             	movzbl (%eax),%edx
  8017d6:	84 d2                	test   %dl,%dl
  8017d8:	75 f2                	jne    8017cc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    

008017e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017eb:	eb 03                	jmp    8017f0 <strfind+0xf>
  8017ed:	83 c0 01             	add    $0x1,%eax
  8017f0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f3:	84 d2                	test   %dl,%dl
  8017f5:	74 04                	je     8017fb <strfind+0x1a>
  8017f7:	38 ca                	cmp    %cl,%dl
  8017f9:	75 f2                	jne    8017ed <strfind+0xc>
			break;
	return (char *) s;
}
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	57                   	push   %edi
  801801:	56                   	push   %esi
  801802:	53                   	push   %ebx
  801803:	8b 7d 08             	mov    0x8(%ebp),%edi
  801806:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801809:	85 c9                	test   %ecx,%ecx
  80180b:	74 36                	je     801843 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80180d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801813:	75 28                	jne    80183d <memset+0x40>
  801815:	f6 c1 03             	test   $0x3,%cl
  801818:	75 23                	jne    80183d <memset+0x40>
		c &= 0xFF;
  80181a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80181e:	89 d3                	mov    %edx,%ebx
  801820:	c1 e3 08             	shl    $0x8,%ebx
  801823:	89 d6                	mov    %edx,%esi
  801825:	c1 e6 18             	shl    $0x18,%esi
  801828:	89 d0                	mov    %edx,%eax
  80182a:	c1 e0 10             	shl    $0x10,%eax
  80182d:	09 f0                	or     %esi,%eax
  80182f:	09 c2                	or     %eax,%edx
  801831:	89 d0                	mov    %edx,%eax
  801833:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801835:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801838:	fc                   	cld    
  801839:	f3 ab                	rep stos %eax,%es:(%edi)
  80183b:	eb 06                	jmp    801843 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80183d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801840:	fc                   	cld    
  801841:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801843:	89 f8                	mov    %edi,%eax
  801845:	5b                   	pop    %ebx
  801846:	5e                   	pop    %esi
  801847:	5f                   	pop    %edi
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	57                   	push   %edi
  80184e:	56                   	push   %esi
  80184f:	8b 45 08             	mov    0x8(%ebp),%eax
  801852:	8b 75 0c             	mov    0xc(%ebp),%esi
  801855:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801858:	39 c6                	cmp    %eax,%esi
  80185a:	73 35                	jae    801891 <memmove+0x47>
  80185c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80185f:	39 d0                	cmp    %edx,%eax
  801861:	73 2e                	jae    801891 <memmove+0x47>
		s += n;
		d += n;
  801863:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801866:	89 d6                	mov    %edx,%esi
  801868:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80186a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801870:	75 13                	jne    801885 <memmove+0x3b>
  801872:	f6 c1 03             	test   $0x3,%cl
  801875:	75 0e                	jne    801885 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801877:	83 ef 04             	sub    $0x4,%edi
  80187a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80187d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801880:	fd                   	std    
  801881:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801883:	eb 09                	jmp    80188e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801885:	83 ef 01             	sub    $0x1,%edi
  801888:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80188b:	fd                   	std    
  80188c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80188e:	fc                   	cld    
  80188f:	eb 1d                	jmp    8018ae <memmove+0x64>
  801891:	89 f2                	mov    %esi,%edx
  801893:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801895:	f6 c2 03             	test   $0x3,%dl
  801898:	75 0f                	jne    8018a9 <memmove+0x5f>
  80189a:	f6 c1 03             	test   $0x3,%cl
  80189d:	75 0a                	jne    8018a9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80189f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018a2:	89 c7                	mov    %eax,%edi
  8018a4:	fc                   	cld    
  8018a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a7:	eb 05                	jmp    8018ae <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018a9:	89 c7                	mov    %eax,%edi
  8018ab:	fc                   	cld    
  8018ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ae:	5e                   	pop    %esi
  8018af:	5f                   	pop    %edi
  8018b0:	5d                   	pop    %ebp
  8018b1:	c3                   	ret    

008018b2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018b5:	ff 75 10             	pushl  0x10(%ebp)
  8018b8:	ff 75 0c             	pushl  0xc(%ebp)
  8018bb:	ff 75 08             	pushl  0x8(%ebp)
  8018be:	e8 87 ff ff ff       	call   80184a <memmove>
}
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	56                   	push   %esi
  8018c9:	53                   	push   %ebx
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d0:	89 c6                	mov    %eax,%esi
  8018d2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d5:	eb 1a                	jmp    8018f1 <memcmp+0x2c>
		if (*s1 != *s2)
  8018d7:	0f b6 08             	movzbl (%eax),%ecx
  8018da:	0f b6 1a             	movzbl (%edx),%ebx
  8018dd:	38 d9                	cmp    %bl,%cl
  8018df:	74 0a                	je     8018eb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018e1:	0f b6 c1             	movzbl %cl,%eax
  8018e4:	0f b6 db             	movzbl %bl,%ebx
  8018e7:	29 d8                	sub    %ebx,%eax
  8018e9:	eb 0f                	jmp    8018fa <memcmp+0x35>
		s1++, s2++;
  8018eb:	83 c0 01             	add    $0x1,%eax
  8018ee:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f1:	39 f0                	cmp    %esi,%eax
  8018f3:	75 e2                	jne    8018d7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    

008018fe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801907:	89 c2                	mov    %eax,%edx
  801909:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80190c:	eb 07                	jmp    801915 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80190e:	38 08                	cmp    %cl,(%eax)
  801910:	74 07                	je     801919 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801912:	83 c0 01             	add    $0x1,%eax
  801915:	39 d0                	cmp    %edx,%eax
  801917:	72 f5                	jb     80190e <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    

0080191b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	57                   	push   %edi
  80191f:	56                   	push   %esi
  801920:	53                   	push   %ebx
  801921:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801924:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801927:	eb 03                	jmp    80192c <strtol+0x11>
		s++;
  801929:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80192c:	0f b6 01             	movzbl (%ecx),%eax
  80192f:	3c 09                	cmp    $0x9,%al
  801931:	74 f6                	je     801929 <strtol+0xe>
  801933:	3c 20                	cmp    $0x20,%al
  801935:	74 f2                	je     801929 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801937:	3c 2b                	cmp    $0x2b,%al
  801939:	75 0a                	jne    801945 <strtol+0x2a>
		s++;
  80193b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80193e:	bf 00 00 00 00       	mov    $0x0,%edi
  801943:	eb 10                	jmp    801955 <strtol+0x3a>
  801945:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80194a:	3c 2d                	cmp    $0x2d,%al
  80194c:	75 07                	jne    801955 <strtol+0x3a>
		s++, neg = 1;
  80194e:	8d 49 01             	lea    0x1(%ecx),%ecx
  801951:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801955:	85 db                	test   %ebx,%ebx
  801957:	0f 94 c0             	sete   %al
  80195a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801960:	75 19                	jne    80197b <strtol+0x60>
  801962:	80 39 30             	cmpb   $0x30,(%ecx)
  801965:	75 14                	jne    80197b <strtol+0x60>
  801967:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80196b:	0f 85 82 00 00 00    	jne    8019f3 <strtol+0xd8>
		s += 2, base = 16;
  801971:	83 c1 02             	add    $0x2,%ecx
  801974:	bb 10 00 00 00       	mov    $0x10,%ebx
  801979:	eb 16                	jmp    801991 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80197b:	84 c0                	test   %al,%al
  80197d:	74 12                	je     801991 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80197f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801984:	80 39 30             	cmpb   $0x30,(%ecx)
  801987:	75 08                	jne    801991 <strtol+0x76>
		s++, base = 8;
  801989:	83 c1 01             	add    $0x1,%ecx
  80198c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801991:	b8 00 00 00 00       	mov    $0x0,%eax
  801996:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801999:	0f b6 11             	movzbl (%ecx),%edx
  80199c:	8d 72 d0             	lea    -0x30(%edx),%esi
  80199f:	89 f3                	mov    %esi,%ebx
  8019a1:	80 fb 09             	cmp    $0x9,%bl
  8019a4:	77 08                	ja     8019ae <strtol+0x93>
			dig = *s - '0';
  8019a6:	0f be d2             	movsbl %dl,%edx
  8019a9:	83 ea 30             	sub    $0x30,%edx
  8019ac:	eb 22                	jmp    8019d0 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019ae:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019b1:	89 f3                	mov    %esi,%ebx
  8019b3:	80 fb 19             	cmp    $0x19,%bl
  8019b6:	77 08                	ja     8019c0 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019b8:	0f be d2             	movsbl %dl,%edx
  8019bb:	83 ea 57             	sub    $0x57,%edx
  8019be:	eb 10                	jmp    8019d0 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019c0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019c3:	89 f3                	mov    %esi,%ebx
  8019c5:	80 fb 19             	cmp    $0x19,%bl
  8019c8:	77 16                	ja     8019e0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019ca:	0f be d2             	movsbl %dl,%edx
  8019cd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019d0:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d3:	7d 0f                	jge    8019e4 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019d5:	83 c1 01             	add    $0x1,%ecx
  8019d8:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019dc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019de:	eb b9                	jmp    801999 <strtol+0x7e>
  8019e0:	89 c2                	mov    %eax,%edx
  8019e2:	eb 02                	jmp    8019e6 <strtol+0xcb>
  8019e4:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019e6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019ea:	74 0d                	je     8019f9 <strtol+0xde>
		*endptr = (char *) s;
  8019ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019ef:	89 0e                	mov    %ecx,(%esi)
  8019f1:	eb 06                	jmp    8019f9 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019f3:	84 c0                	test   %al,%al
  8019f5:	75 92                	jne    801989 <strtol+0x6e>
  8019f7:	eb 98                	jmp    801991 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019f9:	f7 da                	neg    %edx
  8019fb:	85 ff                	test   %edi,%edi
  8019fd:	0f 45 c2             	cmovne %edx,%eax
}
  801a00:	5b                   	pop    %ebx
  801a01:	5e                   	pop    %esi
  801a02:	5f                   	pop    %edi
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    

00801a05 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	56                   	push   %esi
  801a09:	53                   	push   %ebx
  801a0a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801a13:	85 c0                	test   %eax,%eax
  801a15:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a1a:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	50                   	push   %eax
  801a21:	e8 e4 e8 ff ff       	call   80030a <sys_ipc_recv>
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	79 16                	jns    801a43 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801a2d:	85 f6                	test   %esi,%esi
  801a2f:	74 06                	je     801a37 <ipc_recv+0x32>
  801a31:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801a37:	85 db                	test   %ebx,%ebx
  801a39:	74 2c                	je     801a67 <ipc_recv+0x62>
  801a3b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a41:	eb 24                	jmp    801a67 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a43:	85 f6                	test   %esi,%esi
  801a45:	74 0a                	je     801a51 <ipc_recv+0x4c>
  801a47:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4c:	8b 40 74             	mov    0x74(%eax),%eax
  801a4f:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801a51:	85 db                	test   %ebx,%ebx
  801a53:	74 0a                	je     801a5f <ipc_recv+0x5a>
  801a55:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5a:	8b 40 78             	mov    0x78(%eax),%eax
  801a5d:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801a5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a64:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	57                   	push   %edi
  801a72:	56                   	push   %esi
  801a73:	53                   	push   %ebx
  801a74:	83 ec 0c             	sub    $0xc,%esp
  801a77:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801a80:	85 db                	test   %ebx,%ebx
  801a82:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a87:	0f 44 d8             	cmove  %eax,%ebx
  801a8a:	eb 1c                	jmp    801aa8 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801a8c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a8f:	74 12                	je     801aa3 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801a91:	50                   	push   %eax
  801a92:	68 60 22 80 00       	push   $0x802260
  801a97:	6a 39                	push   $0x39
  801a99:	68 7b 22 80 00       	push   $0x80227b
  801a9e:	e8 b5 f5 ff ff       	call   801058 <_panic>
                 sys_yield();
  801aa3:	e8 93 e6 ff ff       	call   80013b <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801aa8:	ff 75 14             	pushl  0x14(%ebp)
  801aab:	53                   	push   %ebx
  801aac:	56                   	push   %esi
  801aad:	57                   	push   %edi
  801aae:	e8 34 e8 ff ff       	call   8002e7 <sys_ipc_try_send>
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 d2                	js     801a8c <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801aba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abd:	5b                   	pop    %ebx
  801abe:	5e                   	pop    %esi
  801abf:	5f                   	pop    %edi
  801ac0:	5d                   	pop    %ebp
  801ac1:	c3                   	ret    

00801ac2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801acd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ad0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad6:	8b 52 50             	mov    0x50(%edx),%edx
  801ad9:	39 ca                	cmp    %ecx,%edx
  801adb:	75 0d                	jne    801aea <ipc_find_env+0x28>
			return envs[i].env_id;
  801add:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ae0:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ae5:	8b 40 08             	mov    0x8(%eax),%eax
  801ae8:	eb 0e                	jmp    801af8 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aea:	83 c0 01             	add    $0x1,%eax
  801aed:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af2:	75 d9                	jne    801acd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af4:	66 b8 00 00          	mov    $0x0,%ax
}
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b00:	89 d0                	mov    %edx,%eax
  801b02:	c1 e8 16             	shr    $0x16,%eax
  801b05:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b11:	f6 c1 01             	test   $0x1,%cl
  801b14:	74 1d                	je     801b33 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b16:	c1 ea 0c             	shr    $0xc,%edx
  801b19:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b20:	f6 c2 01             	test   $0x1,%dl
  801b23:	74 0e                	je     801b33 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b25:	c1 ea 0c             	shr    $0xc,%edx
  801b28:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b2f:	ef 
  801b30:	0f b7 c0             	movzwl %ax,%eax
}
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    
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
