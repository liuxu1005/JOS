
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
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800093:	e8 89 04 00 00       	call   800521 <close_all>
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
  80010c:	68 0a 1e 80 00       	push   $0x801e0a
  800111:	6a 23                	push   $0x23
  800113:	68 27 1e 80 00       	push   $0x801e27
  800118:	e8 44 0f 00 00       	call   801061 <_panic>

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
  80018d:	68 0a 1e 80 00       	push   $0x801e0a
  800192:	6a 23                	push   $0x23
  800194:	68 27 1e 80 00       	push   $0x801e27
  800199:	e8 c3 0e 00 00       	call   801061 <_panic>

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
  8001cf:	68 0a 1e 80 00       	push   $0x801e0a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 27 1e 80 00       	push   $0x801e27
  8001db:	e8 81 0e 00 00       	call   801061 <_panic>

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
  800211:	68 0a 1e 80 00       	push   $0x801e0a
  800216:	6a 23                	push   $0x23
  800218:	68 27 1e 80 00       	push   $0x801e27
  80021d:	e8 3f 0e 00 00       	call   801061 <_panic>

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
  800253:	68 0a 1e 80 00       	push   $0x801e0a
  800258:	6a 23                	push   $0x23
  80025a:	68 27 1e 80 00       	push   $0x801e27
  80025f:	e8 fd 0d 00 00       	call   801061 <_panic>
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
  800295:	68 0a 1e 80 00       	push   $0x801e0a
  80029a:	6a 23                	push   $0x23
  80029c:	68 27 1e 80 00       	push   $0x801e27
  8002a1:	e8 bb 0d 00 00       	call   801061 <_panic>

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
  8002d7:	68 0a 1e 80 00       	push   $0x801e0a
  8002dc:	6a 23                	push   $0x23
  8002de:	68 27 1e 80 00       	push   $0x801e27
  8002e3:	e8 79 0d 00 00       	call   801061 <_panic>

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
  80033b:	68 0a 1e 80 00       	push   $0x801e0a
  800340:	6a 23                	push   $0x23
  800342:	68 27 1e 80 00       	push   $0x801e27
  800347:	e8 15 0d 00 00       	call   801061 <_panic>

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

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 11                	je     8003a8 <fd_alloc+0x2d>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	75 09                	jne    8003b1 <fd_alloc+0x36>
			*fd_store = fd;
  8003a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003af:	eb 17                	jmp    8003c8 <fd_alloc+0x4d>
  8003b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003bb:	75 c9                	jne    800386 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
  800409:	eb 13                	jmp    80041e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb 0c                	jmp    80041e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 05                	jmp    80041e <fd_lookup+0x54>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	eb 13                	jmp    800443 <dev_lookup+0x23>
  800430:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	75 0c                	jne    800443 <dev_lookup+0x23>
			*dev = devtab[i];
  800437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	eb 2e                	jmp    800471 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	75 e7                	jne    800430 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800449:	a1 04 40 80 00       	mov    0x804004,%eax
  80044e:	8b 40 48             	mov    0x48(%eax),%eax
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	51                   	push   %ecx
  800455:	50                   	push   %eax
  800456:	68 38 1e 80 00       	push   $0x801e38
  80045b:	e8 da 0c 00 00       	call   80113a <cprintf>
	*dev = 0;
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 10             	sub    $0x10,%esp
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800484:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800485:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048b:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80048e:	50                   	push   %eax
  80048f:	e8 36 ff ff ff       	call   8003ca <fd_lookup>
  800494:	83 c4 08             	add    $0x8,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	78 05                	js     8004a0 <fd_close+0x2d>
	    || fd != fd2)
  80049b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80049e:	74 0c                	je     8004ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a0:	84 db                	test   %bl,%bl
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	0f 44 c2             	cmove  %edx,%eax
  8004aa:	eb 41                	jmp    8004ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff 36                	pushl  (%esi)
  8004b5:	e8 66 ff ff ff       	call   800420 <dev_lookup>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 1a                	js     8004dd <fd_close+0x6a>
		if (dev->dev_close)
  8004c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 0b                	je     8004dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d2:	83 ec 0c             	sub    $0xc,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff d0                	call   *%eax
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	6a 00                	push   $0x0
  8004e3:	e8 00 fd ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	89 d8                	mov    %ebx,%eax
}
  8004ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 c4 fe ff ff       	call   8003ca <fd_lookup>
  800506:	89 c2                	mov    %eax,%edx
  800508:	83 c4 08             	add    $0x8,%esp
  80050b:	85 d2                	test   %edx,%edx
  80050d:	78 10                	js     80051f <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	6a 01                	push   $0x1
  800514:	ff 75 f4             	pushl  -0xc(%ebp)
  800517:	e8 57 ff ff ff       	call   800473 <fd_close>
  80051c:	83 c4 10             	add    $0x10,%esp
}
  80051f:	c9                   	leave  
  800520:	c3                   	ret    

00800521 <close_all>:

void
close_all(void)
{
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	53                   	push   %ebx
  800525:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800528:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052d:	83 ec 0c             	sub    $0xc,%esp
  800530:	53                   	push   %ebx
  800531:	e8 be ff ff ff       	call   8004f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800536:	83 c3 01             	add    $0x1,%ebx
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	83 fb 20             	cmp    $0x20,%ebx
  80053f:	75 ec                	jne    80052d <close_all+0xc>
		close(i);
}
  800541:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800544:	c9                   	leave  
  800545:	c3                   	ret    

00800546 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	57                   	push   %edi
  80054a:	56                   	push   %esi
  80054b:	53                   	push   %ebx
  80054c:	83 ec 2c             	sub    $0x2c,%esp
  80054f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800552:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800555:	50                   	push   %eax
  800556:	ff 75 08             	pushl  0x8(%ebp)
  800559:	e8 6c fe ff ff       	call   8003ca <fd_lookup>
  80055e:	89 c2                	mov    %eax,%edx
  800560:	83 c4 08             	add    $0x8,%esp
  800563:	85 d2                	test   %edx,%edx
  800565:	0f 88 c1 00 00 00    	js     80062c <dup+0xe6>
		return r;
	close(newfdnum);
  80056b:	83 ec 0c             	sub    $0xc,%esp
  80056e:	56                   	push   %esi
  80056f:	e8 80 ff ff ff       	call   8004f4 <close>

	newfd = INDEX2FD(newfdnum);
  800574:	89 f3                	mov    %esi,%ebx
  800576:	c1 e3 0c             	shl    $0xc,%ebx
  800579:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057f:	83 c4 04             	add    $0x4,%esp
  800582:	ff 75 e4             	pushl  -0x1c(%ebp)
  800585:	e8 da fd ff ff       	call   800364 <fd2data>
  80058a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058c:	89 1c 24             	mov    %ebx,(%esp)
  80058f:	e8 d0 fd ff ff       	call   800364 <fd2data>
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059a:	89 f8                	mov    %edi,%eax
  80059c:	c1 e8 16             	shr    $0x16,%eax
  80059f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a6:	a8 01                	test   $0x1,%al
  8005a8:	74 37                	je     8005e1 <dup+0x9b>
  8005aa:	89 f8                	mov    %edi,%eax
  8005ac:	c1 e8 0c             	shr    $0xc,%eax
  8005af:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b6:	f6 c2 01             	test   $0x1,%dl
  8005b9:	74 26                	je     8005e1 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c2:	83 ec 0c             	sub    $0xc,%esp
  8005c5:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ca:	50                   	push   %eax
  8005cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ce:	6a 00                	push   $0x0
  8005d0:	57                   	push   %edi
  8005d1:	6a 00                	push   $0x0
  8005d3:	e8 ce fb ff ff       	call   8001a6 <sys_page_map>
  8005d8:	89 c7                	mov    %eax,%edi
  8005da:	83 c4 20             	add    $0x20,%esp
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	78 2e                	js     80060f <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e4:	89 d0                	mov    %edx,%eax
  8005e6:	c1 e8 0c             	shr    $0xc,%eax
  8005e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f0:	83 ec 0c             	sub    $0xc,%esp
  8005f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f8:	50                   	push   %eax
  8005f9:	53                   	push   %ebx
  8005fa:	6a 00                	push   $0x0
  8005fc:	52                   	push   %edx
  8005fd:	6a 00                	push   $0x0
  8005ff:	e8 a2 fb ff ff       	call   8001a6 <sys_page_map>
  800604:	89 c7                	mov    %eax,%edi
  800606:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800609:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060b:	85 ff                	test   %edi,%edi
  80060d:	79 1d                	jns    80062c <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 00                	push   $0x0
  800615:	e8 ce fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061a:	83 c4 08             	add    $0x8,%esp
  80061d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800620:	6a 00                	push   $0x0
  800622:	e8 c1 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800627:	83 c4 10             	add    $0x10,%esp
  80062a:	89 f8                	mov    %edi,%eax
}
  80062c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062f:	5b                   	pop    %ebx
  800630:	5e                   	pop    %esi
  800631:	5f                   	pop    %edi
  800632:	5d                   	pop    %ebp
  800633:	c3                   	ret    

