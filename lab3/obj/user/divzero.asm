
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
  800051:	68 c0 0d 80 00       	push   $0x800dc0
  800056:	e8 f3 00 00 00       	call   80014e <cprintf>
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
  80006b:	e8 30 0a 00 00       	call   800aa0 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800078:	c1 e0 05             	shl    $0x5,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 db                	test   %ebx,%ebx
  800087:	7e 07                	jle    800090 <libmain+0x30>
		binaryname = argv[0];
  800089:	8b 06                	mov    (%esi),%eax
  80008b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800090:	83 ec 08             	sub    $0x8,%esp
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	e8 99 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009a:	e8 0a 00 00 00       	call   8000a9 <exit>
  80009f:	83 c4 10             	add    $0x10,%esp
}
  8000a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a5:	5b                   	pop    %ebx
  8000a6:	5e                   	pop    %esi
  8000a7:	5d                   	pop    %ebp
  8000a8:	c3                   	ret    

008000a9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000af:	6a 00                	push   $0x0
  8000b1:	e8 a9 09 00 00       	call   800a5f <sys_env_destroy>
  8000b6:	83 c4 10             	add    $0x10,%esp
}
  8000b9:	c9                   	leave  
  8000ba:	c3                   	ret    

008000bb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	53                   	push   %ebx
  8000bf:	83 ec 04             	sub    $0x4,%esp
  8000c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c5:	8b 13                	mov    (%ebx),%edx
  8000c7:	8d 42 01             	lea    0x1(%edx),%eax
  8000ca:	89 03                	mov    %eax,(%ebx)
  8000cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d8:	75 1a                	jne    8000f4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000da:	83 ec 08             	sub    $0x8,%esp
  8000dd:	68 ff 00 00 00       	push   $0xff
  8000e2:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e5:	50                   	push   %eax
  8000e6:	e8 37 09 00 00       	call   800a22 <sys_cputs>
		b->idx = 0;
  8000eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800106:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010d:	00 00 00 
	b.cnt = 0;
  800110:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800117:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011a:	ff 75 0c             	pushl  0xc(%ebp)
  80011d:	ff 75 08             	pushl  0x8(%ebp)
  800120:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800126:	50                   	push   %eax
  800127:	68 bb 00 80 00       	push   $0x8000bb
  80012c:	e8 4f 01 00 00       	call   800280 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800131:	83 c4 08             	add    $0x8,%esp
  800134:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800140:	50                   	push   %eax
  800141:	e8 dc 08 00 00       	call   800a22 <sys_cputs>

	return b.cnt;
}
  800146:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    

