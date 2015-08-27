
obj/user/faultevilhandler.debug:     file format elf32-i386


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
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
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
  800082:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8000b1:	e8 2f 05 00 00       	call   8005e5 <close_all>
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
	// return value.
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
	// return value.
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
	// return value.
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
  80012a:	68 4a 23 80 00       	push   $0x80234a
  80012f:	6a 22                	push   $0x22
  800131:	68 67 23 80 00       	push   $0x802367
  800136:	e8 5b 14 00 00       	call   801596 <_panic>

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
	// return value.
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
	// return value.
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
	// return value.
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
  8001ab:	68 4a 23 80 00       	push   $0x80234a
  8001b0:	6a 22                	push   $0x22
  8001b2:	68 67 23 80 00       	push   $0x802367
  8001b7:	e8 da 13 00 00       	call   801596 <_panic>

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
	// return value.
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
  8001ed:	68 4a 23 80 00       	push   $0x80234a
  8001f2:	6a 22                	push   $0x22
  8001f4:	68 67 23 80 00       	push   $0x802367
  8001f9:	e8 98 13 00 00       	call   801596 <_panic>

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
	// return value.
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
  80022f:	68 4a 23 80 00       	push   $0x80234a
  800234:	6a 22                	push   $0x22
  800236:	68 67 23 80 00       	push   $0x802367
  80023b:	e8 56 13 00 00       	call   801596 <_panic>

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
	// return value.
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
  800271:	68 4a 23 80 00       	push   $0x80234a
  800276:	6a 22                	push   $0x22
  800278:	68 67 23 80 00       	push   $0x802367
  80027d:	e8 14 13 00 00       	call   801596 <_panic>
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
	// return value.
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
  8002b3:	68 4a 23 80 00       	push   $0x80234a
  8002b8:	6a 22                	push   $0x22
  8002ba:	68 67 23 80 00       	push   $0x802367
  8002bf:	e8 d2 12 00 00       	call   801596 <_panic>

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
	// return value.
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
  8002f5:	68 4a 23 80 00       	push   $0x80234a
  8002fa:	6a 22                	push   $0x22
  8002fc:	68 67 23 80 00       	push   $0x802367
  800301:	e8 90 12 00 00       	call   801596 <_panic>

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
	// return value.
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
	// return value.
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
  800359:	68 4a 23 80 00       	push   $0x80234a
  80035e:	6a 22                	push   $0x22
  800360:	68 67 23 80 00       	push   $0x802367
  800365:	e8 2c 12 00 00       	call   801596 <_panic>

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

00800372 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	57                   	push   %edi
  800376:	56                   	push   %esi
  800377:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800382:	89 d1                	mov    %edx,%ecx
  800384:	89 d3                	mov    %edx,%ebx
  800386:	89 d7                	mov    %edx,%edi
  800388:	89 d6                	mov    %edx,%esi
  80038a:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	57                   	push   %edi
  800395:	56                   	push   %esi
  800396:	53                   	push   %ebx
  800397:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80039a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039f:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a7:	89 cb                	mov    %ecx,%ebx
  8003a9:	89 cf                	mov    %ecx,%edi
  8003ab:	89 ce                	mov    %ecx,%esi
  8003ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003af:	85 c0                	test   %eax,%eax
  8003b1:	7e 17                	jle    8003ca <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	50                   	push   %eax
  8003b7:	6a 0f                	push   $0xf
  8003b9:	68 4a 23 80 00       	push   $0x80234a
  8003be:	6a 22                	push   $0x22
  8003c0:	68 67 23 80 00       	push   $0x802367
  8003c5:	e8 cc 11 00 00       	call   801596 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <sys_recv>:

int
sys_recv(void *addr)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	57                   	push   %edi
  8003d6:	56                   	push   %esi
  8003d7:	53                   	push   %ebx
  8003d8:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8003db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e0:	b8 10 00 00 00       	mov    $0x10,%eax
  8003e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e8:	89 cb                	mov    %ecx,%ebx
  8003ea:	89 cf                	mov    %ecx,%edi
  8003ec:	89 ce                	mov    %ecx,%esi
  8003ee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003f0:	85 c0                	test   %eax,%eax
  8003f2:	7e 17                	jle    80040b <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003f4:	83 ec 0c             	sub    $0xc,%esp
  8003f7:	50                   	push   %eax
  8003f8:	6a 10                	push   $0x10
  8003fa:	68 4a 23 80 00       	push   $0x80234a
  8003ff:	6a 22                	push   $0x22
  800401:	68 67 23 80 00       	push   $0x802367
  800406:	e8 8b 11 00 00       	call   801596 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  80040b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80040e:	5b                   	pop    %ebx
  80040f:	5e                   	pop    %esi
  800410:	5f                   	pop    %edi
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800416:	8b 45 08             	mov    0x8(%ebp),%eax
  800419:	05 00 00 00 30       	add    $0x30000000,%eax
  80041e:	c1 e8 0c             	shr    $0xc,%eax
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800426:	8b 45 08             	mov    0x8(%ebp),%eax
  800429:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80042e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800433:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800438:	5d                   	pop    %ebp
  800439:	c3                   	ret    

0080043a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800440:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800445:	89 c2                	mov    %eax,%edx
  800447:	c1 ea 16             	shr    $0x16,%edx
  80044a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800451:	f6 c2 01             	test   $0x1,%dl
  800454:	74 11                	je     800467 <fd_alloc+0x2d>
  800456:	89 c2                	mov    %eax,%edx
  800458:	c1 ea 0c             	shr    $0xc,%edx
  80045b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800462:	f6 c2 01             	test   $0x1,%dl
  800465:	75 09                	jne    800470 <fd_alloc+0x36>
			*fd_store = fd;
  800467:	89 01                	mov    %eax,(%ecx)
			return 0;
  800469:	b8 00 00 00 00       	mov    $0x0,%eax
  80046e:	eb 17                	jmp    800487 <fd_alloc+0x4d>
  800470:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800475:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80047a:	75 c9                	jne    800445 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80047c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800482:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800487:	5d                   	pop    %ebp
  800488:	c3                   	ret    

00800489 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80048f:	83 f8 1f             	cmp    $0x1f,%eax
  800492:	77 36                	ja     8004ca <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800494:	c1 e0 0c             	shl    $0xc,%eax
  800497:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80049c:	89 c2                	mov    %eax,%edx
  80049e:	c1 ea 16             	shr    $0x16,%edx
  8004a1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004a8:	f6 c2 01             	test   $0x1,%dl
  8004ab:	74 24                	je     8004d1 <fd_lookup+0x48>
  8004ad:	89 c2                	mov    %eax,%edx
  8004af:	c1 ea 0c             	shr    $0xc,%edx
  8004b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004b9:	f6 c2 01             	test   $0x1,%dl
  8004bc:	74 1a                	je     8004d8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c1:	89 02                	mov    %eax,(%edx)
	return 0;
  8004c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c8:	eb 13                	jmp    8004dd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004cf:	eb 0c                	jmp    8004dd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004d6:	eb 05                	jmp    8004dd <fd_lookup+0x54>
  8004d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004dd:	5d                   	pop    %ebp
  8004de:	c3                   	ret    

008004df <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004df:	55                   	push   %ebp
  8004e0:	89 e5                	mov    %esp,%ebp
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8004e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ed:	eb 13                	jmp    800502 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8004ef:	39 08                	cmp    %ecx,(%eax)
  8004f1:	75 0c                	jne    8004ff <dev_lookup+0x20>
			*dev = devtab[i];
  8004f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004f6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fd:	eb 36                	jmp    800535 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004ff:	83 c2 01             	add    $0x1,%edx
  800502:	8b 04 95 f4 23 80 00 	mov    0x8023f4(,%edx,4),%eax
  800509:	85 c0                	test   %eax,%eax
  80050b:	75 e2                	jne    8004ef <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80050d:	a1 08 40 80 00       	mov    0x804008,%eax
  800512:	8b 40 48             	mov    0x48(%eax),%eax
  800515:	83 ec 04             	sub    $0x4,%esp
  800518:	51                   	push   %ecx
  800519:	50                   	push   %eax
  80051a:	68 78 23 80 00       	push   $0x802378
  80051f:	e8 4b 11 00 00       	call   80166f <cprintf>
	*dev = 0;
  800524:	8b 45 0c             	mov    0xc(%ebp),%eax
  800527:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80052d:	83 c4 10             	add    $0x10,%esp
  800530:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	56                   	push   %esi
  80053b:	53                   	push   %ebx
  80053c:	83 ec 10             	sub    $0x10,%esp
  80053f:	8b 75 08             	mov    0x8(%ebp),%esi
  800542:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800548:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800549:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80054f:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800552:	50                   	push   %eax
  800553:	e8 31 ff ff ff       	call   800489 <fd_lookup>
  800558:	83 c4 08             	add    $0x8,%esp
  80055b:	85 c0                	test   %eax,%eax
  80055d:	78 05                	js     800564 <fd_close+0x2d>
	    || fd != fd2)
  80055f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800562:	74 0c                	je     800570 <fd_close+0x39>
		return (must_exist ? r : 0);
  800564:	84 db                	test   %bl,%bl
  800566:	ba 00 00 00 00       	mov    $0x0,%edx
  80056b:	0f 44 c2             	cmove  %edx,%eax
  80056e:	eb 41                	jmp    8005b1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800576:	50                   	push   %eax
  800577:	ff 36                	pushl  (%esi)
  800579:	e8 61 ff ff ff       	call   8004df <dev_lookup>
  80057e:	89 c3                	mov    %eax,%ebx
  800580:	83 c4 10             	add    $0x10,%esp
  800583:	85 c0                	test   %eax,%eax
  800585:	78 1a                	js     8005a1 <fd_close+0x6a>
		if (dev->dev_close)
  800587:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80058a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80058d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800592:	85 c0                	test   %eax,%eax
  800594:	74 0b                	je     8005a1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800596:	83 ec 0c             	sub    $0xc,%esp
  800599:	56                   	push   %esi
  80059a:	ff d0                	call   *%eax
  80059c:	89 c3                	mov    %eax,%ebx
  80059e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	56                   	push   %esi
  8005a5:	6a 00                	push   $0x0
  8005a7:	e8 5a fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	89 d8                	mov    %ebx,%eax
}
  8005b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005b4:	5b                   	pop    %ebx
  8005b5:	5e                   	pop    %esi
  8005b6:	5d                   	pop    %ebp
  8005b7:	c3                   	ret    

008005b8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005b8:	55                   	push   %ebp
  8005b9:	89 e5                	mov    %esp,%ebp
  8005bb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 08             	pushl  0x8(%ebp)
  8005c5:	e8 bf fe ff ff       	call   800489 <fd_lookup>
  8005ca:	89 c2                	mov    %eax,%edx
  8005cc:	83 c4 08             	add    $0x8,%esp
  8005cf:	85 d2                	test   %edx,%edx
  8005d1:	78 10                	js     8005e3 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	6a 01                	push   $0x1
  8005d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8005db:	e8 57 ff ff ff       	call   800537 <fd_close>
  8005e0:	83 c4 10             	add    $0x10,%esp
}
  8005e3:	c9                   	leave  
  8005e4:	c3                   	ret    

008005e5 <close_all>:

void
close_all(void)
{
  8005e5:	55                   	push   %ebp
  8005e6:	89 e5                	mov    %esp,%ebp
  8005e8:	53                   	push   %ebx
  8005e9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005f1:	83 ec 0c             	sub    $0xc,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	e8 be ff ff ff       	call   8005b8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005fa:	83 c3 01             	add    $0x1,%ebx
  8005fd:	83 c4 10             	add    $0x10,%esp
  800600:	83 fb 20             	cmp    $0x20,%ebx
  800603:	75 ec                	jne    8005f1 <close_all+0xc>
		close(i);
}
  800605:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800608:	c9                   	leave  
  800609:	c3                   	ret    

