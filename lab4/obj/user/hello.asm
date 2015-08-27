
obj/user/hello:     file format elf32-i386


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
  800039:	68 80 0f 80 00       	push   $0x800f80
  80003e:	e8 06 01 00 00       	call   800149 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 8e 0f 80 00       	push   $0x800f8e
  800054:	e8 f0 00 00 00       	call   800149 <cprintf>
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
  800069:	e8 2d 0a 00 00       	call   800a9b <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000a7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 a9 09 00 00       	call   800a5a <sys_env_destroy>
  8000b1:	83 c4 10             	add    $0x10,%esp
}
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	53                   	push   %ebx
  8000ba:	83 ec 04             	sub    $0x4,%esp
  8000bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c0:	8b 13                	mov    (%ebx),%edx
  8000c2:	8d 42 01             	lea    0x1(%edx),%eax
  8000c5:	89 03                	mov    %eax,(%ebx)
  8000c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d3:	75 1a                	jne    8000ef <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 ff 00 00 00       	push   $0xff
  8000dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 37 09 00 00       	call   800a1d <sys_cputs>
		b->idx = 0;
  8000e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ec:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000ef:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800101:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800108:	00 00 00 
	b.cnt = 0;
  80010b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800112:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800115:	ff 75 0c             	pushl  0xc(%ebp)
  800118:	ff 75 08             	pushl  0x8(%ebp)
  80011b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800121:	50                   	push   %eax
  800122:	68 b6 00 80 00       	push   $0x8000b6
  800127:	e8 4f 01 00 00       	call   80027b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012c:	83 c4 08             	add    $0x8,%esp
  80012f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800135:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	e8 dc 08 00 00       	call   800a1d <sys_cputs>

	return b.cnt;
}
  800141:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800152:	50                   	push   %eax
  800153:	ff 75 08             	pushl  0x8(%ebp)
  800156:	e8 9d ff ff ff       	call   8000f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	57                   	push   %edi
  800161:	56                   	push   %esi
  800162:	53                   	push   %ebx
  800163:	83 ec 1c             	sub    $0x1c,%esp
  800166:	89 c7                	mov    %eax,%edi
  800168:	89 d6                	mov    %edx,%esi
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800170:	89 d1                	mov    %edx,%ecx
  800172:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800175:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800178:	8b 45 10             	mov    0x10(%ebp),%eax
  80017b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800181:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800188:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80018b:	72 05                	jb     800192 <printnum+0x35>
  80018d:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800190:	77 3e                	ja     8001d0 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	ff 75 18             	pushl  0x18(%ebp)
  800198:	83 eb 01             	sub    $0x1,%ebx
  80019b:	53                   	push   %ebx
  80019c:	50                   	push   %eax
  80019d:	83 ec 08             	sub    $0x8,%esp
  8001a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ac:	e8 1f 0b 00 00       	call   800cd0 <__udivdi3>
  8001b1:	83 c4 18             	add    $0x18,%esp
  8001b4:	52                   	push   %edx
  8001b5:	50                   	push   %eax
  8001b6:	89 f2                	mov    %esi,%edx
  8001b8:	89 f8                	mov    %edi,%eax
  8001ba:	e8 9e ff ff ff       	call   80015d <printnum>
  8001bf:	83 c4 20             	add    $0x20,%esp
  8001c2:	eb 13                	jmp    8001d7 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c4:	83 ec 08             	sub    $0x8,%esp
  8001c7:	56                   	push   %esi
  8001c8:	ff 75 18             	pushl  0x18(%ebp)
  8001cb:	ff d7                	call   *%edi
  8001cd:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d0:	83 eb 01             	sub    $0x1,%ebx
  8001d3:	85 db                	test   %ebx,%ebx
  8001d5:	7f ed                	jg     8001c4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d7:	83 ec 08             	sub    $0x8,%esp
  8001da:	56                   	push   %esi
  8001db:	83 ec 04             	sub    $0x4,%esp
  8001de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e4:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e7:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ea:	e8 11 0c 00 00       	call   800e00 <__umoddi3>
  8001ef:	83 c4 14             	add    $0x14,%esp
  8001f2:	0f be 80 af 0f 80 00 	movsbl 0x800faf(%eax),%eax
  8001f9:	50                   	push   %eax
  8001fa:	ff d7                	call   *%edi
  8001fc:	83 c4 10             	add    $0x10,%esp
}
  8001ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800202:	5b                   	pop    %ebx
  800203:	5e                   	pop    %esi
  800204:	5f                   	pop    %edi
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    

00800207 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80020a:	83 fa 01             	cmp    $0x1,%edx
  80020d:	7e 0e                	jle    80021d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80020f:	8b 10                	mov    (%eax),%edx
  800211:	8d 4a 08             	lea    0x8(%edx),%ecx
  800214:	89 08                	mov    %ecx,(%eax)
  800216:	8b 02                	mov    (%edx),%eax
  800218:	8b 52 04             	mov    0x4(%edx),%edx
  80021b:	eb 22                	jmp    80023f <getuint+0x38>
	else if (lflag)
  80021d:	85 d2                	test   %edx,%edx
  80021f:	74 10                	je     800231 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800221:	8b 10                	mov    (%eax),%edx
  800223:	8d 4a 04             	lea    0x4(%edx),%ecx
  800226:	89 08                	mov    %ecx,(%eax)
  800228:	8b 02                	mov    (%edx),%eax
  80022a:	ba 00 00 00 00       	mov    $0x0,%edx
  80022f:	eb 0e                	jmp    80023f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800231:	8b 10                	mov    (%eax),%edx
  800233:	8d 4a 04             	lea    0x4(%edx),%ecx
  800236:	89 08                	mov    %ecx,(%eax)
  800238:	8b 02                	mov    (%edx),%eax
  80023a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023f:	5d                   	pop    %ebp
  800240:	c3                   	ret    

