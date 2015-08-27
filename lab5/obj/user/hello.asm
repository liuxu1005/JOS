
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 40 1e 80 00       	push   $0x801e40
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 4e 1e 80 00       	push   $0x801e4e
  800054:	e8 f8 00 00 00       	call   800151 <cprintf>
  800059:	83 c4 10             	add    $0x10,%esp
}
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800069:	e8 35 0a 00 00       	call   800aa3 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
  80009a:	83 c4 10             	add    $0x10,%esp
}
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 f0 0d 00 00       	call   800e9f <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 a9 09 00 00       	call   800a62 <sys_env_destroy>
  8000b9:	83 c4 10             	add    $0x10,%esp
}
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 1a                	jne    8000f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000dd:	83 ec 08             	sub    $0x8,%esp
  8000e0:	68 ff 00 00 00       	push   $0xff
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 37 09 00 00       	call   800a25 <sys_cputs>
		b->idx = 0;
  8000ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	ff 75 08             	pushl  0x8(%ebp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	50                   	push   %eax
  80012a:	68 be 00 80 00       	push   $0x8000be
  80012f:	e8 4f 01 00 00       	call   800283 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	83 c4 08             	add    $0x8,%esp
  800137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 dc 08 00 00       	call   800a25 <sys_cputs>

	return b.cnt;
}
  800149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015a:	50                   	push   %eax
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	e8 9d ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 1c             	sub    $0x1c,%esp
  80016e:	89 c7                	mov    %eax,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 d1                	mov    %edx,%ecx
  80017a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800180:	8b 45 10             	mov    0x10(%ebp),%eax
  800183:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800186:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800189:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800190:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800193:	72 05                	jb     80019a <printnum+0x35>
  800195:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800198:	77 3e                	ja     8001d8 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	ff 75 18             	pushl  0x18(%ebp)
  8001a0:	83 eb 01             	sub    $0x1,%ebx
  8001a3:	53                   	push   %ebx
  8001a4:	50                   	push   %eax
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b4:	e8 a7 19 00 00       	call   801b60 <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	89 f8                	mov    %edi,%eax
  8001c2:	e8 9e ff ff ff       	call   800165 <printnum>
  8001c7:	83 c4 20             	add    $0x20,%esp
  8001ca:	eb 13                	jmp    8001df <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 18             	pushl  0x18(%ebp)
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	85 db                	test   %ebx,%ebx
  8001dd:	7f ed                	jg     8001cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	56                   	push   %esi
  8001e3:	83 ec 04             	sub    $0x4,%esp
  8001e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f2:	e8 99 1a 00 00       	call   801c90 <__umoddi3>
  8001f7:	83 c4 14             	add    $0x14,%esp
  8001fa:	0f be 80 6f 1e 80 00 	movsbl 0x801e6f(%eax),%eax
  800201:	50                   	push   %eax
  800202:	ff d7                	call   *%edi
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800212:	83 fa 01             	cmp    $0x1,%edx
  800215:	7e 0e                	jle    800225 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800217:	8b 10                	mov    (%eax),%edx
  800219:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021c:	89 08                	mov    %ecx,(%eax)
  80021e:	8b 02                	mov    (%edx),%eax
  800220:	8b 52 04             	mov    0x4(%edx),%edx
  800223:	eb 22                	jmp    800247 <getuint+0x38>
	else if (lflag)
  800225:	85 d2                	test   %edx,%edx
  800227:	74 10                	je     800239 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800229:	8b 10                	mov    (%eax),%edx
  80022b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022e:	89 08                	mov    %ecx,(%eax)
  800230:	8b 02                	mov    (%edx),%eax
  800232:	ba 00 00 00 00       	mov    $0x0,%edx
  800237:	eb 0e                	jmp    800247 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800239:	8b 10                	mov    (%eax),%edx
  80023b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023e:	89 08                	mov    %ecx,(%eax)
  800240:	8b 02                	mov    (%edx),%eax
  800242:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800247:	5d                   	pop    %ebp
  800248:	c3                   	ret    

00800249 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800253:	8b 10                	mov    (%eax),%edx
  800255:	3b 50 04             	cmp    0x4(%eax),%edx
  800258:	73 0a                	jae    800264 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 45 08             	mov    0x8(%ebp),%eax
  800262:	88 02                	mov    %al,(%edx)
}
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    

00800266 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80026c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026f:	50                   	push   %eax
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	ff 75 0c             	pushl  0xc(%ebp)
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 05 00 00 00       	call   800283 <vprintfmt>
	va_end(ap);
  80027e:	83 c4 10             	add    $0x10,%esp
}
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 2c             	sub    $0x2c,%esp
  80028c:	8b 75 08             	mov    0x8(%ebp),%esi
  80028f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800292:	8b 7d 10             	mov    0x10(%ebp),%edi
  800295:	eb 12                	jmp    8002a9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800297:	85 c0                	test   %eax,%eax
  800299:	0f 84 90 03 00 00    	je     80062f <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	53                   	push   %ebx
  8002a3:	50                   	push   %eax
  8002a4:	ff d6                	call   *%esi
  8002a6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a9:	83 c7 01             	add    $0x1,%edi
  8002ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b0:	83 f8 25             	cmp    $0x25,%eax
  8002b3:	75 e2                	jne    800297 <vprintfmt+0x14>
  8002b5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002c7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d3:	eb 07                	jmp    8002dc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002dc:	8d 47 01             	lea    0x1(%edi),%eax
  8002df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e2:	0f b6 07             	movzbl (%edi),%eax
  8002e5:	0f b6 c8             	movzbl %al,%ecx
  8002e8:	83 e8 23             	sub    $0x23,%eax
  8002eb:	3c 55                	cmp    $0x55,%al
  8002ed:	0f 87 21 03 00 00    	ja     800614 <vprintfmt+0x391>
  8002f3:	0f b6 c0             	movzbl %al,%eax
  8002f6:	ff 24 85 c0 1f 80 00 	jmp    *0x801fc0(,%eax,4)
  8002fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800300:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800304:	eb d6                	jmp    8002dc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800309:	b8 00 00 00 00       	mov    $0x0,%eax
  80030e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800311:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800314:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800318:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80031b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80031e:	83 fa 09             	cmp    $0x9,%edx
  800321:	77 39                	ja     80035c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800323:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800326:	eb e9                	jmp    800311 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800328:	8b 45 14             	mov    0x14(%ebp),%eax
  80032b:	8d 48 04             	lea    0x4(%eax),%ecx
  80032e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800331:	8b 00                	mov    (%eax),%eax
  800333:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800339:	eb 27                	jmp    800362 <vprintfmt+0xdf>
  80033b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033e:	85 c0                	test   %eax,%eax
  800340:	b9 00 00 00 00       	mov    $0x0,%ecx
  800345:	0f 49 c8             	cmovns %eax,%ecx
  800348:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034e:	eb 8c                	jmp    8002dc <vprintfmt+0x59>
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800353:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80035a:	eb 80                	jmp    8002dc <vprintfmt+0x59>
  80035c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80035f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800362:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800366:	0f 89 70 ff ff ff    	jns    8002dc <vprintfmt+0x59>
				width = precision, precision = -1;
  80036c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80036f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800372:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800379:	e9 5e ff ff ff       	jmp    8002dc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80037e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800384:	e9 53 ff ff ff       	jmp    8002dc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800389:	8b 45 14             	mov    0x14(%ebp),%eax
  80038c:	8d 50 04             	lea    0x4(%eax),%edx
  80038f:	89 55 14             	mov    %edx,0x14(%ebp)
  800392:	83 ec 08             	sub    $0x8,%esp
  800395:	53                   	push   %ebx
  800396:	ff 30                	pushl  (%eax)
  800398:	ff d6                	call   *%esi
			break;
  80039a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a0:	e9 04 ff ff ff       	jmp    8002a9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 50 04             	lea    0x4(%eax),%edx
  8003ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ae:	8b 00                	mov    (%eax),%eax
  8003b0:	99                   	cltd   
  8003b1:	31 d0                	xor    %edx,%eax
  8003b3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b5:	83 f8 0f             	cmp    $0xf,%eax
  8003b8:	7f 0b                	jg     8003c5 <vprintfmt+0x142>
  8003ba:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  8003c1:	85 d2                	test   %edx,%edx
  8003c3:	75 18                	jne    8003dd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003c5:	50                   	push   %eax
  8003c6:	68 87 1e 80 00       	push   $0x801e87
  8003cb:	53                   	push   %ebx
  8003cc:	56                   	push   %esi
  8003cd:	e8 94 fe ff ff       	call   800266 <printfmt>
  8003d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d8:	e9 cc fe ff ff       	jmp    8002a9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003dd:	52                   	push   %edx
  8003de:	68 71 22 80 00       	push   $0x802271
  8003e3:	53                   	push   %ebx
  8003e4:	56                   	push   %esi
  8003e5:	e8 7c fe ff ff       	call   800266 <printfmt>
  8003ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f0:	e9 b4 fe ff ff       	jmp    8002a9 <vprintfmt+0x26>
  8003f5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fb:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	8d 50 04             	lea    0x4(%eax),%edx
  800404:	89 55 14             	mov    %edx,0x14(%ebp)
  800407:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800409:	85 ff                	test   %edi,%edi
  80040b:	ba 80 1e 80 00       	mov    $0x801e80,%edx
  800410:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800413:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800417:	0f 84 92 00 00 00    	je     8004af <vprintfmt+0x22c>
  80041d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800421:	0f 8e 96 00 00 00    	jle    8004bd <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	51                   	push   %ecx
  80042b:	57                   	push   %edi
  80042c:	e8 86 02 00 00       	call   8006b7 <strnlen>
  800431:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800434:	29 c1                	sub    %eax,%ecx
  800436:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800439:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800440:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800443:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800446:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800448:	eb 0f                	jmp    800459 <vprintfmt+0x1d6>
					putch(padc, putdat);
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	53                   	push   %ebx
  80044e:	ff 75 e0             	pushl  -0x20(%ebp)
  800451:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	83 ef 01             	sub    $0x1,%edi
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	85 ff                	test   %edi,%edi
  80045b:	7f ed                	jg     80044a <vprintfmt+0x1c7>
  80045d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800460:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800463:	85 c9                	test   %ecx,%ecx
  800465:	b8 00 00 00 00       	mov    $0x0,%eax
  80046a:	0f 49 c1             	cmovns %ecx,%eax
  80046d:	29 c1                	sub    %eax,%ecx
  80046f:	89 75 08             	mov    %esi,0x8(%ebp)
  800472:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800475:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800478:	89 cb                	mov    %ecx,%ebx
  80047a:	eb 4d                	jmp    8004c9 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800480:	74 1b                	je     80049d <vprintfmt+0x21a>
  800482:	0f be c0             	movsbl %al,%eax
  800485:	83 e8 20             	sub    $0x20,%eax
  800488:	83 f8 5e             	cmp    $0x5e,%eax
  80048b:	76 10                	jbe    80049d <vprintfmt+0x21a>
					putch('?', putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 0c             	pushl  0xc(%ebp)
  800493:	6a 3f                	push   $0x3f
  800495:	ff 55 08             	call   *0x8(%ebp)
  800498:	83 c4 10             	add    $0x10,%esp
  80049b:	eb 0d                	jmp    8004aa <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	ff 75 0c             	pushl  0xc(%ebp)
  8004a3:	52                   	push   %edx
  8004a4:	ff 55 08             	call   *0x8(%ebp)
  8004a7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004aa:	83 eb 01             	sub    $0x1,%ebx
  8004ad:	eb 1a                	jmp    8004c9 <vprintfmt+0x246>
  8004af:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bb:	eb 0c                	jmp    8004c9 <vprintfmt+0x246>
  8004bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c9:	83 c7 01             	add    $0x1,%edi
  8004cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d0:	0f be d0             	movsbl %al,%edx
  8004d3:	85 d2                	test   %edx,%edx
  8004d5:	74 23                	je     8004fa <vprintfmt+0x277>
  8004d7:	85 f6                	test   %esi,%esi
  8004d9:	78 a1                	js     80047c <vprintfmt+0x1f9>
  8004db:	83 ee 01             	sub    $0x1,%esi
  8004de:	79 9c                	jns    80047c <vprintfmt+0x1f9>
  8004e0:	89 df                	mov    %ebx,%edi
  8004e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e8:	eb 18                	jmp    800502 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	53                   	push   %ebx
  8004ee:	6a 20                	push   $0x20
  8004f0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f2:	83 ef 01             	sub    $0x1,%edi
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	eb 08                	jmp    800502 <vprintfmt+0x27f>
  8004fa:	89 df                	mov    %ebx,%edi
  8004fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800502:	85 ff                	test   %edi,%edi
  800504:	7f e4                	jg     8004ea <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800509:	e9 9b fd ff ff       	jmp    8002a9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050e:	83 fa 01             	cmp    $0x1,%edx
  800511:	7e 16                	jle    800529 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 50 08             	lea    0x8(%eax),%edx
  800519:	89 55 14             	mov    %edx,0x14(%ebp)
  80051c:	8b 50 04             	mov    0x4(%eax),%edx
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800524:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800527:	eb 32                	jmp    80055b <vprintfmt+0x2d8>
	else if (lflag)
  800529:	85 d2                	test   %edx,%edx
  80052b:	74 18                	je     800545 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	8b 00                	mov    (%eax),%eax
  800538:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053b:	89 c1                	mov    %eax,%ecx
  80053d:	c1 f9 1f             	sar    $0x1f,%ecx
  800540:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800543:	eb 16                	jmp    80055b <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800553:	89 c1                	mov    %eax,%ecx
  800555:	c1 f9 1f             	sar    $0x1f,%ecx
  800558:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80055e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800561:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800566:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056a:	79 74                	jns    8005e0 <vprintfmt+0x35d>
				putch('-', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	53                   	push   %ebx
  800570:	6a 2d                	push   $0x2d
  800572:	ff d6                	call   *%esi
				num = -(long long) num;
  800574:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800577:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80057a:	f7 d8                	neg    %eax
  80057c:	83 d2 00             	adc    $0x0,%edx
  80057f:	f7 da                	neg    %edx
  800581:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800584:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800589:	eb 55                	jmp    8005e0 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058b:	8d 45 14             	lea    0x14(%ebp),%eax
  80058e:	e8 7c fc ff ff       	call   80020f <getuint>
			base = 10;
  800593:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800598:	eb 46                	jmp    8005e0 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80059a:	8d 45 14             	lea    0x14(%ebp),%eax
  80059d:	e8 6d fc ff ff       	call   80020f <getuint>
                        base = 8;
  8005a2:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005a7:	eb 37                	jmp    8005e0 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	6a 30                	push   $0x30
  8005af:	ff d6                	call   *%esi
			putch('x', putdat);
  8005b1:	83 c4 08             	add    $0x8,%esp
  8005b4:	53                   	push   %ebx
  8005b5:	6a 78                	push   $0x78
  8005b7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 50 04             	lea    0x4(%eax),%edx
  8005bf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c2:	8b 00                	mov    (%eax),%eax
  8005c4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005cc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005d1:	eb 0d                	jmp    8005e0 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d6:	e8 34 fc ff ff       	call   80020f <getuint>
			base = 16;
  8005db:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005e7:	57                   	push   %edi
  8005e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8005eb:	51                   	push   %ecx
  8005ec:	52                   	push   %edx
  8005ed:	50                   	push   %eax
  8005ee:	89 da                	mov    %ebx,%edx
  8005f0:	89 f0                	mov    %esi,%eax
  8005f2:	e8 6e fb ff ff       	call   800165 <printnum>
			break;
  8005f7:	83 c4 20             	add    $0x20,%esp
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fd:	e9 a7 fc ff ff       	jmp    8002a9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	51                   	push   %ecx
  800607:	ff d6                	call   *%esi
			break;
  800609:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80060f:	e9 95 fc ff ff       	jmp    8002a9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	6a 25                	push   $0x25
  80061a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80061c:	83 c4 10             	add    $0x10,%esp
  80061f:	eb 03                	jmp    800624 <vprintfmt+0x3a1>
  800621:	83 ef 01             	sub    $0x1,%edi
  800624:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800628:	75 f7                	jne    800621 <vprintfmt+0x39e>
  80062a:	e9 7a fc ff ff       	jmp    8002a9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	83 ec 18             	sub    $0x18,%esp
  80063d:	8b 45 08             	mov    0x8(%ebp),%eax
  800640:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800643:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800646:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80064a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80064d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800654:	85 c0                	test   %eax,%eax
  800656:	74 26                	je     80067e <vsnprintf+0x47>
  800658:	85 d2                	test   %edx,%edx
  80065a:	7e 22                	jle    80067e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80065c:	ff 75 14             	pushl  0x14(%ebp)
  80065f:	ff 75 10             	pushl  0x10(%ebp)
  800662:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800665:	50                   	push   %eax
  800666:	68 49 02 80 00       	push   $0x800249
  80066b:	e8 13 fc ff ff       	call   800283 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800670:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800673:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800676:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	eb 05                	jmp    800683 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80067e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800683:	c9                   	leave  
  800684:	c3                   	ret    

00800685 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80068e:	50                   	push   %eax
  80068f:	ff 75 10             	pushl  0x10(%ebp)
  800692:	ff 75 0c             	pushl  0xc(%ebp)
  800695:	ff 75 08             	pushl  0x8(%ebp)
  800698:	e8 9a ff ff ff       	call   800637 <vsnprintf>
	va_end(ap);

	return rc;
}
  80069d:	c9                   	leave  
  80069e:	c3                   	ret    

0080069f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006aa:	eb 03                	jmp    8006af <strlen+0x10>
		n++;
  8006ac:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006af:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006b3:	75 f7                	jne    8006ac <strlen+0xd>
		n++;
	return n;
}
  8006b5:	5d                   	pop    %ebp
  8006b6:	c3                   	ret    