0080060a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80060a:	55                   	push   %ebp
  80060b:	89 e5                	mov    %esp,%ebp
  80060d:	57                   	push   %edi
  80060e:	56                   	push   %esi
  80060f:	53                   	push   %ebx
  800610:	83 ec 2c             	sub    $0x2c,%esp
  800613:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800616:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800619:	50                   	push   %eax
  80061a:	ff 75 08             	pushl  0x8(%ebp)
  80061d:	e8 67 fe ff ff       	call   800489 <fd_lookup>
  800622:	89 c2                	mov    %eax,%edx
  800624:	83 c4 08             	add    $0x8,%esp
  800627:	85 d2                	test   %edx,%edx
  800629:	0f 88 c1 00 00 00    	js     8006f0 <dup+0xe6>
		return r;
	close(newfdnum);
  80062f:	83 ec 0c             	sub    $0xc,%esp
  800632:	56                   	push   %esi
  800633:	e8 80 ff ff ff       	call   8005b8 <close>

	newfd = INDEX2FD(newfdnum);
  800638:	89 f3                	mov    %esi,%ebx
  80063a:	c1 e3 0c             	shl    $0xc,%ebx
  80063d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800643:	83 c4 04             	add    $0x4,%esp
  800646:	ff 75 e4             	pushl  -0x1c(%ebp)
  800649:	e8 d5 fd ff ff       	call   800423 <fd2data>
  80064e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800650:	89 1c 24             	mov    %ebx,(%esp)
  800653:	e8 cb fd ff ff       	call   800423 <fd2data>
  800658:	83 c4 10             	add    $0x10,%esp
  80065b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80065e:	89 f8                	mov    %edi,%eax
  800660:	c1 e8 16             	shr    $0x16,%eax
  800663:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80066a:	a8 01                	test   $0x1,%al
  80066c:	74 37                	je     8006a5 <dup+0x9b>
  80066e:	89 f8                	mov    %edi,%eax
  800670:	c1 e8 0c             	shr    $0xc,%eax
  800673:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80067a:	f6 c2 01             	test   $0x1,%dl
  80067d:	74 26                	je     8006a5 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80067f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800686:	83 ec 0c             	sub    $0xc,%esp
  800689:	25 07 0e 00 00       	and    $0xe07,%eax
  80068e:	50                   	push   %eax
  80068f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800692:	6a 00                	push   $0x0
  800694:	57                   	push   %edi
  800695:	6a 00                	push   $0x0
  800697:	e8 28 fb ff ff       	call   8001c4 <sys_page_map>
  80069c:	89 c7                	mov    %eax,%edi
  80069e:	83 c4 20             	add    $0x20,%esp
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	78 2e                	js     8006d3 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006a8:	89 d0                	mov    %edx,%eax
  8006aa:	c1 e8 0c             	shr    $0xc,%eax
  8006ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8006bc:	50                   	push   %eax
  8006bd:	53                   	push   %ebx
  8006be:	6a 00                	push   $0x0
  8006c0:	52                   	push   %edx
  8006c1:	6a 00                	push   $0x0
  8006c3:	e8 fc fa ff ff       	call   8001c4 <sys_page_map>
  8006c8:	89 c7                	mov    %eax,%edi
  8006ca:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006cd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006cf:	85 ff                	test   %edi,%edi
  8006d1:	79 1d                	jns    8006f0 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	6a 00                	push   $0x0
  8006d9:	e8 28 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006de:	83 c4 08             	add    $0x8,%esp
  8006e1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006e4:	6a 00                	push   $0x0
  8006e6:	e8 1b fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	89 f8                	mov    %edi,%eax
}
  8006f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f3:	5b                   	pop    %ebx
  8006f4:	5e                   	pop    %esi
  8006f5:	5f                   	pop    %edi
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	53                   	push   %ebx
  8006fc:	83 ec 14             	sub    $0x14,%esp
  8006ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800702:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800705:	50                   	push   %eax
  800706:	53                   	push   %ebx
  800707:	e8 7d fd ff ff       	call   800489 <fd_lookup>
  80070c:	83 c4 08             	add    $0x8,%esp
  80070f:	89 c2                	mov    %eax,%edx
  800711:	85 c0                	test   %eax,%eax
  800713:	78 6d                	js     800782 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071b:	50                   	push   %eax
  80071c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071f:	ff 30                	pushl  (%eax)
  800721:	e8 b9 fd ff ff       	call   8004df <dev_lookup>
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	85 c0                	test   %eax,%eax
  80072b:	78 4c                	js     800779 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80072d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800730:	8b 42 08             	mov    0x8(%edx),%eax
  800733:	83 e0 03             	and    $0x3,%eax
  800736:	83 f8 01             	cmp    $0x1,%eax
  800739:	75 21                	jne    80075c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80073b:	a1 08 40 80 00       	mov    0x804008,%eax
  800740:	8b 40 48             	mov    0x48(%eax),%eax
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	53                   	push   %ebx
  800747:	50                   	push   %eax
  800748:	68 b9 23 80 00       	push   $0x8023b9
  80074d:	e8 1d 0f 00 00       	call   80166f <cprintf>
		return -E_INVAL;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075a:	eb 26                	jmp    800782 <read+0x8a>
	}
	if (!dev->dev_read)
  80075c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075f:	8b 40 08             	mov    0x8(%eax),%eax
  800762:	85 c0                	test   %eax,%eax
  800764:	74 17                	je     80077d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	52                   	push   %edx
  800770:	ff d0                	call   *%eax
  800772:	89 c2                	mov    %eax,%edx
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb 09                	jmp    800782 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800779:	89 c2                	mov    %eax,%edx
  80077b:	eb 05                	jmp    800782 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80077d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800782:	89 d0                	mov    %edx,%eax
  800784:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	57                   	push   %edi
  80078d:	56                   	push   %esi
  80078e:	53                   	push   %ebx
  80078f:	83 ec 0c             	sub    $0xc,%esp
  800792:	8b 7d 08             	mov    0x8(%ebp),%edi
  800795:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800798:	bb 00 00 00 00       	mov    $0x0,%ebx
  80079d:	eb 21                	jmp    8007c0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80079f:	83 ec 04             	sub    $0x4,%esp
  8007a2:	89 f0                	mov    %esi,%eax
  8007a4:	29 d8                	sub    %ebx,%eax
  8007a6:	50                   	push   %eax
  8007a7:	89 d8                	mov    %ebx,%eax
  8007a9:	03 45 0c             	add    0xc(%ebp),%eax
  8007ac:	50                   	push   %eax
  8007ad:	57                   	push   %edi
  8007ae:	e8 45 ff ff ff       	call   8006f8 <read>
		if (m < 0)
  8007b3:	83 c4 10             	add    $0x10,%esp
  8007b6:	85 c0                	test   %eax,%eax
  8007b8:	78 0c                	js     8007c6 <readn+0x3d>
			return m;
		if (m == 0)
  8007ba:	85 c0                	test   %eax,%eax
  8007bc:	74 06                	je     8007c4 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007be:	01 c3                	add    %eax,%ebx
  8007c0:	39 f3                	cmp    %esi,%ebx
  8007c2:	72 db                	jb     80079f <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8007c4:	89 d8                	mov    %ebx,%eax
}
  8007c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007c9:	5b                   	pop    %ebx
  8007ca:	5e                   	pop    %esi
  8007cb:	5f                   	pop    %edi
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	53                   	push   %ebx
  8007d2:	83 ec 14             	sub    $0x14,%esp
  8007d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007db:	50                   	push   %eax
  8007dc:	53                   	push   %ebx
  8007dd:	e8 a7 fc ff ff       	call   800489 <fd_lookup>
  8007e2:	83 c4 08             	add    $0x8,%esp
  8007e5:	89 c2                	mov    %eax,%edx
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 68                	js     800853 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f1:	50                   	push   %eax
  8007f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f5:	ff 30                	pushl  (%eax)
  8007f7:	e8 e3 fc ff ff       	call   8004df <dev_lookup>
  8007fc:	83 c4 10             	add    $0x10,%esp
  8007ff:	85 c0                	test   %eax,%eax
  800801:	78 47                	js     80084a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800803:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800806:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080a:	75 21                	jne    80082d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80080c:	a1 08 40 80 00       	mov    0x804008,%eax
  800811:	8b 40 48             	mov    0x48(%eax),%eax
  800814:	83 ec 04             	sub    $0x4,%esp
  800817:	53                   	push   %ebx
  800818:	50                   	push   %eax
  800819:	68 d5 23 80 00       	push   $0x8023d5
  80081e:	e8 4c 0e 00 00       	call   80166f <cprintf>
		return -E_INVAL;
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80082b:	eb 26                	jmp    800853 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80082d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800830:	8b 52 0c             	mov    0xc(%edx),%edx
  800833:	85 d2                	test   %edx,%edx
  800835:	74 17                	je     80084e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800837:	83 ec 04             	sub    $0x4,%esp
  80083a:	ff 75 10             	pushl  0x10(%ebp)
  80083d:	ff 75 0c             	pushl  0xc(%ebp)
  800840:	50                   	push   %eax
  800841:	ff d2                	call   *%edx
  800843:	89 c2                	mov    %eax,%edx
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	eb 09                	jmp    800853 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084a:	89 c2                	mov    %eax,%edx
  80084c:	eb 05                	jmp    800853 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80084e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800853:	89 d0                	mov    %edx,%eax
  800855:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <seek>:

int
seek(int fdnum, off_t offset)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800860:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800863:	50                   	push   %eax
  800864:	ff 75 08             	pushl  0x8(%ebp)
  800867:	e8 1d fc ff ff       	call   800489 <fd_lookup>
  80086c:	83 c4 08             	add    $0x8,%esp
  80086f:	85 c0                	test   %eax,%eax
  800871:	78 0e                	js     800881 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800873:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
  800879:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	53                   	push   %ebx
  800887:	83 ec 14             	sub    $0x14,%esp
  80088a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800890:	50                   	push   %eax
  800891:	53                   	push   %ebx
  800892:	e8 f2 fb ff ff       	call   800489 <fd_lookup>
  800897:	83 c4 08             	add    $0x8,%esp
  80089a:	89 c2                	mov    %eax,%edx
  80089c:	85 c0                	test   %eax,%eax
  80089e:	78 65                	js     800905 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a6:	50                   	push   %eax
  8008a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008aa:	ff 30                	pushl  (%eax)
  8008ac:	e8 2e fc ff ff       	call   8004df <dev_lookup>
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	85 c0                	test   %eax,%eax
  8008b6:	78 44                	js     8008fc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008bf:	75 21                	jne    8008e2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008c1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008c6:	8b 40 48             	mov    0x48(%eax),%eax
  8008c9:	83 ec 04             	sub    $0x4,%esp
  8008cc:	53                   	push   %ebx
  8008cd:	50                   	push   %eax
  8008ce:	68 98 23 80 00       	push   $0x802398
  8008d3:	e8 97 0d 00 00       	call   80166f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008d8:	83 c4 10             	add    $0x10,%esp
  8008db:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008e0:	eb 23                	jmp    800905 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008e5:	8b 52 18             	mov    0x18(%edx),%edx
  8008e8:	85 d2                	test   %edx,%edx
  8008ea:	74 14                	je     800900 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008ec:	83 ec 08             	sub    $0x8,%esp
  8008ef:	ff 75 0c             	pushl  0xc(%ebp)
  8008f2:	50                   	push   %eax
  8008f3:	ff d2                	call   *%edx
  8008f5:	89 c2                	mov    %eax,%edx
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	eb 09                	jmp    800905 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008fc:	89 c2                	mov    %eax,%edx
  8008fe:	eb 05                	jmp    800905 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800900:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800905:	89 d0                	mov    %edx,%eax
  800907:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    

0080090c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	83 ec 14             	sub    $0x14,%esp
  800913:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800916:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800919:	50                   	push   %eax
  80091a:	ff 75 08             	pushl  0x8(%ebp)
  80091d:	e8 67 fb ff ff       	call   800489 <fd_lookup>
  800922:	83 c4 08             	add    $0x8,%esp
  800925:	89 c2                	mov    %eax,%edx
  800927:	85 c0                	test   %eax,%eax
  800929:	78 58                	js     800983 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800931:	50                   	push   %eax
  800932:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800935:	ff 30                	pushl  (%eax)
  800937:	e8 a3 fb ff ff       	call   8004df <dev_lookup>
  80093c:	83 c4 10             	add    $0x10,%esp
  80093f:	85 c0                	test   %eax,%eax
  800941:	78 37                	js     80097a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800943:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800946:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80094a:	74 32                	je     80097e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80094c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80094f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800956:	00 00 00 
	stat->st_isdir = 0;
  800959:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800960:	00 00 00 
	stat->st_dev = dev;
  800963:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800969:	83 ec 08             	sub    $0x8,%esp
  80096c:	53                   	push   %ebx
  80096d:	ff 75 f0             	pushl  -0x10(%ebp)
  800970:	ff 50 14             	call   *0x14(%eax)
  800973:	89 c2                	mov    %eax,%edx
  800975:	83 c4 10             	add    $0x10,%esp
  800978:	eb 09                	jmp    800983 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80097a:	89 c2                	mov    %eax,%edx
  80097c:	eb 05                	jmp    800983 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80097e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800983:	89 d0                	mov    %edx,%eax
  800985:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80098f:	83 ec 08             	sub    $0x8,%esp
  800992:	6a 00                	push   $0x0
  800994:	ff 75 08             	pushl  0x8(%ebp)
  800997:	e8 09 02 00 00       	call   800ba5 <open>
  80099c:	89 c3                	mov    %eax,%ebx
  80099e:	83 c4 10             	add    $0x10,%esp
  8009a1:	85 db                	test   %ebx,%ebx
  8009a3:	78 1b                	js     8009c0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8009a5:	83 ec 08             	sub    $0x8,%esp
  8009a8:	ff 75 0c             	pushl  0xc(%ebp)
  8009ab:	53                   	push   %ebx
  8009ac:	e8 5b ff ff ff       	call   80090c <fstat>
  8009b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8009b3:	89 1c 24             	mov    %ebx,(%esp)
  8009b6:	e8 fd fb ff ff       	call   8005b8 <close>
	return r;
  8009bb:	83 c4 10             	add    $0x10,%esp
  8009be:	89 f0                	mov    %esi,%eax
}
  8009c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009c3:	5b                   	pop    %ebx
  8009c4:	5e                   	pop    %esi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	56                   	push   %esi
  8009cb:	53                   	push   %ebx
  8009cc:	89 c6                	mov    %eax,%esi
  8009ce:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009d0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009d7:	75 12                	jne    8009eb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009d9:	83 ec 0c             	sub    $0xc,%esp
  8009dc:	6a 01                	push   $0x1
  8009de:	e8 1d 16 00 00       	call   802000 <ipc_find_env>
  8009e3:	a3 00 40 80 00       	mov    %eax,0x804000
  8009e8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009eb:	6a 07                	push   $0x7
  8009ed:	68 00 50 80 00       	push   $0x805000
  8009f2:	56                   	push   %esi
  8009f3:	ff 35 00 40 80 00    	pushl  0x804000
  8009f9:	e8 ae 15 00 00       	call   801fac <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009fe:	83 c4 0c             	add    $0xc,%esp
  800a01:	6a 00                	push   $0x0
  800a03:	53                   	push   %ebx
  800a04:	6a 00                	push   $0x0
  800a06:	e8 38 15 00 00       	call   801f43 <ipc_recv>
}
  800a0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a26:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a30:	b8 02 00 00 00       	mov    $0x2,%eax
  800a35:	e8 8d ff ff ff       	call   8009c7 <fsipc>
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	8b 40 0c             	mov    0xc(%eax),%eax
  800a48:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	b8 06 00 00 00       	mov    $0x6,%eax
  800a57:	e8 6b ff ff ff       	call   8009c7 <fsipc>
}
  800a5c:	c9                   	leave  
  800a5d:	c3                   	ret    

00800a5e <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	53                   	push   %ebx
  800a62:	83 ec 04             	sub    $0x4,%esp
  800a65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a73:	ba 00 00 00 00       	mov    $0x0,%edx
  800a78:	b8 05 00 00 00       	mov    $0x5,%eax
  800a7d:	e8 45 ff ff ff       	call   8009c7 <fsipc>
  800a82:	89 c2                	mov    %eax,%edx
  800a84:	85 d2                	test   %edx,%edx
  800a86:	78 2c                	js     800ab4 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a88:	83 ec 08             	sub    $0x8,%esp
  800a8b:	68 00 50 80 00       	push   $0x805000
  800a90:	53                   	push   %ebx
  800a91:	e8 60 11 00 00       	call   801bf6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a96:	a1 80 50 80 00       	mov    0x805080,%eax
  800a9b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800aa1:	a1 84 50 80 00       	mov    0x805084,%eax
  800aa6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800aac:	83 c4 10             	add    $0x10,%esp
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    