0080014e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800154:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800157:	50                   	push   %eax
  800158:	ff 75 08             	pushl  0x8(%ebp)
  80015b:	e8 9d ff ff ff       	call   8000fd <vcprintf>
	va_end(ap);

	return cnt;
}
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 1c             	sub    $0x1c,%esp
  80016b:	89 c7                	mov    %eax,%edi
  80016d:	89 d6                	mov    %edx,%esi
  80016f:	8b 45 08             	mov    0x8(%ebp),%eax
  800172:	8b 55 0c             	mov    0xc(%ebp),%edx
  800175:	89 d1                	mov    %edx,%ecx
  800177:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80017d:	8b 45 10             	mov    0x10(%ebp),%eax
  800180:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800183:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800186:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80018d:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800190:	72 05                	jb     800197 <printnum+0x35>
  800192:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800195:	77 3e                	ja     8001d5 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	ff 75 18             	pushl  0x18(%ebp)
  80019d:	83 eb 01             	sub    $0x1,%ebx
  8001a0:	53                   	push   %ebx
  8001a1:	50                   	push   %eax
  8001a2:	83 ec 08             	sub    $0x8,%esp
  8001a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b1:	e8 5a 09 00 00       	call   800b10 <__udivdi3>
  8001b6:	83 c4 18             	add    $0x18,%esp
  8001b9:	52                   	push   %edx
  8001ba:	50                   	push   %eax
  8001bb:	89 f2                	mov    %esi,%edx
  8001bd:	89 f8                	mov    %edi,%eax
  8001bf:	e8 9e ff ff ff       	call   800162 <printnum>
  8001c4:	83 c4 20             	add    $0x20,%esp
  8001c7:	eb 13                	jmp    8001dc <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	56                   	push   %esi
  8001cd:	ff 75 18             	pushl  0x18(%ebp)
  8001d0:	ff d7                	call   *%edi
  8001d2:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d5:	83 eb 01             	sub    $0x1,%ebx
  8001d8:	85 db                	test   %ebx,%ebx
  8001da:	7f ed                	jg     8001c9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001dc:	83 ec 08             	sub    $0x8,%esp
  8001df:	56                   	push   %esi
  8001e0:	83 ec 04             	sub    $0x4,%esp
  8001e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ef:	e8 4c 0a 00 00       	call   800c40 <__umoddi3>
  8001f4:	83 c4 14             	add    $0x14,%esp
  8001f7:	0f be 80 d8 0d 80 00 	movsbl 0x800dd8(%eax),%eax
  8001fe:	50                   	push   %eax
  8001ff:	ff d7                	call   *%edi
  800201:	83 c4 10             	add    $0x10,%esp
}
  800204:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5f                   	pop    %edi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80020f:	83 fa 01             	cmp    $0x1,%edx
  800212:	7e 0e                	jle    800222 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800214:	8b 10                	mov    (%eax),%edx
  800216:	8d 4a 08             	lea    0x8(%edx),%ecx
  800219:	89 08                	mov    %ecx,(%eax)
  80021b:	8b 02                	mov    (%edx),%eax
  80021d:	8b 52 04             	mov    0x4(%edx),%edx
  800220:	eb 22                	jmp    800244 <getuint+0x38>
	else if (lflag)
  800222:	85 d2                	test   %edx,%edx
  800224:	74 10                	je     800236 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800226:	8b 10                	mov    (%eax),%edx
  800228:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022b:	89 08                	mov    %ecx,(%eax)
  80022d:	8b 02                	mov    (%edx),%eax
  80022f:	ba 00 00 00 00       	mov    $0x0,%edx
  800234:	eb 0e                	jmp    800244 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800236:	8b 10                	mov    (%eax),%edx
  800238:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023b:	89 08                	mov    %ecx,(%eax)
  80023d:	8b 02                	mov    (%edx),%eax
  80023f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800250:	8b 10                	mov    (%eax),%edx
  800252:	3b 50 04             	cmp    0x4(%eax),%edx
  800255:	73 0a                	jae    800261 <sprintputch+0x1b>
		*b->buf++ = ch;
  800257:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025a:	89 08                	mov    %ecx,(%eax)
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	88 02                	mov    %al,(%edx)
}
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800269:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026c:	50                   	push   %eax
  80026d:	ff 75 10             	pushl  0x10(%ebp)
  800270:	ff 75 0c             	pushl  0xc(%ebp)
  800273:	ff 75 08             	pushl  0x8(%ebp)
  800276:	e8 05 00 00 00       	call   800280 <vprintfmt>
	va_end(ap);
  80027b:	83 c4 10             	add    $0x10,%esp
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 2c             	sub    $0x2c,%esp
  800289:	8b 75 08             	mov    0x8(%ebp),%esi
  80028c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80028f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800292:	eb 12                	jmp    8002a6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800294:	85 c0                	test   %eax,%eax
  800296:	0f 84 90 03 00 00    	je     80062c <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80029c:	83 ec 08             	sub    $0x8,%esp
  80029f:	53                   	push   %ebx
  8002a0:	50                   	push   %eax
  8002a1:	ff d6                	call   *%esi
  8002a3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a6:	83 c7 01             	add    $0x1,%edi
  8002a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ad:	83 f8 25             	cmp    $0x25,%eax
  8002b0:	75 e2                	jne    800294 <vprintfmt+0x14>
  8002b2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002bd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002c4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d0:	eb 07                	jmp    8002d9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d9:	8d 47 01             	lea    0x1(%edi),%eax
  8002dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002df:	0f b6 07             	movzbl (%edi),%eax
  8002e2:	0f b6 c8             	movzbl %al,%ecx
  8002e5:	83 e8 23             	sub    $0x23,%eax
  8002e8:	3c 55                	cmp    $0x55,%al
  8002ea:	0f 87 21 03 00 00    	ja     800611 <vprintfmt+0x391>
  8002f0:	0f b6 c0             	movzbl %al,%eax
  8002f3:	ff 24 85 80 0e 80 00 	jmp    *0x800e80(,%eax,4)
  8002fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002fd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800301:	eb d6                	jmp    8002d9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800306:	b8 00 00 00 00       	mov    $0x0,%eax
  80030b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80030e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800311:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800315:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800318:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80031b:	83 fa 09             	cmp    $0x9,%edx
  80031e:	77 39                	ja     800359 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800320:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800323:	eb e9                	jmp    80030e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800325:	8b 45 14             	mov    0x14(%ebp),%eax
  800328:	8d 48 04             	lea    0x4(%eax),%ecx
  80032b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80032e:	8b 00                	mov    (%eax),%eax
  800330:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800336:	eb 27                	jmp    80035f <vprintfmt+0xdf>
  800338:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033b:	85 c0                	test   %eax,%eax
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	0f 49 c8             	cmovns %eax,%ecx
  800345:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034b:	eb 8c                	jmp    8002d9 <vprintfmt+0x59>
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800350:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800357:	eb 80                	jmp    8002d9 <vprintfmt+0x59>
  800359:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80035c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80035f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800363:	0f 89 70 ff ff ff    	jns    8002d9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800369:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80036c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800376:	e9 5e ff ff ff       	jmp    8002d9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80037b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800381:	e9 53 ff ff ff       	jmp    8002d9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800386:	8b 45 14             	mov    0x14(%ebp),%eax
  800389:	8d 50 04             	lea    0x4(%eax),%edx
  80038c:	89 55 14             	mov    %edx,0x14(%ebp)
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	53                   	push   %ebx
  800393:	ff 30                	pushl  (%eax)
  800395:	ff d6                	call   *%esi
			break;
  800397:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039d:	e9 04 ff ff ff       	jmp    8002a6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8d 50 04             	lea    0x4(%eax),%edx
  8003a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	99                   	cltd   
  8003ae:	31 d0                	xor    %edx,%eax
  8003b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b2:	83 f8 07             	cmp    $0x7,%eax
  8003b5:	7f 0b                	jg     8003c2 <vprintfmt+0x142>
  8003b7:	8b 14 85 e0 0f 80 00 	mov    0x800fe0(,%eax,4),%edx
  8003be:	85 d2                	test   %edx,%edx
  8003c0:	75 18                	jne    8003da <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003c2:	50                   	push   %eax
  8003c3:	68 f0 0d 80 00       	push   $0x800df0
  8003c8:	53                   	push   %ebx
  8003c9:	56                   	push   %esi
  8003ca:	e8 94 fe ff ff       	call   800263 <printfmt>
  8003cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d5:	e9 cc fe ff ff       	jmp    8002a6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003da:	52                   	push   %edx
  8003db:	68 f9 0d 80 00       	push   $0x800df9
  8003e0:	53                   	push   %ebx
  8003e1:	56                   	push   %esi
  8003e2:	e8 7c fe ff ff       	call   800263 <printfmt>
  8003e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ed:	e9 b4 fe ff ff       	jmp    8002a6 <vprintfmt+0x26>
  8003f2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f8:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8d 50 04             	lea    0x4(%eax),%edx
  800401:	89 55 14             	mov    %edx,0x14(%ebp)
  800404:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800406:	85 ff                	test   %edi,%edi
  800408:	ba e9 0d 80 00       	mov    $0x800de9,%edx
  80040d:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800410:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800414:	0f 84 92 00 00 00    	je     8004ac <vprintfmt+0x22c>
  80041a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80041e:	0f 8e 96 00 00 00    	jle    8004ba <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800424:	83 ec 08             	sub    $0x8,%esp
  800427:	51                   	push   %ecx
  800428:	57                   	push   %edi
  800429:	e8 86 02 00 00       	call   8006b4 <strnlen>
  80042e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800431:	29 c1                	sub    %eax,%ecx
  800433:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800436:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800439:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80043d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800440:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800443:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	eb 0f                	jmp    800456 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800447:	83 ec 08             	sub    $0x8,%esp
  80044a:	53                   	push   %ebx
  80044b:	ff 75 e0             	pushl  -0x20(%ebp)
  80044e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800450:	83 ef 01             	sub    $0x1,%edi
  800453:	83 c4 10             	add    $0x10,%esp
  800456:	85 ff                	test   %edi,%edi
  800458:	7f ed                	jg     800447 <vprintfmt+0x1c7>
  80045a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80045d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800460:	85 c9                	test   %ecx,%ecx
  800462:	b8 00 00 00 00       	mov    $0x0,%eax
  800467:	0f 49 c1             	cmovns %ecx,%eax
  80046a:	29 c1                	sub    %eax,%ecx
  80046c:	89 75 08             	mov    %esi,0x8(%ebp)
  80046f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800472:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800475:	89 cb                	mov    %ecx,%ebx
  800477:	eb 4d                	jmp    8004c6 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800479:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047d:	74 1b                	je     80049a <vprintfmt+0x21a>
  80047f:	0f be c0             	movsbl %al,%eax
  800482:	83 e8 20             	sub    $0x20,%eax
  800485:	83 f8 5e             	cmp    $0x5e,%eax
  800488:	76 10                	jbe    80049a <vprintfmt+0x21a>
					putch('?', putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	ff 75 0c             	pushl  0xc(%ebp)
  800490:	6a 3f                	push   $0x3f
  800492:	ff 55 08             	call   *0x8(%ebp)
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	eb 0d                	jmp    8004a7 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	ff 75 0c             	pushl  0xc(%ebp)
  8004a0:	52                   	push   %edx
  8004a1:	ff 55 08             	call   *0x8(%ebp)
  8004a4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a7:	83 eb 01             	sub    $0x1,%ebx
  8004aa:	eb 1a                	jmp    8004c6 <vprintfmt+0x246>
  8004ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8004af:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b8:	eb 0c                	jmp    8004c6 <vprintfmt+0x246>
  8004ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c6:	83 c7 01             	add    $0x1,%edi
  8004c9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004cd:	0f be d0             	movsbl %al,%edx
  8004d0:	85 d2                	test   %edx,%edx
  8004d2:	74 23                	je     8004f7 <vprintfmt+0x277>
  8004d4:	85 f6                	test   %esi,%esi
  8004d6:	78 a1                	js     800479 <vprintfmt+0x1f9>
  8004d8:	83 ee 01             	sub    $0x1,%esi
  8004db:	79 9c                	jns    800479 <vprintfmt+0x1f9>
  8004dd:	89 df                	mov    %ebx,%edi
  8004df:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e5:	eb 18                	jmp    8004ff <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	6a 20                	push   $0x20
  8004ed:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ef:	83 ef 01             	sub    $0x1,%edi
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	eb 08                	jmp    8004ff <vprintfmt+0x27f>
  8004f7:	89 df                	mov    %ebx,%edi
  8004f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ff:	85 ff                	test   %edi,%edi
  800501:	7f e4                	jg     8004e7 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800506:	e9 9b fd ff ff       	jmp    8002a6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050b:	83 fa 01             	cmp    $0x1,%edx
  80050e:	7e 16                	jle    800526 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 50 08             	lea    0x8(%eax),%edx
  800516:	89 55 14             	mov    %edx,0x14(%ebp)
  800519:	8b 50 04             	mov    0x4(%eax),%edx
  80051c:	8b 00                	mov    (%eax),%eax
  80051e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800521:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800524:	eb 32                	jmp    800558 <vprintfmt+0x2d8>
	else if (lflag)
  800526:	85 d2                	test   %edx,%edx
  800528:	74 18                	je     800542 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8d 50 04             	lea    0x4(%eax),%edx
  800530:	89 55 14             	mov    %edx,0x14(%ebp)
  800533:	8b 00                	mov    (%eax),%eax
  800535:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800538:	89 c1                	mov    %eax,%ecx
  80053a:	c1 f9 1f             	sar    $0x1f,%ecx
  80053d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800540:	eb 16                	jmp    800558 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800550:	89 c1                	mov    %eax,%ecx
  800552:	c1 f9 1f             	sar    $0x1f,%ecx
  800555:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800558:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80055b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800563:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800567:	79 74                	jns    8005dd <vprintfmt+0x35d>
				putch('-', putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	53                   	push   %ebx
  80056d:	6a 2d                	push   $0x2d
  80056f:	ff d6                	call   *%esi
				num = -(long long) num;
  800571:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800574:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800577:	f7 d8                	neg    %eax
  800579:	83 d2 00             	adc    $0x0,%edx
  80057c:	f7 da                	neg    %edx
  80057e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800581:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800586:	eb 55                	jmp    8005dd <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800588:	8d 45 14             	lea    0x14(%ebp),%eax
  80058b:	e8 7c fc ff ff       	call   80020c <getuint>
			base = 10;
  800590:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800595:	eb 46                	jmp    8005dd <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800597:	8d 45 14             	lea    0x14(%ebp),%eax
  80059a:	e8 6d fc ff ff       	call   80020c <getuint>
                        base = 8;
  80059f:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005a4:	eb 37                	jmp    8005dd <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 30                	push   $0x30
  8005ac:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ae:	83 c4 08             	add    $0x8,%esp
  8005b1:	53                   	push   %ebx
  8005b2:	6a 78                	push   $0x78
  8005b4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 50 04             	lea    0x4(%eax),%edx
  8005bc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005ce:	eb 0d                	jmp    8005dd <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d3:	e8 34 fc ff ff       	call   80020c <getuint>
			base = 16;
  8005d8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005dd:	83 ec 0c             	sub    $0xc,%esp
  8005e0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005e4:	57                   	push   %edi
  8005e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e8:	51                   	push   %ecx
  8005e9:	52                   	push   %edx
  8005ea:	50                   	push   %eax
  8005eb:	89 da                	mov    %ebx,%edx
  8005ed:	89 f0                	mov    %esi,%eax
  8005ef:	e8 6e fb ff ff       	call   800162 <printnum>
			break;
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fa:	e9 a7 fc ff ff       	jmp    8002a6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	51                   	push   %ecx
  800604:	ff d6                	call   *%esi
			break;
  800606:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800609:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80060c:	e9 95 fc ff ff       	jmp    8002a6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 25                	push   $0x25
  800617:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	eb 03                	jmp    800621 <vprintfmt+0x3a1>
  80061e:	83 ef 01             	sub    $0x1,%edi
  800621:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800625:	75 f7                	jne    80061e <vprintfmt+0x39e>
  800627:	e9 7a fc ff ff       	jmp    8002a6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80062c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062f:	5b                   	pop    %ebx
  800630:	5e                   	pop    %esi
  800631:	5f                   	pop    %edi
  800632:	5d                   	pop    %ebp
  800633:	c3                   	ret    

00800634 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800634:	55                   	push   %ebp
  800635:	89 e5                	mov    %esp,%ebp
  800637:	83 ec 18             	sub    $0x18,%esp
  80063a:	8b 45 08             	mov    0x8(%ebp),%eax
  80063d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800640:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800643:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800647:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80064a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800651:	85 c0                	test   %eax,%eax
  800653:	74 26                	je     80067b <vsnprintf+0x47>
  800655:	85 d2                	test   %edx,%edx
  800657:	7e 22                	jle    80067b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800659:	ff 75 14             	pushl  0x14(%ebp)
  80065c:	ff 75 10             	pushl  0x10(%ebp)
  80065f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800662:	50                   	push   %eax
  800663:	68 46 02 80 00       	push   $0x800246
  800668:	e8 13 fc ff ff       	call   800280 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80066d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800670:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800673:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	eb 05                	jmp    800680 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80067b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800680:	c9                   	leave  
  800681:	c3                   	ret    

00800682 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
  800685:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800688:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80068b:	50                   	push   %eax
  80068c:	ff 75 10             	pushl  0x10(%ebp)
  80068f:	ff 75 0c             	pushl  0xc(%ebp)
  800692:	ff 75 08             	pushl  0x8(%ebp)
  800695:	e8 9a ff ff ff       	call   800634 <vsnprintf>
	va_end(ap);

	return rc;
}
  80069a:	c9                   	leave  
  80069b:	c3                   	ret    

0080069c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a7:	eb 03                	jmp    8006ac <strlen+0x10>
		n++;
  8006a9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ac:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006b0:	75 f7                	jne    8006a9 <strlen+0xd>
		n++;
	return n;
}
  8006b2:	5d                   	pop    %ebp
  8006b3:	c3                   	ret    

