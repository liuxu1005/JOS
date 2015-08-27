
obj/user/softint:     file format elf32-i386


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
  800045:	e8 c9 00 00 00       	call   800113 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800052:	c1 e0 05             	shl    $0x5,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x30>
		binaryname = argv[0];
  800063:	8b 06                	mov    (%esi),%eax
  800065:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	56                   	push   %esi
  80006e:	53                   	push   %ebx
  80006f:	e8 bf ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800074:	e8 0a 00 00 00       	call   800083 <exit>
  800079:	83 c4 10             	add    $0x10,%esp
}
  80007c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007f:	5b                   	pop    %ebx
  800080:	5e                   	pop    %esi
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800089:	6a 00                	push   $0x0
  80008b:	e8 42 00 00 00       	call   8000d2 <sys_env_destroy>
  800090:	83 c4 10             	add    $0x10,%esp
}
  800093:	c9                   	leave  
  800094:	c3                   	ret    

00800095 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	57                   	push   %edi
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	89 c7                	mov    %eax,%edi
  8000aa:	89 c6                	mov    %eax,%esi
  8000ac:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ae:	5b                   	pop    %ebx
  8000af:	5e                   	pop    %esi
  8000b0:	5f                   	pop    %edi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	57                   	push   %edi
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000be:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c3:	89 d1                	mov    %edx,%ecx
  8000c5:	89 d3                	mov    %edx,%ebx
  8000c7:	89 d7                	mov    %edx,%edi
  8000c9:	89 d6                	mov    %edx,%esi
  8000cb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e8:	89 cb                	mov    %ecx,%ebx
  8000ea:	89 cf                	mov    %ecx,%edi
  8000ec:	89 ce                	mov    %ecx,%esi
  8000ee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	7e 17                	jle    80010b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f4:	83 ec 0c             	sub    $0xc,%esp
  8000f7:	50                   	push   %eax
  8000f8:	6a 03                	push   $0x3
  8000fa:	68 aa 0d 80 00       	push   $0x800daa
  8000ff:	6a 23                	push   $0x23
  800101:	68 c7 0d 80 00       	push   $0x800dc7
  800106:	e8 27 00 00 00       	call   800132 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800119:	ba 00 00 00 00       	mov    $0x0,%edx
  80011e:	b8 02 00 00 00       	mov    $0x2,%eax
  800123:	89 d1                	mov    %edx,%ecx
  800125:	89 d3                	mov    %edx,%ebx
  800127:	89 d7                	mov    %edx,%edi
  800129:	89 d6                	mov    %edx,%esi
  80012b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800137:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800140:	e8 ce ff ff ff       	call   800113 <sys_getenvid>
  800145:	83 ec 0c             	sub    $0xc,%esp
  800148:	ff 75 0c             	pushl  0xc(%ebp)
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	56                   	push   %esi
  80014f:	50                   	push   %eax
  800150:	68 d8 0d 80 00       	push   $0x800dd8
  800155:	e8 b1 00 00 00       	call   80020b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015a:	83 c4 18             	add    $0x18,%esp
  80015d:	53                   	push   %ebx
  80015e:	ff 75 10             	pushl  0x10(%ebp)
  800161:	e8 54 00 00 00       	call   8001ba <vcprintf>
	cprintf("\n");
  800166:	c7 04 24 fc 0d 80 00 	movl   $0x800dfc,(%esp)
  80016d:	e8 99 00 00 00       	call   80020b <cprintf>
  800172:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800175:	cc                   	int3   
  800176:	eb fd                	jmp    800175 <_panic+0x43>

00800178 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	53                   	push   %ebx
  80017c:	83 ec 04             	sub    $0x4,%esp
  80017f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800182:	8b 13                	mov    (%ebx),%edx
  800184:	8d 42 01             	lea    0x1(%edx),%eax
  800187:	89 03                	mov    %eax,(%ebx)
  800189:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800190:	3d ff 00 00 00       	cmp    $0xff,%eax
  800195:	75 1a                	jne    8001b1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800197:	83 ec 08             	sub    $0x8,%esp
  80019a:	68 ff 00 00 00       	push   $0xff
  80019f:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a2:	50                   	push   %eax
  8001a3:	e8 ed fe ff ff       	call   800095 <sys_cputs>
		b->idx = 0;
  8001a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ae:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ca:	00 00 00 
	b.cnt = 0;
  8001cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d7:	ff 75 0c             	pushl  0xc(%ebp)
  8001da:	ff 75 08             	pushl  0x8(%ebp)
  8001dd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	68 78 01 80 00       	push   $0x800178
  8001e9:	e8 4f 01 00 00       	call   80033d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ee:	83 c4 08             	add    $0x8,%esp
  8001f1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fd:	50                   	push   %eax
  8001fe:	e8 92 fe ff ff       	call   800095 <sys_cputs>

	return b.cnt;
}
  800203:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800211:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800214:	50                   	push   %eax
  800215:	ff 75 08             	pushl  0x8(%ebp)
  800218:	e8 9d ff ff ff       	call   8001ba <vcprintf>
	va_end(ap);

	return cnt;
}
  80021d:	c9                   	leave  
  80021e:	c3                   	ret    

