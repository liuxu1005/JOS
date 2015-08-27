
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 08 40 80 00       	mov    0x804008,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 00 29 80 00       	push   $0x802900
  800047:	e8 68 01 00 00       	call   8001b4 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 1e 29 80 00       	push   $0x80291e
  800056:	68 1e 29 80 00       	push   $0x80291e
  80005b:	e8 f9 1a 00 00       	call   801b59 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 24 29 80 00       	push   $0x802924
  80006d:	6a 09                	push   $0x9
  80006f:	68 3c 29 80 00       	push   $0x80293c
  800074:	e8 62 00 00 00       	call   8000db <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800086:	e8 7b 0a 00 00       	call   800b06 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
  8000b7:	83 c4 10             	add    $0x10,%esp
}
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 dc 0e 00 00       	call   800fa8 <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 ef 09 00 00       	call   800ac5 <sys_env_destroy>
  8000d6:	83 c4 10             	add    $0x10,%esp
}
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 18 0a 00 00       	call   800b06 <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 58 29 80 00       	push   $0x802958
  8000fe:	e8 b1 00 00 00       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 54 00 00 00       	call   800163 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 95 2e 80 00 	movl   $0x802e95,(%esp)
  800116:	e8 99 00 00 00       	call   8001b4 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 37 09 00 00       	call   800a88 <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 4f 01 00 00       	call   8002e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 dc 08 00 00       	call   800a88 <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 d1                	mov    %edx,%ecx
  8001dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001f3:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001f6:	72 05                	jb     8001fd <printnum+0x35>
  8001f8:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001fb:	77 3e                	ja     80023b <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	ff 75 18             	pushl  0x18(%ebp)
  800203:	83 eb 01             	sub    $0x1,%ebx
  800206:	53                   	push   %ebx
  800207:	50                   	push   %eax
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 34 24 00 00       	call   802650 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 13                	jmp    800242 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023b:	83 eb 01             	sub    $0x1,%ebx
  80023e:	85 db                	test   %ebx,%ebx
  800240:	7f ed                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	56                   	push   %esi
  800246:	83 ec 04             	sub    $0x4,%esp
  800249:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024c:	ff 75 e0             	pushl  -0x20(%ebp)
  80024f:	ff 75 dc             	pushl  -0x24(%ebp)
  800252:	ff 75 d8             	pushl  -0x28(%ebp)
  800255:	e8 26 25 00 00       	call   802780 <__umoddi3>
  80025a:	83 c4 14             	add    $0x14,%esp
  80025d:	0f be 80 7b 29 80 00 	movsbl 0x80297b(%eax),%eax
  800264:	50                   	push   %eax
  800265:	ff d7                	call   *%edi
  800267:	83 c4 10             	add    $0x10,%esp
}
  80026a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026d:	5b                   	pop    %ebx
  80026e:	5e                   	pop    %esi
  80026f:	5f                   	pop    %edi
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800275:	83 fa 01             	cmp    $0x1,%edx
  800278:	7e 0e                	jle    800288 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	8b 52 04             	mov    0x4(%edx),%edx
  800286:	eb 22                	jmp    8002aa <getuint+0x38>
	else if (lflag)
  800288:	85 d2                	test   %edx,%edx
  80028a:	74 10                	je     80029c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800291:	89 08                	mov    %ecx,(%eax)
  800293:	8b 02                	mov    (%edx),%eax
  800295:	ba 00 00 00 00       	mov    $0x0,%edx
  80029a:	eb 0e                	jmp    8002aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 02                	mov    (%edx),%eax
  8002a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b6:	8b 10                	mov    (%eax),%edx
  8002b8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bb:	73 0a                	jae    8002c7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002bd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c0:	89 08                	mov    %ecx,(%eax)
  8002c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c5:	88 02                	mov    %al,(%edx)
}
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002cf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 10             	pushl  0x10(%ebp)
  8002d6:	ff 75 0c             	pushl  0xc(%ebp)
  8002d9:	ff 75 08             	pushl  0x8(%ebp)
  8002dc:	e8 05 00 00 00       	call   8002e6 <vprintfmt>
	va_end(ap);
  8002e1:	83 c4 10             	add    $0x10,%esp
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    

008002e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	57                   	push   %edi
  8002ea:	56                   	push   %esi
  8002eb:	53                   	push   %ebx
  8002ec:	83 ec 2c             	sub    $0x2c,%esp
  8002ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f8:	eb 12                	jmp    80030c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fa:	85 c0                	test   %eax,%eax
  8002fc:	0f 84 90 03 00 00    	je     800692 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800302:	83 ec 08             	sub    $0x8,%esp
  800305:	53                   	push   %ebx
  800306:	50                   	push   %eax
  800307:	ff d6                	call   *%esi
  800309:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030c:	83 c7 01             	add    $0x1,%edi
  80030f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800313:	83 f8 25             	cmp    $0x25,%eax
  800316:	75 e2                	jne    8002fa <vprintfmt+0x14>
  800318:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800323:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800331:	ba 00 00 00 00       	mov    $0x0,%edx
  800336:	eb 07                	jmp    80033f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	8d 47 01             	lea    0x1(%edi),%eax
  800342:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800345:	0f b6 07             	movzbl (%edi),%eax
  800348:	0f b6 c8             	movzbl %al,%ecx
  80034b:	83 e8 23             	sub    $0x23,%eax
  80034e:	3c 55                	cmp    $0x55,%al
  800350:	0f 87 21 03 00 00    	ja     800677 <vprintfmt+0x391>
  800356:	0f b6 c0             	movzbl %al,%eax
  800359:	ff 24 85 c0 2a 80 00 	jmp    *0x802ac0(,%eax,4)
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800363:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800367:	eb d6                	jmp    80033f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036c:	b8 00 00 00 00       	mov    $0x0,%eax
  800371:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800374:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800377:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80037e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800381:	83 fa 09             	cmp    $0x9,%edx
  800384:	77 39                	ja     8003bf <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800386:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800389:	eb e9                	jmp    800374 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038b:	8b 45 14             	mov    0x14(%ebp),%eax
  80038e:	8d 48 04             	lea    0x4(%eax),%ecx
  800391:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800394:	8b 00                	mov    (%eax),%eax
  800396:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039c:	eb 27                	jmp    8003c5 <vprintfmt+0xdf>
  80039e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a8:	0f 49 c8             	cmovns %eax,%ecx
  8003ab:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b1:	eb 8c                	jmp    80033f <vprintfmt+0x59>
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003bd:	eb 80                	jmp    80033f <vprintfmt+0x59>
  8003bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c9:	0f 89 70 ff ff ff    	jns    80033f <vprintfmt+0x59>
				width = precision, precision = -1;
  8003cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003dc:	e9 5e ff ff ff       	jmp    80033f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e7:	e9 53 ff ff ff       	jmp    80033f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 50 04             	lea    0x4(%eax),%edx
  8003f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f5:	83 ec 08             	sub    $0x8,%esp
  8003f8:	53                   	push   %ebx
  8003f9:	ff 30                	pushl  (%eax)
  8003fb:	ff d6                	call   *%esi
			break;
  8003fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800403:	e9 04 ff ff ff       	jmp    80030c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8d 50 04             	lea    0x4(%eax),%edx
  80040e:	89 55 14             	mov    %edx,0x14(%ebp)
  800411:	8b 00                	mov    (%eax),%eax
  800413:	99                   	cltd   
  800414:	31 d0                	xor    %edx,%eax
  800416:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800418:	83 f8 0f             	cmp    $0xf,%eax
  80041b:	7f 0b                	jg     800428 <vprintfmt+0x142>
  80041d:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  800424:	85 d2                	test   %edx,%edx
  800426:	75 18                	jne    800440 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800428:	50                   	push   %eax
  800429:	68 93 29 80 00       	push   $0x802993
  80042e:	53                   	push   %ebx
  80042f:	56                   	push   %esi
  800430:	e8 94 fe ff ff       	call   8002c9 <printfmt>
  800435:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043b:	e9 cc fe ff ff       	jmp    80030c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800440:	52                   	push   %edx
  800441:	68 75 2d 80 00       	push   $0x802d75
  800446:	53                   	push   %ebx
  800447:	56                   	push   %esi
  800448:	e8 7c fe ff ff       	call   8002c9 <printfmt>
  80044d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800453:	e9 b4 fe ff ff       	jmp    80030c <vprintfmt+0x26>
  800458:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80045b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045e:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 50 04             	lea    0x4(%eax),%edx
  800467:	89 55 14             	mov    %edx,0x14(%ebp)
  80046a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80046c:	85 ff                	test   %edi,%edi
  80046e:	ba 8c 29 80 00       	mov    $0x80298c,%edx
  800473:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800476:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047a:	0f 84 92 00 00 00    	je     800512 <vprintfmt+0x22c>
  800480:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800484:	0f 8e 96 00 00 00    	jle    800520 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	51                   	push   %ecx
  80048e:	57                   	push   %edi
  80048f:	e8 86 02 00 00       	call   80071a <strnlen>
  800494:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800497:	29 c1                	sub    %eax,%ecx
  800499:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80049c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	eb 0f                	jmp    8004bc <vprintfmt+0x1d6>
					putch(padc, putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	53                   	push   %ebx
  8004b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b6:	83 ef 01             	sub    $0x1,%edi
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	85 ff                	test   %edi,%edi
  8004be:	7f ed                	jg     8004ad <vprintfmt+0x1c7>
  8004c0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c6:	85 c9                	test   %ecx,%ecx
  8004c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cd:	0f 49 c1             	cmovns %ecx,%eax
  8004d0:	29 c1                	sub    %eax,%ecx
  8004d2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004db:	89 cb                	mov    %ecx,%ebx
  8004dd:	eb 4d                	jmp    80052c <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004df:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e3:	74 1b                	je     800500 <vprintfmt+0x21a>
  8004e5:	0f be c0             	movsbl %al,%eax
  8004e8:	83 e8 20             	sub    $0x20,%eax
  8004eb:	83 f8 5e             	cmp    $0x5e,%eax
  8004ee:	76 10                	jbe    800500 <vprintfmt+0x21a>
					putch('?', putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	ff 75 0c             	pushl  0xc(%ebp)
  8004f6:	6a 3f                	push   $0x3f
  8004f8:	ff 55 08             	call   *0x8(%ebp)
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	eb 0d                	jmp    80050d <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	ff 75 0c             	pushl  0xc(%ebp)
  800506:	52                   	push   %edx
  800507:	ff 55 08             	call   *0x8(%ebp)
  80050a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050d:	83 eb 01             	sub    $0x1,%ebx
  800510:	eb 1a                	jmp    80052c <vprintfmt+0x246>
  800512:	89 75 08             	mov    %esi,0x8(%ebp)
  800515:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800518:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051e:	eb 0c                	jmp    80052c <vprintfmt+0x246>
  800520:	89 75 08             	mov    %esi,0x8(%ebp)
  800523:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800526:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800529:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052c:	83 c7 01             	add    $0x1,%edi
  80052f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800533:	0f be d0             	movsbl %al,%edx
  800536:	85 d2                	test   %edx,%edx
  800538:	74 23                	je     80055d <vprintfmt+0x277>
  80053a:	85 f6                	test   %esi,%esi
  80053c:	78 a1                	js     8004df <vprintfmt+0x1f9>
  80053e:	83 ee 01             	sub    $0x1,%esi
  800541:	79 9c                	jns    8004df <vprintfmt+0x1f9>
  800543:	89 df                	mov    %ebx,%edi
  800545:	8b 75 08             	mov    0x8(%ebp),%esi
  800548:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054b:	eb 18                	jmp    800565 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	53                   	push   %ebx
  800551:	6a 20                	push   $0x20
  800553:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800555:	83 ef 01             	sub    $0x1,%edi
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	eb 08                	jmp    800565 <vprintfmt+0x27f>
  80055d:	89 df                	mov    %ebx,%edi
  80055f:	8b 75 08             	mov    0x8(%ebp),%esi
  800562:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800565:	85 ff                	test   %edi,%edi
  800567:	7f e4                	jg     80054d <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056c:	e9 9b fd ff ff       	jmp    80030c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800571:	83 fa 01             	cmp    $0x1,%edx
  800574:	7e 16                	jle    80058c <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 08             	lea    0x8(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 50 04             	mov    0x4(%eax),%edx
  800582:	8b 00                	mov    (%eax),%eax
  800584:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800587:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058a:	eb 32                	jmp    8005be <vprintfmt+0x2d8>
	else if (lflag)
  80058c:	85 d2                	test   %edx,%edx
  80058e:	74 18                	je     8005a8 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 00                	mov    (%eax),%eax
  80059b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059e:	89 c1                	mov    %eax,%ecx
  8005a0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a6:	eb 16                	jmp    8005be <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	8b 00                	mov    (%eax),%eax
  8005b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b6:	89 c1                	mov    %eax,%ecx
  8005b8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005bb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005be:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cd:	79 74                	jns    800643 <vprintfmt+0x35d>
				putch('-', putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	53                   	push   %ebx
  8005d3:	6a 2d                	push   $0x2d
  8005d5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005da:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005dd:	f7 d8                	neg    %eax
  8005df:	83 d2 00             	adc    $0x0,%edx
  8005e2:	f7 da                	neg    %edx
  8005e4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ec:	eb 55                	jmp    800643 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f1:	e8 7c fc ff ff       	call   800272 <getuint>
			base = 10;
  8005f6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005fb:	eb 46                	jmp    800643 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800600:	e8 6d fc ff ff       	call   800272 <getuint>
                        base = 8;
  800605:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80060a:	eb 37                	jmp    800643 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	6a 30                	push   $0x30
  800612:	ff d6                	call   *%esi
			putch('x', putdat);
  800614:	83 c4 08             	add    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	6a 78                	push   $0x78
  80061a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800625:	8b 00                	mov    (%eax),%eax
  800627:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800634:	eb 0d                	jmp    800643 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
  800639:	e8 34 fc ff ff       	call   800272 <getuint>
			base = 16;
  80063e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800643:	83 ec 0c             	sub    $0xc,%esp
  800646:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80064a:	57                   	push   %edi
  80064b:	ff 75 e0             	pushl  -0x20(%ebp)
  80064e:	51                   	push   %ecx
  80064f:	52                   	push   %edx
  800650:	50                   	push   %eax
  800651:	89 da                	mov    %ebx,%edx
  800653:	89 f0                	mov    %esi,%eax
  800655:	e8 6e fb ff ff       	call   8001c8 <printnum>
			break;
  80065a:	83 c4 20             	add    $0x20,%esp
  80065d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800660:	e9 a7 fc ff ff       	jmp    80030c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	53                   	push   %ebx
  800669:	51                   	push   %ecx
  80066a:	ff d6                	call   *%esi
			break;
  80066c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800672:	e9 95 fc ff ff       	jmp    80030c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	53                   	push   %ebx
  80067b:	6a 25                	push   $0x25
  80067d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067f:	83 c4 10             	add    $0x10,%esp
  800682:	eb 03                	jmp    800687 <vprintfmt+0x3a1>
  800684:	83 ef 01             	sub    $0x1,%edi
  800687:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80068b:	75 f7                	jne    800684 <vprintfmt+0x39e>
  80068d:	e9 7a fc ff ff       	jmp    80030c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800692:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800695:	5b                   	pop    %ebx
  800696:	5e                   	pop    %esi
  800697:	5f                   	pop    %edi
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    

0080069a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 18             	sub    $0x18,%esp
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b7:	85 c0                	test   %eax,%eax
  8006b9:	74 26                	je     8006e1 <vsnprintf+0x47>
  8006bb:	85 d2                	test   %edx,%edx
  8006bd:	7e 22                	jle    8006e1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bf:	ff 75 14             	pushl  0x14(%ebp)
  8006c2:	ff 75 10             	pushl  0x10(%ebp)
  8006c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c8:	50                   	push   %eax
  8006c9:	68 ac 02 80 00       	push   $0x8002ac
  8006ce:	e8 13 fc ff ff       	call   8002e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	eb 05                	jmp    8006e6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e6:	c9                   	leave  
  8006e7:	c3                   	ret    

008006e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f1:	50                   	push   %eax
  8006f2:	ff 75 10             	pushl  0x10(%ebp)
  8006f5:	ff 75 0c             	pushl  0xc(%ebp)
  8006f8:	ff 75 08             	pushl  0x8(%ebp)
  8006fb:	e8 9a ff ff ff       	call   80069a <vsnprintf>
	va_end(ap);

	return rc;
}
  800700:	c9                   	leave  
  800701:	c3                   	ret    

00800702 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800708:	b8 00 00 00 00       	mov    $0x0,%eax
  80070d:	eb 03                	jmp    800712 <strlen+0x10>
		n++;
  80070f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800712:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800716:	75 f7                	jne    80070f <strlen+0xd>
		n++;
	return n;
}
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800720:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800723:	ba 00 00 00 00       	mov    $0x0,%edx
  800728:	eb 03                	jmp    80072d <strnlen+0x13>
		n++;
  80072a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072d:	39 c2                	cmp    %eax,%edx
  80072f:	74 08                	je     800739 <strnlen+0x1f>
  800731:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800735:	75 f3                	jne    80072a <strnlen+0x10>
  800737:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	8b 45 08             	mov    0x8(%ebp),%eax
  800742:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800745:	89 c2                	mov    %eax,%edx
  800747:	83 c2 01             	add    $0x1,%edx
  80074a:	83 c1 01             	add    $0x1,%ecx
  80074d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800751:	88 5a ff             	mov    %bl,-0x1(%edx)
  800754:	84 db                	test   %bl,%bl
  800756:	75 ef                	jne    800747 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800758:	5b                   	pop    %ebx
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	53                   	push   %ebx
  80075f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800762:	53                   	push   %ebx
  800763:	e8 9a ff ff ff       	call   800702 <strlen>
  800768:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	01 d8                	add    %ebx,%eax
  800770:	50                   	push   %eax
  800771:	e8 c5 ff ff ff       	call   80073b <strcpy>
	return dst;
}
  800776:	89 d8                	mov    %ebx,%eax
  800778:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	56                   	push   %esi
  800781:	53                   	push   %ebx
  800782:	8b 75 08             	mov    0x8(%ebp),%esi
  800785:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800788:	89 f3                	mov    %esi,%ebx
  80078a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078d:	89 f2                	mov    %esi,%edx
  80078f:	eb 0f                	jmp    8007a0 <strncpy+0x23>
		*dst++ = *src;
  800791:	83 c2 01             	add    $0x1,%edx
  800794:	0f b6 01             	movzbl (%ecx),%eax
  800797:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079a:	80 39 01             	cmpb   $0x1,(%ecx)
  80079d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a0:	39 da                	cmp    %ebx,%edx
  8007a2:	75 ed                	jne    800791 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a4:	89 f0                	mov    %esi,%eax
  8007a6:	5b                   	pop    %ebx
  8007a7:	5e                   	pop    %esi
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	56                   	push   %esi
  8007ae:	53                   	push   %ebx
  8007af:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b5:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ba:	85 d2                	test   %edx,%edx
  8007bc:	74 21                	je     8007df <strlcpy+0x35>
  8007be:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c2:	89 f2                	mov    %esi,%edx
  8007c4:	eb 09                	jmp    8007cf <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c6:	83 c2 01             	add    $0x1,%edx
  8007c9:	83 c1 01             	add    $0x1,%ecx
  8007cc:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007cf:	39 c2                	cmp    %eax,%edx
  8007d1:	74 09                	je     8007dc <strlcpy+0x32>
  8007d3:	0f b6 19             	movzbl (%ecx),%ebx
  8007d6:	84 db                	test   %bl,%bl
  8007d8:	75 ec                	jne    8007c6 <strlcpy+0x1c>
  8007da:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007dc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007df:	29 f0                	sub    %esi,%eax
}
  8007e1:	5b                   	pop    %ebx
  8007e2:	5e                   	pop    %esi
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ee:	eb 06                	jmp    8007f6 <strcmp+0x11>
		p++, q++;
  8007f0:	83 c1 01             	add    $0x1,%ecx
  8007f3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f6:	0f b6 01             	movzbl (%ecx),%eax
  8007f9:	84 c0                	test   %al,%al
  8007fb:	74 04                	je     800801 <strcmp+0x1c>
  8007fd:	3a 02                	cmp    (%edx),%al
  8007ff:	74 ef                	je     8007f0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800801:	0f b6 c0             	movzbl %al,%eax
  800804:	0f b6 12             	movzbl (%edx),%edx
  800807:	29 d0                	sub    %edx,%eax
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
  800815:	89 c3                	mov    %eax,%ebx
  800817:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80081a:	eb 06                	jmp    800822 <strncmp+0x17>
		n--, p++, q++;
  80081c:	83 c0 01             	add    $0x1,%eax
  80081f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800822:	39 d8                	cmp    %ebx,%eax
  800824:	74 15                	je     80083b <strncmp+0x30>
  800826:	0f b6 08             	movzbl (%eax),%ecx
  800829:	84 c9                	test   %cl,%cl
  80082b:	74 04                	je     800831 <strncmp+0x26>
  80082d:	3a 0a                	cmp    (%edx),%cl
  80082f:	74 eb                	je     80081c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800831:	0f b6 00             	movzbl (%eax),%eax
  800834:	0f b6 12             	movzbl (%edx),%edx
  800837:	29 d0                	sub    %edx,%eax
  800839:	eb 05                	jmp    800840 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800840:	5b                   	pop    %ebx
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084d:	eb 07                	jmp    800856 <strchr+0x13>
		if (*s == c)
  80084f:	38 ca                	cmp    %cl,%dl
  800851:	74 0f                	je     800862 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800853:	83 c0 01             	add    $0x1,%eax
  800856:	0f b6 10             	movzbl (%eax),%edx
  800859:	84 d2                	test   %dl,%dl
  80085b:	75 f2                	jne    80084f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086e:	eb 03                	jmp    800873 <strfind+0xf>
  800870:	83 c0 01             	add    $0x1,%eax
  800873:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800876:	84 d2                	test   %dl,%dl
  800878:	74 04                	je     80087e <strfind+0x1a>
  80087a:	38 ca                	cmp    %cl,%dl
  80087c:	75 f2                	jne    800870 <strfind+0xc>
			break;
	return (char *) s;
}
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	57                   	push   %edi
  800884:	56                   	push   %esi
  800885:	53                   	push   %ebx
  800886:	8b 7d 08             	mov    0x8(%ebp),%edi
  800889:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088c:	85 c9                	test   %ecx,%ecx
  80088e:	74 36                	je     8008c6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800890:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800896:	75 28                	jne    8008c0 <memset+0x40>
  800898:	f6 c1 03             	test   $0x3,%cl
  80089b:	75 23                	jne    8008c0 <memset+0x40>
		c &= 0xFF;
  80089d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a1:	89 d3                	mov    %edx,%ebx
  8008a3:	c1 e3 08             	shl    $0x8,%ebx
  8008a6:	89 d6                	mov    %edx,%esi
  8008a8:	c1 e6 18             	shl    $0x18,%esi
  8008ab:	89 d0                	mov    %edx,%eax
  8008ad:	c1 e0 10             	shl    $0x10,%eax
  8008b0:	09 f0                	or     %esi,%eax
  8008b2:	09 c2                	or     %eax,%edx
  8008b4:	89 d0                	mov    %edx,%eax
  8008b6:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008b8:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008bb:	fc                   	cld    
  8008bc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008be:	eb 06                	jmp    8008c6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c3:	fc                   	cld    
  8008c4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c6:	89 f8                	mov    %edi,%eax
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5f                   	pop    %edi
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	57                   	push   %edi
  8008d1:	56                   	push   %esi
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008db:	39 c6                	cmp    %eax,%esi
  8008dd:	73 35                	jae    800914 <memmove+0x47>
  8008df:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e2:	39 d0                	cmp    %edx,%eax
  8008e4:	73 2e                	jae    800914 <memmove+0x47>
		s += n;
		d += n;
  8008e6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008e9:	89 d6                	mov    %edx,%esi
  8008eb:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ed:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f3:	75 13                	jne    800908 <memmove+0x3b>
  8008f5:	f6 c1 03             	test   $0x3,%cl
  8008f8:	75 0e                	jne    800908 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008fa:	83 ef 04             	sub    $0x4,%edi
  8008fd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800900:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800903:	fd                   	std    
  800904:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800906:	eb 09                	jmp    800911 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800908:	83 ef 01             	sub    $0x1,%edi
  80090b:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090e:	fd                   	std    
  80090f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800911:	fc                   	cld    
  800912:	eb 1d                	jmp    800931 <memmove+0x64>
  800914:	89 f2                	mov    %esi,%edx
  800916:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800918:	f6 c2 03             	test   $0x3,%dl
  80091b:	75 0f                	jne    80092c <memmove+0x5f>
  80091d:	f6 c1 03             	test   $0x3,%cl
  800920:	75 0a                	jne    80092c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800922:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800925:	89 c7                	mov    %eax,%edi
  800927:	fc                   	cld    
  800928:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092a:	eb 05                	jmp    800931 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092c:	89 c7                	mov    %eax,%edi
  80092e:	fc                   	cld    
  80092f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800931:	5e                   	pop    %esi
  800932:	5f                   	pop    %edi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800938:	ff 75 10             	pushl  0x10(%ebp)
  80093b:	ff 75 0c             	pushl  0xc(%ebp)
  80093e:	ff 75 08             	pushl  0x8(%ebp)
  800941:	e8 87 ff ff ff       	call   8008cd <memmove>
}
  800946:	c9                   	leave  
  800947:	c3                   	ret    

