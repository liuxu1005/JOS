
obj/user/faultwrite.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
  80007e:	83 c4 10             	add    $0x10,%esp
}
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 2f 05 00 00       	call   8005c2 <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
  80009d:	83 c4 10             	add    $0x10,%esp
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 0a 23 80 00       	push   $0x80230a
  80010c:	6a 22                	push   $0x22
  80010e:	68 27 23 80 00       	push   $0x802327
  800113:	e8 5b 14 00 00       	call   801573 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{      
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 0a 23 80 00       	push   $0x80230a
  80018d:	6a 22                	push   $0x22
  80018f:	68 27 23 80 00       	push   $0x802327
  800194:	e8 da 13 00 00       	call   801573 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 0a 23 80 00       	push   $0x80230a
  8001cf:	6a 22                	push   $0x22
  8001d1:	68 27 23 80 00       	push   $0x802327
  8001d6:	e8 98 13 00 00       	call   801573 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 0a 23 80 00       	push   $0x80230a
  800211:	6a 22                	push   $0x22
  800213:	68 27 23 80 00       	push   $0x802327
  800218:	e8 56 13 00 00       	call   801573 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 0a 23 80 00       	push   $0x80230a
  800253:	6a 22                	push   $0x22
  800255:	68 27 23 80 00       	push   $0x802327
  80025a:	e8 14 13 00 00       	call   801573 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 0a 23 80 00       	push   $0x80230a
  800295:	6a 22                	push   $0x22
  800297:	68 27 23 80 00       	push   $0x802327
  80029c:	e8 d2 12 00 00       	call   801573 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 0a 23 80 00       	push   $0x80230a
  8002d7:	6a 22                	push   $0x22
  8002d9:	68 27 23 80 00       	push   $0x802327
  8002de:	e8 90 12 00 00       	call   801573 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 0a 23 80 00       	push   $0x80230a
  80033b:	6a 22                	push   $0x22
  80033d:	68 27 23 80 00       	push   $0x802327
  800342:	e8 2c 12 00 00       	call   801573 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035f:	89 d1                	mov    %edx,%ecx
  800361:	89 d3                	mov    %edx,%ebx
  800363:	89 d7                	mov    %edx,%edi
  800365:	89 d6                	mov    %edx,%esi
  800367:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800369:	5b                   	pop    %ebx
  80036a:	5e                   	pop    %esi
  80036b:	5f                   	pop    %edi
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <sys_transmit>:

int
sys_transmit(void *addr)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	57                   	push   %edi
  800372:	56                   	push   %esi
  800373:	53                   	push   %ebx
  800374:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800377:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800381:	8b 55 08             	mov    0x8(%ebp),%edx
  800384:	89 cb                	mov    %ecx,%ebx
  800386:	89 cf                	mov    %ecx,%edi
  800388:	89 ce                	mov    %ecx,%esi
  80038a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80038c:	85 c0                	test   %eax,%eax
  80038e:	7e 17                	jle    8003a7 <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800390:	83 ec 0c             	sub    $0xc,%esp
  800393:	50                   	push   %eax
  800394:	6a 0f                	push   $0xf
  800396:	68 0a 23 80 00       	push   $0x80230a
  80039b:	6a 22                	push   $0x22
  80039d:	68 27 23 80 00       	push   $0x802327
  8003a2:	e8 cc 11 00 00       	call   801573 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <sys_recv>:

int
sys_recv(void *addr)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	57                   	push   %edi
  8003b3:	56                   	push   %esi
  8003b4:	53                   	push   %ebx
  8003b5:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8003b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bd:	b8 10 00 00 00       	mov    $0x10,%eax
  8003c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c5:	89 cb                	mov    %ecx,%ebx
  8003c7:	89 cf                	mov    %ecx,%edi
  8003c9:	89 ce                	mov    %ecx,%esi
  8003cb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003cd:	85 c0                	test   %eax,%eax
  8003cf:	7e 17                	jle    8003e8 <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d1:	83 ec 0c             	sub    $0xc,%esp
  8003d4:	50                   	push   %eax
  8003d5:	6a 10                	push   $0x10
  8003d7:	68 0a 23 80 00       	push   $0x80230a
  8003dc:	6a 22                	push   $0x22
  8003de:	68 27 23 80 00       	push   $0x802327
  8003e3:	e8 8b 11 00 00       	call   801573 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003eb:	5b                   	pop    %ebx
  8003ec:	5e                   	pop    %esi
  8003ed:	5f                   	pop    %edi
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800403:	8b 45 08             	mov    0x8(%ebp),%eax
  800406:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80040b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800410:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800422:	89 c2                	mov    %eax,%edx
  800424:	c1 ea 16             	shr    $0x16,%edx
  800427:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80042e:	f6 c2 01             	test   $0x1,%dl
  800431:	74 11                	je     800444 <fd_alloc+0x2d>
  800433:	89 c2                	mov    %eax,%edx
  800435:	c1 ea 0c             	shr    $0xc,%edx
  800438:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043f:	f6 c2 01             	test   $0x1,%dl
  800442:	75 09                	jne    80044d <fd_alloc+0x36>
			*fd_store = fd;
  800444:	89 01                	mov    %eax,(%ecx)
			return 0;
  800446:	b8 00 00 00 00       	mov    $0x0,%eax
  80044b:	eb 17                	jmp    800464 <fd_alloc+0x4d>
  80044d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800452:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800457:	75 c9                	jne    800422 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800459:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80045f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800464:	5d                   	pop    %ebp
  800465:	c3                   	ret    

00800466 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80046c:	83 f8 1f             	cmp    $0x1f,%eax
  80046f:	77 36                	ja     8004a7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800471:	c1 e0 0c             	shl    $0xc,%eax
  800474:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800479:	89 c2                	mov    %eax,%edx
  80047b:	c1 ea 16             	shr    $0x16,%edx
  80047e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800485:	f6 c2 01             	test   $0x1,%dl
  800488:	74 24                	je     8004ae <fd_lookup+0x48>
  80048a:	89 c2                	mov    %eax,%edx
  80048c:	c1 ea 0c             	shr    $0xc,%edx
  80048f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800496:	f6 c2 01             	test   $0x1,%dl
  800499:	74 1a                	je     8004b5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80049b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049e:	89 02                	mov    %eax,(%edx)
	return 0;
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	eb 13                	jmp    8004ba <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ac:	eb 0c                	jmp    8004ba <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b3:	eb 05                	jmp    8004ba <fd_lookup+0x54>
  8004b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004ba:	5d                   	pop    %ebp
  8004bb:	c3                   	ret    

008004bc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8004c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ca:	eb 13                	jmp    8004df <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8004cc:	39 08                	cmp    %ecx,(%eax)
  8004ce:	75 0c                	jne    8004dc <dev_lookup+0x20>
			*dev = devtab[i];
  8004d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004da:	eb 36                	jmp    800512 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004dc:	83 c2 01             	add    $0x1,%edx
  8004df:	8b 04 95 b4 23 80 00 	mov    0x8023b4(,%edx,4),%eax
  8004e6:	85 c0                	test   %eax,%eax
  8004e8:	75 e2                	jne    8004cc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004ea:	a1 08 40 80 00       	mov    0x804008,%eax
  8004ef:	8b 40 48             	mov    0x48(%eax),%eax
  8004f2:	83 ec 04             	sub    $0x4,%esp
  8004f5:	51                   	push   %ecx
  8004f6:	50                   	push   %eax
  8004f7:	68 38 23 80 00       	push   $0x802338
  8004fc:	e8 4b 11 00 00       	call   80164c <cprintf>
	*dev = 0;
  800501:	8b 45 0c             	mov    0xc(%ebp),%eax
  800504:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800512:	c9                   	leave  
  800513:	c3                   	ret    

00800514 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
  800517:	56                   	push   %esi
  800518:	53                   	push   %ebx
  800519:	83 ec 10             	sub    $0x10,%esp
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800522:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800525:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800526:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80052c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80052f:	50                   	push   %eax
  800530:	e8 31 ff ff ff       	call   800466 <fd_lookup>
  800535:	83 c4 08             	add    $0x8,%esp
  800538:	85 c0                	test   %eax,%eax
  80053a:	78 05                	js     800541 <fd_close+0x2d>
	    || fd != fd2)
  80053c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80053f:	74 0c                	je     80054d <fd_close+0x39>
		return (must_exist ? r : 0);
  800541:	84 db                	test   %bl,%bl
  800543:	ba 00 00 00 00       	mov    $0x0,%edx
  800548:	0f 44 c2             	cmove  %edx,%eax
  80054b:	eb 41                	jmp    80058e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800553:	50                   	push   %eax
  800554:	ff 36                	pushl  (%esi)
  800556:	e8 61 ff ff ff       	call   8004bc <dev_lookup>
  80055b:	89 c3                	mov    %eax,%ebx
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	78 1a                	js     80057e <fd_close+0x6a>
		if (dev->dev_close)
  800564:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800567:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80056a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80056f:	85 c0                	test   %eax,%eax
  800571:	74 0b                	je     80057e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800573:	83 ec 0c             	sub    $0xc,%esp
  800576:	56                   	push   %esi
  800577:	ff d0                	call   *%eax
  800579:	89 c3                	mov    %eax,%ebx
  80057b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	56                   	push   %esi
  800582:	6a 00                	push   $0x0
  800584:	e8 5a fc ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	89 d8                	mov    %ebx,%eax
}
  80058e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800591:	5b                   	pop    %ebx
  800592:	5e                   	pop    %esi
  800593:	5d                   	pop    %ebp
  800594:	c3                   	ret    

00800595 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800595:	55                   	push   %ebp
  800596:	89 e5                	mov    %esp,%ebp
  800598:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80059b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80059e:	50                   	push   %eax
  80059f:	ff 75 08             	pushl  0x8(%ebp)
  8005a2:	e8 bf fe ff ff       	call   800466 <fd_lookup>
  8005a7:	89 c2                	mov    %eax,%edx
  8005a9:	83 c4 08             	add    $0x8,%esp
  8005ac:	85 d2                	test   %edx,%edx
  8005ae:	78 10                	js     8005c0 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	6a 01                	push   $0x1
  8005b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8005b8:	e8 57 ff ff ff       	call   800514 <fd_close>
  8005bd:	83 c4 10             	add    $0x10,%esp
}
  8005c0:	c9                   	leave  
  8005c1:	c3                   	ret    

008005c2 <close_all>:

void
close_all(void)
{
  8005c2:	55                   	push   %ebp
  8005c3:	89 e5                	mov    %esp,%ebp
  8005c5:	53                   	push   %ebx
  8005c6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005c9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005ce:	83 ec 0c             	sub    $0xc,%esp
  8005d1:	53                   	push   %ebx
  8005d2:	e8 be ff ff ff       	call   800595 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005d7:	83 c3 01             	add    $0x1,%ebx
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	83 fb 20             	cmp    $0x20,%ebx
  8005e0:	75 ec                	jne    8005ce <close_all+0xc>
		close(i);
}
  8005e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005e5:	c9                   	leave  
  8005e6:	c3                   	ret    

