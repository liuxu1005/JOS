
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
  800039:	68 40 23 80 00       	push   $0x802340
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 08 40 80 00       	mov    0x804008,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 4e 23 80 00       	push   $0x80234e
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
  80007b:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8000aa:	e8 96 0e 00 00       	call   800f45 <close_all>
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
  8001b4:	e8 b7 1e 00 00       	call   802070 <__udivdi3>
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
  8001f2:	e8 a9 1f 00 00       	call   8021a0 <__umoddi3>
  8001f7:	83 c4 14             	add    $0x14,%esp
  8001fa:	0f be 80 6f 23 80 00 	movsbl 0x80236f(%eax),%eax
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
  8002f6:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
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
  8003ba:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8003c1:	85 d2                	test   %edx,%edx
  8003c3:	75 18                	jne    8003dd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003c5:	50                   	push   %eax
  8003c6:	68 87 23 80 00       	push   $0x802387
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
  8003de:	68 75 27 80 00       	push   $0x802775
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
  80040b:	ba 80 23 80 00       	mov    $0x802380,%edx
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
	// return value.
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
	// return value.
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
	// return value.
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
  800a8a:	68 9f 26 80 00       	push   $0x80269f
  800a8f:	6a 22                	push   $0x22
  800a91:	68 bc 26 80 00       	push   $0x8026bc
  800a96:	e8 5b 14 00 00       	call   801ef6 <_panic>

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
	// return value.
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
	// return value.
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
	// return value.
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
  800b0b:	68 9f 26 80 00       	push   $0x80269f
  800b10:	6a 22                	push   $0x22
  800b12:	68 bc 26 80 00       	push   $0x8026bc
  800b17:	e8 da 13 00 00       	call   801ef6 <_panic>

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
	// return value.
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
  800b4d:	68 9f 26 80 00       	push   $0x80269f
  800b52:	6a 22                	push   $0x22
  800b54:	68 bc 26 80 00       	push   $0x8026bc
  800b59:	e8 98 13 00 00       	call   801ef6 <_panic>

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
	// return value.
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
  800b8f:	68 9f 26 80 00       	push   $0x80269f
  800b94:	6a 22                	push   $0x22
  800b96:	68 bc 26 80 00       	push   $0x8026bc
  800b9b:	e8 56 13 00 00       	call   801ef6 <_panic>

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
	// return value.
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
  800bd1:	68 9f 26 80 00       	push   $0x80269f
  800bd6:	6a 22                	push   $0x22
  800bd8:	68 bc 26 80 00       	push   $0x8026bc
  800bdd:	e8 14 13 00 00       	call   801ef6 <_panic>
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
	// return value.
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
  800c13:	68 9f 26 80 00       	push   $0x80269f
  800c18:	6a 22                	push   $0x22
  800c1a:	68 bc 26 80 00       	push   $0x8026bc
  800c1f:	e8 d2 12 00 00       	call   801ef6 <_panic>

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
	// return value.
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
  800c55:	68 9f 26 80 00       	push   $0x80269f
  800c5a:	6a 22                	push   $0x22
  800c5c:	68 bc 26 80 00       	push   $0x8026bc
  800c61:	e8 90 12 00 00       	call   801ef6 <_panic>

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
	// return value.
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
	// return value.
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
  800cb9:	68 9f 26 80 00       	push   $0x80269f
  800cbe:	6a 22                	push   $0x22
  800cc0:	68 bc 26 80 00       	push   $0x8026bc
  800cc5:	e8 2c 12 00 00       	call   801ef6 <_panic>

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

00800cd2 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ce2:	89 d1                	mov    %edx,%ecx
  800ce4:	89 d3                	mov    %edx,%ebx
  800ce6:	89 d7                	mov    %edx,%edi
  800ce8:	89 d6                	mov    %edx,%esi
  800cea:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cfa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cff:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 cb                	mov    %ecx,%ebx
  800d09:	89 cf                	mov    %ecx,%edi
  800d0b:	89 ce                	mov    %ecx,%esi
  800d0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7e 17                	jle    800d2a <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 0f                	push   $0xf
  800d19:	68 9f 26 80 00       	push   $0x80269f
  800d1e:	6a 22                	push   $0x22
  800d20:	68 bc 26 80 00       	push   $0x8026bc
  800d25:	e8 cc 11 00 00       	call   801ef6 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_recv>:

int
sys_recv(void *addr)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d40:	b8 10 00 00 00       	mov    $0x10,%eax
  800d45:	8b 55 08             	mov    0x8(%ebp),%edx
  800d48:	89 cb                	mov    %ecx,%ebx
  800d4a:	89 cf                	mov    %ecx,%edi
  800d4c:	89 ce                	mov    %ecx,%esi
  800d4e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	7e 17                	jle    800d6b <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d54:	83 ec 0c             	sub    $0xc,%esp
  800d57:	50                   	push   %eax
  800d58:	6a 10                	push   $0x10
  800d5a:	68 9f 26 80 00       	push   $0x80269f
  800d5f:	6a 22                	push   $0x22
  800d61:	68 bc 26 80 00       	push   $0x8026bc
  800d66:	e8 8b 11 00 00       	call   801ef6 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800d6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
  800d79:	05 00 00 00 30       	add    $0x30000000,%eax
  800d7e:	c1 e8 0c             	shr    $0xc,%eax
}
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d86:	8b 45 08             	mov    0x8(%ebp),%eax
  800d89:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800d8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d93:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800da5:	89 c2                	mov    %eax,%edx
  800da7:	c1 ea 16             	shr    $0x16,%edx
  800daa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db1:	f6 c2 01             	test   $0x1,%dl
  800db4:	74 11                	je     800dc7 <fd_alloc+0x2d>
  800db6:	89 c2                	mov    %eax,%edx
  800db8:	c1 ea 0c             	shr    $0xc,%edx
  800dbb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc2:	f6 c2 01             	test   $0x1,%dl
  800dc5:	75 09                	jne    800dd0 <fd_alloc+0x36>
			*fd_store = fd;
  800dc7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dce:	eb 17                	jmp    800de7 <fd_alloc+0x4d>
  800dd0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dd5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dda:	75 c9                	jne    800da5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ddc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800de2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800def:	83 f8 1f             	cmp    $0x1f,%eax
  800df2:	77 36                	ja     800e2a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df4:	c1 e0 0c             	shl    $0xc,%eax
  800df7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dfc:	89 c2                	mov    %eax,%edx
  800dfe:	c1 ea 16             	shr    $0x16,%edx
  800e01:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e08:	f6 c2 01             	test   $0x1,%dl
  800e0b:	74 24                	je     800e31 <fd_lookup+0x48>
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	c1 ea 0c             	shr    $0xc,%edx
  800e12:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e19:	f6 c2 01             	test   $0x1,%dl
  800e1c:	74 1a                	je     800e38 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e21:	89 02                	mov    %eax,(%edx)
	return 0;
  800e23:	b8 00 00 00 00       	mov    $0x0,%eax
  800e28:	eb 13                	jmp    800e3d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e2f:	eb 0c                	jmp    800e3d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e36:	eb 05                	jmp    800e3d <fd_lookup+0x54>
  800e38:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	83 ec 08             	sub    $0x8,%esp
  800e45:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800e48:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4d:	eb 13                	jmp    800e62 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800e4f:	39 08                	cmp    %ecx,(%eax)
  800e51:	75 0c                	jne    800e5f <dev_lookup+0x20>
			*dev = devtab[i];
  800e53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e56:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e58:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5d:	eb 36                	jmp    800e95 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e5f:	83 c2 01             	add    $0x1,%edx
  800e62:	8b 04 95 48 27 80 00 	mov    0x802748(,%edx,4),%eax
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	75 e2                	jne    800e4f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e6d:	a1 08 40 80 00       	mov    0x804008,%eax
  800e72:	8b 40 48             	mov    0x48(%eax),%eax
  800e75:	83 ec 04             	sub    $0x4,%esp
  800e78:	51                   	push   %ecx
  800e79:	50                   	push   %eax
  800e7a:	68 cc 26 80 00       	push   $0x8026cc
  800e7f:	e8 cd f2 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800e84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e87:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 10             	sub    $0x10,%esp
  800e9f:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea8:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eaf:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb2:	50                   	push   %eax
  800eb3:	e8 31 ff ff ff       	call   800de9 <fd_lookup>
  800eb8:	83 c4 08             	add    $0x8,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	78 05                	js     800ec4 <fd_close+0x2d>
	    || fd != fd2)
  800ebf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ec2:	74 0c                	je     800ed0 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ec4:	84 db                	test   %bl,%bl
  800ec6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ecb:	0f 44 c2             	cmove  %edx,%eax
  800ece:	eb 41                	jmp    800f11 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ed0:	83 ec 08             	sub    $0x8,%esp
  800ed3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ed6:	50                   	push   %eax
  800ed7:	ff 36                	pushl  (%esi)
  800ed9:	e8 61 ff ff ff       	call   800e3f <dev_lookup>
  800ede:	89 c3                	mov    %eax,%ebx
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	78 1a                	js     800f01 <fd_close+0x6a>
		if (dev->dev_close)
  800ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eea:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800eed:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	74 0b                	je     800f01 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ef6:	83 ec 0c             	sub    $0xc,%esp
  800ef9:	56                   	push   %esi
  800efa:	ff d0                	call   *%eax
  800efc:	89 c3                	mov    %eax,%ebx
  800efe:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f01:	83 ec 08             	sub    $0x8,%esp
  800f04:	56                   	push   %esi
  800f05:	6a 00                	push   $0x0
  800f07:	e8 5a fc ff ff       	call   800b66 <sys_page_unmap>
	return r;
  800f0c:	83 c4 10             	add    $0x10,%esp
  800f0f:	89 d8                	mov    %ebx,%eax
}
  800f11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f21:	50                   	push   %eax
  800f22:	ff 75 08             	pushl  0x8(%ebp)
  800f25:	e8 bf fe ff ff       	call   800de9 <fd_lookup>
  800f2a:	89 c2                	mov    %eax,%edx
  800f2c:	83 c4 08             	add    $0x8,%esp
  800f2f:	85 d2                	test   %edx,%edx
  800f31:	78 10                	js     800f43 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800f33:	83 ec 08             	sub    $0x8,%esp
  800f36:	6a 01                	push   $0x1
  800f38:	ff 75 f4             	pushl  -0xc(%ebp)
  800f3b:	e8 57 ff ff ff       	call   800e97 <fd_close>
  800f40:	83 c4 10             	add    $0x10,%esp
}
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    

