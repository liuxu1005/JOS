
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
  800076:	83 c4 10             	add    $0x10,%esp
}
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 2f 05 00 00       	call   8005ba <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
  800095:	83 c4 10             	add    $0x10,%esp
}
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 0a 23 80 00       	push   $0x80230a
  800104:	6a 22                	push   $0x22
  800106:	68 27 23 80 00       	push   $0x802327
  80010b:	e8 5b 14 00 00       	call   80156b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{      
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 0a 23 80 00       	push   $0x80230a
  800185:	6a 22                	push   $0x22
  800187:	68 27 23 80 00       	push   $0x802327
  80018c:	e8 da 13 00 00       	call   80156b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 0a 23 80 00       	push   $0x80230a
  8001c7:	6a 22                	push   $0x22
  8001c9:	68 27 23 80 00       	push   $0x802327
  8001ce:	e8 98 13 00 00       	call   80156b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 0a 23 80 00       	push   $0x80230a
  800209:	6a 22                	push   $0x22
  80020b:	68 27 23 80 00       	push   $0x802327
  800210:	e8 56 13 00 00       	call   80156b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 0a 23 80 00       	push   $0x80230a
  80024b:	6a 22                	push   $0x22
  80024d:	68 27 23 80 00       	push   $0x802327
  800252:	e8 14 13 00 00       	call   80156b <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 0a 23 80 00       	push   $0x80230a
  80028d:	6a 22                	push   $0x22
  80028f:	68 27 23 80 00       	push   $0x802327
  800294:	e8 d2 12 00 00       	call   80156b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7e 17                	jle    8002db <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 0a                	push   $0xa
  8002ca:	68 0a 23 80 00       	push   $0x80230a
  8002cf:	6a 22                	push   $0x22
  8002d1:	68 27 23 80 00       	push   $0x802327
  8002d6:	e8 90 12 00 00       	call   80156b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	b8 0d 00 00 00       	mov    $0xd,%eax
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 17                	jle    80033f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0d                	push   $0xd
  80032e:	68 0a 23 80 00       	push   $0x80230a
  800333:	6a 22                	push   $0x22
  800335:	68 27 23 80 00       	push   $0x802327
  80033a:	e8 2c 12 00 00       	call   80156b <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	b8 0e 00 00 00       	mov    $0xe,%eax
  800357:	89 d1                	mov    %edx,%ecx
  800359:	89 d3                	mov    %edx,%ebx
  80035b:	89 d7                	mov    %edx,%edi
  80035d:	89 d6                	mov    %edx,%esi
  80035f:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	57                   	push   %edi
  80036a:	56                   	push   %esi
  80036b:	53                   	push   %ebx
  80036c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80036f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800374:	b8 0f 00 00 00       	mov    $0xf,%eax
  800379:	8b 55 08             	mov    0x8(%ebp),%edx
  80037c:	89 cb                	mov    %ecx,%ebx
  80037e:	89 cf                	mov    %ecx,%edi
  800380:	89 ce                	mov    %ecx,%esi
  800382:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800384:	85 c0                	test   %eax,%eax
  800386:	7e 17                	jle    80039f <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800388:	83 ec 0c             	sub    $0xc,%esp
  80038b:	50                   	push   %eax
  80038c:	6a 0f                	push   $0xf
  80038e:	68 0a 23 80 00       	push   $0x80230a
  800393:	6a 22                	push   $0x22
  800395:	68 27 23 80 00       	push   $0x802327
  80039a:	e8 cc 11 00 00       	call   80156b <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  80039f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003a2:	5b                   	pop    %ebx
  8003a3:	5e                   	pop    %esi
  8003a4:	5f                   	pop    %edi
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <sys_recv>:

int
sys_recv(void *addr)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	57                   	push   %edi
  8003ab:	56                   	push   %esi
  8003ac:	53                   	push   %ebx
  8003ad:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8003b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b5:	b8 10 00 00 00       	mov    $0x10,%eax
  8003ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bd:	89 cb                	mov    %ecx,%ebx
  8003bf:	89 cf                	mov    %ecx,%edi
  8003c1:	89 ce                	mov    %ecx,%esi
  8003c3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003c5:	85 c0                	test   %eax,%eax
  8003c7:	7e 17                	jle    8003e0 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c9:	83 ec 0c             	sub    $0xc,%esp
  8003cc:	50                   	push   %eax
  8003cd:	6a 10                	push   $0x10
  8003cf:	68 0a 23 80 00       	push   $0x80230a
  8003d4:	6a 22                	push   $0x22
  8003d6:	68 27 23 80 00       	push   $0x802327
  8003db:	e8 8b 11 00 00       	call   80156b <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e3:	5b                   	pop    %ebx
  8003e4:	5e                   	pop    %esi
  8003e5:	5f                   	pop    %edi
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ee:	05 00 00 00 30       	add    $0x30000000,%eax
  8003f3:	c1 e8 0c             	shr    $0xc,%eax
}
  8003f6:	5d                   	pop    %ebp
  8003f7:	c3                   	ret    

008003f8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800403:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800408:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80040d:	5d                   	pop    %ebp
  80040e:	c3                   	ret    

0080040f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800415:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80041a:	89 c2                	mov    %eax,%edx
  80041c:	c1 ea 16             	shr    $0x16,%edx
  80041f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800426:	f6 c2 01             	test   $0x1,%dl
  800429:	74 11                	je     80043c <fd_alloc+0x2d>
  80042b:	89 c2                	mov    %eax,%edx
  80042d:	c1 ea 0c             	shr    $0xc,%edx
  800430:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800437:	f6 c2 01             	test   $0x1,%dl
  80043a:	75 09                	jne    800445 <fd_alloc+0x36>
			*fd_store = fd;
  80043c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043e:	b8 00 00 00 00       	mov    $0x0,%eax
  800443:	eb 17                	jmp    80045c <fd_alloc+0x4d>
  800445:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80044a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80044f:	75 c9                	jne    80041a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800451:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800457:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80045c:	5d                   	pop    %ebp
  80045d:	c3                   	ret    

0080045e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800464:	83 f8 1f             	cmp    $0x1f,%eax
  800467:	77 36                	ja     80049f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800469:	c1 e0 0c             	shl    $0xc,%eax
  80046c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800471:	89 c2                	mov    %eax,%edx
  800473:	c1 ea 16             	shr    $0x16,%edx
  800476:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80047d:	f6 c2 01             	test   $0x1,%dl
  800480:	74 24                	je     8004a6 <fd_lookup+0x48>
  800482:	89 c2                	mov    %eax,%edx
  800484:	c1 ea 0c             	shr    $0xc,%edx
  800487:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80048e:	f6 c2 01             	test   $0x1,%dl
  800491:	74 1a                	je     8004ad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800493:	8b 55 0c             	mov    0xc(%ebp),%edx
  800496:	89 02                	mov    %eax,(%edx)
	return 0;
  800498:	b8 00 00 00 00       	mov    $0x0,%eax
  80049d:	eb 13                	jmp    8004b2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80049f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a4:	eb 0c                	jmp    8004b2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ab:	eb 05                	jmp    8004b2 <fd_lookup+0x54>
  8004ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004b2:	5d                   	pop    %ebp
  8004b3:	c3                   	ret    

008004b4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8004bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c2:	eb 13                	jmp    8004d7 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8004c4:	39 08                	cmp    %ecx,(%eax)
  8004c6:	75 0c                	jne    8004d4 <dev_lookup+0x20>
			*dev = devtab[i];
  8004c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d2:	eb 36                	jmp    80050a <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004d4:	83 c2 01             	add    $0x1,%edx
  8004d7:	8b 04 95 b4 23 80 00 	mov    0x8023b4(,%edx,4),%eax
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	75 e2                	jne    8004c4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004e2:	a1 08 40 80 00       	mov    0x804008,%eax
  8004e7:	8b 40 48             	mov    0x48(%eax),%eax
  8004ea:	83 ec 04             	sub    $0x4,%esp
  8004ed:	51                   	push   %ecx
  8004ee:	50                   	push   %eax
  8004ef:	68 38 23 80 00       	push   $0x802338
  8004f4:	e8 4b 11 00 00       	call   801644 <cprintf>
	*dev = 0;
  8004f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80050a:	c9                   	leave  
  80050b:	c3                   	ret    

0080050c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80050c:	55                   	push   %ebp
  80050d:	89 e5                	mov    %esp,%ebp
  80050f:	56                   	push   %esi
  800510:	53                   	push   %ebx
  800511:	83 ec 10             	sub    $0x10,%esp
  800514:	8b 75 08             	mov    0x8(%ebp),%esi
  800517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80051a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051d:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80051e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800524:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800527:	50                   	push   %eax
  800528:	e8 31 ff ff ff       	call   80045e <fd_lookup>
  80052d:	83 c4 08             	add    $0x8,%esp
  800530:	85 c0                	test   %eax,%eax
  800532:	78 05                	js     800539 <fd_close+0x2d>
	    || fd != fd2)
  800534:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800537:	74 0c                	je     800545 <fd_close+0x39>
		return (must_exist ? r : 0);
  800539:	84 db                	test   %bl,%bl
  80053b:	ba 00 00 00 00       	mov    $0x0,%edx
  800540:	0f 44 c2             	cmove  %edx,%eax
  800543:	eb 41                	jmp    800586 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80054b:	50                   	push   %eax
  80054c:	ff 36                	pushl  (%esi)
  80054e:	e8 61 ff ff ff       	call   8004b4 <dev_lookup>
  800553:	89 c3                	mov    %eax,%ebx
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	85 c0                	test   %eax,%eax
  80055a:	78 1a                	js     800576 <fd_close+0x6a>
		if (dev->dev_close)
  80055c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80055f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800562:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800567:	85 c0                	test   %eax,%eax
  800569:	74 0b                	je     800576 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80056b:	83 ec 0c             	sub    $0xc,%esp
  80056e:	56                   	push   %esi
  80056f:	ff d0                	call   *%eax
  800571:	89 c3                	mov    %eax,%ebx
  800573:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	56                   	push   %esi
  80057a:	6a 00                	push   $0x0
  80057c:	e8 5a fc ff ff       	call   8001db <sys_page_unmap>
	return r;
  800581:	83 c4 10             	add    $0x10,%esp
  800584:	89 d8                	mov    %ebx,%eax
}
  800586:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800589:	5b                   	pop    %ebx
  80058a:	5e                   	pop    %esi
  80058b:	5d                   	pop    %ebp
  80058c:	c3                   	ret    

0080058d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80058d:	55                   	push   %ebp
  80058e:	89 e5                	mov    %esp,%ebp
  800590:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800593:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800596:	50                   	push   %eax
  800597:	ff 75 08             	pushl  0x8(%ebp)
  80059a:	e8 bf fe ff ff       	call   80045e <fd_lookup>
  80059f:	89 c2                	mov    %eax,%edx
  8005a1:	83 c4 08             	add    $0x8,%esp
  8005a4:	85 d2                	test   %edx,%edx
  8005a6:	78 10                	js     8005b8 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	6a 01                	push   $0x1
  8005ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8005b0:	e8 57 ff ff ff       	call   80050c <fd_close>
  8005b5:	83 c4 10             	add    $0x10,%esp
}
  8005b8:	c9                   	leave  
  8005b9:	c3                   	ret    

008005ba <close_all>:

void
close_all(void)
{
  8005ba:	55                   	push   %ebp
  8005bb:	89 e5                	mov    %esp,%ebp
  8005bd:	53                   	push   %ebx
  8005be:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005c6:	83 ec 0c             	sub    $0xc,%esp
  8005c9:	53                   	push   %ebx
  8005ca:	e8 be ff ff ff       	call   80058d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005cf:	83 c3 01             	add    $0x1,%ebx
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	83 fb 20             	cmp    $0x20,%ebx
  8005d8:	75 ec                	jne    8005c6 <close_all+0xc>
		close(i);
}
  8005da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005dd:	c9                   	leave  
  8005de:	c3                   	ret    

008005df <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	57                   	push   %edi
  8005e3:	56                   	push   %esi
  8005e4:	53                   	push   %ebx
  8005e5:	83 ec 2c             	sub    $0x2c,%esp
  8005e8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005ee:	50                   	push   %eax
  8005ef:	ff 75 08             	pushl  0x8(%ebp)
  8005f2:	e8 67 fe ff ff       	call   80045e <fd_lookup>
  8005f7:	89 c2                	mov    %eax,%edx
  8005f9:	83 c4 08             	add    $0x8,%esp
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	0f 88 c1 00 00 00    	js     8006c5 <dup+0xe6>
		return r;
	close(newfdnum);
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	56                   	push   %esi
  800608:	e8 80 ff ff ff       	call   80058d <close>

	newfd = INDEX2FD(newfdnum);
  80060d:	89 f3                	mov    %esi,%ebx
  80060f:	c1 e3 0c             	shl    $0xc,%ebx
  800612:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800618:	83 c4 04             	add    $0x4,%esp
  80061b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80061e:	e8 d5 fd ff ff       	call   8003f8 <fd2data>
  800623:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800625:	89 1c 24             	mov    %ebx,(%esp)
  800628:	e8 cb fd ff ff       	call   8003f8 <fd2data>
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800633:	89 f8                	mov    %edi,%eax
  800635:	c1 e8 16             	shr    $0x16,%eax
  800638:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80063f:	a8 01                	test   $0x1,%al
  800641:	74 37                	je     80067a <dup+0x9b>
  800643:	89 f8                	mov    %edi,%eax
  800645:	c1 e8 0c             	shr    $0xc,%eax
  800648:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80064f:	f6 c2 01             	test   $0x1,%dl
  800652:	74 26                	je     80067a <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800654:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80065b:	83 ec 0c             	sub    $0xc,%esp
  80065e:	25 07 0e 00 00       	and    $0xe07,%eax
  800663:	50                   	push   %eax
  800664:	ff 75 d4             	pushl  -0x2c(%ebp)
  800667:	6a 00                	push   $0x0
  800669:	57                   	push   %edi
  80066a:	6a 00                	push   $0x0
  80066c:	e8 28 fb ff ff       	call   800199 <sys_page_map>
  800671:	89 c7                	mov    %eax,%edi
  800673:	83 c4 20             	add    $0x20,%esp
  800676:	85 c0                	test   %eax,%eax
  800678:	78 2e                	js     8006a8 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80067a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80067d:	89 d0                	mov    %edx,%eax
  80067f:	c1 e8 0c             	shr    $0xc,%eax
  800682:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800689:	83 ec 0c             	sub    $0xc,%esp
  80068c:	25 07 0e 00 00       	and    $0xe07,%eax
  800691:	50                   	push   %eax
  800692:	53                   	push   %ebx
  800693:	6a 00                	push   $0x0
  800695:	52                   	push   %edx
  800696:	6a 00                	push   $0x0
  800698:	e8 fc fa ff ff       	call   800199 <sys_page_map>
  80069d:	89 c7                	mov    %eax,%edi
  80069f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006a2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006a4:	85 ff                	test   %edi,%edi
  8006a6:	79 1d                	jns    8006c5 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	6a 00                	push   $0x0
  8006ae:	e8 28 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006b3:	83 c4 08             	add    $0x8,%esp
  8006b6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006b9:	6a 00                	push   $0x0
  8006bb:	e8 1b fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	89 f8                	mov    %edi,%eax
}
  8006c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c8:	5b                   	pop    %ebx
  8006c9:	5e                   	pop    %esi
  8006ca:	5f                   	pop    %edi
  8006cb:	5d                   	pop    %ebp
  8006cc:	c3                   	ret    