00800634 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800634:	55                   	push   %ebp
  800635:	89 e5                	mov    %esp,%ebp
  800637:	53                   	push   %ebx
  800638:	83 ec 14             	sub    $0x14,%esp
  80063b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800641:	50                   	push   %eax
  800642:	53                   	push   %ebx
  800643:	e8 82 fd ff ff       	call   8003ca <fd_lookup>
  800648:	83 c4 08             	add    $0x8,%esp
  80064b:	89 c2                	mov    %eax,%edx
  80064d:	85 c0                	test   %eax,%eax
  80064f:	78 6d                	js     8006be <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800657:	50                   	push   %eax
  800658:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065b:	ff 30                	pushl  (%eax)
  80065d:	e8 be fd ff ff       	call   800420 <dev_lookup>
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	85 c0                	test   %eax,%eax
  800667:	78 4c                	js     8006b5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800669:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066c:	8b 42 08             	mov    0x8(%edx),%eax
  80066f:	83 e0 03             	and    $0x3,%eax
  800672:	83 f8 01             	cmp    $0x1,%eax
  800675:	75 21                	jne    800698 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800677:	a1 04 40 80 00       	mov    0x804004,%eax
  80067c:	8b 40 48             	mov    0x48(%eax),%eax
  80067f:	83 ec 04             	sub    $0x4,%esp
  800682:	53                   	push   %ebx
  800683:	50                   	push   %eax
  800684:	68 79 1e 80 00       	push   $0x801e79
  800689:	e8 ac 0a 00 00       	call   80113a <cprintf>
		return -E_INVAL;
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800696:	eb 26                	jmp    8006be <read+0x8a>
	}
	if (!dev->dev_read)
  800698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069b:	8b 40 08             	mov    0x8(%eax),%eax
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	74 17                	je     8006b9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a2:	83 ec 04             	sub    $0x4,%esp
  8006a5:	ff 75 10             	pushl  0x10(%ebp)
  8006a8:	ff 75 0c             	pushl  0xc(%ebp)
  8006ab:	52                   	push   %edx
  8006ac:	ff d0                	call   *%eax
  8006ae:	89 c2                	mov    %eax,%edx
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	eb 09                	jmp    8006be <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b5:	89 c2                	mov    %eax,%edx
  8006b7:	eb 05                	jmp    8006be <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006be:	89 d0                	mov    %edx,%eax
  8006c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c3:	c9                   	leave  
  8006c4:	c3                   	ret    

008006c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	57                   	push   %edi
  8006c9:	56                   	push   %esi
  8006ca:	53                   	push   %ebx
  8006cb:	83 ec 0c             	sub    $0xc,%esp
  8006ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d9:	eb 21                	jmp    8006fc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006db:	83 ec 04             	sub    $0x4,%esp
  8006de:	89 f0                	mov    %esi,%eax
  8006e0:	29 d8                	sub    %ebx,%eax
  8006e2:	50                   	push   %eax
  8006e3:	89 d8                	mov    %ebx,%eax
  8006e5:	03 45 0c             	add    0xc(%ebp),%eax
  8006e8:	50                   	push   %eax
  8006e9:	57                   	push   %edi
  8006ea:	e8 45 ff ff ff       	call   800634 <read>
		if (m < 0)
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	78 0c                	js     800702 <readn+0x3d>
			return m;
		if (m == 0)
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	74 06                	je     800700 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006fa:	01 c3                	add    %eax,%ebx
  8006fc:	39 f3                	cmp    %esi,%ebx
  8006fe:	72 db                	jb     8006db <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800700:	89 d8                	mov    %ebx,%eax
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	83 ec 14             	sub    $0x14,%esp
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	53                   	push   %ebx
  800719:	e8 ac fc ff ff       	call   8003ca <fd_lookup>
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	89 c2                	mov    %eax,%edx
  800723:	85 c0                	test   %eax,%eax
  800725:	78 68                	js     80078f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 e8 fc ff ff       	call   800420 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 47                	js     800786 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	75 21                	jne    800769 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 04 40 80 00       	mov    0x804004,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 95 1e 80 00       	push   $0x801e95
  80075a:	e8 db 09 00 00       	call   80113a <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800767:	eb 26                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076c:	8b 52 0c             	mov    0xc(%edx),%edx
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 17                	je     80078a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	50                   	push   %eax
  80077d:	ff d2                	call   *%edx
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 09                	jmp    80078f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800786:	89 c2                	mov    %eax,%edx
  800788:	eb 05                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078f:	89 d0                	mov    %edx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <seek>:

int
seek(int fdnum, off_t offset)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 22 fc ff ff       	call   8003ca <fd_lookup>
  8007a8:	83 c4 08             	add    $0x8,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 0e                	js     8007bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 14             	sub    $0x14,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 f7 fb ff ff       	call   8003ca <fd_lookup>
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	78 65                	js     800841 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e6:	ff 30                	pushl  (%eax)
  8007e8:	e8 33 fc ff ff       	call   800420 <dev_lookup>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 44                	js     800838 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fb:	75 21                	jne    80081e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007fd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 58 1e 80 00       	push   $0x801e58
  80080f:	e8 26 09 00 00       	call   80113a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081c:	eb 23                	jmp    800841 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80081e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800821:	8b 52 18             	mov    0x18(%edx),%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	74 14                	je     80083c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	50                   	push   %eax
  80082f:	ff d2                	call   *%edx
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	eb 09                	jmp    800841 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	89 c2                	mov    %eax,%edx
  80083a:	eb 05                	jmp    800841 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800841:	89 d0                	mov    %edx,%eax
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 14             	sub    $0x14,%esp
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800852:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 6c fb ff ff       	call   8003ca <fd_lookup>
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	89 c2                	mov    %eax,%edx
  800863:	85 c0                	test   %eax,%eax
  800865:	78 58                	js     8008bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800871:	ff 30                	pushl  (%eax)
  800873:	e8 a8 fb ff ff       	call   800420 <dev_lookup>
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 37                	js     8008b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800886:	74 32                	je     8008ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800888:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800892:	00 00 00 
	stat->st_isdir = 0;
  800895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089c:	00 00 00 
	stat->st_dev = dev;
  80089f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ac:	ff 50 14             	call   *0x14(%eax)
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 09                	jmp    8008bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	eb 05                	jmp    8008bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	6a 00                	push   $0x0
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 09 02 00 00       	call   800ae1 <open>
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 db                	test   %ebx,%ebx
  8008df:	78 1b                	js     8008fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	53                   	push   %ebx
  8008e8:	e8 5b ff ff ff       	call   800848 <fstat>
  8008ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ef:	89 1c 24             	mov    %ebx,(%esp)
  8008f2:	e8 fd fb ff ff       	call   8004f4 <close>
	return r;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 f0                	mov    %esi,%eax
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	89 c6                	mov    %eax,%esi
  80090a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800913:	75 12                	jne    800927 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	6a 01                	push   $0x1
  80091a:	e8 ac 11 00 00       	call   801acb <ipc_find_env>
  80091f:	a3 00 40 80 00       	mov    %eax,0x804000
  800924:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800927:	6a 07                	push   $0x7
  800929:	68 00 50 80 00       	push   $0x805000
  80092e:	56                   	push   %esi
  80092f:	ff 35 00 40 80 00    	pushl  0x804000
  800935:	e8 3d 11 00 00       	call   801a77 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093a:	83 c4 0c             	add    $0xc,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	53                   	push   %ebx
  800940:	6a 00                	push   $0x0
  800942:	e8 c7 10 00 00       	call   801a0e <ipc_recv>
}
  800947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 40 0c             	mov    0xc(%eax),%eax
  80095a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
  80096c:	b8 02 00 00 00       	mov    $0x2,%eax
  800971:	e8 8d ff ff ff       	call   800903 <fsipc>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 6b ff ff ff       	call   800903 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	83 ec 04             	sub    $0x4,%esp
  8009a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b9:	e8 45 ff ff ff       	call   800903 <fsipc>
  8009be:	89 c2                	mov    %eax,%edx
  8009c0:	85 d2                	test   %edx,%edx
  8009c2:	78 2c                	js     8009f0 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c4:	83 ec 08             	sub    $0x8,%esp
  8009c7:	68 00 50 80 00       	push   $0x805000
  8009cc:	53                   	push   %ebx
  8009cd:	e8 ef 0c 00 00       	call   8016c1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009dd:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e8:	83 c4 10             	add    $0x10,%esp
  8009eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    

008009f5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	57                   	push   %edi
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	83 ec 0c             	sub    $0xc,%esp
  8009fe:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	8b 40 0c             	mov    0xc(%eax),%eax
  800a07:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  800a0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a0f:	eb 3d                	jmp    800a4e <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  800a11:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  800a17:	bf f8 0f 00 00       	mov    $0xff8,%edi
  800a1c:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  800a1f:	83 ec 04             	sub    $0x4,%esp
  800a22:	57                   	push   %edi
  800a23:	53                   	push   %ebx
  800a24:	68 08 50 80 00       	push   $0x805008
  800a29:	e8 25 0e 00 00       	call   801853 <memmove>
                fsipcbuf.write.req_n = tmp; 
  800a2e:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a34:	ba 00 00 00 00       	mov    $0x0,%edx
  800a39:	b8 04 00 00 00       	mov    $0x4,%eax
  800a3e:	e8 c0 fe ff ff       	call   800903 <fsipc>
  800a43:	83 c4 10             	add    $0x10,%esp
  800a46:	85 c0                	test   %eax,%eax
  800a48:	78 0d                	js     800a57 <devfile_write+0x62>
		        return r;
                n -= tmp;
  800a4a:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  800a4c:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  800a4e:	85 f6                	test   %esi,%esi
  800a50:	75 bf                	jne    800a11 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  800a52:	89 d8                	mov    %ebx,%eax
  800a54:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  800a57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a72:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a78:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a82:	e8 7c fe ff ff       	call   800903 <fsipc>
  800a87:	89 c3                	mov    %eax,%ebx
  800a89:	85 c0                	test   %eax,%eax
  800a8b:	78 4b                	js     800ad8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a8d:	39 c6                	cmp    %eax,%esi
  800a8f:	73 16                	jae    800aa7 <devfile_read+0x48>
  800a91:	68 c4 1e 80 00       	push   $0x801ec4
  800a96:	68 cb 1e 80 00       	push   $0x801ecb
  800a9b:	6a 7c                	push   $0x7c
  800a9d:	68 e0 1e 80 00       	push   $0x801ee0
  800aa2:	e8 ba 05 00 00       	call   801061 <_panic>
	assert(r <= PGSIZE);
  800aa7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aac:	7e 16                	jle    800ac4 <devfile_read+0x65>
  800aae:	68 eb 1e 80 00       	push   $0x801eeb
  800ab3:	68 cb 1e 80 00       	push   $0x801ecb
  800ab8:	6a 7d                	push   $0x7d
  800aba:	68 e0 1e 80 00       	push   $0x801ee0
  800abf:	e8 9d 05 00 00       	call   801061 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ac4:	83 ec 04             	sub    $0x4,%esp
  800ac7:	50                   	push   %eax
  800ac8:	68 00 50 80 00       	push   $0x805000
  800acd:	ff 75 0c             	pushl  0xc(%ebp)
  800ad0:	e8 7e 0d 00 00       	call   801853 <memmove>
	return r;
  800ad5:	83 c4 10             	add    $0x10,%esp
}
  800ad8:	89 d8                	mov    %ebx,%eax
  800ada:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	53                   	push   %ebx
  800ae5:	83 ec 20             	sub    $0x20,%esp
  800ae8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aeb:	53                   	push   %ebx
  800aec:	e8 97 0b 00 00       	call   801688 <strlen>
  800af1:	83 c4 10             	add    $0x10,%esp
  800af4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af9:	7f 67                	jg     800b62 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800afb:	83 ec 0c             	sub    $0xc,%esp
  800afe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b01:	50                   	push   %eax
  800b02:	e8 74 f8 ff ff       	call   80037b <fd_alloc>
  800b07:	83 c4 10             	add    $0x10,%esp
		return r;
  800b0a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0c:	85 c0                	test   %eax,%eax
  800b0e:	78 57                	js     800b67 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b10:	83 ec 08             	sub    $0x8,%esp
  800b13:	53                   	push   %ebx
  800b14:	68 00 50 80 00       	push   $0x805000
  800b19:	e8 a3 0b 00 00       	call   8016c1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b21:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b29:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2e:	e8 d0 fd ff ff       	call   800903 <fsipc>
  800b33:	89 c3                	mov    %eax,%ebx
  800b35:	83 c4 10             	add    $0x10,%esp
  800b38:	85 c0                	test   %eax,%eax
  800b3a:	79 14                	jns    800b50 <open+0x6f>
		fd_close(fd, 0);
  800b3c:	83 ec 08             	sub    $0x8,%esp
  800b3f:	6a 00                	push   $0x0
  800b41:	ff 75 f4             	pushl  -0xc(%ebp)
  800b44:	e8 2a f9 ff ff       	call   800473 <fd_close>
		return r;
  800b49:	83 c4 10             	add    $0x10,%esp
  800b4c:	89 da                	mov    %ebx,%edx
  800b4e:	eb 17                	jmp    800b67 <open+0x86>
	}

	return fd2num(fd);
  800b50:	83 ec 0c             	sub    $0xc,%esp
  800b53:	ff 75 f4             	pushl  -0xc(%ebp)
  800b56:	e8 f9 f7 ff ff       	call   800354 <fd2num>
  800b5b:	89 c2                	mov    %eax,%edx
  800b5d:	83 c4 10             	add    $0x10,%esp
  800b60:	eb 05                	jmp    800b67 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b62:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b67:	89 d0                	mov    %edx,%eax
  800b69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b6c:	c9                   	leave  
  800b6d:	c3                   	ret    

