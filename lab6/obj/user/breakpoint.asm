
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
  800056:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800085:	e8 2f 05 00 00       	call   8005b9 <close_all>
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
	// return value.
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
	// return value.
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
	// return value.
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
  8000fe:	68 0a 23 80 00       	push   $0x80230a
  800103:	6a 22                	push   $0x22
  800105:	68 27 23 80 00       	push   $0x802327
  80010a:	e8 5b 14 00 00       	call   80156a <_panic>

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
	// return value.
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
	// return value.
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
	// return value.
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
  80017f:	68 0a 23 80 00       	push   $0x80230a
  800184:	6a 22                	push   $0x22
  800186:	68 27 23 80 00       	push   $0x802327
  80018b:	e8 da 13 00 00       	call   80156a <_panic>

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
	// return value.
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
  8001c1:	68 0a 23 80 00       	push   $0x80230a
  8001c6:	6a 22                	push   $0x22
  8001c8:	68 27 23 80 00       	push   $0x802327
  8001cd:	e8 98 13 00 00       	call   80156a <_panic>

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
	// return value.
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
  800203:	68 0a 23 80 00       	push   $0x80230a
  800208:	6a 22                	push   $0x22
  80020a:	68 27 23 80 00       	push   $0x802327
  80020f:	e8 56 13 00 00       	call   80156a <_panic>

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
	// return value.
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
  800245:	68 0a 23 80 00       	push   $0x80230a
  80024a:	6a 22                	push   $0x22
  80024c:	68 27 23 80 00       	push   $0x802327
  800251:	e8 14 13 00 00       	call   80156a <_panic>
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
	// return value.
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
  800287:	68 0a 23 80 00       	push   $0x80230a
  80028c:	6a 22                	push   $0x22
  80028e:	68 27 23 80 00       	push   $0x802327
  800293:	e8 d2 12 00 00       	call   80156a <_panic>

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
	// return value.
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
  8002c9:	68 0a 23 80 00       	push   $0x80230a
  8002ce:	6a 22                	push   $0x22
  8002d0:	68 27 23 80 00       	push   $0x802327
  8002d5:	e8 90 12 00 00       	call   80156a <_panic>

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
	// return value.
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
	// return value.
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
  80032d:	68 0a 23 80 00       	push   $0x80230a
  800332:	6a 22                	push   $0x22
  800334:	68 27 23 80 00       	push   $0x802327
  800339:	e8 2c 12 00 00       	call   80156a <_panic>

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

00800346 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	57                   	push   %edi
  80034a:	56                   	push   %esi
  80034b:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80034c:	ba 00 00 00 00       	mov    $0x0,%edx
  800351:	b8 0e 00 00 00       	mov    $0xe,%eax
  800356:	89 d1                	mov    %edx,%ecx
  800358:	89 d3                	mov    %edx,%ebx
  80035a:	89 d7                	mov    %edx,%edi
  80035c:	89 d6                	mov    %edx,%esi
  80035e:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800360:	5b                   	pop    %ebx
  800361:	5e                   	pop    %esi
  800362:	5f                   	pop    %edi
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	57                   	push   %edi
  800369:	56                   	push   %esi
  80036a:	53                   	push   %ebx
  80036b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80036e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800373:	b8 0f 00 00 00       	mov    $0xf,%eax
  800378:	8b 55 08             	mov    0x8(%ebp),%edx
  80037b:	89 cb                	mov    %ecx,%ebx
  80037d:	89 cf                	mov    %ecx,%edi
  80037f:	89 ce                	mov    %ecx,%esi
  800381:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800383:	85 c0                	test   %eax,%eax
  800385:	7e 17                	jle    80039e <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800387:	83 ec 0c             	sub    $0xc,%esp
  80038a:	50                   	push   %eax
  80038b:	6a 0f                	push   $0xf
  80038d:	68 0a 23 80 00       	push   $0x80230a
  800392:	6a 22                	push   $0x22
  800394:	68 27 23 80 00       	push   $0x802327
  800399:	e8 cc 11 00 00       	call   80156a <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  80039e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003a1:	5b                   	pop    %ebx
  8003a2:	5e                   	pop    %esi
  8003a3:	5f                   	pop    %edi
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <sys_recv>:

int
sys_recv(void *addr)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	57                   	push   %edi
  8003aa:	56                   	push   %esi
  8003ab:	53                   	push   %ebx
  8003ac:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8003af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b4:	b8 10 00 00 00       	mov    $0x10,%eax
  8003b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bc:	89 cb                	mov    %ecx,%ebx
  8003be:	89 cf                	mov    %ecx,%edi
  8003c0:	89 ce                	mov    %ecx,%esi
  8003c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003c4:	85 c0                	test   %eax,%eax
  8003c6:	7e 17                	jle    8003df <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c8:	83 ec 0c             	sub    $0xc,%esp
  8003cb:	50                   	push   %eax
  8003cc:	6a 10                	push   $0x10
  8003ce:	68 0a 23 80 00       	push   $0x80230a
  8003d3:	6a 22                	push   $0x22
  8003d5:	68 27 23 80 00       	push   $0x802327
  8003da:	e8 8b 11 00 00       	call   80156a <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e2:	5b                   	pop    %ebx
  8003e3:	5e                   	pop    %esi
  8003e4:	5f                   	pop    %edi
  8003e5:	5d                   	pop    %ebp
  8003e6:	c3                   	ret    

008003e7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ed:	05 00 00 00 30       	add    $0x30000000,%eax
  8003f2:	c1 e8 0c             	shr    $0xc,%eax
}
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fd:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800402:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800407:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    

0080040e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800414:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800419:	89 c2                	mov    %eax,%edx
  80041b:	c1 ea 16             	shr    $0x16,%edx
  80041e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800425:	f6 c2 01             	test   $0x1,%dl
  800428:	74 11                	je     80043b <fd_alloc+0x2d>
  80042a:	89 c2                	mov    %eax,%edx
  80042c:	c1 ea 0c             	shr    $0xc,%edx
  80042f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800436:	f6 c2 01             	test   $0x1,%dl
  800439:	75 09                	jne    800444 <fd_alloc+0x36>
			*fd_store = fd;
  80043b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043d:	b8 00 00 00 00       	mov    $0x0,%eax
  800442:	eb 17                	jmp    80045b <fd_alloc+0x4d>
  800444:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800449:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80044e:	75 c9                	jne    800419 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800450:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800456:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    

0080045d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80045d:	55                   	push   %ebp
  80045e:	89 e5                	mov    %esp,%ebp
  800460:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800463:	83 f8 1f             	cmp    $0x1f,%eax
  800466:	77 36                	ja     80049e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800468:	c1 e0 0c             	shl    $0xc,%eax
  80046b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800470:	89 c2                	mov    %eax,%edx
  800472:	c1 ea 16             	shr    $0x16,%edx
  800475:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80047c:	f6 c2 01             	test   $0x1,%dl
  80047f:	74 24                	je     8004a5 <fd_lookup+0x48>
  800481:	89 c2                	mov    %eax,%edx
  800483:	c1 ea 0c             	shr    $0xc,%edx
  800486:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80048d:	f6 c2 01             	test   $0x1,%dl
  800490:	74 1a                	je     8004ac <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800492:	8b 55 0c             	mov    0xc(%ebp),%edx
  800495:	89 02                	mov    %eax,(%edx)
	return 0;
  800497:	b8 00 00 00 00       	mov    $0x0,%eax
  80049c:	eb 13                	jmp    8004b1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80049e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a3:	eb 0c                	jmp    8004b1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004aa:	eb 05                	jmp    8004b1 <fd_lookup+0x54>
  8004ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004b1:	5d                   	pop    %ebp
  8004b2:	c3                   	ret    

008004b3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004b3:	55                   	push   %ebp
  8004b4:	89 e5                	mov    %esp,%ebp
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8004bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c1:	eb 13                	jmp    8004d6 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8004c3:	39 08                	cmp    %ecx,(%eax)
  8004c5:	75 0c                	jne    8004d3 <dev_lookup+0x20>
			*dev = devtab[i];
  8004c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004ca:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d1:	eb 36                	jmp    800509 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004d3:	83 c2 01             	add    $0x1,%edx
  8004d6:	8b 04 95 b4 23 80 00 	mov    0x8023b4(,%edx,4),%eax
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	75 e2                	jne    8004c3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004e1:	a1 08 40 80 00       	mov    0x804008,%eax
  8004e6:	8b 40 48             	mov    0x48(%eax),%eax
  8004e9:	83 ec 04             	sub    $0x4,%esp
  8004ec:	51                   	push   %ecx
  8004ed:	50                   	push   %eax
  8004ee:	68 38 23 80 00       	push   $0x802338
  8004f3:	e8 4b 11 00 00       	call   801643 <cprintf>
	*dev = 0;
  8004f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800509:	c9                   	leave  
  80050a:	c3                   	ret    

0080050b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80050b:	55                   	push   %ebp
  80050c:	89 e5                	mov    %esp,%ebp
  80050e:	56                   	push   %esi
  80050f:	53                   	push   %ebx
  800510:	83 ec 10             	sub    $0x10,%esp
  800513:	8b 75 08             	mov    0x8(%ebp),%esi
  800516:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800519:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051c:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80051d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800523:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800526:	50                   	push   %eax
  800527:	e8 31 ff ff ff       	call   80045d <fd_lookup>
  80052c:	83 c4 08             	add    $0x8,%esp
  80052f:	85 c0                	test   %eax,%eax
  800531:	78 05                	js     800538 <fd_close+0x2d>
	    || fd != fd2)
  800533:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800536:	74 0c                	je     800544 <fd_close+0x39>
		return (must_exist ? r : 0);
  800538:	84 db                	test   %bl,%bl
  80053a:	ba 00 00 00 00       	mov    $0x0,%edx
  80053f:	0f 44 c2             	cmove  %edx,%eax
  800542:	eb 41                	jmp    800585 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80054a:	50                   	push   %eax
  80054b:	ff 36                	pushl  (%esi)
  80054d:	e8 61 ff ff ff       	call   8004b3 <dev_lookup>
  800552:	89 c3                	mov    %eax,%ebx
  800554:	83 c4 10             	add    $0x10,%esp
  800557:	85 c0                	test   %eax,%eax
  800559:	78 1a                	js     800575 <fd_close+0x6a>
		if (dev->dev_close)
  80055b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80055e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800561:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800566:	85 c0                	test   %eax,%eax
  800568:	74 0b                	je     800575 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	56                   	push   %esi
  80056e:	ff d0                	call   *%eax
  800570:	89 c3                	mov    %eax,%ebx
  800572:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	56                   	push   %esi
  800579:	6a 00                	push   $0x0
  80057b:	e8 5a fc ff ff       	call   8001da <sys_page_unmap>
	return r;
  800580:	83 c4 10             	add    $0x10,%esp
  800583:	89 d8                	mov    %ebx,%eax
}
  800585:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800588:	5b                   	pop    %ebx
  800589:	5e                   	pop    %esi
  80058a:	5d                   	pop    %ebp
  80058b:	c3                   	ret    

0080058c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800592:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	ff 75 08             	pushl  0x8(%ebp)
  800599:	e8 bf fe ff ff       	call   80045d <fd_lookup>
  80059e:	89 c2                	mov    %eax,%edx
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	85 d2                	test   %edx,%edx
  8005a5:	78 10                	js     8005b7 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	6a 01                	push   $0x1
  8005ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8005af:	e8 57 ff ff ff       	call   80050b <fd_close>
  8005b4:	83 c4 10             	add    $0x10,%esp
}
  8005b7:	c9                   	leave  
  8005b8:	c3                   	ret    

008005b9 <close_all>:

void
close_all(void)
{
  8005b9:	55                   	push   %ebp
  8005ba:	89 e5                	mov    %esp,%ebp
  8005bc:	53                   	push   %ebx
  8005bd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005c0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	53                   	push   %ebx
  8005c9:	e8 be ff ff ff       	call   80058c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ce:	83 c3 01             	add    $0x1,%ebx
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	83 fb 20             	cmp    $0x20,%ebx
  8005d7:	75 ec                	jne    8005c5 <close_all+0xc>
		close(i);
}
  8005d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005dc:	c9                   	leave  
  8005dd:	c3                   	ret    

008005de <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005de:	55                   	push   %ebp
  8005df:	89 e5                	mov    %esp,%ebp
  8005e1:	57                   	push   %edi
  8005e2:	56                   	push   %esi
  8005e3:	53                   	push   %ebx
  8005e4:	83 ec 2c             	sub    $0x2c,%esp
  8005e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005ed:	50                   	push   %eax
  8005ee:	ff 75 08             	pushl  0x8(%ebp)
  8005f1:	e8 67 fe ff ff       	call   80045d <fd_lookup>
  8005f6:	89 c2                	mov    %eax,%edx
  8005f8:	83 c4 08             	add    $0x8,%esp
  8005fb:	85 d2                	test   %edx,%edx
  8005fd:	0f 88 c1 00 00 00    	js     8006c4 <dup+0xe6>
		return r;
	close(newfdnum);
  800603:	83 ec 0c             	sub    $0xc,%esp
  800606:	56                   	push   %esi
  800607:	e8 80 ff ff ff       	call   80058c <close>

	newfd = INDEX2FD(newfdnum);
  80060c:	89 f3                	mov    %esi,%ebx
  80060e:	c1 e3 0c             	shl    $0xc,%ebx
  800611:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800617:	83 c4 04             	add    $0x4,%esp
  80061a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80061d:	e8 d5 fd ff ff       	call   8003f7 <fd2data>
  800622:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800624:	89 1c 24             	mov    %ebx,(%esp)
  800627:	e8 cb fd ff ff       	call   8003f7 <fd2data>
  80062c:	83 c4 10             	add    $0x10,%esp
  80062f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800632:	89 f8                	mov    %edi,%eax
  800634:	c1 e8 16             	shr    $0x16,%eax
  800637:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80063e:	a8 01                	test   $0x1,%al
  800640:	74 37                	je     800679 <dup+0x9b>
  800642:	89 f8                	mov    %edi,%eax
  800644:	c1 e8 0c             	shr    $0xc,%eax
  800647:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80064e:	f6 c2 01             	test   $0x1,%dl
  800651:	74 26                	je     800679 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800653:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80065a:	83 ec 0c             	sub    $0xc,%esp
  80065d:	25 07 0e 00 00       	and    $0xe07,%eax
  800662:	50                   	push   %eax
  800663:	ff 75 d4             	pushl  -0x2c(%ebp)
  800666:	6a 00                	push   $0x0
  800668:	57                   	push   %edi
  800669:	6a 00                	push   $0x0
  80066b:	e8 28 fb ff ff       	call   800198 <sys_page_map>
  800670:	89 c7                	mov    %eax,%edi
  800672:	83 c4 20             	add    $0x20,%esp
  800675:	85 c0                	test   %eax,%eax
  800677:	78 2e                	js     8006a7 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800679:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80067c:	89 d0                	mov    %edx,%eax
  80067e:	c1 e8 0c             	shr    $0xc,%eax
  800681:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800688:	83 ec 0c             	sub    $0xc,%esp
  80068b:	25 07 0e 00 00       	and    $0xe07,%eax
  800690:	50                   	push   %eax
  800691:	53                   	push   %ebx
  800692:	6a 00                	push   $0x0
  800694:	52                   	push   %edx
  800695:	6a 00                	push   $0x0
  800697:	e8 fc fa ff ff       	call   800198 <sys_page_map>
  80069c:	89 c7                	mov    %eax,%edi
  80069e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006a1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006a3:	85 ff                	test   %edi,%edi
  8006a5:	79 1d                	jns    8006c4 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 00                	push   $0x0
  8006ad:	e8 28 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006b2:	83 c4 08             	add    $0x8,%esp
  8006b5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006b8:	6a 00                	push   $0x0
  8006ba:	e8 1b fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	89 f8                	mov    %edi,%eax
}
  8006c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c7:	5b                   	pop    %ebx
  8006c8:	5e                   	pop    %esi
  8006c9:	5f                   	pop    %edi
  8006ca:	5d                   	pop    %ebp
  8006cb:	c3                   	ret    

