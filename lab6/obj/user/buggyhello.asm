
obj/user/buggyhello.debug:     file format elf32-i386


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
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
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
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 2f 05 00 00       	call   8005c7 <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
  8000a2:	83 c4 10             	add    $0x10,%esp
}
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 4a 23 80 00       	push   $0x80234a
  800111:	6a 22                	push   $0x22
  800113:	68 67 23 80 00       	push   $0x802367
  800118:	e8 5b 14 00 00       	call   801578 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{      
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 4a 23 80 00       	push   $0x80234a
  800192:	6a 22                	push   $0x22
  800194:	68 67 23 80 00       	push   $0x802367
  800199:	e8 da 13 00 00       	call   801578 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 4a 23 80 00       	push   $0x80234a
  8001d4:	6a 22                	push   $0x22
  8001d6:	68 67 23 80 00       	push   $0x802367
  8001db:	e8 98 13 00 00       	call   801578 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 4a 23 80 00       	push   $0x80234a
  800216:	6a 22                	push   $0x22
  800218:	68 67 23 80 00       	push   $0x802367
  80021d:	e8 56 13 00 00       	call   801578 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 4a 23 80 00       	push   $0x80234a
  800258:	6a 22                	push   $0x22
  80025a:	68 67 23 80 00       	push   $0x802367
  80025f:	e8 14 13 00 00       	call   801578 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 4a 23 80 00       	push   $0x80234a
  80029a:	6a 22                	push   $0x22
  80029c:	68 67 23 80 00       	push   $0x802367
  8002a1:	e8 d2 12 00 00       	call   801578 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 4a 23 80 00       	push   $0x80234a
  8002dc:	6a 22                	push   $0x22
  8002de:	68 67 23 80 00       	push   $0x802367
  8002e3:	e8 90 12 00 00       	call   801578 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 4a 23 80 00       	push   $0x80234a
  800340:	6a 22                	push   $0x22
  800342:	68 67 23 80 00       	push   $0x802367
  800347:	e8 2c 12 00 00       	call   801578 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80035a:	ba 00 00 00 00       	mov    $0x0,%edx
  80035f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800364:	89 d1                	mov    %edx,%ecx
  800366:	89 d3                	mov    %edx,%ebx
  800368:	89 d7                	mov    %edx,%edi
  80036a:	89 d6                	mov    %edx,%esi
  80036c:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	57                   	push   %edi
  800377:	56                   	push   %esi
  800378:	53                   	push   %ebx
  800379:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  80037c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800381:	b8 0f 00 00 00       	mov    $0xf,%eax
  800386:	8b 55 08             	mov    0x8(%ebp),%edx
  800389:	89 cb                	mov    %ecx,%ebx
  80038b:	89 cf                	mov    %ecx,%edi
  80038d:	89 ce                	mov    %ecx,%esi
  80038f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800391:	85 c0                	test   %eax,%eax
  800393:	7e 17                	jle    8003ac <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800395:	83 ec 0c             	sub    $0xc,%esp
  800398:	50                   	push   %eax
  800399:	6a 0f                	push   $0xf
  80039b:	68 4a 23 80 00       	push   $0x80234a
  8003a0:	6a 22                	push   $0x22
  8003a2:	68 67 23 80 00       	push   $0x802367
  8003a7:	e8 cc 11 00 00       	call   801578 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <sys_recv>:

int
sys_recv(void *addr)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	57                   	push   %edi
  8003b8:	56                   	push   %esi
  8003b9:	53                   	push   %ebx
  8003ba:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  8003bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c2:	b8 10 00 00 00       	mov    $0x10,%eax
  8003c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ca:	89 cb                	mov    %ecx,%ebx
  8003cc:	89 cf                	mov    %ecx,%edi
  8003ce:	89 ce                	mov    %ecx,%esi
  8003d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003d2:	85 c0                	test   %eax,%eax
  8003d4:	7e 17                	jle    8003ed <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d6:	83 ec 0c             	sub    $0xc,%esp
  8003d9:	50                   	push   %eax
  8003da:	6a 10                	push   $0x10
  8003dc:	68 4a 23 80 00       	push   $0x80234a
  8003e1:	6a 22                	push   $0x22
  8003e3:	68 67 23 80 00       	push   $0x802367
  8003e8:	e8 8b 11 00 00       	call   801578 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  8003ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f0:	5b                   	pop    %ebx
  8003f1:	5e                   	pop    %esi
  8003f2:	5f                   	pop    %edi
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

008003f5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fb:	05 00 00 00 30       	add    $0x30000000,%eax
  800400:	c1 e8 0c             	shr    $0xc,%eax
}
  800403:	5d                   	pop    %ebp
  800404:	c3                   	ret    

00800405 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800408:	8b 45 08             	mov    0x8(%ebp),%eax
  80040b:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800410:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800415:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80041a:	5d                   	pop    %ebp
  80041b:	c3                   	ret    

0080041c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800422:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800427:	89 c2                	mov    %eax,%edx
  800429:	c1 ea 16             	shr    $0x16,%edx
  80042c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800433:	f6 c2 01             	test   $0x1,%dl
  800436:	74 11                	je     800449 <fd_alloc+0x2d>
  800438:	89 c2                	mov    %eax,%edx
  80043a:	c1 ea 0c             	shr    $0xc,%edx
  80043d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800444:	f6 c2 01             	test   $0x1,%dl
  800447:	75 09                	jne    800452 <fd_alloc+0x36>
			*fd_store = fd;
  800449:	89 01                	mov    %eax,(%ecx)
			return 0;
  80044b:	b8 00 00 00 00       	mov    $0x0,%eax
  800450:	eb 17                	jmp    800469 <fd_alloc+0x4d>
  800452:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800457:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80045c:	75 c9                	jne    800427 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80045e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800464:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800469:	5d                   	pop    %ebp
  80046a:	c3                   	ret    

0080046b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800471:	83 f8 1f             	cmp    $0x1f,%eax
  800474:	77 36                	ja     8004ac <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800476:	c1 e0 0c             	shl    $0xc,%eax
  800479:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80047e:	89 c2                	mov    %eax,%edx
  800480:	c1 ea 16             	shr    $0x16,%edx
  800483:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80048a:	f6 c2 01             	test   $0x1,%dl
  80048d:	74 24                	je     8004b3 <fd_lookup+0x48>
  80048f:	89 c2                	mov    %eax,%edx
  800491:	c1 ea 0c             	shr    $0xc,%edx
  800494:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80049b:	f6 c2 01             	test   $0x1,%dl
  80049e:	74 1a                	je     8004ba <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a3:	89 02                	mov    %eax,(%edx)
	return 0;
  8004a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004aa:	eb 13                	jmp    8004bf <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b1:	eb 0c                	jmp    8004bf <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b8:	eb 05                	jmp    8004bf <fd_lookup+0x54>
  8004ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004bf:	5d                   	pop    %ebp
  8004c0:	c3                   	ret    

008004c1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8004ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8004cf:	eb 13                	jmp    8004e4 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  8004d1:	39 08                	cmp    %ecx,(%eax)
  8004d3:	75 0c                	jne    8004e1 <dev_lookup+0x20>
			*dev = devtab[i];
  8004d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004da:	b8 00 00 00 00       	mov    $0x0,%eax
  8004df:	eb 36                	jmp    800517 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004e1:	83 c2 01             	add    $0x1,%edx
  8004e4:	8b 04 95 f4 23 80 00 	mov    0x8023f4(,%edx,4),%eax
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	75 e2                	jne    8004d1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004ef:	a1 08 40 80 00       	mov    0x804008,%eax
  8004f4:	8b 40 48             	mov    0x48(%eax),%eax
  8004f7:	83 ec 04             	sub    $0x4,%esp
  8004fa:	51                   	push   %ecx
  8004fb:	50                   	push   %eax
  8004fc:	68 78 23 80 00       	push   $0x802378
  800501:	e8 4b 11 00 00       	call   801651 <cprintf>
	*dev = 0;
  800506:	8b 45 0c             	mov    0xc(%ebp),%eax
  800509:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800517:	c9                   	leave  
  800518:	c3                   	ret    

00800519 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800519:	55                   	push   %ebp
  80051a:	89 e5                	mov    %esp,%ebp
  80051c:	56                   	push   %esi
  80051d:	53                   	push   %ebx
  80051e:	83 ec 10             	sub    $0x10,%esp
  800521:	8b 75 08             	mov    0x8(%ebp),%esi
  800524:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800527:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80052a:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80052b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800531:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800534:	50                   	push   %eax
  800535:	e8 31 ff ff ff       	call   80046b <fd_lookup>
  80053a:	83 c4 08             	add    $0x8,%esp
  80053d:	85 c0                	test   %eax,%eax
  80053f:	78 05                	js     800546 <fd_close+0x2d>
	    || fd != fd2)
  800541:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800544:	74 0c                	je     800552 <fd_close+0x39>
		return (must_exist ? r : 0);
  800546:	84 db                	test   %bl,%bl
  800548:	ba 00 00 00 00       	mov    $0x0,%edx
  80054d:	0f 44 c2             	cmove  %edx,%eax
  800550:	eb 41                	jmp    800593 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800558:	50                   	push   %eax
  800559:	ff 36                	pushl  (%esi)
  80055b:	e8 61 ff ff ff       	call   8004c1 <dev_lookup>
  800560:	89 c3                	mov    %eax,%ebx
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	85 c0                	test   %eax,%eax
  800567:	78 1a                	js     800583 <fd_close+0x6a>
		if (dev->dev_close)
  800569:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80056c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80056f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800574:	85 c0                	test   %eax,%eax
  800576:	74 0b                	je     800583 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800578:	83 ec 0c             	sub    $0xc,%esp
  80057b:	56                   	push   %esi
  80057c:	ff d0                	call   *%eax
  80057e:	89 c3                	mov    %eax,%ebx
  800580:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	56                   	push   %esi
  800587:	6a 00                	push   $0x0
  800589:	e8 5a fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  80058e:	83 c4 10             	add    $0x10,%esp
  800591:	89 d8                	mov    %ebx,%eax
}
  800593:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5d                   	pop    %ebp
  800599:	c3                   	ret    

0080059a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80059a:	55                   	push   %ebp
  80059b:	89 e5                	mov    %esp,%ebp
  80059d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005a3:	50                   	push   %eax
  8005a4:	ff 75 08             	pushl  0x8(%ebp)
  8005a7:	e8 bf fe ff ff       	call   80046b <fd_lookup>
  8005ac:	89 c2                	mov    %eax,%edx
  8005ae:	83 c4 08             	add    $0x8,%esp
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	78 10                	js     8005c5 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	6a 01                	push   $0x1
  8005ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8005bd:	e8 57 ff ff ff       	call   800519 <fd_close>
  8005c2:	83 c4 10             	add    $0x10,%esp
}
  8005c5:	c9                   	leave  
  8005c6:	c3                   	ret    

008005c7 <close_all>:

void
close_all(void)
{
  8005c7:	55                   	push   %ebp
  8005c8:	89 e5                	mov    %esp,%ebp
  8005ca:	53                   	push   %ebx
  8005cb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ce:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005d3:	83 ec 0c             	sub    $0xc,%esp
  8005d6:	53                   	push   %ebx
  8005d7:	e8 be ff ff ff       	call   80059a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005dc:	83 c3 01             	add    $0x1,%ebx
  8005df:	83 c4 10             	add    $0x10,%esp
  8005e2:	83 fb 20             	cmp    $0x20,%ebx
  8005e5:	75 ec                	jne    8005d3 <close_all+0xc>
		close(i);
}
  8005e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005ea:	c9                   	leave  
  8005eb:	c3                   	ret    

