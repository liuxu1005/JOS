
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 80 0f 80 00       	push   $0x800f80
  800056:	e8 f0 00 00 00       	call   80014b <cprintf>
  80005b:	83 c4 10             	add    $0x10,%esp
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80006b:	e8 2d 0a 00 00       	call   800a9d <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
  80009c:	83 c4 10             	add    $0x10,%esp
}
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 a9 09 00 00       	call   800a5c <sys_env_destroy>
  8000b3:	83 c4 10             	add    $0x10,%esp
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 13                	mov    (%ebx),%edx
  8000c4:	8d 42 01             	lea    0x1(%edx),%eax
  8000c7:	89 03                	mov    %eax,(%ebx)
  8000c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	75 1a                	jne    8000f1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	68 ff 00 00 00       	push   $0xff
  8000df:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e2:	50                   	push   %eax
  8000e3:	e8 37 09 00 00       	call   800a1f <sys_cputs>
		b->idx = 0;
  8000e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ee:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	ff 75 0c             	pushl  0xc(%ebp)
  80011a:	ff 75 08             	pushl  0x8(%ebp)
  80011d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800123:	50                   	push   %eax
  800124:	68 b8 00 80 00       	push   $0x8000b8
  800129:	e8 4f 01 00 00       	call   80027d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012e:	83 c4 08             	add    $0x8,%esp
  800131:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800137:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	e8 dc 08 00 00       	call   800a1f <sys_cputs>

	return b.cnt;
}
  800143:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800151:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800154:	50                   	push   %eax
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	e8 9d ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 1c             	sub    $0x1c,%esp
  800168:	89 c7                	mov    %eax,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	8b 45 08             	mov    0x8(%ebp),%eax
  80016f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800177:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80017a:	8b 45 10             	mov    0x10(%ebp),%eax
  80017d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800180:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800183:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80018a:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80018d:	72 05                	jb     800194 <printnum+0x35>
  80018f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800192:	77 3e                	ja     8001d2 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	ff 75 18             	pushl  0x18(%ebp)
  80019a:	83 eb 01             	sub    $0x1,%ebx
  80019d:	53                   	push   %ebx
  80019e:	50                   	push   %eax
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ae:	e8 1d 0b 00 00       	call   800cd0 <__udivdi3>
  8001b3:	83 c4 18             	add    $0x18,%esp
  8001b6:	52                   	push   %edx
  8001b7:	50                   	push   %eax
  8001b8:	89 f2                	mov    %esi,%edx
  8001ba:	89 f8                	mov    %edi,%eax
  8001bc:	e8 9e ff ff ff       	call   80015f <printnum>
  8001c1:	83 c4 20             	add    $0x20,%esp
  8001c4:	eb 13                	jmp    8001d9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	ff 75 18             	pushl  0x18(%ebp)
  8001cd:	ff d7                	call   *%edi
  8001cf:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d2:	83 eb 01             	sub    $0x1,%ebx
  8001d5:	85 db                	test   %ebx,%ebx
  8001d7:	7f ed                	jg     8001c6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	56                   	push   %esi
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ec:	e8 0f 0c 00 00       	call   800e00 <__umoddi3>
  8001f1:	83 c4 14             	add    $0x14,%esp
  8001f4:	0f be 80 98 0f 80 00 	movsbl 0x800f98(%eax),%eax
  8001fb:	50                   	push   %eax
  8001fc:	ff d7                	call   *%edi
  8001fe:	83 c4 10             	add    $0x10,%esp
}
  800201:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5f                   	pop    %edi
  800207:	5d                   	pop    %ebp
  800208:	c3                   	ret    

00800209 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80020c:	83 fa 01             	cmp    $0x1,%edx
  80020f:	7e 0e                	jle    80021f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800211:	8b 10                	mov    (%eax),%edx
  800213:	8d 4a 08             	lea    0x8(%edx),%ecx
  800216:	89 08                	mov    %ecx,(%eax)
  800218:	8b 02                	mov    (%edx),%eax
  80021a:	8b 52 04             	mov    0x4(%edx),%edx
  80021d:	eb 22                	jmp    800241 <getuint+0x38>
	else if (lflag)
  80021f:	85 d2                	test   %edx,%edx
  800221:	74 10                	je     800233 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800223:	8b 10                	mov    (%eax),%edx
  800225:	8d 4a 04             	lea    0x4(%edx),%ecx
  800228:	89 08                	mov    %ecx,(%eax)
  80022a:	8b 02                	mov    (%edx),%eax
  80022c:	ba 00 00 00 00       	mov    $0x0,%edx
  800231:	eb 0e                	jmp    800241 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800233:	8b 10                	mov    (%eax),%edx
  800235:	8d 4a 04             	lea    0x4(%edx),%ecx
  800238:	89 08                	mov    %ecx,(%eax)
  80023a:	8b 02                	mov    (%edx),%eax
  80023c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    