008006b7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c5:	eb 03                	jmp    8006ca <strnlen+0x13>
		n++;
  8006c7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ca:	39 c2                	cmp    %eax,%edx
  8006cc:	74 08                	je     8006d6 <strnlen+0x1f>
  8006ce:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006d2:	75 f3                	jne    8006c7 <strnlen+0x10>
  8006d4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	53                   	push   %ebx
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006e2:	89 c2                	mov    %eax,%edx
  8006e4:	83 c2 01             	add    $0x1,%edx
  8006e7:	83 c1 01             	add    $0x1,%ecx
  8006ea:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006ee:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006f1:	84 db                	test   %bl,%bl
  8006f3:	75 ef                	jne    8006e4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006f5:	5b                   	pop    %ebx
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	53                   	push   %ebx
  8006fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006ff:	53                   	push   %ebx
  800700:	e8 9a ff ff ff       	call   80069f <strlen>
  800705:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800708:	ff 75 0c             	pushl  0xc(%ebp)
  80070b:	01 d8                	add    %ebx,%eax
  80070d:	50                   	push   %eax
  80070e:	e8 c5 ff ff ff       	call   8006d8 <strcpy>
	return dst;
}
  800713:	89 d8                	mov    %ebx,%eax
  800715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800718:	c9                   	leave  
  800719:	c3                   	ret    