00800241 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800247:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80024b:	8b 10                	mov    (%eax),%edx
  80024d:	3b 50 04             	cmp    0x4(%eax),%edx
  800250:	73 0a                	jae    80025c <sprintputch+0x1b>
		*b->buf++ = ch;
  800252:	8d 4a 01             	lea    0x1(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 45 08             	mov    0x8(%ebp),%eax
  80025a:	88 02                	mov    %al,(%edx)
}
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800264:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800267:	50                   	push   %eax
  800268:	ff 75 10             	pushl  0x10(%ebp)
  80026b:	ff 75 0c             	pushl  0xc(%ebp)
  80026e:	ff 75 08             	pushl  0x8(%ebp)
  800271:	e8 05 00 00 00       	call   80027b <vprintfmt>
	va_end(ap);
  800276:	83 c4 10             	add    $0x10,%esp
}
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 2c             	sub    $0x2c,%esp
  800284:	8b 75 08             	mov    0x8(%ebp),%esi
  800287:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80028a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028d:	eb 12                	jmp    8002a1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80028f:	85 c0                	test   %eax,%eax
  800291:	0f 84 90 03 00 00    	je     800627 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800297:	83 ec 08             	sub    $0x8,%esp
  80029a:	53                   	push   %ebx
  80029b:	50                   	push   %eax
  80029c:	ff d6                	call   *%esi
  80029e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a1:	83 c7 01             	add    $0x1,%edi
  8002a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002a8:	83 f8 25             	cmp    $0x25,%eax
  8002ab:	75 e2                	jne    80028f <vprintfmt+0x14>
  8002ad:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002b8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002bf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cb:	eb 07                	jmp    8002d4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d4:	8d 47 01             	lea    0x1(%edi),%eax
  8002d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002da:	0f b6 07             	movzbl (%edi),%eax
  8002dd:	0f b6 c8             	movzbl %al,%ecx
  8002e0:	83 e8 23             	sub    $0x23,%eax
  8002e3:	3c 55                	cmp    $0x55,%al
  8002e5:	0f 87 21 03 00 00    	ja     80060c <vprintfmt+0x391>
  8002eb:	0f b6 c0             	movzbl %al,%eax
  8002ee:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  8002f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002fc:	eb d6                	jmp    8002d4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800301:	b8 00 00 00 00       	mov    $0x0,%eax
  800306:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800309:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80030c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800310:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800313:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800316:	83 fa 09             	cmp    $0x9,%edx
  800319:	77 39                	ja     800354 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80031b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80031e:	eb e9                	jmp    800309 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800320:	8b 45 14             	mov    0x14(%ebp),%eax
  800323:	8d 48 04             	lea    0x4(%eax),%ecx
  800326:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800329:	8b 00                	mov    (%eax),%eax
  80032b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800331:	eb 27                	jmp    80035a <vprintfmt+0xdf>
  800333:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800336:	85 c0                	test   %eax,%eax
  800338:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033d:	0f 49 c8             	cmovns %eax,%ecx
  800340:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800343:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800346:	eb 8c                	jmp    8002d4 <vprintfmt+0x59>
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80034b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800352:	eb 80                	jmp    8002d4 <vprintfmt+0x59>
  800354:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800357:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80035a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035e:	0f 89 70 ff ff ff    	jns    8002d4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800364:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800367:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800371:	e9 5e ff ff ff       	jmp    8002d4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800376:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80037c:	e9 53 ff ff ff       	jmp    8002d4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800381:	8b 45 14             	mov    0x14(%ebp),%eax
  800384:	8d 50 04             	lea    0x4(%eax),%edx
  800387:	89 55 14             	mov    %edx,0x14(%ebp)
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	53                   	push   %ebx
  80038e:	ff 30                	pushl  (%eax)
  800390:	ff d6                	call   *%esi
			break;
  800392:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800398:	e9 04 ff ff ff       	jmp    8002a1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 50 04             	lea    0x4(%eax),%edx
  8003a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a6:	8b 00                	mov    (%eax),%eax
  8003a8:	99                   	cltd   
  8003a9:	31 d0                	xor    %edx,%eax
  8003ab:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ad:	83 f8 09             	cmp    $0x9,%eax
  8003b0:	7f 0b                	jg     8003bd <vprintfmt+0x142>
  8003b2:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  8003b9:	85 d2                	test   %edx,%edx
  8003bb:	75 18                	jne    8003d5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003bd:	50                   	push   %eax
  8003be:	68 c7 0f 80 00       	push   $0x800fc7
  8003c3:	53                   	push   %ebx
  8003c4:	56                   	push   %esi
  8003c5:	e8 94 fe ff ff       	call   80025e <printfmt>
  8003ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d0:	e9 cc fe ff ff       	jmp    8002a1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d5:	52                   	push   %edx
  8003d6:	68 d0 0f 80 00       	push   $0x800fd0
  8003db:	53                   	push   %ebx
  8003dc:	56                   	push   %esi
  8003dd:	e8 7c fe ff ff       	call   80025e <printfmt>
  8003e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e8:	e9 b4 fe ff ff       	jmp    8002a1 <vprintfmt+0x26>
  8003ed:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f3:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f9:	8d 50 04             	lea    0x4(%eax),%edx
  8003fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ff:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800401:	85 ff                	test   %edi,%edi
  800403:	ba c0 0f 80 00       	mov    $0x800fc0,%edx
  800408:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80040b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80040f:	0f 84 92 00 00 00    	je     8004a7 <vprintfmt+0x22c>
  800415:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800419:	0f 8e 96 00 00 00    	jle    8004b5 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041f:	83 ec 08             	sub    $0x8,%esp
  800422:	51                   	push   %ecx
  800423:	57                   	push   %edi
  800424:	e8 86 02 00 00       	call   8006af <strnlen>
  800429:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80042c:	29 c1                	sub    %eax,%ecx
  80042e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800431:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800434:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80043e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800440:	eb 0f                	jmp    800451 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	53                   	push   %ebx
  800446:	ff 75 e0             	pushl  -0x20(%ebp)
  800449:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	83 ef 01             	sub    $0x1,%edi
  80044e:	83 c4 10             	add    $0x10,%esp
  800451:	85 ff                	test   %edi,%edi
  800453:	7f ed                	jg     800442 <vprintfmt+0x1c7>
  800455:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800458:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80045b:	85 c9                	test   %ecx,%ecx
  80045d:	b8 00 00 00 00       	mov    $0x0,%eax
  800462:	0f 49 c1             	cmovns %ecx,%eax
  800465:	29 c1                	sub    %eax,%ecx
  800467:	89 75 08             	mov    %esi,0x8(%ebp)
  80046a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80046d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800470:	89 cb                	mov    %ecx,%ebx
  800472:	eb 4d                	jmp    8004c1 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800474:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800478:	74 1b                	je     800495 <vprintfmt+0x21a>
  80047a:	0f be c0             	movsbl %al,%eax
  80047d:	83 e8 20             	sub    $0x20,%eax
  800480:	83 f8 5e             	cmp    $0x5e,%eax
  800483:	76 10                	jbe    800495 <vprintfmt+0x21a>
					putch('?', putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 0c             	pushl  0xc(%ebp)
  80048b:	6a 3f                	push   $0x3f
  80048d:	ff 55 08             	call   *0x8(%ebp)
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	eb 0d                	jmp    8004a2 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	52                   	push   %edx
  80049c:	ff 55 08             	call   *0x8(%ebp)
  80049f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a2:	83 eb 01             	sub    $0x1,%ebx
  8004a5:	eb 1a                	jmp    8004c1 <vprintfmt+0x246>
  8004a7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004aa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b3:	eb 0c                	jmp    8004c1 <vprintfmt+0x246>
  8004b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004bb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004be:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c1:	83 c7 01             	add    $0x1,%edi
  8004c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c8:	0f be d0             	movsbl %al,%edx
  8004cb:	85 d2                	test   %edx,%edx
  8004cd:	74 23                	je     8004f2 <vprintfmt+0x277>
  8004cf:	85 f6                	test   %esi,%esi
  8004d1:	78 a1                	js     800474 <vprintfmt+0x1f9>
  8004d3:	83 ee 01             	sub    $0x1,%esi
  8004d6:	79 9c                	jns    800474 <vprintfmt+0x1f9>
  8004d8:	89 df                	mov    %ebx,%edi
  8004da:	8b 75 08             	mov    0x8(%ebp),%esi
  8004dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e0:	eb 18                	jmp    8004fa <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	53                   	push   %ebx
  8004e6:	6a 20                	push   $0x20
  8004e8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ea:	83 ef 01             	sub    $0x1,%edi
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	eb 08                	jmp    8004fa <vprintfmt+0x27f>
  8004f2:	89 df                	mov    %ebx,%edi
  8004f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fa:	85 ff                	test   %edi,%edi
  8004fc:	7f e4                	jg     8004e2 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800501:	e9 9b fd ff ff       	jmp    8002a1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800506:	83 fa 01             	cmp    $0x1,%edx
  800509:	7e 16                	jle    800521 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 50 08             	lea    0x8(%eax),%edx
  800511:	89 55 14             	mov    %edx,0x14(%ebp)
  800514:	8b 50 04             	mov    0x4(%eax),%edx
  800517:	8b 00                	mov    (%eax),%eax
  800519:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051f:	eb 32                	jmp    800553 <vprintfmt+0x2d8>
	else if (lflag)
  800521:	85 d2                	test   %edx,%edx
  800523:	74 18                	je     80053d <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 50 04             	lea    0x4(%eax),%edx
  80052b:	89 55 14             	mov    %edx,0x14(%ebp)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800533:	89 c1                	mov    %eax,%ecx
  800535:	c1 f9 1f             	sar    $0x1f,%ecx
  800538:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80053b:	eb 16                	jmp    800553 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8d 50 04             	lea    0x4(%eax),%edx
  800543:	89 55 14             	mov    %edx,0x14(%ebp)
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054b:	89 c1                	mov    %eax,%ecx
  80054d:	c1 f9 1f             	sar    $0x1f,%ecx
  800550:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800553:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800556:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800559:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800562:	79 74                	jns    8005d8 <vprintfmt+0x35d>
				putch('-', putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	6a 2d                	push   $0x2d
  80056a:	ff d6                	call   *%esi
				num = -(long long) num;
  80056c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80056f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800572:	f7 d8                	neg    %eax
  800574:	83 d2 00             	adc    $0x0,%edx
  800577:	f7 da                	neg    %edx
  800579:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80057c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800581:	eb 55                	jmp    8005d8 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800583:	8d 45 14             	lea    0x14(%ebp),%eax
  800586:	e8 7c fc ff ff       	call   800207 <getuint>
			base = 10;
  80058b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800590:	eb 46                	jmp    8005d8 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800592:	8d 45 14             	lea    0x14(%ebp),%eax
  800595:	e8 6d fc ff ff       	call   800207 <getuint>
                        base = 8;
  80059a:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80059f:	eb 37                	jmp    8005d8 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	53                   	push   %ebx
  8005a5:	6a 30                	push   $0x30
  8005a7:	ff d6                	call   *%esi
			putch('x', putdat);
  8005a9:	83 c4 08             	add    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	6a 78                	push   $0x78
  8005af:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 04             	lea    0x4(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005c9:	eb 0d                	jmp    8005d8 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	e8 34 fc ff ff       	call   800207 <getuint>
			base = 16;
  8005d3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005df:	57                   	push   %edi
  8005e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e3:	51                   	push   %ecx
  8005e4:	52                   	push   %edx
  8005e5:	50                   	push   %eax
  8005e6:	89 da                	mov    %ebx,%edx
  8005e8:	89 f0                	mov    %esi,%eax
  8005ea:	e8 6e fb ff ff       	call   80015d <printnum>
			break;
  8005ef:	83 c4 20             	add    $0x20,%esp
  8005f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f5:	e9 a7 fc ff ff       	jmp    8002a1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	51                   	push   %ecx
  8005ff:	ff d6                	call   *%esi
			break;
  800601:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800607:	e9 95 fc ff ff       	jmp    8002a1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	6a 25                	push   $0x25
  800612:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	eb 03                	jmp    80061c <vprintfmt+0x3a1>
  800619:	83 ef 01             	sub    $0x1,%edi
  80061c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800620:	75 f7                	jne    800619 <vprintfmt+0x39e>
  800622:	e9 7a fc ff ff       	jmp    8002a1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800627:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062a:	5b                   	pop    %ebx
  80062b:	5e                   	pop    %esi
  80062c:	5f                   	pop    %edi
  80062d:	5d                   	pop    %ebp
  80062e:	c3                   	ret    

0080062f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	83 ec 18             	sub    $0x18,%esp
  800635:	8b 45 08             	mov    0x8(%ebp),%eax
  800638:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80063b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80063e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800642:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800645:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80064c:	85 c0                	test   %eax,%eax
  80064e:	74 26                	je     800676 <vsnprintf+0x47>
  800650:	85 d2                	test   %edx,%edx
  800652:	7e 22                	jle    800676 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800654:	ff 75 14             	pushl  0x14(%ebp)
  800657:	ff 75 10             	pushl  0x10(%ebp)
  80065a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80065d:	50                   	push   %eax
  80065e:	68 41 02 80 00       	push   $0x800241
  800663:	e8 13 fc ff ff       	call   80027b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800668:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80066b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80066e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	eb 05                	jmp    80067b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800676:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80067b:	c9                   	leave  
  80067c:	c3                   	ret    

0080067d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800686:	50                   	push   %eax
  800687:	ff 75 10             	pushl  0x10(%ebp)
  80068a:	ff 75 0c             	pushl  0xc(%ebp)
  80068d:	ff 75 08             	pushl  0x8(%ebp)
  800690:	e8 9a ff ff ff       	call   80062f <vsnprintf>
	va_end(ap);

	return rc;
}
  800695:	c9                   	leave  
  800696:	c3                   	ret    

00800697 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80069d:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a2:	eb 03                	jmp    8006a7 <strlen+0x10>
		n++;
  8006a4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ab:	75 f7                	jne    8006a4 <strlen+0xd>
		n++;
	return n;
}
  8006ad:	5d                   	pop    %ebp
  8006ae:	c3                   	ret    

008006af <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bd:	eb 03                	jmp    8006c2 <strnlen+0x13>
		n++;
  8006bf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c2:	39 c2                	cmp    %eax,%edx
  8006c4:	74 08                	je     8006ce <strnlen+0x1f>
  8006c6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006ca:	75 f3                	jne    8006bf <strnlen+0x10>
  8006cc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006ce:	5d                   	pop    %ebp
  8006cf:	c3                   	ret    

008006d0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	53                   	push   %ebx
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006da:	89 c2                	mov    %eax,%edx
  8006dc:	83 c2 01             	add    $0x1,%edx
  8006df:	83 c1 01             	add    $0x1,%ecx
  8006e2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006e9:	84 db                	test   %bl,%bl
  8006eb:	75 ef                	jne    8006dc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006ed:	5b                   	pop    %ebx
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	53                   	push   %ebx
  8006f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006f7:	53                   	push   %ebx
  8006f8:	e8 9a ff ff ff       	call   800697 <strlen>
  8006fd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800700:	ff 75 0c             	pushl  0xc(%ebp)
  800703:	01 d8                	add    %ebx,%eax
  800705:	50                   	push   %eax
  800706:	e8 c5 ff ff ff       	call   8006d0 <strcpy>
	return dst;
}
  80070b:	89 d8                	mov    %ebx,%eax
  80070d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800710:	c9                   	leave  
  800711:	c3                   	ret    