008005e7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005e7:	55                   	push   %ebp
  8005e8:	89 e5                	mov    %esp,%ebp
  8005ea:	57                   	push   %edi
  8005eb:	56                   	push   %esi
  8005ec:	53                   	push   %ebx
  8005ed:	83 ec 2c             	sub    $0x2c,%esp
  8005f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005f6:	50                   	push   %eax
  8005f7:	ff 75 08             	pushl  0x8(%ebp)
  8005fa:	e8 67 fe ff ff       	call   800466 <fd_lookup>
  8005ff:	89 c2                	mov    %eax,%edx
  800601:	83 c4 08             	add    $0x8,%esp
  800604:	85 d2                	test   %edx,%edx
  800606:	0f 88 c1 00 00 00    	js     8006cd <dup+0xe6>
		return r;
	close(newfdnum);
  80060c:	83 ec 0c             	sub    $0xc,%esp
  80060f:	56                   	push   %esi
  800610:	e8 80 ff ff ff       	call   800595 <close>

	newfd = INDEX2FD(newfdnum);
  800615:	89 f3                	mov    %esi,%ebx
  800617:	c1 e3 0c             	shl    $0xc,%ebx
  80061a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800620:	83 c4 04             	add    $0x4,%esp
  800623:	ff 75 e4             	pushl  -0x1c(%ebp)
  800626:	e8 d5 fd ff ff       	call   800400 <fd2data>
  80062b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80062d:	89 1c 24             	mov    %ebx,(%esp)
  800630:	e8 cb fd ff ff       	call   800400 <fd2data>
  800635:	83 c4 10             	add    $0x10,%esp
  800638:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80063b:	89 f8                	mov    %edi,%eax
  80063d:	c1 e8 16             	shr    $0x16,%eax
  800640:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800647:	a8 01                	test   $0x1,%al
  800649:	74 37                	je     800682 <dup+0x9b>
  80064b:	89 f8                	mov    %edi,%eax
  80064d:	c1 e8 0c             	shr    $0xc,%eax
  800650:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800657:	f6 c2 01             	test   $0x1,%dl
  80065a:	74 26                	je     800682 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80065c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800663:	83 ec 0c             	sub    $0xc,%esp
  800666:	25 07 0e 00 00       	and    $0xe07,%eax
  80066b:	50                   	push   %eax
  80066c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80066f:	6a 00                	push   $0x0
  800671:	57                   	push   %edi
  800672:	6a 00                	push   $0x0
  800674:	e8 28 fb ff ff       	call   8001a1 <sys_page_map>
  800679:	89 c7                	mov    %eax,%edi
  80067b:	83 c4 20             	add    $0x20,%esp
  80067e:	85 c0                	test   %eax,%eax
  800680:	78 2e                	js     8006b0 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800682:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800685:	89 d0                	mov    %edx,%eax
  800687:	c1 e8 0c             	shr    $0xc,%eax
  80068a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800691:	83 ec 0c             	sub    $0xc,%esp
  800694:	25 07 0e 00 00       	and    $0xe07,%eax
  800699:	50                   	push   %eax
  80069a:	53                   	push   %ebx
  80069b:	6a 00                	push   $0x0
  80069d:	52                   	push   %edx
  80069e:	6a 00                	push   $0x0
  8006a0:	e8 fc fa ff ff       	call   8001a1 <sys_page_map>
  8006a5:	89 c7                	mov    %eax,%edi
  8006a7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006aa:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006ac:	85 ff                	test   %edi,%edi
  8006ae:	79 1d                	jns    8006cd <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	6a 00                	push   $0x0
  8006b6:	e8 28 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006bb:	83 c4 08             	add    $0x8,%esp
  8006be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006c1:	6a 00                	push   $0x0
  8006c3:	e8 1b fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	89 f8                	mov    %edi,%eax
}
  8006cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d0:	5b                   	pop    %ebx
  8006d1:	5e                   	pop    %esi
  8006d2:	5f                   	pop    %edi
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	53                   	push   %ebx
  8006d9:	83 ec 14             	sub    $0x14,%esp
  8006dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006e2:	50                   	push   %eax
  8006e3:	53                   	push   %ebx
  8006e4:	e8 7d fd ff ff       	call   800466 <fd_lookup>
  8006e9:	83 c4 08             	add    $0x8,%esp
  8006ec:	89 c2                	mov    %eax,%edx
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	78 6d                	js     80075f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006f8:	50                   	push   %eax
  8006f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006fc:	ff 30                	pushl  (%eax)
  8006fe:	e8 b9 fd ff ff       	call   8004bc <dev_lookup>
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	85 c0                	test   %eax,%eax
  800708:	78 4c                	js     800756 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80070a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80070d:	8b 42 08             	mov    0x8(%edx),%eax
  800710:	83 e0 03             	and    $0x3,%eax
  800713:	83 f8 01             	cmp    $0x1,%eax
  800716:	75 21                	jne    800739 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800718:	a1 08 40 80 00       	mov    0x804008,%eax
  80071d:	8b 40 48             	mov    0x48(%eax),%eax
  800720:	83 ec 04             	sub    $0x4,%esp
  800723:	53                   	push   %ebx
  800724:	50                   	push   %eax
  800725:	68 79 23 80 00       	push   $0x802379
  80072a:	e8 1d 0f 00 00       	call   80164c <cprintf>
		return -E_INVAL;
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800737:	eb 26                	jmp    80075f <read+0x8a>
	}
	if (!dev->dev_read)
  800739:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073c:	8b 40 08             	mov    0x8(%eax),%eax
  80073f:	85 c0                	test   %eax,%eax
  800741:	74 17                	je     80075a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	ff 75 10             	pushl  0x10(%ebp)
  800749:	ff 75 0c             	pushl  0xc(%ebp)
  80074c:	52                   	push   %edx
  80074d:	ff d0                	call   *%eax
  80074f:	89 c2                	mov    %eax,%edx
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	eb 09                	jmp    80075f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800756:	89 c2                	mov    %eax,%edx
  800758:	eb 05                	jmp    80075f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80075a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80075f:	89 d0                	mov    %edx,%eax
  800761:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	57                   	push   %edi
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	83 ec 0c             	sub    $0xc,%esp
  80076f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800772:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800775:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077a:	eb 21                	jmp    80079d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80077c:	83 ec 04             	sub    $0x4,%esp
  80077f:	89 f0                	mov    %esi,%eax
  800781:	29 d8                	sub    %ebx,%eax
  800783:	50                   	push   %eax
  800784:	89 d8                	mov    %ebx,%eax
  800786:	03 45 0c             	add    0xc(%ebp),%eax
  800789:	50                   	push   %eax
  80078a:	57                   	push   %edi
  80078b:	e8 45 ff ff ff       	call   8006d5 <read>
		if (m < 0)
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	85 c0                	test   %eax,%eax
  800795:	78 0c                	js     8007a3 <readn+0x3d>
			return m;
		if (m == 0)
  800797:	85 c0                	test   %eax,%eax
  800799:	74 06                	je     8007a1 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80079b:	01 c3                	add    %eax,%ebx
  80079d:	39 f3                	cmp    %esi,%ebx
  80079f:	72 db                	jb     80077c <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8007a1:	89 d8                	mov    %ebx,%eax
}
  8007a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007a6:	5b                   	pop    %ebx
  8007a7:	5e                   	pop    %esi
  8007a8:	5f                   	pop    %edi
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	83 ec 14             	sub    $0x14,%esp
  8007b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b8:	50                   	push   %eax
  8007b9:	53                   	push   %ebx
  8007ba:	e8 a7 fc ff ff       	call   800466 <fd_lookup>
  8007bf:	83 c4 08             	add    $0x8,%esp
  8007c2:	89 c2                	mov    %eax,%edx
  8007c4:	85 c0                	test   %eax,%eax
  8007c6:	78 68                	js     800830 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007ce:	50                   	push   %eax
  8007cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d2:	ff 30                	pushl  (%eax)
  8007d4:	e8 e3 fc ff ff       	call   8004bc <dev_lookup>
  8007d9:	83 c4 10             	add    $0x10,%esp
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	78 47                	js     800827 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e7:	75 21                	jne    80080a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007e9:	a1 08 40 80 00       	mov    0x804008,%eax
  8007ee:	8b 40 48             	mov    0x48(%eax),%eax
  8007f1:	83 ec 04             	sub    $0x4,%esp
  8007f4:	53                   	push   %ebx
  8007f5:	50                   	push   %eax
  8007f6:	68 95 23 80 00       	push   $0x802395
  8007fb:	e8 4c 0e 00 00       	call   80164c <cprintf>
		return -E_INVAL;
  800800:	83 c4 10             	add    $0x10,%esp
  800803:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800808:	eb 26                	jmp    800830 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80080a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80080d:	8b 52 0c             	mov    0xc(%edx),%edx
  800810:	85 d2                	test   %edx,%edx
  800812:	74 17                	je     80082b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800814:	83 ec 04             	sub    $0x4,%esp
  800817:	ff 75 10             	pushl  0x10(%ebp)
  80081a:	ff 75 0c             	pushl  0xc(%ebp)
  80081d:	50                   	push   %eax
  80081e:	ff d2                	call   *%edx
  800820:	89 c2                	mov    %eax,%edx
  800822:	83 c4 10             	add    $0x10,%esp
  800825:	eb 09                	jmp    800830 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800827:	89 c2                	mov    %eax,%edx
  800829:	eb 05                	jmp    800830 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80082b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800830:	89 d0                	mov    %edx,%eax
  800832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <seek>:

int
seek(int fdnum, off_t offset)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80083d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800840:	50                   	push   %eax
  800841:	ff 75 08             	pushl  0x8(%ebp)
  800844:	e8 1d fc ff ff       	call   800466 <fd_lookup>
  800849:	83 c4 08             	add    $0x8,%esp
  80084c:	85 c0                	test   %eax,%eax
  80084e:	78 0e                	js     80085e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800850:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
  800856:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	53                   	push   %ebx
  800864:	83 ec 14             	sub    $0x14,%esp
  800867:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80086a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	53                   	push   %ebx
  80086f:	e8 f2 fb ff ff       	call   800466 <fd_lookup>
  800874:	83 c4 08             	add    $0x8,%esp
  800877:	89 c2                	mov    %eax,%edx
  800879:	85 c0                	test   %eax,%eax
  80087b:	78 65                	js     8008e2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80087d:	83 ec 08             	sub    $0x8,%esp
  800880:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800883:	50                   	push   %eax
  800884:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800887:	ff 30                	pushl  (%eax)
  800889:	e8 2e fc ff ff       	call   8004bc <dev_lookup>
  80088e:	83 c4 10             	add    $0x10,%esp
  800891:	85 c0                	test   %eax,%eax
  800893:	78 44                	js     8008d9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800895:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800898:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80089c:	75 21                	jne    8008bf <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80089e:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008a3:	8b 40 48             	mov    0x48(%eax),%eax
  8008a6:	83 ec 04             	sub    $0x4,%esp
  8008a9:	53                   	push   %ebx
  8008aa:	50                   	push   %eax
  8008ab:	68 58 23 80 00       	push   $0x802358
  8008b0:	e8 97 0d 00 00       	call   80164c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008bd:	eb 23                	jmp    8008e2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008c2:	8b 52 18             	mov    0x18(%edx),%edx
  8008c5:	85 d2                	test   %edx,%edx
  8008c7:	74 14                	je     8008dd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008c9:	83 ec 08             	sub    $0x8,%esp
  8008cc:	ff 75 0c             	pushl  0xc(%ebp)
  8008cf:	50                   	push   %eax
  8008d0:	ff d2                	call   *%edx
  8008d2:	89 c2                	mov    %eax,%edx
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	eb 09                	jmp    8008e2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d9:	89 c2                	mov    %eax,%edx
  8008db:	eb 05                	jmp    8008e2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008e2:	89 d0                	mov    %edx,%eax
  8008e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e7:	c9                   	leave  
  8008e8:	c3                   	ret    

008008e9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	53                   	push   %ebx
  8008ed:	83 ec 14             	sub    $0x14,%esp
  8008f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008f6:	50                   	push   %eax
  8008f7:	ff 75 08             	pushl  0x8(%ebp)
  8008fa:	e8 67 fb ff ff       	call   800466 <fd_lookup>
  8008ff:	83 c4 08             	add    $0x8,%esp
  800902:	89 c2                	mov    %eax,%edx
  800904:	85 c0                	test   %eax,%eax
  800906:	78 58                	js     800960 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80090e:	50                   	push   %eax
  80090f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800912:	ff 30                	pushl  (%eax)
  800914:	e8 a3 fb ff ff       	call   8004bc <dev_lookup>
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	85 c0                	test   %eax,%eax
  80091e:	78 37                	js     800957 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800920:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800923:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800927:	74 32                	je     80095b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800929:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80092c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800933:	00 00 00 
	stat->st_isdir = 0;
  800936:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80093d:	00 00 00 
	stat->st_dev = dev;
  800940:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800946:	83 ec 08             	sub    $0x8,%esp
  800949:	53                   	push   %ebx
  80094a:	ff 75 f0             	pushl  -0x10(%ebp)
  80094d:	ff 50 14             	call   *0x14(%eax)
  800950:	89 c2                	mov    %eax,%edx
  800952:	83 c4 10             	add    $0x10,%esp
  800955:	eb 09                	jmp    800960 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800957:	89 c2                	mov    %eax,%edx
  800959:	eb 05                	jmp    800960 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80095b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800960:	89 d0                	mov    %edx,%eax
  800962:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	56                   	push   %esi
  80096b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80096c:	83 ec 08             	sub    $0x8,%esp
  80096f:	6a 00                	push   $0x0
  800971:	ff 75 08             	pushl  0x8(%ebp)
  800974:	e8 09 02 00 00       	call   800b82 <open>
  800979:	89 c3                	mov    %eax,%ebx
  80097b:	83 c4 10             	add    $0x10,%esp
  80097e:	85 db                	test   %ebx,%ebx
  800980:	78 1b                	js     80099d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800982:	83 ec 08             	sub    $0x8,%esp
  800985:	ff 75 0c             	pushl  0xc(%ebp)
  800988:	53                   	push   %ebx
  800989:	e8 5b ff ff ff       	call   8008e9 <fstat>
  80098e:	89 c6                	mov    %eax,%esi
	close(fd);
  800990:	89 1c 24             	mov    %ebx,(%esp)
  800993:	e8 fd fb ff ff       	call   800595 <close>
	return r;
  800998:	83 c4 10             	add    $0x10,%esp
  80099b:	89 f0                	mov    %esi,%eax
}
  80099d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	89 c6                	mov    %eax,%esi
  8009ab:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009ad:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009b4:	75 12                	jne    8009c8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009b6:	83 ec 0c             	sub    $0xc,%esp
  8009b9:	6a 01                	push   $0x1
  8009bb:	e8 1d 16 00 00       	call   801fdd <ipc_find_env>
  8009c0:	a3 00 40 80 00       	mov    %eax,0x804000
  8009c5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009c8:	6a 07                	push   $0x7
  8009ca:	68 00 50 80 00       	push   $0x805000
  8009cf:	56                   	push   %esi
  8009d0:	ff 35 00 40 80 00    	pushl  0x804000
  8009d6:	e8 ae 15 00 00       	call   801f89 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009db:	83 c4 0c             	add    $0xc,%esp
  8009de:	6a 00                	push   $0x0
  8009e0:	53                   	push   %ebx
  8009e1:	6a 00                	push   $0x0
  8009e3:	e8 38 15 00 00       	call   801f20 <ipc_recv>
}
  8009e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a03:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a08:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0d:	b8 02 00 00 00       	mov    $0x2,%eax
  800a12:	e8 8d ff ff ff       	call   8009a4 <fsipc>
}
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 40 0c             	mov    0xc(%eax),%eax
  800a25:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2f:	b8 06 00 00 00       	mov    $0x6,%eax
  800a34:	e8 6b ff ff ff       	call   8009a4 <fsipc>
}
  800a39:	c9                   	leave  
  800a3a:	c3                   	ret    