008005ec <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005ec:	55                   	push   %ebp
  8005ed:	89 e5                	mov    %esp,%ebp
  8005ef:	57                   	push   %edi
  8005f0:	56                   	push   %esi
  8005f1:	53                   	push   %ebx
  8005f2:	83 ec 2c             	sub    $0x2c,%esp
  8005f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005fb:	50                   	push   %eax
  8005fc:	ff 75 08             	pushl  0x8(%ebp)
  8005ff:	e8 67 fe ff ff       	call   80046b <fd_lookup>
  800604:	89 c2                	mov    %eax,%edx
  800606:	83 c4 08             	add    $0x8,%esp
  800609:	85 d2                	test   %edx,%edx
  80060b:	0f 88 c1 00 00 00    	js     8006d2 <dup+0xe6>
		return r;
	close(newfdnum);
  800611:	83 ec 0c             	sub    $0xc,%esp
  800614:	56                   	push   %esi
  800615:	e8 80 ff ff ff       	call   80059a <close>

	newfd = INDEX2FD(newfdnum);
  80061a:	89 f3                	mov    %esi,%ebx
  80061c:	c1 e3 0c             	shl    $0xc,%ebx
  80061f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800625:	83 c4 04             	add    $0x4,%esp
  800628:	ff 75 e4             	pushl  -0x1c(%ebp)
  80062b:	e8 d5 fd ff ff       	call   800405 <fd2data>
  800630:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800632:	89 1c 24             	mov    %ebx,(%esp)
  800635:	e8 cb fd ff ff       	call   800405 <fd2data>
  80063a:	83 c4 10             	add    $0x10,%esp
  80063d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800640:	89 f8                	mov    %edi,%eax
  800642:	c1 e8 16             	shr    $0x16,%eax
  800645:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80064c:	a8 01                	test   $0x1,%al
  80064e:	74 37                	je     800687 <dup+0x9b>
  800650:	89 f8                	mov    %edi,%eax
  800652:	c1 e8 0c             	shr    $0xc,%eax
  800655:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80065c:	f6 c2 01             	test   $0x1,%dl
  80065f:	74 26                	je     800687 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800661:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800668:	83 ec 0c             	sub    $0xc,%esp
  80066b:	25 07 0e 00 00       	and    $0xe07,%eax
  800670:	50                   	push   %eax
  800671:	ff 75 d4             	pushl  -0x2c(%ebp)
  800674:	6a 00                	push   $0x0
  800676:	57                   	push   %edi
  800677:	6a 00                	push   $0x0
  800679:	e8 28 fb ff ff       	call   8001a6 <sys_page_map>
  80067e:	89 c7                	mov    %eax,%edi
  800680:	83 c4 20             	add    $0x20,%esp
  800683:	85 c0                	test   %eax,%eax
  800685:	78 2e                	js     8006b5 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800687:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80068a:	89 d0                	mov    %edx,%eax
  80068c:	c1 e8 0c             	shr    $0xc,%eax
  80068f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800696:	83 ec 0c             	sub    $0xc,%esp
  800699:	25 07 0e 00 00       	and    $0xe07,%eax
  80069e:	50                   	push   %eax
  80069f:	53                   	push   %ebx
  8006a0:	6a 00                	push   $0x0
  8006a2:	52                   	push   %edx
  8006a3:	6a 00                	push   $0x0
  8006a5:	e8 fc fa ff ff       	call   8001a6 <sys_page_map>
  8006aa:	89 c7                	mov    %eax,%edi
  8006ac:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006af:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006b1:	85 ff                	test   %edi,%edi
  8006b3:	79 1d                	jns    8006d2 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 00                	push   $0x0
  8006bb:	e8 28 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006c0:	83 c4 08             	add    $0x8,%esp
  8006c3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006c6:	6a 00                	push   $0x0
  8006c8:	e8 1b fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	89 f8                	mov    %edi,%eax
}
  8006d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d5:	5b                   	pop    %ebx
  8006d6:	5e                   	pop    %esi
  8006d7:	5f                   	pop    %edi
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	53                   	push   %ebx
  8006de:	83 ec 14             	sub    $0x14,%esp
  8006e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	53                   	push   %ebx
  8006e9:	e8 7d fd ff ff       	call   80046b <fd_lookup>
  8006ee:	83 c4 08             	add    $0x8,%esp
  8006f1:	89 c2                	mov    %eax,%edx
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	78 6d                	js     800764 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006fd:	50                   	push   %eax
  8006fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800701:	ff 30                	pushl  (%eax)
  800703:	e8 b9 fd ff ff       	call   8004c1 <dev_lookup>
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	85 c0                	test   %eax,%eax
  80070d:	78 4c                	js     80075b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80070f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800712:	8b 42 08             	mov    0x8(%edx),%eax
  800715:	83 e0 03             	and    $0x3,%eax
  800718:	83 f8 01             	cmp    $0x1,%eax
  80071b:	75 21                	jne    80073e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80071d:	a1 08 40 80 00       	mov    0x804008,%eax
  800722:	8b 40 48             	mov    0x48(%eax),%eax
  800725:	83 ec 04             	sub    $0x4,%esp
  800728:	53                   	push   %ebx
  800729:	50                   	push   %eax
  80072a:	68 b9 23 80 00       	push   $0x8023b9
  80072f:	e8 1d 0f 00 00       	call   801651 <cprintf>
		return -E_INVAL;
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80073c:	eb 26                	jmp    800764 <read+0x8a>
	}
	if (!dev->dev_read)
  80073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800741:	8b 40 08             	mov    0x8(%eax),%eax
  800744:	85 c0                	test   %eax,%eax
  800746:	74 17                	je     80075f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800748:	83 ec 04             	sub    $0x4,%esp
  80074b:	ff 75 10             	pushl  0x10(%ebp)
  80074e:	ff 75 0c             	pushl  0xc(%ebp)
  800751:	52                   	push   %edx
  800752:	ff d0                	call   *%eax
  800754:	89 c2                	mov    %eax,%edx
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	eb 09                	jmp    800764 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80075b:	89 c2                	mov    %eax,%edx
  80075d:	eb 05                	jmp    800764 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80075f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800764:	89 d0                	mov    %edx,%eax
  800766:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	57                   	push   %edi
  80076f:	56                   	push   %esi
  800770:	53                   	push   %ebx
  800771:	83 ec 0c             	sub    $0xc,%esp
  800774:	8b 7d 08             	mov    0x8(%ebp),%edi
  800777:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80077a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077f:	eb 21                	jmp    8007a2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800781:	83 ec 04             	sub    $0x4,%esp
  800784:	89 f0                	mov    %esi,%eax
  800786:	29 d8                	sub    %ebx,%eax
  800788:	50                   	push   %eax
  800789:	89 d8                	mov    %ebx,%eax
  80078b:	03 45 0c             	add    0xc(%ebp),%eax
  80078e:	50                   	push   %eax
  80078f:	57                   	push   %edi
  800790:	e8 45 ff ff ff       	call   8006da <read>
		if (m < 0)
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	85 c0                	test   %eax,%eax
  80079a:	78 0c                	js     8007a8 <readn+0x3d>
			return m;
		if (m == 0)
  80079c:	85 c0                	test   %eax,%eax
  80079e:	74 06                	je     8007a6 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007a0:	01 c3                	add    %eax,%ebx
  8007a2:	39 f3                	cmp    %esi,%ebx
  8007a4:	72 db                	jb     800781 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8007a6:	89 d8                	mov    %ebx,%eax
}
  8007a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ab:	5b                   	pop    %ebx
  8007ac:	5e                   	pop    %esi
  8007ad:	5f                   	pop    %edi
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	53                   	push   %ebx
  8007b4:	83 ec 14             	sub    $0x14,%esp
  8007b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	53                   	push   %ebx
  8007bf:	e8 a7 fc ff ff       	call   80046b <fd_lookup>
  8007c4:	83 c4 08             	add    $0x8,%esp
  8007c7:	89 c2                	mov    %eax,%edx
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 68                	js     800835 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d7:	ff 30                	pushl  (%eax)
  8007d9:	e8 e3 fc ff ff       	call   8004c1 <dev_lookup>
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	78 47                	js     80082c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ec:	75 21                	jne    80080f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8007f3:	8b 40 48             	mov    0x48(%eax),%eax
  8007f6:	83 ec 04             	sub    $0x4,%esp
  8007f9:	53                   	push   %ebx
  8007fa:	50                   	push   %eax
  8007fb:	68 d5 23 80 00       	push   $0x8023d5
  800800:	e8 4c 0e 00 00       	call   801651 <cprintf>
		return -E_INVAL;
  800805:	83 c4 10             	add    $0x10,%esp
  800808:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080d:	eb 26                	jmp    800835 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80080f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800812:	8b 52 0c             	mov    0xc(%edx),%edx
  800815:	85 d2                	test   %edx,%edx
  800817:	74 17                	je     800830 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800819:	83 ec 04             	sub    $0x4,%esp
  80081c:	ff 75 10             	pushl  0x10(%ebp)
  80081f:	ff 75 0c             	pushl  0xc(%ebp)
  800822:	50                   	push   %eax
  800823:	ff d2                	call   *%edx
  800825:	89 c2                	mov    %eax,%edx
  800827:	83 c4 10             	add    $0x10,%esp
  80082a:	eb 09                	jmp    800835 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	eb 05                	jmp    800835 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800830:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800835:	89 d0                	mov    %edx,%eax
  800837:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083a:	c9                   	leave  
  80083b:	c3                   	ret    

0080083c <seek>:

int
seek(int fdnum, off_t offset)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800842:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800845:	50                   	push   %eax
  800846:	ff 75 08             	pushl  0x8(%ebp)
  800849:	e8 1d fc ff ff       	call   80046b <fd_lookup>
  80084e:	83 c4 08             	add    $0x8,%esp
  800851:	85 c0                	test   %eax,%eax
  800853:	78 0e                	js     800863 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800855:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	53                   	push   %ebx
  800869:	83 ec 14             	sub    $0x14,%esp
  80086c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80086f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800872:	50                   	push   %eax
  800873:	53                   	push   %ebx
  800874:	e8 f2 fb ff ff       	call   80046b <fd_lookup>
  800879:	83 c4 08             	add    $0x8,%esp
  80087c:	89 c2                	mov    %eax,%edx
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 65                	js     8008e7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800888:	50                   	push   %eax
  800889:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088c:	ff 30                	pushl  (%eax)
  80088e:	e8 2e fc ff ff       	call   8004c1 <dev_lookup>
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	85 c0                	test   %eax,%eax
  800898:	78 44                	js     8008de <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80089a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80089d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008a1:	75 21                	jne    8008c4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008a3:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008a8:	8b 40 48             	mov    0x48(%eax),%eax
  8008ab:	83 ec 04             	sub    $0x4,%esp
  8008ae:	53                   	push   %ebx
  8008af:	50                   	push   %eax
  8008b0:	68 98 23 80 00       	push   $0x802398
  8008b5:	e8 97 0d 00 00       	call   801651 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008ba:	83 c4 10             	add    $0x10,%esp
  8008bd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008c2:	eb 23                	jmp    8008e7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008c7:	8b 52 18             	mov    0x18(%edx),%edx
  8008ca:	85 d2                	test   %edx,%edx
  8008cc:	74 14                	je     8008e2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	ff 75 0c             	pushl  0xc(%ebp)
  8008d4:	50                   	push   %eax
  8008d5:	ff d2                	call   *%edx
  8008d7:	89 c2                	mov    %eax,%edx
  8008d9:	83 c4 10             	add    $0x10,%esp
  8008dc:	eb 09                	jmp    8008e7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008de:	89 c2                	mov    %eax,%edx
  8008e0:	eb 05                	jmp    8008e7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008e7:	89 d0                	mov    %edx,%eax
  8008e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    

008008ee <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	53                   	push   %ebx
  8008f2:	83 ec 14             	sub    $0x14,%esp
  8008f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008fb:	50                   	push   %eax
  8008fc:	ff 75 08             	pushl  0x8(%ebp)
  8008ff:	e8 67 fb ff ff       	call   80046b <fd_lookup>
  800904:	83 c4 08             	add    $0x8,%esp
  800907:	89 c2                	mov    %eax,%edx
  800909:	85 c0                	test   %eax,%eax
  80090b:	78 58                	js     800965 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800913:	50                   	push   %eax
  800914:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800917:	ff 30                	pushl  (%eax)
  800919:	e8 a3 fb ff ff       	call   8004c1 <dev_lookup>
  80091e:	83 c4 10             	add    $0x10,%esp
  800921:	85 c0                	test   %eax,%eax
  800923:	78 37                	js     80095c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800925:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800928:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80092c:	74 32                	je     800960 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80092e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800931:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800938:	00 00 00 
	stat->st_isdir = 0;
  80093b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800942:	00 00 00 
	stat->st_dev = dev;
  800945:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80094b:	83 ec 08             	sub    $0x8,%esp
  80094e:	53                   	push   %ebx
  80094f:	ff 75 f0             	pushl  -0x10(%ebp)
  800952:	ff 50 14             	call   *0x14(%eax)
  800955:	89 c2                	mov    %eax,%edx
  800957:	83 c4 10             	add    $0x10,%esp
  80095a:	eb 09                	jmp    800965 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80095c:	89 c2                	mov    %eax,%edx
  80095e:	eb 05                	jmp    800965 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800960:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800965:	89 d0                	mov    %edx,%eax
  800967:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	56                   	push   %esi
  800970:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800971:	83 ec 08             	sub    $0x8,%esp
  800974:	6a 00                	push   $0x0
  800976:	ff 75 08             	pushl  0x8(%ebp)
  800979:	e8 09 02 00 00       	call   800b87 <open>
  80097e:	89 c3                	mov    %eax,%ebx
  800980:	83 c4 10             	add    $0x10,%esp
  800983:	85 db                	test   %ebx,%ebx
  800985:	78 1b                	js     8009a2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800987:	83 ec 08             	sub    $0x8,%esp
  80098a:	ff 75 0c             	pushl  0xc(%ebp)
  80098d:	53                   	push   %ebx
  80098e:	e8 5b ff ff ff       	call   8008ee <fstat>
  800993:	89 c6                	mov    %eax,%esi
	close(fd);
  800995:	89 1c 24             	mov    %ebx,(%esp)
  800998:	e8 fd fb ff ff       	call   80059a <close>
	return r;
  80099d:	83 c4 10             	add    $0x10,%esp
  8009a0:	89 f0                	mov    %esi,%eax
}
  8009a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a5:	5b                   	pop    %ebx
  8009a6:	5e                   	pop    %esi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	56                   	push   %esi
  8009ad:	53                   	push   %ebx
  8009ae:	89 c6                	mov    %eax,%esi
  8009b0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009b2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009b9:	75 12                	jne    8009cd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009bb:	83 ec 0c             	sub    $0xc,%esp
  8009be:	6a 01                	push   $0x1
  8009c0:	e8 1d 16 00 00       	call   801fe2 <ipc_find_env>
  8009c5:	a3 00 40 80 00       	mov    %eax,0x804000
  8009ca:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009cd:	6a 07                	push   $0x7
  8009cf:	68 00 50 80 00       	push   $0x805000
  8009d4:	56                   	push   %esi
  8009d5:	ff 35 00 40 80 00    	pushl  0x804000
  8009db:	e8 ae 15 00 00       	call   801f8e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009e0:	83 c4 0c             	add    $0xc,%esp
  8009e3:	6a 00                	push   $0x0
  8009e5:	53                   	push   %ebx
  8009e6:	6a 00                	push   $0x0
  8009e8:	e8 38 15 00 00       	call   801f25 <ipc_recv>
}
  8009ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f0:	5b                   	pop    %ebx
  8009f1:	5e                   	pop    %esi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 40 0c             	mov    0xc(%eax),%eax
  800a00:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a08:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a12:	b8 02 00 00 00       	mov    $0x2,%eax
  800a17:	e8 8d ff ff ff       	call   8009a9 <fsipc>
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a34:	b8 06 00 00 00       	mov    $0x6,%eax
  800a39:	e8 6b ff ff ff       	call   8009a9 <fsipc>
}
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	53                   	push   %ebx
  800a44:	83 ec 04             	sub    $0x4,%esp
  800a47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a50:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a55:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800a5f:	e8 45 ff ff ff       	call   8009a9 <fsipc>
  800a64:	89 c2                	mov    %eax,%edx
  800a66:	85 d2                	test   %edx,%edx
  800a68:	78 2c                	js     800a96 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a6a:	83 ec 08             	sub    $0x8,%esp
  800a6d:	68 00 50 80 00       	push   $0x805000
  800a72:	53                   	push   %ebx
  800a73:	e8 60 11 00 00       	call   801bd8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a78:	a1 80 50 80 00       	mov    0x805080,%eax
  800a7d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a83:	a1 84 50 80 00       	mov    0x805084,%eax
  800a88:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a8e:	83 c4 10             	add    $0x10,%esp
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a99:	c9                   	leave  
  800a9a:	c3                   	ret    