00800f45 <close_all>:

void
close_all(void)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	53                   	push   %ebx
  800f49:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f4c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f51:	83 ec 0c             	sub    $0xc,%esp
  800f54:	53                   	push   %ebx
  800f55:	e8 be ff ff ff       	call   800f18 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f5a:	83 c3 01             	add    $0x1,%ebx
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	83 fb 20             	cmp    $0x20,%ebx
  800f63:	75 ec                	jne    800f51 <close_all+0xc>
		close(i);
}
  800f65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f68:	c9                   	leave  
  800f69:	c3                   	ret    

00800f6a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	57                   	push   %edi
  800f6e:	56                   	push   %esi
  800f6f:	53                   	push   %ebx
  800f70:	83 ec 2c             	sub    $0x2c,%esp
  800f73:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f79:	50                   	push   %eax
  800f7a:	ff 75 08             	pushl  0x8(%ebp)
  800f7d:	e8 67 fe ff ff       	call   800de9 <fd_lookup>
  800f82:	89 c2                	mov    %eax,%edx
  800f84:	83 c4 08             	add    $0x8,%esp
  800f87:	85 d2                	test   %edx,%edx
  800f89:	0f 88 c1 00 00 00    	js     801050 <dup+0xe6>
		return r;
	close(newfdnum);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	56                   	push   %esi
  800f93:	e8 80 ff ff ff       	call   800f18 <close>

	newfd = INDEX2FD(newfdnum);
  800f98:	89 f3                	mov    %esi,%ebx
  800f9a:	c1 e3 0c             	shl    $0xc,%ebx
  800f9d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fa3:	83 c4 04             	add    $0x4,%esp
  800fa6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa9:	e8 d5 fd ff ff       	call   800d83 <fd2data>
  800fae:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fb0:	89 1c 24             	mov    %ebx,(%esp)
  800fb3:	e8 cb fd ff ff       	call   800d83 <fd2data>
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fbe:	89 f8                	mov    %edi,%eax
  800fc0:	c1 e8 16             	shr    $0x16,%eax
  800fc3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fca:	a8 01                	test   $0x1,%al
  800fcc:	74 37                	je     801005 <dup+0x9b>
  800fce:	89 f8                	mov    %edi,%eax
  800fd0:	c1 e8 0c             	shr    $0xc,%eax
  800fd3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fda:	f6 c2 01             	test   $0x1,%dl
  800fdd:	74 26                	je     801005 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fdf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe6:	83 ec 0c             	sub    $0xc,%esp
  800fe9:	25 07 0e 00 00       	and    $0xe07,%eax
  800fee:	50                   	push   %eax
  800fef:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ff2:	6a 00                	push   $0x0
  800ff4:	57                   	push   %edi
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 28 fb ff ff       	call   800b24 <sys_page_map>
  800ffc:	89 c7                	mov    %eax,%edi
  800ffe:	83 c4 20             	add    $0x20,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	78 2e                	js     801033 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801005:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801008:	89 d0                	mov    %edx,%eax
  80100a:	c1 e8 0c             	shr    $0xc,%eax
  80100d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801014:	83 ec 0c             	sub    $0xc,%esp
  801017:	25 07 0e 00 00       	and    $0xe07,%eax
  80101c:	50                   	push   %eax
  80101d:	53                   	push   %ebx
  80101e:	6a 00                	push   $0x0
  801020:	52                   	push   %edx
  801021:	6a 00                	push   $0x0
  801023:	e8 fc fa ff ff       	call   800b24 <sys_page_map>
  801028:	89 c7                	mov    %eax,%edi
  80102a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80102d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80102f:	85 ff                	test   %edi,%edi
  801031:	79 1d                	jns    801050 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801033:	83 ec 08             	sub    $0x8,%esp
  801036:	53                   	push   %ebx
  801037:	6a 00                	push   $0x0
  801039:	e8 28 fb ff ff       	call   800b66 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80103e:	83 c4 08             	add    $0x8,%esp
  801041:	ff 75 d4             	pushl  -0x2c(%ebp)
  801044:	6a 00                	push   $0x0
  801046:	e8 1b fb ff ff       	call   800b66 <sys_page_unmap>
	return r;
  80104b:	83 c4 10             	add    $0x10,%esp
  80104e:	89 f8                	mov    %edi,%eax
}
  801050:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	53                   	push   %ebx
  80105c:	83 ec 14             	sub    $0x14,%esp
  80105f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801062:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801065:	50                   	push   %eax
  801066:	53                   	push   %ebx
  801067:	e8 7d fd ff ff       	call   800de9 <fd_lookup>
  80106c:	83 c4 08             	add    $0x8,%esp
  80106f:	89 c2                	mov    %eax,%edx
  801071:	85 c0                	test   %eax,%eax
  801073:	78 6d                	js     8010e2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801075:	83 ec 08             	sub    $0x8,%esp
  801078:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107b:	50                   	push   %eax
  80107c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80107f:	ff 30                	pushl  (%eax)
  801081:	e8 b9 fd ff ff       	call   800e3f <dev_lookup>
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	85 c0                	test   %eax,%eax
  80108b:	78 4c                	js     8010d9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80108d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801090:	8b 42 08             	mov    0x8(%edx),%eax
  801093:	83 e0 03             	and    $0x3,%eax
  801096:	83 f8 01             	cmp    $0x1,%eax
  801099:	75 21                	jne    8010bc <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80109b:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a0:	8b 40 48             	mov    0x48(%eax),%eax
  8010a3:	83 ec 04             	sub    $0x4,%esp
  8010a6:	53                   	push   %ebx
  8010a7:	50                   	push   %eax
  8010a8:	68 0d 27 80 00       	push   $0x80270d
  8010ad:	e8 9f f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010ba:	eb 26                	jmp    8010e2 <read+0x8a>
	}
	if (!dev->dev_read)
  8010bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010bf:	8b 40 08             	mov    0x8(%eax),%eax
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	74 17                	je     8010dd <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010c6:	83 ec 04             	sub    $0x4,%esp
  8010c9:	ff 75 10             	pushl  0x10(%ebp)
  8010cc:	ff 75 0c             	pushl  0xc(%ebp)
  8010cf:	52                   	push   %edx
  8010d0:	ff d0                	call   *%eax
  8010d2:	89 c2                	mov    %eax,%edx
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	eb 09                	jmp    8010e2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d9:	89 c2                	mov    %eax,%edx
  8010db:	eb 05                	jmp    8010e2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010e2:	89 d0                	mov    %edx,%eax
  8010e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e7:	c9                   	leave  
  8010e8:	c3                   	ret    

008010e9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	57                   	push   %edi
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 0c             	sub    $0xc,%esp
  8010f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fd:	eb 21                	jmp    801120 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010ff:	83 ec 04             	sub    $0x4,%esp
  801102:	89 f0                	mov    %esi,%eax
  801104:	29 d8                	sub    %ebx,%eax
  801106:	50                   	push   %eax
  801107:	89 d8                	mov    %ebx,%eax
  801109:	03 45 0c             	add    0xc(%ebp),%eax
  80110c:	50                   	push   %eax
  80110d:	57                   	push   %edi
  80110e:	e8 45 ff ff ff       	call   801058 <read>
		if (m < 0)
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	85 c0                	test   %eax,%eax
  801118:	78 0c                	js     801126 <readn+0x3d>
			return m;
		if (m == 0)
  80111a:	85 c0                	test   %eax,%eax
  80111c:	74 06                	je     801124 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80111e:	01 c3                	add    %eax,%ebx
  801120:	39 f3                	cmp    %esi,%ebx
  801122:	72 db                	jb     8010ff <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801124:	89 d8                	mov    %ebx,%eax
}
  801126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801129:	5b                   	pop    %ebx
  80112a:	5e                   	pop    %esi
  80112b:	5f                   	pop    %edi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	53                   	push   %ebx
  801132:	83 ec 14             	sub    $0x14,%esp
  801135:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801138:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113b:	50                   	push   %eax
  80113c:	53                   	push   %ebx
  80113d:	e8 a7 fc ff ff       	call   800de9 <fd_lookup>
  801142:	83 c4 08             	add    $0x8,%esp
  801145:	89 c2                	mov    %eax,%edx
  801147:	85 c0                	test   %eax,%eax
  801149:	78 68                	js     8011b3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114b:	83 ec 08             	sub    $0x8,%esp
  80114e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801155:	ff 30                	pushl  (%eax)
  801157:	e8 e3 fc ff ff       	call   800e3f <dev_lookup>
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	78 47                	js     8011aa <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801163:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801166:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80116a:	75 21                	jne    80118d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80116c:	a1 08 40 80 00       	mov    0x804008,%eax
  801171:	8b 40 48             	mov    0x48(%eax),%eax
  801174:	83 ec 04             	sub    $0x4,%esp
  801177:	53                   	push   %ebx
  801178:	50                   	push   %eax
  801179:	68 29 27 80 00       	push   $0x802729
  80117e:	e8 ce ef ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80118b:	eb 26                	jmp    8011b3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80118d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801190:	8b 52 0c             	mov    0xc(%edx),%edx
  801193:	85 d2                	test   %edx,%edx
  801195:	74 17                	je     8011ae <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801197:	83 ec 04             	sub    $0x4,%esp
  80119a:	ff 75 10             	pushl  0x10(%ebp)
  80119d:	ff 75 0c             	pushl  0xc(%ebp)
  8011a0:	50                   	push   %eax
  8011a1:	ff d2                	call   *%edx
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	eb 09                	jmp    8011b3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011aa:	89 c2                	mov    %eax,%edx
  8011ac:	eb 05                	jmp    8011b3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011b3:	89 d0                	mov    %edx,%eax
  8011b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b8:	c9                   	leave  
  8011b9:	c3                   	ret    