0080021f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	57                   	push   %edi
  800223:	56                   	push   %esi
  800224:	53                   	push   %ebx
  800225:	83 ec 1c             	sub    $0x1c,%esp
  800228:	89 c7                	mov    %eax,%edi
  80022a:	89 d6                	mov    %edx,%esi
  80022c:	8b 45 08             	mov    0x8(%ebp),%eax
  80022f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800232:	89 d1                	mov    %edx,%ecx
  800234:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800237:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023a:	8b 45 10             	mov    0x10(%ebp),%eax
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800243:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80024a:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80024d:	72 05                	jb     800254 <printnum+0x35>
  80024f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800252:	77 3e                	ja     800292 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	ff 75 18             	pushl  0x18(%ebp)
  80025a:	83 eb 01             	sub    $0x1,%ebx
  80025d:	53                   	push   %ebx
  80025e:	50                   	push   %eax
  80025f:	83 ec 08             	sub    $0x8,%esp
  800262:	ff 75 e4             	pushl  -0x1c(%ebp)
  800265:	ff 75 e0             	pushl  -0x20(%ebp)
  800268:	ff 75 dc             	pushl  -0x24(%ebp)
  80026b:	ff 75 d8             	pushl  -0x28(%ebp)
  80026e:	e8 6d 08 00 00       	call   800ae0 <__udivdi3>
  800273:	83 c4 18             	add    $0x18,%esp
  800276:	52                   	push   %edx
  800277:	50                   	push   %eax
  800278:	89 f2                	mov    %esi,%edx
  80027a:	89 f8                	mov    %edi,%eax
  80027c:	e8 9e ff ff ff       	call   80021f <printnum>
  800281:	83 c4 20             	add    $0x20,%esp
  800284:	eb 13                	jmp    800299 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	56                   	push   %esi
  80028a:	ff 75 18             	pushl  0x18(%ebp)
  80028d:	ff d7                	call   *%edi
  80028f:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800292:	83 eb 01             	sub    $0x1,%ebx
  800295:	85 db                	test   %ebx,%ebx
  800297:	7f ed                	jg     800286 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	83 ec 04             	sub    $0x4,%esp
  8002a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ac:	e8 5f 09 00 00       	call   800c10 <__umoddi3>
  8002b1:	83 c4 14             	add    $0x14,%esp
  8002b4:	0f be 80 fe 0d 80 00 	movsbl 0x800dfe(%eax),%eax
  8002bb:	50                   	push   %eax
  8002bc:	ff d7                	call   *%edi
  8002be:	83 c4 10             	add    $0x10,%esp
}
  8002c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cc:	83 fa 01             	cmp    $0x1,%edx
  8002cf:	7e 0e                	jle    8002df <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d1:	8b 10                	mov    (%eax),%edx
  8002d3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d6:	89 08                	mov    %ecx,(%eax)
  8002d8:	8b 02                	mov    (%edx),%eax
  8002da:	8b 52 04             	mov    0x4(%edx),%edx
  8002dd:	eb 22                	jmp    800301 <getuint+0x38>
	else if (lflag)
  8002df:	85 d2                	test   %edx,%edx
  8002e1:	74 10                	je     8002f3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e8:	89 08                	mov    %ecx,(%eax)
  8002ea:	8b 02                	mov    (%edx),%eax
  8002ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f1:	eb 0e                	jmp    800301 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f3:	8b 10                	mov    (%eax),%edx
  8002f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f8:	89 08                	mov    %ecx,(%eax)
  8002fa:	8b 02                	mov    (%edx),%eax
  8002fc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800309:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030d:	8b 10                	mov    (%eax),%edx
  80030f:	3b 50 04             	cmp    0x4(%eax),%edx
  800312:	73 0a                	jae    80031e <sprintputch+0x1b>
		*b->buf++ = ch;
  800314:	8d 4a 01             	lea    0x1(%edx),%ecx
  800317:	89 08                	mov    %ecx,(%eax)
  800319:	8b 45 08             	mov    0x8(%ebp),%eax
  80031c:	88 02                	mov    %al,(%edx)
}
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800326:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800329:	50                   	push   %eax
  80032a:	ff 75 10             	pushl  0x10(%ebp)
  80032d:	ff 75 0c             	pushl  0xc(%ebp)
  800330:	ff 75 08             	pushl  0x8(%ebp)
  800333:	e8 05 00 00 00       	call   80033d <vprintfmt>
	va_end(ap);
  800338:	83 c4 10             	add    $0x10,%esp
}
  80033b:	c9                   	leave  
  80033c:	c3                   	ret    