0080071a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	56                   	push   %esi
  80071e:	53                   	push   %ebx
  80071f:	8b 75 08             	mov    0x8(%ebp),%esi
  800722:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800725:	89 f3                	mov    %esi,%ebx
  800727:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80072a:	89 f2                	mov    %esi,%edx
  80072c:	eb 0f                	jmp    80073d <strncpy+0x23>
		*dst++ = *src;
  80072e:	83 c2 01             	add    $0x1,%edx
  800731:	0f b6 01             	movzbl (%ecx),%eax
  800734:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800737:	80 39 01             	cmpb   $0x1,(%ecx)
  80073a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073d:	39 da                	cmp    %ebx,%edx
  80073f:	75 ed                	jne    80072e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800741:	89 f0                	mov    %esi,%eax
  800743:	5b                   	pop    %ebx
  800744:	5e                   	pop    %esi
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	56                   	push   %esi
  80074b:	53                   	push   %ebx
  80074c:	8b 75 08             	mov    0x8(%ebp),%esi
  80074f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800752:	8b 55 10             	mov    0x10(%ebp),%edx
  800755:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800757:	85 d2                	test   %edx,%edx
  800759:	74 21                	je     80077c <strlcpy+0x35>
  80075b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80075f:	89 f2                	mov    %esi,%edx
  800761:	eb 09                	jmp    80076c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800763:	83 c2 01             	add    $0x1,%edx
  800766:	83 c1 01             	add    $0x1,%ecx
  800769:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80076c:	39 c2                	cmp    %eax,%edx
  80076e:	74 09                	je     800779 <strlcpy+0x32>
  800770:	0f b6 19             	movzbl (%ecx),%ebx
  800773:	84 db                	test   %bl,%bl
  800775:	75 ec                	jne    800763 <strlcpy+0x1c>
  800777:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800779:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80077c:	29 f0                	sub    %esi,%eax
}
  80077e:	5b                   	pop    %ebx
  80077f:	5e                   	pop    %esi
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800788:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80078b:	eb 06                	jmp    800793 <strcmp+0x11>
		p++, q++;
  80078d:	83 c1 01             	add    $0x1,%ecx
  800790:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800793:	0f b6 01             	movzbl (%ecx),%eax
  800796:	84 c0                	test   %al,%al
  800798:	74 04                	je     80079e <strcmp+0x1c>
  80079a:	3a 02                	cmp    (%edx),%al
  80079c:	74 ef                	je     80078d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80079e:	0f b6 c0             	movzbl %al,%eax
  8007a1:	0f b6 12             	movzbl (%edx),%edx
  8007a4:	29 d0                	sub    %edx,%eax
}
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b2:	89 c3                	mov    %eax,%ebx
  8007b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b7:	eb 06                	jmp    8007bf <strncmp+0x17>
		n--, p++, q++;
  8007b9:	83 c0 01             	add    $0x1,%eax
  8007bc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007bf:	39 d8                	cmp    %ebx,%eax
  8007c1:	74 15                	je     8007d8 <strncmp+0x30>
  8007c3:	0f b6 08             	movzbl (%eax),%ecx
  8007c6:	84 c9                	test   %cl,%cl
  8007c8:	74 04                	je     8007ce <strncmp+0x26>
  8007ca:	3a 0a                	cmp    (%edx),%cl
  8007cc:	74 eb                	je     8007b9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ce:	0f b6 00             	movzbl (%eax),%eax
  8007d1:	0f b6 12             	movzbl (%edx),%edx
  8007d4:	29 d0                	sub    %edx,%eax
  8007d6:	eb 05                	jmp    8007dd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007dd:	5b                   	pop    %ebx
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007ea:	eb 07                	jmp    8007f3 <strchr+0x13>
		if (*s == c)
  8007ec:	38 ca                	cmp    %cl,%dl
  8007ee:	74 0f                	je     8007ff <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007f0:	83 c0 01             	add    $0x1,%eax
  8007f3:	0f b6 10             	movzbl (%eax),%edx
  8007f6:	84 d2                	test   %dl,%dl
  8007f8:	75 f2                	jne    8007ec <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080b:	eb 03                	jmp    800810 <strfind+0xf>
  80080d:	83 c0 01             	add    $0x1,%eax
  800810:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800813:	84 d2                	test   %dl,%dl
  800815:	74 04                	je     80081b <strfind+0x1a>
  800817:	38 ca                	cmp    %cl,%dl
  800819:	75 f2                	jne    80080d <strfind+0xc>
			break;
	return (char *) s;
}
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	57                   	push   %edi
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	8b 7d 08             	mov    0x8(%ebp),%edi
  800826:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800829:	85 c9                	test   %ecx,%ecx
  80082b:	74 36                	je     800863 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80082d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800833:	75 28                	jne    80085d <memset+0x40>
  800835:	f6 c1 03             	test   $0x3,%cl
  800838:	75 23                	jne    80085d <memset+0x40>
		c &= 0xFF;
  80083a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80083e:	89 d3                	mov    %edx,%ebx
  800840:	c1 e3 08             	shl    $0x8,%ebx
  800843:	89 d6                	mov    %edx,%esi
  800845:	c1 e6 18             	shl    $0x18,%esi
  800848:	89 d0                	mov    %edx,%eax
  80084a:	c1 e0 10             	shl    $0x10,%eax
  80084d:	09 f0                	or     %esi,%eax
  80084f:	09 c2                	or     %eax,%edx
  800851:	89 d0                	mov    %edx,%eax
  800853:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800855:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800858:	fc                   	cld    
  800859:	f3 ab                	rep stos %eax,%es:(%edi)
  80085b:	eb 06                	jmp    800863 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80085d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800860:	fc                   	cld    
  800861:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800863:	89 f8                	mov    %edi,%eax
  800865:	5b                   	pop    %ebx
  800866:	5e                   	pop    %esi
  800867:	5f                   	pop    %edi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	57                   	push   %edi
  80086e:	56                   	push   %esi
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	8b 75 0c             	mov    0xc(%ebp),%esi
  800875:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800878:	39 c6                	cmp    %eax,%esi
  80087a:	73 35                	jae    8008b1 <memmove+0x47>
  80087c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80087f:	39 d0                	cmp    %edx,%eax
  800881:	73 2e                	jae    8008b1 <memmove+0x47>
		s += n;
		d += n;
  800883:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800886:	89 d6                	mov    %edx,%esi
  800888:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80088a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800890:	75 13                	jne    8008a5 <memmove+0x3b>
  800892:	f6 c1 03             	test   $0x3,%cl
  800895:	75 0e                	jne    8008a5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800897:	83 ef 04             	sub    $0x4,%edi
  80089a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80089d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008a0:	fd                   	std    
  8008a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a3:	eb 09                	jmp    8008ae <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008a5:	83 ef 01             	sub    $0x1,%edi
  8008a8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ab:	fd                   	std    
  8008ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ae:	fc                   	cld    
  8008af:	eb 1d                	jmp    8008ce <memmove+0x64>
  8008b1:	89 f2                	mov    %esi,%edx
  8008b3:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b5:	f6 c2 03             	test   $0x3,%dl
  8008b8:	75 0f                	jne    8008c9 <memmove+0x5f>
  8008ba:	f6 c1 03             	test   $0x3,%cl
  8008bd:	75 0a                	jne    8008c9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008bf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008c2:	89 c7                	mov    %eax,%edi
  8008c4:	fc                   	cld    
  8008c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c7:	eb 05                	jmp    8008ce <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c9:	89 c7                	mov    %eax,%edi
  8008cb:	fc                   	cld    
  8008cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ce:	5e                   	pop    %esi
  8008cf:	5f                   	pop    %edi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008d5:	ff 75 10             	pushl  0x10(%ebp)
  8008d8:	ff 75 0c             	pushl  0xc(%ebp)
  8008db:	ff 75 08             	pushl  0x8(%ebp)
  8008de:	e8 87 ff ff ff       	call   80086a <memmove>
}
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f0:	89 c6                	mov    %eax,%esi
  8008f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f5:	eb 1a                	jmp    800911 <memcmp+0x2c>
		if (*s1 != *s2)
  8008f7:	0f b6 08             	movzbl (%eax),%ecx
  8008fa:	0f b6 1a             	movzbl (%edx),%ebx
  8008fd:	38 d9                	cmp    %bl,%cl
  8008ff:	74 0a                	je     80090b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800901:	0f b6 c1             	movzbl %cl,%eax
  800904:	0f b6 db             	movzbl %bl,%ebx
  800907:	29 d8                	sub    %ebx,%eax
  800909:	eb 0f                	jmp    80091a <memcmp+0x35>
		s1++, s2++;
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800911:	39 f0                	cmp    %esi,%eax
  800913:	75 e2                	jne    8008f7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091a:	5b                   	pop    %ebx
  80091b:	5e                   	pop    %esi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800927:	89 c2                	mov    %eax,%edx
  800929:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80092c:	eb 07                	jmp    800935 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80092e:	38 08                	cmp    %cl,(%eax)
  800930:	74 07                	je     800939 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800932:	83 c0 01             	add    $0x1,%eax
  800935:	39 d0                	cmp    %edx,%eax
  800937:	72 f5                	jb     80092e <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	57                   	push   %edi
  80093f:	56                   	push   %esi
  800940:	53                   	push   %ebx
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800944:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800947:	eb 03                	jmp    80094c <strtol+0x11>
		s++;
  800949:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80094c:	0f b6 01             	movzbl (%ecx),%eax
  80094f:	3c 09                	cmp    $0x9,%al
  800951:	74 f6                	je     800949 <strtol+0xe>
  800953:	3c 20                	cmp    $0x20,%al
  800955:	74 f2                	je     800949 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800957:	3c 2b                	cmp    $0x2b,%al
  800959:	75 0a                	jne    800965 <strtol+0x2a>
		s++;
  80095b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80095e:	bf 00 00 00 00       	mov    $0x0,%edi
  800963:	eb 10                	jmp    800975 <strtol+0x3a>
  800965:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80096a:	3c 2d                	cmp    $0x2d,%al
  80096c:	75 07                	jne    800975 <strtol+0x3a>
		s++, neg = 1;
  80096e:	8d 49 01             	lea    0x1(%ecx),%ecx
  800971:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800975:	85 db                	test   %ebx,%ebx
  800977:	0f 94 c0             	sete   %al
  80097a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800980:	75 19                	jne    80099b <strtol+0x60>
  800982:	80 39 30             	cmpb   $0x30,(%ecx)
  800985:	75 14                	jne    80099b <strtol+0x60>
  800987:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80098b:	0f 85 82 00 00 00    	jne    800a13 <strtol+0xd8>
		s += 2, base = 16;
  800991:	83 c1 02             	add    $0x2,%ecx
  800994:	bb 10 00 00 00       	mov    $0x10,%ebx
  800999:	eb 16                	jmp    8009b1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80099b:	84 c0                	test   %al,%al
  80099d:	74 12                	je     8009b1 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80099f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009a4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a7:	75 08                	jne    8009b1 <strtol+0x76>
		s++, base = 8;
  8009a9:	83 c1 01             	add    $0x1,%ecx
  8009ac:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b9:	0f b6 11             	movzbl (%ecx),%edx
  8009bc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009bf:	89 f3                	mov    %esi,%ebx
  8009c1:	80 fb 09             	cmp    $0x9,%bl
  8009c4:	77 08                	ja     8009ce <strtol+0x93>
			dig = *s - '0';
  8009c6:	0f be d2             	movsbl %dl,%edx
  8009c9:	83 ea 30             	sub    $0x30,%edx
  8009cc:	eb 22                	jmp    8009f0 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009ce:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009d1:	89 f3                	mov    %esi,%ebx
  8009d3:	80 fb 19             	cmp    $0x19,%bl
  8009d6:	77 08                	ja     8009e0 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009d8:	0f be d2             	movsbl %dl,%edx
  8009db:	83 ea 57             	sub    $0x57,%edx
  8009de:	eb 10                	jmp    8009f0 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009e0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009e3:	89 f3                	mov    %esi,%ebx
  8009e5:	80 fb 19             	cmp    $0x19,%bl
  8009e8:	77 16                	ja     800a00 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009ea:	0f be d2             	movsbl %dl,%edx
  8009ed:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009f0:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009f3:	7d 0f                	jge    800a04 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009f5:	83 c1 01             	add    $0x1,%ecx
  8009f8:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009fc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009fe:	eb b9                	jmp    8009b9 <strtol+0x7e>
  800a00:	89 c2                	mov    %eax,%edx
  800a02:	eb 02                	jmp    800a06 <strtol+0xcb>
  800a04:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0a:	74 0d                	je     800a19 <strtol+0xde>
		*endptr = (char *) s;
  800a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0f:	89 0e                	mov    %ecx,(%esi)
  800a11:	eb 06                	jmp    800a19 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a13:	84 c0                	test   %al,%al
  800a15:	75 92                	jne    8009a9 <strtol+0x6e>
  800a17:	eb 98                	jmp    8009b1 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a19:	f7 da                	neg    %edx
  800a1b:	85 ff                	test   %edi,%edi
  800a1d:	0f 45 c2             	cmovne %edx,%eax
}
  800a20:	5b                   	pop    %ebx
  800a21:	5e                   	pop    %esi
  800a22:	5f                   	pop    %edi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	57                   	push   %edi
  800a29:	56                   	push   %esi
  800a2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a33:	8b 55 08             	mov    0x8(%ebp),%edx
  800a36:	89 c3                	mov    %eax,%ebx
  800a38:	89 c7                	mov    %eax,%edi
  800a3a:	89 c6                	mov    %eax,%esi
  800a3c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5f                   	pop    %edi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a49:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a53:	89 d1                	mov    %edx,%ecx
  800a55:	89 d3                	mov    %edx,%ebx
  800a57:	89 d7                	mov    %edx,%edi
  800a59:	89 d6                	mov    %edx,%esi
  800a5b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5f                   	pop    %edi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a70:	b8 03 00 00 00       	mov    $0x3,%eax
  800a75:	8b 55 08             	mov    0x8(%ebp),%edx
  800a78:	89 cb                	mov    %ecx,%ebx
  800a7a:	89 cf                	mov    %ecx,%edi
  800a7c:	89 ce                	mov    %ecx,%esi
  800a7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a80:	85 c0                	test   %eax,%eax
  800a82:	7e 17                	jle    800a9b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a84:	83 ec 0c             	sub    $0xc,%esp
  800a87:	50                   	push   %eax
  800a88:	6a 03                	push   $0x3
  800a8a:	68 9f 21 80 00       	push   $0x80219f
  800a8f:	6a 23                	push   $0x23
  800a91:	68 bc 21 80 00       	push   $0x8021bc
  800a96:	e8 44 0f 00 00       	call   8019df <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aae:	b8 02 00 00 00       	mov    $0x2,%eax
  800ab3:	89 d1                	mov    %edx,%ecx
  800ab5:	89 d3                	mov    %edx,%ebx
  800ab7:	89 d7                	mov    %edx,%edi
  800ab9:	89 d6                	mov    %edx,%esi
  800abb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <sys_yield>:

void
sys_yield(void)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac8:	ba 00 00 00 00       	mov    $0x0,%edx
  800acd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ad2:	89 d1                	mov    %edx,%ecx
  800ad4:	89 d3                	mov    %edx,%ebx
  800ad6:	89 d7                	mov    %edx,%edi
  800ad8:	89 d6                	mov    %edx,%esi
  800ada:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	be 00 00 00 00       	mov    $0x0,%esi
  800aef:	b8 04 00 00 00       	mov    $0x4,%eax
  800af4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af7:	8b 55 08             	mov    0x8(%ebp),%edx
  800afa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800afd:	89 f7                	mov    %esi,%edi
  800aff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b01:	85 c0                	test   %eax,%eax
  800b03:	7e 17                	jle    800b1c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	50                   	push   %eax
  800b09:	6a 04                	push   $0x4
  800b0b:	68 9f 21 80 00       	push   $0x80219f
  800b10:	6a 23                	push   $0x23
  800b12:	68 bc 21 80 00       	push   $0x8021bc
  800b17:	e8 c3 0e 00 00       	call   8019df <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b35:	8b 55 08             	mov    0x8(%ebp),%edx
  800b38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b3e:	8b 75 18             	mov    0x18(%ebp),%esi
  800b41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b43:	85 c0                	test   %eax,%eax
  800b45:	7e 17                	jle    800b5e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	50                   	push   %eax
  800b4b:	6a 05                	push   $0x5
  800b4d:	68 9f 21 80 00       	push   $0x80219f
  800b52:	6a 23                	push   $0x23
  800b54:	68 bc 21 80 00       	push   $0x8021bc
  800b59:	e8 81 0e 00 00       	call   8019df <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b74:	b8 06 00 00 00       	mov    $0x6,%eax
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7f:	89 df                	mov    %ebx,%edi
  800b81:	89 de                	mov    %ebx,%esi
  800b83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b85:	85 c0                	test   %eax,%eax
  800b87:	7e 17                	jle    800ba0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	50                   	push   %eax
  800b8d:	6a 06                	push   $0x6
  800b8f:	68 9f 21 80 00       	push   $0x80219f
  800b94:	6a 23                	push   $0x23
  800b96:	68 bc 21 80 00       	push   $0x8021bc
  800b9b:	e8 3f 0e 00 00       	call   8019df <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ba0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb6:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	89 df                	mov    %ebx,%edi
  800bc3:	89 de                	mov    %ebx,%esi
  800bc5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	7e 17                	jle    800be2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcb:	83 ec 0c             	sub    $0xc,%esp
  800bce:	50                   	push   %eax
  800bcf:	6a 08                	push   $0x8
  800bd1:	68 9f 21 80 00       	push   $0x80219f
  800bd6:	6a 23                	push   $0x23
  800bd8:	68 bc 21 80 00       	push   $0x8021bc
  800bdd:	e8 fd 0d 00 00       	call   8019df <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800be2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf8:	b8 09 00 00 00       	mov    $0x9,%eax
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	89 df                	mov    %ebx,%edi
  800c05:	89 de                	mov    %ebx,%esi
  800c07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	7e 17                	jle    800c24 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0d:	83 ec 0c             	sub    $0xc,%esp
  800c10:	50                   	push   %eax
  800c11:	6a 09                	push   $0x9
  800c13:	68 9f 21 80 00       	push   $0x80219f
  800c18:	6a 23                	push   $0x23
  800c1a:	68 bc 21 80 00       	push   $0x8021bc
  800c1f:	e8 bb 0d 00 00       	call   8019df <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
  800c45:	89 df                	mov    %ebx,%edi
  800c47:	89 de                	mov    %ebx,%esi
  800c49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7e 17                	jle    800c66 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4f:	83 ec 0c             	sub    $0xc,%esp
  800c52:	50                   	push   %eax
  800c53:	6a 0a                	push   $0xa
  800c55:	68 9f 21 80 00       	push   $0x80219f
  800c5a:	6a 23                	push   $0x23
  800c5c:	68 bc 21 80 00       	push   $0x8021bc
  800c61:	e8 79 0d 00 00       	call   8019df <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	be 00 00 00 00       	mov    $0x0,%esi
  800c79:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c87:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	89 cb                	mov    %ecx,%ebx
  800ca9:	89 cf                	mov    %ecx,%edi
  800cab:	89 ce                	mov    %ecx,%esi
  800cad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	7e 17                	jle    800cca <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	50                   	push   %eax
  800cb7:	6a 0d                	push   $0xd
  800cb9:	68 9f 21 80 00       	push   $0x80219f
  800cbe:	6a 23                	push   $0x23
  800cc0:	68 bc 21 80 00       	push   $0x8021bc
  800cc5:	e8 15 0d 00 00       	call   8019df <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	05 00 00 00 30       	add    $0x30000000,%eax
  800cdd:	c1 e8 0c             	shr    $0xc,%eax
}
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce8:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800ced:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800cf2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cff:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d04:	89 c2                	mov    %eax,%edx
  800d06:	c1 ea 16             	shr    $0x16,%edx
  800d09:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d10:	f6 c2 01             	test   $0x1,%dl
  800d13:	74 11                	je     800d26 <fd_alloc+0x2d>
  800d15:	89 c2                	mov    %eax,%edx
  800d17:	c1 ea 0c             	shr    $0xc,%edx
  800d1a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d21:	f6 c2 01             	test   $0x1,%dl
  800d24:	75 09                	jne    800d2f <fd_alloc+0x36>
			*fd_store = fd;
  800d26:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d28:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2d:	eb 17                	jmp    800d46 <fd_alloc+0x4d>
  800d2f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d34:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d39:	75 c9                	jne    800d04 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d3b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d41:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d4e:	83 f8 1f             	cmp    $0x1f,%eax
  800d51:	77 36                	ja     800d89 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d53:	c1 e0 0c             	shl    $0xc,%eax
  800d56:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d5b:	89 c2                	mov    %eax,%edx
  800d5d:	c1 ea 16             	shr    $0x16,%edx
  800d60:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d67:	f6 c2 01             	test   $0x1,%dl
  800d6a:	74 24                	je     800d90 <fd_lookup+0x48>
  800d6c:	89 c2                	mov    %eax,%edx
  800d6e:	c1 ea 0c             	shr    $0xc,%edx
  800d71:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d78:	f6 c2 01             	test   $0x1,%dl
  800d7b:	74 1a                	je     800d97 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d80:	89 02                	mov    %eax,(%edx)
	return 0;
  800d82:	b8 00 00 00 00       	mov    $0x0,%eax
  800d87:	eb 13                	jmp    800d9c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d8e:	eb 0c                	jmp    800d9c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d95:	eb 05                	jmp    800d9c <fd_lookup+0x54>
  800d97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	83 ec 08             	sub    $0x8,%esp
  800da4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da7:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dac:	eb 13                	jmp    800dc1 <dev_lookup+0x23>
  800dae:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800db1:	39 08                	cmp    %ecx,(%eax)
  800db3:	75 0c                	jne    800dc1 <dev_lookup+0x23>
			*dev = devtab[i];
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dba:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbf:	eb 2e                	jmp    800def <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dc1:	8b 02                	mov    (%edx),%eax
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	75 e7                	jne    800dae <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dc7:	a1 04 40 80 00       	mov    0x804004,%eax
  800dcc:	8b 40 48             	mov    0x48(%eax),%eax
  800dcf:	83 ec 04             	sub    $0x4,%esp
  800dd2:	51                   	push   %ecx
  800dd3:	50                   	push   %eax
  800dd4:	68 cc 21 80 00       	push   $0x8021cc
  800dd9:	e8 73 f3 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800dde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800def:	c9                   	leave  
  800df0:	c3                   	ret    

00800df1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 10             	sub    $0x10,%esp
  800df9:	8b 75 08             	mov    0x8(%ebp),%esi
  800dfc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800dff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e02:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e03:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e09:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e0c:	50                   	push   %eax
  800e0d:	e8 36 ff ff ff       	call   800d48 <fd_lookup>
  800e12:	83 c4 08             	add    $0x8,%esp
  800e15:	85 c0                	test   %eax,%eax
  800e17:	78 05                	js     800e1e <fd_close+0x2d>
	    || fd != fd2)
  800e19:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e1c:	74 0c                	je     800e2a <fd_close+0x39>
		return (must_exist ? r : 0);
  800e1e:	84 db                	test   %bl,%bl
  800e20:	ba 00 00 00 00       	mov    $0x0,%edx
  800e25:	0f 44 c2             	cmove  %edx,%eax
  800e28:	eb 41                	jmp    800e6b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e2a:	83 ec 08             	sub    $0x8,%esp
  800e2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e30:	50                   	push   %eax
  800e31:	ff 36                	pushl  (%esi)
  800e33:	e8 66 ff ff ff       	call   800d9e <dev_lookup>
  800e38:	89 c3                	mov    %eax,%ebx
  800e3a:	83 c4 10             	add    $0x10,%esp
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	78 1a                	js     800e5b <fd_close+0x6a>
		if (dev->dev_close)
  800e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e44:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e47:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	74 0b                	je     800e5b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	56                   	push   %esi
  800e54:	ff d0                	call   *%eax
  800e56:	89 c3                	mov    %eax,%ebx
  800e58:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e5b:	83 ec 08             	sub    $0x8,%esp
  800e5e:	56                   	push   %esi
  800e5f:	6a 00                	push   $0x0
  800e61:	e8 00 fd ff ff       	call   800b66 <sys_page_unmap>
	return r;
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	89 d8                	mov    %ebx,%eax
}
  800e6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7b:	50                   	push   %eax
  800e7c:	ff 75 08             	pushl  0x8(%ebp)
  800e7f:	e8 c4 fe ff ff       	call   800d48 <fd_lookup>
  800e84:	89 c2                	mov    %eax,%edx
  800e86:	83 c4 08             	add    $0x8,%esp
  800e89:	85 d2                	test   %edx,%edx
  800e8b:	78 10                	js     800e9d <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800e8d:	83 ec 08             	sub    $0x8,%esp
  800e90:	6a 01                	push   $0x1
  800e92:	ff 75 f4             	pushl  -0xc(%ebp)
  800e95:	e8 57 ff ff ff       	call   800df1 <fd_close>
  800e9a:	83 c4 10             	add    $0x10,%esp
}
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    

00800e9f <close_all>:

void
close_all(void)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ea6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800eab:	83 ec 0c             	sub    $0xc,%esp
  800eae:	53                   	push   %ebx
  800eaf:	e8 be ff ff ff       	call   800e72 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800eb4:	83 c3 01             	add    $0x1,%ebx
  800eb7:	83 c4 10             	add    $0x10,%esp
  800eba:	83 fb 20             	cmp    $0x20,%ebx
  800ebd:	75 ec                	jne    800eab <close_all+0xc>
		close(i);
}
  800ebf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	53                   	push   %ebx
  800eca:	83 ec 2c             	sub    $0x2c,%esp
  800ecd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ed0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ed3:	50                   	push   %eax
  800ed4:	ff 75 08             	pushl  0x8(%ebp)
  800ed7:	e8 6c fe ff ff       	call   800d48 <fd_lookup>
  800edc:	89 c2                	mov    %eax,%edx
  800ede:	83 c4 08             	add    $0x8,%esp
  800ee1:	85 d2                	test   %edx,%edx
  800ee3:	0f 88 c1 00 00 00    	js     800faa <dup+0xe6>
		return r;
	close(newfdnum);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	56                   	push   %esi
  800eed:	e8 80 ff ff ff       	call   800e72 <close>

	newfd = INDEX2FD(newfdnum);
  800ef2:	89 f3                	mov    %esi,%ebx
  800ef4:	c1 e3 0c             	shl    $0xc,%ebx
  800ef7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800efd:	83 c4 04             	add    $0x4,%esp
  800f00:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f03:	e8 da fd ff ff       	call   800ce2 <fd2data>
  800f08:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f0a:	89 1c 24             	mov    %ebx,(%esp)
  800f0d:	e8 d0 fd ff ff       	call   800ce2 <fd2data>
  800f12:	83 c4 10             	add    $0x10,%esp
  800f15:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f18:	89 f8                	mov    %edi,%eax
  800f1a:	c1 e8 16             	shr    $0x16,%eax
  800f1d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f24:	a8 01                	test   $0x1,%al
  800f26:	74 37                	je     800f5f <dup+0x9b>
  800f28:	89 f8                	mov    %edi,%eax
  800f2a:	c1 e8 0c             	shr    $0xc,%eax
  800f2d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f34:	f6 c2 01             	test   $0x1,%dl
  800f37:	74 26                	je     800f5f <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f39:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f40:	83 ec 0c             	sub    $0xc,%esp
  800f43:	25 07 0e 00 00       	and    $0xe07,%eax
  800f48:	50                   	push   %eax
  800f49:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f4c:	6a 00                	push   $0x0
  800f4e:	57                   	push   %edi
  800f4f:	6a 00                	push   $0x0
  800f51:	e8 ce fb ff ff       	call   800b24 <sys_page_map>
  800f56:	89 c7                	mov    %eax,%edi
  800f58:	83 c4 20             	add    $0x20,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	78 2e                	js     800f8d <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f5f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f62:	89 d0                	mov    %edx,%eax
  800f64:	c1 e8 0c             	shr    $0xc,%eax
  800f67:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6e:	83 ec 0c             	sub    $0xc,%esp
  800f71:	25 07 0e 00 00       	and    $0xe07,%eax
  800f76:	50                   	push   %eax
  800f77:	53                   	push   %ebx
  800f78:	6a 00                	push   $0x0
  800f7a:	52                   	push   %edx
  800f7b:	6a 00                	push   $0x0
  800f7d:	e8 a2 fb ff ff       	call   800b24 <sys_page_map>
  800f82:	89 c7                	mov    %eax,%edi
  800f84:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f87:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f89:	85 ff                	test   %edi,%edi
  800f8b:	79 1d                	jns    800faa <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800f8d:	83 ec 08             	sub    $0x8,%esp
  800f90:	53                   	push   %ebx
  800f91:	6a 00                	push   $0x0
  800f93:	e8 ce fb ff ff       	call   800b66 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800f98:	83 c4 08             	add    $0x8,%esp
  800f9b:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f9e:	6a 00                	push   $0x0
  800fa0:	e8 c1 fb ff ff       	call   800b66 <sys_page_unmap>
	return r;
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	89 f8                	mov    %edi,%eax
}
  800faa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5f                   	pop    %edi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	53                   	push   %ebx
  800fb6:	83 ec 14             	sub    $0x14,%esp
  800fb9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fbc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fbf:	50                   	push   %eax
  800fc0:	53                   	push   %ebx
  800fc1:	e8 82 fd ff ff       	call   800d48 <fd_lookup>
  800fc6:	83 c4 08             	add    $0x8,%esp
  800fc9:	89 c2                	mov    %eax,%edx
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	78 6d                	js     80103c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fcf:	83 ec 08             	sub    $0x8,%esp
  800fd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd5:	50                   	push   %eax
  800fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fd9:	ff 30                	pushl  (%eax)
  800fdb:	e8 be fd ff ff       	call   800d9e <dev_lookup>
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	78 4c                	js     801033 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800fe7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fea:	8b 42 08             	mov    0x8(%edx),%eax
  800fed:	83 e0 03             	and    $0x3,%eax
  800ff0:	83 f8 01             	cmp    $0x1,%eax
  800ff3:	75 21                	jne    801016 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ff5:	a1 04 40 80 00       	mov    0x804004,%eax
  800ffa:	8b 40 48             	mov    0x48(%eax),%eax
  800ffd:	83 ec 04             	sub    $0x4,%esp
  801000:	53                   	push   %ebx
  801001:	50                   	push   %eax
  801002:	68 0d 22 80 00       	push   $0x80220d
  801007:	e8 45 f1 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801014:	eb 26                	jmp    80103c <read+0x8a>
	}
	if (!dev->dev_read)
  801016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801019:	8b 40 08             	mov    0x8(%eax),%eax
  80101c:	85 c0                	test   %eax,%eax
  80101e:	74 17                	je     801037 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801020:	83 ec 04             	sub    $0x4,%esp
  801023:	ff 75 10             	pushl  0x10(%ebp)
  801026:	ff 75 0c             	pushl  0xc(%ebp)
  801029:	52                   	push   %edx
  80102a:	ff d0                	call   *%eax
  80102c:	89 c2                	mov    %eax,%edx
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	eb 09                	jmp    80103c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801033:	89 c2                	mov    %eax,%edx
  801035:	eb 05                	jmp    80103c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801037:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80103c:	89 d0                	mov    %edx,%eax
  80103e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801041:	c9                   	leave  
  801042:	c3                   	ret    