00800a9b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	83 ec 0c             	sub    $0xc,%esp
  800aa4:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 40 0c             	mov    0xc(%eax),%eax
  800aad:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800ab2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800ab5:	eb 3d                	jmp    800af4 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800ab7:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800abd:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800ac2:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800ac5:	83 ec 04             	sub    $0x4,%esp
  800ac8:	57                   	push   %edi
  800ac9:	53                   	push   %ebx
  800aca:	68 08 50 80 00       	push   $0x805008
  800acf:	e8 96 12 00 00       	call   801d6a <memmove>
                fsipcbuf.write.req_n = tmp; 
  800ad4:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800ada:	ba 00 00 00 00       	mov    $0x0,%edx
  800adf:	b8 04 00 00 00       	mov    $0x4,%eax
  800ae4:	e8 c0 fe ff ff       	call   8009a9 <fsipc>
  800ae9:	83 c4 10             	add    $0x10,%esp
  800aec:	85 c0                	test   %eax,%eax
  800aee:	78 0d                	js     800afd <devfile_write+0x62>
		        return r;
                n -= tmp;
  800af0:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800af2:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800af4:	85 f6                	test   %esi,%esi
  800af6:	75 bf                	jne    800ab7 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800af8:	89 d8                	mov    %ebx,%eax
  800afa:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800afd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b10:	8b 40 0c             	mov    0xc(%eax),%eax
  800b13:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b18:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b23:	b8 03 00 00 00       	mov    $0x3,%eax
  800b28:	e8 7c fe ff ff       	call   8009a9 <fsipc>
  800b2d:	89 c3                	mov    %eax,%ebx
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	78 4b                	js     800b7e <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b33:	39 c6                	cmp    %eax,%esi
  800b35:	73 16                	jae    800b4d <devfile_read+0x48>
  800b37:	68 08 24 80 00       	push   $0x802408
  800b3c:	68 0f 24 80 00       	push   $0x80240f
  800b41:	6a 7c                	push   $0x7c
  800b43:	68 24 24 80 00       	push   $0x802424
  800b48:	e8 2b 0a 00 00       	call   801578 <_panic>
	assert(r <= PGSIZE);
  800b4d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b52:	7e 16                	jle    800b6a <devfile_read+0x65>
  800b54:	68 2f 24 80 00       	push   $0x80242f
  800b59:	68 0f 24 80 00       	push   $0x80240f
  800b5e:	6a 7d                	push   $0x7d
  800b60:	68 24 24 80 00       	push   $0x802424
  800b65:	e8 0e 0a 00 00       	call   801578 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b6a:	83 ec 04             	sub    $0x4,%esp
  800b6d:	50                   	push   %eax
  800b6e:	68 00 50 80 00       	push   $0x805000
  800b73:	ff 75 0c             	pushl  0xc(%ebp)
  800b76:	e8 ef 11 00 00       	call   801d6a <memmove>
	return r;
  800b7b:	83 c4 10             	add    $0x10,%esp
}
  800b7e:	89 d8                	mov    %ebx,%eax
  800b80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 20             	sub    $0x20,%esp
  800b8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b91:	53                   	push   %ebx
  800b92:	e8 08 10 00 00       	call   801b9f <strlen>
  800b97:	83 c4 10             	add    $0x10,%esp
  800b9a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b9f:	7f 67                	jg     800c08 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ba7:	50                   	push   %eax
  800ba8:	e8 6f f8 ff ff       	call   80041c <fd_alloc>
  800bad:	83 c4 10             	add    $0x10,%esp
		return r;
  800bb0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bb2:	85 c0                	test   %eax,%eax
  800bb4:	78 57                	js     800c0d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bb6:	83 ec 08             	sub    $0x8,%esp
  800bb9:	53                   	push   %ebx
  800bba:	68 00 50 80 00       	push   $0x805000
  800bbf:	e8 14 10 00 00       	call   801bd8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bcc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bcf:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd4:	e8 d0 fd ff ff       	call   8009a9 <fsipc>
  800bd9:	89 c3                	mov    %eax,%ebx
  800bdb:	83 c4 10             	add    $0x10,%esp
  800bde:	85 c0                	test   %eax,%eax
  800be0:	79 14                	jns    800bf6 <open+0x6f>
		fd_close(fd, 0);
  800be2:	83 ec 08             	sub    $0x8,%esp
  800be5:	6a 00                	push   $0x0
  800be7:	ff 75 f4             	pushl  -0xc(%ebp)
  800bea:	e8 2a f9 ff ff       	call   800519 <fd_close>
		return r;
  800bef:	83 c4 10             	add    $0x10,%esp
  800bf2:	89 da                	mov    %ebx,%edx
  800bf4:	eb 17                	jmp    800c0d <open+0x86>
	}

	return fd2num(fd);
  800bf6:	83 ec 0c             	sub    $0xc,%esp
  800bf9:	ff 75 f4             	pushl  -0xc(%ebp)
  800bfc:	e8 f4 f7 ff ff       	call   8003f5 <fd2num>
  800c01:	89 c2                	mov    %eax,%edx
  800c03:	83 c4 10             	add    $0x10,%esp
  800c06:	eb 05                	jmp    800c0d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c08:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c0d:	89 d0                	mov    %edx,%eax
  800c0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c12:	c9                   	leave  
  800c13:	c3                   	ret    

00800c14 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c24:	e8 80 fd ff ff       	call   8009a9 <fsipc>
}
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c31:	68 3b 24 80 00       	push   $0x80243b
  800c36:	ff 75 0c             	pushl  0xc(%ebp)
  800c39:	e8 9a 0f 00 00       	call   801bd8 <strcpy>
	return 0;
}
  800c3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	53                   	push   %ebx
  800c49:	83 ec 10             	sub    $0x10,%esp
  800c4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c4f:	53                   	push   %ebx
  800c50:	e8 c5 13 00 00       	call   80201a <pageref>
  800c55:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c58:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c5d:	83 f8 01             	cmp    $0x1,%eax
  800c60:	75 10                	jne    800c72 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c62:	83 ec 0c             	sub    $0xc,%esp
  800c65:	ff 73 0c             	pushl  0xc(%ebx)
  800c68:	e8 ca 02 00 00       	call   800f37 <nsipc_close>
  800c6d:	89 c2                	mov    %eax,%edx
  800c6f:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c72:	89 d0                	mov    %edx,%eax
  800c74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c77:	c9                   	leave  
  800c78:	c3                   	ret    

00800c79 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c7f:	6a 00                	push   $0x0
  800c81:	ff 75 10             	pushl  0x10(%ebp)
  800c84:	ff 75 0c             	pushl  0xc(%ebp)
  800c87:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8a:	ff 70 0c             	pushl  0xc(%eax)
  800c8d:	e8 82 03 00 00       	call   801014 <nsipc_send>
}
  800c92:	c9                   	leave  
  800c93:	c3                   	ret    

00800c94 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c9a:	6a 00                	push   $0x0
  800c9c:	ff 75 10             	pushl  0x10(%ebp)
  800c9f:	ff 75 0c             	pushl  0xc(%ebp)
  800ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca5:	ff 70 0c             	pushl  0xc(%eax)
  800ca8:	e8 fb 02 00 00       	call   800fa8 <nsipc_recv>
}
  800cad:	c9                   	leave  
  800cae:	c3                   	ret    

00800caf <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800cb5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800cb8:	52                   	push   %edx
  800cb9:	50                   	push   %eax
  800cba:	e8 ac f7 ff ff       	call   80046b <fd_lookup>
  800cbf:	83 c4 10             	add    $0x10,%esp
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	78 17                	js     800cdd <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc9:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800ccf:	39 08                	cmp    %ecx,(%eax)
  800cd1:	75 05                	jne    800cd8 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800cd3:	8b 40 0c             	mov    0xc(%eax),%eax
  800cd6:	eb 05                	jmp    800cdd <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800cd8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800cdd:	c9                   	leave  
  800cde:	c3                   	ret    

00800cdf <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 1c             	sub    $0x1c,%esp
  800ce7:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800ce9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cec:	50                   	push   %eax
  800ced:	e8 2a f7 ff ff       	call   80041c <fd_alloc>
  800cf2:	89 c3                	mov    %eax,%ebx
  800cf4:	83 c4 10             	add    $0x10,%esp
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	78 1b                	js     800d16 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cfb:	83 ec 04             	sub    $0x4,%esp
  800cfe:	68 07 04 00 00       	push   $0x407
  800d03:	ff 75 f4             	pushl  -0xc(%ebp)
  800d06:	6a 00                	push   $0x0
  800d08:	e8 56 f4 ff ff       	call   800163 <sys_page_alloc>
  800d0d:	89 c3                	mov    %eax,%ebx
  800d0f:	83 c4 10             	add    $0x10,%esp
  800d12:	85 c0                	test   %eax,%eax
  800d14:	79 10                	jns    800d26 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d16:	83 ec 0c             	sub    $0xc,%esp
  800d19:	56                   	push   %esi
  800d1a:	e8 18 02 00 00       	call   800f37 <nsipc_close>
		return r;
  800d1f:	83 c4 10             	add    $0x10,%esp
  800d22:	89 d8                	mov    %ebx,%eax
  800d24:	eb 24                	jmp    800d4a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d26:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d2f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d34:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  800d3b:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	52                   	push   %edx
  800d42:	e8 ae f6 ff ff       	call   8003f5 <fd2num>
  800d47:	83 c4 10             	add    $0x10,%esp
}
  800d4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5a:	e8 50 ff ff ff       	call   800caf <fd2sockid>
		return r;
  800d5f:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	78 1f                	js     800d84 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d65:	83 ec 04             	sub    $0x4,%esp
  800d68:	ff 75 10             	pushl  0x10(%ebp)
  800d6b:	ff 75 0c             	pushl  0xc(%ebp)
  800d6e:	50                   	push   %eax
  800d6f:	e8 1c 01 00 00       	call   800e90 <nsipc_accept>
  800d74:	83 c4 10             	add    $0x10,%esp
		return r;
  800d77:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	78 07                	js     800d84 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d7d:	e8 5d ff ff ff       	call   800cdf <alloc_sockfd>
  800d82:	89 c1                	mov    %eax,%ecx
}
  800d84:	89 c8                	mov    %ecx,%eax
  800d86:	c9                   	leave  
  800d87:	c3                   	ret    

00800d88 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	e8 19 ff ff ff       	call   800caf <fd2sockid>
  800d96:	89 c2                	mov    %eax,%edx
  800d98:	85 d2                	test   %edx,%edx
  800d9a:	78 12                	js     800dae <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  800d9c:	83 ec 04             	sub    $0x4,%esp
  800d9f:	ff 75 10             	pushl  0x10(%ebp)
  800da2:	ff 75 0c             	pushl  0xc(%ebp)
  800da5:	52                   	push   %edx
  800da6:	e8 35 01 00 00       	call   800ee0 <nsipc_bind>
  800dab:	83 c4 10             	add    $0x10,%esp
}
  800dae:	c9                   	leave  
  800daf:	c3                   	ret    

00800db0 <shutdown>:

int
shutdown(int s, int how)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	e8 f1 fe ff ff       	call   800caf <fd2sockid>
  800dbe:	89 c2                	mov    %eax,%edx
  800dc0:	85 d2                	test   %edx,%edx
  800dc2:	78 0f                	js     800dd3 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  800dc4:	83 ec 08             	sub    $0x8,%esp
  800dc7:	ff 75 0c             	pushl  0xc(%ebp)
  800dca:	52                   	push   %edx
  800dcb:	e8 45 01 00 00       	call   800f15 <nsipc_shutdown>
  800dd0:	83 c4 10             	add    $0x10,%esp
}
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    

00800dd5 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dde:	e8 cc fe ff ff       	call   800caf <fd2sockid>
  800de3:	89 c2                	mov    %eax,%edx
  800de5:	85 d2                	test   %edx,%edx
  800de7:	78 12                	js     800dfb <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  800de9:	83 ec 04             	sub    $0x4,%esp
  800dec:	ff 75 10             	pushl  0x10(%ebp)
  800def:	ff 75 0c             	pushl  0xc(%ebp)
  800df2:	52                   	push   %edx
  800df3:	e8 59 01 00 00       	call   800f51 <nsipc_connect>
  800df8:	83 c4 10             	add    $0x10,%esp
}
  800dfb:	c9                   	leave  
  800dfc:	c3                   	ret    

00800dfd <listen>:

int
listen(int s, int backlog)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
  800e06:	e8 a4 fe ff ff       	call   800caf <fd2sockid>
  800e0b:	89 c2                	mov    %eax,%edx
  800e0d:	85 d2                	test   %edx,%edx
  800e0f:	78 0f                	js     800e20 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  800e11:	83 ec 08             	sub    $0x8,%esp
  800e14:	ff 75 0c             	pushl  0xc(%ebp)
  800e17:	52                   	push   %edx
  800e18:	e8 69 01 00 00       	call   800f86 <nsipc_listen>
  800e1d:	83 c4 10             	add    $0x10,%esp
}
  800e20:	c9                   	leave  
  800e21:	c3                   	ret    

00800e22 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e28:	ff 75 10             	pushl  0x10(%ebp)
  800e2b:	ff 75 0c             	pushl  0xc(%ebp)
  800e2e:	ff 75 08             	pushl  0x8(%ebp)
  800e31:	e8 3c 02 00 00       	call   801072 <nsipc_socket>
  800e36:	89 c2                	mov    %eax,%edx
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	85 d2                	test   %edx,%edx
  800e3d:	78 05                	js     800e44 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  800e3f:	e8 9b fe ff ff       	call   800cdf <alloc_sockfd>
}
  800e44:	c9                   	leave  
  800e45:	c3                   	ret    

00800e46 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 04             	sub    $0x4,%esp
  800e4d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e4f:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e56:	75 12                	jne    800e6a <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e58:	83 ec 0c             	sub    $0xc,%esp
  800e5b:	6a 02                	push   $0x2
  800e5d:	e8 80 11 00 00       	call   801fe2 <ipc_find_env>
  800e62:	a3 04 40 80 00       	mov    %eax,0x804004
  800e67:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e6a:	6a 07                	push   $0x7
  800e6c:	68 00 60 80 00       	push   $0x806000
  800e71:	53                   	push   %ebx
  800e72:	ff 35 04 40 80 00    	pushl  0x804004
  800e78:	e8 11 11 00 00       	call   801f8e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e7d:	83 c4 0c             	add    $0xc,%esp
  800e80:	6a 00                	push   $0x0
  800e82:	6a 00                	push   $0x0
  800e84:	6a 00                	push   $0x0
  800e86:	e8 9a 10 00 00       	call   801f25 <ipc_recv>
}
  800e8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8e:	c9                   	leave  
  800e8f:	c3                   	ret    

00800e90 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	56                   	push   %esi
  800e94:	53                   	push   %ebx
  800e95:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e98:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800ea0:	8b 06                	mov    (%esi),%eax
  800ea2:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800ea7:	b8 01 00 00 00       	mov    $0x1,%eax
  800eac:	e8 95 ff ff ff       	call   800e46 <nsipc>
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	78 20                	js     800ed7 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800eb7:	83 ec 04             	sub    $0x4,%esp
  800eba:	ff 35 10 60 80 00    	pushl  0x806010
  800ec0:	68 00 60 80 00       	push   $0x806000
  800ec5:	ff 75 0c             	pushl  0xc(%ebp)
  800ec8:	e8 9d 0e 00 00       	call   801d6a <memmove>
		*addrlen = ret->ret_addrlen;
  800ecd:	a1 10 60 80 00       	mov    0x806010,%eax
  800ed2:	89 06                	mov    %eax,(%esi)
  800ed4:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800ed7:	89 d8                	mov    %ebx,%eax
  800ed9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 08             	sub    $0x8,%esp
  800ee7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800eea:	8b 45 08             	mov    0x8(%ebp),%eax
  800eed:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ef2:	53                   	push   %ebx
  800ef3:	ff 75 0c             	pushl  0xc(%ebp)
  800ef6:	68 04 60 80 00       	push   $0x806004
  800efb:	e8 6a 0e 00 00       	call   801d6a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800f00:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800f06:	b8 02 00 00 00       	mov    $0x2,%eax
  800f0b:	e8 36 ff ff ff       	call   800e46 <nsipc>
}
  800f10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    

00800f15 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f26:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800f30:	e8 11 ff ff ff       	call   800e46 <nsipc>
}
  800f35:	c9                   	leave  
  800f36:	c3                   	ret    

00800f37 <nsipc_close>:

int
nsipc_close(int s)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f40:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f45:	b8 04 00 00 00       	mov    $0x4,%eax
  800f4a:	e8 f7 fe ff ff       	call   800e46 <nsipc>
}
  800f4f:	c9                   	leave  
  800f50:	c3                   	ret    