008006cc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	53                   	push   %ebx
  8006d0:	83 ec 14             	sub    $0x14,%esp
  8006d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006d9:	50                   	push   %eax
  8006da:	53                   	push   %ebx
  8006db:	e8 7d fd ff ff       	call   80045d <fd_lookup>
  8006e0:	83 c4 08             	add    $0x8,%esp
  8006e3:	89 c2                	mov    %eax,%edx
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	78 6d                	js     800756 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006ef:	50                   	push   %eax
  8006f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006f3:	ff 30                	pushl  (%eax)
  8006f5:	e8 b9 fd ff ff       	call   8004b3 <dev_lookup>
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	78 4c                	js     80074d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800701:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800704:	8b 42 08             	mov    0x8(%edx),%eax
  800707:	83 e0 03             	and    $0x3,%eax
  80070a:	83 f8 01             	cmp    $0x1,%eax
  80070d:	75 21                	jne    800730 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80070f:	a1 08 40 80 00       	mov    0x804008,%eax
  800714:	8b 40 48             	mov    0x48(%eax),%eax
  800717:	83 ec 04             	sub    $0x4,%esp
  80071a:	53                   	push   %ebx
  80071b:	50                   	push   %eax
  80071c:	68 79 23 80 00       	push   $0x802379
  800721:	e8 1d 0f 00 00       	call   801643 <cprintf>
		return -E_INVAL;
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80072e:	eb 26                	jmp    800756 <read+0x8a>
	}
	if (!dev->dev_read)
  800730:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800733:	8b 40 08             	mov    0x8(%eax),%eax
  800736:	85 c0                	test   %eax,%eax
  800738:	74 17                	je     800751 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80073a:	83 ec 04             	sub    $0x4,%esp
  80073d:	ff 75 10             	pushl  0x10(%ebp)
  800740:	ff 75 0c             	pushl  0xc(%ebp)
  800743:	52                   	push   %edx
  800744:	ff d0                	call   *%eax
  800746:	89 c2                	mov    %eax,%edx
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	eb 09                	jmp    800756 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80074d:	89 c2                	mov    %eax,%edx
  80074f:	eb 05                	jmp    800756 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800751:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800756:	89 d0                	mov    %edx,%eax
  800758:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	57                   	push   %edi
  800761:	56                   	push   %esi
  800762:	53                   	push   %ebx
  800763:	83 ec 0c             	sub    $0xc,%esp
  800766:	8b 7d 08             	mov    0x8(%ebp),%edi
  800769:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80076c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800771:	eb 21                	jmp    800794 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	89 f0                	mov    %esi,%eax
  800778:	29 d8                	sub    %ebx,%eax
  80077a:	50                   	push   %eax
  80077b:	89 d8                	mov    %ebx,%eax
  80077d:	03 45 0c             	add    0xc(%ebp),%eax
  800780:	50                   	push   %eax
  800781:	57                   	push   %edi
  800782:	e8 45 ff ff ff       	call   8006cc <read>
		if (m < 0)
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	85 c0                	test   %eax,%eax
  80078c:	78 0c                	js     80079a <readn+0x3d>
			return m;
		if (m == 0)
  80078e:	85 c0                	test   %eax,%eax
  800790:	74 06                	je     800798 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800792:	01 c3                	add    %eax,%ebx
  800794:	39 f3                	cmp    %esi,%ebx
  800796:	72 db                	jb     800773 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800798:	89 d8                	mov    %ebx,%eax
}
  80079a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079d:	5b                   	pop    %ebx
  80079e:	5e                   	pop    %esi
  80079f:	5f                   	pop    %edi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	53                   	push   %ebx
  8007a6:	83 ec 14             	sub    $0x14,%esp
  8007a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007af:	50                   	push   %eax
  8007b0:	53                   	push   %ebx
  8007b1:	e8 a7 fc ff ff       	call   80045d <fd_lookup>
  8007b6:	83 c4 08             	add    $0x8,%esp
  8007b9:	89 c2                	mov    %eax,%edx
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	78 68                	js     800827 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c5:	50                   	push   %eax
  8007c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c9:	ff 30                	pushl  (%eax)
  8007cb:	e8 e3 fc ff ff       	call   8004b3 <dev_lookup>
  8007d0:	83 c4 10             	add    $0x10,%esp
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	78 47                	js     80081e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007de:	75 21                	jne    800801 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007e0:	a1 08 40 80 00       	mov    0x804008,%eax
  8007e5:	8b 40 48             	mov    0x48(%eax),%eax
  8007e8:	83 ec 04             	sub    $0x4,%esp
  8007eb:	53                   	push   %ebx
  8007ec:	50                   	push   %eax
  8007ed:	68 95 23 80 00       	push   $0x802395
  8007f2:	e8 4c 0e 00 00       	call   801643 <cprintf>
		return -E_INVAL;
  8007f7:	83 c4 10             	add    $0x10,%esp
  8007fa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007ff:	eb 26                	jmp    800827 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800801:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800804:	8b 52 0c             	mov    0xc(%edx),%edx
  800807:	85 d2                	test   %edx,%edx
  800809:	74 17                	je     800822 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80080b:	83 ec 04             	sub    $0x4,%esp
  80080e:	ff 75 10             	pushl  0x10(%ebp)
  800811:	ff 75 0c             	pushl  0xc(%ebp)
  800814:	50                   	push   %eax
  800815:	ff d2                	call   *%edx
  800817:	89 c2                	mov    %eax,%edx
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	eb 09                	jmp    800827 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081e:	89 c2                	mov    %eax,%edx
  800820:	eb 05                	jmp    800827 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800822:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800827:	89 d0                	mov    %edx,%eax
  800829:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082c:	c9                   	leave  
  80082d:	c3                   	ret    

0080082e <seek>:

int
seek(int fdnum, off_t offset)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800834:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800837:	50                   	push   %eax
  800838:	ff 75 08             	pushl  0x8(%ebp)
  80083b:	e8 1d fc ff ff       	call   80045d <fd_lookup>
  800840:	83 c4 08             	add    $0x8,%esp
  800843:	85 c0                	test   %eax,%eax
  800845:	78 0e                	js     800855 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800847:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800850:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	83 ec 14             	sub    $0x14,%esp
  80085e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800861:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800864:	50                   	push   %eax
  800865:	53                   	push   %ebx
  800866:	e8 f2 fb ff ff       	call   80045d <fd_lookup>
  80086b:	83 c4 08             	add    $0x8,%esp
  80086e:	89 c2                	mov    %eax,%edx
  800870:	85 c0                	test   %eax,%eax
  800872:	78 65                	js     8008d9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800874:	83 ec 08             	sub    $0x8,%esp
  800877:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087a:	50                   	push   %eax
  80087b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80087e:	ff 30                	pushl  (%eax)
  800880:	e8 2e fc ff ff       	call   8004b3 <dev_lookup>
  800885:	83 c4 10             	add    $0x10,%esp
  800888:	85 c0                	test   %eax,%eax
  80088a:	78 44                	js     8008d0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80088c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800893:	75 21                	jne    8008b6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800895:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80089a:	8b 40 48             	mov    0x48(%eax),%eax
  80089d:	83 ec 04             	sub    $0x4,%esp
  8008a0:	53                   	push   %ebx
  8008a1:	50                   	push   %eax
  8008a2:	68 58 23 80 00       	push   $0x802358
  8008a7:	e8 97 0d 00 00       	call   801643 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008b4:	eb 23                	jmp    8008d9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008b9:	8b 52 18             	mov    0x18(%edx),%edx
  8008bc:	85 d2                	test   %edx,%edx
  8008be:	74 14                	je     8008d4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008c0:	83 ec 08             	sub    $0x8,%esp
  8008c3:	ff 75 0c             	pushl  0xc(%ebp)
  8008c6:	50                   	push   %eax
  8008c7:	ff d2                	call   *%edx
  8008c9:	89 c2                	mov    %eax,%edx
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	eb 09                	jmp    8008d9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d0:	89 c2                	mov    %eax,%edx
  8008d2:	eb 05                	jmp    8008d9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008d9:	89 d0                	mov    %edx,%eax
  8008db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	53                   	push   %ebx
  8008e4:	83 ec 14             	sub    $0x14,%esp
  8008e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ed:	50                   	push   %eax
  8008ee:	ff 75 08             	pushl  0x8(%ebp)
  8008f1:	e8 67 fb ff ff       	call   80045d <fd_lookup>
  8008f6:	83 c4 08             	add    $0x8,%esp
  8008f9:	89 c2                	mov    %eax,%edx
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	78 58                	js     800957 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800905:	50                   	push   %eax
  800906:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800909:	ff 30                	pushl  (%eax)
  80090b:	e8 a3 fb ff ff       	call   8004b3 <dev_lookup>
  800910:	83 c4 10             	add    $0x10,%esp
  800913:	85 c0                	test   %eax,%eax
  800915:	78 37                	js     80094e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800917:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80091a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80091e:	74 32                	je     800952 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800920:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800923:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80092a:	00 00 00 
	stat->st_isdir = 0;
  80092d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800934:	00 00 00 
	stat->st_dev = dev;
  800937:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80093d:	83 ec 08             	sub    $0x8,%esp
  800940:	53                   	push   %ebx
  800941:	ff 75 f0             	pushl  -0x10(%ebp)
  800944:	ff 50 14             	call   *0x14(%eax)
  800947:	89 c2                	mov    %eax,%edx
  800949:	83 c4 10             	add    $0x10,%esp
  80094c:	eb 09                	jmp    800957 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80094e:	89 c2                	mov    %eax,%edx
  800950:	eb 05                	jmp    800957 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800952:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800957:	89 d0                	mov    %edx,%eax
  800959:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80095c:	c9                   	leave  
  80095d:	c3                   	ret    

0080095e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	56                   	push   %esi
  800962:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800963:	83 ec 08             	sub    $0x8,%esp
  800966:	6a 00                	push   $0x0
  800968:	ff 75 08             	pushl  0x8(%ebp)
  80096b:	e8 09 02 00 00       	call   800b79 <open>
  800970:	89 c3                	mov    %eax,%ebx
  800972:	83 c4 10             	add    $0x10,%esp
  800975:	85 db                	test   %ebx,%ebx
  800977:	78 1b                	js     800994 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800979:	83 ec 08             	sub    $0x8,%esp
  80097c:	ff 75 0c             	pushl  0xc(%ebp)
  80097f:	53                   	push   %ebx
  800980:	e8 5b ff ff ff       	call   8008e0 <fstat>
  800985:	89 c6                	mov    %eax,%esi
	close(fd);
  800987:	89 1c 24             	mov    %ebx,(%esp)
  80098a:	e8 fd fb ff ff       	call   80058c <close>
	return r;
  80098f:	83 c4 10             	add    $0x10,%esp
  800992:	89 f0                	mov    %esi,%eax
}
  800994:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	56                   	push   %esi
  80099f:	53                   	push   %ebx
  8009a0:	89 c6                	mov    %eax,%esi
  8009a2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009a4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009ab:	75 12                	jne    8009bf <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009ad:	83 ec 0c             	sub    $0xc,%esp
  8009b0:	6a 01                	push   $0x1
  8009b2:	e8 1d 16 00 00       	call   801fd4 <ipc_find_env>
  8009b7:	a3 00 40 80 00       	mov    %eax,0x804000
  8009bc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009bf:	6a 07                	push   $0x7
  8009c1:	68 00 50 80 00       	push   $0x805000
  8009c6:	56                   	push   %esi
  8009c7:	ff 35 00 40 80 00    	pushl  0x804000
  8009cd:	e8 ae 15 00 00       	call   801f80 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009d2:	83 c4 0c             	add    $0xc,%esp
  8009d5:	6a 00                	push   $0x0
  8009d7:	53                   	push   %ebx
  8009d8:	6a 00                	push   $0x0
  8009da:	e8 38 15 00 00       	call   801f17 <ipc_recv>
}
  8009df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009e2:	5b                   	pop    %ebx
  8009e3:	5e                   	pop    %esi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fa:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800a04:	b8 02 00 00 00       	mov    $0x2,%eax
  800a09:	e8 8d ff ff ff       	call   80099b <fsipc>
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a21:	ba 00 00 00 00       	mov    $0x0,%edx
  800a26:	b8 06 00 00 00       	mov    $0x6,%eax
  800a2b:	e8 6b ff ff ff       	call   80099b <fsipc>
}
  800a30:	c9                   	leave  
  800a31:	c3                   	ret    

