
obj/user/faultreadkernel.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
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
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 00 1e 80 00       	push   $0x801e00
  800044:	e8 f8 00 00 00       	call   800141 <cprintf>
  800049:	83 c4 10             	add    $0x10,%esp
}
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  800059:	e8 35 0a 00 00       	call   800a93 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
  80008a:	83 c4 10             	add    $0x10,%esp
}
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 f0 0d 00 00       	call   800e8f <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 a9 09 00 00       	call   800a52 <sys_env_destroy>
  8000a9:	83 c4 10             	add    $0x10,%esp
}
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b8:	8b 13                	mov    (%ebx),%edx
  8000ba:	8d 42 01             	lea    0x1(%edx),%eax
  8000bd:	89 03                	mov    %eax,(%ebx)
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 1a                	jne    8000e7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 37 09 00 00       	call   800a15 <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800100:	00 00 00 
	b.cnt = 0;
  800103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	ff 75 08             	pushl  0x8(%ebp)
  800113:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800119:	50                   	push   %eax
  80011a:	68 ae 00 80 00       	push   $0x8000ae
  80011f:	e8 4f 01 00 00       	call   800273 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 dc 08 00 00       	call   800a15 <sys_cputs>

	return b.cnt;
}
  800139:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800147:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014a:	50                   	push   %eax
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	e8 9d ff ff ff       	call   8000f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 1c             	sub    $0x1c,%esp
  80015e:	89 c7                	mov    %eax,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	8b 45 08             	mov    0x8(%ebp),%eax
  800165:	8b 55 0c             	mov    0xc(%ebp),%edx
  800168:	89 d1                	mov    %edx,%ecx
  80016a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800170:	8b 45 10             	mov    0x10(%ebp),%eax
  800173:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800176:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800179:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800180:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800183:	72 05                	jb     80018a <printnum+0x35>
  800185:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800188:	77 3e                	ja     8001c8 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	ff 75 18             	pushl  0x18(%ebp)
  800190:	83 eb 01             	sub    $0x1,%ebx
  800193:	53                   	push   %ebx
  800194:	50                   	push   %eax
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019b:	ff 75 e0             	pushl  -0x20(%ebp)
  80019e:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a4:	e8 a7 19 00 00       	call   801b50 <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	89 f8                	mov    %edi,%eax
  8001b2:	e8 9e ff ff ff       	call   800155 <printnum>
  8001b7:	83 c4 20             	add    $0x20,%esp
  8001ba:	eb 13                	jmp    8001cf <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	ff 75 18             	pushl  0x18(%ebp)
  8001c3:	ff d7                	call   *%edi
  8001c5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	7f ed                	jg     8001bc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cf:	83 ec 08             	sub    $0x8,%esp
  8001d2:	56                   	push   %esi
  8001d3:	83 ec 04             	sub    $0x4,%esp
  8001d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8001df:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e2:	e8 99 1a 00 00       	call   801c80 <__umoddi3>
  8001e7:	83 c4 14             	add    $0x14,%esp
  8001ea:	0f be 80 31 1e 80 00 	movsbl 0x801e31(%eax),%eax
  8001f1:	50                   	push   %eax
  8001f2:	ff d7                	call   *%edi
  8001f4:	83 c4 10             	add    $0x10,%esp
}
  8001f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5f                   	pop    %edi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800202:	83 fa 01             	cmp    $0x1,%edx
  800205:	7e 0e                	jle    800215 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800207:	8b 10                	mov    (%eax),%edx
  800209:	8d 4a 08             	lea    0x8(%edx),%ecx
  80020c:	89 08                	mov    %ecx,(%eax)
  80020e:	8b 02                	mov    (%edx),%eax
  800210:	8b 52 04             	mov    0x4(%edx),%edx
  800213:	eb 22                	jmp    800237 <getuint+0x38>
	else if (lflag)
  800215:	85 d2                	test   %edx,%edx
  800217:	74 10                	je     800229 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800219:	8b 10                	mov    (%eax),%edx
  80021b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021e:	89 08                	mov    %ecx,(%eax)
  800220:	8b 02                	mov    (%edx),%eax
  800222:	ba 00 00 00 00       	mov    $0x0,%edx
  800227:	eb 0e                	jmp    800237 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800229:	8b 10                	mov    (%eax),%edx
  80022b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022e:	89 08                	mov    %ecx,(%eax)
  800230:	8b 02                	mov    (%edx),%eax
  800232:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800237:	5d                   	pop    %ebp
  800238:	c3                   	ret    

00800239 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800243:	8b 10                	mov    (%eax),%edx
  800245:	3b 50 04             	cmp    0x4(%eax),%edx
  800248:	73 0a                	jae    800254 <sprintputch+0x1b>
		*b->buf++ = ch;
  80024a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024d:	89 08                	mov    %ecx,(%eax)
  80024f:	8b 45 08             	mov    0x8(%ebp),%eax
  800252:	88 02                	mov    %al,(%edx)
}
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80025c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025f:	50                   	push   %eax
  800260:	ff 75 10             	pushl  0x10(%ebp)
  800263:	ff 75 0c             	pushl  0xc(%ebp)
  800266:	ff 75 08             	pushl  0x8(%ebp)
  800269:	e8 05 00 00 00       	call   800273 <vprintfmt>
	va_end(ap);
  80026e:	83 c4 10             	add    $0x10,%esp
}
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 2c             	sub    $0x2c,%esp
  80027c:	8b 75 08             	mov    0x8(%ebp),%esi
  80027f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800282:	8b 7d 10             	mov    0x10(%ebp),%edi
  800285:	eb 12                	jmp    800299 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800287:	85 c0                	test   %eax,%eax
  800289:	0f 84 90 03 00 00    	je     80061f <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	53                   	push   %ebx
  800293:	50                   	push   %eax
  800294:	ff d6                	call   *%esi
  800296:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800299:	83 c7 01             	add    $0x1,%edi
  80029c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002a0:	83 f8 25             	cmp    $0x25,%eax
  8002a3:	75 e2                	jne    800287 <vprintfmt+0x14>
  8002a5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002a9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002be:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c3:	eb 07                	jmp    8002cc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002c8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cc:	8d 47 01             	lea    0x1(%edi),%eax
  8002cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d2:	0f b6 07             	movzbl (%edi),%eax
  8002d5:	0f b6 c8             	movzbl %al,%ecx
  8002d8:	83 e8 23             	sub    $0x23,%eax
  8002db:	3c 55                	cmp    $0x55,%al
  8002dd:	0f 87 21 03 00 00    	ja     800604 <vprintfmt+0x391>
  8002e3:	0f b6 c0             	movzbl %al,%eax
  8002e6:	ff 24 85 80 1f 80 00 	jmp    *0x801f80(,%eax,4)
  8002ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f4:	eb d6                	jmp    8002cc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800301:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800304:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800308:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80030b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80030e:	83 fa 09             	cmp    $0x9,%edx
  800311:	77 39                	ja     80034c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800313:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800316:	eb e9                	jmp    800301 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800318:	8b 45 14             	mov    0x14(%ebp),%eax
  80031b:	8d 48 04             	lea    0x4(%eax),%ecx
  80031e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800321:	8b 00                	mov    (%eax),%eax
  800323:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800329:	eb 27                	jmp    800352 <vprintfmt+0xdf>
  80032b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032e:	85 c0                	test   %eax,%eax
  800330:	b9 00 00 00 00       	mov    $0x0,%ecx
  800335:	0f 49 c8             	cmovns %eax,%ecx
  800338:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033e:	eb 8c                	jmp    8002cc <vprintfmt+0x59>
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800343:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80034a:	eb 80                	jmp    8002cc <vprintfmt+0x59>
  80034c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80034f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800352:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800356:	0f 89 70 ff ff ff    	jns    8002cc <vprintfmt+0x59>
				width = precision, precision = -1;
  80035c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80035f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800362:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800369:	e9 5e ff ff ff       	jmp    8002cc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80036e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800374:	e9 53 ff ff ff       	jmp    8002cc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800379:	8b 45 14             	mov    0x14(%ebp),%eax
  80037c:	8d 50 04             	lea    0x4(%eax),%edx
  80037f:	89 55 14             	mov    %edx,0x14(%ebp)
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	53                   	push   %ebx
  800386:	ff 30                	pushl  (%eax)
  800388:	ff d6                	call   *%esi
			break;
  80038a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800390:	e9 04 ff ff ff       	jmp    800299 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800395:	8b 45 14             	mov    0x14(%ebp),%eax
  800398:	8d 50 04             	lea    0x4(%eax),%edx
  80039b:	89 55 14             	mov    %edx,0x14(%ebp)
  80039e:	8b 00                	mov    (%eax),%eax
  8003a0:	99                   	cltd   
  8003a1:	31 d0                	xor    %edx,%eax
  8003a3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a5:	83 f8 0f             	cmp    $0xf,%eax
  8003a8:	7f 0b                	jg     8003b5 <vprintfmt+0x142>
  8003aa:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  8003b1:	85 d2                	test   %edx,%edx
  8003b3:	75 18                	jne    8003cd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003b5:	50                   	push   %eax
  8003b6:	68 49 1e 80 00       	push   $0x801e49
  8003bb:	53                   	push   %ebx
  8003bc:	56                   	push   %esi
  8003bd:	e8 94 fe ff ff       	call   800256 <printfmt>
  8003c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003c8:	e9 cc fe ff ff       	jmp    800299 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003cd:	52                   	push   %edx
  8003ce:	68 31 22 80 00       	push   $0x802231
  8003d3:	53                   	push   %ebx
  8003d4:	56                   	push   %esi
  8003d5:	e8 7c fe ff ff       	call   800256 <printfmt>
  8003da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e0:	e9 b4 fe ff ff       	jmp    800299 <vprintfmt+0x26>
  8003e5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8d 50 04             	lea    0x4(%eax),%edx
  8003f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f9:	85 ff                	test   %edi,%edi
  8003fb:	ba 42 1e 80 00       	mov    $0x801e42,%edx
  800400:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800403:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800407:	0f 84 92 00 00 00    	je     80049f <vprintfmt+0x22c>
  80040d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800411:	0f 8e 96 00 00 00    	jle    8004ad <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	51                   	push   %ecx
  80041b:	57                   	push   %edi
  80041c:	e8 86 02 00 00       	call   8006a7 <strnlen>
  800421:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800424:	29 c1                	sub    %eax,%ecx
  800426:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800429:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800433:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800436:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800438:	eb 0f                	jmp    800449 <vprintfmt+0x1d6>
					putch(padc, putdat);
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	53                   	push   %ebx
  80043e:	ff 75 e0             	pushl  -0x20(%ebp)
  800441:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800443:	83 ef 01             	sub    $0x1,%edi
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	85 ff                	test   %edi,%edi
  80044b:	7f ed                	jg     80043a <vprintfmt+0x1c7>
  80044d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800450:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800453:	85 c9                	test   %ecx,%ecx
  800455:	b8 00 00 00 00       	mov    $0x0,%eax
  80045a:	0f 49 c1             	cmovns %ecx,%eax
  80045d:	29 c1                	sub    %eax,%ecx
  80045f:	89 75 08             	mov    %esi,0x8(%ebp)
  800462:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800465:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800468:	89 cb                	mov    %ecx,%ebx
  80046a:	eb 4d                	jmp    8004b9 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800470:	74 1b                	je     80048d <vprintfmt+0x21a>
  800472:	0f be c0             	movsbl %al,%eax
  800475:	83 e8 20             	sub    $0x20,%eax
  800478:	83 f8 5e             	cmp    $0x5e,%eax
  80047b:	76 10                	jbe    80048d <vprintfmt+0x21a>
					putch('?', putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	ff 75 0c             	pushl  0xc(%ebp)
  800483:	6a 3f                	push   $0x3f
  800485:	ff 55 08             	call   *0x8(%ebp)
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	eb 0d                	jmp    80049a <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 0c             	pushl  0xc(%ebp)
  800493:	52                   	push   %edx
  800494:	ff 55 08             	call   *0x8(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049a:	83 eb 01             	sub    $0x1,%ebx
  80049d:	eb 1a                	jmp    8004b9 <vprintfmt+0x246>
  80049f:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ab:	eb 0c                	jmp    8004b9 <vprintfmt+0x246>
  8004ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b9:	83 c7 01             	add    $0x1,%edi
  8004bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c0:	0f be d0             	movsbl %al,%edx
  8004c3:	85 d2                	test   %edx,%edx
  8004c5:	74 23                	je     8004ea <vprintfmt+0x277>
  8004c7:	85 f6                	test   %esi,%esi
  8004c9:	78 a1                	js     80046c <vprintfmt+0x1f9>
  8004cb:	83 ee 01             	sub    $0x1,%esi
  8004ce:	79 9c                	jns    80046c <vprintfmt+0x1f9>
  8004d0:	89 df                	mov    %ebx,%edi
  8004d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d8:	eb 18                	jmp    8004f2 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	53                   	push   %ebx
  8004de:	6a 20                	push   $0x20
  8004e0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e2:	83 ef 01             	sub    $0x1,%edi
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	eb 08                	jmp    8004f2 <vprintfmt+0x27f>
  8004ea:	89 df                	mov    %ebx,%edi
  8004ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f2:	85 ff                	test   %edi,%edi
  8004f4:	7f e4                	jg     8004da <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f9:	e9 9b fd ff ff       	jmp    800299 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004fe:	83 fa 01             	cmp    $0x1,%edx
  800501:	7e 16                	jle    800519 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8d 50 08             	lea    0x8(%eax),%edx
  800509:	89 55 14             	mov    %edx,0x14(%ebp)
  80050c:	8b 50 04             	mov    0x4(%eax),%edx
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800514:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800517:	eb 32                	jmp    80054b <vprintfmt+0x2d8>
	else if (lflag)
  800519:	85 d2                	test   %edx,%edx
  80051b:	74 18                	je     800535 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 50 04             	lea    0x4(%eax),%edx
  800523:	89 55 14             	mov    %edx,0x14(%ebp)
  800526:	8b 00                	mov    (%eax),%eax
  800528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052b:	89 c1                	mov    %eax,%ecx
  80052d:	c1 f9 1f             	sar    $0x1f,%ecx
  800530:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800533:	eb 16                	jmp    80054b <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800543:	89 c1                	mov    %eax,%ecx
  800545:	c1 f9 1f             	sar    $0x1f,%ecx
  800548:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80054b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80054e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800551:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800556:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80055a:	79 74                	jns    8005d0 <vprintfmt+0x35d>
				putch('-', putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	53                   	push   %ebx
  800560:	6a 2d                	push   $0x2d
  800562:	ff d6                	call   *%esi
				num = -(long long) num;
  800564:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800567:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80056a:	f7 d8                	neg    %eax
  80056c:	83 d2 00             	adc    $0x0,%edx
  80056f:	f7 da                	neg    %edx
  800571:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800574:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800579:	eb 55                	jmp    8005d0 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80057b:	8d 45 14             	lea    0x14(%ebp),%eax
  80057e:	e8 7c fc ff ff       	call   8001ff <getuint>
			base = 10;
  800583:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800588:	eb 46                	jmp    8005d0 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80058a:	8d 45 14             	lea    0x14(%ebp),%eax
  80058d:	e8 6d fc ff ff       	call   8001ff <getuint>
                        base = 8;
  800592:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800597:	eb 37                	jmp    8005d0 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	53                   	push   %ebx
  80059d:	6a 30                	push   $0x30
  80059f:	ff d6                	call   *%esi
			putch('x', putdat);
  8005a1:	83 c4 08             	add    $0x8,%esp
  8005a4:	53                   	push   %ebx
  8005a5:	6a 78                	push   $0x78
  8005a7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 50 04             	lea    0x4(%eax),%edx
  8005af:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005b9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005bc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005c1:	eb 0d                	jmp    8005d0 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c6:	e8 34 fc ff ff       	call   8001ff <getuint>
			base = 16;
  8005cb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d0:	83 ec 0c             	sub    $0xc,%esp
  8005d3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005d7:	57                   	push   %edi
  8005d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8005db:	51                   	push   %ecx
  8005dc:	52                   	push   %edx
  8005dd:	50                   	push   %eax
  8005de:	89 da                	mov    %ebx,%edx
  8005e0:	89 f0                	mov    %esi,%eax
  8005e2:	e8 6e fb ff ff       	call   800155 <printnum>
			break;
  8005e7:	83 c4 20             	add    $0x20,%esp
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ed:	e9 a7 fc ff ff       	jmp    800299 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005f2:	83 ec 08             	sub    $0x8,%esp
  8005f5:	53                   	push   %ebx
  8005f6:	51                   	push   %ecx
  8005f7:	ff d6                	call   *%esi
			break;
  8005f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8005ff:	e9 95 fc ff ff       	jmp    800299 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	53                   	push   %ebx
  800608:	6a 25                	push   $0x25
  80060a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80060c:	83 c4 10             	add    $0x10,%esp
  80060f:	eb 03                	jmp    800614 <vprintfmt+0x3a1>
  800611:	83 ef 01             	sub    $0x1,%edi
  800614:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800618:	75 f7                	jne    800611 <vprintfmt+0x39e>
  80061a:	e9 7a fc ff ff       	jmp    800299 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80061f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800622:	5b                   	pop    %ebx
  800623:	5e                   	pop    %esi
  800624:	5f                   	pop    %edi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	83 ec 18             	sub    $0x18,%esp
  80062d:	8b 45 08             	mov    0x8(%ebp),%eax
  800630:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800633:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800636:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80063a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80063d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800644:	85 c0                	test   %eax,%eax
  800646:	74 26                	je     80066e <vsnprintf+0x47>
  800648:	85 d2                	test   %edx,%edx
  80064a:	7e 22                	jle    80066e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80064c:	ff 75 14             	pushl  0x14(%ebp)
  80064f:	ff 75 10             	pushl  0x10(%ebp)
  800652:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800655:	50                   	push   %eax
  800656:	68 39 02 80 00       	push   $0x800239
  80065b:	e8 13 fc ff ff       	call   800273 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800660:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800663:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800666:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	eb 05                	jmp    800673 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80066e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800673:	c9                   	leave  
  800674:	c3                   	ret    

00800675 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
  800678:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80067e:	50                   	push   %eax
  80067f:	ff 75 10             	pushl  0x10(%ebp)
  800682:	ff 75 0c             	pushl  0xc(%ebp)
  800685:	ff 75 08             	pushl  0x8(%ebp)
  800688:	e8 9a ff ff ff       	call   800627 <vsnprintf>
	va_end(ap);

	return rc;
}
  80068d:	c9                   	leave  
  80068e:	c3                   	ret    

0080068f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80068f:	55                   	push   %ebp
  800690:	89 e5                	mov    %esp,%ebp
  800692:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800695:	b8 00 00 00 00       	mov    $0x0,%eax
  80069a:	eb 03                	jmp    80069f <strlen+0x10>
		n++;
  80069c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80069f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006a3:	75 f7                	jne    80069c <strlen+0xd>
		n++;
	return n;
}
  8006a5:	5d                   	pop    %ebp
  8006a6:	c3                   	ret    

008006a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006a7:	55                   	push   %ebp
  8006a8:	89 e5                	mov    %esp,%ebp
  8006aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b5:	eb 03                	jmp    8006ba <strnlen+0x13>
		n++;
  8006b7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ba:	39 c2                	cmp    %eax,%edx
  8006bc:	74 08                	je     8006c6 <strnlen+0x1f>
  8006be:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006c2:	75 f3                	jne    8006b7 <strnlen+0x10>
  8006c4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006c6:	5d                   	pop    %ebp
  8006c7:	c3                   	ret    

008006c8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	53                   	push   %ebx
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006d2:	89 c2                	mov    %eax,%edx
  8006d4:	83 c2 01             	add    $0x1,%edx
  8006d7:	83 c1 01             	add    $0x1,%ecx
  8006da:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006de:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006e1:	84 db                	test   %bl,%bl
  8006e3:	75 ef                	jne    8006d4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006e5:	5b                   	pop    %ebx
  8006e6:	5d                   	pop    %ebp
  8006e7:	c3                   	ret    

008006e8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	53                   	push   %ebx
  8006ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006ef:	53                   	push   %ebx
  8006f0:	e8 9a ff ff ff       	call   80068f <strlen>
  8006f5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8006f8:	ff 75 0c             	pushl  0xc(%ebp)
  8006fb:	01 d8                	add    %ebx,%eax
  8006fd:	50                   	push   %eax
  8006fe:	e8 c5 ff ff ff       	call   8006c8 <strcpy>
	return dst;
}
  800703:	89 d8                	mov    %ebx,%eax
  800705:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800708:	c9                   	leave  
  800709:	c3                   	ret    