00800f51 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	53                   	push   %ebx
  800f55:	83 ec 08             	sub    $0x8,%esp
  800f58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f63:	53                   	push   %ebx
  800f64:	ff 75 0c             	pushl  0xc(%ebp)
  800f67:	68 04 60 80 00       	push   $0x806004
  800f6c:	e8 f9 0d 00 00       	call   801d6a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f71:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f77:	b8 05 00 00 00       	mov    $0x5,%eax
  800f7c:	e8 c5 fe ff ff       	call   800e46 <nsipc>
}
  800f81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f84:	c9                   	leave  
  800f85:	c3                   	ret    

00800f86 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f97:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f9c:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa1:	e8 a0 fe ff ff       	call   800e46 <nsipc>
}
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	56                   	push   %esi
  800fac:	53                   	push   %ebx
  800fad:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800fb8:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800fbe:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc1:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800fc6:	b8 07 00 00 00       	mov    $0x7,%eax
  800fcb:	e8 76 fe ff ff       	call   800e46 <nsipc>
  800fd0:	89 c3                	mov    %eax,%ebx
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	78 35                	js     80100b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800fd6:	39 f0                	cmp    %esi,%eax
  800fd8:	7f 07                	jg     800fe1 <nsipc_recv+0x39>
  800fda:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800fdf:	7e 16                	jle    800ff7 <nsipc_recv+0x4f>
  800fe1:	68 47 24 80 00       	push   $0x802447
  800fe6:	68 0f 24 80 00       	push   $0x80240f
  800feb:	6a 62                	push   $0x62
  800fed:	68 5c 24 80 00       	push   $0x80245c
  800ff2:	e8 81 05 00 00       	call   801578 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	50                   	push   %eax
  800ffb:	68 00 60 80 00       	push   $0x806000
  801000:	ff 75 0c             	pushl  0xc(%ebp)
  801003:	e8 62 0d 00 00       	call   801d6a <memmove>
  801008:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80100b:	89 d8                	mov    %ebx,%eax
  80100d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	53                   	push   %ebx
  801018:	83 ec 04             	sub    $0x4,%esp
  80101b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80101e:	8b 45 08             	mov    0x8(%ebp),%eax
  801021:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801026:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80102c:	7e 16                	jle    801044 <nsipc_send+0x30>
  80102e:	68 68 24 80 00       	push   $0x802468
  801033:	68 0f 24 80 00       	push   $0x80240f
  801038:	6a 6d                	push   $0x6d
  80103a:	68 5c 24 80 00       	push   $0x80245c
  80103f:	e8 34 05 00 00       	call   801578 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801044:	83 ec 04             	sub    $0x4,%esp
  801047:	53                   	push   %ebx
  801048:	ff 75 0c             	pushl  0xc(%ebp)
  80104b:	68 0c 60 80 00       	push   $0x80600c
  801050:	e8 15 0d 00 00       	call   801d6a <memmove>
	nsipcbuf.send.req_size = size;
  801055:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80105b:	8b 45 14             	mov    0x14(%ebp),%eax
  80105e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801063:	b8 08 00 00 00       	mov    $0x8,%eax
  801068:	e8 d9 fd ff ff       	call   800e46 <nsipc>
}
  80106d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801070:	c9                   	leave  
  801071:	c3                   	ret    

00801072 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801078:	8b 45 08             	mov    0x8(%ebp),%eax
  80107b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801080:	8b 45 0c             	mov    0xc(%ebp),%eax
  801083:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801088:	8b 45 10             	mov    0x10(%ebp),%eax
  80108b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801090:	b8 09 00 00 00       	mov    $0x9,%eax
  801095:	e8 ac fd ff ff       	call   800e46 <nsipc>
}
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010a4:	83 ec 0c             	sub    $0xc,%esp
  8010a7:	ff 75 08             	pushl  0x8(%ebp)
  8010aa:	e8 56 f3 ff ff       	call   800405 <fd2data>
  8010af:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010b1:	83 c4 08             	add    $0x8,%esp
  8010b4:	68 74 24 80 00       	push   $0x802474
  8010b9:	53                   	push   %ebx
  8010ba:	e8 19 0b 00 00       	call   801bd8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010bf:	8b 56 04             	mov    0x4(%esi),%edx
  8010c2:	89 d0                	mov    %edx,%eax
  8010c4:	2b 06                	sub    (%esi),%eax
  8010c6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8010cc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8010d3:	00 00 00 
	stat->st_dev = &devpipe;
  8010d6:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8010dd:	30 80 00 
	return 0;
}
  8010e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	53                   	push   %ebx
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010f6:	53                   	push   %ebx
  8010f7:	6a 00                	push   $0x0
  8010f9:	e8 ea f0 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010fe:	89 1c 24             	mov    %ebx,(%esp)
  801101:	e8 ff f2 ff ff       	call   800405 <fd2data>
  801106:	83 c4 08             	add    $0x8,%esp
  801109:	50                   	push   %eax
  80110a:	6a 00                	push   $0x0
  80110c:	e8 d7 f0 ff ff       	call   8001e8 <sys_page_unmap>
}
  801111:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801114:	c9                   	leave  
  801115:	c3                   	ret    

00801116 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	57                   	push   %edi
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
  80111c:	83 ec 1c             	sub    $0x1c,%esp
  80111f:	89 c6                	mov    %eax,%esi
  801121:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801124:	a1 08 40 80 00       	mov    0x804008,%eax
  801129:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80112c:	83 ec 0c             	sub    $0xc,%esp
  80112f:	56                   	push   %esi
  801130:	e8 e5 0e 00 00       	call   80201a <pageref>
  801135:	89 c7                	mov    %eax,%edi
  801137:	83 c4 04             	add    $0x4,%esp
  80113a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80113d:	e8 d8 0e 00 00       	call   80201a <pageref>
  801142:	83 c4 10             	add    $0x10,%esp
  801145:	39 c7                	cmp    %eax,%edi
  801147:	0f 94 c2             	sete   %dl
  80114a:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80114d:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801153:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801156:	39 fb                	cmp    %edi,%ebx
  801158:	74 19                	je     801173 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  80115a:	84 d2                	test   %dl,%dl
  80115c:	74 c6                	je     801124 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80115e:	8b 51 58             	mov    0x58(%ecx),%edx
  801161:	50                   	push   %eax
  801162:	52                   	push   %edx
  801163:	53                   	push   %ebx
  801164:	68 7b 24 80 00       	push   $0x80247b
  801169:	e8 e3 04 00 00       	call   801651 <cprintf>
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	eb b1                	jmp    801124 <_pipeisclosed+0xe>
	}
}
  801173:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	57                   	push   %edi
  80117f:	56                   	push   %esi
  801180:	53                   	push   %ebx
  801181:	83 ec 28             	sub    $0x28,%esp
  801184:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801187:	56                   	push   %esi
  801188:	e8 78 f2 ff ff       	call   800405 <fd2data>
  80118d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	bf 00 00 00 00       	mov    $0x0,%edi
  801197:	eb 4b                	jmp    8011e4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801199:	89 da                	mov    %ebx,%edx
  80119b:	89 f0                	mov    %esi,%eax
  80119d:	e8 74 ff ff ff       	call   801116 <_pipeisclosed>
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	75 48                	jne    8011ee <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011a6:	e8 99 ef ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011ab:	8b 43 04             	mov    0x4(%ebx),%eax
  8011ae:	8b 0b                	mov    (%ebx),%ecx
  8011b0:	8d 51 20             	lea    0x20(%ecx),%edx
  8011b3:	39 d0                	cmp    %edx,%eax
  8011b5:	73 e2                	jae    801199 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ba:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011be:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	c1 fa 1f             	sar    $0x1f,%edx
  8011c6:	89 d1                	mov    %edx,%ecx
  8011c8:	c1 e9 1b             	shr    $0x1b,%ecx
  8011cb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8011ce:	83 e2 1f             	and    $0x1f,%edx
  8011d1:	29 ca                	sub    %ecx,%edx
  8011d3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8011d7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011db:	83 c0 01             	add    $0x1,%eax
  8011de:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011e1:	83 c7 01             	add    $0x1,%edi
  8011e4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011e7:	75 c2                	jne    8011ab <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ec:	eb 05                	jmp    8011f3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011ee:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f6:	5b                   	pop    %ebx
  8011f7:	5e                   	pop    %esi
  8011f8:	5f                   	pop    %edi
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	57                   	push   %edi
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
  801201:	83 ec 18             	sub    $0x18,%esp
  801204:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801207:	57                   	push   %edi
  801208:	e8 f8 f1 ff ff       	call   800405 <fd2data>
  80120d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	bb 00 00 00 00       	mov    $0x0,%ebx
  801217:	eb 3d                	jmp    801256 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801219:	85 db                	test   %ebx,%ebx
  80121b:	74 04                	je     801221 <devpipe_read+0x26>
				return i;
  80121d:	89 d8                	mov    %ebx,%eax
  80121f:	eb 44                	jmp    801265 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801221:	89 f2                	mov    %esi,%edx
  801223:	89 f8                	mov    %edi,%eax
  801225:	e8 ec fe ff ff       	call   801116 <_pipeisclosed>
  80122a:	85 c0                	test   %eax,%eax
  80122c:	75 32                	jne    801260 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80122e:	e8 11 ef ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801233:	8b 06                	mov    (%esi),%eax
  801235:	3b 46 04             	cmp    0x4(%esi),%eax
  801238:	74 df                	je     801219 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80123a:	99                   	cltd   
  80123b:	c1 ea 1b             	shr    $0x1b,%edx
  80123e:	01 d0                	add    %edx,%eax
  801240:	83 e0 1f             	and    $0x1f,%eax
  801243:	29 d0                	sub    %edx,%eax
  801245:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80124a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801250:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801253:	83 c3 01             	add    $0x1,%ebx
  801256:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801259:	75 d8                	jne    801233 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80125b:	8b 45 10             	mov    0x10(%ebp),%eax
  80125e:	eb 05                	jmp    801265 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801260:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801265:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801268:	5b                   	pop    %ebx
  801269:	5e                   	pop    %esi
  80126a:	5f                   	pop    %edi
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	56                   	push   %esi
  801271:	53                   	push   %ebx
  801272:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801275:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	e8 9e f1 ff ff       	call   80041c <fd_alloc>
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	89 c2                	mov    %eax,%edx
  801283:	85 c0                	test   %eax,%eax
  801285:	0f 88 2c 01 00 00    	js     8013b7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128b:	83 ec 04             	sub    $0x4,%esp
  80128e:	68 07 04 00 00       	push   $0x407
  801293:	ff 75 f4             	pushl  -0xc(%ebp)
  801296:	6a 00                	push   $0x0
  801298:	e8 c6 ee ff ff       	call   800163 <sys_page_alloc>
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	0f 88 0d 01 00 00    	js     8013b7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012aa:	83 ec 0c             	sub    $0xc,%esp
  8012ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	e8 66 f1 ff ff       	call   80041c <fd_alloc>
  8012b6:	89 c3                	mov    %eax,%ebx
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	0f 88 e2 00 00 00    	js     8013a5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012c3:	83 ec 04             	sub    $0x4,%esp
  8012c6:	68 07 04 00 00       	push   $0x407
  8012cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ce:	6a 00                	push   $0x0
  8012d0:	e8 8e ee ff ff       	call   800163 <sys_page_alloc>
  8012d5:	89 c3                	mov    %eax,%ebx
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	0f 88 c3 00 00 00    	js     8013a5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012e2:	83 ec 0c             	sub    $0xc,%esp
  8012e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e8:	e8 18 f1 ff ff       	call   800405 <fd2data>
  8012ed:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ef:	83 c4 0c             	add    $0xc,%esp
  8012f2:	68 07 04 00 00       	push   $0x407
  8012f7:	50                   	push   %eax
  8012f8:	6a 00                	push   $0x0
  8012fa:	e8 64 ee ff ff       	call   800163 <sys_page_alloc>
  8012ff:	89 c3                	mov    %eax,%ebx
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	0f 88 89 00 00 00    	js     801395 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80130c:	83 ec 0c             	sub    $0xc,%esp
  80130f:	ff 75 f0             	pushl  -0x10(%ebp)
  801312:	e8 ee f0 ff ff       	call   800405 <fd2data>
  801317:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80131e:	50                   	push   %eax
  80131f:	6a 00                	push   $0x0
  801321:	56                   	push   %esi
  801322:	6a 00                	push   $0x0
  801324:	e8 7d ee ff ff       	call   8001a6 <sys_page_map>
  801329:	89 c3                	mov    %eax,%ebx
  80132b:	83 c4 20             	add    $0x20,%esp
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 55                	js     801387 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801332:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801338:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80133d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801340:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801347:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80134d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801350:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801352:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801355:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	ff 75 f4             	pushl  -0xc(%ebp)
  801362:	e8 8e f0 ff ff       	call   8003f5 <fd2num>
  801367:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80136a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80136c:	83 c4 04             	add    $0x4,%esp
  80136f:	ff 75 f0             	pushl  -0x10(%ebp)
  801372:	e8 7e f0 ff ff       	call   8003f5 <fd2num>
  801377:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80137a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	ba 00 00 00 00       	mov    $0x0,%edx
  801385:	eb 30                	jmp    8013b7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	56                   	push   %esi
  80138b:	6a 00                	push   $0x0
  80138d:	e8 56 ee ff ff       	call   8001e8 <sys_page_unmap>
  801392:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	ff 75 f0             	pushl  -0x10(%ebp)
  80139b:	6a 00                	push   $0x0
  80139d:	e8 46 ee ff ff       	call   8001e8 <sys_page_unmap>
  8013a2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ab:	6a 00                	push   $0x0
  8013ad:	e8 36 ee ff ff       	call   8001e8 <sys_page_unmap>
  8013b2:	83 c4 10             	add    $0x10,%esp
  8013b5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013b7:	89 d0                	mov    %edx,%eax
  8013b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bc:	5b                   	pop    %ebx
  8013bd:	5e                   	pop    %esi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c9:	50                   	push   %eax
  8013ca:	ff 75 08             	pushl  0x8(%ebp)
  8013cd:	e8 99 f0 ff ff       	call   80046b <fd_lookup>
  8013d2:	89 c2                	mov    %eax,%edx
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	85 d2                	test   %edx,%edx
  8013d9:	78 18                	js     8013f3 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013db:	83 ec 0c             	sub    $0xc,%esp
  8013de:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e1:	e8 1f f0 ff ff       	call   800405 <fd2data>
	return _pipeisclosed(fd, p);
  8013e6:	89 c2                	mov    %eax,%edx
  8013e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013eb:	e8 26 fd ff ff       	call   801116 <_pipeisclosed>
  8013f0:	83 c4 10             	add    $0x10,%esp
}
  8013f3:	c9                   	leave  
  8013f4:	c3                   	ret    

008013f5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fd:	5d                   	pop    %ebp
  8013fe:	c3                   	ret    