00800a3b <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	83 ec 04             	sub    $0x4,%esp
  800a42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a50:	ba 00 00 00 00       	mov    $0x0,%edx
  800a55:	b8 05 00 00 00       	mov    $0x5,%eax
  800a5a:	e8 45 ff ff ff       	call   8009a4 <fsipc>
  800a5f:	89 c2                	mov    %eax,%edx
  800a61:	85 d2                	test   %edx,%edx
  800a63:	78 2c                	js     800a91 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a65:	83 ec 08             	sub    $0x8,%esp
  800a68:	68 00 50 80 00       	push   $0x805000
  800a6d:	53                   	push   %ebx
  800a6e:	e8 60 11 00 00       	call   801bd3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a73:	a1 80 50 80 00       	mov    0x805080,%eax
  800a78:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a7e:	a1 84 50 80 00       	mov    0x805084,%eax
  800a83:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a89:	83 c4 10             	add    $0x10,%esp
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a94:	c9                   	leave  
  800a95:	c3                   	ret    

00800a96 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	83 ec 0c             	sub    $0xc,%esp
  800a9f:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	8b 40 0c             	mov    0xc(%eax),%eax
  800aa8:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800aad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800ab0:	eb 3d                	jmp    800aef <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800ab2:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800ab8:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800abd:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800ac0:	83 ec 04             	sub    $0x4,%esp
  800ac3:	57                   	push   %edi
  800ac4:	53                   	push   %ebx
  800ac5:	68 08 50 80 00       	push   $0x805008
  800aca:	e8 96 12 00 00       	call   801d65 <memmove>
                fsipcbuf.write.req_n = tmp; 
  800acf:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	b8 04 00 00 00       	mov    $0x4,%eax
  800adf:	e8 c0 fe ff ff       	call   8009a4 <fsipc>
  800ae4:	83 c4 10             	add    $0x10,%esp
  800ae7:	85 c0                	test   %eax,%eax
  800ae9:	78 0d                	js     800af8 <devfile_write+0x62>
		        return r;
                n -= tmp;
  800aeb:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800aed:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800aef:	85 f6                	test   %esi,%esi
  800af1:	75 bf                	jne    800ab2 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800af3:	89 d8                	mov    %ebx,%eax
  800af5:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800af8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 40 0c             	mov    0xc(%eax),%eax
  800b0e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b13:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b23:	e8 7c fe ff ff       	call   8009a4 <fsipc>
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	78 4b                	js     800b79 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b2e:	39 c6                	cmp    %eax,%esi
  800b30:	73 16                	jae    800b48 <devfile_read+0x48>
  800b32:	68 c8 23 80 00       	push   $0x8023c8
  800b37:	68 cf 23 80 00       	push   $0x8023cf
  800b3c:	6a 7c                	push   $0x7c
  800b3e:	68 e4 23 80 00       	push   $0x8023e4
  800b43:	e8 2b 0a 00 00       	call   801573 <_panic>
	assert(r <= PGSIZE);
  800b48:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b4d:	7e 16                	jle    800b65 <devfile_read+0x65>
  800b4f:	68 ef 23 80 00       	push   $0x8023ef
  800b54:	68 cf 23 80 00       	push   $0x8023cf
  800b59:	6a 7d                	push   $0x7d
  800b5b:	68 e4 23 80 00       	push   $0x8023e4
  800b60:	e8 0e 0a 00 00       	call   801573 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b65:	83 ec 04             	sub    $0x4,%esp
  800b68:	50                   	push   %eax
  800b69:	68 00 50 80 00       	push   $0x805000
  800b6e:	ff 75 0c             	pushl  0xc(%ebp)
  800b71:	e8 ef 11 00 00       	call   801d65 <memmove>
	return r;
  800b76:	83 c4 10             	add    $0x10,%esp
}
  800b79:	89 d8                	mov    %ebx,%eax
  800b7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	53                   	push   %ebx
  800b86:	83 ec 20             	sub    $0x20,%esp
  800b89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b8c:	53                   	push   %ebx
  800b8d:	e8 08 10 00 00       	call   801b9a <strlen>
  800b92:	83 c4 10             	add    $0x10,%esp
  800b95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b9a:	7f 67                	jg     800c03 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b9c:	83 ec 0c             	sub    $0xc,%esp
  800b9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ba2:	50                   	push   %eax
  800ba3:	e8 6f f8 ff ff       	call   800417 <fd_alloc>
  800ba8:	83 c4 10             	add    $0x10,%esp
		return r;
  800bab:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bad:	85 c0                	test   %eax,%eax
  800baf:	78 57                	js     800c08 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bb1:	83 ec 08             	sub    $0x8,%esp
  800bb4:	53                   	push   %ebx
  800bb5:	68 00 50 80 00       	push   $0x805000
  800bba:	e8 14 10 00 00       	call   801bd3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bca:	b8 01 00 00 00       	mov    $0x1,%eax
  800bcf:	e8 d0 fd ff ff       	call   8009a4 <fsipc>
  800bd4:	89 c3                	mov    %eax,%ebx
  800bd6:	83 c4 10             	add    $0x10,%esp
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	79 14                	jns    800bf1 <open+0x6f>
		fd_close(fd, 0);
  800bdd:	83 ec 08             	sub    $0x8,%esp
  800be0:	6a 00                	push   $0x0
  800be2:	ff 75 f4             	pushl  -0xc(%ebp)
  800be5:	e8 2a f9 ff ff       	call   800514 <fd_close>
		return r;
  800bea:	83 c4 10             	add    $0x10,%esp
  800bed:	89 da                	mov    %ebx,%edx
  800bef:	eb 17                	jmp    800c08 <open+0x86>
	}

	return fd2num(fd);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	ff 75 f4             	pushl  -0xc(%ebp)
  800bf7:	e8 f4 f7 ff ff       	call   8003f0 <fd2num>
  800bfc:	89 c2                	mov    %eax,%edx
  800bfe:	83 c4 10             	add    $0x10,%esp
  800c01:	eb 05                	jmp    800c08 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c03:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c08:	89 d0                	mov    %edx,%eax
  800c0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    

00800c0f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1a:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1f:	e8 80 fd ff ff       	call   8009a4 <fsipc>
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c2c:	68 fb 23 80 00       	push   $0x8023fb
  800c31:	ff 75 0c             	pushl  0xc(%ebp)
  800c34:	e8 9a 0f 00 00       	call   801bd3 <strcpy>
	return 0;
}
  800c39:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	53                   	push   %ebx
  800c44:	83 ec 10             	sub    $0x10,%esp
  800c47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c4a:	53                   	push   %ebx
  800c4b:	e8 c5 13 00 00       	call   802015 <pageref>
  800c50:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c53:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c58:	83 f8 01             	cmp    $0x1,%eax
  800c5b:	75 10                	jne    800c6d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	ff 73 0c             	pushl  0xc(%ebx)
  800c63:	e8 ca 02 00 00       	call   800f32 <nsipc_close>
  800c68:	89 c2                	mov    %eax,%edx
  800c6a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c6d:	89 d0                	mov    %edx,%eax
  800c6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c72:	c9                   	leave  
  800c73:	c3                   	ret    

00800c74 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c7a:	6a 00                	push   $0x0
  800c7c:	ff 75 10             	pushl  0x10(%ebp)
  800c7f:	ff 75 0c             	pushl  0xc(%ebp)
  800c82:	8b 45 08             	mov    0x8(%ebp),%eax
  800c85:	ff 70 0c             	pushl  0xc(%eax)
  800c88:	e8 82 03 00 00       	call   80100f <nsipc_send>
}
  800c8d:	c9                   	leave  
  800c8e:	c3                   	ret    

00800c8f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c95:	6a 00                	push   $0x0
  800c97:	ff 75 10             	pushl  0x10(%ebp)
  800c9a:	ff 75 0c             	pushl  0xc(%ebp)
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	ff 70 0c             	pushl  0xc(%eax)
  800ca3:	e8 fb 02 00 00       	call   800fa3 <nsipc_recv>
}
  800ca8:	c9                   	leave  
  800ca9:	c3                   	ret    

00800caa <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800cb0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800cb3:	52                   	push   %edx
  800cb4:	50                   	push   %eax
  800cb5:	e8 ac f7 ff ff       	call   800466 <fd_lookup>
  800cba:	83 c4 10             	add    $0x10,%esp
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	78 17                	js     800cd8 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc4:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800cca:	39 08                	cmp    %ecx,(%eax)
  800ccc:	75 05                	jne    800cd3 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800cce:	8b 40 0c             	mov    0xc(%eax),%eax
  800cd1:	eb 05                	jmp    800cd8 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800cd3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800cd8:	c9                   	leave  
  800cd9:	c3                   	ret    

00800cda <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 1c             	sub    $0x1c,%esp
  800ce2:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800ce4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ce7:	50                   	push   %eax
  800ce8:	e8 2a f7 ff ff       	call   800417 <fd_alloc>
  800ced:	89 c3                	mov    %eax,%ebx
  800cef:	83 c4 10             	add    $0x10,%esp
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	78 1b                	js     800d11 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cf6:	83 ec 04             	sub    $0x4,%esp
  800cf9:	68 07 04 00 00       	push   $0x407
  800cfe:	ff 75 f4             	pushl  -0xc(%ebp)
  800d01:	6a 00                	push   $0x0
  800d03:	e8 56 f4 ff ff       	call   80015e <sys_page_alloc>
  800d08:	89 c3                	mov    %eax,%ebx
  800d0a:	83 c4 10             	add    $0x10,%esp
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	79 10                	jns    800d21 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	56                   	push   %esi
  800d15:	e8 18 02 00 00       	call   800f32 <nsipc_close>
		return r;
  800d1a:	83 c4 10             	add    $0x10,%esp
  800d1d:	89 d8                	mov    %ebx,%eax
  800d1f:	eb 24                	jmp    800d45 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d21:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d2a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d2f:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  800d36:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	52                   	push   %edx
  800d3d:	e8 ae f6 ff ff       	call   8003f0 <fd2num>
  800d42:	83 c4 10             	add    $0x10,%esp
}
  800d45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	e8 50 ff ff ff       	call   800caa <fd2sockid>
		return r;
  800d5a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	78 1f                	js     800d7f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	ff 75 10             	pushl  0x10(%ebp)
  800d66:	ff 75 0c             	pushl  0xc(%ebp)
  800d69:	50                   	push   %eax
  800d6a:	e8 1c 01 00 00       	call   800e8b <nsipc_accept>
  800d6f:	83 c4 10             	add    $0x10,%esp
		return r;
  800d72:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	78 07                	js     800d7f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d78:	e8 5d ff ff ff       	call   800cda <alloc_sockfd>
  800d7d:	89 c1                	mov    %eax,%ecx
}
  800d7f:	89 c8                	mov    %ecx,%eax
  800d81:	c9                   	leave  
  800d82:	c3                   	ret    

00800d83 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	e8 19 ff ff ff       	call   800caa <fd2sockid>
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	85 d2                	test   %edx,%edx
  800d95:	78 12                	js     800da9 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  800d97:	83 ec 04             	sub    $0x4,%esp
  800d9a:	ff 75 10             	pushl  0x10(%ebp)
  800d9d:	ff 75 0c             	pushl  0xc(%ebp)
  800da0:	52                   	push   %edx
  800da1:	e8 35 01 00 00       	call   800edb <nsipc_bind>
  800da6:	83 c4 10             	add    $0x10,%esp
}
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    

00800dab <shutdown>:

int
shutdown(int s, int how)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800db1:	8b 45 08             	mov    0x8(%ebp),%eax
  800db4:	e8 f1 fe ff ff       	call   800caa <fd2sockid>
  800db9:	89 c2                	mov    %eax,%edx
  800dbb:	85 d2                	test   %edx,%edx
  800dbd:	78 0f                	js     800dce <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  800dbf:	83 ec 08             	sub    $0x8,%esp
  800dc2:	ff 75 0c             	pushl  0xc(%ebp)
  800dc5:	52                   	push   %edx
  800dc6:	e8 45 01 00 00       	call   800f10 <nsipc_shutdown>
  800dcb:	83 c4 10             	add    $0x10,%esp
}
  800dce:	c9                   	leave  
  800dcf:	c3                   	ret    

00800dd0 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd9:	e8 cc fe ff ff       	call   800caa <fd2sockid>
  800dde:	89 c2                	mov    %eax,%edx
  800de0:	85 d2                	test   %edx,%edx
  800de2:	78 12                	js     800df6 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  800de4:	83 ec 04             	sub    $0x4,%esp
  800de7:	ff 75 10             	pushl  0x10(%ebp)
  800dea:	ff 75 0c             	pushl  0xc(%ebp)
  800ded:	52                   	push   %edx
  800dee:	e8 59 01 00 00       	call   800f4c <nsipc_connect>
  800df3:	83 c4 10             	add    $0x10,%esp
}
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    

00800df8 <listen>:

int
listen(int s, int backlog)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	e8 a4 fe ff ff       	call   800caa <fd2sockid>
  800e06:	89 c2                	mov    %eax,%edx
  800e08:	85 d2                	test   %edx,%edx
  800e0a:	78 0f                	js     800e1b <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  800e0c:	83 ec 08             	sub    $0x8,%esp
  800e0f:	ff 75 0c             	pushl  0xc(%ebp)
  800e12:	52                   	push   %edx
  800e13:	e8 69 01 00 00       	call   800f81 <nsipc_listen>
  800e18:	83 c4 10             	add    $0x10,%esp
}
  800e1b:	c9                   	leave  
  800e1c:	c3                   	ret    

