
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 40 13 80 00       	push   $0x801340
  80003f:	e8 5c 01 00 00       	call   8001a0 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 78 0d 00 00       	call   800dc1 <fork>
  800049:	89 c3                	mov    %eax,%ebx
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 12                	jne    800064 <umain+0x31>
		cprintf("I am the child.  Spinning...\n");
  800052:	83 ec 0c             	sub    $0xc,%esp
  800055:	68 b8 13 80 00       	push   $0x8013b8
  80005a:	e8 41 01 00 00       	call   8001a0 <cprintf>
  80005f:	83 c4 10             	add    $0x10,%esp
		while (1)
			/* do nothing */;
  800062:	eb fe                	jmp    800062 <umain+0x2f>
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 68 13 80 00       	push   $0x801368
  80006c:	e8 2f 01 00 00       	call   8001a0 <cprintf>
	sys_yield();
  800071:	e8 9b 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800076:	e8 96 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80007b:	e8 91 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800080:	e8 8c 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800085:	e8 87 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80008a:	e8 82 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80008f:	e8 7d 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800094:	e8 78 0a 00 00       	call   800b11 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 90 13 80 00 	movl   $0x801390,(%esp)
  8000a0:	e8 fb 00 00 00       	call   8001a0 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 04 0a 00 00       	call   800ab1 <sys_env_destroy>
  8000ad:	83 c4 10             	add    $0x10,%esp
}
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000c0:	e8 2d 0a 00 00       	call   800af2 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
  8000f1:	83 c4 10             	add    $0x10,%esp
}
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 a9 09 00 00       	call   800ab1 <sys_env_destroy>
  800108:	83 c4 10             	add    $0x10,%esp
}
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	53                   	push   %ebx
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800117:	8b 13                	mov    (%ebx),%edx
  800119:	8d 42 01             	lea    0x1(%edx),%eax
  80011c:	89 03                	mov    %eax,(%ebx)
  80011e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800121:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800125:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012a:	75 1a                	jne    800146 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80012c:	83 ec 08             	sub    $0x8,%esp
  80012f:	68 ff 00 00 00       	push   $0xff
  800134:	8d 43 08             	lea    0x8(%ebx),%eax
  800137:	50                   	push   %eax
  800138:	e8 37 09 00 00       	call   800a74 <sys_cputs>
		b->idx = 0;
  80013d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800143:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800146:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800158:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	ff 75 0c             	pushl  0xc(%ebp)
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	68 0d 01 80 00       	push   $0x80010d
  80017e:	e8 4f 01 00 00       	call   8002d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800183:	83 c4 08             	add    $0x8,%esp
  800186:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	e8 dc 08 00 00       	call   800a74 <sys_cputs>

	return b.cnt;
}
  800198:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a9:	50                   	push   %eax
  8001aa:	ff 75 08             	pushl  0x8(%ebp)
  8001ad:	e8 9d ff ff ff       	call   80014f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 1c             	sub    $0x1c,%esp
  8001bd:	89 c7                	mov    %eax,%edi
  8001bf:	89 d6                	mov    %edx,%esi
  8001c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c7:	89 d1                	mov    %edx,%ecx
  8001c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001cc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001df:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001e2:	72 05                	jb     8001e9 <printnum+0x35>
  8001e4:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001e7:	77 3e                	ja     800227 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	ff 75 18             	pushl  0x18(%ebp)
  8001ef:	83 eb 01             	sub    $0x1,%ebx
  8001f2:	53                   	push   %ebx
  8001f3:	50                   	push   %eax
  8001f4:	83 ec 08             	sub    $0x8,%esp
  8001f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fd:	ff 75 dc             	pushl  -0x24(%ebp)
  800200:	ff 75 d8             	pushl  -0x28(%ebp)
  800203:	e8 78 0e 00 00       	call   801080 <__udivdi3>
  800208:	83 c4 18             	add    $0x18,%esp
  80020b:	52                   	push   %edx
  80020c:	50                   	push   %eax
  80020d:	89 f2                	mov    %esi,%edx
  80020f:	89 f8                	mov    %edi,%eax
  800211:	e8 9e ff ff ff       	call   8001b4 <printnum>
  800216:	83 c4 20             	add    $0x20,%esp
  800219:	eb 13                	jmp    80022e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	ff 75 18             	pushl  0x18(%ebp)
  800222:	ff d7                	call   *%edi
  800224:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800227:	83 eb 01             	sub    $0x1,%ebx
  80022a:	85 db                	test   %ebx,%ebx
  80022c:	7f ed                	jg     80021b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022e:	83 ec 08             	sub    $0x8,%esp
  800231:	56                   	push   %esi
  800232:	83 ec 04             	sub    $0x4,%esp
  800235:	ff 75 e4             	pushl  -0x1c(%ebp)
  800238:	ff 75 e0             	pushl  -0x20(%ebp)
  80023b:	ff 75 dc             	pushl  -0x24(%ebp)
  80023e:	ff 75 d8             	pushl  -0x28(%ebp)
  800241:	e8 6a 0f 00 00       	call   8011b0 <__umoddi3>
  800246:	83 c4 14             	add    $0x14,%esp
  800249:	0f be 80 e0 13 80 00 	movsbl 0x8013e0(%eax),%eax
  800250:	50                   	push   %eax
  800251:	ff d7                	call   *%edi
  800253:	83 c4 10             	add    $0x10,%esp
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800261:	83 fa 01             	cmp    $0x1,%edx
  800264:	7e 0e                	jle    800274 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800266:	8b 10                	mov    (%eax),%edx
  800268:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 02                	mov    (%edx),%eax
  80026f:	8b 52 04             	mov    0x4(%edx),%edx
  800272:	eb 22                	jmp    800296 <getuint+0x38>
	else if (lflag)
  800274:	85 d2                	test   %edx,%edx
  800276:	74 10                	je     800288 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027d:	89 08                	mov    %ecx,(%eax)
  80027f:	8b 02                	mov    (%edx),%eax
  800281:	ba 00 00 00 00       	mov    $0x0,%edx
  800286:	eb 0e                	jmp    800296 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800288:	8b 10                	mov    (%eax),%edx
  80028a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028d:	89 08                	mov    %ecx,(%eax)
  80028f:	8b 02                	mov    (%edx),%eax
  800291:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a7:	73 0a                	jae    8002b3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ac:	89 08                	mov    %ecx,(%eax)
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	88 02                	mov    %al,(%edx)
}
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002bb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002be:	50                   	push   %eax
  8002bf:	ff 75 10             	pushl  0x10(%ebp)
  8002c2:	ff 75 0c             	pushl  0xc(%ebp)
  8002c5:	ff 75 08             	pushl  0x8(%ebp)
  8002c8:	e8 05 00 00 00       	call   8002d2 <vprintfmt>
	va_end(ap);
  8002cd:	83 c4 10             	add    $0x10,%esp
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 2c             	sub    $0x2c,%esp
  8002db:	8b 75 08             	mov    0x8(%ebp),%esi
  8002de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e4:	eb 12                	jmp    8002f8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e6:	85 c0                	test   %eax,%eax
  8002e8:	0f 84 90 03 00 00    	je     80067e <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002ee:	83 ec 08             	sub    $0x8,%esp
  8002f1:	53                   	push   %ebx
  8002f2:	50                   	push   %eax
  8002f3:	ff d6                	call   *%esi
  8002f5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f8:	83 c7 01             	add    $0x1,%edi
  8002fb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ff:	83 f8 25             	cmp    $0x25,%eax
  800302:	75 e2                	jne    8002e6 <vprintfmt+0x14>
  800304:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800308:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80030f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800316:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
  800322:	eb 07                	jmp    80032b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800327:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032b:	8d 47 01             	lea    0x1(%edi),%eax
  80032e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800331:	0f b6 07             	movzbl (%edi),%eax
  800334:	0f b6 c8             	movzbl %al,%ecx
  800337:	83 e8 23             	sub    $0x23,%eax
  80033a:	3c 55                	cmp    $0x55,%al
  80033c:	0f 87 21 03 00 00    	ja     800663 <vprintfmt+0x391>
  800342:	0f b6 c0             	movzbl %al,%eax
  800345:	ff 24 85 a0 14 80 00 	jmp    *0x8014a0(,%eax,4)
  80034c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800353:	eb d6                	jmp    80032b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800358:	b8 00 00 00 00       	mov    $0x0,%eax
  80035d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800360:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800363:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800367:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80036a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80036d:	83 fa 09             	cmp    $0x9,%edx
  800370:	77 39                	ja     8003ab <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800372:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800375:	eb e9                	jmp    800360 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800377:	8b 45 14             	mov    0x14(%ebp),%eax
  80037a:	8d 48 04             	lea    0x4(%eax),%ecx
  80037d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800380:	8b 00                	mov    (%eax),%eax
  800382:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800388:	eb 27                	jmp    8003b1 <vprintfmt+0xdf>
  80038a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038d:	85 c0                	test   %eax,%eax
  80038f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800394:	0f 49 c8             	cmovns %eax,%ecx
  800397:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039d:	eb 8c                	jmp    80032b <vprintfmt+0x59>
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a9:	eb 80                	jmp    80032b <vprintfmt+0x59>
  8003ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ae:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b5:	0f 89 70 ff ff ff    	jns    80032b <vprintfmt+0x59>
				width = precision, precision = -1;
  8003bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c8:	e9 5e ff ff ff       	jmp    80032b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003cd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d3:	e9 53 ff ff ff       	jmp    80032b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8d 50 04             	lea    0x4(%eax),%edx
  8003de:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e1:	83 ec 08             	sub    $0x8,%esp
  8003e4:	53                   	push   %ebx
  8003e5:	ff 30                	pushl  (%eax)
  8003e7:	ff d6                	call   *%esi
			break;
  8003e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ef:	e9 04 ff ff ff       	jmp    8002f8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 50 04             	lea    0x4(%eax),%edx
  8003fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fd:	8b 00                	mov    (%eax),%eax
  8003ff:	99                   	cltd   
  800400:	31 d0                	xor    %edx,%eax
  800402:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800404:	83 f8 09             	cmp    $0x9,%eax
  800407:	7f 0b                	jg     800414 <vprintfmt+0x142>
  800409:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  800410:	85 d2                	test   %edx,%edx
  800412:	75 18                	jne    80042c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800414:	50                   	push   %eax
  800415:	68 f8 13 80 00       	push   $0x8013f8
  80041a:	53                   	push   %ebx
  80041b:	56                   	push   %esi
  80041c:	e8 94 fe ff ff       	call   8002b5 <printfmt>
  800421:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800427:	e9 cc fe ff ff       	jmp    8002f8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80042c:	52                   	push   %edx
  80042d:	68 01 14 80 00       	push   $0x801401
  800432:	53                   	push   %ebx
  800433:	56                   	push   %esi
  800434:	e8 7c fe ff ff       	call   8002b5 <printfmt>
  800439:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043f:	e9 b4 fe ff ff       	jmp    8002f8 <vprintfmt+0x26>
  800444:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800447:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80044a:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 50 04             	lea    0x4(%eax),%edx
  800453:	89 55 14             	mov    %edx,0x14(%ebp)
  800456:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800458:	85 ff                	test   %edi,%edi
  80045a:	ba f1 13 80 00       	mov    $0x8013f1,%edx
  80045f:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800462:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800466:	0f 84 92 00 00 00    	je     8004fe <vprintfmt+0x22c>
  80046c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800470:	0f 8e 96 00 00 00    	jle    80050c <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	51                   	push   %ecx
  80047a:	57                   	push   %edi
  80047b:	e8 86 02 00 00       	call   800706 <strnlen>
  800480:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800483:	29 c1                	sub    %eax,%ecx
  800485:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800488:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80048b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80048f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800492:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800495:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800497:	eb 0f                	jmp    8004a8 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	53                   	push   %ebx
  80049d:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a2:	83 ef 01             	sub    $0x1,%edi
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	85 ff                	test   %edi,%edi
  8004aa:	7f ed                	jg     800499 <vprintfmt+0x1c7>
  8004ac:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004af:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b2:	85 c9                	test   %ecx,%ecx
  8004b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b9:	0f 49 c1             	cmovns %ecx,%eax
  8004bc:	29 c1                	sub    %eax,%ecx
  8004be:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c7:	89 cb                	mov    %ecx,%ebx
  8004c9:	eb 4d                	jmp    800518 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004cf:	74 1b                	je     8004ec <vprintfmt+0x21a>
  8004d1:	0f be c0             	movsbl %al,%eax
  8004d4:	83 e8 20             	sub    $0x20,%eax
  8004d7:	83 f8 5e             	cmp    $0x5e,%eax
  8004da:	76 10                	jbe    8004ec <vprintfmt+0x21a>
					putch('?', putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	ff 75 0c             	pushl  0xc(%ebp)
  8004e2:	6a 3f                	push   $0x3f
  8004e4:	ff 55 08             	call   *0x8(%ebp)
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	eb 0d                	jmp    8004f9 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	ff 75 0c             	pushl  0xc(%ebp)
  8004f2:	52                   	push   %edx
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f9:	83 eb 01             	sub    $0x1,%ebx
  8004fc:	eb 1a                	jmp    800518 <vprintfmt+0x246>
  8004fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800501:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800504:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800507:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050a:	eb 0c                	jmp    800518 <vprintfmt+0x246>
  80050c:	89 75 08             	mov    %esi,0x8(%ebp)
  80050f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800512:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800515:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800518:	83 c7 01             	add    $0x1,%edi
  80051b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051f:	0f be d0             	movsbl %al,%edx
  800522:	85 d2                	test   %edx,%edx
  800524:	74 23                	je     800549 <vprintfmt+0x277>
  800526:	85 f6                	test   %esi,%esi
  800528:	78 a1                	js     8004cb <vprintfmt+0x1f9>
  80052a:	83 ee 01             	sub    $0x1,%esi
  80052d:	79 9c                	jns    8004cb <vprintfmt+0x1f9>
  80052f:	89 df                	mov    %ebx,%edi
  800531:	8b 75 08             	mov    0x8(%ebp),%esi
  800534:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800537:	eb 18                	jmp    800551 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	53                   	push   %ebx
  80053d:	6a 20                	push   $0x20
  80053f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800541:	83 ef 01             	sub    $0x1,%edi
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	eb 08                	jmp    800551 <vprintfmt+0x27f>
  800549:	89 df                	mov    %ebx,%edi
  80054b:	8b 75 08             	mov    0x8(%ebp),%esi
  80054e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800551:	85 ff                	test   %edi,%edi
  800553:	7f e4                	jg     800539 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800555:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800558:	e9 9b fd ff ff       	jmp    8002f8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055d:	83 fa 01             	cmp    $0x1,%edx
  800560:	7e 16                	jle    800578 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 50 08             	lea    0x8(%eax),%edx
  800568:	89 55 14             	mov    %edx,0x14(%ebp)
  80056b:	8b 50 04             	mov    0x4(%eax),%edx
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800573:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800576:	eb 32                	jmp    8005aa <vprintfmt+0x2d8>
	else if (lflag)
  800578:	85 d2                	test   %edx,%edx
  80057a:	74 18                	je     800594 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 50 04             	lea    0x4(%eax),%edx
  800582:	89 55 14             	mov    %edx,0x14(%ebp)
  800585:	8b 00                	mov    (%eax),%eax
  800587:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058a:	89 c1                	mov    %eax,%ecx
  80058c:	c1 f9 1f             	sar    $0x1f,%ecx
  80058f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800592:	eb 16                	jmp    8005aa <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 04             	lea    0x4(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 00                	mov    (%eax),%eax
  80059f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a2:	89 c1                	mov    %eax,%ecx
  8005a4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b9:	79 74                	jns    80062f <vprintfmt+0x35d>
				putch('-', putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	53                   	push   %ebx
  8005bf:	6a 2d                	push   $0x2d
  8005c1:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005c9:	f7 d8                	neg    %eax
  8005cb:	83 d2 00             	adc    $0x0,%edx
  8005ce:	f7 da                	neg    %edx
  8005d0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005d8:	eb 55                	jmp    80062f <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005da:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dd:	e8 7c fc ff ff       	call   80025e <getuint>
			base = 10;
  8005e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005e7:	eb 46                	jmp    80062f <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ec:	e8 6d fc ff ff       	call   80025e <getuint>
                        base = 8;
  8005f1:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005f6:	eb 37                	jmp    80062f <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	53                   	push   %ebx
  8005fc:	6a 30                	push   $0x30
  8005fe:	ff d6                	call   *%esi
			putch('x', putdat);
  800600:	83 c4 08             	add    $0x8,%esp
  800603:	53                   	push   %ebx
  800604:	6a 78                	push   $0x78
  800606:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 04             	lea    0x4(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800611:	8b 00                	mov    (%eax),%eax
  800613:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800618:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80061b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800620:	eb 0d                	jmp    80062f <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	e8 34 fc ff ff       	call   80025e <getuint>
			base = 16;
  80062a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062f:	83 ec 0c             	sub    $0xc,%esp
  800632:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800636:	57                   	push   %edi
  800637:	ff 75 e0             	pushl  -0x20(%ebp)
  80063a:	51                   	push   %ecx
  80063b:	52                   	push   %edx
  80063c:	50                   	push   %eax
  80063d:	89 da                	mov    %ebx,%edx
  80063f:	89 f0                	mov    %esi,%eax
  800641:	e8 6e fb ff ff       	call   8001b4 <printnum>
			break;
  800646:	83 c4 20             	add    $0x20,%esp
  800649:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80064c:	e9 a7 fc ff ff       	jmp    8002f8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	51                   	push   %ecx
  800656:	ff d6                	call   *%esi
			break;
  800658:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80065e:	e9 95 fc ff ff       	jmp    8002f8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	6a 25                	push   $0x25
  800669:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066b:	83 c4 10             	add    $0x10,%esp
  80066e:	eb 03                	jmp    800673 <vprintfmt+0x3a1>
  800670:	83 ef 01             	sub    $0x1,%edi
  800673:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800677:	75 f7                	jne    800670 <vprintfmt+0x39e>
  800679:	e9 7a fc ff ff       	jmp    8002f8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80067e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800681:	5b                   	pop    %ebx
  800682:	5e                   	pop    %esi
  800683:	5f                   	pop    %edi
  800684:	5d                   	pop    %ebp
  800685:	c3                   	ret    

00800686 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	83 ec 18             	sub    $0x18,%esp
  80068c:	8b 45 08             	mov    0x8(%ebp),%eax
  80068f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800692:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800695:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800699:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	74 26                	je     8006cd <vsnprintf+0x47>
  8006a7:	85 d2                	test   %edx,%edx
  8006a9:	7e 22                	jle    8006cd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ab:	ff 75 14             	pushl  0x14(%ebp)
  8006ae:	ff 75 10             	pushl  0x10(%ebp)
  8006b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b4:	50                   	push   %eax
  8006b5:	68 98 02 80 00       	push   $0x800298
  8006ba:	e8 13 fc ff ff       	call   8002d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	eb 05                	jmp    8006d2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006da:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006dd:	50                   	push   %eax
  8006de:	ff 75 10             	pushl  0x10(%ebp)
  8006e1:	ff 75 0c             	pushl  0xc(%ebp)
  8006e4:	ff 75 08             	pushl  0x8(%ebp)
  8006e7:	e8 9a ff ff ff       	call   800686 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ec:	c9                   	leave  
  8006ed:	c3                   	ret    

008006ee <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f9:	eb 03                	jmp    8006fe <strlen+0x10>
		n++;
  8006fb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800702:	75 f7                	jne    8006fb <strlen+0xd>
		n++;
	return n;
}
  800704:	5d                   	pop    %ebp
  800705:	c3                   	ret    

00800706 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070f:	ba 00 00 00 00       	mov    $0x0,%edx
  800714:	eb 03                	jmp    800719 <strnlen+0x13>
		n++;
  800716:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800719:	39 c2                	cmp    %eax,%edx
  80071b:	74 08                	je     800725 <strnlen+0x1f>
  80071d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800721:	75 f3                	jne    800716 <strnlen+0x10>
  800723:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	53                   	push   %ebx
  80072b:	8b 45 08             	mov    0x8(%ebp),%eax
  80072e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800731:	89 c2                	mov    %eax,%edx
  800733:	83 c2 01             	add    $0x1,%edx
  800736:	83 c1 01             	add    $0x1,%ecx
  800739:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80073d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800740:	84 db                	test   %bl,%bl
  800742:	75 ef                	jne    800733 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800744:	5b                   	pop    %ebx
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	53                   	push   %ebx
  80074b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074e:	53                   	push   %ebx
  80074f:	e8 9a ff ff ff       	call   8006ee <strlen>
  800754:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800757:	ff 75 0c             	pushl  0xc(%ebp)
  80075a:	01 d8                	add    %ebx,%eax
  80075c:	50                   	push   %eax
  80075d:	e8 c5 ff ff ff       	call   800727 <strcpy>
	return dst;
}
  800762:	89 d8                	mov    %ebx,%eax
  800764:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800767:	c9                   	leave  
  800768:	c3                   	ret    

00800769 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	56                   	push   %esi
  80076d:	53                   	push   %ebx
  80076e:	8b 75 08             	mov    0x8(%ebp),%esi
  800771:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800774:	89 f3                	mov    %esi,%ebx
  800776:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800779:	89 f2                	mov    %esi,%edx
  80077b:	eb 0f                	jmp    80078c <strncpy+0x23>
		*dst++ = *src;
  80077d:	83 c2 01             	add    $0x1,%edx
  800780:	0f b6 01             	movzbl (%ecx),%eax
  800783:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800786:	80 39 01             	cmpb   $0x1,(%ecx)
  800789:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078c:	39 da                	cmp    %ebx,%edx
  80078e:	75 ed                	jne    80077d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800790:	89 f0                	mov    %esi,%eax
  800792:	5b                   	pop    %ebx
  800793:	5e                   	pop    %esi
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	56                   	push   %esi
  80079a:	53                   	push   %ebx
  80079b:	8b 75 08             	mov    0x8(%ebp),%esi
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007a4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a6:	85 d2                	test   %edx,%edx
  8007a8:	74 21                	je     8007cb <strlcpy+0x35>
  8007aa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ae:	89 f2                	mov    %esi,%edx
  8007b0:	eb 09                	jmp    8007bb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b2:	83 c2 01             	add    $0x1,%edx
  8007b5:	83 c1 01             	add    $0x1,%ecx
  8007b8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007bb:	39 c2                	cmp    %eax,%edx
  8007bd:	74 09                	je     8007c8 <strlcpy+0x32>
  8007bf:	0f b6 19             	movzbl (%ecx),%ebx
  8007c2:	84 db                	test   %bl,%bl
  8007c4:	75 ec                	jne    8007b2 <strlcpy+0x1c>
  8007c6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007cb:	29 f0                	sub    %esi,%eax
}
  8007cd:	5b                   	pop    %ebx
  8007ce:	5e                   	pop    %esi
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007da:	eb 06                	jmp    8007e2 <strcmp+0x11>
		p++, q++;
  8007dc:	83 c1 01             	add    $0x1,%ecx
  8007df:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e2:	0f b6 01             	movzbl (%ecx),%eax
  8007e5:	84 c0                	test   %al,%al
  8007e7:	74 04                	je     8007ed <strcmp+0x1c>
  8007e9:	3a 02                	cmp    (%edx),%al
  8007eb:	74 ef                	je     8007dc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ed:	0f b6 c0             	movzbl %al,%eax
  8007f0:	0f b6 12             	movzbl (%edx),%edx
  8007f3:	29 d0                	sub    %edx,%eax
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800801:	89 c3                	mov    %eax,%ebx
  800803:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800806:	eb 06                	jmp    80080e <strncmp+0x17>
		n--, p++, q++;
  800808:	83 c0 01             	add    $0x1,%eax
  80080b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80080e:	39 d8                	cmp    %ebx,%eax
  800810:	74 15                	je     800827 <strncmp+0x30>
  800812:	0f b6 08             	movzbl (%eax),%ecx
  800815:	84 c9                	test   %cl,%cl
  800817:	74 04                	je     80081d <strncmp+0x26>
  800819:	3a 0a                	cmp    (%edx),%cl
  80081b:	74 eb                	je     800808 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80081d:	0f b6 00             	movzbl (%eax),%eax
  800820:	0f b6 12             	movzbl (%edx),%edx
  800823:	29 d0                	sub    %edx,%eax
  800825:	eb 05                	jmp    80082c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80082c:	5b                   	pop    %ebx
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	8b 45 08             	mov    0x8(%ebp),%eax
  800835:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800839:	eb 07                	jmp    800842 <strchr+0x13>
		if (*s == c)
  80083b:	38 ca                	cmp    %cl,%dl
  80083d:	74 0f                	je     80084e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80083f:	83 c0 01             	add    $0x1,%eax
  800842:	0f b6 10             	movzbl (%eax),%edx
  800845:	84 d2                	test   %dl,%dl
  800847:	75 f2                	jne    80083b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800849:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085a:	eb 03                	jmp    80085f <strfind+0xf>
  80085c:	83 c0 01             	add    $0x1,%eax
  80085f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800862:	84 d2                	test   %dl,%dl
  800864:	74 04                	je     80086a <strfind+0x1a>
  800866:	38 ca                	cmp    %cl,%dl
  800868:	75 f2                	jne    80085c <strfind+0xc>
			break;
	return (char *) s;
}
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	57                   	push   %edi
  800870:	56                   	push   %esi
  800871:	53                   	push   %ebx
  800872:	8b 7d 08             	mov    0x8(%ebp),%edi
  800875:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800878:	85 c9                	test   %ecx,%ecx
  80087a:	74 36                	je     8008b2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80087c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800882:	75 28                	jne    8008ac <memset+0x40>
  800884:	f6 c1 03             	test   $0x3,%cl
  800887:	75 23                	jne    8008ac <memset+0x40>
		c &= 0xFF;
  800889:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80088d:	89 d3                	mov    %edx,%ebx
  80088f:	c1 e3 08             	shl    $0x8,%ebx
  800892:	89 d6                	mov    %edx,%esi
  800894:	c1 e6 18             	shl    $0x18,%esi
  800897:	89 d0                	mov    %edx,%eax
  800899:	c1 e0 10             	shl    $0x10,%eax
  80089c:	09 f0                	or     %esi,%eax
  80089e:	09 c2                	or     %eax,%edx
  8008a0:	89 d0                	mov    %edx,%eax
  8008a2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008a7:	fc                   	cld    
  8008a8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008aa:	eb 06                	jmp    8008b2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008af:	fc                   	cld    
  8008b0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b2:	89 f8                	mov    %edi,%eax
  8008b4:	5b                   	pop    %ebx
  8008b5:	5e                   	pop    %esi
  8008b6:	5f                   	pop    %edi
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	57                   	push   %edi
  8008bd:	56                   	push   %esi
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c7:	39 c6                	cmp    %eax,%esi
  8008c9:	73 35                	jae    800900 <memmove+0x47>
  8008cb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ce:	39 d0                	cmp    %edx,%eax
  8008d0:	73 2e                	jae    800900 <memmove+0x47>
		s += n;
		d += n;
  8008d2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008d5:	89 d6                	mov    %edx,%esi
  8008d7:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008df:	75 13                	jne    8008f4 <memmove+0x3b>
  8008e1:	f6 c1 03             	test   $0x3,%cl
  8008e4:	75 0e                	jne    8008f4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e6:	83 ef 04             	sub    $0x4,%edi
  8008e9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ec:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008ef:	fd                   	std    
  8008f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f2:	eb 09                	jmp    8008fd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f4:	83 ef 01             	sub    $0x1,%edi
  8008f7:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fa:	fd                   	std    
  8008fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fd:	fc                   	cld    
  8008fe:	eb 1d                	jmp    80091d <memmove+0x64>
  800900:	89 f2                	mov    %esi,%edx
  800902:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800904:	f6 c2 03             	test   $0x3,%dl
  800907:	75 0f                	jne    800918 <memmove+0x5f>
  800909:	f6 c1 03             	test   $0x3,%cl
  80090c:	75 0a                	jne    800918 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80090e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800911:	89 c7                	mov    %eax,%edi
  800913:	fc                   	cld    
  800914:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800916:	eb 05                	jmp    80091d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800918:	89 c7                	mov    %eax,%edi
  80091a:	fc                   	cld    
  80091b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091d:	5e                   	pop    %esi
  80091e:	5f                   	pop    %edi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800924:	ff 75 10             	pushl  0x10(%ebp)
  800927:	ff 75 0c             	pushl  0xc(%ebp)
  80092a:	ff 75 08             	pushl  0x8(%ebp)
  80092d:	e8 87 ff ff ff       	call   8008b9 <memmove>
}
  800932:	c9                   	leave  
  800933:	c3                   	ret    