00800243 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800249:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80024d:	8b 10                	mov    (%eax),%edx
  80024f:	3b 50 04             	cmp    0x4(%eax),%edx
  800252:	73 0a                	jae    80025e <sprintputch+0x1b>
		*b->buf++ = ch;
  800254:	8d 4a 01             	lea    0x1(%edx),%ecx
  800257:	89 08                	mov    %ecx,(%eax)
  800259:	8b 45 08             	mov    0x8(%ebp),%eax
  80025c:	88 02                	mov    %al,(%edx)
}
  80025e:	5d                   	pop    %ebp
  80025f:	c3                   	ret    

00800260 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800266:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800269:	50                   	push   %eax
  80026a:	ff 75 10             	pushl  0x10(%ebp)
  80026d:	ff 75 0c             	pushl  0xc(%ebp)
  800270:	ff 75 08             	pushl  0x8(%ebp)
  800273:	e8 05 00 00 00       	call   80027d <vprintfmt>
	va_end(ap);
  800278:	83 c4 10             	add    $0x10,%esp
}
  80027b:	c9                   	leave  
  80027c:	c3                   	ret    

0080027d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	57                   	push   %edi
  800281:	56                   	push   %esi
  800282:	53                   	push   %ebx
  800283:	83 ec 2c             	sub    $0x2c,%esp
  800286:	8b 75 08             	mov    0x8(%ebp),%esi
  800289:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80028c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028f:	eb 12                	jmp    8002a3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800291:	85 c0                	test   %eax,%eax
  800293:	0f 84 90 03 00 00    	je     800629 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	53                   	push   %ebx
  80029d:	50                   	push   %eax
  80029e:	ff d6                	call   *%esi
  8002a0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a3:	83 c7 01             	add    $0x1,%edi
  8002a6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002aa:	83 f8 25             	cmp    $0x25,%eax
  8002ad:	75 e2                	jne    800291 <vprintfmt+0x14>
  8002af:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ba:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002c1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cd:	eb 07                	jmp    8002d6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d6:	8d 47 01             	lea    0x1(%edi),%eax
  8002d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dc:	0f b6 07             	movzbl (%edi),%eax
  8002df:	0f b6 c8             	movzbl %al,%ecx
  8002e2:	83 e8 23             	sub    $0x23,%eax
  8002e5:	3c 55                	cmp    $0x55,%al
  8002e7:	0f 87 21 03 00 00    	ja     80060e <vprintfmt+0x391>
  8002ed:	0f b6 c0             	movzbl %al,%eax
  8002f0:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  8002f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002fa:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002fe:	eb d6                	jmp    8002d6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800303:	b8 00 00 00 00       	mov    $0x0,%eax
  800308:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80030b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80030e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800312:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800315:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800318:	83 fa 09             	cmp    $0x9,%edx
  80031b:	77 39                	ja     800356 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80031d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800320:	eb e9                	jmp    80030b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800322:	8b 45 14             	mov    0x14(%ebp),%eax
  800325:	8d 48 04             	lea    0x4(%eax),%ecx
  800328:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80032b:	8b 00                	mov    (%eax),%eax
  80032d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800333:	eb 27                	jmp    80035c <vprintfmt+0xdf>
  800335:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800338:	85 c0                	test   %eax,%eax
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	0f 49 c8             	cmovns %eax,%ecx
  800342:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800348:	eb 8c                	jmp    8002d6 <vprintfmt+0x59>
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80034d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800354:	eb 80                	jmp    8002d6 <vprintfmt+0x59>
  800356:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800359:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80035c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800360:	0f 89 70 ff ff ff    	jns    8002d6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800366:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800369:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800373:	e9 5e ff ff ff       	jmp    8002d6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800378:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80037e:	e9 53 ff ff ff       	jmp    8002d6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800383:	8b 45 14             	mov    0x14(%ebp),%eax
  800386:	8d 50 04             	lea    0x4(%eax),%edx
  800389:	89 55 14             	mov    %edx,0x14(%ebp)
  80038c:	83 ec 08             	sub    $0x8,%esp
  80038f:	53                   	push   %ebx
  800390:	ff 30                	pushl  (%eax)
  800392:	ff d6                	call   *%esi
			break;
  800394:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039a:	e9 04 ff ff ff       	jmp    8002a3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a2:	8d 50 04             	lea    0x4(%eax),%edx
  8003a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a8:	8b 00                	mov    (%eax),%eax
  8003aa:	99                   	cltd   
  8003ab:	31 d0                	xor    %edx,%eax
  8003ad:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003af:	83 f8 09             	cmp    $0x9,%eax
  8003b2:	7f 0b                	jg     8003bf <vprintfmt+0x142>
  8003b4:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  8003bb:	85 d2                	test   %edx,%edx
  8003bd:	75 18                	jne    8003d7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003bf:	50                   	push   %eax
  8003c0:	68 b0 0f 80 00       	push   $0x800fb0
  8003c5:	53                   	push   %ebx
  8003c6:	56                   	push   %esi
  8003c7:	e8 94 fe ff ff       	call   800260 <printfmt>
  8003cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d2:	e9 cc fe ff ff       	jmp    8002a3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d7:	52                   	push   %edx
  8003d8:	68 b9 0f 80 00       	push   $0x800fb9
  8003dd:	53                   	push   %ebx
  8003de:	56                   	push   %esi
  8003df:	e8 7c fe ff ff       	call   800260 <printfmt>
  8003e4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ea:	e9 b4 fe ff ff       	jmp    8002a3 <vprintfmt+0x26>
  8003ef:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 50 04             	lea    0x4(%eax),%edx
  8003fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800401:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800403:	85 ff                	test   %edi,%edi
  800405:	ba a9 0f 80 00       	mov    $0x800fa9,%edx
  80040a:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80040d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800411:	0f 84 92 00 00 00    	je     8004a9 <vprintfmt+0x22c>
  800417:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80041b:	0f 8e 96 00 00 00    	jle    8004b7 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800421:	83 ec 08             	sub    $0x8,%esp
  800424:	51                   	push   %ecx
  800425:	57                   	push   %edi
  800426:	e8 86 02 00 00       	call   8006b1 <strnlen>
  80042b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80042e:	29 c1                	sub    %eax,%ecx
  800430:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800433:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800436:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80043a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800440:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800442:	eb 0f                	jmp    800453 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	53                   	push   %ebx
  800448:	ff 75 e0             	pushl  -0x20(%ebp)
  80044b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044d:	83 ef 01             	sub    $0x1,%edi
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	85 ff                	test   %edi,%edi
  800455:	7f ed                	jg     800444 <vprintfmt+0x1c7>
  800457:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80045a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80045d:	85 c9                	test   %ecx,%ecx
  80045f:	b8 00 00 00 00       	mov    $0x0,%eax
  800464:	0f 49 c1             	cmovns %ecx,%eax
  800467:	29 c1                	sub    %eax,%ecx
  800469:	89 75 08             	mov    %esi,0x8(%ebp)
  80046c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80046f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800472:	89 cb                	mov    %ecx,%ebx
  800474:	eb 4d                	jmp    8004c3 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800476:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047a:	74 1b                	je     800497 <vprintfmt+0x21a>
  80047c:	0f be c0             	movsbl %al,%eax
  80047f:	83 e8 20             	sub    $0x20,%eax
  800482:	83 f8 5e             	cmp    $0x5e,%eax
  800485:	76 10                	jbe    800497 <vprintfmt+0x21a>
					putch('?', putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	ff 75 0c             	pushl  0xc(%ebp)
  80048d:	6a 3f                	push   $0x3f
  80048f:	ff 55 08             	call   *0x8(%ebp)
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	eb 0d                	jmp    8004a4 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	ff 75 0c             	pushl  0xc(%ebp)
  80049d:	52                   	push   %edx
  80049e:	ff 55 08             	call   *0x8(%ebp)
  8004a1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a4:	83 eb 01             	sub    $0x1,%ebx
  8004a7:	eb 1a                	jmp    8004c3 <vprintfmt+0x246>
  8004a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b5:	eb 0c                	jmp    8004c3 <vprintfmt+0x246>
  8004b7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ba:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004bd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c3:	83 c7 01             	add    $0x1,%edi
  8004c6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ca:	0f be d0             	movsbl %al,%edx
  8004cd:	85 d2                	test   %edx,%edx
  8004cf:	74 23                	je     8004f4 <vprintfmt+0x277>
  8004d1:	85 f6                	test   %esi,%esi
  8004d3:	78 a1                	js     800476 <vprintfmt+0x1f9>
  8004d5:	83 ee 01             	sub    $0x1,%esi
  8004d8:	79 9c                	jns    800476 <vprintfmt+0x1f9>
  8004da:	89 df                	mov    %ebx,%edi
  8004dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e2:	eb 18                	jmp    8004fc <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	53                   	push   %ebx
  8004e8:	6a 20                	push   $0x20
  8004ea:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ec:	83 ef 01             	sub    $0x1,%edi
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	eb 08                	jmp    8004fc <vprintfmt+0x27f>
  8004f4:	89 df                	mov    %ebx,%edi
  8004f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fc:	85 ff                	test   %edi,%edi
  8004fe:	7f e4                	jg     8004e4 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800503:	e9 9b fd ff ff       	jmp    8002a3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800508:	83 fa 01             	cmp    $0x1,%edx
  80050b:	7e 16                	jle    800523 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 50 08             	lea    0x8(%eax),%edx
  800513:	89 55 14             	mov    %edx,0x14(%ebp)
  800516:	8b 50 04             	mov    0x4(%eax),%edx
  800519:	8b 00                	mov    (%eax),%eax
  80051b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800521:	eb 32                	jmp    800555 <vprintfmt+0x2d8>
	else if (lflag)
  800523:	85 d2                	test   %edx,%edx
  800525:	74 18                	je     80053f <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8d 50 04             	lea    0x4(%eax),%edx
  80052d:	89 55 14             	mov    %edx,0x14(%ebp)
  800530:	8b 00                	mov    (%eax),%eax
  800532:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800535:	89 c1                	mov    %eax,%ecx
  800537:	c1 f9 1f             	sar    $0x1f,%ecx
  80053a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80053d:	eb 16                	jmp    800555 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054d:	89 c1                	mov    %eax,%ecx
  80054f:	c1 f9 1f             	sar    $0x1f,%ecx
  800552:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800555:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800558:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800560:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800564:	79 74                	jns    8005da <vprintfmt+0x35d>
				putch('-', putdat);
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	53                   	push   %ebx
  80056a:	6a 2d                	push   $0x2d
  80056c:	ff d6                	call   *%esi
				num = -(long long) num;
  80056e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800571:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800574:	f7 d8                	neg    %eax
  800576:	83 d2 00             	adc    $0x0,%edx
  800579:	f7 da                	neg    %edx
  80057b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80057e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800583:	eb 55                	jmp    8005da <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800585:	8d 45 14             	lea    0x14(%ebp),%eax
  800588:	e8 7c fc ff ff       	call   800209 <getuint>
			base = 10;
  80058d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800592:	eb 46                	jmp    8005da <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800594:	8d 45 14             	lea    0x14(%ebp),%eax
  800597:	e8 6d fc ff ff       	call   800209 <getuint>
                        base = 8;
  80059c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005a1:	eb 37                	jmp    8005da <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	53                   	push   %ebx
  8005a7:	6a 30                	push   $0x30
  8005a9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ab:	83 c4 08             	add    $0x8,%esp
  8005ae:	53                   	push   %ebx
  8005af:	6a 78                	push   $0x78
  8005b1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 50 04             	lea    0x4(%eax),%edx
  8005b9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005bc:	8b 00                	mov    (%eax),%eax
  8005be:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005cb:	eb 0d                	jmp    8005da <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d0:	e8 34 fc ff ff       	call   800209 <getuint>
			base = 16;
  8005d5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005da:	83 ec 0c             	sub    $0xc,%esp
  8005dd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005e1:	57                   	push   %edi
  8005e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e5:	51                   	push   %ecx
  8005e6:	52                   	push   %edx
  8005e7:	50                   	push   %eax
  8005e8:	89 da                	mov    %ebx,%edx
  8005ea:	89 f0                	mov    %esi,%eax
  8005ec:	e8 6e fb ff ff       	call   80015f <printnum>
			break;
  8005f1:	83 c4 20             	add    $0x20,%esp
  8005f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f7:	e9 a7 fc ff ff       	jmp    8002a3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	53                   	push   %ebx
  800600:	51                   	push   %ecx
  800601:	ff d6                	call   *%esi
			break;
  800603:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800609:	e9 95 fc ff ff       	jmp    8002a3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 25                	push   $0x25
  800614:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	eb 03                	jmp    80061e <vprintfmt+0x3a1>
  80061b:	83 ef 01             	sub    $0x1,%edi
  80061e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800622:	75 f7                	jne    80061b <vprintfmt+0x39e>
  800624:	e9 7a fc ff ff       	jmp    8002a3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800629:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062c:	5b                   	pop    %ebx
  80062d:	5e                   	pop    %esi
  80062e:	5f                   	pop    %edi
  80062f:	5d                   	pop    %ebp
  800630:	c3                   	ret    

00800631 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800631:	55                   	push   %ebp
  800632:	89 e5                	mov    %esp,%ebp
  800634:	83 ec 18             	sub    $0x18,%esp
  800637:	8b 45 08             	mov    0x8(%ebp),%eax
  80063a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80063d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800640:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800644:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800647:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80064e:	85 c0                	test   %eax,%eax
  800650:	74 26                	je     800678 <vsnprintf+0x47>
  800652:	85 d2                	test   %edx,%edx
  800654:	7e 22                	jle    800678 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800656:	ff 75 14             	pushl  0x14(%ebp)
  800659:	ff 75 10             	pushl  0x10(%ebp)
  80065c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80065f:	50                   	push   %eax
  800660:	68 43 02 80 00       	push   $0x800243
  800665:	e8 13 fc ff ff       	call   80027d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80066a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80066d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800670:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	eb 05                	jmp    80067d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800678:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80067d:	c9                   	leave  
  80067e:	c3                   	ret    

0080067f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800685:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800688:	50                   	push   %eax
  800689:	ff 75 10             	pushl  0x10(%ebp)
  80068c:	ff 75 0c             	pushl  0xc(%ebp)
  80068f:	ff 75 08             	pushl  0x8(%ebp)
  800692:	e8 9a ff ff ff       	call   800631 <vsnprintf>
	va_end(ap);

	return rc;
}
  800697:	c9                   	leave  
  800698:	c3                   	ret    