00800a32 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	53                   	push   %ebx
  800a36:	83 ec 04             	sub    $0x4,%esp
  800a39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a42:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a47:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4c:	b8 05 00 00 00       	mov    $0x5,%eax
  800a51:	e8 45 ff ff ff       	call   80099b <fsipc>
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	85 d2                	test   %edx,%edx
  800a5a:	78 2c                	js     800a88 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a5c:	83 ec 08             	sub    $0x8,%esp
  800a5f:	68 00 50 80 00       	push   $0x805000
  800a64:	53                   	push   %ebx
  800a65:	e8 60 11 00 00       	call   801bca <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a6a:	a1 80 50 80 00       	mov    0x805080,%eax
  800a6f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a75:	a1 84 50 80 00       	mov    0x805084,%eax
  800a7a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a80:	83 c4 10             	add    $0x10,%esp
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	83 ec 0c             	sub    $0xc,%esp
  800a96:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a9f:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800aa4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800aa7:	eb 3d                	jmp    800ae6 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800aa9:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800aaf:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800ab4:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800ab7:	83 ec 04             	sub    $0x4,%esp
  800aba:	57                   	push   %edi
  800abb:	53                   	push   %ebx
  800abc:	68 08 50 80 00       	push   $0x805008
  800ac1:	e8 96 12 00 00       	call   801d5c <memmove>
                fsipcbuf.write.req_n = tmp; 
  800ac6:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800acc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ad6:	e8 c0 fe ff ff       	call   80099b <fsipc>
  800adb:	83 c4 10             	add    $0x10,%esp
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	78 0d                	js     800aef <devfile_write+0x62>
		        return r;
                n -= tmp;
  800ae2:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800ae4:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800ae6:	85 f6                	test   %esi,%esi
  800ae8:	75 bf                	jne    800aa9 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800aea:	89 d8                	mov    %ebx,%eax
  800aec:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	8b 40 0c             	mov    0xc(%eax),%eax
  800b05:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b0a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1a:	e8 7c fe ff ff       	call   80099b <fsipc>
  800b1f:	89 c3                	mov    %eax,%ebx
  800b21:	85 c0                	test   %eax,%eax
  800b23:	78 4b                	js     800b70 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b25:	39 c6                	cmp    %eax,%esi
  800b27:	73 16                	jae    800b3f <devfile_read+0x48>
  800b29:	68 c8 23 80 00       	push   $0x8023c8
  800b2e:	68 cf 23 80 00       	push   $0x8023cf
  800b33:	6a 7c                	push   $0x7c
  800b35:	68 e4 23 80 00       	push   $0x8023e4
  800b3a:	e8 2b 0a 00 00       	call   80156a <_panic>
	assert(r <= PGSIZE);
  800b3f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b44:	7e 16                	jle    800b5c <devfile_read+0x65>
  800b46:	68 ef 23 80 00       	push   $0x8023ef
  800b4b:	68 cf 23 80 00       	push   $0x8023cf
  800b50:	6a 7d                	push   $0x7d
  800b52:	68 e4 23 80 00       	push   $0x8023e4
  800b57:	e8 0e 0a 00 00       	call   80156a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b5c:	83 ec 04             	sub    $0x4,%esp
  800b5f:	50                   	push   %eax
  800b60:	68 00 50 80 00       	push   $0x805000
  800b65:	ff 75 0c             	pushl  0xc(%ebp)
  800b68:	e8 ef 11 00 00       	call   801d5c <memmove>
	return r;
  800b6d:	83 c4 10             	add    $0x10,%esp
}
  800b70:	89 d8                	mov    %ebx,%eax
  800b72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	53                   	push   %ebx
  800b7d:	83 ec 20             	sub    $0x20,%esp
  800b80:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b83:	53                   	push   %ebx
  800b84:	e8 08 10 00 00       	call   801b91 <strlen>
  800b89:	83 c4 10             	add    $0x10,%esp
  800b8c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b91:	7f 67                	jg     800bfa <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b93:	83 ec 0c             	sub    $0xc,%esp
  800b96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b99:	50                   	push   %eax
  800b9a:	e8 6f f8 ff ff       	call   80040e <fd_alloc>
  800b9f:	83 c4 10             	add    $0x10,%esp
		return r;
  800ba2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ba4:	85 c0                	test   %eax,%eax
  800ba6:	78 57                	js     800bff <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ba8:	83 ec 08             	sub    $0x8,%esp
  800bab:	53                   	push   %ebx
  800bac:	68 00 50 80 00       	push   $0x805000
  800bb1:	e8 14 10 00 00       	call   801bca <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc6:	e8 d0 fd ff ff       	call   80099b <fsipc>
  800bcb:	89 c3                	mov    %eax,%ebx
  800bcd:	83 c4 10             	add    $0x10,%esp
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	79 14                	jns    800be8 <open+0x6f>
		fd_close(fd, 0);
  800bd4:	83 ec 08             	sub    $0x8,%esp
  800bd7:	6a 00                	push   $0x0
  800bd9:	ff 75 f4             	pushl  -0xc(%ebp)
  800bdc:	e8 2a f9 ff ff       	call   80050b <fd_close>
		return r;
  800be1:	83 c4 10             	add    $0x10,%esp
  800be4:	89 da                	mov    %ebx,%edx
  800be6:	eb 17                	jmp    800bff <open+0x86>
	}

	return fd2num(fd);
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	ff 75 f4             	pushl  -0xc(%ebp)
  800bee:	e8 f4 f7 ff ff       	call   8003e7 <fd2num>
  800bf3:	89 c2                	mov    %eax,%edx
  800bf5:	83 c4 10             	add    $0x10,%esp
  800bf8:	eb 05                	jmp    800bff <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bfa:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bff:	89 d0                	mov    %edx,%eax
  800c01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c11:	b8 08 00 00 00       	mov    $0x8,%eax
  800c16:	e8 80 fd ff ff       	call   80099b <fsipc>
}
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c23:	68 fb 23 80 00       	push   $0x8023fb
  800c28:	ff 75 0c             	pushl  0xc(%ebp)
  800c2b:	e8 9a 0f 00 00       	call   801bca <strcpy>
	return 0;
}
  800c30:	b8 00 00 00 00       	mov    $0x0,%eax
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 10             	sub    $0x10,%esp
  800c3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c41:	53                   	push   %ebx
  800c42:	e8 c5 13 00 00       	call   80200c <pageref>
  800c47:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c4a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c4f:	83 f8 01             	cmp    $0x1,%eax
  800c52:	75 10                	jne    800c64 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	ff 73 0c             	pushl  0xc(%ebx)
  800c5a:	e8 ca 02 00 00       	call   800f29 <nsipc_close>
  800c5f:	89 c2                	mov    %eax,%edx
  800c61:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c64:	89 d0                	mov    %edx,%eax
  800c66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c71:	6a 00                	push   $0x0
  800c73:	ff 75 10             	pushl  0x10(%ebp)
  800c76:	ff 75 0c             	pushl  0xc(%ebp)
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	ff 70 0c             	pushl  0xc(%eax)
  800c7f:	e8 82 03 00 00       	call   801006 <nsipc_send>
}
  800c84:	c9                   	leave  
  800c85:	c3                   	ret    

00800c86 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c8c:	6a 00                	push   $0x0
  800c8e:	ff 75 10             	pushl  0x10(%ebp)
  800c91:	ff 75 0c             	pushl  0xc(%ebp)
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	ff 70 0c             	pushl  0xc(%eax)
  800c9a:	e8 fb 02 00 00       	call   800f9a <nsipc_recv>
}
  800c9f:	c9                   	leave  
  800ca0:	c3                   	ret    

00800ca1 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800ca7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800caa:	52                   	push   %edx
  800cab:	50                   	push   %eax
  800cac:	e8 ac f7 ff ff       	call   80045d <fd_lookup>
  800cb1:	83 c4 10             	add    $0x10,%esp
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	78 17                	js     800ccf <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbb:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800cc1:	39 08                	cmp    %ecx,(%eax)
  800cc3:	75 05                	jne    800cca <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800cc5:	8b 40 0c             	mov    0xc(%eax),%eax
  800cc8:	eb 05                	jmp    800ccf <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800cca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800ccf:	c9                   	leave  
  800cd0:	c3                   	ret    

00800cd1 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	83 ec 1c             	sub    $0x1c,%esp
  800cd9:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800cdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cde:	50                   	push   %eax
  800cdf:	e8 2a f7 ff ff       	call   80040e <fd_alloc>
  800ce4:	89 c3                	mov    %eax,%ebx
  800ce6:	83 c4 10             	add    $0x10,%esp
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	78 1b                	js     800d08 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800ced:	83 ec 04             	sub    $0x4,%esp
  800cf0:	68 07 04 00 00       	push   $0x407
  800cf5:	ff 75 f4             	pushl  -0xc(%ebp)
  800cf8:	6a 00                	push   $0x0
  800cfa:	e8 56 f4 ff ff       	call   800155 <sys_page_alloc>
  800cff:	89 c3                	mov    %eax,%ebx
  800d01:	83 c4 10             	add    $0x10,%esp
  800d04:	85 c0                	test   %eax,%eax
  800d06:	79 10                	jns    800d18 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	56                   	push   %esi
  800d0c:	e8 18 02 00 00       	call   800f29 <nsipc_close>
		return r;
  800d11:	83 c4 10             	add    $0x10,%esp
  800d14:	89 d8                	mov    %ebx,%eax
  800d16:	eb 24                	jmp    800d3c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d21:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d26:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  800d2d:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	52                   	push   %edx
  800d34:	e8 ae f6 ff ff       	call   8003e7 <fd2num>
  800d39:	83 c4 10             	add    $0x10,%esp
}
  800d3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d49:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4c:	e8 50 ff ff ff       	call   800ca1 <fd2sockid>
		return r;
  800d51:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d53:	85 c0                	test   %eax,%eax
  800d55:	78 1f                	js     800d76 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d57:	83 ec 04             	sub    $0x4,%esp
  800d5a:	ff 75 10             	pushl  0x10(%ebp)
  800d5d:	ff 75 0c             	pushl  0xc(%ebp)
  800d60:	50                   	push   %eax
  800d61:	e8 1c 01 00 00       	call   800e82 <nsipc_accept>
  800d66:	83 c4 10             	add    $0x10,%esp
		return r;
  800d69:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	78 07                	js     800d76 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d6f:	e8 5d ff ff ff       	call   800cd1 <alloc_sockfd>
  800d74:	89 c1                	mov    %eax,%ecx
}
  800d76:	89 c8                	mov    %ecx,%eax
  800d78:	c9                   	leave  
  800d79:	c3                   	ret    

00800d7a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	e8 19 ff ff ff       	call   800ca1 <fd2sockid>
  800d88:	89 c2                	mov    %eax,%edx
  800d8a:	85 d2                	test   %edx,%edx
  800d8c:	78 12                	js     800da0 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  800d8e:	83 ec 04             	sub    $0x4,%esp
  800d91:	ff 75 10             	pushl  0x10(%ebp)
  800d94:	ff 75 0c             	pushl  0xc(%ebp)
  800d97:	52                   	push   %edx
  800d98:	e8 35 01 00 00       	call   800ed2 <nsipc_bind>
  800d9d:	83 c4 10             	add    $0x10,%esp
}
  800da0:	c9                   	leave  
  800da1:	c3                   	ret    

00800da2 <shutdown>:

int
shutdown(int s, int how)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dab:	e8 f1 fe ff ff       	call   800ca1 <fd2sockid>
  800db0:	89 c2                	mov    %eax,%edx
  800db2:	85 d2                	test   %edx,%edx
  800db4:	78 0f                	js     800dc5 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  800db6:	83 ec 08             	sub    $0x8,%esp
  800db9:	ff 75 0c             	pushl  0xc(%ebp)
  800dbc:	52                   	push   %edx
  800dbd:	e8 45 01 00 00       	call   800f07 <nsipc_shutdown>
  800dc2:	83 c4 10             	add    $0x10,%esp
}
  800dc5:	c9                   	leave  
  800dc6:	c3                   	ret    

00800dc7 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd0:	e8 cc fe ff ff       	call   800ca1 <fd2sockid>
  800dd5:	89 c2                	mov    %eax,%edx
  800dd7:	85 d2                	test   %edx,%edx
  800dd9:	78 12                	js     800ded <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  800ddb:	83 ec 04             	sub    $0x4,%esp
  800dde:	ff 75 10             	pushl  0x10(%ebp)
  800de1:	ff 75 0c             	pushl  0xc(%ebp)
  800de4:	52                   	push   %edx
  800de5:	e8 59 01 00 00       	call   800f43 <nsipc_connect>
  800dea:	83 c4 10             	add    $0x10,%esp
}
  800ded:	c9                   	leave  
  800dee:	c3                   	ret    

00800def <listen>:

int
listen(int s, int backlog)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	e8 a4 fe ff ff       	call   800ca1 <fd2sockid>
  800dfd:	89 c2                	mov    %eax,%edx
  800dff:	85 d2                	test   %edx,%edx
  800e01:	78 0f                	js     800e12 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  800e03:	83 ec 08             	sub    $0x8,%esp
  800e06:	ff 75 0c             	pushl  0xc(%ebp)
  800e09:	52                   	push   %edx
  800e0a:	e8 69 01 00 00       	call   800f78 <nsipc_listen>
  800e0f:	83 c4 10             	add    $0x10,%esp
}
  800e12:	c9                   	leave  
  800e13:	c3                   	ret    

00800e14 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e1a:	ff 75 10             	pushl  0x10(%ebp)
  800e1d:	ff 75 0c             	pushl  0xc(%ebp)
  800e20:	ff 75 08             	pushl  0x8(%ebp)
  800e23:	e8 3c 02 00 00       	call   801064 <nsipc_socket>
  800e28:	89 c2                	mov    %eax,%edx
  800e2a:	83 c4 10             	add    $0x10,%esp
  800e2d:	85 d2                	test   %edx,%edx
  800e2f:	78 05                	js     800e36 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  800e31:	e8 9b fe ff ff       	call   800cd1 <alloc_sockfd>
}
  800e36:	c9                   	leave  
  800e37:	c3                   	ret    

00800e38 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	53                   	push   %ebx
  800e3c:	83 ec 04             	sub    $0x4,%esp
  800e3f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e41:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e48:	75 12                	jne    800e5c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e4a:	83 ec 0c             	sub    $0xc,%esp
  800e4d:	6a 02                	push   $0x2
  800e4f:	e8 80 11 00 00       	call   801fd4 <ipc_find_env>
  800e54:	a3 04 40 80 00       	mov    %eax,0x804004
  800e59:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e5c:	6a 07                	push   $0x7
  800e5e:	68 00 60 80 00       	push   $0x806000
  800e63:	53                   	push   %ebx
  800e64:	ff 35 04 40 80 00    	pushl  0x804004
  800e6a:	e8 11 11 00 00       	call   801f80 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e6f:	83 c4 0c             	add    $0xc,%esp
  800e72:	6a 00                	push   $0x0
  800e74:	6a 00                	push   $0x0
  800e76:	6a 00                	push   $0x0
  800e78:	e8 9a 10 00 00       	call   801f17 <ipc_recv>
}
  800e7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e92:	8b 06                	mov    (%esi),%eax
  800e94:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e99:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9e:	e8 95 ff ff ff       	call   800e38 <nsipc>
  800ea3:	89 c3                	mov    %eax,%ebx
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	78 20                	js     800ec9 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	ff 35 10 60 80 00    	pushl  0x806010
  800eb2:	68 00 60 80 00       	push   $0x806000
  800eb7:	ff 75 0c             	pushl  0xc(%ebp)
  800eba:	e8 9d 0e 00 00       	call   801d5c <memmove>
		*addrlen = ret->ret_addrlen;
  800ebf:	a1 10 60 80 00       	mov    0x806010,%eax
  800ec4:	89 06                	mov    %eax,(%esi)
  800ec6:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800ec9:	89 d8                	mov    %ebx,%eax
  800ecb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ece:	5b                   	pop    %ebx
  800ecf:	5e                   	pop    %esi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    

00800ed2 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 08             	sub    $0x8,%esp
  800ed9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800edc:	8b 45 08             	mov    0x8(%ebp),%eax
  800edf:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ee4:	53                   	push   %ebx
  800ee5:	ff 75 0c             	pushl  0xc(%ebp)
  800ee8:	68 04 60 80 00       	push   $0x806004
  800eed:	e8 6a 0e 00 00       	call   801d5c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800ef2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800ef8:	b8 02 00 00 00       	mov    $0x2,%eax
  800efd:	e8 36 ff ff ff       	call   800e38 <nsipc>
}
  800f02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    

00800f07 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f10:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f18:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800f22:	e8 11 ff ff ff       	call   800e38 <nsipc>
}
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    

00800f29 <nsipc_close>:

int
nsipc_close(int s)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f32:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f37:	b8 04 00 00 00       	mov    $0x4,%eax
  800f3c:	e8 f7 fe ff ff       	call   800e38 <nsipc>
}
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	53                   	push   %ebx
  800f47:	83 ec 08             	sub    $0x8,%esp
  800f4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f50:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f55:	53                   	push   %ebx
  800f56:	ff 75 0c             	pushl  0xc(%ebp)
  800f59:	68 04 60 80 00       	push   $0x806004
  800f5e:	e8 f9 0d 00 00       	call   801d5c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f63:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f69:	b8 05 00 00 00       	mov    $0x5,%eax
  800f6e:	e8 c5 fe ff ff       	call   800e38 <nsipc>
}
  800f73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f76:	c9                   	leave  
  800f77:	c3                   	ret    

00800f78 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f81:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f89:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f93:	e8 a0 fe ff ff       	call   800e38 <nsipc>
}
  800f98:	c9                   	leave  
  800f99:	c3                   	ret    

00800f9a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800faa:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800fb0:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb3:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800fb8:	b8 07 00 00 00       	mov    $0x7,%eax
  800fbd:	e8 76 fe ff ff       	call   800e38 <nsipc>
  800fc2:	89 c3                	mov    %eax,%ebx
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 35                	js     800ffd <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800fc8:	39 f0                	cmp    %esi,%eax
  800fca:	7f 07                	jg     800fd3 <nsipc_recv+0x39>
  800fcc:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800fd1:	7e 16                	jle    800fe9 <nsipc_recv+0x4f>
  800fd3:	68 07 24 80 00       	push   $0x802407
  800fd8:	68 cf 23 80 00       	push   $0x8023cf
  800fdd:	6a 62                	push   $0x62
  800fdf:	68 1c 24 80 00       	push   $0x80241c
  800fe4:	e8 81 05 00 00       	call   80156a <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fe9:	83 ec 04             	sub    $0x4,%esp
  800fec:	50                   	push   %eax
  800fed:	68 00 60 80 00       	push   $0x806000
  800ff2:	ff 75 0c             	pushl  0xc(%ebp)
  800ff5:	e8 62 0d 00 00       	call   801d5c <memmove>
  800ffa:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800ffd:	89 d8                	mov    %ebx,%eax
  800fff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801002:	5b                   	pop    %ebx
  801003:	5e                   	pop    %esi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	53                   	push   %ebx
  80100a:	83 ec 04             	sub    $0x4,%esp
  80100d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801010:	8b 45 08             	mov    0x8(%ebp),%eax
  801013:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801018:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80101e:	7e 16                	jle    801036 <nsipc_send+0x30>
  801020:	68 28 24 80 00       	push   $0x802428
  801025:	68 cf 23 80 00       	push   $0x8023cf
  80102a:	6a 6d                	push   $0x6d
  80102c:	68 1c 24 80 00       	push   $0x80241c
  801031:	e8 34 05 00 00       	call   80156a <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801036:	83 ec 04             	sub    $0x4,%esp
  801039:	53                   	push   %ebx
  80103a:	ff 75 0c             	pushl  0xc(%ebp)
  80103d:	68 0c 60 80 00       	push   $0x80600c
  801042:	e8 15 0d 00 00       	call   801d5c <memmove>
	nsipcbuf.send.req_size = size;
  801047:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80104d:	8b 45 14             	mov    0x14(%ebp),%eax
  801050:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801055:	b8 08 00 00 00       	mov    $0x8,%eax
  80105a:	e8 d9 fd ff ff       	call   800e38 <nsipc>
}
  80105f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801062:	c9                   	leave  
  801063:	c3                   	ret    

00801064 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80106a:	8b 45 08             	mov    0x8(%ebp),%eax
  80106d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801072:	8b 45 0c             	mov    0xc(%ebp),%eax
  801075:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80107a:	8b 45 10             	mov    0x10(%ebp),%eax
  80107d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801082:	b8 09 00 00 00       	mov    $0x9,%eax
  801087:	e8 ac fd ff ff       	call   800e38 <nsipc>
}
  80108c:	c9                   	leave  
  80108d:	c3                   	ret    

0080108e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	ff 75 08             	pushl  0x8(%ebp)
  80109c:	e8 56 f3 ff ff       	call   8003f7 <fd2data>
  8010a1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010a3:	83 c4 08             	add    $0x8,%esp
  8010a6:	68 34 24 80 00       	push   $0x802434
  8010ab:	53                   	push   %ebx
  8010ac:	e8 19 0b 00 00       	call   801bca <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010b1:	8b 56 04             	mov    0x4(%esi),%edx
  8010b4:	89 d0                	mov    %edx,%eax
  8010b6:	2b 06                	sub    (%esi),%eax
  8010b8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8010be:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8010c5:	00 00 00 
	stat->st_dev = &devpipe;
  8010c8:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8010cf:	30 80 00 
	return 0;
}
  8010d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010da:	5b                   	pop    %ebx
  8010db:	5e                   	pop    %esi
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 0c             	sub    $0xc,%esp
  8010e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010e8:	53                   	push   %ebx
  8010e9:	6a 00                	push   $0x0
  8010eb:	e8 ea f0 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010f0:	89 1c 24             	mov    %ebx,(%esp)
  8010f3:	e8 ff f2 ff ff       	call   8003f7 <fd2data>
  8010f8:	83 c4 08             	add    $0x8,%esp
  8010fb:	50                   	push   %eax
  8010fc:	6a 00                	push   $0x0
  8010fe:	e8 d7 f0 ff ff       	call   8001da <sys_page_unmap>
}
  801103:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801106:	c9                   	leave  
  801107:	c3                   	ret    

00801108 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	57                   	push   %edi
  80110c:	56                   	push   %esi
  80110d:	53                   	push   %ebx
  80110e:	83 ec 1c             	sub    $0x1c,%esp
  801111:	89 c6                	mov    %eax,%esi
  801113:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801116:	a1 08 40 80 00       	mov    0x804008,%eax
  80111b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	56                   	push   %esi
  801122:	e8 e5 0e 00 00       	call   80200c <pageref>
  801127:	89 c7                	mov    %eax,%edi
  801129:	83 c4 04             	add    $0x4,%esp
  80112c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80112f:	e8 d8 0e 00 00       	call   80200c <pageref>
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	39 c7                	cmp    %eax,%edi
  801139:	0f 94 c2             	sete   %dl
  80113c:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80113f:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801145:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801148:	39 fb                	cmp    %edi,%ebx
  80114a:	74 19                	je     801165 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  80114c:	84 d2                	test   %dl,%dl
  80114e:	74 c6                	je     801116 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801150:	8b 51 58             	mov    0x58(%ecx),%edx
  801153:	50                   	push   %eax
  801154:	52                   	push   %edx
  801155:	53                   	push   %ebx
  801156:	68 3b 24 80 00       	push   $0x80243b
  80115b:	e8 e3 04 00 00       	call   801643 <cprintf>
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	eb b1                	jmp    801116 <_pipeisclosed+0xe>
	}
}
  801165:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801168:	5b                   	pop    %ebx
  801169:	5e                   	pop    %esi
  80116a:	5f                   	pop    %edi
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	57                   	push   %edi
  801171:	56                   	push   %esi
  801172:	53                   	push   %ebx
  801173:	83 ec 28             	sub    $0x28,%esp
  801176:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801179:	56                   	push   %esi
  80117a:	e8 78 f2 ff ff       	call   8003f7 <fd2data>
  80117f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	bf 00 00 00 00       	mov    $0x0,%edi
  801189:	eb 4b                	jmp    8011d6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80118b:	89 da                	mov    %ebx,%edx
  80118d:	89 f0                	mov    %esi,%eax
  80118f:	e8 74 ff ff ff       	call   801108 <_pipeisclosed>
  801194:	85 c0                	test   %eax,%eax
  801196:	75 48                	jne    8011e0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801198:	e8 99 ef ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80119d:	8b 43 04             	mov    0x4(%ebx),%eax
  8011a0:	8b 0b                	mov    (%ebx),%ecx
  8011a2:	8d 51 20             	lea    0x20(%ecx),%edx
  8011a5:	39 d0                	cmp    %edx,%eax
  8011a7:	73 e2                	jae    80118b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ac:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011b0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8011b3:	89 c2                	mov    %eax,%edx
  8011b5:	c1 fa 1f             	sar    $0x1f,%edx
  8011b8:	89 d1                	mov    %edx,%ecx
  8011ba:	c1 e9 1b             	shr    $0x1b,%ecx
  8011bd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8011c0:	83 e2 1f             	and    $0x1f,%edx
  8011c3:	29 ca                	sub    %ecx,%edx
  8011c5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8011c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011cd:	83 c0 01             	add    $0x1,%eax
  8011d0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d3:	83 c7 01             	add    $0x1,%edi
  8011d6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011d9:	75 c2                	jne    80119d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011db:	8b 45 10             	mov    0x10(%ebp),%eax
  8011de:	eb 05                	jmp    8011e5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011e0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	57                   	push   %edi
  8011f1:	56                   	push   %esi
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 18             	sub    $0x18,%esp
  8011f6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011f9:	57                   	push   %edi
  8011fa:	e8 f8 f1 ff ff       	call   8003f7 <fd2data>
  8011ff:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	bb 00 00 00 00       	mov    $0x0,%ebx
  801209:	eb 3d                	jmp    801248 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80120b:	85 db                	test   %ebx,%ebx
  80120d:	74 04                	je     801213 <devpipe_read+0x26>
				return i;
  80120f:	89 d8                	mov    %ebx,%eax
  801211:	eb 44                	jmp    801257 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801213:	89 f2                	mov    %esi,%edx
  801215:	89 f8                	mov    %edi,%eax
  801217:	e8 ec fe ff ff       	call   801108 <_pipeisclosed>
  80121c:	85 c0                	test   %eax,%eax
  80121e:	75 32                	jne    801252 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801220:	e8 11 ef ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801225:	8b 06                	mov    (%esi),%eax
  801227:	3b 46 04             	cmp    0x4(%esi),%eax
  80122a:	74 df                	je     80120b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80122c:	99                   	cltd   
  80122d:	c1 ea 1b             	shr    $0x1b,%edx
  801230:	01 d0                	add    %edx,%eax
  801232:	83 e0 1f             	and    $0x1f,%eax
  801235:	29 d0                	sub    %edx,%eax
  801237:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80123c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80123f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801242:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801245:	83 c3 01             	add    $0x1,%ebx
  801248:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80124b:	75 d8                	jne    801225 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80124d:	8b 45 10             	mov    0x10(%ebp),%eax
  801250:	eb 05                	jmp    801257 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801252:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125a:	5b                   	pop    %ebx
  80125b:	5e                   	pop    %esi
  80125c:	5f                   	pop    %edi
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
  801264:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	e8 9e f1 ff ff       	call   80040e <fd_alloc>
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	89 c2                	mov    %eax,%edx
  801275:	85 c0                	test   %eax,%eax
  801277:	0f 88 2c 01 00 00    	js     8013a9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127d:	83 ec 04             	sub    $0x4,%esp
  801280:	68 07 04 00 00       	push   $0x407
  801285:	ff 75 f4             	pushl  -0xc(%ebp)
  801288:	6a 00                	push   $0x0
  80128a:	e8 c6 ee ff ff       	call   800155 <sys_page_alloc>
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	89 c2                	mov    %eax,%edx
  801294:	85 c0                	test   %eax,%eax
  801296:	0f 88 0d 01 00 00    	js     8013a9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80129c:	83 ec 0c             	sub    $0xc,%esp
  80129f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a2:	50                   	push   %eax
  8012a3:	e8 66 f1 ff ff       	call   80040e <fd_alloc>
  8012a8:	89 c3                	mov    %eax,%ebx
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	0f 88 e2 00 00 00    	js     801397 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012b5:	83 ec 04             	sub    $0x4,%esp
  8012b8:	68 07 04 00 00       	push   $0x407
  8012bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c0:	6a 00                	push   $0x0
  8012c2:	e8 8e ee ff ff       	call   800155 <sys_page_alloc>
  8012c7:	89 c3                	mov    %eax,%ebx
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	0f 88 c3 00 00 00    	js     801397 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012d4:	83 ec 0c             	sub    $0xc,%esp
  8012d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8012da:	e8 18 f1 ff ff       	call   8003f7 <fd2data>
  8012df:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012e1:	83 c4 0c             	add    $0xc,%esp
  8012e4:	68 07 04 00 00       	push   $0x407
  8012e9:	50                   	push   %eax
  8012ea:	6a 00                	push   $0x0
  8012ec:	e8 64 ee ff ff       	call   800155 <sys_page_alloc>
  8012f1:	89 c3                	mov    %eax,%ebx
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	0f 88 89 00 00 00    	js     801387 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012fe:	83 ec 0c             	sub    $0xc,%esp
  801301:	ff 75 f0             	pushl  -0x10(%ebp)
  801304:	e8 ee f0 ff ff       	call   8003f7 <fd2data>
  801309:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801310:	50                   	push   %eax
  801311:	6a 00                	push   $0x0
  801313:	56                   	push   %esi
  801314:	6a 00                	push   $0x0
  801316:	e8 7d ee ff ff       	call   800198 <sys_page_map>
  80131b:	89 c3                	mov    %eax,%ebx
  80131d:	83 c4 20             	add    $0x20,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 55                	js     801379 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801324:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80132a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80132f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801332:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801339:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80133f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801342:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801344:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801347:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80134e:	83 ec 0c             	sub    $0xc,%esp
  801351:	ff 75 f4             	pushl  -0xc(%ebp)
  801354:	e8 8e f0 ff ff       	call   8003e7 <fd2num>
  801359:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80135c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80135e:	83 c4 04             	add    $0x4,%esp
  801361:	ff 75 f0             	pushl  -0x10(%ebp)
  801364:	e8 7e f0 ff ff       	call   8003e7 <fd2num>
  801369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80136c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	ba 00 00 00 00       	mov    $0x0,%edx
  801377:	eb 30                	jmp    8013a9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	56                   	push   %esi
  80137d:	6a 00                	push   $0x0
  80137f:	e8 56 ee ff ff       	call   8001da <sys_page_unmap>
  801384:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	ff 75 f0             	pushl  -0x10(%ebp)
  80138d:	6a 00                	push   $0x0
  80138f:	e8 46 ee ff ff       	call   8001da <sys_page_unmap>
  801394:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	ff 75 f4             	pushl  -0xc(%ebp)
  80139d:	6a 00                	push   $0x0
  80139f:	e8 36 ee ff ff       	call   8001da <sys_page_unmap>
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013a9:	89 d0                	mov    %edx,%eax
  8013ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ae:	5b                   	pop    %ebx
  8013af:	5e                   	pop    %esi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	ff 75 08             	pushl  0x8(%ebp)
  8013bf:	e8 99 f0 ff ff       	call   80045d <fd_lookup>
  8013c4:	89 c2                	mov    %eax,%edx
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	85 d2                	test   %edx,%edx
  8013cb:	78 18                	js     8013e5 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013cd:	83 ec 0c             	sub    $0xc,%esp
  8013d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d3:	e8 1f f0 ff ff       	call   8003f7 <fd2data>
	return _pipeisclosed(fd, p);
  8013d8:	89 c2                	mov    %eax,%edx
  8013da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013dd:	e8 26 fd ff ff       	call   801108 <_pipeisclosed>
  8013e2:	83 c4 10             	add    $0x10,%esp
}
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    

008013e7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ef:	5d                   	pop    %ebp
  8013f0:	c3                   	ret    