008011ba <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011c3:	50                   	push   %eax
  8011c4:	ff 75 08             	pushl  0x8(%ebp)
  8011c7:	e8 1d fc ff ff       	call   800de9 <fd_lookup>
  8011cc:	83 c4 08             	add    $0x8,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 0e                	js     8011e1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 14             	sub    $0x14,%esp
  8011ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f0:	50                   	push   %eax
  8011f1:	53                   	push   %ebx
  8011f2:	e8 f2 fb ff ff       	call   800de9 <fd_lookup>
  8011f7:	83 c4 08             	add    $0x8,%esp
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	78 65                	js     801265 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801200:	83 ec 08             	sub    $0x8,%esp
  801203:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801206:	50                   	push   %eax
  801207:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120a:	ff 30                	pushl  (%eax)
  80120c:	e8 2e fc ff ff       	call   800e3f <dev_lookup>
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	85 c0                	test   %eax,%eax
  801216:	78 44                	js     80125c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801218:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80121f:	75 21                	jne    801242 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801221:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801226:	8b 40 48             	mov    0x48(%eax),%eax
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	53                   	push   %ebx
  80122d:	50                   	push   %eax
  80122e:	68 ec 26 80 00       	push   $0x8026ec
  801233:	e8 19 ef ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801240:	eb 23                	jmp    801265 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801242:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801245:	8b 52 18             	mov    0x18(%edx),%edx
  801248:	85 d2                	test   %edx,%edx
  80124a:	74 14                	je     801260 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	ff 75 0c             	pushl  0xc(%ebp)
  801252:	50                   	push   %eax
  801253:	ff d2                	call   *%edx
  801255:	89 c2                	mov    %eax,%edx
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	eb 09                	jmp    801265 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	eb 05                	jmp    801265 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801260:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801265:	89 d0                	mov    %edx,%eax
  801267:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126a:	c9                   	leave  
  80126b:	c3                   	ret    

0080126c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	53                   	push   %ebx
  801270:	83 ec 14             	sub    $0x14,%esp
  801273:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801276:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	ff 75 08             	pushl  0x8(%ebp)
  80127d:	e8 67 fb ff ff       	call   800de9 <fd_lookup>
  801282:	83 c4 08             	add    $0x8,%esp
  801285:	89 c2                	mov    %eax,%edx
  801287:	85 c0                	test   %eax,%eax
  801289:	78 58                	js     8012e3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801291:	50                   	push   %eax
  801292:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801295:	ff 30                	pushl  (%eax)
  801297:	e8 a3 fb ff ff       	call   800e3f <dev_lookup>
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	78 37                	js     8012da <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012aa:	74 32                	je     8012de <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ac:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012af:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012b6:	00 00 00 
	stat->st_isdir = 0;
  8012b9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012c0:	00 00 00 
	stat->st_dev = dev;
  8012c3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012c9:	83 ec 08             	sub    $0x8,%esp
  8012cc:	53                   	push   %ebx
  8012cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d0:	ff 50 14             	call   *0x14(%eax)
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	eb 09                	jmp    8012e3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	eb 05                	jmp    8012e3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012e3:	89 d0                	mov    %edx,%eax
  8012e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e8:	c9                   	leave  
  8012e9:	c3                   	ret    

008012ea <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	56                   	push   %esi
  8012ee:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012ef:	83 ec 08             	sub    $0x8,%esp
  8012f2:	6a 00                	push   $0x0
  8012f4:	ff 75 08             	pushl  0x8(%ebp)
  8012f7:	e8 09 02 00 00       	call   801505 <open>
  8012fc:	89 c3                	mov    %eax,%ebx
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	85 db                	test   %ebx,%ebx
  801303:	78 1b                	js     801320 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	ff 75 0c             	pushl  0xc(%ebp)
  80130b:	53                   	push   %ebx
  80130c:	e8 5b ff ff ff       	call   80126c <fstat>
  801311:	89 c6                	mov    %eax,%esi
	close(fd);
  801313:	89 1c 24             	mov    %ebx,(%esp)
  801316:	e8 fd fb ff ff       	call   800f18 <close>
	return r;
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	89 f0                	mov    %esi,%eax
}
  801320:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801323:	5b                   	pop    %ebx
  801324:	5e                   	pop    %esi
  801325:	5d                   	pop    %ebp
  801326:	c3                   	ret    

00801327 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	56                   	push   %esi
  80132b:	53                   	push   %ebx
  80132c:	89 c6                	mov    %eax,%esi
  80132e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801330:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801337:	75 12                	jne    80134b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801339:	83 ec 0c             	sub    $0xc,%esp
  80133c:	6a 01                	push   $0x1
  80133e:	e8 b6 0c 00 00       	call   801ff9 <ipc_find_env>
  801343:	a3 00 40 80 00       	mov    %eax,0x804000
  801348:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80134b:	6a 07                	push   $0x7
  80134d:	68 00 50 80 00       	push   $0x805000
  801352:	56                   	push   %esi
  801353:	ff 35 00 40 80 00    	pushl  0x804000
  801359:	e8 47 0c 00 00       	call   801fa5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80135e:	83 c4 0c             	add    $0xc,%esp
  801361:	6a 00                	push   $0x0
  801363:	53                   	push   %ebx
  801364:	6a 00                	push   $0x0
  801366:	e8 d1 0b 00 00       	call   801f3c <ipc_recv>
}
  80136b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136e:	5b                   	pop    %ebx
  80136f:	5e                   	pop    %esi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
  80137b:	8b 40 0c             	mov    0xc(%eax),%eax
  80137e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801383:	8b 45 0c             	mov    0xc(%ebp),%eax
  801386:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80138b:	ba 00 00 00 00       	mov    $0x0,%edx
  801390:	b8 02 00 00 00       	mov    $0x2,%eax
  801395:	e8 8d ff ff ff       	call   801327 <fsipc>
}
  80139a:	c9                   	leave  
  80139b:	c3                   	ret    

0080139c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8013b7:	e8 6b ff ff ff       	call   801327 <fsipc>
}
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	53                   	push   %ebx
  8013c2:	83 ec 04             	sub    $0x4,%esp
  8013c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ce:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8013dd:	e8 45 ff ff ff       	call   801327 <fsipc>
  8013e2:	89 c2                	mov    %eax,%edx
  8013e4:	85 d2                	test   %edx,%edx
  8013e6:	78 2c                	js     801414 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	68 00 50 80 00       	push   $0x805000
  8013f0:	53                   	push   %ebx
  8013f1:	e8 e2 f2 ff ff       	call   8006d8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013f6:	a1 80 50 80 00       	mov    0x805080,%eax
  8013fb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801401:	a1 84 50 80 00       	mov    0x805084,%eax
  801406:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801414:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801417:	c9                   	leave  
  801418:	c3                   	ret    

00801419 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	57                   	push   %edi
  80141d:	56                   	push   %esi
  80141e:	53                   	push   %ebx
  80141f:	83 ec 0c             	sub    $0xc,%esp
  801422:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801425:	8b 45 08             	mov    0x8(%ebp),%eax
  801428:	8b 40 0c             	mov    0xc(%eax),%eax
  80142b:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801430:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801433:	eb 3d                	jmp    801472 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801435:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80143b:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801440:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801443:	83 ec 04             	sub    $0x4,%esp
  801446:	57                   	push   %edi
  801447:	53                   	push   %ebx
  801448:	68 08 50 80 00       	push   $0x805008
  80144d:	e8 18 f4 ff ff       	call   80086a <memmove>
                fsipcbuf.write.req_n = tmp; 
  801452:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801458:	ba 00 00 00 00       	mov    $0x0,%edx
  80145d:	b8 04 00 00 00       	mov    $0x4,%eax
  801462:	e8 c0 fe ff ff       	call   801327 <fsipc>
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 0d                	js     80147b <devfile_write+0x62>
		        return r;
                n -= tmp;
  80146e:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801470:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801472:	85 f6                	test   %esi,%esi
  801474:	75 bf                	jne    801435 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801476:	89 d8                	mov    %ebx,%eax
  801478:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80147b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5f                   	pop    %edi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    

00801483 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	56                   	push   %esi
  801487:	53                   	push   %ebx
  801488:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80148b:	8b 45 08             	mov    0x8(%ebp),%eax
  80148e:	8b 40 0c             	mov    0xc(%eax),%eax
  801491:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801496:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80149c:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a1:	b8 03 00 00 00       	mov    $0x3,%eax
  8014a6:	e8 7c fe ff ff       	call   801327 <fsipc>
  8014ab:	89 c3                	mov    %eax,%ebx
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	78 4b                	js     8014fc <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014b1:	39 c6                	cmp    %eax,%esi
  8014b3:	73 16                	jae    8014cb <devfile_read+0x48>
  8014b5:	68 5c 27 80 00       	push   $0x80275c
  8014ba:	68 63 27 80 00       	push   $0x802763
  8014bf:	6a 7c                	push   $0x7c
  8014c1:	68 78 27 80 00       	push   $0x802778
  8014c6:	e8 2b 0a 00 00       	call   801ef6 <_panic>
	assert(r <= PGSIZE);
  8014cb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014d0:	7e 16                	jle    8014e8 <devfile_read+0x65>
  8014d2:	68 83 27 80 00       	push   $0x802783
  8014d7:	68 63 27 80 00       	push   $0x802763
  8014dc:	6a 7d                	push   $0x7d
  8014de:	68 78 27 80 00       	push   $0x802778
  8014e3:	e8 0e 0a 00 00       	call   801ef6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014e8:	83 ec 04             	sub    $0x4,%esp
  8014eb:	50                   	push   %eax
  8014ec:	68 00 50 80 00       	push   $0x805000
  8014f1:	ff 75 0c             	pushl  0xc(%ebp)
  8014f4:	e8 71 f3 ff ff       	call   80086a <memmove>
	return r;
  8014f9:	83 c4 10             	add    $0x10,%esp
}
  8014fc:	89 d8                	mov    %ebx,%eax
  8014fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801501:	5b                   	pop    %ebx
  801502:	5e                   	pop    %esi
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	53                   	push   %ebx
  801509:	83 ec 20             	sub    $0x20,%esp
  80150c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80150f:	53                   	push   %ebx
  801510:	e8 8a f1 ff ff       	call   80069f <strlen>
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80151d:	7f 67                	jg     801586 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80151f:	83 ec 0c             	sub    $0xc,%esp
  801522:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801525:	50                   	push   %eax
  801526:	e8 6f f8 ff ff       	call   800d9a <fd_alloc>
  80152b:	83 c4 10             	add    $0x10,%esp
		return r;
  80152e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801530:	85 c0                	test   %eax,%eax
  801532:	78 57                	js     80158b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801534:	83 ec 08             	sub    $0x8,%esp
  801537:	53                   	push   %ebx
  801538:	68 00 50 80 00       	push   $0x805000
  80153d:	e8 96 f1 ff ff       	call   8006d8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801542:	8b 45 0c             	mov    0xc(%ebp),%eax
  801545:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80154a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154d:	b8 01 00 00 00       	mov    $0x1,%eax
  801552:	e8 d0 fd ff ff       	call   801327 <fsipc>
  801557:	89 c3                	mov    %eax,%ebx
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	85 c0                	test   %eax,%eax
  80155e:	79 14                	jns    801574 <open+0x6f>
		fd_close(fd, 0);
  801560:	83 ec 08             	sub    $0x8,%esp
  801563:	6a 00                	push   $0x0
  801565:	ff 75 f4             	pushl  -0xc(%ebp)
  801568:	e8 2a f9 ff ff       	call   800e97 <fd_close>
		return r;
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	89 da                	mov    %ebx,%edx
  801572:	eb 17                	jmp    80158b <open+0x86>
	}

	return fd2num(fd);
  801574:	83 ec 0c             	sub    $0xc,%esp
  801577:	ff 75 f4             	pushl  -0xc(%ebp)
  80157a:	e8 f4 f7 ff ff       	call   800d73 <fd2num>
  80157f:	89 c2                	mov    %eax,%edx
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	eb 05                	jmp    80158b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801586:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80158b:	89 d0                	mov    %edx,%eax
  80158d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801590:	c9                   	leave  
  801591:	c3                   	ret    