008006b4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ba:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c2:	eb 03                	jmp    8006c7 <strnlen+0x13>
		n++;
  8006c4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c7:	39 c2                	cmp    %eax,%edx
  8006c9:	74 08                	je     8006d3 <strnlen+0x1f>
  8006cb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006cf:	75 f3                	jne    8006c4 <strnlen+0x10>
  8006d1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	53                   	push   %ebx
  8006d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006df:	89 c2                	mov    %eax,%edx
  8006e1:	83 c2 01             	add    $0x1,%edx
  8006e4:	83 c1 01             	add    $0x1,%ecx
  8006e7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006eb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006ee:	84 db                	test   %bl,%bl
  8006f0:	75 ef                	jne    8006e1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006f2:	5b                   	pop    %ebx
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	53                   	push   %ebx
  8006f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006fc:	53                   	push   %ebx
  8006fd:	e8 9a ff ff ff       	call   80069c <strlen>
  800702:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800705:	ff 75 0c             	pushl  0xc(%ebp)
  800708:	01 d8                	add    %ebx,%eax
  80070a:	50                   	push   %eax
  80070b:	e8 c5 ff ff ff       	call   8006d5 <strcpy>
	return dst;
}
  800710:	89 d8                	mov    %ebx,%eax
  800712:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800715:	c9                   	leave  
  800716:	c3                   	ret    