0080070a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	56                   	push   %esi
  80070e:	53                   	push   %ebx
  80070f:	8b 75 08             	mov    0x8(%ebp),%esi
  800712:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800715:	89 f3                	mov    %esi,%ebx
  800717:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80071a:	89 f2                	mov    %esi,%edx
  80071c:	eb 0f                	jmp    80072d <strncpy+0x23>
		*dst++ = *src;
  80071e:	83 c2 01             	add    $0x1,%edx
  800721:	0f b6 01             	movzbl (%ecx),%eax
  800724:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800727:	80 39 01             	cmpb   $0x1,(%ecx)
  80072a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80072d:	39 da                	cmp    %ebx,%edx
  80072f:	75 ed                	jne    80071e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800731:	89 f0                	mov    %esi,%eax
  800733:	5b                   	pop    %ebx
  800734:	5e                   	pop    %esi
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	56                   	push   %esi
  80073b:	53                   	push   %ebx
  80073c:	8b 75 08             	mov    0x8(%ebp),%esi
  80073f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800742:	8b 55 10             	mov    0x10(%ebp),%edx
  800745:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800747:	85 d2                	test   %edx,%edx
  800749:	74 21                	je     80076c <strlcpy+0x35>
  80074b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80074f:	89 f2                	mov    %esi,%edx
  800751:	eb 09                	jmp    80075c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800753:	83 c2 01             	add    $0x1,%edx
  800756:	83 c1 01             	add    $0x1,%ecx
  800759:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80075c:	39 c2                	cmp    %eax,%edx
  80075e:	74 09                	je     800769 <strlcpy+0x32>
  800760:	0f b6 19             	movzbl (%ecx),%ebx
  800763:	84 db                	test   %bl,%bl
  800765:	75 ec                	jne    800753 <strlcpy+0x1c>
  800767:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800769:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80076c:	29 f0                	sub    %esi,%eax
}
  80076e:	5b                   	pop    %ebx
  80076f:	5e                   	pop    %esi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800778:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80077b:	eb 06                	jmp    800783 <strcmp+0x11>
		p++, q++;
  80077d:	83 c1 01             	add    $0x1,%ecx
  800780:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800783:	0f b6 01             	movzbl (%ecx),%eax
  800786:	84 c0                	test   %al,%al
  800788:	74 04                	je     80078e <strcmp+0x1c>
  80078a:	3a 02                	cmp    (%edx),%al
  80078c:	74 ef                	je     80077d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80078e:	0f b6 c0             	movzbl %al,%eax
  800791:	0f b6 12             	movzbl (%edx),%edx
  800794:	29 d0                	sub    %edx,%eax
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	53                   	push   %ebx
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a2:	89 c3                	mov    %eax,%ebx
  8007a4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007a7:	eb 06                	jmp    8007af <strncmp+0x17>
		n--, p++, q++;
  8007a9:	83 c0 01             	add    $0x1,%eax
  8007ac:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007af:	39 d8                	cmp    %ebx,%eax
  8007b1:	74 15                	je     8007c8 <strncmp+0x30>
  8007b3:	0f b6 08             	movzbl (%eax),%ecx
  8007b6:	84 c9                	test   %cl,%cl
  8007b8:	74 04                	je     8007be <strncmp+0x26>
  8007ba:	3a 0a                	cmp    (%edx),%cl
  8007bc:	74 eb                	je     8007a9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007be:	0f b6 00             	movzbl (%eax),%eax
  8007c1:	0f b6 12             	movzbl (%edx),%edx
  8007c4:	29 d0                	sub    %edx,%eax
  8007c6:	eb 05                	jmp    8007cd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007c8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007cd:	5b                   	pop    %ebx
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007da:	eb 07                	jmp    8007e3 <strchr+0x13>
		if (*s == c)
  8007dc:	38 ca                	cmp    %cl,%dl
  8007de:	74 0f                	je     8007ef <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007e0:	83 c0 01             	add    $0x1,%eax
  8007e3:	0f b6 10             	movzbl (%eax),%edx
  8007e6:	84 d2                	test   %dl,%dl
  8007e8:	75 f2                	jne    8007dc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007fb:	eb 03                	jmp    800800 <strfind+0xf>
  8007fd:	83 c0 01             	add    $0x1,%eax
  800800:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800803:	84 d2                	test   %dl,%dl
  800805:	74 04                	je     80080b <strfind+0x1a>
  800807:	38 ca                	cmp    %cl,%dl
  800809:	75 f2                	jne    8007fd <strfind+0xc>
			break;
	return (char *) s;
}
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	57                   	push   %edi
  800811:	56                   	push   %esi
  800812:	53                   	push   %ebx
  800813:	8b 7d 08             	mov    0x8(%ebp),%edi
  800816:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800819:	85 c9                	test   %ecx,%ecx
  80081b:	74 36                	je     800853 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80081d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800823:	75 28                	jne    80084d <memset+0x40>
  800825:	f6 c1 03             	test   $0x3,%cl
  800828:	75 23                	jne    80084d <memset+0x40>
		c &= 0xFF;
  80082a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80082e:	89 d3                	mov    %edx,%ebx
  800830:	c1 e3 08             	shl    $0x8,%ebx
  800833:	89 d6                	mov    %edx,%esi
  800835:	c1 e6 18             	shl    $0x18,%esi
  800838:	89 d0                	mov    %edx,%eax
  80083a:	c1 e0 10             	shl    $0x10,%eax
  80083d:	09 f0                	or     %esi,%eax
  80083f:	09 c2                	or     %eax,%edx
  800841:	89 d0                	mov    %edx,%eax
  800843:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800845:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800848:	fc                   	cld    
  800849:	f3 ab                	rep stos %eax,%es:(%edi)
  80084b:	eb 06                	jmp    800853 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80084d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800850:	fc                   	cld    
  800851:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800853:	89 f8                	mov    %edi,%eax
  800855:	5b                   	pop    %ebx
  800856:	5e                   	pop    %esi
  800857:	5f                   	pop    %edi
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	57                   	push   %edi
  80085e:	56                   	push   %esi
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8b 75 0c             	mov    0xc(%ebp),%esi
  800865:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800868:	39 c6                	cmp    %eax,%esi
  80086a:	73 35                	jae    8008a1 <memmove+0x47>
  80086c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80086f:	39 d0                	cmp    %edx,%eax
  800871:	73 2e                	jae    8008a1 <memmove+0x47>
		s += n;
		d += n;
  800873:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800876:	89 d6                	mov    %edx,%esi
  800878:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80087a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800880:	75 13                	jne    800895 <memmove+0x3b>
  800882:	f6 c1 03             	test   $0x3,%cl
  800885:	75 0e                	jne    800895 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800887:	83 ef 04             	sub    $0x4,%edi
  80088a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80088d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800890:	fd                   	std    
  800891:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800893:	eb 09                	jmp    80089e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800895:	83 ef 01             	sub    $0x1,%edi
  800898:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80089b:	fd                   	std    
  80089c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80089e:	fc                   	cld    
  80089f:	eb 1d                	jmp    8008be <memmove+0x64>
  8008a1:	89 f2                	mov    %esi,%edx
  8008a3:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a5:	f6 c2 03             	test   $0x3,%dl
  8008a8:	75 0f                	jne    8008b9 <memmove+0x5f>
  8008aa:	f6 c1 03             	test   $0x3,%cl
  8008ad:	75 0a                	jne    8008b9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008af:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008b2:	89 c7                	mov    %eax,%edi
  8008b4:	fc                   	cld    
  8008b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b7:	eb 05                	jmp    8008be <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008b9:	89 c7                	mov    %eax,%edi
  8008bb:	fc                   	cld    
  8008bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008be:	5e                   	pop    %esi
  8008bf:	5f                   	pop    %edi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008c5:	ff 75 10             	pushl  0x10(%ebp)
  8008c8:	ff 75 0c             	pushl  0xc(%ebp)
  8008cb:	ff 75 08             	pushl  0x8(%ebp)
  8008ce:	e8 87 ff ff ff       	call   80085a <memmove>
}
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    