0080033d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 2c             	sub    $0x2c,%esp
  800346:	8b 75 08             	mov    0x8(%ebp),%esi
  800349:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034f:	eb 12                	jmp    800363 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800351:	85 c0                	test   %eax,%eax
  800353:	0f 84 90 03 00 00    	je     8006e9 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800359:	83 ec 08             	sub    $0x8,%esp
  80035c:	53                   	push   %ebx
  80035d:	50                   	push   %eax
  80035e:	ff d6                	call   *%esi
  800360:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800363:	83 c7 01             	add    $0x1,%edi
  800366:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80036a:	83 f8 25             	cmp    $0x25,%eax
  80036d:	75 e2                	jne    800351 <vprintfmt+0x14>
  80036f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800373:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800381:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800388:	ba 00 00 00 00       	mov    $0x0,%edx
  80038d:	eb 07                	jmp    800396 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800392:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8d 47 01             	lea    0x1(%edi),%eax
  800399:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039c:	0f b6 07             	movzbl (%edi),%eax
  80039f:	0f b6 c8             	movzbl %al,%ecx
  8003a2:	83 e8 23             	sub    $0x23,%eax
  8003a5:	3c 55                	cmp    $0x55,%al
  8003a7:	0f 87 21 03 00 00    	ja     8006ce <vprintfmt+0x391>
  8003ad:	0f b6 c0             	movzbl %al,%eax
  8003b0:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ba:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003be:	eb d6                	jmp    800396 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ce:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003d2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d8:	83 fa 09             	cmp    $0x9,%edx
  8003db:	77 39                	ja     800416 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003dd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e0:	eb e9                	jmp    8003cb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e5:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003eb:	8b 00                	mov    (%eax),%eax
  8003ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f3:	eb 27                	jmp    80041c <vprintfmt+0xdf>
  8003f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ff:	0f 49 c8             	cmovns %eax,%ecx
  800402:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800408:	eb 8c                	jmp    800396 <vprintfmt+0x59>
  80040a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800414:	eb 80                	jmp    800396 <vprintfmt+0x59>
  800416:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800419:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80041c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800420:	0f 89 70 ff ff ff    	jns    800396 <vprintfmt+0x59>
				width = precision, precision = -1;
  800426:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800429:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800433:	e9 5e ff ff ff       	jmp    800396 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800438:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043e:	e9 53 ff ff ff       	jmp    800396 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	53                   	push   %ebx
  800450:	ff 30                	pushl  (%eax)
  800452:	ff d6                	call   *%esi
			break;
  800454:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045a:	e9 04 ff ff ff       	jmp    800363 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	8d 50 04             	lea    0x4(%eax),%edx
  800465:	89 55 14             	mov    %edx,0x14(%ebp)
  800468:	8b 00                	mov    (%eax),%eax
  80046a:	99                   	cltd   
  80046b:	31 d0                	xor    %edx,%eax
  80046d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046f:	83 f8 07             	cmp    $0x7,%eax
  800472:	7f 0b                	jg     80047f <vprintfmt+0x142>
  800474:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  80047b:	85 d2                	test   %edx,%edx
  80047d:	75 18                	jne    800497 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80047f:	50                   	push   %eax
  800480:	68 16 0e 80 00       	push   $0x800e16
  800485:	53                   	push   %ebx
  800486:	56                   	push   %esi
  800487:	e8 94 fe ff ff       	call   800320 <printfmt>
  80048c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800492:	e9 cc fe ff ff       	jmp    800363 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800497:	52                   	push   %edx
  800498:	68 1f 0e 80 00       	push   $0x800e1f
  80049d:	53                   	push   %ebx
  80049e:	56                   	push   %esi
  80049f:	e8 7c fe ff ff       	call   800320 <printfmt>
  8004a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004aa:	e9 b4 fe ff ff       	jmp    800363 <vprintfmt+0x26>
  8004af:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b5:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8d 50 04             	lea    0x4(%eax),%edx
  8004be:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c3:	85 ff                	test   %edi,%edi
  8004c5:	ba 0f 0e 80 00       	mov    $0x800e0f,%edx
  8004ca:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8004cd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d1:	0f 84 92 00 00 00    	je     800569 <vprintfmt+0x22c>
  8004d7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004db:	0f 8e 96 00 00 00    	jle    800577 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	51                   	push   %ecx
  8004e5:	57                   	push   %edi
  8004e6:	e8 86 02 00 00       	call   800771 <strnlen>
  8004eb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ee:	29 c1                	sub    %eax,%ecx
  8004f0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800500:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800502:	eb 0f                	jmp    800513 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	ff 75 e0             	pushl  -0x20(%ebp)
  80050b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	83 ef 01             	sub    $0x1,%edi
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	85 ff                	test   %edi,%edi
  800515:	7f ed                	jg     800504 <vprintfmt+0x1c7>
  800517:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80051a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80051d:	85 c9                	test   %ecx,%ecx
  80051f:	b8 00 00 00 00       	mov    $0x0,%eax
  800524:	0f 49 c1             	cmovns %ecx,%eax
  800527:	29 c1                	sub    %eax,%ecx
  800529:	89 75 08             	mov    %esi,0x8(%ebp)
  80052c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800532:	89 cb                	mov    %ecx,%ebx
  800534:	eb 4d                	jmp    800583 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800536:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053a:	74 1b                	je     800557 <vprintfmt+0x21a>
  80053c:	0f be c0             	movsbl %al,%eax
  80053f:	83 e8 20             	sub    $0x20,%eax
  800542:	83 f8 5e             	cmp    $0x5e,%eax
  800545:	76 10                	jbe    800557 <vprintfmt+0x21a>
					putch('?', putdat);
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	ff 75 0c             	pushl  0xc(%ebp)
  80054d:	6a 3f                	push   $0x3f
  80054f:	ff 55 08             	call   *0x8(%ebp)
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	eb 0d                	jmp    800564 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	ff 75 0c             	pushl  0xc(%ebp)
  80055d:	52                   	push   %edx
  80055e:	ff 55 08             	call   *0x8(%ebp)
  800561:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	eb 1a                	jmp    800583 <vprintfmt+0x246>
  800569:	89 75 08             	mov    %esi,0x8(%ebp)
  80056c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800572:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800575:	eb 0c                	jmp    800583 <vprintfmt+0x246>
  800577:	89 75 08             	mov    %esi,0x8(%ebp)
  80057a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800580:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800583:	83 c7 01             	add    $0x1,%edi
  800586:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80058a:	0f be d0             	movsbl %al,%edx
  80058d:	85 d2                	test   %edx,%edx
  80058f:	74 23                	je     8005b4 <vprintfmt+0x277>
  800591:	85 f6                	test   %esi,%esi
  800593:	78 a1                	js     800536 <vprintfmt+0x1f9>
  800595:	83 ee 01             	sub    $0x1,%esi
  800598:	79 9c                	jns    800536 <vprintfmt+0x1f9>
  80059a:	89 df                	mov    %ebx,%edi
  80059c:	8b 75 08             	mov    0x8(%ebp),%esi
  80059f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a2:	eb 18                	jmp    8005bc <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	53                   	push   %ebx
  8005a8:	6a 20                	push   $0x20
  8005aa:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ac:	83 ef 01             	sub    $0x1,%edi
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	eb 08                	jmp    8005bc <vprintfmt+0x27f>
  8005b4:	89 df                	mov    %ebx,%edi
  8005b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	7f e4                	jg     8005a4 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c3:	e9 9b fd ff ff       	jmp    800363 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c8:	83 fa 01             	cmp    $0x1,%edx
  8005cb:	7e 16                	jle    8005e3 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 08             	lea    0x8(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d6:	8b 50 04             	mov    0x4(%eax),%edx
  8005d9:	8b 00                	mov    (%eax),%eax
  8005db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e1:	eb 32                	jmp    800615 <vprintfmt+0x2d8>
	else if (lflag)
  8005e3:	85 d2                	test   %edx,%edx
  8005e5:	74 18                	je     8005ff <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 50 04             	lea    0x4(%eax),%edx
  8005ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f5:	89 c1                	mov    %eax,%ecx
  8005f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fd:	eb 16                	jmp    800615 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 50 04             	lea    0x4(%eax),%edx
  800605:	89 55 14             	mov    %edx,0x14(%ebp)
  800608:	8b 00                	mov    (%eax),%eax
  80060a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060d:	89 c1                	mov    %eax,%ecx
  80060f:	c1 f9 1f             	sar    $0x1f,%ecx
  800612:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800615:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800618:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80061b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800620:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800624:	79 74                	jns    80069a <vprintfmt+0x35d>
				putch('-', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 2d                	push   $0x2d
  80062c:	ff d6                	call   *%esi
				num = -(long long) num;
  80062e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800631:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800634:	f7 d8                	neg    %eax
  800636:	83 d2 00             	adc    $0x0,%edx
  800639:	f7 da                	neg    %edx
  80063b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800643:	eb 55                	jmp    80069a <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800645:	8d 45 14             	lea    0x14(%ebp),%eax
  800648:	e8 7c fc ff ff       	call   8002c9 <getuint>
			base = 10;
  80064d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800652:	eb 46                	jmp    80069a <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800654:	8d 45 14             	lea    0x14(%ebp),%eax
  800657:	e8 6d fc ff ff       	call   8002c9 <getuint>
                        base = 8;
  80065c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800661:	eb 37                	jmp    80069a <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	6a 30                	push   $0x30
  800669:	ff d6                	call   *%esi
			putch('x', putdat);
  80066b:	83 c4 08             	add    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 78                	push   $0x78
  800671:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8d 50 04             	lea    0x4(%eax),%edx
  800679:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067c:	8b 00                	mov    (%eax),%eax
  80067e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800683:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800686:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80068b:	eb 0d                	jmp    80069a <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068d:	8d 45 14             	lea    0x14(%ebp),%eax
  800690:	e8 34 fc ff ff       	call   8002c9 <getuint>
			base = 16;
  800695:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069a:	83 ec 0c             	sub    $0xc,%esp
  80069d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a1:	57                   	push   %edi
  8006a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a5:	51                   	push   %ecx
  8006a6:	52                   	push   %edx
  8006a7:	50                   	push   %eax
  8006a8:	89 da                	mov    %ebx,%edx
  8006aa:	89 f0                	mov    %esi,%eax
  8006ac:	e8 6e fb ff ff       	call   80021f <printnum>
			break;
  8006b1:	83 c4 20             	add    $0x20,%esp
  8006b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b7:	e9 a7 fc ff ff       	jmp    800363 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	51                   	push   %ecx
  8006c1:	ff d6                	call   *%esi
			break;
  8006c3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c9:	e9 95 fc ff ff       	jmp    800363 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	6a 25                	push   $0x25
  8006d4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	eb 03                	jmp    8006de <vprintfmt+0x3a1>
  8006db:	83 ef 01             	sub    $0x1,%edi
  8006de:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e2:	75 f7                	jne    8006db <vprintfmt+0x39e>
  8006e4:	e9 7a fc ff ff       	jmp    800363 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ec:	5b                   	pop    %ebx
  8006ed:	5e                   	pop    %esi
  8006ee:	5f                   	pop    %edi
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	83 ec 18             	sub    $0x18,%esp
  8006f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800700:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800704:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800707:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 26                	je     800738 <vsnprintf+0x47>
  800712:	85 d2                	test   %edx,%edx
  800714:	7e 22                	jle    800738 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800716:	ff 75 14             	pushl  0x14(%ebp)
  800719:	ff 75 10             	pushl  0x10(%ebp)
  80071c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	68 03 03 80 00       	push   $0x800303
  800725:	e8 13 fc ff ff       	call   80033d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800730:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	eb 05                	jmp    80073d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800738:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073d:	c9                   	leave  
  80073e:	c3                   	ret    

0080073f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800745:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800748:	50                   	push   %eax
  800749:	ff 75 10             	pushl  0x10(%ebp)
  80074c:	ff 75 0c             	pushl  0xc(%ebp)
  80074f:	ff 75 08             	pushl  0x8(%ebp)
  800752:	e8 9a ff ff ff       	call   8006f1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
  800764:	eb 03                	jmp    800769 <strlen+0x10>
		n++;
  800766:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800769:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076d:	75 f7                	jne    800766 <strlen+0xd>
		n++;
	return n;
}
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800777:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077a:	ba 00 00 00 00       	mov    $0x0,%edx
  80077f:	eb 03                	jmp    800784 <strnlen+0x13>
		n++;
  800781:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800784:	39 c2                	cmp    %eax,%edx
  800786:	74 08                	je     800790 <strnlen+0x1f>
  800788:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80078c:	75 f3                	jne    800781 <strnlen+0x10>
  80078e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	53                   	push   %ebx
  800796:	8b 45 08             	mov    0x8(%ebp),%eax
  800799:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079c:	89 c2                	mov    %eax,%edx
  80079e:	83 c2 01             	add    $0x1,%edx
  8007a1:	83 c1 01             	add    $0x1,%ecx
  8007a4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ab:	84 db                	test   %bl,%bl
  8007ad:	75 ef                	jne    80079e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007af:	5b                   	pop    %ebx
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b9:	53                   	push   %ebx
  8007ba:	e8 9a ff ff ff       	call   800759 <strlen>
  8007bf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c2:	ff 75 0c             	pushl  0xc(%ebp)
  8007c5:	01 d8                	add    %ebx,%eax
  8007c7:	50                   	push   %eax
  8007c8:	e8 c5 ff ff ff       	call   800792 <strcpy>
	return dst;
}
  8007cd:	89 d8                	mov    %ebx,%eax
  8007cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	56                   	push   %esi
  8007d8:	53                   	push   %ebx
  8007d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007df:	89 f3                	mov    %esi,%ebx
  8007e1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e4:	89 f2                	mov    %esi,%edx
  8007e6:	eb 0f                	jmp    8007f7 <strncpy+0x23>
		*dst++ = *src;
  8007e8:	83 c2 01             	add    $0x1,%edx
  8007eb:	0f b6 01             	movzbl (%ecx),%eax
  8007ee:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f1:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f7:	39 da                	cmp    %ebx,%edx
  8007f9:	75 ed                	jne    8007e8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fb:	89 f0                	mov    %esi,%eax
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	56                   	push   %esi
  800805:	53                   	push   %ebx
  800806:	8b 75 08             	mov    0x8(%ebp),%esi
  800809:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080c:	8b 55 10             	mov    0x10(%ebp),%edx
  80080f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800811:	85 d2                	test   %edx,%edx
  800813:	74 21                	je     800836 <strlcpy+0x35>
  800815:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800819:	89 f2                	mov    %esi,%edx
  80081b:	eb 09                	jmp    800826 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081d:	83 c2 01             	add    $0x1,%edx
  800820:	83 c1 01             	add    $0x1,%ecx
  800823:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800826:	39 c2                	cmp    %eax,%edx
  800828:	74 09                	je     800833 <strlcpy+0x32>
  80082a:	0f b6 19             	movzbl (%ecx),%ebx
  80082d:	84 db                	test   %bl,%bl
  80082f:	75 ec                	jne    80081d <strlcpy+0x1c>
  800831:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800833:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800836:	29 f0                	sub    %esi,%eax
}
  800838:	5b                   	pop    %ebx
  800839:	5e                   	pop    %esi
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800845:	eb 06                	jmp    80084d <strcmp+0x11>
		p++, q++;
  800847:	83 c1 01             	add    $0x1,%ecx
  80084a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084d:	0f b6 01             	movzbl (%ecx),%eax
  800850:	84 c0                	test   %al,%al
  800852:	74 04                	je     800858 <strcmp+0x1c>
  800854:	3a 02                	cmp    (%edx),%al
  800856:	74 ef                	je     800847 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800858:	0f b6 c0             	movzbl %al,%eax
  80085b:	0f b6 12             	movzbl (%edx),%edx
  80085e:	29 d0                	sub    %edx,%eax
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086c:	89 c3                	mov    %eax,%ebx
  80086e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800871:	eb 06                	jmp    800879 <strncmp+0x17>
		n--, p++, q++;
  800873:	83 c0 01             	add    $0x1,%eax
  800876:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800879:	39 d8                	cmp    %ebx,%eax
  80087b:	74 15                	je     800892 <strncmp+0x30>
  80087d:	0f b6 08             	movzbl (%eax),%ecx
  800880:	84 c9                	test   %cl,%cl
  800882:	74 04                	je     800888 <strncmp+0x26>
  800884:	3a 0a                	cmp    (%edx),%cl
  800886:	74 eb                	je     800873 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800888:	0f b6 00             	movzbl (%eax),%eax
  80088b:	0f b6 12             	movzbl (%edx),%edx
  80088e:	29 d0                	sub    %edx,%eax
  800890:	eb 05                	jmp    800897 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a4:	eb 07                	jmp    8008ad <strchr+0x13>
		if (*s == c)
  8008a6:	38 ca                	cmp    %cl,%dl
  8008a8:	74 0f                	je     8008b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	0f b6 10             	movzbl (%eax),%edx
  8008b0:	84 d2                	test   %dl,%dl
  8008b2:	75 f2                	jne    8008a6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c5:	eb 03                	jmp    8008ca <strfind+0xf>
  8008c7:	83 c0 01             	add    $0x1,%eax
  8008ca:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cd:	84 d2                	test   %dl,%dl
  8008cf:	74 04                	je     8008d5 <strfind+0x1a>
  8008d1:	38 ca                	cmp    %cl,%dl
  8008d3:	75 f2                	jne    8008c7 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e3:	85 c9                	test   %ecx,%ecx
  8008e5:	74 36                	je     80091d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ed:	75 28                	jne    800917 <memset+0x40>
  8008ef:	f6 c1 03             	test   $0x3,%cl
  8008f2:	75 23                	jne    800917 <memset+0x40>
		c &= 0xFF;
  8008f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f8:	89 d3                	mov    %edx,%ebx
  8008fa:	c1 e3 08             	shl    $0x8,%ebx
  8008fd:	89 d6                	mov    %edx,%esi
  8008ff:	c1 e6 18             	shl    $0x18,%esi
  800902:	89 d0                	mov    %edx,%eax
  800904:	c1 e0 10             	shl    $0x10,%eax
  800907:	09 f0                	or     %esi,%eax
  800909:	09 c2                	or     %eax,%edx
  80090b:	89 d0                	mov    %edx,%eax
  80090d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80090f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800912:	fc                   	cld    
  800913:	f3 ab                	rep stos %eax,%es:(%edi)
  800915:	eb 06                	jmp    80091d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800917:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091a:	fc                   	cld    
  80091b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091d:	89 f8                	mov    %edi,%eax
  80091f:	5b                   	pop    %ebx
  800920:	5e                   	pop    %esi
  800921:	5f                   	pop    %edi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	57                   	push   %edi
  800928:	56                   	push   %esi
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800932:	39 c6                	cmp    %eax,%esi
  800934:	73 35                	jae    80096b <memmove+0x47>
  800936:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800939:	39 d0                	cmp    %edx,%eax
  80093b:	73 2e                	jae    80096b <memmove+0x47>
		s += n;
		d += n;
  80093d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800940:	89 d6                	mov    %edx,%esi
  800942:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094a:	75 13                	jne    80095f <memmove+0x3b>
  80094c:	f6 c1 03             	test   $0x3,%cl
  80094f:	75 0e                	jne    80095f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800951:	83 ef 04             	sub    $0x4,%edi
  800954:	8d 72 fc             	lea    -0x4(%edx),%esi
  800957:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80095a:	fd                   	std    
  80095b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095d:	eb 09                	jmp    800968 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095f:	83 ef 01             	sub    $0x1,%edi
  800962:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800965:	fd                   	std    
  800966:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800968:	fc                   	cld    
  800969:	eb 1d                	jmp    800988 <memmove+0x64>
  80096b:	89 f2                	mov    %esi,%edx
  80096d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096f:	f6 c2 03             	test   $0x3,%dl
  800972:	75 0f                	jne    800983 <memmove+0x5f>
  800974:	f6 c1 03             	test   $0x3,%cl
  800977:	75 0a                	jne    800983 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800979:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80097c:	89 c7                	mov    %eax,%edi
  80097e:	fc                   	cld    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 05                	jmp    800988 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800983:	89 c7                	mov    %eax,%edi
  800985:	fc                   	cld    
  800986:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800988:	5e                   	pop    %esi
  800989:	5f                   	pop    %edi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098f:	ff 75 10             	pushl  0x10(%ebp)
  800992:	ff 75 0c             	pushl  0xc(%ebp)
  800995:	ff 75 08             	pushl  0x8(%ebp)
  800998:	e8 87 ff ff ff       	call   800924 <memmove>
}
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    