00801043 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
  801049:	83 ec 0c             	sub    $0xc,%esp
  80104c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80104f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801052:	bb 00 00 00 00       	mov    $0x0,%ebx
  801057:	eb 21                	jmp    80107a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801059:	83 ec 04             	sub    $0x4,%esp
  80105c:	89 f0                	mov    %esi,%eax
  80105e:	29 d8                	sub    %ebx,%eax
  801060:	50                   	push   %eax
  801061:	89 d8                	mov    %ebx,%eax
  801063:	03 45 0c             	add    0xc(%ebp),%eax
  801066:	50                   	push   %eax
  801067:	57                   	push   %edi
  801068:	e8 45 ff ff ff       	call   800fb2 <read>
		if (m < 0)
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	78 0c                	js     801080 <readn+0x3d>
			return m;
		if (m == 0)
  801074:	85 c0                	test   %eax,%eax
  801076:	74 06                	je     80107e <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801078:	01 c3                	add    %eax,%ebx
  80107a:	39 f3                	cmp    %esi,%ebx
  80107c:	72 db                	jb     801059 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80107e:	89 d8                	mov    %ebx,%eax
}
  801080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801083:	5b                   	pop    %ebx
  801084:	5e                   	pop    %esi
  801085:	5f                   	pop    %edi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	53                   	push   %ebx
  80108c:	83 ec 14             	sub    $0x14,%esp
  80108f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801092:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801095:	50                   	push   %eax
  801096:	53                   	push   %ebx
  801097:	e8 ac fc ff ff       	call   800d48 <fd_lookup>
  80109c:	83 c4 08             	add    $0x8,%esp
  80109f:	89 c2                	mov    %eax,%edx
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	78 68                	js     80110d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a5:	83 ec 08             	sub    $0x8,%esp
  8010a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ab:	50                   	push   %eax
  8010ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010af:	ff 30                	pushl  (%eax)
  8010b1:	e8 e8 fc ff ff       	call   800d9e <dev_lookup>
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	78 47                	js     801104 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010c4:	75 21                	jne    8010e7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8010cb:	8b 40 48             	mov    0x48(%eax),%eax
  8010ce:	83 ec 04             	sub    $0x4,%esp
  8010d1:	53                   	push   %ebx
  8010d2:	50                   	push   %eax
  8010d3:	68 29 22 80 00       	push   $0x802229
  8010d8:	e8 74 f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010e5:	eb 26                	jmp    80110d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010ea:	8b 52 0c             	mov    0xc(%edx),%edx
  8010ed:	85 d2                	test   %edx,%edx
  8010ef:	74 17                	je     801108 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010f1:	83 ec 04             	sub    $0x4,%esp
  8010f4:	ff 75 10             	pushl  0x10(%ebp)
  8010f7:	ff 75 0c             	pushl  0xc(%ebp)
  8010fa:	50                   	push   %eax
  8010fb:	ff d2                	call   *%edx
  8010fd:	89 c2                	mov    %eax,%edx
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	eb 09                	jmp    80110d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801104:	89 c2                	mov    %eax,%edx
  801106:	eb 05                	jmp    80110d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801108:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80110d:	89 d0                	mov    %edx,%eax
  80110f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801112:	c9                   	leave  
  801113:	c3                   	ret    

00801114 <seek>:

int
seek(int fdnum, off_t offset)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80111a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80111d:	50                   	push   %eax
  80111e:	ff 75 08             	pushl  0x8(%ebp)
  801121:	e8 22 fc ff ff       	call   800d48 <fd_lookup>
  801126:	83 c4 08             	add    $0x8,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	78 0e                	js     80113b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80112d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801130:	8b 55 0c             	mov    0xc(%ebp),%edx
  801133:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801136:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80113b:	c9                   	leave  
  80113c:	c3                   	ret    

0080113d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	53                   	push   %ebx
  801141:	83 ec 14             	sub    $0x14,%esp
  801144:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801147:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114a:	50                   	push   %eax
  80114b:	53                   	push   %ebx
  80114c:	e8 f7 fb ff ff       	call   800d48 <fd_lookup>
  801151:	83 c4 08             	add    $0x8,%esp
  801154:	89 c2                	mov    %eax,%edx
  801156:	85 c0                	test   %eax,%eax
  801158:	78 65                	js     8011bf <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115a:	83 ec 08             	sub    $0x8,%esp
  80115d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801160:	50                   	push   %eax
  801161:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801164:	ff 30                	pushl  (%eax)
  801166:	e8 33 fc ff ff       	call   800d9e <dev_lookup>
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	78 44                	js     8011b6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801172:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801175:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801179:	75 21                	jne    80119c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80117b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801180:	8b 40 48             	mov    0x48(%eax),%eax
  801183:	83 ec 04             	sub    $0x4,%esp
  801186:	53                   	push   %ebx
  801187:	50                   	push   %eax
  801188:	68 ec 21 80 00       	push   $0x8021ec
  80118d:	e8 bf ef ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80119a:	eb 23                	jmp    8011bf <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80119c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80119f:	8b 52 18             	mov    0x18(%edx),%edx
  8011a2:	85 d2                	test   %edx,%edx
  8011a4:	74 14                	je     8011ba <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	ff 75 0c             	pushl  0xc(%ebp)
  8011ac:	50                   	push   %eax
  8011ad:	ff d2                	call   *%edx
  8011af:	89 c2                	mov    %eax,%edx
  8011b1:	83 c4 10             	add    $0x10,%esp
  8011b4:	eb 09                	jmp    8011bf <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b6:	89 c2                	mov    %eax,%edx
  8011b8:	eb 05                	jmp    8011bf <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011bf:	89 d0                	mov    %edx,%eax
  8011c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c4:	c9                   	leave  
  8011c5:	c3                   	ret    

008011c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	53                   	push   %ebx
  8011ca:	83 ec 14             	sub    $0x14,%esp
  8011cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d3:	50                   	push   %eax
  8011d4:	ff 75 08             	pushl  0x8(%ebp)
  8011d7:	e8 6c fb ff ff       	call   800d48 <fd_lookup>
  8011dc:	83 c4 08             	add    $0x8,%esp
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	78 58                	js     80123d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011eb:	50                   	push   %eax
  8011ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ef:	ff 30                	pushl  (%eax)
  8011f1:	e8 a8 fb ff ff       	call   800d9e <dev_lookup>
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	78 37                	js     801234 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8011fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801200:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801204:	74 32                	je     801238 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801206:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801209:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801210:	00 00 00 
	stat->st_isdir = 0;
  801213:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80121a:	00 00 00 
	stat->st_dev = dev;
  80121d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801223:	83 ec 08             	sub    $0x8,%esp
  801226:	53                   	push   %ebx
  801227:	ff 75 f0             	pushl  -0x10(%ebp)
  80122a:	ff 50 14             	call   *0x14(%eax)
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	eb 09                	jmp    80123d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801234:	89 c2                	mov    %eax,%edx
  801236:	eb 05                	jmp    80123d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801238:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80123d:	89 d0                	mov    %edx,%eax
  80123f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	56                   	push   %esi
  801248:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	6a 00                	push   $0x0
  80124e:	ff 75 08             	pushl  0x8(%ebp)
  801251:	e8 09 02 00 00       	call   80145f <open>
  801256:	89 c3                	mov    %eax,%ebx
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	85 db                	test   %ebx,%ebx
  80125d:	78 1b                	js     80127a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80125f:	83 ec 08             	sub    $0x8,%esp
  801262:	ff 75 0c             	pushl  0xc(%ebp)
  801265:	53                   	push   %ebx
  801266:	e8 5b ff ff ff       	call   8011c6 <fstat>
  80126b:	89 c6                	mov    %eax,%esi
	close(fd);
  80126d:	89 1c 24             	mov    %ebx,(%esp)
  801270:	e8 fd fb ff ff       	call   800e72 <close>
	return r;
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	89 f0                	mov    %esi,%eax
}
  80127a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80127d:	5b                   	pop    %ebx
  80127e:	5e                   	pop    %esi
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    

00801281 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	89 c6                	mov    %eax,%esi
  801288:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80128a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801291:	75 12                	jne    8012a5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801293:	83 ec 0c             	sub    $0xc,%esp
  801296:	6a 01                	push   $0x1
  801298:	e8 45 08 00 00       	call   801ae2 <ipc_find_env>
  80129d:	a3 00 40 80 00       	mov    %eax,0x804000
  8012a2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012a5:	6a 07                	push   $0x7
  8012a7:	68 00 50 80 00       	push   $0x805000
  8012ac:	56                   	push   %esi
  8012ad:	ff 35 00 40 80 00    	pushl  0x804000
  8012b3:	e8 d6 07 00 00       	call   801a8e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012b8:	83 c4 0c             	add    $0xc,%esp
  8012bb:	6a 00                	push   $0x0
  8012bd:	53                   	push   %ebx
  8012be:	6a 00                	push   $0x0
  8012c0:	e8 60 07 00 00       	call   801a25 <ipc_recv>
}
  8012c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5d                   	pop    %ebp
  8012cb:	c3                   	ret    

008012cc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8012d8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ea:	b8 02 00 00 00       	mov    $0x2,%eax
  8012ef:	e8 8d ff ff ff       	call   801281 <fsipc>
}
  8012f4:	c9                   	leave  
  8012f5:	c3                   	ret    

008012f6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8012fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801302:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801307:	ba 00 00 00 00       	mov    $0x0,%edx
  80130c:	b8 06 00 00 00       	mov    $0x6,%eax
  801311:	e8 6b ff ff ff       	call   801281 <fsipc>
}
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	53                   	push   %ebx
  80131c:	83 ec 04             	sub    $0x4,%esp
  80131f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801322:	8b 45 08             	mov    0x8(%ebp),%eax
  801325:	8b 40 0c             	mov    0xc(%eax),%eax
  801328:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80132d:	ba 00 00 00 00       	mov    $0x0,%edx
  801332:	b8 05 00 00 00       	mov    $0x5,%eax
  801337:	e8 45 ff ff ff       	call   801281 <fsipc>
  80133c:	89 c2                	mov    %eax,%edx
  80133e:	85 d2                	test   %edx,%edx
  801340:	78 2c                	js     80136e <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801342:	83 ec 08             	sub    $0x8,%esp
  801345:	68 00 50 80 00       	push   $0x805000
  80134a:	53                   	push   %ebx
  80134b:	e8 88 f3 ff ff       	call   8006d8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801350:	a1 80 50 80 00       	mov    0x805080,%eax
  801355:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80135b:	a1 84 50 80 00       	mov    0x805084,%eax
  801360:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80136e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	57                   	push   %edi
  801377:	56                   	push   %esi
  801378:	53                   	push   %ebx
  801379:	83 ec 0c             	sub    $0xc,%esp
  80137c:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  80137f:	8b 45 08             	mov    0x8(%ebp),%eax
  801382:	8b 40 0c             	mov    0xc(%eax),%eax
  801385:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80138a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80138d:	eb 3d                	jmp    8013cc <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  80138f:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801395:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80139a:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80139d:	83 ec 04             	sub    $0x4,%esp
  8013a0:	57                   	push   %edi
  8013a1:	53                   	push   %ebx
  8013a2:	68 08 50 80 00       	push   $0x805008
  8013a7:	e8 be f4 ff ff       	call   80086a <memmove>
                fsipcbuf.write.req_n = tmp; 
  8013ac:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8013b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b7:	b8 04 00 00 00       	mov    $0x4,%eax
  8013bc:	e8 c0 fe ff ff       	call   801281 <fsipc>
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	78 0d                	js     8013d5 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8013c8:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8013ca:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8013cc:	85 f6                	test   %esi,%esi
  8013ce:	75 bf                	jne    80138f <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8013d0:	89 d8                	mov    %ebx,%eax
  8013d2:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8013d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d8:	5b                   	pop    %ebx
  8013d9:	5e                   	pop    %esi
  8013da:	5f                   	pop    %edi
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    