008008d5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	56                   	push   %esi
  8008d9:	53                   	push   %ebx
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e0:	89 c6                	mov    %eax,%esi
  8008e2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008e5:	eb 1a                	jmp    800901 <memcmp+0x2c>
		if (*s1 != *s2)
  8008e7:	0f b6 08             	movzbl (%eax),%ecx
  8008ea:	0f b6 1a             	movzbl (%edx),%ebx
  8008ed:	38 d9                	cmp    %bl,%cl
  8008ef:	74 0a                	je     8008fb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008f1:	0f b6 c1             	movzbl %cl,%eax
  8008f4:	0f b6 db             	movzbl %bl,%ebx
  8008f7:	29 d8                	sub    %ebx,%eax
  8008f9:	eb 0f                	jmp    80090a <memcmp+0x35>
		s1++, s2++;
  8008fb:	83 c0 01             	add    $0x1,%eax
  8008fe:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800901:	39 f0                	cmp    %esi,%eax
  800903:	75 e2                	jne    8008e7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800917:	89 c2                	mov    %eax,%edx
  800919:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80091c:	eb 07                	jmp    800925 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80091e:	38 08                	cmp    %cl,(%eax)
  800920:	74 07                	je     800929 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800922:	83 c0 01             	add    $0x1,%eax
  800925:	39 d0                	cmp    %edx,%eax
  800927:	72 f5                	jb     80091e <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	57                   	push   %edi
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800934:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800937:	eb 03                	jmp    80093c <strtol+0x11>
		s++;
  800939:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80093c:	0f b6 01             	movzbl (%ecx),%eax
  80093f:	3c 09                	cmp    $0x9,%al
  800941:	74 f6                	je     800939 <strtol+0xe>
  800943:	3c 20                	cmp    $0x20,%al
  800945:	74 f2                	je     800939 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800947:	3c 2b                	cmp    $0x2b,%al
  800949:	75 0a                	jne    800955 <strtol+0x2a>
		s++;
  80094b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80094e:	bf 00 00 00 00       	mov    $0x0,%edi
  800953:	eb 10                	jmp    800965 <strtol+0x3a>
  800955:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80095a:	3c 2d                	cmp    $0x2d,%al
  80095c:	75 07                	jne    800965 <strtol+0x3a>
		s++, neg = 1;
  80095e:	8d 49 01             	lea    0x1(%ecx),%ecx
  800961:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800965:	85 db                	test   %ebx,%ebx
  800967:	0f 94 c0             	sete   %al
  80096a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800970:	75 19                	jne    80098b <strtol+0x60>
  800972:	80 39 30             	cmpb   $0x30,(%ecx)
  800975:	75 14                	jne    80098b <strtol+0x60>
  800977:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80097b:	0f 85 82 00 00 00    	jne    800a03 <strtol+0xd8>
		s += 2, base = 16;
  800981:	83 c1 02             	add    $0x2,%ecx
  800984:	bb 10 00 00 00       	mov    $0x10,%ebx
  800989:	eb 16                	jmp    8009a1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80098b:	84 c0                	test   %al,%al
  80098d:	74 12                	je     8009a1 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80098f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800994:	80 39 30             	cmpb   $0x30,(%ecx)
  800997:	75 08                	jne    8009a1 <strtol+0x76>
		s++, base = 8;
  800999:	83 c1 01             	add    $0x1,%ecx
  80099c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009a9:	0f b6 11             	movzbl (%ecx),%edx
  8009ac:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009af:	89 f3                	mov    %esi,%ebx
  8009b1:	80 fb 09             	cmp    $0x9,%bl
  8009b4:	77 08                	ja     8009be <strtol+0x93>
			dig = *s - '0';
  8009b6:	0f be d2             	movsbl %dl,%edx
  8009b9:	83 ea 30             	sub    $0x30,%edx
  8009bc:	eb 22                	jmp    8009e0 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009be:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009c1:	89 f3                	mov    %esi,%ebx
  8009c3:	80 fb 19             	cmp    $0x19,%bl
  8009c6:	77 08                	ja     8009d0 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009c8:	0f be d2             	movsbl %dl,%edx
  8009cb:	83 ea 57             	sub    $0x57,%edx
  8009ce:	eb 10                	jmp    8009e0 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009d0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009d3:	89 f3                	mov    %esi,%ebx
  8009d5:	80 fb 19             	cmp    $0x19,%bl
  8009d8:	77 16                	ja     8009f0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009da:	0f be d2             	movsbl %dl,%edx
  8009dd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009e0:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009e3:	7d 0f                	jge    8009f4 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009e5:	83 c1 01             	add    $0x1,%ecx
  8009e8:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009ec:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009ee:	eb b9                	jmp    8009a9 <strtol+0x7e>
  8009f0:	89 c2                	mov    %eax,%edx
  8009f2:	eb 02                	jmp    8009f6 <strtol+0xcb>
  8009f4:	89 c2                	mov    %eax,%edx

	if (endptr)
  8009f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009fa:	74 0d                	je     800a09 <strtol+0xde>
		*endptr = (char *) s;
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	89 0e                	mov    %ecx,(%esi)
  800a01:	eb 06                	jmp    800a09 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a03:	84 c0                	test   %al,%al
  800a05:	75 92                	jne    800999 <strtol+0x6e>
  800a07:	eb 98                	jmp    8009a1 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a09:	f7 da                	neg    %edx
  800a0b:	85 ff                	test   %edi,%edi
  800a0d:	0f 45 c2             	cmovne %edx,%eax
}
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5f                   	pop    %edi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	57                   	push   %edi
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a23:	8b 55 08             	mov    0x8(%ebp),%edx
  800a26:	89 c3                	mov    %eax,%ebx
  800a28:	89 c7                	mov    %eax,%edi
  800a2a:	89 c6                	mov    %eax,%esi
  800a2c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a2e:	5b                   	pop    %ebx
  800a2f:	5e                   	pop    %esi
  800a30:	5f                   	pop    %edi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a39:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a43:	89 d1                	mov    %edx,%ecx
  800a45:	89 d3                	mov    %edx,%ebx
  800a47:	89 d7                	mov    %edx,%edi
  800a49:	89 d6                	mov    %edx,%esi
  800a4b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
  800a58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a60:	b8 03 00 00 00       	mov    $0x3,%eax
  800a65:	8b 55 08             	mov    0x8(%ebp),%edx
  800a68:	89 cb                	mov    %ecx,%ebx
  800a6a:	89 cf                	mov    %ecx,%edi
  800a6c:	89 ce                	mov    %ecx,%esi
  800a6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a70:	85 c0                	test   %eax,%eax
  800a72:	7e 17                	jle    800a8b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a74:	83 ec 0c             	sub    $0xc,%esp
  800a77:	50                   	push   %eax
  800a78:	6a 03                	push   $0x3
  800a7a:	68 5f 21 80 00       	push   $0x80215f
  800a7f:	6a 23                	push   $0x23
  800a81:	68 7c 21 80 00       	push   $0x80217c
  800a86:	e8 44 0f 00 00       	call   8019cf <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a99:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9e:	b8 02 00 00 00       	mov    $0x2,%eax
  800aa3:	89 d1                	mov    %edx,%ecx
  800aa5:	89 d3                	mov    %edx,%ebx
  800aa7:	89 d7                	mov    %edx,%edi
  800aa9:	89 d6                	mov    %edx,%esi
  800aab:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <sys_yield>:

void
sys_yield(void)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  800abd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ac2:	89 d1                	mov    %edx,%ecx
  800ac4:	89 d3                	mov    %edx,%ebx
  800ac6:	89 d7                	mov    %edx,%edi
  800ac8:	89 d6                	mov    %edx,%esi
  800aca:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
  800ad7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ada:	be 00 00 00 00       	mov    $0x0,%esi
  800adf:	b8 04 00 00 00       	mov    $0x4,%eax
  800ae4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800aed:	89 f7                	mov    %esi,%edi
  800aef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af1:	85 c0                	test   %eax,%eax
  800af3:	7e 17                	jle    800b0c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af5:	83 ec 0c             	sub    $0xc,%esp
  800af8:	50                   	push   %eax
  800af9:	6a 04                	push   $0x4
  800afb:	68 5f 21 80 00       	push   $0x80215f
  800b00:	6a 23                	push   $0x23
  800b02:	68 7c 21 80 00       	push   $0x80217c
  800b07:	e8 c3 0e 00 00       	call   8019cf <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
  800b1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b25:	8b 55 08             	mov    0x8(%ebp),%edx
  800b28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b2e:	8b 75 18             	mov    0x18(%ebp),%esi
  800b31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b33:	85 c0                	test   %eax,%eax
  800b35:	7e 17                	jle    800b4e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	50                   	push   %eax
  800b3b:	6a 05                	push   $0x5
  800b3d:	68 5f 21 80 00       	push   $0x80215f
  800b42:	6a 23                	push   $0x23
  800b44:	68 7c 21 80 00       	push   $0x80217c
  800b49:	e8 81 0e 00 00       	call   8019cf <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
  800b5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b64:	b8 06 00 00 00       	mov    $0x6,%eax
  800b69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6f:	89 df                	mov    %ebx,%edi
  800b71:	89 de                	mov    %ebx,%esi
  800b73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b75:	85 c0                	test   %eax,%eax
  800b77:	7e 17                	jle    800b90 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	50                   	push   %eax
  800b7d:	6a 06                	push   $0x6
  800b7f:	68 5f 21 80 00       	push   $0x80215f
  800b84:	6a 23                	push   $0x23
  800b86:	68 7c 21 80 00       	push   $0x80217c
  800b8b:	e8 3f 0e 00 00       	call   8019cf <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
  800b9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba6:	b8 08 00 00 00       	mov    $0x8,%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	89 df                	mov    %ebx,%edi
  800bb3:	89 de                	mov    %ebx,%esi
  800bb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb7:	85 c0                	test   %eax,%eax
  800bb9:	7e 17                	jle    800bd2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	50                   	push   %eax
  800bbf:	6a 08                	push   $0x8
  800bc1:	68 5f 21 80 00       	push   $0x80215f
  800bc6:	6a 23                	push   $0x23
  800bc8:	68 7c 21 80 00       	push   $0x80217c
  800bcd:	e8 fd 0d 00 00       	call   8019cf <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be8:	b8 09 00 00 00       	mov    $0x9,%eax
  800bed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	89 df                	mov    %ebx,%edi
  800bf5:	89 de                	mov    %ebx,%esi
  800bf7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf9:	85 c0                	test   %eax,%eax
  800bfb:	7e 17                	jle    800c14 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfd:	83 ec 0c             	sub    $0xc,%esp
  800c00:	50                   	push   %eax
  800c01:	6a 09                	push   $0x9
  800c03:	68 5f 21 80 00       	push   $0x80215f
  800c08:	6a 23                	push   $0x23
  800c0a:	68 7c 21 80 00       	push   $0x80217c
  800c0f:	e8 bb 0d 00 00       	call   8019cf <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	89 df                	mov    %ebx,%edi
  800c37:	89 de                	mov    %ebx,%esi
  800c39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 17                	jle    800c56 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 0a                	push   $0xa
  800c45:	68 5f 21 80 00       	push   $0x80215f
  800c4a:	6a 23                	push   $0x23
  800c4c:	68 7c 21 80 00       	push   $0x80217c
  800c51:	e8 79 0d 00 00       	call   8019cf <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	be 00 00 00 00       	mov    $0x0,%esi
  800c69:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	89 cb                	mov    %ecx,%ebx
  800c99:	89 cf                	mov    %ecx,%edi
  800c9b:	89 ce                	mov    %ecx,%esi
  800c9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 0d                	push   $0xd
  800ca9:	68 5f 21 80 00       	push   $0x80215f
  800cae:	6a 23                	push   $0x23
  800cb0:	68 7c 21 80 00       	push   $0x80217c
  800cb5:	e8 15 0d 00 00       	call   8019cf <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	05 00 00 00 30       	add    $0x30000000,%eax
  800ccd:	c1 e8 0c             	shr    $0xc,%eax
}
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800cdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ce2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cef:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800cf4:	89 c2                	mov    %eax,%edx
  800cf6:	c1 ea 16             	shr    $0x16,%edx
  800cf9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d00:	f6 c2 01             	test   $0x1,%dl
  800d03:	74 11                	je     800d16 <fd_alloc+0x2d>
  800d05:	89 c2                	mov    %eax,%edx
  800d07:	c1 ea 0c             	shr    $0xc,%edx
  800d0a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d11:	f6 c2 01             	test   $0x1,%dl
  800d14:	75 09                	jne    800d1f <fd_alloc+0x36>
			*fd_store = fd;
  800d16:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d18:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1d:	eb 17                	jmp    800d36 <fd_alloc+0x4d>
  800d1f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d24:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d29:	75 c9                	jne    800cf4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d2b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d31:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d3e:	83 f8 1f             	cmp    $0x1f,%eax
  800d41:	77 36                	ja     800d79 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d43:	c1 e0 0c             	shl    $0xc,%eax
  800d46:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d4b:	89 c2                	mov    %eax,%edx
  800d4d:	c1 ea 16             	shr    $0x16,%edx
  800d50:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d57:	f6 c2 01             	test   $0x1,%dl
  800d5a:	74 24                	je     800d80 <fd_lookup+0x48>
  800d5c:	89 c2                	mov    %eax,%edx
  800d5e:	c1 ea 0c             	shr    $0xc,%edx
  800d61:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d68:	f6 c2 01             	test   $0x1,%dl
  800d6b:	74 1a                	je     800d87 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d70:	89 02                	mov    %eax,(%edx)
	return 0;
  800d72:	b8 00 00 00 00       	mov    $0x0,%eax
  800d77:	eb 13                	jmp    800d8c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d7e:	eb 0c                	jmp    800d8c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d80:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d85:	eb 05                	jmp    800d8c <fd_lookup+0x54>
  800d87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	83 ec 08             	sub    $0x8,%esp
  800d94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d97:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800d9c:	eb 13                	jmp    800db1 <dev_lookup+0x23>
  800d9e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800da1:	39 08                	cmp    %ecx,(%eax)
  800da3:	75 0c                	jne    800db1 <dev_lookup+0x23>
			*dev = devtab[i];
  800da5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800daa:	b8 00 00 00 00       	mov    $0x0,%eax
  800daf:	eb 2e                	jmp    800ddf <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800db1:	8b 02                	mov    (%edx),%eax
  800db3:	85 c0                	test   %eax,%eax
  800db5:	75 e7                	jne    800d9e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800db7:	a1 04 40 80 00       	mov    0x804004,%eax
  800dbc:	8b 40 48             	mov    0x48(%eax),%eax
  800dbf:	83 ec 04             	sub    $0x4,%esp
  800dc2:	51                   	push   %ecx
  800dc3:	50                   	push   %eax
  800dc4:	68 8c 21 80 00       	push   $0x80218c
  800dc9:	e8 73 f3 ff ff       	call   800141 <cprintf>
	*dev = 0;
  800dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800dd7:	83 c4 10             	add    $0x10,%esp
  800dda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ddf:	c9                   	leave  
  800de0:	c3                   	ret    

00800de1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
  800de6:	83 ec 10             	sub    $0x10,%esp
  800de9:	8b 75 08             	mov    0x8(%ebp),%esi
  800dec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800def:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800df2:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800df9:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800dfc:	50                   	push   %eax
  800dfd:	e8 36 ff ff ff       	call   800d38 <fd_lookup>
  800e02:	83 c4 08             	add    $0x8,%esp
  800e05:	85 c0                	test   %eax,%eax
  800e07:	78 05                	js     800e0e <fd_close+0x2d>
	    || fd != fd2)
  800e09:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e0c:	74 0c                	je     800e1a <fd_close+0x39>
		return (must_exist ? r : 0);
  800e0e:	84 db                	test   %bl,%bl
  800e10:	ba 00 00 00 00       	mov    $0x0,%edx
  800e15:	0f 44 c2             	cmove  %edx,%eax
  800e18:	eb 41                	jmp    800e5b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e20:	50                   	push   %eax
  800e21:	ff 36                	pushl  (%esi)
  800e23:	e8 66 ff ff ff       	call   800d8e <dev_lookup>
  800e28:	89 c3                	mov    %eax,%ebx
  800e2a:	83 c4 10             	add    $0x10,%esp
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	78 1a                	js     800e4b <fd_close+0x6a>
		if (dev->dev_close)
  800e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e34:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e37:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	74 0b                	je     800e4b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e40:	83 ec 0c             	sub    $0xc,%esp
  800e43:	56                   	push   %esi
  800e44:	ff d0                	call   *%eax
  800e46:	89 c3                	mov    %eax,%ebx
  800e48:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e4b:	83 ec 08             	sub    $0x8,%esp
  800e4e:	56                   	push   %esi
  800e4f:	6a 00                	push   $0x0
  800e51:	e8 00 fd ff ff       	call   800b56 <sys_page_unmap>
	return r;
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	89 d8                	mov    %ebx,%eax
}
  800e5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e6b:	50                   	push   %eax
  800e6c:	ff 75 08             	pushl  0x8(%ebp)
  800e6f:	e8 c4 fe ff ff       	call   800d38 <fd_lookup>
  800e74:	89 c2                	mov    %eax,%edx
  800e76:	83 c4 08             	add    $0x8,%esp
  800e79:	85 d2                	test   %edx,%edx
  800e7b:	78 10                	js     800e8d <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800e7d:	83 ec 08             	sub    $0x8,%esp
  800e80:	6a 01                	push   $0x1
  800e82:	ff 75 f4             	pushl  -0xc(%ebp)
  800e85:	e8 57 ff ff ff       	call   800de1 <fd_close>
  800e8a:	83 c4 10             	add    $0x10,%esp
}
  800e8d:	c9                   	leave  
  800e8e:	c3                   	ret    

00800e8f <close_all>:

void
close_all(void)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	53                   	push   %ebx
  800e93:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800e96:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800e9b:	83 ec 0c             	sub    $0xc,%esp
  800e9e:	53                   	push   %ebx
  800e9f:	e8 be ff ff ff       	call   800e62 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ea4:	83 c3 01             	add    $0x1,%ebx
  800ea7:	83 c4 10             	add    $0x10,%esp
  800eaa:	83 fb 20             	cmp    $0x20,%ebx
  800ead:	75 ec                	jne    800e9b <close_all+0xc>
		close(i);
}
  800eaf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb2:	c9                   	leave  
  800eb3:	c3                   	ret    

00800eb4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
  800eba:	83 ec 2c             	sub    $0x2c,%esp
  800ebd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ec0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ec3:	50                   	push   %eax
  800ec4:	ff 75 08             	pushl  0x8(%ebp)
  800ec7:	e8 6c fe ff ff       	call   800d38 <fd_lookup>
  800ecc:	89 c2                	mov    %eax,%edx
  800ece:	83 c4 08             	add    $0x8,%esp
  800ed1:	85 d2                	test   %edx,%edx
  800ed3:	0f 88 c1 00 00 00    	js     800f9a <dup+0xe6>
		return r;
	close(newfdnum);
  800ed9:	83 ec 0c             	sub    $0xc,%esp
  800edc:	56                   	push   %esi
  800edd:	e8 80 ff ff ff       	call   800e62 <close>

	newfd = INDEX2FD(newfdnum);
  800ee2:	89 f3                	mov    %esi,%ebx
  800ee4:	c1 e3 0c             	shl    $0xc,%ebx
  800ee7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800eed:	83 c4 04             	add    $0x4,%esp
  800ef0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ef3:	e8 da fd ff ff       	call   800cd2 <fd2data>
  800ef8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800efa:	89 1c 24             	mov    %ebx,(%esp)
  800efd:	e8 d0 fd ff ff       	call   800cd2 <fd2data>
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f08:	89 f8                	mov    %edi,%eax
  800f0a:	c1 e8 16             	shr    $0x16,%eax
  800f0d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f14:	a8 01                	test   $0x1,%al
  800f16:	74 37                	je     800f4f <dup+0x9b>
  800f18:	89 f8                	mov    %edi,%eax
  800f1a:	c1 e8 0c             	shr    $0xc,%eax
  800f1d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f24:	f6 c2 01             	test   $0x1,%dl
  800f27:	74 26                	je     800f4f <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f29:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f30:	83 ec 0c             	sub    $0xc,%esp
  800f33:	25 07 0e 00 00       	and    $0xe07,%eax
  800f38:	50                   	push   %eax
  800f39:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f3c:	6a 00                	push   $0x0
  800f3e:	57                   	push   %edi
  800f3f:	6a 00                	push   $0x0
  800f41:	e8 ce fb ff ff       	call   800b14 <sys_page_map>
  800f46:	89 c7                	mov    %eax,%edi
  800f48:	83 c4 20             	add    $0x20,%esp
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	78 2e                	js     800f7d <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f4f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f52:	89 d0                	mov    %edx,%eax
  800f54:	c1 e8 0c             	shr    $0xc,%eax
  800f57:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f5e:	83 ec 0c             	sub    $0xc,%esp
  800f61:	25 07 0e 00 00       	and    $0xe07,%eax
  800f66:	50                   	push   %eax
  800f67:	53                   	push   %ebx
  800f68:	6a 00                	push   $0x0
  800f6a:	52                   	push   %edx
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 a2 fb ff ff       	call   800b14 <sys_page_map>
  800f72:	89 c7                	mov    %eax,%edi
  800f74:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f77:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f79:	85 ff                	test   %edi,%edi
  800f7b:	79 1d                	jns    800f9a <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800f7d:	83 ec 08             	sub    $0x8,%esp
  800f80:	53                   	push   %ebx
  800f81:	6a 00                	push   $0x0
  800f83:	e8 ce fb ff ff       	call   800b56 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800f88:	83 c4 08             	add    $0x8,%esp
  800f8b:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f8e:	6a 00                	push   $0x0
  800f90:	e8 c1 fb ff ff       	call   800b56 <sys_page_unmap>
	return r;
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	89 f8                	mov    %edi,%eax
}
  800f9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	53                   	push   %ebx
  800fa6:	83 ec 14             	sub    $0x14,%esp
  800fa9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800faf:	50                   	push   %eax
  800fb0:	53                   	push   %ebx
  800fb1:	e8 82 fd ff ff       	call   800d38 <fd_lookup>
  800fb6:	83 c4 08             	add    $0x8,%esp
  800fb9:	89 c2                	mov    %eax,%edx
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	78 6d                	js     80102c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fbf:	83 ec 08             	sub    $0x8,%esp
  800fc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc5:	50                   	push   %eax
  800fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fc9:	ff 30                	pushl  (%eax)
  800fcb:	e8 be fd ff ff       	call   800d8e <dev_lookup>
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	78 4c                	js     801023 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800fd7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fda:	8b 42 08             	mov    0x8(%edx),%eax
  800fdd:	83 e0 03             	and    $0x3,%eax
  800fe0:	83 f8 01             	cmp    $0x1,%eax
  800fe3:	75 21                	jne    801006 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800fe5:	a1 04 40 80 00       	mov    0x804004,%eax
  800fea:	8b 40 48             	mov    0x48(%eax),%eax
  800fed:	83 ec 04             	sub    $0x4,%esp
  800ff0:	53                   	push   %ebx
  800ff1:	50                   	push   %eax
  800ff2:	68 cd 21 80 00       	push   $0x8021cd
  800ff7:	e8 45 f1 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801004:	eb 26                	jmp    80102c <read+0x8a>
	}
	if (!dev->dev_read)
  801006:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801009:	8b 40 08             	mov    0x8(%eax),%eax
  80100c:	85 c0                	test   %eax,%eax
  80100e:	74 17                	je     801027 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801010:	83 ec 04             	sub    $0x4,%esp
  801013:	ff 75 10             	pushl  0x10(%ebp)
  801016:	ff 75 0c             	pushl  0xc(%ebp)
  801019:	52                   	push   %edx
  80101a:	ff d0                	call   *%eax
  80101c:	89 c2                	mov    %eax,%edx
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	eb 09                	jmp    80102c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801023:	89 c2                	mov    %eax,%edx
  801025:	eb 05                	jmp    80102c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801027:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80102c:	89 d0                	mov    %edx,%eax
  80102e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801031:	c9                   	leave  
  801032:	c3                   	ret    