00801592 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801598:	ba 00 00 00 00       	mov    $0x0,%edx
  80159d:	b8 08 00 00 00       	mov    $0x8,%eax
  8015a2:	e8 80 fd ff ff       	call   801327 <fsipc>
}
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015af:	68 8f 27 80 00       	push   $0x80278f
  8015b4:	ff 75 0c             	pushl  0xc(%ebp)
  8015b7:	e8 1c f1 ff ff       	call   8006d8 <strcpy>
	return 0;
}
  8015bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	53                   	push   %ebx
  8015c7:	83 ec 10             	sub    $0x10,%esp
  8015ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015cd:	53                   	push   %ebx
  8015ce:	e8 5e 0a 00 00       	call   802031 <pageref>
  8015d3:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015d6:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8015db:	83 f8 01             	cmp    $0x1,%eax
  8015de:	75 10                	jne    8015f0 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	ff 73 0c             	pushl  0xc(%ebx)
  8015e6:	e8 ca 02 00 00       	call   8018b5 <nsipc_close>
  8015eb:	89 c2                	mov    %eax,%edx
  8015ed:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015f0:	89 d0                	mov    %edx,%eax
  8015f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f5:	c9                   	leave  
  8015f6:	c3                   	ret    

008015f7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015fd:	6a 00                	push   $0x0
  8015ff:	ff 75 10             	pushl  0x10(%ebp)
  801602:	ff 75 0c             	pushl  0xc(%ebp)
  801605:	8b 45 08             	mov    0x8(%ebp),%eax
  801608:	ff 70 0c             	pushl  0xc(%eax)
  80160b:	e8 82 03 00 00       	call   801992 <nsipc_send>
}
  801610:	c9                   	leave  
  801611:	c3                   	ret    

00801612 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801618:	6a 00                	push   $0x0
  80161a:	ff 75 10             	pushl  0x10(%ebp)
  80161d:	ff 75 0c             	pushl  0xc(%ebp)
  801620:	8b 45 08             	mov    0x8(%ebp),%eax
  801623:	ff 70 0c             	pushl  0xc(%eax)
  801626:	e8 fb 02 00 00       	call   801926 <nsipc_recv>
}
  80162b:	c9                   	leave  
  80162c:	c3                   	ret    

0080162d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
  801630:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801633:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801636:	52                   	push   %edx
  801637:	50                   	push   %eax
  801638:	e8 ac f7 ff ff       	call   800de9 <fd_lookup>
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	85 c0                	test   %eax,%eax
  801642:	78 17                	js     80165b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801644:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801647:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80164d:	39 08                	cmp    %ecx,(%eax)
  80164f:	75 05                	jne    801656 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801651:	8b 40 0c             	mov    0xc(%eax),%eax
  801654:	eb 05                	jmp    80165b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801656:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80165b:	c9                   	leave  
  80165c:	c3                   	ret    

0080165d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	56                   	push   %esi
  801661:	53                   	push   %ebx
  801662:	83 ec 1c             	sub    $0x1c,%esp
  801665:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801667:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166a:	50                   	push   %eax
  80166b:	e8 2a f7 ff ff       	call   800d9a <fd_alloc>
  801670:	89 c3                	mov    %eax,%ebx
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	85 c0                	test   %eax,%eax
  801677:	78 1b                	js     801694 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801679:	83 ec 04             	sub    $0x4,%esp
  80167c:	68 07 04 00 00       	push   $0x407
  801681:	ff 75 f4             	pushl  -0xc(%ebp)
  801684:	6a 00                	push   $0x0
  801686:	e8 56 f4 ff ff       	call   800ae1 <sys_page_alloc>
  80168b:	89 c3                	mov    %eax,%ebx
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	85 c0                	test   %eax,%eax
  801692:	79 10                	jns    8016a4 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801694:	83 ec 0c             	sub    $0xc,%esp
  801697:	56                   	push   %esi
  801698:	e8 18 02 00 00       	call   8018b5 <nsipc_close>
		return r;
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	89 d8                	mov    %ebx,%eax
  8016a2:	eb 24                	jmp    8016c8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8016a4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8016aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ad:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b2:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8016b9:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8016bc:	83 ec 0c             	sub    $0xc,%esp
  8016bf:	52                   	push   %edx
  8016c0:	e8 ae f6 ff ff       	call   800d73 <fd2num>
  8016c5:	83 c4 10             	add    $0x10,%esp
}
  8016c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016cb:	5b                   	pop    %ebx
  8016cc:	5e                   	pop    %esi
  8016cd:	5d                   	pop    %ebp
  8016ce:	c3                   	ret    

008016cf <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d8:	e8 50 ff ff ff       	call   80162d <fd2sockid>
		return r;
  8016dd:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	78 1f                	js     801702 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016e3:	83 ec 04             	sub    $0x4,%esp
  8016e6:	ff 75 10             	pushl  0x10(%ebp)
  8016e9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ec:	50                   	push   %eax
  8016ed:	e8 1c 01 00 00       	call   80180e <nsipc_accept>
  8016f2:	83 c4 10             	add    $0x10,%esp
		return r;
  8016f5:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	78 07                	js     801702 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016fb:	e8 5d ff ff ff       	call   80165d <alloc_sockfd>
  801700:	89 c1                	mov    %eax,%ecx
}
  801702:	89 c8                	mov    %ecx,%eax
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80170c:	8b 45 08             	mov    0x8(%ebp),%eax
  80170f:	e8 19 ff ff ff       	call   80162d <fd2sockid>
  801714:	89 c2                	mov    %eax,%edx
  801716:	85 d2                	test   %edx,%edx
  801718:	78 12                	js     80172c <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  80171a:	83 ec 04             	sub    $0x4,%esp
  80171d:	ff 75 10             	pushl  0x10(%ebp)
  801720:	ff 75 0c             	pushl  0xc(%ebp)
  801723:	52                   	push   %edx
  801724:	e8 35 01 00 00       	call   80185e <nsipc_bind>
  801729:	83 c4 10             	add    $0x10,%esp
}
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <shutdown>:

int
shutdown(int s, int how)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801734:	8b 45 08             	mov    0x8(%ebp),%eax
  801737:	e8 f1 fe ff ff       	call   80162d <fd2sockid>
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	85 d2                	test   %edx,%edx
  801740:	78 0f                	js     801751 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801742:	83 ec 08             	sub    $0x8,%esp
  801745:	ff 75 0c             	pushl  0xc(%ebp)
  801748:	52                   	push   %edx
  801749:	e8 45 01 00 00       	call   801893 <nsipc_shutdown>
  80174e:	83 c4 10             	add    $0x10,%esp
}
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801759:	8b 45 08             	mov    0x8(%ebp),%eax
  80175c:	e8 cc fe ff ff       	call   80162d <fd2sockid>
  801761:	89 c2                	mov    %eax,%edx
  801763:	85 d2                	test   %edx,%edx
  801765:	78 12                	js     801779 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801767:	83 ec 04             	sub    $0x4,%esp
  80176a:	ff 75 10             	pushl  0x10(%ebp)
  80176d:	ff 75 0c             	pushl  0xc(%ebp)
  801770:	52                   	push   %edx
  801771:	e8 59 01 00 00       	call   8018cf <nsipc_connect>
  801776:	83 c4 10             	add    $0x10,%esp
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <listen>:

int
listen(int s, int backlog)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801781:	8b 45 08             	mov    0x8(%ebp),%eax
  801784:	e8 a4 fe ff ff       	call   80162d <fd2sockid>
  801789:	89 c2                	mov    %eax,%edx
  80178b:	85 d2                	test   %edx,%edx
  80178d:	78 0f                	js     80179e <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  80178f:	83 ec 08             	sub    $0x8,%esp
  801792:	ff 75 0c             	pushl  0xc(%ebp)
  801795:	52                   	push   %edx
  801796:	e8 69 01 00 00       	call   801904 <nsipc_listen>
  80179b:	83 c4 10             	add    $0x10,%esp
}
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017a6:	ff 75 10             	pushl  0x10(%ebp)
  8017a9:	ff 75 0c             	pushl  0xc(%ebp)
  8017ac:	ff 75 08             	pushl  0x8(%ebp)
  8017af:	e8 3c 02 00 00       	call   8019f0 <nsipc_socket>
  8017b4:	89 c2                	mov    %eax,%edx
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	85 d2                	test   %edx,%edx
  8017bb:	78 05                	js     8017c2 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  8017bd:	e8 9b fe ff ff       	call   80165d <alloc_sockfd>
}
  8017c2:	c9                   	leave  
  8017c3:	c3                   	ret    