00800948 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 55 0c             	mov    0xc(%ebp),%edx
  800953:	89 c6                	mov    %eax,%esi
  800955:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800958:	eb 1a                	jmp    800974 <memcmp+0x2c>
		if (*s1 != *s2)
  80095a:	0f b6 08             	movzbl (%eax),%ecx
  80095d:	0f b6 1a             	movzbl (%edx),%ebx
  800960:	38 d9                	cmp    %bl,%cl
  800962:	74 0a                	je     80096e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800964:	0f b6 c1             	movzbl %cl,%eax
  800967:	0f b6 db             	movzbl %bl,%ebx
  80096a:	29 d8                	sub    %ebx,%eax
  80096c:	eb 0f                	jmp    80097d <memcmp+0x35>
		s1++, s2++;
  80096e:	83 c0 01             	add    $0x1,%eax
  800971:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800974:	39 f0                	cmp    %esi,%eax
  800976:	75 e2                	jne    80095a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80098a:	89 c2                	mov    %eax,%edx
  80098c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80098f:	eb 07                	jmp    800998 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800991:	38 08                	cmp    %cl,(%eax)
  800993:	74 07                	je     80099c <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800995:	83 c0 01             	add    $0x1,%eax
  800998:	39 d0                	cmp    %edx,%eax
  80099a:	72 f5                	jb     800991 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	57                   	push   %edi
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009aa:	eb 03                	jmp    8009af <strtol+0x11>
		s++;
  8009ac:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009af:	0f b6 01             	movzbl (%ecx),%eax
  8009b2:	3c 09                	cmp    $0x9,%al
  8009b4:	74 f6                	je     8009ac <strtol+0xe>
  8009b6:	3c 20                	cmp    $0x20,%al
  8009b8:	74 f2                	je     8009ac <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ba:	3c 2b                	cmp    $0x2b,%al
  8009bc:	75 0a                	jne    8009c8 <strtol+0x2a>
		s++;
  8009be:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c6:	eb 10                	jmp    8009d8 <strtol+0x3a>
  8009c8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009cd:	3c 2d                	cmp    $0x2d,%al
  8009cf:	75 07                	jne    8009d8 <strtol+0x3a>
		s++, neg = 1;
  8009d1:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009d4:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d8:	85 db                	test   %ebx,%ebx
  8009da:	0f 94 c0             	sete   %al
  8009dd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e3:	75 19                	jne    8009fe <strtol+0x60>
  8009e5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e8:	75 14                	jne    8009fe <strtol+0x60>
  8009ea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ee:	0f 85 82 00 00 00    	jne    800a76 <strtol+0xd8>
		s += 2, base = 16;
  8009f4:	83 c1 02             	add    $0x2,%ecx
  8009f7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fc:	eb 16                	jmp    800a14 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009fe:	84 c0                	test   %al,%al
  800a00:	74 12                	je     800a14 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a02:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a07:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0a:	75 08                	jne    800a14 <strtol+0x76>
		s++, base = 8;
  800a0c:	83 c1 01             	add    $0x1,%ecx
  800a0f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
  800a19:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1c:	0f b6 11             	movzbl (%ecx),%edx
  800a1f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a22:	89 f3                	mov    %esi,%ebx
  800a24:	80 fb 09             	cmp    $0x9,%bl
  800a27:	77 08                	ja     800a31 <strtol+0x93>
			dig = *s - '0';
  800a29:	0f be d2             	movsbl %dl,%edx
  800a2c:	83 ea 30             	sub    $0x30,%edx
  800a2f:	eb 22                	jmp    800a53 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a31:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a34:	89 f3                	mov    %esi,%ebx
  800a36:	80 fb 19             	cmp    $0x19,%bl
  800a39:	77 08                	ja     800a43 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a3b:	0f be d2             	movsbl %dl,%edx
  800a3e:	83 ea 57             	sub    $0x57,%edx
  800a41:	eb 10                	jmp    800a53 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a43:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a46:	89 f3                	mov    %esi,%ebx
  800a48:	80 fb 19             	cmp    $0x19,%bl
  800a4b:	77 16                	ja     800a63 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a4d:	0f be d2             	movsbl %dl,%edx
  800a50:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a53:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a56:	7d 0f                	jge    800a67 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a61:	eb b9                	jmp    800a1c <strtol+0x7e>
  800a63:	89 c2                	mov    %eax,%edx
  800a65:	eb 02                	jmp    800a69 <strtol+0xcb>
  800a67:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6d:	74 0d                	je     800a7c <strtol+0xde>
		*endptr = (char *) s;
  800a6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a72:	89 0e                	mov    %ecx,(%esi)
  800a74:	eb 06                	jmp    800a7c <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a76:	84 c0                	test   %al,%al
  800a78:	75 92                	jne    800a0c <strtol+0x6e>
  800a7a:	eb 98                	jmp    800a14 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a7c:	f7 da                	neg    %edx
  800a7e:	85 ff                	test   %edi,%edi
  800a80:	0f 45 c2             	cmovne %edx,%eax
}
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5f                   	pop    %edi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a96:	8b 55 08             	mov    0x8(%ebp),%edx
  800a99:	89 c3                	mov    %eax,%ebx
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	89 c6                	mov    %eax,%esi
  800a9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800aac:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab6:	89 d1                	mov    %edx,%ecx
  800ab8:	89 d3                	mov    %edx,%ebx
  800aba:	89 d7                	mov    %edx,%edi
  800abc:	89 d6                	mov    %edx,%esi
  800abe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800ace:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad8:	8b 55 08             	mov    0x8(%ebp),%edx
  800adb:	89 cb                	mov    %ecx,%ebx
  800add:	89 cf                	mov    %ecx,%edi
  800adf:	89 ce                	mov    %ecx,%esi
  800ae1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	7e 17                	jle    800afe <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae7:	83 ec 0c             	sub    $0xc,%esp
  800aea:	50                   	push   %eax
  800aeb:	6a 03                	push   $0x3
  800aed:	68 9f 2c 80 00       	push   $0x802c9f
  800af2:	6a 22                	push   $0x22
  800af4:	68 bc 2c 80 00       	push   $0x802cbc
  800af9:	e8 dd f5 ff ff       	call   8000db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b11:	b8 02 00 00 00       	mov    $0x2,%eax
  800b16:	89 d1                	mov    %edx,%ecx
  800b18:	89 d3                	mov    %edx,%ebx
  800b1a:	89 d7                	mov    %edx,%edi
  800b1c:	89 d6                	mov    %edx,%esi
  800b1e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_yield>:

void
sys_yield(void)
{      
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b35:	89 d1                	mov    %edx,%ecx
  800b37:	89 d3                	mov    %edx,%ebx
  800b39:	89 d7                	mov    %edx,%edi
  800b3b:	89 d6                	mov    %edx,%esi
  800b3d:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b4d:	be 00 00 00 00       	mov    $0x0,%esi
  800b52:	b8 04 00 00 00       	mov    $0x4,%eax
  800b57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b60:	89 f7                	mov    %esi,%edi
  800b62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b64:	85 c0                	test   %eax,%eax
  800b66:	7e 17                	jle    800b7f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b68:	83 ec 0c             	sub    $0xc,%esp
  800b6b:	50                   	push   %eax
  800b6c:	6a 04                	push   $0x4
  800b6e:	68 9f 2c 80 00       	push   $0x802c9f
  800b73:	6a 22                	push   $0x22
  800b75:	68 bc 2c 80 00       	push   $0x802cbc
  800b7a:	e8 5c f5 ff ff       	call   8000db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
  800b8d:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b90:	b8 05 00 00 00       	mov    $0x5,%eax
  800b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba6:	85 c0                	test   %eax,%eax
  800ba8:	7e 17                	jle    800bc1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baa:	83 ec 0c             	sub    $0xc,%esp
  800bad:	50                   	push   %eax
  800bae:	6a 05                	push   $0x5
  800bb0:	68 9f 2c 80 00       	push   $0x802c9f
  800bb5:	6a 22                	push   $0x22
  800bb7:	68 bc 2c 80 00       	push   $0x802cbc
  800bbc:	e8 1a f5 ff ff       	call   8000db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd7:	b8 06 00 00 00       	mov    $0x6,%eax
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	89 df                	mov    %ebx,%edi
  800be4:	89 de                	mov    %ebx,%esi
  800be6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be8:	85 c0                	test   %eax,%eax
  800bea:	7e 17                	jle    800c03 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bec:	83 ec 0c             	sub    $0xc,%esp
  800bef:	50                   	push   %eax
  800bf0:	6a 06                	push   $0x6
  800bf2:	68 9f 2c 80 00       	push   $0x802c9f
  800bf7:	6a 22                	push   $0x22
  800bf9:	68 bc 2c 80 00       	push   $0x802cbc
  800bfe:	e8 d8 f4 ff ff       	call   8000db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c19:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	89 df                	mov    %ebx,%edi
  800c26:	89 de                	mov    %ebx,%esi
  800c28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7e 17                	jle    800c45 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	50                   	push   %eax
  800c32:	6a 08                	push   $0x8
  800c34:	68 9f 2c 80 00       	push   $0x802c9f
  800c39:	6a 22                	push   $0x22
  800c3b:	68 bc 2c 80 00       	push   $0x802cbc
  800c40:	e8 96 f4 ff ff       	call   8000db <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
  800c66:	89 df                	mov    %ebx,%edi
  800c68:	89 de                	mov    %ebx,%esi
  800c6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7e 17                	jle    800c87 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	50                   	push   %eax
  800c74:	6a 09                	push   $0x9
  800c76:	68 9f 2c 80 00       	push   $0x802c9f
  800c7b:	6a 22                	push   $0x22
  800c7d:	68 bc 2c 80 00       	push   $0x802cbc
  800c82:	e8 54 f4 ff ff       	call   8000db <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	89 df                	mov    %ebx,%edi
  800caa:	89 de                	mov    %ebx,%esi
  800cac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7e 17                	jle    800cc9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	6a 0a                	push   $0xa
  800cb8:	68 9f 2c 80 00       	push   $0x802c9f
  800cbd:	6a 22                	push   $0x22
  800cbf:	68 bc 2c 80 00       	push   $0x802cbc
  800cc4:	e8 12 f4 ff ff       	call   8000db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cd7:	be 00 00 00 00       	mov    $0x0,%esi
  800cdc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cea:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ced:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cfd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d02:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	89 cb                	mov    %ecx,%ebx
  800d0c:	89 cf                	mov    %ecx,%edi
  800d0e:	89 ce                	mov    %ecx,%esi
  800d10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d12:	85 c0                	test   %eax,%eax
  800d14:	7e 17                	jle    800d2d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d16:	83 ec 0c             	sub    $0xc,%esp
  800d19:	50                   	push   %eax
  800d1a:	6a 0d                	push   $0xd
  800d1c:	68 9f 2c 80 00       	push   $0x802c9f
  800d21:	6a 22                	push   $0x22
  800d23:	68 bc 2c 80 00       	push   $0x802cbc
  800d28:	e8 ae f3 ff ff       	call   8000db <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d40:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d45:	89 d1                	mov    %edx,%ecx
  800d47:	89 d3                	mov    %edx,%ebx
  800d49:	89 d7                	mov    %edx,%edi
  800d4b:	89 d6                	mov    %edx,%esi
  800d4d:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d62:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d67:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6a:	89 cb                	mov    %ecx,%ebx
  800d6c:	89 cf                	mov    %ecx,%edi
  800d6e:	89 ce                	mov    %ecx,%esi
  800d70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7e 17                	jle    800d8d <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	50                   	push   %eax
  800d7a:	6a 0f                	push   $0xf
  800d7c:	68 9f 2c 80 00       	push   $0x802c9f
  800d81:	6a 22                	push   $0x22
  800d83:	68 bc 2c 80 00       	push   $0x802cbc
  800d88:	e8 4e f3 ff ff       	call   8000db <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <sys_recv>:

int
sys_recv(void *addr)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da3:	b8 10 00 00 00       	mov    $0x10,%eax
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	89 cb                	mov    %ecx,%ebx
  800dad:	89 cf                	mov    %ecx,%edi
  800daf:	89 ce                	mov    %ecx,%esi
  800db1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db3:	85 c0                	test   %eax,%eax
  800db5:	7e 17                	jle    800dce <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db7:	83 ec 0c             	sub    $0xc,%esp
  800dba:	50                   	push   %eax
  800dbb:	6a 10                	push   $0x10
  800dbd:	68 9f 2c 80 00       	push   $0x802c9f
  800dc2:	6a 22                	push   $0x22
  800dc4:	68 bc 2c 80 00       	push   $0x802cbc
  800dc9:	e8 0d f3 ff ff       	call   8000db <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800dce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	05 00 00 00 30       	add    $0x30000000,%eax
  800de1:	c1 e8 0c             	shr    $0xc,%eax
}
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800df1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e03:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e08:	89 c2                	mov    %eax,%edx
  800e0a:	c1 ea 16             	shr    $0x16,%edx
  800e0d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e14:	f6 c2 01             	test   $0x1,%dl
  800e17:	74 11                	je     800e2a <fd_alloc+0x2d>
  800e19:	89 c2                	mov    %eax,%edx
  800e1b:	c1 ea 0c             	shr    $0xc,%edx
  800e1e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e25:	f6 c2 01             	test   $0x1,%dl
  800e28:	75 09                	jne    800e33 <fd_alloc+0x36>
			*fd_store = fd;
  800e2a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e31:	eb 17                	jmp    800e4a <fd_alloc+0x4d>
  800e33:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e38:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e3d:	75 c9                	jne    800e08 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e3f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e45:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e52:	83 f8 1f             	cmp    $0x1f,%eax
  800e55:	77 36                	ja     800e8d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e57:	c1 e0 0c             	shl    $0xc,%eax
  800e5a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e5f:	89 c2                	mov    %eax,%edx
  800e61:	c1 ea 16             	shr    $0x16,%edx
  800e64:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6b:	f6 c2 01             	test   $0x1,%dl
  800e6e:	74 24                	je     800e94 <fd_lookup+0x48>
  800e70:	89 c2                	mov    %eax,%edx
  800e72:	c1 ea 0c             	shr    $0xc,%edx
  800e75:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7c:	f6 c2 01             	test   $0x1,%dl
  800e7f:	74 1a                	je     800e9b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e81:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e84:	89 02                	mov    %eax,(%edx)
	return 0;
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8b:	eb 13                	jmp    800ea0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e92:	eb 0c                	jmp    800ea0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e99:	eb 05                	jmp    800ea0 <fd_lookup+0x54>
  800e9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	83 ec 08             	sub    $0x8,%esp
  800ea8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800eab:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb0:	eb 13                	jmp    800ec5 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800eb2:	39 08                	cmp    %ecx,(%eax)
  800eb4:	75 0c                	jne    800ec2 <dev_lookup+0x20>
			*dev = devtab[i];
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec0:	eb 36                	jmp    800ef8 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ec2:	83 c2 01             	add    $0x1,%edx
  800ec5:	8b 04 95 48 2d 80 00 	mov    0x802d48(,%edx,4),%eax
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	75 e2                	jne    800eb2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ed0:	a1 08 40 80 00       	mov    0x804008,%eax
  800ed5:	8b 40 48             	mov    0x48(%eax),%eax
  800ed8:	83 ec 04             	sub    $0x4,%esp
  800edb:	51                   	push   %ecx
  800edc:	50                   	push   %eax
  800edd:	68 cc 2c 80 00       	push   $0x802ccc
  800ee2:	e8 cd f2 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  800ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ef0:	83 c4 10             	add    $0x10,%esp
  800ef3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ef8:	c9                   	leave  
  800ef9:	c3                   	ret    

00800efa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	83 ec 10             	sub    $0x10,%esp
  800f02:	8b 75 08             	mov    0x8(%ebp),%esi
  800f05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f0b:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f0c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f12:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f15:	50                   	push   %eax
  800f16:	e8 31 ff ff ff       	call   800e4c <fd_lookup>
  800f1b:	83 c4 08             	add    $0x8,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	78 05                	js     800f27 <fd_close+0x2d>
	    || fd != fd2)
  800f22:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f25:	74 0c                	je     800f33 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f27:	84 db                	test   %bl,%bl
  800f29:	ba 00 00 00 00       	mov    $0x0,%edx
  800f2e:	0f 44 c2             	cmove  %edx,%eax
  800f31:	eb 41                	jmp    800f74 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f33:	83 ec 08             	sub    $0x8,%esp
  800f36:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f39:	50                   	push   %eax
  800f3a:	ff 36                	pushl  (%esi)
  800f3c:	e8 61 ff ff ff       	call   800ea2 <dev_lookup>
  800f41:	89 c3                	mov    %eax,%ebx
  800f43:	83 c4 10             	add    $0x10,%esp
  800f46:	85 c0                	test   %eax,%eax
  800f48:	78 1a                	js     800f64 <fd_close+0x6a>
		if (dev->dev_close)
  800f4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f50:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f55:	85 c0                	test   %eax,%eax
  800f57:	74 0b                	je     800f64 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f59:	83 ec 0c             	sub    $0xc,%esp
  800f5c:	56                   	push   %esi
  800f5d:	ff d0                	call   *%eax
  800f5f:	89 c3                	mov    %eax,%ebx
  800f61:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f64:	83 ec 08             	sub    $0x8,%esp
  800f67:	56                   	push   %esi
  800f68:	6a 00                	push   $0x0
  800f6a:	e8 5a fc ff ff       	call   800bc9 <sys_page_unmap>
	return r;
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	89 d8                	mov    %ebx,%eax
}
  800f74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f84:	50                   	push   %eax
  800f85:	ff 75 08             	pushl  0x8(%ebp)
  800f88:	e8 bf fe ff ff       	call   800e4c <fd_lookup>
  800f8d:	89 c2                	mov    %eax,%edx
  800f8f:	83 c4 08             	add    $0x8,%esp
  800f92:	85 d2                	test   %edx,%edx
  800f94:	78 10                	js     800fa6 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800f96:	83 ec 08             	sub    $0x8,%esp
  800f99:	6a 01                	push   $0x1
  800f9b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f9e:	e8 57 ff ff ff       	call   800efa <fd_close>
  800fa3:	83 c4 10             	add    $0x10,%esp
}
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <close_all>:

void
close_all(void)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	53                   	push   %ebx
  800fac:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800faf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fb4:	83 ec 0c             	sub    $0xc,%esp
  800fb7:	53                   	push   %ebx
  800fb8:	e8 be ff ff ff       	call   800f7b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fbd:	83 c3 01             	add    $0x1,%ebx
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	83 fb 20             	cmp    $0x20,%ebx
  800fc6:	75 ec                	jne    800fb4 <close_all+0xc>
		close(i);
}
  800fc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fcb:	c9                   	leave  
  800fcc:	c3                   	ret    

00800fcd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 2c             	sub    $0x2c,%esp
  800fd6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fd9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fdc:	50                   	push   %eax
  800fdd:	ff 75 08             	pushl  0x8(%ebp)
  800fe0:	e8 67 fe ff ff       	call   800e4c <fd_lookup>
  800fe5:	89 c2                	mov    %eax,%edx
  800fe7:	83 c4 08             	add    $0x8,%esp
  800fea:	85 d2                	test   %edx,%edx
  800fec:	0f 88 c1 00 00 00    	js     8010b3 <dup+0xe6>
		return r;
	close(newfdnum);
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	56                   	push   %esi
  800ff6:	e8 80 ff ff ff       	call   800f7b <close>

	newfd = INDEX2FD(newfdnum);
  800ffb:	89 f3                	mov    %esi,%ebx
  800ffd:	c1 e3 0c             	shl    $0xc,%ebx
  801000:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801006:	83 c4 04             	add    $0x4,%esp
  801009:	ff 75 e4             	pushl  -0x1c(%ebp)
  80100c:	e8 d5 fd ff ff       	call   800de6 <fd2data>
  801011:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801013:	89 1c 24             	mov    %ebx,(%esp)
  801016:	e8 cb fd ff ff       	call   800de6 <fd2data>
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801021:	89 f8                	mov    %edi,%eax
  801023:	c1 e8 16             	shr    $0x16,%eax
  801026:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80102d:	a8 01                	test   $0x1,%al
  80102f:	74 37                	je     801068 <dup+0x9b>
  801031:	89 f8                	mov    %edi,%eax
  801033:	c1 e8 0c             	shr    $0xc,%eax
  801036:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103d:	f6 c2 01             	test   $0x1,%dl
  801040:	74 26                	je     801068 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801042:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801049:	83 ec 0c             	sub    $0xc,%esp
  80104c:	25 07 0e 00 00       	and    $0xe07,%eax
  801051:	50                   	push   %eax
  801052:	ff 75 d4             	pushl  -0x2c(%ebp)
  801055:	6a 00                	push   $0x0
  801057:	57                   	push   %edi
  801058:	6a 00                	push   $0x0
  80105a:	e8 28 fb ff ff       	call   800b87 <sys_page_map>
  80105f:	89 c7                	mov    %eax,%edi
  801061:	83 c4 20             	add    $0x20,%esp
  801064:	85 c0                	test   %eax,%eax
  801066:	78 2e                	js     801096 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801068:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80106b:	89 d0                	mov    %edx,%eax
  80106d:	c1 e8 0c             	shr    $0xc,%eax
  801070:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	25 07 0e 00 00       	and    $0xe07,%eax
  80107f:	50                   	push   %eax
  801080:	53                   	push   %ebx
  801081:	6a 00                	push   $0x0
  801083:	52                   	push   %edx
  801084:	6a 00                	push   $0x0
  801086:	e8 fc fa ff ff       	call   800b87 <sys_page_map>
  80108b:	89 c7                	mov    %eax,%edi
  80108d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801090:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801092:	85 ff                	test   %edi,%edi
  801094:	79 1d                	jns    8010b3 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801096:	83 ec 08             	sub    $0x8,%esp
  801099:	53                   	push   %ebx
  80109a:	6a 00                	push   $0x0
  80109c:	e8 28 fb ff ff       	call   800bc9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010a1:	83 c4 08             	add    $0x8,%esp
  8010a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 1b fb ff ff       	call   800bc9 <sys_page_unmap>
	return r;
  8010ae:	83 c4 10             	add    $0x10,%esp
  8010b1:	89 f8                	mov    %edi,%eax
}
  8010b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b6:	5b                   	pop    %ebx
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	53                   	push   %ebx
  8010bf:	83 ec 14             	sub    $0x14,%esp
  8010c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c8:	50                   	push   %eax
  8010c9:	53                   	push   %ebx
  8010ca:	e8 7d fd ff ff       	call   800e4c <fd_lookup>
  8010cf:	83 c4 08             	add    $0x8,%esp
  8010d2:	89 c2                	mov    %eax,%edx
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	78 6d                	js     801145 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d8:	83 ec 08             	sub    $0x8,%esp
  8010db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010de:	50                   	push   %eax
  8010df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e2:	ff 30                	pushl  (%eax)
  8010e4:	e8 b9 fd ff ff       	call   800ea2 <dev_lookup>
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	78 4c                	js     80113c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010f0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010f3:	8b 42 08             	mov    0x8(%edx),%eax
  8010f6:	83 e0 03             	and    $0x3,%eax
  8010f9:	83 f8 01             	cmp    $0x1,%eax
  8010fc:	75 21                	jne    80111f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010fe:	a1 08 40 80 00       	mov    0x804008,%eax
  801103:	8b 40 48             	mov    0x48(%eax),%eax
  801106:	83 ec 04             	sub    $0x4,%esp
  801109:	53                   	push   %ebx
  80110a:	50                   	push   %eax
  80110b:	68 0d 2d 80 00       	push   $0x802d0d
  801110:	e8 9f f0 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80111d:	eb 26                	jmp    801145 <read+0x8a>
	}
	if (!dev->dev_read)
  80111f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801122:	8b 40 08             	mov    0x8(%eax),%eax
  801125:	85 c0                	test   %eax,%eax
  801127:	74 17                	je     801140 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801129:	83 ec 04             	sub    $0x4,%esp
  80112c:	ff 75 10             	pushl  0x10(%ebp)
  80112f:	ff 75 0c             	pushl  0xc(%ebp)
  801132:	52                   	push   %edx
  801133:	ff d0                	call   *%eax
  801135:	89 c2                	mov    %eax,%edx
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	eb 09                	jmp    801145 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113c:	89 c2                	mov    %eax,%edx
  80113e:	eb 05                	jmp    801145 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801140:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801145:	89 d0                	mov    %edx,%eax
  801147:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114a:	c9                   	leave  
  80114b:	c3                   	ret    

0080114c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	57                   	push   %edi
  801150:	56                   	push   %esi
  801151:	53                   	push   %ebx
  801152:	83 ec 0c             	sub    $0xc,%esp
  801155:	8b 7d 08             	mov    0x8(%ebp),%edi
  801158:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80115b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801160:	eb 21                	jmp    801183 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801162:	83 ec 04             	sub    $0x4,%esp
  801165:	89 f0                	mov    %esi,%eax
  801167:	29 d8                	sub    %ebx,%eax
  801169:	50                   	push   %eax
  80116a:	89 d8                	mov    %ebx,%eax
  80116c:	03 45 0c             	add    0xc(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	57                   	push   %edi
  801171:	e8 45 ff ff ff       	call   8010bb <read>
		if (m < 0)
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	85 c0                	test   %eax,%eax
  80117b:	78 0c                	js     801189 <readn+0x3d>
			return m;
		if (m == 0)
  80117d:	85 c0                	test   %eax,%eax
  80117f:	74 06                	je     801187 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801181:	01 c3                	add    %eax,%ebx
  801183:	39 f3                	cmp    %esi,%ebx
  801185:	72 db                	jb     801162 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801187:	89 d8                	mov    %ebx,%eax
}
  801189:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5e                   	pop    %esi
  80118e:	5f                   	pop    %edi
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	53                   	push   %ebx
  801195:	83 ec 14             	sub    $0x14,%esp
  801198:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119e:	50                   	push   %eax
  80119f:	53                   	push   %ebx
  8011a0:	e8 a7 fc ff ff       	call   800e4c <fd_lookup>
  8011a5:	83 c4 08             	add    $0x8,%esp
  8011a8:	89 c2                	mov    %eax,%edx
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 68                	js     801216 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ae:	83 ec 08             	sub    $0x8,%esp
  8011b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b4:	50                   	push   %eax
  8011b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b8:	ff 30                	pushl  (%eax)
  8011ba:	e8 e3 fc ff ff       	call   800ea2 <dev_lookup>
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 47                	js     80120d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011cd:	75 21                	jne    8011f0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cf:	a1 08 40 80 00       	mov    0x804008,%eax
  8011d4:	8b 40 48             	mov    0x48(%eax),%eax
  8011d7:	83 ec 04             	sub    $0x4,%esp
  8011da:	53                   	push   %ebx
  8011db:	50                   	push   %eax
  8011dc:	68 29 2d 80 00       	push   $0x802d29
  8011e1:	e8 ce ef ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ee:	eb 26                	jmp    801216 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f3:	8b 52 0c             	mov    0xc(%edx),%edx
  8011f6:	85 d2                	test   %edx,%edx
  8011f8:	74 17                	je     801211 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011fa:	83 ec 04             	sub    $0x4,%esp
  8011fd:	ff 75 10             	pushl  0x10(%ebp)
  801200:	ff 75 0c             	pushl  0xc(%ebp)
  801203:	50                   	push   %eax
  801204:	ff d2                	call   *%edx
  801206:	89 c2                	mov    %eax,%edx
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	eb 09                	jmp    801216 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	eb 05                	jmp    801216 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801211:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801216:	89 d0                	mov    %edx,%eax
  801218:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    