008013ff <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801405:	68 93 24 80 00       	push   $0x802493
  80140a:	ff 75 0c             	pushl  0xc(%ebp)
  80140d:	e8 c6 07 00 00       	call   801bd8 <strcpy>
	return 0;
}
  801412:	b8 00 00 00 00       	mov    $0x0,%eax
  801417:	c9                   	leave  
  801418:	c3                   	ret    

00801419 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	57                   	push   %edi
  80141d:	56                   	push   %esi
  80141e:	53                   	push   %ebx
  80141f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801425:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80142a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801430:	eb 2d                	jmp    80145f <devcons_write+0x46>
		m = n - tot;
  801432:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801435:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801437:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80143a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80143f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801442:	83 ec 04             	sub    $0x4,%esp
  801445:	53                   	push   %ebx
  801446:	03 45 0c             	add    0xc(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	57                   	push   %edi
  80144b:	e8 1a 09 00 00       	call   801d6a <memmove>
		sys_cputs(buf, m);
  801450:	83 c4 08             	add    $0x8,%esp
  801453:	53                   	push   %ebx
  801454:	57                   	push   %edi
  801455:	e8 4d ec ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80145a:	01 de                	add    %ebx,%esi
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	89 f0                	mov    %esi,%eax
  801461:	3b 75 10             	cmp    0x10(%ebp),%esi
  801464:	72 cc                	jb     801432 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801466:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801469:	5b                   	pop    %ebx
  80146a:	5e                   	pop    %esi
  80146b:	5f                   	pop    %edi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    

0080146e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801474:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801479:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80147d:	75 07                	jne    801486 <devcons_read+0x18>
  80147f:	eb 28                	jmp    8014a9 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801481:	e8 be ec ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801486:	e8 3a ec ff ff       	call   8000c5 <sys_cgetc>
  80148b:	85 c0                	test   %eax,%eax
  80148d:	74 f2                	je     801481 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 16                	js     8014a9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801493:	83 f8 04             	cmp    $0x4,%eax
  801496:	74 0c                	je     8014a4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801498:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149b:	88 02                	mov    %al,(%edx)
	return 1;
  80149d:	b8 01 00 00 00       	mov    $0x1,%eax
  8014a2:	eb 05                	jmp    8014a9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014a4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014b7:	6a 01                	push   $0x1
  8014b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	e8 e5 eb ff ff       	call   8000a7 <sys_cputs>
  8014c2:	83 c4 10             	add    $0x10,%esp
}
  8014c5:	c9                   	leave  
  8014c6:	c3                   	ret    

008014c7 <getchar>:

int
getchar(void)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014cd:	6a 01                	push   $0x1
  8014cf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	6a 00                	push   $0x0
  8014d5:	e8 00 f2 ff ff       	call   8006da <read>
	if (r < 0)
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 0f                	js     8014f0 <getchar+0x29>
		return r;
	if (r < 1)
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	7e 06                	jle    8014eb <getchar+0x24>
		return -E_EOF;
	return c;
  8014e5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014e9:	eb 05                	jmp    8014f0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014eb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fb:	50                   	push   %eax
  8014fc:	ff 75 08             	pushl  0x8(%ebp)
  8014ff:	e8 67 ef ff ff       	call   80046b <fd_lookup>
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	78 11                	js     80151c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80150b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801514:	39 10                	cmp    %edx,(%eax)
  801516:	0f 94 c0             	sete   %al
  801519:	0f b6 c0             	movzbl %al,%eax
}
  80151c:	c9                   	leave  
  80151d:	c3                   	ret    

0080151e <opencons>:

int
opencons(void)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801524:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801527:	50                   	push   %eax
  801528:	e8 ef ee ff ff       	call   80041c <fd_alloc>
  80152d:	83 c4 10             	add    $0x10,%esp
		return r;
  801530:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801532:	85 c0                	test   %eax,%eax
  801534:	78 3e                	js     801574 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801536:	83 ec 04             	sub    $0x4,%esp
  801539:	68 07 04 00 00       	push   $0x407
  80153e:	ff 75 f4             	pushl  -0xc(%ebp)
  801541:	6a 00                	push   $0x0
  801543:	e8 1b ec ff ff       	call   800163 <sys_page_alloc>
  801548:	83 c4 10             	add    $0x10,%esp
		return r;
  80154b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 23                	js     801574 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801551:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801557:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80155c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801566:	83 ec 0c             	sub    $0xc,%esp
  801569:	50                   	push   %eax
  80156a:	e8 86 ee ff ff       	call   8003f5 <fd2num>
  80156f:	89 c2                	mov    %eax,%edx
  801571:	83 c4 10             	add    $0x10,%esp
}
  801574:	89 d0                	mov    %edx,%eax
  801576:	c9                   	leave  
  801577:	c3                   	ret    

00801578 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	56                   	push   %esi
  80157c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80157d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801580:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801586:	e8 9a eb ff ff       	call   800125 <sys_getenvid>
  80158b:	83 ec 0c             	sub    $0xc,%esp
  80158e:	ff 75 0c             	pushl  0xc(%ebp)
  801591:	ff 75 08             	pushl  0x8(%ebp)
  801594:	56                   	push   %esi
  801595:	50                   	push   %eax
  801596:	68 a0 24 80 00       	push   $0x8024a0
  80159b:	e8 b1 00 00 00       	call   801651 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015a0:	83 c4 18             	add    $0x18,%esp
  8015a3:	53                   	push   %ebx
  8015a4:	ff 75 10             	pushl  0x10(%ebp)
  8015a7:	e8 54 00 00 00       	call   801600 <vcprintf>
	cprintf("\n");
  8015ac:	c7 04 24 8c 24 80 00 	movl   $0x80248c,(%esp)
  8015b3:	e8 99 00 00 00       	call   801651 <cprintf>
  8015b8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015bb:	cc                   	int3   
  8015bc:	eb fd                	jmp    8015bb <_panic+0x43>

008015be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 04             	sub    $0x4,%esp
  8015c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015c8:	8b 13                	mov    (%ebx),%edx
  8015ca:	8d 42 01             	lea    0x1(%edx),%eax
  8015cd:	89 03                	mov    %eax,(%ebx)
  8015cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8015d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015db:	75 1a                	jne    8015f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	68 ff 00 00 00       	push   $0xff
  8015e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8015e8:	50                   	push   %eax
  8015e9:	e8 b9 ea ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8015ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801609:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801610:	00 00 00 
	b.cnt = 0;
  801613:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80161a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80161d:	ff 75 0c             	pushl  0xc(%ebp)
  801620:	ff 75 08             	pushl  0x8(%ebp)
  801623:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801629:	50                   	push   %eax
  80162a:	68 be 15 80 00       	push   $0x8015be
  80162f:	e8 4f 01 00 00       	call   801783 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801634:	83 c4 08             	add    $0x8,%esp
  801637:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80163d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	e8 5e ea ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  801649:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80164f:	c9                   	leave  
  801650:	c3                   	ret    

00801651 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801657:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80165a:	50                   	push   %eax
  80165b:	ff 75 08             	pushl  0x8(%ebp)
  80165e:	e8 9d ff ff ff       	call   801600 <vcprintf>
	va_end(ap);

	return cnt;
}
  801663:	c9                   	leave  
  801664:	c3                   	ret    

00801665 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	57                   	push   %edi
  801669:	56                   	push   %esi
  80166a:	53                   	push   %ebx
  80166b:	83 ec 1c             	sub    $0x1c,%esp
  80166e:	89 c7                	mov    %eax,%edi
  801670:	89 d6                	mov    %edx,%esi
  801672:	8b 45 08             	mov    0x8(%ebp),%eax
  801675:	8b 55 0c             	mov    0xc(%ebp),%edx
  801678:	89 d1                	mov    %edx,%ecx
  80167a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80167d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801680:	8b 45 10             	mov    0x10(%ebp),%eax
  801683:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801686:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801689:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801690:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801693:	72 05                	jb     80169a <printnum+0x35>
  801695:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801698:	77 3e                	ja     8016d8 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80169a:	83 ec 0c             	sub    $0xc,%esp
  80169d:	ff 75 18             	pushl  0x18(%ebp)
  8016a0:	83 eb 01             	sub    $0x1,%ebx
  8016a3:	53                   	push   %ebx
  8016a4:	50                   	push   %eax
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8016b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8016b4:	e8 a7 09 00 00       	call   802060 <__udivdi3>
  8016b9:	83 c4 18             	add    $0x18,%esp
  8016bc:	52                   	push   %edx
  8016bd:	50                   	push   %eax
  8016be:	89 f2                	mov    %esi,%edx
  8016c0:	89 f8                	mov    %edi,%eax
  8016c2:	e8 9e ff ff ff       	call   801665 <printnum>
  8016c7:	83 c4 20             	add    $0x20,%esp
  8016ca:	eb 13                	jmp    8016df <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8016cc:	83 ec 08             	sub    $0x8,%esp
  8016cf:	56                   	push   %esi
  8016d0:	ff 75 18             	pushl  0x18(%ebp)
  8016d3:	ff d7                	call   *%edi
  8016d5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8016d8:	83 eb 01             	sub    $0x1,%ebx
  8016db:	85 db                	test   %ebx,%ebx
  8016dd:	7f ed                	jg     8016cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016df:	83 ec 08             	sub    $0x8,%esp
  8016e2:	56                   	push   %esi
  8016e3:	83 ec 04             	sub    $0x4,%esp
  8016e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8016ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8016f2:	e8 99 0a 00 00       	call   802190 <__umoddi3>
  8016f7:	83 c4 14             	add    $0x14,%esp
  8016fa:	0f be 80 c3 24 80 00 	movsbl 0x8024c3(%eax),%eax
  801701:	50                   	push   %eax
  801702:	ff d7                	call   *%edi
  801704:	83 c4 10             	add    $0x10,%esp
}
  801707:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170a:	5b                   	pop    %ebx
  80170b:	5e                   	pop    %esi
  80170c:	5f                   	pop    %edi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801712:	83 fa 01             	cmp    $0x1,%edx
  801715:	7e 0e                	jle    801725 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801717:	8b 10                	mov    (%eax),%edx
  801719:	8d 4a 08             	lea    0x8(%edx),%ecx
  80171c:	89 08                	mov    %ecx,(%eax)
  80171e:	8b 02                	mov    (%edx),%eax
  801720:	8b 52 04             	mov    0x4(%edx),%edx
  801723:	eb 22                	jmp    801747 <getuint+0x38>
	else if (lflag)
  801725:	85 d2                	test   %edx,%edx
  801727:	74 10                	je     801739 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801729:	8b 10                	mov    (%eax),%edx
  80172b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80172e:	89 08                	mov    %ecx,(%eax)
  801730:	8b 02                	mov    (%edx),%eax
  801732:	ba 00 00 00 00       	mov    $0x0,%edx
  801737:	eb 0e                	jmp    801747 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801739:	8b 10                	mov    (%eax),%edx
  80173b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80173e:	89 08                	mov    %ecx,(%eax)
  801740:	8b 02                	mov    (%edx),%eax
  801742:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80174f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801753:	8b 10                	mov    (%eax),%edx
  801755:	3b 50 04             	cmp    0x4(%eax),%edx
  801758:	73 0a                	jae    801764 <sprintputch+0x1b>
		*b->buf++ = ch;
  80175a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80175d:	89 08                	mov    %ecx,(%eax)
  80175f:	8b 45 08             	mov    0x8(%ebp),%eax
  801762:	88 02                	mov    %al,(%edx)
}
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80176c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80176f:	50                   	push   %eax
  801770:	ff 75 10             	pushl  0x10(%ebp)
  801773:	ff 75 0c             	pushl  0xc(%ebp)
  801776:	ff 75 08             	pushl  0x8(%ebp)
  801779:	e8 05 00 00 00       	call   801783 <vprintfmt>
	va_end(ap);
  80177e:	83 c4 10             	add    $0x10,%esp
}
  801781:	c9                   	leave  
  801782:	c3                   	ret    