00800712 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	56                   	push   %esi
  800716:	53                   	push   %ebx
  800717:	8b 75 08             	mov    0x8(%ebp),%esi
  80071a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071d:	89 f3                	mov    %esi,%ebx
  80071f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800722:	89 f2                	mov    %esi,%edx
  800724:	eb 0f                	jmp    800735 <strncpy+0x23>
		*dst++ = *src;
  800726:	83 c2 01             	add    $0x1,%edx
  800729:	0f b6 01             	movzbl (%ecx),%eax
  80072c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80072f:	80 39 01             	cmpb   $0x1,(%ecx)
  800732:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800735:	39 da                	cmp    %ebx,%edx
  800737:	75 ed                	jne    800726 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800739:	89 f0                	mov    %esi,%eax
  80073b:	5b                   	pop    %ebx
  80073c:	5e                   	pop    %esi
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	56                   	push   %esi
  800743:	53                   	push   %ebx
  800744:	8b 75 08             	mov    0x8(%ebp),%esi
  800747:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074a:	8b 55 10             	mov    0x10(%ebp),%edx
  80074d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80074f:	85 d2                	test   %edx,%edx
  800751:	74 21                	je     800774 <strlcpy+0x35>
  800753:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800757:	89 f2                	mov    %esi,%edx
  800759:	eb 09                	jmp    800764 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80075b:	83 c2 01             	add    $0x1,%edx
  80075e:	83 c1 01             	add    $0x1,%ecx
  800761:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800764:	39 c2                	cmp    %eax,%edx
  800766:	74 09                	je     800771 <strlcpy+0x32>
  800768:	0f b6 19             	movzbl (%ecx),%ebx
  80076b:	84 db                	test   %bl,%bl
  80076d:	75 ec                	jne    80075b <strlcpy+0x1c>
  80076f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800771:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800774:	29 f0                	sub    %esi,%eax
}
  800776:	5b                   	pop    %ebx
  800777:	5e                   	pop    %esi
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800780:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800783:	eb 06                	jmp    80078b <strcmp+0x11>
		p++, q++;
  800785:	83 c1 01             	add    $0x1,%ecx
  800788:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80078b:	0f b6 01             	movzbl (%ecx),%eax
  80078e:	84 c0                	test   %al,%al
  800790:	74 04                	je     800796 <strcmp+0x1c>
  800792:	3a 02                	cmp    (%edx),%al
  800794:	74 ef                	je     800785 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800796:	0f b6 c0             	movzbl %al,%eax
  800799:	0f b6 12             	movzbl (%edx),%edx
  80079c:	29 d0                	sub    %edx,%eax
}
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007aa:	89 c3                	mov    %eax,%ebx
  8007ac:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007af:	eb 06                	jmp    8007b7 <strncmp+0x17>
		n--, p++, q++;
  8007b1:	83 c0 01             	add    $0x1,%eax
  8007b4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007b7:	39 d8                	cmp    %ebx,%eax
  8007b9:	74 15                	je     8007d0 <strncmp+0x30>
  8007bb:	0f b6 08             	movzbl (%eax),%ecx
  8007be:	84 c9                	test   %cl,%cl
  8007c0:	74 04                	je     8007c6 <strncmp+0x26>
  8007c2:	3a 0a                	cmp    (%edx),%cl
  8007c4:	74 eb                	je     8007b1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c6:	0f b6 00             	movzbl (%eax),%eax
  8007c9:	0f b6 12             	movzbl (%edx),%edx
  8007cc:	29 d0                	sub    %edx,%eax
  8007ce:	eb 05                	jmp    8007d5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e2:	eb 07                	jmp    8007eb <strchr+0x13>
		if (*s == c)
  8007e4:	38 ca                	cmp    %cl,%dl
  8007e6:	74 0f                	je     8007f7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007e8:	83 c0 01             	add    $0x1,%eax
  8007eb:	0f b6 10             	movzbl (%eax),%edx
  8007ee:	84 d2                	test   %dl,%dl
  8007f0:	75 f2                	jne    8007e4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800803:	eb 03                	jmp    800808 <strfind+0xf>
  800805:	83 c0 01             	add    $0x1,%eax
  800808:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80080b:	84 d2                	test   %dl,%dl
  80080d:	74 04                	je     800813 <strfind+0x1a>
  80080f:	38 ca                	cmp    %cl,%dl
  800811:	75 f2                	jne    800805 <strfind+0xc>
			break;
	return (char *) s;
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	57                   	push   %edi
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80081e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800821:	85 c9                	test   %ecx,%ecx
  800823:	74 36                	je     80085b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800825:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80082b:	75 28                	jne    800855 <memset+0x40>
  80082d:	f6 c1 03             	test   $0x3,%cl
  800830:	75 23                	jne    800855 <memset+0x40>
		c &= 0xFF;
  800832:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800836:	89 d3                	mov    %edx,%ebx
  800838:	c1 e3 08             	shl    $0x8,%ebx
  80083b:	89 d6                	mov    %edx,%esi
  80083d:	c1 e6 18             	shl    $0x18,%esi
  800840:	89 d0                	mov    %edx,%eax
  800842:	c1 e0 10             	shl    $0x10,%eax
  800845:	09 f0                	or     %esi,%eax
  800847:	09 c2                	or     %eax,%edx
  800849:	89 d0                	mov    %edx,%eax
  80084b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80084d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800850:	fc                   	cld    
  800851:	f3 ab                	rep stos %eax,%es:(%edi)
  800853:	eb 06                	jmp    80085b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800855:	8b 45 0c             	mov    0xc(%ebp),%eax
  800858:	fc                   	cld    
  800859:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80085b:	89 f8                	mov    %edi,%eax
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5f                   	pop    %edi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	57                   	push   %edi
  800866:	56                   	push   %esi
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80086d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800870:	39 c6                	cmp    %eax,%esi
  800872:	73 35                	jae    8008a9 <memmove+0x47>
  800874:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800877:	39 d0                	cmp    %edx,%eax
  800879:	73 2e                	jae    8008a9 <memmove+0x47>
		s += n;
		d += n;
  80087b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80087e:	89 d6                	mov    %edx,%esi
  800880:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800882:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800888:	75 13                	jne    80089d <memmove+0x3b>
  80088a:	f6 c1 03             	test   $0x3,%cl
  80088d:	75 0e                	jne    80089d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80088f:	83 ef 04             	sub    $0x4,%edi
  800892:	8d 72 fc             	lea    -0x4(%edx),%esi
  800895:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800898:	fd                   	std    
  800899:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80089b:	eb 09                	jmp    8008a6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80089d:	83 ef 01             	sub    $0x1,%edi
  8008a0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008a3:	fd                   	std    
  8008a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008a6:	fc                   	cld    
  8008a7:	eb 1d                	jmp    8008c6 <memmove+0x64>
  8008a9:	89 f2                	mov    %esi,%edx
  8008ab:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ad:	f6 c2 03             	test   $0x3,%dl
  8008b0:	75 0f                	jne    8008c1 <memmove+0x5f>
  8008b2:	f6 c1 03             	test   $0x3,%cl
  8008b5:	75 0a                	jne    8008c1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008b7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008ba:	89 c7                	mov    %eax,%edi
  8008bc:	fc                   	cld    
  8008bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008bf:	eb 05                	jmp    8008c6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c1:	89 c7                	mov    %eax,%edi
  8008c3:	fc                   	cld    
  8008c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008c6:	5e                   	pop    %esi
  8008c7:	5f                   	pop    %edi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008cd:	ff 75 10             	pushl  0x10(%ebp)
  8008d0:	ff 75 0c             	pushl  0xc(%ebp)
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 87 ff ff ff       	call   800862 <memmove>
}
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e8:	89 c6                	mov    %eax,%esi
  8008ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008ed:	eb 1a                	jmp    800909 <memcmp+0x2c>
		if (*s1 != *s2)
  8008ef:	0f b6 08             	movzbl (%eax),%ecx
  8008f2:	0f b6 1a             	movzbl (%edx),%ebx
  8008f5:	38 d9                	cmp    %bl,%cl
  8008f7:	74 0a                	je     800903 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008f9:	0f b6 c1             	movzbl %cl,%eax
  8008fc:	0f b6 db             	movzbl %bl,%ebx
  8008ff:	29 d8                	sub    %ebx,%eax
  800901:	eb 0f                	jmp    800912 <memcmp+0x35>
		s1++, s2++;
  800903:	83 c0 01             	add    $0x1,%eax
  800906:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800909:	39 f0                	cmp    %esi,%eax
  80090b:	75 e2                	jne    8008ef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80091f:	89 c2                	mov    %eax,%edx
  800921:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800924:	eb 07                	jmp    80092d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800926:	38 08                	cmp    %cl,(%eax)
  800928:	74 07                	je     800931 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	39 d0                	cmp    %edx,%eax
  80092f:	72 f5                	jb     800926 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	57                   	push   %edi
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80093f:	eb 03                	jmp    800944 <strtol+0x11>
		s++;
  800941:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800944:	0f b6 01             	movzbl (%ecx),%eax
  800947:	3c 09                	cmp    $0x9,%al
  800949:	74 f6                	je     800941 <strtol+0xe>
  80094b:	3c 20                	cmp    $0x20,%al
  80094d:	74 f2                	je     800941 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80094f:	3c 2b                	cmp    $0x2b,%al
  800951:	75 0a                	jne    80095d <strtol+0x2a>
		s++;
  800953:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800956:	bf 00 00 00 00       	mov    $0x0,%edi
  80095b:	eb 10                	jmp    80096d <strtol+0x3a>
  80095d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800962:	3c 2d                	cmp    $0x2d,%al
  800964:	75 07                	jne    80096d <strtol+0x3a>
		s++, neg = 1;
  800966:	8d 49 01             	lea    0x1(%ecx),%ecx
  800969:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80096d:	85 db                	test   %ebx,%ebx
  80096f:	0f 94 c0             	sete   %al
  800972:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800978:	75 19                	jne    800993 <strtol+0x60>
  80097a:	80 39 30             	cmpb   $0x30,(%ecx)
  80097d:	75 14                	jne    800993 <strtol+0x60>
  80097f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800983:	0f 85 82 00 00 00    	jne    800a0b <strtol+0xd8>
		s += 2, base = 16;
  800989:	83 c1 02             	add    $0x2,%ecx
  80098c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800991:	eb 16                	jmp    8009a9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800993:	84 c0                	test   %al,%al
  800995:	74 12                	je     8009a9 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800997:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80099c:	80 39 30             	cmpb   $0x30,(%ecx)
  80099f:	75 08                	jne    8009a9 <strtol+0x76>
		s++, base = 8;
  8009a1:	83 c1 01             	add    $0x1,%ecx
  8009a4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ae:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b1:	0f b6 11             	movzbl (%ecx),%edx
  8009b4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009b7:	89 f3                	mov    %esi,%ebx
  8009b9:	80 fb 09             	cmp    $0x9,%bl
  8009bc:	77 08                	ja     8009c6 <strtol+0x93>
			dig = *s - '0';
  8009be:	0f be d2             	movsbl %dl,%edx
  8009c1:	83 ea 30             	sub    $0x30,%edx
  8009c4:	eb 22                	jmp    8009e8 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009c6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009c9:	89 f3                	mov    %esi,%ebx
  8009cb:	80 fb 19             	cmp    $0x19,%bl
  8009ce:	77 08                	ja     8009d8 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009d0:	0f be d2             	movsbl %dl,%edx
  8009d3:	83 ea 57             	sub    $0x57,%edx
  8009d6:	eb 10                	jmp    8009e8 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009d8:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009db:	89 f3                	mov    %esi,%ebx
  8009dd:	80 fb 19             	cmp    $0x19,%bl
  8009e0:	77 16                	ja     8009f8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009e2:	0f be d2             	movsbl %dl,%edx
  8009e5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009e8:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009eb:	7d 0f                	jge    8009fc <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009ed:	83 c1 01             	add    $0x1,%ecx
  8009f0:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009f6:	eb b9                	jmp    8009b1 <strtol+0x7e>
  8009f8:	89 c2                	mov    %eax,%edx
  8009fa:	eb 02                	jmp    8009fe <strtol+0xcb>
  8009fc:	89 c2                	mov    %eax,%edx

	if (endptr)
  8009fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a02:	74 0d                	je     800a11 <strtol+0xde>
		*endptr = (char *) s;
  800a04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a07:	89 0e                	mov    %ecx,(%esi)
  800a09:	eb 06                	jmp    800a11 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0b:	84 c0                	test   %al,%al
  800a0d:	75 92                	jne    8009a1 <strtol+0x6e>
  800a0f:	eb 98                	jmp    8009a9 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a11:	f7 da                	neg    %edx
  800a13:	85 ff                	test   %edi,%edi
  800a15:	0f 45 c2             	cmovne %edx,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5f                   	pop    %edi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
  800a28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2e:	89 c3                	mov    %eax,%ebx
  800a30:	89 c7                	mov    %eax,%edi
  800a32:	89 c6                	mov    %eax,%esi
  800a34:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a41:	ba 00 00 00 00       	mov    $0x0,%edx
  800a46:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4b:	89 d1                	mov    %edx,%ecx
  800a4d:	89 d3                	mov    %edx,%ebx
  800a4f:	89 d7                	mov    %edx,%edi
  800a51:	89 d6                	mov    %edx,%esi
  800a53:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	57                   	push   %edi
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a68:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a70:	89 cb                	mov    %ecx,%ebx
  800a72:	89 cf                	mov    %ecx,%edi
  800a74:	89 ce                	mov    %ecx,%esi
  800a76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	7e 17                	jle    800a93 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a7c:	83 ec 0c             	sub    $0xc,%esp
  800a7f:	50                   	push   %eax
  800a80:	6a 03                	push   $0x3
  800a82:	68 08 12 80 00       	push   $0x801208
  800a87:	6a 23                	push   $0x23
  800a89:	68 25 12 80 00       	push   $0x801225
  800a8e:	e8 f5 01 00 00       	call   800c88 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	b8 02 00 00 00       	mov    $0x2,%eax
  800aab:	89 d1                	mov    %edx,%ecx
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	89 d7                	mov    %edx,%edi
  800ab1:	89 d6                	mov    %edx,%esi
  800ab3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_yield>:

void
sys_yield(void)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aca:	89 d1                	mov    %edx,%ecx
  800acc:	89 d3                	mov    %edx,%ebx
  800ace:	89 d7                	mov    %edx,%edi
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	be 00 00 00 00       	mov    $0x0,%esi
  800ae7:	b8 04 00 00 00       	mov    $0x4,%eax
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aef:	8b 55 08             	mov    0x8(%ebp),%edx
  800af2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800af5:	89 f7                	mov    %esi,%edi
  800af7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af9:	85 c0                	test   %eax,%eax
  800afb:	7e 17                	jle    800b14 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afd:	83 ec 0c             	sub    $0xc,%esp
  800b00:	50                   	push   %eax
  800b01:	6a 04                	push   $0x4
  800b03:	68 08 12 80 00       	push   $0x801208
  800b08:	6a 23                	push   $0x23
  800b0a:	68 25 12 80 00       	push   $0x801225
  800b0f:	e8 74 01 00 00       	call   800c88 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	b8 05 00 00 00       	mov    $0x5,%eax
  800b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b33:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b36:	8b 75 18             	mov    0x18(%ebp),%esi
  800b39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	7e 17                	jle    800b56 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	50                   	push   %eax
  800b43:	6a 05                	push   $0x5
  800b45:	68 08 12 80 00       	push   $0x801208
  800b4a:	6a 23                	push   $0x23
  800b4c:	68 25 12 80 00       	push   $0x801225
  800b51:	e8 32 01 00 00       	call   800c88 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b6c:	b8 06 00 00 00       	mov    $0x6,%eax
  800b71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	89 df                	mov    %ebx,%edi
  800b79:	89 de                	mov    %ebx,%esi
  800b7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7e 17                	jle    800b98 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	50                   	push   %eax
  800b85:	6a 06                	push   $0x6
  800b87:	68 08 12 80 00       	push   $0x801208
  800b8c:	6a 23                	push   $0x23
  800b8e:	68 25 12 80 00       	push   $0x801225
  800b93:	e8 f0 00 00 00       	call   800c88 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bae:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 df                	mov    %ebx,%edi
  800bbb:	89 de                	mov    %ebx,%esi
  800bbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 17                	jle    800bda <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	50                   	push   %eax
  800bc7:	6a 08                	push   $0x8
  800bc9:	68 08 12 80 00       	push   $0x801208
  800bce:	6a 23                	push   $0x23
  800bd0:	68 25 12 80 00       	push   $0x801225
  800bd5:	e8 ae 00 00 00       	call   800c88 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800beb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf0:	b8 09 00 00 00       	mov    $0x9,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 df                	mov    %ebx,%edi
  800bfd:	89 de                	mov    %ebx,%esi
  800bff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 17                	jle    800c1c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	50                   	push   %eax
  800c09:	6a 09                	push   $0x9
  800c0b:	68 08 12 80 00       	push   $0x801208
  800c10:	6a 23                	push   $0x23
  800c12:	68 25 12 80 00       	push   $0x801225
  800c17:	e8 6c 00 00 00       	call   800c88 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	be 00 00 00 00       	mov    $0x0,%esi
  800c2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c40:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c55:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	89 cb                	mov    %ecx,%ebx
  800c5f:	89 cf                	mov    %ecx,%edi
  800c61:	89 ce                	mov    %ecx,%esi
  800c63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 0c                	push   $0xc
  800c6f:	68 08 12 80 00       	push   $0x801208
  800c74:	6a 23                	push   $0x23
  800c76:	68 25 12 80 00       	push   $0x801225
  800c7b:	e8 08 00 00 00       	call   800c88 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c8d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c90:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800c96:	e8 00 fe ff ff       	call   800a9b <sys_getenvid>
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	ff 75 0c             	pushl  0xc(%ebp)
  800ca1:	ff 75 08             	pushl  0x8(%ebp)
  800ca4:	56                   	push   %esi
  800ca5:	50                   	push   %eax
  800ca6:	68 34 12 80 00       	push   $0x801234
  800cab:	e8 99 f4 ff ff       	call   800149 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cb0:	83 c4 18             	add    $0x18,%esp
  800cb3:	53                   	push   %ebx
  800cb4:	ff 75 10             	pushl  0x10(%ebp)
  800cb7:	e8 3c f4 ff ff       	call   8000f8 <vcprintf>
	cprintf("\n");
  800cbc:	c7 04 24 8c 0f 80 00 	movl   $0x800f8c,(%esp)
  800cc3:	e8 81 f4 ff ff       	call   800149 <cprintf>
  800cc8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ccb:	cc                   	int3   
  800ccc:	eb fd                	jmp    800ccb <_panic+0x43>
  800cce:	66 90                	xchg   %ax,%ax