00800ab9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	8b 40 0c             	mov    0xc(%eax),%eax
  800acb:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800ad0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800ad3:	eb 3d                	jmp    800b12 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800ad5:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800adb:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800ae0:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800ae3:	83 ec 04             	sub    $0x4,%esp
  800ae6:	57                   	push   %edi
  800ae7:	53                   	push   %ebx
  800ae8:	68 08 50 80 00       	push   $0x805008
  800aed:	e8 96 12 00 00       	call   801d88 <memmove>
                fsipcbuf.write.req_n = tmp; 
  800af2:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 04 00 00 00       	mov    $0x4,%eax
  800b02:	e8 c0 fe ff ff       	call   8009c7 <fsipc>
  800b07:	83 c4 10             	add    $0x10,%esp
  800b0a:	85 c0                	test   %eax,%eax
  800b0c:	78 0d                	js     800b1b <devfile_write+0x62>
		        return r;
                n -= tmp;
  800b0e:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800b10:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800b12:	85 f6                	test   %esi,%esi
  800b14:	75 bf                	jne    800ad5 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800b16:	89 d8                	mov    %ebx,%eax
  800b18:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
  800b28:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2e:	8b 40 0c             	mov    0xc(%eax),%eax
  800b31:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b36:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b41:	b8 03 00 00 00       	mov    $0x3,%eax
  800b46:	e8 7c fe ff ff       	call   8009c7 <fsipc>
  800b4b:	89 c3                	mov    %eax,%ebx
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	78 4b                	js     800b9c <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b51:	39 c6                	cmp    %eax,%esi
  800b53:	73 16                	jae    800b6b <devfile_read+0x48>
  800b55:	68 08 24 80 00       	push   $0x802408
  800b5a:	68 0f 24 80 00       	push   $0x80240f
  800b5f:	6a 7c                	push   $0x7c
  800b61:	68 24 24 80 00       	push   $0x802424
  800b66:	e8 2b 0a 00 00       	call   801596 <_panic>
	assert(r <= PGSIZE);
  800b6b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b70:	7e 16                	jle    800b88 <devfile_read+0x65>
  800b72:	68 2f 24 80 00       	push   $0x80242f
  800b77:	68 0f 24 80 00       	push   $0x80240f
  800b7c:	6a 7d                	push   $0x7d
  800b7e:	68 24 24 80 00       	push   $0x802424
  800b83:	e8 0e 0a 00 00       	call   801596 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b88:	83 ec 04             	sub    $0x4,%esp
  800b8b:	50                   	push   %eax
  800b8c:	68 00 50 80 00       	push   $0x805000
  800b91:	ff 75 0c             	pushl  0xc(%ebp)
  800b94:	e8 ef 11 00 00       	call   801d88 <memmove>
	return r;
  800b99:	83 c4 10             	add    $0x10,%esp
}
  800b9c:	89 d8                	mov    %ebx,%eax
  800b9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 20             	sub    $0x20,%esp
  800bac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800baf:	53                   	push   %ebx
  800bb0:	e8 08 10 00 00       	call   801bbd <strlen>
  800bb5:	83 c4 10             	add    $0x10,%esp
  800bb8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bbd:	7f 67                	jg     800c26 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bbf:	83 ec 0c             	sub    $0xc,%esp
  800bc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bc5:	50                   	push   %eax
  800bc6:	e8 6f f8 ff ff       	call   80043a <fd_alloc>
  800bcb:	83 c4 10             	add    $0x10,%esp
		return r;
  800bce:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	78 57                	js     800c2b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bd4:	83 ec 08             	sub    $0x8,%esp
  800bd7:	53                   	push   %ebx
  800bd8:	68 00 50 80 00       	push   $0x805000
  800bdd:	e8 14 10 00 00       	call   801bf6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bed:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf2:	e8 d0 fd ff ff       	call   8009c7 <fsipc>
  800bf7:	89 c3                	mov    %eax,%ebx
  800bf9:	83 c4 10             	add    $0x10,%esp
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	79 14                	jns    800c14 <open+0x6f>
		fd_close(fd, 0);
  800c00:	83 ec 08             	sub    $0x8,%esp
  800c03:	6a 00                	push   $0x0
  800c05:	ff 75 f4             	pushl  -0xc(%ebp)
  800c08:	e8 2a f9 ff ff       	call   800537 <fd_close>
		return r;
  800c0d:	83 c4 10             	add    $0x10,%esp
  800c10:	89 da                	mov    %ebx,%edx
  800c12:	eb 17                	jmp    800c2b <open+0x86>
	}

	return fd2num(fd);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	ff 75 f4             	pushl  -0xc(%ebp)
  800c1a:	e8 f4 f7 ff ff       	call   800413 <fd2num>
  800c1f:	89 c2                	mov    %eax,%edx
  800c21:	83 c4 10             	add    $0x10,%esp
  800c24:	eb 05                	jmp    800c2b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c26:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c2b:	89 d0                	mov    %edx,%eax
  800c2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c30:	c9                   	leave  
  800c31:	c3                   	ret    

00800c32 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c38:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c42:	e8 80 fd ff ff       	call   8009c7 <fsipc>
}
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    

00800c49 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c4f:	68 3b 24 80 00       	push   $0x80243b
  800c54:	ff 75 0c             	pushl  0xc(%ebp)
  800c57:	e8 9a 0f 00 00       	call   801bf6 <strcpy>
	return 0;
}
  800c5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	53                   	push   %ebx
  800c67:	83 ec 10             	sub    $0x10,%esp
  800c6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c6d:	53                   	push   %ebx
  800c6e:	e8 c5 13 00 00       	call   802038 <pageref>
  800c73:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c76:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c7b:	83 f8 01             	cmp    $0x1,%eax
  800c7e:	75 10                	jne    800c90 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c80:	83 ec 0c             	sub    $0xc,%esp
  800c83:	ff 73 0c             	pushl  0xc(%ebx)
  800c86:	e8 ca 02 00 00       	call   800f55 <nsipc_close>
  800c8b:	89 c2                	mov    %eax,%edx
  800c8d:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c90:	89 d0                	mov    %edx,%eax
  800c92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c9d:	6a 00                	push   $0x0
  800c9f:	ff 75 10             	pushl  0x10(%ebp)
  800ca2:	ff 75 0c             	pushl  0xc(%ebp)
  800ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca8:	ff 70 0c             	pushl  0xc(%eax)
  800cab:	e8 82 03 00 00       	call   801032 <nsipc_send>
}
  800cb0:	c9                   	leave  
  800cb1:	c3                   	ret    

00800cb2 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800cb8:	6a 00                	push   $0x0
  800cba:	ff 75 10             	pushl  0x10(%ebp)
  800cbd:	ff 75 0c             	pushl  0xc(%ebp)
  800cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc3:	ff 70 0c             	pushl  0xc(%eax)
  800cc6:	e8 fb 02 00 00       	call   800fc6 <nsipc_recv>
}
  800ccb:	c9                   	leave  
  800ccc:	c3                   	ret    

00800ccd <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800cd3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800cd6:	52                   	push   %edx
  800cd7:	50                   	push   %eax
  800cd8:	e8 ac f7 ff ff       	call   800489 <fd_lookup>
  800cdd:	83 c4 10             	add    $0x10,%esp
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	78 17                	js     800cfb <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce7:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800ced:	39 08                	cmp    %ecx,(%eax)
  800cef:	75 05                	jne    800cf6 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800cf1:	8b 40 0c             	mov    0xc(%eax),%eax
  800cf4:	eb 05                	jmp    800cfb <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800cf6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800cfb:	c9                   	leave  
  800cfc:	c3                   	ret    

00800cfd <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
  800d02:	83 ec 1c             	sub    $0x1c,%esp
  800d05:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800d07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d0a:	50                   	push   %eax
  800d0b:	e8 2a f7 ff ff       	call   80043a <fd_alloc>
  800d10:	89 c3                	mov    %eax,%ebx
  800d12:	83 c4 10             	add    $0x10,%esp
  800d15:	85 c0                	test   %eax,%eax
  800d17:	78 1b                	js     800d34 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800d19:	83 ec 04             	sub    $0x4,%esp
  800d1c:	68 07 04 00 00       	push   $0x407
  800d21:	ff 75 f4             	pushl  -0xc(%ebp)
  800d24:	6a 00                	push   $0x0
  800d26:	e8 56 f4 ff ff       	call   800181 <sys_page_alloc>
  800d2b:	89 c3                	mov    %eax,%ebx
  800d2d:	83 c4 10             	add    $0x10,%esp
  800d30:	85 c0                	test   %eax,%eax
  800d32:	79 10                	jns    800d44 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	56                   	push   %esi
  800d38:	e8 18 02 00 00       	call   800f55 <nsipc_close>
		return r;
  800d3d:	83 c4 10             	add    $0x10,%esp
  800d40:	89 d8                	mov    %ebx,%eax
  800d42:	eb 24                	jmp    800d68 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d44:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d4d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d52:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  800d59:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  800d5c:	83 ec 0c             	sub    $0xc,%esp
  800d5f:	52                   	push   %edx
  800d60:	e8 ae f6 ff ff       	call   800413 <fd2num>
  800d65:	83 c4 10             	add    $0x10,%esp
}
  800d68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d75:	8b 45 08             	mov    0x8(%ebp),%eax
  800d78:	e8 50 ff ff ff       	call   800ccd <fd2sockid>
		return r;
  800d7d:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	78 1f                	js     800da2 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d83:	83 ec 04             	sub    $0x4,%esp
  800d86:	ff 75 10             	pushl  0x10(%ebp)
  800d89:	ff 75 0c             	pushl  0xc(%ebp)
  800d8c:	50                   	push   %eax
  800d8d:	e8 1c 01 00 00       	call   800eae <nsipc_accept>
  800d92:	83 c4 10             	add    $0x10,%esp
		return r;
  800d95:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d97:	85 c0                	test   %eax,%eax
  800d99:	78 07                	js     800da2 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d9b:	e8 5d ff ff ff       	call   800cfd <alloc_sockfd>
  800da0:	89 c1                	mov    %eax,%ecx
}
  800da2:	89 c8                	mov    %ecx,%eax
  800da4:	c9                   	leave  
  800da5:	c3                   	ret    

00800da6 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dac:	8b 45 08             	mov    0x8(%ebp),%eax
  800daf:	e8 19 ff ff ff       	call   800ccd <fd2sockid>
  800db4:	89 c2                	mov    %eax,%edx
  800db6:	85 d2                	test   %edx,%edx
  800db8:	78 12                	js     800dcc <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  800dba:	83 ec 04             	sub    $0x4,%esp
  800dbd:	ff 75 10             	pushl  0x10(%ebp)
  800dc0:	ff 75 0c             	pushl  0xc(%ebp)
  800dc3:	52                   	push   %edx
  800dc4:	e8 35 01 00 00       	call   800efe <nsipc_bind>
  800dc9:	83 c4 10             	add    $0x10,%esp
}
  800dcc:	c9                   	leave  
  800dcd:	c3                   	ret    

00800dce <shutdown>:

int
shutdown(int s, int how)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd7:	e8 f1 fe ff ff       	call   800ccd <fd2sockid>
  800ddc:	89 c2                	mov    %eax,%edx
  800dde:	85 d2                	test   %edx,%edx
  800de0:	78 0f                	js     800df1 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  800de2:	83 ec 08             	sub    $0x8,%esp
  800de5:	ff 75 0c             	pushl  0xc(%ebp)
  800de8:	52                   	push   %edx
  800de9:	e8 45 01 00 00       	call   800f33 <nsipc_shutdown>
  800dee:	83 c4 10             	add    $0x10,%esp
}
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    

00800df3 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	e8 cc fe ff ff       	call   800ccd <fd2sockid>
  800e01:	89 c2                	mov    %eax,%edx
  800e03:	85 d2                	test   %edx,%edx
  800e05:	78 12                	js     800e19 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  800e07:	83 ec 04             	sub    $0x4,%esp
  800e0a:	ff 75 10             	pushl  0x10(%ebp)
  800e0d:	ff 75 0c             	pushl  0xc(%ebp)
  800e10:	52                   	push   %edx
  800e11:	e8 59 01 00 00       	call   800f6f <nsipc_connect>
  800e16:	83 c4 10             	add    $0x10,%esp
}
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    

00800e1b <listen>:

int
listen(int s, int backlog)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e21:	8b 45 08             	mov    0x8(%ebp),%eax
  800e24:	e8 a4 fe ff ff       	call   800ccd <fd2sockid>
  800e29:	89 c2                	mov    %eax,%edx
  800e2b:	85 d2                	test   %edx,%edx
  800e2d:	78 0f                	js     800e3e <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  800e2f:	83 ec 08             	sub    $0x8,%esp
  800e32:	ff 75 0c             	pushl  0xc(%ebp)
  800e35:	52                   	push   %edx
  800e36:	e8 69 01 00 00       	call   800fa4 <nsipc_listen>
  800e3b:	83 c4 10             	add    $0x10,%esp
}
  800e3e:	c9                   	leave  
  800e3f:	c3                   	ret    

00800e40 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e46:	ff 75 10             	pushl  0x10(%ebp)
  800e49:	ff 75 0c             	pushl  0xc(%ebp)
  800e4c:	ff 75 08             	pushl  0x8(%ebp)
  800e4f:	e8 3c 02 00 00       	call   801090 <nsipc_socket>
  800e54:	89 c2                	mov    %eax,%edx
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	85 d2                	test   %edx,%edx
  800e5b:	78 05                	js     800e62 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  800e5d:	e8 9b fe ff ff       	call   800cfd <alloc_sockfd>
}
  800e62:	c9                   	leave  
  800e63:	c3                   	ret    

00800e64 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	53                   	push   %ebx
  800e68:	83 ec 04             	sub    $0x4,%esp
  800e6b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e6d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e74:	75 12                	jne    800e88 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e76:	83 ec 0c             	sub    $0xc,%esp
  800e79:	6a 02                	push   $0x2
  800e7b:	e8 80 11 00 00       	call   802000 <ipc_find_env>
  800e80:	a3 04 40 80 00       	mov    %eax,0x804004
  800e85:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e88:	6a 07                	push   $0x7
  800e8a:	68 00 60 80 00       	push   $0x806000
  800e8f:	53                   	push   %ebx
  800e90:	ff 35 04 40 80 00    	pushl  0x804004
  800e96:	e8 11 11 00 00       	call   801fac <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e9b:	83 c4 0c             	add    $0xc,%esp
  800e9e:	6a 00                	push   $0x0
  800ea0:	6a 00                	push   $0x0
  800ea2:	6a 00                	push   $0x0
  800ea4:	e8 9a 10 00 00       	call   801f43 <ipc_recv>
}
  800ea9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
  800eb3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800ebe:	8b 06                	mov    (%esi),%eax
  800ec0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800ec5:	b8 01 00 00 00       	mov    $0x1,%eax
  800eca:	e8 95 ff ff ff       	call   800e64 <nsipc>
  800ecf:	89 c3                	mov    %eax,%ebx
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	78 20                	js     800ef5 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	ff 35 10 60 80 00    	pushl  0x806010
  800ede:	68 00 60 80 00       	push   $0x806000
  800ee3:	ff 75 0c             	pushl  0xc(%ebp)
  800ee6:	e8 9d 0e 00 00       	call   801d88 <memmove>
		*addrlen = ret->ret_addrlen;
  800eeb:	a1 10 60 80 00       	mov    0x806010,%eax
  800ef0:	89 06                	mov    %eax,(%esi)
  800ef2:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800ef5:	89 d8                	mov    %ebx,%eax
  800ef7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800efa:	5b                   	pop    %ebx
  800efb:	5e                   	pop    %esi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	53                   	push   %ebx
  800f02:	83 ec 08             	sub    $0x8,%esp
  800f05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800f08:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800f10:	53                   	push   %ebx
  800f11:	ff 75 0c             	pushl  0xc(%ebp)
  800f14:	68 04 60 80 00       	push   $0x806004
  800f19:	e8 6a 0e 00 00       	call   801d88 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800f1e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800f24:	b8 02 00 00 00       	mov    $0x2,%eax
  800f29:	e8 36 ff ff ff       	call   800e64 <nsipc>
}
  800f2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f31:	c9                   	leave  
  800f32:	c3                   	ret    

00800f33 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f44:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f49:	b8 03 00 00 00       	mov    $0x3,%eax
  800f4e:	e8 11 ff ff ff       	call   800e64 <nsipc>
}
  800f53:	c9                   	leave  
  800f54:	c3                   	ret    

00800f55 <nsipc_close>:

int
nsipc_close(int s)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f63:	b8 04 00 00 00       	mov    $0x4,%eax
  800f68:	e8 f7 fe ff ff       	call   800e64 <nsipc>
}
  800f6d:	c9                   	leave  
  800f6e:	c3                   	ret    