00800717 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	56                   	push   %esi
  80071b:	53                   	push   %ebx
  80071c:	8b 75 08             	mov    0x8(%ebp),%esi
  80071f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800722:	89 f3                	mov    %esi,%ebx
  800724:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800727:	89 f2                	mov    %esi,%edx
  800729:	eb 0f                	jmp    80073a <strncpy+0x23>
		*dst++ = *src;
  80072b:	83 c2 01             	add    $0x1,%edx
  80072e:	0f b6 01             	movzbl (%ecx),%eax
  800731:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800734:	80 39 01             	cmpb   $0x1,(%ecx)
  800737:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073a:	39 da                	cmp    %ebx,%edx
  80073c:	75 ed                	jne    80072b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80073e:	89 f0                	mov    %esi,%eax
  800740:	5b                   	pop    %ebx
  800741:	5e                   	pop    %esi
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	56                   	push   %esi
  800748:	53                   	push   %ebx
  800749:	8b 75 08             	mov    0x8(%ebp),%esi
  80074c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074f:	8b 55 10             	mov    0x10(%ebp),%edx
  800752:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800754:	85 d2                	test   %edx,%edx
  800756:	74 21                	je     800779 <strlcpy+0x35>
  800758:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80075c:	89 f2                	mov    %esi,%edx
  80075e:	eb 09                	jmp    800769 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800760:	83 c2 01             	add    $0x1,%edx
  800763:	83 c1 01             	add    $0x1,%ecx
  800766:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800769:	39 c2                	cmp    %eax,%edx
  80076b:	74 09                	je     800776 <strlcpy+0x32>
  80076d:	0f b6 19             	movzbl (%ecx),%ebx
  800770:	84 db                	test   %bl,%bl
  800772:	75 ec                	jne    800760 <strlcpy+0x1c>
  800774:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800776:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800779:	29 f0                	sub    %esi,%eax
}
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800788:	eb 06                	jmp    800790 <strcmp+0x11>
		p++, q++;
  80078a:	83 c1 01             	add    $0x1,%ecx
  80078d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800790:	0f b6 01             	movzbl (%ecx),%eax
  800793:	84 c0                	test   %al,%al
  800795:	74 04                	je     80079b <strcmp+0x1c>
  800797:	3a 02                	cmp    (%edx),%al
  800799:	74 ef                	je     80078a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80079b:	0f b6 c0             	movzbl %al,%eax
  80079e:	0f b6 12             	movzbl (%edx),%edx
  8007a1:	29 d0                	sub    %edx,%eax
}
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	53                   	push   %ebx
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007af:	89 c3                	mov    %eax,%ebx
  8007b1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b4:	eb 06                	jmp    8007bc <strncmp+0x17>
		n--, p++, q++;
  8007b6:	83 c0 01             	add    $0x1,%eax
  8007b9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007bc:	39 d8                	cmp    %ebx,%eax
  8007be:	74 15                	je     8007d5 <strncmp+0x30>
  8007c0:	0f b6 08             	movzbl (%eax),%ecx
  8007c3:	84 c9                	test   %cl,%cl
  8007c5:	74 04                	je     8007cb <strncmp+0x26>
  8007c7:	3a 0a                	cmp    (%edx),%cl
  8007c9:	74 eb                	je     8007b6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cb:	0f b6 00             	movzbl (%eax),%eax
  8007ce:	0f b6 12             	movzbl (%edx),%edx
  8007d1:	29 d0                	sub    %edx,%eax
  8007d3:	eb 05                	jmp    8007da <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007da:	5b                   	pop    %ebx
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e7:	eb 07                	jmp    8007f0 <strchr+0x13>
		if (*s == c)
  8007e9:	38 ca                	cmp    %cl,%dl
  8007eb:	74 0f                	je     8007fc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007ed:	83 c0 01             	add    $0x1,%eax
  8007f0:	0f b6 10             	movzbl (%eax),%edx
  8007f3:	84 d2                	test   %dl,%dl
  8007f5:	75 f2                	jne    8007e9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800808:	eb 03                	jmp    80080d <strfind+0xf>
  80080a:	83 c0 01             	add    $0x1,%eax
  80080d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800810:	84 d2                	test   %dl,%dl
  800812:	74 04                	je     800818 <strfind+0x1a>
  800814:	38 ca                	cmp    %cl,%dl
  800816:	75 f2                	jne    80080a <strfind+0xc>
			break;
	return (char *) s;
}
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	57                   	push   %edi
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 7d 08             	mov    0x8(%ebp),%edi
  800823:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800826:	85 c9                	test   %ecx,%ecx
  800828:	74 36                	je     800860 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80082a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800830:	75 28                	jne    80085a <memset+0x40>
  800832:	f6 c1 03             	test   $0x3,%cl
  800835:	75 23                	jne    80085a <memset+0x40>
		c &= 0xFF;
  800837:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80083b:	89 d3                	mov    %edx,%ebx
  80083d:	c1 e3 08             	shl    $0x8,%ebx
  800840:	89 d6                	mov    %edx,%esi
  800842:	c1 e6 18             	shl    $0x18,%esi
  800845:	89 d0                	mov    %edx,%eax
  800847:	c1 e0 10             	shl    $0x10,%eax
  80084a:	09 f0                	or     %esi,%eax
  80084c:	09 c2                	or     %eax,%edx
  80084e:	89 d0                	mov    %edx,%eax
  800850:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800852:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800855:	fc                   	cld    
  800856:	f3 ab                	rep stos %eax,%es:(%edi)
  800858:	eb 06                	jmp    800860 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80085a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085d:	fc                   	cld    
  80085e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800860:	89 f8                	mov    %edi,%eax
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5f                   	pop    %edi
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	57                   	push   %edi
  80086b:	56                   	push   %esi
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800872:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800875:	39 c6                	cmp    %eax,%esi
  800877:	73 35                	jae    8008ae <memmove+0x47>
  800879:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80087c:	39 d0                	cmp    %edx,%eax
  80087e:	73 2e                	jae    8008ae <memmove+0x47>
		s += n;
		d += n;
  800880:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800883:	89 d6                	mov    %edx,%esi
  800885:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800887:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088d:	75 13                	jne    8008a2 <memmove+0x3b>
  80088f:	f6 c1 03             	test   $0x3,%cl
  800892:	75 0e                	jne    8008a2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800894:	83 ef 04             	sub    $0x4,%edi
  800897:	8d 72 fc             	lea    -0x4(%edx),%esi
  80089a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80089d:	fd                   	std    
  80089e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a0:	eb 09                	jmp    8008ab <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008a2:	83 ef 01             	sub    $0x1,%edi
  8008a5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008a8:	fd                   	std    
  8008a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ab:	fc                   	cld    
  8008ac:	eb 1d                	jmp    8008cb <memmove+0x64>
  8008ae:	89 f2                	mov    %esi,%edx
  8008b0:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b2:	f6 c2 03             	test   $0x3,%dl
  8008b5:	75 0f                	jne    8008c6 <memmove+0x5f>
  8008b7:	f6 c1 03             	test   $0x3,%cl
  8008ba:	75 0a                	jne    8008c6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008bc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008bf:	89 c7                	mov    %eax,%edi
  8008c1:	fc                   	cld    
  8008c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c4:	eb 05                	jmp    8008cb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c6:	89 c7                	mov    %eax,%edi
  8008c8:	fc                   	cld    
  8008c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008d2:	ff 75 10             	pushl  0x10(%ebp)
  8008d5:	ff 75 0c             	pushl  0xc(%ebp)
  8008d8:	ff 75 08             	pushl  0x8(%ebp)
  8008db:	e8 87 ff ff ff       	call   800867 <memmove>
}
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    