00800699 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800699:	55                   	push   %ebp
  80069a:	89 e5                	mov    %esp,%ebp
  80069c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80069f:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a4:	eb 03                	jmp    8006a9 <strlen+0x10>
		n++;
  8006a6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ad:	75 f7                	jne    8006a6 <strlen+0xd>
		n++;
	return n;
}
  8006af:	5d                   	pop    %ebp
  8006b0:	c3                   	ret    

008006b1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
  8006b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bf:	eb 03                	jmp    8006c4 <strnlen+0x13>
		n++;
  8006c1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c4:	39 c2                	cmp    %eax,%edx
  8006c6:	74 08                	je     8006d0 <strnlen+0x1f>
  8006c8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006cc:	75 f3                	jne    8006c1 <strnlen+0x10>
  8006ce:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	53                   	push   %ebx
  8006d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006dc:	89 c2                	mov    %eax,%edx
  8006de:	83 c2 01             	add    $0x1,%edx
  8006e1:	83 c1 01             	add    $0x1,%ecx
  8006e4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006e8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006eb:	84 db                	test   %bl,%bl
  8006ed:	75 ef                	jne    8006de <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006ef:	5b                   	pop    %ebx
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	53                   	push   %ebx
  8006f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006f9:	53                   	push   %ebx
  8006fa:	e8 9a ff ff ff       	call   800699 <strlen>
  8006ff:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800702:	ff 75 0c             	pushl  0xc(%ebp)
  800705:	01 d8                	add    %ebx,%eax
  800707:	50                   	push   %eax
  800708:	e8 c5 ff ff ff       	call   8006d2 <strcpy>
	return dst;
}
  80070d:	89 d8                	mov    %ebx,%eax
  80070f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	56                   	push   %esi
  800718:	53                   	push   %ebx
  800719:	8b 75 08             	mov    0x8(%ebp),%esi
  80071c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071f:	89 f3                	mov    %esi,%ebx
  800721:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800724:	89 f2                	mov    %esi,%edx
  800726:	eb 0f                	jmp    800737 <strncpy+0x23>
		*dst++ = *src;
  800728:	83 c2 01             	add    $0x1,%edx
  80072b:	0f b6 01             	movzbl (%ecx),%eax
  80072e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800731:	80 39 01             	cmpb   $0x1,(%ecx)
  800734:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800737:	39 da                	cmp    %ebx,%edx
  800739:	75 ed                	jne    800728 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80073b:	89 f0                	mov    %esi,%eax
  80073d:	5b                   	pop    %ebx
  80073e:	5e                   	pop    %esi
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	56                   	push   %esi
  800745:	53                   	push   %ebx
  800746:	8b 75 08             	mov    0x8(%ebp),%esi
  800749:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074c:	8b 55 10             	mov    0x10(%ebp),%edx
  80074f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800751:	85 d2                	test   %edx,%edx
  800753:	74 21                	je     800776 <strlcpy+0x35>
  800755:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800759:	89 f2                	mov    %esi,%edx
  80075b:	eb 09                	jmp    800766 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80075d:	83 c2 01             	add    $0x1,%edx
  800760:	83 c1 01             	add    $0x1,%ecx
  800763:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800766:	39 c2                	cmp    %eax,%edx
  800768:	74 09                	je     800773 <strlcpy+0x32>
  80076a:	0f b6 19             	movzbl (%ecx),%ebx
  80076d:	84 db                	test   %bl,%bl
  80076f:	75 ec                	jne    80075d <strlcpy+0x1c>
  800771:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800773:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800776:	29 f0                	sub    %esi,%eax
}
  800778:	5b                   	pop    %ebx
  800779:	5e                   	pop    %esi
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800782:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800785:	eb 06                	jmp    80078d <strcmp+0x11>
		p++, q++;
  800787:	83 c1 01             	add    $0x1,%ecx
  80078a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80078d:	0f b6 01             	movzbl (%ecx),%eax
  800790:	84 c0                	test   %al,%al
  800792:	74 04                	je     800798 <strcmp+0x1c>
  800794:	3a 02                	cmp    (%edx),%al
  800796:	74 ef                	je     800787 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800798:	0f b6 c0             	movzbl %al,%eax
  80079b:	0f b6 12             	movzbl (%edx),%edx
  80079e:	29 d0                	sub    %edx,%eax
}
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	53                   	push   %ebx
  8007a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 c3                	mov    %eax,%ebx
  8007ae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b1:	eb 06                	jmp    8007b9 <strncmp+0x17>
		n--, p++, q++;
  8007b3:	83 c0 01             	add    $0x1,%eax
  8007b6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007b9:	39 d8                	cmp    %ebx,%eax
  8007bb:	74 15                	je     8007d2 <strncmp+0x30>
  8007bd:	0f b6 08             	movzbl (%eax),%ecx
  8007c0:	84 c9                	test   %cl,%cl
  8007c2:	74 04                	je     8007c8 <strncmp+0x26>
  8007c4:	3a 0a                	cmp    (%edx),%cl
  8007c6:	74 eb                	je     8007b3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c8:	0f b6 00             	movzbl (%eax),%eax
  8007cb:	0f b6 12             	movzbl (%edx),%edx
  8007ce:	29 d0                	sub    %edx,%eax
  8007d0:	eb 05                	jmp    8007d7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007d7:	5b                   	pop    %ebx
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e4:	eb 07                	jmp    8007ed <strchr+0x13>
		if (*s == c)
  8007e6:	38 ca                	cmp    %cl,%dl
  8007e8:	74 0f                	je     8007f9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007ea:	83 c0 01             	add    $0x1,%eax
  8007ed:	0f b6 10             	movzbl (%eax),%edx
  8007f0:	84 d2                	test   %dl,%dl
  8007f2:	75 f2                	jne    8007e6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800805:	eb 03                	jmp    80080a <strfind+0xf>
  800807:	83 c0 01             	add    $0x1,%eax
  80080a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80080d:	84 d2                	test   %dl,%dl
  80080f:	74 04                	je     800815 <strfind+0x1a>
  800811:	38 ca                	cmp    %cl,%dl
  800813:	75 f2                	jne    800807 <strfind+0xc>
			break;
	return (char *) s;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	57                   	push   %edi
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800820:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800823:	85 c9                	test   %ecx,%ecx
  800825:	74 36                	je     80085d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800827:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80082d:	75 28                	jne    800857 <memset+0x40>
  80082f:	f6 c1 03             	test   $0x3,%cl
  800832:	75 23                	jne    800857 <memset+0x40>
		c &= 0xFF;
  800834:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800838:	89 d3                	mov    %edx,%ebx
  80083a:	c1 e3 08             	shl    $0x8,%ebx
  80083d:	89 d6                	mov    %edx,%esi
  80083f:	c1 e6 18             	shl    $0x18,%esi
  800842:	89 d0                	mov    %edx,%eax
  800844:	c1 e0 10             	shl    $0x10,%eax
  800847:	09 f0                	or     %esi,%eax
  800849:	09 c2                	or     %eax,%edx
  80084b:	89 d0                	mov    %edx,%eax
  80084d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80084f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800852:	fc                   	cld    
  800853:	f3 ab                	rep stos %eax,%es:(%edi)
  800855:	eb 06                	jmp    80085d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085a:	fc                   	cld    
  80085b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80085d:	89 f8                	mov    %edi,%eax
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5f                   	pop    %edi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	57                   	push   %edi
  800868:	56                   	push   %esi
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80086f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800872:	39 c6                	cmp    %eax,%esi
  800874:	73 35                	jae    8008ab <memmove+0x47>
  800876:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800879:	39 d0                	cmp    %edx,%eax
  80087b:	73 2e                	jae    8008ab <memmove+0x47>
		s += n;
		d += n;
  80087d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800880:	89 d6                	mov    %edx,%esi
  800882:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800884:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088a:	75 13                	jne    80089f <memmove+0x3b>
  80088c:	f6 c1 03             	test   $0x3,%cl
  80088f:	75 0e                	jne    80089f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800891:	83 ef 04             	sub    $0x4,%edi
  800894:	8d 72 fc             	lea    -0x4(%edx),%esi
  800897:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80089a:	fd                   	std    
  80089b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80089d:	eb 09                	jmp    8008a8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80089f:	83 ef 01             	sub    $0x1,%edi
  8008a2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008a5:	fd                   	std    
  8008a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008a8:	fc                   	cld    
  8008a9:	eb 1d                	jmp    8008c8 <memmove+0x64>
  8008ab:	89 f2                	mov    %esi,%edx
  8008ad:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008af:	f6 c2 03             	test   $0x3,%dl
  8008b2:	75 0f                	jne    8008c3 <memmove+0x5f>
  8008b4:	f6 c1 03             	test   $0x3,%cl
  8008b7:	75 0a                	jne    8008c3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008b9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008bc:	89 c7                	mov    %eax,%edi
  8008be:	fc                   	cld    
  8008bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c1:	eb 05                	jmp    8008c8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c3:	89 c7                	mov    %eax,%edi
  8008c5:	fc                   	cld    
  8008c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008c8:	5e                   	pop    %esi
  8008c9:	5f                   	pop    %edi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008cf:	ff 75 10             	pushl  0x10(%ebp)
  8008d2:	ff 75 0c             	pushl  0xc(%ebp)
  8008d5:	ff 75 08             	pushl  0x8(%ebp)
  8008d8:	e8 87 ff ff ff       	call   800864 <memmove>
}
  8008dd:	c9                   	leave  
  8008de:	c3                   	ret    