0080121d <seek>:

int
seek(int fdnum, off_t offset)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801223:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801226:	50                   	push   %eax
  801227:	ff 75 08             	pushl  0x8(%ebp)
  80122a:	e8 1d fc ff ff       	call   800e4c <fd_lookup>
  80122f:	83 c4 08             	add    $0x8,%esp
  801232:	85 c0                	test   %eax,%eax
  801234:	78 0e                	js     801244 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801236:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80123f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801244:	c9                   	leave  
  801245:	c3                   	ret    

00801246 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	53                   	push   %ebx
  80124a:	83 ec 14             	sub    $0x14,%esp
  80124d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801250:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801253:	50                   	push   %eax
  801254:	53                   	push   %ebx
  801255:	e8 f2 fb ff ff       	call   800e4c <fd_lookup>
  80125a:	83 c4 08             	add    $0x8,%esp
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 65                	js     8012c8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801263:	83 ec 08             	sub    $0x8,%esp
  801266:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801269:	50                   	push   %eax
  80126a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126d:	ff 30                	pushl  (%eax)
  80126f:	e8 2e fc ff ff       	call   800ea2 <dev_lookup>
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	78 44                	js     8012bf <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80127b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801282:	75 21                	jne    8012a5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801284:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801289:	8b 40 48             	mov    0x48(%eax),%eax
  80128c:	83 ec 04             	sub    $0x4,%esp
  80128f:	53                   	push   %ebx
  801290:	50                   	push   %eax
  801291:	68 ec 2c 80 00       	push   $0x802cec
  801296:	e8 19 ef ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a3:	eb 23                	jmp    8012c8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a8:	8b 52 18             	mov    0x18(%edx),%edx
  8012ab:	85 d2                	test   %edx,%edx
  8012ad:	74 14                	je     8012c3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012af:	83 ec 08             	sub    $0x8,%esp
  8012b2:	ff 75 0c             	pushl  0xc(%ebp)
  8012b5:	50                   	push   %eax
  8012b6:	ff d2                	call   *%edx
  8012b8:	89 c2                	mov    %eax,%edx
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	eb 09                	jmp    8012c8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bf:	89 c2                	mov    %eax,%edx
  8012c1:	eb 05                	jmp    8012c8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012c8:	89 d0                	mov    %edx,%eax
  8012ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	53                   	push   %ebx
  8012d3:	83 ec 14             	sub    $0x14,%esp
  8012d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012dc:	50                   	push   %eax
  8012dd:	ff 75 08             	pushl  0x8(%ebp)
  8012e0:	e8 67 fb ff ff       	call   800e4c <fd_lookup>
  8012e5:	83 c4 08             	add    $0x8,%esp
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 58                	js     801346 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f8:	ff 30                	pushl  (%eax)
  8012fa:	e8 a3 fb ff ff       	call   800ea2 <dev_lookup>
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 37                	js     80133d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801306:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801309:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80130d:	74 32                	je     801341 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80130f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801312:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801319:	00 00 00 
	stat->st_isdir = 0;
  80131c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801323:	00 00 00 
	stat->st_dev = dev;
  801326:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	53                   	push   %ebx
  801330:	ff 75 f0             	pushl  -0x10(%ebp)
  801333:	ff 50 14             	call   *0x14(%eax)
  801336:	89 c2                	mov    %eax,%edx
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	eb 09                	jmp    801346 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	eb 05                	jmp    801346 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801341:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801346:	89 d0                	mov    %edx,%eax
  801348:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134b:	c9                   	leave  
  80134c:	c3                   	ret    

0080134d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80134d:	55                   	push   %ebp
  80134e:	89 e5                	mov    %esp,%ebp
  801350:	56                   	push   %esi
  801351:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	6a 00                	push   $0x0
  801357:	ff 75 08             	pushl  0x8(%ebp)
  80135a:	e8 09 02 00 00       	call   801568 <open>
  80135f:	89 c3                	mov    %eax,%ebx
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	85 db                	test   %ebx,%ebx
  801366:	78 1b                	js     801383 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	ff 75 0c             	pushl  0xc(%ebp)
  80136e:	53                   	push   %ebx
  80136f:	e8 5b ff ff ff       	call   8012cf <fstat>
  801374:	89 c6                	mov    %eax,%esi
	close(fd);
  801376:	89 1c 24             	mov    %ebx,(%esp)
  801379:	e8 fd fb ff ff       	call   800f7b <close>
	return r;
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	89 f0                	mov    %esi,%eax
}
  801383:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801386:	5b                   	pop    %ebx
  801387:	5e                   	pop    %esi
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    

0080138a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	56                   	push   %esi
  80138e:	53                   	push   %ebx
  80138f:	89 c6                	mov    %eax,%esi
  801391:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801393:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80139a:	75 12                	jne    8013ae <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80139c:	83 ec 0c             	sub    $0xc,%esp
  80139f:	6a 01                	push   $0x1
  8013a1:	e8 30 12 00 00       	call   8025d6 <ipc_find_env>
  8013a6:	a3 00 40 80 00       	mov    %eax,0x804000
  8013ab:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ae:	6a 07                	push   $0x7
  8013b0:	68 00 50 80 00       	push   $0x805000
  8013b5:	56                   	push   %esi
  8013b6:	ff 35 00 40 80 00    	pushl  0x804000
  8013bc:	e8 c1 11 00 00       	call   802582 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013c1:	83 c4 0c             	add    $0xc,%esp
  8013c4:	6a 00                	push   $0x0
  8013c6:	53                   	push   %ebx
  8013c7:	6a 00                	push   $0x0
  8013c9:	e8 4b 11 00 00       	call   802519 <ipc_recv>
}
  8013ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    

008013d5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013db:	8b 45 08             	mov    0x8(%ebp),%eax
  8013de:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f3:	b8 02 00 00 00       	mov    $0x2,%eax
  8013f8:	e8 8d ff ff ff       	call   80138a <fsipc>
}
  8013fd:	c9                   	leave  
  8013fe:	c3                   	ret    

008013ff <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801405:	8b 45 08             	mov    0x8(%ebp),%eax
  801408:	8b 40 0c             	mov    0xc(%eax),%eax
  80140b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801410:	ba 00 00 00 00       	mov    $0x0,%edx
  801415:	b8 06 00 00 00       	mov    $0x6,%eax
  80141a:	e8 6b ff ff ff       	call   80138a <fsipc>
}
  80141f:	c9                   	leave  
  801420:	c3                   	ret    

00801421 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	53                   	push   %ebx
  801425:	83 ec 04             	sub    $0x4,%esp
  801428:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80142b:	8b 45 08             	mov    0x8(%ebp),%eax
  80142e:	8b 40 0c             	mov    0xc(%eax),%eax
  801431:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801436:	ba 00 00 00 00       	mov    $0x0,%edx
  80143b:	b8 05 00 00 00       	mov    $0x5,%eax
  801440:	e8 45 ff ff ff       	call   80138a <fsipc>
  801445:	89 c2                	mov    %eax,%edx
  801447:	85 d2                	test   %edx,%edx
  801449:	78 2c                	js     801477 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	68 00 50 80 00       	push   $0x805000
  801453:	53                   	push   %ebx
  801454:	e8 e2 f2 ff ff       	call   80073b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801459:	a1 80 50 80 00       	mov    0x805080,%eax
  80145e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801464:	a1 84 50 80 00       	mov    0x805084,%eax
  801469:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801477:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	57                   	push   %edi
  801480:	56                   	push   %esi
  801481:	53                   	push   %ebx
  801482:	83 ec 0c             	sub    $0xc,%esp
  801485:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801488:	8b 45 08             	mov    0x8(%ebp),%eax
  80148b:	8b 40 0c             	mov    0xc(%eax),%eax
  80148e:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801493:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801496:	eb 3d                	jmp    8014d5 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801498:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80149e:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8014a3:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8014a6:	83 ec 04             	sub    $0x4,%esp
  8014a9:	57                   	push   %edi
  8014aa:	53                   	push   %ebx
  8014ab:	68 08 50 80 00       	push   $0x805008
  8014b0:	e8 18 f4 ff ff       	call   8008cd <memmove>
                fsipcbuf.write.req_n = tmp; 
  8014b5:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c0:	b8 04 00 00 00       	mov    $0x4,%eax
  8014c5:	e8 c0 fe ff ff       	call   80138a <fsipc>
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 0d                	js     8014de <devfile_write+0x62>
		        return r;
                n -= tmp;
  8014d1:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8014d3:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8014d5:	85 f6                	test   %esi,%esi
  8014d7:	75 bf                	jne    801498 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8014d9:	89 d8                	mov    %ebx,%eax
  8014db:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8014de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e1:	5b                   	pop    %ebx
  8014e2:	5e                   	pop    %esi
  8014e3:	5f                   	pop    %edi
  8014e4:	5d                   	pop    %ebp
  8014e5:	c3                   	ret    

008014e6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	56                   	push   %esi
  8014ea:	53                   	push   %ebx
  8014eb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014f9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801504:	b8 03 00 00 00       	mov    $0x3,%eax
  801509:	e8 7c fe ff ff       	call   80138a <fsipc>
  80150e:	89 c3                	mov    %eax,%ebx
  801510:	85 c0                	test   %eax,%eax
  801512:	78 4b                	js     80155f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801514:	39 c6                	cmp    %eax,%esi
  801516:	73 16                	jae    80152e <devfile_read+0x48>
  801518:	68 5c 2d 80 00       	push   $0x802d5c
  80151d:	68 63 2d 80 00       	push   $0x802d63
  801522:	6a 7c                	push   $0x7c
  801524:	68 78 2d 80 00       	push   $0x802d78
  801529:	e8 ad eb ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  80152e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801533:	7e 16                	jle    80154b <devfile_read+0x65>
  801535:	68 83 2d 80 00       	push   $0x802d83
  80153a:	68 63 2d 80 00       	push   $0x802d63
  80153f:	6a 7d                	push   $0x7d
  801541:	68 78 2d 80 00       	push   $0x802d78
  801546:	e8 90 eb ff ff       	call   8000db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80154b:	83 ec 04             	sub    $0x4,%esp
  80154e:	50                   	push   %eax
  80154f:	68 00 50 80 00       	push   $0x805000
  801554:	ff 75 0c             	pushl  0xc(%ebp)
  801557:	e8 71 f3 ff ff       	call   8008cd <memmove>
	return r;
  80155c:	83 c4 10             	add    $0x10,%esp
}
  80155f:	89 d8                	mov    %ebx,%eax
  801561:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801564:	5b                   	pop    %ebx
  801565:	5e                   	pop    %esi
  801566:	5d                   	pop    %ebp
  801567:	c3                   	ret    

00801568 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	53                   	push   %ebx
  80156c:	83 ec 20             	sub    $0x20,%esp
  80156f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801572:	53                   	push   %ebx
  801573:	e8 8a f1 ff ff       	call   800702 <strlen>
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801580:	7f 67                	jg     8015e9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801582:	83 ec 0c             	sub    $0xc,%esp
  801585:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	e8 6f f8 ff ff       	call   800dfd <fd_alloc>
  80158e:	83 c4 10             	add    $0x10,%esp
		return r;
  801591:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801593:	85 c0                	test   %eax,%eax
  801595:	78 57                	js     8015ee <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801597:	83 ec 08             	sub    $0x8,%esp
  80159a:	53                   	push   %ebx
  80159b:	68 00 50 80 00       	push   $0x805000
  8015a0:	e8 96 f1 ff ff       	call   80073b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8015b5:	e8 d0 fd ff ff       	call   80138a <fsipc>
  8015ba:	89 c3                	mov    %eax,%ebx
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	79 14                	jns    8015d7 <open+0x6f>
		fd_close(fd, 0);
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	6a 00                	push   $0x0
  8015c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8015cb:	e8 2a f9 ff ff       	call   800efa <fd_close>
		return r;
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	89 da                	mov    %ebx,%edx
  8015d5:	eb 17                	jmp    8015ee <open+0x86>
	}

	return fd2num(fd);
  8015d7:	83 ec 0c             	sub    $0xc,%esp
  8015da:	ff 75 f4             	pushl  -0xc(%ebp)
  8015dd:	e8 f4 f7 ff ff       	call   800dd6 <fd2num>
  8015e2:	89 c2                	mov    %eax,%edx
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	eb 05                	jmp    8015ee <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015e9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015ee:	89 d0                	mov    %edx,%eax
  8015f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    

008015f5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801600:	b8 08 00 00 00       	mov    $0x8,%eax
  801605:	e8 80 fd ff ff       	call   80138a <fsipc>
}
  80160a:	c9                   	leave  
  80160b:	c3                   	ret    