008017c4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 04             	sub    $0x4,%esp
  8017cb:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017cd:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017d4:	75 12                	jne    8017e8 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017d6:	83 ec 0c             	sub    $0xc,%esp
  8017d9:	6a 02                	push   $0x2
  8017db:	e8 19 08 00 00       	call   801ff9 <ipc_find_env>
  8017e0:	a3 04 40 80 00       	mov    %eax,0x804004
  8017e5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017e8:	6a 07                	push   $0x7
  8017ea:	68 00 60 80 00       	push   $0x806000
  8017ef:	53                   	push   %ebx
  8017f0:	ff 35 04 40 80 00    	pushl  0x804004
  8017f6:	e8 aa 07 00 00       	call   801fa5 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017fb:	83 c4 0c             	add    $0xc,%esp
  8017fe:	6a 00                	push   $0x0
  801800:	6a 00                	push   $0x0
  801802:	6a 00                	push   $0x0
  801804:	e8 33 07 00 00       	call   801f3c <ipc_recv>
}
  801809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	56                   	push   %esi
  801812:	53                   	push   %ebx
  801813:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801816:	8b 45 08             	mov    0x8(%ebp),%eax
  801819:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80181e:	8b 06                	mov    (%esi),%eax
  801820:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801825:	b8 01 00 00 00       	mov    $0x1,%eax
  80182a:	e8 95 ff ff ff       	call   8017c4 <nsipc>
  80182f:	89 c3                	mov    %eax,%ebx
  801831:	85 c0                	test   %eax,%eax
  801833:	78 20                	js     801855 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801835:	83 ec 04             	sub    $0x4,%esp
  801838:	ff 35 10 60 80 00    	pushl  0x806010
  80183e:	68 00 60 80 00       	push   $0x806000
  801843:	ff 75 0c             	pushl  0xc(%ebp)
  801846:	e8 1f f0 ff ff       	call   80086a <memmove>
		*addrlen = ret->ret_addrlen;
  80184b:	a1 10 60 80 00       	mov    0x806010,%eax
  801850:	89 06                	mov    %eax,(%esi)
  801852:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801855:	89 d8                	mov    %ebx,%eax
  801857:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185a:	5b                   	pop    %ebx
  80185b:	5e                   	pop    %esi
  80185c:	5d                   	pop    %ebp
  80185d:	c3                   	ret    

0080185e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	53                   	push   %ebx
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801868:	8b 45 08             	mov    0x8(%ebp),%eax
  80186b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801870:	53                   	push   %ebx
  801871:	ff 75 0c             	pushl  0xc(%ebp)
  801874:	68 04 60 80 00       	push   $0x806004
  801879:	e8 ec ef ff ff       	call   80086a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80187e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801884:	b8 02 00 00 00       	mov    $0x2,%eax
  801889:	e8 36 ff ff ff       	call   8017c4 <nsipc>
}
  80188e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801899:	8b 45 08             	mov    0x8(%ebp),%eax
  80189c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018a9:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ae:	e8 11 ff ff ff       	call   8017c4 <nsipc>
}
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    

008018b5 <nsipc_close>:

int
nsipc_close(int s)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8018c8:	e8 f7 fe ff ff       	call   8017c4 <nsipc>
}
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	53                   	push   %ebx
  8018d3:	83 ec 08             	sub    $0x8,%esp
  8018d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018e1:	53                   	push   %ebx
  8018e2:	ff 75 0c             	pushl  0xc(%ebp)
  8018e5:	68 04 60 80 00       	push   $0x806004
  8018ea:	e8 7b ef ff ff       	call   80086a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018ef:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8018fa:	e8 c5 fe ff ff       	call   8017c4 <nsipc>
}
  8018ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801902:	c9                   	leave  
  801903:	c3                   	ret    

00801904 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80190a:	8b 45 08             	mov    0x8(%ebp),%eax
  80190d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801912:	8b 45 0c             	mov    0xc(%ebp),%eax
  801915:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80191a:	b8 06 00 00 00       	mov    $0x6,%eax
  80191f:	e8 a0 fe ff ff       	call   8017c4 <nsipc>
}
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	56                   	push   %esi
  80192a:	53                   	push   %ebx
  80192b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
  801931:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801936:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80193c:	8b 45 14             	mov    0x14(%ebp),%eax
  80193f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801944:	b8 07 00 00 00       	mov    $0x7,%eax
  801949:	e8 76 fe ff ff       	call   8017c4 <nsipc>
  80194e:	89 c3                	mov    %eax,%ebx
  801950:	85 c0                	test   %eax,%eax
  801952:	78 35                	js     801989 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801954:	39 f0                	cmp    %esi,%eax
  801956:	7f 07                	jg     80195f <nsipc_recv+0x39>
  801958:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80195d:	7e 16                	jle    801975 <nsipc_recv+0x4f>
  80195f:	68 9b 27 80 00       	push   $0x80279b
  801964:	68 63 27 80 00       	push   $0x802763
  801969:	6a 62                	push   $0x62
  80196b:	68 b0 27 80 00       	push   $0x8027b0
  801970:	e8 81 05 00 00       	call   801ef6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801975:	83 ec 04             	sub    $0x4,%esp
  801978:	50                   	push   %eax
  801979:	68 00 60 80 00       	push   $0x806000
  80197e:	ff 75 0c             	pushl  0xc(%ebp)
  801981:	e8 e4 ee ff ff       	call   80086a <memmove>
  801986:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801989:	89 d8                	mov    %ebx,%eax
  80198b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198e:	5b                   	pop    %ebx
  80198f:	5e                   	pop    %esi
  801990:	5d                   	pop    %ebp
  801991:	c3                   	ret    

00801992 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	53                   	push   %ebx
  801996:	83 ec 04             	sub    $0x4,%esp
  801999:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80199c:	8b 45 08             	mov    0x8(%ebp),%eax
  80199f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8019a4:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8019aa:	7e 16                	jle    8019c2 <nsipc_send+0x30>
  8019ac:	68 bc 27 80 00       	push   $0x8027bc
  8019b1:	68 63 27 80 00       	push   $0x802763
  8019b6:	6a 6d                	push   $0x6d
  8019b8:	68 b0 27 80 00       	push   $0x8027b0
  8019bd:	e8 34 05 00 00       	call   801ef6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019c2:	83 ec 04             	sub    $0x4,%esp
  8019c5:	53                   	push   %ebx
  8019c6:	ff 75 0c             	pushl  0xc(%ebp)
  8019c9:	68 0c 60 80 00       	push   $0x80600c
  8019ce:	e8 97 ee ff ff       	call   80086a <memmove>
	nsipcbuf.send.req_size = size;
  8019d3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019dc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e6:	e8 d9 fd ff ff       	call   8017c4 <nsipc>
}
  8019eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ee:	c9                   	leave  
  8019ef:	c3                   	ret    

008019f0 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a01:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a06:	8b 45 10             	mov    0x10(%ebp),%eax
  801a09:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a0e:	b8 09 00 00 00       	mov    $0x9,%eax
  801a13:	e8 ac fd ff ff       	call   8017c4 <nsipc>
}
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    

00801a1a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	56                   	push   %esi
  801a1e:	53                   	push   %ebx
  801a1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a22:	83 ec 0c             	sub    $0xc,%esp
  801a25:	ff 75 08             	pushl  0x8(%ebp)
  801a28:	e8 56 f3 ff ff       	call   800d83 <fd2data>
  801a2d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a2f:	83 c4 08             	add    $0x8,%esp
  801a32:	68 c8 27 80 00       	push   $0x8027c8
  801a37:	53                   	push   %ebx
  801a38:	e8 9b ec ff ff       	call   8006d8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a3d:	8b 56 04             	mov    0x4(%esi),%edx
  801a40:	89 d0                	mov    %edx,%eax
  801a42:	2b 06                	sub    (%esi),%eax
  801a44:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a4a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a51:	00 00 00 
	stat->st_dev = &devpipe;
  801a54:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a5b:	30 80 00 
	return 0;
}
  801a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a66:	5b                   	pop    %ebx
  801a67:	5e                   	pop    %esi
  801a68:	5d                   	pop    %ebp
  801a69:	c3                   	ret    

00801a6a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	53                   	push   %ebx
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a74:	53                   	push   %ebx
  801a75:	6a 00                	push   $0x0
  801a77:	e8 ea f0 ff ff       	call   800b66 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a7c:	89 1c 24             	mov    %ebx,(%esp)
  801a7f:	e8 ff f2 ff ff       	call   800d83 <fd2data>
  801a84:	83 c4 08             	add    $0x8,%esp
  801a87:	50                   	push   %eax
  801a88:	6a 00                	push   $0x0
  801a8a:	e8 d7 f0 ff ff       	call   800b66 <sys_page_unmap>
}
  801a8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a92:	c9                   	leave  
  801a93:	c3                   	ret    

00801a94 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	57                   	push   %edi
  801a98:	56                   	push   %esi
  801a99:	53                   	push   %ebx
  801a9a:	83 ec 1c             	sub    $0x1c,%esp
  801a9d:	89 c6                	mov    %eax,%esi
  801a9f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aa2:	a1 08 40 80 00       	mov    0x804008,%eax
  801aa7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801aaa:	83 ec 0c             	sub    $0xc,%esp
  801aad:	56                   	push   %esi
  801aae:	e8 7e 05 00 00       	call   802031 <pageref>
  801ab3:	89 c7                	mov    %eax,%edi
  801ab5:	83 c4 04             	add    $0x4,%esp
  801ab8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801abb:	e8 71 05 00 00       	call   802031 <pageref>
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	39 c7                	cmp    %eax,%edi
  801ac5:	0f 94 c2             	sete   %dl
  801ac8:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801acb:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801ad1:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801ad4:	39 fb                	cmp    %edi,%ebx
  801ad6:	74 19                	je     801af1 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801ad8:	84 d2                	test   %dl,%dl
  801ada:	74 c6                	je     801aa2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801adc:	8b 51 58             	mov    0x58(%ecx),%edx
  801adf:	50                   	push   %eax
  801ae0:	52                   	push   %edx
  801ae1:	53                   	push   %ebx
  801ae2:	68 cf 27 80 00       	push   $0x8027cf
  801ae7:	e8 65 e6 ff ff       	call   800151 <cprintf>
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	eb b1                	jmp    801aa2 <_pipeisclosed+0xe>
	}
}
  801af1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af4:	5b                   	pop    %ebx
  801af5:	5e                   	pop    %esi
  801af6:	5f                   	pop    %edi
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    