00801033 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80103f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801042:	bb 00 00 00 00       	mov    $0x0,%ebx
  801047:	eb 21                	jmp    80106a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801049:	83 ec 04             	sub    $0x4,%esp
  80104c:	89 f0                	mov    %esi,%eax
  80104e:	29 d8                	sub    %ebx,%eax
  801050:	50                   	push   %eax
  801051:	89 d8                	mov    %ebx,%eax
  801053:	03 45 0c             	add    0xc(%ebp),%eax
  801056:	50                   	push   %eax
  801057:	57                   	push   %edi
  801058:	e8 45 ff ff ff       	call   800fa2 <read>
		if (m < 0)
  80105d:	83 c4 10             	add    $0x10,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	78 0c                	js     801070 <readn+0x3d>
			return m;
		if (m == 0)
  801064:	85 c0                	test   %eax,%eax
  801066:	74 06                	je     80106e <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801068:	01 c3                	add    %eax,%ebx
  80106a:	39 f3                	cmp    %esi,%ebx
  80106c:	72 db                	jb     801049 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80106e:	89 d8                	mov    %ebx,%eax
}
  801070:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801073:	5b                   	pop    %ebx
  801074:	5e                   	pop    %esi
  801075:	5f                   	pop    %edi
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    

00801078 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	53                   	push   %ebx
  80107c:	83 ec 14             	sub    $0x14,%esp
  80107f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801082:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801085:	50                   	push   %eax
  801086:	53                   	push   %ebx
  801087:	e8 ac fc ff ff       	call   800d38 <fd_lookup>
  80108c:	83 c4 08             	add    $0x8,%esp
  80108f:	89 c2                	mov    %eax,%edx
  801091:	85 c0                	test   %eax,%eax
  801093:	78 68                	js     8010fd <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80109b:	50                   	push   %eax
  80109c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80109f:	ff 30                	pushl  (%eax)
  8010a1:	e8 e8 fc ff ff       	call   800d8e <dev_lookup>
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	78 47                	js     8010f4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010b4:	75 21                	jne    8010d7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8010bb:	8b 40 48             	mov    0x48(%eax),%eax
  8010be:	83 ec 04             	sub    $0x4,%esp
  8010c1:	53                   	push   %ebx
  8010c2:	50                   	push   %eax
  8010c3:	68 e9 21 80 00       	push   $0x8021e9
  8010c8:	e8 74 f0 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010d5:	eb 26                	jmp    8010fd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010da:	8b 52 0c             	mov    0xc(%edx),%edx
  8010dd:	85 d2                	test   %edx,%edx
  8010df:	74 17                	je     8010f8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010e1:	83 ec 04             	sub    $0x4,%esp
  8010e4:	ff 75 10             	pushl  0x10(%ebp)
  8010e7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ea:	50                   	push   %eax
  8010eb:	ff d2                	call   *%edx
  8010ed:	89 c2                	mov    %eax,%edx
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	eb 09                	jmp    8010fd <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f4:	89 c2                	mov    %eax,%edx
  8010f6:	eb 05                	jmp    8010fd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8010f8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8010fd:	89 d0                	mov    %edx,%eax
  8010ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801102:	c9                   	leave  
  801103:	c3                   	ret    

00801104 <seek>:

int
seek(int fdnum, off_t offset)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80110a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80110d:	50                   	push   %eax
  80110e:	ff 75 08             	pushl  0x8(%ebp)
  801111:	e8 22 fc ff ff       	call   800d38 <fd_lookup>
  801116:	83 c4 08             	add    $0x8,%esp
  801119:	85 c0                	test   %eax,%eax
  80111b:	78 0e                	js     80112b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80111d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801120:	8b 55 0c             	mov    0xc(%ebp),%edx
  801123:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801126:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80112b:	c9                   	leave  
  80112c:	c3                   	ret    

0080112d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	53                   	push   %ebx
  801131:	83 ec 14             	sub    $0x14,%esp
  801134:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801137:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113a:	50                   	push   %eax
  80113b:	53                   	push   %ebx
  80113c:	e8 f7 fb ff ff       	call   800d38 <fd_lookup>
  801141:	83 c4 08             	add    $0x8,%esp
  801144:	89 c2                	mov    %eax,%edx
  801146:	85 c0                	test   %eax,%eax
  801148:	78 65                	js     8011af <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801154:	ff 30                	pushl  (%eax)
  801156:	e8 33 fc ff ff       	call   800d8e <dev_lookup>
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 44                	js     8011a6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801162:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801165:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801169:	75 21                	jne    80118c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80116b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801170:	8b 40 48             	mov    0x48(%eax),%eax
  801173:	83 ec 04             	sub    $0x4,%esp
  801176:	53                   	push   %ebx
  801177:	50                   	push   %eax
  801178:	68 ac 21 80 00       	push   $0x8021ac
  80117d:	e8 bf ef ff ff       	call   800141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80118a:	eb 23                	jmp    8011af <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80118c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80118f:	8b 52 18             	mov    0x18(%edx),%edx
  801192:	85 d2                	test   %edx,%edx
  801194:	74 14                	je     8011aa <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801196:	83 ec 08             	sub    $0x8,%esp
  801199:	ff 75 0c             	pushl  0xc(%ebp)
  80119c:	50                   	push   %eax
  80119d:	ff d2                	call   *%edx
  80119f:	89 c2                	mov    %eax,%edx
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	eb 09                	jmp    8011af <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a6:	89 c2                	mov    %eax,%edx
  8011a8:	eb 05                	jmp    8011af <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011aa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011af:	89 d0                	mov    %edx,%eax
  8011b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b4:	c9                   	leave  
  8011b5:	c3                   	ret    

008011b6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	53                   	push   %ebx
  8011ba:	83 ec 14             	sub    $0x14,%esp
  8011bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c3:	50                   	push   %eax
  8011c4:	ff 75 08             	pushl  0x8(%ebp)
  8011c7:	e8 6c fb ff ff       	call   800d38 <fd_lookup>
  8011cc:	83 c4 08             	add    $0x8,%esp
  8011cf:	89 c2                	mov    %eax,%edx
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	78 58                	js     80122d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d5:	83 ec 08             	sub    $0x8,%esp
  8011d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011db:	50                   	push   %eax
  8011dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011df:	ff 30                	pushl  (%eax)
  8011e1:	e8 a8 fb ff ff       	call   800d8e <dev_lookup>
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	78 37                	js     801224 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8011ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8011f4:	74 32                	je     801228 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011f6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8011f9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801200:	00 00 00 
	stat->st_isdir = 0;
  801203:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80120a:	00 00 00 
	stat->st_dev = dev;
  80120d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801213:	83 ec 08             	sub    $0x8,%esp
  801216:	53                   	push   %ebx
  801217:	ff 75 f0             	pushl  -0x10(%ebp)
  80121a:	ff 50 14             	call   *0x14(%eax)
  80121d:	89 c2                	mov    %eax,%edx
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	eb 09                	jmp    80122d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801224:	89 c2                	mov    %eax,%edx
  801226:	eb 05                	jmp    80122d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801228:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80122d:	89 d0                	mov    %edx,%eax
  80122f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801232:	c9                   	leave  
  801233:	c3                   	ret    

00801234 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	56                   	push   %esi
  801238:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801239:	83 ec 08             	sub    $0x8,%esp
  80123c:	6a 00                	push   $0x0
  80123e:	ff 75 08             	pushl  0x8(%ebp)
  801241:	e8 09 02 00 00       	call   80144f <open>
  801246:	89 c3                	mov    %eax,%ebx
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 db                	test   %ebx,%ebx
  80124d:	78 1b                	js     80126a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80124f:	83 ec 08             	sub    $0x8,%esp
  801252:	ff 75 0c             	pushl  0xc(%ebp)
  801255:	53                   	push   %ebx
  801256:	e8 5b ff ff ff       	call   8011b6 <fstat>
  80125b:	89 c6                	mov    %eax,%esi
	close(fd);
  80125d:	89 1c 24             	mov    %ebx,(%esp)
  801260:	e8 fd fb ff ff       	call   800e62 <close>
	return r;
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	89 f0                	mov    %esi,%eax
}
  80126a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80126d:	5b                   	pop    %ebx
  80126e:	5e                   	pop    %esi
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	56                   	push   %esi
  801275:	53                   	push   %ebx
  801276:	89 c6                	mov    %eax,%esi
  801278:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80127a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801281:	75 12                	jne    801295 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801283:	83 ec 0c             	sub    $0xc,%esp
  801286:	6a 01                	push   $0x1
  801288:	e8 45 08 00 00       	call   801ad2 <ipc_find_env>
  80128d:	a3 00 40 80 00       	mov    %eax,0x804000
  801292:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801295:	6a 07                	push   $0x7
  801297:	68 00 50 80 00       	push   $0x805000
  80129c:	56                   	push   %esi
  80129d:	ff 35 00 40 80 00    	pushl  0x804000
  8012a3:	e8 d6 07 00 00       	call   801a7e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012a8:	83 c4 0c             	add    $0xc,%esp
  8012ab:	6a 00                	push   $0x0
  8012ad:	53                   	push   %ebx
  8012ae:	6a 00                	push   $0x0
  8012b0:	e8 60 07 00 00       	call   801a15 <ipc_recv>
}
  8012b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b8:	5b                   	pop    %ebx
  8012b9:	5e                   	pop    %esi
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    

008012bc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8012c8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012da:	b8 02 00 00 00       	mov    $0x2,%eax
  8012df:	e8 8d ff ff ff       	call   801271 <fsipc>
}
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8012ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8012f2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8012f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fc:	b8 06 00 00 00       	mov    $0x6,%eax
  801301:	e8 6b ff ff ff       	call   801271 <fsipc>
}
  801306:	c9                   	leave  
  801307:	c3                   	ret    

00801308 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	53                   	push   %ebx
  80130c:	83 ec 04             	sub    $0x4,%esp
  80130f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801312:	8b 45 08             	mov    0x8(%ebp),%eax
  801315:	8b 40 0c             	mov    0xc(%eax),%eax
  801318:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80131d:	ba 00 00 00 00       	mov    $0x0,%edx
  801322:	b8 05 00 00 00       	mov    $0x5,%eax
  801327:	e8 45 ff ff ff       	call   801271 <fsipc>
  80132c:	89 c2                	mov    %eax,%edx
  80132e:	85 d2                	test   %edx,%edx
  801330:	78 2c                	js     80135e <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801332:	83 ec 08             	sub    $0x8,%esp
  801335:	68 00 50 80 00       	push   $0x805000
  80133a:	53                   	push   %ebx
  80133b:	e8 88 f3 ff ff       	call   8006c8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801340:	a1 80 50 80 00       	mov    0x805080,%eax
  801345:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80134b:	a1 84 50 80 00       	mov    0x805084,%eax
  801350:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80135e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	57                   	push   %edi
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
  801369:	83 ec 0c             	sub    $0xc,%esp
  80136c:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  80136f:	8b 45 08             	mov    0x8(%ebp),%eax
  801372:	8b 40 0c             	mov    0xc(%eax),%eax
  801375:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80137a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80137d:	eb 3d                	jmp    8013bc <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  80137f:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801385:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80138a:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80138d:	83 ec 04             	sub    $0x4,%esp
  801390:	57                   	push   %edi
  801391:	53                   	push   %ebx
  801392:	68 08 50 80 00       	push   $0x805008
  801397:	e8 be f4 ff ff       	call   80085a <memmove>
                fsipcbuf.write.req_n = tmp; 
  80139c:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8013a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8013ac:	e8 c0 fe ff ff       	call   801271 <fsipc>
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 0d                	js     8013c5 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8013b8:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8013ba:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8013bc:	85 f6                	test   %esi,%esi
  8013be:	75 bf                	jne    80137f <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8013c0:	89 d8                	mov    %ebx,%eax
  8013c2:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8013c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5f                   	pop    %edi
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    