008006cd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	53                   	push   %ebx
  8006d1:	83 ec 14             	sub    $0x14,%esp
  8006d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006da:	50                   	push   %eax
  8006db:	53                   	push   %ebx
  8006dc:	e8 7d fd ff ff       	call   80045e <fd_lookup>
  8006e1:	83 c4 08             	add    $0x8,%esp
  8006e4:	89 c2                	mov    %eax,%edx
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	78 6d                	js     800757 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006f0:	50                   	push   %eax
  8006f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006f4:	ff 30                	pushl  (%eax)
  8006f6:	e8 b9 fd ff ff       	call   8004b4 <dev_lookup>
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	85 c0                	test   %eax,%eax
  800700:	78 4c                	js     80074e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800702:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800705:	8b 42 08             	mov    0x8(%edx),%eax
  800708:	83 e0 03             	and    $0x3,%eax
  80070b:	83 f8 01             	cmp    $0x1,%eax
  80070e:	75 21                	jne    800731 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800710:	a1 08 40 80 00       	mov    0x804008,%eax
  800715:	8b 40 48             	mov    0x48(%eax),%eax
  800718:	83 ec 04             	sub    $0x4,%esp
  80071b:	53                   	push   %ebx
  80071c:	50                   	push   %eax
  80071d:	68 79 23 80 00       	push   $0x802379
  800722:	e8 1d 0f 00 00       	call   801644 <cprintf>
		return -E_INVAL;
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80072f:	eb 26                	jmp    800757 <read+0x8a>
	}
	if (!dev->dev_read)
  800731:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800734:	8b 40 08             	mov    0x8(%eax),%eax
  800737:	85 c0                	test   %eax,%eax
  800739:	74 17                	je     800752 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80073b:	83 ec 04             	sub    $0x4,%esp
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	52                   	push   %edx
  800745:	ff d0                	call   *%eax
  800747:	89 c2                	mov    %eax,%edx
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb 09                	jmp    800757 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80074e:	89 c2                	mov    %eax,%edx
  800750:	eb 05                	jmp    800757 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800752:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800757:	89 d0                	mov    %edx,%eax
  800759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	57                   	push   %edi
  800762:	56                   	push   %esi
  800763:	53                   	push   %ebx
  800764:	83 ec 0c             	sub    $0xc,%esp
  800767:	8b 7d 08             	mov    0x8(%ebp),%edi
  80076a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80076d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800772:	eb 21                	jmp    800795 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800774:	83 ec 04             	sub    $0x4,%esp
  800777:	89 f0                	mov    %esi,%eax
  800779:	29 d8                	sub    %ebx,%eax
  80077b:	50                   	push   %eax
  80077c:	89 d8                	mov    %ebx,%eax
  80077e:	03 45 0c             	add    0xc(%ebp),%eax
  800781:	50                   	push   %eax
  800782:	57                   	push   %edi
  800783:	e8 45 ff ff ff       	call   8006cd <read>
		if (m < 0)
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	85 c0                	test   %eax,%eax
  80078d:	78 0c                	js     80079b <readn+0x3d>
			return m;
		if (m == 0)
  80078f:	85 c0                	test   %eax,%eax
  800791:	74 06                	je     800799 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800793:	01 c3                	add    %eax,%ebx
  800795:	39 f3                	cmp    %esi,%ebx
  800797:	72 db                	jb     800774 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800799:	89 d8                	mov    %ebx,%eax
}
  80079b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5f                   	pop    %edi
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	53                   	push   %ebx
  8007a7:	83 ec 14             	sub    $0x14,%esp
  8007aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b0:	50                   	push   %eax
  8007b1:	53                   	push   %ebx
  8007b2:	e8 a7 fc ff ff       	call   80045e <fd_lookup>
  8007b7:	83 c4 08             	add    $0x8,%esp
  8007ba:	89 c2                	mov    %eax,%edx
  8007bc:	85 c0                	test   %eax,%eax
  8007be:	78 68                	js     800828 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c6:	50                   	push   %eax
  8007c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ca:	ff 30                	pushl  (%eax)
  8007cc:	e8 e3 fc ff ff       	call   8004b4 <dev_lookup>
  8007d1:	83 c4 10             	add    $0x10,%esp
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	78 47                	js     80081f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007db:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007df:	75 21                	jne    800802 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007e1:	a1 08 40 80 00       	mov    0x804008,%eax
  8007e6:	8b 40 48             	mov    0x48(%eax),%eax
  8007e9:	83 ec 04             	sub    $0x4,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	50                   	push   %eax
  8007ee:	68 95 23 80 00       	push   $0x802395
  8007f3:	e8 4c 0e 00 00       	call   801644 <cprintf>
		return -E_INVAL;
  8007f8:	83 c4 10             	add    $0x10,%esp
  8007fb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800800:	eb 26                	jmp    800828 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800802:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800805:	8b 52 0c             	mov    0xc(%edx),%edx
  800808:	85 d2                	test   %edx,%edx
  80080a:	74 17                	je     800823 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80080c:	83 ec 04             	sub    $0x4,%esp
  80080f:	ff 75 10             	pushl  0x10(%ebp)
  800812:	ff 75 0c             	pushl  0xc(%ebp)
  800815:	50                   	push   %eax
  800816:	ff d2                	call   *%edx
  800818:	89 c2                	mov    %eax,%edx
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	eb 09                	jmp    800828 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081f:	89 c2                	mov    %eax,%edx
  800821:	eb 05                	jmp    800828 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800823:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800828:	89 d0                	mov    %edx,%eax
  80082a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    

0080082f <seek>:

int
seek(int fdnum, off_t offset)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800835:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800838:	50                   	push   %eax
  800839:	ff 75 08             	pushl  0x8(%ebp)
  80083c:	e8 1d fc ff ff       	call   80045e <fd_lookup>
  800841:	83 c4 08             	add    $0x8,%esp
  800844:	85 c0                	test   %eax,%eax
  800846:	78 0e                	js     800856 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800848:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	53                   	push   %ebx
  80085c:	83 ec 14             	sub    $0x14,%esp
  80085f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800862:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800865:	50                   	push   %eax
  800866:	53                   	push   %ebx
  800867:	e8 f2 fb ff ff       	call   80045e <fd_lookup>
  80086c:	83 c4 08             	add    $0x8,%esp
  80086f:	89 c2                	mov    %eax,%edx
  800871:	85 c0                	test   %eax,%eax
  800873:	78 65                	js     8008da <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800875:	83 ec 08             	sub    $0x8,%esp
  800878:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087b:	50                   	push   %eax
  80087c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80087f:	ff 30                	pushl  (%eax)
  800881:	e8 2e fc ff ff       	call   8004b4 <dev_lookup>
  800886:	83 c4 10             	add    $0x10,%esp
  800889:	85 c0                	test   %eax,%eax
  80088b:	78 44                	js     8008d1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80088d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800890:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800894:	75 21                	jne    8008b7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800896:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80089b:	8b 40 48             	mov    0x48(%eax),%eax
  80089e:	83 ec 04             	sub    $0x4,%esp
  8008a1:	53                   	push   %ebx
  8008a2:	50                   	push   %eax
  8008a3:	68 58 23 80 00       	push   $0x802358
  8008a8:	e8 97 0d 00 00       	call   801644 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008ad:	83 c4 10             	add    $0x10,%esp
  8008b0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008b5:	eb 23                	jmp    8008da <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008ba:	8b 52 18             	mov    0x18(%edx),%edx
  8008bd:	85 d2                	test   %edx,%edx
  8008bf:	74 14                	je     8008d5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008c1:	83 ec 08             	sub    $0x8,%esp
  8008c4:	ff 75 0c             	pushl  0xc(%ebp)
  8008c7:	50                   	push   %eax
  8008c8:	ff d2                	call   *%edx
  8008ca:	89 c2                	mov    %eax,%edx
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	eb 09                	jmp    8008da <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d1:	89 c2                	mov    %eax,%edx
  8008d3:	eb 05                	jmp    8008da <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008d5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008da:	89 d0                	mov    %edx,%eax
  8008dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008df:	c9                   	leave  
  8008e0:	c3                   	ret    

008008e1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	53                   	push   %ebx
  8008e5:	83 ec 14             	sub    $0x14,%esp
  8008e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ee:	50                   	push   %eax
  8008ef:	ff 75 08             	pushl  0x8(%ebp)
  8008f2:	e8 67 fb ff ff       	call   80045e <fd_lookup>
  8008f7:	83 c4 08             	add    $0x8,%esp
  8008fa:	89 c2                	mov    %eax,%edx
  8008fc:	85 c0                	test   %eax,%eax
  8008fe:	78 58                	js     800958 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800900:	83 ec 08             	sub    $0x8,%esp
  800903:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800906:	50                   	push   %eax
  800907:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80090a:	ff 30                	pushl  (%eax)
  80090c:	e8 a3 fb ff ff       	call   8004b4 <dev_lookup>
  800911:	83 c4 10             	add    $0x10,%esp
  800914:	85 c0                	test   %eax,%eax
  800916:	78 37                	js     80094f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800918:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80091b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80091f:	74 32                	je     800953 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800921:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800924:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80092b:	00 00 00 
	stat->st_isdir = 0;
  80092e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800935:	00 00 00 
	stat->st_dev = dev;
  800938:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80093e:	83 ec 08             	sub    $0x8,%esp
  800941:	53                   	push   %ebx
  800942:	ff 75 f0             	pushl  -0x10(%ebp)
  800945:	ff 50 14             	call   *0x14(%eax)
  800948:	89 c2                	mov    %eax,%edx
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	eb 09                	jmp    800958 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80094f:	89 c2                	mov    %eax,%edx
  800951:	eb 05                	jmp    800958 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800953:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800958:	89 d0                	mov    %edx,%eax
  80095a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800964:	83 ec 08             	sub    $0x8,%esp
  800967:	6a 00                	push   $0x0
  800969:	ff 75 08             	pushl  0x8(%ebp)
  80096c:	e8 09 02 00 00       	call   800b7a <open>
  800971:	89 c3                	mov    %eax,%ebx
  800973:	83 c4 10             	add    $0x10,%esp
  800976:	85 db                	test   %ebx,%ebx
  800978:	78 1b                	js     800995 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80097a:	83 ec 08             	sub    $0x8,%esp
  80097d:	ff 75 0c             	pushl  0xc(%ebp)
  800980:	53                   	push   %ebx
  800981:	e8 5b ff ff ff       	call   8008e1 <fstat>
  800986:	89 c6                	mov    %eax,%esi
	close(fd);
  800988:	89 1c 24             	mov    %ebx,(%esp)
  80098b:	e8 fd fb ff ff       	call   80058d <close>
	return r;
  800990:	83 c4 10             	add    $0x10,%esp
  800993:	89 f0                	mov    %esi,%eax
}
  800995:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800998:	5b                   	pop    %ebx
  800999:	5e                   	pop    %esi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	89 c6                	mov    %eax,%esi
  8009a3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009a5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009ac:	75 12                	jne    8009c0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009ae:	83 ec 0c             	sub    $0xc,%esp
  8009b1:	6a 01                	push   $0x1
  8009b3:	e8 1d 16 00 00       	call   801fd5 <ipc_find_env>
  8009b8:	a3 00 40 80 00       	mov    %eax,0x804000
  8009bd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009c0:	6a 07                	push   $0x7
  8009c2:	68 00 50 80 00       	push   $0x805000
  8009c7:	56                   	push   %esi
  8009c8:	ff 35 00 40 80 00    	pushl  0x804000
  8009ce:	e8 ae 15 00 00       	call   801f81 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009d3:	83 c4 0c             	add    $0xc,%esp
  8009d6:	6a 00                	push   $0x0
  8009d8:	53                   	push   %ebx
  8009d9:	6a 00                	push   $0x0
  8009db:	e8 38 15 00 00       	call   801f18 <ipc_recv>
}
  8009e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009e3:	5b                   	pop    %ebx
  8009e4:	5e                   	pop    %esi
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a00:	ba 00 00 00 00       	mov    $0x0,%edx
  800a05:	b8 02 00 00 00       	mov    $0x2,%eax
  800a0a:	e8 8d ff ff ff       	call   80099c <fsipc>
}
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
  800a27:	b8 06 00 00 00       	mov    $0x6,%eax
  800a2c:	e8 6b ff ff ff       	call   80099c <fsipc>
}
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	53                   	push   %ebx
  800a37:	83 ec 04             	sub    $0x4,%esp
  800a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	8b 40 0c             	mov    0xc(%eax),%eax
  800a43:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a48:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4d:	b8 05 00 00 00       	mov    $0x5,%eax
  800a52:	e8 45 ff ff ff       	call   80099c <fsipc>
  800a57:	89 c2                	mov    %eax,%edx
  800a59:	85 d2                	test   %edx,%edx
  800a5b:	78 2c                	js     800a89 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a5d:	83 ec 08             	sub    $0x8,%esp
  800a60:	68 00 50 80 00       	push   $0x805000
  800a65:	53                   	push   %ebx
  800a66:	e8 60 11 00 00       	call   801bcb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a6b:	a1 80 50 80 00       	mov    0x805080,%eax
  800a70:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a76:	a1 84 50 80 00       	mov    0x805084,%eax
  800a7b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a81:	83 c4 10             	add    $0x10,%esp
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a8c:	c9                   	leave  
  800a8d:	c3                   	ret    