00800b6e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
  800b79:	b8 08 00 00 00       	mov    $0x8,%eax
  800b7e:	e8 80 fd ff ff       	call   800903 <fsipc>
}
  800b83:	c9                   	leave  
  800b84:	c3                   	ret    

00800b85 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b8d:	83 ec 0c             	sub    $0xc,%esp
  800b90:	ff 75 08             	pushl  0x8(%ebp)
  800b93:	e8 cc f7 ff ff       	call   800364 <fd2data>
  800b98:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b9a:	83 c4 08             	add    $0x8,%esp
  800b9d:	68 f7 1e 80 00       	push   $0x801ef7
  800ba2:	53                   	push   %ebx
  800ba3:	e8 19 0b 00 00       	call   8016c1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba8:	8b 56 04             	mov    0x4(%esi),%edx
  800bab:	89 d0                	mov    %edx,%eax
  800bad:	2b 06                	sub    (%esi),%eax
  800baf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bbc:	00 00 00 
	stat->st_dev = &devpipe;
  800bbf:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bc6:	30 80 00 
	return 0;
}
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 0c             	sub    $0xc,%esp
  800bdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bdf:	53                   	push   %ebx
  800be0:	6a 00                	push   $0x0
  800be2:	e8 01 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800be7:	89 1c 24             	mov    %ebx,(%esp)
  800bea:	e8 75 f7 ff ff       	call   800364 <fd2data>
  800bef:	83 c4 08             	add    $0x8,%esp
  800bf2:	50                   	push   %eax
  800bf3:	6a 00                	push   $0x0
  800bf5:	e8 ee f5 ff ff       	call   8001e8 <sys_page_unmap>
}
  800bfa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 1c             	sub    $0x1c,%esp
  800c08:	89 c6                	mov    %eax,%esi
  800c0a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c0d:	a1 04 40 80 00       	mov    0x804004,%eax
  800c12:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	56                   	push   %esi
  800c19:	e8 e5 0e 00 00       	call   801b03 <pageref>
  800c1e:	89 c7                	mov    %eax,%edi
  800c20:	83 c4 04             	add    $0x4,%esp
  800c23:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c26:	e8 d8 0e 00 00       	call   801b03 <pageref>
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	39 c7                	cmp    %eax,%edi
  800c30:	0f 94 c2             	sete   %dl
  800c33:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800c36:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800c3c:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800c3f:	39 fb                	cmp    %edi,%ebx
  800c41:	74 19                	je     800c5c <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  800c43:	84 d2                	test   %dl,%dl
  800c45:	74 c6                	je     800c0d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c47:	8b 51 58             	mov    0x58(%ecx),%edx
  800c4a:	50                   	push   %eax
  800c4b:	52                   	push   %edx
  800c4c:	53                   	push   %ebx
  800c4d:	68 fe 1e 80 00       	push   $0x801efe
  800c52:	e8 e3 04 00 00       	call   80113a <cprintf>
  800c57:	83 c4 10             	add    $0x10,%esp
  800c5a:	eb b1                	jmp    800c0d <_pipeisclosed+0xe>
	}
}
  800c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 28             	sub    $0x28,%esp
  800c6d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c70:	56                   	push   %esi
  800c71:	e8 ee f6 ff ff       	call   800364 <fd2data>
  800c76:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c78:	83 c4 10             	add    $0x10,%esp
  800c7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c80:	eb 4b                	jmp    800ccd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c82:	89 da                	mov    %ebx,%edx
  800c84:	89 f0                	mov    %esi,%eax
  800c86:	e8 74 ff ff ff       	call   800bff <_pipeisclosed>
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	75 48                	jne    800cd7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c8f:	e8 b0 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c94:	8b 43 04             	mov    0x4(%ebx),%eax
  800c97:	8b 0b                	mov    (%ebx),%ecx
  800c99:	8d 51 20             	lea    0x20(%ecx),%edx
  800c9c:	39 d0                	cmp    %edx,%eax
  800c9e:	73 e2                	jae    800c82 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800caa:	89 c2                	mov    %eax,%edx
  800cac:	c1 fa 1f             	sar    $0x1f,%edx
  800caf:	89 d1                	mov    %edx,%ecx
  800cb1:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb7:	83 e2 1f             	and    $0x1f,%edx
  800cba:	29 ca                	sub    %ecx,%edx
  800cbc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cc0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc4:	83 c0 01             	add    $0x1,%eax
  800cc7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cca:	83 c7 01             	add    $0x1,%edi
  800ccd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cd0:	75 c2                	jne    800c94 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cd2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd5:	eb 05                	jmp    800cdc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 18             	sub    $0x18,%esp
  800ced:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cf0:	57                   	push   %edi
  800cf1:	e8 6e f6 ff ff       	call   800364 <fd2data>
  800cf6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf8:	83 c4 10             	add    $0x10,%esp
  800cfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d00:	eb 3d                	jmp    800d3f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d02:	85 db                	test   %ebx,%ebx
  800d04:	74 04                	je     800d0a <devpipe_read+0x26>
				return i;
  800d06:	89 d8                	mov    %ebx,%eax
  800d08:	eb 44                	jmp    800d4e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d0a:	89 f2                	mov    %esi,%edx
  800d0c:	89 f8                	mov    %edi,%eax
  800d0e:	e8 ec fe ff ff       	call   800bff <_pipeisclosed>
  800d13:	85 c0                	test   %eax,%eax
  800d15:	75 32                	jne    800d49 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d17:	e8 28 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d1c:	8b 06                	mov    (%esi),%eax
  800d1e:	3b 46 04             	cmp    0x4(%esi),%eax
  800d21:	74 df                	je     800d02 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d23:	99                   	cltd   
  800d24:	c1 ea 1b             	shr    $0x1b,%edx
  800d27:	01 d0                	add    %edx,%eax
  800d29:	83 e0 1f             	and    $0x1f,%eax
  800d2c:	29 d0                	sub    %edx,%eax
  800d2e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d36:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d39:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d3c:	83 c3 01             	add    $0x1,%ebx
  800d3f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d42:	75 d8                	jne    800d1c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d44:	8b 45 10             	mov    0x10(%ebp),%eax
  800d47:	eb 05                	jmp    800d4e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d49:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d61:	50                   	push   %eax
  800d62:	e8 14 f6 ff ff       	call   80037b <fd_alloc>
  800d67:	83 c4 10             	add    $0x10,%esp
  800d6a:	89 c2                	mov    %eax,%edx
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	0f 88 2c 01 00 00    	js     800ea0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d74:	83 ec 04             	sub    $0x4,%esp
  800d77:	68 07 04 00 00       	push   $0x407
  800d7c:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7f:	6a 00                	push   $0x0
  800d81:	e8 dd f3 ff ff       	call   800163 <sys_page_alloc>
  800d86:	83 c4 10             	add    $0x10,%esp
  800d89:	89 c2                	mov    %eax,%edx
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	0f 88 0d 01 00 00    	js     800ea0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d93:	83 ec 0c             	sub    $0xc,%esp
  800d96:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d99:	50                   	push   %eax
  800d9a:	e8 dc f5 ff ff       	call   80037b <fd_alloc>
  800d9f:	89 c3                	mov    %eax,%ebx
  800da1:	83 c4 10             	add    $0x10,%esp
  800da4:	85 c0                	test   %eax,%eax
  800da6:	0f 88 e2 00 00 00    	js     800e8e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dac:	83 ec 04             	sub    $0x4,%esp
  800daf:	68 07 04 00 00       	push   $0x407
  800db4:	ff 75 f0             	pushl  -0x10(%ebp)
  800db7:	6a 00                	push   $0x0
  800db9:	e8 a5 f3 ff ff       	call   800163 <sys_page_alloc>
  800dbe:	89 c3                	mov    %eax,%ebx
  800dc0:	83 c4 10             	add    $0x10,%esp
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	0f 88 c3 00 00 00    	js     800e8e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dcb:	83 ec 0c             	sub    $0xc,%esp
  800dce:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd1:	e8 8e f5 ff ff       	call   800364 <fd2data>
  800dd6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd8:	83 c4 0c             	add    $0xc,%esp
  800ddb:	68 07 04 00 00       	push   $0x407
  800de0:	50                   	push   %eax
  800de1:	6a 00                	push   $0x0
  800de3:	e8 7b f3 ff ff       	call   800163 <sys_page_alloc>
  800de8:	89 c3                	mov    %eax,%ebx
  800dea:	83 c4 10             	add    $0x10,%esp
  800ded:	85 c0                	test   %eax,%eax
  800def:	0f 88 89 00 00 00    	js     800e7e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df5:	83 ec 0c             	sub    $0xc,%esp
  800df8:	ff 75 f0             	pushl  -0x10(%ebp)
  800dfb:	e8 64 f5 ff ff       	call   800364 <fd2data>
  800e00:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e07:	50                   	push   %eax
  800e08:	6a 00                	push   $0x0
  800e0a:	56                   	push   %esi
  800e0b:	6a 00                	push   $0x0
  800e0d:	e8 94 f3 ff ff       	call   8001a6 <sys_page_map>
  800e12:	89 c3                	mov    %eax,%ebx
  800e14:	83 c4 20             	add    $0x20,%esp
  800e17:	85 c0                	test   %eax,%eax
  800e19:	78 55                	js     800e70 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e1b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e24:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e29:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e30:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e39:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e45:	83 ec 0c             	sub    $0xc,%esp
  800e48:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4b:	e8 04 f5 ff ff       	call   800354 <fd2num>
  800e50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e53:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e55:	83 c4 04             	add    $0x4,%esp
  800e58:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5b:	e8 f4 f4 ff ff       	call   800354 <fd2num>
  800e60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e63:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6e:	eb 30                	jmp    800ea0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e70:	83 ec 08             	sub    $0x8,%esp
  800e73:	56                   	push   %esi
  800e74:	6a 00                	push   $0x0
  800e76:	e8 6d f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e7b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e7e:	83 ec 08             	sub    $0x8,%esp
  800e81:	ff 75 f0             	pushl  -0x10(%ebp)
  800e84:	6a 00                	push   $0x0
  800e86:	e8 5d f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e8b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e8e:	83 ec 08             	sub    $0x8,%esp
  800e91:	ff 75 f4             	pushl  -0xc(%ebp)
  800e94:	6a 00                	push   $0x0
  800e96:	e8 4d f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e9b:	83 c4 10             	add    $0x10,%esp
  800e9e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ea0:	89 d0                	mov    %edx,%eax
  800ea2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb2:	50                   	push   %eax
  800eb3:	ff 75 08             	pushl  0x8(%ebp)
  800eb6:	e8 0f f5 ff ff       	call   8003ca <fd_lookup>
  800ebb:	89 c2                	mov    %eax,%edx
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	85 d2                	test   %edx,%edx
  800ec2:	78 18                	js     800edc <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ec4:	83 ec 0c             	sub    $0xc,%esp
  800ec7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eca:	e8 95 f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800ecf:	89 c2                	mov    %eax,%edx
  800ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed4:	e8 26 fd ff ff       	call   800bff <_pipeisclosed>
  800ed9:	83 c4 10             	add    $0x10,%esp
}
  800edc:	c9                   	leave  
  800edd:	c3                   	ret    