008013f1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013f7:	68 53 24 80 00       	push   $0x802453
  8013fc:	ff 75 0c             	pushl  0xc(%ebp)
  8013ff:	e8 c6 07 00 00       	call   801bca <strcpy>
	return 0;
}
  801404:	b8 00 00 00 00       	mov    $0x0,%eax
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	57                   	push   %edi
  80140f:	56                   	push   %esi
  801410:	53                   	push   %ebx
  801411:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801417:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80141c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801422:	eb 2d                	jmp    801451 <devcons_write+0x46>
		m = n - tot;
  801424:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801427:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801429:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80142c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801431:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801434:	83 ec 04             	sub    $0x4,%esp
  801437:	53                   	push   %ebx
  801438:	03 45 0c             	add    0xc(%ebp),%eax
  80143b:	50                   	push   %eax
  80143c:	57                   	push   %edi
  80143d:	e8 1a 09 00 00       	call   801d5c <memmove>
		sys_cputs(buf, m);
  801442:	83 c4 08             	add    $0x8,%esp
  801445:	53                   	push   %ebx
  801446:	57                   	push   %edi
  801447:	e8 4d ec ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80144c:	01 de                	add    %ebx,%esi
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	89 f0                	mov    %esi,%eax
  801453:	3b 75 10             	cmp    0x10(%ebp),%esi
  801456:	72 cc                	jb     801424 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801458:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145b:	5b                   	pop    %ebx
  80145c:	5e                   	pop    %esi
  80145d:	5f                   	pop    %edi
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801466:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80146b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80146f:	75 07                	jne    801478 <devcons_read+0x18>
  801471:	eb 28                	jmp    80149b <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801473:	e8 be ec ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801478:	e8 3a ec ff ff       	call   8000b7 <sys_cgetc>
  80147d:	85 c0                	test   %eax,%eax
  80147f:	74 f2                	je     801473 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801481:	85 c0                	test   %eax,%eax
  801483:	78 16                	js     80149b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801485:	83 f8 04             	cmp    $0x4,%eax
  801488:	74 0c                	je     801496 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80148a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80148d:	88 02                	mov    %al,(%edx)
	return 1;
  80148f:	b8 01 00 00 00       	mov    $0x1,%eax
  801494:	eb 05                	jmp    80149b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801496:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014a9:	6a 01                	push   $0x1
  8014ab:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014ae:	50                   	push   %eax
  8014af:	e8 e5 eb ff ff       	call   800099 <sys_cputs>
  8014b4:	83 c4 10             	add    $0x10,%esp
}
  8014b7:	c9                   	leave  
  8014b8:	c3                   	ret    

008014b9 <getchar>:

int
getchar(void)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014bf:	6a 01                	push   $0x1
  8014c1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014c4:	50                   	push   %eax
  8014c5:	6a 00                	push   $0x0
  8014c7:	e8 00 f2 ff ff       	call   8006cc <read>
	if (r < 0)
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 0f                	js     8014e2 <getchar+0x29>
		return r;
	if (r < 1)
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	7e 06                	jle    8014dd <getchar+0x24>
		return -E_EOF;
	return c;
  8014d7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014db:	eb 05                	jmp    8014e2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014dd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ed:	50                   	push   %eax
  8014ee:	ff 75 08             	pushl  0x8(%ebp)
  8014f1:	e8 67 ef ff ff       	call   80045d <fd_lookup>
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 11                	js     80150e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801500:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801506:	39 10                	cmp    %edx,(%eax)
  801508:	0f 94 c0             	sete   %al
  80150b:	0f b6 c0             	movzbl %al,%eax
}
  80150e:	c9                   	leave  
  80150f:	c3                   	ret    

00801510 <opencons>:

int
opencons(void)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801516:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801519:	50                   	push   %eax
  80151a:	e8 ef ee ff ff       	call   80040e <fd_alloc>
  80151f:	83 c4 10             	add    $0x10,%esp
		return r;
  801522:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801524:	85 c0                	test   %eax,%eax
  801526:	78 3e                	js     801566 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801528:	83 ec 04             	sub    $0x4,%esp
  80152b:	68 07 04 00 00       	push   $0x407
  801530:	ff 75 f4             	pushl  -0xc(%ebp)
  801533:	6a 00                	push   $0x0
  801535:	e8 1b ec ff ff       	call   800155 <sys_page_alloc>
  80153a:	83 c4 10             	add    $0x10,%esp
		return r;
  80153d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 23                	js     801566 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801543:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801549:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80154e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801551:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801558:	83 ec 0c             	sub    $0xc,%esp
  80155b:	50                   	push   %eax
  80155c:	e8 86 ee ff ff       	call   8003e7 <fd2num>
  801561:	89 c2                	mov    %eax,%edx
  801563:	83 c4 10             	add    $0x10,%esp
}
  801566:	89 d0                	mov    %edx,%eax
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	56                   	push   %esi
  80156e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80156f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801572:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801578:	e8 9a eb ff ff       	call   800117 <sys_getenvid>
  80157d:	83 ec 0c             	sub    $0xc,%esp
  801580:	ff 75 0c             	pushl  0xc(%ebp)
  801583:	ff 75 08             	pushl  0x8(%ebp)
  801586:	56                   	push   %esi
  801587:	50                   	push   %eax
  801588:	68 60 24 80 00       	push   $0x802460
  80158d:	e8 b1 00 00 00       	call   801643 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801592:	83 c4 18             	add    $0x18,%esp
  801595:	53                   	push   %ebx
  801596:	ff 75 10             	pushl  0x10(%ebp)
  801599:	e8 54 00 00 00       	call   8015f2 <vcprintf>
	cprintf("\n");
  80159e:	c7 04 24 4c 24 80 00 	movl   $0x80244c,(%esp)
  8015a5:	e8 99 00 00 00       	call   801643 <cprintf>
  8015aa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015ad:	cc                   	int3   
  8015ae:	eb fd                	jmp    8015ad <_panic+0x43>

008015b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	53                   	push   %ebx
  8015b4:	83 ec 04             	sub    $0x4,%esp
  8015b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015ba:	8b 13                	mov    (%ebx),%edx
  8015bc:	8d 42 01             	lea    0x1(%edx),%eax
  8015bf:	89 03                	mov    %eax,(%ebx)
  8015c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015c4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8015c8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015cd:	75 1a                	jne    8015e9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	68 ff 00 00 00       	push   $0xff
  8015d7:	8d 43 08             	lea    0x8(%ebx),%eax
  8015da:	50                   	push   %eax
  8015db:	e8 b9 ea ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8015e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015e6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015e9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    

008015f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801602:	00 00 00 
	b.cnt = 0;
  801605:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80160c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80160f:	ff 75 0c             	pushl  0xc(%ebp)
  801612:	ff 75 08             	pushl  0x8(%ebp)
  801615:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	68 b0 15 80 00       	push   $0x8015b0
  801621:	e8 4f 01 00 00       	call   801775 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801626:	83 c4 08             	add    $0x8,%esp
  801629:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80162f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	e8 5e ea ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  80163b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801641:	c9                   	leave  
  801642:	c3                   	ret    

00801643 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801649:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80164c:	50                   	push   %eax
  80164d:	ff 75 08             	pushl  0x8(%ebp)
  801650:	e8 9d ff ff ff       	call   8015f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  801655:	c9                   	leave  
  801656:	c3                   	ret    

00801657 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	57                   	push   %edi
  80165b:	56                   	push   %esi
  80165c:	53                   	push   %ebx
  80165d:	83 ec 1c             	sub    $0x1c,%esp
  801660:	89 c7                	mov    %eax,%edi
  801662:	89 d6                	mov    %edx,%esi
  801664:	8b 45 08             	mov    0x8(%ebp),%eax
  801667:	8b 55 0c             	mov    0xc(%ebp),%edx
  80166a:	89 d1                	mov    %edx,%ecx
  80166c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80166f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801672:	8b 45 10             	mov    0x10(%ebp),%eax
  801675:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801678:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80167b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801682:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801685:	72 05                	jb     80168c <printnum+0x35>
  801687:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80168a:	77 3e                	ja     8016ca <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80168c:	83 ec 0c             	sub    $0xc,%esp
  80168f:	ff 75 18             	pushl  0x18(%ebp)
  801692:	83 eb 01             	sub    $0x1,%ebx
  801695:	53                   	push   %ebx
  801696:	50                   	push   %eax
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80169d:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8016a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8016a6:	e8 a5 09 00 00       	call   802050 <__udivdi3>
  8016ab:	83 c4 18             	add    $0x18,%esp
  8016ae:	52                   	push   %edx
  8016af:	50                   	push   %eax
  8016b0:	89 f2                	mov    %esi,%edx
  8016b2:	89 f8                	mov    %edi,%eax
  8016b4:	e8 9e ff ff ff       	call   801657 <printnum>
  8016b9:	83 c4 20             	add    $0x20,%esp
  8016bc:	eb 13                	jmp    8016d1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	56                   	push   %esi
  8016c2:	ff 75 18             	pushl  0x18(%ebp)
  8016c5:	ff d7                	call   *%edi
  8016c7:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8016ca:	83 eb 01             	sub    $0x1,%ebx
  8016cd:	85 db                	test   %ebx,%ebx
  8016cf:	7f ed                	jg     8016be <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016d1:	83 ec 08             	sub    $0x8,%esp
  8016d4:	56                   	push   %esi
  8016d5:	83 ec 04             	sub    $0x4,%esp
  8016d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016db:	ff 75 e0             	pushl  -0x20(%ebp)
  8016de:	ff 75 dc             	pushl  -0x24(%ebp)
  8016e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8016e4:	e8 97 0a 00 00       	call   802180 <__umoddi3>
  8016e9:	83 c4 14             	add    $0x14,%esp
  8016ec:	0f be 80 83 24 80 00 	movsbl 0x802483(%eax),%eax
  8016f3:	50                   	push   %eax
  8016f4:	ff d7                	call   *%edi
  8016f6:	83 c4 10             	add    $0x10,%esp
}
  8016f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fc:	5b                   	pop    %ebx
  8016fd:	5e                   	pop    %esi
  8016fe:	5f                   	pop    %edi
  8016ff:	5d                   	pop    %ebp
  801700:	c3                   	ret    

00801701 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801704:	83 fa 01             	cmp    $0x1,%edx
  801707:	7e 0e                	jle    801717 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801709:	8b 10                	mov    (%eax),%edx
  80170b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80170e:	89 08                	mov    %ecx,(%eax)
  801710:	8b 02                	mov    (%edx),%eax
  801712:	8b 52 04             	mov    0x4(%edx),%edx
  801715:	eb 22                	jmp    801739 <getuint+0x38>
	else if (lflag)
  801717:	85 d2                	test   %edx,%edx
  801719:	74 10                	je     80172b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80171b:	8b 10                	mov    (%eax),%edx
  80171d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801720:	89 08                	mov    %ecx,(%eax)
  801722:	8b 02                	mov    (%edx),%eax
  801724:	ba 00 00 00 00       	mov    $0x0,%edx
  801729:	eb 0e                	jmp    801739 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80172b:	8b 10                	mov    (%eax),%edx
  80172d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801730:	89 08                	mov    %ecx,(%eax)
  801732:	8b 02                	mov    (%edx),%eax
  801734:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801739:	5d                   	pop    %ebp
  80173a:	c3                   	ret    

0080173b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801741:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801745:	8b 10                	mov    (%eax),%edx
  801747:	3b 50 04             	cmp    0x4(%eax),%edx
  80174a:	73 0a                	jae    801756 <sprintputch+0x1b>
		*b->buf++ = ch;
  80174c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80174f:	89 08                	mov    %ecx,(%eax)
  801751:	8b 45 08             	mov    0x8(%ebp),%eax
  801754:	88 02                	mov    %al,(%edx)
}
  801756:	5d                   	pop    %ebp
  801757:	c3                   	ret    

00801758 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80175e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801761:	50                   	push   %eax
  801762:	ff 75 10             	pushl  0x10(%ebp)
  801765:	ff 75 0c             	pushl  0xc(%ebp)
  801768:	ff 75 08             	pushl  0x8(%ebp)
  80176b:	e8 05 00 00 00       	call   801775 <vprintfmt>
	va_end(ap);
  801770:	83 c4 10             	add    $0x10,%esp
}
  801773:	c9                   	leave  
  801774:	c3                   	ret    