0080160c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	57                   	push   %edi
  801610:	56                   	push   %esi
  801611:	53                   	push   %ebx
  801612:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801618:	6a 00                	push   $0x0
  80161a:	ff 75 08             	pushl  0x8(%ebp)
  80161d:	e8 46 ff ff ff       	call   801568 <open>
  801622:	89 c7                	mov    %eax,%edi
  801624:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	85 c0                	test   %eax,%eax
  80162f:	0f 88 97 04 00 00    	js     801acc <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801635:	83 ec 04             	sub    $0x4,%esp
  801638:	68 00 02 00 00       	push   $0x200
  80163d:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	57                   	push   %edi
  801645:	e8 02 fb ff ff       	call   80114c <readn>
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	3d 00 02 00 00       	cmp    $0x200,%eax
  801652:	75 0c                	jne    801660 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801654:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80165b:	45 4c 46 
  80165e:	74 33                	je     801693 <spawn+0x87>
		close(fd);
  801660:	83 ec 0c             	sub    $0xc,%esp
  801663:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801669:	e8 0d f9 ff ff       	call   800f7b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80166e:	83 c4 0c             	add    $0xc,%esp
  801671:	68 7f 45 4c 46       	push   $0x464c457f
  801676:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80167c:	68 8f 2d 80 00       	push   $0x802d8f
  801681:	e8 2e eb ff ff       	call   8001b4 <cprintf>
		return -E_NOT_EXEC;
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80168e:	e9 be 04 00 00       	jmp    801b51 <spawn+0x545>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801693:	b8 07 00 00 00       	mov    $0x7,%eax
  801698:	cd 30                	int    $0x30
  80169a:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8016a0:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	0f 88 26 04 00 00    	js     801ad4 <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016ae:	89 c6                	mov    %eax,%esi
  8016b0:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8016b6:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8016b9:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016bf:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016c5:	b9 11 00 00 00       	mov    $0x11,%ecx
  8016ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8016cc:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8016d2:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016d8:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8016dd:	be 00 00 00 00       	mov    $0x0,%esi
  8016e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016e5:	eb 13                	jmp    8016fa <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8016e7:	83 ec 0c             	sub    $0xc,%esp
  8016ea:	50                   	push   %eax
  8016eb:	e8 12 f0 ff ff       	call   800702 <strlen>
  8016f0:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016f4:	83 c3 01             	add    $0x1,%ebx
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801701:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801704:	85 c0                	test   %eax,%eax
  801706:	75 df                	jne    8016e7 <spawn+0xdb>
  801708:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80170e:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801714:	bf 00 10 40 00       	mov    $0x401000,%edi
  801719:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80171b:	89 fa                	mov    %edi,%edx
  80171d:	83 e2 fc             	and    $0xfffffffc,%edx
  801720:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801727:	29 c2                	sub    %eax,%edx
  801729:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80172f:	8d 42 f8             	lea    -0x8(%edx),%eax
  801732:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801737:	0f 86 a7 03 00 00    	jbe    801ae4 <spawn+0x4d8>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80173d:	83 ec 04             	sub    $0x4,%esp
  801740:	6a 07                	push   $0x7
  801742:	68 00 00 40 00       	push   $0x400000
  801747:	6a 00                	push   $0x0
  801749:	e8 f6 f3 ff ff       	call   800b44 <sys_page_alloc>
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	0f 88 f8 03 00 00    	js     801b51 <spawn+0x545>
  801759:	be 00 00 00 00       	mov    $0x0,%esi
  80175e:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801764:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801767:	eb 30                	jmp    801799 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801769:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80176f:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801775:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801778:	83 ec 08             	sub    $0x8,%esp
  80177b:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80177e:	57                   	push   %edi
  80177f:	e8 b7 ef ff ff       	call   80073b <strcpy>
		string_store += strlen(argv[i]) + 1;
  801784:	83 c4 04             	add    $0x4,%esp
  801787:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80178a:	e8 73 ef ff ff       	call   800702 <strlen>
  80178f:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801793:	83 c6 01             	add    $0x1,%esi
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80179f:	7f c8                	jg     801769 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8017a1:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8017a7:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8017ad:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017b4:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017ba:	74 19                	je     8017d5 <spawn+0x1c9>
  8017bc:	68 1c 2e 80 00       	push   $0x802e1c
  8017c1:	68 63 2d 80 00       	push   $0x802d63
  8017c6:	68 f1 00 00 00       	push   $0xf1
  8017cb:	68 a9 2d 80 00       	push   $0x802da9
  8017d0:	e8 06 e9 ff ff       	call   8000db <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8017d5:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8017db:	89 f8                	mov    %edi,%eax
  8017dd:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8017e2:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8017e5:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8017eb:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8017ee:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8017f4:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017fa:	83 ec 0c             	sub    $0xc,%esp
  8017fd:	6a 07                	push   $0x7
  8017ff:	68 00 d0 bf ee       	push   $0xeebfd000
  801804:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80180a:	68 00 00 40 00       	push   $0x400000
  80180f:	6a 00                	push   $0x0
  801811:	e8 71 f3 ff ff       	call   800b87 <sys_page_map>
  801816:	89 c3                	mov    %eax,%ebx
  801818:	83 c4 20             	add    $0x20,%esp
  80181b:	85 c0                	test   %eax,%eax
  80181d:	0f 88 1a 03 00 00    	js     801b3d <spawn+0x531>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801823:	83 ec 08             	sub    $0x8,%esp
  801826:	68 00 00 40 00       	push   $0x400000
  80182b:	6a 00                	push   $0x0
  80182d:	e8 97 f3 ff ff       	call   800bc9 <sys_page_unmap>
  801832:	89 c3                	mov    %eax,%ebx
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	85 c0                	test   %eax,%eax
  801839:	0f 88 fe 02 00 00    	js     801b3d <spawn+0x531>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80183f:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801845:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80184c:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801852:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801859:	00 00 00 
  80185c:	e9 85 01 00 00       	jmp    8019e6 <spawn+0x3da>
		if (ph->p_type != ELF_PROG_LOAD)
  801861:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801867:	83 38 01             	cmpl   $0x1,(%eax)
  80186a:	0f 85 68 01 00 00    	jne    8019d8 <spawn+0x3cc>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801870:	89 c7                	mov    %eax,%edi
  801872:	8b 40 18             	mov    0x18(%eax),%eax
  801875:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80187b:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80187e:	83 f8 01             	cmp    $0x1,%eax
  801881:	19 c0                	sbb    %eax,%eax
  801883:	83 e0 fe             	and    $0xfffffffe,%eax
  801886:	83 c0 07             	add    $0x7,%eax
  801889:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80188f:	89 f8                	mov    %edi,%eax
  801891:	8b 7f 04             	mov    0x4(%edi),%edi
  801894:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80189a:	8b 78 10             	mov    0x10(%eax),%edi
  80189d:	8b 48 14             	mov    0x14(%eax),%ecx
  8018a0:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  8018a6:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8018a9:	89 f0                	mov    %esi,%eax
  8018ab:	25 ff 0f 00 00       	and    $0xfff,%eax
  8018b0:	74 10                	je     8018c2 <spawn+0x2b6>
		va -= i;
  8018b2:	29 c6                	sub    %eax,%esi
		memsz += i;
  8018b4:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  8018ba:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8018bc:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8018c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018c7:	e9 fa 00 00 00       	jmp    8019c6 <spawn+0x3ba>
		if (i >= filesz) {
  8018cc:	39 fb                	cmp    %edi,%ebx
  8018ce:	72 27                	jb     8018f7 <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8018d0:	83 ec 04             	sub    $0x4,%esp
  8018d3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018d9:	56                   	push   %esi
  8018da:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018e0:	e8 5f f2 ff ff       	call   800b44 <sys_page_alloc>
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	85 c0                	test   %eax,%eax
  8018ea:	0f 89 ca 00 00 00    	jns    8019ba <spawn+0x3ae>
  8018f0:	89 c7                	mov    %eax,%edi
  8018f2:	e9 fe 01 00 00       	jmp    801af5 <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018f7:	83 ec 04             	sub    $0x4,%esp
  8018fa:	6a 07                	push   $0x7
  8018fc:	68 00 00 40 00       	push   $0x400000
  801901:	6a 00                	push   $0x0
  801903:	e8 3c f2 ff ff       	call   800b44 <sys_page_alloc>
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	85 c0                	test   %eax,%eax
  80190d:	0f 88 d8 01 00 00    	js     801aeb <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80191c:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  801922:	50                   	push   %eax
  801923:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801929:	e8 ef f8 ff ff       	call   80121d <seek>
  80192e:	83 c4 10             	add    $0x10,%esp
  801931:	85 c0                	test   %eax,%eax
  801933:	0f 88 b6 01 00 00    	js     801aef <spawn+0x4e3>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801939:	83 ec 04             	sub    $0x4,%esp
  80193c:	89 fa                	mov    %edi,%edx
  80193e:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  801944:	89 d0                	mov    %edx,%eax
  801946:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  80194c:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801951:	0f 47 c1             	cmova  %ecx,%eax
  801954:	50                   	push   %eax
  801955:	68 00 00 40 00       	push   $0x400000
  80195a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801960:	e8 e7 f7 ff ff       	call   80114c <readn>
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	85 c0                	test   %eax,%eax
  80196a:	0f 88 83 01 00 00    	js     801af3 <spawn+0x4e7>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801970:	83 ec 0c             	sub    $0xc,%esp
  801973:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801979:	56                   	push   %esi
  80197a:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801980:	68 00 00 40 00       	push   $0x400000
  801985:	6a 00                	push   $0x0
  801987:	e8 fb f1 ff ff       	call   800b87 <sys_page_map>
  80198c:	83 c4 20             	add    $0x20,%esp
  80198f:	85 c0                	test   %eax,%eax
  801991:	79 15                	jns    8019a8 <spawn+0x39c>
				panic("spawn: sys_page_map data: %e", r);
  801993:	50                   	push   %eax
  801994:	68 b5 2d 80 00       	push   $0x802db5
  801999:	68 24 01 00 00       	push   $0x124
  80199e:	68 a9 2d 80 00       	push   $0x802da9
  8019a3:	e8 33 e7 ff ff       	call   8000db <_panic>
			sys_page_unmap(0, UTEMP);
  8019a8:	83 ec 08             	sub    $0x8,%esp
  8019ab:	68 00 00 40 00       	push   $0x400000
  8019b0:	6a 00                	push   $0x0
  8019b2:	e8 12 f2 ff ff       	call   800bc9 <sys_page_unmap>
  8019b7:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019ba:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019c0:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019c6:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8019cc:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8019d2:	0f 82 f4 fe ff ff    	jb     8018cc <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019d8:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8019df:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8019e6:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8019ed:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8019f3:	0f 8c 68 fe ff ff    	jl     801861 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8019f9:	83 ec 0c             	sub    $0xc,%esp
  8019fc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a02:	e8 74 f5 ff ff       	call   800f7b <close>
  801a07:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801a0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a0f:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801a15:	89 d8                	mov    %ebx,%eax
  801a17:	c1 e8 16             	shr    $0x16,%eax
  801a1a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a21:	a8 01                	test   $0x1,%al
  801a23:	74 53                	je     801a78 <spawn+0x46c>
  801a25:	89 d8                	mov    %ebx,%eax
  801a27:	c1 e8 0c             	shr    $0xc,%eax
  801a2a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a31:	f6 c2 01             	test   $0x1,%dl
  801a34:	74 42                	je     801a78 <spawn+0x46c>
  801a36:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a3d:	f6 c6 04             	test   $0x4,%dh
  801a40:	74 36                	je     801a78 <spawn+0x46c>
                        r = sys_page_map(0, (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  801a42:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a49:	83 ec 0c             	sub    $0xc,%esp
  801a4c:	25 07 0e 00 00       	and    $0xe07,%eax
  801a51:	50                   	push   %eax
  801a52:	53                   	push   %ebx
  801a53:	56                   	push   %esi
  801a54:	53                   	push   %ebx
  801a55:	6a 00                	push   $0x0
  801a57:	e8 2b f1 ff ff       	call   800b87 <sys_page_map>
                        if (r < 0) return r;
  801a5c:	83 c4 20             	add    $0x20,%esp
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	79 15                	jns    801a78 <spawn+0x46c>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801a63:	50                   	push   %eax
  801a64:	68 d2 2d 80 00       	push   $0x802dd2
  801a69:	68 82 00 00 00       	push   $0x82
  801a6e:	68 a9 2d 80 00       	push   $0x802da9
  801a73:	e8 63 e6 ff ff       	call   8000db <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
        int r;
        void *addr;
        for (addr = (uint8_t*) 0; addr < (void *) UTOP; addr += PGSIZE)
  801a78:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a7e:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801a84:	75 8f                	jne    801a15 <spawn+0x409>
  801a86:	e9 8d 00 00 00       	jmp    801b18 <spawn+0x50c>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
		panic("sys_env_set_trapframe: %e", r);
  801a8b:	50                   	push   %eax
  801a8c:	68 e8 2d 80 00       	push   $0x802de8
  801a91:	68 85 00 00 00       	push   $0x85
  801a96:	68 a9 2d 80 00       	push   $0x802da9
  801a9b:	e8 3b e6 ff ff       	call   8000db <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801aa0:	83 ec 08             	sub    $0x8,%esp
  801aa3:	6a 02                	push   $0x2
  801aa5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aab:	e8 5b f1 ff ff       	call   800c0b <sys_env_set_status>
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	79 25                	jns    801adc <spawn+0x4d0>
		panic("sys_env_set_status: %e", r);
  801ab7:	50                   	push   %eax
  801ab8:	68 02 2e 80 00       	push   $0x802e02
  801abd:	68 88 00 00 00       	push   $0x88
  801ac2:	68 a9 2d 80 00       	push   $0x802da9
  801ac7:	e8 0f e6 ff ff       	call   8000db <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801acc:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801ad2:	eb 7d                	jmp    801b51 <spawn+0x545>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801ad4:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801ada:	eb 75                	jmp    801b51 <spawn+0x545>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801adc:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801ae2:	eb 6d                	jmp    801b51 <spawn+0x545>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801ae4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801ae9:	eb 66                	jmp    801b51 <spawn+0x545>
  801aeb:	89 c7                	mov    %eax,%edi
  801aed:	eb 06                	jmp    801af5 <spawn+0x4e9>
  801aef:	89 c7                	mov    %eax,%edi
  801af1:	eb 02                	jmp    801af5 <spawn+0x4e9>
  801af3:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801af5:	83 ec 0c             	sub    $0xc,%esp
  801af8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801afe:	e8 c2 ef ff ff       	call   800ac5 <sys_env_destroy>
	close(fd);
  801b03:	83 c4 04             	add    $0x4,%esp
  801b06:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b0c:	e8 6a f4 ff ff       	call   800f7b <close>
	return r;
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	89 f8                	mov    %edi,%eax
  801b16:	eb 39                	jmp    801b51 <spawn+0x545>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0) 
  801b18:	83 ec 08             	sub    $0x8,%esp
  801b1b:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b21:	50                   	push   %eax
  801b22:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b28:	e8 20 f1 ff ff       	call   800c4d <sys_env_set_trapframe>
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	85 c0                	test   %eax,%eax
  801b32:	0f 89 68 ff ff ff    	jns    801aa0 <spawn+0x494>
  801b38:	e9 4e ff ff ff       	jmp    801a8b <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b3d:	83 ec 08             	sub    $0x8,%esp
  801b40:	68 00 00 40 00       	push   $0x400000
  801b45:	6a 00                	push   $0x0
  801b47:	e8 7d f0 ff ff       	call   800bc9 <sys_page_unmap>
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5e                   	pop    %esi
  801b56:	5f                   	pop    %edi
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    

00801b59 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	56                   	push   %esi
  801b5d:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b5e:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b61:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b66:	eb 03                	jmp    801b6b <spawnl+0x12>
		argc++;
  801b68:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b6b:	83 c2 04             	add    $0x4,%edx
  801b6e:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b72:	75 f4                	jne    801b68 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b74:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b7b:	83 e2 f0             	and    $0xfffffff0,%edx
  801b7e:	29 d4                	sub    %edx,%esp
  801b80:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b84:	c1 ea 02             	shr    $0x2,%edx
  801b87:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801b8e:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b93:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801b9a:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ba1:	00 
  801ba2:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba9:	eb 0a                	jmp    801bb5 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801bab:	83 c0 01             	add    $0x1,%eax
  801bae:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801bb2:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bb5:	39 d0                	cmp    %edx,%eax
  801bb7:	75 f2                	jne    801bab <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801bb9:	83 ec 08             	sub    $0x8,%esp
  801bbc:	56                   	push   %esi
  801bbd:	ff 75 08             	pushl  0x8(%ebp)
  801bc0:	e8 47 fa ff ff       	call   80160c <spawn>
}
  801bc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc8:	5b                   	pop    %ebx
  801bc9:	5e                   	pop    %esi
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    

00801bcc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801bd2:	68 44 2e 80 00       	push   $0x802e44
  801bd7:	ff 75 0c             	pushl  0xc(%ebp)
  801bda:	e8 5c eb ff ff       	call   80073b <strcpy>
	return 0;
}
  801bdf:	b8 00 00 00 00       	mov    $0x0,%eax
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    

00801be6 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	53                   	push   %ebx
  801bea:	83 ec 10             	sub    $0x10,%esp
  801bed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801bf0:	53                   	push   %ebx
  801bf1:	e8 18 0a 00 00       	call   80260e <pageref>
  801bf6:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801bf9:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801bfe:	83 f8 01             	cmp    $0x1,%eax
  801c01:	75 10                	jne    801c13 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801c03:	83 ec 0c             	sub    $0xc,%esp
  801c06:	ff 73 0c             	pushl  0xc(%ebx)
  801c09:	e8 ca 02 00 00       	call   801ed8 <nsipc_close>
  801c0e:	89 c2                	mov    %eax,%edx
  801c10:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801c13:	89 d0                	mov    %edx,%eax
  801c15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c18:	c9                   	leave  
  801c19:	c3                   	ret    

00801c1a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c20:	6a 00                	push   $0x0
  801c22:	ff 75 10             	pushl  0x10(%ebp)
  801c25:	ff 75 0c             	pushl  0xc(%ebp)
  801c28:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2b:	ff 70 0c             	pushl  0xc(%eax)
  801c2e:	e8 82 03 00 00       	call   801fb5 <nsipc_send>
}
  801c33:	c9                   	leave  
  801c34:	c3                   	ret    

00801c35 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c3b:	6a 00                	push   $0x0
  801c3d:	ff 75 10             	pushl  0x10(%ebp)
  801c40:	ff 75 0c             	pushl  0xc(%ebp)
  801c43:	8b 45 08             	mov    0x8(%ebp),%eax
  801c46:	ff 70 0c             	pushl  0xc(%eax)
  801c49:	e8 fb 02 00 00       	call   801f49 <nsipc_recv>
}
  801c4e:	c9                   	leave  
  801c4f:	c3                   	ret    

00801c50 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c56:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c59:	52                   	push   %edx
  801c5a:	50                   	push   %eax
  801c5b:	e8 ec f1 ff ff       	call   800e4c <fd_lookup>
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	85 c0                	test   %eax,%eax
  801c65:	78 17                	js     801c7e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c70:	39 08                	cmp    %ecx,(%eax)
  801c72:	75 05                	jne    801c79 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c74:	8b 40 0c             	mov    0xc(%eax),%eax
  801c77:	eb 05                	jmp    801c7e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c79:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    

00801c80 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	56                   	push   %esi
  801c84:	53                   	push   %ebx
  801c85:	83 ec 1c             	sub    $0x1c,%esp
  801c88:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8d:	50                   	push   %eax
  801c8e:	e8 6a f1 ff ff       	call   800dfd <fd_alloc>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 1b                	js     801cb7 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c9c:	83 ec 04             	sub    $0x4,%esp
  801c9f:	68 07 04 00 00       	push   $0x407
  801ca4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca7:	6a 00                	push   $0x0
  801ca9:	e8 96 ee ff ff       	call   800b44 <sys_page_alloc>
  801cae:	89 c3                	mov    %eax,%ebx
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	79 10                	jns    801cc7 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801cb7:	83 ec 0c             	sub    $0xc,%esp
  801cba:	56                   	push   %esi
  801cbb:	e8 18 02 00 00       	call   801ed8 <nsipc_close>
		return r;
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	89 d8                	mov    %ebx,%eax
  801cc5:	eb 24                	jmp    801ceb <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801cc7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd0:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cd5:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  801cdc:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801cdf:	83 ec 0c             	sub    $0xc,%esp
  801ce2:	52                   	push   %edx
  801ce3:	e8 ee f0 ff ff       	call   800dd6 <fd2num>
  801ce8:	83 c4 10             	add    $0x10,%esp
}
  801ceb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cee:	5b                   	pop    %ebx
  801cef:	5e                   	pop    %esi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    

