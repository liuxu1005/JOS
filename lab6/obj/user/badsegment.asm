
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
  80005b:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80008a:	e8 2f 05 00 00       	call   8005be <close_all>
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
	// return value.
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
	// return value.
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
	// return value.
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
  800103:	68 0a 23 80 00       	push   $0x80230a
  800108:	6a 22                	push   $0x22
  80010a:	68 27 23 80 00       	push   $0x802327
  80010f:	e8 5b 14 00 00       	call   80156f <_panic>

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
	// return value.
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
	// return value.
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
	// return value.
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
  800184:	68 0a 23 80 00       	push   $0x80230a
  800189:	6a 22                	push   $0x22
  80018b:	68 27 23 80 00       	push   $0x802327
  800190:	e8 da 13 00 00       	call   80156f <_panic>

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
	// return value.
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
  8001c6:	68 0a 23 80 00       	push   $0x80230a
  8001cb:	6a 22                	push   $0x22
  8001cd:	68 27 23 80 00       	push   $0x802327
  8001d2:	e8 98 13 00 00       	call   80156f <_panic>

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
	// return value.
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
  800208:	68 0a 23 80 00       	push   $0x80230a
  80020d:	6a 22                	push   $0x22
  80020f:	68 27 23 80 00       	push   $0x802327
  800214:	e8 56 13 00 00       	call   80156f <_panic>

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
	// return value.
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
  80024a:	68 0a 23 80 00       	push   $0x80230a
  80024f:	6a 22                	push   $0x22
  800251:	68 27 23 80 00       	push   $0x802327
  800256:	e8 14 13 00 00       	call   80156f <_panic>
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
	// return value.
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
  80028c:	68 0a 23 80 00       	push   $0x80230a
  800291:	6a 22                	push   $0x22
  800293:	68 27 23 80 00       	push   $0x802327
  800298:	e8 d2 12 00 00       	call   80156f <_panic>

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
	// return value.
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
  8002ce:	68 0a 23 80 00       	push   $0x80230a
  8002d3:	6a 22                	push   $0x22
  8002d5:	68 27 23 80 00       	push   $0x802327
  8002da:	e8 90 12 00 00       	call   80156f <_panic>

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
	// return value.
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
	// return value.
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
  800332:	68 0a 23 80 00       	push   $0x80230a
  800337:	6a 22                	push   $0x22
  800339:	68 27 23 80 00       	push   $0x802327
  80033e:	e8 2c 12 00 00       	call   80156f <_panic>

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

0080034b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035b:	89 d1                	mov    %edx,%ecx
  80035d:	89 d3                	mov    %edx,%ebx
  80035f:	89 d7                	mov    %edx,%edi
  800361:	89 d6                	mov    %edx,%esi
  800363:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <sys_transmit>:

int
sys_transmit(void *addr)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
  800370:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800373:	b9 00 00 00 00       	mov    $0x0,%ecx
  800378:	b8 0f 00 00 00       	mov    $0xf,%eax
  80037d:	8b 55 08             	mov    0x8(%ebp),%edx
  800380:	89 cb                	mov    %ecx,%ebx
  800382:	89 cf                	mov    %ecx,%edi
  800384:	89 ce                	mov    %ecx,%esi
  800386:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800388:	85 c0                	test   %eax,%eax
  80038a:	7e 17                	jle    8003a3 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80038c:	83 ec 0c             	sub    $0xc,%esp
  80038f:	50                   	push   %eax
  800390:	6a 0f                	push   $0xf
  800392:	68 0a 23 80 00       	push   $0x80230a
  800397:	6a 22                	push   $0x22
  800399:	68 27 23 80 00       	push   $0x802327
  80039e:	e8 cc 11 00 00       	call   80156f <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003a6:	5b                   	pop    %ebx
  8003a7:	5e                   	pop    %esi
  8003a8:	5f                   	pop    %edi
  8003a9:	5d                   	pop    %ebp
  8003aa:	c3                   	ret    

008003ab <sys_recv>:

int
sys_recv(void *addr)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	57                   	push   %edi
  8003af:	56                   	push   %esi
  8003b0:	53                   	push   %ebx
  8003b1:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8003b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b9:	b8 10 00 00 00       	mov    $0x10,%eax
  8003be:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c1:	89 cb                	mov    %ecx,%ebx
  8003c3:	89 cf                	mov    %ecx,%edi
  8003c5:	89 ce                	mov    %ecx,%esi
  8003c7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003c9:	85 c0                	test   %eax,%eax
  8003cb:	7e 17                	jle    8003e4 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003cd:	83 ec 0c             	sub    $0xc,%esp
  8003d0:	50                   	push   %eax
  8003d1:	6a 10                	push   $0x10
  8003d3:	68 0a 23 80 00       	push   $0x80230a
  8003d8:	6a 22                	push   $0x22
  8003da:	68 27 23 80 00       	push   $0x802327
  8003df:	e8 8b 11 00 00       	call   80156f <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e7:	5b                   	pop    %ebx
  8003e8:	5e                   	pop    %esi
  8003e9:	5f                   	pop    %edi
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f2:	05 00 00 00 30       	add    $0x30000000,%eax
  8003f7:	c1 e8 0c             	shr    $0xc,%eax
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800407:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80040c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800419:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80041e:	89 c2                	mov    %eax,%edx
  800420:	c1 ea 16             	shr    $0x16,%edx
  800423:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80042a:	f6 c2 01             	test   $0x1,%dl
  80042d:	74 11                	je     800440 <fd_alloc+0x2d>
  80042f:	89 c2                	mov    %eax,%edx
  800431:	c1 ea 0c             	shr    $0xc,%edx
  800434:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043b:	f6 c2 01             	test   $0x1,%dl
  80043e:	75 09                	jne    800449 <fd_alloc+0x36>
			*fd_store = fd;
  800440:	89 01                	mov    %eax,(%ecx)
			return 0;
  800442:	b8 00 00 00 00       	mov    $0x0,%eax
  800447:	eb 17                	jmp    800460 <fd_alloc+0x4d>
  800449:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80044e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800453:	75 c9                	jne    80041e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800455:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80045b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800468:	83 f8 1f             	cmp    $0x1f,%eax
  80046b:	77 36                	ja     8004a3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80046d:	c1 e0 0c             	shl    $0xc,%eax
  800470:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800475:	89 c2                	mov    %eax,%edx
  800477:	c1 ea 16             	shr    $0x16,%edx
  80047a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800481:	f6 c2 01             	test   $0x1,%dl
  800484:	74 24                	je     8004aa <fd_lookup+0x48>
  800486:	89 c2                	mov    %eax,%edx
  800488:	c1 ea 0c             	shr    $0xc,%edx
  80048b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800492:	f6 c2 01             	test   $0x1,%dl
  800495:	74 1a                	je     8004b1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800497:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049a:	89 02                	mov    %eax,(%edx)
	return 0;
  80049c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a1:	eb 13                	jmp    8004b6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a8:	eb 0c                	jmp    8004b6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004af:	eb 05                	jmp    8004b6 <fd_lookup+0x54>
  8004b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8004c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c6:	eb 13                	jmp    8004db <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8004c8:	39 08                	cmp    %ecx,(%eax)
  8004ca:	75 0c                	jne    8004d8 <dev_lookup+0x20>
			*dev = devtab[i];
  8004cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d6:	eb 36                	jmp    80050e <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004d8:	83 c2 01             	add    $0x1,%edx
  8004db:	8b 04 95 b4 23 80 00 	mov    0x8023b4(,%edx,4),%eax
  8004e2:	85 c0                	test   %eax,%eax
  8004e4:	75 e2                	jne    8004c8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004e6:	a1 08 40 80 00       	mov    0x804008,%eax
  8004eb:	8b 40 48             	mov    0x48(%eax),%eax
  8004ee:	83 ec 04             	sub    $0x4,%esp
  8004f1:	51                   	push   %ecx
  8004f2:	50                   	push   %eax
  8004f3:	68 38 23 80 00       	push   $0x802338
  8004f8:	e8 4b 11 00 00       	call   801648 <cprintf>
	*dev = 0;
  8004fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800500:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80050e:	c9                   	leave  
  80050f:	c3                   	ret    

00800510 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	56                   	push   %esi
  800514:	53                   	push   %ebx
  800515:	83 ec 10             	sub    $0x10,%esp
  800518:	8b 75 08             	mov    0x8(%ebp),%esi
  80051b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80051e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800521:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800522:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800528:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80052b:	50                   	push   %eax
  80052c:	e8 31 ff ff ff       	call   800462 <fd_lookup>
  800531:	83 c4 08             	add    $0x8,%esp
  800534:	85 c0                	test   %eax,%eax
  800536:	78 05                	js     80053d <fd_close+0x2d>
	    || fd != fd2)
  800538:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80053b:	74 0c                	je     800549 <fd_close+0x39>
		return (must_exist ? r : 0);
  80053d:	84 db                	test   %bl,%bl
  80053f:	ba 00 00 00 00       	mov    $0x0,%edx
  800544:	0f 44 c2             	cmove  %edx,%eax
  800547:	eb 41                	jmp    80058a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80054f:	50                   	push   %eax
  800550:	ff 36                	pushl  (%esi)
  800552:	e8 61 ff ff ff       	call   8004b8 <dev_lookup>
  800557:	89 c3                	mov    %eax,%ebx
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	85 c0                	test   %eax,%eax
  80055e:	78 1a                	js     80057a <fd_close+0x6a>
		if (dev->dev_close)
  800560:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800563:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800566:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80056b:	85 c0                	test   %eax,%eax
  80056d:	74 0b                	je     80057a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80056f:	83 ec 0c             	sub    $0xc,%esp
  800572:	56                   	push   %esi
  800573:	ff d0                	call   *%eax
  800575:	89 c3                	mov    %eax,%ebx
  800577:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	56                   	push   %esi
  80057e:	6a 00                	push   $0x0
  800580:	e8 5a fc ff ff       	call   8001df <sys_page_unmap>
	return r;
  800585:	83 c4 10             	add    $0x10,%esp
  800588:	89 d8                	mov    %ebx,%eax
}
  80058a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80058d:	5b                   	pop    %ebx
  80058e:	5e                   	pop    %esi
  80058f:	5d                   	pop    %ebp
  800590:	c3                   	ret    

00800591 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800597:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80059a:	50                   	push   %eax
  80059b:	ff 75 08             	pushl  0x8(%ebp)
  80059e:	e8 bf fe ff ff       	call   800462 <fd_lookup>
  8005a3:	89 c2                	mov    %eax,%edx
  8005a5:	83 c4 08             	add    $0x8,%esp
  8005a8:	85 d2                	test   %edx,%edx
  8005aa:	78 10                	js     8005bc <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	6a 01                	push   $0x1
  8005b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8005b4:	e8 57 ff ff ff       	call   800510 <fd_close>
  8005b9:	83 c4 10             	add    $0x10,%esp
}
  8005bc:	c9                   	leave  
  8005bd:	c3                   	ret    

008005be <close_all>:

void
close_all(void)
{
  8005be:	55                   	push   %ebp
  8005bf:	89 e5                	mov    %esp,%ebp
  8005c1:	53                   	push   %ebx
  8005c2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005c5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005ca:	83 ec 0c             	sub    $0xc,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	e8 be ff ff ff       	call   800591 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005d3:	83 c3 01             	add    $0x1,%ebx
  8005d6:	83 c4 10             	add    $0x10,%esp
  8005d9:	83 fb 20             	cmp    $0x20,%ebx
  8005dc:	75 ec                	jne    8005ca <close_all+0xc>
		close(i);
}
  8005de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005e1:	c9                   	leave  
  8005e2:	c3                   	ret    

008005e3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005e3:	55                   	push   %ebp
  8005e4:	89 e5                	mov    %esp,%ebp
  8005e6:	57                   	push   %edi
  8005e7:	56                   	push   %esi
  8005e8:	53                   	push   %ebx
  8005e9:	83 ec 2c             	sub    $0x2c,%esp
  8005ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005f2:	50                   	push   %eax
  8005f3:	ff 75 08             	pushl  0x8(%ebp)
  8005f6:	e8 67 fe ff ff       	call   800462 <fd_lookup>
  8005fb:	89 c2                	mov    %eax,%edx
  8005fd:	83 c4 08             	add    $0x8,%esp
  800600:	85 d2                	test   %edx,%edx
  800602:	0f 88 c1 00 00 00    	js     8006c9 <dup+0xe6>
		return r;
	close(newfdnum);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 80 ff ff ff       	call   800591 <close>

	newfd = INDEX2FD(newfdnum);
  800611:	89 f3                	mov    %esi,%ebx
  800613:	c1 e3 0c             	shl    $0xc,%ebx
  800616:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80061c:	83 c4 04             	add    $0x4,%esp
  80061f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800622:	e8 d5 fd ff ff       	call   8003fc <fd2data>
  800627:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800629:	89 1c 24             	mov    %ebx,(%esp)
  80062c:	e8 cb fd ff ff       	call   8003fc <fd2data>
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800637:	89 f8                	mov    %edi,%eax
  800639:	c1 e8 16             	shr    $0x16,%eax
  80063c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800643:	a8 01                	test   $0x1,%al
  800645:	74 37                	je     80067e <dup+0x9b>
  800647:	89 f8                	mov    %edi,%eax
  800649:	c1 e8 0c             	shr    $0xc,%eax
  80064c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800653:	f6 c2 01             	test   $0x1,%dl
  800656:	74 26                	je     80067e <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800658:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80065f:	83 ec 0c             	sub    $0xc,%esp
  800662:	25 07 0e 00 00       	and    $0xe07,%eax
  800667:	50                   	push   %eax
  800668:	ff 75 d4             	pushl  -0x2c(%ebp)
  80066b:	6a 00                	push   $0x0
  80066d:	57                   	push   %edi
  80066e:	6a 00                	push   $0x0
  800670:	e8 28 fb ff ff       	call   80019d <sys_page_map>
  800675:	89 c7                	mov    %eax,%edi
  800677:	83 c4 20             	add    $0x20,%esp
  80067a:	85 c0                	test   %eax,%eax
  80067c:	78 2e                	js     8006ac <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80067e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800681:	89 d0                	mov    %edx,%eax
  800683:	c1 e8 0c             	shr    $0xc,%eax
  800686:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80068d:	83 ec 0c             	sub    $0xc,%esp
  800690:	25 07 0e 00 00       	and    $0xe07,%eax
  800695:	50                   	push   %eax
  800696:	53                   	push   %ebx
  800697:	6a 00                	push   $0x0
  800699:	52                   	push   %edx
  80069a:	6a 00                	push   $0x0
  80069c:	e8 fc fa ff ff       	call   80019d <sys_page_map>
  8006a1:	89 c7                	mov    %eax,%edi
  8006a3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006a6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006a8:	85 ff                	test   %edi,%edi
  8006aa:	79 1d                	jns    8006c9 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 00                	push   $0x0
  8006b2:	e8 28 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006b7:	83 c4 08             	add    $0x8,%esp
  8006ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006bd:	6a 00                	push   $0x0
  8006bf:	e8 1b fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	89 f8                	mov    %edi,%eax
}
  8006c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cc:	5b                   	pop    %ebx
  8006cd:	5e                   	pop    %esi
  8006ce:	5f                   	pop    %edi
  8006cf:	5d                   	pop    %ebp
  8006d0:	c3                   	ret    