00801af9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	57                   	push   %edi
  801afd:	56                   	push   %esi
  801afe:	53                   	push   %ebx
  801aff:	83 ec 28             	sub    $0x28,%esp
  801b02:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b05:	56                   	push   %esi
  801b06:	e8 78 f2 ff ff       	call   800d83 <fd2data>
  801b0b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	bf 00 00 00 00       	mov    $0x0,%edi
  801b15:	eb 4b                	jmp    801b62 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b17:	89 da                	mov    %ebx,%edx
  801b19:	89 f0                	mov    %esi,%eax
  801b1b:	e8 74 ff ff ff       	call   801a94 <_pipeisclosed>
  801b20:	85 c0                	test   %eax,%eax
  801b22:	75 48                	jne    801b6c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b24:	e8 99 ef ff ff       	call   800ac2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b29:	8b 43 04             	mov    0x4(%ebx),%eax
  801b2c:	8b 0b                	mov    (%ebx),%ecx
  801b2e:	8d 51 20             	lea    0x20(%ecx),%edx
  801b31:	39 d0                	cmp    %edx,%eax
  801b33:	73 e2                	jae    801b17 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b38:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b3c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b3f:	89 c2                	mov    %eax,%edx
  801b41:	c1 fa 1f             	sar    $0x1f,%edx
  801b44:	89 d1                	mov    %edx,%ecx
  801b46:	c1 e9 1b             	shr    $0x1b,%ecx
  801b49:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b4c:	83 e2 1f             	and    $0x1f,%edx
  801b4f:	29 ca                	sub    %ecx,%edx
  801b51:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b55:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b59:	83 c0 01             	add    $0x1,%eax
  801b5c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5f:	83 c7 01             	add    $0x1,%edi
  801b62:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b65:	75 c2                	jne    801b29 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b67:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6a:	eb 05                	jmp    801b71 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b6c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b74:	5b                   	pop    %ebx
  801b75:	5e                   	pop    %esi
  801b76:	5f                   	pop    %edi
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	57                   	push   %edi
  801b7d:	56                   	push   %esi
  801b7e:	53                   	push   %ebx
  801b7f:	83 ec 18             	sub    $0x18,%esp
  801b82:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b85:	57                   	push   %edi
  801b86:	e8 f8 f1 ff ff       	call   800d83 <fd2data>
  801b8b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b95:	eb 3d                	jmp    801bd4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b97:	85 db                	test   %ebx,%ebx
  801b99:	74 04                	je     801b9f <devpipe_read+0x26>
				return i;
  801b9b:	89 d8                	mov    %ebx,%eax
  801b9d:	eb 44                	jmp    801be3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b9f:	89 f2                	mov    %esi,%edx
  801ba1:	89 f8                	mov    %edi,%eax
  801ba3:	e8 ec fe ff ff       	call   801a94 <_pipeisclosed>
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	75 32                	jne    801bde <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bac:	e8 11 ef ff ff       	call   800ac2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bb1:	8b 06                	mov    (%esi),%eax
  801bb3:	3b 46 04             	cmp    0x4(%esi),%eax
  801bb6:	74 df                	je     801b97 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bb8:	99                   	cltd   
  801bb9:	c1 ea 1b             	shr    $0x1b,%edx
  801bbc:	01 d0                	add    %edx,%eax
  801bbe:	83 e0 1f             	and    $0x1f,%eax
  801bc1:	29 d0                	sub    %edx,%eax
  801bc3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bce:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd1:	83 c3 01             	add    $0x1,%ebx
  801bd4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bd7:	75 d8                	jne    801bb1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bd9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bdc:	eb 05                	jmp    801be3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bde:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801be3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be6:	5b                   	pop    %ebx
  801be7:	5e                   	pop    %esi
  801be8:	5f                   	pop    %edi
  801be9:	5d                   	pop    %ebp
  801bea:	c3                   	ret    

00801beb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	56                   	push   %esi
  801bef:	53                   	push   %ebx
  801bf0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bf3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf6:	50                   	push   %eax
  801bf7:	e8 9e f1 ff ff       	call   800d9a <fd_alloc>
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	89 c2                	mov    %eax,%edx
  801c01:	85 c0                	test   %eax,%eax
  801c03:	0f 88 2c 01 00 00    	js     801d35 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c09:	83 ec 04             	sub    $0x4,%esp
  801c0c:	68 07 04 00 00       	push   $0x407
  801c11:	ff 75 f4             	pushl  -0xc(%ebp)
  801c14:	6a 00                	push   $0x0
  801c16:	e8 c6 ee ff ff       	call   800ae1 <sys_page_alloc>
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	89 c2                	mov    %eax,%edx
  801c20:	85 c0                	test   %eax,%eax
  801c22:	0f 88 0d 01 00 00    	js     801d35 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c28:	83 ec 0c             	sub    $0xc,%esp
  801c2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c2e:	50                   	push   %eax
  801c2f:	e8 66 f1 ff ff       	call   800d9a <fd_alloc>
  801c34:	89 c3                	mov    %eax,%ebx
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	0f 88 e2 00 00 00    	js     801d23 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c41:	83 ec 04             	sub    $0x4,%esp
  801c44:	68 07 04 00 00       	push   $0x407
  801c49:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4c:	6a 00                	push   $0x0
  801c4e:	e8 8e ee ff ff       	call   800ae1 <sys_page_alloc>
  801c53:	89 c3                	mov    %eax,%ebx
  801c55:	83 c4 10             	add    $0x10,%esp
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	0f 88 c3 00 00 00    	js     801d23 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c60:	83 ec 0c             	sub    $0xc,%esp
  801c63:	ff 75 f4             	pushl  -0xc(%ebp)
  801c66:	e8 18 f1 ff ff       	call   800d83 <fd2data>
  801c6b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6d:	83 c4 0c             	add    $0xc,%esp
  801c70:	68 07 04 00 00       	push   $0x407
  801c75:	50                   	push   %eax
  801c76:	6a 00                	push   $0x0
  801c78:	e8 64 ee ff ff       	call   800ae1 <sys_page_alloc>
  801c7d:	89 c3                	mov    %eax,%ebx
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	85 c0                	test   %eax,%eax
  801c84:	0f 88 89 00 00 00    	js     801d13 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8a:	83 ec 0c             	sub    $0xc,%esp
  801c8d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c90:	e8 ee f0 ff ff       	call   800d83 <fd2data>
  801c95:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c9c:	50                   	push   %eax
  801c9d:	6a 00                	push   $0x0
  801c9f:	56                   	push   %esi
  801ca0:	6a 00                	push   $0x0
  801ca2:	e8 7d ee ff ff       	call   800b24 <sys_page_map>
  801ca7:	89 c3                	mov    %eax,%ebx
  801ca9:	83 c4 20             	add    $0x20,%esp
  801cac:	85 c0                	test   %eax,%eax
  801cae:	78 55                	js     801d05 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cb0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cc5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cce:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce0:	e8 8e f0 ff ff       	call   800d73 <fd2num>
  801ce5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cea:	83 c4 04             	add    $0x4,%esp
  801ced:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf0:	e8 7e f0 ff ff       	call   800d73 <fd2num>
  801cf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cfb:	83 c4 10             	add    $0x10,%esp
  801cfe:	ba 00 00 00 00       	mov    $0x0,%edx
  801d03:	eb 30                	jmp    801d35 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d05:	83 ec 08             	sub    $0x8,%esp
  801d08:	56                   	push   %esi
  801d09:	6a 00                	push   $0x0
  801d0b:	e8 56 ee ff ff       	call   800b66 <sys_page_unmap>
  801d10:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d13:	83 ec 08             	sub    $0x8,%esp
  801d16:	ff 75 f0             	pushl  -0x10(%ebp)
  801d19:	6a 00                	push   $0x0
  801d1b:	e8 46 ee ff ff       	call   800b66 <sys_page_unmap>
  801d20:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d23:	83 ec 08             	sub    $0x8,%esp
  801d26:	ff 75 f4             	pushl  -0xc(%ebp)
  801d29:	6a 00                	push   $0x0
  801d2b:	e8 36 ee ff ff       	call   800b66 <sys_page_unmap>
  801d30:	83 c4 10             	add    $0x10,%esp
  801d33:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d35:	89 d0                	mov    %edx,%eax
  801d37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3a:	5b                   	pop    %ebx
  801d3b:	5e                   	pop    %esi
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d47:	50                   	push   %eax
  801d48:	ff 75 08             	pushl  0x8(%ebp)
  801d4b:	e8 99 f0 ff ff       	call   800de9 <fd_lookup>
  801d50:	89 c2                	mov    %eax,%edx
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	85 d2                	test   %edx,%edx
  801d57:	78 18                	js     801d71 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d59:	83 ec 0c             	sub    $0xc,%esp
  801d5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5f:	e8 1f f0 ff ff       	call   800d83 <fd2data>
	return _pipeisclosed(fd, p);
  801d64:	89 c2                	mov    %eax,%edx
  801d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d69:	e8 26 fd ff ff       	call   801a94 <_pipeisclosed>
  801d6e:	83 c4 10             	add    $0x10,%esp
}
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d76:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    

00801d7d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d83:	68 e7 27 80 00       	push   $0x8027e7
  801d88:	ff 75 0c             	pushl  0xc(%ebp)
  801d8b:	e8 48 e9 ff ff       	call   8006d8 <strcpy>
	return 0;
}
  801d90:	b8 00 00 00 00       	mov    $0x0,%eax
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    

00801d97 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	57                   	push   %edi
  801d9b:	56                   	push   %esi
  801d9c:	53                   	push   %ebx
  801d9d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801da8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dae:	eb 2d                	jmp    801ddd <devcons_write+0x46>
		m = n - tot;
  801db0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801db5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801db8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dbd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc0:	83 ec 04             	sub    $0x4,%esp
  801dc3:	53                   	push   %ebx
  801dc4:	03 45 0c             	add    0xc(%ebp),%eax
  801dc7:	50                   	push   %eax
  801dc8:	57                   	push   %edi
  801dc9:	e8 9c ea ff ff       	call   80086a <memmove>
		sys_cputs(buf, m);
  801dce:	83 c4 08             	add    $0x8,%esp
  801dd1:	53                   	push   %ebx
  801dd2:	57                   	push   %edi
  801dd3:	e8 4d ec ff ff       	call   800a25 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd8:	01 de                	add    %ebx,%esi
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	89 f0                	mov    %esi,%eax
  801ddf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801de2:	72 cc                	jb     801db0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801de4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5e                   	pop    %esi
  801de9:	5f                   	pop    %edi
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    

00801dec <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801df2:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801df7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dfb:	75 07                	jne    801e04 <devcons_read+0x18>
  801dfd:	eb 28                	jmp    801e27 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dff:	e8 be ec ff ff       	call   800ac2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e04:	e8 3a ec ff ff       	call   800a43 <sys_cgetc>
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	74 f2                	je     801dff <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	78 16                	js     801e27 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e11:	83 f8 04             	cmp    $0x4,%eax
  801e14:	74 0c                	je     801e22 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e16:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e19:	88 02                	mov    %al,(%edx)
	return 1;
  801e1b:	b8 01 00 00 00       	mov    $0x1,%eax
  801e20:	eb 05                	jmp    801e27 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e22:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e27:	c9                   	leave  
  801e28:	c3                   	ret    