00801775 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	57                   	push   %edi
  801779:	56                   	push   %esi
  80177a:	53                   	push   %ebx
  80177b:	83 ec 2c             	sub    $0x2c,%esp
  80177e:	8b 75 08             	mov    0x8(%ebp),%esi
  801781:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801784:	8b 7d 10             	mov    0x10(%ebp),%edi
  801787:	eb 12                	jmp    80179b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801789:	85 c0                	test   %eax,%eax
  80178b:	0f 84 90 03 00 00    	je     801b21 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  801791:	83 ec 08             	sub    $0x8,%esp
  801794:	53                   	push   %ebx
  801795:	50                   	push   %eax
  801796:	ff d6                	call   *%esi
  801798:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80179b:	83 c7 01             	add    $0x1,%edi
  80179e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017a2:	83 f8 25             	cmp    $0x25,%eax
  8017a5:	75 e2                	jne    801789 <vprintfmt+0x14>
  8017a7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017ab:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8017b2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017b9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8017c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c5:	eb 07                	jmp    8017ce <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8017ca:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ce:	8d 47 01             	lea    0x1(%edi),%eax
  8017d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017d4:	0f b6 07             	movzbl (%edi),%eax
  8017d7:	0f b6 c8             	movzbl %al,%ecx
  8017da:	83 e8 23             	sub    $0x23,%eax
  8017dd:	3c 55                	cmp    $0x55,%al
  8017df:	0f 87 21 03 00 00    	ja     801b06 <vprintfmt+0x391>
  8017e5:	0f b6 c0             	movzbl %al,%eax
  8017e8:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  8017ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017f2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017f6:	eb d6                	jmp    8017ce <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801800:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801803:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801806:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80180a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80180d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801810:	83 fa 09             	cmp    $0x9,%edx
  801813:	77 39                	ja     80184e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801815:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801818:	eb e9                	jmp    801803 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80181a:	8b 45 14             	mov    0x14(%ebp),%eax
  80181d:	8d 48 04             	lea    0x4(%eax),%ecx
  801820:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801823:	8b 00                	mov    (%eax),%eax
  801825:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801828:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80182b:	eb 27                	jmp    801854 <vprintfmt+0xdf>
  80182d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801830:	85 c0                	test   %eax,%eax
  801832:	b9 00 00 00 00       	mov    $0x0,%ecx
  801837:	0f 49 c8             	cmovns %eax,%ecx
  80183a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801840:	eb 8c                	jmp    8017ce <vprintfmt+0x59>
  801842:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801845:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80184c:	eb 80                	jmp    8017ce <vprintfmt+0x59>
  80184e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801851:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801854:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801858:	0f 89 70 ff ff ff    	jns    8017ce <vprintfmt+0x59>
				width = precision, precision = -1;
  80185e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801861:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801864:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80186b:	e9 5e ff ff ff       	jmp    8017ce <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801870:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801873:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801876:	e9 53 ff ff ff       	jmp    8017ce <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80187b:	8b 45 14             	mov    0x14(%ebp),%eax
  80187e:	8d 50 04             	lea    0x4(%eax),%edx
  801881:	89 55 14             	mov    %edx,0x14(%ebp)
  801884:	83 ec 08             	sub    $0x8,%esp
  801887:	53                   	push   %ebx
  801888:	ff 30                	pushl  (%eax)
  80188a:	ff d6                	call   *%esi
			break;
  80188c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80188f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801892:	e9 04 ff ff ff       	jmp    80179b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801897:	8b 45 14             	mov    0x14(%ebp),%eax
  80189a:	8d 50 04             	lea    0x4(%eax),%edx
  80189d:	89 55 14             	mov    %edx,0x14(%ebp)
  8018a0:	8b 00                	mov    (%eax),%eax
  8018a2:	99                   	cltd   
  8018a3:	31 d0                	xor    %edx,%eax
  8018a5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018a7:	83 f8 0f             	cmp    $0xf,%eax
  8018aa:	7f 0b                	jg     8018b7 <vprintfmt+0x142>
  8018ac:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  8018b3:	85 d2                	test   %edx,%edx
  8018b5:	75 18                	jne    8018cf <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8018b7:	50                   	push   %eax
  8018b8:	68 9b 24 80 00       	push   $0x80249b
  8018bd:	53                   	push   %ebx
  8018be:	56                   	push   %esi
  8018bf:	e8 94 fe ff ff       	call   801758 <printfmt>
  8018c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8018ca:	e9 cc fe ff ff       	jmp    80179b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018cf:	52                   	push   %edx
  8018d0:	68 e1 23 80 00       	push   $0x8023e1
  8018d5:	53                   	push   %ebx
  8018d6:	56                   	push   %esi
  8018d7:	e8 7c fe ff ff       	call   801758 <printfmt>
  8018dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018e2:	e9 b4 fe ff ff       	jmp    80179b <vprintfmt+0x26>
  8018e7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8018ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018ed:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f3:	8d 50 04             	lea    0x4(%eax),%edx
  8018f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8018f9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018fb:	85 ff                	test   %edi,%edi
  8018fd:	ba 94 24 80 00       	mov    $0x802494,%edx
  801902:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  801905:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801909:	0f 84 92 00 00 00    	je     8019a1 <vprintfmt+0x22c>
  80190f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801913:	0f 8e 96 00 00 00    	jle    8019af <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801919:	83 ec 08             	sub    $0x8,%esp
  80191c:	51                   	push   %ecx
  80191d:	57                   	push   %edi
  80191e:	e8 86 02 00 00       	call   801ba9 <strnlen>
  801923:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801926:	29 c1                	sub    %eax,%ecx
  801928:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80192b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80192e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801932:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801935:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801938:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80193a:	eb 0f                	jmp    80194b <vprintfmt+0x1d6>
					putch(padc, putdat);
  80193c:	83 ec 08             	sub    $0x8,%esp
  80193f:	53                   	push   %ebx
  801940:	ff 75 e0             	pushl  -0x20(%ebp)
  801943:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801945:	83 ef 01             	sub    $0x1,%edi
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	85 ff                	test   %edi,%edi
  80194d:	7f ed                	jg     80193c <vprintfmt+0x1c7>
  80194f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801952:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801955:	85 c9                	test   %ecx,%ecx
  801957:	b8 00 00 00 00       	mov    $0x0,%eax
  80195c:	0f 49 c1             	cmovns %ecx,%eax
  80195f:	29 c1                	sub    %eax,%ecx
  801961:	89 75 08             	mov    %esi,0x8(%ebp)
  801964:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801967:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80196a:	89 cb                	mov    %ecx,%ebx
  80196c:	eb 4d                	jmp    8019bb <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80196e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801972:	74 1b                	je     80198f <vprintfmt+0x21a>
  801974:	0f be c0             	movsbl %al,%eax
  801977:	83 e8 20             	sub    $0x20,%eax
  80197a:	83 f8 5e             	cmp    $0x5e,%eax
  80197d:	76 10                	jbe    80198f <vprintfmt+0x21a>
					putch('?', putdat);
  80197f:	83 ec 08             	sub    $0x8,%esp
  801982:	ff 75 0c             	pushl  0xc(%ebp)
  801985:	6a 3f                	push   $0x3f
  801987:	ff 55 08             	call   *0x8(%ebp)
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	eb 0d                	jmp    80199c <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	ff 75 0c             	pushl  0xc(%ebp)
  801995:	52                   	push   %edx
  801996:	ff 55 08             	call   *0x8(%ebp)
  801999:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80199c:	83 eb 01             	sub    $0x1,%ebx
  80199f:	eb 1a                	jmp    8019bb <vprintfmt+0x246>
  8019a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8019a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019ad:	eb 0c                	jmp    8019bb <vprintfmt+0x246>
  8019af:	89 75 08             	mov    %esi,0x8(%ebp)
  8019b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019bb:	83 c7 01             	add    $0x1,%edi
  8019be:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019c2:	0f be d0             	movsbl %al,%edx
  8019c5:	85 d2                	test   %edx,%edx
  8019c7:	74 23                	je     8019ec <vprintfmt+0x277>
  8019c9:	85 f6                	test   %esi,%esi
  8019cb:	78 a1                	js     80196e <vprintfmt+0x1f9>
  8019cd:	83 ee 01             	sub    $0x1,%esi
  8019d0:	79 9c                	jns    80196e <vprintfmt+0x1f9>
  8019d2:	89 df                	mov    %ebx,%edi
  8019d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8019d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019da:	eb 18                	jmp    8019f4 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019dc:	83 ec 08             	sub    $0x8,%esp
  8019df:	53                   	push   %ebx
  8019e0:	6a 20                	push   $0x20
  8019e2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019e4:	83 ef 01             	sub    $0x1,%edi
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	eb 08                	jmp    8019f4 <vprintfmt+0x27f>
  8019ec:	89 df                	mov    %ebx,%edi
  8019ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019f4:	85 ff                	test   %edi,%edi
  8019f6:	7f e4                	jg     8019dc <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019fb:	e9 9b fd ff ff       	jmp    80179b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a00:	83 fa 01             	cmp    $0x1,%edx
  801a03:	7e 16                	jle    801a1b <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801a05:	8b 45 14             	mov    0x14(%ebp),%eax
  801a08:	8d 50 08             	lea    0x8(%eax),%edx
  801a0b:	89 55 14             	mov    %edx,0x14(%ebp)
  801a0e:	8b 50 04             	mov    0x4(%eax),%edx
  801a11:	8b 00                	mov    (%eax),%eax
  801a13:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a16:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a19:	eb 32                	jmp    801a4d <vprintfmt+0x2d8>
	else if (lflag)
  801a1b:	85 d2                	test   %edx,%edx
  801a1d:	74 18                	je     801a37 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801a1f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a22:	8d 50 04             	lea    0x4(%eax),%edx
  801a25:	89 55 14             	mov    %edx,0x14(%ebp)
  801a28:	8b 00                	mov    (%eax),%eax
  801a2a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a2d:	89 c1                	mov    %eax,%ecx
  801a2f:	c1 f9 1f             	sar    $0x1f,%ecx
  801a32:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a35:	eb 16                	jmp    801a4d <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801a37:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3a:	8d 50 04             	lea    0x4(%eax),%edx
  801a3d:	89 55 14             	mov    %edx,0x14(%ebp)
  801a40:	8b 00                	mov    (%eax),%eax
  801a42:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a45:	89 c1                	mov    %eax,%ecx
  801a47:	c1 f9 1f             	sar    $0x1f,%ecx
  801a4a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a4d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a50:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a53:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a58:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a5c:	79 74                	jns    801ad2 <vprintfmt+0x35d>
				putch('-', putdat);
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	53                   	push   %ebx
  801a62:	6a 2d                	push   $0x2d
  801a64:	ff d6                	call   *%esi
				num = -(long long) num;
  801a66:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a69:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a6c:	f7 d8                	neg    %eax
  801a6e:	83 d2 00             	adc    $0x0,%edx
  801a71:	f7 da                	neg    %edx
  801a73:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a76:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a7b:	eb 55                	jmp    801ad2 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a7d:	8d 45 14             	lea    0x14(%ebp),%eax
  801a80:	e8 7c fc ff ff       	call   801701 <getuint>
			base = 10;
  801a85:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a8a:	eb 46                	jmp    801ad2 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a8c:	8d 45 14             	lea    0x14(%ebp),%eax
  801a8f:	e8 6d fc ff ff       	call   801701 <getuint>
                        base = 8;
  801a94:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a99:	eb 37                	jmp    801ad2 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801a9b:	83 ec 08             	sub    $0x8,%esp
  801a9e:	53                   	push   %ebx
  801a9f:	6a 30                	push   $0x30
  801aa1:	ff d6                	call   *%esi
			putch('x', putdat);
  801aa3:	83 c4 08             	add    $0x8,%esp
  801aa6:	53                   	push   %ebx
  801aa7:	6a 78                	push   $0x78
  801aa9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801aab:	8b 45 14             	mov    0x14(%ebp),%eax
  801aae:	8d 50 04             	lea    0x4(%eax),%edx
  801ab1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ab4:	8b 00                	mov    (%eax),%eax
  801ab6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801abb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801abe:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ac3:	eb 0d                	jmp    801ad2 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ac5:	8d 45 14             	lea    0x14(%ebp),%eax
  801ac8:	e8 34 fc ff ff       	call   801701 <getuint>
			base = 16;
  801acd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ad2:	83 ec 0c             	sub    $0xc,%esp
  801ad5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ad9:	57                   	push   %edi
  801ada:	ff 75 e0             	pushl  -0x20(%ebp)
  801add:	51                   	push   %ecx
  801ade:	52                   	push   %edx
  801adf:	50                   	push   %eax
  801ae0:	89 da                	mov    %ebx,%edx
  801ae2:	89 f0                	mov    %esi,%eax
  801ae4:	e8 6e fb ff ff       	call   801657 <printnum>
			break;
  801ae9:	83 c4 20             	add    $0x20,%esp
  801aec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801aef:	e9 a7 fc ff ff       	jmp    80179b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801af4:	83 ec 08             	sub    $0x8,%esp
  801af7:	53                   	push   %ebx
  801af8:	51                   	push   %ecx
  801af9:	ff d6                	call   *%esi
			break;
  801afb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801afe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b01:	e9 95 fc ff ff       	jmp    80179b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b06:	83 ec 08             	sub    $0x8,%esp
  801b09:	53                   	push   %ebx
  801b0a:	6a 25                	push   $0x25
  801b0c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	eb 03                	jmp    801b16 <vprintfmt+0x3a1>
  801b13:	83 ef 01             	sub    $0x1,%edi
  801b16:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b1a:	75 f7                	jne    801b13 <vprintfmt+0x39e>
  801b1c:	e9 7a fc ff ff       	jmp    80179b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b24:	5b                   	pop    %ebx
  801b25:	5e                   	pop    %esi
  801b26:	5f                   	pop    %edi
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	83 ec 18             	sub    $0x18,%esp
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b32:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b35:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b38:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b3c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b3f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b46:	85 c0                	test   %eax,%eax
  801b48:	74 26                	je     801b70 <vsnprintf+0x47>
  801b4a:	85 d2                	test   %edx,%edx
  801b4c:	7e 22                	jle    801b70 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b4e:	ff 75 14             	pushl  0x14(%ebp)
  801b51:	ff 75 10             	pushl  0x10(%ebp)
  801b54:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b57:	50                   	push   %eax
  801b58:	68 3b 17 80 00       	push   $0x80173b
  801b5d:	e8 13 fc ff ff       	call   801775 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b62:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b65:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	eb 05                	jmp    801b75 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b7d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b80:	50                   	push   %eax
  801b81:	ff 75 10             	pushl  0x10(%ebp)
  801b84:	ff 75 0c             	pushl  0xc(%ebp)
  801b87:	ff 75 08             	pushl  0x8(%ebp)
  801b8a:	e8 9a ff ff ff       	call   801b29 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b8f:	c9                   	leave  
  801b90:	c3                   	ret    

00801b91 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b97:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9c:	eb 03                	jmp    801ba1 <strlen+0x10>
		n++;
  801b9e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ba1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ba5:	75 f7                	jne    801b9e <strlen+0xd>
		n++;
	return n;
}
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    

00801ba9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801baf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb7:	eb 03                	jmp    801bbc <strnlen+0x13>
		n++;
  801bb9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bbc:	39 c2                	cmp    %eax,%edx
  801bbe:	74 08                	je     801bc8 <strnlen+0x1f>
  801bc0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bc4:	75 f3                	jne    801bb9 <strnlen+0x10>
  801bc6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bc8:	5d                   	pop    %ebp
  801bc9:	c3                   	ret    

00801bca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	53                   	push   %ebx
  801bce:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bd4:	89 c2                	mov    %eax,%edx
  801bd6:	83 c2 01             	add    $0x1,%edx
  801bd9:	83 c1 01             	add    $0x1,%ecx
  801bdc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801be0:	88 5a ff             	mov    %bl,-0x1(%edx)
  801be3:	84 db                	test   %bl,%bl
  801be5:	75 ef                	jne    801bd6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801be7:	5b                   	pop    %ebx
  801be8:	5d                   	pop    %ebp
  801be9:	c3                   	ret    

00801bea <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	53                   	push   %ebx
  801bee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bf1:	53                   	push   %ebx
  801bf2:	e8 9a ff ff ff       	call   801b91 <strlen>
  801bf7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bfa:	ff 75 0c             	pushl  0xc(%ebp)
  801bfd:	01 d8                	add    %ebx,%eax
  801bff:	50                   	push   %eax
  801c00:	e8 c5 ff ff ff       	call   801bca <strcpy>
	return dst;
}
  801c05:	89 d8                	mov    %ebx,%eax
  801c07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	56                   	push   %esi
  801c10:	53                   	push   %ebx
  801c11:	8b 75 08             	mov    0x8(%ebp),%esi
  801c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c17:	89 f3                	mov    %esi,%ebx
  801c19:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c1c:	89 f2                	mov    %esi,%edx
  801c1e:	eb 0f                	jmp    801c2f <strncpy+0x23>
		*dst++ = *src;
  801c20:	83 c2 01             	add    $0x1,%edx
  801c23:	0f b6 01             	movzbl (%ecx),%eax
  801c26:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c29:	80 39 01             	cmpb   $0x1,(%ecx)
  801c2c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c2f:	39 da                	cmp    %ebx,%edx
  801c31:	75 ed                	jne    801c20 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c33:	89 f0                	mov    %esi,%eax
  801c35:	5b                   	pop    %ebx
  801c36:	5e                   	pop    %esi
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    