00800e1d <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e23:	ff 75 10             	pushl  0x10(%ebp)
  800e26:	ff 75 0c             	pushl  0xc(%ebp)
  800e29:	ff 75 08             	pushl  0x8(%ebp)
  800e2c:	e8 3c 02 00 00       	call   80106d <nsipc_socket>
  800e31:	89 c2                	mov    %eax,%edx
  800e33:	83 c4 10             	add    $0x10,%esp
  800e36:	85 d2                	test   %edx,%edx
  800e38:	78 05                	js     800e3f <socket+0x22>
		return r;
	return alloc_sockfd(r);
  800e3a:	e8 9b fe ff ff       	call   800cda <alloc_sockfd>
}
  800e3f:	c9                   	leave  
  800e40:	c3                   	ret    

00800e41 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	53                   	push   %ebx
  800e45:	83 ec 04             	sub    $0x4,%esp
  800e48:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e4a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e51:	75 12                	jne    800e65 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	6a 02                	push   $0x2
  800e58:	e8 80 11 00 00       	call   801fdd <ipc_find_env>
  800e5d:	a3 04 40 80 00       	mov    %eax,0x804004
  800e62:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e65:	6a 07                	push   $0x7
  800e67:	68 00 60 80 00       	push   $0x806000
  800e6c:	53                   	push   %ebx
  800e6d:	ff 35 04 40 80 00    	pushl  0x804004
  800e73:	e8 11 11 00 00       	call   801f89 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e78:	83 c4 0c             	add    $0xc,%esp
  800e7b:	6a 00                	push   $0x0
  800e7d:	6a 00                	push   $0x0
  800e7f:	6a 00                	push   $0x0
  800e81:	e8 9a 10 00 00       	call   801f20 <ipc_recv>
}
  800e86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e89:	c9                   	leave  
  800e8a:	c3                   	ret    

00800e8b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	56                   	push   %esi
  800e8f:	53                   	push   %ebx
  800e90:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e93:	8b 45 08             	mov    0x8(%ebp),%eax
  800e96:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e9b:	8b 06                	mov    (%esi),%eax
  800e9d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800ea2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea7:	e8 95 ff ff ff       	call   800e41 <nsipc>
  800eac:	89 c3                	mov    %eax,%ebx
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	78 20                	js     800ed2 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800eb2:	83 ec 04             	sub    $0x4,%esp
  800eb5:	ff 35 10 60 80 00    	pushl  0x806010
  800ebb:	68 00 60 80 00       	push   $0x806000
  800ec0:	ff 75 0c             	pushl  0xc(%ebp)
  800ec3:	e8 9d 0e 00 00       	call   801d65 <memmove>
		*addrlen = ret->ret_addrlen;
  800ec8:	a1 10 60 80 00       	mov    0x806010,%eax
  800ecd:	89 06                	mov    %eax,(%esi)
  800ecf:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800ed2:	89 d8                	mov    %ebx,%eax
  800ed4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	53                   	push   %ebx
  800edf:	83 ec 08             	sub    $0x8,%esp
  800ee2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800ee5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800eed:	53                   	push   %ebx
  800eee:	ff 75 0c             	pushl  0xc(%ebp)
  800ef1:	68 04 60 80 00       	push   $0x806004
  800ef6:	e8 6a 0e 00 00       	call   801d65 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800efb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800f01:	b8 02 00 00 00       	mov    $0x2,%eax
  800f06:	e8 36 ff ff ff       	call   800e41 <nsipc>
}
  800f0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f0e:	c9                   	leave  
  800f0f:	c3                   	ret    

00800f10 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
  800f19:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f21:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f26:	b8 03 00 00 00       	mov    $0x3,%eax
  800f2b:	e8 11 ff ff ff       	call   800e41 <nsipc>
}
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    

00800f32 <nsipc_close>:

int
nsipc_close(int s)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f38:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f40:	b8 04 00 00 00       	mov    $0x4,%eax
  800f45:	e8 f7 fe ff ff       	call   800e41 <nsipc>
}
  800f4a:	c9                   	leave  
  800f4b:	c3                   	ret    

00800f4c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 08             	sub    $0x8,%esp
  800f53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f56:	8b 45 08             	mov    0x8(%ebp),%eax
  800f59:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f5e:	53                   	push   %ebx
  800f5f:	ff 75 0c             	pushl  0xc(%ebp)
  800f62:	68 04 60 80 00       	push   $0x806004
  800f67:	e8 f9 0d 00 00       	call   801d65 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f6c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f72:	b8 05 00 00 00       	mov    $0x5,%eax
  800f77:	e8 c5 fe ff ff       	call   800e41 <nsipc>
}
  800f7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    

00800f81 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f87:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f92:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f97:	b8 06 00 00 00       	mov    $0x6,%eax
  800f9c:	e8 a0 fe ff ff       	call   800e41 <nsipc>
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
  800fa8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fab:	8b 45 08             	mov    0x8(%ebp),%eax
  800fae:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800fb3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800fb9:	8b 45 14             	mov    0x14(%ebp),%eax
  800fbc:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800fc1:	b8 07 00 00 00       	mov    $0x7,%eax
  800fc6:	e8 76 fe ff ff       	call   800e41 <nsipc>
  800fcb:	89 c3                	mov    %eax,%ebx
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 35                	js     801006 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800fd1:	39 f0                	cmp    %esi,%eax
  800fd3:	7f 07                	jg     800fdc <nsipc_recv+0x39>
  800fd5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800fda:	7e 16                	jle    800ff2 <nsipc_recv+0x4f>
  800fdc:	68 07 24 80 00       	push   $0x802407
  800fe1:	68 cf 23 80 00       	push   $0x8023cf
  800fe6:	6a 62                	push   $0x62
  800fe8:	68 1c 24 80 00       	push   $0x80241c
  800fed:	e8 81 05 00 00       	call   801573 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800ff2:	83 ec 04             	sub    $0x4,%esp
  800ff5:	50                   	push   %eax
  800ff6:	68 00 60 80 00       	push   $0x806000
  800ffb:	ff 75 0c             	pushl  0xc(%ebp)
  800ffe:	e8 62 0d 00 00       	call   801d65 <memmove>
  801003:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801006:	89 d8                	mov    %ebx,%eax
  801008:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    

0080100f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	53                   	push   %ebx
  801013:	83 ec 04             	sub    $0x4,%esp
  801016:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801019:	8b 45 08             	mov    0x8(%ebp),%eax
  80101c:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801021:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801027:	7e 16                	jle    80103f <nsipc_send+0x30>
  801029:	68 28 24 80 00       	push   $0x802428
  80102e:	68 cf 23 80 00       	push   $0x8023cf
  801033:	6a 6d                	push   $0x6d
  801035:	68 1c 24 80 00       	push   $0x80241c
  80103a:	e8 34 05 00 00       	call   801573 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	53                   	push   %ebx
  801043:	ff 75 0c             	pushl  0xc(%ebp)
  801046:	68 0c 60 80 00       	push   $0x80600c
  80104b:	e8 15 0d 00 00       	call   801d65 <memmove>
	nsipcbuf.send.req_size = size;
  801050:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801056:	8b 45 14             	mov    0x14(%ebp),%eax
  801059:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80105e:	b8 08 00 00 00       	mov    $0x8,%eax
  801063:	e8 d9 fd ff ff       	call   800e41 <nsipc>
}
  801068:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106b:	c9                   	leave  
  80106c:	c3                   	ret    

0080106d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80107b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801083:	8b 45 10             	mov    0x10(%ebp),%eax
  801086:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80108b:	b8 09 00 00 00       	mov    $0x9,%eax
  801090:	e8 ac fd ff ff       	call   800e41 <nsipc>
}
  801095:	c9                   	leave  
  801096:	c3                   	ret    

00801097 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	56                   	push   %esi
  80109b:	53                   	push   %ebx
  80109c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	ff 75 08             	pushl  0x8(%ebp)
  8010a5:	e8 56 f3 ff ff       	call   800400 <fd2data>
  8010aa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010ac:	83 c4 08             	add    $0x8,%esp
  8010af:	68 34 24 80 00       	push   $0x802434
  8010b4:	53                   	push   %ebx
  8010b5:	e8 19 0b 00 00       	call   801bd3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010ba:	8b 56 04             	mov    0x4(%esi),%edx
  8010bd:	89 d0                	mov    %edx,%eax
  8010bf:	2b 06                	sub    (%esi),%eax
  8010c1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8010c7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8010ce:	00 00 00 
	stat->st_dev = &devpipe;
  8010d1:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8010d8:	30 80 00 
	return 0;
}
  8010db:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e3:	5b                   	pop    %ebx
  8010e4:	5e                   	pop    %esi
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    

008010e7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	53                   	push   %ebx
  8010eb:	83 ec 0c             	sub    $0xc,%esp
  8010ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010f1:	53                   	push   %ebx
  8010f2:	6a 00                	push   $0x0
  8010f4:	e8 ea f0 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010f9:	89 1c 24             	mov    %ebx,(%esp)
  8010fc:	e8 ff f2 ff ff       	call   800400 <fd2data>
  801101:	83 c4 08             	add    $0x8,%esp
  801104:	50                   	push   %eax
  801105:	6a 00                	push   $0x0
  801107:	e8 d7 f0 ff ff       	call   8001e3 <sys_page_unmap>
}
  80110c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110f:	c9                   	leave  
  801110:	c3                   	ret    