008013dd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	56                   	push   %esi
  8013e1:	53                   	push   %ebx
  8013e2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013eb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013f0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fb:	b8 03 00 00 00       	mov    $0x3,%eax
  801400:	e8 7c fe ff ff       	call   801281 <fsipc>
  801405:	89 c3                	mov    %eax,%ebx
  801407:	85 c0                	test   %eax,%eax
  801409:	78 4b                	js     801456 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80140b:	39 c6                	cmp    %eax,%esi
  80140d:	73 16                	jae    801425 <devfile_read+0x48>
  80140f:	68 58 22 80 00       	push   $0x802258
  801414:	68 5f 22 80 00       	push   $0x80225f
  801419:	6a 7c                	push   $0x7c
  80141b:	68 74 22 80 00       	push   $0x802274
  801420:	e8 ba 05 00 00       	call   8019df <_panic>
	assert(r <= PGSIZE);
  801425:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80142a:	7e 16                	jle    801442 <devfile_read+0x65>
  80142c:	68 7f 22 80 00       	push   $0x80227f
  801431:	68 5f 22 80 00       	push   $0x80225f
  801436:	6a 7d                	push   $0x7d
  801438:	68 74 22 80 00       	push   $0x802274
  80143d:	e8 9d 05 00 00       	call   8019df <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801442:	83 ec 04             	sub    $0x4,%esp
  801445:	50                   	push   %eax
  801446:	68 00 50 80 00       	push   $0x805000
  80144b:	ff 75 0c             	pushl  0xc(%ebp)
  80144e:	e8 17 f4 ff ff       	call   80086a <memmove>
	return r;
  801453:	83 c4 10             	add    $0x10,%esp
}
  801456:	89 d8                	mov    %ebx,%eax
  801458:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145b:	5b                   	pop    %ebx
  80145c:	5e                   	pop    %esi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    

0080145f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	53                   	push   %ebx
  801463:	83 ec 20             	sub    $0x20,%esp
  801466:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801469:	53                   	push   %ebx
  80146a:	e8 30 f2 ff ff       	call   80069f <strlen>
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801477:	7f 67                	jg     8014e0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801479:	83 ec 0c             	sub    $0xc,%esp
  80147c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	e8 74 f8 ff ff       	call   800cf9 <fd_alloc>
  801485:	83 c4 10             	add    $0x10,%esp
		return r;
  801488:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 57                	js     8014e5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	53                   	push   %ebx
  801492:	68 00 50 80 00       	push   $0x805000
  801497:	e8 3c f2 ff ff       	call   8006d8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80149c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ac:	e8 d0 fd ff ff       	call   801281 <fsipc>
  8014b1:	89 c3                	mov    %eax,%ebx
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	79 14                	jns    8014ce <open+0x6f>
		fd_close(fd, 0);
  8014ba:	83 ec 08             	sub    $0x8,%esp
  8014bd:	6a 00                	push   $0x0
  8014bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c2:	e8 2a f9 ff ff       	call   800df1 <fd_close>
		return r;
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	89 da                	mov    %ebx,%edx
  8014cc:	eb 17                	jmp    8014e5 <open+0x86>
	}

	return fd2num(fd);
  8014ce:	83 ec 0c             	sub    $0xc,%esp
  8014d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d4:	e8 f9 f7 ff ff       	call   800cd2 <fd2num>
  8014d9:	89 c2                	mov    %eax,%edx
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	eb 05                	jmp    8014e5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014e0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014e5:	89 d0                	mov    %edx,%eax
  8014e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ea:	c9                   	leave  
  8014eb:	c3                   	ret    

008014ec <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f7:	b8 08 00 00 00       	mov    $0x8,%eax
  8014fc:	e8 80 fd ff ff       	call   801281 <fsipc>
}
  801501:	c9                   	leave  
  801502:	c3                   	ret    

00801503 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	56                   	push   %esi
  801507:	53                   	push   %ebx
  801508:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80150b:	83 ec 0c             	sub    $0xc,%esp
  80150e:	ff 75 08             	pushl  0x8(%ebp)
  801511:	e8 cc f7 ff ff       	call   800ce2 <fd2data>
  801516:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	68 8b 22 80 00       	push   $0x80228b
  801520:	53                   	push   %ebx
  801521:	e8 b2 f1 ff ff       	call   8006d8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801526:	8b 56 04             	mov    0x4(%esi),%edx
  801529:	89 d0                	mov    %edx,%eax
  80152b:	2b 06                	sub    (%esi),%eax
  80152d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801533:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80153a:	00 00 00 
	stat->st_dev = &devpipe;
  80153d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801544:	30 80 00 
	return 0;
}
  801547:	b8 00 00 00 00       	mov    $0x0,%eax
  80154c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154f:	5b                   	pop    %ebx
  801550:	5e                   	pop    %esi
  801551:	5d                   	pop    %ebp
  801552:	c3                   	ret    

00801553 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	53                   	push   %ebx
  801557:	83 ec 0c             	sub    $0xc,%esp
  80155a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80155d:	53                   	push   %ebx
  80155e:	6a 00                	push   $0x0
  801560:	e8 01 f6 ff ff       	call   800b66 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801565:	89 1c 24             	mov    %ebx,(%esp)
  801568:	e8 75 f7 ff ff       	call   800ce2 <fd2data>
  80156d:	83 c4 08             	add    $0x8,%esp
  801570:	50                   	push   %eax
  801571:	6a 00                	push   $0x0
  801573:	e8 ee f5 ff ff       	call   800b66 <sys_page_unmap>
}
  801578:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157b:	c9                   	leave  
  80157c:	c3                   	ret    

0080157d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	57                   	push   %edi
  801581:	56                   	push   %esi
  801582:	53                   	push   %ebx
  801583:	83 ec 1c             	sub    $0x1c,%esp
  801586:	89 c6                	mov    %eax,%esi
  801588:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80158b:	a1 04 40 80 00       	mov    0x804004,%eax
  801590:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801593:	83 ec 0c             	sub    $0xc,%esp
  801596:	56                   	push   %esi
  801597:	e8 7e 05 00 00       	call   801b1a <pageref>
  80159c:	89 c7                	mov    %eax,%edi
  80159e:	83 c4 04             	add    $0x4,%esp
  8015a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015a4:	e8 71 05 00 00       	call   801b1a <pageref>
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	39 c7                	cmp    %eax,%edi
  8015ae:	0f 94 c2             	sete   %dl
  8015b1:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8015b4:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  8015ba:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8015bd:	39 fb                	cmp    %edi,%ebx
  8015bf:	74 19                	je     8015da <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8015c1:	84 d2                	test   %dl,%dl
  8015c3:	74 c6                	je     80158b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015c5:	8b 51 58             	mov    0x58(%ecx),%edx
  8015c8:	50                   	push   %eax
  8015c9:	52                   	push   %edx
  8015ca:	53                   	push   %ebx
  8015cb:	68 92 22 80 00       	push   $0x802292
  8015d0:	e8 7c eb ff ff       	call   800151 <cprintf>
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	eb b1                	jmp    80158b <_pipeisclosed+0xe>
	}
}
  8015da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015dd:	5b                   	pop    %ebx
  8015de:	5e                   	pop    %esi
  8015df:	5f                   	pop    %edi
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	57                   	push   %edi
  8015e6:	56                   	push   %esi
  8015e7:	53                   	push   %ebx
  8015e8:	83 ec 28             	sub    $0x28,%esp
  8015eb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015ee:	56                   	push   %esi
  8015ef:	e8 ee f6 ff ff       	call   800ce2 <fd2data>
  8015f4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	bf 00 00 00 00       	mov    $0x0,%edi
  8015fe:	eb 4b                	jmp    80164b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801600:	89 da                	mov    %ebx,%edx
  801602:	89 f0                	mov    %esi,%eax
  801604:	e8 74 ff ff ff       	call   80157d <_pipeisclosed>
  801609:	85 c0                	test   %eax,%eax
  80160b:	75 48                	jne    801655 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80160d:	e8 b0 f4 ff ff       	call   800ac2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801612:	8b 43 04             	mov    0x4(%ebx),%eax
  801615:	8b 0b                	mov    (%ebx),%ecx
  801617:	8d 51 20             	lea    0x20(%ecx),%edx
  80161a:	39 d0                	cmp    %edx,%eax
  80161c:	73 e2                	jae    801600 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80161e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801621:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801625:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801628:	89 c2                	mov    %eax,%edx
  80162a:	c1 fa 1f             	sar    $0x1f,%edx
  80162d:	89 d1                	mov    %edx,%ecx
  80162f:	c1 e9 1b             	shr    $0x1b,%ecx
  801632:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801635:	83 e2 1f             	and    $0x1f,%edx
  801638:	29 ca                	sub    %ecx,%edx
  80163a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80163e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801642:	83 c0 01             	add    $0x1,%eax
  801645:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801648:	83 c7 01             	add    $0x1,%edi
  80164b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80164e:	75 c2                	jne    801612 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801650:	8b 45 10             	mov    0x10(%ebp),%eax
  801653:	eb 05                	jmp    80165a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801655:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80165a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5f                   	pop    %edi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	57                   	push   %edi
  801666:	56                   	push   %esi
  801667:	53                   	push   %ebx
  801668:	83 ec 18             	sub    $0x18,%esp
  80166b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80166e:	57                   	push   %edi
  80166f:	e8 6e f6 ff ff       	call   800ce2 <fd2data>
  801674:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	bb 00 00 00 00       	mov    $0x0,%ebx
  80167e:	eb 3d                	jmp    8016bd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801680:	85 db                	test   %ebx,%ebx
  801682:	74 04                	je     801688 <devpipe_read+0x26>
				return i;
  801684:	89 d8                	mov    %ebx,%eax
  801686:	eb 44                	jmp    8016cc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801688:	89 f2                	mov    %esi,%edx
  80168a:	89 f8                	mov    %edi,%eax
  80168c:	e8 ec fe ff ff       	call   80157d <_pipeisclosed>
  801691:	85 c0                	test   %eax,%eax
  801693:	75 32                	jne    8016c7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801695:	e8 28 f4 ff ff       	call   800ac2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80169a:	8b 06                	mov    (%esi),%eax
  80169c:	3b 46 04             	cmp    0x4(%esi),%eax
  80169f:	74 df                	je     801680 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016a1:	99                   	cltd   
  8016a2:	c1 ea 1b             	shr    $0x1b,%edx
  8016a5:	01 d0                	add    %edx,%eax
  8016a7:	83 e0 1f             	and    $0x1f,%eax
  8016aa:	29 d0                	sub    %edx,%eax
  8016ac:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016b7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ba:	83 c3 01             	add    $0x1,%ebx
  8016bd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016c0:	75 d8                	jne    80169a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8016c5:	eb 05                	jmp    8016cc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016c7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cf:	5b                   	pop    %ebx
  8016d0:	5e                   	pop    %esi
  8016d1:	5f                   	pop    %edi
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    