008013cd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	56                   	push   %esi
  8013d1:	53                   	push   %ebx
  8013d2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013db:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013e0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8013f0:	e8 7c fe ff ff       	call   801271 <fsipc>
  8013f5:	89 c3                	mov    %eax,%ebx
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 4b                	js     801446 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013fb:	39 c6                	cmp    %eax,%esi
  8013fd:	73 16                	jae    801415 <devfile_read+0x48>
  8013ff:	68 18 22 80 00       	push   $0x802218
  801404:	68 1f 22 80 00       	push   $0x80221f
  801409:	6a 7c                	push   $0x7c
  80140b:	68 34 22 80 00       	push   $0x802234
  801410:	e8 ba 05 00 00       	call   8019cf <_panic>
	assert(r <= PGSIZE);
  801415:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80141a:	7e 16                	jle    801432 <devfile_read+0x65>
  80141c:	68 3f 22 80 00       	push   $0x80223f
  801421:	68 1f 22 80 00       	push   $0x80221f
  801426:	6a 7d                	push   $0x7d
  801428:	68 34 22 80 00       	push   $0x802234
  80142d:	e8 9d 05 00 00       	call   8019cf <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801432:	83 ec 04             	sub    $0x4,%esp
  801435:	50                   	push   %eax
  801436:	68 00 50 80 00       	push   $0x805000
  80143b:	ff 75 0c             	pushl  0xc(%ebp)
  80143e:	e8 17 f4 ff ff       	call   80085a <memmove>
	return r;
  801443:	83 c4 10             	add    $0x10,%esp
}
  801446:	89 d8                	mov    %ebx,%eax
  801448:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144b:	5b                   	pop    %ebx
  80144c:	5e                   	pop    %esi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    

0080144f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	53                   	push   %ebx
  801453:	83 ec 20             	sub    $0x20,%esp
  801456:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801459:	53                   	push   %ebx
  80145a:	e8 30 f2 ff ff       	call   80068f <strlen>
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801467:	7f 67                	jg     8014d0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801469:	83 ec 0c             	sub    $0xc,%esp
  80146c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146f:	50                   	push   %eax
  801470:	e8 74 f8 ff ff       	call   800ce9 <fd_alloc>
  801475:	83 c4 10             	add    $0x10,%esp
		return r;
  801478:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 57                	js     8014d5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80147e:	83 ec 08             	sub    $0x8,%esp
  801481:	53                   	push   %ebx
  801482:	68 00 50 80 00       	push   $0x805000
  801487:	e8 3c f2 ff ff       	call   8006c8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80148c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801494:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801497:	b8 01 00 00 00       	mov    $0x1,%eax
  80149c:	e8 d0 fd ff ff       	call   801271 <fsipc>
  8014a1:	89 c3                	mov    %eax,%ebx
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	79 14                	jns    8014be <open+0x6f>
		fd_close(fd, 0);
  8014aa:	83 ec 08             	sub    $0x8,%esp
  8014ad:	6a 00                	push   $0x0
  8014af:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b2:	e8 2a f9 ff ff       	call   800de1 <fd_close>
		return r;
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	89 da                	mov    %ebx,%edx
  8014bc:	eb 17                	jmp    8014d5 <open+0x86>
	}

	return fd2num(fd);
  8014be:	83 ec 0c             	sub    $0xc,%esp
  8014c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c4:	e8 f9 f7 ff ff       	call   800cc2 <fd2num>
  8014c9:	89 c2                	mov    %eax,%edx
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	eb 05                	jmp    8014d5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014d0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014d5:	89 d0                	mov    %edx,%eax
  8014d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014da:	c9                   	leave  
  8014db:	c3                   	ret    

008014dc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e7:	b8 08 00 00 00       	mov    $0x8,%eax
  8014ec:	e8 80 fd ff ff       	call   801271 <fsipc>
}
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    

008014f3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
  8014f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014fb:	83 ec 0c             	sub    $0xc,%esp
  8014fe:	ff 75 08             	pushl  0x8(%ebp)
  801501:	e8 cc f7 ff ff       	call   800cd2 <fd2data>
  801506:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801508:	83 c4 08             	add    $0x8,%esp
  80150b:	68 4b 22 80 00       	push   $0x80224b
  801510:	53                   	push   %ebx
  801511:	e8 b2 f1 ff ff       	call   8006c8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801516:	8b 56 04             	mov    0x4(%esi),%edx
  801519:	89 d0                	mov    %edx,%eax
  80151b:	2b 06                	sub    (%esi),%eax
  80151d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801523:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80152a:	00 00 00 
	stat->st_dev = &devpipe;
  80152d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801534:	30 80 00 
	return 0;
}
  801537:	b8 00 00 00 00       	mov    $0x0,%eax
  80153c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153f:	5b                   	pop    %ebx
  801540:	5e                   	pop    %esi
  801541:	5d                   	pop    %ebp
  801542:	c3                   	ret    

00801543 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	53                   	push   %ebx
  801547:	83 ec 0c             	sub    $0xc,%esp
  80154a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80154d:	53                   	push   %ebx
  80154e:	6a 00                	push   $0x0
  801550:	e8 01 f6 ff ff       	call   800b56 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801555:	89 1c 24             	mov    %ebx,(%esp)
  801558:	e8 75 f7 ff ff       	call   800cd2 <fd2data>
  80155d:	83 c4 08             	add    $0x8,%esp
  801560:	50                   	push   %eax
  801561:	6a 00                	push   $0x0
  801563:	e8 ee f5 ff ff       	call   800b56 <sys_page_unmap>
}
  801568:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156b:	c9                   	leave  
  80156c:	c3                   	ret    

0080156d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	57                   	push   %edi
  801571:	56                   	push   %esi
  801572:	53                   	push   %ebx
  801573:	83 ec 1c             	sub    $0x1c,%esp
  801576:	89 c6                	mov    %eax,%esi
  801578:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80157b:	a1 04 40 80 00       	mov    0x804004,%eax
  801580:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801583:	83 ec 0c             	sub    $0xc,%esp
  801586:	56                   	push   %esi
  801587:	e8 7e 05 00 00       	call   801b0a <pageref>
  80158c:	89 c7                	mov    %eax,%edi
  80158e:	83 c4 04             	add    $0x4,%esp
  801591:	ff 75 e4             	pushl  -0x1c(%ebp)
  801594:	e8 71 05 00 00       	call   801b0a <pageref>
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	39 c7                	cmp    %eax,%edi
  80159e:	0f 94 c2             	sete   %dl
  8015a1:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8015a4:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  8015aa:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8015ad:	39 fb                	cmp    %edi,%ebx
  8015af:	74 19                	je     8015ca <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8015b1:	84 d2                	test   %dl,%dl
  8015b3:	74 c6                	je     80157b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015b5:	8b 51 58             	mov    0x58(%ecx),%edx
  8015b8:	50                   	push   %eax
  8015b9:	52                   	push   %edx
  8015ba:	53                   	push   %ebx
  8015bb:	68 52 22 80 00       	push   $0x802252
  8015c0:	e8 7c eb ff ff       	call   800141 <cprintf>
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	eb b1                	jmp    80157b <_pipeisclosed+0xe>
	}
}
  8015ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5e                   	pop    %esi
  8015cf:	5f                   	pop    %edi
  8015d0:	5d                   	pop    %ebp
  8015d1:	c3                   	ret    

008015d2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	57                   	push   %edi
  8015d6:	56                   	push   %esi
  8015d7:	53                   	push   %ebx
  8015d8:	83 ec 28             	sub    $0x28,%esp
  8015db:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015de:	56                   	push   %esi
  8015df:	e8 ee f6 ff ff       	call   800cd2 <fd2data>
  8015e4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	bf 00 00 00 00       	mov    $0x0,%edi
  8015ee:	eb 4b                	jmp    80163b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015f0:	89 da                	mov    %ebx,%edx
  8015f2:	89 f0                	mov    %esi,%eax
  8015f4:	e8 74 ff ff ff       	call   80156d <_pipeisclosed>
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	75 48                	jne    801645 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015fd:	e8 b0 f4 ff ff       	call   800ab2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801602:	8b 43 04             	mov    0x4(%ebx),%eax
  801605:	8b 0b                	mov    (%ebx),%ecx
  801607:	8d 51 20             	lea    0x20(%ecx),%edx
  80160a:	39 d0                	cmp    %edx,%eax
  80160c:	73 e2                	jae    8015f0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80160e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801611:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801615:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801618:	89 c2                	mov    %eax,%edx
  80161a:	c1 fa 1f             	sar    $0x1f,%edx
  80161d:	89 d1                	mov    %edx,%ecx
  80161f:	c1 e9 1b             	shr    $0x1b,%ecx
  801622:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801625:	83 e2 1f             	and    $0x1f,%edx
  801628:	29 ca                	sub    %ecx,%edx
  80162a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80162e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801632:	83 c0 01             	add    $0x1,%eax
  801635:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801638:	83 c7 01             	add    $0x1,%edi
  80163b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80163e:	75 c2                	jne    801602 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801640:	8b 45 10             	mov    0x10(%ebp),%eax
  801643:	eb 05                	jmp    80164a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801645:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80164a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164d:	5b                   	pop    %ebx
  80164e:	5e                   	pop    %esi
  80164f:	5f                   	pop    %edi
  801650:	5d                   	pop    %ebp
  801651:	c3                   	ret    

00801652 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	57                   	push   %edi
  801656:	56                   	push   %esi
  801657:	53                   	push   %ebx
  801658:	83 ec 18             	sub    $0x18,%esp
  80165b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80165e:	57                   	push   %edi
  80165f:	e8 6e f6 ff ff       	call   800cd2 <fd2data>
  801664:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	bb 00 00 00 00       	mov    $0x0,%ebx
  80166e:	eb 3d                	jmp    8016ad <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801670:	85 db                	test   %ebx,%ebx
  801672:	74 04                	je     801678 <devpipe_read+0x26>
				return i;
  801674:	89 d8                	mov    %ebx,%eax
  801676:	eb 44                	jmp    8016bc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801678:	89 f2                	mov    %esi,%edx
  80167a:	89 f8                	mov    %edi,%eax
  80167c:	e8 ec fe ff ff       	call   80156d <_pipeisclosed>
  801681:	85 c0                	test   %eax,%eax
  801683:	75 32                	jne    8016b7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801685:	e8 28 f4 ff ff       	call   800ab2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80168a:	8b 06                	mov    (%esi),%eax
  80168c:	3b 46 04             	cmp    0x4(%esi),%eax
  80168f:	74 df                	je     801670 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801691:	99                   	cltd   
  801692:	c1 ea 1b             	shr    $0x1b,%edx
  801695:	01 d0                	add    %edx,%eax
  801697:	83 e0 1f             	and    $0x1f,%eax
  80169a:	29 d0                	sub    %edx,%eax
  80169c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016a7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016aa:	83 c3 01             	add    $0x1,%ebx
  8016ad:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016b0:	75 d8                	jne    80168a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8016b5:	eb 05                	jmp    8016bc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016b7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bf:	5b                   	pop    %ebx
  8016c0:	5e                   	pop    %esi
  8016c1:	5f                   	pop    %edi
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	56                   	push   %esi
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cf:	50                   	push   %eax
  8016d0:	e8 14 f6 ff ff       	call   800ce9 <fd_alloc>
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	89 c2                	mov    %eax,%edx
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	0f 88 2c 01 00 00    	js     80180e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016e2:	83 ec 04             	sub    $0x4,%esp
  8016e5:	68 07 04 00 00       	push   $0x407
  8016ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ed:	6a 00                	push   $0x0
  8016ef:	e8 dd f3 ff ff       	call   800ad1 <sys_page_alloc>
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	0f 88 0d 01 00 00    	js     80180e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801701:	83 ec 0c             	sub    $0xc,%esp
  801704:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801707:	50                   	push   %eax
  801708:	e8 dc f5 ff ff       	call   800ce9 <fd_alloc>
  80170d:	89 c3                	mov    %eax,%ebx
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	85 c0                	test   %eax,%eax
  801714:	0f 88 e2 00 00 00    	js     8017fc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80171a:	83 ec 04             	sub    $0x4,%esp
  80171d:	68 07 04 00 00       	push   $0x407
  801722:	ff 75 f0             	pushl  -0x10(%ebp)
  801725:	6a 00                	push   $0x0
  801727:	e8 a5 f3 ff ff       	call   800ad1 <sys_page_alloc>
  80172c:	89 c3                	mov    %eax,%ebx
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	85 c0                	test   %eax,%eax
  801733:	0f 88 c3 00 00 00    	js     8017fc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801739:	83 ec 0c             	sub    $0xc,%esp
  80173c:	ff 75 f4             	pushl  -0xc(%ebp)
  80173f:	e8 8e f5 ff ff       	call   800cd2 <fd2data>
  801744:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801746:	83 c4 0c             	add    $0xc,%esp
  801749:	68 07 04 00 00       	push   $0x407
  80174e:	50                   	push   %eax
  80174f:	6a 00                	push   $0x0
  801751:	e8 7b f3 ff ff       	call   800ad1 <sys_page_alloc>
  801756:	89 c3                	mov    %eax,%ebx
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	85 c0                	test   %eax,%eax
  80175d:	0f 88 89 00 00 00    	js     8017ec <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801763:	83 ec 0c             	sub    $0xc,%esp
  801766:	ff 75 f0             	pushl  -0x10(%ebp)
  801769:	e8 64 f5 ff ff       	call   800cd2 <fd2data>
  80176e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801775:	50                   	push   %eax
  801776:	6a 00                	push   $0x0
  801778:	56                   	push   %esi
  801779:	6a 00                	push   $0x0
  80177b:	e8 94 f3 ff ff       	call   800b14 <sys_page_map>
  801780:	89 c3                	mov    %eax,%ebx
  801782:	83 c4 20             	add    $0x20,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	78 55                	js     8017de <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801789:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80178f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801792:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801794:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801797:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80179e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ac:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017b3:	83 ec 0c             	sub    $0xc,%esp
  8017b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b9:	e8 04 f5 ff ff       	call   800cc2 <fd2num>
  8017be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017c3:	83 c4 04             	add    $0x4,%esp
  8017c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c9:	e8 f4 f4 ff ff       	call   800cc2 <fd2num>
  8017ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017dc:	eb 30                	jmp    80180e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017de:	83 ec 08             	sub    $0x8,%esp
  8017e1:	56                   	push   %esi
  8017e2:	6a 00                	push   $0x0
  8017e4:	e8 6d f3 ff ff       	call   800b56 <sys_page_unmap>
  8017e9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f2:	6a 00                	push   $0x0
  8017f4:	e8 5d f3 ff ff       	call   800b56 <sys_page_unmap>
  8017f9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801802:	6a 00                	push   $0x0
  801804:	e8 4d f3 ff ff       	call   800b56 <sys_page_unmap>
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80180e:	89 d0                	mov    %edx,%eax
  801810:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801813:	5b                   	pop    %ebx
  801814:	5e                   	pop    %esi
  801815:	5d                   	pop    %ebp
  801816:	c3                   	ret    