00801111 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	57                   	push   %edi
  801115:	56                   	push   %esi
  801116:	53                   	push   %ebx
  801117:	83 ec 1c             	sub    $0x1c,%esp
  80111a:	89 c6                	mov    %eax,%esi
  80111c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80111f:	a1 08 40 80 00       	mov    0x804008,%eax
  801124:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	56                   	push   %esi
  80112b:	e8 e5 0e 00 00       	call   802015 <pageref>
  801130:	89 c7                	mov    %eax,%edi
  801132:	83 c4 04             	add    $0x4,%esp
  801135:	ff 75 e4             	pushl  -0x1c(%ebp)
  801138:	e8 d8 0e 00 00       	call   802015 <pageref>
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	39 c7                	cmp    %eax,%edi
  801142:	0f 94 c2             	sete   %dl
  801145:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801148:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  80114e:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801151:	39 fb                	cmp    %edi,%ebx
  801153:	74 19                	je     80116e <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801155:	84 d2                	test   %dl,%dl
  801157:	74 c6                	je     80111f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801159:	8b 51 58             	mov    0x58(%ecx),%edx
  80115c:	50                   	push   %eax
  80115d:	52                   	push   %edx
  80115e:	53                   	push   %ebx
  80115f:	68 3b 24 80 00       	push   $0x80243b
  801164:	e8 e3 04 00 00       	call   80164c <cprintf>
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	eb b1                	jmp    80111f <_pipeisclosed+0xe>
	}
}
  80116e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801171:	5b                   	pop    %ebx
  801172:	5e                   	pop    %esi
  801173:	5f                   	pop    %edi
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	57                   	push   %edi
  80117a:	56                   	push   %esi
  80117b:	53                   	push   %ebx
  80117c:	83 ec 28             	sub    $0x28,%esp
  80117f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801182:	56                   	push   %esi
  801183:	e8 78 f2 ff ff       	call   800400 <fd2data>
  801188:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80118a:	83 c4 10             	add    $0x10,%esp
  80118d:	bf 00 00 00 00       	mov    $0x0,%edi
  801192:	eb 4b                	jmp    8011df <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801194:	89 da                	mov    %ebx,%edx
  801196:	89 f0                	mov    %esi,%eax
  801198:	e8 74 ff ff ff       	call   801111 <_pipeisclosed>
  80119d:	85 c0                	test   %eax,%eax
  80119f:	75 48                	jne    8011e9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011a1:	e8 99 ef ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011a6:	8b 43 04             	mov    0x4(%ebx),%eax
  8011a9:	8b 0b                	mov    (%ebx),%ecx
  8011ab:	8d 51 20             	lea    0x20(%ecx),%edx
  8011ae:	39 d0                	cmp    %edx,%eax
  8011b0:	73 e2                	jae    801194 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011b9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8011bc:	89 c2                	mov    %eax,%edx
  8011be:	c1 fa 1f             	sar    $0x1f,%edx
  8011c1:	89 d1                	mov    %edx,%ecx
  8011c3:	c1 e9 1b             	shr    $0x1b,%ecx
  8011c6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8011c9:	83 e2 1f             	and    $0x1f,%edx
  8011cc:	29 ca                	sub    %ecx,%edx
  8011ce:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8011d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011d6:	83 c0 01             	add    $0x1,%eax
  8011d9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011dc:	83 c7 01             	add    $0x1,%edi
  8011df:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011e2:	75 c2                	jne    8011a6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8011e7:	eb 05                	jmp    8011ee <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011e9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f1:	5b                   	pop    %ebx
  8011f2:	5e                   	pop    %esi
  8011f3:	5f                   	pop    %edi
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	57                   	push   %edi
  8011fa:	56                   	push   %esi
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 18             	sub    $0x18,%esp
  8011ff:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801202:	57                   	push   %edi
  801203:	e8 f8 f1 ff ff       	call   800400 <fd2data>
  801208:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801212:	eb 3d                	jmp    801251 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801214:	85 db                	test   %ebx,%ebx
  801216:	74 04                	je     80121c <devpipe_read+0x26>
				return i;
  801218:	89 d8                	mov    %ebx,%eax
  80121a:	eb 44                	jmp    801260 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80121c:	89 f2                	mov    %esi,%edx
  80121e:	89 f8                	mov    %edi,%eax
  801220:	e8 ec fe ff ff       	call   801111 <_pipeisclosed>
  801225:	85 c0                	test   %eax,%eax
  801227:	75 32                	jne    80125b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801229:	e8 11 ef ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80122e:	8b 06                	mov    (%esi),%eax
  801230:	3b 46 04             	cmp    0x4(%esi),%eax
  801233:	74 df                	je     801214 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801235:	99                   	cltd   
  801236:	c1 ea 1b             	shr    $0x1b,%edx
  801239:	01 d0                	add    %edx,%eax
  80123b:	83 e0 1f             	and    $0x1f,%eax
  80123e:	29 d0                	sub    %edx,%eax
  801240:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801245:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801248:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80124b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80124e:	83 c3 01             	add    $0x1,%ebx
  801251:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801254:	75 d8                	jne    80122e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801256:	8b 45 10             	mov    0x10(%ebp),%eax
  801259:	eb 05                	jmp    801260 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80125b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	56                   	push   %esi
  80126c:	53                   	push   %ebx
  80126d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801270:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801273:	50                   	push   %eax
  801274:	e8 9e f1 ff ff       	call   800417 <fd_alloc>
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	89 c2                	mov    %eax,%edx
  80127e:	85 c0                	test   %eax,%eax
  801280:	0f 88 2c 01 00 00    	js     8013b2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801286:	83 ec 04             	sub    $0x4,%esp
  801289:	68 07 04 00 00       	push   $0x407
  80128e:	ff 75 f4             	pushl  -0xc(%ebp)
  801291:	6a 00                	push   $0x0
  801293:	e8 c6 ee ff ff       	call   80015e <sys_page_alloc>
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	89 c2                	mov    %eax,%edx
  80129d:	85 c0                	test   %eax,%eax
  80129f:	0f 88 0d 01 00 00    	js     8013b2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012a5:	83 ec 0c             	sub    $0xc,%esp
  8012a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	e8 66 f1 ff ff       	call   800417 <fd_alloc>
  8012b1:	89 c3                	mov    %eax,%ebx
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	0f 88 e2 00 00 00    	js     8013a0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012be:	83 ec 04             	sub    $0x4,%esp
  8012c1:	68 07 04 00 00       	push   $0x407
  8012c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c9:	6a 00                	push   $0x0
  8012cb:	e8 8e ee ff ff       	call   80015e <sys_page_alloc>
  8012d0:	89 c3                	mov    %eax,%ebx
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	0f 88 c3 00 00 00    	js     8013a0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012dd:	83 ec 0c             	sub    $0xc,%esp
  8012e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e3:	e8 18 f1 ff ff       	call   800400 <fd2data>
  8012e8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ea:	83 c4 0c             	add    $0xc,%esp
  8012ed:	68 07 04 00 00       	push   $0x407
  8012f2:	50                   	push   %eax
  8012f3:	6a 00                	push   $0x0
  8012f5:	e8 64 ee ff ff       	call   80015e <sys_page_alloc>
  8012fa:	89 c3                	mov    %eax,%ebx
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	0f 88 89 00 00 00    	js     801390 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801307:	83 ec 0c             	sub    $0xc,%esp
  80130a:	ff 75 f0             	pushl  -0x10(%ebp)
  80130d:	e8 ee f0 ff ff       	call   800400 <fd2data>
  801312:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801319:	50                   	push   %eax
  80131a:	6a 00                	push   $0x0
  80131c:	56                   	push   %esi
  80131d:	6a 00                	push   $0x0
  80131f:	e8 7d ee ff ff       	call   8001a1 <sys_page_map>
  801324:	89 c3                	mov    %eax,%ebx
  801326:	83 c4 20             	add    $0x20,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 55                	js     801382 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80132d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801333:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801336:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801338:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801342:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801348:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80134d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801350:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801357:	83 ec 0c             	sub    $0xc,%esp
  80135a:	ff 75 f4             	pushl  -0xc(%ebp)
  80135d:	e8 8e f0 ff ff       	call   8003f0 <fd2num>
  801362:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801365:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801367:	83 c4 04             	add    $0x4,%esp
  80136a:	ff 75 f0             	pushl  -0x10(%ebp)
  80136d:	e8 7e f0 ff ff       	call   8003f0 <fd2num>
  801372:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801375:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	ba 00 00 00 00       	mov    $0x0,%edx
  801380:	eb 30                	jmp    8013b2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	56                   	push   %esi
  801386:	6a 00                	push   $0x0
  801388:	e8 56 ee ff ff       	call   8001e3 <sys_page_unmap>
  80138d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	ff 75 f0             	pushl  -0x10(%ebp)
  801396:	6a 00                	push   $0x0
  801398:	e8 46 ee ff ff       	call   8001e3 <sys_page_unmap>
  80139d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a6:	6a 00                	push   $0x0
  8013a8:	e8 36 ee ff ff       	call   8001e3 <sys_page_unmap>
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013b2:	89 d0                	mov    %edx,%eax
  8013b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5e                   	pop    %esi
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    

008013bb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c4:	50                   	push   %eax
  8013c5:	ff 75 08             	pushl  0x8(%ebp)
  8013c8:	e8 99 f0 ff ff       	call   800466 <fd_lookup>
  8013cd:	89 c2                	mov    %eax,%edx
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	85 d2                	test   %edx,%edx
  8013d4:	78 18                	js     8013ee <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8013dc:	e8 1f f0 ff ff       	call   800400 <fd2data>
	return _pipeisclosed(fd, p);
  8013e1:	89 c2                	mov    %eax,%edx
  8013e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e6:	e8 26 fd ff ff       	call   801111 <_pipeisclosed>
  8013eb:	83 c4 10             	add    $0x10,%esp
}
  8013ee:	c9                   	leave  
  8013ef:	c3                   	ret    

008013f0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f8:	5d                   	pop    %ebp
  8013f9:	c3                   	ret    

008013fa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801400:	68 53 24 80 00       	push   $0x802453
  801405:	ff 75 0c             	pushl  0xc(%ebp)
  801408:	e8 c6 07 00 00       	call   801bd3 <strcpy>
	return 0;
}
  80140d:	b8 00 00 00 00       	mov    $0x0,%eax
  801412:	c9                   	leave  
  801413:	c3                   	ret    

00801414 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	57                   	push   %edi
  801418:	56                   	push   %esi
  801419:	53                   	push   %ebx
  80141a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801420:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801425:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80142b:	eb 2d                	jmp    80145a <devcons_write+0x46>
		m = n - tot;
  80142d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801430:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801432:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801435:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80143a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80143d:	83 ec 04             	sub    $0x4,%esp
  801440:	53                   	push   %ebx
  801441:	03 45 0c             	add    0xc(%ebp),%eax
  801444:	50                   	push   %eax
  801445:	57                   	push   %edi
  801446:	e8 1a 09 00 00       	call   801d65 <memmove>
		sys_cputs(buf, m);
  80144b:	83 c4 08             	add    $0x8,%esp
  80144e:	53                   	push   %ebx
  80144f:	57                   	push   %edi
  801450:	e8 4d ec ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801455:	01 de                	add    %ebx,%esi
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	89 f0                	mov    %esi,%eax
  80145c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80145f:	72 cc                	jb     80142d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801461:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801464:	5b                   	pop    %ebx
  801465:	5e                   	pop    %esi
  801466:	5f                   	pop    %edi
  801467:	5d                   	pop    %ebp
  801468:	c3                   	ret    

00801469 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80146f:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801474:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801478:	75 07                	jne    801481 <devcons_read+0x18>
  80147a:	eb 28                	jmp    8014a4 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80147c:	e8 be ec ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801481:	e8 3a ec ff ff       	call   8000c0 <sys_cgetc>
  801486:	85 c0                	test   %eax,%eax
  801488:	74 f2                	je     80147c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 16                	js     8014a4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80148e:	83 f8 04             	cmp    $0x4,%eax
  801491:	74 0c                	je     80149f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801493:	8b 55 0c             	mov    0xc(%ebp),%edx
  801496:	88 02                	mov    %al,(%edx)
	return 1;
  801498:	b8 01 00 00 00       	mov    $0x1,%eax
  80149d:	eb 05                	jmp    8014a4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80149f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8014af:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014b2:	6a 01                	push   $0x1
  8014b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014b7:	50                   	push   %eax
  8014b8:	e8 e5 eb ff ff       	call   8000a2 <sys_cputs>
  8014bd:	83 c4 10             	add    $0x10,%esp
}
  8014c0:	c9                   	leave  
  8014c1:	c3                   	ret    

008014c2 <getchar>:

int
getchar(void)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014c8:	6a 01                	push   $0x1
  8014ca:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014cd:	50                   	push   %eax
  8014ce:	6a 00                	push   $0x0
  8014d0:	e8 00 f2 ff ff       	call   8006d5 <read>
	if (r < 0)
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	78 0f                	js     8014eb <getchar+0x29>
		return r;
	if (r < 1)
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	7e 06                	jle    8014e6 <getchar+0x24>
		return -E_EOF;
	return c;
  8014e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014e4:	eb 05                	jmp    8014eb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014e6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f6:	50                   	push   %eax
  8014f7:	ff 75 08             	pushl  0x8(%ebp)
  8014fa:	e8 67 ef ff ff       	call   800466 <fd_lookup>
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	85 c0                	test   %eax,%eax
  801504:	78 11                	js     801517 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801506:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801509:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80150f:	39 10                	cmp    %edx,(%eax)
  801511:	0f 94 c0             	sete   %al
  801514:	0f b6 c0             	movzbl %al,%eax
}
  801517:	c9                   	leave  
  801518:	c3                   	ret    

00801519 <opencons>:

int
opencons(void)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80151f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	e8 ef ee ff ff       	call   800417 <fd_alloc>
  801528:	83 c4 10             	add    $0x10,%esp
		return r;
  80152b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 3e                	js     80156f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801531:	83 ec 04             	sub    $0x4,%esp
  801534:	68 07 04 00 00       	push   $0x407
  801539:	ff 75 f4             	pushl  -0xc(%ebp)
  80153c:	6a 00                	push   $0x0
  80153e:	e8 1b ec ff ff       	call   80015e <sys_page_alloc>
  801543:	83 c4 10             	add    $0x10,%esp
		return r;
  801546:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 23                	js     80156f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80154c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801552:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801555:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801557:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801561:	83 ec 0c             	sub    $0xc,%esp
  801564:	50                   	push   %eax
  801565:	e8 86 ee ff ff       	call   8003f0 <fd2num>
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	83 c4 10             	add    $0x10,%esp
}
  80156f:	89 d0                	mov    %edx,%eax
  801571:	c9                   	leave  
  801572:	c3                   	ret    

00801573 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	56                   	push   %esi
  801577:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801578:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80157b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801581:	e8 9a eb ff ff       	call   800120 <sys_getenvid>
  801586:	83 ec 0c             	sub    $0xc,%esp
  801589:	ff 75 0c             	pushl  0xc(%ebp)
  80158c:	ff 75 08             	pushl  0x8(%ebp)
  80158f:	56                   	push   %esi
  801590:	50                   	push   %eax
  801591:	68 60 24 80 00       	push   $0x802460
  801596:	e8 b1 00 00 00       	call   80164c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80159b:	83 c4 18             	add    $0x18,%esp
  80159e:	53                   	push   %ebx
  80159f:	ff 75 10             	pushl  0x10(%ebp)
  8015a2:	e8 54 00 00 00       	call   8015fb <vcprintf>
	cprintf("\n");
  8015a7:	c7 04 24 4c 24 80 00 	movl   $0x80244c,(%esp)
  8015ae:	e8 99 00 00 00       	call   80164c <cprintf>
  8015b3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015b6:	cc                   	int3   
  8015b7:	eb fd                	jmp    8015b6 <_panic+0x43>

008015b9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 04             	sub    $0x4,%esp
  8015c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015c3:	8b 13                	mov    (%ebx),%edx
  8015c5:	8d 42 01             	lea    0x1(%edx),%eax
  8015c8:	89 03                	mov    %eax,(%ebx)
  8015ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8015d1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015d6:	75 1a                	jne    8015f2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8015d8:	83 ec 08             	sub    $0x8,%esp
  8015db:	68 ff 00 00 00       	push   $0xff
  8015e0:	8d 43 08             	lea    0x8(%ebx),%eax
  8015e3:	50                   	push   %eax
  8015e4:	e8 b9 ea ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8015e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015ef:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015f2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    

008015fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801604:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80160b:	00 00 00 
	b.cnt = 0;
  80160e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801615:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801618:	ff 75 0c             	pushl  0xc(%ebp)
  80161b:	ff 75 08             	pushl  0x8(%ebp)
  80161e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	68 b9 15 80 00       	push   $0x8015b9
  80162a:	e8 4f 01 00 00       	call   80177e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80162f:	83 c4 08             	add    $0x8,%esp
  801632:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801638:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80163e:	50                   	push   %eax
  80163f:	e8 5e ea ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  801644:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    