00800a8e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	57                   	push   %edi
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
  800a94:	83 ec 0c             	sub    $0xc,%esp
  800a97:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9d:	8b 40 0c             	mov    0xc(%eax),%eax
  800aa0:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800aa5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800aa8:	eb 3d                	jmp    800ae7 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800aaa:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800ab0:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800ab5:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800ab8:	83 ec 04             	sub    $0x4,%esp
  800abb:	57                   	push   %edi
  800abc:	53                   	push   %ebx
  800abd:	68 08 50 80 00       	push   $0x805008
  800ac2:	e8 96 12 00 00       	call   801d5d <memmove>
                fsipcbuf.write.req_n = tmp; 
  800ac7:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800acd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ad7:	e8 c0 fe ff ff       	call   80099c <fsipc>
  800adc:	83 c4 10             	add    $0x10,%esp
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	78 0d                	js     800af0 <devfile_write+0x62>
		        return r;
                n -= tmp;
  800ae3:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800ae5:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800ae7:	85 f6                	test   %esi,%esi
  800ae9:	75 bf                	jne    800aaa <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800aeb:	89 d8                	mov    %ebx,%eax
  800aed:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800af0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af3:	5b                   	pop    %ebx
  800af4:	5e                   	pop    %esi
  800af5:	5f                   	pop    %edi
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 40 0c             	mov    0xc(%eax),%eax
  800b06:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b0b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b11:	ba 00 00 00 00       	mov    $0x0,%edx
  800b16:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1b:	e8 7c fe ff ff       	call   80099c <fsipc>
  800b20:	89 c3                	mov    %eax,%ebx
  800b22:	85 c0                	test   %eax,%eax
  800b24:	78 4b                	js     800b71 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b26:	39 c6                	cmp    %eax,%esi
  800b28:	73 16                	jae    800b40 <devfile_read+0x48>
  800b2a:	68 c8 23 80 00       	push   $0x8023c8
  800b2f:	68 cf 23 80 00       	push   $0x8023cf
  800b34:	6a 7c                	push   $0x7c
  800b36:	68 e4 23 80 00       	push   $0x8023e4
  800b3b:	e8 2b 0a 00 00       	call   80156b <_panic>
	assert(r <= PGSIZE);
  800b40:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b45:	7e 16                	jle    800b5d <devfile_read+0x65>
  800b47:	68 ef 23 80 00       	push   $0x8023ef
  800b4c:	68 cf 23 80 00       	push   $0x8023cf
  800b51:	6a 7d                	push   $0x7d
  800b53:	68 e4 23 80 00       	push   $0x8023e4
  800b58:	e8 0e 0a 00 00       	call   80156b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b5d:	83 ec 04             	sub    $0x4,%esp
  800b60:	50                   	push   %eax
  800b61:	68 00 50 80 00       	push   $0x805000
  800b66:	ff 75 0c             	pushl  0xc(%ebp)
  800b69:	e8 ef 11 00 00       	call   801d5d <memmove>
	return r;
  800b6e:	83 c4 10             	add    $0x10,%esp
}
  800b71:	89 d8                	mov    %ebx,%eax
  800b73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 20             	sub    $0x20,%esp
  800b81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b84:	53                   	push   %ebx
  800b85:	e8 08 10 00 00       	call   801b92 <strlen>
  800b8a:	83 c4 10             	add    $0x10,%esp
  800b8d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b92:	7f 67                	jg     800bfb <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b94:	83 ec 0c             	sub    $0xc,%esp
  800b97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b9a:	50                   	push   %eax
  800b9b:	e8 6f f8 ff ff       	call   80040f <fd_alloc>
  800ba0:	83 c4 10             	add    $0x10,%esp
		return r;
  800ba3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ba5:	85 c0                	test   %eax,%eax
  800ba7:	78 57                	js     800c00 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ba9:	83 ec 08             	sub    $0x8,%esp
  800bac:	53                   	push   %ebx
  800bad:	68 00 50 80 00       	push   $0x805000
  800bb2:	e8 14 10 00 00       	call   801bcb <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bba:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bbf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bc2:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc7:	e8 d0 fd ff ff       	call   80099c <fsipc>
  800bcc:	89 c3                	mov    %eax,%ebx
  800bce:	83 c4 10             	add    $0x10,%esp
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	79 14                	jns    800be9 <open+0x6f>
		fd_close(fd, 0);
  800bd5:	83 ec 08             	sub    $0x8,%esp
  800bd8:	6a 00                	push   $0x0
  800bda:	ff 75 f4             	pushl  -0xc(%ebp)
  800bdd:	e8 2a f9 ff ff       	call   80050c <fd_close>
		return r;
  800be2:	83 c4 10             	add    $0x10,%esp
  800be5:	89 da                	mov    %ebx,%edx
  800be7:	eb 17                	jmp    800c00 <open+0x86>
	}

	return fd2num(fd);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	ff 75 f4             	pushl  -0xc(%ebp)
  800bef:	e8 f4 f7 ff ff       	call   8003e8 <fd2num>
  800bf4:	89 c2                	mov    %eax,%edx
  800bf6:	83 c4 10             	add    $0x10,%esp
  800bf9:	eb 05                	jmp    800c00 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bfb:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c00:	89 d0                	mov    %edx,%eax
  800c02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 08 00 00 00       	mov    $0x8,%eax
  800c17:	e8 80 fd ff ff       	call   80099c <fsipc>
}
  800c1c:	c9                   	leave  
  800c1d:	c3                   	ret    

00800c1e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c24:	68 fb 23 80 00       	push   $0x8023fb
  800c29:	ff 75 0c             	pushl  0xc(%ebp)
  800c2c:	e8 9a 0f 00 00       	call   801bcb <strcpy>
	return 0;
}
  800c31:	b8 00 00 00 00       	mov    $0x0,%eax
  800c36:	c9                   	leave  
  800c37:	c3                   	ret    

00800c38 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 10             	sub    $0x10,%esp
  800c3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c42:	53                   	push   %ebx
  800c43:	e8 c5 13 00 00       	call   80200d <pageref>
  800c48:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c50:	83 f8 01             	cmp    $0x1,%eax
  800c53:	75 10                	jne    800c65 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c55:	83 ec 0c             	sub    $0xc,%esp
  800c58:	ff 73 0c             	pushl  0xc(%ebx)
  800c5b:	e8 ca 02 00 00       	call   800f2a <nsipc_close>
  800c60:	89 c2                	mov    %eax,%edx
  800c62:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c65:	89 d0                	mov    %edx,%eax
  800c67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c72:	6a 00                	push   $0x0
  800c74:	ff 75 10             	pushl  0x10(%ebp)
  800c77:	ff 75 0c             	pushl  0xc(%ebp)
  800c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7d:	ff 70 0c             	pushl  0xc(%eax)
  800c80:	e8 82 03 00 00       	call   801007 <nsipc_send>
}
  800c85:	c9                   	leave  
  800c86:	c3                   	ret    

00800c87 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c8d:	6a 00                	push   $0x0
  800c8f:	ff 75 10             	pushl  0x10(%ebp)
  800c92:	ff 75 0c             	pushl  0xc(%ebp)
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	ff 70 0c             	pushl  0xc(%eax)
  800c9b:	e8 fb 02 00 00       	call   800f9b <nsipc_recv>
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    

00800ca2 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800ca8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800cab:	52                   	push   %edx
  800cac:	50                   	push   %eax
  800cad:	e8 ac f7 ff ff       	call   80045e <fd_lookup>
  800cb2:	83 c4 10             	add    $0x10,%esp
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	78 17                	js     800cd0 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbc:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800cc2:	39 08                	cmp    %ecx,(%eax)
  800cc4:	75 05                	jne    800ccb <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800cc6:	8b 40 0c             	mov    0xc(%eax),%eax
  800cc9:	eb 05                	jmp    800cd0 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800ccb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800cd0:	c9                   	leave  
  800cd1:	c3                   	ret    

00800cd2 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 1c             	sub    $0x1c,%esp
  800cda:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800cdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cdf:	50                   	push   %eax
  800ce0:	e8 2a f7 ff ff       	call   80040f <fd_alloc>
  800ce5:	89 c3                	mov    %eax,%ebx
  800ce7:	83 c4 10             	add    $0x10,%esp
  800cea:	85 c0                	test   %eax,%eax
  800cec:	78 1b                	js     800d09 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cee:	83 ec 04             	sub    $0x4,%esp
  800cf1:	68 07 04 00 00       	push   $0x407
  800cf6:	ff 75 f4             	pushl  -0xc(%ebp)
  800cf9:	6a 00                	push   $0x0
  800cfb:	e8 56 f4 ff ff       	call   800156 <sys_page_alloc>
  800d00:	89 c3                	mov    %eax,%ebx
  800d02:	83 c4 10             	add    $0x10,%esp
  800d05:	85 c0                	test   %eax,%eax
  800d07:	79 10                	jns    800d19 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d09:	83 ec 0c             	sub    $0xc,%esp
  800d0c:	56                   	push   %esi
  800d0d:	e8 18 02 00 00       	call   800f2a <nsipc_close>
		return r;
  800d12:	83 c4 10             	add    $0x10,%esp
  800d15:	89 d8                	mov    %ebx,%eax
  800d17:	eb 24                	jmp    800d3d <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d19:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d22:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d27:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  800d2e:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	52                   	push   %edx
  800d35:	e8 ae f6 ff ff       	call   8003e8 <fd2num>
  800d3a:	83 c4 10             	add    $0x10,%esp
}
  800d3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	e8 50 ff ff ff       	call   800ca2 <fd2sockid>
		return r;
  800d52:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d54:	85 c0                	test   %eax,%eax
  800d56:	78 1f                	js     800d77 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d58:	83 ec 04             	sub    $0x4,%esp
  800d5b:	ff 75 10             	pushl  0x10(%ebp)
  800d5e:	ff 75 0c             	pushl  0xc(%ebp)
  800d61:	50                   	push   %eax
  800d62:	e8 1c 01 00 00       	call   800e83 <nsipc_accept>
  800d67:	83 c4 10             	add    $0x10,%esp
		return r;
  800d6a:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	78 07                	js     800d77 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d70:	e8 5d ff ff ff       	call   800cd2 <alloc_sockfd>
  800d75:	89 c1                	mov    %eax,%ecx
}
  800d77:	89 c8                	mov    %ecx,%eax
  800d79:	c9                   	leave  
  800d7a:	c3                   	ret    

00800d7b <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	e8 19 ff ff ff       	call   800ca2 <fd2sockid>
  800d89:	89 c2                	mov    %eax,%edx
  800d8b:	85 d2                	test   %edx,%edx
  800d8d:	78 12                	js     800da1 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  800d8f:	83 ec 04             	sub    $0x4,%esp
  800d92:	ff 75 10             	pushl  0x10(%ebp)
  800d95:	ff 75 0c             	pushl  0xc(%ebp)
  800d98:	52                   	push   %edx
  800d99:	e8 35 01 00 00       	call   800ed3 <nsipc_bind>
  800d9e:	83 c4 10             	add    $0x10,%esp
}
  800da1:	c9                   	leave  
  800da2:	c3                   	ret    

00800da3 <shutdown>:

int
shutdown(int s, int how)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	e8 f1 fe ff ff       	call   800ca2 <fd2sockid>
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	85 d2                	test   %edx,%edx
  800db5:	78 0f                	js     800dc6 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  800db7:	83 ec 08             	sub    $0x8,%esp
  800dba:	ff 75 0c             	pushl  0xc(%ebp)
  800dbd:	52                   	push   %edx
  800dbe:	e8 45 01 00 00       	call   800f08 <nsipc_shutdown>
  800dc3:	83 c4 10             	add    $0x10,%esp
}
  800dc6:	c9                   	leave  
  800dc7:	c3                   	ret    

00800dc8 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd1:	e8 cc fe ff ff       	call   800ca2 <fd2sockid>
  800dd6:	89 c2                	mov    %eax,%edx
  800dd8:	85 d2                	test   %edx,%edx
  800dda:	78 12                	js     800dee <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  800ddc:	83 ec 04             	sub    $0x4,%esp
  800ddf:	ff 75 10             	pushl  0x10(%ebp)
  800de2:	ff 75 0c             	pushl  0xc(%ebp)
  800de5:	52                   	push   %edx
  800de6:	e8 59 01 00 00       	call   800f44 <nsipc_connect>
  800deb:	83 c4 10             	add    $0x10,%esp
}
  800dee:	c9                   	leave  
  800def:	c3                   	ret    