008006d1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	53                   	push   %ebx
  8006d5:	83 ec 14             	sub    $0x14,%esp
  8006d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006de:	50                   	push   %eax
  8006df:	53                   	push   %ebx
  8006e0:	e8 7d fd ff ff       	call   800462 <fd_lookup>
  8006e5:	83 c4 08             	add    $0x8,%esp
  8006e8:	89 c2                	mov    %eax,%edx
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	78 6d                	js     80075b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006f4:	50                   	push   %eax
  8006f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006f8:	ff 30                	pushl  (%eax)
  8006fa:	e8 b9 fd ff ff       	call   8004b8 <dev_lookup>
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	85 c0                	test   %eax,%eax
  800704:	78 4c                	js     800752 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800706:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800709:	8b 42 08             	mov    0x8(%edx),%eax
  80070c:	83 e0 03             	and    $0x3,%eax
  80070f:	83 f8 01             	cmp    $0x1,%eax
  800712:	75 21                	jne    800735 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800714:	a1 08 40 80 00       	mov    0x804008,%eax
  800719:	8b 40 48             	mov    0x48(%eax),%eax
  80071c:	83 ec 04             	sub    $0x4,%esp
  80071f:	53                   	push   %ebx
  800720:	50                   	push   %eax
  800721:	68 79 23 80 00       	push   $0x802379
  800726:	e8 1d 0f 00 00       	call   801648 <cprintf>
		return -E_INVAL;
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800733:	eb 26                	jmp    80075b <read+0x8a>
	}
	if (!dev->dev_read)
  800735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800738:	8b 40 08             	mov    0x8(%eax),%eax
  80073b:	85 c0                	test   %eax,%eax
  80073d:	74 17                	je     800756 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80073f:	83 ec 04             	sub    $0x4,%esp
  800742:	ff 75 10             	pushl  0x10(%ebp)
  800745:	ff 75 0c             	pushl  0xc(%ebp)
  800748:	52                   	push   %edx
  800749:	ff d0                	call   *%eax
  80074b:	89 c2                	mov    %eax,%edx
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	eb 09                	jmp    80075b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800752:	89 c2                	mov    %eax,%edx
  800754:	eb 05                	jmp    80075b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800756:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80075b:	89 d0                	mov    %edx,%eax
  80075d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800760:	c9                   	leave  
  800761:	c3                   	ret    

00800762 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	57                   	push   %edi
  800766:	56                   	push   %esi
  800767:	53                   	push   %ebx
  800768:	83 ec 0c             	sub    $0xc,%esp
  80076b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80076e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800771:	bb 00 00 00 00       	mov    $0x0,%ebx
  800776:	eb 21                	jmp    800799 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800778:	83 ec 04             	sub    $0x4,%esp
  80077b:	89 f0                	mov    %esi,%eax
  80077d:	29 d8                	sub    %ebx,%eax
  80077f:	50                   	push   %eax
  800780:	89 d8                	mov    %ebx,%eax
  800782:	03 45 0c             	add    0xc(%ebp),%eax
  800785:	50                   	push   %eax
  800786:	57                   	push   %edi
  800787:	e8 45 ff ff ff       	call   8006d1 <read>
		if (m < 0)
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	85 c0                	test   %eax,%eax
  800791:	78 0c                	js     80079f <readn+0x3d>
			return m;
		if (m == 0)
  800793:	85 c0                	test   %eax,%eax
  800795:	74 06                	je     80079d <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800797:	01 c3                	add    %eax,%ebx
  800799:	39 f3                	cmp    %esi,%ebx
  80079b:	72 db                	jb     800778 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80079d:	89 d8                	mov    %ebx,%eax
}
  80079f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007a2:	5b                   	pop    %ebx
  8007a3:	5e                   	pop    %esi
  8007a4:	5f                   	pop    %edi
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	83 ec 14             	sub    $0x14,%esp
  8007ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b4:	50                   	push   %eax
  8007b5:	53                   	push   %ebx
  8007b6:	e8 a7 fc ff ff       	call   800462 <fd_lookup>
  8007bb:	83 c4 08             	add    $0x8,%esp
  8007be:	89 c2                	mov    %eax,%edx
  8007c0:	85 c0                	test   %eax,%eax
  8007c2:	78 68                	js     80082c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007ca:	50                   	push   %eax
  8007cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ce:	ff 30                	pushl  (%eax)
  8007d0:	e8 e3 fc ff ff       	call   8004b8 <dev_lookup>
  8007d5:	83 c4 10             	add    $0x10,%esp
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	78 47                	js     800823 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007df:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e3:	75 21                	jne    800806 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007e5:	a1 08 40 80 00       	mov    0x804008,%eax
  8007ea:	8b 40 48             	mov    0x48(%eax),%eax
  8007ed:	83 ec 04             	sub    $0x4,%esp
  8007f0:	53                   	push   %ebx
  8007f1:	50                   	push   %eax
  8007f2:	68 95 23 80 00       	push   $0x802395
  8007f7:	e8 4c 0e 00 00       	call   801648 <cprintf>
		return -E_INVAL;
  8007fc:	83 c4 10             	add    $0x10,%esp
  8007ff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800804:	eb 26                	jmp    80082c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800806:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800809:	8b 52 0c             	mov    0xc(%edx),%edx
  80080c:	85 d2                	test   %edx,%edx
  80080e:	74 17                	je     800827 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800810:	83 ec 04             	sub    $0x4,%esp
  800813:	ff 75 10             	pushl  0x10(%ebp)
  800816:	ff 75 0c             	pushl  0xc(%ebp)
  800819:	50                   	push   %eax
  80081a:	ff d2                	call   *%edx
  80081c:	89 c2                	mov    %eax,%edx
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	eb 09                	jmp    80082c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800823:	89 c2                	mov    %eax,%edx
  800825:	eb 05                	jmp    80082c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800827:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80082c:	89 d0                	mov    %edx,%eax
  80082e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <seek>:

int
seek(int fdnum, off_t offset)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800839:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80083c:	50                   	push   %eax
  80083d:	ff 75 08             	pushl  0x8(%ebp)
  800840:	e8 1d fc ff ff       	call   800462 <fd_lookup>
  800845:	83 c4 08             	add    $0x8,%esp
  800848:	85 c0                	test   %eax,%eax
  80084a:	78 0e                	js     80085a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80084c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800852:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085a:	c9                   	leave  
  80085b:	c3                   	ret    

0080085c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	53                   	push   %ebx
  800860:	83 ec 14             	sub    $0x14,%esp
  800863:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800866:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800869:	50                   	push   %eax
  80086a:	53                   	push   %ebx
  80086b:	e8 f2 fb ff ff       	call   800462 <fd_lookup>
  800870:	83 c4 08             	add    $0x8,%esp
  800873:	89 c2                	mov    %eax,%edx
  800875:	85 c0                	test   %eax,%eax
  800877:	78 65                	js     8008de <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800879:	83 ec 08             	sub    $0x8,%esp
  80087c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087f:	50                   	push   %eax
  800880:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800883:	ff 30                	pushl  (%eax)
  800885:	e8 2e fc ff ff       	call   8004b8 <dev_lookup>
  80088a:	83 c4 10             	add    $0x10,%esp
  80088d:	85 c0                	test   %eax,%eax
  80088f:	78 44                	js     8008d5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800891:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800894:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800898:	75 21                	jne    8008bb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80089a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80089f:	8b 40 48             	mov    0x48(%eax),%eax
  8008a2:	83 ec 04             	sub    $0x4,%esp
  8008a5:	53                   	push   %ebx
  8008a6:	50                   	push   %eax
  8008a7:	68 58 23 80 00       	push   $0x802358
  8008ac:	e8 97 0d 00 00       	call   801648 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008b9:	eb 23                	jmp    8008de <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008be:	8b 52 18             	mov    0x18(%edx),%edx
  8008c1:	85 d2                	test   %edx,%edx
  8008c3:	74 14                	je     8008d9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008c5:	83 ec 08             	sub    $0x8,%esp
  8008c8:	ff 75 0c             	pushl  0xc(%ebp)
  8008cb:	50                   	push   %eax
  8008cc:	ff d2                	call   *%edx
  8008ce:	89 c2                	mov    %eax,%edx
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	eb 09                	jmp    8008de <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d5:	89 c2                	mov    %eax,%edx
  8008d7:	eb 05                	jmp    8008de <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008de:	89 d0                	mov    %edx,%eax
  8008e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	53                   	push   %ebx
  8008e9:	83 ec 14             	sub    $0x14,%esp
  8008ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008f2:	50                   	push   %eax
  8008f3:	ff 75 08             	pushl  0x8(%ebp)
  8008f6:	e8 67 fb ff ff       	call   800462 <fd_lookup>
  8008fb:	83 c4 08             	add    $0x8,%esp
  8008fe:	89 c2                	mov    %eax,%edx
  800900:	85 c0                	test   %eax,%eax
  800902:	78 58                	js     80095c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800904:	83 ec 08             	sub    $0x8,%esp
  800907:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80090a:	50                   	push   %eax
  80090b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80090e:	ff 30                	pushl  (%eax)
  800910:	e8 a3 fb ff ff       	call   8004b8 <dev_lookup>
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	85 c0                	test   %eax,%eax
  80091a:	78 37                	js     800953 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80091c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80091f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800923:	74 32                	je     800957 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800925:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800928:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80092f:	00 00 00 
	stat->st_isdir = 0;
  800932:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800939:	00 00 00 
	stat->st_dev = dev;
  80093c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800942:	83 ec 08             	sub    $0x8,%esp
  800945:	53                   	push   %ebx
  800946:	ff 75 f0             	pushl  -0x10(%ebp)
  800949:	ff 50 14             	call   *0x14(%eax)
  80094c:	89 c2                	mov    %eax,%edx
  80094e:	83 c4 10             	add    $0x10,%esp
  800951:	eb 09                	jmp    80095c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800953:	89 c2                	mov    %eax,%edx
  800955:	eb 05                	jmp    80095c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800957:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80095c:	89 d0                	mov    %edx,%eax
  80095e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800968:	83 ec 08             	sub    $0x8,%esp
  80096b:	6a 00                	push   $0x0
  80096d:	ff 75 08             	pushl  0x8(%ebp)
  800970:	e8 09 02 00 00       	call   800b7e <open>
  800975:	89 c3                	mov    %eax,%ebx
  800977:	83 c4 10             	add    $0x10,%esp
  80097a:	85 db                	test   %ebx,%ebx
  80097c:	78 1b                	js     800999 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80097e:	83 ec 08             	sub    $0x8,%esp
  800981:	ff 75 0c             	pushl  0xc(%ebp)
  800984:	53                   	push   %ebx
  800985:	e8 5b ff ff ff       	call   8008e5 <fstat>
  80098a:	89 c6                	mov    %eax,%esi
	close(fd);
  80098c:	89 1c 24             	mov    %ebx,(%esp)
  80098f:	e8 fd fb ff ff       	call   800591 <close>
	return r;
  800994:	83 c4 10             	add    $0x10,%esp
  800997:	89 f0                	mov    %esi,%eax
}
  800999:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	89 c6                	mov    %eax,%esi
  8009a7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009a9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009b0:	75 12                	jne    8009c4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009b2:	83 ec 0c             	sub    $0xc,%esp
  8009b5:	6a 01                	push   $0x1
  8009b7:	e8 1d 16 00 00       	call   801fd9 <ipc_find_env>
  8009bc:	a3 00 40 80 00       	mov    %eax,0x804000
  8009c1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009c4:	6a 07                	push   $0x7
  8009c6:	68 00 50 80 00       	push   $0x805000
  8009cb:	56                   	push   %esi
  8009cc:	ff 35 00 40 80 00    	pushl  0x804000
  8009d2:	e8 ae 15 00 00       	call   801f85 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009d7:	83 c4 0c             	add    $0xc,%esp
  8009da:	6a 00                	push   $0x0
  8009dc:	53                   	push   %ebx
  8009dd:	6a 00                	push   $0x0
  8009df:	e8 38 15 00 00       	call   801f1c <ipc_recv>
}
  8009e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009e7:	5b                   	pop    %ebx
  8009e8:	5e                   	pop    %esi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ff:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a04:	ba 00 00 00 00       	mov    $0x0,%edx
  800a09:	b8 02 00 00 00       	mov    $0x2,%eax
  800a0e:	e8 8d ff ff ff       	call   8009a0 <fsipc>
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a21:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a26:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2b:	b8 06 00 00 00       	mov    $0x6,%eax
  800a30:	e8 6b ff ff ff       	call   8009a0 <fsipc>
}
  800a35:	c9                   	leave  
  800a36:	c3                   	ret    