00801c39 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	56                   	push   %esi
  801c3d:	53                   	push   %ebx
  801c3e:	8b 75 08             	mov    0x8(%ebp),%esi
  801c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c44:	8b 55 10             	mov    0x10(%ebp),%edx
  801c47:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c49:	85 d2                	test   %edx,%edx
  801c4b:	74 21                	je     801c6e <strlcpy+0x35>
  801c4d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c51:	89 f2                	mov    %esi,%edx
  801c53:	eb 09                	jmp    801c5e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c55:	83 c2 01             	add    $0x1,%edx
  801c58:	83 c1 01             	add    $0x1,%ecx
  801c5b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c5e:	39 c2                	cmp    %eax,%edx
  801c60:	74 09                	je     801c6b <strlcpy+0x32>
  801c62:	0f b6 19             	movzbl (%ecx),%ebx
  801c65:	84 db                	test   %bl,%bl
  801c67:	75 ec                	jne    801c55 <strlcpy+0x1c>
  801c69:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c6b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c6e:	29 f0                	sub    %esi,%eax
}
  801c70:	5b                   	pop    %ebx
  801c71:	5e                   	pop    %esi
  801c72:	5d                   	pop    %ebp
  801c73:	c3                   	ret    

00801c74 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c7d:	eb 06                	jmp    801c85 <strcmp+0x11>
		p++, q++;
  801c7f:	83 c1 01             	add    $0x1,%ecx
  801c82:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c85:	0f b6 01             	movzbl (%ecx),%eax
  801c88:	84 c0                	test   %al,%al
  801c8a:	74 04                	je     801c90 <strcmp+0x1c>
  801c8c:	3a 02                	cmp    (%edx),%al
  801c8e:	74 ef                	je     801c7f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c90:	0f b6 c0             	movzbl %al,%eax
  801c93:	0f b6 12             	movzbl (%edx),%edx
  801c96:	29 d0                	sub    %edx,%eax
}
  801c98:	5d                   	pop    %ebp
  801c99:	c3                   	ret    

00801c9a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c9a:	55                   	push   %ebp
  801c9b:	89 e5                	mov    %esp,%ebp
  801c9d:	53                   	push   %ebx
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ca4:	89 c3                	mov    %eax,%ebx
  801ca6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ca9:	eb 06                	jmp    801cb1 <strncmp+0x17>
		n--, p++, q++;
  801cab:	83 c0 01             	add    $0x1,%eax
  801cae:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cb1:	39 d8                	cmp    %ebx,%eax
  801cb3:	74 15                	je     801cca <strncmp+0x30>
  801cb5:	0f b6 08             	movzbl (%eax),%ecx
  801cb8:	84 c9                	test   %cl,%cl
  801cba:	74 04                	je     801cc0 <strncmp+0x26>
  801cbc:	3a 0a                	cmp    (%edx),%cl
  801cbe:	74 eb                	je     801cab <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cc0:	0f b6 00             	movzbl (%eax),%eax
  801cc3:	0f b6 12             	movzbl (%edx),%edx
  801cc6:	29 d0                	sub    %edx,%eax
  801cc8:	eb 05                	jmp    801ccf <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cca:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801ccf:	5b                   	pop    %ebx
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cdc:	eb 07                	jmp    801ce5 <strchr+0x13>
		if (*s == c)
  801cde:	38 ca                	cmp    %cl,%dl
  801ce0:	74 0f                	je     801cf1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ce2:	83 c0 01             	add    $0x1,%eax
  801ce5:	0f b6 10             	movzbl (%eax),%edx
  801ce8:	84 d2                	test   %dl,%dl
  801cea:	75 f2                	jne    801cde <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf1:	5d                   	pop    %ebp
  801cf2:	c3                   	ret    

00801cf3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cfd:	eb 03                	jmp    801d02 <strfind+0xf>
  801cff:	83 c0 01             	add    $0x1,%eax
  801d02:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d05:	84 d2                	test   %dl,%dl
  801d07:	74 04                	je     801d0d <strfind+0x1a>
  801d09:	38 ca                	cmp    %cl,%dl
  801d0b:	75 f2                	jne    801cff <strfind+0xc>
			break;
	return (char *) s;
}
  801d0d:	5d                   	pop    %ebp
  801d0e:	c3                   	ret    

00801d0f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	57                   	push   %edi
  801d13:	56                   	push   %esi
  801d14:	53                   	push   %ebx
  801d15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d1b:	85 c9                	test   %ecx,%ecx
  801d1d:	74 36                	je     801d55 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d25:	75 28                	jne    801d4f <memset+0x40>
  801d27:	f6 c1 03             	test   $0x3,%cl
  801d2a:	75 23                	jne    801d4f <memset+0x40>
		c &= 0xFF;
  801d2c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d30:	89 d3                	mov    %edx,%ebx
  801d32:	c1 e3 08             	shl    $0x8,%ebx
  801d35:	89 d6                	mov    %edx,%esi
  801d37:	c1 e6 18             	shl    $0x18,%esi
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	c1 e0 10             	shl    $0x10,%eax
  801d3f:	09 f0                	or     %esi,%eax
  801d41:	09 c2                	or     %eax,%edx
  801d43:	89 d0                	mov    %edx,%eax
  801d45:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d47:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801d4a:	fc                   	cld    
  801d4b:	f3 ab                	rep stos %eax,%es:(%edi)
  801d4d:	eb 06                	jmp    801d55 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d52:	fc                   	cld    
  801d53:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d55:	89 f8                	mov    %edi,%eax
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5f                   	pop    %edi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    

00801d5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	57                   	push   %edi
  801d60:	56                   	push   %esi
  801d61:	8b 45 08             	mov    0x8(%ebp),%eax
  801d64:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d6a:	39 c6                	cmp    %eax,%esi
  801d6c:	73 35                	jae    801da3 <memmove+0x47>
  801d6e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d71:	39 d0                	cmp    %edx,%eax
  801d73:	73 2e                	jae    801da3 <memmove+0x47>
		s += n;
		d += n;
  801d75:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801d78:	89 d6                	mov    %edx,%esi
  801d7a:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d7c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d82:	75 13                	jne    801d97 <memmove+0x3b>
  801d84:	f6 c1 03             	test   $0x3,%cl
  801d87:	75 0e                	jne    801d97 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d89:	83 ef 04             	sub    $0x4,%edi
  801d8c:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d8f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801d92:	fd                   	std    
  801d93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d95:	eb 09                	jmp    801da0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d97:	83 ef 01             	sub    $0x1,%edi
  801d9a:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d9d:	fd                   	std    
  801d9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801da0:	fc                   	cld    
  801da1:	eb 1d                	jmp    801dc0 <memmove+0x64>
  801da3:	89 f2                	mov    %esi,%edx
  801da5:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801da7:	f6 c2 03             	test   $0x3,%dl
  801daa:	75 0f                	jne    801dbb <memmove+0x5f>
  801dac:	f6 c1 03             	test   $0x3,%cl
  801daf:	75 0a                	jne    801dbb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801db1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801db4:	89 c7                	mov    %eax,%edi
  801db6:	fc                   	cld    
  801db7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801db9:	eb 05                	jmp    801dc0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801dbb:	89 c7                	mov    %eax,%edi
  801dbd:	fc                   	cld    
  801dbe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dc0:	5e                   	pop    %esi
  801dc1:	5f                   	pop    %edi
  801dc2:	5d                   	pop    %ebp
  801dc3:	c3                   	ret    

00801dc4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801dc7:	ff 75 10             	pushl  0x10(%ebp)
  801dca:	ff 75 0c             	pushl  0xc(%ebp)
  801dcd:	ff 75 08             	pushl  0x8(%ebp)
  801dd0:	e8 87 ff ff ff       	call   801d5c <memmove>
}
  801dd5:	c9                   	leave  
  801dd6:	c3                   	ret    

00801dd7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	56                   	push   %esi
  801ddb:	53                   	push   %ebx
  801ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de2:	89 c6                	mov    %eax,%esi
  801de4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801de7:	eb 1a                	jmp    801e03 <memcmp+0x2c>
		if (*s1 != *s2)
  801de9:	0f b6 08             	movzbl (%eax),%ecx
  801dec:	0f b6 1a             	movzbl (%edx),%ebx
  801def:	38 d9                	cmp    %bl,%cl
  801df1:	74 0a                	je     801dfd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801df3:	0f b6 c1             	movzbl %cl,%eax
  801df6:	0f b6 db             	movzbl %bl,%ebx
  801df9:	29 d8                	sub    %ebx,%eax
  801dfb:	eb 0f                	jmp    801e0c <memcmp+0x35>
		s1++, s2++;
  801dfd:	83 c0 01             	add    $0x1,%eax
  801e00:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e03:	39 f0                	cmp    %esi,%eax
  801e05:	75 e2                	jne    801de9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e0c:	5b                   	pop    %ebx
  801e0d:	5e                   	pop    %esi
  801e0e:	5d                   	pop    %ebp
  801e0f:	c3                   	ret    

00801e10 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	8b 45 08             	mov    0x8(%ebp),%eax
  801e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801e19:	89 c2                	mov    %eax,%edx
  801e1b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e1e:	eb 07                	jmp    801e27 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e20:	38 08                	cmp    %cl,(%eax)
  801e22:	74 07                	je     801e2b <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e24:	83 c0 01             	add    $0x1,%eax
  801e27:	39 d0                	cmp    %edx,%eax
  801e29:	72 f5                	jb     801e20 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	57                   	push   %edi
  801e31:	56                   	push   %esi
  801e32:	53                   	push   %ebx
  801e33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e39:	eb 03                	jmp    801e3e <strtol+0x11>
		s++;
  801e3b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e3e:	0f b6 01             	movzbl (%ecx),%eax
  801e41:	3c 09                	cmp    $0x9,%al
  801e43:	74 f6                	je     801e3b <strtol+0xe>
  801e45:	3c 20                	cmp    $0x20,%al
  801e47:	74 f2                	je     801e3b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e49:	3c 2b                	cmp    $0x2b,%al
  801e4b:	75 0a                	jne    801e57 <strtol+0x2a>
		s++;
  801e4d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e50:	bf 00 00 00 00       	mov    $0x0,%edi
  801e55:	eb 10                	jmp    801e67 <strtol+0x3a>
  801e57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e5c:	3c 2d                	cmp    $0x2d,%al
  801e5e:	75 07                	jne    801e67 <strtol+0x3a>
		s++, neg = 1;
  801e60:	8d 49 01             	lea    0x1(%ecx),%ecx
  801e63:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e67:	85 db                	test   %ebx,%ebx
  801e69:	0f 94 c0             	sete   %al
  801e6c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e72:	75 19                	jne    801e8d <strtol+0x60>
  801e74:	80 39 30             	cmpb   $0x30,(%ecx)
  801e77:	75 14                	jne    801e8d <strtol+0x60>
  801e79:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e7d:	0f 85 82 00 00 00    	jne    801f05 <strtol+0xd8>
		s += 2, base = 16;
  801e83:	83 c1 02             	add    $0x2,%ecx
  801e86:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e8b:	eb 16                	jmp    801ea3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801e8d:	84 c0                	test   %al,%al
  801e8f:	74 12                	je     801ea3 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e91:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e96:	80 39 30             	cmpb   $0x30,(%ecx)
  801e99:	75 08                	jne    801ea3 <strtol+0x76>
		s++, base = 8;
  801e9b:	83 c1 01             	add    $0x1,%ecx
  801e9e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ea3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801eab:	0f b6 11             	movzbl (%ecx),%edx
  801eae:	8d 72 d0             	lea    -0x30(%edx),%esi
  801eb1:	89 f3                	mov    %esi,%ebx
  801eb3:	80 fb 09             	cmp    $0x9,%bl
  801eb6:	77 08                	ja     801ec0 <strtol+0x93>
			dig = *s - '0';
  801eb8:	0f be d2             	movsbl %dl,%edx
  801ebb:	83 ea 30             	sub    $0x30,%edx
  801ebe:	eb 22                	jmp    801ee2 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  801ec0:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ec3:	89 f3                	mov    %esi,%ebx
  801ec5:	80 fb 19             	cmp    $0x19,%bl
  801ec8:	77 08                	ja     801ed2 <strtol+0xa5>
			dig = *s - 'a' + 10;
  801eca:	0f be d2             	movsbl %dl,%edx
  801ecd:	83 ea 57             	sub    $0x57,%edx
  801ed0:	eb 10                	jmp    801ee2 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  801ed2:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ed5:	89 f3                	mov    %esi,%ebx
  801ed7:	80 fb 19             	cmp    $0x19,%bl
  801eda:	77 16                	ja     801ef2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801edc:	0f be d2             	movsbl %dl,%edx
  801edf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ee2:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ee5:	7d 0f                	jge    801ef6 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801ee7:	83 c1 01             	add    $0x1,%ecx
  801eea:	0f af 45 10          	imul   0x10(%ebp),%eax
  801eee:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ef0:	eb b9                	jmp    801eab <strtol+0x7e>
  801ef2:	89 c2                	mov    %eax,%edx
  801ef4:	eb 02                	jmp    801ef8 <strtol+0xcb>
  801ef6:	89 c2                	mov    %eax,%edx

	if (endptr)
  801ef8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801efc:	74 0d                	je     801f0b <strtol+0xde>
		*endptr = (char *) s;
  801efe:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f01:	89 0e                	mov    %ecx,(%esi)
  801f03:	eb 06                	jmp    801f0b <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f05:	84 c0                	test   %al,%al
  801f07:	75 92                	jne    801e9b <strtol+0x6e>
  801f09:	eb 98                	jmp    801ea3 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f0b:	f7 da                	neg    %edx
  801f0d:	85 ff                	test   %edi,%edi
  801f0f:	0f 45 c2             	cmovne %edx,%eax
}
  801f12:	5b                   	pop    %ebx
  801f13:	5e                   	pop    %esi
  801f14:	5f                   	pop    %edi
  801f15:	5d                   	pop    %ebp
  801f16:	c3                   	ret    

00801f17 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	56                   	push   %esi
  801f1b:	53                   	push   %ebx
  801f1c:	8b 75 08             	mov    0x8(%ebp),%esi
  801f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f25:	85 c0                	test   %eax,%eax
  801f27:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f2c:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f2f:	83 ec 0c             	sub    $0xc,%esp
  801f32:	50                   	push   %eax
  801f33:	e8 cd e3 ff ff       	call   800305 <sys_ipc_recv>
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	79 16                	jns    801f55 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801f3f:	85 f6                	test   %esi,%esi
  801f41:	74 06                	je     801f49 <ipc_recv+0x32>
  801f43:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801f49:	85 db                	test   %ebx,%ebx
  801f4b:	74 2c                	je     801f79 <ipc_recv+0x62>
  801f4d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f53:	eb 24                	jmp    801f79 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801f55:	85 f6                	test   %esi,%esi
  801f57:	74 0a                	je     801f63 <ipc_recv+0x4c>
  801f59:	a1 08 40 80 00       	mov    0x804008,%eax
  801f5e:	8b 40 74             	mov    0x74(%eax),%eax
  801f61:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801f63:	85 db                	test   %ebx,%ebx
  801f65:	74 0a                	je     801f71 <ipc_recv+0x5a>
  801f67:	a1 08 40 80 00       	mov    0x804008,%eax
  801f6c:	8b 40 78             	mov    0x78(%eax),%eax
  801f6f:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801f71:	a1 08 40 80 00       	mov    0x804008,%eax
  801f76:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7c:	5b                   	pop    %ebx
  801f7d:	5e                   	pop    %esi
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	57                   	push   %edi
  801f84:	56                   	push   %esi
  801f85:	53                   	push   %ebx
  801f86:	83 ec 0c             	sub    $0xc,%esp
  801f89:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801f92:	85 db                	test   %ebx,%ebx
  801f94:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f99:	0f 44 d8             	cmove  %eax,%ebx
  801f9c:	eb 1c                	jmp    801fba <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801f9e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fa1:	74 12                	je     801fb5 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801fa3:	50                   	push   %eax
  801fa4:	68 a0 27 80 00       	push   $0x8027a0
  801fa9:	6a 39                	push   $0x39
  801fab:	68 bb 27 80 00       	push   $0x8027bb
  801fb0:	e8 b5 f5 ff ff       	call   80156a <_panic>
                 sys_yield();
  801fb5:	e8 7c e1 ff ff       	call   800136 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801fba:	ff 75 14             	pushl  0x14(%ebp)
  801fbd:	53                   	push   %ebx
  801fbe:	56                   	push   %esi
  801fbf:	57                   	push   %edi
  801fc0:	e8 1d e3 ff ff       	call   8002e2 <sys_ipc_try_send>
  801fc5:	83 c4 10             	add    $0x10,%esp
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	78 d2                	js     801f9e <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801fcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fcf:	5b                   	pop    %ebx
  801fd0:	5e                   	pop    %esi
  801fd1:	5f                   	pop    %edi
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    