00800ede <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eee:	68 16 1f 80 00       	push   $0x801f16
  800ef3:	ff 75 0c             	pushl  0xc(%ebp)
  800ef6:	e8 c6 07 00 00       	call   8016c1 <strcpy>
	return 0;
}
  800efb:	b8 00 00 00 00       	mov    $0x0,%eax
  800f00:	c9                   	leave  
  800f01:	c3                   	ret    

00800f02 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f0e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f13:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f19:	eb 2d                	jmp    800f48 <devcons_write+0x46>
		m = n - tot;
  800f1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f20:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f23:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f28:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f2b:	83 ec 04             	sub    $0x4,%esp
  800f2e:	53                   	push   %ebx
  800f2f:	03 45 0c             	add    0xc(%ebp),%eax
  800f32:	50                   	push   %eax
  800f33:	57                   	push   %edi
  800f34:	e8 1a 09 00 00       	call   801853 <memmove>
		sys_cputs(buf, m);
  800f39:	83 c4 08             	add    $0x8,%esp
  800f3c:	53                   	push   %ebx
  800f3d:	57                   	push   %edi
  800f3e:	e8 64 f1 ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f43:	01 de                	add    %ebx,%esi
  800f45:	83 c4 10             	add    $0x10,%esp
  800f48:	89 f0                	mov    %esi,%eax
  800f4a:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f4d:	72 cc                	jb     800f1b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f52:	5b                   	pop    %ebx
  800f53:	5e                   	pop    %esi
  800f54:	5f                   	pop    %edi
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f5d:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f66:	75 07                	jne    800f6f <devcons_read+0x18>
  800f68:	eb 28                	jmp    800f92 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f6a:	e8 d5 f1 ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f6f:	e8 51 f1 ff ff       	call   8000c5 <sys_cgetc>
  800f74:	85 c0                	test   %eax,%eax
  800f76:	74 f2                	je     800f6a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	78 16                	js     800f92 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f7c:	83 f8 04             	cmp    $0x4,%eax
  800f7f:	74 0c                	je     800f8d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f81:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f84:	88 02                	mov    %al,(%edx)
	return 1;
  800f86:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8b:	eb 05                	jmp    800f92 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f8d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f92:	c9                   	leave  
  800f93:	c3                   	ret    

00800f94 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fa0:	6a 01                	push   $0x1
  800fa2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa5:	50                   	push   %eax
  800fa6:	e8 fc f0 ff ff       	call   8000a7 <sys_cputs>
  800fab:	83 c4 10             	add    $0x10,%esp
}
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <getchar>:

int
getchar(void)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fb6:	6a 01                	push   $0x1
  800fb8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbb:	50                   	push   %eax
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 71 f6 ff ff       	call   800634 <read>
	if (r < 0)
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	78 0f                	js     800fd9 <getchar+0x29>
		return r;
	if (r < 1)
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	7e 06                	jle    800fd4 <getchar+0x24>
		return -E_EOF;
	return c;
  800fce:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fd2:	eb 05                	jmp    800fd9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fd4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    

00800fdb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe4:	50                   	push   %eax
  800fe5:	ff 75 08             	pushl  0x8(%ebp)
  800fe8:	e8 dd f3 ff ff       	call   8003ca <fd_lookup>
  800fed:	83 c4 10             	add    $0x10,%esp
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	78 11                	js     801005 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ffd:	39 10                	cmp    %edx,(%eax)
  800fff:	0f 94 c0             	sete   %al
  801002:	0f b6 c0             	movzbl %al,%eax
}
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <opencons>:

int
opencons(void)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80100d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801010:	50                   	push   %eax
  801011:	e8 65 f3 ff ff       	call   80037b <fd_alloc>
  801016:	83 c4 10             	add    $0x10,%esp
		return r;
  801019:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 3e                	js     80105d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80101f:	83 ec 04             	sub    $0x4,%esp
  801022:	68 07 04 00 00       	push   $0x407
  801027:	ff 75 f4             	pushl  -0xc(%ebp)
  80102a:	6a 00                	push   $0x0
  80102c:	e8 32 f1 ff ff       	call   800163 <sys_page_alloc>
  801031:	83 c4 10             	add    $0x10,%esp
		return r;
  801034:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801036:	85 c0                	test   %eax,%eax
  801038:	78 23                	js     80105d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80103a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801040:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801043:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801045:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801048:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	50                   	push   %eax
  801053:	e8 fc f2 ff ff       	call   800354 <fd2num>
  801058:	89 c2                	mov    %eax,%edx
  80105a:	83 c4 10             	add    $0x10,%esp
}
  80105d:	89 d0                	mov    %edx,%eax
  80105f:	c9                   	leave  
  801060:	c3                   	ret    

00801061 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	56                   	push   %esi
  801065:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801066:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801069:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80106f:	e8 b1 f0 ff ff       	call   800125 <sys_getenvid>
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	ff 75 0c             	pushl  0xc(%ebp)
  80107a:	ff 75 08             	pushl  0x8(%ebp)
  80107d:	56                   	push   %esi
  80107e:	50                   	push   %eax
  80107f:	68 24 1f 80 00       	push   $0x801f24
  801084:	e8 b1 00 00 00       	call   80113a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801089:	83 c4 18             	add    $0x18,%esp
  80108c:	53                   	push   %ebx
  80108d:	ff 75 10             	pushl  0x10(%ebp)
  801090:	e8 54 00 00 00       	call   8010e9 <vcprintf>
	cprintf("\n");
  801095:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  80109c:	e8 99 00 00 00       	call   80113a <cprintf>
  8010a1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010a4:	cc                   	int3   
  8010a5:	eb fd                	jmp    8010a4 <_panic+0x43>

008010a7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	53                   	push   %ebx
  8010ab:	83 ec 04             	sub    $0x4,%esp
  8010ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010b1:	8b 13                	mov    (%ebx),%edx
  8010b3:	8d 42 01             	lea    0x1(%edx),%eax
  8010b6:	89 03                	mov    %eax,(%ebx)
  8010b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010bb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010bf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010c4:	75 1a                	jne    8010e0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010c6:	83 ec 08             	sub    $0x8,%esp
  8010c9:	68 ff 00 00 00       	push   $0xff
  8010ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8010d1:	50                   	push   %eax
  8010d2:	e8 d0 ef ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8010d7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010dd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010e0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e7:	c9                   	leave  
  8010e8:	c3                   	ret    