00800f6f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	53                   	push   %ebx
  800f73:	83 ec 08             	sub    $0x8,%esp
  800f76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f79:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f81:	53                   	push   %ebx
  800f82:	ff 75 0c             	pushl  0xc(%ebp)
  800f85:	68 04 60 80 00       	push   $0x806004
  800f8a:	e8 f9 0d 00 00       	call   801d88 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f8f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f95:	b8 05 00 00 00       	mov    $0x5,%eax
  800f9a:	e8 c5 fe ff ff       	call   800e64 <nsipc>
}
  800f9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa2:	c9                   	leave  
  800fa3:	c3                   	ret    

00800fa4 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800faa:	8b 45 08             	mov    0x8(%ebp),%eax
  800fad:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800fb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800fba:	b8 06 00 00 00       	mov    $0x6,%eax
  800fbf:	e8 a0 fe ff ff       	call   800e64 <nsipc>
}
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    

00800fc6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	56                   	push   %esi
  800fca:	53                   	push   %ebx
  800fcb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fce:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800fd6:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800fdc:	8b 45 14             	mov    0x14(%ebp),%eax
  800fdf:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800fe4:	b8 07 00 00 00       	mov    $0x7,%eax
  800fe9:	e8 76 fe ff ff       	call   800e64 <nsipc>
  800fee:	89 c3                	mov    %eax,%ebx
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	78 35                	js     801029 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800ff4:	39 f0                	cmp    %esi,%eax
  800ff6:	7f 07                	jg     800fff <nsipc_recv+0x39>
  800ff8:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800ffd:	7e 16                	jle    801015 <nsipc_recv+0x4f>
  800fff:	68 47 24 80 00       	push   $0x802447
  801004:	68 0f 24 80 00       	push   $0x80240f
  801009:	6a 62                	push   $0x62
  80100b:	68 5c 24 80 00       	push   $0x80245c
  801010:	e8 81 05 00 00       	call   801596 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801015:	83 ec 04             	sub    $0x4,%esp
  801018:	50                   	push   %eax
  801019:	68 00 60 80 00       	push   $0x806000
  80101e:	ff 75 0c             	pushl  0xc(%ebp)
  801021:	e8 62 0d 00 00       	call   801d88 <memmove>
  801026:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801029:	89 d8                	mov    %ebx,%eax
  80102b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    

00801032 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	53                   	push   %ebx
  801036:	83 ec 04             	sub    $0x4,%esp
  801039:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80103c:	8b 45 08             	mov    0x8(%ebp),%eax
  80103f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801044:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80104a:	7e 16                	jle    801062 <nsipc_send+0x30>
  80104c:	68 68 24 80 00       	push   $0x802468
  801051:	68 0f 24 80 00       	push   $0x80240f
  801056:	6a 6d                	push   $0x6d
  801058:	68 5c 24 80 00       	push   $0x80245c
  80105d:	e8 34 05 00 00       	call   801596 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801062:	83 ec 04             	sub    $0x4,%esp
  801065:	53                   	push   %ebx
  801066:	ff 75 0c             	pushl  0xc(%ebp)
  801069:	68 0c 60 80 00       	push   $0x80600c
  80106e:	e8 15 0d 00 00       	call   801d88 <memmove>
	nsipcbuf.send.req_size = size;
  801073:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801079:	8b 45 14             	mov    0x14(%ebp),%eax
  80107c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801081:	b8 08 00 00 00       	mov    $0x8,%eax
  801086:	e8 d9 fd ff ff       	call   800e64 <nsipc>
}
  80108b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801096:	8b 45 08             	mov    0x8(%ebp),%eax
  801099:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80109e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8010a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8010a9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8010ae:	b8 09 00 00 00       	mov    $0x9,%eax
  8010b3:	e8 ac fd ff ff       	call   800e64 <nsipc>
}
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    

008010ba <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	56                   	push   %esi
  8010be:	53                   	push   %ebx
  8010bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010c2:	83 ec 0c             	sub    $0xc,%esp
  8010c5:	ff 75 08             	pushl  0x8(%ebp)
  8010c8:	e8 56 f3 ff ff       	call   800423 <fd2data>
  8010cd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010cf:	83 c4 08             	add    $0x8,%esp
  8010d2:	68 74 24 80 00       	push   $0x802474
  8010d7:	53                   	push   %ebx
  8010d8:	e8 19 0b 00 00       	call   801bf6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010dd:	8b 56 04             	mov    0x4(%esi),%edx
  8010e0:	89 d0                	mov    %edx,%eax
  8010e2:	2b 06                	sub    (%esi),%eax
  8010e4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8010ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8010f1:	00 00 00 
	stat->st_dev = &devpipe;
  8010f4:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8010fb:	30 80 00 
	return 0;
}
  8010fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801103:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801106:	5b                   	pop    %ebx
  801107:	5e                   	pop    %esi
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    

0080110a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	53                   	push   %ebx
  80110e:	83 ec 0c             	sub    $0xc,%esp
  801111:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801114:	53                   	push   %ebx
  801115:	6a 00                	push   $0x0
  801117:	e8 ea f0 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80111c:	89 1c 24             	mov    %ebx,(%esp)
  80111f:	e8 ff f2 ff ff       	call   800423 <fd2data>
  801124:	83 c4 08             	add    $0x8,%esp
  801127:	50                   	push   %eax
  801128:	6a 00                	push   $0x0
  80112a:	e8 d7 f0 ff ff       	call   800206 <sys_page_unmap>
}
  80112f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801132:	c9                   	leave  
  801133:	c3                   	ret    

00801134 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	57                   	push   %edi
  801138:	56                   	push   %esi
  801139:	53                   	push   %ebx
  80113a:	83 ec 1c             	sub    $0x1c,%esp
  80113d:	89 c6                	mov    %eax,%esi
  80113f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801142:	a1 08 40 80 00       	mov    0x804008,%eax
  801147:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80114a:	83 ec 0c             	sub    $0xc,%esp
  80114d:	56                   	push   %esi
  80114e:	e8 e5 0e 00 00       	call   802038 <pageref>
  801153:	89 c7                	mov    %eax,%edi
  801155:	83 c4 04             	add    $0x4,%esp
  801158:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115b:	e8 d8 0e 00 00       	call   802038 <pageref>
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	39 c7                	cmp    %eax,%edi
  801165:	0f 94 c2             	sete   %dl
  801168:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80116b:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801171:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801174:	39 fb                	cmp    %edi,%ebx
  801176:	74 19                	je     801191 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801178:	84 d2                	test   %dl,%dl
  80117a:	74 c6                	je     801142 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80117c:	8b 51 58             	mov    0x58(%ecx),%edx
  80117f:	50                   	push   %eax
  801180:	52                   	push   %edx
  801181:	53                   	push   %ebx
  801182:	68 7b 24 80 00       	push   $0x80247b
  801187:	e8 e3 04 00 00       	call   80166f <cprintf>
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	eb b1                	jmp    801142 <_pipeisclosed+0xe>
	}
}
  801191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5f                   	pop    %edi
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	57                   	push   %edi
  80119d:	56                   	push   %esi
  80119e:	53                   	push   %ebx
  80119f:	83 ec 28             	sub    $0x28,%esp
  8011a2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011a5:	56                   	push   %esi
  8011a6:	e8 78 f2 ff ff       	call   800423 <fd2data>
  8011ab:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	bf 00 00 00 00       	mov    $0x0,%edi
  8011b5:	eb 4b                	jmp    801202 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011b7:	89 da                	mov    %ebx,%edx
  8011b9:	89 f0                	mov    %esi,%eax
  8011bb:	e8 74 ff ff ff       	call   801134 <_pipeisclosed>
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	75 48                	jne    80120c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011c4:	e8 99 ef ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011c9:	8b 43 04             	mov    0x4(%ebx),%eax
  8011cc:	8b 0b                	mov    (%ebx),%ecx
  8011ce:	8d 51 20             	lea    0x20(%ecx),%edx
  8011d1:	39 d0                	cmp    %edx,%eax
  8011d3:	73 e2                	jae    8011b7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011dc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	c1 fa 1f             	sar    $0x1f,%edx
  8011e4:	89 d1                	mov    %edx,%ecx
  8011e6:	c1 e9 1b             	shr    $0x1b,%ecx
  8011e9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8011ec:	83 e2 1f             	and    $0x1f,%edx
  8011ef:	29 ca                	sub    %ecx,%edx
  8011f1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8011f5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011f9:	83 c0 01             	add    $0x1,%eax
  8011fc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011ff:	83 c7 01             	add    $0x1,%edi
  801202:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801205:	75 c2                	jne    8011c9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801207:	8b 45 10             	mov    0x10(%ebp),%eax
  80120a:	eb 05                	jmp    801211 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801214:	5b                   	pop    %ebx
  801215:	5e                   	pop    %esi
  801216:	5f                   	pop    %edi
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	57                   	push   %edi
  80121d:	56                   	push   %esi
  80121e:	53                   	push   %ebx
  80121f:	83 ec 18             	sub    $0x18,%esp
  801222:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801225:	57                   	push   %edi
  801226:	e8 f8 f1 ff ff       	call   800423 <fd2data>
  80122b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	bb 00 00 00 00       	mov    $0x0,%ebx
  801235:	eb 3d                	jmp    801274 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801237:	85 db                	test   %ebx,%ebx
  801239:	74 04                	je     80123f <devpipe_read+0x26>
				return i;
  80123b:	89 d8                	mov    %ebx,%eax
  80123d:	eb 44                	jmp    801283 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80123f:	89 f2                	mov    %esi,%edx
  801241:	89 f8                	mov    %edi,%eax
  801243:	e8 ec fe ff ff       	call   801134 <_pipeisclosed>
  801248:	85 c0                	test   %eax,%eax
  80124a:	75 32                	jne    80127e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80124c:	e8 11 ef ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801251:	8b 06                	mov    (%esi),%eax
  801253:	3b 46 04             	cmp    0x4(%esi),%eax
  801256:	74 df                	je     801237 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801258:	99                   	cltd   
  801259:	c1 ea 1b             	shr    $0x1b,%edx
  80125c:	01 d0                	add    %edx,%eax
  80125e:	83 e0 1f             	and    $0x1f,%eax
  801261:	29 d0                	sub    %edx,%eax
  801263:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801268:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80126e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801271:	83 c3 01             	add    $0x1,%ebx
  801274:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801277:	75 d8                	jne    801251 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801279:	8b 45 10             	mov    0x10(%ebp),%eax
  80127c:	eb 05                	jmp    801283 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80127e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801283:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801286:	5b                   	pop    %ebx
  801287:	5e                   	pop    %esi
  801288:	5f                   	pop    %edi
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	56                   	push   %esi
  80128f:	53                   	push   %ebx
  801290:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801293:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801296:	50                   	push   %eax
  801297:	e8 9e f1 ff ff       	call   80043a <fd_alloc>
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	89 c2                	mov    %eax,%edx
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	0f 88 2c 01 00 00    	js     8013d5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012a9:	83 ec 04             	sub    $0x4,%esp
  8012ac:	68 07 04 00 00       	push   $0x407
  8012b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b4:	6a 00                	push   $0x0
  8012b6:	e8 c6 ee ff ff       	call   800181 <sys_page_alloc>
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	0f 88 0d 01 00 00    	js     8013d5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012c8:	83 ec 0c             	sub    $0xc,%esp
  8012cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ce:	50                   	push   %eax
  8012cf:	e8 66 f1 ff ff       	call   80043a <fd_alloc>
  8012d4:	89 c3                	mov    %eax,%ebx
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	0f 88 e2 00 00 00    	js     8013c3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012e1:	83 ec 04             	sub    $0x4,%esp
  8012e4:	68 07 04 00 00       	push   $0x407
  8012e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ec:	6a 00                	push   $0x0
  8012ee:	e8 8e ee ff ff       	call   800181 <sys_page_alloc>
  8012f3:	89 c3                	mov    %eax,%ebx
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	0f 88 c3 00 00 00    	js     8013c3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801300:	83 ec 0c             	sub    $0xc,%esp
  801303:	ff 75 f4             	pushl  -0xc(%ebp)
  801306:	e8 18 f1 ff ff       	call   800423 <fd2data>
  80130b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80130d:	83 c4 0c             	add    $0xc,%esp
  801310:	68 07 04 00 00       	push   $0x407
  801315:	50                   	push   %eax
  801316:	6a 00                	push   $0x0
  801318:	e8 64 ee ff ff       	call   800181 <sys_page_alloc>
  80131d:	89 c3                	mov    %eax,%ebx
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	0f 88 89 00 00 00    	js     8013b3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80132a:	83 ec 0c             	sub    $0xc,%esp
  80132d:	ff 75 f0             	pushl  -0x10(%ebp)
  801330:	e8 ee f0 ff ff       	call   800423 <fd2data>
  801335:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80133c:	50                   	push   %eax
  80133d:	6a 00                	push   $0x0
  80133f:	56                   	push   %esi
  801340:	6a 00                	push   $0x0
  801342:	e8 7d ee ff ff       	call   8001c4 <sys_page_map>
  801347:	89 c3                	mov    %eax,%ebx
  801349:	83 c4 20             	add    $0x20,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 55                	js     8013a5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801350:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801356:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801359:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80135b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801365:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80136b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801370:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801373:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80137a:	83 ec 0c             	sub    $0xc,%esp
  80137d:	ff 75 f4             	pushl  -0xc(%ebp)
  801380:	e8 8e f0 ff ff       	call   800413 <fd2num>
  801385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801388:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80138a:	83 c4 04             	add    $0x4,%esp
  80138d:	ff 75 f0             	pushl  -0x10(%ebp)
  801390:	e8 7e f0 ff ff       	call   800413 <fd2num>
  801395:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801398:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80139b:	83 c4 10             	add    $0x10,%esp
  80139e:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a3:	eb 30                	jmp    8013d5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	56                   	push   %esi
  8013a9:	6a 00                	push   $0x0
  8013ab:	e8 56 ee ff ff       	call   800206 <sys_page_unmap>
  8013b0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8013b9:	6a 00                	push   $0x0
  8013bb:	e8 46 ee ff ff       	call   800206 <sys_page_unmap>
  8013c0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 36 ee ff ff       	call   800206 <sys_page_unmap>
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013d5:	89 d0                	mov    %edx,%eax
  8013d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013da:	5b                   	pop    %ebx
  8013db:	5e                   	pop    %esi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e7:	50                   	push   %eax
  8013e8:	ff 75 08             	pushl  0x8(%ebp)
  8013eb:	e8 99 f0 ff ff       	call   800489 <fd_lookup>
  8013f0:	89 c2                	mov    %eax,%edx
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	85 d2                	test   %edx,%edx
  8013f7:	78 18                	js     801411 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013f9:	83 ec 0c             	sub    $0xc,%esp
  8013fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ff:	e8 1f f0 ff ff       	call   800423 <fd2data>
	return _pipeisclosed(fd, p);
  801404:	89 c2                	mov    %eax,%edx
  801406:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801409:	e8 26 fd ff ff       	call   801134 <_pipeisclosed>
  80140e:	83 c4 10             	add    $0x10,%esp
}
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801416:	b8 00 00 00 00       	mov    $0x0,%eax
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    