008008e2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 c6                	mov    %eax,%esi
  8008ef:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f2:	eb 1a                	jmp    80090e <memcmp+0x2c>
		if (*s1 != *s2)
  8008f4:	0f b6 08             	movzbl (%eax),%ecx
  8008f7:	0f b6 1a             	movzbl (%edx),%ebx
  8008fa:	38 d9                	cmp    %bl,%cl
  8008fc:	74 0a                	je     800908 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008fe:	0f b6 c1             	movzbl %cl,%eax
  800901:	0f b6 db             	movzbl %bl,%ebx
  800904:	29 d8                	sub    %ebx,%eax
  800906:	eb 0f                	jmp    800917 <memcmp+0x35>
		s1++, s2++;
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090e:	39 f0                	cmp    %esi,%eax
  800910:	75 e2                	jne    8008f4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800924:	89 c2                	mov    %eax,%edx
  800926:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800929:	eb 07                	jmp    800932 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80092b:	38 08                	cmp    %cl,(%eax)
  80092d:	74 07                	je     800936 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80092f:	83 c0 01             	add    $0x1,%eax
  800932:	39 d0                	cmp    %edx,%eax
  800934:	72 f5                	jb     80092b <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800941:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800944:	eb 03                	jmp    800949 <strtol+0x11>
		s++;
  800946:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800949:	0f b6 01             	movzbl (%ecx),%eax
  80094c:	3c 09                	cmp    $0x9,%al
  80094e:	74 f6                	je     800946 <strtol+0xe>
  800950:	3c 20                	cmp    $0x20,%al
  800952:	74 f2                	je     800946 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800954:	3c 2b                	cmp    $0x2b,%al
  800956:	75 0a                	jne    800962 <strtol+0x2a>
		s++;
  800958:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80095b:	bf 00 00 00 00       	mov    $0x0,%edi
  800960:	eb 10                	jmp    800972 <strtol+0x3a>
  800962:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800967:	3c 2d                	cmp    $0x2d,%al
  800969:	75 07                	jne    800972 <strtol+0x3a>
		s++, neg = 1;
  80096b:	8d 49 01             	lea    0x1(%ecx),%ecx
  80096e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800972:	85 db                	test   %ebx,%ebx
  800974:	0f 94 c0             	sete   %al
  800977:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80097d:	75 19                	jne    800998 <strtol+0x60>
  80097f:	80 39 30             	cmpb   $0x30,(%ecx)
  800982:	75 14                	jne    800998 <strtol+0x60>
  800984:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800988:	0f 85 82 00 00 00    	jne    800a10 <strtol+0xd8>
		s += 2, base = 16;
  80098e:	83 c1 02             	add    $0x2,%ecx
  800991:	bb 10 00 00 00       	mov    $0x10,%ebx
  800996:	eb 16                	jmp    8009ae <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800998:	84 c0                	test   %al,%al
  80099a:	74 12                	je     8009ae <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80099c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009a1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a4:	75 08                	jne    8009ae <strtol+0x76>
		s++, base = 8;
  8009a6:	83 c1 01             	add    $0x1,%ecx
  8009a9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b6:	0f b6 11             	movzbl (%ecx),%edx
  8009b9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009bc:	89 f3                	mov    %esi,%ebx
  8009be:	80 fb 09             	cmp    $0x9,%bl
  8009c1:	77 08                	ja     8009cb <strtol+0x93>
			dig = *s - '0';
  8009c3:	0f be d2             	movsbl %dl,%edx
  8009c6:	83 ea 30             	sub    $0x30,%edx
  8009c9:	eb 22                	jmp    8009ed <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009cb:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ce:	89 f3                	mov    %esi,%ebx
  8009d0:	80 fb 19             	cmp    $0x19,%bl
  8009d3:	77 08                	ja     8009dd <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009d5:	0f be d2             	movsbl %dl,%edx
  8009d8:	83 ea 57             	sub    $0x57,%edx
  8009db:	eb 10                	jmp    8009ed <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009dd:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009e0:	89 f3                	mov    %esi,%ebx
  8009e2:	80 fb 19             	cmp    $0x19,%bl
  8009e5:	77 16                	ja     8009fd <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009e7:	0f be d2             	movsbl %dl,%edx
  8009ea:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009ed:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009f0:	7d 0f                	jge    800a01 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009f2:	83 c1 01             	add    $0x1,%ecx
  8009f5:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009fb:	eb b9                	jmp    8009b6 <strtol+0x7e>
  8009fd:	89 c2                	mov    %eax,%edx
  8009ff:	eb 02                	jmp    800a03 <strtol+0xcb>
  800a01:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a03:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a07:	74 0d                	je     800a16 <strtol+0xde>
		*endptr = (char *) s;
  800a09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0c:	89 0e                	mov    %ecx,(%esi)
  800a0e:	eb 06                	jmp    800a16 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a10:	84 c0                	test   %al,%al
  800a12:	75 92                	jne    8009a6 <strtol+0x6e>
  800a14:	eb 98                	jmp    8009ae <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a16:	f7 da                	neg    %edx
  800a18:	85 ff                	test   %edi,%edi
  800a1a:	0f 45 c2             	cmovne %edx,%eax
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5f                   	pop    %edi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a30:	8b 55 08             	mov    0x8(%ebp),%edx
  800a33:	89 c3                	mov    %eax,%ebx
  800a35:	89 c7                	mov    %eax,%edi
  800a37:	89 c6                	mov    %eax,%esi
  800a39:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a3b:	5b                   	pop    %ebx
  800a3c:	5e                   	pop    %esi
  800a3d:	5f                   	pop    %edi
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	57                   	push   %edi
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a46:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4b:	b8 01 00 00 00       	mov    $0x1,%eax
  800a50:	89 d1                	mov    %edx,%ecx
  800a52:	89 d3                	mov    %edx,%ebx
  800a54:	89 d7                	mov    %edx,%edi
  800a56:	89 d6                	mov    %edx,%esi
  800a58:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a6d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a72:	8b 55 08             	mov    0x8(%ebp),%edx
  800a75:	89 cb                	mov    %ecx,%ebx
  800a77:	89 cf                	mov    %ecx,%edi
  800a79:	89 ce                	mov    %ecx,%esi
  800a7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a7d:	85 c0                	test   %eax,%eax
  800a7f:	7e 17                	jle    800a98 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a81:	83 ec 0c             	sub    $0xc,%esp
  800a84:	50                   	push   %eax
  800a85:	6a 03                	push   $0x3
  800a87:	68 00 10 80 00       	push   $0x801000
  800a8c:	6a 23                	push   $0x23
  800a8e:	68 1d 10 80 00       	push   $0x80101d
  800a93:	e8 27 00 00 00       	call   800abf <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aab:	b8 02 00 00 00       	mov    $0x2,%eax
  800ab0:	89 d1                	mov    %edx,%ecx
  800ab2:	89 d3                	mov    %edx,%ebx
  800ab4:	89 d7                	mov    %edx,%edi
  800ab6:	89 d6                	mov    %edx,%esi
  800ab8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ac4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ac7:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800acd:	e8 ce ff ff ff       	call   800aa0 <sys_getenvid>
  800ad2:	83 ec 0c             	sub    $0xc,%esp
  800ad5:	ff 75 0c             	pushl  0xc(%ebp)
  800ad8:	ff 75 08             	pushl  0x8(%ebp)
  800adb:	56                   	push   %esi
  800adc:	50                   	push   %eax
  800add:	68 2c 10 80 00       	push   $0x80102c
  800ae2:	e8 67 f6 ff ff       	call   80014e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ae7:	83 c4 18             	add    $0x18,%esp
  800aea:	53                   	push   %ebx
  800aeb:	ff 75 10             	pushl  0x10(%ebp)
  800aee:	e8 0a f6 ff ff       	call   8000fd <vcprintf>
	cprintf("\n");
  800af3:	c7 04 24 cc 0d 80 00 	movl   $0x800dcc,(%esp)
  800afa:	e8 4f f6 ff ff       	call   80014e <cprintf>
  800aff:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b02:	cc                   	int3   
  800b03:	eb fd                	jmp    800b02 <_panic+0x43>
  800b05:	66 90                	xchg   %ax,%ax
  800b07:	66 90                	xchg   %ax,%ax
  800b09:	66 90                	xchg   %ax,%ax
  800b0b:	66 90                	xchg   %ax,%ax
  800b0d:	66 90                	xchg   %ax,%ax
  800b0f:	90                   	nop