008016d4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	56                   	push   %esi
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016df:	50                   	push   %eax
  8016e0:	e8 14 f6 ff ff       	call   800cf9 <fd_alloc>
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	0f 88 2c 01 00 00    	js     80181e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016f2:	83 ec 04             	sub    $0x4,%esp
  8016f5:	68 07 04 00 00       	push   $0x407
  8016fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8016fd:	6a 00                	push   $0x0
  8016ff:	e8 dd f3 ff ff       	call   800ae1 <sys_page_alloc>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	89 c2                	mov    %eax,%edx
  801709:	85 c0                	test   %eax,%eax
  80170b:	0f 88 0d 01 00 00    	js     80181e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801711:	83 ec 0c             	sub    $0xc,%esp
  801714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801717:	50                   	push   %eax
  801718:	e8 dc f5 ff ff       	call   800cf9 <fd_alloc>
  80171d:	89 c3                	mov    %eax,%ebx
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	85 c0                	test   %eax,%eax
  801724:	0f 88 e2 00 00 00    	js     80180c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80172a:	83 ec 04             	sub    $0x4,%esp
  80172d:	68 07 04 00 00       	push   $0x407
  801732:	ff 75 f0             	pushl  -0x10(%ebp)
  801735:	6a 00                	push   $0x0
  801737:	e8 a5 f3 ff ff       	call   800ae1 <sys_page_alloc>
  80173c:	89 c3                	mov    %eax,%ebx
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	85 c0                	test   %eax,%eax
  801743:	0f 88 c3 00 00 00    	js     80180c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801749:	83 ec 0c             	sub    $0xc,%esp
  80174c:	ff 75 f4             	pushl  -0xc(%ebp)
  80174f:	e8 8e f5 ff ff       	call   800ce2 <fd2data>
  801754:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801756:	83 c4 0c             	add    $0xc,%esp
  801759:	68 07 04 00 00       	push   $0x407
  80175e:	50                   	push   %eax
  80175f:	6a 00                	push   $0x0
  801761:	e8 7b f3 ff ff       	call   800ae1 <sys_page_alloc>
  801766:	89 c3                	mov    %eax,%ebx
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	85 c0                	test   %eax,%eax
  80176d:	0f 88 89 00 00 00    	js     8017fc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801773:	83 ec 0c             	sub    $0xc,%esp
  801776:	ff 75 f0             	pushl  -0x10(%ebp)
  801779:	e8 64 f5 ff ff       	call   800ce2 <fd2data>
  80177e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801785:	50                   	push   %eax
  801786:	6a 00                	push   $0x0
  801788:	56                   	push   %esi
  801789:	6a 00                	push   $0x0
  80178b:	e8 94 f3 ff ff       	call   800b24 <sys_page_map>
  801790:	89 c3                	mov    %eax,%ebx
  801792:	83 c4 20             	add    $0x20,%esp
  801795:	85 c0                	test   %eax,%eax
  801797:	78 55                	js     8017ee <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801799:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80179f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017ae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017c3:	83 ec 0c             	sub    $0xc,%esp
  8017c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c9:	e8 04 f5 ff ff       	call   800cd2 <fd2num>
  8017ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017d3:	83 c4 04             	add    $0x4,%esp
  8017d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d9:	e8 f4 f4 ff ff       	call   800cd2 <fd2num>
  8017de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ec:	eb 30                	jmp    80181e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	56                   	push   %esi
  8017f2:	6a 00                	push   $0x0
  8017f4:	e8 6d f3 ff ff       	call   800b66 <sys_page_unmap>
  8017f9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	ff 75 f0             	pushl  -0x10(%ebp)
  801802:	6a 00                	push   $0x0
  801804:	e8 5d f3 ff ff       	call   800b66 <sys_page_unmap>
  801809:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80180c:	83 ec 08             	sub    $0x8,%esp
  80180f:	ff 75 f4             	pushl  -0xc(%ebp)
  801812:	6a 00                	push   $0x0
  801814:	e8 4d f3 ff ff       	call   800b66 <sys_page_unmap>
  801819:	83 c4 10             	add    $0x10,%esp
  80181c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80181e:	89 d0                	mov    %edx,%eax
  801820:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801823:	5b                   	pop    %ebx
  801824:	5e                   	pop    %esi
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80182d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801830:	50                   	push   %eax
  801831:	ff 75 08             	pushl  0x8(%ebp)
  801834:	e8 0f f5 ff ff       	call   800d48 <fd_lookup>
  801839:	89 c2                	mov    %eax,%edx
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	85 d2                	test   %edx,%edx
  801840:	78 18                	js     80185a <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801842:	83 ec 0c             	sub    $0xc,%esp
  801845:	ff 75 f4             	pushl  -0xc(%ebp)
  801848:	e8 95 f4 ff ff       	call   800ce2 <fd2data>
	return _pipeisclosed(fd, p);
  80184d:	89 c2                	mov    %eax,%edx
  80184f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801852:	e8 26 fd ff ff       	call   80157d <_pipeisclosed>
  801857:	83 c4 10             	add    $0x10,%esp
}
  80185a:	c9                   	leave  
  80185b:	c3                   	ret    

0080185c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80185f:	b8 00 00 00 00       	mov    $0x0,%eax
  801864:	5d                   	pop    %ebp
  801865:	c3                   	ret    

00801866 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80186c:	68 aa 22 80 00       	push   $0x8022aa
  801871:	ff 75 0c             	pushl  0xc(%ebp)
  801874:	e8 5f ee ff ff       	call   8006d8 <strcpy>
	return 0;
}
  801879:	b8 00 00 00 00       	mov    $0x0,%eax
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	57                   	push   %edi
  801884:	56                   	push   %esi
  801885:	53                   	push   %ebx
  801886:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80188c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801891:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801897:	eb 2d                	jmp    8018c6 <devcons_write+0x46>
		m = n - tot;
  801899:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80189c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80189e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018a1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018a6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018a9:	83 ec 04             	sub    $0x4,%esp
  8018ac:	53                   	push   %ebx
  8018ad:	03 45 0c             	add    0xc(%ebp),%eax
  8018b0:	50                   	push   %eax
  8018b1:	57                   	push   %edi
  8018b2:	e8 b3 ef ff ff       	call   80086a <memmove>
		sys_cputs(buf, m);
  8018b7:	83 c4 08             	add    $0x8,%esp
  8018ba:	53                   	push   %ebx
  8018bb:	57                   	push   %edi
  8018bc:	e8 64 f1 ff ff       	call   800a25 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c1:	01 de                	add    %ebx,%esi
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	89 f0                	mov    %esi,%eax
  8018c8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018cb:	72 cc                	jb     801899 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d0:	5b                   	pop    %ebx
  8018d1:	5e                   	pop    %esi
  8018d2:	5f                   	pop    %edi
  8018d3:	5d                   	pop    %ebp
  8018d4:	c3                   	ret    

008018d5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8018db:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8018e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018e4:	75 07                	jne    8018ed <devcons_read+0x18>
  8018e6:	eb 28                	jmp    801910 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018e8:	e8 d5 f1 ff ff       	call   800ac2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018ed:	e8 51 f1 ff ff       	call   800a43 <sys_cgetc>
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	74 f2                	je     8018e8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 16                	js     801910 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018fa:	83 f8 04             	cmp    $0x4,%eax
  8018fd:	74 0c                	je     80190b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801902:	88 02                	mov    %al,(%edx)
	return 1;
  801904:	b8 01 00 00 00       	mov    $0x1,%eax
  801909:	eb 05                	jmp    801910 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80190b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801910:	c9                   	leave  
  801911:	c3                   	ret    

00801912 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801918:	8b 45 08             	mov    0x8(%ebp),%eax
  80191b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80191e:	6a 01                	push   $0x1
  801920:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801923:	50                   	push   %eax
  801924:	e8 fc f0 ff ff       	call   800a25 <sys_cputs>
  801929:	83 c4 10             	add    $0x10,%esp
}
  80192c:	c9                   	leave  
  80192d:	c3                   	ret    

0080192e <getchar>:

int
getchar(void)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801934:	6a 01                	push   $0x1
  801936:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801939:	50                   	push   %eax
  80193a:	6a 00                	push   $0x0
  80193c:	e8 71 f6 ff ff       	call   800fb2 <read>
	if (r < 0)
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	85 c0                	test   %eax,%eax
  801946:	78 0f                	js     801957 <getchar+0x29>
		return r;
	if (r < 1)
  801948:	85 c0                	test   %eax,%eax
  80194a:	7e 06                	jle    801952 <getchar+0x24>
		return -E_EOF;
	return c;
  80194c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801950:	eb 05                	jmp    801957 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801952:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80195f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801962:	50                   	push   %eax
  801963:	ff 75 08             	pushl  0x8(%ebp)
  801966:	e8 dd f3 ff ff       	call   800d48 <fd_lookup>
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 11                	js     801983 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801972:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801975:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80197b:	39 10                	cmp    %edx,(%eax)
  80197d:	0f 94 c0             	sete   %al
  801980:	0f b6 c0             	movzbl %al,%eax
}
  801983:	c9                   	leave  
  801984:	c3                   	ret    

00801985 <opencons>:

int
opencons(void)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80198b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198e:	50                   	push   %eax
  80198f:	e8 65 f3 ff ff       	call   800cf9 <fd_alloc>
  801994:	83 c4 10             	add    $0x10,%esp
		return r;
  801997:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801999:	85 c0                	test   %eax,%eax
  80199b:	78 3e                	js     8019db <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80199d:	83 ec 04             	sub    $0x4,%esp
  8019a0:	68 07 04 00 00       	push   $0x407
  8019a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a8:	6a 00                	push   $0x0
  8019aa:	e8 32 f1 ff ff       	call   800ae1 <sys_page_alloc>
  8019af:	83 c4 10             	add    $0x10,%esp
		return r;
  8019b2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	78 23                	js     8019db <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019b8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019cd:	83 ec 0c             	sub    $0xc,%esp
  8019d0:	50                   	push   %eax
  8019d1:	e8 fc f2 ff ff       	call   800cd2 <fd2num>
  8019d6:	89 c2                	mov    %eax,%edx
  8019d8:	83 c4 10             	add    $0x10,%esp
}
  8019db:	89 d0                	mov    %edx,%eax
  8019dd:	c9                   	leave  
  8019de:	c3                   	ret    

008019df <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019e4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019e7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019ed:	e8 b1 f0 ff ff       	call   800aa3 <sys_getenvid>
  8019f2:	83 ec 0c             	sub    $0xc,%esp
  8019f5:	ff 75 0c             	pushl  0xc(%ebp)
  8019f8:	ff 75 08             	pushl  0x8(%ebp)
  8019fb:	56                   	push   %esi
  8019fc:	50                   	push   %eax
  8019fd:	68 b8 22 80 00       	push   $0x8022b8
  801a02:	e8 4a e7 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a07:	83 c4 18             	add    $0x18,%esp
  801a0a:	53                   	push   %ebx
  801a0b:	ff 75 10             	pushl  0x10(%ebp)
  801a0e:	e8 ed e6 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801a13:	c7 04 24 a3 22 80 00 	movl   $0x8022a3,(%esp)
  801a1a:	e8 32 e7 ff ff       	call   800151 <cprintf>
  801a1f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a22:	cc                   	int3   
  801a23:	eb fd                	jmp    801a22 <_panic+0x43>

00801a25 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	56                   	push   %esi
  801a29:	53                   	push   %ebx
  801a2a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801a33:	85 c0                	test   %eax,%eax
  801a35:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a3a:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801a3d:	83 ec 0c             	sub    $0xc,%esp
  801a40:	50                   	push   %eax
  801a41:	e8 4b f2 ff ff       	call   800c91 <sys_ipc_recv>
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	79 16                	jns    801a63 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801a4d:	85 f6                	test   %esi,%esi
  801a4f:	74 06                	je     801a57 <ipc_recv+0x32>
  801a51:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801a57:	85 db                	test   %ebx,%ebx
  801a59:	74 2c                	je     801a87 <ipc_recv+0x62>
  801a5b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a61:	eb 24                	jmp    801a87 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a63:	85 f6                	test   %esi,%esi
  801a65:	74 0a                	je     801a71 <ipc_recv+0x4c>
  801a67:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6c:	8b 40 74             	mov    0x74(%eax),%eax
  801a6f:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801a71:	85 db                	test   %ebx,%ebx
  801a73:	74 0a                	je     801a7f <ipc_recv+0x5a>
  801a75:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7a:	8b 40 78             	mov    0x78(%eax),%eax
  801a7d:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801a7f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a84:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8a:	5b                   	pop    %ebx
  801a8b:	5e                   	pop    %esi
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	57                   	push   %edi
  801a92:	56                   	push   %esi
  801a93:	53                   	push   %ebx
  801a94:	83 ec 0c             	sub    $0xc,%esp
  801a97:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a9a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801aa0:	85 db                	test   %ebx,%ebx
  801aa2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801aa7:	0f 44 d8             	cmove  %eax,%ebx
  801aaa:	eb 1c                	jmp    801ac8 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801aac:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aaf:	74 12                	je     801ac3 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801ab1:	50                   	push   %eax
  801ab2:	68 dc 22 80 00       	push   $0x8022dc
  801ab7:	6a 39                	push   $0x39
  801ab9:	68 f7 22 80 00       	push   $0x8022f7
  801abe:	e8 1c ff ff ff       	call   8019df <_panic>
                 sys_yield();
  801ac3:	e8 fa ef ff ff       	call   800ac2 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ac8:	ff 75 14             	pushl  0x14(%ebp)
  801acb:	53                   	push   %ebx
  801acc:	56                   	push   %esi
  801acd:	57                   	push   %edi
  801ace:	e8 9b f1 ff ff       	call   800c6e <sys_ipc_try_send>
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	78 d2                	js     801aac <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801ada:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5f                   	pop    %edi
  801ae0:	5d                   	pop    %ebp
  801ae1:	c3                   	ret    

00801ae2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ae8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aed:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801af0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af6:	8b 52 50             	mov    0x50(%edx),%edx
  801af9:	39 ca                	cmp    %ecx,%edx
  801afb:	75 0d                	jne    801b0a <ipc_find_env+0x28>
			return envs[i].env_id;
  801afd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b00:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801b05:	8b 40 08             	mov    0x8(%eax),%eax
  801b08:	eb 0e                	jmp    801b18 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b0a:	83 c0 01             	add    $0x1,%eax
  801b0d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b12:	75 d9                	jne    801aed <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b14:	66 b8 00 00          	mov    $0x0,%ax
}
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    

00801b1a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b20:	89 d0                	mov    %edx,%eax
  801b22:	c1 e8 16             	shr    $0x16,%eax
  801b25:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b2c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b31:	f6 c1 01             	test   $0x1,%cl
  801b34:	74 1d                	je     801b53 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b36:	c1 ea 0c             	shr    $0xc,%edx
  801b39:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b40:	f6 c2 01             	test   $0x1,%dl
  801b43:	74 0e                	je     801b53 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b45:	c1 ea 0c             	shr    $0xc,%edx
  801b48:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b4f:	ef 
  801b50:	0f b7 c0             	movzwl %ax,%eax
}
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    
  801b55:	66 90                	xchg   %ax,%ax
  801b57:	66 90                	xchg   %ax,%ax
  801b59:	66 90                	xchg   %ax,%ax
  801b5b:	66 90                	xchg   %ax,%ax
  801b5d:	66 90                	xchg   %ax,%ax
  801b5f:	90                   	nop