00801cf2 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	e8 50 ff ff ff       	call   801c50 <fd2sockid>
		return r;
  801d00:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d02:	85 c0                	test   %eax,%eax
  801d04:	78 1f                	js     801d25 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d06:	83 ec 04             	sub    $0x4,%esp
  801d09:	ff 75 10             	pushl  0x10(%ebp)
  801d0c:	ff 75 0c             	pushl  0xc(%ebp)
  801d0f:	50                   	push   %eax
  801d10:	e8 1c 01 00 00       	call   801e31 <nsipc_accept>
  801d15:	83 c4 10             	add    $0x10,%esp
		return r;
  801d18:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	78 07                	js     801d25 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801d1e:	e8 5d ff ff ff       	call   801c80 <alloc_sockfd>
  801d23:	89 c1                	mov    %eax,%ecx
}
  801d25:	89 c8                	mov    %ecx,%eax
  801d27:	c9                   	leave  
  801d28:	c3                   	ret    

00801d29 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d32:	e8 19 ff ff ff       	call   801c50 <fd2sockid>
  801d37:	89 c2                	mov    %eax,%edx
  801d39:	85 d2                	test   %edx,%edx
  801d3b:	78 12                	js     801d4f <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  801d3d:	83 ec 04             	sub    $0x4,%esp
  801d40:	ff 75 10             	pushl  0x10(%ebp)
  801d43:	ff 75 0c             	pushl  0xc(%ebp)
  801d46:	52                   	push   %edx
  801d47:	e8 35 01 00 00       	call   801e81 <nsipc_bind>
  801d4c:	83 c4 10             	add    $0x10,%esp
}
  801d4f:	c9                   	leave  
  801d50:	c3                   	ret    

00801d51 <shutdown>:

int
shutdown(int s, int how)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d57:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5a:	e8 f1 fe ff ff       	call   801c50 <fd2sockid>
  801d5f:	89 c2                	mov    %eax,%edx
  801d61:	85 d2                	test   %edx,%edx
  801d63:	78 0f                	js     801d74 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801d65:	83 ec 08             	sub    $0x8,%esp
  801d68:	ff 75 0c             	pushl  0xc(%ebp)
  801d6b:	52                   	push   %edx
  801d6c:	e8 45 01 00 00       	call   801eb6 <nsipc_shutdown>
  801d71:	83 c4 10             	add    $0x10,%esp
}
  801d74:	c9                   	leave  
  801d75:	c3                   	ret    

00801d76 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7f:	e8 cc fe ff ff       	call   801c50 <fd2sockid>
  801d84:	89 c2                	mov    %eax,%edx
  801d86:	85 d2                	test   %edx,%edx
  801d88:	78 12                	js     801d9c <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801d8a:	83 ec 04             	sub    $0x4,%esp
  801d8d:	ff 75 10             	pushl  0x10(%ebp)
  801d90:	ff 75 0c             	pushl  0xc(%ebp)
  801d93:	52                   	push   %edx
  801d94:	e8 59 01 00 00       	call   801ef2 <nsipc_connect>
  801d99:	83 c4 10             	add    $0x10,%esp
}
  801d9c:	c9                   	leave  
  801d9d:	c3                   	ret    

00801d9e <listen>:

int
listen(int s, int backlog)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801da4:	8b 45 08             	mov    0x8(%ebp),%eax
  801da7:	e8 a4 fe ff ff       	call   801c50 <fd2sockid>
  801dac:	89 c2                	mov    %eax,%edx
  801dae:	85 d2                	test   %edx,%edx
  801db0:	78 0f                	js     801dc1 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801db2:	83 ec 08             	sub    $0x8,%esp
  801db5:	ff 75 0c             	pushl  0xc(%ebp)
  801db8:	52                   	push   %edx
  801db9:	e8 69 01 00 00       	call   801f27 <nsipc_listen>
  801dbe:	83 c4 10             	add    $0x10,%esp
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801dc9:	ff 75 10             	pushl  0x10(%ebp)
  801dcc:	ff 75 0c             	pushl  0xc(%ebp)
  801dcf:	ff 75 08             	pushl  0x8(%ebp)
  801dd2:	e8 3c 02 00 00       	call   802013 <nsipc_socket>
  801dd7:	89 c2                	mov    %eax,%edx
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	85 d2                	test   %edx,%edx
  801dde:	78 05                	js     801de5 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801de0:	e8 9b fe ff ff       	call   801c80 <alloc_sockfd>
}
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	53                   	push   %ebx
  801deb:	83 ec 04             	sub    $0x4,%esp
  801dee:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801df0:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801df7:	75 12                	jne    801e0b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801df9:	83 ec 0c             	sub    $0xc,%esp
  801dfc:	6a 02                	push   $0x2
  801dfe:	e8 d3 07 00 00       	call   8025d6 <ipc_find_env>
  801e03:	a3 04 40 80 00       	mov    %eax,0x804004
  801e08:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e0b:	6a 07                	push   $0x7
  801e0d:	68 00 60 80 00       	push   $0x806000
  801e12:	53                   	push   %ebx
  801e13:	ff 35 04 40 80 00    	pushl  0x804004
  801e19:	e8 64 07 00 00       	call   802582 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e1e:	83 c4 0c             	add    $0xc,%esp
  801e21:	6a 00                	push   $0x0
  801e23:	6a 00                	push   $0x0
  801e25:	6a 00                	push   $0x0
  801e27:	e8 ed 06 00 00       	call   802519 <ipc_recv>
}
  801e2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	56                   	push   %esi
  801e35:	53                   	push   %ebx
  801e36:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e39:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e41:	8b 06                	mov    (%esi),%eax
  801e43:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e48:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4d:	e8 95 ff ff ff       	call   801de7 <nsipc>
  801e52:	89 c3                	mov    %eax,%ebx
  801e54:	85 c0                	test   %eax,%eax
  801e56:	78 20                	js     801e78 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e58:	83 ec 04             	sub    $0x4,%esp
  801e5b:	ff 35 10 60 80 00    	pushl  0x806010
  801e61:	68 00 60 80 00       	push   $0x806000
  801e66:	ff 75 0c             	pushl  0xc(%ebp)
  801e69:	e8 5f ea ff ff       	call   8008cd <memmove>
		*addrlen = ret->ret_addrlen;
  801e6e:	a1 10 60 80 00       	mov    0x806010,%eax
  801e73:	89 06                	mov    %eax,(%esi)
  801e75:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801e78:	89 d8                	mov    %ebx,%eax
  801e7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e7d:	5b                   	pop    %ebx
  801e7e:	5e                   	pop    %esi
  801e7f:	5d                   	pop    %ebp
  801e80:	c3                   	ret    

00801e81 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	53                   	push   %ebx
  801e85:	83 ec 08             	sub    $0x8,%esp
  801e88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e93:	53                   	push   %ebx
  801e94:	ff 75 0c             	pushl  0xc(%ebp)
  801e97:	68 04 60 80 00       	push   $0x806004
  801e9c:	e8 2c ea ff ff       	call   8008cd <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ea1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ea7:	b8 02 00 00 00       	mov    $0x2,%eax
  801eac:	e8 36 ff ff ff       	call   801de7 <nsipc>
}
  801eb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb4:	c9                   	leave  
  801eb5:	c3                   	ret    

00801eb6 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ecc:	b8 03 00 00 00       	mov    $0x3,%eax
  801ed1:	e8 11 ff ff ff       	call   801de7 <nsipc>
}
  801ed6:	c9                   	leave  
  801ed7:	c3                   	ret    

00801ed8 <nsipc_close>:

int
nsipc_close(int s)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ede:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee1:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ee6:	b8 04 00 00 00       	mov    $0x4,%eax
  801eeb:	e8 f7 fe ff ff       	call   801de7 <nsipc>
}
  801ef0:	c9                   	leave  
  801ef1:	c3                   	ret    

00801ef2 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	53                   	push   %ebx
  801ef6:	83 ec 08             	sub    $0x8,%esp
  801ef9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801efc:	8b 45 08             	mov    0x8(%ebp),%eax
  801eff:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f04:	53                   	push   %ebx
  801f05:	ff 75 0c             	pushl  0xc(%ebp)
  801f08:	68 04 60 80 00       	push   $0x806004
  801f0d:	e8 bb e9 ff ff       	call   8008cd <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f12:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f18:	b8 05 00 00 00       	mov    $0x5,%eax
  801f1d:	e8 c5 fe ff ff       	call   801de7 <nsipc>
}
  801f22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f25:	c9                   	leave  
  801f26:	c3                   	ret    

00801f27 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f30:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f38:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f3d:	b8 06 00 00 00       	mov    $0x6,%eax
  801f42:	e8 a0 fe ff ff       	call   801de7 <nsipc>
}
  801f47:	c9                   	leave  
  801f48:	c3                   	ret    

00801f49 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	56                   	push   %esi
  801f4d:	53                   	push   %ebx
  801f4e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f51:	8b 45 08             	mov    0x8(%ebp),%eax
  801f54:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f59:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f5f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f62:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f67:	b8 07 00 00 00       	mov    $0x7,%eax
  801f6c:	e8 76 fe ff ff       	call   801de7 <nsipc>
  801f71:	89 c3                	mov    %eax,%ebx
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 35                	js     801fac <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801f77:	39 f0                	cmp    %esi,%eax
  801f79:	7f 07                	jg     801f82 <nsipc_recv+0x39>
  801f7b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f80:	7e 16                	jle    801f98 <nsipc_recv+0x4f>
  801f82:	68 50 2e 80 00       	push   $0x802e50
  801f87:	68 63 2d 80 00       	push   $0x802d63
  801f8c:	6a 62                	push   $0x62
  801f8e:	68 65 2e 80 00       	push   $0x802e65
  801f93:	e8 43 e1 ff ff       	call   8000db <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f98:	83 ec 04             	sub    $0x4,%esp
  801f9b:	50                   	push   %eax
  801f9c:	68 00 60 80 00       	push   $0x806000
  801fa1:	ff 75 0c             	pushl  0xc(%ebp)
  801fa4:	e8 24 e9 ff ff       	call   8008cd <memmove>
  801fa9:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801fac:	89 d8                	mov    %ebx,%eax
  801fae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb1:	5b                   	pop    %ebx
  801fb2:	5e                   	pop    %esi
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    

00801fb5 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	53                   	push   %ebx
  801fb9:	83 ec 04             	sub    $0x4,%esp
  801fbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc2:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801fc7:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fcd:	7e 16                	jle    801fe5 <nsipc_send+0x30>
  801fcf:	68 71 2e 80 00       	push   $0x802e71
  801fd4:	68 63 2d 80 00       	push   $0x802d63
  801fd9:	6a 6d                	push   $0x6d
  801fdb:	68 65 2e 80 00       	push   $0x802e65
  801fe0:	e8 f6 e0 ff ff       	call   8000db <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fe5:	83 ec 04             	sub    $0x4,%esp
  801fe8:	53                   	push   %ebx
  801fe9:	ff 75 0c             	pushl  0xc(%ebp)
  801fec:	68 0c 60 80 00       	push   $0x80600c
  801ff1:	e8 d7 e8 ff ff       	call   8008cd <memmove>
	nsipcbuf.send.req_size = size;
  801ff6:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ffc:	8b 45 14             	mov    0x14(%ebp),%eax
  801fff:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802004:	b8 08 00 00 00       	mov    $0x8,%eax
  802009:	e8 d9 fd ff ff       	call   801de7 <nsipc>
}
  80200e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802011:	c9                   	leave  
  802012:	c3                   	ret    

00802013 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802019:	8b 45 08             	mov    0x8(%ebp),%eax
  80201c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802021:	8b 45 0c             	mov    0xc(%ebp),%eax
  802024:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802029:	8b 45 10             	mov    0x10(%ebp),%eax
  80202c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802031:	b8 09 00 00 00       	mov    $0x9,%eax
  802036:	e8 ac fd ff ff       	call   801de7 <nsipc>
}
  80203b:	c9                   	leave  
  80203c:	c3                   	ret    

0080203d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80203d:	55                   	push   %ebp
  80203e:	89 e5                	mov    %esp,%ebp
  802040:	56                   	push   %esi
  802041:	53                   	push   %ebx
  802042:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802045:	83 ec 0c             	sub    $0xc,%esp
  802048:	ff 75 08             	pushl  0x8(%ebp)
  80204b:	e8 96 ed ff ff       	call   800de6 <fd2data>
  802050:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802052:	83 c4 08             	add    $0x8,%esp
  802055:	68 7d 2e 80 00       	push   $0x802e7d
  80205a:	53                   	push   %ebx
  80205b:	e8 db e6 ff ff       	call   80073b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802060:	8b 56 04             	mov    0x4(%esi),%edx
  802063:	89 d0                	mov    %edx,%eax
  802065:	2b 06                	sub    (%esi),%eax
  802067:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80206d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802074:	00 00 00 
	stat->st_dev = &devpipe;
  802077:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80207e:	30 80 00 
	return 0;
}
  802081:	b8 00 00 00 00       	mov    $0x0,%eax
  802086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802089:	5b                   	pop    %ebx
  80208a:	5e                   	pop    %esi
  80208b:	5d                   	pop    %ebp
  80208c:	c3                   	ret    

0080208d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80208d:	55                   	push   %ebp
  80208e:	89 e5                	mov    %esp,%ebp
  802090:	53                   	push   %ebx
  802091:	83 ec 0c             	sub    $0xc,%esp
  802094:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802097:	53                   	push   %ebx
  802098:	6a 00                	push   $0x0
  80209a:	e8 2a eb ff ff       	call   800bc9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80209f:	89 1c 24             	mov    %ebx,(%esp)
  8020a2:	e8 3f ed ff ff       	call   800de6 <fd2data>
  8020a7:	83 c4 08             	add    $0x8,%esp
  8020aa:	50                   	push   %eax
  8020ab:	6a 00                	push   $0x0
  8020ad:	e8 17 eb ff ff       	call   800bc9 <sys_page_unmap>
}
  8020b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020b5:	c9                   	leave  
  8020b6:	c3                   	ret    

008020b7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020b7:	55                   	push   %ebp
  8020b8:	89 e5                	mov    %esp,%ebp
  8020ba:	57                   	push   %edi
  8020bb:	56                   	push   %esi
  8020bc:	53                   	push   %ebx
  8020bd:	83 ec 1c             	sub    $0x1c,%esp
  8020c0:	89 c6                	mov    %eax,%esi
  8020c2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8020ca:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020cd:	83 ec 0c             	sub    $0xc,%esp
  8020d0:	56                   	push   %esi
  8020d1:	e8 38 05 00 00       	call   80260e <pageref>
  8020d6:	89 c7                	mov    %eax,%edi
  8020d8:	83 c4 04             	add    $0x4,%esp
  8020db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020de:	e8 2b 05 00 00       	call   80260e <pageref>
  8020e3:	83 c4 10             	add    $0x10,%esp
  8020e6:	39 c7                	cmp    %eax,%edi
  8020e8:	0f 94 c2             	sete   %dl
  8020eb:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8020ee:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  8020f4:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8020f7:	39 fb                	cmp    %edi,%ebx
  8020f9:	74 19                	je     802114 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8020fb:	84 d2                	test   %dl,%dl
  8020fd:	74 c6                	je     8020c5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020ff:	8b 51 58             	mov    0x58(%ecx),%edx
  802102:	50                   	push   %eax
  802103:	52                   	push   %edx
  802104:	53                   	push   %ebx
  802105:	68 84 2e 80 00       	push   $0x802e84
  80210a:	e8 a5 e0 ff ff       	call   8001b4 <cprintf>
  80210f:	83 c4 10             	add    $0x10,%esp
  802112:	eb b1                	jmp    8020c5 <_pipeisclosed+0xe>
	}
}
  802114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    

0080211c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	57                   	push   %edi
  802120:	56                   	push   %esi
  802121:	53                   	push   %ebx
  802122:	83 ec 28             	sub    $0x28,%esp
  802125:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802128:	56                   	push   %esi
  802129:	e8 b8 ec ff ff       	call   800de6 <fd2data>
  80212e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802130:	83 c4 10             	add    $0x10,%esp
  802133:	bf 00 00 00 00       	mov    $0x0,%edi
  802138:	eb 4b                	jmp    802185 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80213a:	89 da                	mov    %ebx,%edx
  80213c:	89 f0                	mov    %esi,%eax
  80213e:	e8 74 ff ff ff       	call   8020b7 <_pipeisclosed>
  802143:	85 c0                	test   %eax,%eax
  802145:	75 48                	jne    80218f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802147:	e8 d9 e9 ff ff       	call   800b25 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80214c:	8b 43 04             	mov    0x4(%ebx),%eax
  80214f:	8b 0b                	mov    (%ebx),%ecx
  802151:	8d 51 20             	lea    0x20(%ecx),%edx
  802154:	39 d0                	cmp    %edx,%eax
  802156:	73 e2                	jae    80213a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802158:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80215b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80215f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802162:	89 c2                	mov    %eax,%edx
  802164:	c1 fa 1f             	sar    $0x1f,%edx
  802167:	89 d1                	mov    %edx,%ecx
  802169:	c1 e9 1b             	shr    $0x1b,%ecx
  80216c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80216f:	83 e2 1f             	and    $0x1f,%edx
  802172:	29 ca                	sub    %ecx,%edx
  802174:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802178:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80217c:	83 c0 01             	add    $0x1,%eax
  80217f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802182:	83 c7 01             	add    $0x1,%edi
  802185:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802188:	75 c2                	jne    80214c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80218a:	8b 45 10             	mov    0x10(%ebp),%eax
  80218d:	eb 05                	jmp    802194 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80218f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    