00800a37 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	53                   	push   %ebx
  800a3b:	83 ec 04             	sub    $0x4,%esp
  800a3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8b 40 0c             	mov    0xc(%eax),%eax
  800a47:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a51:	b8 05 00 00 00       	mov    $0x5,%eax
  800a56:	e8 45 ff ff ff       	call   8009a0 <fsipc>
  800a5b:	89 c2                	mov    %eax,%edx
  800a5d:	85 d2                	test   %edx,%edx
  800a5f:	78 2c                	js     800a8d <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a61:	83 ec 08             	sub    $0x8,%esp
  800a64:	68 00 50 80 00       	push   $0x805000
  800a69:	53                   	push   %ebx
  800a6a:	e8 60 11 00 00       	call   801bcf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a6f:	a1 80 50 80 00       	mov    0x805080,%eax
  800a74:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a7a:	a1 84 50 80 00       	mov    0x805084,%eax
  800a7f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a85:	83 c4 10             	add    $0x10,%esp
  800a88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a90:	c9                   	leave  
  800a91:	c3                   	ret    

00800a92 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	83 ec 0c             	sub    $0xc,%esp
  800a9b:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	8b 40 0c             	mov    0xc(%eax),%eax
  800aa4:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800aa9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800aac:	eb 3d                	jmp    800aeb <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800aae:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800ab4:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800ab9:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800abc:	83 ec 04             	sub    $0x4,%esp
  800abf:	57                   	push   %edi
  800ac0:	53                   	push   %ebx
  800ac1:	68 08 50 80 00       	push   $0x805008
  800ac6:	e8 96 12 00 00       	call   801d61 <memmove>
                fsipcbuf.write.req_n = tmp; 
  800acb:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800ad1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad6:	b8 04 00 00 00       	mov    $0x4,%eax
  800adb:	e8 c0 fe ff ff       	call   8009a0 <fsipc>
  800ae0:	83 c4 10             	add    $0x10,%esp
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	78 0d                	js     800af4 <devfile_write+0x62>
		        return r;
                n -= tmp;
  800ae7:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800ae9:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800aeb:	85 f6                	test   %esi,%esi
  800aed:	75 bf                	jne    800aae <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800aef:	89 d8                	mov    %ebx,%eax
  800af1:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800af4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	8b 40 0c             	mov    0xc(%eax),%eax
  800b0a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b0f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b15:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1f:	e8 7c fe ff ff       	call   8009a0 <fsipc>
  800b24:	89 c3                	mov    %eax,%ebx
  800b26:	85 c0                	test   %eax,%eax
  800b28:	78 4b                	js     800b75 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b2a:	39 c6                	cmp    %eax,%esi
  800b2c:	73 16                	jae    800b44 <devfile_read+0x48>
  800b2e:	68 c8 23 80 00       	push   $0x8023c8
  800b33:	68 cf 23 80 00       	push   $0x8023cf
  800b38:	6a 7c                	push   $0x7c
  800b3a:	68 e4 23 80 00       	push   $0x8023e4
  800b3f:	e8 2b 0a 00 00       	call   80156f <_panic>
	assert(r <= PGSIZE);
  800b44:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b49:	7e 16                	jle    800b61 <devfile_read+0x65>
  800b4b:	68 ef 23 80 00       	push   $0x8023ef
  800b50:	68 cf 23 80 00       	push   $0x8023cf
  800b55:	6a 7d                	push   $0x7d
  800b57:	68 e4 23 80 00       	push   $0x8023e4
  800b5c:	e8 0e 0a 00 00       	call   80156f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b61:	83 ec 04             	sub    $0x4,%esp
  800b64:	50                   	push   %eax
  800b65:	68 00 50 80 00       	push   $0x805000
  800b6a:	ff 75 0c             	pushl  0xc(%ebp)
  800b6d:	e8 ef 11 00 00       	call   801d61 <memmove>
	return r;
  800b72:	83 c4 10             	add    $0x10,%esp
}
  800b75:	89 d8                	mov    %ebx,%eax
  800b77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	53                   	push   %ebx
  800b82:	83 ec 20             	sub    $0x20,%esp
  800b85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b88:	53                   	push   %ebx
  800b89:	e8 08 10 00 00       	call   801b96 <strlen>
  800b8e:	83 c4 10             	add    $0x10,%esp
  800b91:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b96:	7f 67                	jg     800bff <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b9e:	50                   	push   %eax
  800b9f:	e8 6f f8 ff ff       	call   800413 <fd_alloc>
  800ba4:	83 c4 10             	add    $0x10,%esp
		return r;
  800ba7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ba9:	85 c0                	test   %eax,%eax
  800bab:	78 57                	js     800c04 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bad:	83 ec 08             	sub    $0x8,%esp
  800bb0:	53                   	push   %ebx
  800bb1:	68 00 50 80 00       	push   $0x805000
  800bb6:	e8 14 10 00 00       	call   801bcf <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbe:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bcb:	e8 d0 fd ff ff       	call   8009a0 <fsipc>
  800bd0:	89 c3                	mov    %eax,%ebx
  800bd2:	83 c4 10             	add    $0x10,%esp
  800bd5:	85 c0                	test   %eax,%eax
  800bd7:	79 14                	jns    800bed <open+0x6f>
		fd_close(fd, 0);
  800bd9:	83 ec 08             	sub    $0x8,%esp
  800bdc:	6a 00                	push   $0x0
  800bde:	ff 75 f4             	pushl  -0xc(%ebp)
  800be1:	e8 2a f9 ff ff       	call   800510 <fd_close>
		return r;
  800be6:	83 c4 10             	add    $0x10,%esp
  800be9:	89 da                	mov    %ebx,%edx
  800beb:	eb 17                	jmp    800c04 <open+0x86>
	}

	return fd2num(fd);
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	ff 75 f4             	pushl  -0xc(%ebp)
  800bf3:	e8 f4 f7 ff ff       	call   8003ec <fd2num>
  800bf8:	89 c2                	mov    %eax,%edx
  800bfa:	83 c4 10             	add    $0x10,%esp
  800bfd:	eb 05                	jmp    800c04 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bff:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c04:	89 d0                	mov    %edx,%eax
  800c06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c09:	c9                   	leave  
  800c0a:	c3                   	ret    

00800c0b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c11:	ba 00 00 00 00       	mov    $0x0,%edx
  800c16:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1b:	e8 80 fd ff ff       	call   8009a0 <fsipc>
}
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c28:	68 fb 23 80 00       	push   $0x8023fb
  800c2d:	ff 75 0c             	pushl  0xc(%ebp)
  800c30:	e8 9a 0f 00 00       	call   801bcf <strcpy>
	return 0;
}
  800c35:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    

00800c3c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 10             	sub    $0x10,%esp
  800c43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c46:	53                   	push   %ebx
  800c47:	e8 c5 13 00 00       	call   802011 <pageref>
  800c4c:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c4f:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c54:	83 f8 01             	cmp    $0x1,%eax
  800c57:	75 10                	jne    800c69 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c59:	83 ec 0c             	sub    $0xc,%esp
  800c5c:	ff 73 0c             	pushl  0xc(%ebx)
  800c5f:	e8 ca 02 00 00       	call   800f2e <nsipc_close>
  800c64:	89 c2                	mov    %eax,%edx
  800c66:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c69:	89 d0                	mov    %edx,%eax
  800c6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c6e:	c9                   	leave  
  800c6f:	c3                   	ret    

00800c70 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c76:	6a 00                	push   $0x0
  800c78:	ff 75 10             	pushl  0x10(%ebp)
  800c7b:	ff 75 0c             	pushl  0xc(%ebp)
  800c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c81:	ff 70 0c             	pushl  0xc(%eax)
  800c84:	e8 82 03 00 00       	call   80100b <nsipc_send>
}
  800c89:	c9                   	leave  
  800c8a:	c3                   	ret    

00800c8b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c91:	6a 00                	push   $0x0
  800c93:	ff 75 10             	pushl  0x10(%ebp)
  800c96:	ff 75 0c             	pushl  0xc(%ebp)
  800c99:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9c:	ff 70 0c             	pushl  0xc(%eax)
  800c9f:	e8 fb 02 00 00       	call   800f9f <nsipc_recv>
}
  800ca4:	c9                   	leave  
  800ca5:	c3                   	ret    

00800ca6 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800cac:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800caf:	52                   	push   %edx
  800cb0:	50                   	push   %eax
  800cb1:	e8 ac f7 ff ff       	call   800462 <fd_lookup>
  800cb6:	83 c4 10             	add    $0x10,%esp
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	78 17                	js     800cd4 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc0:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800cc6:	39 08                	cmp    %ecx,(%eax)
  800cc8:	75 05                	jne    800ccf <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800cca:	8b 40 0c             	mov    0xc(%eax),%eax
  800ccd:	eb 05                	jmp    800cd4 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800ccf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800cd4:	c9                   	leave  
  800cd5:	c3                   	ret    

00800cd6 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 1c             	sub    $0x1c,%esp
  800cde:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800ce0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ce3:	50                   	push   %eax
  800ce4:	e8 2a f7 ff ff       	call   800413 <fd_alloc>
  800ce9:	89 c3                	mov    %eax,%ebx
  800ceb:	83 c4 10             	add    $0x10,%esp
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	78 1b                	js     800d0d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cf2:	83 ec 04             	sub    $0x4,%esp
  800cf5:	68 07 04 00 00       	push   $0x407
  800cfa:	ff 75 f4             	pushl  -0xc(%ebp)
  800cfd:	6a 00                	push   $0x0
  800cff:	e8 56 f4 ff ff       	call   80015a <sys_page_alloc>
  800d04:	89 c3                	mov    %eax,%ebx
  800d06:	83 c4 10             	add    $0x10,%esp
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	79 10                	jns    800d1d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d0d:	83 ec 0c             	sub    $0xc,%esp
  800d10:	56                   	push   %esi
  800d11:	e8 18 02 00 00       	call   800f2e <nsipc_close>
		return r;
  800d16:	83 c4 10             	add    $0x10,%esp
  800d19:	89 d8                	mov    %ebx,%eax
  800d1b:	eb 24                	jmp    800d41 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d1d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d26:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d2b:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  800d32:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	52                   	push   %edx
  800d39:	e8 ae f6 ff ff       	call   8003ec <fd2num>
  800d3e:	83 c4 10             	add    $0x10,%esp
}
  800d41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	e8 50 ff ff ff       	call   800ca6 <fd2sockid>
		return r;
  800d56:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	78 1f                	js     800d7b <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d5c:	83 ec 04             	sub    $0x4,%esp
  800d5f:	ff 75 10             	pushl  0x10(%ebp)
  800d62:	ff 75 0c             	pushl  0xc(%ebp)
  800d65:	50                   	push   %eax
  800d66:	e8 1c 01 00 00       	call   800e87 <nsipc_accept>
  800d6b:	83 c4 10             	add    $0x10,%esp
		return r;
  800d6e:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d70:	85 c0                	test   %eax,%eax
  800d72:	78 07                	js     800d7b <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d74:	e8 5d ff ff ff       	call   800cd6 <alloc_sockfd>
  800d79:	89 c1                	mov    %eax,%ecx
}
  800d7b:	89 c8                	mov    %ecx,%eax
  800d7d:	c9                   	leave  
  800d7e:	c3                   	ret    

00800d7f <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d85:	8b 45 08             	mov    0x8(%ebp),%eax
  800d88:	e8 19 ff ff ff       	call   800ca6 <fd2sockid>
  800d8d:	89 c2                	mov    %eax,%edx
  800d8f:	85 d2                	test   %edx,%edx
  800d91:	78 12                	js     800da5 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  800d93:	83 ec 04             	sub    $0x4,%esp
  800d96:	ff 75 10             	pushl  0x10(%ebp)
  800d99:	ff 75 0c             	pushl  0xc(%ebp)
  800d9c:	52                   	push   %edx
  800d9d:	e8 35 01 00 00       	call   800ed7 <nsipc_bind>
  800da2:	83 c4 10             	add    $0x10,%esp
}
  800da5:	c9                   	leave  
  800da6:	c3                   	ret    

00800da7 <shutdown>:

int
shutdown(int s, int how)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dad:	8b 45 08             	mov    0x8(%ebp),%eax
  800db0:	e8 f1 fe ff ff       	call   800ca6 <fd2sockid>
  800db5:	89 c2                	mov    %eax,%edx
  800db7:	85 d2                	test   %edx,%edx
  800db9:	78 0f                	js     800dca <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  800dbb:	83 ec 08             	sub    $0x8,%esp
  800dbe:	ff 75 0c             	pushl  0xc(%ebp)
  800dc1:	52                   	push   %edx
  800dc2:	e8 45 01 00 00       	call   800f0c <nsipc_shutdown>
  800dc7:	83 c4 10             	add    $0x10,%esp
}
  800dca:	c9                   	leave  
  800dcb:	c3                   	ret    

00800dcc <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	e8 cc fe ff ff       	call   800ca6 <fd2sockid>
  800dda:	89 c2                	mov    %eax,%edx
  800ddc:	85 d2                	test   %edx,%edx
  800dde:	78 12                	js     800df2 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  800de0:	83 ec 04             	sub    $0x4,%esp
  800de3:	ff 75 10             	pushl  0x10(%ebp)
  800de6:	ff 75 0c             	pushl  0xc(%ebp)
  800de9:	52                   	push   %edx
  800dea:	e8 59 01 00 00       	call   800f48 <nsipc_connect>
  800def:	83 c4 10             	add    $0x10,%esp
}
  800df2:	c9                   	leave  
  800df3:	c3                   	ret    