00800df0 <listen>:

int
listen(int s, int backlog)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	e8 a4 fe ff ff       	call   800ca2 <fd2sockid>
  800dfe:	89 c2                	mov    %eax,%edx
  800e00:	85 d2                	test   %edx,%edx
  800e02:	78 0f                	js     800e13 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  800e04:	83 ec 08             	sub    $0x8,%esp
  800e07:	ff 75 0c             	pushl  0xc(%ebp)
  800e0a:	52                   	push   %edx
  800e0b:	e8 69 01 00 00       	call   800f79 <nsipc_listen>
  800e10:	83 c4 10             	add    $0x10,%esp
}
  800e13:	c9                   	leave  
  800e14:	c3                   	ret    

00800e15 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e1b:	ff 75 10             	pushl  0x10(%ebp)
  800e1e:	ff 75 0c             	pushl  0xc(%ebp)
  800e21:	ff 75 08             	pushl  0x8(%ebp)
  800e24:	e8 3c 02 00 00       	call   801065 <nsipc_socket>
  800e29:	89 c2                	mov    %eax,%edx
  800e2b:	83 c4 10             	add    $0x10,%esp
  800e2e:	85 d2                	test   %edx,%edx
  800e30:	78 05                	js     800e37 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  800e32:	e8 9b fe ff ff       	call   800cd2 <alloc_sockfd>
}
  800e37:	c9                   	leave  
  800e38:	c3                   	ret    

00800e39 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	53                   	push   %ebx
  800e3d:	83 ec 04             	sub    $0x4,%esp
  800e40:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e42:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e49:	75 12                	jne    800e5d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	6a 02                	push   $0x2
  800e50:	e8 80 11 00 00       	call   801fd5 <ipc_find_env>
  800e55:	a3 04 40 80 00       	mov    %eax,0x804004
  800e5a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e5d:	6a 07                	push   $0x7
  800e5f:	68 00 60 80 00       	push   $0x806000
  800e64:	53                   	push   %ebx
  800e65:	ff 35 04 40 80 00    	pushl  0x804004
  800e6b:	e8 11 11 00 00       	call   801f81 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e70:	83 c4 0c             	add    $0xc,%esp
  800e73:	6a 00                	push   $0x0
  800e75:	6a 00                	push   $0x0
  800e77:	6a 00                	push   $0x0
  800e79:	e8 9a 10 00 00       	call   801f18 <ipc_recv>
}
  800e7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e81:	c9                   	leave  
  800e82:	c3                   	ret    

00800e83 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e93:	8b 06                	mov    (%esi),%eax
  800e95:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e9a:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9f:	e8 95 ff ff ff       	call   800e39 <nsipc>
  800ea4:	89 c3                	mov    %eax,%ebx
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	78 20                	js     800eca <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800eaa:	83 ec 04             	sub    $0x4,%esp
  800ead:	ff 35 10 60 80 00    	pushl  0x806010
  800eb3:	68 00 60 80 00       	push   $0x806000
  800eb8:	ff 75 0c             	pushl  0xc(%ebp)
  800ebb:	e8 9d 0e 00 00       	call   801d5d <memmove>
		*addrlen = ret->ret_addrlen;
  800ec0:	a1 10 60 80 00       	mov    0x806010,%eax
  800ec5:	89 06                	mov    %eax,(%esi)
  800ec7:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800eca:	89 d8                	mov    %ebx,%eax
  800ecc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	53                   	push   %ebx
  800ed7:	83 ec 08             	sub    $0x8,%esp
  800eda:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ee5:	53                   	push   %ebx
  800ee6:	ff 75 0c             	pushl  0xc(%ebp)
  800ee9:	68 04 60 80 00       	push   $0x806004
  800eee:	e8 6a 0e 00 00       	call   801d5d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800ef3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800ef9:	b8 02 00 00 00       	mov    $0x2,%eax
  800efe:	e8 36 ff ff ff       	call   800e39 <nsipc>
}
  800f03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f06:	c9                   	leave  
  800f07:	c3                   	ret    

00800f08 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f11:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f19:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800f23:	e8 11 ff ff ff       	call   800e39 <nsipc>
}
  800f28:	c9                   	leave  
  800f29:	c3                   	ret    

00800f2a <nsipc_close>:

int
nsipc_close(int s)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
  800f33:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f38:	b8 04 00 00 00       	mov    $0x4,%eax
  800f3d:	e8 f7 fe ff ff       	call   800e39 <nsipc>
}
  800f42:	c9                   	leave  
  800f43:	c3                   	ret    

00800f44 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	53                   	push   %ebx
  800f48:	83 ec 08             	sub    $0x8,%esp
  800f4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f51:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f56:	53                   	push   %ebx
  800f57:	ff 75 0c             	pushl  0xc(%ebp)
  800f5a:	68 04 60 80 00       	push   $0x806004
  800f5f:	e8 f9 0d 00 00       	call   801d5d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f64:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f6f:	e8 c5 fe ff ff       	call   800e39 <nsipc>
}
  800f74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f77:	c9                   	leave  
  800f78:	c3                   	ret    

00800f79 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f82:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f8f:	b8 06 00 00 00       	mov    $0x6,%eax
  800f94:	e8 a0 fe ff ff       	call   800e39 <nsipc>
}
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    

00800f9b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	56                   	push   %esi
  800f9f:	53                   	push   %ebx
  800fa0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800fab:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800fb1:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb4:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800fb9:	b8 07 00 00 00       	mov    $0x7,%eax
  800fbe:	e8 76 fe ff ff       	call   800e39 <nsipc>
  800fc3:	89 c3                	mov    %eax,%ebx
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	78 35                	js     800ffe <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800fc9:	39 f0                	cmp    %esi,%eax
  800fcb:	7f 07                	jg     800fd4 <nsipc_recv+0x39>
  800fcd:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800fd2:	7e 16                	jle    800fea <nsipc_recv+0x4f>
  800fd4:	68 07 24 80 00       	push   $0x802407
  800fd9:	68 cf 23 80 00       	push   $0x8023cf
  800fde:	6a 62                	push   $0x62
  800fe0:	68 1c 24 80 00       	push   $0x80241c
  800fe5:	e8 81 05 00 00       	call   80156b <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fea:	83 ec 04             	sub    $0x4,%esp
  800fed:	50                   	push   %eax
  800fee:	68 00 60 80 00       	push   $0x806000
  800ff3:	ff 75 0c             	pushl  0xc(%ebp)
  800ff6:	e8 62 0d 00 00       	call   801d5d <memmove>
  800ffb:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800ffe:	89 d8                	mov    %ebx,%eax
  801000:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801003:	5b                   	pop    %ebx
  801004:	5e                   	pop    %esi
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	53                   	push   %ebx
  80100b:	83 ec 04             	sub    $0x4,%esp
  80100e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801011:	8b 45 08             	mov    0x8(%ebp),%eax
  801014:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801019:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80101f:	7e 16                	jle    801037 <nsipc_send+0x30>
  801021:	68 28 24 80 00       	push   $0x802428
  801026:	68 cf 23 80 00       	push   $0x8023cf
  80102b:	6a 6d                	push   $0x6d
  80102d:	68 1c 24 80 00       	push   $0x80241c
  801032:	e8 34 05 00 00       	call   80156b <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801037:	83 ec 04             	sub    $0x4,%esp
  80103a:	53                   	push   %ebx
  80103b:	ff 75 0c             	pushl  0xc(%ebp)
  80103e:	68 0c 60 80 00       	push   $0x80600c
  801043:	e8 15 0d 00 00       	call   801d5d <memmove>
	nsipcbuf.send.req_size = size;
  801048:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80104e:	8b 45 14             	mov    0x14(%ebp),%eax
  801051:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801056:	b8 08 00 00 00       	mov    $0x8,%eax
  80105b:	e8 d9 fd ff ff       	call   800e39 <nsipc>
}
  801060:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801063:	c9                   	leave  
  801064:	c3                   	ret    

00801065 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80106b:	8b 45 08             	mov    0x8(%ebp),%eax
  80106e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801073:	8b 45 0c             	mov    0xc(%ebp),%eax
  801076:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80107b:	8b 45 10             	mov    0x10(%ebp),%eax
  80107e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801083:	b8 09 00 00 00       	mov    $0x9,%eax
  801088:	e8 ac fd ff ff       	call   800e39 <nsipc>
}
  80108d:	c9                   	leave  
  80108e:	c3                   	ret    