00801817 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80181d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801820:	50                   	push   %eax
  801821:	ff 75 08             	pushl  0x8(%ebp)
  801824:	e8 0f f5 ff ff       	call   800d38 <fd_lookup>
  801829:	89 c2                	mov    %eax,%edx
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	85 d2                	test   %edx,%edx
  801830:	78 18                	js     80184a <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801832:	83 ec 0c             	sub    $0xc,%esp
  801835:	ff 75 f4             	pushl  -0xc(%ebp)
  801838:	e8 95 f4 ff ff       	call   800cd2 <fd2data>
	return _pipeisclosed(fd, p);
  80183d:	89 c2                	mov    %eax,%edx
  80183f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801842:	e8 26 fd ff ff       	call   80156d <_pipeisclosed>
  801847:	83 c4 10             	add    $0x10,%esp
}
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80184f:	b8 00 00 00 00       	mov    $0x0,%eax
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    

00801856 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80185c:	68 6a 22 80 00       	push   $0x80226a
  801861:	ff 75 0c             	pushl  0xc(%ebp)
  801864:	e8 5f ee ff ff       	call   8006c8 <strcpy>
	return 0;
}
  801869:	b8 00 00 00 00       	mov    $0x0,%eax
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	57                   	push   %edi
  801874:	56                   	push   %esi
  801875:	53                   	push   %ebx
  801876:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80187c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801881:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801887:	eb 2d                	jmp    8018b6 <devcons_write+0x46>
		m = n - tot;
  801889:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80188c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80188e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801891:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801896:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801899:	83 ec 04             	sub    $0x4,%esp
  80189c:	53                   	push   %ebx
  80189d:	03 45 0c             	add    0xc(%ebp),%eax
  8018a0:	50                   	push   %eax
  8018a1:	57                   	push   %edi
  8018a2:	e8 b3 ef ff ff       	call   80085a <memmove>
		sys_cputs(buf, m);
  8018a7:	83 c4 08             	add    $0x8,%esp
  8018aa:	53                   	push   %ebx
  8018ab:	57                   	push   %edi
  8018ac:	e8 64 f1 ff ff       	call   800a15 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018b1:	01 de                	add    %ebx,%esi
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	89 f0                	mov    %esi,%eax
  8018b8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018bb:	72 cc                	jb     801889 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c0:	5b                   	pop    %ebx
  8018c1:	5e                   	pop    %esi
  8018c2:	5f                   	pop    %edi
  8018c3:	5d                   	pop    %ebp
  8018c4:	c3                   	ret    

008018c5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8018cb:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8018d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018d4:	75 07                	jne    8018dd <devcons_read+0x18>
  8018d6:	eb 28                	jmp    801900 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018d8:	e8 d5 f1 ff ff       	call   800ab2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018dd:	e8 51 f1 ff ff       	call   800a33 <sys_cgetc>
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	74 f2                	je     8018d8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 16                	js     801900 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018ea:	83 f8 04             	cmp    $0x4,%eax
  8018ed:	74 0c                	je     8018fb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f2:	88 02                	mov    %al,(%edx)
	return 1;
  8018f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f9:	eb 05                	jmp    801900 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018fb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801908:	8b 45 08             	mov    0x8(%ebp),%eax
  80190b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80190e:	6a 01                	push   $0x1
  801910:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	e8 fc f0 ff ff       	call   800a15 <sys_cputs>
  801919:	83 c4 10             	add    $0x10,%esp
}
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <getchar>:

int
getchar(void)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801924:	6a 01                	push   $0x1
  801926:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801929:	50                   	push   %eax
  80192a:	6a 00                	push   $0x0
  80192c:	e8 71 f6 ff ff       	call   800fa2 <read>
	if (r < 0)
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	85 c0                	test   %eax,%eax
  801936:	78 0f                	js     801947 <getchar+0x29>
		return r;
	if (r < 1)
  801938:	85 c0                	test   %eax,%eax
  80193a:	7e 06                	jle    801942 <getchar+0x24>
		return -E_EOF;
	return c;
  80193c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801940:	eb 05                	jmp    801947 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801942:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801947:	c9                   	leave  
  801948:	c3                   	ret    

00801949 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80194f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801952:	50                   	push   %eax
  801953:	ff 75 08             	pushl  0x8(%ebp)
  801956:	e8 dd f3 ff ff       	call   800d38 <fd_lookup>
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	85 c0                	test   %eax,%eax
  801960:	78 11                	js     801973 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801962:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801965:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80196b:	39 10                	cmp    %edx,(%eax)
  80196d:	0f 94 c0             	sete   %al
  801970:	0f b6 c0             	movzbl %al,%eax
}
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <opencons>:

int
opencons(void)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80197b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197e:	50                   	push   %eax
  80197f:	e8 65 f3 ff ff       	call   800ce9 <fd_alloc>
  801984:	83 c4 10             	add    $0x10,%esp
		return r;
  801987:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801989:	85 c0                	test   %eax,%eax
  80198b:	78 3e                	js     8019cb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80198d:	83 ec 04             	sub    $0x4,%esp
  801990:	68 07 04 00 00       	push   $0x407
  801995:	ff 75 f4             	pushl  -0xc(%ebp)
  801998:	6a 00                	push   $0x0
  80199a:	e8 32 f1 ff ff       	call   800ad1 <sys_page_alloc>
  80199f:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	78 23                	js     8019cb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019a8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	50                   	push   %eax
  8019c1:	e8 fc f2 ff ff       	call   800cc2 <fd2num>
  8019c6:	89 c2                	mov    %eax,%edx
  8019c8:	83 c4 10             	add    $0x10,%esp
}
  8019cb:	89 d0                	mov    %edx,%eax
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	56                   	push   %esi
  8019d3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019d4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019d7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019dd:	e8 b1 f0 ff ff       	call   800a93 <sys_getenvid>
  8019e2:	83 ec 0c             	sub    $0xc,%esp
  8019e5:	ff 75 0c             	pushl  0xc(%ebp)
  8019e8:	ff 75 08             	pushl  0x8(%ebp)
  8019eb:	56                   	push   %esi
  8019ec:	50                   	push   %eax
  8019ed:	68 78 22 80 00       	push   $0x802278
  8019f2:	e8 4a e7 ff ff       	call   800141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019f7:	83 c4 18             	add    $0x18,%esp
  8019fa:	53                   	push   %ebx
  8019fb:	ff 75 10             	pushl  0x10(%ebp)
  8019fe:	e8 ed e6 ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  801a03:	c7 04 24 63 22 80 00 	movl   $0x802263,(%esp)
  801a0a:	e8 32 e7 ff ff       	call   800141 <cprintf>
  801a0f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a12:	cc                   	int3   
  801a13:	eb fd                	jmp    801a12 <_panic+0x43>

00801a15 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	56                   	push   %esi
  801a19:	53                   	push   %ebx
  801a1a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801a23:	85 c0                	test   %eax,%eax
  801a25:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a2a:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801a2d:	83 ec 0c             	sub    $0xc,%esp
  801a30:	50                   	push   %eax
  801a31:	e8 4b f2 ff ff       	call   800c81 <sys_ipc_recv>
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	79 16                	jns    801a53 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801a3d:	85 f6                	test   %esi,%esi
  801a3f:	74 06                	je     801a47 <ipc_recv+0x32>
  801a41:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801a47:	85 db                	test   %ebx,%ebx
  801a49:	74 2c                	je     801a77 <ipc_recv+0x62>
  801a4b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a51:	eb 24                	jmp    801a77 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a53:	85 f6                	test   %esi,%esi
  801a55:	74 0a                	je     801a61 <ipc_recv+0x4c>
  801a57:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5c:	8b 40 74             	mov    0x74(%eax),%eax
  801a5f:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801a61:	85 db                	test   %ebx,%ebx
  801a63:	74 0a                	je     801a6f <ipc_recv+0x5a>
  801a65:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6a:	8b 40 78             	mov    0x78(%eax),%eax
  801a6d:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801a6f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a74:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5e                   	pop    %esi
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	57                   	push   %edi
  801a82:	56                   	push   %esi
  801a83:	53                   	push   %ebx
  801a84:	83 ec 0c             	sub    $0xc,%esp
  801a87:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801a90:	85 db                	test   %ebx,%ebx
  801a92:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a97:	0f 44 d8             	cmove  %eax,%ebx
  801a9a:	eb 1c                	jmp    801ab8 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801a9c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a9f:	74 12                	je     801ab3 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801aa1:	50                   	push   %eax
  801aa2:	68 9c 22 80 00       	push   $0x80229c
  801aa7:	6a 39                	push   $0x39
  801aa9:	68 b7 22 80 00       	push   $0x8022b7
  801aae:	e8 1c ff ff ff       	call   8019cf <_panic>
                 sys_yield();
  801ab3:	e8 fa ef ff ff       	call   800ab2 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ab8:	ff 75 14             	pushl  0x14(%ebp)
  801abb:	53                   	push   %ebx
  801abc:	56                   	push   %esi
  801abd:	57                   	push   %edi
  801abe:	e8 9b f1 ff ff       	call   800c5e <sys_ipc_try_send>
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	78 d2                	js     801a9c <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801aca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acd:	5b                   	pop    %ebx
  801ace:	5e                   	pop    %esi
  801acf:	5f                   	pop    %edi
  801ad0:	5d                   	pop    %ebp
  801ad1:	c3                   	ret    

00801ad2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ad8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801add:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ae0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ae6:	8b 52 50             	mov    0x50(%edx),%edx
  801ae9:	39 ca                	cmp    %ecx,%edx
  801aeb:	75 0d                	jne    801afa <ipc_find_env+0x28>
			return envs[i].env_id;
  801aed:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801af0:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801af5:	8b 40 08             	mov    0x8(%eax),%eax
  801af8:	eb 0e                	jmp    801b08 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801afa:	83 c0 01             	add    $0x1,%eax
  801afd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b02:	75 d9                	jne    801add <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b04:	66 b8 00 00          	mov    $0x0,%ax
}
  801b08:	5d                   	pop    %ebp
  801b09:	c3                   	ret    