00800df4 <listen>:

int
listen(int s, int backlog)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfd:	e8 a4 fe ff ff       	call   800ca6 <fd2sockid>
  800e02:	89 c2                	mov    %eax,%edx
  800e04:	85 d2                	test   %edx,%edx
  800e06:	78 0f                	js     800e17 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  800e08:	83 ec 08             	sub    $0x8,%esp
  800e0b:	ff 75 0c             	pushl  0xc(%ebp)
  800e0e:	52                   	push   %edx
  800e0f:	e8 69 01 00 00       	call   800f7d <nsipc_listen>
  800e14:	83 c4 10             	add    $0x10,%esp
}
  800e17:	c9                   	leave  
  800e18:	c3                   	ret    

00800e19 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e1f:	ff 75 10             	pushl  0x10(%ebp)
  800e22:	ff 75 0c             	pushl  0xc(%ebp)
  800e25:	ff 75 08             	pushl  0x8(%ebp)
  800e28:	e8 3c 02 00 00       	call   801069 <nsipc_socket>
  800e2d:	89 c2                	mov    %eax,%edx
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	85 d2                	test   %edx,%edx
  800e34:	78 05                	js     800e3b <socket+0x22>
		return r;
	return alloc_sockfd(r);
  800e36:	e8 9b fe ff ff       	call   800cd6 <alloc_sockfd>
}
  800e3b:	c9                   	leave  
  800e3c:	c3                   	ret    

00800e3d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	53                   	push   %ebx
  800e41:	83 ec 04             	sub    $0x4,%esp
  800e44:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e46:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e4d:	75 12                	jne    800e61 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e4f:	83 ec 0c             	sub    $0xc,%esp
  800e52:	6a 02                	push   $0x2
  800e54:	e8 80 11 00 00       	call   801fd9 <ipc_find_env>
  800e59:	a3 04 40 80 00       	mov    %eax,0x804004
  800e5e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e61:	6a 07                	push   $0x7
  800e63:	68 00 60 80 00       	push   $0x806000
  800e68:	53                   	push   %ebx
  800e69:	ff 35 04 40 80 00    	pushl  0x804004
  800e6f:	e8 11 11 00 00       	call   801f85 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e74:	83 c4 0c             	add    $0xc,%esp
  800e77:	6a 00                	push   $0x0
  800e79:	6a 00                	push   $0x0
  800e7b:	6a 00                	push   $0x0
  800e7d:	e8 9a 10 00 00       	call   801f1c <ipc_recv>
}
  800e82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e85:	c9                   	leave  
  800e86:	c3                   	ret    

00800e87 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e92:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e97:	8b 06                	mov    (%esi),%eax
  800e99:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea3:	e8 95 ff ff ff       	call   800e3d <nsipc>
  800ea8:	89 c3                	mov    %eax,%ebx
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	78 20                	js     800ece <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800eae:	83 ec 04             	sub    $0x4,%esp
  800eb1:	ff 35 10 60 80 00    	pushl  0x806010
  800eb7:	68 00 60 80 00       	push   $0x806000
  800ebc:	ff 75 0c             	pushl  0xc(%ebp)
  800ebf:	e8 9d 0e 00 00       	call   801d61 <memmove>
		*addrlen = ret->ret_addrlen;
  800ec4:	a1 10 60 80 00       	mov    0x806010,%eax
  800ec9:	89 06                	mov    %eax,(%esi)
  800ecb:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800ece:	89 d8                	mov    %ebx,%eax
  800ed0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	53                   	push   %ebx
  800edb:	83 ec 08             	sub    $0x8,%esp
  800ede:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ee9:	53                   	push   %ebx
  800eea:	ff 75 0c             	pushl  0xc(%ebp)
  800eed:	68 04 60 80 00       	push   $0x806004
  800ef2:	e8 6a 0e 00 00       	call   801d61 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800ef7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800efd:	b8 02 00 00 00       	mov    $0x2,%eax
  800f02:	e8 36 ff ff ff       	call   800e3d <nsipc>
}
  800f07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f0a:	c9                   	leave  
  800f0b:	c3                   	ret    

00800f0c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f12:	8b 45 08             	mov    0x8(%ebp),%eax
  800f15:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f22:	b8 03 00 00 00       	mov    $0x3,%eax
  800f27:	e8 11 ff ff ff       	call   800e3d <nsipc>
}
  800f2c:	c9                   	leave  
  800f2d:	c3                   	ret    

00800f2e <nsipc_close>:

int
nsipc_close(int s)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f34:	8b 45 08             	mov    0x8(%ebp),%eax
  800f37:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f3c:	b8 04 00 00 00       	mov    $0x4,%eax
  800f41:	e8 f7 fe ff ff       	call   800e3d <nsipc>
}
  800f46:	c9                   	leave  
  800f47:	c3                   	ret    

00800f48 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	53                   	push   %ebx
  800f4c:	83 ec 08             	sub    $0x8,%esp
  800f4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f52:	8b 45 08             	mov    0x8(%ebp),%eax
  800f55:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f5a:	53                   	push   %ebx
  800f5b:	ff 75 0c             	pushl  0xc(%ebp)
  800f5e:	68 04 60 80 00       	push   $0x806004
  800f63:	e8 f9 0d 00 00       	call   801d61 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f68:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800f73:	e8 c5 fe ff ff       	call   800e3d <nsipc>
}
  800f78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7b:	c9                   	leave  
  800f7c:	c3                   	ret    

00800f7d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f83:	8b 45 08             	mov    0x8(%ebp),%eax
  800f86:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f93:	b8 06 00 00 00       	mov    $0x6,%eax
  800f98:	e8 a0 fe ff ff       	call   800e3d <nsipc>
}
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
  800fa4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800faa:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800faf:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800fb5:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb8:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800fbd:	b8 07 00 00 00       	mov    $0x7,%eax
  800fc2:	e8 76 fe ff ff       	call   800e3d <nsipc>
  800fc7:	89 c3                	mov    %eax,%ebx
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	78 35                	js     801002 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800fcd:	39 f0                	cmp    %esi,%eax
  800fcf:	7f 07                	jg     800fd8 <nsipc_recv+0x39>
  800fd1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800fd6:	7e 16                	jle    800fee <nsipc_recv+0x4f>
  800fd8:	68 07 24 80 00       	push   $0x802407
  800fdd:	68 cf 23 80 00       	push   $0x8023cf
  800fe2:	6a 62                	push   $0x62
  800fe4:	68 1c 24 80 00       	push   $0x80241c
  800fe9:	e8 81 05 00 00       	call   80156f <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	50                   	push   %eax
  800ff2:	68 00 60 80 00       	push   $0x806000
  800ff7:	ff 75 0c             	pushl  0xc(%ebp)
  800ffa:	e8 62 0d 00 00       	call   801d61 <memmove>
  800fff:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801002:	89 d8                	mov    %ebx,%eax
  801004:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	53                   	push   %ebx
  80100f:	83 ec 04             	sub    $0x4,%esp
  801012:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801015:	8b 45 08             	mov    0x8(%ebp),%eax
  801018:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80101d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801023:	7e 16                	jle    80103b <nsipc_send+0x30>
  801025:	68 28 24 80 00       	push   $0x802428
  80102a:	68 cf 23 80 00       	push   $0x8023cf
  80102f:	6a 6d                	push   $0x6d
  801031:	68 1c 24 80 00       	push   $0x80241c
  801036:	e8 34 05 00 00       	call   80156f <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80103b:	83 ec 04             	sub    $0x4,%esp
  80103e:	53                   	push   %ebx
  80103f:	ff 75 0c             	pushl  0xc(%ebp)
  801042:	68 0c 60 80 00       	push   $0x80600c
  801047:	e8 15 0d 00 00       	call   801d61 <memmove>
	nsipcbuf.send.req_size = size;
  80104c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801052:	8b 45 14             	mov    0x14(%ebp),%eax
  801055:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80105a:	b8 08 00 00 00       	mov    $0x8,%eax
  80105f:	e8 d9 fd ff ff       	call   800e3d <nsipc>
}
  801064:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801067:	c9                   	leave  
  801068:	c3                   	ret    

00801069 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80106f:	8b 45 08             	mov    0x8(%ebp),%eax
  801072:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801077:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80107f:	8b 45 10             	mov    0x10(%ebp),%eax
  801082:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801087:	b8 09 00 00 00       	mov    $0x9,%eax
  80108c:	e8 ac fd ff ff       	call   800e3d <nsipc>
}
  801091:	c9                   	leave  
  801092:	c3                   	ret    

00801093 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	56                   	push   %esi
  801097:	53                   	push   %ebx
  801098:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	ff 75 08             	pushl  0x8(%ebp)
  8010a1:	e8 56 f3 ff ff       	call   8003fc <fd2data>
  8010a6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010a8:	83 c4 08             	add    $0x8,%esp
  8010ab:	68 34 24 80 00       	push   $0x802434
  8010b0:	53                   	push   %ebx
  8010b1:	e8 19 0b 00 00       	call   801bcf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010b6:	8b 56 04             	mov    0x4(%esi),%edx
  8010b9:	89 d0                	mov    %edx,%eax
  8010bb:	2b 06                	sub    (%esi),%eax
  8010bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8010c3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8010ca:	00 00 00 
	stat->st_dev = &devpipe;
  8010cd:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8010d4:	30 80 00 
	return 0;
}
  8010d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010df:	5b                   	pop    %ebx
  8010e0:	5e                   	pop    %esi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 0c             	sub    $0xc,%esp
  8010ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010ed:	53                   	push   %ebx
  8010ee:	6a 00                	push   $0x0
  8010f0:	e8 ea f0 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010f5:	89 1c 24             	mov    %ebx,(%esp)
  8010f8:	e8 ff f2 ff ff       	call   8003fc <fd2data>
  8010fd:	83 c4 08             	add    $0x8,%esp
  801100:	50                   	push   %eax
  801101:	6a 00                	push   $0x0
  801103:	e8 d7 f0 ff ff       	call   8001df <sys_page_unmap>
}
  801108:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110b:	c9                   	leave  
  80110c:	c3                   	ret    