0080164c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801652:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801655:	50                   	push   %eax
  801656:	ff 75 08             	pushl  0x8(%ebp)
  801659:	e8 9d ff ff ff       	call   8015fb <vcprintf>
	va_end(ap);

	return cnt;
}
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	57                   	push   %edi
  801664:	56                   	push   %esi
  801665:	53                   	push   %ebx
  801666:	83 ec 1c             	sub    $0x1c,%esp
  801669:	89 c7                	mov    %eax,%edi
  80166b:	89 d6                	mov    %edx,%esi
  80166d:	8b 45 08             	mov    0x8(%ebp),%eax
  801670:	8b 55 0c             	mov    0xc(%ebp),%edx
  801673:	89 d1                	mov    %edx,%ecx
  801675:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801678:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80167b:	8b 45 10             	mov    0x10(%ebp),%eax
  80167e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801681:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801684:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80168b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80168e:	72 05                	jb     801695 <printnum+0x35>
  801690:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801693:	77 3e                	ja     8016d3 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801695:	83 ec 0c             	sub    $0xc,%esp
  801698:	ff 75 18             	pushl  0x18(%ebp)
  80169b:	83 eb 01             	sub    $0x1,%ebx
  80169e:	53                   	push   %ebx
  80169f:	50                   	push   %eax
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a9:	ff 75 dc             	pushl  -0x24(%ebp)
  8016ac:	ff 75 d8             	pushl  -0x28(%ebp)
  8016af:	e8 9c 09 00 00       	call   802050 <__udivdi3>
  8016b4:	83 c4 18             	add    $0x18,%esp
  8016b7:	52                   	push   %edx
  8016b8:	50                   	push   %eax
  8016b9:	89 f2                	mov    %esi,%edx
  8016bb:	89 f8                	mov    %edi,%eax
  8016bd:	e8 9e ff ff ff       	call   801660 <printnum>
  8016c2:	83 c4 20             	add    $0x20,%esp
  8016c5:	eb 13                	jmp    8016da <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8016c7:	83 ec 08             	sub    $0x8,%esp
  8016ca:	56                   	push   %esi
  8016cb:	ff 75 18             	pushl  0x18(%ebp)
  8016ce:	ff d7                	call   *%edi
  8016d0:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8016d3:	83 eb 01             	sub    $0x1,%ebx
  8016d6:	85 db                	test   %ebx,%ebx
  8016d8:	7f ed                	jg     8016c7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	56                   	push   %esi
  8016de:	83 ec 04             	sub    $0x4,%esp
  8016e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8016e7:	ff 75 dc             	pushl  -0x24(%ebp)
  8016ea:	ff 75 d8             	pushl  -0x28(%ebp)
  8016ed:	e8 8e 0a 00 00       	call   802180 <__umoddi3>
  8016f2:	83 c4 14             	add    $0x14,%esp
  8016f5:	0f be 80 83 24 80 00 	movsbl 0x802483(%eax),%eax
  8016fc:	50                   	push   %eax
  8016fd:	ff d7                	call   *%edi
  8016ff:	83 c4 10             	add    $0x10,%esp
}
  801702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801705:	5b                   	pop    %ebx
  801706:	5e                   	pop    %esi
  801707:	5f                   	pop    %edi
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    

0080170a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80170d:	83 fa 01             	cmp    $0x1,%edx
  801710:	7e 0e                	jle    801720 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801712:	8b 10                	mov    (%eax),%edx
  801714:	8d 4a 08             	lea    0x8(%edx),%ecx
  801717:	89 08                	mov    %ecx,(%eax)
  801719:	8b 02                	mov    (%edx),%eax
  80171b:	8b 52 04             	mov    0x4(%edx),%edx
  80171e:	eb 22                	jmp    801742 <getuint+0x38>
	else if (lflag)
  801720:	85 d2                	test   %edx,%edx
  801722:	74 10                	je     801734 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801724:	8b 10                	mov    (%eax),%edx
  801726:	8d 4a 04             	lea    0x4(%edx),%ecx
  801729:	89 08                	mov    %ecx,(%eax)
  80172b:	8b 02                	mov    (%edx),%eax
  80172d:	ba 00 00 00 00       	mov    $0x0,%edx
  801732:	eb 0e                	jmp    801742 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801734:	8b 10                	mov    (%eax),%edx
  801736:	8d 4a 04             	lea    0x4(%edx),%ecx
  801739:	89 08                	mov    %ecx,(%eax)
  80173b:	8b 02                	mov    (%edx),%eax
  80173d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801742:	5d                   	pop    %ebp
  801743:	c3                   	ret    

00801744 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80174a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80174e:	8b 10                	mov    (%eax),%edx
  801750:	3b 50 04             	cmp    0x4(%eax),%edx
  801753:	73 0a                	jae    80175f <sprintputch+0x1b>
		*b->buf++ = ch;
  801755:	8d 4a 01             	lea    0x1(%edx),%ecx
  801758:	89 08                	mov    %ecx,(%eax)
  80175a:	8b 45 08             	mov    0x8(%ebp),%eax
  80175d:	88 02                	mov    %al,(%edx)
}
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801767:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80176a:	50                   	push   %eax
  80176b:	ff 75 10             	pushl  0x10(%ebp)
  80176e:	ff 75 0c             	pushl  0xc(%ebp)
  801771:	ff 75 08             	pushl  0x8(%ebp)
  801774:	e8 05 00 00 00       	call   80177e <vprintfmt>
	va_end(ap);
  801779:	83 c4 10             	add    $0x10,%esp
}
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	57                   	push   %edi
  801782:	56                   	push   %esi
  801783:	53                   	push   %ebx
  801784:	83 ec 2c             	sub    $0x2c,%esp
  801787:	8b 75 08             	mov    0x8(%ebp),%esi
  80178a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80178d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801790:	eb 12                	jmp    8017a4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801792:	85 c0                	test   %eax,%eax
  801794:	0f 84 90 03 00 00    	je     801b2a <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80179a:	83 ec 08             	sub    $0x8,%esp
  80179d:	53                   	push   %ebx
  80179e:	50                   	push   %eax
  80179f:	ff d6                	call   *%esi
  8017a1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017a4:	83 c7 01             	add    $0x1,%edi
  8017a7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017ab:	83 f8 25             	cmp    $0x25,%eax
  8017ae:	75 e2                	jne    801792 <vprintfmt+0x14>
  8017b0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017b4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8017bb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017c2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8017c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ce:	eb 07                	jmp    8017d7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8017d3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d7:	8d 47 01             	lea    0x1(%edi),%eax
  8017da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017dd:	0f b6 07             	movzbl (%edi),%eax
  8017e0:	0f b6 c8             	movzbl %al,%ecx
  8017e3:	83 e8 23             	sub    $0x23,%eax
  8017e6:	3c 55                	cmp    $0x55,%al
  8017e8:	0f 87 21 03 00 00    	ja     801b0f <vprintfmt+0x391>
  8017ee:	0f b6 c0             	movzbl %al,%eax
  8017f1:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  8017f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017fb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017ff:	eb d6                	jmp    8017d7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801801:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801804:	b8 00 00 00 00       	mov    $0x0,%eax
  801809:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80180c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80180f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801813:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801816:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801819:	83 fa 09             	cmp    $0x9,%edx
  80181c:	77 39                	ja     801857 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80181e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801821:	eb e9                	jmp    80180c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801823:	8b 45 14             	mov    0x14(%ebp),%eax
  801826:	8d 48 04             	lea    0x4(%eax),%ecx
  801829:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80182c:	8b 00                	mov    (%eax),%eax
  80182e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801831:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801834:	eb 27                	jmp    80185d <vprintfmt+0xdf>
  801836:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801839:	85 c0                	test   %eax,%eax
  80183b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801840:	0f 49 c8             	cmovns %eax,%ecx
  801843:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801846:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801849:	eb 8c                	jmp    8017d7 <vprintfmt+0x59>
  80184b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80184e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801855:	eb 80                	jmp    8017d7 <vprintfmt+0x59>
  801857:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80185a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80185d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801861:	0f 89 70 ff ff ff    	jns    8017d7 <vprintfmt+0x59>
				width = precision, precision = -1;
  801867:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80186a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80186d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801874:	e9 5e ff ff ff       	jmp    8017d7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801879:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80187c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80187f:	e9 53 ff ff ff       	jmp    8017d7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801884:	8b 45 14             	mov    0x14(%ebp),%eax
  801887:	8d 50 04             	lea    0x4(%eax),%edx
  80188a:	89 55 14             	mov    %edx,0x14(%ebp)
  80188d:	83 ec 08             	sub    $0x8,%esp
  801890:	53                   	push   %ebx
  801891:	ff 30                	pushl  (%eax)
  801893:	ff d6                	call   *%esi
			break;
  801895:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801898:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80189b:	e9 04 ff ff ff       	jmp    8017a4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a3:	8d 50 04             	lea    0x4(%eax),%edx
  8018a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8018a9:	8b 00                	mov    (%eax),%eax
  8018ab:	99                   	cltd   
  8018ac:	31 d0                	xor    %edx,%eax
  8018ae:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018b0:	83 f8 0f             	cmp    $0xf,%eax
  8018b3:	7f 0b                	jg     8018c0 <vprintfmt+0x142>
  8018b5:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  8018bc:	85 d2                	test   %edx,%edx
  8018be:	75 18                	jne    8018d8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8018c0:	50                   	push   %eax
  8018c1:	68 9b 24 80 00       	push   $0x80249b
  8018c6:	53                   	push   %ebx
  8018c7:	56                   	push   %esi
  8018c8:	e8 94 fe ff ff       	call   801761 <printfmt>
  8018cd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8018d3:	e9 cc fe ff ff       	jmp    8017a4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018d8:	52                   	push   %edx
  8018d9:	68 e1 23 80 00       	push   $0x8023e1
  8018de:	53                   	push   %ebx
  8018df:	56                   	push   %esi
  8018e0:	e8 7c fe ff ff       	call   801761 <printfmt>
  8018e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018eb:	e9 b4 fe ff ff       	jmp    8017a4 <vprintfmt+0x26>
  8018f0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8018f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018f6:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fc:	8d 50 04             	lea    0x4(%eax),%edx
  8018ff:	89 55 14             	mov    %edx,0x14(%ebp)
  801902:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801904:	85 ff                	test   %edi,%edi
  801906:	ba 94 24 80 00       	mov    $0x802494,%edx
  80190b:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80190e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801912:	0f 84 92 00 00 00    	je     8019aa <vprintfmt+0x22c>
  801918:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80191c:	0f 8e 96 00 00 00    	jle    8019b8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	51                   	push   %ecx
  801926:	57                   	push   %edi
  801927:	e8 86 02 00 00       	call   801bb2 <strnlen>
  80192c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80192f:	29 c1                	sub    %eax,%ecx
  801931:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801934:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801937:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80193b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80193e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801941:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801943:	eb 0f                	jmp    801954 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801945:	83 ec 08             	sub    $0x8,%esp
  801948:	53                   	push   %ebx
  801949:	ff 75 e0             	pushl  -0x20(%ebp)
  80194c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80194e:	83 ef 01             	sub    $0x1,%edi
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	85 ff                	test   %edi,%edi
  801956:	7f ed                	jg     801945 <vprintfmt+0x1c7>
  801958:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80195b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80195e:	85 c9                	test   %ecx,%ecx
  801960:	b8 00 00 00 00       	mov    $0x0,%eax
  801965:	0f 49 c1             	cmovns %ecx,%eax
  801968:	29 c1                	sub    %eax,%ecx
  80196a:	89 75 08             	mov    %esi,0x8(%ebp)
  80196d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801970:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801973:	89 cb                	mov    %ecx,%ebx
  801975:	eb 4d                	jmp    8019c4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801977:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80197b:	74 1b                	je     801998 <vprintfmt+0x21a>
  80197d:	0f be c0             	movsbl %al,%eax
  801980:	83 e8 20             	sub    $0x20,%eax
  801983:	83 f8 5e             	cmp    $0x5e,%eax
  801986:	76 10                	jbe    801998 <vprintfmt+0x21a>
					putch('?', putdat);
  801988:	83 ec 08             	sub    $0x8,%esp
  80198b:	ff 75 0c             	pushl  0xc(%ebp)
  80198e:	6a 3f                	push   $0x3f
  801990:	ff 55 08             	call   *0x8(%ebp)
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	eb 0d                	jmp    8019a5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801998:	83 ec 08             	sub    $0x8,%esp
  80199b:	ff 75 0c             	pushl  0xc(%ebp)
  80199e:	52                   	push   %edx
  80199f:	ff 55 08             	call   *0x8(%ebp)
  8019a2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019a5:	83 eb 01             	sub    $0x1,%ebx
  8019a8:	eb 1a                	jmp    8019c4 <vprintfmt+0x246>
  8019aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8019ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019b6:	eb 0c                	jmp    8019c4 <vprintfmt+0x246>
  8019b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8019bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019c4:	83 c7 01             	add    $0x1,%edi
  8019c7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019cb:	0f be d0             	movsbl %al,%edx
  8019ce:	85 d2                	test   %edx,%edx
  8019d0:	74 23                	je     8019f5 <vprintfmt+0x277>
  8019d2:	85 f6                	test   %esi,%esi
  8019d4:	78 a1                	js     801977 <vprintfmt+0x1f9>
  8019d6:	83 ee 01             	sub    $0x1,%esi
  8019d9:	79 9c                	jns    801977 <vprintfmt+0x1f9>
  8019db:	89 df                	mov    %ebx,%edi
  8019dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019e3:	eb 18                	jmp    8019fd <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019e5:	83 ec 08             	sub    $0x8,%esp
  8019e8:	53                   	push   %ebx
  8019e9:	6a 20                	push   $0x20
  8019eb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019ed:	83 ef 01             	sub    $0x1,%edi
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	eb 08                	jmp    8019fd <vprintfmt+0x27f>
  8019f5:	89 df                	mov    %ebx,%edi
  8019f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8019fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019fd:	85 ff                	test   %edi,%edi
  8019ff:	7f e4                	jg     8019e5 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a04:	e9 9b fd ff ff       	jmp    8017a4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a09:	83 fa 01             	cmp    $0x1,%edx
  801a0c:	7e 16                	jle    801a24 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801a0e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a11:	8d 50 08             	lea    0x8(%eax),%edx
  801a14:	89 55 14             	mov    %edx,0x14(%ebp)
  801a17:	8b 50 04             	mov    0x4(%eax),%edx
  801a1a:	8b 00                	mov    (%eax),%eax
  801a1c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a1f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a22:	eb 32                	jmp    801a56 <vprintfmt+0x2d8>
	else if (lflag)
  801a24:	85 d2                	test   %edx,%edx
  801a26:	74 18                	je     801a40 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801a28:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2b:	8d 50 04             	lea    0x4(%eax),%edx
  801a2e:	89 55 14             	mov    %edx,0x14(%ebp)
  801a31:	8b 00                	mov    (%eax),%eax
  801a33:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a36:	89 c1                	mov    %eax,%ecx
  801a38:	c1 f9 1f             	sar    $0x1f,%ecx
  801a3b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a3e:	eb 16                	jmp    801a56 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801a40:	8b 45 14             	mov    0x14(%ebp),%eax
  801a43:	8d 50 04             	lea    0x4(%eax),%edx
  801a46:	89 55 14             	mov    %edx,0x14(%ebp)
  801a49:	8b 00                	mov    (%eax),%eax
  801a4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a4e:	89 c1                	mov    %eax,%ecx
  801a50:	c1 f9 1f             	sar    $0x1f,%ecx
  801a53:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a56:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a59:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a5c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a61:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a65:	79 74                	jns    801adb <vprintfmt+0x35d>
				putch('-', putdat);
  801a67:	83 ec 08             	sub    $0x8,%esp
  801a6a:	53                   	push   %ebx
  801a6b:	6a 2d                	push   $0x2d
  801a6d:	ff d6                	call   *%esi
				num = -(long long) num;
  801a6f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a72:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a75:	f7 d8                	neg    %eax
  801a77:	83 d2 00             	adc    $0x0,%edx
  801a7a:	f7 da                	neg    %edx
  801a7c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a7f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a84:	eb 55                	jmp    801adb <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a86:	8d 45 14             	lea    0x14(%ebp),%eax
  801a89:	e8 7c fc ff ff       	call   80170a <getuint>
			base = 10;
  801a8e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a93:	eb 46                	jmp    801adb <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a95:	8d 45 14             	lea    0x14(%ebp),%eax
  801a98:	e8 6d fc ff ff       	call   80170a <getuint>
                        base = 8;
  801a9d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801aa2:	eb 37                	jmp    801adb <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801aa4:	83 ec 08             	sub    $0x8,%esp
  801aa7:	53                   	push   %ebx
  801aa8:	6a 30                	push   $0x30
  801aaa:	ff d6                	call   *%esi
			putch('x', putdat);
  801aac:	83 c4 08             	add    $0x8,%esp
  801aaf:	53                   	push   %ebx
  801ab0:	6a 78                	push   $0x78
  801ab2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801ab4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab7:	8d 50 04             	lea    0x4(%eax),%edx
  801aba:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801abd:	8b 00                	mov    (%eax),%eax
  801abf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ac4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ac7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801acc:	eb 0d                	jmp    801adb <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ace:	8d 45 14             	lea    0x14(%ebp),%eax
  801ad1:	e8 34 fc ff ff       	call   80170a <getuint>
			base = 16;
  801ad6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801adb:	83 ec 0c             	sub    $0xc,%esp
  801ade:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ae2:	57                   	push   %edi
  801ae3:	ff 75 e0             	pushl  -0x20(%ebp)
  801ae6:	51                   	push   %ecx
  801ae7:	52                   	push   %edx
  801ae8:	50                   	push   %eax
  801ae9:	89 da                	mov    %ebx,%edx
  801aeb:	89 f0                	mov    %esi,%eax
  801aed:	e8 6e fb ff ff       	call   801660 <printnum>
			break;
  801af2:	83 c4 20             	add    $0x20,%esp
  801af5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801af8:	e9 a7 fc ff ff       	jmp    8017a4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801afd:	83 ec 08             	sub    $0x8,%esp
  801b00:	53                   	push   %ebx
  801b01:	51                   	push   %ecx
  801b02:	ff d6                	call   *%esi
			break;
  801b04:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b0a:	e9 95 fc ff ff       	jmp    8017a4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b0f:	83 ec 08             	sub    $0x8,%esp
  801b12:	53                   	push   %ebx
  801b13:	6a 25                	push   $0x25
  801b15:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	eb 03                	jmp    801b1f <vprintfmt+0x3a1>
  801b1c:	83 ef 01             	sub    $0x1,%edi
  801b1f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b23:	75 f7                	jne    801b1c <vprintfmt+0x39e>
  801b25:	e9 7a fc ff ff       	jmp    8017a4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2d:	5b                   	pop    %ebx
  801b2e:	5e                   	pop    %esi
  801b2f:	5f                   	pop    %edi
  801b30:	5d                   	pop    %ebp
  801b31:	c3                   	ret    