00801b60 <__udivdi3>:
  801b60:	55                   	push   %ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	83 ec 10             	sub    $0x10,%esp
  801b66:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b6a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b6e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b72:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b76:	85 d2                	test   %edx,%edx
  801b78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b7c:	89 34 24             	mov    %esi,(%esp)
  801b7f:	89 c8                	mov    %ecx,%eax
  801b81:	75 35                	jne    801bb8 <__udivdi3+0x58>
  801b83:	39 f1                	cmp    %esi,%ecx
  801b85:	0f 87 bd 00 00 00    	ja     801c48 <__udivdi3+0xe8>
  801b8b:	85 c9                	test   %ecx,%ecx
  801b8d:	89 cd                	mov    %ecx,%ebp
  801b8f:	75 0b                	jne    801b9c <__udivdi3+0x3c>
  801b91:	b8 01 00 00 00       	mov    $0x1,%eax
  801b96:	31 d2                	xor    %edx,%edx
  801b98:	f7 f1                	div    %ecx
  801b9a:	89 c5                	mov    %eax,%ebp
  801b9c:	89 f0                	mov    %esi,%eax
  801b9e:	31 d2                	xor    %edx,%edx
  801ba0:	f7 f5                	div    %ebp
  801ba2:	89 c6                	mov    %eax,%esi
  801ba4:	89 f8                	mov    %edi,%eax
  801ba6:	f7 f5                	div    %ebp
  801ba8:	89 f2                	mov    %esi,%edx
  801baa:	83 c4 10             	add    $0x10,%esp
  801bad:	5e                   	pop    %esi
  801bae:	5f                   	pop    %edi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    
  801bb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bb8:	3b 14 24             	cmp    (%esp),%edx
  801bbb:	77 7b                	ja     801c38 <__udivdi3+0xd8>
  801bbd:	0f bd f2             	bsr    %edx,%esi
  801bc0:	83 f6 1f             	xor    $0x1f,%esi
  801bc3:	0f 84 97 00 00 00    	je     801c60 <__udivdi3+0x100>
  801bc9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801bce:	89 d7                	mov    %edx,%edi
  801bd0:	89 f1                	mov    %esi,%ecx
  801bd2:	29 f5                	sub    %esi,%ebp
  801bd4:	d3 e7                	shl    %cl,%edi
  801bd6:	89 c2                	mov    %eax,%edx
  801bd8:	89 e9                	mov    %ebp,%ecx
  801bda:	d3 ea                	shr    %cl,%edx
  801bdc:	89 f1                	mov    %esi,%ecx
  801bde:	09 fa                	or     %edi,%edx
  801be0:	8b 3c 24             	mov    (%esp),%edi
  801be3:	d3 e0                	shl    %cl,%eax
  801be5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801be9:	89 e9                	mov    %ebp,%ecx
  801beb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bef:	8b 44 24 04          	mov    0x4(%esp),%eax
  801bf3:	89 fa                	mov    %edi,%edx
  801bf5:	d3 ea                	shr    %cl,%edx
  801bf7:	89 f1                	mov    %esi,%ecx
  801bf9:	d3 e7                	shl    %cl,%edi
  801bfb:	89 e9                	mov    %ebp,%ecx
  801bfd:	d3 e8                	shr    %cl,%eax
  801bff:	09 c7                	or     %eax,%edi
  801c01:	89 f8                	mov    %edi,%eax
  801c03:	f7 74 24 08          	divl   0x8(%esp)
  801c07:	89 d5                	mov    %edx,%ebp
  801c09:	89 c7                	mov    %eax,%edi
  801c0b:	f7 64 24 0c          	mull   0xc(%esp)
  801c0f:	39 d5                	cmp    %edx,%ebp
  801c11:	89 14 24             	mov    %edx,(%esp)
  801c14:	72 11                	jb     801c27 <__udivdi3+0xc7>
  801c16:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c1a:	89 f1                	mov    %esi,%ecx
  801c1c:	d3 e2                	shl    %cl,%edx
  801c1e:	39 c2                	cmp    %eax,%edx
  801c20:	73 5e                	jae    801c80 <__udivdi3+0x120>
  801c22:	3b 2c 24             	cmp    (%esp),%ebp
  801c25:	75 59                	jne    801c80 <__udivdi3+0x120>
  801c27:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c2a:	31 f6                	xor    %esi,%esi
  801c2c:	89 f2                	mov    %esi,%edx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    
  801c35:	8d 76 00             	lea    0x0(%esi),%esi
  801c38:	31 f6                	xor    %esi,%esi
  801c3a:	31 c0                	xor    %eax,%eax
  801c3c:	89 f2                	mov    %esi,%edx
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	5e                   	pop    %esi
  801c42:	5f                   	pop    %edi
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    
  801c45:	8d 76 00             	lea    0x0(%esi),%esi
  801c48:	89 f2                	mov    %esi,%edx
  801c4a:	31 f6                	xor    %esi,%esi
  801c4c:	89 f8                	mov    %edi,%eax
  801c4e:	f7 f1                	div    %ecx
  801c50:	89 f2                	mov    %esi,%edx
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	5e                   	pop    %esi
  801c56:	5f                   	pop    %edi
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    
  801c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c60:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c64:	76 0b                	jbe    801c71 <__udivdi3+0x111>
  801c66:	31 c0                	xor    %eax,%eax
  801c68:	3b 14 24             	cmp    (%esp),%edx
  801c6b:	0f 83 37 ff ff ff    	jae    801ba8 <__udivdi3+0x48>
  801c71:	b8 01 00 00 00       	mov    $0x1,%eax
  801c76:	e9 2d ff ff ff       	jmp    801ba8 <__udivdi3+0x48>
  801c7b:	90                   	nop
  801c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c80:	89 f8                	mov    %edi,%eax
  801c82:	31 f6                	xor    %esi,%esi
  801c84:	e9 1f ff ff ff       	jmp    801ba8 <__udivdi3+0x48>
  801c89:	66 90                	xchg   %ax,%ax
  801c8b:	66 90                	xchg   %ax,%ax
  801c8d:	66 90                	xchg   %ax,%ax
  801c8f:	90                   	nop

00801c90 <__umoddi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	83 ec 20             	sub    $0x20,%esp
  801c96:	8b 44 24 34          	mov    0x34(%esp),%eax
  801c9a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c9e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca2:	89 c6                	mov    %eax,%esi
  801ca4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ca8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801cb0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801cb4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801cb8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	89 c2                	mov    %eax,%edx
  801cc0:	75 1e                	jne    801ce0 <__umoddi3+0x50>
  801cc2:	39 f7                	cmp    %esi,%edi
  801cc4:	76 52                	jbe    801d18 <__umoddi3+0x88>
  801cc6:	89 c8                	mov    %ecx,%eax
  801cc8:	89 f2                	mov    %esi,%edx
  801cca:	f7 f7                	div    %edi
  801ccc:	89 d0                	mov    %edx,%eax
  801cce:	31 d2                	xor    %edx,%edx
  801cd0:	83 c4 20             	add    $0x20,%esp
  801cd3:	5e                   	pop    %esi
  801cd4:	5f                   	pop    %edi
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    
  801cd7:	89 f6                	mov    %esi,%esi
  801cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801ce0:	39 f0                	cmp    %esi,%eax
  801ce2:	77 5c                	ja     801d40 <__umoddi3+0xb0>
  801ce4:	0f bd e8             	bsr    %eax,%ebp
  801ce7:	83 f5 1f             	xor    $0x1f,%ebp
  801cea:	75 64                	jne    801d50 <__umoddi3+0xc0>
  801cec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801cf0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801cf4:	0f 86 f6 00 00 00    	jbe    801df0 <__umoddi3+0x160>
  801cfa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cfe:	0f 82 ec 00 00 00    	jb     801df0 <__umoddi3+0x160>
  801d04:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d08:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d0c:	83 c4 20             	add    $0x20,%esp
  801d0f:	5e                   	pop    %esi
  801d10:	5f                   	pop    %edi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    
  801d13:	90                   	nop
  801d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d18:	85 ff                	test   %edi,%edi
  801d1a:	89 fd                	mov    %edi,%ebp
  801d1c:	75 0b                	jne    801d29 <__umoddi3+0x99>
  801d1e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d23:	31 d2                	xor    %edx,%edx
  801d25:	f7 f7                	div    %edi
  801d27:	89 c5                	mov    %eax,%ebp
  801d29:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d2d:	31 d2                	xor    %edx,%edx
  801d2f:	f7 f5                	div    %ebp
  801d31:	89 c8                	mov    %ecx,%eax
  801d33:	f7 f5                	div    %ebp
  801d35:	eb 95                	jmp    801ccc <__umoddi3+0x3c>
  801d37:	89 f6                	mov    %esi,%esi
  801d39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d40:	89 c8                	mov    %ecx,%eax
  801d42:	89 f2                	mov    %esi,%edx
  801d44:	83 c4 20             	add    $0x20,%esp
  801d47:	5e                   	pop    %esi
  801d48:	5f                   	pop    %edi
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    
  801d4b:	90                   	nop
  801d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d50:	b8 20 00 00 00       	mov    $0x20,%eax
  801d55:	89 e9                	mov    %ebp,%ecx
  801d57:	29 e8                	sub    %ebp,%eax
  801d59:	d3 e2                	shl    %cl,%edx
  801d5b:	89 c7                	mov    %eax,%edi
  801d5d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d61:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d65:	89 f9                	mov    %edi,%ecx
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 c1                	mov    %eax,%ecx
  801d6b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d6f:	09 d1                	or     %edx,%ecx
  801d71:	89 fa                	mov    %edi,%edx
  801d73:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d77:	89 e9                	mov    %ebp,%ecx
  801d79:	d3 e0                	shl    %cl,%eax
  801d7b:	89 f9                	mov    %edi,%ecx
  801d7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	d3 e8                	shr    %cl,%eax
  801d85:	89 e9                	mov    %ebp,%ecx
  801d87:	89 c7                	mov    %eax,%edi
  801d89:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d8d:	d3 e6                	shl    %cl,%esi
  801d8f:	89 d1                	mov    %edx,%ecx
  801d91:	89 fa                	mov    %edi,%edx
  801d93:	d3 e8                	shr    %cl,%eax
  801d95:	89 e9                	mov    %ebp,%ecx
  801d97:	09 f0                	or     %esi,%eax
  801d99:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801d9d:	f7 74 24 10          	divl   0x10(%esp)
  801da1:	d3 e6                	shl    %cl,%esi
  801da3:	89 d1                	mov    %edx,%ecx
  801da5:	f7 64 24 0c          	mull   0xc(%esp)
  801da9:	39 d1                	cmp    %edx,%ecx
  801dab:	89 74 24 14          	mov    %esi,0x14(%esp)
  801daf:	89 d7                	mov    %edx,%edi
  801db1:	89 c6                	mov    %eax,%esi
  801db3:	72 0a                	jb     801dbf <__umoddi3+0x12f>
  801db5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801db9:	73 10                	jae    801dcb <__umoddi3+0x13b>
  801dbb:	39 d1                	cmp    %edx,%ecx
  801dbd:	75 0c                	jne    801dcb <__umoddi3+0x13b>
  801dbf:	89 d7                	mov    %edx,%edi
  801dc1:	89 c6                	mov    %eax,%esi
  801dc3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801dc7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801dcb:	89 ca                	mov    %ecx,%edx
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801dd3:	29 f0                	sub    %esi,%eax
  801dd5:	19 fa                	sbb    %edi,%edx
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801dde:	89 d7                	mov    %edx,%edi
  801de0:	d3 e7                	shl    %cl,%edi
  801de2:	89 e9                	mov    %ebp,%ecx
  801de4:	09 f8                	or     %edi,%eax
  801de6:	d3 ea                	shr    %cl,%edx
  801de8:	83 c4 20             	add    $0x20,%esp
  801deb:	5e                   	pop    %esi
  801dec:	5f                   	pop    %edi
  801ded:	5d                   	pop    %ebp
  801dee:	c3                   	ret    
  801def:	90                   	nop
  801df0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801df4:	29 f9                	sub    %edi,%ecx
  801df6:	19 c6                	sbb    %eax,%esi
  801df8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801dfc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e00:	e9 ff fe ff ff       	jmp    801d04 <__umoddi3+0x74>