0080110d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	57                   	push   %edi
  801111:	56                   	push   %esi
  801112:	53                   	push   %ebx
  801113:	83 ec 1c             	sub    $0x1c,%esp
  801116:	89 c6                	mov    %eax,%esi
  801118:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80111b:	a1 08 40 80 00       	mov    0x804008,%eax
  801120:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801123:	83 ec 0c             	sub    $0xc,%esp
  801126:	56                   	push   %esi
  801127:	e8 e5 0e 00 00       	call   802011 <pageref>
  80112c:	89 c7                	mov    %eax,%edi
  80112e:	83 c4 04             	add    $0x4,%esp
  801131:	ff 75 e4             	pushl  -0x1c(%ebp)
  801134:	e8 d8 0e 00 00       	call   802011 <pageref>
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	39 c7                	cmp    %eax,%edi
  80113e:	0f 94 c2             	sete   %dl
  801141:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801144:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  80114a:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  80114d:	39 fb                	cmp    %edi,%ebx
  80114f:	74 19                	je     80116a <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801151:	84 d2                	test   %dl,%dl
  801153:	74 c6                	je     80111b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801155:	8b 51 58             	mov    0x58(%ecx),%edx
  801158:	50                   	push   %eax
  801159:	52                   	push   %edx
  80115a:	53                   	push   %ebx
  80115b:	68 3b 24 80 00       	push   $0x80243b
  801160:	e8 e3 04 00 00       	call   801648 <cprintf>
  801165:	83 c4 10             	add    $0x10,%esp
  801168:	eb b1                	jmp    80111b <_pipeisclosed+0xe>
	}
}
  80116a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116d:	5b                   	pop    %ebx
  80116e:	5e                   	pop    %esi
  80116f:	5f                   	pop    %edi
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	57                   	push   %edi
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 28             	sub    $0x28,%esp
  80117b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80117e:	56                   	push   %esi
  80117f:	e8 78 f2 ff ff       	call   8003fc <fd2data>
  801184:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	bf 00 00 00 00       	mov    $0x0,%edi
  80118e:	eb 4b                	jmp    8011db <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801190:	89 da                	mov    %ebx,%edx
  801192:	89 f0                	mov    %esi,%eax
  801194:	e8 74 ff ff ff       	call   80110d <_pipeisclosed>
  801199:	85 c0                	test   %eax,%eax
  80119b:	75 48                	jne    8011e5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80119d:	e8 99 ef ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011a2:	8b 43 04             	mov    0x4(%ebx),%eax
  8011a5:	8b 0b                	mov    (%ebx),%ecx
  8011a7:	8d 51 20             	lea    0x20(%ecx),%edx
  8011aa:	39 d0                	cmp    %edx,%eax
  8011ac:	73 e2                	jae    801190 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011b5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	c1 fa 1f             	sar    $0x1f,%edx
  8011bd:	89 d1                	mov    %edx,%ecx
  8011bf:	c1 e9 1b             	shr    $0x1b,%ecx
  8011c2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8011c5:	83 e2 1f             	and    $0x1f,%edx
  8011c8:	29 ca                	sub    %ecx,%edx
  8011ca:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8011ce:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011d2:	83 c0 01             	add    $0x1,%eax
  8011d5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d8:	83 c7 01             	add    $0x1,%edi
  8011db:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011de:	75 c2                	jne    8011a2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011e3:	eb 05                	jmp    8011ea <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011e5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	57                   	push   %edi
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 18             	sub    $0x18,%esp
  8011fb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011fe:	57                   	push   %edi
  8011ff:	e8 f8 f1 ff ff       	call   8003fc <fd2data>
  801204:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120e:	eb 3d                	jmp    80124d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801210:	85 db                	test   %ebx,%ebx
  801212:	74 04                	je     801218 <devpipe_read+0x26>
				return i;
  801214:	89 d8                	mov    %ebx,%eax
  801216:	eb 44                	jmp    80125c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801218:	89 f2                	mov    %esi,%edx
  80121a:	89 f8                	mov    %edi,%eax
  80121c:	e8 ec fe ff ff       	call   80110d <_pipeisclosed>
  801221:	85 c0                	test   %eax,%eax
  801223:	75 32                	jne    801257 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801225:	e8 11 ef ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80122a:	8b 06                	mov    (%esi),%eax
  80122c:	3b 46 04             	cmp    0x4(%esi),%eax
  80122f:	74 df                	je     801210 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801231:	99                   	cltd   
  801232:	c1 ea 1b             	shr    $0x1b,%edx
  801235:	01 d0                	add    %edx,%eax
  801237:	83 e0 1f             	and    $0x1f,%eax
  80123a:	29 d0                	sub    %edx,%eax
  80123c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801241:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801244:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801247:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80124a:	83 c3 01             	add    $0x1,%ebx
  80124d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801250:	75 d8                	jne    80122a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801252:	8b 45 10             	mov    0x10(%ebp),%eax
  801255:	eb 05                	jmp    80125c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801257:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80125c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125f:	5b                   	pop    %ebx
  801260:	5e                   	pop    %esi
  801261:	5f                   	pop    %edi
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	56                   	push   %esi
  801268:	53                   	push   %ebx
  801269:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80126c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126f:	50                   	push   %eax
  801270:	e8 9e f1 ff ff       	call   800413 <fd_alloc>
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	89 c2                	mov    %eax,%edx
  80127a:	85 c0                	test   %eax,%eax
  80127c:	0f 88 2c 01 00 00    	js     8013ae <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801282:	83 ec 04             	sub    $0x4,%esp
  801285:	68 07 04 00 00       	push   $0x407
  80128a:	ff 75 f4             	pushl  -0xc(%ebp)
  80128d:	6a 00                	push   $0x0
  80128f:	e8 c6 ee ff ff       	call   80015a <sys_page_alloc>
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	89 c2                	mov    %eax,%edx
  801299:	85 c0                	test   %eax,%eax
  80129b:	0f 88 0d 01 00 00    	js     8013ae <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012a1:	83 ec 0c             	sub    $0xc,%esp
  8012a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	e8 66 f1 ff ff       	call   800413 <fd_alloc>
  8012ad:	89 c3                	mov    %eax,%ebx
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	0f 88 e2 00 00 00    	js     80139c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	68 07 04 00 00       	push   $0x407
  8012c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c5:	6a 00                	push   $0x0
  8012c7:	e8 8e ee ff ff       	call   80015a <sys_page_alloc>
  8012cc:	89 c3                	mov    %eax,%ebx
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	0f 88 c3 00 00 00    	js     80139c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8012df:	e8 18 f1 ff ff       	call   8003fc <fd2data>
  8012e4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012e6:	83 c4 0c             	add    $0xc,%esp
  8012e9:	68 07 04 00 00       	push   $0x407
  8012ee:	50                   	push   %eax
  8012ef:	6a 00                	push   $0x0
  8012f1:	e8 64 ee ff ff       	call   80015a <sys_page_alloc>
  8012f6:	89 c3                	mov    %eax,%ebx
  8012f8:	83 c4 10             	add    $0x10,%esp
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	0f 88 89 00 00 00    	js     80138c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801303:	83 ec 0c             	sub    $0xc,%esp
  801306:	ff 75 f0             	pushl  -0x10(%ebp)
  801309:	e8 ee f0 ff ff       	call   8003fc <fd2data>
  80130e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801315:	50                   	push   %eax
  801316:	6a 00                	push   $0x0
  801318:	56                   	push   %esi
  801319:	6a 00                	push   $0x0
  80131b:	e8 7d ee ff ff       	call   80019d <sys_page_map>
  801320:	89 c3                	mov    %eax,%ebx
  801322:	83 c4 20             	add    $0x20,%esp
  801325:	85 c0                	test   %eax,%eax
  801327:	78 55                	js     80137e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801329:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80132f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801332:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801334:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801337:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80133e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801344:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801347:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801349:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	ff 75 f4             	pushl  -0xc(%ebp)
  801359:	e8 8e f0 ff ff       	call   8003ec <fd2num>
  80135e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801361:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801363:	83 c4 04             	add    $0x4,%esp
  801366:	ff 75 f0             	pushl  -0x10(%ebp)
  801369:	e8 7e f0 ff ff       	call   8003ec <fd2num>
  80136e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801371:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	ba 00 00 00 00       	mov    $0x0,%edx
  80137c:	eb 30                	jmp    8013ae <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80137e:	83 ec 08             	sub    $0x8,%esp
  801381:	56                   	push   %esi
  801382:	6a 00                	push   $0x0
  801384:	e8 56 ee ff ff       	call   8001df <sys_page_unmap>
  801389:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	ff 75 f0             	pushl  -0x10(%ebp)
  801392:	6a 00                	push   $0x0
  801394:	e8 46 ee ff ff       	call   8001df <sys_page_unmap>
  801399:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a2:	6a 00                	push   $0x0
  8013a4:	e8 36 ee ff ff       	call   8001df <sys_page_unmap>
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013ae:	89 d0                	mov    %edx,%eax
  8013b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b3:	5b                   	pop    %ebx
  8013b4:	5e                   	pop    %esi
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c0:	50                   	push   %eax
  8013c1:	ff 75 08             	pushl  0x8(%ebp)
  8013c4:	e8 99 f0 ff ff       	call   800462 <fd_lookup>
  8013c9:	89 c2                	mov    %eax,%edx
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	85 d2                	test   %edx,%edx
  8013d0:	78 18                	js     8013ea <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013d2:	83 ec 0c             	sub    $0xc,%esp
  8013d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d8:	e8 1f f0 ff ff       	call   8003fc <fd2data>
	return _pipeisclosed(fd, p);
  8013dd:	89 c2                	mov    %eax,%edx
  8013df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e2:	e8 26 fd ff ff       	call   80110d <_pipeisclosed>
  8013e7:	83 c4 10             	add    $0x10,%esp
}
  8013ea:	c9                   	leave  
  8013eb:	c3                   	ret    

008013ec <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013fc:	68 53 24 80 00       	push   $0x802453
  801401:	ff 75 0c             	pushl  0xc(%ebp)
  801404:	e8 c6 07 00 00       	call   801bcf <strcpy>
	return 0;
}
  801409:	b8 00 00 00 00       	mov    $0x0,%eax
  80140e:	c9                   	leave  
  80140f:	c3                   	ret    

00801410 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	57                   	push   %edi
  801414:	56                   	push   %esi
  801415:	53                   	push   %ebx
  801416:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80141c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801421:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801427:	eb 2d                	jmp    801456 <devcons_write+0x46>
		m = n - tot;
  801429:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80142c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80142e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801431:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801436:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801439:	83 ec 04             	sub    $0x4,%esp
  80143c:	53                   	push   %ebx
  80143d:	03 45 0c             	add    0xc(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	57                   	push   %edi
  801442:	e8 1a 09 00 00       	call   801d61 <memmove>
		sys_cputs(buf, m);
  801447:	83 c4 08             	add    $0x8,%esp
  80144a:	53                   	push   %ebx
  80144b:	57                   	push   %edi
  80144c:	e8 4d ec ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801451:	01 de                	add    %ebx,%esi
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	89 f0                	mov    %esi,%eax
  801458:	3b 75 10             	cmp    0x10(%ebp),%esi
  80145b:	72 cc                	jb     801429 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80145d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801460:	5b                   	pop    %ebx
  801461:	5e                   	pop    %esi
  801462:	5f                   	pop    %edi
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    

00801465 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80146b:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801470:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801474:	75 07                	jne    80147d <devcons_read+0x18>
  801476:	eb 28                	jmp    8014a0 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801478:	e8 be ec ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80147d:	e8 3a ec ff ff       	call   8000bc <sys_cgetc>
  801482:	85 c0                	test   %eax,%eax
  801484:	74 f2                	je     801478 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801486:	85 c0                	test   %eax,%eax
  801488:	78 16                	js     8014a0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80148a:	83 f8 04             	cmp    $0x4,%eax
  80148d:	74 0c                	je     80149b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80148f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801492:	88 02                	mov    %al,(%edx)
	return 1;
  801494:	b8 01 00 00 00       	mov    $0x1,%eax
  801499:	eb 05                	jmp    8014a0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80149b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    

008014a2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ab:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014ae:	6a 01                	push   $0x1
  8014b0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014b3:	50                   	push   %eax
  8014b4:	e8 e5 eb ff ff       	call   80009e <sys_cputs>
  8014b9:	83 c4 10             	add    $0x10,%esp
}
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <getchar>:

int
getchar(void)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014c4:	6a 01                	push   $0x1
  8014c6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	6a 00                	push   $0x0
  8014cc:	e8 00 f2 ff ff       	call   8006d1 <read>
	if (r < 0)
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 0f                	js     8014e7 <getchar+0x29>
		return r;
	if (r < 1)
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	7e 06                	jle    8014e2 <getchar+0x24>
		return -E_EOF;
	return c;
  8014dc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014e0:	eb 05                	jmp    8014e7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014e2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014e7:	c9                   	leave  
  8014e8:	c3                   	ret    

008014e9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f2:	50                   	push   %eax
  8014f3:	ff 75 08             	pushl  0x8(%ebp)
  8014f6:	e8 67 ef ff ff       	call   800462 <fd_lookup>
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 11                	js     801513 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801502:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801505:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80150b:	39 10                	cmp    %edx,(%eax)
  80150d:	0f 94 c0             	sete   %al
  801510:	0f b6 c0             	movzbl %al,%eax
}
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <opencons>:

int
opencons(void)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80151b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	e8 ef ee ff ff       	call   800413 <fd_alloc>
  801524:	83 c4 10             	add    $0x10,%esp
		return r;
  801527:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 3e                	js     80156b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80152d:	83 ec 04             	sub    $0x4,%esp
  801530:	68 07 04 00 00       	push   $0x407
  801535:	ff 75 f4             	pushl  -0xc(%ebp)
  801538:	6a 00                	push   $0x0
  80153a:	e8 1b ec ff ff       	call   80015a <sys_page_alloc>
  80153f:	83 c4 10             	add    $0x10,%esp
		return r;
  801542:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801544:	85 c0                	test   %eax,%eax
  801546:	78 23                	js     80156b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801548:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80154e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801551:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801553:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801556:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80155d:	83 ec 0c             	sub    $0xc,%esp
  801560:	50                   	push   %eax
  801561:	e8 86 ee ff ff       	call   8003ec <fd2num>
  801566:	89 c2                	mov    %eax,%edx
  801568:	83 c4 10             	add    $0x10,%esp
}
  80156b:	89 d0                	mov    %edx,%eax
  80156d:	c9                   	leave  
  80156e:	c3                   	ret    

0080156f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	56                   	push   %esi
  801573:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801574:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801577:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80157d:	e8 9a eb ff ff       	call   80011c <sys_getenvid>
  801582:	83 ec 0c             	sub    $0xc,%esp
  801585:	ff 75 0c             	pushl  0xc(%ebp)
  801588:	ff 75 08             	pushl  0x8(%ebp)
  80158b:	56                   	push   %esi
  80158c:	50                   	push   %eax
  80158d:	68 60 24 80 00       	push   $0x802460
  801592:	e8 b1 00 00 00       	call   801648 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801597:	83 c4 18             	add    $0x18,%esp
  80159a:	53                   	push   %ebx
  80159b:	ff 75 10             	pushl  0x10(%ebp)
  80159e:	e8 54 00 00 00       	call   8015f7 <vcprintf>
	cprintf("\n");
  8015a3:	c7 04 24 4c 24 80 00 	movl   $0x80244c,(%esp)
  8015aa:	e8 99 00 00 00       	call   801648 <cprintf>
  8015af:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015b2:	cc                   	int3   
  8015b3:	eb fd                	jmp    8015b2 <_panic+0x43>

008015b5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 04             	sub    $0x4,%esp
  8015bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015bf:	8b 13                	mov    (%ebx),%edx
  8015c1:	8d 42 01             	lea    0x1(%edx),%eax
  8015c4:	89 03                	mov    %eax,(%ebx)
  8015c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8015cd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015d2:	75 1a                	jne    8015ee <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	68 ff 00 00 00       	push   $0xff
  8015dc:	8d 43 08             	lea    0x8(%ebx),%eax
  8015df:	50                   	push   %eax
  8015e0:	e8 b9 ea ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8015e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015eb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015ee:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f5:	c9                   	leave  
  8015f6:	c3                   	ret    