0080141d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801423:	68 93 24 80 00       	push   $0x802493
  801428:	ff 75 0c             	pushl  0xc(%ebp)
  80142b:	e8 c6 07 00 00       	call   801bf6 <strcpy>
	return 0;
}
  801430:	b8 00 00 00 00       	mov    $0x0,%eax
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	57                   	push   %edi
  80143b:	56                   	push   %esi
  80143c:	53                   	push   %ebx
  80143d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801443:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801448:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80144e:	eb 2d                	jmp    80147d <devcons_write+0x46>
		m = n - tot;
  801450:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801453:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801455:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801458:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80145d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801460:	83 ec 04             	sub    $0x4,%esp
  801463:	53                   	push   %ebx
  801464:	03 45 0c             	add    0xc(%ebp),%eax
  801467:	50                   	push   %eax
  801468:	57                   	push   %edi
  801469:	e8 1a 09 00 00       	call   801d88 <memmove>
		sys_cputs(buf, m);
  80146e:	83 c4 08             	add    $0x8,%esp
  801471:	53                   	push   %ebx
  801472:	57                   	push   %edi
  801473:	e8 4d ec ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801478:	01 de                	add    %ebx,%esi
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	89 f0                	mov    %esi,%eax
  80147f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801482:	72 cc                	jb     801450 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801484:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801487:	5b                   	pop    %ebx
  801488:	5e                   	pop    %esi
  801489:	5f                   	pop    %edi
  80148a:	5d                   	pop    %ebp
  80148b:	c3                   	ret    

0080148c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801492:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801497:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80149b:	75 07                	jne    8014a4 <devcons_read+0x18>
  80149d:	eb 28                	jmp    8014c7 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80149f:	e8 be ec ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014a4:	e8 3a ec ff ff       	call   8000e3 <sys_cgetc>
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	74 f2                	je     80149f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	78 16                	js     8014c7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014b1:	83 f8 04             	cmp    $0x4,%eax
  8014b4:	74 0c                	je     8014c2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b9:	88 02                	mov    %al,(%edx)
	return 1;
  8014bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8014c0:	eb 05                	jmp    8014c7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014c2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014c7:	c9                   	leave  
  8014c8:	c3                   	ret    

008014c9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014d5:	6a 01                	push   $0x1
  8014d7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	e8 e5 eb ff ff       	call   8000c5 <sys_cputs>
  8014e0:	83 c4 10             	add    $0x10,%esp
}
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <getchar>:

int
getchar(void)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014eb:	6a 01                	push   $0x1
  8014ed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014f0:	50                   	push   %eax
  8014f1:	6a 00                	push   $0x0
  8014f3:	e8 00 f2 ff ff       	call   8006f8 <read>
	if (r < 0)
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 0f                	js     80150e <getchar+0x29>
		return r;
	if (r < 1)
  8014ff:	85 c0                	test   %eax,%eax
  801501:	7e 06                	jle    801509 <getchar+0x24>
		return -E_EOF;
	return c;
  801503:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801507:	eb 05                	jmp    80150e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801509:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80150e:	c9                   	leave  
  80150f:	c3                   	ret    

00801510 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801516:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801519:	50                   	push   %eax
  80151a:	ff 75 08             	pushl  0x8(%ebp)
  80151d:	e8 67 ef ff ff       	call   800489 <fd_lookup>
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	85 c0                	test   %eax,%eax
  801527:	78 11                	js     80153a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801529:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801532:	39 10                	cmp    %edx,(%eax)
  801534:	0f 94 c0             	sete   %al
  801537:	0f b6 c0             	movzbl %al,%eax
}
  80153a:	c9                   	leave  
  80153b:	c3                   	ret    

0080153c <opencons>:

int
opencons(void)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801542:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801545:	50                   	push   %eax
  801546:	e8 ef ee ff ff       	call   80043a <fd_alloc>
  80154b:	83 c4 10             	add    $0x10,%esp
		return r;
  80154e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801550:	85 c0                	test   %eax,%eax
  801552:	78 3e                	js     801592 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801554:	83 ec 04             	sub    $0x4,%esp
  801557:	68 07 04 00 00       	push   $0x407
  80155c:	ff 75 f4             	pushl  -0xc(%ebp)
  80155f:	6a 00                	push   $0x0
  801561:	e8 1b ec ff ff       	call   800181 <sys_page_alloc>
  801566:	83 c4 10             	add    $0x10,%esp
		return r;
  801569:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 23                	js     801592 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80156f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801575:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801578:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80157a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801584:	83 ec 0c             	sub    $0xc,%esp
  801587:	50                   	push   %eax
  801588:	e8 86 ee ff ff       	call   800413 <fd2num>
  80158d:	89 c2                	mov    %eax,%edx
  80158f:	83 c4 10             	add    $0x10,%esp
}
  801592:	89 d0                	mov    %edx,%eax
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	56                   	push   %esi
  80159a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80159b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80159e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015a4:	e8 9a eb ff ff       	call   800143 <sys_getenvid>
  8015a9:	83 ec 0c             	sub    $0xc,%esp
  8015ac:	ff 75 0c             	pushl  0xc(%ebp)
  8015af:	ff 75 08             	pushl  0x8(%ebp)
  8015b2:	56                   	push   %esi
  8015b3:	50                   	push   %eax
  8015b4:	68 a0 24 80 00       	push   $0x8024a0
  8015b9:	e8 b1 00 00 00       	call   80166f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015be:	83 c4 18             	add    $0x18,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	ff 75 10             	pushl  0x10(%ebp)
  8015c5:	e8 54 00 00 00       	call   80161e <vcprintf>
	cprintf("\n");
  8015ca:	c7 04 24 8c 24 80 00 	movl   $0x80248c,(%esp)
  8015d1:	e8 99 00 00 00       	call   80166f <cprintf>
  8015d6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015d9:	cc                   	int3   
  8015da:	eb fd                	jmp    8015d9 <_panic+0x43>

008015dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 04             	sub    $0x4,%esp
  8015e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015e6:	8b 13                	mov    (%ebx),%edx
  8015e8:	8d 42 01             	lea    0x1(%edx),%eax
  8015eb:	89 03                	mov    %eax,(%ebx)
  8015ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015f0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8015f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015f9:	75 1a                	jne    801615 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	68 ff 00 00 00       	push   $0xff
  801603:	8d 43 08             	lea    0x8(%ebx),%eax
  801606:	50                   	push   %eax
  801607:	e8 b9 ea ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  80160c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801612:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801615:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801619:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801627:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80162e:	00 00 00 
	b.cnt = 0;
  801631:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801638:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80163b:	ff 75 0c             	pushl  0xc(%ebp)
  80163e:	ff 75 08             	pushl  0x8(%ebp)
  801641:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	68 dc 15 80 00       	push   $0x8015dc
  80164d:	e8 4f 01 00 00       	call   8017a1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801652:	83 c4 08             	add    $0x8,%esp
  801655:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80165b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	e8 5e ea ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  801667:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801675:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801678:	50                   	push   %eax
  801679:	ff 75 08             	pushl  0x8(%ebp)
  80167c:	e8 9d ff ff ff       	call   80161e <vcprintf>
	va_end(ap);

	return cnt;
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	57                   	push   %edi
  801687:	56                   	push   %esi
  801688:	53                   	push   %ebx
  801689:	83 ec 1c             	sub    $0x1c,%esp
  80168c:	89 c7                	mov    %eax,%edi
  80168e:	89 d6                	mov    %edx,%esi
  801690:	8b 45 08             	mov    0x8(%ebp),%eax
  801693:	8b 55 0c             	mov    0xc(%ebp),%edx
  801696:	89 d1                	mov    %edx,%ecx
  801698:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80169b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80169e:	8b 45 10             	mov    0x10(%ebp),%eax
  8016a1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016a7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8016ae:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8016b1:	72 05                	jb     8016b8 <printnum+0x35>
  8016b3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8016b6:	77 3e                	ja     8016f6 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016b8:	83 ec 0c             	sub    $0xc,%esp
  8016bb:	ff 75 18             	pushl  0x18(%ebp)
  8016be:	83 eb 01             	sub    $0x1,%ebx
  8016c1:	53                   	push   %ebx
  8016c2:	50                   	push   %eax
  8016c3:	83 ec 08             	sub    $0x8,%esp
  8016c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8016cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8016cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8016d2:	e8 a9 09 00 00       	call   802080 <__udivdi3>
  8016d7:	83 c4 18             	add    $0x18,%esp
  8016da:	52                   	push   %edx
  8016db:	50                   	push   %eax
  8016dc:	89 f2                	mov    %esi,%edx
  8016de:	89 f8                	mov    %edi,%eax
  8016e0:	e8 9e ff ff ff       	call   801683 <printnum>
  8016e5:	83 c4 20             	add    $0x20,%esp
  8016e8:	eb 13                	jmp    8016fd <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8016ea:	83 ec 08             	sub    $0x8,%esp
  8016ed:	56                   	push   %esi
  8016ee:	ff 75 18             	pushl  0x18(%ebp)
  8016f1:	ff d7                	call   *%edi
  8016f3:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8016f6:	83 eb 01             	sub    $0x1,%ebx
  8016f9:	85 db                	test   %ebx,%ebx
  8016fb:	7f ed                	jg     8016ea <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	56                   	push   %esi
  801701:	83 ec 04             	sub    $0x4,%esp
  801704:	ff 75 e4             	pushl  -0x1c(%ebp)
  801707:	ff 75 e0             	pushl  -0x20(%ebp)
  80170a:	ff 75 dc             	pushl  -0x24(%ebp)
  80170d:	ff 75 d8             	pushl  -0x28(%ebp)
  801710:	e8 9b 0a 00 00       	call   8021b0 <__umoddi3>
  801715:	83 c4 14             	add    $0x14,%esp
  801718:	0f be 80 c3 24 80 00 	movsbl 0x8024c3(%eax),%eax
  80171f:	50                   	push   %eax
  801720:	ff d7                	call   *%edi
  801722:	83 c4 10             	add    $0x10,%esp
}
  801725:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5f                   	pop    %edi
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801730:	83 fa 01             	cmp    $0x1,%edx
  801733:	7e 0e                	jle    801743 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801735:	8b 10                	mov    (%eax),%edx
  801737:	8d 4a 08             	lea    0x8(%edx),%ecx
  80173a:	89 08                	mov    %ecx,(%eax)
  80173c:	8b 02                	mov    (%edx),%eax
  80173e:	8b 52 04             	mov    0x4(%edx),%edx
  801741:	eb 22                	jmp    801765 <getuint+0x38>
	else if (lflag)
  801743:	85 d2                	test   %edx,%edx
  801745:	74 10                	je     801757 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801747:	8b 10                	mov    (%eax),%edx
  801749:	8d 4a 04             	lea    0x4(%edx),%ecx
  80174c:	89 08                	mov    %ecx,(%eax)
  80174e:	8b 02                	mov    (%edx),%eax
  801750:	ba 00 00 00 00       	mov    $0x0,%edx
  801755:	eb 0e                	jmp    801765 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801757:	8b 10                	mov    (%eax),%edx
  801759:	8d 4a 04             	lea    0x4(%edx),%ecx
  80175c:	89 08                	mov    %ecx,(%eax)
  80175e:	8b 02                	mov    (%edx),%eax
  801760:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801765:	5d                   	pop    %ebp
  801766:	c3                   	ret    

00801767 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80176d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801771:	8b 10                	mov    (%eax),%edx
  801773:	3b 50 04             	cmp    0x4(%eax),%edx
  801776:	73 0a                	jae    801782 <sprintputch+0x1b>
		*b->buf++ = ch;
  801778:	8d 4a 01             	lea    0x1(%edx),%ecx
  80177b:	89 08                	mov    %ecx,(%eax)
  80177d:	8b 45 08             	mov    0x8(%ebp),%eax
  801780:	88 02                	mov    %al,(%edx)
}
  801782:	5d                   	pop    %ebp
  801783:	c3                   	ret    

00801784 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80178a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80178d:	50                   	push   %eax
  80178e:	ff 75 10             	pushl  0x10(%ebp)
  801791:	ff 75 0c             	pushl  0xc(%ebp)
  801794:	ff 75 08             	pushl  0x8(%ebp)
  801797:	e8 05 00 00 00       	call   8017a1 <vprintfmt>
	va_end(ap);
  80179c:	83 c4 10             	add    $0x10,%esp
}
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    