0080108f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	56                   	push   %esi
  801093:	53                   	push   %ebx
  801094:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	ff 75 08             	pushl  0x8(%ebp)
  80109d:	e8 56 f3 ff ff       	call   8003f8 <fd2data>
  8010a2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010a4:	83 c4 08             	add    $0x8,%esp
  8010a7:	68 34 24 80 00       	push   $0x802434
  8010ac:	53                   	push   %ebx
  8010ad:	e8 19 0b 00 00       	call   801bcb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010b2:	8b 56 04             	mov    0x4(%esi),%edx
  8010b5:	89 d0                	mov    %edx,%eax
  8010b7:	2b 06                	sub    (%esi),%eax
  8010b9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8010bf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8010c6:	00 00 00 
	stat->st_dev = &devpipe;
  8010c9:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8010d0:	30 80 00 
	return 0;
}
  8010d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	53                   	push   %ebx
  8010e3:	83 ec 0c             	sub    $0xc,%esp
  8010e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010e9:	53                   	push   %ebx
  8010ea:	6a 00                	push   $0x0
  8010ec:	e8 ea f0 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010f1:	89 1c 24             	mov    %ebx,(%esp)
  8010f4:	e8 ff f2 ff ff       	call   8003f8 <fd2data>
  8010f9:	83 c4 08             	add    $0x8,%esp
  8010fc:	50                   	push   %eax
  8010fd:	6a 00                	push   $0x0
  8010ff:	e8 d7 f0 ff ff       	call   8001db <sys_page_unmap>
}
  801104:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	57                   	push   %edi
  80110d:	56                   	push   %esi
  80110e:	53                   	push   %ebx
  80110f:	83 ec 1c             	sub    $0x1c,%esp
  801112:	89 c6                	mov    %eax,%esi
  801114:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801117:	a1 08 40 80 00       	mov    0x804008,%eax
  80111c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	56                   	push   %esi
  801123:	e8 e5 0e 00 00       	call   80200d <pageref>
  801128:	89 c7                	mov    %eax,%edi
  80112a:	83 c4 04             	add    $0x4,%esp
  80112d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801130:	e8 d8 0e 00 00       	call   80200d <pageref>
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	39 c7                	cmp    %eax,%edi
  80113a:	0f 94 c2             	sete   %dl
  80113d:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801140:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801146:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801149:	39 fb                	cmp    %edi,%ebx
  80114b:	74 19                	je     801166 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  80114d:	84 d2                	test   %dl,%dl
  80114f:	74 c6                	je     801117 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801151:	8b 51 58             	mov    0x58(%ecx),%edx
  801154:	50                   	push   %eax
  801155:	52                   	push   %edx
  801156:	53                   	push   %ebx
  801157:	68 3b 24 80 00       	push   $0x80243b
  80115c:	e8 e3 04 00 00       	call   801644 <cprintf>
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	eb b1                	jmp    801117 <_pipeisclosed+0xe>
	}
}
  801166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 28             	sub    $0x28,%esp
  801177:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80117a:	56                   	push   %esi
  80117b:	e8 78 f2 ff ff       	call   8003f8 <fd2data>
  801180:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	bf 00 00 00 00       	mov    $0x0,%edi
  80118a:	eb 4b                	jmp    8011d7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80118c:	89 da                	mov    %ebx,%edx
  80118e:	89 f0                	mov    %esi,%eax
  801190:	e8 74 ff ff ff       	call   801109 <_pipeisclosed>
  801195:	85 c0                	test   %eax,%eax
  801197:	75 48                	jne    8011e1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801199:	e8 99 ef ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80119e:	8b 43 04             	mov    0x4(%ebx),%eax
  8011a1:	8b 0b                	mov    (%ebx),%ecx
  8011a3:	8d 51 20             	lea    0x20(%ecx),%edx
  8011a6:	39 d0                	cmp    %edx,%eax
  8011a8:	73 e2                	jae    80118c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ad:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011b1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8011b4:	89 c2                	mov    %eax,%edx
  8011b6:	c1 fa 1f             	sar    $0x1f,%edx
  8011b9:	89 d1                	mov    %edx,%ecx
  8011bb:	c1 e9 1b             	shr    $0x1b,%ecx
  8011be:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8011c1:	83 e2 1f             	and    $0x1f,%edx
  8011c4:	29 ca                	sub    %ecx,%edx
  8011c6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8011ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011ce:	83 c0 01             	add    $0x1,%eax
  8011d1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d4:	83 c7 01             	add    $0x1,%edi
  8011d7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011da:	75 c2                	jne    80119e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8011df:	eb 05                	jmp    8011e6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011e1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e9:	5b                   	pop    %ebx
  8011ea:	5e                   	pop    %esi
  8011eb:	5f                   	pop    %edi
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 18             	sub    $0x18,%esp
  8011f7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011fa:	57                   	push   %edi
  8011fb:	e8 f8 f1 ff ff       	call   8003f8 <fd2data>
  801200:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120a:	eb 3d                	jmp    801249 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80120c:	85 db                	test   %ebx,%ebx
  80120e:	74 04                	je     801214 <devpipe_read+0x26>
				return i;
  801210:	89 d8                	mov    %ebx,%eax
  801212:	eb 44                	jmp    801258 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801214:	89 f2                	mov    %esi,%edx
  801216:	89 f8                	mov    %edi,%eax
  801218:	e8 ec fe ff ff       	call   801109 <_pipeisclosed>
  80121d:	85 c0                	test   %eax,%eax
  80121f:	75 32                	jne    801253 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801221:	e8 11 ef ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801226:	8b 06                	mov    (%esi),%eax
  801228:	3b 46 04             	cmp    0x4(%esi),%eax
  80122b:	74 df                	je     80120c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80122d:	99                   	cltd   
  80122e:	c1 ea 1b             	shr    $0x1b,%edx
  801231:	01 d0                	add    %edx,%eax
  801233:	83 e0 1f             	and    $0x1f,%eax
  801236:	29 d0                	sub    %edx,%eax
  801238:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80123d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801240:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801243:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801246:	83 c3 01             	add    $0x1,%ebx
  801249:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80124c:	75 d8                	jne    801226 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80124e:	8b 45 10             	mov    0x10(%ebp),%eax
  801251:	eb 05                	jmp    801258 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801253:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801258:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125b:	5b                   	pop    %ebx
  80125c:	5e                   	pop    %esi
  80125d:	5f                   	pop    %edi
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801268:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126b:	50                   	push   %eax
  80126c:	e8 9e f1 ff ff       	call   80040f <fd_alloc>
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	89 c2                	mov    %eax,%edx
  801276:	85 c0                	test   %eax,%eax
  801278:	0f 88 2c 01 00 00    	js     8013aa <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127e:	83 ec 04             	sub    $0x4,%esp
  801281:	68 07 04 00 00       	push   $0x407
  801286:	ff 75 f4             	pushl  -0xc(%ebp)
  801289:	6a 00                	push   $0x0
  80128b:	e8 c6 ee ff ff       	call   800156 <sys_page_alloc>
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	89 c2                	mov    %eax,%edx
  801295:	85 c0                	test   %eax,%eax
  801297:	0f 88 0d 01 00 00    	js     8013aa <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80129d:	83 ec 0c             	sub    $0xc,%esp
  8012a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a3:	50                   	push   %eax
  8012a4:	e8 66 f1 ff ff       	call   80040f <fd_alloc>
  8012a9:	89 c3                	mov    %eax,%ebx
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	0f 88 e2 00 00 00    	js     801398 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012b6:	83 ec 04             	sub    $0x4,%esp
  8012b9:	68 07 04 00 00       	push   $0x407
  8012be:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c1:	6a 00                	push   $0x0
  8012c3:	e8 8e ee ff ff       	call   800156 <sys_page_alloc>
  8012c8:	89 c3                	mov    %eax,%ebx
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	0f 88 c3 00 00 00    	js     801398 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012d5:	83 ec 0c             	sub    $0xc,%esp
  8012d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8012db:	e8 18 f1 ff ff       	call   8003f8 <fd2data>
  8012e0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012e2:	83 c4 0c             	add    $0xc,%esp
  8012e5:	68 07 04 00 00       	push   $0x407
  8012ea:	50                   	push   %eax
  8012eb:	6a 00                	push   $0x0
  8012ed:	e8 64 ee ff ff       	call   800156 <sys_page_alloc>
  8012f2:	89 c3                	mov    %eax,%ebx
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	0f 88 89 00 00 00    	js     801388 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ff:	83 ec 0c             	sub    $0xc,%esp
  801302:	ff 75 f0             	pushl  -0x10(%ebp)
  801305:	e8 ee f0 ff ff       	call   8003f8 <fd2data>
  80130a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801311:	50                   	push   %eax
  801312:	6a 00                	push   $0x0
  801314:	56                   	push   %esi
  801315:	6a 00                	push   $0x0
  801317:	e8 7d ee ff ff       	call   800199 <sys_page_map>
  80131c:	89 c3                	mov    %eax,%ebx
  80131e:	83 c4 20             	add    $0x20,%esp
  801321:	85 c0                	test   %eax,%eax
  801323:	78 55                	js     80137a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801325:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80132b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801330:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801333:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80133a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801340:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801343:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801345:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801348:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	ff 75 f4             	pushl  -0xc(%ebp)
  801355:	e8 8e f0 ff ff       	call   8003e8 <fd2num>
  80135a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80135d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80135f:	83 c4 04             	add    $0x4,%esp
  801362:	ff 75 f0             	pushl  -0x10(%ebp)
  801365:	e8 7e f0 ff ff       	call   8003e8 <fd2num>
  80136a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80136d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	ba 00 00 00 00       	mov    $0x0,%edx
  801378:	eb 30                	jmp    8013aa <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80137a:	83 ec 08             	sub    $0x8,%esp
  80137d:	56                   	push   %esi
  80137e:	6a 00                	push   $0x0
  801380:	e8 56 ee ff ff       	call   8001db <sys_page_unmap>
  801385:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	ff 75 f0             	pushl  -0x10(%ebp)
  80138e:	6a 00                	push   $0x0
  801390:	e8 46 ee ff ff       	call   8001db <sys_page_unmap>
  801395:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801398:	83 ec 08             	sub    $0x8,%esp
  80139b:	ff 75 f4             	pushl  -0xc(%ebp)
  80139e:	6a 00                	push   $0x0
  8013a0:	e8 36 ee ff ff       	call   8001db <sys_page_unmap>
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013aa:	89 d0                	mov    %edx,%eax
  8013ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013af:	5b                   	pop    %ebx
  8013b0:	5e                   	pop    %esi
  8013b1:	5d                   	pop    %ebp
  8013b2:	c3                   	ret    

008013b3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	ff 75 08             	pushl  0x8(%ebp)
  8013c0:	e8 99 f0 ff ff       	call   80045e <fd_lookup>
  8013c5:	89 c2                	mov    %eax,%edx
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 d2                	test   %edx,%edx
  8013cc:	78 18                	js     8013e6 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d4:	e8 1f f0 ff ff       	call   8003f8 <fd2data>
	return _pipeisclosed(fd, p);
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013de:	e8 26 fd ff ff       	call   801109 <_pipeisclosed>
  8013e3:	83 c4 10             	add    $0x10,%esp
}
  8013e6:	c9                   	leave  
  8013e7:	c3                   	ret    

008013e8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    

008013f2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013f8:	68 53 24 80 00       	push   $0x802453
  8013fd:	ff 75 0c             	pushl  0xc(%ebp)
  801400:	e8 c6 07 00 00       	call   801bcb <strcpy>
	return 0;
}
  801405:	b8 00 00 00 00       	mov    $0x0,%eax
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    

0080140c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	57                   	push   %edi
  801410:	56                   	push   %esi
  801411:	53                   	push   %ebx
  801412:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801418:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80141d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801423:	eb 2d                	jmp    801452 <devcons_write+0x46>
		m = n - tot;
  801425:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801428:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80142a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80142d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801432:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801435:	83 ec 04             	sub    $0x4,%esp
  801438:	53                   	push   %ebx
  801439:	03 45 0c             	add    0xc(%ebp),%eax
  80143c:	50                   	push   %eax
  80143d:	57                   	push   %edi
  80143e:	e8 1a 09 00 00       	call   801d5d <memmove>
		sys_cputs(buf, m);
  801443:	83 c4 08             	add    $0x8,%esp
  801446:	53                   	push   %ebx
  801447:	57                   	push   %edi
  801448:	e8 4d ec ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80144d:	01 de                	add    %ebx,%esi
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	89 f0                	mov    %esi,%eax
  801454:	3b 75 10             	cmp    0x10(%ebp),%esi
  801457:	72 cc                	jb     801425 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801459:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145c:	5b                   	pop    %ebx
  80145d:	5e                   	pop    %esi
  80145e:	5f                   	pop    %edi
  80145f:	5d                   	pop    %ebp
  801460:	c3                   	ret    

00801461 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801467:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80146c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801470:	75 07                	jne    801479 <devcons_read+0x18>
  801472:	eb 28                	jmp    80149c <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801474:	e8 be ec ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801479:	e8 3a ec ff ff       	call   8000b8 <sys_cgetc>
  80147e:	85 c0                	test   %eax,%eax
  801480:	74 f2                	je     801474 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801482:	85 c0                	test   %eax,%eax
  801484:	78 16                	js     80149c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801486:	83 f8 04             	cmp    $0x4,%eax
  801489:	74 0c                	je     801497 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80148b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80148e:	88 02                	mov    %al,(%edx)
	return 1;
  801490:	b8 01 00 00 00       	mov    $0x1,%eax
  801495:	eb 05                	jmp    80149c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801497:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014aa:	6a 01                	push   $0x1
  8014ac:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014af:	50                   	push   %eax
  8014b0:	e8 e5 eb ff ff       	call   80009a <sys_cputs>
  8014b5:	83 c4 10             	add    $0x10,%esp
}
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <getchar>:

int
getchar(void)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014c0:	6a 01                	push   $0x1
  8014c2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	6a 00                	push   $0x0
  8014c8:	e8 00 f2 ff ff       	call   8006cd <read>
	if (r < 0)
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 0f                	js     8014e3 <getchar+0x29>
		return r;
	if (r < 1)
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	7e 06                	jle    8014de <getchar+0x24>
		return -E_EOF;
	return c;
  8014d8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014dc:	eb 05                	jmp    8014e3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014de:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ee:	50                   	push   %eax
  8014ef:	ff 75 08             	pushl  0x8(%ebp)
  8014f2:	e8 67 ef ff ff       	call   80045e <fd_lookup>
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 11                	js     80150f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801501:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801507:	39 10                	cmp    %edx,(%eax)
  801509:	0f 94 c0             	sete   %al
  80150c:	0f b6 c0             	movzbl %al,%eax
}
  80150f:	c9                   	leave  
  801510:	c3                   	ret    

00801511 <opencons>:

int
opencons(void)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801517:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151a:	50                   	push   %eax
  80151b:	e8 ef ee ff ff       	call   80040f <fd_alloc>
  801520:	83 c4 10             	add    $0x10,%esp
		return r;
  801523:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801525:	85 c0                	test   %eax,%eax
  801527:	78 3e                	js     801567 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801529:	83 ec 04             	sub    $0x4,%esp
  80152c:	68 07 04 00 00       	push   $0x407
  801531:	ff 75 f4             	pushl  -0xc(%ebp)
  801534:	6a 00                	push   $0x0
  801536:	e8 1b ec ff ff       	call   800156 <sys_page_alloc>
  80153b:	83 c4 10             	add    $0x10,%esp
		return r;
  80153e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801540:	85 c0                	test   %eax,%eax
  801542:	78 23                	js     801567 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801544:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80154a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80154f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801552:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801559:	83 ec 0c             	sub    $0xc,%esp
  80155c:	50                   	push   %eax
  80155d:	e8 86 ee ff ff       	call   8003e8 <fd2num>
  801562:	89 c2                	mov    %eax,%edx
  801564:	83 c4 10             	add    $0x10,%esp
}
  801567:	89 d0                	mov    %edx,%eax
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	56                   	push   %esi
  80156f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801570:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801573:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801579:	e8 9a eb ff ff       	call   800118 <sys_getenvid>
  80157e:	83 ec 0c             	sub    $0xc,%esp
  801581:	ff 75 0c             	pushl  0xc(%ebp)
  801584:	ff 75 08             	pushl  0x8(%ebp)
  801587:	56                   	push   %esi
  801588:	50                   	push   %eax
  801589:	68 60 24 80 00       	push   $0x802460
  80158e:	e8 b1 00 00 00       	call   801644 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801593:	83 c4 18             	add    $0x18,%esp
  801596:	53                   	push   %ebx
  801597:	ff 75 10             	pushl  0x10(%ebp)
  80159a:	e8 54 00 00 00       	call   8015f3 <vcprintf>
	cprintf("\n");
  80159f:	c7 04 24 4c 24 80 00 	movl   $0x80244c,(%esp)
  8015a6:	e8 99 00 00 00       	call   801644 <cprintf>
  8015ab:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015ae:	cc                   	int3   
  8015af:	eb fd                	jmp    8015ae <_panic+0x43>

008015b1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	53                   	push   %ebx
  8015b5:	83 ec 04             	sub    $0x4,%esp
  8015b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015bb:	8b 13                	mov    (%ebx),%edx
  8015bd:	8d 42 01             	lea    0x1(%edx),%eax
  8015c0:	89 03                	mov    %eax,(%ebx)
  8015c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015c5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8015c9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015ce:	75 1a                	jne    8015ea <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	68 ff 00 00 00       	push   $0xff
  8015d8:	8d 43 08             	lea    0x8(%ebx),%eax
  8015db:	50                   	push   %eax
  8015dc:	e8 b9 ea ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8015e1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015e7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015ea:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801603:	00 00 00 
	b.cnt = 0;
  801606:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80160d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801610:	ff 75 0c             	pushl  0xc(%ebp)
  801613:	ff 75 08             	pushl  0x8(%ebp)
  801616:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	68 b1 15 80 00       	push   $0x8015b1
  801622:	e8 4f 01 00 00       	call   801776 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801627:	83 c4 08             	add    $0x8,%esp
  80162a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801630:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801636:	50                   	push   %eax
  801637:	e8 5e ea ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  80163c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80164a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80164d:	50                   	push   %eax
  80164e:	ff 75 08             	pushl  0x8(%ebp)
  801651:	e8 9d ff ff ff       	call   8015f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  801656:	c9                   	leave  
  801657:	c3                   	ret    