008010e9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010f2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010f9:	00 00 00 
	b.cnt = 0;
  8010fc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801103:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801106:	ff 75 0c             	pushl  0xc(%ebp)
  801109:	ff 75 08             	pushl  0x8(%ebp)
  80110c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801112:	50                   	push   %eax
  801113:	68 a7 10 80 00       	push   $0x8010a7
  801118:	e8 4f 01 00 00       	call   80126c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80111d:	83 c4 08             	add    $0x8,%esp
  801120:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801126:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80112c:	50                   	push   %eax
  80112d:	e8 75 ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  801132:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801138:	c9                   	leave  
  801139:	c3                   	ret    

0080113a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801140:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801143:	50                   	push   %eax
  801144:	ff 75 08             	pushl  0x8(%ebp)
  801147:	e8 9d ff ff ff       	call   8010e9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80114c:	c9                   	leave  
  80114d:	c3                   	ret    

0080114e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	57                   	push   %edi
  801152:	56                   	push   %esi
  801153:	53                   	push   %ebx
  801154:	83 ec 1c             	sub    $0x1c,%esp
  801157:	89 c7                	mov    %eax,%edi
  801159:	89 d6                	mov    %edx,%esi
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
  80115e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801161:	89 d1                	mov    %edx,%ecx
  801163:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801166:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801169:	8b 45 10             	mov    0x10(%ebp),%eax
  80116c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80116f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801172:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801179:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80117c:	72 05                	jb     801183 <printnum+0x35>
  80117e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801181:	77 3e                	ja     8011c1 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801183:	83 ec 0c             	sub    $0xc,%esp
  801186:	ff 75 18             	pushl  0x18(%ebp)
  801189:	83 eb 01             	sub    $0x1,%ebx
  80118c:	53                   	push   %ebx
  80118d:	50                   	push   %eax
  80118e:	83 ec 08             	sub    $0x8,%esp
  801191:	ff 75 e4             	pushl  -0x1c(%ebp)
  801194:	ff 75 e0             	pushl  -0x20(%ebp)
  801197:	ff 75 dc             	pushl  -0x24(%ebp)
  80119a:	ff 75 d8             	pushl  -0x28(%ebp)
  80119d:	e8 9e 09 00 00       	call   801b40 <__udivdi3>
  8011a2:	83 c4 18             	add    $0x18,%esp
  8011a5:	52                   	push   %edx
  8011a6:	50                   	push   %eax
  8011a7:	89 f2                	mov    %esi,%edx
  8011a9:	89 f8                	mov    %edi,%eax
  8011ab:	e8 9e ff ff ff       	call   80114e <printnum>
  8011b0:	83 c4 20             	add    $0x20,%esp
  8011b3:	eb 13                	jmp    8011c8 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011b5:	83 ec 08             	sub    $0x8,%esp
  8011b8:	56                   	push   %esi
  8011b9:	ff 75 18             	pushl  0x18(%ebp)
  8011bc:	ff d7                	call   *%edi
  8011be:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011c1:	83 eb 01             	sub    $0x1,%ebx
  8011c4:	85 db                	test   %ebx,%ebx
  8011c6:	7f ed                	jg     8011b5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	56                   	push   %esi
  8011cc:	83 ec 04             	sub    $0x4,%esp
  8011cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d5:	ff 75 dc             	pushl  -0x24(%ebp)
  8011d8:	ff 75 d8             	pushl  -0x28(%ebp)
  8011db:	e8 90 0a 00 00       	call   801c70 <__umoddi3>
  8011e0:	83 c4 14             	add    $0x14,%esp
  8011e3:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  8011ea:	50                   	push   %eax
  8011eb:	ff d7                	call   *%edi
  8011ed:	83 c4 10             	add    $0x10,%esp
}
  8011f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5f                   	pop    %edi
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011fb:	83 fa 01             	cmp    $0x1,%edx
  8011fe:	7e 0e                	jle    80120e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801200:	8b 10                	mov    (%eax),%edx
  801202:	8d 4a 08             	lea    0x8(%edx),%ecx
  801205:	89 08                	mov    %ecx,(%eax)
  801207:	8b 02                	mov    (%edx),%eax
  801209:	8b 52 04             	mov    0x4(%edx),%edx
  80120c:	eb 22                	jmp    801230 <getuint+0x38>
	else if (lflag)
  80120e:	85 d2                	test   %edx,%edx
  801210:	74 10                	je     801222 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801212:	8b 10                	mov    (%eax),%edx
  801214:	8d 4a 04             	lea    0x4(%edx),%ecx
  801217:	89 08                	mov    %ecx,(%eax)
  801219:	8b 02                	mov    (%edx),%eax
  80121b:	ba 00 00 00 00       	mov    $0x0,%edx
  801220:	eb 0e                	jmp    801230 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801222:	8b 10                	mov    (%eax),%edx
  801224:	8d 4a 04             	lea    0x4(%edx),%ecx
  801227:	89 08                	mov    %ecx,(%eax)
  801229:	8b 02                	mov    (%edx),%eax
  80122b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801238:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80123c:	8b 10                	mov    (%eax),%edx
  80123e:	3b 50 04             	cmp    0x4(%eax),%edx
  801241:	73 0a                	jae    80124d <sprintputch+0x1b>
		*b->buf++ = ch;
  801243:	8d 4a 01             	lea    0x1(%edx),%ecx
  801246:	89 08                	mov    %ecx,(%eax)
  801248:	8b 45 08             	mov    0x8(%ebp),%eax
  80124b:	88 02                	mov    %al,(%edx)
}
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801255:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801258:	50                   	push   %eax
  801259:	ff 75 10             	pushl  0x10(%ebp)
  80125c:	ff 75 0c             	pushl  0xc(%ebp)
  80125f:	ff 75 08             	pushl  0x8(%ebp)
  801262:	e8 05 00 00 00       	call   80126c <vprintfmt>
	va_end(ap);
  801267:	83 c4 10             	add    $0x10,%esp
}
  80126a:	c9                   	leave  
  80126b:	c3                   	ret    