00801b32 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 18             	sub    $0x18,%esp
  801b38:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b41:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b45:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	74 26                	je     801b79 <vsnprintf+0x47>
  801b53:	85 d2                	test   %edx,%edx
  801b55:	7e 22                	jle    801b79 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b57:	ff 75 14             	pushl  0x14(%ebp)
  801b5a:	ff 75 10             	pushl  0x10(%ebp)
  801b5d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b60:	50                   	push   %eax
  801b61:	68 44 17 80 00       	push   $0x801744
  801b66:	e8 13 fc ff ff       	call   80177e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b6e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b74:	83 c4 10             	add    $0x10,%esp
  801b77:	eb 05                	jmp    801b7e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b86:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b89:	50                   	push   %eax
  801b8a:	ff 75 10             	pushl  0x10(%ebp)
  801b8d:	ff 75 0c             	pushl  0xc(%ebp)
  801b90:	ff 75 08             	pushl  0x8(%ebp)
  801b93:	e8 9a ff ff ff       	call   801b32 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ba0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba5:	eb 03                	jmp    801baa <strlen+0x10>
		n++;
  801ba7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801baa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bae:	75 f7                	jne    801ba7 <strlen+0xd>
		n++;
	return n;
}
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    

00801bb2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc0:	eb 03                	jmp    801bc5 <strnlen+0x13>
		n++;
  801bc2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bc5:	39 c2                	cmp    %eax,%edx
  801bc7:	74 08                	je     801bd1 <strnlen+0x1f>
  801bc9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bcd:	75 f3                	jne    801bc2 <strnlen+0x10>
  801bcf:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	53                   	push   %ebx
  801bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bdd:	89 c2                	mov    %eax,%edx
  801bdf:	83 c2 01             	add    $0x1,%edx
  801be2:	83 c1 01             	add    $0x1,%ecx
  801be5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801be9:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bec:	84 db                	test   %bl,%bl
  801bee:	75 ef                	jne    801bdf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bf0:	5b                   	pop    %ebx
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	53                   	push   %ebx
  801bf7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bfa:	53                   	push   %ebx
  801bfb:	e8 9a ff ff ff       	call   801b9a <strlen>
  801c00:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c03:	ff 75 0c             	pushl  0xc(%ebp)
  801c06:	01 d8                	add    %ebx,%eax
  801c08:	50                   	push   %eax
  801c09:	e8 c5 ff ff ff       	call   801bd3 <strcpy>
	return dst;
}
  801c0e:	89 d8                	mov    %ebx,%eax
  801c10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c13:	c9                   	leave  
  801c14:	c3                   	ret    

00801c15 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	56                   	push   %esi
  801c19:	53                   	push   %ebx
  801c1a:	8b 75 08             	mov    0x8(%ebp),%esi
  801c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c20:	89 f3                	mov    %esi,%ebx
  801c22:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c25:	89 f2                	mov    %esi,%edx
  801c27:	eb 0f                	jmp    801c38 <strncpy+0x23>
		*dst++ = *src;
  801c29:	83 c2 01             	add    $0x1,%edx
  801c2c:	0f b6 01             	movzbl (%ecx),%eax
  801c2f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c32:	80 39 01             	cmpb   $0x1,(%ecx)
  801c35:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c38:	39 da                	cmp    %ebx,%edx
  801c3a:	75 ed                	jne    801c29 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c3c:	89 f0                	mov    %esi,%eax
  801c3e:	5b                   	pop    %ebx
  801c3f:	5e                   	pop    %esi
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	56                   	push   %esi
  801c46:	53                   	push   %ebx
  801c47:	8b 75 08             	mov    0x8(%ebp),%esi
  801c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c4d:	8b 55 10             	mov    0x10(%ebp),%edx
  801c50:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c52:	85 d2                	test   %edx,%edx
  801c54:	74 21                	je     801c77 <strlcpy+0x35>
  801c56:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c5a:	89 f2                	mov    %esi,%edx
  801c5c:	eb 09                	jmp    801c67 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c5e:	83 c2 01             	add    $0x1,%edx
  801c61:	83 c1 01             	add    $0x1,%ecx
  801c64:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c67:	39 c2                	cmp    %eax,%edx
  801c69:	74 09                	je     801c74 <strlcpy+0x32>
  801c6b:	0f b6 19             	movzbl (%ecx),%ebx
  801c6e:	84 db                	test   %bl,%bl
  801c70:	75 ec                	jne    801c5e <strlcpy+0x1c>
  801c72:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c74:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c77:	29 f0                	sub    %esi,%eax
}
  801c79:	5b                   	pop    %ebx
  801c7a:	5e                   	pop    %esi
  801c7b:	5d                   	pop    %ebp
  801c7c:	c3                   	ret    

00801c7d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c83:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c86:	eb 06                	jmp    801c8e <strcmp+0x11>
		p++, q++;
  801c88:	83 c1 01             	add    $0x1,%ecx
  801c8b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c8e:	0f b6 01             	movzbl (%ecx),%eax
  801c91:	84 c0                	test   %al,%al
  801c93:	74 04                	je     801c99 <strcmp+0x1c>
  801c95:	3a 02                	cmp    (%edx),%al
  801c97:	74 ef                	je     801c88 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c99:	0f b6 c0             	movzbl %al,%eax
  801c9c:	0f b6 12             	movzbl (%edx),%edx
  801c9f:	29 d0                	sub    %edx,%eax
}
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	53                   	push   %ebx
  801ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  801caa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cad:	89 c3                	mov    %eax,%ebx
  801caf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cb2:	eb 06                	jmp    801cba <strncmp+0x17>
		n--, p++, q++;
  801cb4:	83 c0 01             	add    $0x1,%eax
  801cb7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cba:	39 d8                	cmp    %ebx,%eax
  801cbc:	74 15                	je     801cd3 <strncmp+0x30>
  801cbe:	0f b6 08             	movzbl (%eax),%ecx
  801cc1:	84 c9                	test   %cl,%cl
  801cc3:	74 04                	je     801cc9 <strncmp+0x26>
  801cc5:	3a 0a                	cmp    (%edx),%cl
  801cc7:	74 eb                	je     801cb4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cc9:	0f b6 00             	movzbl (%eax),%eax
  801ccc:	0f b6 12             	movzbl (%edx),%edx
  801ccf:	29 d0                	sub    %edx,%eax
  801cd1:	eb 05                	jmp    801cd8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cd3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801cd8:	5b                   	pop    %ebx
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    

00801cdb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ce5:	eb 07                	jmp    801cee <strchr+0x13>
		if (*s == c)
  801ce7:	38 ca                	cmp    %cl,%dl
  801ce9:	74 0f                	je     801cfa <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ceb:	83 c0 01             	add    $0x1,%eax
  801cee:	0f b6 10             	movzbl (%eax),%edx
  801cf1:	84 d2                	test   %dl,%dl
  801cf3:	75 f2                	jne    801ce7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cf5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    

00801cfc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	8b 45 08             	mov    0x8(%ebp),%eax
  801d02:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d06:	eb 03                	jmp    801d0b <strfind+0xf>
  801d08:	83 c0 01             	add    $0x1,%eax
  801d0b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d0e:	84 d2                	test   %dl,%dl
  801d10:	74 04                	je     801d16 <strfind+0x1a>
  801d12:	38 ca                	cmp    %cl,%dl
  801d14:	75 f2                	jne    801d08 <strfind+0xc>
			break;
	return (char *) s;
}
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    

00801d18 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	57                   	push   %edi
  801d1c:	56                   	push   %esi
  801d1d:	53                   	push   %ebx
  801d1e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d21:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d24:	85 c9                	test   %ecx,%ecx
  801d26:	74 36                	je     801d5e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d28:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d2e:	75 28                	jne    801d58 <memset+0x40>
  801d30:	f6 c1 03             	test   $0x3,%cl
  801d33:	75 23                	jne    801d58 <memset+0x40>
		c &= 0xFF;
  801d35:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d39:	89 d3                	mov    %edx,%ebx
  801d3b:	c1 e3 08             	shl    $0x8,%ebx
  801d3e:	89 d6                	mov    %edx,%esi
  801d40:	c1 e6 18             	shl    $0x18,%esi
  801d43:	89 d0                	mov    %edx,%eax
  801d45:	c1 e0 10             	shl    $0x10,%eax
  801d48:	09 f0                	or     %esi,%eax
  801d4a:	09 c2                	or     %eax,%edx
  801d4c:	89 d0                	mov    %edx,%eax
  801d4e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d50:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801d53:	fc                   	cld    
  801d54:	f3 ab                	rep stos %eax,%es:(%edi)
  801d56:	eb 06                	jmp    801d5e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5b:	fc                   	cld    
  801d5c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d5e:	89 f8                	mov    %edi,%eax
  801d60:	5b                   	pop    %ebx
  801d61:	5e                   	pop    %esi
  801d62:	5f                   	pop    %edi
  801d63:	5d                   	pop    %ebp
  801d64:	c3                   	ret    