00801658 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	57                   	push   %edi
  80165c:	56                   	push   %esi
  80165d:	53                   	push   %ebx
  80165e:	83 ec 1c             	sub    $0x1c,%esp
  801661:	89 c7                	mov    %eax,%edi
  801663:	89 d6                	mov    %edx,%esi
  801665:	8b 45 08             	mov    0x8(%ebp),%eax
  801668:	8b 55 0c             	mov    0xc(%ebp),%edx
  80166b:	89 d1                	mov    %edx,%ecx
  80166d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801670:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801673:	8b 45 10             	mov    0x10(%ebp),%eax
  801676:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801679:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80167c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801683:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801686:	72 05                	jb     80168d <printnum+0x35>
  801688:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80168b:	77 3e                	ja     8016cb <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80168d:	83 ec 0c             	sub    $0xc,%esp
  801690:	ff 75 18             	pushl  0x18(%ebp)
  801693:	83 eb 01             	sub    $0x1,%ebx
  801696:	53                   	push   %ebx
  801697:	50                   	push   %eax
  801698:	83 ec 08             	sub    $0x8,%esp
  80169b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80169e:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a1:	ff 75 dc             	pushl  -0x24(%ebp)
  8016a4:	ff 75 d8             	pushl  -0x28(%ebp)
  8016a7:	e8 a4 09 00 00       	call   802050 <__udivdi3>
  8016ac:	83 c4 18             	add    $0x18,%esp
  8016af:	52                   	push   %edx
  8016b0:	50                   	push   %eax
  8016b1:	89 f2                	mov    %esi,%edx
  8016b3:	89 f8                	mov    %edi,%eax
  8016b5:	e8 9e ff ff ff       	call   801658 <printnum>
  8016ba:	83 c4 20             	add    $0x20,%esp
  8016bd:	eb 13                	jmp    8016d2 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8016bf:	83 ec 08             	sub    $0x8,%esp
  8016c2:	56                   	push   %esi
  8016c3:	ff 75 18             	pushl  0x18(%ebp)
  8016c6:	ff d7                	call   *%edi
  8016c8:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8016cb:	83 eb 01             	sub    $0x1,%ebx
  8016ce:	85 db                	test   %ebx,%ebx
  8016d0:	7f ed                	jg     8016bf <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016d2:	83 ec 08             	sub    $0x8,%esp
  8016d5:	56                   	push   %esi
  8016d6:	83 ec 04             	sub    $0x4,%esp
  8016d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8016df:	ff 75 dc             	pushl  -0x24(%ebp)
  8016e2:	ff 75 d8             	pushl  -0x28(%ebp)
  8016e5:	e8 96 0a 00 00       	call   802180 <__umoddi3>
  8016ea:	83 c4 14             	add    $0x14,%esp
  8016ed:	0f be 80 83 24 80 00 	movsbl 0x802483(%eax),%eax
  8016f4:	50                   	push   %eax
  8016f5:	ff d7                	call   *%edi
  8016f7:	83 c4 10             	add    $0x10,%esp
}
  8016fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fd:	5b                   	pop    %ebx
  8016fe:	5e                   	pop    %esi
  8016ff:	5f                   	pop    %edi
  801700:	5d                   	pop    %ebp
  801701:	c3                   	ret    

00801702 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801705:	83 fa 01             	cmp    $0x1,%edx
  801708:	7e 0e                	jle    801718 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80170a:	8b 10                	mov    (%eax),%edx
  80170c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80170f:	89 08                	mov    %ecx,(%eax)
  801711:	8b 02                	mov    (%edx),%eax
  801713:	8b 52 04             	mov    0x4(%edx),%edx
  801716:	eb 22                	jmp    80173a <getuint+0x38>
	else if (lflag)
  801718:	85 d2                	test   %edx,%edx
  80171a:	74 10                	je     80172c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80171c:	8b 10                	mov    (%eax),%edx
  80171e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801721:	89 08                	mov    %ecx,(%eax)
  801723:	8b 02                	mov    (%edx),%eax
  801725:	ba 00 00 00 00       	mov    $0x0,%edx
  80172a:	eb 0e                	jmp    80173a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80172c:	8b 10                	mov    (%eax),%edx
  80172e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801731:	89 08                	mov    %ecx,(%eax)
  801733:	8b 02                	mov    (%edx),%eax
  801735:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    

0080173c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801742:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801746:	8b 10                	mov    (%eax),%edx
  801748:	3b 50 04             	cmp    0x4(%eax),%edx
  80174b:	73 0a                	jae    801757 <sprintputch+0x1b>
		*b->buf++ = ch;
  80174d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801750:	89 08                	mov    %ecx,(%eax)
  801752:	8b 45 08             	mov    0x8(%ebp),%eax
  801755:	88 02                	mov    %al,(%edx)
}
  801757:	5d                   	pop    %ebp
  801758:	c3                   	ret    

00801759 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80175f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801762:	50                   	push   %eax
  801763:	ff 75 10             	pushl  0x10(%ebp)
  801766:	ff 75 0c             	pushl  0xc(%ebp)
  801769:	ff 75 08             	pushl  0x8(%ebp)
  80176c:	e8 05 00 00 00       	call   801776 <vprintfmt>
	va_end(ap);
  801771:	83 c4 10             	add    $0x10,%esp
}
  801774:	c9                   	leave  
  801775:	c3                   	ret    

00801776 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	57                   	push   %edi
  80177a:	56                   	push   %esi
  80177b:	53                   	push   %ebx
  80177c:	83 ec 2c             	sub    $0x2c,%esp
  80177f:	8b 75 08             	mov    0x8(%ebp),%esi
  801782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801785:	8b 7d 10             	mov    0x10(%ebp),%edi
  801788:	eb 12                	jmp    80179c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80178a:	85 c0                	test   %eax,%eax
  80178c:	0f 84 90 03 00 00    	je     801b22 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  801792:	83 ec 08             	sub    $0x8,%esp
  801795:	53                   	push   %ebx
  801796:	50                   	push   %eax
  801797:	ff d6                	call   *%esi
  801799:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80179c:	83 c7 01             	add    $0x1,%edi
  80179f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017a3:	83 f8 25             	cmp    $0x25,%eax
  8017a6:	75 e2                	jne    80178a <vprintfmt+0x14>
  8017a8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017ac:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8017b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017ba:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8017c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c6:	eb 07                	jmp    8017cf <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8017cb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017cf:	8d 47 01             	lea    0x1(%edi),%eax
  8017d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017d5:	0f b6 07             	movzbl (%edi),%eax
  8017d8:	0f b6 c8             	movzbl %al,%ecx
  8017db:	83 e8 23             	sub    $0x23,%eax
  8017de:	3c 55                	cmp    $0x55,%al
  8017e0:	0f 87 21 03 00 00    	ja     801b07 <vprintfmt+0x391>
  8017e6:	0f b6 c0             	movzbl %al,%eax
  8017e9:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  8017f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017f3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017f7:	eb d6                	jmp    8017cf <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801801:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801804:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801807:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80180b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80180e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801811:	83 fa 09             	cmp    $0x9,%edx
  801814:	77 39                	ja     80184f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801816:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801819:	eb e9                	jmp    801804 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80181b:	8b 45 14             	mov    0x14(%ebp),%eax
  80181e:	8d 48 04             	lea    0x4(%eax),%ecx
  801821:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801824:	8b 00                	mov    (%eax),%eax
  801826:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801829:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80182c:	eb 27                	jmp    801855 <vprintfmt+0xdf>
  80182e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801831:	85 c0                	test   %eax,%eax
  801833:	b9 00 00 00 00       	mov    $0x0,%ecx
  801838:	0f 49 c8             	cmovns %eax,%ecx
  80183b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801841:	eb 8c                	jmp    8017cf <vprintfmt+0x59>
  801843:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801846:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80184d:	eb 80                	jmp    8017cf <vprintfmt+0x59>
  80184f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801852:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801855:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801859:	0f 89 70 ff ff ff    	jns    8017cf <vprintfmt+0x59>
				width = precision, precision = -1;
  80185f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801862:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801865:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80186c:	e9 5e ff ff ff       	jmp    8017cf <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801871:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801874:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801877:	e9 53 ff ff ff       	jmp    8017cf <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80187c:	8b 45 14             	mov    0x14(%ebp),%eax
  80187f:	8d 50 04             	lea    0x4(%eax),%edx
  801882:	89 55 14             	mov    %edx,0x14(%ebp)
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	53                   	push   %ebx
  801889:	ff 30                	pushl  (%eax)
  80188b:	ff d6                	call   *%esi
			break;
  80188d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801890:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801893:	e9 04 ff ff ff       	jmp    80179c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801898:	8b 45 14             	mov    0x14(%ebp),%eax
  80189b:	8d 50 04             	lea    0x4(%eax),%edx
  80189e:	89 55 14             	mov    %edx,0x14(%ebp)
  8018a1:	8b 00                	mov    (%eax),%eax
  8018a3:	99                   	cltd   
  8018a4:	31 d0                	xor    %edx,%eax
  8018a6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018a8:	83 f8 0f             	cmp    $0xf,%eax
  8018ab:	7f 0b                	jg     8018b8 <vprintfmt+0x142>
  8018ad:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  8018b4:	85 d2                	test   %edx,%edx
  8018b6:	75 18                	jne    8018d0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8018b8:	50                   	push   %eax
  8018b9:	68 9b 24 80 00       	push   $0x80249b
  8018be:	53                   	push   %ebx
  8018bf:	56                   	push   %esi
  8018c0:	e8 94 fe ff ff       	call   801759 <printfmt>
  8018c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8018cb:	e9 cc fe ff ff       	jmp    80179c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018d0:	52                   	push   %edx
  8018d1:	68 e1 23 80 00       	push   $0x8023e1
  8018d6:	53                   	push   %ebx
  8018d7:	56                   	push   %esi
  8018d8:	e8 7c fe ff ff       	call   801759 <printfmt>
  8018dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018e3:	e9 b4 fe ff ff       	jmp    80179c <vprintfmt+0x26>
  8018e8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8018eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018ee:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f4:	8d 50 04             	lea    0x4(%eax),%edx
  8018f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8018fa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018fc:	85 ff                	test   %edi,%edi
  8018fe:	ba 94 24 80 00       	mov    $0x802494,%edx
  801903:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  801906:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80190a:	0f 84 92 00 00 00    	je     8019a2 <vprintfmt+0x22c>
  801910:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801914:	0f 8e 96 00 00 00    	jle    8019b0 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80191a:	83 ec 08             	sub    $0x8,%esp
  80191d:	51                   	push   %ecx
  80191e:	57                   	push   %edi
  80191f:	e8 86 02 00 00       	call   801baa <strnlen>
  801924:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801927:	29 c1                	sub    %eax,%ecx
  801929:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80192c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80192f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801933:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801936:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801939:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80193b:	eb 0f                	jmp    80194c <vprintfmt+0x1d6>
					putch(padc, putdat);
  80193d:	83 ec 08             	sub    $0x8,%esp
  801940:	53                   	push   %ebx
  801941:	ff 75 e0             	pushl  -0x20(%ebp)
  801944:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801946:	83 ef 01             	sub    $0x1,%edi
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 ff                	test   %edi,%edi
  80194e:	7f ed                	jg     80193d <vprintfmt+0x1c7>
  801950:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801953:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801956:	85 c9                	test   %ecx,%ecx
  801958:	b8 00 00 00 00       	mov    $0x0,%eax
  80195d:	0f 49 c1             	cmovns %ecx,%eax
  801960:	29 c1                	sub    %eax,%ecx
  801962:	89 75 08             	mov    %esi,0x8(%ebp)
  801965:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801968:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80196b:	89 cb                	mov    %ecx,%ebx
  80196d:	eb 4d                	jmp    8019bc <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80196f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801973:	74 1b                	je     801990 <vprintfmt+0x21a>
  801975:	0f be c0             	movsbl %al,%eax
  801978:	83 e8 20             	sub    $0x20,%eax
  80197b:	83 f8 5e             	cmp    $0x5e,%eax
  80197e:	76 10                	jbe    801990 <vprintfmt+0x21a>
					putch('?', putdat);
  801980:	83 ec 08             	sub    $0x8,%esp
  801983:	ff 75 0c             	pushl  0xc(%ebp)
  801986:	6a 3f                	push   $0x3f
  801988:	ff 55 08             	call   *0x8(%ebp)
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	eb 0d                	jmp    80199d <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801990:	83 ec 08             	sub    $0x8,%esp
  801993:	ff 75 0c             	pushl  0xc(%ebp)
  801996:	52                   	push   %edx
  801997:	ff 55 08             	call   *0x8(%ebp)
  80199a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80199d:	83 eb 01             	sub    $0x1,%ebx
  8019a0:	eb 1a                	jmp    8019bc <vprintfmt+0x246>
  8019a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8019a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019ae:	eb 0c                	jmp    8019bc <vprintfmt+0x246>
  8019b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8019b3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019b9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019bc:	83 c7 01             	add    $0x1,%edi
  8019bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019c3:	0f be d0             	movsbl %al,%edx
  8019c6:	85 d2                	test   %edx,%edx
  8019c8:	74 23                	je     8019ed <vprintfmt+0x277>
  8019ca:	85 f6                	test   %esi,%esi
  8019cc:	78 a1                	js     80196f <vprintfmt+0x1f9>
  8019ce:	83 ee 01             	sub    $0x1,%esi
  8019d1:	79 9c                	jns    80196f <vprintfmt+0x1f9>
  8019d3:	89 df                	mov    %ebx,%edi
  8019d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8019d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019db:	eb 18                	jmp    8019f5 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019dd:	83 ec 08             	sub    $0x8,%esp
  8019e0:	53                   	push   %ebx
  8019e1:	6a 20                	push   $0x20
  8019e3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019e5:	83 ef 01             	sub    $0x1,%edi
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	eb 08                	jmp    8019f5 <vprintfmt+0x27f>
  8019ed:	89 df                	mov    %ebx,%edi
  8019ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019f5:	85 ff                	test   %edi,%edi
  8019f7:	7f e4                	jg     8019dd <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019fc:	e9 9b fd ff ff       	jmp    80179c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a01:	83 fa 01             	cmp    $0x1,%edx
  801a04:	7e 16                	jle    801a1c <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801a06:	8b 45 14             	mov    0x14(%ebp),%eax
  801a09:	8d 50 08             	lea    0x8(%eax),%edx
  801a0c:	89 55 14             	mov    %edx,0x14(%ebp)
  801a0f:	8b 50 04             	mov    0x4(%eax),%edx
  801a12:	8b 00                	mov    (%eax),%eax
  801a14:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a17:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a1a:	eb 32                	jmp    801a4e <vprintfmt+0x2d8>
	else if (lflag)
  801a1c:	85 d2                	test   %edx,%edx
  801a1e:	74 18                	je     801a38 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801a20:	8b 45 14             	mov    0x14(%ebp),%eax
  801a23:	8d 50 04             	lea    0x4(%eax),%edx
  801a26:	89 55 14             	mov    %edx,0x14(%ebp)
  801a29:	8b 00                	mov    (%eax),%eax
  801a2b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a2e:	89 c1                	mov    %eax,%ecx
  801a30:	c1 f9 1f             	sar    $0x1f,%ecx
  801a33:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a36:	eb 16                	jmp    801a4e <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801a38:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3b:	8d 50 04             	lea    0x4(%eax),%edx
  801a3e:	89 55 14             	mov    %edx,0x14(%ebp)
  801a41:	8b 00                	mov    (%eax),%eax
  801a43:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a46:	89 c1                	mov    %eax,%ecx
  801a48:	c1 f9 1f             	sar    $0x1f,%ecx
  801a4b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a4e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a51:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a54:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a59:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a5d:	79 74                	jns    801ad3 <vprintfmt+0x35d>
				putch('-', putdat);
  801a5f:	83 ec 08             	sub    $0x8,%esp
  801a62:	53                   	push   %ebx
  801a63:	6a 2d                	push   $0x2d
  801a65:	ff d6                	call   *%esi
				num = -(long long) num;
  801a67:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a6a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a6d:	f7 d8                	neg    %eax
  801a6f:	83 d2 00             	adc    $0x0,%edx
  801a72:	f7 da                	neg    %edx
  801a74:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a77:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a7c:	eb 55                	jmp    801ad3 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a7e:	8d 45 14             	lea    0x14(%ebp),%eax
  801a81:	e8 7c fc ff ff       	call   801702 <getuint>
			base = 10;
  801a86:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a8b:	eb 46                	jmp    801ad3 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a8d:	8d 45 14             	lea    0x14(%ebp),%eax
  801a90:	e8 6d fc ff ff       	call   801702 <getuint>
                        base = 8;
  801a95:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a9a:	eb 37                	jmp    801ad3 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801a9c:	83 ec 08             	sub    $0x8,%esp
  801a9f:	53                   	push   %ebx
  801aa0:	6a 30                	push   $0x30
  801aa2:	ff d6                	call   *%esi
			putch('x', putdat);
  801aa4:	83 c4 08             	add    $0x8,%esp
  801aa7:	53                   	push   %ebx
  801aa8:	6a 78                	push   $0x78
  801aaa:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801aac:	8b 45 14             	mov    0x14(%ebp),%eax
  801aaf:	8d 50 04             	lea    0x4(%eax),%edx
  801ab2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ab5:	8b 00                	mov    (%eax),%eax
  801ab7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801abc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801abf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ac4:	eb 0d                	jmp    801ad3 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ac6:	8d 45 14             	lea    0x14(%ebp),%eax
  801ac9:	e8 34 fc ff ff       	call   801702 <getuint>
			base = 16;
  801ace:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ad3:	83 ec 0c             	sub    $0xc,%esp
  801ad6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ada:	57                   	push   %edi
  801adb:	ff 75 e0             	pushl  -0x20(%ebp)
  801ade:	51                   	push   %ecx
  801adf:	52                   	push   %edx
  801ae0:	50                   	push   %eax
  801ae1:	89 da                	mov    %ebx,%edx
  801ae3:	89 f0                	mov    %esi,%eax
  801ae5:	e8 6e fb ff ff       	call   801658 <printnum>
			break;
  801aea:	83 c4 20             	add    $0x20,%esp
  801aed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801af0:	e9 a7 fc ff ff       	jmp    80179c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801af5:	83 ec 08             	sub    $0x8,%esp
  801af8:	53                   	push   %ebx
  801af9:	51                   	push   %ecx
  801afa:	ff d6                	call   *%esi
			break;
  801afc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b02:	e9 95 fc ff ff       	jmp    80179c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b07:	83 ec 08             	sub    $0x8,%esp
  801b0a:	53                   	push   %ebx
  801b0b:	6a 25                	push   $0x25
  801b0d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	eb 03                	jmp    801b17 <vprintfmt+0x3a1>
  801b14:	83 ef 01             	sub    $0x1,%edi
  801b17:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b1b:	75 f7                	jne    801b14 <vprintfmt+0x39e>
  801b1d:	e9 7a fc ff ff       	jmp    80179c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b25:	5b                   	pop    %ebx
  801b26:	5e                   	pop    %esi
  801b27:	5f                   	pop    %edi
  801b28:	5d                   	pop    %ebp
  801b29:	c3                   	ret    