0080126c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	57                   	push   %edi
  801270:	56                   	push   %esi
  801271:	53                   	push   %ebx
  801272:	83 ec 2c             	sub    $0x2c,%esp
  801275:	8b 75 08             	mov    0x8(%ebp),%esi
  801278:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80127b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80127e:	eb 12                	jmp    801292 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801280:	85 c0                	test   %eax,%eax
  801282:	0f 84 90 03 00 00    	je     801618 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  801288:	83 ec 08             	sub    $0x8,%esp
  80128b:	53                   	push   %ebx
  80128c:	50                   	push   %eax
  80128d:	ff d6                	call   *%esi
  80128f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801292:	83 c7 01             	add    $0x1,%edi
  801295:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801299:	83 f8 25             	cmp    $0x25,%eax
  80129c:	75 e2                	jne    801280 <vprintfmt+0x14>
  80129e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012a2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012a9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012b0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012bc:	eb 07                	jmp    8012c5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012be:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012c1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c5:	8d 47 01             	lea    0x1(%edi),%eax
  8012c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012cb:	0f b6 07             	movzbl (%edi),%eax
  8012ce:	0f b6 c8             	movzbl %al,%ecx
  8012d1:	83 e8 23             	sub    $0x23,%eax
  8012d4:	3c 55                	cmp    $0x55,%al
  8012d6:	0f 87 21 03 00 00    	ja     8015fd <vprintfmt+0x391>
  8012dc:	0f b6 c0             	movzbl %al,%eax
  8012df:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8012e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012e9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012ed:	eb d6                	jmp    8012c5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012fa:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012fd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801301:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801304:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801307:	83 fa 09             	cmp    $0x9,%edx
  80130a:	77 39                	ja     801345 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80130c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80130f:	eb e9                	jmp    8012fa <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801311:	8b 45 14             	mov    0x14(%ebp),%eax
  801314:	8d 48 04             	lea    0x4(%eax),%ecx
  801317:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80131a:	8b 00                	mov    (%eax),%eax
  80131c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801322:	eb 27                	jmp    80134b <vprintfmt+0xdf>
  801324:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801327:	85 c0                	test   %eax,%eax
  801329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80132e:	0f 49 c8             	cmovns %eax,%ecx
  801331:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801337:	eb 8c                	jmp    8012c5 <vprintfmt+0x59>
  801339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80133c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801343:	eb 80                	jmp    8012c5 <vprintfmt+0x59>
  801345:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801348:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80134b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80134f:	0f 89 70 ff ff ff    	jns    8012c5 <vprintfmt+0x59>
				width = precision, precision = -1;
  801355:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801358:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80135b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801362:	e9 5e ff ff ff       	jmp    8012c5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801367:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80136d:	e9 53 ff ff ff       	jmp    8012c5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801372:	8b 45 14             	mov    0x14(%ebp),%eax
  801375:	8d 50 04             	lea    0x4(%eax),%edx
  801378:	89 55 14             	mov    %edx,0x14(%ebp)
  80137b:	83 ec 08             	sub    $0x8,%esp
  80137e:	53                   	push   %ebx
  80137f:	ff 30                	pushl  (%eax)
  801381:	ff d6                	call   *%esi
			break;
  801383:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801389:	e9 04 ff ff ff       	jmp    801292 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80138e:	8b 45 14             	mov    0x14(%ebp),%eax
  801391:	8d 50 04             	lea    0x4(%eax),%edx
  801394:	89 55 14             	mov    %edx,0x14(%ebp)
  801397:	8b 00                	mov    (%eax),%eax
  801399:	99                   	cltd   
  80139a:	31 d0                	xor    %edx,%eax
  80139c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80139e:	83 f8 0f             	cmp    $0xf,%eax
  8013a1:	7f 0b                	jg     8013ae <vprintfmt+0x142>
  8013a3:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  8013aa:	85 d2                	test   %edx,%edx
  8013ac:	75 18                	jne    8013c6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013ae:	50                   	push   %eax
  8013af:	68 5f 1f 80 00       	push   $0x801f5f
  8013b4:	53                   	push   %ebx
  8013b5:	56                   	push   %esi
  8013b6:	e8 94 fe ff ff       	call   80124f <printfmt>
  8013bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013c1:	e9 cc fe ff ff       	jmp    801292 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013c6:	52                   	push   %edx
  8013c7:	68 dd 1e 80 00       	push   $0x801edd
  8013cc:	53                   	push   %ebx
  8013cd:	56                   	push   %esi
  8013ce:	e8 7c fe ff ff       	call   80124f <printfmt>
  8013d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013d9:	e9 b4 fe ff ff       	jmp    801292 <vprintfmt+0x26>
  8013de:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013e4:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ea:	8d 50 04             	lea    0x4(%eax),%edx
  8013ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8013f0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013f2:	85 ff                	test   %edi,%edi
  8013f4:	ba 58 1f 80 00       	mov    $0x801f58,%edx
  8013f9:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8013fc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801400:	0f 84 92 00 00 00    	je     801498 <vprintfmt+0x22c>
  801406:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80140a:	0f 8e 96 00 00 00    	jle    8014a6 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  801410:	83 ec 08             	sub    $0x8,%esp
  801413:	51                   	push   %ecx
  801414:	57                   	push   %edi
  801415:	e8 86 02 00 00       	call   8016a0 <strnlen>
  80141a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80141d:	29 c1                	sub    %eax,%ecx
  80141f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801422:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801425:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801429:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80142c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80142f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801431:	eb 0f                	jmp    801442 <vprintfmt+0x1d6>
					putch(padc, putdat);
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	53                   	push   %ebx
  801437:	ff 75 e0             	pushl  -0x20(%ebp)
  80143a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80143c:	83 ef 01             	sub    $0x1,%edi
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	85 ff                	test   %edi,%edi
  801444:	7f ed                	jg     801433 <vprintfmt+0x1c7>
  801446:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801449:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80144c:	85 c9                	test   %ecx,%ecx
  80144e:	b8 00 00 00 00       	mov    $0x0,%eax
  801453:	0f 49 c1             	cmovns %ecx,%eax
  801456:	29 c1                	sub    %eax,%ecx
  801458:	89 75 08             	mov    %esi,0x8(%ebp)
  80145b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80145e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801461:	89 cb                	mov    %ecx,%ebx
  801463:	eb 4d                	jmp    8014b2 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801465:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801469:	74 1b                	je     801486 <vprintfmt+0x21a>
  80146b:	0f be c0             	movsbl %al,%eax
  80146e:	83 e8 20             	sub    $0x20,%eax
  801471:	83 f8 5e             	cmp    $0x5e,%eax
  801474:	76 10                	jbe    801486 <vprintfmt+0x21a>
					putch('?', putdat);
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	ff 75 0c             	pushl  0xc(%ebp)
  80147c:	6a 3f                	push   $0x3f
  80147e:	ff 55 08             	call   *0x8(%ebp)
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	eb 0d                	jmp    801493 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  801486:	83 ec 08             	sub    $0x8,%esp
  801489:	ff 75 0c             	pushl  0xc(%ebp)
  80148c:	52                   	push   %edx
  80148d:	ff 55 08             	call   *0x8(%ebp)
  801490:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801493:	83 eb 01             	sub    $0x1,%ebx
  801496:	eb 1a                	jmp    8014b2 <vprintfmt+0x246>
  801498:	89 75 08             	mov    %esi,0x8(%ebp)
  80149b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80149e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a4:	eb 0c                	jmp    8014b2 <vprintfmt+0x246>
  8014a6:	89 75 08             	mov    %esi,0x8(%ebp)
  8014a9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014ac:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014af:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014b2:	83 c7 01             	add    $0x1,%edi
  8014b5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014b9:	0f be d0             	movsbl %al,%edx
  8014bc:	85 d2                	test   %edx,%edx
  8014be:	74 23                	je     8014e3 <vprintfmt+0x277>
  8014c0:	85 f6                	test   %esi,%esi
  8014c2:	78 a1                	js     801465 <vprintfmt+0x1f9>
  8014c4:	83 ee 01             	sub    $0x1,%esi
  8014c7:	79 9c                	jns    801465 <vprintfmt+0x1f9>
  8014c9:	89 df                	mov    %ebx,%edi
  8014cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d1:	eb 18                	jmp    8014eb <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014d3:	83 ec 08             	sub    $0x8,%esp
  8014d6:	53                   	push   %ebx
  8014d7:	6a 20                	push   $0x20
  8014d9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014db:	83 ef 01             	sub    $0x1,%edi
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	eb 08                	jmp    8014eb <vprintfmt+0x27f>
  8014e3:	89 df                	mov    %ebx,%edi
  8014e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014eb:	85 ff                	test   %edi,%edi
  8014ed:	7f e4                	jg     8014d3 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014f2:	e9 9b fd ff ff       	jmp    801292 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014f7:	83 fa 01             	cmp    $0x1,%edx
  8014fa:	7e 16                	jle    801512 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8014fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ff:	8d 50 08             	lea    0x8(%eax),%edx
  801502:	89 55 14             	mov    %edx,0x14(%ebp)
  801505:	8b 50 04             	mov    0x4(%eax),%edx
  801508:	8b 00                	mov    (%eax),%eax
  80150a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801510:	eb 32                	jmp    801544 <vprintfmt+0x2d8>
	else if (lflag)
  801512:	85 d2                	test   %edx,%edx
  801514:	74 18                	je     80152e <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  801516:	8b 45 14             	mov    0x14(%ebp),%eax
  801519:	8d 50 04             	lea    0x4(%eax),%edx
  80151c:	89 55 14             	mov    %edx,0x14(%ebp)
  80151f:	8b 00                	mov    (%eax),%eax
  801521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801524:	89 c1                	mov    %eax,%ecx
  801526:	c1 f9 1f             	sar    $0x1f,%ecx
  801529:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80152c:	eb 16                	jmp    801544 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80152e:	8b 45 14             	mov    0x14(%ebp),%eax
  801531:	8d 50 04             	lea    0x4(%eax),%edx
  801534:	89 55 14             	mov    %edx,0x14(%ebp)
  801537:	8b 00                	mov    (%eax),%eax
  801539:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153c:	89 c1                	mov    %eax,%ecx
  80153e:	c1 f9 1f             	sar    $0x1f,%ecx
  801541:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801544:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801547:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80154a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80154f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801553:	79 74                	jns    8015c9 <vprintfmt+0x35d>
				putch('-', putdat);
  801555:	83 ec 08             	sub    $0x8,%esp
  801558:	53                   	push   %ebx
  801559:	6a 2d                	push   $0x2d
  80155b:	ff d6                	call   *%esi
				num = -(long long) num;
  80155d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801560:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801563:	f7 d8                	neg    %eax
  801565:	83 d2 00             	adc    $0x0,%edx
  801568:	f7 da                	neg    %edx
  80156a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80156d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801572:	eb 55                	jmp    8015c9 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801574:	8d 45 14             	lea    0x14(%ebp),%eax
  801577:	e8 7c fc ff ff       	call   8011f8 <getuint>
			base = 10;
  80157c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801581:	eb 46                	jmp    8015c9 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801583:	8d 45 14             	lea    0x14(%ebp),%eax
  801586:	e8 6d fc ff ff       	call   8011f8 <getuint>
                        base = 8;
  80158b:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801590:	eb 37                	jmp    8015c9 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  801592:	83 ec 08             	sub    $0x8,%esp
  801595:	53                   	push   %ebx
  801596:	6a 30                	push   $0x30
  801598:	ff d6                	call   *%esi
			putch('x', putdat);
  80159a:	83 c4 08             	add    $0x8,%esp
  80159d:	53                   	push   %ebx
  80159e:	6a 78                	push   $0x78
  8015a0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a5:	8d 50 04             	lea    0x4(%eax),%edx
  8015a8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015ab:	8b 00                	mov    (%eax),%eax
  8015ad:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015b2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015b5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015ba:	eb 0d                	jmp    8015c9 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8015bf:	e8 34 fc ff ff       	call   8011f8 <getuint>
			base = 16;
  8015c4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015c9:	83 ec 0c             	sub    $0xc,%esp
  8015cc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015d0:	57                   	push   %edi
  8015d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d4:	51                   	push   %ecx
  8015d5:	52                   	push   %edx
  8015d6:	50                   	push   %eax
  8015d7:	89 da                	mov    %ebx,%edx
  8015d9:	89 f0                	mov    %esi,%eax
  8015db:	e8 6e fb ff ff       	call   80114e <printnum>
			break;
  8015e0:	83 c4 20             	add    $0x20,%esp
  8015e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015e6:	e9 a7 fc ff ff       	jmp    801292 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	53                   	push   %ebx
  8015ef:	51                   	push   %ecx
  8015f0:	ff d6                	call   *%esi
			break;
  8015f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015f8:	e9 95 fc ff ff       	jmp    801292 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	53                   	push   %ebx
  801601:	6a 25                	push   $0x25
  801603:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	eb 03                	jmp    80160d <vprintfmt+0x3a1>
  80160a:	83 ef 01             	sub    $0x1,%edi
  80160d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801611:	75 f7                	jne    80160a <vprintfmt+0x39e>
  801613:	e9 7a fc ff ff       	jmp    801292 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801618:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5f                   	pop    %edi
  80161e:	5d                   	pop    %ebp
  80161f:	c3                   	ret    

00801620 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	83 ec 18             	sub    $0x18,%esp
  801626:	8b 45 08             	mov    0x8(%ebp),%eax
  801629:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80162c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80162f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801633:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801636:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80163d:	85 c0                	test   %eax,%eax
  80163f:	74 26                	je     801667 <vsnprintf+0x47>
  801641:	85 d2                	test   %edx,%edx
  801643:	7e 22                	jle    801667 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801645:	ff 75 14             	pushl  0x14(%ebp)
  801648:	ff 75 10             	pushl  0x10(%ebp)
  80164b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	68 32 12 80 00       	push   $0x801232
  801654:	e8 13 fc ff ff       	call   80126c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801659:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80165c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80165f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	eb 05                	jmp    80166c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801667:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801674:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801677:	50                   	push   %eax
  801678:	ff 75 10             	pushl  0x10(%ebp)
  80167b:	ff 75 0c             	pushl  0xc(%ebp)
  80167e:	ff 75 08             	pushl  0x8(%ebp)
  801681:	e8 9a ff ff ff       	call   801620 <vsnprintf>
	va_end(ap);

	return rc;
}
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80168e:	b8 00 00 00 00       	mov    $0x0,%eax
  801693:	eb 03                	jmp    801698 <strlen+0x10>
		n++;
  801695:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801698:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80169c:	75 f7                	jne    801695 <strlen+0xd>
		n++;
	return n;
}
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ae:	eb 03                	jmp    8016b3 <strnlen+0x13>
		n++;
  8016b0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b3:	39 c2                	cmp    %eax,%edx
  8016b5:	74 08                	je     8016bf <strnlen+0x1f>
  8016b7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016bb:	75 f3                	jne    8016b0 <strnlen+0x10>
  8016bd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    