00801d65 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	57                   	push   %edi
  801d69:	56                   	push   %esi
  801d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d73:	39 c6                	cmp    %eax,%esi
  801d75:	73 35                	jae    801dac <memmove+0x47>
  801d77:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d7a:	39 d0                	cmp    %edx,%eax
  801d7c:	73 2e                	jae    801dac <memmove+0x47>
		s += n;
		d += n;
  801d7e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801d81:	89 d6                	mov    %edx,%esi
  801d83:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d85:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d8b:	75 13                	jne    801da0 <memmove+0x3b>
  801d8d:	f6 c1 03             	test   $0x3,%cl
  801d90:	75 0e                	jne    801da0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d92:	83 ef 04             	sub    $0x4,%edi
  801d95:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d98:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801d9b:	fd                   	std    
  801d9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d9e:	eb 09                	jmp    801da9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801da0:	83 ef 01             	sub    $0x1,%edi
  801da3:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801da6:	fd                   	std    
  801da7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801da9:	fc                   	cld    
  801daa:	eb 1d                	jmp    801dc9 <memmove+0x64>
  801dac:	89 f2                	mov    %esi,%edx
  801dae:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801db0:	f6 c2 03             	test   $0x3,%dl
  801db3:	75 0f                	jne    801dc4 <memmove+0x5f>
  801db5:	f6 c1 03             	test   $0x3,%cl
  801db8:	75 0a                	jne    801dc4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801dba:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801dbd:	89 c7                	mov    %eax,%edi
  801dbf:	fc                   	cld    
  801dc0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dc2:	eb 05                	jmp    801dc9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801dc4:	89 c7                	mov    %eax,%edi
  801dc6:	fc                   	cld    
  801dc7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    

00801dcd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801dd0:	ff 75 10             	pushl  0x10(%ebp)
  801dd3:	ff 75 0c             	pushl  0xc(%ebp)
  801dd6:	ff 75 08             	pushl  0x8(%ebp)
  801dd9:	e8 87 ff ff ff       	call   801d65 <memmove>
}
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    

00801de0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	56                   	push   %esi
  801de4:	53                   	push   %ebx
  801de5:	8b 45 08             	mov    0x8(%ebp),%eax
  801de8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801deb:	89 c6                	mov    %eax,%esi
  801ded:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801df0:	eb 1a                	jmp    801e0c <memcmp+0x2c>
		if (*s1 != *s2)
  801df2:	0f b6 08             	movzbl (%eax),%ecx
  801df5:	0f b6 1a             	movzbl (%edx),%ebx
  801df8:	38 d9                	cmp    %bl,%cl
  801dfa:	74 0a                	je     801e06 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801dfc:	0f b6 c1             	movzbl %cl,%eax
  801dff:	0f b6 db             	movzbl %bl,%ebx
  801e02:	29 d8                	sub    %ebx,%eax
  801e04:	eb 0f                	jmp    801e15 <memcmp+0x35>
		s1++, s2++;
  801e06:	83 c0 01             	add    $0x1,%eax
  801e09:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e0c:	39 f0                	cmp    %esi,%eax
  801e0e:	75 e2                	jne    801df2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e15:	5b                   	pop    %ebx
  801e16:	5e                   	pop    %esi
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    

00801e19 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801e22:	89 c2                	mov    %eax,%edx
  801e24:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e27:	eb 07                	jmp    801e30 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e29:	38 08                	cmp    %cl,(%eax)
  801e2b:	74 07                	je     801e34 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e2d:	83 c0 01             	add    $0x1,%eax
  801e30:	39 d0                	cmp    %edx,%eax
  801e32:	72 f5                	jb     801e29 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e34:	5d                   	pop    %ebp
  801e35:	c3                   	ret    

00801e36 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	57                   	push   %edi
  801e3a:	56                   	push   %esi
  801e3b:	53                   	push   %ebx
  801e3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e42:	eb 03                	jmp    801e47 <strtol+0x11>
		s++;
  801e44:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e47:	0f b6 01             	movzbl (%ecx),%eax
  801e4a:	3c 09                	cmp    $0x9,%al
  801e4c:	74 f6                	je     801e44 <strtol+0xe>
  801e4e:	3c 20                	cmp    $0x20,%al
  801e50:	74 f2                	je     801e44 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e52:	3c 2b                	cmp    $0x2b,%al
  801e54:	75 0a                	jne    801e60 <strtol+0x2a>
		s++;
  801e56:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e59:	bf 00 00 00 00       	mov    $0x0,%edi
  801e5e:	eb 10                	jmp    801e70 <strtol+0x3a>
  801e60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e65:	3c 2d                	cmp    $0x2d,%al
  801e67:	75 07                	jne    801e70 <strtol+0x3a>
		s++, neg = 1;
  801e69:	8d 49 01             	lea    0x1(%ecx),%ecx
  801e6c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e70:	85 db                	test   %ebx,%ebx
  801e72:	0f 94 c0             	sete   %al
  801e75:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e7b:	75 19                	jne    801e96 <strtol+0x60>
  801e7d:	80 39 30             	cmpb   $0x30,(%ecx)
  801e80:	75 14                	jne    801e96 <strtol+0x60>
  801e82:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e86:	0f 85 82 00 00 00    	jne    801f0e <strtol+0xd8>
		s += 2, base = 16;
  801e8c:	83 c1 02             	add    $0x2,%ecx
  801e8f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e94:	eb 16                	jmp    801eac <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801e96:	84 c0                	test   %al,%al
  801e98:	74 12                	je     801eac <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e9a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e9f:	80 39 30             	cmpb   $0x30,(%ecx)
  801ea2:	75 08                	jne    801eac <strtol+0x76>
		s++, base = 8;
  801ea4:	83 c1 01             	add    $0x1,%ecx
  801ea7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801eac:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801eb4:	0f b6 11             	movzbl (%ecx),%edx
  801eb7:	8d 72 d0             	lea    -0x30(%edx),%esi
  801eba:	89 f3                	mov    %esi,%ebx
  801ebc:	80 fb 09             	cmp    $0x9,%bl
  801ebf:	77 08                	ja     801ec9 <strtol+0x93>
			dig = *s - '0';
  801ec1:	0f be d2             	movsbl %dl,%edx
  801ec4:	83 ea 30             	sub    $0x30,%edx
  801ec7:	eb 22                	jmp    801eeb <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  801ec9:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ecc:	89 f3                	mov    %esi,%ebx
  801ece:	80 fb 19             	cmp    $0x19,%bl
  801ed1:	77 08                	ja     801edb <strtol+0xa5>
			dig = *s - 'a' + 10;
  801ed3:	0f be d2             	movsbl %dl,%edx
  801ed6:	83 ea 57             	sub    $0x57,%edx
  801ed9:	eb 10                	jmp    801eeb <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  801edb:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ede:	89 f3                	mov    %esi,%ebx
  801ee0:	80 fb 19             	cmp    $0x19,%bl
  801ee3:	77 16                	ja     801efb <strtol+0xc5>
			dig = *s - 'A' + 10;
  801ee5:	0f be d2             	movsbl %dl,%edx
  801ee8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801eeb:	3b 55 10             	cmp    0x10(%ebp),%edx
  801eee:	7d 0f                	jge    801eff <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801ef0:	83 c1 01             	add    $0x1,%ecx
  801ef3:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ef7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ef9:	eb b9                	jmp    801eb4 <strtol+0x7e>
  801efb:	89 c2                	mov    %eax,%edx
  801efd:	eb 02                	jmp    801f01 <strtol+0xcb>
  801eff:	89 c2                	mov    %eax,%edx

	if (endptr)
  801f01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f05:	74 0d                	je     801f14 <strtol+0xde>
		*endptr = (char *) s;
  801f07:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0a:	89 0e                	mov    %ecx,(%esi)
  801f0c:	eb 06                	jmp    801f14 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f0e:	84 c0                	test   %al,%al
  801f10:	75 92                	jne    801ea4 <strtol+0x6e>
  801f12:	eb 98                	jmp    801eac <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f14:	f7 da                	neg    %edx
  801f16:	85 ff                	test   %edi,%edi
  801f18:	0f 45 c2             	cmovne %edx,%eax
}
  801f1b:	5b                   	pop    %ebx
  801f1c:	5e                   	pop    %esi
  801f1d:	5f                   	pop    %edi
  801f1e:	5d                   	pop    %ebp
  801f1f:	c3                   	ret    

00801f20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	56                   	push   %esi
  801f24:	53                   	push   %ebx
  801f25:	8b 75 08             	mov    0x8(%ebp),%esi
  801f28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f35:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f38:	83 ec 0c             	sub    $0xc,%esp
  801f3b:	50                   	push   %eax
  801f3c:	e8 cd e3 ff ff       	call   80030e <sys_ipc_recv>
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	85 c0                	test   %eax,%eax
  801f46:	79 16                	jns    801f5e <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801f48:	85 f6                	test   %esi,%esi
  801f4a:	74 06                	je     801f52 <ipc_recv+0x32>
  801f4c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801f52:	85 db                	test   %ebx,%ebx
  801f54:	74 2c                	je     801f82 <ipc_recv+0x62>
  801f56:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f5c:	eb 24                	jmp    801f82 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801f5e:	85 f6                	test   %esi,%esi
  801f60:	74 0a                	je     801f6c <ipc_recv+0x4c>
  801f62:	a1 08 40 80 00       	mov    0x804008,%eax
  801f67:	8b 40 74             	mov    0x74(%eax),%eax
  801f6a:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801f6c:	85 db                	test   %ebx,%ebx
  801f6e:	74 0a                	je     801f7a <ipc_recv+0x5a>
  801f70:	a1 08 40 80 00       	mov    0x804008,%eax
  801f75:	8b 40 78             	mov    0x78(%eax),%eax
  801f78:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801f7a:	a1 08 40 80 00       	mov    0x804008,%eax
  801f7f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f85:	5b                   	pop    %ebx
  801f86:	5e                   	pop    %esi
  801f87:	5d                   	pop    %ebp
  801f88:	c3                   	ret    

00801f89 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f89:	55                   	push   %ebp
  801f8a:	89 e5                	mov    %esp,%ebp
  801f8c:	57                   	push   %edi
  801f8d:	56                   	push   %esi
  801f8e:	53                   	push   %ebx
  801f8f:	83 ec 0c             	sub    $0xc,%esp
  801f92:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f95:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801f9b:	85 db                	test   %ebx,%ebx
  801f9d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fa2:	0f 44 d8             	cmove  %eax,%ebx
  801fa5:	eb 1c                	jmp    801fc3 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801fa7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801faa:	74 12                	je     801fbe <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801fac:	50                   	push   %eax
  801fad:	68 a0 27 80 00       	push   $0x8027a0
  801fb2:	6a 39                	push   $0x39
  801fb4:	68 bb 27 80 00       	push   $0x8027bb
  801fb9:	e8 b5 f5 ff ff       	call   801573 <_panic>
                 sys_yield();
  801fbe:	e8 7c e1 ff ff       	call   80013f <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801fc3:	ff 75 14             	pushl  0x14(%ebp)
  801fc6:	53                   	push   %ebx
  801fc7:	56                   	push   %esi
  801fc8:	57                   	push   %edi
  801fc9:	e8 1d e3 ff ff       	call   8002eb <sys_ipc_try_send>
  801fce:	83 c4 10             	add    $0x10,%esp
  801fd1:	85 c0                	test   %eax,%eax
  801fd3:	78 d2                	js     801fa7 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801fd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd8:	5b                   	pop    %ebx
  801fd9:	5e                   	pop    %esi
  801fda:	5f                   	pop    %edi
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    

00801fdd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fe3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fe8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801feb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ff1:	8b 52 50             	mov    0x50(%edx),%edx
  801ff4:	39 ca                	cmp    %ecx,%edx
  801ff6:	75 0d                	jne    802005 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ff8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ffb:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802000:	8b 40 08             	mov    0x8(%eax),%eax
  802003:	eb 0e                	jmp    802013 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802005:	83 c0 01             	add    $0x1,%eax
  802008:	3d 00 04 00 00       	cmp    $0x400,%eax
  80200d:	75 d9                	jne    801fe8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80200f:	66 b8 00 00          	mov    $0x0,%ax
}
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    

00802015 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
  802018:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80201b:	89 d0                	mov    %edx,%eax
  80201d:	c1 e8 16             	shr    $0x16,%eax
  802020:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802027:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202c:	f6 c1 01             	test   $0x1,%cl
  80202f:	74 1d                	je     80204e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802031:	c1 ea 0c             	shr    $0xc,%edx
  802034:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80203b:	f6 c2 01             	test   $0x1,%dl
  80203e:	74 0e                	je     80204e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802040:	c1 ea 0c             	shr    $0xc,%edx
  802043:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80204a:	ef 
  80204b:	0f b7 c0             	movzwl %ax,%eax
}
  80204e:	5d                   	pop    %ebp
  80204f:	c3                   	ret    

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