008017a1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	57                   	push   %edi
  8017a5:	56                   	push   %esi
  8017a6:	53                   	push   %ebx
  8017a7:	83 ec 2c             	sub    $0x2c,%esp
  8017aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8017ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017b0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017b3:	eb 12                	jmp    8017c7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	0f 84 90 03 00 00    	je     801b4d <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8017bd:	83 ec 08             	sub    $0x8,%esp
  8017c0:	53                   	push   %ebx
  8017c1:	50                   	push   %eax
  8017c2:	ff d6                	call   *%esi
  8017c4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017c7:	83 c7 01             	add    $0x1,%edi
  8017ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017ce:	83 f8 25             	cmp    $0x25,%eax
  8017d1:	75 e2                	jne    8017b5 <vprintfmt+0x14>
  8017d3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017d7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8017de:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017e5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8017ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f1:	eb 07                	jmp    8017fa <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8017f6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017fa:	8d 47 01             	lea    0x1(%edi),%eax
  8017fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801800:	0f b6 07             	movzbl (%edi),%eax
  801803:	0f b6 c8             	movzbl %al,%ecx
  801806:	83 e8 23             	sub    $0x23,%eax
  801809:	3c 55                	cmp    $0x55,%al
  80180b:	0f 87 21 03 00 00    	ja     801b32 <vprintfmt+0x391>
  801811:	0f b6 c0             	movzbl %al,%eax
  801814:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  80181b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80181e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801822:	eb d6                	jmp    8017fa <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801824:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801827:	b8 00 00 00 00       	mov    $0x0,%eax
  80182c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80182f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801832:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801836:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801839:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80183c:	83 fa 09             	cmp    $0x9,%edx
  80183f:	77 39                	ja     80187a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801841:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801844:	eb e9                	jmp    80182f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801846:	8b 45 14             	mov    0x14(%ebp),%eax
  801849:	8d 48 04             	lea    0x4(%eax),%ecx
  80184c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80184f:	8b 00                	mov    (%eax),%eax
  801851:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801854:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801857:	eb 27                	jmp    801880 <vprintfmt+0xdf>
  801859:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80185c:	85 c0                	test   %eax,%eax
  80185e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801863:	0f 49 c8             	cmovns %eax,%ecx
  801866:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801869:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80186c:	eb 8c                	jmp    8017fa <vprintfmt+0x59>
  80186e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801871:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801878:	eb 80                	jmp    8017fa <vprintfmt+0x59>
  80187a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80187d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801880:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801884:	0f 89 70 ff ff ff    	jns    8017fa <vprintfmt+0x59>
				width = precision, precision = -1;
  80188a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80188d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801890:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801897:	e9 5e ff ff ff       	jmp    8017fa <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80189c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80189f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018a2:	e9 53 ff ff ff       	jmp    8017fa <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8018aa:	8d 50 04             	lea    0x4(%eax),%edx
  8018ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8018b0:	83 ec 08             	sub    $0x8,%esp
  8018b3:	53                   	push   %ebx
  8018b4:	ff 30                	pushl  (%eax)
  8018b6:	ff d6                	call   *%esi
			break;
  8018b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018be:	e9 04 ff ff ff       	jmp    8017c7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c6:	8d 50 04             	lea    0x4(%eax),%edx
  8018c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8018cc:	8b 00                	mov    (%eax),%eax
  8018ce:	99                   	cltd   
  8018cf:	31 d0                	xor    %edx,%eax
  8018d1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018d3:	83 f8 0f             	cmp    $0xf,%eax
  8018d6:	7f 0b                	jg     8018e3 <vprintfmt+0x142>
  8018d8:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  8018df:	85 d2                	test   %edx,%edx
  8018e1:	75 18                	jne    8018fb <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8018e3:	50                   	push   %eax
  8018e4:	68 db 24 80 00       	push   $0x8024db
  8018e9:	53                   	push   %ebx
  8018ea:	56                   	push   %esi
  8018eb:	e8 94 fe ff ff       	call   801784 <printfmt>
  8018f0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8018f6:	e9 cc fe ff ff       	jmp    8017c7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018fb:	52                   	push   %edx
  8018fc:	68 21 24 80 00       	push   $0x802421
  801901:	53                   	push   %ebx
  801902:	56                   	push   %esi
  801903:	e8 7c fe ff ff       	call   801784 <printfmt>
  801908:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80190b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80190e:	e9 b4 fe ff ff       	jmp    8017c7 <vprintfmt+0x26>
  801913:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801916:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801919:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80191c:	8b 45 14             	mov    0x14(%ebp),%eax
  80191f:	8d 50 04             	lea    0x4(%eax),%edx
  801922:	89 55 14             	mov    %edx,0x14(%ebp)
  801925:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801927:	85 ff                	test   %edi,%edi
  801929:	ba d4 24 80 00       	mov    $0x8024d4,%edx
  80192e:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  801931:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801935:	0f 84 92 00 00 00    	je     8019cd <vprintfmt+0x22c>
  80193b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80193f:	0f 8e 96 00 00 00    	jle    8019db <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801945:	83 ec 08             	sub    $0x8,%esp
  801948:	51                   	push   %ecx
  801949:	57                   	push   %edi
  80194a:	e8 86 02 00 00       	call   801bd5 <strnlen>
  80194f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801952:	29 c1                	sub    %eax,%ecx
  801954:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801957:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80195a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80195e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801961:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801964:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801966:	eb 0f                	jmp    801977 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801968:	83 ec 08             	sub    $0x8,%esp
  80196b:	53                   	push   %ebx
  80196c:	ff 75 e0             	pushl  -0x20(%ebp)
  80196f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801971:	83 ef 01             	sub    $0x1,%edi
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	85 ff                	test   %edi,%edi
  801979:	7f ed                	jg     801968 <vprintfmt+0x1c7>
  80197b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80197e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801981:	85 c9                	test   %ecx,%ecx
  801983:	b8 00 00 00 00       	mov    $0x0,%eax
  801988:	0f 49 c1             	cmovns %ecx,%eax
  80198b:	29 c1                	sub    %eax,%ecx
  80198d:	89 75 08             	mov    %esi,0x8(%ebp)
  801990:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801993:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801996:	89 cb                	mov    %ecx,%ebx
  801998:	eb 4d                	jmp    8019e7 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80199a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80199e:	74 1b                	je     8019bb <vprintfmt+0x21a>
  8019a0:	0f be c0             	movsbl %al,%eax
  8019a3:	83 e8 20             	sub    $0x20,%eax
  8019a6:	83 f8 5e             	cmp    $0x5e,%eax
  8019a9:	76 10                	jbe    8019bb <vprintfmt+0x21a>
					putch('?', putdat);
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	ff 75 0c             	pushl  0xc(%ebp)
  8019b1:	6a 3f                	push   $0x3f
  8019b3:	ff 55 08             	call   *0x8(%ebp)
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	eb 0d                	jmp    8019c8 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8019bb:	83 ec 08             	sub    $0x8,%esp
  8019be:	ff 75 0c             	pushl  0xc(%ebp)
  8019c1:	52                   	push   %edx
  8019c2:	ff 55 08             	call   *0x8(%ebp)
  8019c5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019c8:	83 eb 01             	sub    $0x1,%ebx
  8019cb:	eb 1a                	jmp    8019e7 <vprintfmt+0x246>
  8019cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8019d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019d9:	eb 0c                	jmp    8019e7 <vprintfmt+0x246>
  8019db:	89 75 08             	mov    %esi,0x8(%ebp)
  8019de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019e7:	83 c7 01             	add    $0x1,%edi
  8019ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019ee:	0f be d0             	movsbl %al,%edx
  8019f1:	85 d2                	test   %edx,%edx
  8019f3:	74 23                	je     801a18 <vprintfmt+0x277>
  8019f5:	85 f6                	test   %esi,%esi
  8019f7:	78 a1                	js     80199a <vprintfmt+0x1f9>
  8019f9:	83 ee 01             	sub    $0x1,%esi
  8019fc:	79 9c                	jns    80199a <vprintfmt+0x1f9>
  8019fe:	89 df                	mov    %ebx,%edi
  801a00:	8b 75 08             	mov    0x8(%ebp),%esi
  801a03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a06:	eb 18                	jmp    801a20 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a08:	83 ec 08             	sub    $0x8,%esp
  801a0b:	53                   	push   %ebx
  801a0c:	6a 20                	push   $0x20
  801a0e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a10:	83 ef 01             	sub    $0x1,%edi
  801a13:	83 c4 10             	add    $0x10,%esp
  801a16:	eb 08                	jmp    801a20 <vprintfmt+0x27f>
  801a18:	89 df                	mov    %ebx,%edi
  801a1a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a20:	85 ff                	test   %edi,%edi
  801a22:	7f e4                	jg     801a08 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a27:	e9 9b fd ff ff       	jmp    8017c7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a2c:	83 fa 01             	cmp    $0x1,%edx
  801a2f:	7e 16                	jle    801a47 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801a31:	8b 45 14             	mov    0x14(%ebp),%eax
  801a34:	8d 50 08             	lea    0x8(%eax),%edx
  801a37:	89 55 14             	mov    %edx,0x14(%ebp)
  801a3a:	8b 50 04             	mov    0x4(%eax),%edx
  801a3d:	8b 00                	mov    (%eax),%eax
  801a3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a42:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a45:	eb 32                	jmp    801a79 <vprintfmt+0x2d8>
	else if (lflag)
  801a47:	85 d2                	test   %edx,%edx
  801a49:	74 18                	je     801a63 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801a4b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a4e:	8d 50 04             	lea    0x4(%eax),%edx
  801a51:	89 55 14             	mov    %edx,0x14(%ebp)
  801a54:	8b 00                	mov    (%eax),%eax
  801a56:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a59:	89 c1                	mov    %eax,%ecx
  801a5b:	c1 f9 1f             	sar    $0x1f,%ecx
  801a5e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a61:	eb 16                	jmp    801a79 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801a63:	8b 45 14             	mov    0x14(%ebp),%eax
  801a66:	8d 50 04             	lea    0x4(%eax),%edx
  801a69:	89 55 14             	mov    %edx,0x14(%ebp)
  801a6c:	8b 00                	mov    (%eax),%eax
  801a6e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a71:	89 c1                	mov    %eax,%ecx
  801a73:	c1 f9 1f             	sar    $0x1f,%ecx
  801a76:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a79:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a7c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a7f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a84:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a88:	79 74                	jns    801afe <vprintfmt+0x35d>
				putch('-', putdat);
  801a8a:	83 ec 08             	sub    $0x8,%esp
  801a8d:	53                   	push   %ebx
  801a8e:	6a 2d                	push   $0x2d
  801a90:	ff d6                	call   *%esi
				num = -(long long) num;
  801a92:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a95:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a98:	f7 d8                	neg    %eax
  801a9a:	83 d2 00             	adc    $0x0,%edx
  801a9d:	f7 da                	neg    %edx
  801a9f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801aa2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801aa7:	eb 55                	jmp    801afe <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801aa9:	8d 45 14             	lea    0x14(%ebp),%eax
  801aac:	e8 7c fc ff ff       	call   80172d <getuint>
			base = 10;
  801ab1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ab6:	eb 46                	jmp    801afe <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ab8:	8d 45 14             	lea    0x14(%ebp),%eax
  801abb:	e8 6d fc ff ff       	call   80172d <getuint>
                        base = 8;
  801ac0:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801ac5:	eb 37                	jmp    801afe <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801ac7:	83 ec 08             	sub    $0x8,%esp
  801aca:	53                   	push   %ebx
  801acb:	6a 30                	push   $0x30
  801acd:	ff d6                	call   *%esi
			putch('x', putdat);
  801acf:	83 c4 08             	add    $0x8,%esp
  801ad2:	53                   	push   %ebx
  801ad3:	6a 78                	push   $0x78
  801ad5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801ad7:	8b 45 14             	mov    0x14(%ebp),%eax
  801ada:	8d 50 04             	lea    0x4(%eax),%edx
  801add:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ae0:	8b 00                	mov    (%eax),%eax
  801ae2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ae7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801aea:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801aef:	eb 0d                	jmp    801afe <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801af1:	8d 45 14             	lea    0x14(%ebp),%eax
  801af4:	e8 34 fc ff ff       	call   80172d <getuint>
			base = 16;
  801af9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801afe:	83 ec 0c             	sub    $0xc,%esp
  801b01:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b05:	57                   	push   %edi
  801b06:	ff 75 e0             	pushl  -0x20(%ebp)
  801b09:	51                   	push   %ecx
  801b0a:	52                   	push   %edx
  801b0b:	50                   	push   %eax
  801b0c:	89 da                	mov    %ebx,%edx
  801b0e:	89 f0                	mov    %esi,%eax
  801b10:	e8 6e fb ff ff       	call   801683 <printnum>
			break;
  801b15:	83 c4 20             	add    $0x20,%esp
  801b18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b1b:	e9 a7 fc ff ff       	jmp    8017c7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b20:	83 ec 08             	sub    $0x8,%esp
  801b23:	53                   	push   %ebx
  801b24:	51                   	push   %ecx
  801b25:	ff d6                	call   *%esi
			break;
  801b27:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b2a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b2d:	e9 95 fc ff ff       	jmp    8017c7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b32:	83 ec 08             	sub    $0x8,%esp
  801b35:	53                   	push   %ebx
  801b36:	6a 25                	push   $0x25
  801b38:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b3a:	83 c4 10             	add    $0x10,%esp
  801b3d:	eb 03                	jmp    801b42 <vprintfmt+0x3a1>
  801b3f:	83 ef 01             	sub    $0x1,%edi
  801b42:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b46:	75 f7                	jne    801b3f <vprintfmt+0x39e>
  801b48:	e9 7a fc ff ff       	jmp    8017c7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5f                   	pop    %edi
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 18             	sub    $0x18,%esp
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b61:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b64:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b68:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b6b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b72:	85 c0                	test   %eax,%eax
  801b74:	74 26                	je     801b9c <vsnprintf+0x47>
  801b76:	85 d2                	test   %edx,%edx
  801b78:	7e 22                	jle    801b9c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b7a:	ff 75 14             	pushl  0x14(%ebp)
  801b7d:	ff 75 10             	pushl  0x10(%ebp)
  801b80:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b83:	50                   	push   %eax
  801b84:	68 67 17 80 00       	push   $0x801767
  801b89:	e8 13 fc ff ff       	call   8017a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b91:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	eb 05                	jmp    801ba1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ba1:	c9                   	leave  
  801ba2:	c3                   	ret    

00801ba3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801ba9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bac:	50                   	push   %eax
  801bad:	ff 75 10             	pushl  0x10(%ebp)
  801bb0:	ff 75 0c             	pushl  0xc(%ebp)
  801bb3:	ff 75 08             	pushl  0x8(%ebp)
  801bb6:	e8 9a ff ff ff       	call   801b55 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    

00801bbd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc8:	eb 03                	jmp    801bcd <strlen+0x10>
		n++;
  801bca:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801bcd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bd1:	75 f7                	jne    801bca <strlen+0xd>
		n++;
	return n;
}
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    

00801bd5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bde:	ba 00 00 00 00       	mov    $0x0,%edx
  801be3:	eb 03                	jmp    801be8 <strnlen+0x13>
		n++;
  801be5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801be8:	39 c2                	cmp    %eax,%edx
  801bea:	74 08                	je     801bf4 <strnlen+0x1f>
  801bec:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bf0:	75 f3                	jne    801be5 <strnlen+0x10>
  801bf2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    

00801bf6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	53                   	push   %ebx
  801bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c00:	89 c2                	mov    %eax,%edx
  801c02:	83 c2 01             	add    $0x1,%edx
  801c05:	83 c1 01             	add    $0x1,%ecx
  801c08:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c0c:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c0f:	84 db                	test   %bl,%bl
  801c11:	75 ef                	jne    801c02 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c13:	5b                   	pop    %ebx
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	53                   	push   %ebx
  801c1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c1d:	53                   	push   %ebx
  801c1e:	e8 9a ff ff ff       	call   801bbd <strlen>
  801c23:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c26:	ff 75 0c             	pushl  0xc(%ebp)
  801c29:	01 d8                	add    %ebx,%eax
  801c2b:	50                   	push   %eax
  801c2c:	e8 c5 ff ff ff       	call   801bf6 <strcpy>
	return dst;
}
  801c31:	89 d8                	mov    %ebx,%eax
  801c33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c36:	c9                   	leave  
  801c37:	c3                   	ret    

00801c38 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	56                   	push   %esi
  801c3c:	53                   	push   %ebx
  801c3d:	8b 75 08             	mov    0x8(%ebp),%esi
  801c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c43:	89 f3                	mov    %esi,%ebx
  801c45:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c48:	89 f2                	mov    %esi,%edx
  801c4a:	eb 0f                	jmp    801c5b <strncpy+0x23>
		*dst++ = *src;
  801c4c:	83 c2 01             	add    $0x1,%edx
  801c4f:	0f b6 01             	movzbl (%ecx),%eax
  801c52:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c55:	80 39 01             	cmpb   $0x1,(%ecx)
  801c58:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c5b:	39 da                	cmp    %ebx,%edx
  801c5d:	75 ed                	jne    801c4c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c5f:	89 f0                	mov    %esi,%eax
  801c61:	5b                   	pop    %ebx
  801c62:	5e                   	pop    %esi
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    