00801e29 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e32:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e35:	6a 01                	push   $0x1
  801e37:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e3a:	50                   	push   %eax
  801e3b:	e8 e5 eb ff ff       	call   800a25 <sys_cputs>
  801e40:	83 c4 10             	add    $0x10,%esp
}
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    

00801e45 <getchar>:

int
getchar(void)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e4b:	6a 01                	push   $0x1
  801e4d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e50:	50                   	push   %eax
  801e51:	6a 00                	push   $0x0
  801e53:	e8 00 f2 ff ff       	call   801058 <read>
	if (r < 0)
  801e58:	83 c4 10             	add    $0x10,%esp
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	78 0f                	js     801e6e <getchar+0x29>
		return r;
	if (r < 1)
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	7e 06                	jle    801e69 <getchar+0x24>
		return -E_EOF;
	return c;
  801e63:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e67:	eb 05                	jmp    801e6e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e69:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    

00801e70 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e79:	50                   	push   %eax
  801e7a:	ff 75 08             	pushl  0x8(%ebp)
  801e7d:	e8 67 ef ff ff       	call   800de9 <fd_lookup>
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	85 c0                	test   %eax,%eax
  801e87:	78 11                	js     801e9a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e92:	39 10                	cmp    %edx,(%eax)
  801e94:	0f 94 c0             	sete   %al
  801e97:	0f b6 c0             	movzbl %al,%eax
}
  801e9a:	c9                   	leave  
  801e9b:	c3                   	ret    

00801e9c <opencons>:

int
opencons(void)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea5:	50                   	push   %eax
  801ea6:	e8 ef ee ff ff       	call   800d9a <fd_alloc>
  801eab:	83 c4 10             	add    $0x10,%esp
		return r;
  801eae:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	78 3e                	js     801ef2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb4:	83 ec 04             	sub    $0x4,%esp
  801eb7:	68 07 04 00 00       	push   $0x407
  801ebc:	ff 75 f4             	pushl  -0xc(%ebp)
  801ebf:	6a 00                	push   $0x0
  801ec1:	e8 1b ec ff ff       	call   800ae1 <sys_page_alloc>
  801ec6:	83 c4 10             	add    $0x10,%esp
		return r;
  801ec9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	78 23                	js     801ef2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ecf:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ee4:	83 ec 0c             	sub    $0xc,%esp
  801ee7:	50                   	push   %eax
  801ee8:	e8 86 ee ff ff       	call   800d73 <fd2num>
  801eed:	89 c2                	mov    %eax,%edx
  801eef:	83 c4 10             	add    $0x10,%esp
}
  801ef2:	89 d0                	mov    %edx,%eax
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	56                   	push   %esi
  801efa:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801efb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801efe:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f04:	e8 9a eb ff ff       	call   800aa3 <sys_getenvid>
  801f09:	83 ec 0c             	sub    $0xc,%esp
  801f0c:	ff 75 0c             	pushl  0xc(%ebp)
  801f0f:	ff 75 08             	pushl  0x8(%ebp)
  801f12:	56                   	push   %esi
  801f13:	50                   	push   %eax
  801f14:	68 f4 27 80 00       	push   $0x8027f4
  801f19:	e8 33 e2 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f1e:	83 c4 18             	add    $0x18,%esp
  801f21:	53                   	push   %ebx
  801f22:	ff 75 10             	pushl  0x10(%ebp)
  801f25:	e8 d6 e1 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801f2a:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  801f31:	e8 1b e2 ff ff       	call   800151 <cprintf>
  801f36:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f39:	cc                   	int3   
  801f3a:	eb fd                	jmp    801f39 <_panic+0x43>

00801f3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	56                   	push   %esi
  801f40:	53                   	push   %ebx
  801f41:	8b 75 08             	mov    0x8(%ebp),%esi
  801f44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f51:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f54:	83 ec 0c             	sub    $0xc,%esp
  801f57:	50                   	push   %eax
  801f58:	e8 34 ed ff ff       	call   800c91 <sys_ipc_recv>
  801f5d:	83 c4 10             	add    $0x10,%esp
  801f60:	85 c0                	test   %eax,%eax
  801f62:	79 16                	jns    801f7a <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801f64:	85 f6                	test   %esi,%esi
  801f66:	74 06                	je     801f6e <ipc_recv+0x32>
  801f68:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801f6e:	85 db                	test   %ebx,%ebx
  801f70:	74 2c                	je     801f9e <ipc_recv+0x62>
  801f72:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f78:	eb 24                	jmp    801f9e <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801f7a:	85 f6                	test   %esi,%esi
  801f7c:	74 0a                	je     801f88 <ipc_recv+0x4c>
  801f7e:	a1 08 40 80 00       	mov    0x804008,%eax
  801f83:	8b 40 74             	mov    0x74(%eax),%eax
  801f86:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801f88:	85 db                	test   %ebx,%ebx
  801f8a:	74 0a                	je     801f96 <ipc_recv+0x5a>
  801f8c:	a1 08 40 80 00       	mov    0x804008,%eax
  801f91:	8b 40 78             	mov    0x78(%eax),%eax
  801f94:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801f96:	a1 08 40 80 00       	mov    0x804008,%eax
  801f9b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa1:	5b                   	pop    %ebx
  801fa2:	5e                   	pop    %esi
  801fa3:	5d                   	pop    %ebp
  801fa4:	c3                   	ret    

00801fa5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	57                   	push   %edi
  801fa9:	56                   	push   %esi
  801faa:	53                   	push   %ebx
  801fab:	83 ec 0c             	sub    $0xc,%esp
  801fae:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801fb7:	85 db                	test   %ebx,%ebx
  801fb9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fbe:	0f 44 d8             	cmove  %eax,%ebx
  801fc1:	eb 1c                	jmp    801fdf <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801fc3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fc6:	74 12                	je     801fda <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801fc8:	50                   	push   %eax
  801fc9:	68 18 28 80 00       	push   $0x802818
  801fce:	6a 39                	push   $0x39
  801fd0:	68 33 28 80 00       	push   $0x802833
  801fd5:	e8 1c ff ff ff       	call   801ef6 <_panic>
                 sys_yield();
  801fda:	e8 e3 ea ff ff       	call   800ac2 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801fdf:	ff 75 14             	pushl  0x14(%ebp)
  801fe2:	53                   	push   %ebx
  801fe3:	56                   	push   %esi
  801fe4:	57                   	push   %edi
  801fe5:	e8 84 ec ff ff       	call   800c6e <sys_ipc_try_send>
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	85 c0                	test   %eax,%eax
  801fef:	78 d2                	js     801fc3 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801ff1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff4:	5b                   	pop    %ebx
  801ff5:	5e                   	pop    %esi
  801ff6:	5f                   	pop    %edi
  801ff7:	5d                   	pop    %ebp
  801ff8:	c3                   	ret    

00801ff9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fff:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802004:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802007:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80200d:	8b 52 50             	mov    0x50(%edx),%edx
  802010:	39 ca                	cmp    %ecx,%edx
  802012:	75 0d                	jne    802021 <ipc_find_env+0x28>
			return envs[i].env_id;
  802014:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802017:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80201c:	8b 40 08             	mov    0x8(%eax),%eax
  80201f:	eb 0e                	jmp    80202f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802021:	83 c0 01             	add    $0x1,%eax
  802024:	3d 00 04 00 00       	cmp    $0x400,%eax
  802029:	75 d9                	jne    802004 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80202b:	66 b8 00 00          	mov    $0x0,%ax
}
  80202f:	5d                   	pop    %ebp
  802030:	c3                   	ret    