008016c1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	53                   	push   %ebx
  8016c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016cb:	89 c2                	mov    %eax,%edx
  8016cd:	83 c2 01             	add    $0x1,%edx
  8016d0:	83 c1 01             	add    $0x1,%ecx
  8016d3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016d7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016da:	84 db                	test   %bl,%bl
  8016dc:	75 ef                	jne    8016cd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016de:	5b                   	pop    %ebx
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	53                   	push   %ebx
  8016e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016e8:	53                   	push   %ebx
  8016e9:	e8 9a ff ff ff       	call   801688 <strlen>
  8016ee:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016f1:	ff 75 0c             	pushl  0xc(%ebp)
  8016f4:	01 d8                	add    %ebx,%eax
  8016f6:	50                   	push   %eax
  8016f7:	e8 c5 ff ff ff       	call   8016c1 <strcpy>
	return dst;
}
  8016fc:	89 d8                	mov    %ebx,%eax
  8016fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	56                   	push   %esi
  801707:	53                   	push   %ebx
  801708:	8b 75 08             	mov    0x8(%ebp),%esi
  80170b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170e:	89 f3                	mov    %esi,%ebx
  801710:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801713:	89 f2                	mov    %esi,%edx
  801715:	eb 0f                	jmp    801726 <strncpy+0x23>
		*dst++ = *src;
  801717:	83 c2 01             	add    $0x1,%edx
  80171a:	0f b6 01             	movzbl (%ecx),%eax
  80171d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801720:	80 39 01             	cmpb   $0x1,(%ecx)
  801723:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801726:	39 da                	cmp    %ebx,%edx
  801728:	75 ed                	jne    801717 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80172a:	89 f0                	mov    %esi,%eax
  80172c:	5b                   	pop    %ebx
  80172d:	5e                   	pop    %esi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	56                   	push   %esi
  801734:	53                   	push   %ebx
  801735:	8b 75 08             	mov    0x8(%ebp),%esi
  801738:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173b:	8b 55 10             	mov    0x10(%ebp),%edx
  80173e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801740:	85 d2                	test   %edx,%edx
  801742:	74 21                	je     801765 <strlcpy+0x35>
  801744:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801748:	89 f2                	mov    %esi,%edx
  80174a:	eb 09                	jmp    801755 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80174c:	83 c2 01             	add    $0x1,%edx
  80174f:	83 c1 01             	add    $0x1,%ecx
  801752:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801755:	39 c2                	cmp    %eax,%edx
  801757:	74 09                	je     801762 <strlcpy+0x32>
  801759:	0f b6 19             	movzbl (%ecx),%ebx
  80175c:	84 db                	test   %bl,%bl
  80175e:	75 ec                	jne    80174c <strlcpy+0x1c>
  801760:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801762:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801765:	29 f0                	sub    %esi,%eax
}
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801771:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801774:	eb 06                	jmp    80177c <strcmp+0x11>
		p++, q++;
  801776:	83 c1 01             	add    $0x1,%ecx
  801779:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80177c:	0f b6 01             	movzbl (%ecx),%eax
  80177f:	84 c0                	test   %al,%al
  801781:	74 04                	je     801787 <strcmp+0x1c>
  801783:	3a 02                	cmp    (%edx),%al
  801785:	74 ef                	je     801776 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801787:	0f b6 c0             	movzbl %al,%eax
  80178a:	0f b6 12             	movzbl (%edx),%edx
  80178d:	29 d0                	sub    %edx,%eax
}
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	53                   	push   %ebx
  801795:	8b 45 08             	mov    0x8(%ebp),%eax
  801798:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179b:	89 c3                	mov    %eax,%ebx
  80179d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017a0:	eb 06                	jmp    8017a8 <strncmp+0x17>
		n--, p++, q++;
  8017a2:	83 c0 01             	add    $0x1,%eax
  8017a5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a8:	39 d8                	cmp    %ebx,%eax
  8017aa:	74 15                	je     8017c1 <strncmp+0x30>
  8017ac:	0f b6 08             	movzbl (%eax),%ecx
  8017af:	84 c9                	test   %cl,%cl
  8017b1:	74 04                	je     8017b7 <strncmp+0x26>
  8017b3:	3a 0a                	cmp    (%edx),%cl
  8017b5:	74 eb                	je     8017a2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b7:	0f b6 00             	movzbl (%eax),%eax
  8017ba:	0f b6 12             	movzbl (%edx),%edx
  8017bd:	29 d0                	sub    %edx,%eax
  8017bf:	eb 05                	jmp    8017c6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017c1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017c6:	5b                   	pop    %ebx
  8017c7:	5d                   	pop    %ebp
  8017c8:	c3                   	ret    

008017c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017d3:	eb 07                	jmp    8017dc <strchr+0x13>
		if (*s == c)
  8017d5:	38 ca                	cmp    %cl,%dl
  8017d7:	74 0f                	je     8017e8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017d9:	83 c0 01             	add    $0x1,%eax
  8017dc:	0f b6 10             	movzbl (%eax),%edx
  8017df:	84 d2                	test   %dl,%dl
  8017e1:	75 f2                	jne    8017d5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f4:	eb 03                	jmp    8017f9 <strfind+0xf>
  8017f6:	83 c0 01             	add    $0x1,%eax
  8017f9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017fc:	84 d2                	test   %dl,%dl
  8017fe:	74 04                	je     801804 <strfind+0x1a>
  801800:	38 ca                	cmp    %cl,%dl
  801802:	75 f2                	jne    8017f6 <strfind+0xc>
			break;
	return (char *) s;
}
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    

00801806 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	57                   	push   %edi
  80180a:	56                   	push   %esi
  80180b:	53                   	push   %ebx
  80180c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80180f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801812:	85 c9                	test   %ecx,%ecx
  801814:	74 36                	je     80184c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801816:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80181c:	75 28                	jne    801846 <memset+0x40>
  80181e:	f6 c1 03             	test   $0x3,%cl
  801821:	75 23                	jne    801846 <memset+0x40>
		c &= 0xFF;
  801823:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801827:	89 d3                	mov    %edx,%ebx
  801829:	c1 e3 08             	shl    $0x8,%ebx
  80182c:	89 d6                	mov    %edx,%esi
  80182e:	c1 e6 18             	shl    $0x18,%esi
  801831:	89 d0                	mov    %edx,%eax
  801833:	c1 e0 10             	shl    $0x10,%eax
  801836:	09 f0                	or     %esi,%eax
  801838:	09 c2                	or     %eax,%edx
  80183a:	89 d0                	mov    %edx,%eax
  80183c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80183e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801841:	fc                   	cld    
  801842:	f3 ab                	rep stos %eax,%es:(%edi)
  801844:	eb 06                	jmp    80184c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801846:	8b 45 0c             	mov    0xc(%ebp),%eax
  801849:	fc                   	cld    
  80184a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80184c:	89 f8                	mov    %edi,%eax
  80184e:	5b                   	pop    %ebx
  80184f:	5e                   	pop    %esi
  801850:	5f                   	pop    %edi
  801851:	5d                   	pop    %ebp
  801852:	c3                   	ret    

00801853 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	57                   	push   %edi
  801857:	56                   	push   %esi
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80185e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801861:	39 c6                	cmp    %eax,%esi
  801863:	73 35                	jae    80189a <memmove+0x47>
  801865:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801868:	39 d0                	cmp    %edx,%eax
  80186a:	73 2e                	jae    80189a <memmove+0x47>
		s += n;
		d += n;
  80186c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80186f:	89 d6                	mov    %edx,%esi
  801871:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801873:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801879:	75 13                	jne    80188e <memmove+0x3b>
  80187b:	f6 c1 03             	test   $0x3,%cl
  80187e:	75 0e                	jne    80188e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801880:	83 ef 04             	sub    $0x4,%edi
  801883:	8d 72 fc             	lea    -0x4(%edx),%esi
  801886:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801889:	fd                   	std    
  80188a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80188c:	eb 09                	jmp    801897 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80188e:	83 ef 01             	sub    $0x1,%edi
  801891:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801894:	fd                   	std    
  801895:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801897:	fc                   	cld    
  801898:	eb 1d                	jmp    8018b7 <memmove+0x64>
  80189a:	89 f2                	mov    %esi,%edx
  80189c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80189e:	f6 c2 03             	test   $0x3,%dl
  8018a1:	75 0f                	jne    8018b2 <memmove+0x5f>
  8018a3:	f6 c1 03             	test   $0x3,%cl
  8018a6:	75 0a                	jne    8018b2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018a8:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018ab:	89 c7                	mov    %eax,%edi
  8018ad:	fc                   	cld    
  8018ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b0:	eb 05                	jmp    8018b7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018b2:	89 c7                	mov    %eax,%edi
  8018b4:	fc                   	cld    
  8018b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018b7:	5e                   	pop    %esi
  8018b8:	5f                   	pop    %edi
  8018b9:	5d                   	pop    %ebp
  8018ba:	c3                   	ret    