0080219c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	57                   	push   %edi
  8021a0:	56                   	push   %esi
  8021a1:	53                   	push   %ebx
  8021a2:	83 ec 18             	sub    $0x18,%esp
  8021a5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021a8:	57                   	push   %edi
  8021a9:	e8 38 ec ff ff       	call   800de6 <fd2data>
  8021ae:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021b0:	83 c4 10             	add    $0x10,%esp
  8021b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021b8:	eb 3d                	jmp    8021f7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021ba:	85 db                	test   %ebx,%ebx
  8021bc:	74 04                	je     8021c2 <devpipe_read+0x26>
				return i;
  8021be:	89 d8                	mov    %ebx,%eax
  8021c0:	eb 44                	jmp    802206 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	89 f8                	mov    %edi,%eax
  8021c6:	e8 ec fe ff ff       	call   8020b7 <_pipeisclosed>
  8021cb:	85 c0                	test   %eax,%eax
  8021cd:	75 32                	jne    802201 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021cf:	e8 51 e9 ff ff       	call   800b25 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021d4:	8b 06                	mov    (%esi),%eax
  8021d6:	3b 46 04             	cmp    0x4(%esi),%eax
  8021d9:	74 df                	je     8021ba <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021db:	99                   	cltd   
  8021dc:	c1 ea 1b             	shr    $0x1b,%edx
  8021df:	01 d0                	add    %edx,%eax
  8021e1:	83 e0 1f             	and    $0x1f,%eax
  8021e4:	29 d0                	sub    %edx,%eax
  8021e6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8021eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021ee:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8021f1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021f4:	83 c3 01             	add    $0x1,%ebx
  8021f7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021fa:	75 d8                	jne    8021d4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8021fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ff:	eb 05                	jmp    802206 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802201:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802209:	5b                   	pop    %ebx
  80220a:	5e                   	pop    %esi
  80220b:	5f                   	pop    %edi
  80220c:	5d                   	pop    %ebp
  80220d:	c3                   	ret    

0080220e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80220e:	55                   	push   %ebp
  80220f:	89 e5                	mov    %esp,%ebp
  802211:	56                   	push   %esi
  802212:	53                   	push   %ebx
  802213:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802216:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802219:	50                   	push   %eax
  80221a:	e8 de eb ff ff       	call   800dfd <fd_alloc>
  80221f:	83 c4 10             	add    $0x10,%esp
  802222:	89 c2                	mov    %eax,%edx
  802224:	85 c0                	test   %eax,%eax
  802226:	0f 88 2c 01 00 00    	js     802358 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80222c:	83 ec 04             	sub    $0x4,%esp
  80222f:	68 07 04 00 00       	push   $0x407
  802234:	ff 75 f4             	pushl  -0xc(%ebp)
  802237:	6a 00                	push   $0x0
  802239:	e8 06 e9 ff ff       	call   800b44 <sys_page_alloc>
  80223e:	83 c4 10             	add    $0x10,%esp
  802241:	89 c2                	mov    %eax,%edx
  802243:	85 c0                	test   %eax,%eax
  802245:	0f 88 0d 01 00 00    	js     802358 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80224b:	83 ec 0c             	sub    $0xc,%esp
  80224e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802251:	50                   	push   %eax
  802252:	e8 a6 eb ff ff       	call   800dfd <fd_alloc>
  802257:	89 c3                	mov    %eax,%ebx
  802259:	83 c4 10             	add    $0x10,%esp
  80225c:	85 c0                	test   %eax,%eax
  80225e:	0f 88 e2 00 00 00    	js     802346 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802264:	83 ec 04             	sub    $0x4,%esp
  802267:	68 07 04 00 00       	push   $0x407
  80226c:	ff 75 f0             	pushl  -0x10(%ebp)
  80226f:	6a 00                	push   $0x0
  802271:	e8 ce e8 ff ff       	call   800b44 <sys_page_alloc>
  802276:	89 c3                	mov    %eax,%ebx
  802278:	83 c4 10             	add    $0x10,%esp
  80227b:	85 c0                	test   %eax,%eax
  80227d:	0f 88 c3 00 00 00    	js     802346 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802283:	83 ec 0c             	sub    $0xc,%esp
  802286:	ff 75 f4             	pushl  -0xc(%ebp)
  802289:	e8 58 eb ff ff       	call   800de6 <fd2data>
  80228e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802290:	83 c4 0c             	add    $0xc,%esp
  802293:	68 07 04 00 00       	push   $0x407
  802298:	50                   	push   %eax
  802299:	6a 00                	push   $0x0
  80229b:	e8 a4 e8 ff ff       	call   800b44 <sys_page_alloc>
  8022a0:	89 c3                	mov    %eax,%ebx
  8022a2:	83 c4 10             	add    $0x10,%esp
  8022a5:	85 c0                	test   %eax,%eax
  8022a7:	0f 88 89 00 00 00    	js     802336 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ad:	83 ec 0c             	sub    $0xc,%esp
  8022b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8022b3:	e8 2e eb ff ff       	call   800de6 <fd2data>
  8022b8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8022bf:	50                   	push   %eax
  8022c0:	6a 00                	push   $0x0
  8022c2:	56                   	push   %esi
  8022c3:	6a 00                	push   $0x0
  8022c5:	e8 bd e8 ff ff       	call   800b87 <sys_page_map>
  8022ca:	89 c3                	mov    %eax,%ebx
  8022cc:	83 c4 20             	add    $0x20,%esp
  8022cf:	85 c0                	test   %eax,%eax
  8022d1:	78 55                	js     802328 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022d3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022dc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8022e8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8022fd:	83 ec 0c             	sub    $0xc,%esp
  802300:	ff 75 f4             	pushl  -0xc(%ebp)
  802303:	e8 ce ea ff ff       	call   800dd6 <fd2num>
  802308:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80230b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80230d:	83 c4 04             	add    $0x4,%esp
  802310:	ff 75 f0             	pushl  -0x10(%ebp)
  802313:	e8 be ea ff ff       	call   800dd6 <fd2num>
  802318:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80231b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80231e:	83 c4 10             	add    $0x10,%esp
  802321:	ba 00 00 00 00       	mov    $0x0,%edx
  802326:	eb 30                	jmp    802358 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802328:	83 ec 08             	sub    $0x8,%esp
  80232b:	56                   	push   %esi
  80232c:	6a 00                	push   $0x0
  80232e:	e8 96 e8 ff ff       	call   800bc9 <sys_page_unmap>
  802333:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802336:	83 ec 08             	sub    $0x8,%esp
  802339:	ff 75 f0             	pushl  -0x10(%ebp)
  80233c:	6a 00                	push   $0x0
  80233e:	e8 86 e8 ff ff       	call   800bc9 <sys_page_unmap>
  802343:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802346:	83 ec 08             	sub    $0x8,%esp
  802349:	ff 75 f4             	pushl  -0xc(%ebp)
  80234c:	6a 00                	push   $0x0
  80234e:	e8 76 e8 ff ff       	call   800bc9 <sys_page_unmap>
  802353:	83 c4 10             	add    $0x10,%esp
  802356:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802358:	89 d0                	mov    %edx,%eax
  80235a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80235d:	5b                   	pop    %ebx
  80235e:	5e                   	pop    %esi
  80235f:	5d                   	pop    %ebp
  802360:	c3                   	ret    

00802361 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802361:	55                   	push   %ebp
  802362:	89 e5                	mov    %esp,%ebp
  802364:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80236a:	50                   	push   %eax
  80236b:	ff 75 08             	pushl  0x8(%ebp)
  80236e:	e8 d9 ea ff ff       	call   800e4c <fd_lookup>
  802373:	89 c2                	mov    %eax,%edx
  802375:	83 c4 10             	add    $0x10,%esp
  802378:	85 d2                	test   %edx,%edx
  80237a:	78 18                	js     802394 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80237c:	83 ec 0c             	sub    $0xc,%esp
  80237f:	ff 75 f4             	pushl  -0xc(%ebp)
  802382:	e8 5f ea ff ff       	call   800de6 <fd2data>
	return _pipeisclosed(fd, p);
  802387:	89 c2                	mov    %eax,%edx
  802389:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80238c:	e8 26 fd ff ff       	call   8020b7 <_pipeisclosed>
  802391:	83 c4 10             	add    $0x10,%esp
}
  802394:	c9                   	leave  
  802395:	c3                   	ret    

00802396 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802396:	55                   	push   %ebp
  802397:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802399:	b8 00 00 00 00       	mov    $0x0,%eax
  80239e:	5d                   	pop    %ebp
  80239f:	c3                   	ret    

008023a0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023a0:	55                   	push   %ebp
  8023a1:	89 e5                	mov    %esp,%ebp
  8023a3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8023a6:	68 9c 2e 80 00       	push   $0x802e9c
  8023ab:	ff 75 0c             	pushl  0xc(%ebp)
  8023ae:	e8 88 e3 ff ff       	call   80073b <strcpy>
	return 0;
}
  8023b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8023b8:	c9                   	leave  
  8023b9:	c3                   	ret    

008023ba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023ba:	55                   	push   %ebp
  8023bb:	89 e5                	mov    %esp,%ebp
  8023bd:	57                   	push   %edi
  8023be:	56                   	push   %esi
  8023bf:	53                   	push   %ebx
  8023c0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023c6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023cb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023d1:	eb 2d                	jmp    802400 <devcons_write+0x46>
		m = n - tot;
  8023d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023d6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8023d8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023db:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023e0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023e3:	83 ec 04             	sub    $0x4,%esp
  8023e6:	53                   	push   %ebx
  8023e7:	03 45 0c             	add    0xc(%ebp),%eax
  8023ea:	50                   	push   %eax
  8023eb:	57                   	push   %edi
  8023ec:	e8 dc e4 ff ff       	call   8008cd <memmove>
		sys_cputs(buf, m);
  8023f1:	83 c4 08             	add    $0x8,%esp
  8023f4:	53                   	push   %ebx
  8023f5:	57                   	push   %edi
  8023f6:	e8 8d e6 ff ff       	call   800a88 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023fb:	01 de                	add    %ebx,%esi
  8023fd:	83 c4 10             	add    $0x10,%esp
  802400:	89 f0                	mov    %esi,%eax
  802402:	3b 75 10             	cmp    0x10(%ebp),%esi
  802405:	72 cc                	jb     8023d3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802407:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80240a:	5b                   	pop    %ebx
  80240b:	5e                   	pop    %esi
  80240c:	5f                   	pop    %edi
  80240d:	5d                   	pop    %ebp
  80240e:	c3                   	ret    

0080240f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80240f:	55                   	push   %ebp
  802410:	89 e5                	mov    %esp,%ebp
  802412:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802415:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80241a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80241e:	75 07                	jne    802427 <devcons_read+0x18>
  802420:	eb 28                	jmp    80244a <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802422:	e8 fe e6 ff ff       	call   800b25 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802427:	e8 7a e6 ff ff       	call   800aa6 <sys_cgetc>
  80242c:	85 c0                	test   %eax,%eax
  80242e:	74 f2                	je     802422 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802430:	85 c0                	test   %eax,%eax
  802432:	78 16                	js     80244a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802434:	83 f8 04             	cmp    $0x4,%eax
  802437:	74 0c                	je     802445 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802439:	8b 55 0c             	mov    0xc(%ebp),%edx
  80243c:	88 02                	mov    %al,(%edx)
	return 1;
  80243e:	b8 01 00 00 00       	mov    $0x1,%eax
  802443:	eb 05                	jmp    80244a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802445:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80244a:	c9                   	leave  
  80244b:	c3                   	ret    

0080244c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80244c:	55                   	push   %ebp
  80244d:	89 e5                	mov    %esp,%ebp
  80244f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802452:	8b 45 08             	mov    0x8(%ebp),%eax
  802455:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802458:	6a 01                	push   $0x1
  80245a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80245d:	50                   	push   %eax
  80245e:	e8 25 e6 ff ff       	call   800a88 <sys_cputs>
  802463:	83 c4 10             	add    $0x10,%esp
}
  802466:	c9                   	leave  
  802467:	c3                   	ret    

00802468 <getchar>:

int
getchar(void)
{
  802468:	55                   	push   %ebp
  802469:	89 e5                	mov    %esp,%ebp
  80246b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80246e:	6a 01                	push   $0x1
  802470:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802473:	50                   	push   %eax
  802474:	6a 00                	push   $0x0
  802476:	e8 40 ec ff ff       	call   8010bb <read>
	if (r < 0)
  80247b:	83 c4 10             	add    $0x10,%esp
  80247e:	85 c0                	test   %eax,%eax
  802480:	78 0f                	js     802491 <getchar+0x29>
		return r;
	if (r < 1)
  802482:	85 c0                	test   %eax,%eax
  802484:	7e 06                	jle    80248c <getchar+0x24>
		return -E_EOF;
	return c;
  802486:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80248a:	eb 05                	jmp    802491 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80248c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802491:	c9                   	leave  
  802492:	c3                   	ret    

00802493 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802493:	55                   	push   %ebp
  802494:	89 e5                	mov    %esp,%ebp
  802496:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802499:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80249c:	50                   	push   %eax
  80249d:	ff 75 08             	pushl  0x8(%ebp)
  8024a0:	e8 a7 e9 ff ff       	call   800e4c <fd_lookup>
  8024a5:	83 c4 10             	add    $0x10,%esp
  8024a8:	85 c0                	test   %eax,%eax
  8024aa:	78 11                	js     8024bd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024af:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024b5:	39 10                	cmp    %edx,(%eax)
  8024b7:	0f 94 c0             	sete   %al
  8024ba:	0f b6 c0             	movzbl %al,%eax
}
  8024bd:	c9                   	leave  
  8024be:	c3                   	ret    

008024bf <opencons>:

int
opencons(void)
{
  8024bf:	55                   	push   %ebp
  8024c0:	89 e5                	mov    %esp,%ebp
  8024c2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024c8:	50                   	push   %eax
  8024c9:	e8 2f e9 ff ff       	call   800dfd <fd_alloc>
  8024ce:	83 c4 10             	add    $0x10,%esp
		return r;
  8024d1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024d3:	85 c0                	test   %eax,%eax
  8024d5:	78 3e                	js     802515 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024d7:	83 ec 04             	sub    $0x4,%esp
  8024da:	68 07 04 00 00       	push   $0x407
  8024df:	ff 75 f4             	pushl  -0xc(%ebp)
  8024e2:	6a 00                	push   $0x0
  8024e4:	e8 5b e6 ff ff       	call   800b44 <sys_page_alloc>
  8024e9:	83 c4 10             	add    $0x10,%esp
		return r;
  8024ec:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024ee:	85 c0                	test   %eax,%eax
  8024f0:	78 23                	js     802515 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024f2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024fb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802500:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802507:	83 ec 0c             	sub    $0xc,%esp
  80250a:	50                   	push   %eax
  80250b:	e8 c6 e8 ff ff       	call   800dd6 <fd2num>
  802510:	89 c2                	mov    %eax,%edx
  802512:	83 c4 10             	add    $0x10,%esp
}
  802515:	89 d0                	mov    %edx,%eax
  802517:	c9                   	leave  
  802518:	c3                   	ret    

00802519 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802519:	55                   	push   %ebp
  80251a:	89 e5                	mov    %esp,%ebp
  80251c:	56                   	push   %esi
  80251d:	53                   	push   %ebx
  80251e:	8b 75 08             	mov    0x8(%ebp),%esi
  802521:	8b 45 0c             	mov    0xc(%ebp),%eax
  802524:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  802527:	85 c0                	test   %eax,%eax
  802529:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80252e:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802531:	83 ec 0c             	sub    $0xc,%esp
  802534:	50                   	push   %eax
  802535:	e8 ba e7 ff ff       	call   800cf4 <sys_ipc_recv>
  80253a:	83 c4 10             	add    $0x10,%esp
  80253d:	85 c0                	test   %eax,%eax
  80253f:	79 16                	jns    802557 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802541:	85 f6                	test   %esi,%esi
  802543:	74 06                	je     80254b <ipc_recv+0x32>
  802545:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  80254b:	85 db                	test   %ebx,%ebx
  80254d:	74 2c                	je     80257b <ipc_recv+0x62>
  80254f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802555:	eb 24                	jmp    80257b <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  802557:	85 f6                	test   %esi,%esi
  802559:	74 0a                	je     802565 <ipc_recv+0x4c>
  80255b:	a1 08 40 80 00       	mov    0x804008,%eax
  802560:	8b 40 74             	mov    0x74(%eax),%eax
  802563:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  802565:	85 db                	test   %ebx,%ebx
  802567:	74 0a                	je     802573 <ipc_recv+0x5a>
  802569:	a1 08 40 80 00       	mov    0x804008,%eax
  80256e:	8b 40 78             	mov    0x78(%eax),%eax
  802571:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  802573:	a1 08 40 80 00       	mov    0x804008,%eax
  802578:	8b 40 70             	mov    0x70(%eax),%eax
}
  80257b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80257e:	5b                   	pop    %ebx
  80257f:	5e                   	pop    %esi
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    