00800cd0 <__udivdi3>:
  800cd0:	55                   	push   %ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	83 ec 10             	sub    $0x10,%esp
  800cd6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800cda:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800cde:	8b 74 24 24          	mov    0x24(%esp),%esi
  800ce2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800ce6:	85 d2                	test   %edx,%edx
  800ce8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cec:	89 34 24             	mov    %esi,(%esp)
  800cef:	89 c8                	mov    %ecx,%eax
  800cf1:	75 35                	jne    800d28 <__udivdi3+0x58>
  800cf3:	39 f1                	cmp    %esi,%ecx
  800cf5:	0f 87 bd 00 00 00    	ja     800db8 <__udivdi3+0xe8>
  800cfb:	85 c9                	test   %ecx,%ecx
  800cfd:	89 cd                	mov    %ecx,%ebp
  800cff:	75 0b                	jne    800d0c <__udivdi3+0x3c>
  800d01:	b8 01 00 00 00       	mov    $0x1,%eax
  800d06:	31 d2                	xor    %edx,%edx
  800d08:	f7 f1                	div    %ecx
  800d0a:	89 c5                	mov    %eax,%ebp
  800d0c:	89 f0                	mov    %esi,%eax
  800d0e:	31 d2                	xor    %edx,%edx
  800d10:	f7 f5                	div    %ebp
  800d12:	89 c6                	mov    %eax,%esi
  800d14:	89 f8                	mov    %edi,%eax
  800d16:	f7 f5                	div    %ebp
  800d18:	89 f2                	mov    %esi,%edx
  800d1a:	83 c4 10             	add    $0x10,%esp
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    
  800d21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d28:	3b 14 24             	cmp    (%esp),%edx
  800d2b:	77 7b                	ja     800da8 <__udivdi3+0xd8>
  800d2d:	0f bd f2             	bsr    %edx,%esi
  800d30:	83 f6 1f             	xor    $0x1f,%esi
  800d33:	0f 84 97 00 00 00    	je     800dd0 <__udivdi3+0x100>
  800d39:	bd 20 00 00 00       	mov    $0x20,%ebp
  800d3e:	89 d7                	mov    %edx,%edi
  800d40:	89 f1                	mov    %esi,%ecx
  800d42:	29 f5                	sub    %esi,%ebp
  800d44:	d3 e7                	shl    %cl,%edi
  800d46:	89 c2                	mov    %eax,%edx
  800d48:	89 e9                	mov    %ebp,%ecx
  800d4a:	d3 ea                	shr    %cl,%edx
  800d4c:	89 f1                	mov    %esi,%ecx
  800d4e:	09 fa                	or     %edi,%edx
  800d50:	8b 3c 24             	mov    (%esp),%edi
  800d53:	d3 e0                	shl    %cl,%eax
  800d55:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d59:	89 e9                	mov    %ebp,%ecx
  800d5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d5f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d63:	89 fa                	mov    %edi,%edx
  800d65:	d3 ea                	shr    %cl,%edx
  800d67:	89 f1                	mov    %esi,%ecx
  800d69:	d3 e7                	shl    %cl,%edi
  800d6b:	89 e9                	mov    %ebp,%ecx
  800d6d:	d3 e8                	shr    %cl,%eax
  800d6f:	09 c7                	or     %eax,%edi
  800d71:	89 f8                	mov    %edi,%eax
  800d73:	f7 74 24 08          	divl   0x8(%esp)
  800d77:	89 d5                	mov    %edx,%ebp
  800d79:	89 c7                	mov    %eax,%edi
  800d7b:	f7 64 24 0c          	mull   0xc(%esp)
  800d7f:	39 d5                	cmp    %edx,%ebp
  800d81:	89 14 24             	mov    %edx,(%esp)
  800d84:	72 11                	jb     800d97 <__udivdi3+0xc7>
  800d86:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d8a:	89 f1                	mov    %esi,%ecx
  800d8c:	d3 e2                	shl    %cl,%edx
  800d8e:	39 c2                	cmp    %eax,%edx
  800d90:	73 5e                	jae    800df0 <__udivdi3+0x120>
  800d92:	3b 2c 24             	cmp    (%esp),%ebp
  800d95:	75 59                	jne    800df0 <__udivdi3+0x120>
  800d97:	8d 47 ff             	lea    -0x1(%edi),%eax
  800d9a:	31 f6                	xor    %esi,%esi
  800d9c:	89 f2                	mov    %esi,%edx
  800d9e:	83 c4 10             	add    $0x10,%esp
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    
  800da5:	8d 76 00             	lea    0x0(%esi),%esi
  800da8:	31 f6                	xor    %esi,%esi
  800daa:	31 c0                	xor    %eax,%eax
  800dac:	89 f2                	mov    %esi,%edx
  800dae:	83 c4 10             	add    $0x10,%esp
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    
  800db5:	8d 76 00             	lea    0x0(%esi),%esi
  800db8:	89 f2                	mov    %esi,%edx
  800dba:	31 f6                	xor    %esi,%esi
  800dbc:	89 f8                	mov    %edi,%eax
  800dbe:	f7 f1                	div    %ecx
  800dc0:	89 f2                	mov    %esi,%edx
  800dc2:	83 c4 10             	add    $0x10,%esp
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    
  800dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dd0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dd4:	76 0b                	jbe    800de1 <__udivdi3+0x111>
  800dd6:	31 c0                	xor    %eax,%eax
  800dd8:	3b 14 24             	cmp    (%esp),%edx
  800ddb:	0f 83 37 ff ff ff    	jae    800d18 <__udivdi3+0x48>
  800de1:	b8 01 00 00 00       	mov    $0x1,%eax
  800de6:	e9 2d ff ff ff       	jmp    800d18 <__udivdi3+0x48>
  800deb:	90                   	nop
  800dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df0:	89 f8                	mov    %edi,%eax
  800df2:	31 f6                	xor    %esi,%esi
  800df4:	e9 1f ff ff ff       	jmp    800d18 <__udivdi3+0x48>
  800df9:	66 90                	xchg   %ax,%ax
  800dfb:	66 90                	xchg   %ax,%ax
  800dfd:	66 90                	xchg   %ax,%ax
  800dff:	90                   	nop