00801783 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	57                   	push   %edi
  801787:	56                   	push   %esi
  801788:	53                   	push   %ebx
  801789:	83 ec 2c             	sub    $0x2c,%esp
  80178c:	8b 75 08             	mov    0x8(%ebp),%esi
  80178f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801792:	8b 7d 10             	mov    0x10(%ebp),%edi
  801795:	eb 12                	jmp    8017a9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801797:	85 c0                	test   %eax,%eax
  801799:	0f 84 90 03 00 00    	je     801b2f <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80179f:	83 ec 08             	sub    $0x8,%esp
  8017a2:	53                   	push   %ebx
  8017a3:	50                   	push   %eax
  8017a4:	ff d6                	call   *%esi
  8017a6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017a9:	83 c7 01             	add    $0x1,%edi
  8017ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017b0:	83 f8 25             	cmp    $0x25,%eax
  8017b3:	75 e2                	jne    801797 <vprintfmt+0x14>
  8017b5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017b9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8017c0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017c7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8017ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d3:	eb 07                	jmp    8017dc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8017d8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017dc:	8d 47 01             	lea    0x1(%edi),%eax
  8017df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017e2:	0f b6 07             	movzbl (%edi),%eax
  8017e5:	0f b6 c8             	movzbl %al,%ecx
  8017e8:	83 e8 23             	sub    $0x23,%eax
  8017eb:	3c 55                	cmp    $0x55,%al
  8017ed:	0f 87 21 03 00 00    	ja     801b14 <vprintfmt+0x391>
  8017f3:	0f b6 c0             	movzbl %al,%eax
  8017f6:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  8017fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801800:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801804:	eb d6                	jmp    8017dc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801806:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801809:	b8 00 00 00 00       	mov    $0x0,%eax
  80180e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801811:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801814:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801818:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80181b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80181e:	83 fa 09             	cmp    $0x9,%edx
  801821:	77 39                	ja     80185c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801823:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801826:	eb e9                	jmp    801811 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801828:	8b 45 14             	mov    0x14(%ebp),%eax
  80182b:	8d 48 04             	lea    0x4(%eax),%ecx
  80182e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801831:	8b 00                	mov    (%eax),%eax
  801833:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801836:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801839:	eb 27                	jmp    801862 <vprintfmt+0xdf>
  80183b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80183e:	85 c0                	test   %eax,%eax
  801840:	b9 00 00 00 00       	mov    $0x0,%ecx
  801845:	0f 49 c8             	cmovns %eax,%ecx
  801848:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80184e:	eb 8c                	jmp    8017dc <vprintfmt+0x59>
  801850:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801853:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80185a:	eb 80                	jmp    8017dc <vprintfmt+0x59>
  80185c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80185f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801862:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801866:	0f 89 70 ff ff ff    	jns    8017dc <vprintfmt+0x59>
				width = precision, precision = -1;
  80186c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80186f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801872:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801879:	e9 5e ff ff ff       	jmp    8017dc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80187e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801884:	e9 53 ff ff ff       	jmp    8017dc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801889:	8b 45 14             	mov    0x14(%ebp),%eax
  80188c:	8d 50 04             	lea    0x4(%eax),%edx
  80188f:	89 55 14             	mov    %edx,0x14(%ebp)
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	53                   	push   %ebx
  801896:	ff 30                	pushl  (%eax)
  801898:	ff d6                	call   *%esi
			break;
  80189a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80189d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018a0:	e9 04 ff ff ff       	jmp    8017a9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a8:	8d 50 04             	lea    0x4(%eax),%edx
  8018ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8018ae:	8b 00                	mov    (%eax),%eax
  8018b0:	99                   	cltd   
  8018b1:	31 d0                	xor    %edx,%eax
  8018b3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018b5:	83 f8 0f             	cmp    $0xf,%eax
  8018b8:	7f 0b                	jg     8018c5 <vprintfmt+0x142>
  8018ba:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  8018c1:	85 d2                	test   %edx,%edx
  8018c3:	75 18                	jne    8018dd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8018c5:	50                   	push   %eax
  8018c6:	68 db 24 80 00       	push   $0x8024db
  8018cb:	53                   	push   %ebx
  8018cc:	56                   	push   %esi
  8018cd:	e8 94 fe ff ff       	call   801766 <printfmt>
  8018d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8018d8:	e9 cc fe ff ff       	jmp    8017a9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8018dd:	52                   	push   %edx
  8018de:	68 21 24 80 00       	push   $0x802421
  8018e3:	53                   	push   %ebx
  8018e4:	56                   	push   %esi
  8018e5:	e8 7c fe ff ff       	call   801766 <printfmt>
  8018ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018f0:	e9 b4 fe ff ff       	jmp    8017a9 <vprintfmt+0x26>
  8018f5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8018f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018fb:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801901:	8d 50 04             	lea    0x4(%eax),%edx
  801904:	89 55 14             	mov    %edx,0x14(%ebp)
  801907:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801909:	85 ff                	test   %edi,%edi
  80190b:	ba d4 24 80 00       	mov    $0x8024d4,%edx
  801910:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  801913:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801917:	0f 84 92 00 00 00    	je     8019af <vprintfmt+0x22c>
  80191d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801921:	0f 8e 96 00 00 00    	jle    8019bd <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801927:	83 ec 08             	sub    $0x8,%esp
  80192a:	51                   	push   %ecx
  80192b:	57                   	push   %edi
  80192c:	e8 86 02 00 00       	call   801bb7 <strnlen>
  801931:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801934:	29 c1                	sub    %eax,%ecx
  801936:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801939:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80193c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801940:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801943:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801946:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801948:	eb 0f                	jmp    801959 <vprintfmt+0x1d6>
					putch(padc, putdat);
  80194a:	83 ec 08             	sub    $0x8,%esp
  80194d:	53                   	push   %ebx
  80194e:	ff 75 e0             	pushl  -0x20(%ebp)
  801951:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801953:	83 ef 01             	sub    $0x1,%edi
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	85 ff                	test   %edi,%edi
  80195b:	7f ed                	jg     80194a <vprintfmt+0x1c7>
  80195d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801960:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801963:	85 c9                	test   %ecx,%ecx
  801965:	b8 00 00 00 00       	mov    $0x0,%eax
  80196a:	0f 49 c1             	cmovns %ecx,%eax
  80196d:	29 c1                	sub    %eax,%ecx
  80196f:	89 75 08             	mov    %esi,0x8(%ebp)
  801972:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801975:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801978:	89 cb                	mov    %ecx,%ebx
  80197a:	eb 4d                	jmp    8019c9 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80197c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801980:	74 1b                	je     80199d <vprintfmt+0x21a>
  801982:	0f be c0             	movsbl %al,%eax
  801985:	83 e8 20             	sub    $0x20,%eax
  801988:	83 f8 5e             	cmp    $0x5e,%eax
  80198b:	76 10                	jbe    80199d <vprintfmt+0x21a>
					putch('?', putdat);
  80198d:	83 ec 08             	sub    $0x8,%esp
  801990:	ff 75 0c             	pushl  0xc(%ebp)
  801993:	6a 3f                	push   $0x3f
  801995:	ff 55 08             	call   *0x8(%ebp)
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	eb 0d                	jmp    8019aa <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80199d:	83 ec 08             	sub    $0x8,%esp
  8019a0:	ff 75 0c             	pushl  0xc(%ebp)
  8019a3:	52                   	push   %edx
  8019a4:	ff 55 08             	call   *0x8(%ebp)
  8019a7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019aa:	83 eb 01             	sub    $0x1,%ebx
  8019ad:	eb 1a                	jmp    8019c9 <vprintfmt+0x246>
  8019af:	89 75 08             	mov    %esi,0x8(%ebp)
  8019b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019bb:	eb 0c                	jmp    8019c9 <vprintfmt+0x246>
  8019bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8019c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019c6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019c9:	83 c7 01             	add    $0x1,%edi
  8019cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019d0:	0f be d0             	movsbl %al,%edx
  8019d3:	85 d2                	test   %edx,%edx
  8019d5:	74 23                	je     8019fa <vprintfmt+0x277>
  8019d7:	85 f6                	test   %esi,%esi
  8019d9:	78 a1                	js     80197c <vprintfmt+0x1f9>
  8019db:	83 ee 01             	sub    $0x1,%esi
  8019de:	79 9c                	jns    80197c <vprintfmt+0x1f9>
  8019e0:	89 df                	mov    %ebx,%edi
  8019e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019e8:	eb 18                	jmp    801a02 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019ea:	83 ec 08             	sub    $0x8,%esp
  8019ed:	53                   	push   %ebx
  8019ee:	6a 20                	push   $0x20
  8019f0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019f2:	83 ef 01             	sub    $0x1,%edi
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	eb 08                	jmp    801a02 <vprintfmt+0x27f>
  8019fa:	89 df                	mov    %ebx,%edi
  8019fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8019ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a02:	85 ff                	test   %edi,%edi
  801a04:	7f e4                	jg     8019ea <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a09:	e9 9b fd ff ff       	jmp    8017a9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a0e:	83 fa 01             	cmp    $0x1,%edx
  801a11:	7e 16                	jle    801a29 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  801a13:	8b 45 14             	mov    0x14(%ebp),%eax
  801a16:	8d 50 08             	lea    0x8(%eax),%edx
  801a19:	89 55 14             	mov    %edx,0x14(%ebp)
  801a1c:	8b 50 04             	mov    0x4(%eax),%edx
  801a1f:	8b 00                	mov    (%eax),%eax
  801a21:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a24:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a27:	eb 32                	jmp    801a5b <vprintfmt+0x2d8>
	else if (lflag)
  801a29:	85 d2                	test   %edx,%edx
  801a2b:	74 18                	je     801a45 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801a2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a30:	8d 50 04             	lea    0x4(%eax),%edx
  801a33:	89 55 14             	mov    %edx,0x14(%ebp)
  801a36:	8b 00                	mov    (%eax),%eax
  801a38:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a3b:	89 c1                	mov    %eax,%ecx
  801a3d:	c1 f9 1f             	sar    $0x1f,%ecx
  801a40:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a43:	eb 16                	jmp    801a5b <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  801a45:	8b 45 14             	mov    0x14(%ebp),%eax
  801a48:	8d 50 04             	lea    0x4(%eax),%edx
  801a4b:	89 55 14             	mov    %edx,0x14(%ebp)
  801a4e:	8b 00                	mov    (%eax),%eax
  801a50:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a53:	89 c1                	mov    %eax,%ecx
  801a55:	c1 f9 1f             	sar    $0x1f,%ecx
  801a58:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a5b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a5e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a61:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a66:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a6a:	79 74                	jns    801ae0 <vprintfmt+0x35d>
				putch('-', putdat);
  801a6c:	83 ec 08             	sub    $0x8,%esp
  801a6f:	53                   	push   %ebx
  801a70:	6a 2d                	push   $0x2d
  801a72:	ff d6                	call   *%esi
				num = -(long long) num;
  801a74:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a77:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a7a:	f7 d8                	neg    %eax
  801a7c:	83 d2 00             	adc    $0x0,%edx
  801a7f:	f7 da                	neg    %edx
  801a81:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a84:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a89:	eb 55                	jmp    801ae0 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a8b:	8d 45 14             	lea    0x14(%ebp),%eax
  801a8e:	e8 7c fc ff ff       	call   80170f <getuint>
			base = 10;
  801a93:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a98:	eb 46                	jmp    801ae0 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a9a:	8d 45 14             	lea    0x14(%ebp),%eax
  801a9d:	e8 6d fc ff ff       	call   80170f <getuint>
                        base = 8;
  801aa2:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801aa7:	eb 37                	jmp    801ae0 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801aa9:	83 ec 08             	sub    $0x8,%esp
  801aac:	53                   	push   %ebx
  801aad:	6a 30                	push   $0x30
  801aaf:	ff d6                	call   *%esi
			putch('x', putdat);
  801ab1:	83 c4 08             	add    $0x8,%esp
  801ab4:	53                   	push   %ebx
  801ab5:	6a 78                	push   $0x78
  801ab7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801ab9:	8b 45 14             	mov    0x14(%ebp),%eax
  801abc:	8d 50 04             	lea    0x4(%eax),%edx
  801abf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ac2:	8b 00                	mov    (%eax),%eax
  801ac4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ac9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801acc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ad1:	eb 0d                	jmp    801ae0 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ad3:	8d 45 14             	lea    0x14(%ebp),%eax
  801ad6:	e8 34 fc ff ff       	call   80170f <getuint>
			base = 16;
  801adb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ae0:	83 ec 0c             	sub    $0xc,%esp
  801ae3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ae7:	57                   	push   %edi
  801ae8:	ff 75 e0             	pushl  -0x20(%ebp)
  801aeb:	51                   	push   %ecx
  801aec:	52                   	push   %edx
  801aed:	50                   	push   %eax
  801aee:	89 da                	mov    %ebx,%edx
  801af0:	89 f0                	mov    %esi,%eax
  801af2:	e8 6e fb ff ff       	call   801665 <printnum>
			break;
  801af7:	83 c4 20             	add    $0x20,%esp
  801afa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801afd:	e9 a7 fc ff ff       	jmp    8017a9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b02:	83 ec 08             	sub    $0x8,%esp
  801b05:	53                   	push   %ebx
  801b06:	51                   	push   %ecx
  801b07:	ff d6                	call   *%esi
			break;
  801b09:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b0f:	e9 95 fc ff ff       	jmp    8017a9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b14:	83 ec 08             	sub    $0x8,%esp
  801b17:	53                   	push   %ebx
  801b18:	6a 25                	push   $0x25
  801b1a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	eb 03                	jmp    801b24 <vprintfmt+0x3a1>
  801b21:	83 ef 01             	sub    $0x1,%edi
  801b24:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b28:	75 f7                	jne    801b21 <vprintfmt+0x39e>
  801b2a:	e9 7a fc ff ff       	jmp    8017a9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b32:	5b                   	pop    %ebx
  801b33:	5e                   	pop    %esi
  801b34:	5f                   	pop    %edi
  801b35:	5d                   	pop    %ebp
  801b36:	c3                   	ret    

00801b37 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	83 ec 18             	sub    $0x18,%esp
  801b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b40:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b43:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b46:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b4a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b54:	85 c0                	test   %eax,%eax
  801b56:	74 26                	je     801b7e <vsnprintf+0x47>
  801b58:	85 d2                	test   %edx,%edx
  801b5a:	7e 22                	jle    801b7e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b5c:	ff 75 14             	pushl  0x14(%ebp)
  801b5f:	ff 75 10             	pushl  0x10(%ebp)
  801b62:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b65:	50                   	push   %eax
  801b66:	68 49 17 80 00       	push   $0x801749
  801b6b:	e8 13 fc ff ff       	call   801783 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b70:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b73:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	eb 05                	jmp    801b83 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b83:	c9                   	leave  
  801b84:	c3                   	ret    

00801b85 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b8b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b8e:	50                   	push   %eax
  801b8f:	ff 75 10             	pushl  0x10(%ebp)
  801b92:	ff 75 0c             	pushl  0xc(%ebp)
  801b95:	ff 75 08             	pushl  0x8(%ebp)
  801b98:	e8 9a ff ff ff       	call   801b37 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b9d:	c9                   	leave  
  801b9e:	c3                   	ret    

00801b9f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  801baa:	eb 03                	jmp    801baf <strlen+0x10>
		n++;
  801bac:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801baf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bb3:	75 f7                	jne    801bac <strlen+0xd>
		n++;
	return n;
}
  801bb5:	5d                   	pop    %ebp
  801bb6:	c3                   	ret    

00801bb7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bbd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc5:	eb 03                	jmp    801bca <strnlen+0x13>
		n++;
  801bc7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bca:	39 c2                	cmp    %eax,%edx
  801bcc:	74 08                	je     801bd6 <strnlen+0x1f>
  801bce:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bd2:	75 f3                	jne    801bc7 <strnlen+0x10>
  801bd4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	53                   	push   %ebx
  801bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801be2:	89 c2                	mov    %eax,%edx
  801be4:	83 c2 01             	add    $0x1,%edx
  801be7:	83 c1 01             	add    $0x1,%ecx
  801bea:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bee:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bf1:	84 db                	test   %bl,%bl
  801bf3:	75 ef                	jne    801be4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bf5:	5b                   	pop    %ebx
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    

00801bf8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	53                   	push   %ebx
  801bfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bff:	53                   	push   %ebx
  801c00:	e8 9a ff ff ff       	call   801b9f <strlen>
  801c05:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c08:	ff 75 0c             	pushl  0xc(%ebp)
  801c0b:	01 d8                	add    %ebx,%eax
  801c0d:	50                   	push   %eax
  801c0e:	e8 c5 ff ff ff       	call   801bd8 <strcpy>
	return dst;
}
  801c13:	89 d8                	mov    %ebx,%eax
  801c15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c18:	c9                   	leave  
  801c19:	c3                   	ret    

00801c1a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	56                   	push   %esi
  801c1e:	53                   	push   %ebx
  801c1f:	8b 75 08             	mov    0x8(%ebp),%esi
  801c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c25:	89 f3                	mov    %esi,%ebx
  801c27:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c2a:	89 f2                	mov    %esi,%edx
  801c2c:	eb 0f                	jmp    801c3d <strncpy+0x23>
		*dst++ = *src;
  801c2e:	83 c2 01             	add    $0x1,%edx
  801c31:	0f b6 01             	movzbl (%ecx),%eax
  801c34:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c37:	80 39 01             	cmpb   $0x1,(%ecx)
  801c3a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c3d:	39 da                	cmp    %ebx,%edx
  801c3f:	75 ed                	jne    801c2e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c41:	89 f0                	mov    %esi,%eax
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    

00801c47 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	56                   	push   %esi
  801c4b:	53                   	push   %ebx
  801c4c:	8b 75 08             	mov    0x8(%ebp),%esi
  801c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c52:	8b 55 10             	mov    0x10(%ebp),%edx
  801c55:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c57:	85 d2                	test   %edx,%edx
  801c59:	74 21                	je     801c7c <strlcpy+0x35>
  801c5b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c5f:	89 f2                	mov    %esi,%edx
  801c61:	eb 09                	jmp    801c6c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c63:	83 c2 01             	add    $0x1,%edx
  801c66:	83 c1 01             	add    $0x1,%ecx
  801c69:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c6c:	39 c2                	cmp    %eax,%edx
  801c6e:	74 09                	je     801c79 <strlcpy+0x32>
  801c70:	0f b6 19             	movzbl (%ecx),%ebx
  801c73:	84 db                	test   %bl,%bl
  801c75:	75 ec                	jne    801c63 <strlcpy+0x1c>
  801c77:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c79:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c7c:	29 f0                	sub    %esi,%eax
}
  801c7e:	5b                   	pop    %ebx
  801c7f:	5e                   	pop    %esi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    