008015f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801600:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801607:	00 00 00 
	b.cnt = 0;
  80160a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801611:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801614:	ff 75 0c             	pushl  0xc(%ebp)
  801617:	ff 75 08             	pushl  0x8(%ebp)
  80161a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	68 b5 15 80 00       	push   $0x8015b5
  801626:	e8 4f 01 00 00       	call   80177a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80162b:	83 c4 08             	add    $0x8,%esp
  80162e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801634:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80163a:	50                   	push   %eax
  80163b:	e8 5e ea ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  801640:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80164e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801651:	50                   	push   %eax
  801652:	ff 75 08             	pushl  0x8(%ebp)
  801655:	e8 9d ff ff ff       	call   8015f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	57                   	push   %edi
  801660:	56                   	push   %esi
  801661:	53                   	push   %ebx
  801662:	83 ec 1c             	sub    $0x1c,%esp
  801665:	89 c7                	mov    %eax,%edi
  801667:	89 d6                	mov    %edx,%esi
  801669:	8b 45 08             	mov    0x8(%ebp),%eax
  80166c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80166f:	89 d1                	mov    %edx,%ecx
  801671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801674:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801677:	8b 45 10             	mov    0x10(%ebp),%eax
  80167a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80167d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801680:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801687:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80168a:	72 05                	jb     801691 <printnum+0x35>
  80168c:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80168f:	77 3e                	ja     8016cf <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801691:	83 ec 0c             	sub    $0xc,%esp
  801694:	ff 75 18             	pushl  0x18(%ebp)
  801697:	83 eb 01             	sub    $0x1,%ebx
  80169a:	53                   	push   %ebx
  80169b:	50                   	push   %eax
  80169c:	83 ec 08             	sub    $0x8,%esp
  80169f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8016a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8016ab:	e8 a0 09 00 00       	call   802050 <__udivdi3>
  8016b0:	83 c4 18             	add    $0x18,%esp
  8016b3:	52                   	push   %edx
  8016b4:	50                   	push   %eax
  8016b5:	89 f2                	mov    %esi,%edx
  8016b7:	89 f8                	mov    %edi,%eax
  8016b9:	e8 9e ff ff ff       	call   80165c <printnum>
  8016be:	83 c4 20             	add    $0x20,%esp
  8016c1:	eb 13                	jmp    8016d6 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8016c3:	83 ec 08             	sub    $0x8,%esp
  8016c6:	56                   	push   %esi
  8016c7:	ff 75 18             	pushl  0x18(%ebp)
  8016ca:	ff d7                	call   *%edi
  8016cc:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8016cf:	83 eb 01             	sub    $0x1,%ebx
  8016d2:	85 db                	test   %ebx,%ebx
  8016d4:	7f ed                	jg     8016c3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	56                   	push   %esi
  8016da:	83 ec 04             	sub    $0x4,%esp
  8016dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8016e3:	ff 75 dc             	pushl  -0x24(%ebp)
  8016e6:	ff 75 d8             	pushl  -0x28(%ebp)
  8016e9:	e8 92 0a 00 00       	call   802180 <__umoddi3>
  8016ee:	83 c4 14             	add    $0x14,%esp
  8016f1:	0f be 80 83 24 80 00 	movsbl 0x802483(%eax),%eax
  8016f8:	50                   	push   %eax
  8016f9:	ff d7                	call   *%edi
  8016fb:	83 c4 10             	add    $0x10,%esp
}
  8016fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801701:	5b                   	pop    %ebx
  801702:	5e                   	pop    %esi
  801703:	5f                   	pop    %edi
  801704:	5d                   	pop    %ebp
  801705:	c3                   	ret    

00801706 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801709:	83 fa 01             	cmp    $0x1,%edx
  80170c:	7e 0e                	jle    80171c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80170e:	8b 10                	mov    (%eax),%edx
  801710:	8d 4a 08             	lea    0x8(%edx),%ecx
  801713:	89 08                	mov    %ecx,(%eax)
  801715:	8b 02                	mov    (%edx),%eax
  801717:	8b 52 04             	mov    0x4(%edx),%edx
  80171a:	eb 22                	jmp    80173e <getuint+0x38>
	else if (lflag)
  80171c:	85 d2                	test   %edx,%edx
  80171e:	74 10                	je     801730 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801720:	8b 10                	mov    (%eax),%edx
  801722:	8d 4a 04             	lea    0x4(%edx),%ecx
  801725:	89 08                	mov    %ecx,(%eax)
  801727:	8b 02                	mov    (%edx),%eax
  801729:	ba 00 00 00 00       	mov    $0x0,%edx
  80172e:	eb 0e                	jmp    80173e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801730:	8b 10                	mov    (%eax),%edx
  801732:	8d 4a 04             	lea    0x4(%edx),%ecx
  801735:	89 08                	mov    %ecx,(%eax)
  801737:	8b 02                	mov    (%edx),%eax
  801739:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801746:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80174a:	8b 10                	mov    (%eax),%edx
  80174c:	3b 50 04             	cmp    0x4(%eax),%edx
  80174f:	73 0a                	jae    80175b <sprintputch+0x1b>
		*b->buf++ = ch;
  801751:	8d 4a 01             	lea    0x1(%edx),%ecx
  801754:	89 08                	mov    %ecx,(%eax)
  801756:	8b 45 08             	mov    0x8(%ebp),%eax
  801759:	88 02                	mov    %al,(%edx)
}
  80175b:	5d                   	pop    %ebp
  80175c:	c3                   	ret    

0080175d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801763:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801766:	50                   	push   %eax
  801767:	ff 75 10             	pushl  0x10(%ebp)
  80176a:	ff 75 0c             	pushl  0xc(%ebp)
  80176d:	ff 75 08             	pushl  0x8(%ebp)
  801770:	e8 05 00 00 00       	call   80177a <vprintfmt>
	va_end(ap);
  801775:	83 c4 10             	add    $0x10,%esp
}
  801778:	c9                   	leave  
  801779:	c3                   	ret    

0080177a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	57                   	push   %edi
  80177e:	56                   	push   %esi
  80177f:	53                   	push   %ebx
  801780:	83 ec 2c             	sub    $0x2c,%esp
  801783:	8b 75 08             	mov    0x8(%ebp),%esi
  801786:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801789:	8b 7d 10             	mov    0x10(%ebp),%edi
  80178c:	eb 12                	jmp    8017a0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80178e:	85 c0                	test   %eax,%eax
  801790:	0f 84 90 03 00 00    	je     801b26 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  801796:	83 ec 08             	sub    $0x8,%esp
  801799:	53                   	push   %ebx
  80179a:	50                   	push   %eax
  80179b:	ff d6                	call   *%esi
  80179d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017a0:	83 c7 01             	add    $0x1,%edi
  8017a3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017a7:	83 f8 25             	cmp    $0x25,%eax
  8017aa:	75 e2                	jne    80178e <vprintfmt+0x14>
  8017ac:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017b0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8017b7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017be:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8017c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ca:	eb 07                	jmp    8017d3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8017cf:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d3:	8d 47 01             	lea    0x1(%edi),%eax
  8017d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017d9:	0f b6 07             	movzbl (%edi),%eax
  8017dc:	0f b6 c8             	movzbl %al,%ecx
  8017df:	83 e8 23             	sub    $0x23,%eax
  8017e2:	3c 55                	cmp    $0x55,%al
  8017e4:	0f 87 21 03 00 00    	ja     801b0b <vprintfmt+0x391>
  8017ea:	0f b6 c0             	movzbl %al,%eax
  8017ed:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  8017f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017f7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017fb:	eb d6                	jmp    8017d3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801800:	b8 00 00 00 00       	mov    $0x0,%eax
  801805:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801808:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80180b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80180f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801812:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801815:	83 fa 09             	cmp    $0x9,%edx
  801818:	77 39                	ja     801853 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80181a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80181d:	eb e9                	jmp    801808 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80181f:	8b 45 14             	mov    0x14(%ebp),%eax
  801822:	8d 48 04             	lea    0x4(%eax),%ecx
  801825:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801828:	8b 00                	mov    (%eax),%eax
  80182a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801830:	eb 27                	jmp    801859 <vprintfmt+0xdf>
  801832:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801835:	85 c0                	test   %eax,%eax
  801837:	b9 00 00 00 00       	mov    $0x0,%ecx
  80183c:	0f 49 c8             	cmovns %eax,%ecx
  80183f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801842:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801845:	eb 8c                	jmp    8017d3 <vprintfmt+0x59>
  801847:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80184a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801851:	eb 80                	jmp    8017d3 <vprintfmt+0x59>
  801853:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801856:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801859:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80185d:	0f 89 70 ff ff ff    	jns    8017d3 <vprintfmt+0x59>
				width = precision, precision = -1;
  801863:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801866:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801869:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801870:	e9 5e ff ff ff       	jmp    8017d3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801875:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801878:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80187b:	e9 53 ff ff ff       	jmp    8017d3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801880:	8b 45 14             	mov    0x14(%ebp),%eax
  801883:	8d 50 04             	lea    0x4(%eax),%edx
  801886:	89 55 14             	mov    %edx,0x14(%ebp)
  801889:	83 ec 08             	sub    $0x8,%esp
  80188c:	53                   	push   %ebx
  80188d:	ff 30                	pushl  (%eax)
  80188f:	ff d6                	call   *%esi
			break;
  801891:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801894:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801897:	e9 04 ff ff ff       	jmp    8017a0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80189c:	8b 45 14             	mov    0x14(%ebp),%eax
  80189f:	8d 50 04             	lea    0x4(%eax),%edx
  8018a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8018a5:	8b 00                	mov    (%eax),%eax
  8018a7:	99                   	cltd   
  8018a8:	31 d0                	xor    %edx,%eax
  8018aa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018ac:	83 f8 0f             	cmp    $0xf,%eax
  8018af:	7f 0b                	jg     8018bc <vprintfmt+0x142>
  8018b1:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  8018b8:	85 d2                	test   %edx,%edx
  8018ba:	75 18                	jne    8018d4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8018bc:	50                   	push   %eax
  8018bd:	68 9b 24 80 00       	push   $0x80249b
  8018c2:	53                   	push   %ebx
  8018c3:	56                   	push   %esi
  8018c4:	e8 94 fe ff ff       	call   80175d <printfmt>
  8018c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8018cf:	e9 cc fe ff ff       	jmp    8017a0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018d4:	52                   	push   %edx
  8018d5:	68 e1 23 80 00       	push   $0x8023e1
  8018da:	53                   	push   %ebx
  8018db:	56                   	push   %esi
  8018dc:	e8 7c fe ff ff       	call   80175d <printfmt>
  8018e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018e7:	e9 b4 fe ff ff       	jmp    8017a0 <vprintfmt+0x26>
  8018ec:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8018ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f8:	8d 50 04             	lea    0x4(%eax),%edx
  8018fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8018fe:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801900:	85 ff                	test   %edi,%edi
  801902:	ba 94 24 80 00       	mov    $0x802494,%edx
  801907:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80190a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80190e:	0f 84 92 00 00 00    	je     8019a6 <vprintfmt+0x22c>
  801914:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801918:	0f 8e 96 00 00 00    	jle    8019b4 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80191e:	83 ec 08             	sub    $0x8,%esp
  801921:	51                   	push   %ecx
  801922:	57                   	push   %edi
  801923:	e8 86 02 00 00       	call   801bae <strnlen>
  801928:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80192b:	29 c1                	sub    %eax,%ecx
  80192d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801930:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801933:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801937:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80193a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80193d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80193f:	eb 0f                	jmp    801950 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	53                   	push   %ebx
  801945:	ff 75 e0             	pushl  -0x20(%ebp)
  801948:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80194a:	83 ef 01             	sub    $0x1,%edi
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	85 ff                	test   %edi,%edi
  801952:	7f ed                	jg     801941 <vprintfmt+0x1c7>
  801954:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801957:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80195a:	85 c9                	test   %ecx,%ecx
  80195c:	b8 00 00 00 00       	mov    $0x0,%eax
  801961:	0f 49 c1             	cmovns %ecx,%eax
  801964:	29 c1                	sub    %eax,%ecx
  801966:	89 75 08             	mov    %esi,0x8(%ebp)
  801969:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80196c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80196f:	89 cb                	mov    %ecx,%ebx
  801971:	eb 4d                	jmp    8019c0 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801973:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801977:	74 1b                	je     801994 <vprintfmt+0x21a>
  801979:	0f be c0             	movsbl %al,%eax
  80197c:	83 e8 20             	sub    $0x20,%eax
  80197f:	83 f8 5e             	cmp    $0x5e,%eax
  801982:	76 10                	jbe    801994 <vprintfmt+0x21a>
					putch('?', putdat);
  801984:	83 ec 08             	sub    $0x8,%esp
  801987:	ff 75 0c             	pushl  0xc(%ebp)
  80198a:	6a 3f                	push   $0x3f
  80198c:	ff 55 08             	call   *0x8(%ebp)
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	eb 0d                	jmp    8019a1 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	ff 75 0c             	pushl  0xc(%ebp)
  80199a:	52                   	push   %edx
  80199b:	ff 55 08             	call   *0x8(%ebp)
  80199e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019a1:	83 eb 01             	sub    $0x1,%ebx
  8019a4:	eb 1a                	jmp    8019c0 <vprintfmt+0x246>
  8019a6:	89 75 08             	mov    %esi,0x8(%ebp)
  8019a9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019ac:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019af:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019b2:	eb 0c                	jmp    8019c0 <vprintfmt+0x246>
  8019b4:	89 75 08             	mov    %esi,0x8(%ebp)
  8019b7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019ba:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019bd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019c0:	83 c7 01             	add    $0x1,%edi
  8019c3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019c7:	0f be d0             	movsbl %al,%edx
  8019ca:	85 d2                	test   %edx,%edx
  8019cc:	74 23                	je     8019f1 <vprintfmt+0x277>
  8019ce:	85 f6                	test   %esi,%esi
  8019d0:	78 a1                	js     801973 <vprintfmt+0x1f9>
  8019d2:	83 ee 01             	sub    $0x1,%esi
  8019d5:	79 9c                	jns    801973 <vprintfmt+0x1f9>
  8019d7:	89 df                	mov    %ebx,%edi
  8019d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8019dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019df:	eb 18                	jmp    8019f9 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019e1:	83 ec 08             	sub    $0x8,%esp
  8019e4:	53                   	push   %ebx
  8019e5:	6a 20                	push   $0x20
  8019e7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019e9:	83 ef 01             	sub    $0x1,%edi
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	eb 08                	jmp    8019f9 <vprintfmt+0x27f>
  8019f1:	89 df                	mov    %ebx,%edi
  8019f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019f9:	85 ff                	test   %edi,%edi
  8019fb:	7f e4                	jg     8019e1 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a00:	e9 9b fd ff ff       	jmp    8017a0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a05:	83 fa 01             	cmp    $0x1,%edx
  801a08:	7e 16                	jle    801a20 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0d:	8d 50 08             	lea    0x8(%eax),%edx
  801a10:	89 55 14             	mov    %edx,0x14(%ebp)
  801a13:	8b 50 04             	mov    0x4(%eax),%edx
  801a16:	8b 00                	mov    (%eax),%eax
  801a18:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a1b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a1e:	eb 32                	jmp    801a52 <vprintfmt+0x2d8>
	else if (lflag)
  801a20:	85 d2                	test   %edx,%edx
  801a22:	74 18                	je     801a3c <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801a24:	8b 45 14             	mov    0x14(%ebp),%eax
  801a27:	8d 50 04             	lea    0x4(%eax),%edx
  801a2a:	89 55 14             	mov    %edx,0x14(%ebp)
  801a2d:	8b 00                	mov    (%eax),%eax
  801a2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a32:	89 c1                	mov    %eax,%ecx
  801a34:	c1 f9 1f             	sar    $0x1f,%ecx
  801a37:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a3a:	eb 16                	jmp    801a52 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801a3c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3f:	8d 50 04             	lea    0x4(%eax),%edx
  801a42:	89 55 14             	mov    %edx,0x14(%ebp)
  801a45:	8b 00                	mov    (%eax),%eax
  801a47:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a4a:	89 c1                	mov    %eax,%ecx
  801a4c:	c1 f9 1f             	sar    $0x1f,%ecx
  801a4f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a52:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a55:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a58:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a5d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a61:	79 74                	jns    801ad7 <vprintfmt+0x35d>
				putch('-', putdat);
  801a63:	83 ec 08             	sub    $0x8,%esp
  801a66:	53                   	push   %ebx
  801a67:	6a 2d                	push   $0x2d
  801a69:	ff d6                	call   *%esi
				num = -(long long) num;
  801a6b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a6e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a71:	f7 d8                	neg    %eax
  801a73:	83 d2 00             	adc    $0x0,%edx
  801a76:	f7 da                	neg    %edx
  801a78:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a7b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a80:	eb 55                	jmp    801ad7 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a82:	8d 45 14             	lea    0x14(%ebp),%eax
  801a85:	e8 7c fc ff ff       	call   801706 <getuint>
			base = 10;
  801a8a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a8f:	eb 46                	jmp    801ad7 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a91:	8d 45 14             	lea    0x14(%ebp),%eax
  801a94:	e8 6d fc ff ff       	call   801706 <getuint>
                        base = 8;
  801a99:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a9e:	eb 37                	jmp    801ad7 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801aa0:	83 ec 08             	sub    $0x8,%esp
  801aa3:	53                   	push   %ebx
  801aa4:	6a 30                	push   $0x30
  801aa6:	ff d6                	call   *%esi
			putch('x', putdat);
  801aa8:	83 c4 08             	add    $0x8,%esp
  801aab:	53                   	push   %ebx
  801aac:	6a 78                	push   $0x78
  801aae:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801ab0:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab3:	8d 50 04             	lea    0x4(%eax),%edx
  801ab6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ab9:	8b 00                	mov    (%eax),%eax
  801abb:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ac0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ac3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ac8:	eb 0d                	jmp    801ad7 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801aca:	8d 45 14             	lea    0x14(%ebp),%eax
  801acd:	e8 34 fc ff ff       	call   801706 <getuint>
			base = 16;
  801ad2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ad7:	83 ec 0c             	sub    $0xc,%esp
  801ada:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ade:	57                   	push   %edi
  801adf:	ff 75 e0             	pushl  -0x20(%ebp)
  801ae2:	51                   	push   %ecx
  801ae3:	52                   	push   %edx
  801ae4:	50                   	push   %eax
  801ae5:	89 da                	mov    %ebx,%edx
  801ae7:	89 f0                	mov    %esi,%eax
  801ae9:	e8 6e fb ff ff       	call   80165c <printnum>
			break;
  801aee:	83 c4 20             	add    $0x20,%esp
  801af1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801af4:	e9 a7 fc ff ff       	jmp    8017a0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801af9:	83 ec 08             	sub    $0x8,%esp
  801afc:	53                   	push   %ebx
  801afd:	51                   	push   %ecx
  801afe:	ff d6                	call   *%esi
			break;
  801b00:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b03:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b06:	e9 95 fc ff ff       	jmp    8017a0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b0b:	83 ec 08             	sub    $0x8,%esp
  801b0e:	53                   	push   %ebx
  801b0f:	6a 25                	push   $0x25
  801b11:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	eb 03                	jmp    801b1b <vprintfmt+0x3a1>
  801b18:	83 ef 01             	sub    $0x1,%edi
  801b1b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b1f:	75 f7                	jne    801b18 <vprintfmt+0x39e>
  801b21:	e9 7a fc ff ff       	jmp    8017a0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b29:	5b                   	pop    %ebx
  801b2a:	5e                   	pop    %esi
  801b2b:	5f                   	pop    %edi
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    