00800b10 <__udivdi3>:
  800b10:	55                   	push   %ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	83 ec 10             	sub    $0x10,%esp
  800b16:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800b1a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800b1e:	8b 74 24 24          	mov    0x24(%esp),%esi
  800b22:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b26:	85 d2                	test   %edx,%edx
  800b28:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b2c:	89 34 24             	mov    %esi,(%esp)
  800b2f:	89 c8                	mov    %ecx,%eax
  800b31:	75 35                	jne    800b68 <__udivdi3+0x58>
  800b33:	39 f1                	cmp    %esi,%ecx
  800b35:	0f 87 bd 00 00 00    	ja     800bf8 <__udivdi3+0xe8>
  800b3b:	85 c9                	test   %ecx,%ecx
  800b3d:	89 cd                	mov    %ecx,%ebp
  800b3f:	75 0b                	jne    800b4c <__udivdi3+0x3c>
  800b41:	b8 01 00 00 00       	mov    $0x1,%eax
  800b46:	31 d2                	xor    %edx,%edx
  800b48:	f7 f1                	div    %ecx
  800b4a:	89 c5                	mov    %eax,%ebp
  800b4c:	89 f0                	mov    %esi,%eax
  800b4e:	31 d2                	xor    %edx,%edx
  800b50:	f7 f5                	div    %ebp
  800b52:	89 c6                	mov    %eax,%esi
  800b54:	89 f8                	mov    %edi,%eax
  800b56:	f7 f5                	div    %ebp
  800b58:	89 f2                	mov    %esi,%edx
  800b5a:	83 c4 10             	add    $0x10,%esp
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    
  800b61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b68:	3b 14 24             	cmp    (%esp),%edx
  800b6b:	77 7b                	ja     800be8 <__udivdi3+0xd8>
  800b6d:	0f bd f2             	bsr    %edx,%esi
  800b70:	83 f6 1f             	xor    $0x1f,%esi
  800b73:	0f 84 97 00 00 00    	je     800c10 <__udivdi3+0x100>
  800b79:	bd 20 00 00 00       	mov    $0x20,%ebp
  800b7e:	89 d7                	mov    %edx,%edi
  800b80:	89 f1                	mov    %esi,%ecx
  800b82:	29 f5                	sub    %esi,%ebp
  800b84:	d3 e7                	shl    %cl,%edi
  800b86:	89 c2                	mov    %eax,%edx
  800b88:	89 e9                	mov    %ebp,%ecx
  800b8a:	d3 ea                	shr    %cl,%edx
  800b8c:	89 f1                	mov    %esi,%ecx
  800b8e:	09 fa                	or     %edi,%edx
  800b90:	8b 3c 24             	mov    (%esp),%edi
  800b93:	d3 e0                	shl    %cl,%eax
  800b95:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b99:	89 e9                	mov    %ebp,%ecx
  800b9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b9f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ba3:	89 fa                	mov    %edi,%edx
  800ba5:	d3 ea                	shr    %cl,%edx
  800ba7:	89 f1                	mov    %esi,%ecx
  800ba9:	d3 e7                	shl    %cl,%edi
  800bab:	89 e9                	mov    %ebp,%ecx
  800bad:	d3 e8                	shr    %cl,%eax
  800baf:	09 c7                	or     %eax,%edi
  800bb1:	89 f8                	mov    %edi,%eax
  800bb3:	f7 74 24 08          	divl   0x8(%esp)
  800bb7:	89 d5                	mov    %edx,%ebp
  800bb9:	89 c7                	mov    %eax,%edi
  800bbb:	f7 64 24 0c          	mull   0xc(%esp)
  800bbf:	39 d5                	cmp    %edx,%ebp
  800bc1:	89 14 24             	mov    %edx,(%esp)
  800bc4:	72 11                	jb     800bd7 <__udivdi3+0xc7>
  800bc6:	8b 54 24 04          	mov    0x4(%esp),%edx
  800bca:	89 f1                	mov    %esi,%ecx
  800bcc:	d3 e2                	shl    %cl,%edx
  800bce:	39 c2                	cmp    %eax,%edx
  800bd0:	73 5e                	jae    800c30 <__udivdi3+0x120>
  800bd2:	3b 2c 24             	cmp    (%esp),%ebp
  800bd5:	75 59                	jne    800c30 <__udivdi3+0x120>
  800bd7:	8d 47 ff             	lea    -0x1(%edi),%eax
  800bda:	31 f6                	xor    %esi,%esi
  800bdc:	89 f2                	mov    %esi,%edx
  800bde:	83 c4 10             	add    $0x10,%esp
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    
  800be5:	8d 76 00             	lea    0x0(%esi),%esi
  800be8:	31 f6                	xor    %esi,%esi
  800bea:	31 c0                	xor    %eax,%eax
  800bec:	89 f2                	mov    %esi,%edx
  800bee:	83 c4 10             	add    $0x10,%esp
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    
  800bf5:	8d 76 00             	lea    0x0(%esi),%esi
  800bf8:	89 f2                	mov    %esi,%edx
  800bfa:	31 f6                	xor    %esi,%esi
  800bfc:	89 f8                	mov    %edi,%eax
  800bfe:	f7 f1                	div    %ecx
  800c00:	89 f2                	mov    %esi,%edx
  800c02:	83 c4 10             	add    $0x10,%esp
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    
  800c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c10:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800c14:	76 0b                	jbe    800c21 <__udivdi3+0x111>
  800c16:	31 c0                	xor    %eax,%eax
  800c18:	3b 14 24             	cmp    (%esp),%edx
  800c1b:	0f 83 37 ff ff ff    	jae    800b58 <__udivdi3+0x48>
  800c21:	b8 01 00 00 00       	mov    $0x1,%eax
  800c26:	e9 2d ff ff ff       	jmp    800b58 <__udivdi3+0x48>
  800c2b:	90                   	nop
  800c2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c30:	89 f8                	mov    %edi,%eax
  800c32:	31 f6                	xor    %esi,%esi
  800c34:	e9 1f ff ff ff       	jmp    800b58 <__udivdi3+0x48>
  800c39:	66 90                	xchg   %ax,%ax
  800c3b:	66 90                	xchg   %ax,%ax
  800c3d:	66 90                	xchg   %ax,%ax
  800c3f:	90                   	nop