00802582 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802582:	55                   	push   %ebp
  802583:	89 e5                	mov    %esp,%ebp
  802585:	57                   	push   %edi
  802586:	56                   	push   %esi
  802587:	53                   	push   %ebx
  802588:	83 ec 0c             	sub    $0xc,%esp
  80258b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80258e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802591:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  802594:	85 db                	test   %ebx,%ebx
  802596:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80259b:	0f 44 d8             	cmove  %eax,%ebx
  80259e:	eb 1c                	jmp    8025bc <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  8025a0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025a3:	74 12                	je     8025b7 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  8025a5:	50                   	push   %eax
  8025a6:	68 a8 2e 80 00       	push   $0x802ea8
  8025ab:	6a 39                	push   $0x39
  8025ad:	68 c3 2e 80 00       	push   $0x802ec3
  8025b2:	e8 24 db ff ff       	call   8000db <_panic>
                 sys_yield();
  8025b7:	e8 69 e5 ff ff       	call   800b25 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8025bc:	ff 75 14             	pushl  0x14(%ebp)
  8025bf:	53                   	push   %ebx
  8025c0:	56                   	push   %esi
  8025c1:	57                   	push   %edi
  8025c2:	e8 0a e7 ff ff       	call   800cd1 <sys_ipc_try_send>
  8025c7:	83 c4 10             	add    $0x10,%esp
  8025ca:	85 c0                	test   %eax,%eax
  8025cc:	78 d2                	js     8025a0 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8025ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025d1:	5b                   	pop    %ebx
  8025d2:	5e                   	pop    %esi
  8025d3:	5f                   	pop    %edi
  8025d4:	5d                   	pop    %ebp
  8025d5:	c3                   	ret    

008025d6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025d6:	55                   	push   %ebp
  8025d7:	89 e5                	mov    %esp,%ebp
  8025d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025dc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025e1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025e4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025ea:	8b 52 50             	mov    0x50(%edx),%edx
  8025ed:	39 ca                	cmp    %ecx,%edx
  8025ef:	75 0d                	jne    8025fe <ipc_find_env+0x28>
			return envs[i].env_id;
  8025f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025f4:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8025f9:	8b 40 08             	mov    0x8(%eax),%eax
  8025fc:	eb 0e                	jmp    80260c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025fe:	83 c0 01             	add    $0x1,%eax
  802601:	3d 00 04 00 00       	cmp    $0x400,%eax
  802606:	75 d9                	jne    8025e1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802608:	66 b8 00 00          	mov    $0x0,%ax
}
  80260c:	5d                   	pop    %ebp
  80260d:	c3                   	ret    

0080260e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80260e:	55                   	push   %ebp
  80260f:	89 e5                	mov    %esp,%ebp
  802611:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802614:	89 d0                	mov    %edx,%eax
  802616:	c1 e8 16             	shr    $0x16,%eax
  802619:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802620:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802625:	f6 c1 01             	test   $0x1,%cl
  802628:	74 1d                	je     802647 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80262a:	c1 ea 0c             	shr    $0xc,%edx
  80262d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802634:	f6 c2 01             	test   $0x1,%dl
  802637:	74 0e                	je     802647 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802639:	c1 ea 0c             	shr    $0xc,%edx
  80263c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802643:	ef 
  802644:	0f b7 c0             	movzwl %ax,%eax
}
  802647:	5d                   	pop    %ebp
  802648:	c3                   	ret    
  802649:	66 90                	xchg   %ax,%ax
  80264b:	66 90                	xchg   %ax,%ax
  80264d:	66 90                	xchg   %ax,%ax
  80264f:	90                   	nop

00802650 <__udivdi3>:
  802650:	55                   	push   %ebp
  802651:	57                   	push   %edi
  802652:	56                   	push   %esi
  802653:	83 ec 10             	sub    $0x10,%esp
  802656:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80265a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80265e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802662:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802666:	85 d2                	test   %edx,%edx
  802668:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80266c:	89 34 24             	mov    %esi,(%esp)
  80266f:	89 c8                	mov    %ecx,%eax
  802671:	75 35                	jne    8026a8 <__udivdi3+0x58>
  802673:	39 f1                	cmp    %esi,%ecx
  802675:	0f 87 bd 00 00 00    	ja     802738 <__udivdi3+0xe8>
  80267b:	85 c9                	test   %ecx,%ecx
  80267d:	89 cd                	mov    %ecx,%ebp
  80267f:	75 0b                	jne    80268c <__udivdi3+0x3c>
  802681:	b8 01 00 00 00       	mov    $0x1,%eax
  802686:	31 d2                	xor    %edx,%edx
  802688:	f7 f1                	div    %ecx
  80268a:	89 c5                	mov    %eax,%ebp
  80268c:	89 f0                	mov    %esi,%eax
  80268e:	31 d2                	xor    %edx,%edx
  802690:	f7 f5                	div    %ebp
  802692:	89 c6                	mov    %eax,%esi
  802694:	89 f8                	mov    %edi,%eax
  802696:	f7 f5                	div    %ebp
  802698:	89 f2                	mov    %esi,%edx
  80269a:	83 c4 10             	add    $0x10,%esp
  80269d:	5e                   	pop    %esi
  80269e:	5f                   	pop    %edi
  80269f:	5d                   	pop    %ebp
  8026a0:	c3                   	ret    
  8026a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a8:	3b 14 24             	cmp    (%esp),%edx
  8026ab:	77 7b                	ja     802728 <__udivdi3+0xd8>
  8026ad:	0f bd f2             	bsr    %edx,%esi
  8026b0:	83 f6 1f             	xor    $0x1f,%esi
  8026b3:	0f 84 97 00 00 00    	je     802750 <__udivdi3+0x100>
  8026b9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8026be:	89 d7                	mov    %edx,%edi
  8026c0:	89 f1                	mov    %esi,%ecx
  8026c2:	29 f5                	sub    %esi,%ebp
  8026c4:	d3 e7                	shl    %cl,%edi
  8026c6:	89 c2                	mov    %eax,%edx
  8026c8:	89 e9                	mov    %ebp,%ecx
  8026ca:	d3 ea                	shr    %cl,%edx
  8026cc:	89 f1                	mov    %esi,%ecx
  8026ce:	09 fa                	or     %edi,%edx
  8026d0:	8b 3c 24             	mov    (%esp),%edi
  8026d3:	d3 e0                	shl    %cl,%eax
  8026d5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8026d9:	89 e9                	mov    %ebp,%ecx
  8026db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026df:	8b 44 24 04          	mov    0x4(%esp),%eax
  8026e3:	89 fa                	mov    %edi,%edx
  8026e5:	d3 ea                	shr    %cl,%edx
  8026e7:	89 f1                	mov    %esi,%ecx
  8026e9:	d3 e7                	shl    %cl,%edi
  8026eb:	89 e9                	mov    %ebp,%ecx
  8026ed:	d3 e8                	shr    %cl,%eax
  8026ef:	09 c7                	or     %eax,%edi
  8026f1:	89 f8                	mov    %edi,%eax
  8026f3:	f7 74 24 08          	divl   0x8(%esp)
  8026f7:	89 d5                	mov    %edx,%ebp
  8026f9:	89 c7                	mov    %eax,%edi
  8026fb:	f7 64 24 0c          	mull   0xc(%esp)
  8026ff:	39 d5                	cmp    %edx,%ebp
  802701:	89 14 24             	mov    %edx,(%esp)
  802704:	72 11                	jb     802717 <__udivdi3+0xc7>
  802706:	8b 54 24 04          	mov    0x4(%esp),%edx
  80270a:	89 f1                	mov    %esi,%ecx
  80270c:	d3 e2                	shl    %cl,%edx
  80270e:	39 c2                	cmp    %eax,%edx
  802710:	73 5e                	jae    802770 <__udivdi3+0x120>
  802712:	3b 2c 24             	cmp    (%esp),%ebp
  802715:	75 59                	jne    802770 <__udivdi3+0x120>
  802717:	8d 47 ff             	lea    -0x1(%edi),%eax
  80271a:	31 f6                	xor    %esi,%esi
  80271c:	89 f2                	mov    %esi,%edx
  80271e:	83 c4 10             	add    $0x10,%esp
  802721:	5e                   	pop    %esi
  802722:	5f                   	pop    %edi
  802723:	5d                   	pop    %ebp
  802724:	c3                   	ret    
  802725:	8d 76 00             	lea    0x0(%esi),%esi
  802728:	31 f6                	xor    %esi,%esi
  80272a:	31 c0                	xor    %eax,%eax
  80272c:	89 f2                	mov    %esi,%edx
  80272e:	83 c4 10             	add    $0x10,%esp
  802731:	5e                   	pop    %esi
  802732:	5f                   	pop    %edi
  802733:	5d                   	pop    %ebp
  802734:	c3                   	ret    
  802735:	8d 76 00             	lea    0x0(%esi),%esi
  802738:	89 f2                	mov    %esi,%edx
  80273a:	31 f6                	xor    %esi,%esi
  80273c:	89 f8                	mov    %edi,%eax
  80273e:	f7 f1                	div    %ecx
  802740:	89 f2                	mov    %esi,%edx
  802742:	83 c4 10             	add    $0x10,%esp
  802745:	5e                   	pop    %esi
  802746:	5f                   	pop    %edi
  802747:	5d                   	pop    %ebp
  802748:	c3                   	ret    
  802749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802750:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802754:	76 0b                	jbe    802761 <__udivdi3+0x111>
  802756:	31 c0                	xor    %eax,%eax
  802758:	3b 14 24             	cmp    (%esp),%edx
  80275b:	0f 83 37 ff ff ff    	jae    802698 <__udivdi3+0x48>
  802761:	b8 01 00 00 00       	mov    $0x1,%eax
  802766:	e9 2d ff ff ff       	jmp    802698 <__udivdi3+0x48>
  80276b:	90                   	nop
  80276c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802770:	89 f8                	mov    %edi,%eax
  802772:	31 f6                	xor    %esi,%esi
  802774:	e9 1f ff ff ff       	jmp    802698 <__udivdi3+0x48>
  802779:	66 90                	xchg   %ax,%ax
  80277b:	66 90                	xchg   %ax,%ax
  80277d:	66 90                	xchg   %ax,%ax
  80277f:	90                   	nop

00802780 <__umoddi3>:
  802780:	55                   	push   %ebp
  802781:	57                   	push   %edi
  802782:	56                   	push   %esi
  802783:	83 ec 20             	sub    $0x20,%esp
  802786:	8b 44 24 34          	mov    0x34(%esp),%eax
  80278a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80278e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802792:	89 c6                	mov    %eax,%esi
  802794:	89 44 24 10          	mov    %eax,0x10(%esp)
  802798:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80279c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8027a0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8027a4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8027a8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8027ac:	85 c0                	test   %eax,%eax
  8027ae:	89 c2                	mov    %eax,%edx
  8027b0:	75 1e                	jne    8027d0 <__umoddi3+0x50>
  8027b2:	39 f7                	cmp    %esi,%edi
  8027b4:	76 52                	jbe    802808 <__umoddi3+0x88>
  8027b6:	89 c8                	mov    %ecx,%eax
  8027b8:	89 f2                	mov    %esi,%edx
  8027ba:	f7 f7                	div    %edi
  8027bc:	89 d0                	mov    %edx,%eax
  8027be:	31 d2                	xor    %edx,%edx
  8027c0:	83 c4 20             	add    $0x20,%esp
  8027c3:	5e                   	pop    %esi
  8027c4:	5f                   	pop    %edi
  8027c5:	5d                   	pop    %ebp
  8027c6:	c3                   	ret    
  8027c7:	89 f6                	mov    %esi,%esi
  8027c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8027d0:	39 f0                	cmp    %esi,%eax
  8027d2:	77 5c                	ja     802830 <__umoddi3+0xb0>
  8027d4:	0f bd e8             	bsr    %eax,%ebp
  8027d7:	83 f5 1f             	xor    $0x1f,%ebp
  8027da:	75 64                	jne    802840 <__umoddi3+0xc0>
  8027dc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8027e0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8027e4:	0f 86 f6 00 00 00    	jbe    8028e0 <__umoddi3+0x160>
  8027ea:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8027ee:	0f 82 ec 00 00 00    	jb     8028e0 <__umoddi3+0x160>
  8027f4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8027f8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8027fc:	83 c4 20             	add    $0x20,%esp
  8027ff:	5e                   	pop    %esi
  802800:	5f                   	pop    %edi
  802801:	5d                   	pop    %ebp
  802802:	c3                   	ret    
  802803:	90                   	nop
  802804:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802808:	85 ff                	test   %edi,%edi
  80280a:	89 fd                	mov    %edi,%ebp
  80280c:	75 0b                	jne    802819 <__umoddi3+0x99>
  80280e:	b8 01 00 00 00       	mov    $0x1,%eax
  802813:	31 d2                	xor    %edx,%edx
  802815:	f7 f7                	div    %edi
  802817:	89 c5                	mov    %eax,%ebp
  802819:	8b 44 24 10          	mov    0x10(%esp),%eax
  80281d:	31 d2                	xor    %edx,%edx
  80281f:	f7 f5                	div    %ebp
  802821:	89 c8                	mov    %ecx,%eax
  802823:	f7 f5                	div    %ebp
  802825:	eb 95                	jmp    8027bc <__umoddi3+0x3c>
  802827:	89 f6                	mov    %esi,%esi
  802829:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802830:	89 c8                	mov    %ecx,%eax
  802832:	89 f2                	mov    %esi,%edx
  802834:	83 c4 20             	add    $0x20,%esp
  802837:	5e                   	pop    %esi
  802838:	5f                   	pop    %edi
  802839:	5d                   	pop    %ebp
  80283a:	c3                   	ret    
  80283b:	90                   	nop
  80283c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802840:	b8 20 00 00 00       	mov    $0x20,%eax
  802845:	89 e9                	mov    %ebp,%ecx
  802847:	29 e8                	sub    %ebp,%eax
  802849:	d3 e2                	shl    %cl,%edx
  80284b:	89 c7                	mov    %eax,%edi
  80284d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802851:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802855:	89 f9                	mov    %edi,%ecx
  802857:	d3 e8                	shr    %cl,%eax
  802859:	89 c1                	mov    %eax,%ecx
  80285b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80285f:	09 d1                	or     %edx,%ecx
  802861:	89 fa                	mov    %edi,%edx
  802863:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802867:	89 e9                	mov    %ebp,%ecx
  802869:	d3 e0                	shl    %cl,%eax
  80286b:	89 f9                	mov    %edi,%ecx
  80286d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802871:	89 f0                	mov    %esi,%eax
  802873:	d3 e8                	shr    %cl,%eax
  802875:	89 e9                	mov    %ebp,%ecx
  802877:	89 c7                	mov    %eax,%edi
  802879:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80287d:	d3 e6                	shl    %cl,%esi
  80287f:	89 d1                	mov    %edx,%ecx
  802881:	89 fa                	mov    %edi,%edx
  802883:	d3 e8                	shr    %cl,%eax
  802885:	89 e9                	mov    %ebp,%ecx
  802887:	09 f0                	or     %esi,%eax
  802889:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80288d:	f7 74 24 10          	divl   0x10(%esp)
  802891:	d3 e6                	shl    %cl,%esi
  802893:	89 d1                	mov    %edx,%ecx
  802895:	f7 64 24 0c          	mull   0xc(%esp)
  802899:	39 d1                	cmp    %edx,%ecx
  80289b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80289f:	89 d7                	mov    %edx,%edi
  8028a1:	89 c6                	mov    %eax,%esi
  8028a3:	72 0a                	jb     8028af <__umoddi3+0x12f>
  8028a5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8028a9:	73 10                	jae    8028bb <__umoddi3+0x13b>
  8028ab:	39 d1                	cmp    %edx,%ecx
  8028ad:	75 0c                	jne    8028bb <__umoddi3+0x13b>
  8028af:	89 d7                	mov    %edx,%edi
  8028b1:	89 c6                	mov    %eax,%esi
  8028b3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8028b7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8028bb:	89 ca                	mov    %ecx,%edx
  8028bd:	89 e9                	mov    %ebp,%ecx
  8028bf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028c3:	29 f0                	sub    %esi,%eax
  8028c5:	19 fa                	sbb    %edi,%edx
  8028c7:	d3 e8                	shr    %cl,%eax
  8028c9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8028ce:	89 d7                	mov    %edx,%edi
  8028d0:	d3 e7                	shl    %cl,%edi
  8028d2:	89 e9                	mov    %ebp,%ecx
  8028d4:	09 f8                	or     %edi,%eax
  8028d6:	d3 ea                	shr    %cl,%edx
  8028d8:	83 c4 20             	add    $0x20,%esp
  8028db:	5e                   	pop    %esi
  8028dc:	5f                   	pop    %edi
  8028dd:	5d                   	pop    %ebp
  8028de:	c3                   	ret    
  8028df:	90                   	nop
  8028e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8028e4:	29 f9                	sub    %edi,%ecx
  8028e6:	19 c6                	sbb    %eax,%esi
  8028e8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8028ec:	89 74 24 18          	mov    %esi,0x18(%esp)
  8028f0:	e9 ff fe ff ff       	jmp    8027f4 <__umoddi3+0x74>