00801b2e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	83 ec 18             	sub    $0x18,%esp
  801b34:	8b 45 08             	mov    0x8(%ebp),%eax
  801b37:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b3d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b41:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b44:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	74 26                	je     801b75 <vsnprintf+0x47>
  801b4f:	85 d2                	test   %edx,%edx
  801b51:	7e 22                	jle    801b75 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b53:	ff 75 14             	pushl  0x14(%ebp)
  801b56:	ff 75 10             	pushl  0x10(%ebp)
  801b59:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b5c:	50                   	push   %eax
  801b5d:	68 40 17 80 00       	push   $0x801740
  801b62:	e8 13 fc ff ff       	call   80177a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b67:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b6a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b70:	83 c4 10             	add    $0x10,%esp
  801b73:	eb 05                	jmp    801b7a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b75:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b7a:	c9                   	leave  
  801b7b:	c3                   	ret    

00801b7c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b82:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b85:	50                   	push   %eax
  801b86:	ff 75 10             	pushl  0x10(%ebp)
  801b89:	ff 75 0c             	pushl  0xc(%ebp)
  801b8c:	ff 75 08             	pushl  0x8(%ebp)
  801b8f:	e8 9a ff ff ff       	call   801b2e <vsnprintf>
	va_end(ap);

	return rc;
}
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba1:	eb 03                	jmp    801ba6 <strlen+0x10>
		n++;
  801ba3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ba6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801baa:	75 f7                	jne    801ba3 <strlen+0xd>
		n++;
	return n;
}
  801bac:	5d                   	pop    %ebp
  801bad:	c3                   	ret    

00801bae <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bb7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bbc:	eb 03                	jmp    801bc1 <strnlen+0x13>
		n++;
  801bbe:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bc1:	39 c2                	cmp    %eax,%edx
  801bc3:	74 08                	je     801bcd <strnlen+0x1f>
  801bc5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bc9:	75 f3                	jne    801bbe <strnlen+0x10>
  801bcb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    

00801bcf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	53                   	push   %ebx
  801bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bd9:	89 c2                	mov    %eax,%edx
  801bdb:	83 c2 01             	add    $0x1,%edx
  801bde:	83 c1 01             	add    $0x1,%ecx
  801be1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801be5:	88 5a ff             	mov    %bl,-0x1(%edx)
  801be8:	84 db                	test   %bl,%bl
  801bea:	75 ef                	jne    801bdb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bec:	5b                   	pop    %ebx
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	53                   	push   %ebx
  801bf3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bf6:	53                   	push   %ebx
  801bf7:	e8 9a ff ff ff       	call   801b96 <strlen>
  801bfc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bff:	ff 75 0c             	pushl  0xc(%ebp)
  801c02:	01 d8                	add    %ebx,%eax
  801c04:	50                   	push   %eax
  801c05:	e8 c5 ff ff ff       	call   801bcf <strcpy>
	return dst;
}
  801c0a:	89 d8                	mov    %ebx,%eax
  801c0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0f:	c9                   	leave  
  801c10:	c3                   	ret    

00801c11 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	56                   	push   %esi
  801c15:	53                   	push   %ebx
  801c16:	8b 75 08             	mov    0x8(%ebp),%esi
  801c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c1c:	89 f3                	mov    %esi,%ebx
  801c1e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c21:	89 f2                	mov    %esi,%edx
  801c23:	eb 0f                	jmp    801c34 <strncpy+0x23>
		*dst++ = *src;
  801c25:	83 c2 01             	add    $0x1,%edx
  801c28:	0f b6 01             	movzbl (%ecx),%eax
  801c2b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c2e:	80 39 01             	cmpb   $0x1,(%ecx)
  801c31:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c34:	39 da                	cmp    %ebx,%edx
  801c36:	75 ed                	jne    801c25 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c38:	89 f0                	mov    %esi,%eax
  801c3a:	5b                   	pop    %ebx
  801c3b:	5e                   	pop    %esi
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	56                   	push   %esi
  801c42:	53                   	push   %ebx
  801c43:	8b 75 08             	mov    0x8(%ebp),%esi
  801c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c49:	8b 55 10             	mov    0x10(%ebp),%edx
  801c4c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c4e:	85 d2                	test   %edx,%edx
  801c50:	74 21                	je     801c73 <strlcpy+0x35>
  801c52:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c56:	89 f2                	mov    %esi,%edx
  801c58:	eb 09                	jmp    801c63 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c5a:	83 c2 01             	add    $0x1,%edx
  801c5d:	83 c1 01             	add    $0x1,%ecx
  801c60:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c63:	39 c2                	cmp    %eax,%edx
  801c65:	74 09                	je     801c70 <strlcpy+0x32>
  801c67:	0f b6 19             	movzbl (%ecx),%ebx
  801c6a:	84 db                	test   %bl,%bl
  801c6c:	75 ec                	jne    801c5a <strlcpy+0x1c>
  801c6e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c70:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c73:	29 f0                	sub    %esi,%eax
}
  801c75:	5b                   	pop    %ebx
  801c76:	5e                   	pop    %esi
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c82:	eb 06                	jmp    801c8a <strcmp+0x11>
		p++, q++;
  801c84:	83 c1 01             	add    $0x1,%ecx
  801c87:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c8a:	0f b6 01             	movzbl (%ecx),%eax
  801c8d:	84 c0                	test   %al,%al
  801c8f:	74 04                	je     801c95 <strcmp+0x1c>
  801c91:	3a 02                	cmp    (%edx),%al
  801c93:	74 ef                	je     801c84 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c95:	0f b6 c0             	movzbl %al,%eax
  801c98:	0f b6 12             	movzbl (%edx),%edx
  801c9b:	29 d0                	sub    %edx,%eax
}
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    

00801c9f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	53                   	push   %ebx
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ca9:	89 c3                	mov    %eax,%ebx
  801cab:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cae:	eb 06                	jmp    801cb6 <strncmp+0x17>
		n--, p++, q++;
  801cb0:	83 c0 01             	add    $0x1,%eax
  801cb3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cb6:	39 d8                	cmp    %ebx,%eax
  801cb8:	74 15                	je     801ccf <strncmp+0x30>
  801cba:	0f b6 08             	movzbl (%eax),%ecx
  801cbd:	84 c9                	test   %cl,%cl
  801cbf:	74 04                	je     801cc5 <strncmp+0x26>
  801cc1:	3a 0a                	cmp    (%edx),%cl
  801cc3:	74 eb                	je     801cb0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cc5:	0f b6 00             	movzbl (%eax),%eax
  801cc8:	0f b6 12             	movzbl (%edx),%edx
  801ccb:	29 d0                	sub    %edx,%eax
  801ccd:	eb 05                	jmp    801cd4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801ccf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801cd4:	5b                   	pop    %ebx
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ce1:	eb 07                	jmp    801cea <strchr+0x13>
		if (*s == c)
  801ce3:	38 ca                	cmp    %cl,%dl
  801ce5:	74 0f                	je     801cf6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ce7:	83 c0 01             	add    $0x1,%eax
  801cea:	0f b6 10             	movzbl (%eax),%edx
  801ced:	84 d2                	test   %dl,%dl
  801cef:	75 f2                	jne    801ce3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    

00801cf8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d02:	eb 03                	jmp    801d07 <strfind+0xf>
  801d04:	83 c0 01             	add    $0x1,%eax
  801d07:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d0a:	84 d2                	test   %dl,%dl
  801d0c:	74 04                	je     801d12 <strfind+0x1a>
  801d0e:	38 ca                	cmp    %cl,%dl
  801d10:	75 f2                	jne    801d04 <strfind+0xc>
			break;
	return (char *) s;
}
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    

00801d14 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	57                   	push   %edi
  801d18:	56                   	push   %esi
  801d19:	53                   	push   %ebx
  801d1a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d20:	85 c9                	test   %ecx,%ecx
  801d22:	74 36                	je     801d5a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d2a:	75 28                	jne    801d54 <memset+0x40>
  801d2c:	f6 c1 03             	test   $0x3,%cl
  801d2f:	75 23                	jne    801d54 <memset+0x40>
		c &= 0xFF;
  801d31:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d35:	89 d3                	mov    %edx,%ebx
  801d37:	c1 e3 08             	shl    $0x8,%ebx
  801d3a:	89 d6                	mov    %edx,%esi
  801d3c:	c1 e6 18             	shl    $0x18,%esi
  801d3f:	89 d0                	mov    %edx,%eax
  801d41:	c1 e0 10             	shl    $0x10,%eax
  801d44:	09 f0                	or     %esi,%eax
  801d46:	09 c2                	or     %eax,%edx
  801d48:	89 d0                	mov    %edx,%eax
  801d4a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d4c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801d4f:	fc                   	cld    
  801d50:	f3 ab                	rep stos %eax,%es:(%edi)
  801d52:	eb 06                	jmp    801d5a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d57:	fc                   	cld    
  801d58:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d5a:	89 f8                	mov    %edi,%eax
  801d5c:	5b                   	pop    %ebx
  801d5d:	5e                   	pop    %esi
  801d5e:	5f                   	pop    %edi
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    