00800c40 <__umoddi3>:
  800c40:	55                   	push   %ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	83 ec 20             	sub    $0x20,%esp
  800c46:	8b 44 24 34          	mov    0x34(%esp),%eax
  800c4a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c4e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c52:	89 c6                	mov    %eax,%esi
  800c54:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c58:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c5c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800c60:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c64:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800c68:	89 74 24 18          	mov    %esi,0x18(%esp)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	89 c2                	mov    %eax,%edx
  800c70:	75 1e                	jne    800c90 <__umoddi3+0x50>
  800c72:	39 f7                	cmp    %esi,%edi
  800c74:	76 52                	jbe    800cc8 <__umoddi3+0x88>
  800c76:	89 c8                	mov    %ecx,%eax
  800c78:	89 f2                	mov    %esi,%edx
  800c7a:	f7 f7                	div    %edi
  800c7c:	89 d0                	mov    %edx,%eax
  800c7e:	31 d2                	xor    %edx,%edx
  800c80:	83 c4 20             	add    $0x20,%esp
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    
  800c87:	89 f6                	mov    %esi,%esi
  800c89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800c90:	39 f0                	cmp    %esi,%eax
  800c92:	77 5c                	ja     800cf0 <__umoddi3+0xb0>
  800c94:	0f bd e8             	bsr    %eax,%ebp
  800c97:	83 f5 1f             	xor    $0x1f,%ebp
  800c9a:	75 64                	jne    800d00 <__umoddi3+0xc0>
  800c9c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800ca0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800ca4:	0f 86 f6 00 00 00    	jbe    800da0 <__umoddi3+0x160>
  800caa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800cae:	0f 82 ec 00 00 00    	jb     800da0 <__umoddi3+0x160>
  800cb4:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cb8:	8b 54 24 18          	mov    0x18(%esp),%edx
  800cbc:	83 c4 20             	add    $0x20,%esp
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    
  800cc3:	90                   	nop
  800cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cc8:	85 ff                	test   %edi,%edi
  800cca:	89 fd                	mov    %edi,%ebp
  800ccc:	75 0b                	jne    800cd9 <__umoddi3+0x99>
  800cce:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd3:	31 d2                	xor    %edx,%edx
  800cd5:	f7 f7                	div    %edi
  800cd7:	89 c5                	mov    %eax,%ebp
  800cd9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800cdd:	31 d2                	xor    %edx,%edx
  800cdf:	f7 f5                	div    %ebp
  800ce1:	89 c8                	mov    %ecx,%eax
  800ce3:	f7 f5                	div    %ebp
  800ce5:	eb 95                	jmp    800c7c <__umoddi3+0x3c>
  800ce7:	89 f6                	mov    %esi,%esi
  800ce9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800cf0:	89 c8                	mov    %ecx,%eax
  800cf2:	89 f2                	mov    %esi,%edx
  800cf4:	83 c4 20             	add    $0x20,%esp
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    
  800cfb:	90                   	nop
  800cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d00:	b8 20 00 00 00       	mov    $0x20,%eax
  800d05:	89 e9                	mov    %ebp,%ecx
  800d07:	29 e8                	sub    %ebp,%eax
  800d09:	d3 e2                	shl    %cl,%edx
  800d0b:	89 c7                	mov    %eax,%edi
  800d0d:	89 44 24 18          	mov    %eax,0x18(%esp)
  800d11:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d15:	89 f9                	mov    %edi,%ecx
  800d17:	d3 e8                	shr    %cl,%eax
  800d19:	89 c1                	mov    %eax,%ecx
  800d1b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d1f:	09 d1                	or     %edx,%ecx
  800d21:	89 fa                	mov    %edi,%edx
  800d23:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d27:	89 e9                	mov    %ebp,%ecx
  800d29:	d3 e0                	shl    %cl,%eax
  800d2b:	89 f9                	mov    %edi,%ecx
  800d2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d31:	89 f0                	mov    %esi,%eax
  800d33:	d3 e8                	shr    %cl,%eax
  800d35:	89 e9                	mov    %ebp,%ecx
  800d37:	89 c7                	mov    %eax,%edi
  800d39:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d3d:	d3 e6                	shl    %cl,%esi
  800d3f:	89 d1                	mov    %edx,%ecx
  800d41:	89 fa                	mov    %edi,%edx
  800d43:	d3 e8                	shr    %cl,%eax
  800d45:	89 e9                	mov    %ebp,%ecx
  800d47:	09 f0                	or     %esi,%eax
  800d49:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800d4d:	f7 74 24 10          	divl   0x10(%esp)
  800d51:	d3 e6                	shl    %cl,%esi
  800d53:	89 d1                	mov    %edx,%ecx
  800d55:	f7 64 24 0c          	mull   0xc(%esp)
  800d59:	39 d1                	cmp    %edx,%ecx
  800d5b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800d5f:	89 d7                	mov    %edx,%edi
  800d61:	89 c6                	mov    %eax,%esi
  800d63:	72 0a                	jb     800d6f <__umoddi3+0x12f>
  800d65:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800d69:	73 10                	jae    800d7b <__umoddi3+0x13b>
  800d6b:	39 d1                	cmp    %edx,%ecx
  800d6d:	75 0c                	jne    800d7b <__umoddi3+0x13b>
  800d6f:	89 d7                	mov    %edx,%edi
  800d71:	89 c6                	mov    %eax,%esi
  800d73:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800d77:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800d7b:	89 ca                	mov    %ecx,%edx
  800d7d:	89 e9                	mov    %ebp,%ecx
  800d7f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d83:	29 f0                	sub    %esi,%eax
  800d85:	19 fa                	sbb    %edi,%edx
  800d87:	d3 e8                	shr    %cl,%eax
  800d89:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800d8e:	89 d7                	mov    %edx,%edi
  800d90:	d3 e7                	shl    %cl,%edi
  800d92:	89 e9                	mov    %ebp,%ecx
  800d94:	09 f8                	or     %edi,%eax
  800d96:	d3 ea                	shr    %cl,%edx
  800d98:	83 c4 20             	add    $0x20,%esp
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    
  800d9f:	90                   	nop
  800da0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800da4:	29 f9                	sub    %edi,%ecx
  800da6:	19 c6                	sbb    %eax,%esi
  800da8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800dac:	89 74 24 18          	mov    %esi,0x18(%esp)
  800db0:	e9 ff fe ff ff       	jmp    800cb4 <__umoddi3+0x74>