00801b0a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b10:	89 d0                	mov    %edx,%eax
  801b12:	c1 e8 16             	shr    $0x16,%eax
  801b15:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b21:	f6 c1 01             	test   $0x1,%cl
  801b24:	74 1d                	je     801b43 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b26:	c1 ea 0c             	shr    $0xc,%edx
  801b29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b30:	f6 c2 01             	test   $0x1,%dl
  801b33:	74 0e                	je     801b43 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b35:	c1 ea 0c             	shr    $0xc,%edx
  801b38:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b3f:	ef 
  801b40:	0f b7 c0             	movzwl %ax,%eax
}
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    
  801b45:	66 90                	xchg   %ax,%ax
  801b47:	66 90                	xchg   %ax,%ax
  801b49:	66 90                	xchg   %ax,%ax
  801b4b:	66 90                	xchg   %ax,%ax
  801b4d:	66 90                	xchg   %ax,%ax
  801b4f:	90                   	nop

00801b50 <__udivdi3>:
  801b50:	55                   	push   %ebp
  801b51:	57                   	push   %edi
  801b52:	56                   	push   %esi
  801b53:	83 ec 10             	sub    $0x10,%esp
  801b56:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b5a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b5e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b66:	85 d2                	test   %edx,%edx
  801b68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b6c:	89 34 24             	mov    %esi,(%esp)
  801b6f:	89 c8                	mov    %ecx,%eax
  801b71:	75 35                	jne    801ba8 <__udivdi3+0x58>
  801b73:	39 f1                	cmp    %esi,%ecx
  801b75:	0f 87 bd 00 00 00    	ja     801c38 <__udivdi3+0xe8>
  801b7b:	85 c9                	test   %ecx,%ecx
  801b7d:	89 cd                	mov    %ecx,%ebp
  801b7f:	75 0b                	jne    801b8c <__udivdi3+0x3c>
  801b81:	b8 01 00 00 00       	mov    $0x1,%eax
  801b86:	31 d2                	xor    %edx,%edx
  801b88:	f7 f1                	div    %ecx
  801b8a:	89 c5                	mov    %eax,%ebp
  801b8c:	89 f0                	mov    %esi,%eax
  801b8e:	31 d2                	xor    %edx,%edx
  801b90:	f7 f5                	div    %ebp
  801b92:	89 c6                	mov    %eax,%esi
  801b94:	89 f8                	mov    %edi,%eax
  801b96:	f7 f5                	div    %ebp
  801b98:	89 f2                	mov    %esi,%edx
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	5e                   	pop    %esi
  801b9e:	5f                   	pop    %edi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    
  801ba1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ba8:	3b 14 24             	cmp    (%esp),%edx
  801bab:	77 7b                	ja     801c28 <__udivdi3+0xd8>
  801bad:	0f bd f2             	bsr    %edx,%esi
  801bb0:	83 f6 1f             	xor    $0x1f,%esi
  801bb3:	0f 84 97 00 00 00    	je     801c50 <__udivdi3+0x100>
  801bb9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801bbe:	89 d7                	mov    %edx,%edi
  801bc0:	89 f1                	mov    %esi,%ecx
  801bc2:	29 f5                	sub    %esi,%ebp
  801bc4:	d3 e7                	shl    %cl,%edi
  801bc6:	89 c2                	mov    %eax,%edx
  801bc8:	89 e9                	mov    %ebp,%ecx
  801bca:	d3 ea                	shr    %cl,%edx
  801bcc:	89 f1                	mov    %esi,%ecx
  801bce:	09 fa                	or     %edi,%edx
  801bd0:	8b 3c 24             	mov    (%esp),%edi
  801bd3:	d3 e0                	shl    %cl,%eax
  801bd5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bd9:	89 e9                	mov    %ebp,%ecx
  801bdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bdf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801be3:	89 fa                	mov    %edi,%edx
  801be5:	d3 ea                	shr    %cl,%edx
  801be7:	89 f1                	mov    %esi,%ecx
  801be9:	d3 e7                	shl    %cl,%edi
  801beb:	89 e9                	mov    %ebp,%ecx
  801bed:	d3 e8                	shr    %cl,%eax
  801bef:	09 c7                	or     %eax,%edi
  801bf1:	89 f8                	mov    %edi,%eax
  801bf3:	f7 74 24 08          	divl   0x8(%esp)
  801bf7:	89 d5                	mov    %edx,%ebp
  801bf9:	89 c7                	mov    %eax,%edi
  801bfb:	f7 64 24 0c          	mull   0xc(%esp)
  801bff:	39 d5                	cmp    %edx,%ebp
  801c01:	89 14 24             	mov    %edx,(%esp)
  801c04:	72 11                	jb     801c17 <__udivdi3+0xc7>
  801c06:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c0a:	89 f1                	mov    %esi,%ecx
  801c0c:	d3 e2                	shl    %cl,%edx
  801c0e:	39 c2                	cmp    %eax,%edx
  801c10:	73 5e                	jae    801c70 <__udivdi3+0x120>
  801c12:	3b 2c 24             	cmp    (%esp),%ebp
  801c15:	75 59                	jne    801c70 <__udivdi3+0x120>
  801c17:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c1a:	31 f6                	xor    %esi,%esi
  801c1c:	89 f2                	mov    %esi,%edx
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    
  801c25:	8d 76 00             	lea    0x0(%esi),%esi
  801c28:	31 f6                	xor    %esi,%esi
  801c2a:	31 c0                	xor    %eax,%eax
  801c2c:	89 f2                	mov    %esi,%edx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    
  801c35:	8d 76 00             	lea    0x0(%esi),%esi
  801c38:	89 f2                	mov    %esi,%edx
  801c3a:	31 f6                	xor    %esi,%esi
  801c3c:	89 f8                	mov    %edi,%eax
  801c3e:	f7 f1                	div    %ecx
  801c40:	89 f2                	mov    %esi,%edx
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	5e                   	pop    %esi
  801c46:	5f                   	pop    %edi
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c54:	76 0b                	jbe    801c61 <__udivdi3+0x111>
  801c56:	31 c0                	xor    %eax,%eax
  801c58:	3b 14 24             	cmp    (%esp),%edx
  801c5b:	0f 83 37 ff ff ff    	jae    801b98 <__udivdi3+0x48>
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	e9 2d ff ff ff       	jmp    801b98 <__udivdi3+0x48>
  801c6b:	90                   	nop
  801c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c70:	89 f8                	mov    %edi,%eax
  801c72:	31 f6                	xor    %esi,%esi
  801c74:	e9 1f ff ff ff       	jmp    801b98 <__udivdi3+0x48>
  801c79:	66 90                	xchg   %ax,%ax
  801c7b:	66 90                	xchg   %ax,%ax
  801c7d:	66 90                	xchg   %ax,%ax
  801c7f:	90                   	nop

00801c80 <__umoddi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	83 ec 20             	sub    $0x20,%esp
  801c86:	8b 44 24 34          	mov    0x34(%esp),%eax
  801c8a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c8e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c92:	89 c6                	mov    %eax,%esi
  801c94:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c98:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c9c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801ca0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ca4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801ca8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801cac:	85 c0                	test   %eax,%eax
  801cae:	89 c2                	mov    %eax,%edx
  801cb0:	75 1e                	jne    801cd0 <__umoddi3+0x50>
  801cb2:	39 f7                	cmp    %esi,%edi
  801cb4:	76 52                	jbe    801d08 <__umoddi3+0x88>
  801cb6:	89 c8                	mov    %ecx,%eax
  801cb8:	89 f2                	mov    %esi,%edx
  801cba:	f7 f7                	div    %edi
  801cbc:	89 d0                	mov    %edx,%eax
  801cbe:	31 d2                	xor    %edx,%edx
  801cc0:	83 c4 20             	add    $0x20,%esp
  801cc3:	5e                   	pop    %esi
  801cc4:	5f                   	pop    %edi
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    
  801cc7:	89 f6                	mov    %esi,%esi
  801cc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801cd0:	39 f0                	cmp    %esi,%eax
  801cd2:	77 5c                	ja     801d30 <__umoddi3+0xb0>
  801cd4:	0f bd e8             	bsr    %eax,%ebp
  801cd7:	83 f5 1f             	xor    $0x1f,%ebp
  801cda:	75 64                	jne    801d40 <__umoddi3+0xc0>
  801cdc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801ce0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801ce4:	0f 86 f6 00 00 00    	jbe    801de0 <__umoddi3+0x160>
  801cea:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cee:	0f 82 ec 00 00 00    	jb     801de0 <__umoddi3+0x160>
  801cf4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801cf8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801cfc:	83 c4 20             	add    $0x20,%esp
  801cff:	5e                   	pop    %esi
  801d00:	5f                   	pop    %edi
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    
  801d03:	90                   	nop
  801d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d08:	85 ff                	test   %edi,%edi
  801d0a:	89 fd                	mov    %edi,%ebp
  801d0c:	75 0b                	jne    801d19 <__umoddi3+0x99>
  801d0e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f7                	div    %edi
  801d17:	89 c5                	mov    %eax,%ebp
  801d19:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d1d:	31 d2                	xor    %edx,%edx
  801d1f:	f7 f5                	div    %ebp
  801d21:	89 c8                	mov    %ecx,%eax
  801d23:	f7 f5                	div    %ebp
  801d25:	eb 95                	jmp    801cbc <__umoddi3+0x3c>
  801d27:	89 f6                	mov    %esi,%esi
  801d29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	83 c4 20             	add    $0x20,%esp
  801d37:	5e                   	pop    %esi
  801d38:	5f                   	pop    %edi
  801d39:	5d                   	pop    %ebp
  801d3a:	c3                   	ret    
  801d3b:	90                   	nop
  801d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d40:	b8 20 00 00 00       	mov    $0x20,%eax
  801d45:	89 e9                	mov    %ebp,%ecx
  801d47:	29 e8                	sub    %ebp,%eax
  801d49:	d3 e2                	shl    %cl,%edx
  801d4b:	89 c7                	mov    %eax,%edi
  801d4d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d51:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d55:	89 f9                	mov    %edi,%ecx
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 c1                	mov    %eax,%ecx
  801d5b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d5f:	09 d1                	or     %edx,%ecx
  801d61:	89 fa                	mov    %edi,%edx
  801d63:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d67:	89 e9                	mov    %ebp,%ecx
  801d69:	d3 e0                	shl    %cl,%eax
  801d6b:	89 f9                	mov    %edi,%ecx
  801d6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	d3 e8                	shr    %cl,%eax
  801d75:	89 e9                	mov    %ebp,%ecx
  801d77:	89 c7                	mov    %eax,%edi
  801d79:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d7d:	d3 e6                	shl    %cl,%esi
  801d7f:	89 d1                	mov    %edx,%ecx
  801d81:	89 fa                	mov    %edi,%edx
  801d83:	d3 e8                	shr    %cl,%eax
  801d85:	89 e9                	mov    %ebp,%ecx
  801d87:	09 f0                	or     %esi,%eax
  801d89:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801d8d:	f7 74 24 10          	divl   0x10(%esp)
  801d91:	d3 e6                	shl    %cl,%esi
  801d93:	89 d1                	mov    %edx,%ecx
  801d95:	f7 64 24 0c          	mull   0xc(%esp)
  801d99:	39 d1                	cmp    %edx,%ecx
  801d9b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801d9f:	89 d7                	mov    %edx,%edi
  801da1:	89 c6                	mov    %eax,%esi
  801da3:	72 0a                	jb     801daf <__umoddi3+0x12f>
  801da5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801da9:	73 10                	jae    801dbb <__umoddi3+0x13b>
  801dab:	39 d1                	cmp    %edx,%ecx
  801dad:	75 0c                	jne    801dbb <__umoddi3+0x13b>
  801daf:	89 d7                	mov    %edx,%edi
  801db1:	89 c6                	mov    %eax,%esi
  801db3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801db7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801dbb:	89 ca                	mov    %ecx,%edx
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801dc3:	29 f0                	sub    %esi,%eax
  801dc5:	19 fa                	sbb    %edi,%edx
  801dc7:	d3 e8                	shr    %cl,%eax
  801dc9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801dce:	89 d7                	mov    %edx,%edi
  801dd0:	d3 e7                	shl    %cl,%edi
  801dd2:	89 e9                	mov    %ebp,%ecx
  801dd4:	09 f8                	or     %edi,%eax
  801dd6:	d3 ea                	shr    %cl,%edx
  801dd8:	83 c4 20             	add    $0x20,%esp
  801ddb:	5e                   	pop    %esi
  801ddc:	5f                   	pop    %edi
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    
  801ddf:	90                   	nop
  801de0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801de4:	29 f9                	sub    %edi,%ecx
  801de6:	19 c6                	sbb    %eax,%esi
  801de8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801dec:	89 74 24 18          	mov    %esi,0x18(%esp)
  801df0:	e9 ff fe ff ff       	jmp    801cf4 <__umoddi3+0x74>