00802031 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802031:	55                   	push   %ebp
  802032:	89 e5                	mov    %esp,%ebp
  802034:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802037:	89 d0                	mov    %edx,%eax
  802039:	c1 e8 16             	shr    $0x16,%eax
  80203c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802043:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802048:	f6 c1 01             	test   $0x1,%cl
  80204b:	74 1d                	je     80206a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80204d:	c1 ea 0c             	shr    $0xc,%edx
  802050:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802057:	f6 c2 01             	test   $0x1,%dl
  80205a:	74 0e                	je     80206a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80205c:	c1 ea 0c             	shr    $0xc,%edx
  80205f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802066:	ef 
  802067:	0f b7 c0             	movzwl %ax,%eax
}
  80206a:	5d                   	pop    %ebp
  80206b:	c3                   	ret    
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	83 ec 10             	sub    $0x10,%esp
  802076:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80207a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80207e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802082:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802086:	85 d2                	test   %edx,%edx
  802088:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80208c:	89 34 24             	mov    %esi,(%esp)
  80208f:	89 c8                	mov    %ecx,%eax
  802091:	75 35                	jne    8020c8 <__udivdi3+0x58>
  802093:	39 f1                	cmp    %esi,%ecx
  802095:	0f 87 bd 00 00 00    	ja     802158 <__udivdi3+0xe8>
  80209b:	85 c9                	test   %ecx,%ecx
  80209d:	89 cd                	mov    %ecx,%ebp
  80209f:	75 0b                	jne    8020ac <__udivdi3+0x3c>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	31 d2                	xor    %edx,%edx
  8020a8:	f7 f1                	div    %ecx
  8020aa:	89 c5                	mov    %eax,%ebp
  8020ac:	89 f0                	mov    %esi,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	f7 f5                	div    %ebp
  8020b2:	89 c6                	mov    %eax,%esi
  8020b4:	89 f8                	mov    %edi,%eax
  8020b6:	f7 f5                	div    %ebp
  8020b8:	89 f2                	mov    %esi,%edx
  8020ba:	83 c4 10             	add    $0x10,%esp
  8020bd:	5e                   	pop    %esi
  8020be:	5f                   	pop    %edi
  8020bf:	5d                   	pop    %ebp
  8020c0:	c3                   	ret    
  8020c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	3b 14 24             	cmp    (%esp),%edx
  8020cb:	77 7b                	ja     802148 <__udivdi3+0xd8>
  8020cd:	0f bd f2             	bsr    %edx,%esi
  8020d0:	83 f6 1f             	xor    $0x1f,%esi
  8020d3:	0f 84 97 00 00 00    	je     802170 <__udivdi3+0x100>
  8020d9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020de:	89 d7                	mov    %edx,%edi
  8020e0:	89 f1                	mov    %esi,%ecx
  8020e2:	29 f5                	sub    %esi,%ebp
  8020e4:	d3 e7                	shl    %cl,%edi
  8020e6:	89 c2                	mov    %eax,%edx
  8020e8:	89 e9                	mov    %ebp,%ecx
  8020ea:	d3 ea                	shr    %cl,%edx
  8020ec:	89 f1                	mov    %esi,%ecx
  8020ee:	09 fa                	or     %edi,%edx
  8020f0:	8b 3c 24             	mov    (%esp),%edi
  8020f3:	d3 e0                	shl    %cl,%eax
  8020f5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020f9:	89 e9                	mov    %ebp,%ecx
  8020fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ff:	8b 44 24 04          	mov    0x4(%esp),%eax
  802103:	89 fa                	mov    %edi,%edx
  802105:	d3 ea                	shr    %cl,%edx
  802107:	89 f1                	mov    %esi,%ecx
  802109:	d3 e7                	shl    %cl,%edi
  80210b:	89 e9                	mov    %ebp,%ecx
  80210d:	d3 e8                	shr    %cl,%eax
  80210f:	09 c7                	or     %eax,%edi
  802111:	89 f8                	mov    %edi,%eax
  802113:	f7 74 24 08          	divl   0x8(%esp)
  802117:	89 d5                	mov    %edx,%ebp
  802119:	89 c7                	mov    %eax,%edi
  80211b:	f7 64 24 0c          	mull   0xc(%esp)
  80211f:	39 d5                	cmp    %edx,%ebp
  802121:	89 14 24             	mov    %edx,(%esp)
  802124:	72 11                	jb     802137 <__udivdi3+0xc7>
  802126:	8b 54 24 04          	mov    0x4(%esp),%edx
  80212a:	89 f1                	mov    %esi,%ecx
  80212c:	d3 e2                	shl    %cl,%edx
  80212e:	39 c2                	cmp    %eax,%edx
  802130:	73 5e                	jae    802190 <__udivdi3+0x120>
  802132:	3b 2c 24             	cmp    (%esp),%ebp
  802135:	75 59                	jne    802190 <__udivdi3+0x120>
  802137:	8d 47 ff             	lea    -0x1(%edi),%eax
  80213a:	31 f6                	xor    %esi,%esi
  80213c:	89 f2                	mov    %esi,%edx
  80213e:	83 c4 10             	add    $0x10,%esp
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	31 f6                	xor    %esi,%esi
  80214a:	31 c0                	xor    %eax,%eax
  80214c:	89 f2                	mov    %esi,%edx
  80214e:	83 c4 10             	add    $0x10,%esp
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	89 f2                	mov    %esi,%edx
  80215a:	31 f6                	xor    %esi,%esi
  80215c:	89 f8                	mov    %edi,%eax
  80215e:	f7 f1                	div    %ecx
  802160:	89 f2                	mov    %esi,%edx
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802174:	76 0b                	jbe    802181 <__udivdi3+0x111>
  802176:	31 c0                	xor    %eax,%eax
  802178:	3b 14 24             	cmp    (%esp),%edx
  80217b:	0f 83 37 ff ff ff    	jae    8020b8 <__udivdi3+0x48>
  802181:	b8 01 00 00 00       	mov    $0x1,%eax
  802186:	e9 2d ff ff ff       	jmp    8020b8 <__udivdi3+0x48>
  80218b:	90                   	nop
  80218c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802190:	89 f8                	mov    %edi,%eax
  802192:	31 f6                	xor    %esi,%esi
  802194:	e9 1f ff ff ff       	jmp    8020b8 <__udivdi3+0x48>
  802199:	66 90                	xchg   %ax,%ax
  80219b:	66 90                	xchg   %ax,%ax
  80219d:	66 90                	xchg   %ax,%ax
  80219f:	90                   	nop

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	83 ec 20             	sub    $0x20,%esp
  8021a6:	8b 44 24 34          	mov    0x34(%esp),%eax
  8021aa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ae:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b2:	89 c6                	mov    %eax,%esi
  8021b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021b8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021bc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8021c0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021c4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021c8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021cc:	85 c0                	test   %eax,%eax
  8021ce:	89 c2                	mov    %eax,%edx
  8021d0:	75 1e                	jne    8021f0 <__umoddi3+0x50>
  8021d2:	39 f7                	cmp    %esi,%edi
  8021d4:	76 52                	jbe    802228 <__umoddi3+0x88>
  8021d6:	89 c8                	mov    %ecx,%eax
  8021d8:	89 f2                	mov    %esi,%edx
  8021da:	f7 f7                	div    %edi
  8021dc:	89 d0                	mov    %edx,%eax
  8021de:	31 d2                	xor    %edx,%edx
  8021e0:	83 c4 20             	add    $0x20,%esp
  8021e3:	5e                   	pop    %esi
  8021e4:	5f                   	pop    %edi
  8021e5:	5d                   	pop    %ebp
  8021e6:	c3                   	ret    
  8021e7:	89 f6                	mov    %esi,%esi
  8021e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021f0:	39 f0                	cmp    %esi,%eax
  8021f2:	77 5c                	ja     802250 <__umoddi3+0xb0>
  8021f4:	0f bd e8             	bsr    %eax,%ebp
  8021f7:	83 f5 1f             	xor    $0x1f,%ebp
  8021fa:	75 64                	jne    802260 <__umoddi3+0xc0>
  8021fc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802200:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802204:	0f 86 f6 00 00 00    	jbe    802300 <__umoddi3+0x160>
  80220a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80220e:	0f 82 ec 00 00 00    	jb     802300 <__umoddi3+0x160>
  802214:	8b 44 24 14          	mov    0x14(%esp),%eax
  802218:	8b 54 24 18          	mov    0x18(%esp),%edx
  80221c:	83 c4 20             	add    $0x20,%esp
  80221f:	5e                   	pop    %esi
  802220:	5f                   	pop    %edi
  802221:	5d                   	pop    %ebp
  802222:	c3                   	ret    
  802223:	90                   	nop
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	85 ff                	test   %edi,%edi
  80222a:	89 fd                	mov    %edi,%ebp
  80222c:	75 0b                	jne    802239 <__umoddi3+0x99>
  80222e:	b8 01 00 00 00       	mov    $0x1,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f7                	div    %edi
  802237:	89 c5                	mov    %eax,%ebp
  802239:	8b 44 24 10          	mov    0x10(%esp),%eax
  80223d:	31 d2                	xor    %edx,%edx
  80223f:	f7 f5                	div    %ebp
  802241:	89 c8                	mov    %ecx,%eax
  802243:	f7 f5                	div    %ebp
  802245:	eb 95                	jmp    8021dc <__umoddi3+0x3c>
  802247:	89 f6                	mov    %esi,%esi
  802249:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 20             	add    $0x20,%esp
  802257:	5e                   	pop    %esi
  802258:	5f                   	pop    %edi
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    
  80225b:	90                   	nop
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	b8 20 00 00 00       	mov    $0x20,%eax
  802265:	89 e9                	mov    %ebp,%ecx
  802267:	29 e8                	sub    %ebp,%eax
  802269:	d3 e2                	shl    %cl,%edx
  80226b:	89 c7                	mov    %eax,%edi
  80226d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802271:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e8                	shr    %cl,%eax
  802279:	89 c1                	mov    %eax,%ecx
  80227b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80227f:	09 d1                	or     %edx,%ecx
  802281:	89 fa                	mov    %edi,%edx
  802283:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802287:	89 e9                	mov    %ebp,%ecx
  802289:	d3 e0                	shl    %cl,%eax
  80228b:	89 f9                	mov    %edi,%ecx
  80228d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802291:	89 f0                	mov    %esi,%eax
  802293:	d3 e8                	shr    %cl,%eax
  802295:	89 e9                	mov    %ebp,%ecx
  802297:	89 c7                	mov    %eax,%edi
  802299:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80229d:	d3 e6                	shl    %cl,%esi
  80229f:	89 d1                	mov    %edx,%ecx
  8022a1:	89 fa                	mov    %edi,%edx
  8022a3:	d3 e8                	shr    %cl,%eax
  8022a5:	89 e9                	mov    %ebp,%ecx
  8022a7:	09 f0                	or     %esi,%eax
  8022a9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  8022ad:	f7 74 24 10          	divl   0x10(%esp)
  8022b1:	d3 e6                	shl    %cl,%esi
  8022b3:	89 d1                	mov    %edx,%ecx
  8022b5:	f7 64 24 0c          	mull   0xc(%esp)
  8022b9:	39 d1                	cmp    %edx,%ecx
  8022bb:	89 74 24 14          	mov    %esi,0x14(%esp)
  8022bf:	89 d7                	mov    %edx,%edi
  8022c1:	89 c6                	mov    %eax,%esi
  8022c3:	72 0a                	jb     8022cf <__umoddi3+0x12f>
  8022c5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8022c9:	73 10                	jae    8022db <__umoddi3+0x13b>
  8022cb:	39 d1                	cmp    %edx,%ecx
  8022cd:	75 0c                	jne    8022db <__umoddi3+0x13b>
  8022cf:	89 d7                	mov    %edx,%edi
  8022d1:	89 c6                	mov    %eax,%esi
  8022d3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8022d7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8022db:	89 ca                	mov    %ecx,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022e3:	29 f0                	sub    %esi,%eax
  8022e5:	19 fa                	sbb    %edi,%edx
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8022ee:	89 d7                	mov    %edx,%edi
  8022f0:	d3 e7                	shl    %cl,%edi
  8022f2:	89 e9                	mov    %ebp,%ecx
  8022f4:	09 f8                	or     %edi,%eax
  8022f6:	d3 ea                	shr    %cl,%edx
  8022f8:	83 c4 20             	add    $0x20,%esp
  8022fb:	5e                   	pop    %esi
  8022fc:	5f                   	pop    %edi
  8022fd:	5d                   	pop    %ebp
  8022fe:	c3                   	ret    
  8022ff:	90                   	nop
  802300:	8b 74 24 10          	mov    0x10(%esp),%esi
  802304:	29 f9                	sub    %edi,%ecx
  802306:	19 c6                	sbb    %eax,%esi
  802308:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80230c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802310:	e9 ff fe ff ff       	jmp    802214 <__umoddi3+0x74>