00801fd4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
  801fd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fda:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fdf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fe2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fe8:	8b 52 50             	mov    0x50(%edx),%edx
  801feb:	39 ca                	cmp    %ecx,%edx
  801fed:	75 0d                	jne    801ffc <ipc_find_env+0x28>
			return envs[i].env_id;
  801fef:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ff2:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ff7:	8b 40 08             	mov    0x8(%eax),%eax
  801ffa:	eb 0e                	jmp    80200a <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ffc:	83 c0 01             	add    $0x1,%eax
  801fff:	3d 00 04 00 00       	cmp    $0x400,%eax
  802004:	75 d9                	jne    801fdf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802006:	66 b8 00 00          	mov    $0x0,%ax
}
  80200a:	5d                   	pop    %ebp
  80200b:	c3                   	ret    

0080200c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802012:	89 d0                	mov    %edx,%eax
  802014:	c1 e8 16             	shr    $0x16,%eax
  802017:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80201e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802023:	f6 c1 01             	test   $0x1,%cl
  802026:	74 1d                	je     802045 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802028:	c1 ea 0c             	shr    $0xc,%edx
  80202b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802032:	f6 c2 01             	test   $0x1,%dl
  802035:	74 0e                	je     802045 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802037:	c1 ea 0c             	shr    $0xc,%edx
  80203a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802041:	ef 
  802042:	0f b7 c0             	movzwl %ax,%eax
}
  802045:	5d                   	pop    %ebp
  802046:	c3                   	ret    
  802047:	66 90                	xchg   %ax,%ax
  802049:	66 90                	xchg   %ax,%ax
  80204b:	66 90                	xchg   %ax,%ax
  80204d:	66 90                	xchg   %ax,%ax
  80204f:	90                   	nop

00802050 <__udivdi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	83 ec 10             	sub    $0x10,%esp
  802056:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80205a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80205e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802062:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802066:	85 d2                	test   %edx,%edx
  802068:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80206c:	89 34 24             	mov    %esi,(%esp)
  80206f:	89 c8                	mov    %ecx,%eax
  802071:	75 35                	jne    8020a8 <__udivdi3+0x58>
  802073:	39 f1                	cmp    %esi,%ecx
  802075:	0f 87 bd 00 00 00    	ja     802138 <__udivdi3+0xe8>
  80207b:	85 c9                	test   %ecx,%ecx
  80207d:	89 cd                	mov    %ecx,%ebp
  80207f:	75 0b                	jne    80208c <__udivdi3+0x3c>
  802081:	b8 01 00 00 00       	mov    $0x1,%eax
  802086:	31 d2                	xor    %edx,%edx
  802088:	f7 f1                	div    %ecx
  80208a:	89 c5                	mov    %eax,%ebp
  80208c:	89 f0                	mov    %esi,%eax
  80208e:	31 d2                	xor    %edx,%edx
  802090:	f7 f5                	div    %ebp
  802092:	89 c6                	mov    %eax,%esi
  802094:	89 f8                	mov    %edi,%eax
  802096:	f7 f5                	div    %ebp
  802098:	89 f2                	mov    %esi,%edx
  80209a:	83 c4 10             	add    $0x10,%esp
  80209d:	5e                   	pop    %esi
  80209e:	5f                   	pop    %edi
  80209f:	5d                   	pop    %ebp
  8020a0:	c3                   	ret    
  8020a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	3b 14 24             	cmp    (%esp),%edx
  8020ab:	77 7b                	ja     802128 <__udivdi3+0xd8>
  8020ad:	0f bd f2             	bsr    %edx,%esi
  8020b0:	83 f6 1f             	xor    $0x1f,%esi
  8020b3:	0f 84 97 00 00 00    	je     802150 <__udivdi3+0x100>
  8020b9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020be:	89 d7                	mov    %edx,%edi
  8020c0:	89 f1                	mov    %esi,%ecx
  8020c2:	29 f5                	sub    %esi,%ebp
  8020c4:	d3 e7                	shl    %cl,%edi
  8020c6:	89 c2                	mov    %eax,%edx
  8020c8:	89 e9                	mov    %ebp,%ecx
  8020ca:	d3 ea                	shr    %cl,%edx
  8020cc:	89 f1                	mov    %esi,%ecx
  8020ce:	09 fa                	or     %edi,%edx
  8020d0:	8b 3c 24             	mov    (%esp),%edi
  8020d3:	d3 e0                	shl    %cl,%eax
  8020d5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020d9:	89 e9                	mov    %ebp,%ecx
  8020db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020df:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020e3:	89 fa                	mov    %edi,%edx
  8020e5:	d3 ea                	shr    %cl,%edx
  8020e7:	89 f1                	mov    %esi,%ecx
  8020e9:	d3 e7                	shl    %cl,%edi
  8020eb:	89 e9                	mov    %ebp,%ecx
  8020ed:	d3 e8                	shr    %cl,%eax
  8020ef:	09 c7                	or     %eax,%edi
  8020f1:	89 f8                	mov    %edi,%eax
  8020f3:	f7 74 24 08          	divl   0x8(%esp)
  8020f7:	89 d5                	mov    %edx,%ebp
  8020f9:	89 c7                	mov    %eax,%edi
  8020fb:	f7 64 24 0c          	mull   0xc(%esp)
  8020ff:	39 d5                	cmp    %edx,%ebp
  802101:	89 14 24             	mov    %edx,(%esp)
  802104:	72 11                	jb     802117 <__udivdi3+0xc7>
  802106:	8b 54 24 04          	mov    0x4(%esp),%edx
  80210a:	89 f1                	mov    %esi,%ecx
  80210c:	d3 e2                	shl    %cl,%edx
  80210e:	39 c2                	cmp    %eax,%edx
  802110:	73 5e                	jae    802170 <__udivdi3+0x120>
  802112:	3b 2c 24             	cmp    (%esp),%ebp
  802115:	75 59                	jne    802170 <__udivdi3+0x120>
  802117:	8d 47 ff             	lea    -0x1(%edi),%eax
  80211a:	31 f6                	xor    %esi,%esi
  80211c:	89 f2                	mov    %esi,%edx
  80211e:	83 c4 10             	add    $0x10,%esp
  802121:	5e                   	pop    %esi
  802122:	5f                   	pop    %edi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    
  802125:	8d 76 00             	lea    0x0(%esi),%esi
  802128:	31 f6                	xor    %esi,%esi
  80212a:	31 c0                	xor    %eax,%eax
  80212c:	89 f2                	mov    %esi,%edx
  80212e:	83 c4 10             	add    $0x10,%esp
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	89 f2                	mov    %esi,%edx
  80213a:	31 f6                	xor    %esi,%esi
  80213c:	89 f8                	mov    %edi,%eax
  80213e:	f7 f1                	div    %ecx
  802140:	89 f2                	mov    %esi,%edx
  802142:	83 c4 10             	add    $0x10,%esp
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802154:	76 0b                	jbe    802161 <__udivdi3+0x111>
  802156:	31 c0                	xor    %eax,%eax
  802158:	3b 14 24             	cmp    (%esp),%edx
  80215b:	0f 83 37 ff ff ff    	jae    802098 <__udivdi3+0x48>
  802161:	b8 01 00 00 00       	mov    $0x1,%eax
  802166:	e9 2d ff ff ff       	jmp    802098 <__udivdi3+0x48>
  80216b:	90                   	nop
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 f8                	mov    %edi,%eax
  802172:	31 f6                	xor    %esi,%esi
  802174:	e9 1f ff ff ff       	jmp    802098 <__udivdi3+0x48>
  802179:	66 90                	xchg   %ax,%ax
  80217b:	66 90                	xchg   %ax,%ax
  80217d:	66 90                	xchg   %ax,%ax
  80217f:	90                   	nop

00802180 <__umoddi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	83 ec 20             	sub    $0x20,%esp
  802186:	8b 44 24 34          	mov    0x34(%esp),%eax
  80218a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80218e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802192:	89 c6                	mov    %eax,%esi
  802194:	89 44 24 10          	mov    %eax,0x10(%esp)
  802198:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80219c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8021a0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021a4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021a8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021ac:	85 c0                	test   %eax,%eax
  8021ae:	89 c2                	mov    %eax,%edx
  8021b0:	75 1e                	jne    8021d0 <__umoddi3+0x50>
  8021b2:	39 f7                	cmp    %esi,%edi
  8021b4:	76 52                	jbe    802208 <__umoddi3+0x88>
  8021b6:	89 c8                	mov    %ecx,%eax
  8021b8:	89 f2                	mov    %esi,%edx
  8021ba:	f7 f7                	div    %edi
  8021bc:	89 d0                	mov    %edx,%eax
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	83 c4 20             	add    $0x20,%esp
  8021c3:	5e                   	pop    %esi
  8021c4:	5f                   	pop    %edi
  8021c5:	5d                   	pop    %ebp
  8021c6:	c3                   	ret    
  8021c7:	89 f6                	mov    %esi,%esi
  8021c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021d0:	39 f0                	cmp    %esi,%eax
  8021d2:	77 5c                	ja     802230 <__umoddi3+0xb0>
  8021d4:	0f bd e8             	bsr    %eax,%ebp
  8021d7:	83 f5 1f             	xor    $0x1f,%ebp
  8021da:	75 64                	jne    802240 <__umoddi3+0xc0>
  8021dc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8021e0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8021e4:	0f 86 f6 00 00 00    	jbe    8022e0 <__umoddi3+0x160>
  8021ea:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8021ee:	0f 82 ec 00 00 00    	jb     8022e0 <__umoddi3+0x160>
  8021f4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021f8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8021fc:	83 c4 20             	add    $0x20,%esp
  8021ff:	5e                   	pop    %esi
  802200:	5f                   	pop    %edi
  802201:	5d                   	pop    %ebp
  802202:	c3                   	ret    
  802203:	90                   	nop
  802204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802208:	85 ff                	test   %edi,%edi
  80220a:	89 fd                	mov    %edi,%ebp
  80220c:	75 0b                	jne    802219 <__umoddi3+0x99>
  80220e:	b8 01 00 00 00       	mov    $0x1,%eax
  802213:	31 d2                	xor    %edx,%edx
  802215:	f7 f7                	div    %edi
  802217:	89 c5                	mov    %eax,%ebp
  802219:	8b 44 24 10          	mov    0x10(%esp),%eax
  80221d:	31 d2                	xor    %edx,%edx
  80221f:	f7 f5                	div    %ebp
  802221:	89 c8                	mov    %ecx,%eax
  802223:	f7 f5                	div    %ebp
  802225:	eb 95                	jmp    8021bc <__umoddi3+0x3c>
  802227:	89 f6                	mov    %esi,%esi
  802229:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	83 c4 20             	add    $0x20,%esp
  802237:	5e                   	pop    %esi
  802238:	5f                   	pop    %edi
  802239:	5d                   	pop    %ebp
  80223a:	c3                   	ret    
  80223b:	90                   	nop
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	b8 20 00 00 00       	mov    $0x20,%eax
  802245:	89 e9                	mov    %ebp,%ecx
  802247:	29 e8                	sub    %ebp,%eax
  802249:	d3 e2                	shl    %cl,%edx
  80224b:	89 c7                	mov    %eax,%edi
  80224d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802251:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 e8                	shr    %cl,%eax
  802259:	89 c1                	mov    %eax,%ecx
  80225b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80225f:	09 d1                	or     %edx,%ecx
  802261:	89 fa                	mov    %edi,%edx
  802263:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802267:	89 e9                	mov    %ebp,%ecx
  802269:	d3 e0                	shl    %cl,%eax
  80226b:	89 f9                	mov    %edi,%ecx
  80226d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802271:	89 f0                	mov    %esi,%eax
  802273:	d3 e8                	shr    %cl,%eax
  802275:	89 e9                	mov    %ebp,%ecx
  802277:	89 c7                	mov    %eax,%edi
  802279:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80227d:	d3 e6                	shl    %cl,%esi
  80227f:	89 d1                	mov    %edx,%ecx
  802281:	89 fa                	mov    %edi,%edx
  802283:	d3 e8                	shr    %cl,%eax
  802285:	89 e9                	mov    %ebp,%ecx
  802287:	09 f0                	or     %esi,%eax
  802289:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80228d:	f7 74 24 10          	divl   0x10(%esp)
  802291:	d3 e6                	shl    %cl,%esi
  802293:	89 d1                	mov    %edx,%ecx
  802295:	f7 64 24 0c          	mull   0xc(%esp)
  802299:	39 d1                	cmp    %edx,%ecx
  80229b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80229f:	89 d7                	mov    %edx,%edi
  8022a1:	89 c6                	mov    %eax,%esi
  8022a3:	72 0a                	jb     8022af <__umoddi3+0x12f>
  8022a5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8022a9:	73 10                	jae    8022bb <__umoddi3+0x13b>
  8022ab:	39 d1                	cmp    %edx,%ecx
  8022ad:	75 0c                	jne    8022bb <__umoddi3+0x13b>
  8022af:	89 d7                	mov    %edx,%edi
  8022b1:	89 c6                	mov    %eax,%esi
  8022b3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8022b7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8022bb:	89 ca                	mov    %ecx,%edx
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022c3:	29 f0                	sub    %esi,%eax
  8022c5:	19 fa                	sbb    %edi,%edx
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8022ce:	89 d7                	mov    %edx,%edi
  8022d0:	d3 e7                	shl    %cl,%edi
  8022d2:	89 e9                	mov    %ebp,%ecx
  8022d4:	09 f8                	or     %edi,%eax
  8022d6:	d3 ea                	shr    %cl,%edx
  8022d8:	83 c4 20             	add    $0x20,%esp
  8022db:	5e                   	pop    %esi
  8022dc:	5f                   	pop    %edi
  8022dd:	5d                   	pop    %ebp
  8022de:	c3                   	ret    
  8022df:	90                   	nop
  8022e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022e4:	29 f9                	sub    %edi,%ecx
  8022e6:	19 c6                	sbb    %eax,%esi
  8022e8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8022ec:	89 74 24 18          	mov    %esi,0x18(%esp)
  8022f0:	e9 ff fe ff ff       	jmp    8021f4 <__umoddi3+0x74>