00800934 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093f:	89 c6                	mov    %eax,%esi
  800941:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800944:	eb 1a                	jmp    800960 <memcmp+0x2c>
		if (*s1 != *s2)
  800946:	0f b6 08             	movzbl (%eax),%ecx
  800949:	0f b6 1a             	movzbl (%edx),%ebx
  80094c:	38 d9                	cmp    %bl,%cl
  80094e:	74 0a                	je     80095a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800950:	0f b6 c1             	movzbl %cl,%eax
  800953:	0f b6 db             	movzbl %bl,%ebx
  800956:	29 d8                	sub    %ebx,%eax
  800958:	eb 0f                	jmp    800969 <memcmp+0x35>
		s1++, s2++;
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800960:	39 f0                	cmp    %esi,%eax
  800962:	75 e2                	jne    800946 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800976:	89 c2                	mov    %eax,%edx
  800978:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80097b:	eb 07                	jmp    800984 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097d:	38 08                	cmp    %cl,(%eax)
  80097f:	74 07                	je     800988 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800981:	83 c0 01             	add    $0x1,%eax
  800984:	39 d0                	cmp    %edx,%eax
  800986:	72 f5                	jb     80097d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	57                   	push   %edi
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800993:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800996:	eb 03                	jmp    80099b <strtol+0x11>
		s++;
  800998:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099b:	0f b6 01             	movzbl (%ecx),%eax
  80099e:	3c 09                	cmp    $0x9,%al
  8009a0:	74 f6                	je     800998 <strtol+0xe>
  8009a2:	3c 20                	cmp    $0x20,%al
  8009a4:	74 f2                	je     800998 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a6:	3c 2b                	cmp    $0x2b,%al
  8009a8:	75 0a                	jne    8009b4 <strtol+0x2a>
		s++;
  8009aa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ad:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b2:	eb 10                	jmp    8009c4 <strtol+0x3a>
  8009b4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b9:	3c 2d                	cmp    $0x2d,%al
  8009bb:	75 07                	jne    8009c4 <strtol+0x3a>
		s++, neg = 1;
  8009bd:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009c0:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c4:	85 db                	test   %ebx,%ebx
  8009c6:	0f 94 c0             	sete   %al
  8009c9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009cf:	75 19                	jne    8009ea <strtol+0x60>
  8009d1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d4:	75 14                	jne    8009ea <strtol+0x60>
  8009d6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009da:	0f 85 82 00 00 00    	jne    800a62 <strtol+0xd8>
		s += 2, base = 16;
  8009e0:	83 c1 02             	add    $0x2,%ecx
  8009e3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e8:	eb 16                	jmp    800a00 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009ea:	84 c0                	test   %al,%al
  8009ec:	74 12                	je     800a00 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ee:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f6:	75 08                	jne    800a00 <strtol+0x76>
		s++, base = 8;
  8009f8:	83 c1 01             	add    $0x1,%ecx
  8009fb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
  800a05:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a08:	0f b6 11             	movzbl (%ecx),%edx
  800a0b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a0e:	89 f3                	mov    %esi,%ebx
  800a10:	80 fb 09             	cmp    $0x9,%bl
  800a13:	77 08                	ja     800a1d <strtol+0x93>
			dig = *s - '0';
  800a15:	0f be d2             	movsbl %dl,%edx
  800a18:	83 ea 30             	sub    $0x30,%edx
  800a1b:	eb 22                	jmp    800a3f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a1d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a20:	89 f3                	mov    %esi,%ebx
  800a22:	80 fb 19             	cmp    $0x19,%bl
  800a25:	77 08                	ja     800a2f <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a27:	0f be d2             	movsbl %dl,%edx
  800a2a:	83 ea 57             	sub    $0x57,%edx
  800a2d:	eb 10                	jmp    800a3f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a2f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a32:	89 f3                	mov    %esi,%ebx
  800a34:	80 fb 19             	cmp    $0x19,%bl
  800a37:	77 16                	ja     800a4f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a39:	0f be d2             	movsbl %dl,%edx
  800a3c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a3f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a42:	7d 0f                	jge    800a53 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a44:	83 c1 01             	add    $0x1,%ecx
  800a47:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a4b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a4d:	eb b9                	jmp    800a08 <strtol+0x7e>
  800a4f:	89 c2                	mov    %eax,%edx
  800a51:	eb 02                	jmp    800a55 <strtol+0xcb>
  800a53:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a59:	74 0d                	je     800a68 <strtol+0xde>
		*endptr = (char *) s;
  800a5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5e:	89 0e                	mov    %ecx,(%esi)
  800a60:	eb 06                	jmp    800a68 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a62:	84 c0                	test   %al,%al
  800a64:	75 92                	jne    8009f8 <strtol+0x6e>
  800a66:	eb 98                	jmp    800a00 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a68:	f7 da                	neg    %edx
  800a6a:	85 ff                	test   %edi,%edi
  800a6c:	0f 45 c2             	cmovne %edx,%eax
}
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	89 c3                	mov    %eax,%ebx
  800a87:	89 c7                	mov    %eax,%edi
  800a89:	89 c6                	mov    %eax,%esi
  800a8b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa2:	89 d1                	mov    %edx,%ecx
  800aa4:	89 d3                	mov    %edx,%ebx
  800aa6:	89 d7                	mov    %edx,%edi
  800aa8:	89 d6                	mov    %edx,%esi
  800aaa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	89 cb                	mov    %ecx,%ebx
  800ac9:	89 cf                	mov    %ecx,%edi
  800acb:	89 ce                	mov    %ecx,%esi
  800acd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800acf:	85 c0                	test   %eax,%eax
  800ad1:	7e 17                	jle    800aea <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad3:	83 ec 0c             	sub    $0xc,%esp
  800ad6:	50                   	push   %eax
  800ad7:	6a 03                	push   $0x3
  800ad9:	68 28 16 80 00       	push   $0x801628
  800ade:	6a 23                	push   $0x23
  800ae0:	68 45 16 80 00       	push   $0x801645
  800ae5:	e8 b6 04 00 00       	call   800fa0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 02 00 00 00       	mov    $0x2,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_yield>:

void
sys_yield(void)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b17:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b21:	89 d1                	mov    %edx,%ecx
  800b23:	89 d3                	mov    %edx,%ebx
  800b25:	89 d7                	mov    %edx,%edi
  800b27:	89 d6                	mov    %edx,%esi
  800b29:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	be 00 00 00 00       	mov    $0x0,%esi
  800b3e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4c:	89 f7                	mov    %esi,%edi
  800b4e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b50:	85 c0                	test   %eax,%eax
  800b52:	7e 17                	jle    800b6b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b54:	83 ec 0c             	sub    $0xc,%esp
  800b57:	50                   	push   %eax
  800b58:	6a 04                	push   $0x4
  800b5a:	68 28 16 80 00       	push   $0x801628
  800b5f:	6a 23                	push   $0x23
  800b61:	68 45 16 80 00       	push   $0x801645
  800b66:	e8 35 04 00 00       	call   800fa0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	b8 05 00 00 00       	mov    $0x5,%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b8d:	8b 75 18             	mov    0x18(%ebp),%esi
  800b90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b92:	85 c0                	test   %eax,%eax
  800b94:	7e 17                	jle    800bad <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b96:	83 ec 0c             	sub    $0xc,%esp
  800b99:	50                   	push   %eax
  800b9a:	6a 05                	push   $0x5
  800b9c:	68 28 16 80 00       	push   $0x801628
  800ba1:	6a 23                	push   $0x23
  800ba3:	68 45 16 80 00       	push   $0x801645
  800ba8:	e8 f3 03 00 00       	call   800fa0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc3:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	89 df                	mov    %ebx,%edi
  800bd0:	89 de                	mov    %ebx,%esi
  800bd2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	7e 17                	jle    800bef <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	50                   	push   %eax
  800bdc:	6a 06                	push   $0x6
  800bde:	68 28 16 80 00       	push   $0x801628
  800be3:	6a 23                	push   $0x23
  800be5:	68 45 16 80 00       	push   $0x801645
  800bea:	e8 b1 03 00 00       	call   800fa0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c05:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 df                	mov    %ebx,%edi
  800c12:	89 de                	mov    %ebx,%esi
  800c14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7e 17                	jle    800c31 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 08                	push   $0x8
  800c20:	68 28 16 80 00       	push   $0x801628
  800c25:	6a 23                	push   $0x23
  800c27:	68 45 16 80 00       	push   $0x801645
  800c2c:	e8 6f 03 00 00       	call   800fa0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c47:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	89 df                	mov    %ebx,%edi
  800c54:	89 de                	mov    %ebx,%esi
  800c56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 17                	jle    800c73 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 09                	push   $0x9
  800c62:	68 28 16 80 00       	push   $0x801628
  800c67:	6a 23                	push   $0x23
  800c69:	68 45 16 80 00       	push   $0x801645
  800c6e:	e8 2d 03 00 00       	call   800fa0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c81:	be 00 00 00 00       	mov    $0x0,%esi
  800c86:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c97:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cac:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	89 cb                	mov    %ecx,%ebx
  800cb6:	89 cf                	mov    %ecx,%edi
  800cb8:	89 ce                	mov    %ecx,%esi
  800cba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 0c                	push   $0xc
  800cc6:	68 28 16 80 00       	push   $0x801628
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 45 16 80 00       	push   $0x801645
  800cd2:	e8 c9 02 00 00       	call   800fa0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 04             	sub    $0x4,%esp
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800ce9:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800ceb:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800cef:	74 2e                	je     800d1f <pgfault+0x40>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800cf1:	89 c2                	mov    %eax,%edx
  800cf3:	c1 ea 16             	shr    $0x16,%edx
  800cf6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800cfd:	f6 c2 01             	test   $0x1,%dl
  800d00:	74 1d                	je     800d1f <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d02:	89 c2                	mov    %eax,%edx
  800d04:	c1 ea 0c             	shr    $0xc,%edx
  800d07:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800d0e:	f6 c1 01             	test   $0x1,%cl
  800d11:	74 0c                	je     800d1f <pgfault+0x40>
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800d13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if(!(
  800d1a:	f6 c6 08             	test   $0x8,%dh
  800d1d:	75 14                	jne    800d33 <pgfault+0x54>
             ((err & FEC_WR) == FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
             (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
            )
           )
                panic("err isn't caused by write or cow\n"); 
  800d1f:	83 ec 04             	sub    $0x4,%esp
  800d22:	68 54 16 80 00       	push   $0x801654
  800d27:	6a 21                	push   $0x21
  800d29:	68 e7 16 80 00       	push   $0x8016e7
  800d2e:	e8 6d 02 00 00       	call   800fa0 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        void *radd = ROUNDDOWN(addr, PGSIZE);
  800d33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d38:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P) < 0)
  800d3a:	83 ec 04             	sub    $0x4,%esp
  800d3d:	6a 07                	push   $0x7
  800d3f:	68 00 f0 7f 00       	push   $0x7ff000
  800d44:	6a 00                	push   $0x0
  800d46:	e8 e5 fd ff ff       	call   800b30 <sys_page_alloc>
  800d4b:	83 c4 10             	add    $0x10,%esp
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	79 14                	jns    800d66 <pgfault+0x87>
                panic("sys_page_alloc fails\n");
  800d52:	83 ec 04             	sub    $0x4,%esp
  800d55:	68 f2 16 80 00       	push   $0x8016f2
  800d5a:	6a 2b                	push   $0x2b
  800d5c:	68 e7 16 80 00       	push   $0x8016e7
  800d61:	e8 3a 02 00 00       	call   800fa0 <_panic>
        memmove(PFTEMP, radd, PGSIZE);
  800d66:	83 ec 04             	sub    $0x4,%esp
  800d69:	68 00 10 00 00       	push   $0x1000
  800d6e:	53                   	push   %ebx
  800d6f:	68 00 f0 7f 00       	push   $0x7ff000
  800d74:	e8 40 fb ff ff       	call   8008b9 <memmove>
        if(sys_page_map(0, PFTEMP, 0, radd, PTE_U | PTE_W | PTE_P) < 0)
  800d79:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800d80:	53                   	push   %ebx
  800d81:	6a 00                	push   $0x0
  800d83:	68 00 f0 7f 00       	push   $0x7ff000
  800d88:	6a 00                	push   $0x0
  800d8a:	e8 e4 fd ff ff       	call   800b73 <sys_page_map>
  800d8f:	83 c4 20             	add    $0x20,%esp
  800d92:	85 c0                	test   %eax,%eax
  800d94:	79 14                	jns    800daa <pgfault+0xcb>
                panic("sys_page_map fails\n");
  800d96:	83 ec 04             	sub    $0x4,%esp
  800d99:	68 08 17 80 00       	push   $0x801708
  800d9e:	6a 2e                	push   $0x2e
  800da0:	68 e7 16 80 00       	push   $0x8016e7
  800da5:	e8 f6 01 00 00       	call   800fa0 <_panic>
        sys_page_unmap(0, PFTEMP); 
  800daa:	83 ec 08             	sub    $0x8,%esp
  800dad:	68 00 f0 7f 00       	push   $0x7ff000
  800db2:	6a 00                	push   $0x0
  800db4:	e8 fc fd ff ff       	call   800bb5 <sys_page_unmap>
  800db9:	83 c4 10             	add    $0x10,%esp
               
	//panic("pgfault not implemented");
}
  800dbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dbf:	c9                   	leave  
  800dc0:	c3                   	ret    