00800e00 <__umoddi3>:
  800e00:	55                   	push   %ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	83 ec 20             	sub    $0x20,%esp
  800e06:	8b 44 24 34          	mov    0x34(%esp),%eax
  800e0a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e0e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e12:	89 c6                	mov    %eax,%esi
  800e14:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e18:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800e1c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800e20:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e24:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800e28:	89 74 24 18          	mov    %esi,0x18(%esp)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	89 c2                	mov    %eax,%edx
  800e30:	75 1e                	jne    800e50 <__umoddi3+0x50>
  800e32:	39 f7                	cmp    %esi,%edi
  800e34:	76 52                	jbe    800e88 <__umoddi3+0x88>
  800e36:	89 c8                	mov    %ecx,%eax
  800e38:	89 f2                	mov    %esi,%edx
  800e3a:	f7 f7                	div    %edi
  800e3c:	89 d0                	mov    %edx,%eax
  800e3e:	31 d2                	xor    %edx,%edx
  800e40:	83 c4 20             	add    $0x20,%esp
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    
  800e47:	89 f6                	mov    %esi,%esi
  800e49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e50:	39 f0                	cmp    %esi,%eax
  800e52:	77 5c                	ja     800eb0 <__umoddi3+0xb0>
  800e54:	0f bd e8             	bsr    %eax,%ebp
  800e57:	83 f5 1f             	xor    $0x1f,%ebp
  800e5a:	75 64                	jne    800ec0 <__umoddi3+0xc0>
  800e5c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800e60:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800e64:	0f 86 f6 00 00 00    	jbe    800f60 <__umoddi3+0x160>
  800e6a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800e6e:	0f 82 ec 00 00 00    	jb     800f60 <__umoddi3+0x160>
  800e74:	8b 44 24 14          	mov    0x14(%esp),%eax
  800e78:	8b 54 24 18          	mov    0x18(%esp),%edx
  800e7c:	83 c4 20             	add    $0x20,%esp
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    
  800e83:	90                   	nop
  800e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e88:	85 ff                	test   %edi,%edi
  800e8a:	89 fd                	mov    %edi,%ebp
  800e8c:	75 0b                	jne    800e99 <__umoddi3+0x99>
  800e8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e93:	31 d2                	xor    %edx,%edx
  800e95:	f7 f7                	div    %edi
  800e97:	89 c5                	mov    %eax,%ebp
  800e99:	8b 44 24 10          	mov    0x10(%esp),%eax
  800e9d:	31 d2                	xor    %edx,%edx
  800e9f:	f7 f5                	div    %ebp
  800ea1:	89 c8                	mov    %ecx,%eax
  800ea3:	f7 f5                	div    %ebp
  800ea5:	eb 95                	jmp    800e3c <__umoddi3+0x3c>
  800ea7:	89 f6                	mov    %esi,%esi
  800ea9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800eb0:	89 c8                	mov    %ecx,%eax
  800eb2:	89 f2                	mov    %esi,%edx
  800eb4:	83 c4 20             	add    $0x20,%esp
  800eb7:	5e                   	pop    %esi
  800eb8:	5f                   	pop    %edi
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    
  800ebb:	90                   	nop
  800ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	b8 20 00 00 00       	mov    $0x20,%eax
  800ec5:	89 e9                	mov    %ebp,%ecx
  800ec7:	29 e8                	sub    %ebp,%eax
  800ec9:	d3 e2                	shl    %cl,%edx
  800ecb:	89 c7                	mov    %eax,%edi
  800ecd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800ed1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ed5:	89 f9                	mov    %edi,%ecx
  800ed7:	d3 e8                	shr    %cl,%eax
  800ed9:	89 c1                	mov    %eax,%ecx
  800edb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800edf:	09 d1                	or     %edx,%ecx
  800ee1:	89 fa                	mov    %edi,%edx
  800ee3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ee7:	89 e9                	mov    %ebp,%ecx
  800ee9:	d3 e0                	shl    %cl,%eax
  800eeb:	89 f9                	mov    %edi,%ecx
  800eed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ef1:	89 f0                	mov    %esi,%eax
  800ef3:	d3 e8                	shr    %cl,%eax
  800ef5:	89 e9                	mov    %ebp,%ecx
  800ef7:	89 c7                	mov    %eax,%edi
  800ef9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800efd:	d3 e6                	shl    %cl,%esi
  800eff:	89 d1                	mov    %edx,%ecx
  800f01:	89 fa                	mov    %edi,%edx
  800f03:	d3 e8                	shr    %cl,%eax
  800f05:	89 e9                	mov    %ebp,%ecx
  800f07:	09 f0                	or     %esi,%eax
  800f09:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800f0d:	f7 74 24 10          	divl   0x10(%esp)
  800f11:	d3 e6                	shl    %cl,%esi
  800f13:	89 d1                	mov    %edx,%ecx
  800f15:	f7 64 24 0c          	mull   0xc(%esp)
  800f19:	39 d1                	cmp    %edx,%ecx
  800f1b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800f1f:	89 d7                	mov    %edx,%edi
  800f21:	89 c6                	mov    %eax,%esi
  800f23:	72 0a                	jb     800f2f <__umoddi3+0x12f>
  800f25:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800f29:	73 10                	jae    800f3b <__umoddi3+0x13b>
  800f2b:	39 d1                	cmp    %edx,%ecx
  800f2d:	75 0c                	jne    800f3b <__umoddi3+0x13b>
  800f2f:	89 d7                	mov    %edx,%edi
  800f31:	89 c6                	mov    %eax,%esi
  800f33:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800f37:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800f3b:	89 ca                	mov    %ecx,%edx
  800f3d:	89 e9                	mov    %ebp,%ecx
  800f3f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f43:	29 f0                	sub    %esi,%eax
  800f45:	19 fa                	sbb    %edi,%edx
  800f47:	d3 e8                	shr    %cl,%eax
  800f49:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800f4e:	89 d7                	mov    %edx,%edi
  800f50:	d3 e7                	shl    %cl,%edi
  800f52:	89 e9                	mov    %ebp,%ecx
  800f54:	09 f8                	or     %edi,%eax
  800f56:	d3 ea                	shr    %cl,%edx
  800f58:	83 c4 20             	add    $0x20,%esp
  800f5b:	5e                   	pop    %esi
  800f5c:	5f                   	pop    %edi
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    
  800f5f:	90                   	nop
  800f60:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f64:	29 f9                	sub    %edi,%ecx
  800f66:	19 c6                	sbb    %eax,%esi
  800f68:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800f6c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f70:	e9 ff fe ff ff       	jmp    800e74 <__umoddi3+0x74>