0080099f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009aa:	89 c6                	mov    %eax,%esi
  8009ac:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009af:	eb 1a                	jmp    8009cb <memcmp+0x2c>
		if (*s1 != *s2)
  8009b1:	0f b6 08             	movzbl (%eax),%ecx
  8009b4:	0f b6 1a             	movzbl (%edx),%ebx
  8009b7:	38 d9                	cmp    %bl,%cl
  8009b9:	74 0a                	je     8009c5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009bb:	0f b6 c1             	movzbl %cl,%eax
  8009be:	0f b6 db             	movzbl %bl,%ebx
  8009c1:	29 d8                	sub    %ebx,%eax
  8009c3:	eb 0f                	jmp    8009d4 <memcmp+0x35>
		s1++, s2++;
  8009c5:	83 c0 01             	add    $0x1,%eax
  8009c8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cb:	39 f0                	cmp    %esi,%eax
  8009cd:	75 e2                	jne    8009b1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d4:	5b                   	pop    %ebx
  8009d5:	5e                   	pop    %esi
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e1:	89 c2                	mov    %eax,%edx
  8009e3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e6:	eb 07                	jmp    8009ef <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e8:	38 08                	cmp    %cl,(%eax)
  8009ea:	74 07                	je     8009f3 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ec:	83 c0 01             	add    $0x1,%eax
  8009ef:	39 d0                	cmp    %edx,%eax
  8009f1:	72 f5                	jb     8009e8 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	57                   	push   %edi
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a01:	eb 03                	jmp    800a06 <strtol+0x11>
		s++;
  800a03:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a06:	0f b6 01             	movzbl (%ecx),%eax
  800a09:	3c 09                	cmp    $0x9,%al
  800a0b:	74 f6                	je     800a03 <strtol+0xe>
  800a0d:	3c 20                	cmp    $0x20,%al
  800a0f:	74 f2                	je     800a03 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a11:	3c 2b                	cmp    $0x2b,%al
  800a13:	75 0a                	jne    800a1f <strtol+0x2a>
		s++;
  800a15:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a18:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1d:	eb 10                	jmp    800a2f <strtol+0x3a>
  800a1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a24:	3c 2d                	cmp    $0x2d,%al
  800a26:	75 07                	jne    800a2f <strtol+0x3a>
		s++, neg = 1;
  800a28:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a2b:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2f:	85 db                	test   %ebx,%ebx
  800a31:	0f 94 c0             	sete   %al
  800a34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3a:	75 19                	jne    800a55 <strtol+0x60>
  800a3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3f:	75 14                	jne    800a55 <strtol+0x60>
  800a41:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a45:	0f 85 82 00 00 00    	jne    800acd <strtol+0xd8>
		s += 2, base = 16;
  800a4b:	83 c1 02             	add    $0x2,%ecx
  800a4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a53:	eb 16                	jmp    800a6b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a55:	84 c0                	test   %al,%al
  800a57:	74 12                	je     800a6b <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a59:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a61:	75 08                	jne    800a6b <strtol+0x76>
		s++, base = 8;
  800a63:	83 c1 01             	add    $0x1,%ecx
  800a66:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a70:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a73:	0f b6 11             	movzbl (%ecx),%edx
  800a76:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a79:	89 f3                	mov    %esi,%ebx
  800a7b:	80 fb 09             	cmp    $0x9,%bl
  800a7e:	77 08                	ja     800a88 <strtol+0x93>
			dig = *s - '0';
  800a80:	0f be d2             	movsbl %dl,%edx
  800a83:	83 ea 30             	sub    $0x30,%edx
  800a86:	eb 22                	jmp    800aaa <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8b:	89 f3                	mov    %esi,%ebx
  800a8d:	80 fb 19             	cmp    $0x19,%bl
  800a90:	77 08                	ja     800a9a <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a92:	0f be d2             	movsbl %dl,%edx
  800a95:	83 ea 57             	sub    $0x57,%edx
  800a98:	eb 10                	jmp    800aaa <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	80 fb 19             	cmp    $0x19,%bl
  800aa2:	77 16                	ja     800aba <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aa4:	0f be d2             	movsbl %dl,%edx
  800aa7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aaa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aad:	7d 0f                	jge    800abe <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800aaf:	83 c1 01             	add    $0x1,%ecx
  800ab2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab8:	eb b9                	jmp    800a73 <strtol+0x7e>
  800aba:	89 c2                	mov    %eax,%edx
  800abc:	eb 02                	jmp    800ac0 <strtol+0xcb>
  800abe:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ac0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac4:	74 0d                	je     800ad3 <strtol+0xde>
		*endptr = (char *) s;
  800ac6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac9:	89 0e                	mov    %ecx,(%esi)
  800acb:	eb 06                	jmp    800ad3 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acd:	84 c0                	test   %al,%al
  800acf:	75 92                	jne    800a63 <strtol+0x6e>
  800ad1:	eb 98                	jmp    800a6b <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad3:	f7 da                	neg    %edx
  800ad5:	85 ff                	test   %edi,%edi
  800ad7:	0f 45 c2             	cmovne %edx,%eax
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    
  800adf:	90                   	nop