00801d61 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	57                   	push   %edi
  801d65:	56                   	push   %esi
  801d66:	8b 45 08             	mov    0x8(%ebp),%eax
  801d69:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d6c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d6f:	39 c6                	cmp    %eax,%esi
  801d71:	73 35                	jae    801da8 <memmove+0x47>
  801d73:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d76:	39 d0                	cmp    %edx,%eax
  801d78:	73 2e                	jae    801da8 <memmove+0x47>
		s += n;
		d += n;
  801d7a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801d7d:	89 d6                	mov    %edx,%esi
  801d7f:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d81:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d87:	75 13                	jne    801d9c <memmove+0x3b>
  801d89:	f6 c1 03             	test   $0x3,%cl
  801d8c:	75 0e                	jne    801d9c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d8e:	83 ef 04             	sub    $0x4,%edi
  801d91:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d94:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801d97:	fd                   	std    
  801d98:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d9a:	eb 09                	jmp    801da5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d9c:	83 ef 01             	sub    $0x1,%edi
  801d9f:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801da2:	fd                   	std    
  801da3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801da5:	fc                   	cld    
  801da6:	eb 1d                	jmp    801dc5 <memmove+0x64>
  801da8:	89 f2                	mov    %esi,%edx
  801daa:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dac:	f6 c2 03             	test   $0x3,%dl
  801daf:	75 0f                	jne    801dc0 <memmove+0x5f>
  801db1:	f6 c1 03             	test   $0x3,%cl
  801db4:	75 0a                	jne    801dc0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801db6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801db9:	89 c7                	mov    %eax,%edi
  801dbb:	fc                   	cld    
  801dbc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dbe:	eb 05                	jmp    801dc5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801dc0:	89 c7                	mov    %eax,%edi
  801dc2:	fc                   	cld    
  801dc3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dc5:	5e                   	pop    %esi
  801dc6:	5f                   	pop    %edi
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    

00801dc9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801dcc:	ff 75 10             	pushl  0x10(%ebp)
  801dcf:	ff 75 0c             	pushl  0xc(%ebp)
  801dd2:	ff 75 08             	pushl  0x8(%ebp)
  801dd5:	e8 87 ff ff ff       	call   801d61 <memmove>
}
  801dda:	c9                   	leave  
  801ddb:	c3                   	ret    

00801ddc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	56                   	push   %esi
  801de0:	53                   	push   %ebx
  801de1:	8b 45 08             	mov    0x8(%ebp),%eax
  801de4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de7:	89 c6                	mov    %eax,%esi
  801de9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dec:	eb 1a                	jmp    801e08 <memcmp+0x2c>
		if (*s1 != *s2)
  801dee:	0f b6 08             	movzbl (%eax),%ecx
  801df1:	0f b6 1a             	movzbl (%edx),%ebx
  801df4:	38 d9                	cmp    %bl,%cl
  801df6:	74 0a                	je     801e02 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801df8:	0f b6 c1             	movzbl %cl,%eax
  801dfb:	0f b6 db             	movzbl %bl,%ebx
  801dfe:	29 d8                	sub    %ebx,%eax
  801e00:	eb 0f                	jmp    801e11 <memcmp+0x35>
		s1++, s2++;
  801e02:	83 c0 01             	add    $0x1,%eax
  801e05:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e08:	39 f0                	cmp    %esi,%eax
  801e0a:	75 e2                	jne    801dee <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e11:	5b                   	pop    %ebx
  801e12:	5e                   	pop    %esi
  801e13:	5d                   	pop    %ebp
  801e14:	c3                   	ret    

00801e15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801e1e:	89 c2                	mov    %eax,%edx
  801e20:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e23:	eb 07                	jmp    801e2c <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e25:	38 08                	cmp    %cl,(%eax)
  801e27:	74 07                	je     801e30 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e29:	83 c0 01             	add    $0x1,%eax
  801e2c:	39 d0                	cmp    %edx,%eax
  801e2e:	72 f5                	jb     801e25 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e30:	5d                   	pop    %ebp
  801e31:	c3                   	ret    

00801e32 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	57                   	push   %edi
  801e36:	56                   	push   %esi
  801e37:	53                   	push   %ebx
  801e38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e3e:	eb 03                	jmp    801e43 <strtol+0x11>
		s++;
  801e40:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e43:	0f b6 01             	movzbl (%ecx),%eax
  801e46:	3c 09                	cmp    $0x9,%al
  801e48:	74 f6                	je     801e40 <strtol+0xe>
  801e4a:	3c 20                	cmp    $0x20,%al
  801e4c:	74 f2                	je     801e40 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e4e:	3c 2b                	cmp    $0x2b,%al
  801e50:	75 0a                	jne    801e5c <strtol+0x2a>
		s++;
  801e52:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e55:	bf 00 00 00 00       	mov    $0x0,%edi
  801e5a:	eb 10                	jmp    801e6c <strtol+0x3a>
  801e5c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e61:	3c 2d                	cmp    $0x2d,%al
  801e63:	75 07                	jne    801e6c <strtol+0x3a>
		s++, neg = 1;
  801e65:	8d 49 01             	lea    0x1(%ecx),%ecx
  801e68:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e6c:	85 db                	test   %ebx,%ebx
  801e6e:	0f 94 c0             	sete   %al
  801e71:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e77:	75 19                	jne    801e92 <strtol+0x60>
  801e79:	80 39 30             	cmpb   $0x30,(%ecx)
  801e7c:	75 14                	jne    801e92 <strtol+0x60>
  801e7e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e82:	0f 85 82 00 00 00    	jne    801f0a <strtol+0xd8>
		s += 2, base = 16;
  801e88:	83 c1 02             	add    $0x2,%ecx
  801e8b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e90:	eb 16                	jmp    801ea8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801e92:	84 c0                	test   %al,%al
  801e94:	74 12                	je     801ea8 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e96:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e9b:	80 39 30             	cmpb   $0x30,(%ecx)
  801e9e:	75 08                	jne    801ea8 <strtol+0x76>
		s++, base = 8;
  801ea0:	83 c1 01             	add    $0x1,%ecx
  801ea3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ea8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ead:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801eb0:	0f b6 11             	movzbl (%ecx),%edx
  801eb3:	8d 72 d0             	lea    -0x30(%edx),%esi
  801eb6:	89 f3                	mov    %esi,%ebx
  801eb8:	80 fb 09             	cmp    $0x9,%bl
  801ebb:	77 08                	ja     801ec5 <strtol+0x93>
			dig = *s - '0';
  801ebd:	0f be d2             	movsbl %dl,%edx
  801ec0:	83 ea 30             	sub    $0x30,%edx
  801ec3:	eb 22                	jmp    801ee7 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  801ec5:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ec8:	89 f3                	mov    %esi,%ebx
  801eca:	80 fb 19             	cmp    $0x19,%bl
  801ecd:	77 08                	ja     801ed7 <strtol+0xa5>
			dig = *s - 'a' + 10;
  801ecf:	0f be d2             	movsbl %dl,%edx
  801ed2:	83 ea 57             	sub    $0x57,%edx
  801ed5:	eb 10                	jmp    801ee7 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  801ed7:	8d 72 bf             	lea    -0x41(%edx),%esi
  801eda:	89 f3                	mov    %esi,%ebx
  801edc:	80 fb 19             	cmp    $0x19,%bl
  801edf:	77 16                	ja     801ef7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801ee1:	0f be d2             	movsbl %dl,%edx
  801ee4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ee7:	3b 55 10             	cmp    0x10(%ebp),%edx
  801eea:	7d 0f                	jge    801efb <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801eec:	83 c1 01             	add    $0x1,%ecx
  801eef:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ef3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ef5:	eb b9                	jmp    801eb0 <strtol+0x7e>
  801ef7:	89 c2                	mov    %eax,%edx
  801ef9:	eb 02                	jmp    801efd <strtol+0xcb>
  801efb:	89 c2                	mov    %eax,%edx

	if (endptr)
  801efd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f01:	74 0d                	je     801f10 <strtol+0xde>
		*endptr = (char *) s;
  801f03:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f06:	89 0e                	mov    %ecx,(%esi)
  801f08:	eb 06                	jmp    801f10 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f0a:	84 c0                	test   %al,%al
  801f0c:	75 92                	jne    801ea0 <strtol+0x6e>
  801f0e:	eb 98                	jmp    801ea8 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f10:	f7 da                	neg    %edx
  801f12:	85 ff                	test   %edi,%edi
  801f14:	0f 45 c2             	cmovne %edx,%eax
}
  801f17:	5b                   	pop    %ebx
  801f18:	5e                   	pop    %esi
  801f19:	5f                   	pop    %edi
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    

00801f1c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	56                   	push   %esi
  801f20:	53                   	push   %ebx
  801f21:	8b 75 08             	mov    0x8(%ebp),%esi
  801f24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f31:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f34:	83 ec 0c             	sub    $0xc,%esp
  801f37:	50                   	push   %eax
  801f38:	e8 cd e3 ff ff       	call   80030a <sys_ipc_recv>
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	85 c0                	test   %eax,%eax
  801f42:	79 16                	jns    801f5a <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801f44:	85 f6                	test   %esi,%esi
  801f46:	74 06                	je     801f4e <ipc_recv+0x32>
  801f48:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801f4e:	85 db                	test   %ebx,%ebx
  801f50:	74 2c                	je     801f7e <ipc_recv+0x62>
  801f52:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f58:	eb 24                	jmp    801f7e <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801f5a:	85 f6                	test   %esi,%esi
  801f5c:	74 0a                	je     801f68 <ipc_recv+0x4c>
  801f5e:	a1 08 40 80 00       	mov    0x804008,%eax
  801f63:	8b 40 74             	mov    0x74(%eax),%eax
  801f66:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801f68:	85 db                	test   %ebx,%ebx
  801f6a:	74 0a                	je     801f76 <ipc_recv+0x5a>
  801f6c:	a1 08 40 80 00       	mov    0x804008,%eax
  801f71:	8b 40 78             	mov    0x78(%eax),%eax
  801f74:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801f76:	a1 08 40 80 00       	mov    0x804008,%eax
  801f7b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f81:	5b                   	pop    %ebx
  801f82:	5e                   	pop    %esi
  801f83:	5d                   	pop    %ebp
  801f84:	c3                   	ret    

00801f85 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f85:	55                   	push   %ebp
  801f86:	89 e5                	mov    %esp,%ebp
  801f88:	57                   	push   %edi
  801f89:	56                   	push   %esi
  801f8a:	53                   	push   %ebx
  801f8b:	83 ec 0c             	sub    $0xc,%esp
  801f8e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f91:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801f97:	85 db                	test   %ebx,%ebx
  801f99:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f9e:	0f 44 d8             	cmove  %eax,%ebx
  801fa1:	eb 1c                	jmp    801fbf <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801fa3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fa6:	74 12                	je     801fba <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801fa8:	50                   	push   %eax
  801fa9:	68 a0 27 80 00       	push   $0x8027a0
  801fae:	6a 39                	push   $0x39
  801fb0:	68 bb 27 80 00       	push   $0x8027bb
  801fb5:	e8 b5 f5 ff ff       	call   80156f <_panic>
                 sys_yield();
  801fba:	e8 7c e1 ff ff       	call   80013b <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801fbf:	ff 75 14             	pushl  0x14(%ebp)
  801fc2:	53                   	push   %ebx
  801fc3:	56                   	push   %esi
  801fc4:	57                   	push   %edi
  801fc5:	e8 1d e3 ff ff       	call   8002e7 <sys_ipc_try_send>
  801fca:	83 c4 10             	add    $0x10,%esp
  801fcd:	85 c0                	test   %eax,%eax
  801fcf:	78 d2                	js     801fa3 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801fd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fdf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fe4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fe7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fed:	8b 52 50             	mov    0x50(%edx),%edx
  801ff0:	39 ca                	cmp    %ecx,%edx
  801ff2:	75 0d                	jne    802001 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ff4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ff7:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ffc:	8b 40 08             	mov    0x8(%eax),%eax
  801fff:	eb 0e                	jmp    80200f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802001:	83 c0 01             	add    $0x1,%eax
  802004:	3d 00 04 00 00       	cmp    $0x400,%eax
  802009:	75 d9                	jne    801fe4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80200b:	66 b8 00 00          	mov    $0x0,%ax
}
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    

00802011 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802011:	55                   	push   %ebp
  802012:	89 e5                	mov    %esp,%ebp
  802014:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802017:	89 d0                	mov    %edx,%eax
  802019:	c1 e8 16             	shr    $0x16,%eax
  80201c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802023:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802028:	f6 c1 01             	test   $0x1,%cl
  80202b:	74 1d                	je     80204a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80202d:	c1 ea 0c             	shr    $0xc,%edx
  802030:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802037:	f6 c2 01             	test   $0x1,%dl
  80203a:	74 0e                	je     80204a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80203c:	c1 ea 0c             	shr    $0xc,%edx
  80203f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802046:	ef 
  802047:	0f b7 c0             	movzwl %ax,%eax
}
  80204a:	5d                   	pop    %ebp
  80204b:	c3                   	ret    
  80204c:	66 90                	xchg   %ax,%ax
  80204e:	66 90                	xchg   %ax,%ax

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