00801b2a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	83 ec 18             	sub    $0x18,%esp
  801b30:	8b 45 08             	mov    0x8(%ebp),%eax
  801b33:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b36:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b39:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b3d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b40:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b47:	85 c0                	test   %eax,%eax
  801b49:	74 26                	je     801b71 <vsnprintf+0x47>
  801b4b:	85 d2                	test   %edx,%edx
  801b4d:	7e 22                	jle    801b71 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b4f:	ff 75 14             	pushl  0x14(%ebp)
  801b52:	ff 75 10             	pushl  0x10(%ebp)
  801b55:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b58:	50                   	push   %eax
  801b59:	68 3c 17 80 00       	push   $0x80173c
  801b5e:	e8 13 fc ff ff       	call   801776 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b63:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b66:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	eb 05                	jmp    801b76 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b76:	c9                   	leave  
  801b77:	c3                   	ret    

00801b78 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b7e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b81:	50                   	push   %eax
  801b82:	ff 75 10             	pushl  0x10(%ebp)
  801b85:	ff 75 0c             	pushl  0xc(%ebp)
  801b88:	ff 75 08             	pushl  0x8(%ebp)
  801b8b:	e8 9a ff ff ff       	call   801b2a <vsnprintf>
	va_end(ap);

	return rc;
}
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b98:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9d:	eb 03                	jmp    801ba2 <strlen+0x10>
		n++;
  801b9f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ba2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ba6:	75 f7                	jne    801b9f <strlen+0xd>
		n++;
	return n;
}
  801ba8:	5d                   	pop    %ebp
  801ba9:	c3                   	ret    

00801baa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bb3:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb8:	eb 03                	jmp    801bbd <strnlen+0x13>
		n++;
  801bba:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bbd:	39 c2                	cmp    %eax,%edx
  801bbf:	74 08                	je     801bc9 <strnlen+0x1f>
  801bc1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bc5:	75 f3                	jne    801bba <strnlen+0x10>
  801bc7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    

00801bcb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	53                   	push   %ebx
  801bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bd5:	89 c2                	mov    %eax,%edx
  801bd7:	83 c2 01             	add    $0x1,%edx
  801bda:	83 c1 01             	add    $0x1,%ecx
  801bdd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801be1:	88 5a ff             	mov    %bl,-0x1(%edx)
  801be4:	84 db                	test   %bl,%bl
  801be6:	75 ef                	jne    801bd7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801be8:	5b                   	pop    %ebx
  801be9:	5d                   	pop    %ebp
  801bea:	c3                   	ret    

00801beb <strcat>:

char *
strcat(char *dst, const char *src)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	53                   	push   %ebx
  801bef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bf2:	53                   	push   %ebx
  801bf3:	e8 9a ff ff ff       	call   801b92 <strlen>
  801bf8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bfb:	ff 75 0c             	pushl  0xc(%ebp)
  801bfe:	01 d8                	add    %ebx,%eax
  801c00:	50                   	push   %eax
  801c01:	e8 c5 ff ff ff       	call   801bcb <strcpy>
	return dst;
}
  801c06:	89 d8                	mov    %ebx,%eax
  801c08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0b:	c9                   	leave  
  801c0c:	c3                   	ret    

00801c0d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	56                   	push   %esi
  801c11:	53                   	push   %ebx
  801c12:	8b 75 08             	mov    0x8(%ebp),%esi
  801c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c18:	89 f3                	mov    %esi,%ebx
  801c1a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c1d:	89 f2                	mov    %esi,%edx
  801c1f:	eb 0f                	jmp    801c30 <strncpy+0x23>
		*dst++ = *src;
  801c21:	83 c2 01             	add    $0x1,%edx
  801c24:	0f b6 01             	movzbl (%ecx),%eax
  801c27:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c2a:	80 39 01             	cmpb   $0x1,(%ecx)
  801c2d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c30:	39 da                	cmp    %ebx,%edx
  801c32:	75 ed                	jne    801c21 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c34:	89 f0                	mov    %esi,%eax
  801c36:	5b                   	pop    %ebx
  801c37:	5e                   	pop    %esi
  801c38:	5d                   	pop    %ebp
  801c39:	c3                   	ret    

00801c3a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	56                   	push   %esi
  801c3e:	53                   	push   %ebx
  801c3f:	8b 75 08             	mov    0x8(%ebp),%esi
  801c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c45:	8b 55 10             	mov    0x10(%ebp),%edx
  801c48:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c4a:	85 d2                	test   %edx,%edx
  801c4c:	74 21                	je     801c6f <strlcpy+0x35>
  801c4e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c52:	89 f2                	mov    %esi,%edx
  801c54:	eb 09                	jmp    801c5f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c56:	83 c2 01             	add    $0x1,%edx
  801c59:	83 c1 01             	add    $0x1,%ecx
  801c5c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c5f:	39 c2                	cmp    %eax,%edx
  801c61:	74 09                	je     801c6c <strlcpy+0x32>
  801c63:	0f b6 19             	movzbl (%ecx),%ebx
  801c66:	84 db                	test   %bl,%bl
  801c68:	75 ec                	jne    801c56 <strlcpy+0x1c>
  801c6a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c6c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c6f:	29 f0                	sub    %esi,%eax
}
  801c71:	5b                   	pop    %ebx
  801c72:	5e                   	pop    %esi
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    

00801c75 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c7e:	eb 06                	jmp    801c86 <strcmp+0x11>
		p++, q++;
  801c80:	83 c1 01             	add    $0x1,%ecx
  801c83:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c86:	0f b6 01             	movzbl (%ecx),%eax
  801c89:	84 c0                	test   %al,%al
  801c8b:	74 04                	je     801c91 <strcmp+0x1c>
  801c8d:	3a 02                	cmp    (%edx),%al
  801c8f:	74 ef                	je     801c80 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c91:	0f b6 c0             	movzbl %al,%eax
  801c94:	0f b6 12             	movzbl (%edx),%edx
  801c97:	29 d0                	sub    %edx,%eax
}
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    

00801c9b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	53                   	push   %ebx
  801c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ca5:	89 c3                	mov    %eax,%ebx
  801ca7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801caa:	eb 06                	jmp    801cb2 <strncmp+0x17>
		n--, p++, q++;
  801cac:	83 c0 01             	add    $0x1,%eax
  801caf:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cb2:	39 d8                	cmp    %ebx,%eax
  801cb4:	74 15                	je     801ccb <strncmp+0x30>
  801cb6:	0f b6 08             	movzbl (%eax),%ecx
  801cb9:	84 c9                	test   %cl,%cl
  801cbb:	74 04                	je     801cc1 <strncmp+0x26>
  801cbd:	3a 0a                	cmp    (%edx),%cl
  801cbf:	74 eb                	je     801cac <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cc1:	0f b6 00             	movzbl (%eax),%eax
  801cc4:	0f b6 12             	movzbl (%edx),%edx
  801cc7:	29 d0                	sub    %edx,%eax
  801cc9:	eb 05                	jmp    801cd0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801ccb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801cd0:	5b                   	pop    %ebx
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    

00801cd3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cdd:	eb 07                	jmp    801ce6 <strchr+0x13>
		if (*s == c)
  801cdf:	38 ca                	cmp    %cl,%dl
  801ce1:	74 0f                	je     801cf2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ce3:	83 c0 01             	add    $0x1,%eax
  801ce6:	0f b6 10             	movzbl (%eax),%edx
  801ce9:	84 d2                	test   %dl,%dl
  801ceb:	75 f2                	jne    801cdf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801ced:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    

00801cf4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cfe:	eb 03                	jmp    801d03 <strfind+0xf>
  801d00:	83 c0 01             	add    $0x1,%eax
  801d03:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d06:	84 d2                	test   %dl,%dl
  801d08:	74 04                	je     801d0e <strfind+0x1a>
  801d0a:	38 ca                	cmp    %cl,%dl
  801d0c:	75 f2                	jne    801d00 <strfind+0xc>
			break;
	return (char *) s;
}
  801d0e:	5d                   	pop    %ebp
  801d0f:	c3                   	ret    