00801c65 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	56                   	push   %esi
  801c69:	53                   	push   %ebx
  801c6a:	8b 75 08             	mov    0x8(%ebp),%esi
  801c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c70:	8b 55 10             	mov    0x10(%ebp),%edx
  801c73:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c75:	85 d2                	test   %edx,%edx
  801c77:	74 21                	je     801c9a <strlcpy+0x35>
  801c79:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c7d:	89 f2                	mov    %esi,%edx
  801c7f:	eb 09                	jmp    801c8a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c81:	83 c2 01             	add    $0x1,%edx
  801c84:	83 c1 01             	add    $0x1,%ecx
  801c87:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c8a:	39 c2                	cmp    %eax,%edx
  801c8c:	74 09                	je     801c97 <strlcpy+0x32>
  801c8e:	0f b6 19             	movzbl (%ecx),%ebx
  801c91:	84 db                	test   %bl,%bl
  801c93:	75 ec                	jne    801c81 <strlcpy+0x1c>
  801c95:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c97:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c9a:	29 f0                	sub    %esi,%eax
}
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5d                   	pop    %ebp
  801c9f:	c3                   	ret    

00801ca0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801ca9:	eb 06                	jmp    801cb1 <strcmp+0x11>
		p++, q++;
  801cab:	83 c1 01             	add    $0x1,%ecx
  801cae:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801cb1:	0f b6 01             	movzbl (%ecx),%eax
  801cb4:	84 c0                	test   %al,%al
  801cb6:	74 04                	je     801cbc <strcmp+0x1c>
  801cb8:	3a 02                	cmp    (%edx),%al
  801cba:	74 ef                	je     801cab <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cbc:	0f b6 c0             	movzbl %al,%eax
  801cbf:	0f b6 12             	movzbl (%edx),%edx
  801cc2:	29 d0                	sub    %edx,%eax
}
  801cc4:	5d                   	pop    %ebp
  801cc5:	c3                   	ret    

00801cc6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	53                   	push   %ebx
  801cca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd0:	89 c3                	mov    %eax,%ebx
  801cd2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cd5:	eb 06                	jmp    801cdd <strncmp+0x17>
		n--, p++, q++;
  801cd7:	83 c0 01             	add    $0x1,%eax
  801cda:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cdd:	39 d8                	cmp    %ebx,%eax
  801cdf:	74 15                	je     801cf6 <strncmp+0x30>
  801ce1:	0f b6 08             	movzbl (%eax),%ecx
  801ce4:	84 c9                	test   %cl,%cl
  801ce6:	74 04                	je     801cec <strncmp+0x26>
  801ce8:	3a 0a                	cmp    (%edx),%cl
  801cea:	74 eb                	je     801cd7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cec:	0f b6 00             	movzbl (%eax),%eax
  801cef:	0f b6 12             	movzbl (%edx),%edx
  801cf2:	29 d0                	sub    %edx,%eax
  801cf4:	eb 05                	jmp    801cfb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cf6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801cfb:	5b                   	pop    %ebx
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	8b 45 08             	mov    0x8(%ebp),%eax
  801d04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d08:	eb 07                	jmp    801d11 <strchr+0x13>
		if (*s == c)
  801d0a:	38 ca                	cmp    %cl,%dl
  801d0c:	74 0f                	je     801d1d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d0e:	83 c0 01             	add    $0x1,%eax
  801d11:	0f b6 10             	movzbl (%eax),%edx
  801d14:	84 d2                	test   %dl,%dl
  801d16:	75 f2                	jne    801d0a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d1d:	5d                   	pop    %ebp
  801d1e:	c3                   	ret    

00801d1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	8b 45 08             	mov    0x8(%ebp),%eax
  801d25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d29:	eb 03                	jmp    801d2e <strfind+0xf>
  801d2b:	83 c0 01             	add    $0x1,%eax
  801d2e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d31:	84 d2                	test   %dl,%dl
  801d33:	74 04                	je     801d39 <strfind+0x1a>
  801d35:	38 ca                	cmp    %cl,%dl
  801d37:	75 f2                	jne    801d2b <strfind+0xc>
			break;
	return (char *) s;
}
  801d39:	5d                   	pop    %ebp
  801d3a:	c3                   	ret    

00801d3b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	57                   	push   %edi
  801d3f:	56                   	push   %esi
  801d40:	53                   	push   %ebx
  801d41:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d47:	85 c9                	test   %ecx,%ecx
  801d49:	74 36                	je     801d81 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d4b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d51:	75 28                	jne    801d7b <memset+0x40>
  801d53:	f6 c1 03             	test   $0x3,%cl
  801d56:	75 23                	jne    801d7b <memset+0x40>
		c &= 0xFF;
  801d58:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d5c:	89 d3                	mov    %edx,%ebx
  801d5e:	c1 e3 08             	shl    $0x8,%ebx
  801d61:	89 d6                	mov    %edx,%esi
  801d63:	c1 e6 18             	shl    $0x18,%esi
  801d66:	89 d0                	mov    %edx,%eax
  801d68:	c1 e0 10             	shl    $0x10,%eax
  801d6b:	09 f0                	or     %esi,%eax
  801d6d:	09 c2                	or     %eax,%edx
  801d6f:	89 d0                	mov    %edx,%eax
  801d71:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d73:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801d76:	fc                   	cld    
  801d77:	f3 ab                	rep stos %eax,%es:(%edi)
  801d79:	eb 06                	jmp    801d81 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7e:	fc                   	cld    
  801d7f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d81:	89 f8                	mov    %edi,%eax
  801d83:	5b                   	pop    %ebx
  801d84:	5e                   	pop    %esi
  801d85:	5f                   	pop    %edi
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    

00801d88 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	57                   	push   %edi
  801d8c:	56                   	push   %esi
  801d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d90:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d96:	39 c6                	cmp    %eax,%esi
  801d98:	73 35                	jae    801dcf <memmove+0x47>
  801d9a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d9d:	39 d0                	cmp    %edx,%eax
  801d9f:	73 2e                	jae    801dcf <memmove+0x47>
		s += n;
		d += n;
  801da1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801da4:	89 d6                	mov    %edx,%esi
  801da6:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801da8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801dae:	75 13                	jne    801dc3 <memmove+0x3b>
  801db0:	f6 c1 03             	test   $0x3,%cl
  801db3:	75 0e                	jne    801dc3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801db5:	83 ef 04             	sub    $0x4,%edi
  801db8:	8d 72 fc             	lea    -0x4(%edx),%esi
  801dbb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801dbe:	fd                   	std    
  801dbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dc1:	eb 09                	jmp    801dcc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801dc3:	83 ef 01             	sub    $0x1,%edi
  801dc6:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801dc9:	fd                   	std    
  801dca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801dcc:	fc                   	cld    
  801dcd:	eb 1d                	jmp    801dec <memmove+0x64>
  801dcf:	89 f2                	mov    %esi,%edx
  801dd1:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dd3:	f6 c2 03             	test   $0x3,%dl
  801dd6:	75 0f                	jne    801de7 <memmove+0x5f>
  801dd8:	f6 c1 03             	test   $0x3,%cl
  801ddb:	75 0a                	jne    801de7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801ddd:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801de0:	89 c7                	mov    %eax,%edi
  801de2:	fc                   	cld    
  801de3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801de5:	eb 05                	jmp    801dec <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801de7:	89 c7                	mov    %eax,%edi
  801de9:	fc                   	cld    
  801dea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dec:	5e                   	pop    %esi
  801ded:	5f                   	pop    %edi
  801dee:	5d                   	pop    %ebp
  801def:	c3                   	ret    

00801df0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801df3:	ff 75 10             	pushl  0x10(%ebp)
  801df6:	ff 75 0c             	pushl  0xc(%ebp)
  801df9:	ff 75 08             	pushl  0x8(%ebp)
  801dfc:	e8 87 ff ff ff       	call   801d88 <memmove>
}
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    

00801e03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	56                   	push   %esi
  801e07:	53                   	push   %ebx
  801e08:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e0e:	89 c6                	mov    %eax,%esi
  801e10:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e13:	eb 1a                	jmp    801e2f <memcmp+0x2c>
		if (*s1 != *s2)
  801e15:	0f b6 08             	movzbl (%eax),%ecx
  801e18:	0f b6 1a             	movzbl (%edx),%ebx
  801e1b:	38 d9                	cmp    %bl,%cl
  801e1d:	74 0a                	je     801e29 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e1f:	0f b6 c1             	movzbl %cl,%eax
  801e22:	0f b6 db             	movzbl %bl,%ebx
  801e25:	29 d8                	sub    %ebx,%eax
  801e27:	eb 0f                	jmp    801e38 <memcmp+0x35>
		s1++, s2++;
  801e29:	83 c0 01             	add    $0x1,%eax
  801e2c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e2f:	39 f0                	cmp    %esi,%eax
  801e31:	75 e2                	jne    801e15 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    

00801e3c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801e45:	89 c2                	mov    %eax,%edx
  801e47:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e4a:	eb 07                	jmp    801e53 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e4c:	38 08                	cmp    %cl,(%eax)
  801e4e:	74 07                	je     801e57 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e50:	83 c0 01             	add    $0x1,%eax
  801e53:	39 d0                	cmp    %edx,%eax
  801e55:	72 f5                	jb     801e4c <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    

00801e59 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	57                   	push   %edi
  801e5d:	56                   	push   %esi
  801e5e:	53                   	push   %ebx
  801e5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e65:	eb 03                	jmp    801e6a <strtol+0x11>
		s++;
  801e67:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e6a:	0f b6 01             	movzbl (%ecx),%eax
  801e6d:	3c 09                	cmp    $0x9,%al
  801e6f:	74 f6                	je     801e67 <strtol+0xe>
  801e71:	3c 20                	cmp    $0x20,%al
  801e73:	74 f2                	je     801e67 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e75:	3c 2b                	cmp    $0x2b,%al
  801e77:	75 0a                	jne    801e83 <strtol+0x2a>
		s++;
  801e79:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e7c:	bf 00 00 00 00       	mov    $0x0,%edi
  801e81:	eb 10                	jmp    801e93 <strtol+0x3a>
  801e83:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e88:	3c 2d                	cmp    $0x2d,%al
  801e8a:	75 07                	jne    801e93 <strtol+0x3a>
		s++, neg = 1;
  801e8c:	8d 49 01             	lea    0x1(%ecx),%ecx
  801e8f:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e93:	85 db                	test   %ebx,%ebx
  801e95:	0f 94 c0             	sete   %al
  801e98:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e9e:	75 19                	jne    801eb9 <strtol+0x60>
  801ea0:	80 39 30             	cmpb   $0x30,(%ecx)
  801ea3:	75 14                	jne    801eb9 <strtol+0x60>
  801ea5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ea9:	0f 85 82 00 00 00    	jne    801f31 <strtol+0xd8>
		s += 2, base = 16;
  801eaf:	83 c1 02             	add    $0x2,%ecx
  801eb2:	bb 10 00 00 00       	mov    $0x10,%ebx
  801eb7:	eb 16                	jmp    801ecf <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801eb9:	84 c0                	test   %al,%al
  801ebb:	74 12                	je     801ecf <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ebd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ec2:	80 39 30             	cmpb   $0x30,(%ecx)
  801ec5:	75 08                	jne    801ecf <strtol+0x76>
		s++, base = 8;
  801ec7:	83 c1 01             	add    $0x1,%ecx
  801eca:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ecf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ed7:	0f b6 11             	movzbl (%ecx),%edx
  801eda:	8d 72 d0             	lea    -0x30(%edx),%esi
  801edd:	89 f3                	mov    %esi,%ebx
  801edf:	80 fb 09             	cmp    $0x9,%bl
  801ee2:	77 08                	ja     801eec <strtol+0x93>
			dig = *s - '0';
  801ee4:	0f be d2             	movsbl %dl,%edx
  801ee7:	83 ea 30             	sub    $0x30,%edx
  801eea:	eb 22                	jmp    801f0e <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  801eec:	8d 72 9f             	lea    -0x61(%edx),%esi
  801eef:	89 f3                	mov    %esi,%ebx
  801ef1:	80 fb 19             	cmp    $0x19,%bl
  801ef4:	77 08                	ja     801efe <strtol+0xa5>
			dig = *s - 'a' + 10;
  801ef6:	0f be d2             	movsbl %dl,%edx
  801ef9:	83 ea 57             	sub    $0x57,%edx
  801efc:	eb 10                	jmp    801f0e <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  801efe:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f01:	89 f3                	mov    %esi,%ebx
  801f03:	80 fb 19             	cmp    $0x19,%bl
  801f06:	77 16                	ja     801f1e <strtol+0xc5>
			dig = *s - 'A' + 10;
  801f08:	0f be d2             	movsbl %dl,%edx
  801f0b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f0e:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f11:	7d 0f                	jge    801f22 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801f13:	83 c1 01             	add    $0x1,%ecx
  801f16:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f1a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f1c:	eb b9                	jmp    801ed7 <strtol+0x7e>
  801f1e:	89 c2                	mov    %eax,%edx
  801f20:	eb 02                	jmp    801f24 <strtol+0xcb>
  801f22:	89 c2                	mov    %eax,%edx

	if (endptr)
  801f24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f28:	74 0d                	je     801f37 <strtol+0xde>
		*endptr = (char *) s;
  801f2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f2d:	89 0e                	mov    %ecx,(%esi)
  801f2f:	eb 06                	jmp    801f37 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f31:	84 c0                	test   %al,%al
  801f33:	75 92                	jne    801ec7 <strtol+0x6e>
  801f35:	eb 98                	jmp    801ecf <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f37:	f7 da                	neg    %edx
  801f39:	85 ff                	test   %edi,%edi
  801f3b:	0f 45 c2             	cmovne %edx,%eax
}
  801f3e:	5b                   	pop    %ebx
  801f3f:	5e                   	pop    %esi
  801f40:	5f                   	pop    %edi
  801f41:	5d                   	pop    %ebp
  801f42:	c3                   	ret    

00801f43 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	56                   	push   %esi
  801f47:	53                   	push   %ebx
  801f48:	8b 75 08             	mov    0x8(%ebp),%esi
  801f4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f51:	85 c0                	test   %eax,%eax
  801f53:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f58:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f5b:	83 ec 0c             	sub    $0xc,%esp
  801f5e:	50                   	push   %eax
  801f5f:	e8 cd e3 ff ff       	call   800331 <sys_ipc_recv>
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	85 c0                	test   %eax,%eax
  801f69:	79 16                	jns    801f81 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801f6b:	85 f6                	test   %esi,%esi
  801f6d:	74 06                	je     801f75 <ipc_recv+0x32>
  801f6f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801f75:	85 db                	test   %ebx,%ebx
  801f77:	74 2c                	je     801fa5 <ipc_recv+0x62>
  801f79:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f7f:	eb 24                	jmp    801fa5 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801f81:	85 f6                	test   %esi,%esi
  801f83:	74 0a                	je     801f8f <ipc_recv+0x4c>
  801f85:	a1 08 40 80 00       	mov    0x804008,%eax
  801f8a:	8b 40 74             	mov    0x74(%eax),%eax
  801f8d:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801f8f:	85 db                	test   %ebx,%ebx
  801f91:	74 0a                	je     801f9d <ipc_recv+0x5a>
  801f93:	a1 08 40 80 00       	mov    0x804008,%eax
  801f98:	8b 40 78             	mov    0x78(%eax),%eax
  801f9b:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801f9d:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fa5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa8:	5b                   	pop    %ebx
  801fa9:	5e                   	pop    %esi
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    