00801c82 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c88:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c8b:	eb 06                	jmp    801c93 <strcmp+0x11>
		p++, q++;
  801c8d:	83 c1 01             	add    $0x1,%ecx
  801c90:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c93:	0f b6 01             	movzbl (%ecx),%eax
  801c96:	84 c0                	test   %al,%al
  801c98:	74 04                	je     801c9e <strcmp+0x1c>
  801c9a:	3a 02                	cmp    (%edx),%al
  801c9c:	74 ef                	je     801c8d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c9e:	0f b6 c0             	movzbl %al,%eax
  801ca1:	0f b6 12             	movzbl (%edx),%edx
  801ca4:	29 d0                	sub    %edx,%eax
}
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    

00801ca8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	53                   	push   %ebx
  801cac:	8b 45 08             	mov    0x8(%ebp),%eax
  801caf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb2:	89 c3                	mov    %eax,%ebx
  801cb4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cb7:	eb 06                	jmp    801cbf <strncmp+0x17>
		n--, p++, q++;
  801cb9:	83 c0 01             	add    $0x1,%eax
  801cbc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cbf:	39 d8                	cmp    %ebx,%eax
  801cc1:	74 15                	je     801cd8 <strncmp+0x30>
  801cc3:	0f b6 08             	movzbl (%eax),%ecx
  801cc6:	84 c9                	test   %cl,%cl
  801cc8:	74 04                	je     801cce <strncmp+0x26>
  801cca:	3a 0a                	cmp    (%edx),%cl
  801ccc:	74 eb                	je     801cb9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cce:	0f b6 00             	movzbl (%eax),%eax
  801cd1:	0f b6 12             	movzbl (%edx),%edx
  801cd4:	29 d0                	sub    %edx,%eax
  801cd6:	eb 05                	jmp    801cdd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cd8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801cdd:	5b                   	pop    %ebx
  801cde:	5d                   	pop    %ebp
  801cdf:	c3                   	ret    

00801ce0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cea:	eb 07                	jmp    801cf3 <strchr+0x13>
		if (*s == c)
  801cec:	38 ca                	cmp    %cl,%dl
  801cee:	74 0f                	je     801cff <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801cf0:	83 c0 01             	add    $0x1,%eax
  801cf3:	0f b6 10             	movzbl (%eax),%edx
  801cf6:	84 d2                	test   %dl,%dl
  801cf8:	75 f2                	jne    801cec <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cfa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	8b 45 08             	mov    0x8(%ebp),%eax
  801d07:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d0b:	eb 03                	jmp    801d10 <strfind+0xf>
  801d0d:	83 c0 01             	add    $0x1,%eax
  801d10:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d13:	84 d2                	test   %dl,%dl
  801d15:	74 04                	je     801d1b <strfind+0x1a>
  801d17:	38 ca                	cmp    %cl,%dl
  801d19:	75 f2                	jne    801d0d <strfind+0xc>
			break;
	return (char *) s;
}
  801d1b:	5d                   	pop    %ebp
  801d1c:	c3                   	ret    

00801d1d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	57                   	push   %edi
  801d21:	56                   	push   %esi
  801d22:	53                   	push   %ebx
  801d23:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d29:	85 c9                	test   %ecx,%ecx
  801d2b:	74 36                	je     801d63 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d33:	75 28                	jne    801d5d <memset+0x40>
  801d35:	f6 c1 03             	test   $0x3,%cl
  801d38:	75 23                	jne    801d5d <memset+0x40>
		c &= 0xFF;
  801d3a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d3e:	89 d3                	mov    %edx,%ebx
  801d40:	c1 e3 08             	shl    $0x8,%ebx
  801d43:	89 d6                	mov    %edx,%esi
  801d45:	c1 e6 18             	shl    $0x18,%esi
  801d48:	89 d0                	mov    %edx,%eax
  801d4a:	c1 e0 10             	shl    $0x10,%eax
  801d4d:	09 f0                	or     %esi,%eax
  801d4f:	09 c2                	or     %eax,%edx
  801d51:	89 d0                	mov    %edx,%eax
  801d53:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d55:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801d58:	fc                   	cld    
  801d59:	f3 ab                	rep stos %eax,%es:(%edi)
  801d5b:	eb 06                	jmp    801d63 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d60:	fc                   	cld    
  801d61:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d63:	89 f8                	mov    %edi,%eax
  801d65:	5b                   	pop    %ebx
  801d66:	5e                   	pop    %esi
  801d67:	5f                   	pop    %edi
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    

00801d6a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	57                   	push   %edi
  801d6e:	56                   	push   %esi
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d72:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d78:	39 c6                	cmp    %eax,%esi
  801d7a:	73 35                	jae    801db1 <memmove+0x47>
  801d7c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d7f:	39 d0                	cmp    %edx,%eax
  801d81:	73 2e                	jae    801db1 <memmove+0x47>
		s += n;
		d += n;
  801d83:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801d86:	89 d6                	mov    %edx,%esi
  801d88:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d8a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d90:	75 13                	jne    801da5 <memmove+0x3b>
  801d92:	f6 c1 03             	test   $0x3,%cl
  801d95:	75 0e                	jne    801da5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d97:	83 ef 04             	sub    $0x4,%edi
  801d9a:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d9d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801da0:	fd                   	std    
  801da1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801da3:	eb 09                	jmp    801dae <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801da5:	83 ef 01             	sub    $0x1,%edi
  801da8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801dab:	fd                   	std    
  801dac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801dae:	fc                   	cld    
  801daf:	eb 1d                	jmp    801dce <memmove+0x64>
  801db1:	89 f2                	mov    %esi,%edx
  801db3:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801db5:	f6 c2 03             	test   $0x3,%dl
  801db8:	75 0f                	jne    801dc9 <memmove+0x5f>
  801dba:	f6 c1 03             	test   $0x3,%cl
  801dbd:	75 0a                	jne    801dc9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801dbf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801dc2:	89 c7                	mov    %eax,%edi
  801dc4:	fc                   	cld    
  801dc5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dc7:	eb 05                	jmp    801dce <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801dc9:	89 c7                	mov    %eax,%edi
  801dcb:	fc                   	cld    
  801dcc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dce:	5e                   	pop    %esi
  801dcf:	5f                   	pop    %edi
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    

00801dd2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801dd5:	ff 75 10             	pushl  0x10(%ebp)
  801dd8:	ff 75 0c             	pushl  0xc(%ebp)
  801ddb:	ff 75 08             	pushl  0x8(%ebp)
  801dde:	e8 87 ff ff ff       	call   801d6a <memmove>
}
  801de3:	c9                   	leave  
  801de4:	c3                   	ret    

00801de5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	56                   	push   %esi
  801de9:	53                   	push   %ebx
  801dea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ded:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df0:	89 c6                	mov    %eax,%esi
  801df2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801df5:	eb 1a                	jmp    801e11 <memcmp+0x2c>
		if (*s1 != *s2)
  801df7:	0f b6 08             	movzbl (%eax),%ecx
  801dfa:	0f b6 1a             	movzbl (%edx),%ebx
  801dfd:	38 d9                	cmp    %bl,%cl
  801dff:	74 0a                	je     801e0b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e01:	0f b6 c1             	movzbl %cl,%eax
  801e04:	0f b6 db             	movzbl %bl,%ebx
  801e07:	29 d8                	sub    %ebx,%eax
  801e09:	eb 0f                	jmp    801e1a <memcmp+0x35>
		s1++, s2++;
  801e0b:	83 c0 01             	add    $0x1,%eax
  801e0e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e11:	39 f0                	cmp    %esi,%eax
  801e13:	75 e2                	jne    801df7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e1a:	5b                   	pop    %ebx
  801e1b:	5e                   	pop    %esi
  801e1c:	5d                   	pop    %ebp
  801e1d:	c3                   	ret    

00801e1e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	8b 45 08             	mov    0x8(%ebp),%eax
  801e24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801e27:	89 c2                	mov    %eax,%edx
  801e29:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e2c:	eb 07                	jmp    801e35 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e2e:	38 08                	cmp    %cl,(%eax)
  801e30:	74 07                	je     801e39 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e32:	83 c0 01             	add    $0x1,%eax
  801e35:	39 d0                	cmp    %edx,%eax
  801e37:	72 f5                	jb     801e2e <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e39:	5d                   	pop    %ebp
  801e3a:	c3                   	ret    

00801e3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	57                   	push   %edi
  801e3f:	56                   	push   %esi
  801e40:	53                   	push   %ebx
  801e41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e47:	eb 03                	jmp    801e4c <strtol+0x11>
		s++;
  801e49:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e4c:	0f b6 01             	movzbl (%ecx),%eax
  801e4f:	3c 09                	cmp    $0x9,%al
  801e51:	74 f6                	je     801e49 <strtol+0xe>
  801e53:	3c 20                	cmp    $0x20,%al
  801e55:	74 f2                	je     801e49 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e57:	3c 2b                	cmp    $0x2b,%al
  801e59:	75 0a                	jne    801e65 <strtol+0x2a>
		s++;
  801e5b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e5e:	bf 00 00 00 00       	mov    $0x0,%edi
  801e63:	eb 10                	jmp    801e75 <strtol+0x3a>
  801e65:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e6a:	3c 2d                	cmp    $0x2d,%al
  801e6c:	75 07                	jne    801e75 <strtol+0x3a>
		s++, neg = 1;
  801e6e:	8d 49 01             	lea    0x1(%ecx),%ecx
  801e71:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e75:	85 db                	test   %ebx,%ebx
  801e77:	0f 94 c0             	sete   %al
  801e7a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e80:	75 19                	jne    801e9b <strtol+0x60>
  801e82:	80 39 30             	cmpb   $0x30,(%ecx)
  801e85:	75 14                	jne    801e9b <strtol+0x60>
  801e87:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e8b:	0f 85 82 00 00 00    	jne    801f13 <strtol+0xd8>
		s += 2, base = 16;
  801e91:	83 c1 02             	add    $0x2,%ecx
  801e94:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e99:	eb 16                	jmp    801eb1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801e9b:	84 c0                	test   %al,%al
  801e9d:	74 12                	je     801eb1 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e9f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ea4:	80 39 30             	cmpb   $0x30,(%ecx)
  801ea7:	75 08                	jne    801eb1 <strtol+0x76>
		s++, base = 8;
  801ea9:	83 c1 01             	add    $0x1,%ecx
  801eac:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801eb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801eb9:	0f b6 11             	movzbl (%ecx),%edx
  801ebc:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ebf:	89 f3                	mov    %esi,%ebx
  801ec1:	80 fb 09             	cmp    $0x9,%bl
  801ec4:	77 08                	ja     801ece <strtol+0x93>
			dig = *s - '0';
  801ec6:	0f be d2             	movsbl %dl,%edx
  801ec9:	83 ea 30             	sub    $0x30,%edx
  801ecc:	eb 22                	jmp    801ef0 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  801ece:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ed1:	89 f3                	mov    %esi,%ebx
  801ed3:	80 fb 19             	cmp    $0x19,%bl
  801ed6:	77 08                	ja     801ee0 <strtol+0xa5>
			dig = *s - 'a' + 10;
  801ed8:	0f be d2             	movsbl %dl,%edx
  801edb:	83 ea 57             	sub    $0x57,%edx
  801ede:	eb 10                	jmp    801ef0 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  801ee0:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ee3:	89 f3                	mov    %esi,%ebx
  801ee5:	80 fb 19             	cmp    $0x19,%bl
  801ee8:	77 16                	ja     801f00 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801eea:	0f be d2             	movsbl %dl,%edx
  801eed:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ef0:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ef3:	7d 0f                	jge    801f04 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801ef5:	83 c1 01             	add    $0x1,%ecx
  801ef8:	0f af 45 10          	imul   0x10(%ebp),%eax
  801efc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801efe:	eb b9                	jmp    801eb9 <strtol+0x7e>
  801f00:	89 c2                	mov    %eax,%edx
  801f02:	eb 02                	jmp    801f06 <strtol+0xcb>
  801f04:	89 c2                	mov    %eax,%edx

	if (endptr)
  801f06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f0a:	74 0d                	je     801f19 <strtol+0xde>
		*endptr = (char *) s;
  801f0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0f:	89 0e                	mov    %ecx,(%esi)
  801f11:	eb 06                	jmp    801f19 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f13:	84 c0                	test   %al,%al
  801f15:	75 92                	jne    801ea9 <strtol+0x6e>
  801f17:	eb 98                	jmp    801eb1 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f19:	f7 da                	neg    %edx
  801f1b:	85 ff                	test   %edi,%edi
  801f1d:	0f 45 c2             	cmovne %edx,%eax
}
  801f20:	5b                   	pop    %ebx
  801f21:	5e                   	pop    %esi
  801f22:	5f                   	pop    %edi
  801f23:	5d                   	pop    %ebp
  801f24:	c3                   	ret    

00801f25 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	56                   	push   %esi
  801f29:	53                   	push   %ebx
  801f2a:	8b 75 08             	mov    0x8(%ebp),%esi
  801f2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f33:	85 c0                	test   %eax,%eax
  801f35:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f3a:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f3d:	83 ec 0c             	sub    $0xc,%esp
  801f40:	50                   	push   %eax
  801f41:	e8 cd e3 ff ff       	call   800313 <sys_ipc_recv>
  801f46:	83 c4 10             	add    $0x10,%esp
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	79 16                	jns    801f63 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801f4d:	85 f6                	test   %esi,%esi
  801f4f:	74 06                	je     801f57 <ipc_recv+0x32>
  801f51:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801f57:	85 db                	test   %ebx,%ebx
  801f59:	74 2c                	je     801f87 <ipc_recv+0x62>
  801f5b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f61:	eb 24                	jmp    801f87 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801f63:	85 f6                	test   %esi,%esi
  801f65:	74 0a                	je     801f71 <ipc_recv+0x4c>
  801f67:	a1 08 40 80 00       	mov    0x804008,%eax
  801f6c:	8b 40 74             	mov    0x74(%eax),%eax
  801f6f:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801f71:	85 db                	test   %ebx,%ebx
  801f73:	74 0a                	je     801f7f <ipc_recv+0x5a>
  801f75:	a1 08 40 80 00       	mov    0x804008,%eax
  801f7a:	8b 40 78             	mov    0x78(%eax),%eax
  801f7d:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801f7f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f84:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8a:	5b                   	pop    %ebx
  801f8b:	5e                   	pop    %esi
  801f8c:	5d                   	pop    %ebp
  801f8d:	c3                   	ret    