008008df <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	89 c6                	mov    %eax,%esi
  8008ec:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008ef:	eb 1a                	jmp    80090b <memcmp+0x2c>
		if (*s1 != *s2)
  8008f1:	0f b6 08             	movzbl (%eax),%ecx
  8008f4:	0f b6 1a             	movzbl (%edx),%ebx
  8008f7:	38 d9                	cmp    %bl,%cl
  8008f9:	74 0a                	je     800905 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008fb:	0f b6 c1             	movzbl %cl,%eax
  8008fe:	0f b6 db             	movzbl %bl,%ebx
  800901:	29 d8                	sub    %ebx,%eax
  800903:	eb 0f                	jmp    800914 <memcmp+0x35>
		s1++, s2++;
  800905:	83 c0 01             	add    $0x1,%eax
  800908:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090b:	39 f0                	cmp    %esi,%eax
  80090d:	75 e2                	jne    8008f1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80090f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800921:	89 c2                	mov    %eax,%edx
  800923:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800926:	eb 07                	jmp    80092f <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800928:	38 08                	cmp    %cl,(%eax)
  80092a:	74 07                	je     800933 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80092c:	83 c0 01             	add    $0x1,%eax
  80092f:	39 d0                	cmp    %edx,%eax
  800931:	72 f5                	jb     800928 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	57                   	push   %edi
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800941:	eb 03                	jmp    800946 <strtol+0x11>
		s++;
  800943:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800946:	0f b6 01             	movzbl (%ecx),%eax
  800949:	3c 09                	cmp    $0x9,%al
  80094b:	74 f6                	je     800943 <strtol+0xe>
  80094d:	3c 20                	cmp    $0x20,%al
  80094f:	74 f2                	je     800943 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800951:	3c 2b                	cmp    $0x2b,%al
  800953:	75 0a                	jne    80095f <strtol+0x2a>
		s++;
  800955:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800958:	bf 00 00 00 00       	mov    $0x0,%edi
  80095d:	eb 10                	jmp    80096f <strtol+0x3a>
  80095f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800964:	3c 2d                	cmp    $0x2d,%al
  800966:	75 07                	jne    80096f <strtol+0x3a>
		s++, neg = 1;
  800968:	8d 49 01             	lea    0x1(%ecx),%ecx
  80096b:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80096f:	85 db                	test   %ebx,%ebx
  800971:	0f 94 c0             	sete   %al
  800974:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80097a:	75 19                	jne    800995 <strtol+0x60>
  80097c:	80 39 30             	cmpb   $0x30,(%ecx)
  80097f:	75 14                	jne    800995 <strtol+0x60>
  800981:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800985:	0f 85 82 00 00 00    	jne    800a0d <strtol+0xd8>
		s += 2, base = 16;
  80098b:	83 c1 02             	add    $0x2,%ecx
  80098e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800993:	eb 16                	jmp    8009ab <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800995:	84 c0                	test   %al,%al
  800997:	74 12                	je     8009ab <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800999:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80099e:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a1:	75 08                	jne    8009ab <strtol+0x76>
		s++, base = 8;
  8009a3:	83 c1 01             	add    $0x1,%ecx
  8009a6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b3:	0f b6 11             	movzbl (%ecx),%edx
  8009b6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009b9:	89 f3                	mov    %esi,%ebx
  8009bb:	80 fb 09             	cmp    $0x9,%bl
  8009be:	77 08                	ja     8009c8 <strtol+0x93>
			dig = *s - '0';
  8009c0:	0f be d2             	movsbl %dl,%edx
  8009c3:	83 ea 30             	sub    $0x30,%edx
  8009c6:	eb 22                	jmp    8009ea <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009c8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009cb:	89 f3                	mov    %esi,%ebx
  8009cd:	80 fb 19             	cmp    $0x19,%bl
  8009d0:	77 08                	ja     8009da <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009d2:	0f be d2             	movsbl %dl,%edx
  8009d5:	83 ea 57             	sub    $0x57,%edx
  8009d8:	eb 10                	jmp    8009ea <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009da:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009dd:	89 f3                	mov    %esi,%ebx
  8009df:	80 fb 19             	cmp    $0x19,%bl
  8009e2:	77 16                	ja     8009fa <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009e4:	0f be d2             	movsbl %dl,%edx
  8009e7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009ea:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009ed:	7d 0f                	jge    8009fe <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009ef:	83 c1 01             	add    $0x1,%ecx
  8009f2:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009f8:	eb b9                	jmp    8009b3 <strtol+0x7e>
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	eb 02                	jmp    800a00 <strtol+0xcb>
  8009fe:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a04:	74 0d                	je     800a13 <strtol+0xde>
		*endptr = (char *) s;
  800a06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a09:	89 0e                	mov    %ecx,(%esi)
  800a0b:	eb 06                	jmp    800a13 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0d:	84 c0                	test   %al,%al
  800a0f:	75 92                	jne    8009a3 <strtol+0x6e>
  800a11:	eb 98                	jmp    8009ab <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a13:	f7 da                	neg    %edx
  800a15:	85 ff                	test   %edi,%edi
  800a17:	0f 45 c2             	cmovne %edx,%eax
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5f                   	pop    %edi
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a30:	89 c3                	mov    %eax,%ebx
  800a32:	89 c7                	mov    %eax,%edi
  800a34:	89 c6                	mov    %eax,%esi
  800a36:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a38:	5b                   	pop    %ebx
  800a39:	5e                   	pop    %esi
  800a3a:	5f                   	pop    %edi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a43:	ba 00 00 00 00       	mov    $0x0,%edx
  800a48:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4d:	89 d1                	mov    %edx,%ecx
  800a4f:	89 d3                	mov    %edx,%ebx
  800a51:	89 d7                	mov    %edx,%edi
  800a53:	89 d6                	mov    %edx,%esi
  800a55:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a57:	5b                   	pop    %ebx
  800a58:	5e                   	pop    %esi
  800a59:	5f                   	pop    %edi
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a6a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a72:	89 cb                	mov    %ecx,%ebx
  800a74:	89 cf                	mov    %ecx,%edi
  800a76:	89 ce                	mov    %ecx,%esi
  800a78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a7a:	85 c0                	test   %eax,%eax
  800a7c:	7e 17                	jle    800a95 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a7e:	83 ec 0c             	sub    $0xc,%esp
  800a81:	50                   	push   %eax
  800a82:	6a 03                	push   $0x3
  800a84:	68 e8 11 80 00       	push   $0x8011e8
  800a89:	6a 23                	push   $0x23
  800a8b:	68 05 12 80 00       	push   $0x801205
  800a90:	e8 f5 01 00 00       	call   800c8a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa3:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa8:	b8 02 00 00 00       	mov    $0x2,%eax
  800aad:	89 d1                	mov    %edx,%ecx
  800aaf:	89 d3                	mov    %edx,%ebx
  800ab1:	89 d7                	mov    %edx,%edi
  800ab3:	89 d6                	mov    %edx,%esi
  800ab5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <sys_yield>:

void
sys_yield(void)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800acc:	89 d1                	mov    %edx,%ecx
  800ace:	89 d3                	mov    %edx,%ebx
  800ad0:	89 d7                	mov    %edx,%edi
  800ad2:	89 d6                	mov    %edx,%esi
  800ad4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	be 00 00 00 00       	mov    $0x0,%esi
  800ae9:	b8 04 00 00 00       	mov    $0x4,%eax
  800aee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af1:	8b 55 08             	mov    0x8(%ebp),%edx
  800af4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800af7:	89 f7                	mov    %esi,%edi
  800af9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7e 17                	jle    800b16 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aff:	83 ec 0c             	sub    $0xc,%esp
  800b02:	50                   	push   %eax
  800b03:	6a 04                	push   $0x4
  800b05:	68 e8 11 80 00       	push   $0x8011e8
  800b0a:	6a 23                	push   $0x23
  800b0c:	68 05 12 80 00       	push   $0x801205
  800b11:	e8 74 01 00 00       	call   800c8a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b27:	b8 05 00 00 00       	mov    $0x5,%eax
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b38:	8b 75 18             	mov    0x18(%ebp),%esi
  800b3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	7e 17                	jle    800b58 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b41:	83 ec 0c             	sub    $0xc,%esp
  800b44:	50                   	push   %eax
  800b45:	6a 05                	push   $0x5
  800b47:	68 e8 11 80 00       	push   $0x8011e8
  800b4c:	6a 23                	push   $0x23
  800b4e:	68 05 12 80 00       	push   $0x801205
  800b53:	e8 32 01 00 00       	call   800c8a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	89 df                	mov    %ebx,%edi
  800b7b:	89 de                	mov    %ebx,%esi
  800b7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	7e 17                	jle    800b9a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	50                   	push   %eax
  800b87:	6a 06                	push   $0x6
  800b89:	68 e8 11 80 00       	push   $0x8011e8
  800b8e:	6a 23                	push   $0x23
  800b90:	68 05 12 80 00       	push   $0x801205
  800b95:	e8 f0 00 00 00       	call   800c8a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	89 df                	mov    %ebx,%edi
  800bbd:	89 de                	mov    %ebx,%esi
  800bbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 17                	jle    800bdc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	50                   	push   %eax
  800bc9:	6a 08                	push   $0x8
  800bcb:	68 e8 11 80 00       	push   $0x8011e8
  800bd0:	6a 23                	push   $0x23
  800bd2:	68 05 12 80 00       	push   $0x801205
  800bd7:	e8 ae 00 00 00       	call   800c8a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  800bea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf2:	b8 09 00 00 00       	mov    $0x9,%eax
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	89 df                	mov    %ebx,%edi
  800bff:	89 de                	mov    %ebx,%esi
  800c01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 17                	jle    800c1e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 09                	push   $0x9
  800c0d:	68 e8 11 80 00       	push   $0x8011e8
  800c12:	6a 23                	push   $0x23
  800c14:	68 05 12 80 00       	push   $0x801205
  800c19:	e8 6c 00 00 00       	call   800c8a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	be 00 00 00 00       	mov    $0x0,%esi
  800c31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c42:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c57:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 cb                	mov    %ecx,%ebx
  800c61:	89 cf                	mov    %ecx,%edi
  800c63:	89 ce                	mov    %ecx,%esi
  800c65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 17                	jle    800c82 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 0c                	push   $0xc
  800c71:	68 e8 11 80 00       	push   $0x8011e8
  800c76:	6a 23                	push   $0x23
  800c78:	68 05 12 80 00       	push   $0x801205
  800c7d:	e8 08 00 00 00       	call   800c8a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c8f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c92:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800c98:	e8 00 fe ff ff       	call   800a9d <sys_getenvid>
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	ff 75 0c             	pushl  0xc(%ebp)
  800ca3:	ff 75 08             	pushl  0x8(%ebp)
  800ca6:	56                   	push   %esi
  800ca7:	50                   	push   %eax
  800ca8:	68 14 12 80 00       	push   $0x801214
  800cad:	e8 99 f4 ff ff       	call   80014b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cb2:	83 c4 18             	add    $0x18,%esp
  800cb5:	53                   	push   %ebx
  800cb6:	ff 75 10             	pushl  0x10(%ebp)
  800cb9:	e8 3c f4 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  800cbe:	c7 04 24 8c 0f 80 00 	movl   $0x800f8c,(%esp)
  800cc5:	e8 81 f4 ff ff       	call   80014b <cprintf>
  800cca:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ccd:	cc                   	int3   
  800cce:	eb fd                	jmp    800ccd <_panic+0x43>

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