00800ae0 <__udivdi3>:
  800ae0:	55                   	push   %ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	83 ec 10             	sub    $0x10,%esp
  800ae6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800aea:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800aee:	8b 74 24 24          	mov    0x24(%esp),%esi
  800af2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800af6:	85 d2                	test   %edx,%edx
  800af8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800afc:	89 34 24             	mov    %esi,(%esp)
  800aff:	89 c8                	mov    %ecx,%eax
  800b01:	75 35                	jne    800b38 <__udivdi3+0x58>
  800b03:	39 f1                	cmp    %esi,%ecx
  800b05:	0f 87 bd 00 00 00    	ja     800bc8 <__udivdi3+0xe8>
  800b0b:	85 c9                	test   %ecx,%ecx
  800b0d:	89 cd                	mov    %ecx,%ebp
  800b0f:	75 0b                	jne    800b1c <__udivdi3+0x3c>
  800b11:	b8 01 00 00 00       	mov    $0x1,%eax
  800b16:	31 d2                	xor    %edx,%edx
  800b18:	f7 f1                	div    %ecx
  800b1a:	89 c5                	mov    %eax,%ebp
  800b1c:	89 f0                	mov    %esi,%eax
  800b1e:	31 d2                	xor    %edx,%edx
  800b20:	f7 f5                	div    %ebp
  800b22:	89 c6                	mov    %eax,%esi
  800b24:	89 f8                	mov    %edi,%eax
  800b26:	f7 f5                	div    %ebp
  800b28:	89 f2                	mov    %esi,%edx
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    
  800b31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b38:	3b 14 24             	cmp    (%esp),%edx
  800b3b:	77 7b                	ja     800bb8 <__udivdi3+0xd8>
  800b3d:	0f bd f2             	bsr    %edx,%esi
  800b40:	83 f6 1f             	xor    $0x1f,%esi
  800b43:	0f 84 97 00 00 00    	je     800be0 <__udivdi3+0x100>
  800b49:	bd 20 00 00 00       	mov    $0x20,%ebp
  800b4e:	89 d7                	mov    %edx,%edi
  800b50:	89 f1                	mov    %esi,%ecx
  800b52:	29 f5                	sub    %esi,%ebp
  800b54:	d3 e7                	shl    %cl,%edi
  800b56:	89 c2                	mov    %eax,%edx
  800b58:	89 e9                	mov    %ebp,%ecx
  800b5a:	d3 ea                	shr    %cl,%edx
  800b5c:	89 f1                	mov    %esi,%ecx
  800b5e:	09 fa                	or     %edi,%edx
  800b60:	8b 3c 24             	mov    (%esp),%edi
  800b63:	d3 e0                	shl    %cl,%eax
  800b65:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b69:	89 e9                	mov    %ebp,%ecx
  800b6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b6f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800b73:	89 fa                	mov    %edi,%edx
  800b75:	d3 ea                	shr    %cl,%edx
  800b77:	89 f1                	mov    %esi,%ecx
  800b79:	d3 e7                	shl    %cl,%edi
  800b7b:	89 e9                	mov    %ebp,%ecx
  800b7d:	d3 e8                	shr    %cl,%eax
  800b7f:	09 c7                	or     %eax,%edi
  800b81:	89 f8                	mov    %edi,%eax
  800b83:	f7 74 24 08          	divl   0x8(%esp)
  800b87:	89 d5                	mov    %edx,%ebp
  800b89:	89 c7                	mov    %eax,%edi
  800b8b:	f7 64 24 0c          	mull   0xc(%esp)
  800b8f:	39 d5                	cmp    %edx,%ebp
  800b91:	89 14 24             	mov    %edx,(%esp)
  800b94:	72 11                	jb     800ba7 <__udivdi3+0xc7>
  800b96:	8b 54 24 04          	mov    0x4(%esp),%edx
  800b9a:	89 f1                	mov    %esi,%ecx
  800b9c:	d3 e2                	shl    %cl,%edx
  800b9e:	39 c2                	cmp    %eax,%edx
  800ba0:	73 5e                	jae    800c00 <__udivdi3+0x120>
  800ba2:	3b 2c 24             	cmp    (%esp),%ebp
  800ba5:	75 59                	jne    800c00 <__udivdi3+0x120>
  800ba7:	8d 47 ff             	lea    -0x1(%edi),%eax
  800baa:	31 f6                	xor    %esi,%esi
  800bac:	89 f2                	mov    %esi,%edx
  800bae:	83 c4 10             	add    $0x10,%esp
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    
  800bb5:	8d 76 00             	lea    0x0(%esi),%esi
  800bb8:	31 f6                	xor    %esi,%esi
  800bba:	31 c0                	xor    %eax,%eax
  800bbc:	89 f2                	mov    %esi,%edx
  800bbe:	83 c4 10             	add    $0x10,%esp
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    
  800bc5:	8d 76 00             	lea    0x0(%esi),%esi
  800bc8:	89 f2                	mov    %esi,%edx
  800bca:	31 f6                	xor    %esi,%esi
  800bcc:	89 f8                	mov    %edi,%eax
  800bce:	f7 f1                	div    %ecx
  800bd0:	89 f2                	mov    %esi,%edx
  800bd2:	83 c4 10             	add    $0x10,%esp
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    
  800bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800be0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800be4:	76 0b                	jbe    800bf1 <__udivdi3+0x111>
  800be6:	31 c0                	xor    %eax,%eax
  800be8:	3b 14 24             	cmp    (%esp),%edx
  800beb:	0f 83 37 ff ff ff    	jae    800b28 <__udivdi3+0x48>
  800bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf6:	e9 2d ff ff ff       	jmp    800b28 <__udivdi3+0x48>
  800bfb:	90                   	nop
  800bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c00:	89 f8                	mov    %edi,%eax
  800c02:	31 f6                	xor    %esi,%esi
  800c04:	e9 1f ff ff ff       	jmp    800b28 <__udivdi3+0x48>
  800c09:	66 90                	xchg   %ax,%ax
  800c0b:	66 90                	xchg   %ax,%ax
  800c0d:	66 90                	xchg   %ax,%ax
  800c0f:	90                   	nop