00801f8e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 0c             	sub    $0xc,%esp
  801f97:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f9a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801fa0:	85 db                	test   %ebx,%ebx
  801fa2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fa7:	0f 44 d8             	cmove  %eax,%ebx
  801faa:	eb 1c                	jmp    801fc8 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801fac:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801faf:	74 12                	je     801fc3 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801fb1:	50                   	push   %eax
  801fb2:	68 e0 27 80 00       	push   $0x8027e0
  801fb7:	6a 39                	push   $0x39
  801fb9:	68 fb 27 80 00       	push   $0x8027fb
  801fbe:	e8 b5 f5 ff ff       	call   801578 <_panic>
                 sys_yield();
  801fc3:	e8 7c e1 ff ff       	call   800144 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801fc8:	ff 75 14             	pushl  0x14(%ebp)
  801fcb:	53                   	push   %ebx
  801fcc:	56                   	push   %esi
  801fcd:	57                   	push   %edi
  801fce:	e8 1d e3 ff ff       	call   8002f0 <sys_ipc_try_send>
  801fd3:	83 c4 10             	add    $0x10,%esp
  801fd6:	85 c0                	test   %eax,%eax
  801fd8:	78 d2                	js     801fac <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801fda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fdd:	5b                   	pop    %ebx
  801fde:	5e                   	pop    %esi
  801fdf:	5f                   	pop    %edi
  801fe0:	5d                   	pop    %ebp
  801fe1:	c3                   	ret    

00801fe2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fe8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fed:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ff0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ff6:	8b 52 50             	mov    0x50(%edx),%edx
  801ff9:	39 ca                	cmp    %ecx,%edx
  801ffb:	75 0d                	jne    80200a <ipc_find_env+0x28>
			return envs[i].env_id;
  801ffd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802000:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802005:	8b 40 08             	mov    0x8(%eax),%eax
  802008:	eb 0e                	jmp    802018 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80200a:	83 c0 01             	add    $0x1,%eax
  80200d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802012:	75 d9                	jne    801fed <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802014:	66 b8 00 00          	mov    $0x0,%ax
}
  802018:	5d                   	pop    %ebp
  802019:	c3                   	ret    

0080201a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802020:	89 d0                	mov    %edx,%eax
  802022:	c1 e8 16             	shr    $0x16,%eax
  802025:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80202c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802031:	f6 c1 01             	test   $0x1,%cl
  802034:	74 1d                	je     802053 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802036:	c1 ea 0c             	shr    $0xc,%edx
  802039:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802040:	f6 c2 01             	test   $0x1,%dl
  802043:	74 0e                	je     802053 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802045:	c1 ea 0c             	shr    $0xc,%edx
  802048:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80204f:	ef 
  802050:	0f b7 c0             	movzwl %ax,%eax
}
  802053:	5d                   	pop    %ebp
  802054:	c3                   	ret    
  802055:	66 90                	xchg   %ax,%ax
  802057:	66 90                	xchg   %ax,%ax
  802059:	66 90                	xchg   %ax,%ax
  80205b:	66 90                	xchg   %ax,%ax
  80205d:	66 90                	xchg   %ax,%ax
  80205f:	90                   	nop

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	83 ec 10             	sub    $0x10,%esp
  802066:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80206a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80206e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802072:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802076:	85 d2                	test   %edx,%edx
  802078:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80207c:	89 34 24             	mov    %esi,(%esp)
  80207f:	89 c8                	mov    %ecx,%eax
  802081:	75 35                	jne    8020b8 <__udivdi3+0x58>
  802083:	39 f1                	cmp    %esi,%ecx
  802085:	0f 87 bd 00 00 00    	ja     802148 <__udivdi3+0xe8>
  80208b:	85 c9                	test   %ecx,%ecx
  80208d:	89 cd                	mov    %ecx,%ebp
  80208f:	75 0b                	jne    80209c <__udivdi3+0x3c>
  802091:	b8 01 00 00 00       	mov    $0x1,%eax
  802096:	31 d2                	xor    %edx,%edx
  802098:	f7 f1                	div    %ecx
  80209a:	89 c5                	mov    %eax,%ebp
  80209c:	89 f0                	mov    %esi,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f5                	div    %ebp
  8020a2:	89 c6                	mov    %eax,%esi
  8020a4:	89 f8                	mov    %edi,%eax
  8020a6:	f7 f5                	div    %ebp
  8020a8:	89 f2                	mov    %esi,%edx
  8020aa:	83 c4 10             	add    $0x10,%esp
  8020ad:	5e                   	pop    %esi
  8020ae:	5f                   	pop    %edi
  8020af:	5d                   	pop    %ebp
  8020b0:	c3                   	ret    
  8020b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	3b 14 24             	cmp    (%esp),%edx
  8020bb:	77 7b                	ja     802138 <__udivdi3+0xd8>
  8020bd:	0f bd f2             	bsr    %edx,%esi
  8020c0:	83 f6 1f             	xor    $0x1f,%esi
  8020c3:	0f 84 97 00 00 00    	je     802160 <__udivdi3+0x100>
  8020c9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020ce:	89 d7                	mov    %edx,%edi
  8020d0:	89 f1                	mov    %esi,%ecx
  8020d2:	29 f5                	sub    %esi,%ebp
  8020d4:	d3 e7                	shl    %cl,%edi
  8020d6:	89 c2                	mov    %eax,%edx
  8020d8:	89 e9                	mov    %ebp,%ecx
  8020da:	d3 ea                	shr    %cl,%edx
  8020dc:	89 f1                	mov    %esi,%ecx
  8020de:	09 fa                	or     %edi,%edx
  8020e0:	8b 3c 24             	mov    (%esp),%edi
  8020e3:	d3 e0                	shl    %cl,%eax
  8020e5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020e9:	89 e9                	mov    %ebp,%ecx
  8020eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ef:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020f3:	89 fa                	mov    %edi,%edx
  8020f5:	d3 ea                	shr    %cl,%edx
  8020f7:	89 f1                	mov    %esi,%ecx
  8020f9:	d3 e7                	shl    %cl,%edi
  8020fb:	89 e9                	mov    %ebp,%ecx
  8020fd:	d3 e8                	shr    %cl,%eax
  8020ff:	09 c7                	or     %eax,%edi
  802101:	89 f8                	mov    %edi,%eax
  802103:	f7 74 24 08          	divl   0x8(%esp)
  802107:	89 d5                	mov    %edx,%ebp
  802109:	89 c7                	mov    %eax,%edi
  80210b:	f7 64 24 0c          	mull   0xc(%esp)
  80210f:	39 d5                	cmp    %edx,%ebp
  802111:	89 14 24             	mov    %edx,(%esp)
  802114:	72 11                	jb     802127 <__udivdi3+0xc7>
  802116:	8b 54 24 04          	mov    0x4(%esp),%edx
  80211a:	89 f1                	mov    %esi,%ecx
  80211c:	d3 e2                	shl    %cl,%edx
  80211e:	39 c2                	cmp    %eax,%edx
  802120:	73 5e                	jae    802180 <__udivdi3+0x120>
  802122:	3b 2c 24             	cmp    (%esp),%ebp
  802125:	75 59                	jne    802180 <__udivdi3+0x120>
  802127:	8d 47 ff             	lea    -0x1(%edi),%eax
  80212a:	31 f6                	xor    %esi,%esi
  80212c:	89 f2                	mov    %esi,%edx
  80212e:	83 c4 10             	add    $0x10,%esp
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	31 f6                	xor    %esi,%esi
  80213a:	31 c0                	xor    %eax,%eax
  80213c:	89 f2                	mov    %esi,%edx
  80213e:	83 c4 10             	add    $0x10,%esp
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	89 f2                	mov    %esi,%edx
  80214a:	31 f6                	xor    %esi,%esi
  80214c:	89 f8                	mov    %edi,%eax
  80214e:	f7 f1                	div    %ecx
  802150:	89 f2                	mov    %esi,%edx
  802152:	83 c4 10             	add    $0x10,%esp
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802164:	76 0b                	jbe    802171 <__udivdi3+0x111>
  802166:	31 c0                	xor    %eax,%eax
  802168:	3b 14 24             	cmp    (%esp),%edx
  80216b:	0f 83 37 ff ff ff    	jae    8020a8 <__udivdi3+0x48>
  802171:	b8 01 00 00 00       	mov    $0x1,%eax
  802176:	e9 2d ff ff ff       	jmp    8020a8 <__udivdi3+0x48>
  80217b:	90                   	nop
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 f8                	mov    %edi,%eax
  802182:	31 f6                	xor    %esi,%esi
  802184:	e9 1f ff ff ff       	jmp    8020a8 <__udivdi3+0x48>
  802189:	66 90                	xchg   %ax,%ax
  80218b:	66 90                	xchg   %ax,%ax
  80218d:	66 90                	xchg   %ax,%ax
  80218f:	90                   	nop

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	83 ec 20             	sub    $0x20,%esp
  802196:	8b 44 24 34          	mov    0x34(%esp),%eax
  80219a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80219e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a2:	89 c6                	mov    %eax,%esi
  8021a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021a8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021ac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8021b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021b4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021b8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021bc:	85 c0                	test   %eax,%eax
  8021be:	89 c2                	mov    %eax,%edx
  8021c0:	75 1e                	jne    8021e0 <__umoddi3+0x50>
  8021c2:	39 f7                	cmp    %esi,%edi
  8021c4:	76 52                	jbe    802218 <__umoddi3+0x88>
  8021c6:	89 c8                	mov    %ecx,%eax
  8021c8:	89 f2                	mov    %esi,%edx
  8021ca:	f7 f7                	div    %edi
  8021cc:	89 d0                	mov    %edx,%eax
  8021ce:	31 d2                	xor    %edx,%edx
  8021d0:	83 c4 20             	add    $0x20,%esp
  8021d3:	5e                   	pop    %esi
  8021d4:	5f                   	pop    %edi
  8021d5:	5d                   	pop    %ebp
  8021d6:	c3                   	ret    
  8021d7:	89 f6                	mov    %esi,%esi
  8021d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021e0:	39 f0                	cmp    %esi,%eax
  8021e2:	77 5c                	ja     802240 <__umoddi3+0xb0>
  8021e4:	0f bd e8             	bsr    %eax,%ebp
  8021e7:	83 f5 1f             	xor    $0x1f,%ebp
  8021ea:	75 64                	jne    802250 <__umoddi3+0xc0>
  8021ec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8021f0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8021f4:	0f 86 f6 00 00 00    	jbe    8022f0 <__umoddi3+0x160>
  8021fa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8021fe:	0f 82 ec 00 00 00    	jb     8022f0 <__umoddi3+0x160>
  802204:	8b 44 24 14          	mov    0x14(%esp),%eax
  802208:	8b 54 24 18          	mov    0x18(%esp),%edx
  80220c:	83 c4 20             	add    $0x20,%esp
  80220f:	5e                   	pop    %esi
  802210:	5f                   	pop    %edi
  802211:	5d                   	pop    %ebp
  802212:	c3                   	ret    
  802213:	90                   	nop
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	85 ff                	test   %edi,%edi
  80221a:	89 fd                	mov    %edi,%ebp
  80221c:	75 0b                	jne    802229 <__umoddi3+0x99>
  80221e:	b8 01 00 00 00       	mov    $0x1,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f7                	div    %edi
  802227:	89 c5                	mov    %eax,%ebp
  802229:	8b 44 24 10          	mov    0x10(%esp),%eax
  80222d:	31 d2                	xor    %edx,%edx
  80222f:	f7 f5                	div    %ebp
  802231:	89 c8                	mov    %ecx,%eax
  802233:	f7 f5                	div    %ebp
  802235:	eb 95                	jmp    8021cc <__umoddi3+0x3c>
  802237:	89 f6                	mov    %esi,%esi
  802239:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 20             	add    $0x20,%esp
  802247:	5e                   	pop    %esi
  802248:	5f                   	pop    %edi
  802249:	5d                   	pop    %ebp
  80224a:	c3                   	ret    
  80224b:	90                   	nop
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	b8 20 00 00 00       	mov    $0x20,%eax
  802255:	89 e9                	mov    %ebp,%ecx
  802257:	29 e8                	sub    %ebp,%eax
  802259:	d3 e2                	shl    %cl,%edx
  80225b:	89 c7                	mov    %eax,%edi
  80225d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802261:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802265:	89 f9                	mov    %edi,%ecx
  802267:	d3 e8                	shr    %cl,%eax
  802269:	89 c1                	mov    %eax,%ecx
  80226b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80226f:	09 d1                	or     %edx,%ecx
  802271:	89 fa                	mov    %edi,%edx
  802273:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802277:	89 e9                	mov    %ebp,%ecx
  802279:	d3 e0                	shl    %cl,%eax
  80227b:	89 f9                	mov    %edi,%ecx
  80227d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802281:	89 f0                	mov    %esi,%eax
  802283:	d3 e8                	shr    %cl,%eax
  802285:	89 e9                	mov    %ebp,%ecx
  802287:	89 c7                	mov    %eax,%edi
  802289:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80228d:	d3 e6                	shl    %cl,%esi
  80228f:	89 d1                	mov    %edx,%ecx
  802291:	89 fa                	mov    %edi,%edx
  802293:	d3 e8                	shr    %cl,%eax
  802295:	89 e9                	mov    %ebp,%ecx
  802297:	09 f0                	or     %esi,%eax
  802299:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80229d:	f7 74 24 10          	divl   0x10(%esp)
  8022a1:	d3 e6                	shl    %cl,%esi
  8022a3:	89 d1                	mov    %edx,%ecx
  8022a5:	f7 64 24 0c          	mull   0xc(%esp)
  8022a9:	39 d1                	cmp    %edx,%ecx
  8022ab:	89 74 24 14          	mov    %esi,0x14(%esp)
  8022af:	89 d7                	mov    %edx,%edi
  8022b1:	89 c6                	mov    %eax,%esi
  8022b3:	72 0a                	jb     8022bf <__umoddi3+0x12f>
  8022b5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8022b9:	73 10                	jae    8022cb <__umoddi3+0x13b>
  8022bb:	39 d1                	cmp    %edx,%ecx
  8022bd:	75 0c                	jne    8022cb <__umoddi3+0x13b>
  8022bf:	89 d7                	mov    %edx,%edi
  8022c1:	89 c6                	mov    %eax,%esi
  8022c3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8022c7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8022cb:	89 ca                	mov    %ecx,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022d3:	29 f0                	sub    %esi,%eax
  8022d5:	19 fa                	sbb    %edi,%edx
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8022de:	89 d7                	mov    %edx,%edi
  8022e0:	d3 e7                	shl    %cl,%edi
  8022e2:	89 e9                	mov    %ebp,%ecx
  8022e4:	09 f8                	or     %edi,%eax
  8022e6:	d3 ea                	shr    %cl,%edx
  8022e8:	83 c4 20             	add    $0x20,%esp
  8022eb:	5e                   	pop    %esi
  8022ec:	5f                   	pop    %edi
  8022ed:	5d                   	pop    %ebp
  8022ee:	c3                   	ret    
  8022ef:	90                   	nop
  8022f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022f4:	29 f9                	sub    %edi,%ecx
  8022f6:	19 c6                	sbb    %eax,%esi
  8022f8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8022fc:	89 74 24 18          	mov    %esi,0x18(%esp)
  802300:	e9 ff fe ff ff       	jmp    802204 <__umoddi3+0x74>