00801fac <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	57                   	push   %edi
  801fb0:	56                   	push   %esi
  801fb1:	53                   	push   %ebx
  801fb2:	83 ec 0c             	sub    $0xc,%esp
  801fb5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fb8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801fbe:	85 db                	test   %ebx,%ebx
  801fc0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fc5:	0f 44 d8             	cmove  %eax,%ebx
  801fc8:	eb 1c                	jmp    801fe6 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801fca:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fcd:	74 12                	je     801fe1 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801fcf:	50                   	push   %eax
  801fd0:	68 e0 27 80 00       	push   $0x8027e0
  801fd5:	6a 39                	push   $0x39
  801fd7:	68 fb 27 80 00       	push   $0x8027fb
  801fdc:	e8 b5 f5 ff ff       	call   801596 <_panic>
                 sys_yield();
  801fe1:	e8 7c e1 ff ff       	call   800162 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801fe6:	ff 75 14             	pushl  0x14(%ebp)
  801fe9:	53                   	push   %ebx
  801fea:	56                   	push   %esi
  801feb:	57                   	push   %edi
  801fec:	e8 1d e3 ff ff       	call   80030e <sys_ipc_try_send>
  801ff1:	83 c4 10             	add    $0x10,%esp
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	78 d2                	js     801fca <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801ff8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffb:	5b                   	pop    %ebx
  801ffc:	5e                   	pop    %esi
  801ffd:	5f                   	pop    %edi
  801ffe:	5d                   	pop    %ebp
  801fff:	c3                   	ret    

00802000 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802006:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80200b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80200e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802014:	8b 52 50             	mov    0x50(%edx),%edx
  802017:	39 ca                	cmp    %ecx,%edx
  802019:	75 0d                	jne    802028 <ipc_find_env+0x28>
			return envs[i].env_id;
  80201b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80201e:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802023:	8b 40 08             	mov    0x8(%eax),%eax
  802026:	eb 0e                	jmp    802036 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802028:	83 c0 01             	add    $0x1,%eax
  80202b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802030:	75 d9                	jne    80200b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802032:	66 b8 00 00          	mov    $0x0,%ax
}
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    

00802038 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802038:	55                   	push   %ebp
  802039:	89 e5                	mov    %esp,%ebp
  80203b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203e:	89 d0                	mov    %edx,%eax
  802040:	c1 e8 16             	shr    $0x16,%eax
  802043:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80204a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204f:	f6 c1 01             	test   $0x1,%cl
  802052:	74 1d                	je     802071 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802054:	c1 ea 0c             	shr    $0xc,%edx
  802057:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80205e:	f6 c2 01             	test   $0x1,%dl
  802061:	74 0e                	je     802071 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802063:	c1 ea 0c             	shr    $0xc,%edx
  802066:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80206d:	ef 
  80206e:	0f b7 c0             	movzwl %ax,%eax
}
  802071:	5d                   	pop    %ebp
  802072:	c3                   	ret    
  802073:	66 90                	xchg   %ax,%ax
  802075:	66 90                	xchg   %ax,%ax
  802077:	66 90                	xchg   %ax,%ax
  802079:	66 90                	xchg   %ax,%ax
  80207b:	66 90                	xchg   %ax,%ax
  80207d:	66 90                	xchg   %ax,%ax
  80207f:	90                   	nop

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	83 ec 10             	sub    $0x10,%esp
  802086:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80208a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80208e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802092:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802096:	85 d2                	test   %edx,%edx
  802098:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80209c:	89 34 24             	mov    %esi,(%esp)
  80209f:	89 c8                	mov    %ecx,%eax
  8020a1:	75 35                	jne    8020d8 <__udivdi3+0x58>
  8020a3:	39 f1                	cmp    %esi,%ecx
  8020a5:	0f 87 bd 00 00 00    	ja     802168 <__udivdi3+0xe8>
  8020ab:	85 c9                	test   %ecx,%ecx
  8020ad:	89 cd                	mov    %ecx,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f1                	div    %ecx
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 f0                	mov    %esi,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c6                	mov    %eax,%esi
  8020c4:	89 f8                	mov    %edi,%eax
  8020c6:	f7 f5                	div    %ebp
  8020c8:	89 f2                	mov    %esi,%edx
  8020ca:	83 c4 10             	add    $0x10,%esp
  8020cd:	5e                   	pop    %esi
  8020ce:	5f                   	pop    %edi
  8020cf:	5d                   	pop    %ebp
  8020d0:	c3                   	ret    
  8020d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	3b 14 24             	cmp    (%esp),%edx
  8020db:	77 7b                	ja     802158 <__udivdi3+0xd8>
  8020dd:	0f bd f2             	bsr    %edx,%esi
  8020e0:	83 f6 1f             	xor    $0x1f,%esi
  8020e3:	0f 84 97 00 00 00    	je     802180 <__udivdi3+0x100>
  8020e9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020ee:	89 d7                	mov    %edx,%edi
  8020f0:	89 f1                	mov    %esi,%ecx
  8020f2:	29 f5                	sub    %esi,%ebp
  8020f4:	d3 e7                	shl    %cl,%edi
  8020f6:	89 c2                	mov    %eax,%edx
  8020f8:	89 e9                	mov    %ebp,%ecx
  8020fa:	d3 ea                	shr    %cl,%edx
  8020fc:	89 f1                	mov    %esi,%ecx
  8020fe:	09 fa                	or     %edi,%edx
  802100:	8b 3c 24             	mov    (%esp),%edi
  802103:	d3 e0                	shl    %cl,%eax
  802105:	89 54 24 08          	mov    %edx,0x8(%esp)
  802109:	89 e9                	mov    %ebp,%ecx
  80210b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802113:	89 fa                	mov    %edi,%edx
  802115:	d3 ea                	shr    %cl,%edx
  802117:	89 f1                	mov    %esi,%ecx
  802119:	d3 e7                	shl    %cl,%edi
  80211b:	89 e9                	mov    %ebp,%ecx
  80211d:	d3 e8                	shr    %cl,%eax
  80211f:	09 c7                	or     %eax,%edi
  802121:	89 f8                	mov    %edi,%eax
  802123:	f7 74 24 08          	divl   0x8(%esp)
  802127:	89 d5                	mov    %edx,%ebp
  802129:	89 c7                	mov    %eax,%edi
  80212b:	f7 64 24 0c          	mull   0xc(%esp)
  80212f:	39 d5                	cmp    %edx,%ebp
  802131:	89 14 24             	mov    %edx,(%esp)
  802134:	72 11                	jb     802147 <__udivdi3+0xc7>
  802136:	8b 54 24 04          	mov    0x4(%esp),%edx
  80213a:	89 f1                	mov    %esi,%ecx
  80213c:	d3 e2                	shl    %cl,%edx
  80213e:	39 c2                	cmp    %eax,%edx
  802140:	73 5e                	jae    8021a0 <__udivdi3+0x120>
  802142:	3b 2c 24             	cmp    (%esp),%ebp
  802145:	75 59                	jne    8021a0 <__udivdi3+0x120>
  802147:	8d 47 ff             	lea    -0x1(%edi),%eax
  80214a:	31 f6                	xor    %esi,%esi
  80214c:	89 f2                	mov    %esi,%edx
  80214e:	83 c4 10             	add    $0x10,%esp
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	31 f6                	xor    %esi,%esi
  80215a:	31 c0                	xor    %eax,%eax
  80215c:	89 f2                	mov    %esi,%edx
  80215e:	83 c4 10             	add    $0x10,%esp
  802161:	5e                   	pop    %esi
  802162:	5f                   	pop    %edi
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    
  802165:	8d 76 00             	lea    0x0(%esi),%esi
  802168:	89 f2                	mov    %esi,%edx
  80216a:	31 f6                	xor    %esi,%esi
  80216c:	89 f8                	mov    %edi,%eax
  80216e:	f7 f1                	div    %ecx
  802170:	89 f2                	mov    %esi,%edx
  802172:	83 c4 10             	add    $0x10,%esp
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802184:	76 0b                	jbe    802191 <__udivdi3+0x111>
  802186:	31 c0                	xor    %eax,%eax
  802188:	3b 14 24             	cmp    (%esp),%edx
  80218b:	0f 83 37 ff ff ff    	jae    8020c8 <__udivdi3+0x48>
  802191:	b8 01 00 00 00       	mov    $0x1,%eax
  802196:	e9 2d ff ff ff       	jmp    8020c8 <__udivdi3+0x48>
  80219b:	90                   	nop
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 f8                	mov    %edi,%eax
  8021a2:	31 f6                	xor    %esi,%esi
  8021a4:	e9 1f ff ff ff       	jmp    8020c8 <__udivdi3+0x48>
  8021a9:	66 90                	xchg   %ax,%ax
  8021ab:	66 90                	xchg   %ax,%ax
  8021ad:	66 90                	xchg   %ax,%ax
  8021af:	90                   	nop

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	83 ec 20             	sub    $0x20,%esp
  8021b6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8021ba:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021be:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c2:	89 c6                	mov    %eax,%esi
  8021c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021c8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021cc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8021d0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021d4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021d8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021dc:	85 c0                	test   %eax,%eax
  8021de:	89 c2                	mov    %eax,%edx
  8021e0:	75 1e                	jne    802200 <__umoddi3+0x50>
  8021e2:	39 f7                	cmp    %esi,%edi
  8021e4:	76 52                	jbe    802238 <__umoddi3+0x88>
  8021e6:	89 c8                	mov    %ecx,%eax
  8021e8:	89 f2                	mov    %esi,%edx
  8021ea:	f7 f7                	div    %edi
  8021ec:	89 d0                	mov    %edx,%eax
  8021ee:	31 d2                	xor    %edx,%edx
  8021f0:	83 c4 20             	add    $0x20,%esp
  8021f3:	5e                   	pop    %esi
  8021f4:	5f                   	pop    %edi
  8021f5:	5d                   	pop    %ebp
  8021f6:	c3                   	ret    
  8021f7:	89 f6                	mov    %esi,%esi
  8021f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802200:	39 f0                	cmp    %esi,%eax
  802202:	77 5c                	ja     802260 <__umoddi3+0xb0>
  802204:	0f bd e8             	bsr    %eax,%ebp
  802207:	83 f5 1f             	xor    $0x1f,%ebp
  80220a:	75 64                	jne    802270 <__umoddi3+0xc0>
  80220c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802210:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802214:	0f 86 f6 00 00 00    	jbe    802310 <__umoddi3+0x160>
  80221a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80221e:	0f 82 ec 00 00 00    	jb     802310 <__umoddi3+0x160>
  802224:	8b 44 24 14          	mov    0x14(%esp),%eax
  802228:	8b 54 24 18          	mov    0x18(%esp),%edx
  80222c:	83 c4 20             	add    $0x20,%esp
  80222f:	5e                   	pop    %esi
  802230:	5f                   	pop    %edi
  802231:	5d                   	pop    %ebp
  802232:	c3                   	ret    
  802233:	90                   	nop
  802234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802238:	85 ff                	test   %edi,%edi
  80223a:	89 fd                	mov    %edi,%ebp
  80223c:	75 0b                	jne    802249 <__umoddi3+0x99>
  80223e:	b8 01 00 00 00       	mov    $0x1,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f7                	div    %edi
  802247:	89 c5                	mov    %eax,%ebp
  802249:	8b 44 24 10          	mov    0x10(%esp),%eax
  80224d:	31 d2                	xor    %edx,%edx
  80224f:	f7 f5                	div    %ebp
  802251:	89 c8                	mov    %ecx,%eax
  802253:	f7 f5                	div    %ebp
  802255:	eb 95                	jmp    8021ec <__umoddi3+0x3c>
  802257:	89 f6                	mov    %esi,%esi
  802259:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	83 c4 20             	add    $0x20,%esp
  802267:	5e                   	pop    %esi
  802268:	5f                   	pop    %edi
  802269:	5d                   	pop    %ebp
  80226a:	c3                   	ret    
  80226b:	90                   	nop
  80226c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802270:	b8 20 00 00 00       	mov    $0x20,%eax
  802275:	89 e9                	mov    %ebp,%ecx
  802277:	29 e8                	sub    %ebp,%eax
  802279:	d3 e2                	shl    %cl,%edx
  80227b:	89 c7                	mov    %eax,%edi
  80227d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802281:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 c1                	mov    %eax,%ecx
  80228b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80228f:	09 d1                	or     %edx,%ecx
  802291:	89 fa                	mov    %edi,%edx
  802293:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802297:	89 e9                	mov    %ebp,%ecx
  802299:	d3 e0                	shl    %cl,%eax
  80229b:	89 f9                	mov    %edi,%ecx
  80229d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022a1:	89 f0                	mov    %esi,%eax
  8022a3:	d3 e8                	shr    %cl,%eax
  8022a5:	89 e9                	mov    %ebp,%ecx
  8022a7:	89 c7                	mov    %eax,%edi
  8022a9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8022ad:	d3 e6                	shl    %cl,%esi
  8022af:	89 d1                	mov    %edx,%ecx
  8022b1:	89 fa                	mov    %edi,%edx
  8022b3:	d3 e8                	shr    %cl,%eax
  8022b5:	89 e9                	mov    %ebp,%ecx
  8022b7:	09 f0                	or     %esi,%eax
  8022b9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8022bd:	f7 74 24 10          	divl   0x10(%esp)
  8022c1:	d3 e6                	shl    %cl,%esi
  8022c3:	89 d1                	mov    %edx,%ecx
  8022c5:	f7 64 24 0c          	mull   0xc(%esp)
  8022c9:	39 d1                	cmp    %edx,%ecx
  8022cb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8022cf:	89 d7                	mov    %edx,%edi
  8022d1:	89 c6                	mov    %eax,%esi
  8022d3:	72 0a                	jb     8022df <__umoddi3+0x12f>
  8022d5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8022d9:	73 10                	jae    8022eb <__umoddi3+0x13b>
  8022db:	39 d1                	cmp    %edx,%ecx
  8022dd:	75 0c                	jne    8022eb <__umoddi3+0x13b>
  8022df:	89 d7                	mov    %edx,%edi
  8022e1:	89 c6                	mov    %eax,%esi
  8022e3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8022e7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8022eb:	89 ca                	mov    %ecx,%edx
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022f3:	29 f0                	sub    %esi,%eax
  8022f5:	19 fa                	sbb    %edi,%edx
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8022fe:	89 d7                	mov    %edx,%edi
  802300:	d3 e7                	shl    %cl,%edi
  802302:	89 e9                	mov    %ebp,%ecx
  802304:	09 f8                	or     %edi,%eax
  802306:	d3 ea                	shr    %cl,%edx
  802308:	83 c4 20             	add    $0x20,%esp
  80230b:	5e                   	pop    %esi
  80230c:	5f                   	pop    %edi
  80230d:	5d                   	pop    %ebp
  80230e:	c3                   	ret    
  80230f:	90                   	nop
  802310:	8b 74 24 10          	mov    0x10(%esp),%esi
  802314:	29 f9                	sub    %edi,%ecx
  802316:	19 c6                	sbb    %eax,%esi
  802318:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80231c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802320:	e9 ff fe ff ff       	jmp    802224 <__umoddi3+0x74>