00800dc1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        void *addr;
        set_pgfault_handler(pgfault);
  800dca:	68 df 0c 80 00       	push   $0x800cdf
  800dcf:	e8 12 02 00 00       	call   800fe6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800dd4:	b8 07 00 00 00       	mov    $0x7,%eax
  800dd9:	cd 30                	int    $0x30
  800ddb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        envid_t forkid = sys_exofork();
        if (forkid < 0)
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	85 c0                	test   %eax,%eax
  800de3:	79 12                	jns    800df7 <fork+0x36>
		panic("sys_exofork: %e", forkid);
  800de5:	50                   	push   %eax
  800de6:	68 1c 17 80 00       	push   $0x80171c
  800deb:	6a 6d                	push   $0x6d
  800ded:	68 e7 16 80 00       	push   $0x8016e7
  800df2:	e8 a9 01 00 00       	call   800fa0 <_panic>
  800df7:	89 c7                	mov    %eax,%edi
  800df9:	bb 00 00 80 00       	mov    $0x800000,%ebx
        if(forkid == 0) {
  800dfe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e02:	75 21                	jne    800e25 <fork+0x64>
                thisenv = &envs[ENVX(sys_getenvid())];
  800e04:	e8 e9 fc ff ff       	call   800af2 <sys_getenvid>
  800e09:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e0e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e11:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e16:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e20:	e9 59 01 00 00       	jmp    800f7e <fork+0x1bd>
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
  800e25:	89 d8                	mov    %ebx,%eax
  800e27:	c1 e8 16             	shr    $0x16,%eax
  800e2a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e31:	a8 01                	test   $0x1,%al
  800e33:	0f 84 b0 00 00 00    	je     800ee9 <fork+0x128>
  800e39:	89 d8                	mov    %ebx,%eax
  800e3b:	c1 e8 0c             	shr    $0xc,%eax
  800e3e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e45:	f6 c2 01             	test   $0x1,%dl
  800e48:	0f 84 9b 00 00 00    	je     800ee9 <fork+0x128>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        void *add = (void *)(pn * PGSIZE);
  800e4e:	89 c6                	mov    %eax,%esi
  800e50:	c1 e6 0c             	shl    $0xc,%esi
    
        if( (uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)) {
  800e53:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e5a:	f6 c6 08             	test   $0x8,%dh
  800e5d:	75 0b                	jne    800e6a <fork+0xa9>
  800e5f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e66:	a8 02                	test   $0x2,%al
  800e68:	74 57                	je     800ec1 <fork+0x100>
                if((r = sys_page_map(0, add, envid, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800e6a:	83 ec 0c             	sub    $0xc,%esp
  800e6d:	68 05 08 00 00       	push   $0x805
  800e72:	56                   	push   %esi
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	6a 00                	push   $0x0
  800e77:	e8 f7 fc ff ff       	call   800b73 <sys_page_map>
  800e7c:	83 c4 20             	add    $0x20,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	79 12                	jns    800e95 <fork+0xd4>
                        panic("sys_page_map on new page fails %d \n", r);
  800e83:	50                   	push   %eax
  800e84:	68 78 16 80 00       	push   $0x801678
  800e89:	6a 4a                	push   $0x4a
  800e8b:	68 e7 16 80 00       	push   $0x8016e7
  800e90:	e8 0b 01 00 00       	call   800fa0 <_panic>
                if((r = sys_page_map(0, add, 0, add, PTE_COW | PTE_P | PTE_U)) < 0)
  800e95:	83 ec 0c             	sub    $0xc,%esp
  800e98:	68 05 08 00 00       	push   $0x805
  800e9d:	56                   	push   %esi
  800e9e:	6a 00                	push   $0x0
  800ea0:	56                   	push   %esi
  800ea1:	6a 00                	push   $0x0
  800ea3:	e8 cb fc ff ff       	call   800b73 <sys_page_map>
  800ea8:	83 c4 20             	add    $0x20,%esp
  800eab:	85 c0                	test   %eax,%eax
  800ead:	79 3a                	jns    800ee9 <fork+0x128>
                        panic("sys_page_map on current page fails %d\n", r);
  800eaf:	50                   	push   %eax
  800eb0:	68 9c 16 80 00       	push   $0x80169c
  800eb5:	6a 4c                	push   $0x4c
  800eb7:	68 e7 16 80 00       	push   $0x8016e7
  800ebc:	e8 df 00 00 00       	call   800fa0 <_panic>
        } else 
                if((r = sys_page_map(0, add, envid, add, PTE_P | PTE_U)) < 0)
  800ec1:	83 ec 0c             	sub    $0xc,%esp
  800ec4:	6a 05                	push   $0x5
  800ec6:	56                   	push   %esi
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	6a 00                	push   $0x0
  800ecb:	e8 a3 fc ff ff       	call   800b73 <sys_page_map>
  800ed0:	83 c4 20             	add    $0x20,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	79 12                	jns    800ee9 <fork+0x128>
                        panic("sys_page_map on new page fails %d\n", r);
  800ed7:	50                   	push   %eax
  800ed8:	68 c4 16 80 00       	push   $0x8016c4
  800edd:	6a 4f                	push   $0x4f
  800edf:	68 e7 16 80 00       	push   $0x8016e7
  800ee4:	e8 b7 00 00 00       	call   800fa0 <_panic>
		panic("sys_exofork: %e", forkid);
        if(forkid == 0) {
                thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
        }
        for (addr = (uint8_t*) UTEXT; addr < (void *) USTACKTOP; addr += PGSIZE)
  800ee9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800eef:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800ef5:	0f 85 2a ff ff ff    	jne    800e25 <fork+0x64>
		if( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) )
                        duppage(forkid, PGNUM(addr));
        if (sys_page_alloc(forkid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800efb:	83 ec 04             	sub    $0x4,%esp
  800efe:	6a 07                	push   $0x7
  800f00:	68 00 f0 bf ee       	push   $0xeebff000
  800f05:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f08:	e8 23 fc ff ff       	call   800b30 <sys_page_alloc>
  800f0d:	83 c4 10             	add    $0x10,%esp
  800f10:	85 c0                	test   %eax,%eax
  800f12:	79 14                	jns    800f28 <fork+0x167>
                panic("user stack alloc failure\n");	
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	68 2c 17 80 00       	push   $0x80172c
  800f1c:	6a 76                	push   $0x76
  800f1e:	68 e7 16 80 00       	push   $0x8016e7
  800f23:	e8 78 00 00 00       	call   800fa0 <_panic>
        extern void _pgfault_upcall(); 
        if(sys_env_set_pgfault_upcall(forkid, _pgfault_upcall) < 0)
  800f28:	83 ec 08             	sub    $0x8,%esp
  800f2b:	68 55 10 80 00       	push   $0x801055
  800f30:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f33:	e8 01 fd ff ff       	call   800c39 <sys_env_set_pgfault_upcall>
  800f38:	83 c4 10             	add    $0x10,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	79 14                	jns    800f53 <fork+0x192>
                panic("set pgfault upcall fails %d\n", forkid);
  800f3f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f42:	68 46 17 80 00       	push   $0x801746
  800f47:	6a 79                	push   $0x79
  800f49:	68 e7 16 80 00       	push   $0x8016e7
  800f4e:	e8 4d 00 00 00       	call   800fa0 <_panic>
        if(sys_env_set_status(forkid, ENV_RUNNABLE) < 0)
  800f53:	83 ec 08             	sub    $0x8,%esp
  800f56:	6a 02                	push   $0x2
  800f58:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5b:	e8 97 fc ff ff       	call   800bf7 <sys_env_set_status>
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	79 14                	jns    800f7b <fork+0x1ba>
                panic("set %d runnable fails\n", forkid);
  800f67:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f6a:	68 63 17 80 00       	push   $0x801763
  800f6f:	6a 7b                	push   $0x7b
  800f71:	68 e7 16 80 00       	push   $0x8016e7
  800f76:	e8 25 00 00 00       	call   800fa0 <_panic>
        return forkid;
  800f7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <sfork>:

// Challenge!
int
sfork(void)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f8c:	68 7a 17 80 00       	push   $0x80177a
  800f91:	68 83 00 00 00       	push   $0x83
  800f96:	68 e7 16 80 00       	push   $0x8016e7
  800f9b:	e8 00 00 00 00       	call   800fa0 <_panic>

00800fa0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fa5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fa8:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800fae:	e8 3f fb ff ff       	call   800af2 <sys_getenvid>
  800fb3:	83 ec 0c             	sub    $0xc,%esp
  800fb6:	ff 75 0c             	pushl  0xc(%ebp)
  800fb9:	ff 75 08             	pushl  0x8(%ebp)
  800fbc:	56                   	push   %esi
  800fbd:	50                   	push   %eax
  800fbe:	68 90 17 80 00       	push   $0x801790
  800fc3:	e8 d8 f1 ff ff       	call   8001a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fc8:	83 c4 18             	add    $0x18,%esp
  800fcb:	53                   	push   %ebx
  800fcc:	ff 75 10             	pushl  0x10(%ebp)
  800fcf:	e8 7b f1 ff ff       	call   80014f <vcprintf>
	cprintf("\n");
  800fd4:	c7 04 24 d4 13 80 00 	movl   $0x8013d4,(%esp)
  800fdb:	e8 c0 f1 ff ff       	call   8001a0 <cprintf>
  800fe0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fe3:	cc                   	int3   
  800fe4:	eb fd                	jmp    800fe3 <_panic+0x43>

00800fe6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fec:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800ff3:	75 2c                	jne    801021 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  800ff5:	83 ec 04             	sub    $0x4,%esp
  800ff8:	6a 07                	push   $0x7
  800ffa:	68 00 f0 bf ee       	push   $0xeebff000
  800fff:	6a 00                	push   $0x0
  801001:	e8 2a fb ff ff       	call   800b30 <sys_page_alloc>
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	74 14                	je     801021 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  80100d:	83 ec 04             	sub    $0x4,%esp
  801010:	68 b4 17 80 00       	push   $0x8017b4
  801015:	6a 21                	push   $0x21
  801017:	68 18 18 80 00       	push   $0x801818
  80101c:	e8 7f ff ff ff       	call   800fa0 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801021:	8b 45 08             	mov    0x8(%ebp),%eax
  801024:	a3 08 20 80 00       	mov    %eax,0x802008
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801029:	83 ec 08             	sub    $0x8,%esp
  80102c:	68 55 10 80 00       	push   $0x801055
  801031:	6a 00                	push   $0x0
  801033:	e8 01 fc ff ff       	call   800c39 <sys_env_set_pgfault_upcall>
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	79 14                	jns    801053 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	68 e0 17 80 00       	push   $0x8017e0
  801047:	6a 29                	push   $0x29
  801049:	68 18 18 80 00       	push   $0x801818
  80104e:	e8 4d ff ff ff       	call   800fa0 <_panic>
}
  801053:	c9                   	leave  
  801054:	c3                   	ret    

00801055 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801055:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801056:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80105b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80105d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  801060:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  801065:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  801069:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  80106d:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  80106f:	83 c4 08             	add    $0x8,%esp
        popal
  801072:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  801073:	83 c4 04             	add    $0x4,%esp
        popfl
  801076:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  801077:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801078:	c3                   	ret    
  801079:	66 90                	xchg   %ax,%ax
  80107b:	66 90                	xchg   %ax,%ax
  80107d:	66 90                	xchg   %ax,%ax
  80107f:	90                   	nop

00801080 <__udivdi3>:
  801080:	55                   	push   %ebp
  801081:	57                   	push   %edi
  801082:	56                   	push   %esi
  801083:	83 ec 10             	sub    $0x10,%esp
  801086:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80108a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80108e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801092:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801096:	85 d2                	test   %edx,%edx
  801098:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80109c:	89 34 24             	mov    %esi,(%esp)
  80109f:	89 c8                	mov    %ecx,%eax
  8010a1:	75 35                	jne    8010d8 <__udivdi3+0x58>
  8010a3:	39 f1                	cmp    %esi,%ecx
  8010a5:	0f 87 bd 00 00 00    	ja     801168 <__udivdi3+0xe8>
  8010ab:	85 c9                	test   %ecx,%ecx
  8010ad:	89 cd                	mov    %ecx,%ebp
  8010af:	75 0b                	jne    8010bc <__udivdi3+0x3c>
  8010b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8010b6:	31 d2                	xor    %edx,%edx
  8010b8:	f7 f1                	div    %ecx
  8010ba:	89 c5                	mov    %eax,%ebp
  8010bc:	89 f0                	mov    %esi,%eax
  8010be:	31 d2                	xor    %edx,%edx
  8010c0:	f7 f5                	div    %ebp
  8010c2:	89 c6                	mov    %eax,%esi
  8010c4:	89 f8                	mov    %edi,%eax
  8010c6:	f7 f5                	div    %ebp
  8010c8:	89 f2                	mov    %esi,%edx
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	5e                   	pop    %esi
  8010ce:	5f                   	pop    %edi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    
  8010d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010d8:	3b 14 24             	cmp    (%esp),%edx
  8010db:	77 7b                	ja     801158 <__udivdi3+0xd8>
  8010dd:	0f bd f2             	bsr    %edx,%esi
  8010e0:	83 f6 1f             	xor    $0x1f,%esi
  8010e3:	0f 84 97 00 00 00    	je     801180 <__udivdi3+0x100>
  8010e9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8010ee:	89 d7                	mov    %edx,%edi
  8010f0:	89 f1                	mov    %esi,%ecx
  8010f2:	29 f5                	sub    %esi,%ebp
  8010f4:	d3 e7                	shl    %cl,%edi
  8010f6:	89 c2                	mov    %eax,%edx
  8010f8:	89 e9                	mov    %ebp,%ecx
  8010fa:	d3 ea                	shr    %cl,%edx
  8010fc:	89 f1                	mov    %esi,%ecx
  8010fe:	09 fa                	or     %edi,%edx
  801100:	8b 3c 24             	mov    (%esp),%edi
  801103:	d3 e0                	shl    %cl,%eax
  801105:	89 54 24 08          	mov    %edx,0x8(%esp)
  801109:	89 e9                	mov    %ebp,%ecx
  80110b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80110f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801113:	89 fa                	mov    %edi,%edx
  801115:	d3 ea                	shr    %cl,%edx
  801117:	89 f1                	mov    %esi,%ecx
  801119:	d3 e7                	shl    %cl,%edi
  80111b:	89 e9                	mov    %ebp,%ecx
  80111d:	d3 e8                	shr    %cl,%eax
  80111f:	09 c7                	or     %eax,%edi
  801121:	89 f8                	mov    %edi,%eax
  801123:	f7 74 24 08          	divl   0x8(%esp)
  801127:	89 d5                	mov    %edx,%ebp
  801129:	89 c7                	mov    %eax,%edi
  80112b:	f7 64 24 0c          	mull   0xc(%esp)
  80112f:	39 d5                	cmp    %edx,%ebp
  801131:	89 14 24             	mov    %edx,(%esp)
  801134:	72 11                	jb     801147 <__udivdi3+0xc7>
  801136:	8b 54 24 04          	mov    0x4(%esp),%edx
  80113a:	89 f1                	mov    %esi,%ecx
  80113c:	d3 e2                	shl    %cl,%edx
  80113e:	39 c2                	cmp    %eax,%edx
  801140:	73 5e                	jae    8011a0 <__udivdi3+0x120>
  801142:	3b 2c 24             	cmp    (%esp),%ebp
  801145:	75 59                	jne    8011a0 <__udivdi3+0x120>
  801147:	8d 47 ff             	lea    -0x1(%edi),%eax
  80114a:	31 f6                	xor    %esi,%esi
  80114c:	89 f2                	mov    %esi,%edx
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    
  801155:	8d 76 00             	lea    0x0(%esi),%esi
  801158:	31 f6                	xor    %esi,%esi
  80115a:	31 c0                	xor    %eax,%eax
  80115c:	89 f2                	mov    %esi,%edx
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    
  801165:	8d 76 00             	lea    0x0(%esi),%esi
  801168:	89 f2                	mov    %esi,%edx
  80116a:	31 f6                	xor    %esi,%esi
  80116c:	89 f8                	mov    %edi,%eax
  80116e:	f7 f1                	div    %ecx
  801170:	89 f2                	mov    %esi,%edx
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	5e                   	pop    %esi
  801176:	5f                   	pop    %edi
  801177:	5d                   	pop    %ebp
  801178:	c3                   	ret    
  801179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801180:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801184:	76 0b                	jbe    801191 <__udivdi3+0x111>
  801186:	31 c0                	xor    %eax,%eax
  801188:	3b 14 24             	cmp    (%esp),%edx
  80118b:	0f 83 37 ff ff ff    	jae    8010c8 <__udivdi3+0x48>
  801191:	b8 01 00 00 00       	mov    $0x1,%eax
  801196:	e9 2d ff ff ff       	jmp    8010c8 <__udivdi3+0x48>
  80119b:	90                   	nop
  80119c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	89 f8                	mov    %edi,%eax
  8011a2:	31 f6                	xor    %esi,%esi
  8011a4:	e9 1f ff ff ff       	jmp    8010c8 <__udivdi3+0x48>
  8011a9:	66 90                	xchg   %ax,%ax
  8011ab:	66 90                	xchg   %ax,%ax
  8011ad:	66 90                	xchg   %ax,%ax
  8011af:	90                   	nop

008011b0 <__umoddi3>:
  8011b0:	55                   	push   %ebp
  8011b1:	57                   	push   %edi
  8011b2:	56                   	push   %esi
  8011b3:	83 ec 20             	sub    $0x20,%esp
  8011b6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8011ba:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8011be:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011c2:	89 c6                	mov    %eax,%esi
  8011c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8011cc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8011d0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011d4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011d8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	89 c2                	mov    %eax,%edx
  8011e0:	75 1e                	jne    801200 <__umoddi3+0x50>
  8011e2:	39 f7                	cmp    %esi,%edi
  8011e4:	76 52                	jbe    801238 <__umoddi3+0x88>
  8011e6:	89 c8                	mov    %ecx,%eax
  8011e8:	89 f2                	mov    %esi,%edx
  8011ea:	f7 f7                	div    %edi
  8011ec:	89 d0                	mov    %edx,%eax
  8011ee:	31 d2                	xor    %edx,%edx
  8011f0:	83 c4 20             	add    $0x20,%esp
  8011f3:	5e                   	pop    %esi
  8011f4:	5f                   	pop    %edi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    
  8011f7:	89 f6                	mov    %esi,%esi
  8011f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801200:	39 f0                	cmp    %esi,%eax
  801202:	77 5c                	ja     801260 <__umoddi3+0xb0>
  801204:	0f bd e8             	bsr    %eax,%ebp
  801207:	83 f5 1f             	xor    $0x1f,%ebp
  80120a:	75 64                	jne    801270 <__umoddi3+0xc0>
  80120c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801210:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801214:	0f 86 f6 00 00 00    	jbe    801310 <__umoddi3+0x160>
  80121a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80121e:	0f 82 ec 00 00 00    	jb     801310 <__umoddi3+0x160>
  801224:	8b 44 24 14          	mov    0x14(%esp),%eax
  801228:	8b 54 24 18          	mov    0x18(%esp),%edx
  80122c:	83 c4 20             	add    $0x20,%esp
  80122f:	5e                   	pop    %esi
  801230:	5f                   	pop    %edi
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    
  801233:	90                   	nop
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	85 ff                	test   %edi,%edi
  80123a:	89 fd                	mov    %edi,%ebp
  80123c:	75 0b                	jne    801249 <__umoddi3+0x99>
  80123e:	b8 01 00 00 00       	mov    $0x1,%eax
  801243:	31 d2                	xor    %edx,%edx
  801245:	f7 f7                	div    %edi
  801247:	89 c5                	mov    %eax,%ebp
  801249:	8b 44 24 10          	mov    0x10(%esp),%eax
  80124d:	31 d2                	xor    %edx,%edx
  80124f:	f7 f5                	div    %ebp
  801251:	89 c8                	mov    %ecx,%eax
  801253:	f7 f5                	div    %ebp
  801255:	eb 95                	jmp    8011ec <__umoddi3+0x3c>
  801257:	89 f6                	mov    %esi,%esi
  801259:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801260:	89 c8                	mov    %ecx,%eax
  801262:	89 f2                	mov    %esi,%edx
  801264:	83 c4 20             	add    $0x20,%esp
  801267:	5e                   	pop    %esi
  801268:	5f                   	pop    %edi
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    
  80126b:	90                   	nop
  80126c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801270:	b8 20 00 00 00       	mov    $0x20,%eax
  801275:	89 e9                	mov    %ebp,%ecx
  801277:	29 e8                	sub    %ebp,%eax
  801279:	d3 e2                	shl    %cl,%edx
  80127b:	89 c7                	mov    %eax,%edi
  80127d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801281:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801285:	89 f9                	mov    %edi,%ecx
  801287:	d3 e8                	shr    %cl,%eax
  801289:	89 c1                	mov    %eax,%ecx
  80128b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80128f:	09 d1                	or     %edx,%ecx
  801291:	89 fa                	mov    %edi,%edx
  801293:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801297:	89 e9                	mov    %ebp,%ecx
  801299:	d3 e0                	shl    %cl,%eax
  80129b:	89 f9                	mov    %edi,%ecx
  80129d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a1:	89 f0                	mov    %esi,%eax
  8012a3:	d3 e8                	shr    %cl,%eax
  8012a5:	89 e9                	mov    %ebp,%ecx
  8012a7:	89 c7                	mov    %eax,%edi
  8012a9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8012ad:	d3 e6                	shl    %cl,%esi
  8012af:	89 d1                	mov    %edx,%ecx
  8012b1:	89 fa                	mov    %edi,%edx
  8012b3:	d3 e8                	shr    %cl,%eax
  8012b5:	89 e9                	mov    %ebp,%ecx
  8012b7:	09 f0                	or     %esi,%eax
  8012b9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8012bd:	f7 74 24 10          	divl   0x10(%esp)
  8012c1:	d3 e6                	shl    %cl,%esi
  8012c3:	89 d1                	mov    %edx,%ecx
  8012c5:	f7 64 24 0c          	mull   0xc(%esp)
  8012c9:	39 d1                	cmp    %edx,%ecx
  8012cb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8012cf:	89 d7                	mov    %edx,%edi
  8012d1:	89 c6                	mov    %eax,%esi
  8012d3:	72 0a                	jb     8012df <__umoddi3+0x12f>
  8012d5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8012d9:	73 10                	jae    8012eb <__umoddi3+0x13b>
  8012db:	39 d1                	cmp    %edx,%ecx
  8012dd:	75 0c                	jne    8012eb <__umoddi3+0x13b>
  8012df:	89 d7                	mov    %edx,%edi
  8012e1:	89 c6                	mov    %eax,%esi
  8012e3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8012e7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8012eb:	89 ca                	mov    %ecx,%edx
  8012ed:	89 e9                	mov    %ebp,%ecx
  8012ef:	8b 44 24 14          	mov    0x14(%esp),%eax
  8012f3:	29 f0                	sub    %esi,%eax
  8012f5:	19 fa                	sbb    %edi,%edx
  8012f7:	d3 e8                	shr    %cl,%eax
  8012f9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8012fe:	89 d7                	mov    %edx,%edi
  801300:	d3 e7                	shl    %cl,%edi
  801302:	89 e9                	mov    %ebp,%ecx
  801304:	09 f8                	or     %edi,%eax
  801306:	d3 ea                	shr    %cl,%edx
  801308:	83 c4 20             	add    $0x20,%esp
  80130b:	5e                   	pop    %esi
  80130c:	5f                   	pop    %edi
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    
  80130f:	90                   	nop
  801310:	8b 74 24 10          	mov    0x10(%esp),%esi
  801314:	29 f9                	sub    %edi,%ecx
  801316:	19 c6                	sbb    %eax,%esi
  801318:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80131c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801320:	e9 ff fe ff ff       	jmp    801224 <__umoddi3+0x74>