00800c10 <__umoddi3>:
  800c10:	55                   	push   %ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	83 ec 20             	sub    $0x20,%esp
  800c16:	8b 44 24 34          	mov    0x34(%esp),%eax
  800c1a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c1e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c22:	89 c6                	mov    %eax,%esi
  800c24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c28:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c2c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800c30:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c34:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800c38:	89 74 24 18          	mov    %esi,0x18(%esp)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	89 c2                	mov    %eax,%edx
  800c40:	75 1e                	jne    800c60 <__umoddi3+0x50>
  800c42:	39 f7                	cmp    %esi,%edi
  800c44:	76 52                	jbe    800c98 <__umoddi3+0x88>
  800c46:	89 c8                	mov    %ecx,%eax
  800c48:	89 f2                	mov    %esi,%edx
  800c4a:	f7 f7                	div    %edi
  800c4c:	89 d0                	mov    %edx,%eax
  800c4e:	31 d2                	xor    %edx,%edx
  800c50:	83 c4 20             	add    $0x20,%esp
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    
  800c57:	89 f6                	mov    %esi,%esi
  800c59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800c60:	39 f0                	cmp    %esi,%eax
  800c62:	77 5c                	ja     800cc0 <__umoddi3+0xb0>
  800c64:	0f bd e8             	bsr    %eax,%ebp
  800c67:	83 f5 1f             	xor    $0x1f,%ebp
  800c6a:	75 64                	jne    800cd0 <__umoddi3+0xc0>
  800c6c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800c70:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800c74:	0f 86 f6 00 00 00    	jbe    800d70 <__umoddi3+0x160>
  800c7a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800c7e:	0f 82 ec 00 00 00    	jb     800d70 <__umoddi3+0x160>
  800c84:	8b 44 24 14          	mov    0x14(%esp),%eax
  800c88:	8b 54 24 18          	mov    0x18(%esp),%edx
  800c8c:	83 c4 20             	add    $0x20,%esp
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    
  800c93:	90                   	nop
  800c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c98:	85 ff                	test   %edi,%edi
  800c9a:	89 fd                	mov    %edi,%ebp
  800c9c:	75 0b                	jne    800ca9 <__umoddi3+0x99>
  800c9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca3:	31 d2                	xor    %edx,%edx
  800ca5:	f7 f7                	div    %edi
  800ca7:	89 c5                	mov    %eax,%ebp
  800ca9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800cad:	31 d2                	xor    %edx,%edx
  800caf:	f7 f5                	div    %ebp
  800cb1:	89 c8                	mov    %ecx,%eax
  800cb3:	f7 f5                	div    %ebp
  800cb5:	eb 95                	jmp    800c4c <__umoddi3+0x3c>
  800cb7:	89 f6                	mov    %esi,%esi
  800cb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800cc0:	89 c8                	mov    %ecx,%eax
  800cc2:	89 f2                	mov    %esi,%edx
  800cc4:	83 c4 20             	add    $0x20,%esp
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    
  800ccb:	90                   	nop
  800ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	b8 20 00 00 00       	mov    $0x20,%eax
  800cd5:	89 e9                	mov    %ebp,%ecx
  800cd7:	29 e8                	sub    %ebp,%eax
  800cd9:	d3 e2                	shl    %cl,%edx
  800cdb:	89 c7                	mov    %eax,%edi
  800cdd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800ce1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ce5:	89 f9                	mov    %edi,%ecx
  800ce7:	d3 e8                	shr    %cl,%eax
  800ce9:	89 c1                	mov    %eax,%ecx
  800ceb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cef:	09 d1                	or     %edx,%ecx
  800cf1:	89 fa                	mov    %edi,%edx
  800cf3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800cf7:	89 e9                	mov    %ebp,%ecx
  800cf9:	d3 e0                	shl    %cl,%eax
  800cfb:	89 f9                	mov    %edi,%ecx
  800cfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d01:	89 f0                	mov    %esi,%eax
  800d03:	d3 e8                	shr    %cl,%eax
  800d05:	89 e9                	mov    %ebp,%ecx
  800d07:	89 c7                	mov    %eax,%edi
  800d09:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d0d:	d3 e6                	shl    %cl,%esi
  800d0f:	89 d1                	mov    %edx,%ecx
  800d11:	89 fa                	mov    %edi,%edx
  800d13:	d3 e8                	shr    %cl,%eax
  800d15:	89 e9                	mov    %ebp,%ecx
  800d17:	09 f0                	or     %esi,%eax
  800d19:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800d1d:	f7 74 24 10          	divl   0x10(%esp)
  800d21:	d3 e6                	shl    %cl,%esi
  800d23:	89 d1                	mov    %edx,%ecx
  800d25:	f7 64 24 0c          	mull   0xc(%esp)
  800d29:	39 d1                	cmp    %edx,%ecx
  800d2b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800d2f:	89 d7                	mov    %edx,%edi
  800d31:	89 c6                	mov    %eax,%esi
  800d33:	72 0a                	jb     800d3f <__umoddi3+0x12f>
  800d35:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800d39:	73 10                	jae    800d4b <__umoddi3+0x13b>
  800d3b:	39 d1                	cmp    %edx,%ecx
  800d3d:	75 0c                	jne    800d4b <__umoddi3+0x13b>
  800d3f:	89 d7                	mov    %edx,%edi
  800d41:	89 c6                	mov    %eax,%esi
  800d43:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800d47:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800d4b:	89 ca                	mov    %ecx,%edx
  800d4d:	89 e9                	mov    %ebp,%ecx
  800d4f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d53:	29 f0                	sub    %esi,%eax
  800d55:	19 fa                	sbb    %edi,%edx
  800d57:	d3 e8                	shr    %cl,%eax
  800d59:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800d5e:	89 d7                	mov    %edx,%edi
  800d60:	d3 e7                	shl    %cl,%edi
  800d62:	89 e9                	mov    %ebp,%ecx
  800d64:	09 f8                	or     %edi,%eax
  800d66:	d3 ea                	shr    %cl,%edx
  800d68:	83 c4 20             	add    $0x20,%esp
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    
  800d6f:	90                   	nop
  800d70:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d74:	29 f9                	sub    %edi,%ecx
  800d76:	19 c6                	sbb    %eax,%esi
  800d78:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800d7c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800d80:	e9 ff fe ff ff       	jmp    800c84 <__umoddi3+0x74>