008018bb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018be:	ff 75 10             	pushl  0x10(%ebp)
  8018c1:	ff 75 0c             	pushl  0xc(%ebp)
  8018c4:	ff 75 08             	pushl  0x8(%ebp)
  8018c7:	e8 87 ff ff ff       	call   801853 <memmove>
}
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	56                   	push   %esi
  8018d2:	53                   	push   %ebx
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d9:	89 c6                	mov    %eax,%esi
  8018db:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018de:	eb 1a                	jmp    8018fa <memcmp+0x2c>
		if (*s1 != *s2)
  8018e0:	0f b6 08             	movzbl (%eax),%ecx
  8018e3:	0f b6 1a             	movzbl (%edx),%ebx
  8018e6:	38 d9                	cmp    %bl,%cl
  8018e8:	74 0a                	je     8018f4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018ea:	0f b6 c1             	movzbl %cl,%eax
  8018ed:	0f b6 db             	movzbl %bl,%ebx
  8018f0:	29 d8                	sub    %ebx,%eax
  8018f2:	eb 0f                	jmp    801903 <memcmp+0x35>
		s1++, s2++;
  8018f4:	83 c0 01             	add    $0x1,%eax
  8018f7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018fa:	39 f0                	cmp    %esi,%eax
  8018fc:	75 e2                	jne    8018e0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801903:	5b                   	pop    %ebx
  801904:	5e                   	pop    %esi
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    

00801907 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	8b 45 08             	mov    0x8(%ebp),%eax
  80190d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801910:	89 c2                	mov    %eax,%edx
  801912:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801915:	eb 07                	jmp    80191e <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801917:	38 08                	cmp    %cl,(%eax)
  801919:	74 07                	je     801922 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80191b:	83 c0 01             	add    $0x1,%eax
  80191e:	39 d0                	cmp    %edx,%eax
  801920:	72 f5                	jb     801917 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801922:	5d                   	pop    %ebp
  801923:	c3                   	ret    

00801924 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	57                   	push   %edi
  801928:	56                   	push   %esi
  801929:	53                   	push   %ebx
  80192a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80192d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801930:	eb 03                	jmp    801935 <strtol+0x11>
		s++;
  801932:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801935:	0f b6 01             	movzbl (%ecx),%eax
  801938:	3c 09                	cmp    $0x9,%al
  80193a:	74 f6                	je     801932 <strtol+0xe>
  80193c:	3c 20                	cmp    $0x20,%al
  80193e:	74 f2                	je     801932 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801940:	3c 2b                	cmp    $0x2b,%al
  801942:	75 0a                	jne    80194e <strtol+0x2a>
		s++;
  801944:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801947:	bf 00 00 00 00       	mov    $0x0,%edi
  80194c:	eb 10                	jmp    80195e <strtol+0x3a>
  80194e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801953:	3c 2d                	cmp    $0x2d,%al
  801955:	75 07                	jne    80195e <strtol+0x3a>
		s++, neg = 1;
  801957:	8d 49 01             	lea    0x1(%ecx),%ecx
  80195a:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80195e:	85 db                	test   %ebx,%ebx
  801960:	0f 94 c0             	sete   %al
  801963:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801969:	75 19                	jne    801984 <strtol+0x60>
  80196b:	80 39 30             	cmpb   $0x30,(%ecx)
  80196e:	75 14                	jne    801984 <strtol+0x60>
  801970:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801974:	0f 85 82 00 00 00    	jne    8019fc <strtol+0xd8>
		s += 2, base = 16;
  80197a:	83 c1 02             	add    $0x2,%ecx
  80197d:	bb 10 00 00 00       	mov    $0x10,%ebx
  801982:	eb 16                	jmp    80199a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801984:	84 c0                	test   %al,%al
  801986:	74 12                	je     80199a <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801988:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80198d:	80 39 30             	cmpb   $0x30,(%ecx)
  801990:	75 08                	jne    80199a <strtol+0x76>
		s++, base = 8;
  801992:	83 c1 01             	add    $0x1,%ecx
  801995:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80199a:	b8 00 00 00 00       	mov    $0x0,%eax
  80199f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019a2:	0f b6 11             	movzbl (%ecx),%edx
  8019a5:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019a8:	89 f3                	mov    %esi,%ebx
  8019aa:	80 fb 09             	cmp    $0x9,%bl
  8019ad:	77 08                	ja     8019b7 <strtol+0x93>
			dig = *s - '0';
  8019af:	0f be d2             	movsbl %dl,%edx
  8019b2:	83 ea 30             	sub    $0x30,%edx
  8019b5:	eb 22                	jmp    8019d9 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019b7:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019ba:	89 f3                	mov    %esi,%ebx
  8019bc:	80 fb 19             	cmp    $0x19,%bl
  8019bf:	77 08                	ja     8019c9 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019c1:	0f be d2             	movsbl %dl,%edx
  8019c4:	83 ea 57             	sub    $0x57,%edx
  8019c7:	eb 10                	jmp    8019d9 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019c9:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019cc:	89 f3                	mov    %esi,%ebx
  8019ce:	80 fb 19             	cmp    $0x19,%bl
  8019d1:	77 16                	ja     8019e9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019d3:	0f be d2             	movsbl %dl,%edx
  8019d6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019d9:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019dc:	7d 0f                	jge    8019ed <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019de:	83 c1 01             	add    $0x1,%ecx
  8019e1:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019e5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019e7:	eb b9                	jmp    8019a2 <strtol+0x7e>
  8019e9:	89 c2                	mov    %eax,%edx
  8019eb:	eb 02                	jmp    8019ef <strtol+0xcb>
  8019ed:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019f3:	74 0d                	je     801a02 <strtol+0xde>
		*endptr = (char *) s;
  8019f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019f8:	89 0e                	mov    %ecx,(%esi)
  8019fa:	eb 06                	jmp    801a02 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019fc:	84 c0                	test   %al,%al
  8019fe:	75 92                	jne    801992 <strtol+0x6e>
  801a00:	eb 98                	jmp    80199a <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a02:	f7 da                	neg    %edx
  801a04:	85 ff                	test   %edi,%edi
  801a06:	0f 45 c2             	cmovne %edx,%eax
}
  801a09:	5b                   	pop    %ebx
  801a0a:	5e                   	pop    %esi
  801a0b:	5f                   	pop    %edi
  801a0c:	5d                   	pop    %ebp
  801a0d:	c3                   	ret    

00801a0e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	56                   	push   %esi
  801a12:	53                   	push   %ebx
  801a13:	8b 75 08             	mov    0x8(%ebp),%esi
  801a16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a23:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801a26:	83 ec 0c             	sub    $0xc,%esp
  801a29:	50                   	push   %eax
  801a2a:	e8 e4 e8 ff ff       	call   800313 <sys_ipc_recv>
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	85 c0                	test   %eax,%eax
  801a34:	79 16                	jns    801a4c <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801a36:	85 f6                	test   %esi,%esi
  801a38:	74 06                	je     801a40 <ipc_recv+0x32>
  801a3a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801a40:	85 db                	test   %ebx,%ebx
  801a42:	74 2c                	je     801a70 <ipc_recv+0x62>
  801a44:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a4a:	eb 24                	jmp    801a70 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a4c:	85 f6                	test   %esi,%esi
  801a4e:	74 0a                	je     801a5a <ipc_recv+0x4c>
  801a50:	a1 04 40 80 00       	mov    0x804004,%eax
  801a55:	8b 40 74             	mov    0x74(%eax),%eax
  801a58:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801a5a:	85 db                	test   %ebx,%ebx
  801a5c:	74 0a                	je     801a68 <ipc_recv+0x5a>
  801a5e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a63:	8b 40 78             	mov    0x78(%eax),%eax
  801a66:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801a68:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a73:	5b                   	pop    %ebx
  801a74:	5e                   	pop    %esi
  801a75:	5d                   	pop    %ebp
  801a76:	c3                   	ret    

00801a77 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	57                   	push   %edi
  801a7b:	56                   	push   %esi
  801a7c:	53                   	push   %ebx
  801a7d:	83 ec 0c             	sub    $0xc,%esp
  801a80:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a83:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801a89:	85 db                	test   %ebx,%ebx
  801a8b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a90:	0f 44 d8             	cmove  %eax,%ebx
  801a93:	eb 1c                	jmp    801ab1 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801a95:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a98:	74 12                	je     801aac <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801a9a:	50                   	push   %eax
  801a9b:	68 60 22 80 00       	push   $0x802260
  801aa0:	6a 39                	push   $0x39
  801aa2:	68 7b 22 80 00       	push   $0x80227b
  801aa7:	e8 b5 f5 ff ff       	call   801061 <_panic>
                 sys_yield();
  801aac:	e8 93 e6 ff ff       	call   800144 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ab1:	ff 75 14             	pushl  0x14(%ebp)
  801ab4:	53                   	push   %ebx
  801ab5:	56                   	push   %esi
  801ab6:	57                   	push   %edi
  801ab7:	e8 34 e8 ff ff       	call   8002f0 <sys_ipc_try_send>
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	78 d2                	js     801a95 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801ac3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5f                   	pop    %edi
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    

00801acb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ad1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ad6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ad9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801adf:	8b 52 50             	mov    0x50(%edx),%edx
  801ae2:	39 ca                	cmp    %ecx,%edx
  801ae4:	75 0d                	jne    801af3 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ae6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ae9:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801aee:	8b 40 08             	mov    0x8(%eax),%eax
  801af1:	eb 0e                	jmp    801b01 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af3:	83 c0 01             	add    $0x1,%eax
  801af6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801afb:	75 d9                	jne    801ad6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801afd:	66 b8 00 00          	mov    $0x0,%ax
}
  801b01:	5d                   	pop    %ebp
  801b02:	c3                   	ret    

00801b03 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b09:	89 d0                	mov    %edx,%eax
  801b0b:	c1 e8 16             	shr    $0x16,%eax
  801b0e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b15:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1a:	f6 c1 01             	test   $0x1,%cl
  801b1d:	74 1d                	je     801b3c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b1f:	c1 ea 0c             	shr    $0xc,%edx
  801b22:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b29:	f6 c2 01             	test   $0x1,%dl
  801b2c:	74 0e                	je     801b3c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b2e:	c1 ea 0c             	shr    $0xc,%edx
  801b31:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b38:	ef 
  801b39:	0f b7 c0             	movzwl %ax,%eax
}
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    
  801b3e:	66 90                	xchg   %ax,%ax

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