00801d10 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	57                   	push   %edi
  801d14:	56                   	push   %esi
  801d15:	53                   	push   %ebx
  801d16:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d19:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d1c:	85 c9                	test   %ecx,%ecx
  801d1e:	74 36                	je     801d56 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d20:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d26:	75 28                	jne    801d50 <memset+0x40>
  801d28:	f6 c1 03             	test   $0x3,%cl
  801d2b:	75 23                	jne    801d50 <memset+0x40>
		c &= 0xFF;
  801d2d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d31:	89 d3                	mov    %edx,%ebx
  801d33:	c1 e3 08             	shl    $0x8,%ebx
  801d36:	89 d6                	mov    %edx,%esi
  801d38:	c1 e6 18             	shl    $0x18,%esi
  801d3b:	89 d0                	mov    %edx,%eax
  801d3d:	c1 e0 10             	shl    $0x10,%eax
  801d40:	09 f0                	or     %esi,%eax
  801d42:	09 c2                	or     %eax,%edx
  801d44:	89 d0                	mov    %edx,%eax
  801d46:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d48:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801d4b:	fc                   	cld    
  801d4c:	f3 ab                	rep stos %eax,%es:(%edi)
  801d4e:	eb 06                	jmp    801d56 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d53:	fc                   	cld    
  801d54:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d56:	89 f8                	mov    %edi,%eax
  801d58:	5b                   	pop    %ebx
  801d59:	5e                   	pop    %esi
  801d5a:	5f                   	pop    %edi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    

00801d5d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	57                   	push   %edi
  801d61:	56                   	push   %esi
  801d62:	8b 45 08             	mov    0x8(%ebp),%eax
  801d65:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d68:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d6b:	39 c6                	cmp    %eax,%esi
  801d6d:	73 35                	jae    801da4 <memmove+0x47>
  801d6f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d72:	39 d0                	cmp    %edx,%eax
  801d74:	73 2e                	jae    801da4 <memmove+0x47>
		s += n;
		d += n;
  801d76:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801d79:	89 d6                	mov    %edx,%esi
  801d7b:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d7d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d83:	75 13                	jne    801d98 <memmove+0x3b>
  801d85:	f6 c1 03             	test   $0x3,%cl
  801d88:	75 0e                	jne    801d98 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d8a:	83 ef 04             	sub    $0x4,%edi
  801d8d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d90:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801d93:	fd                   	std    
  801d94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d96:	eb 09                	jmp    801da1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d98:	83 ef 01             	sub    $0x1,%edi
  801d9b:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d9e:	fd                   	std    
  801d9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801da1:	fc                   	cld    
  801da2:	eb 1d                	jmp    801dc1 <memmove+0x64>
  801da4:	89 f2                	mov    %esi,%edx
  801da6:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801da8:	f6 c2 03             	test   $0x3,%dl
  801dab:	75 0f                	jne    801dbc <memmove+0x5f>
  801dad:	f6 c1 03             	test   $0x3,%cl
  801db0:	75 0a                	jne    801dbc <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801db2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801db5:	89 c7                	mov    %eax,%edi
  801db7:	fc                   	cld    
  801db8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dba:	eb 05                	jmp    801dc1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801dbc:	89 c7                	mov    %eax,%edi
  801dbe:	fc                   	cld    
  801dbf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dc1:	5e                   	pop    %esi
  801dc2:	5f                   	pop    %edi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801dc8:	ff 75 10             	pushl  0x10(%ebp)
  801dcb:	ff 75 0c             	pushl  0xc(%ebp)
  801dce:	ff 75 08             	pushl  0x8(%ebp)
  801dd1:	e8 87 ff ff ff       	call   801d5d <memmove>
}
  801dd6:	c9                   	leave  
  801dd7:	c3                   	ret    

00801dd8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	56                   	push   %esi
  801ddc:	53                   	push   %ebx
  801ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  801de0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de3:	89 c6                	mov    %eax,%esi
  801de5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801de8:	eb 1a                	jmp    801e04 <memcmp+0x2c>
		if (*s1 != *s2)
  801dea:	0f b6 08             	movzbl (%eax),%ecx
  801ded:	0f b6 1a             	movzbl (%edx),%ebx
  801df0:	38 d9                	cmp    %bl,%cl
  801df2:	74 0a                	je     801dfe <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801df4:	0f b6 c1             	movzbl %cl,%eax
  801df7:	0f b6 db             	movzbl %bl,%ebx
  801dfa:	29 d8                	sub    %ebx,%eax
  801dfc:	eb 0f                	jmp    801e0d <memcmp+0x35>
		s1++, s2++;
  801dfe:	83 c0 01             	add    $0x1,%eax
  801e01:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e04:	39 f0                	cmp    %esi,%eax
  801e06:	75 e2                	jne    801dea <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e0d:	5b                   	pop    %ebx
  801e0e:	5e                   	pop    %esi
  801e0f:	5d                   	pop    %ebp
  801e10:	c3                   	ret    

00801e11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801e1a:	89 c2                	mov    %eax,%edx
  801e1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e1f:	eb 07                	jmp    801e28 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e21:	38 08                	cmp    %cl,(%eax)
  801e23:	74 07                	je     801e2c <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e25:	83 c0 01             	add    $0x1,%eax
  801e28:	39 d0                	cmp    %edx,%eax
  801e2a:	72 f5                	jb     801e21 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e2c:	5d                   	pop    %ebp
  801e2d:	c3                   	ret    

00801e2e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	57                   	push   %edi
  801e32:	56                   	push   %esi
  801e33:	53                   	push   %ebx
  801e34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e3a:	eb 03                	jmp    801e3f <strtol+0x11>
		s++;
  801e3c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e3f:	0f b6 01             	movzbl (%ecx),%eax
  801e42:	3c 09                	cmp    $0x9,%al
  801e44:	74 f6                	je     801e3c <strtol+0xe>
  801e46:	3c 20                	cmp    $0x20,%al
  801e48:	74 f2                	je     801e3c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e4a:	3c 2b                	cmp    $0x2b,%al
  801e4c:	75 0a                	jne    801e58 <strtol+0x2a>
		s++;
  801e4e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e51:	bf 00 00 00 00       	mov    $0x0,%edi
  801e56:	eb 10                	jmp    801e68 <strtol+0x3a>
  801e58:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e5d:	3c 2d                	cmp    $0x2d,%al
  801e5f:	75 07                	jne    801e68 <strtol+0x3a>
		s++, neg = 1;
  801e61:	8d 49 01             	lea    0x1(%ecx),%ecx
  801e64:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e68:	85 db                	test   %ebx,%ebx
  801e6a:	0f 94 c0             	sete   %al
  801e6d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e73:	75 19                	jne    801e8e <strtol+0x60>
  801e75:	80 39 30             	cmpb   $0x30,(%ecx)
  801e78:	75 14                	jne    801e8e <strtol+0x60>
  801e7a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e7e:	0f 85 82 00 00 00    	jne    801f06 <strtol+0xd8>
		s += 2, base = 16;
  801e84:	83 c1 02             	add    $0x2,%ecx
  801e87:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e8c:	eb 16                	jmp    801ea4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801e8e:	84 c0                	test   %al,%al
  801e90:	74 12                	je     801ea4 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e92:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e97:	80 39 30             	cmpb   $0x30,(%ecx)
  801e9a:	75 08                	jne    801ea4 <strtol+0x76>
		s++, base = 8;
  801e9c:	83 c1 01             	add    $0x1,%ecx
  801e9f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ea4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801eac:	0f b6 11             	movzbl (%ecx),%edx
  801eaf:	8d 72 d0             	lea    -0x30(%edx),%esi
  801eb2:	89 f3                	mov    %esi,%ebx
  801eb4:	80 fb 09             	cmp    $0x9,%bl
  801eb7:	77 08                	ja     801ec1 <strtol+0x93>
			dig = *s - '0';
  801eb9:	0f be d2             	movsbl %dl,%edx
  801ebc:	83 ea 30             	sub    $0x30,%edx
  801ebf:	eb 22                	jmp    801ee3 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  801ec1:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ec4:	89 f3                	mov    %esi,%ebx
  801ec6:	80 fb 19             	cmp    $0x19,%bl
  801ec9:	77 08                	ja     801ed3 <strtol+0xa5>
			dig = *s - 'a' + 10;
  801ecb:	0f be d2             	movsbl %dl,%edx
  801ece:	83 ea 57             	sub    $0x57,%edx
  801ed1:	eb 10                	jmp    801ee3 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  801ed3:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ed6:	89 f3                	mov    %esi,%ebx
  801ed8:	80 fb 19             	cmp    $0x19,%bl
  801edb:	77 16                	ja     801ef3 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801edd:	0f be d2             	movsbl %dl,%edx
  801ee0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ee3:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ee6:	7d 0f                	jge    801ef7 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801ee8:	83 c1 01             	add    $0x1,%ecx
  801eeb:	0f af 45 10          	imul   0x10(%ebp),%eax
  801eef:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ef1:	eb b9                	jmp    801eac <strtol+0x7e>
  801ef3:	89 c2                	mov    %eax,%edx
  801ef5:	eb 02                	jmp    801ef9 <strtol+0xcb>
  801ef7:	89 c2                	mov    %eax,%edx

	if (endptr)
  801ef9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801efd:	74 0d                	je     801f0c <strtol+0xde>
		*endptr = (char *) s;
  801eff:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f02:	89 0e                	mov    %ecx,(%esi)
  801f04:	eb 06                	jmp    801f0c <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f06:	84 c0                	test   %al,%al
  801f08:	75 92                	jne    801e9c <strtol+0x6e>
  801f0a:	eb 98                	jmp    801ea4 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f0c:	f7 da                	neg    %edx
  801f0e:	85 ff                	test   %edi,%edi
  801f10:	0f 45 c2             	cmovne %edx,%eax
}
  801f13:	5b                   	pop    %ebx
  801f14:	5e                   	pop    %esi
  801f15:	5f                   	pop    %edi
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    

00801f18 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	56                   	push   %esi
  801f1c:	53                   	push   %ebx
  801f1d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f26:	85 c0                	test   %eax,%eax
  801f28:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f2d:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f30:	83 ec 0c             	sub    $0xc,%esp
  801f33:	50                   	push   %eax
  801f34:	e8 cd e3 ff ff       	call   800306 <sys_ipc_recv>
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	79 16                	jns    801f56 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801f40:	85 f6                	test   %esi,%esi
  801f42:	74 06                	je     801f4a <ipc_recv+0x32>
  801f44:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801f4a:	85 db                	test   %ebx,%ebx
  801f4c:	74 2c                	je     801f7a <ipc_recv+0x62>
  801f4e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f54:	eb 24                	jmp    801f7a <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801f56:	85 f6                	test   %esi,%esi
  801f58:	74 0a                	je     801f64 <ipc_recv+0x4c>
  801f5a:	a1 08 40 80 00       	mov    0x804008,%eax
  801f5f:	8b 40 74             	mov    0x74(%eax),%eax
  801f62:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801f64:	85 db                	test   %ebx,%ebx
  801f66:	74 0a                	je     801f72 <ipc_recv+0x5a>
  801f68:	a1 08 40 80 00       	mov    0x804008,%eax
  801f6d:	8b 40 78             	mov    0x78(%eax),%eax
  801f70:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801f72:	a1 08 40 80 00       	mov    0x804008,%eax
  801f77:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	5d                   	pop    %ebp
  801f80:	c3                   	ret    

00801f81 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	57                   	push   %edi
  801f85:	56                   	push   %esi
  801f86:	53                   	push   %ebx
  801f87:	83 ec 0c             	sub    $0xc,%esp
  801f8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801f93:	85 db                	test   %ebx,%ebx
  801f95:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f9a:	0f 44 d8             	cmove  %eax,%ebx
  801f9d:	eb 1c                	jmp    801fbb <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801f9f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fa2:	74 12                	je     801fb6 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801fa4:	50                   	push   %eax
  801fa5:	68 a0 27 80 00       	push   $0x8027a0
  801faa:	6a 39                	push   $0x39
  801fac:	68 bb 27 80 00       	push   $0x8027bb
  801fb1:	e8 b5 f5 ff ff       	call   80156b <_panic>
                 sys_yield();
  801fb6:	e8 7c e1 ff ff       	call   800137 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801fbb:	ff 75 14             	pushl  0x14(%ebp)
  801fbe:	53                   	push   %ebx
  801fbf:	56                   	push   %esi
  801fc0:	57                   	push   %edi
  801fc1:	e8 1d e3 ff ff       	call   8002e3 <sys_ipc_try_send>
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	78 d2                	js     801f9f <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801fcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd0:	5b                   	pop    %ebx
  801fd1:	5e                   	pop    %esi
  801fd2:	5f                   	pop    %edi
  801fd3:	5d                   	pop    %ebp
  801fd4:	c3                   	ret    

00801fd5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fdb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fe0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fe3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fe9:	8b 52 50             	mov    0x50(%edx),%edx
  801fec:	39 ca                	cmp    %ecx,%edx
  801fee:	75 0d                	jne    801ffd <ipc_find_env+0x28>
			return envs[i].env_id;
  801ff0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ff3:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ff8:	8b 40 08             	mov    0x8(%eax),%eax
  801ffb:	eb 0e                	jmp    80200b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ffd:	83 c0 01             	add    $0x1,%eax
  802000:	3d 00 04 00 00       	cmp    $0x400,%eax
  802005:	75 d9                	jne    801fe0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802007:	66 b8 00 00          	mov    $0x0,%ax
}
  80200b:	5d                   	pop    %ebp
  80200c:	c3                   	ret    

0080200d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80200d:	55                   	push   %ebp
  80200e:	89 e5                	mov    %esp,%ebp
  802010:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802013:	89 d0                	mov    %edx,%eax
  802015:	c1 e8 16             	shr    $0x16,%eax
  802018:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80201f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802024:	f6 c1 01             	test   $0x1,%cl
  802027:	74 1d                	je     802046 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802029:	c1 ea 0c             	shr    $0xc,%edx
  80202c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802033:	f6 c2 01             	test   $0x1,%dl
  802036:	74 0e                	je     802046 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802038:	c1 ea 0c             	shr    $0xc,%edx
  80203b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802042:	ef 
  802043:	0f b7 c0             	movzwl %ax,%eax
}
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	66 90                	xchg   %ax,%ax
  80204a:	66 90                	xchg   %ax,%ax
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
