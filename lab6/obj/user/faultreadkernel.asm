
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
  80003f:	68 40 23 80 00       	push   $0x802340
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
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80009a:	e8 96 0e 00 00       	call   800f35 <close_all>
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
  8001a4:	e8 b7 1e 00 00       	call   802060 <__udivdi3>
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
  8001e2:	e8 a9 1f 00 00       	call   802190 <__umoddi3>
  8001e7:	83 c4 14             	add    $0x14,%esp
  8001ea:	0f be 80 71 23 80 00 	movsbl 0x802371(%eax),%eax
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
  8002e6:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
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
  8003aa:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8003b1:	85 d2                	test   %edx,%edx
  8003b3:	75 18                	jne    8003cd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003b5:	50                   	push   %eax
  8003b6:	68 89 23 80 00       	push   $0x802389
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
  8003ce:	68 75 27 80 00       	push   $0x802775
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
  8003fb:	ba 82 23 80 00       	mov    $0x802382,%edx
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
	// return value.
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
	// return value.
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
	// return value.
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
  800a7a:	68 9f 26 80 00       	push   $0x80269f
  800a7f:	6a 22                	push   $0x22
  800a81:	68 bc 26 80 00       	push   $0x8026bc
  800a86:	e8 5b 14 00 00       	call   801ee6 <_panic>

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
	// return value.
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
	// return value.
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
	// return value.
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
  800afb:	68 9f 26 80 00       	push   $0x80269f
  800b00:	6a 22                	push   $0x22
  800b02:	68 bc 26 80 00       	push   $0x8026bc
  800b07:	e8 da 13 00 00       	call   801ee6 <_panic>

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
	// return value.
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
  800b3d:	68 9f 26 80 00       	push   $0x80269f
  800b42:	6a 22                	push   $0x22
  800b44:	68 bc 26 80 00       	push   $0x8026bc
  800b49:	e8 98 13 00 00       	call   801ee6 <_panic>

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
	// return value.
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
  800b7f:	68 9f 26 80 00       	push   $0x80269f
  800b84:	6a 22                	push   $0x22
  800b86:	68 bc 26 80 00       	push   $0x8026bc
  800b8b:	e8 56 13 00 00       	call   801ee6 <_panic>

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
	// return value.
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
  800bc1:	68 9f 26 80 00       	push   $0x80269f
  800bc6:	6a 22                	push   $0x22
  800bc8:	68 bc 26 80 00       	push   $0x8026bc
  800bcd:	e8 14 13 00 00       	call   801ee6 <_panic>
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
	// return value.
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
  800c03:	68 9f 26 80 00       	push   $0x80269f
  800c08:	6a 22                	push   $0x22
  800c0a:	68 bc 26 80 00       	push   $0x8026bc
  800c0f:	e8 d2 12 00 00       	call   801ee6 <_panic>

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
	// return value.
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
  800c45:	68 9f 26 80 00       	push   $0x80269f
  800c4a:	6a 22                	push   $0x22
  800c4c:	68 bc 26 80 00       	push   $0x8026bc
  800c51:	e8 90 12 00 00       	call   801ee6 <_panic>

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
	// return value.
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
	// return value.
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
  800ca9:	68 9f 26 80 00       	push   $0x80269f
  800cae:	6a 22                	push   $0x22
  800cb0:	68 bc 26 80 00       	push   $0x8026bc
  800cb5:	e8 2c 12 00 00       	call   801ee6 <_panic>

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

00800cc2 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cd2:	89 d1                	mov    %edx,%ecx
  800cd4:	89 d3                	mov    %edx,%ebx
  800cd6:	89 d7                	mov    %edx,%edi
  800cd8:	89 d6                	mov    %edx,%esi
  800cda:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cef:	b8 0f 00 00 00       	mov    $0xf,%eax
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	89 cb                	mov    %ecx,%ebx
  800cf9:	89 cf                	mov    %ecx,%edi
  800cfb:	89 ce                	mov    %ecx,%esi
  800cfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 17                	jle    800d1a <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 0f                	push   $0xf
  800d09:	68 9f 26 80 00       	push   $0x80269f
  800d0e:	6a 22                	push   $0x22
  800d10:	68 bc 26 80 00       	push   $0x8026bc
  800d15:	e8 cc 11 00 00       	call   801ee6 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_recv>:

int
sys_recv(void *addr)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d2b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d30:	b8 10 00 00 00       	mov    $0x10,%eax
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	89 cb                	mov    %ecx,%ebx
  800d3a:	89 cf                	mov    %ecx,%edi
  800d3c:	89 ce                	mov    %ecx,%esi
  800d3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7e 17                	jle    800d5b <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 10                	push   $0x10
  800d4a:	68 9f 26 80 00       	push   $0x80269f
  800d4f:	6a 22                	push   $0x22
  800d51:	68 bc 26 80 00       	push   $0x8026bc
  800d56:	e8 8b 11 00 00       	call   801ee6 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d66:	8b 45 08             	mov    0x8(%ebp),%eax
  800d69:	05 00 00 00 30       	add    $0x30000000,%eax
  800d6e:	c1 e8 0c             	shr    $0xc,%eax
}
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
  800d79:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800d7e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d83:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d90:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d95:	89 c2                	mov    %eax,%edx
  800d97:	c1 ea 16             	shr    $0x16,%edx
  800d9a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da1:	f6 c2 01             	test   $0x1,%dl
  800da4:	74 11                	je     800db7 <fd_alloc+0x2d>
  800da6:	89 c2                	mov    %eax,%edx
  800da8:	c1 ea 0c             	shr    $0xc,%edx
  800dab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db2:	f6 c2 01             	test   $0x1,%dl
  800db5:	75 09                	jne    800dc0 <fd_alloc+0x36>
			*fd_store = fd;
  800db7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800db9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbe:	eb 17                	jmp    800dd7 <fd_alloc+0x4d>
  800dc0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dc5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dca:	75 c9                	jne    800d95 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dcc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dd2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ddf:	83 f8 1f             	cmp    $0x1f,%eax
  800de2:	77 36                	ja     800e1a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800de4:	c1 e0 0c             	shl    $0xc,%eax
  800de7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dec:	89 c2                	mov    %eax,%edx
  800dee:	c1 ea 16             	shr    $0x16,%edx
  800df1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df8:	f6 c2 01             	test   $0x1,%dl
  800dfb:	74 24                	je     800e21 <fd_lookup+0x48>
  800dfd:	89 c2                	mov    %eax,%edx
  800dff:	c1 ea 0c             	shr    $0xc,%edx
  800e02:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e09:	f6 c2 01             	test   $0x1,%dl
  800e0c:	74 1a                	je     800e28 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e11:	89 02                	mov    %eax,(%edx)
	return 0;
  800e13:	b8 00 00 00 00       	mov    $0x0,%eax
  800e18:	eb 13                	jmp    800e2d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e1f:	eb 0c                	jmp    800e2d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e26:	eb 05                	jmp    800e2d <fd_lookup+0x54>
  800e28:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	83 ec 08             	sub    $0x8,%esp
  800e35:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800e38:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3d:	eb 13                	jmp    800e52 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800e3f:	39 08                	cmp    %ecx,(%eax)
  800e41:	75 0c                	jne    800e4f <dev_lookup+0x20>
			*dev = devtab[i];
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e48:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4d:	eb 36                	jmp    800e85 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e4f:	83 c2 01             	add    $0x1,%edx
  800e52:	8b 04 95 48 27 80 00 	mov    0x802748(,%edx,4),%eax
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	75 e2                	jne    800e3f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e5d:	a1 08 40 80 00       	mov    0x804008,%eax
  800e62:	8b 40 48             	mov    0x48(%eax),%eax
  800e65:	83 ec 04             	sub    $0x4,%esp
  800e68:	51                   	push   %ecx
  800e69:	50                   	push   %eax
  800e6a:	68 cc 26 80 00       	push   $0x8026cc
  800e6f:	e8 cd f2 ff ff       	call   800141 <cprintf>
	*dev = 0;
  800e74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e77:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e7d:	83 c4 10             	add    $0x10,%esp
  800e80:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e85:	c9                   	leave  
  800e86:	c3                   	ret    

00800e87 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 10             	sub    $0x10,%esp
  800e8f:	8b 75 08             	mov    0x8(%ebp),%esi
  800e92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e98:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e99:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e9f:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea2:	50                   	push   %eax
  800ea3:	e8 31 ff ff ff       	call   800dd9 <fd_lookup>
  800ea8:	83 c4 08             	add    $0x8,%esp
  800eab:	85 c0                	test   %eax,%eax
  800ead:	78 05                	js     800eb4 <fd_close+0x2d>
	    || fd != fd2)
  800eaf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800eb2:	74 0c                	je     800ec0 <fd_close+0x39>
		return (must_exist ? r : 0);
  800eb4:	84 db                	test   %bl,%bl
  800eb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebb:	0f 44 c2             	cmove  %edx,%eax
  800ebe:	eb 41                	jmp    800f01 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ec0:	83 ec 08             	sub    $0x8,%esp
  800ec3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ec6:	50                   	push   %eax
  800ec7:	ff 36                	pushl  (%esi)
  800ec9:	e8 61 ff ff ff       	call   800e2f <dev_lookup>
  800ece:	89 c3                	mov    %eax,%ebx
  800ed0:	83 c4 10             	add    $0x10,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	78 1a                	js     800ef1 <fd_close+0x6a>
		if (dev->dev_close)
  800ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eda:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800edd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	74 0b                	je     800ef1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ee6:	83 ec 0c             	sub    $0xc,%esp
  800ee9:	56                   	push   %esi
  800eea:	ff d0                	call   *%eax
  800eec:	89 c3                	mov    %eax,%ebx
  800eee:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ef1:	83 ec 08             	sub    $0x8,%esp
  800ef4:	56                   	push   %esi
  800ef5:	6a 00                	push   $0x0
  800ef7:	e8 5a fc ff ff       	call   800b56 <sys_page_unmap>
	return r;
  800efc:	83 c4 10             	add    $0x10,%esp
  800eff:	89 d8                	mov    %ebx,%eax
}
  800f01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f11:	50                   	push   %eax
  800f12:	ff 75 08             	pushl  0x8(%ebp)
  800f15:	e8 bf fe ff ff       	call   800dd9 <fd_lookup>
  800f1a:	89 c2                	mov    %eax,%edx
  800f1c:	83 c4 08             	add    $0x8,%esp
  800f1f:	85 d2                	test   %edx,%edx
  800f21:	78 10                	js     800f33 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800f23:	83 ec 08             	sub    $0x8,%esp
  800f26:	6a 01                	push   $0x1
  800f28:	ff 75 f4             	pushl  -0xc(%ebp)
  800f2b:	e8 57 ff ff ff       	call   800e87 <fd_close>
  800f30:	83 c4 10             	add    $0x10,%esp
}
  800f33:	c9                   	leave  
  800f34:	c3                   	ret    

00800f35 <close_all>:

void
close_all(void)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	53                   	push   %ebx
  800f39:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f3c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f41:	83 ec 0c             	sub    $0xc,%esp
  800f44:	53                   	push   %ebx
  800f45:	e8 be ff ff ff       	call   800f08 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f4a:	83 c3 01             	add    $0x1,%ebx
  800f4d:	83 c4 10             	add    $0x10,%esp
  800f50:	83 fb 20             	cmp    $0x20,%ebx
  800f53:	75 ec                	jne    800f41 <close_all+0xc>
		close(i);
}
  800f55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f58:	c9                   	leave  
  800f59:	c3                   	ret    

00800f5a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 2c             	sub    $0x2c,%esp
  800f63:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f66:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f69:	50                   	push   %eax
  800f6a:	ff 75 08             	pushl  0x8(%ebp)
  800f6d:	e8 67 fe ff ff       	call   800dd9 <fd_lookup>
  800f72:	89 c2                	mov    %eax,%edx
  800f74:	83 c4 08             	add    $0x8,%esp
  800f77:	85 d2                	test   %edx,%edx
  800f79:	0f 88 c1 00 00 00    	js     801040 <dup+0xe6>
		return r;
	close(newfdnum);
  800f7f:	83 ec 0c             	sub    $0xc,%esp
  800f82:	56                   	push   %esi
  800f83:	e8 80 ff ff ff       	call   800f08 <close>

	newfd = INDEX2FD(newfdnum);
  800f88:	89 f3                	mov    %esi,%ebx
  800f8a:	c1 e3 0c             	shl    $0xc,%ebx
  800f8d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f93:	83 c4 04             	add    $0x4,%esp
  800f96:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f99:	e8 d5 fd ff ff       	call   800d73 <fd2data>
  800f9e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fa0:	89 1c 24             	mov    %ebx,(%esp)
  800fa3:	e8 cb fd ff ff       	call   800d73 <fd2data>
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fae:	89 f8                	mov    %edi,%eax
  800fb0:	c1 e8 16             	shr    $0x16,%eax
  800fb3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fba:	a8 01                	test   $0x1,%al
  800fbc:	74 37                	je     800ff5 <dup+0x9b>
  800fbe:	89 f8                	mov    %edi,%eax
  800fc0:	c1 e8 0c             	shr    $0xc,%eax
  800fc3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fca:	f6 c2 01             	test   $0x1,%dl
  800fcd:	74 26                	je     800ff5 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fcf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	25 07 0e 00 00       	and    $0xe07,%eax
  800fde:	50                   	push   %eax
  800fdf:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fe2:	6a 00                	push   $0x0
  800fe4:	57                   	push   %edi
  800fe5:	6a 00                	push   $0x0
  800fe7:	e8 28 fb ff ff       	call   800b14 <sys_page_map>
  800fec:	89 c7                	mov    %eax,%edi
  800fee:	83 c4 20             	add    $0x20,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 2e                	js     801023 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ff5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ff8:	89 d0                	mov    %edx,%eax
  800ffa:	c1 e8 0c             	shr    $0xc,%eax
  800ffd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	25 07 0e 00 00       	and    $0xe07,%eax
  80100c:	50                   	push   %eax
  80100d:	53                   	push   %ebx
  80100e:	6a 00                	push   $0x0
  801010:	52                   	push   %edx
  801011:	6a 00                	push   $0x0
  801013:	e8 fc fa ff ff       	call   800b14 <sys_page_map>
  801018:	89 c7                	mov    %eax,%edi
  80101a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80101d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80101f:	85 ff                	test   %edi,%edi
  801021:	79 1d                	jns    801040 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801023:	83 ec 08             	sub    $0x8,%esp
  801026:	53                   	push   %ebx
  801027:	6a 00                	push   $0x0
  801029:	e8 28 fb ff ff       	call   800b56 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80102e:	83 c4 08             	add    $0x8,%esp
  801031:	ff 75 d4             	pushl  -0x2c(%ebp)
  801034:	6a 00                	push   $0x0
  801036:	e8 1b fb ff ff       	call   800b56 <sys_page_unmap>
	return r;
  80103b:	83 c4 10             	add    $0x10,%esp
  80103e:	89 f8                	mov    %edi,%eax
}
  801040:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801043:	5b                   	pop    %ebx
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	53                   	push   %ebx
  80104c:	83 ec 14             	sub    $0x14,%esp
  80104f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801052:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801055:	50                   	push   %eax
  801056:	53                   	push   %ebx
  801057:	e8 7d fd ff ff       	call   800dd9 <fd_lookup>
  80105c:	83 c4 08             	add    $0x8,%esp
  80105f:	89 c2                	mov    %eax,%edx
  801061:	85 c0                	test   %eax,%eax
  801063:	78 6d                	js     8010d2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106b:	50                   	push   %eax
  80106c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80106f:	ff 30                	pushl  (%eax)
  801071:	e8 b9 fd ff ff       	call   800e2f <dev_lookup>
  801076:	83 c4 10             	add    $0x10,%esp
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 4c                	js     8010c9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80107d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801080:	8b 42 08             	mov    0x8(%edx),%eax
  801083:	83 e0 03             	and    $0x3,%eax
  801086:	83 f8 01             	cmp    $0x1,%eax
  801089:	75 21                	jne    8010ac <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80108b:	a1 08 40 80 00       	mov    0x804008,%eax
  801090:	8b 40 48             	mov    0x48(%eax),%eax
  801093:	83 ec 04             	sub    $0x4,%esp
  801096:	53                   	push   %ebx
  801097:	50                   	push   %eax
  801098:	68 0d 27 80 00       	push   $0x80270d
  80109d:	e8 9f f0 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010aa:	eb 26                	jmp    8010d2 <read+0x8a>
	}
	if (!dev->dev_read)
  8010ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010af:	8b 40 08             	mov    0x8(%eax),%eax
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	74 17                	je     8010cd <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010b6:	83 ec 04             	sub    $0x4,%esp
  8010b9:	ff 75 10             	pushl  0x10(%ebp)
  8010bc:	ff 75 0c             	pushl  0xc(%ebp)
  8010bf:	52                   	push   %edx
  8010c0:	ff d0                	call   *%eax
  8010c2:	89 c2                	mov    %eax,%edx
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	eb 09                	jmp    8010d2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	eb 05                	jmp    8010d2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010d2:	89 d0                	mov    %edx,%eax
  8010d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d7:	c9                   	leave  
  8010d8:	c3                   	ret    

008010d9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	57                   	push   %edi
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
  8010df:	83 ec 0c             	sub    $0xc,%esp
  8010e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ed:	eb 21                	jmp    801110 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010ef:	83 ec 04             	sub    $0x4,%esp
  8010f2:	89 f0                	mov    %esi,%eax
  8010f4:	29 d8                	sub    %ebx,%eax
  8010f6:	50                   	push   %eax
  8010f7:	89 d8                	mov    %ebx,%eax
  8010f9:	03 45 0c             	add    0xc(%ebp),%eax
  8010fc:	50                   	push   %eax
  8010fd:	57                   	push   %edi
  8010fe:	e8 45 ff ff ff       	call   801048 <read>
		if (m < 0)
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	85 c0                	test   %eax,%eax
  801108:	78 0c                	js     801116 <readn+0x3d>
			return m;
		if (m == 0)
  80110a:	85 c0                	test   %eax,%eax
  80110c:	74 06                	je     801114 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80110e:	01 c3                	add    %eax,%ebx
  801110:	39 f3                	cmp    %esi,%ebx
  801112:	72 db                	jb     8010ef <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801114:	89 d8                	mov    %ebx,%eax
}
  801116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    

0080111e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	53                   	push   %ebx
  801122:	83 ec 14             	sub    $0x14,%esp
  801125:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801128:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112b:	50                   	push   %eax
  80112c:	53                   	push   %ebx
  80112d:	e8 a7 fc ff ff       	call   800dd9 <fd_lookup>
  801132:	83 c4 08             	add    $0x8,%esp
  801135:	89 c2                	mov    %eax,%edx
  801137:	85 c0                	test   %eax,%eax
  801139:	78 68                	js     8011a3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113b:	83 ec 08             	sub    $0x8,%esp
  80113e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801141:	50                   	push   %eax
  801142:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801145:	ff 30                	pushl  (%eax)
  801147:	e8 e3 fc ff ff       	call   800e2f <dev_lookup>
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 47                	js     80119a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801153:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801156:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80115a:	75 21                	jne    80117d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80115c:	a1 08 40 80 00       	mov    0x804008,%eax
  801161:	8b 40 48             	mov    0x48(%eax),%eax
  801164:	83 ec 04             	sub    $0x4,%esp
  801167:	53                   	push   %ebx
  801168:	50                   	push   %eax
  801169:	68 29 27 80 00       	push   $0x802729
  80116e:	e8 ce ef ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80117b:	eb 26                	jmp    8011a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80117d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801180:	8b 52 0c             	mov    0xc(%edx),%edx
  801183:	85 d2                	test   %edx,%edx
  801185:	74 17                	je     80119e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801187:	83 ec 04             	sub    $0x4,%esp
  80118a:	ff 75 10             	pushl  0x10(%ebp)
  80118d:	ff 75 0c             	pushl  0xc(%ebp)
  801190:	50                   	push   %eax
  801191:	ff d2                	call   *%edx
  801193:	89 c2                	mov    %eax,%edx
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	eb 09                	jmp    8011a3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119a:	89 c2                	mov    %eax,%edx
  80119c:	eb 05                	jmp    8011a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80119e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011a3:	89 d0                	mov    %edx,%eax
  8011a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a8:	c9                   	leave  
  8011a9:	c3                   	ret    

008011aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011b3:	50                   	push   %eax
  8011b4:	ff 75 08             	pushl  0x8(%ebp)
  8011b7:	e8 1d fc ff ff       	call   800dd9 <fd_lookup>
  8011bc:	83 c4 08             	add    $0x8,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 0e                	js     8011d1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d1:	c9                   	leave  
  8011d2:	c3                   	ret    

008011d3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 14             	sub    $0x14,%esp
  8011da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e0:	50                   	push   %eax
  8011e1:	53                   	push   %ebx
  8011e2:	e8 f2 fb ff ff       	call   800dd9 <fd_lookup>
  8011e7:	83 c4 08             	add    $0x8,%esp
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	78 65                	js     801255 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f0:	83 ec 08             	sub    $0x8,%esp
  8011f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fa:	ff 30                	pushl  (%eax)
  8011fc:	e8 2e fc ff ff       	call   800e2f <dev_lookup>
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	78 44                	js     80124c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801208:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80120f:	75 21                	jne    801232 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801211:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801216:	8b 40 48             	mov    0x48(%eax),%eax
  801219:	83 ec 04             	sub    $0x4,%esp
  80121c:	53                   	push   %ebx
  80121d:	50                   	push   %eax
  80121e:	68 ec 26 80 00       	push   $0x8026ec
  801223:	e8 19 ef ff ff       	call   800141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801230:	eb 23                	jmp    801255 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801232:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801235:	8b 52 18             	mov    0x18(%edx),%edx
  801238:	85 d2                	test   %edx,%edx
  80123a:	74 14                	je     801250 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	ff 75 0c             	pushl  0xc(%ebp)
  801242:	50                   	push   %eax
  801243:	ff d2                	call   *%edx
  801245:	89 c2                	mov    %eax,%edx
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	eb 09                	jmp    801255 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124c:	89 c2                	mov    %eax,%edx
  80124e:	eb 05                	jmp    801255 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801250:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801255:	89 d0                	mov    %edx,%eax
  801257:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125a:	c9                   	leave  
  80125b:	c3                   	ret    

0080125c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	53                   	push   %ebx
  801260:	83 ec 14             	sub    $0x14,%esp
  801263:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801266:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801269:	50                   	push   %eax
  80126a:	ff 75 08             	pushl  0x8(%ebp)
  80126d:	e8 67 fb ff ff       	call   800dd9 <fd_lookup>
  801272:	83 c4 08             	add    $0x8,%esp
  801275:	89 c2                	mov    %eax,%edx
  801277:	85 c0                	test   %eax,%eax
  801279:	78 58                	js     8012d3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801281:	50                   	push   %eax
  801282:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801285:	ff 30                	pushl  (%eax)
  801287:	e8 a3 fb ff ff       	call   800e2f <dev_lookup>
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 37                	js     8012ca <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801293:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801296:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80129a:	74 32                	je     8012ce <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80129c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80129f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012a6:	00 00 00 
	stat->st_isdir = 0;
  8012a9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012b0:	00 00 00 
	stat->st_dev = dev;
  8012b3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012b9:	83 ec 08             	sub    $0x8,%esp
  8012bc:	53                   	push   %ebx
  8012bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c0:	ff 50 14             	call   *0x14(%eax)
  8012c3:	89 c2                	mov    %eax,%edx
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	eb 09                	jmp    8012d3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ca:	89 c2                	mov    %eax,%edx
  8012cc:	eb 05                	jmp    8012d3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012d3:	89 d0                	mov    %edx,%eax
  8012d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d8:	c9                   	leave  
  8012d9:	c3                   	ret    

008012da <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	56                   	push   %esi
  8012de:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012df:	83 ec 08             	sub    $0x8,%esp
  8012e2:	6a 00                	push   $0x0
  8012e4:	ff 75 08             	pushl  0x8(%ebp)
  8012e7:	e8 09 02 00 00       	call   8014f5 <open>
  8012ec:	89 c3                	mov    %eax,%ebx
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	85 db                	test   %ebx,%ebx
  8012f3:	78 1b                	js     801310 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012f5:	83 ec 08             	sub    $0x8,%esp
  8012f8:	ff 75 0c             	pushl  0xc(%ebp)
  8012fb:	53                   	push   %ebx
  8012fc:	e8 5b ff ff ff       	call   80125c <fstat>
  801301:	89 c6                	mov    %eax,%esi
	close(fd);
  801303:	89 1c 24             	mov    %ebx,(%esp)
  801306:	e8 fd fb ff ff       	call   800f08 <close>
	return r;
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	89 f0                	mov    %esi,%eax
}
  801310:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5d                   	pop    %ebp
  801316:	c3                   	ret    

00801317 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	56                   	push   %esi
  80131b:	53                   	push   %ebx
  80131c:	89 c6                	mov    %eax,%esi
  80131e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801320:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801327:	75 12                	jne    80133b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801329:	83 ec 0c             	sub    $0xc,%esp
  80132c:	6a 01                	push   $0x1
  80132e:	e8 b6 0c 00 00       	call   801fe9 <ipc_find_env>
  801333:	a3 00 40 80 00       	mov    %eax,0x804000
  801338:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80133b:	6a 07                	push   $0x7
  80133d:	68 00 50 80 00       	push   $0x805000
  801342:	56                   	push   %esi
  801343:	ff 35 00 40 80 00    	pushl  0x804000
  801349:	e8 47 0c 00 00       	call   801f95 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80134e:	83 c4 0c             	add    $0xc,%esp
  801351:	6a 00                	push   $0x0
  801353:	53                   	push   %ebx
  801354:	6a 00                	push   $0x0
  801356:	e8 d1 0b 00 00       	call   801f2c <ipc_recv>
}
  80135b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135e:	5b                   	pop    %ebx
  80135f:	5e                   	pop    %esi
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801368:	8b 45 08             	mov    0x8(%ebp),%eax
  80136b:	8b 40 0c             	mov    0xc(%eax),%eax
  80136e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801373:	8b 45 0c             	mov    0xc(%ebp),%eax
  801376:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80137b:	ba 00 00 00 00       	mov    $0x0,%edx
  801380:	b8 02 00 00 00       	mov    $0x2,%eax
  801385:	e8 8d ff ff ff       	call   801317 <fsipc>
}
  80138a:	c9                   	leave  
  80138b:	c3                   	ret    

0080138c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801392:	8b 45 08             	mov    0x8(%ebp),%eax
  801395:	8b 40 0c             	mov    0xc(%eax),%eax
  801398:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80139d:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a2:	b8 06 00 00 00       	mov    $0x6,%eax
  8013a7:	e8 6b ff ff ff       	call   801317 <fsipc>
}
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    

008013ae <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	53                   	push   %ebx
  8013b2:	83 ec 04             	sub    $0x4,%esp
  8013b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8013be:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8013cd:	e8 45 ff ff ff       	call   801317 <fsipc>
  8013d2:	89 c2                	mov    %eax,%edx
  8013d4:	85 d2                	test   %edx,%edx
  8013d6:	78 2c                	js     801404 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013d8:	83 ec 08             	sub    $0x8,%esp
  8013db:	68 00 50 80 00       	push   $0x805000
  8013e0:	53                   	push   %ebx
  8013e1:	e8 e2 f2 ff ff       	call   8006c8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013e6:	a1 80 50 80 00       	mov    0x805080,%eax
  8013eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013f1:	a1 84 50 80 00       	mov    0x805084,%eax
  8013f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801404:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801407:	c9                   	leave  
  801408:	c3                   	ret    

00801409 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	57                   	push   %edi
  80140d:	56                   	push   %esi
  80140e:	53                   	push   %ebx
  80140f:	83 ec 0c             	sub    $0xc,%esp
  801412:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801415:	8b 45 08             	mov    0x8(%ebp),%eax
  801418:	8b 40 0c             	mov    0xc(%eax),%eax
  80141b:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801420:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801423:	eb 3d                	jmp    801462 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801425:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80142b:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801430:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801433:	83 ec 04             	sub    $0x4,%esp
  801436:	57                   	push   %edi
  801437:	53                   	push   %ebx
  801438:	68 08 50 80 00       	push   $0x805008
  80143d:	e8 18 f4 ff ff       	call   80085a <memmove>
                fsipcbuf.write.req_n = tmp; 
  801442:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801448:	ba 00 00 00 00       	mov    $0x0,%edx
  80144d:	b8 04 00 00 00       	mov    $0x4,%eax
  801452:	e8 c0 fe ff ff       	call   801317 <fsipc>
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 0d                	js     80146b <devfile_write+0x62>
		        return r;
                n -= tmp;
  80145e:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801460:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801462:	85 f6                	test   %esi,%esi
  801464:	75 bf                	jne    801425 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801466:	89 d8                	mov    %ebx,%eax
  801468:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80146b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146e:	5b                   	pop    %ebx
  80146f:	5e                   	pop    %esi
  801470:	5f                   	pop    %edi
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	56                   	push   %esi
  801477:	53                   	push   %ebx
  801478:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80147b:	8b 45 08             	mov    0x8(%ebp),%eax
  80147e:	8b 40 0c             	mov    0xc(%eax),%eax
  801481:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801486:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80148c:	ba 00 00 00 00       	mov    $0x0,%edx
  801491:	b8 03 00 00 00       	mov    $0x3,%eax
  801496:	e8 7c fe ff ff       	call   801317 <fsipc>
  80149b:	89 c3                	mov    %eax,%ebx
  80149d:	85 c0                	test   %eax,%eax
  80149f:	78 4b                	js     8014ec <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014a1:	39 c6                	cmp    %eax,%esi
  8014a3:	73 16                	jae    8014bb <devfile_read+0x48>
  8014a5:	68 5c 27 80 00       	push   $0x80275c
  8014aa:	68 63 27 80 00       	push   $0x802763
  8014af:	6a 7c                	push   $0x7c
  8014b1:	68 78 27 80 00       	push   $0x802778
  8014b6:	e8 2b 0a 00 00       	call   801ee6 <_panic>
	assert(r <= PGSIZE);
  8014bb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014c0:	7e 16                	jle    8014d8 <devfile_read+0x65>
  8014c2:	68 83 27 80 00       	push   $0x802783
  8014c7:	68 63 27 80 00       	push   $0x802763
  8014cc:	6a 7d                	push   $0x7d
  8014ce:	68 78 27 80 00       	push   $0x802778
  8014d3:	e8 0e 0a 00 00       	call   801ee6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014d8:	83 ec 04             	sub    $0x4,%esp
  8014db:	50                   	push   %eax
  8014dc:	68 00 50 80 00       	push   $0x805000
  8014e1:	ff 75 0c             	pushl  0xc(%ebp)
  8014e4:	e8 71 f3 ff ff       	call   80085a <memmove>
	return r;
  8014e9:	83 c4 10             	add    $0x10,%esp
}
  8014ec:	89 d8                	mov    %ebx,%eax
  8014ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f1:	5b                   	pop    %ebx
  8014f2:	5e                   	pop    %esi
  8014f3:	5d                   	pop    %ebp
  8014f4:	c3                   	ret    

008014f5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	53                   	push   %ebx
  8014f9:	83 ec 20             	sub    $0x20,%esp
  8014fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014ff:	53                   	push   %ebx
  801500:	e8 8a f1 ff ff       	call   80068f <strlen>
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80150d:	7f 67                	jg     801576 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80150f:	83 ec 0c             	sub    $0xc,%esp
  801512:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801515:	50                   	push   %eax
  801516:	e8 6f f8 ff ff       	call   800d8a <fd_alloc>
  80151b:	83 c4 10             	add    $0x10,%esp
		return r;
  80151e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801520:	85 c0                	test   %eax,%eax
  801522:	78 57                	js     80157b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	53                   	push   %ebx
  801528:	68 00 50 80 00       	push   $0x805000
  80152d:	e8 96 f1 ff ff       	call   8006c8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801532:	8b 45 0c             	mov    0xc(%ebp),%eax
  801535:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80153a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80153d:	b8 01 00 00 00       	mov    $0x1,%eax
  801542:	e8 d0 fd ff ff       	call   801317 <fsipc>
  801547:	89 c3                	mov    %eax,%ebx
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	85 c0                	test   %eax,%eax
  80154e:	79 14                	jns    801564 <open+0x6f>
		fd_close(fd, 0);
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	6a 00                	push   $0x0
  801555:	ff 75 f4             	pushl  -0xc(%ebp)
  801558:	e8 2a f9 ff ff       	call   800e87 <fd_close>
		return r;
  80155d:	83 c4 10             	add    $0x10,%esp
  801560:	89 da                	mov    %ebx,%edx
  801562:	eb 17                	jmp    80157b <open+0x86>
	}

	return fd2num(fd);
  801564:	83 ec 0c             	sub    $0xc,%esp
  801567:	ff 75 f4             	pushl  -0xc(%ebp)
  80156a:	e8 f4 f7 ff ff       	call   800d63 <fd2num>
  80156f:	89 c2                	mov    %eax,%edx
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	eb 05                	jmp    80157b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801576:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80157b:	89 d0                	mov    %edx,%eax
  80157d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801588:	ba 00 00 00 00       	mov    $0x0,%edx
  80158d:	b8 08 00 00 00       	mov    $0x8,%eax
  801592:	e8 80 fd ff ff       	call   801317 <fsipc>
}
  801597:	c9                   	leave  
  801598:	c3                   	ret    

00801599 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80159f:	68 8f 27 80 00       	push   $0x80278f
  8015a4:	ff 75 0c             	pushl  0xc(%ebp)
  8015a7:	e8 1c f1 ff ff       	call   8006c8 <strcpy>
	return 0;
}
  8015ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b1:	c9                   	leave  
  8015b2:	c3                   	ret    

008015b3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 10             	sub    $0x10,%esp
  8015ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015bd:	53                   	push   %ebx
  8015be:	e8 5e 0a 00 00       	call   802021 <pageref>
  8015c3:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015c6:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8015cb:	83 f8 01             	cmp    $0x1,%eax
  8015ce:	75 10                	jne    8015e0 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015d0:	83 ec 0c             	sub    $0xc,%esp
  8015d3:	ff 73 0c             	pushl  0xc(%ebx)
  8015d6:	e8 ca 02 00 00       	call   8018a5 <nsipc_close>
  8015db:	89 c2                	mov    %eax,%edx
  8015dd:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015e0:	89 d0                	mov    %edx,%eax
  8015e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e5:	c9                   	leave  
  8015e6:	c3                   	ret    

008015e7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015ed:	6a 00                	push   $0x0
  8015ef:	ff 75 10             	pushl  0x10(%ebp)
  8015f2:	ff 75 0c             	pushl  0xc(%ebp)
  8015f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f8:	ff 70 0c             	pushl  0xc(%eax)
  8015fb:	e8 82 03 00 00       	call   801982 <nsipc_send>
}
  801600:	c9                   	leave  
  801601:	c3                   	ret    

00801602 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801608:	6a 00                	push   $0x0
  80160a:	ff 75 10             	pushl  0x10(%ebp)
  80160d:	ff 75 0c             	pushl  0xc(%ebp)
  801610:	8b 45 08             	mov    0x8(%ebp),%eax
  801613:	ff 70 0c             	pushl  0xc(%eax)
  801616:	e8 fb 02 00 00       	call   801916 <nsipc_recv>
}
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801623:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801626:	52                   	push   %edx
  801627:	50                   	push   %eax
  801628:	e8 ac f7 ff ff       	call   800dd9 <fd_lookup>
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	85 c0                	test   %eax,%eax
  801632:	78 17                	js     80164b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801634:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801637:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80163d:	39 08                	cmp    %ecx,(%eax)
  80163f:	75 05                	jne    801646 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801641:	8b 40 0c             	mov    0xc(%eax),%eax
  801644:	eb 05                	jmp    80164b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801646:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    

0080164d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	56                   	push   %esi
  801651:	53                   	push   %ebx
  801652:	83 ec 1c             	sub    $0x1c,%esp
  801655:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165a:	50                   	push   %eax
  80165b:	e8 2a f7 ff ff       	call   800d8a <fd_alloc>
  801660:	89 c3                	mov    %eax,%ebx
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	85 c0                	test   %eax,%eax
  801667:	78 1b                	js     801684 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801669:	83 ec 04             	sub    $0x4,%esp
  80166c:	68 07 04 00 00       	push   $0x407
  801671:	ff 75 f4             	pushl  -0xc(%ebp)
  801674:	6a 00                	push   $0x0
  801676:	e8 56 f4 ff ff       	call   800ad1 <sys_page_alloc>
  80167b:	89 c3                	mov    %eax,%ebx
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	85 c0                	test   %eax,%eax
  801682:	79 10                	jns    801694 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801684:	83 ec 0c             	sub    $0xc,%esp
  801687:	56                   	push   %esi
  801688:	e8 18 02 00 00       	call   8018a5 <nsipc_close>
		return r;
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	89 d8                	mov    %ebx,%eax
  801692:	eb 24                	jmp    8016b8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801694:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80169a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80169f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a2:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8016a9:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8016ac:	83 ec 0c             	sub    $0xc,%esp
  8016af:	52                   	push   %edx
  8016b0:	e8 ae f6 ff ff       	call   800d63 <fd2num>
  8016b5:	83 c4 10             	add    $0x10,%esp
}
  8016b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    

008016bf <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c8:	e8 50 ff ff ff       	call   80161d <fd2sockid>
		return r;
  8016cd:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	78 1f                	js     8016f2 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016d3:	83 ec 04             	sub    $0x4,%esp
  8016d6:	ff 75 10             	pushl  0x10(%ebp)
  8016d9:	ff 75 0c             	pushl  0xc(%ebp)
  8016dc:	50                   	push   %eax
  8016dd:	e8 1c 01 00 00       	call   8017fe <nsipc_accept>
  8016e2:	83 c4 10             	add    $0x10,%esp
		return r;
  8016e5:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 07                	js     8016f2 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016eb:	e8 5d ff ff ff       	call   80164d <alloc_sockfd>
  8016f0:	89 c1                	mov    %eax,%ecx
}
  8016f2:	89 c8                	mov    %ecx,%eax
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ff:	e8 19 ff ff ff       	call   80161d <fd2sockid>
  801704:	89 c2                	mov    %eax,%edx
  801706:	85 d2                	test   %edx,%edx
  801708:	78 12                	js     80171c <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  80170a:	83 ec 04             	sub    $0x4,%esp
  80170d:	ff 75 10             	pushl  0x10(%ebp)
  801710:	ff 75 0c             	pushl  0xc(%ebp)
  801713:	52                   	push   %edx
  801714:	e8 35 01 00 00       	call   80184e <nsipc_bind>
  801719:	83 c4 10             	add    $0x10,%esp
}
  80171c:	c9                   	leave  
  80171d:	c3                   	ret    

0080171e <shutdown>:

int
shutdown(int s, int how)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801724:	8b 45 08             	mov    0x8(%ebp),%eax
  801727:	e8 f1 fe ff ff       	call   80161d <fd2sockid>
  80172c:	89 c2                	mov    %eax,%edx
  80172e:	85 d2                	test   %edx,%edx
  801730:	78 0f                	js     801741 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	ff 75 0c             	pushl  0xc(%ebp)
  801738:	52                   	push   %edx
  801739:	e8 45 01 00 00       	call   801883 <nsipc_shutdown>
  80173e:	83 c4 10             	add    $0x10,%esp
}
  801741:	c9                   	leave  
  801742:	c3                   	ret    

00801743 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801749:	8b 45 08             	mov    0x8(%ebp),%eax
  80174c:	e8 cc fe ff ff       	call   80161d <fd2sockid>
  801751:	89 c2                	mov    %eax,%edx
  801753:	85 d2                	test   %edx,%edx
  801755:	78 12                	js     801769 <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801757:	83 ec 04             	sub    $0x4,%esp
  80175a:	ff 75 10             	pushl  0x10(%ebp)
  80175d:	ff 75 0c             	pushl  0xc(%ebp)
  801760:	52                   	push   %edx
  801761:	e8 59 01 00 00       	call   8018bf <nsipc_connect>
  801766:	83 c4 10             	add    $0x10,%esp
}
  801769:	c9                   	leave  
  80176a:	c3                   	ret    

0080176b <listen>:

int
listen(int s, int backlog)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801771:	8b 45 08             	mov    0x8(%ebp),%eax
  801774:	e8 a4 fe ff ff       	call   80161d <fd2sockid>
  801779:	89 c2                	mov    %eax,%edx
  80177b:	85 d2                	test   %edx,%edx
  80177d:	78 0f                	js     80178e <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  80177f:	83 ec 08             	sub    $0x8,%esp
  801782:	ff 75 0c             	pushl  0xc(%ebp)
  801785:	52                   	push   %edx
  801786:	e8 69 01 00 00       	call   8018f4 <nsipc_listen>
  80178b:	83 c4 10             	add    $0x10,%esp
}
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801796:	ff 75 10             	pushl  0x10(%ebp)
  801799:	ff 75 0c             	pushl  0xc(%ebp)
  80179c:	ff 75 08             	pushl  0x8(%ebp)
  80179f:	e8 3c 02 00 00       	call   8019e0 <nsipc_socket>
  8017a4:	89 c2                	mov    %eax,%edx
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	85 d2                	test   %edx,%edx
  8017ab:	78 05                	js     8017b2 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  8017ad:	e8 9b fe ff ff       	call   80164d <alloc_sockfd>
}
  8017b2:	c9                   	leave  
  8017b3:	c3                   	ret    

008017b4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	53                   	push   %ebx
  8017b8:	83 ec 04             	sub    $0x4,%esp
  8017bb:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017bd:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017c4:	75 12                	jne    8017d8 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017c6:	83 ec 0c             	sub    $0xc,%esp
  8017c9:	6a 02                	push   $0x2
  8017cb:	e8 19 08 00 00       	call   801fe9 <ipc_find_env>
  8017d0:	a3 04 40 80 00       	mov    %eax,0x804004
  8017d5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017d8:	6a 07                	push   $0x7
  8017da:	68 00 60 80 00       	push   $0x806000
  8017df:	53                   	push   %ebx
  8017e0:	ff 35 04 40 80 00    	pushl  0x804004
  8017e6:	e8 aa 07 00 00       	call   801f95 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017eb:	83 c4 0c             	add    $0xc,%esp
  8017ee:	6a 00                	push   $0x0
  8017f0:	6a 00                	push   $0x0
  8017f2:	6a 00                	push   $0x0
  8017f4:	e8 33 07 00 00       	call   801f2c <ipc_recv>
}
  8017f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	56                   	push   %esi
  801802:	53                   	push   %ebx
  801803:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801806:	8b 45 08             	mov    0x8(%ebp),%eax
  801809:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80180e:	8b 06                	mov    (%esi),%eax
  801810:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801815:	b8 01 00 00 00       	mov    $0x1,%eax
  80181a:	e8 95 ff ff ff       	call   8017b4 <nsipc>
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	85 c0                	test   %eax,%eax
  801823:	78 20                	js     801845 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801825:	83 ec 04             	sub    $0x4,%esp
  801828:	ff 35 10 60 80 00    	pushl  0x806010
  80182e:	68 00 60 80 00       	push   $0x806000
  801833:	ff 75 0c             	pushl  0xc(%ebp)
  801836:	e8 1f f0 ff ff       	call   80085a <memmove>
		*addrlen = ret->ret_addrlen;
  80183b:	a1 10 60 80 00       	mov    0x806010,%eax
  801840:	89 06                	mov    %eax,(%esi)
  801842:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801845:	89 d8                	mov    %ebx,%eax
  801847:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184a:	5b                   	pop    %ebx
  80184b:	5e                   	pop    %esi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	53                   	push   %ebx
  801852:	83 ec 08             	sub    $0x8,%esp
  801855:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801860:	53                   	push   %ebx
  801861:	ff 75 0c             	pushl  0xc(%ebp)
  801864:	68 04 60 80 00       	push   $0x806004
  801869:	e8 ec ef ff ff       	call   80085a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80186e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801874:	b8 02 00 00 00       	mov    $0x2,%eax
  801879:	e8 36 ff ff ff       	call   8017b4 <nsipc>
}
  80187e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801891:	8b 45 0c             	mov    0xc(%ebp),%eax
  801894:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801899:	b8 03 00 00 00       	mov    $0x3,%eax
  80189e:	e8 11 ff ff ff       	call   8017b4 <nsipc>
}
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <nsipc_close>:

int
nsipc_close(int s)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b8:	e8 f7 fe ff ff       	call   8017b4 <nsipc>
}
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 08             	sub    $0x8,%esp
  8018c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018d1:	53                   	push   %ebx
  8018d2:	ff 75 0c             	pushl  0xc(%ebp)
  8018d5:	68 04 60 80 00       	push   $0x806004
  8018da:	e8 7b ef ff ff       	call   80085a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018df:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ea:	e8 c5 fe ff ff       	call   8017b4 <nsipc>
}
  8018ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801902:	8b 45 0c             	mov    0xc(%ebp),%eax
  801905:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80190a:	b8 06 00 00 00       	mov    $0x6,%eax
  80190f:	e8 a0 fe ff ff       	call   8017b4 <nsipc>
}
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	56                   	push   %esi
  80191a:	53                   	push   %ebx
  80191b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80191e:	8b 45 08             	mov    0x8(%ebp),%eax
  801921:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801926:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80192c:	8b 45 14             	mov    0x14(%ebp),%eax
  80192f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801934:	b8 07 00 00 00       	mov    $0x7,%eax
  801939:	e8 76 fe ff ff       	call   8017b4 <nsipc>
  80193e:	89 c3                	mov    %eax,%ebx
  801940:	85 c0                	test   %eax,%eax
  801942:	78 35                	js     801979 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801944:	39 f0                	cmp    %esi,%eax
  801946:	7f 07                	jg     80194f <nsipc_recv+0x39>
  801948:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80194d:	7e 16                	jle    801965 <nsipc_recv+0x4f>
  80194f:	68 9b 27 80 00       	push   $0x80279b
  801954:	68 63 27 80 00       	push   $0x802763
  801959:	6a 62                	push   $0x62
  80195b:	68 b0 27 80 00       	push   $0x8027b0
  801960:	e8 81 05 00 00       	call   801ee6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801965:	83 ec 04             	sub    $0x4,%esp
  801968:	50                   	push   %eax
  801969:	68 00 60 80 00       	push   $0x806000
  80196e:	ff 75 0c             	pushl  0xc(%ebp)
  801971:	e8 e4 ee ff ff       	call   80085a <memmove>
  801976:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801979:	89 d8                	mov    %ebx,%eax
  80197b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197e:	5b                   	pop    %ebx
  80197f:	5e                   	pop    %esi
  801980:	5d                   	pop    %ebp
  801981:	c3                   	ret    

00801982 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	53                   	push   %ebx
  801986:	83 ec 04             	sub    $0x4,%esp
  801989:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80198c:	8b 45 08             	mov    0x8(%ebp),%eax
  80198f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801994:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80199a:	7e 16                	jle    8019b2 <nsipc_send+0x30>
  80199c:	68 bc 27 80 00       	push   $0x8027bc
  8019a1:	68 63 27 80 00       	push   $0x802763
  8019a6:	6a 6d                	push   $0x6d
  8019a8:	68 b0 27 80 00       	push   $0x8027b0
  8019ad:	e8 34 05 00 00       	call   801ee6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019b2:	83 ec 04             	sub    $0x4,%esp
  8019b5:	53                   	push   %ebx
  8019b6:	ff 75 0c             	pushl  0xc(%ebp)
  8019b9:	68 0c 60 80 00       	push   $0x80600c
  8019be:	e8 97 ee ff ff       	call   80085a <memmove>
	nsipcbuf.send.req_size = size;
  8019c3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019cc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019d1:	b8 08 00 00 00       	mov    $0x8,%eax
  8019d6:	e8 d9 fd ff ff       	call   8017b4 <nsipc>
}
  8019db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8019f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8019fe:	b8 09 00 00 00       	mov    $0x9,%eax
  801a03:	e8 ac fd ff ff       	call   8017b4 <nsipc>
}
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	56                   	push   %esi
  801a0e:	53                   	push   %ebx
  801a0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a12:	83 ec 0c             	sub    $0xc,%esp
  801a15:	ff 75 08             	pushl  0x8(%ebp)
  801a18:	e8 56 f3 ff ff       	call   800d73 <fd2data>
  801a1d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a1f:	83 c4 08             	add    $0x8,%esp
  801a22:	68 c8 27 80 00       	push   $0x8027c8
  801a27:	53                   	push   %ebx
  801a28:	e8 9b ec ff ff       	call   8006c8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a2d:	8b 56 04             	mov    0x4(%esi),%edx
  801a30:	89 d0                	mov    %edx,%eax
  801a32:	2b 06                	sub    (%esi),%eax
  801a34:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a3a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a41:	00 00 00 
	stat->st_dev = &devpipe;
  801a44:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a4b:	30 80 00 
	return 0;
}
  801a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a56:	5b                   	pop    %ebx
  801a57:	5e                   	pop    %esi
  801a58:	5d                   	pop    %ebp
  801a59:	c3                   	ret    

00801a5a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 0c             	sub    $0xc,%esp
  801a61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a64:	53                   	push   %ebx
  801a65:	6a 00                	push   $0x0
  801a67:	e8 ea f0 ff ff       	call   800b56 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a6c:	89 1c 24             	mov    %ebx,(%esp)
  801a6f:	e8 ff f2 ff ff       	call   800d73 <fd2data>
  801a74:	83 c4 08             	add    $0x8,%esp
  801a77:	50                   	push   %eax
  801a78:	6a 00                	push   $0x0
  801a7a:	e8 d7 f0 ff ff       	call   800b56 <sys_page_unmap>
}
  801a7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	57                   	push   %edi
  801a88:	56                   	push   %esi
  801a89:	53                   	push   %ebx
  801a8a:	83 ec 1c             	sub    $0x1c,%esp
  801a8d:	89 c6                	mov    %eax,%esi
  801a8f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a92:	a1 08 40 80 00       	mov    0x804008,%eax
  801a97:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	56                   	push   %esi
  801a9e:	e8 7e 05 00 00       	call   802021 <pageref>
  801aa3:	89 c7                	mov    %eax,%edi
  801aa5:	83 c4 04             	add    $0x4,%esp
  801aa8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aab:	e8 71 05 00 00       	call   802021 <pageref>
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	39 c7                	cmp    %eax,%edi
  801ab5:	0f 94 c2             	sete   %dl
  801ab8:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801abb:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801ac1:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801ac4:	39 fb                	cmp    %edi,%ebx
  801ac6:	74 19                	je     801ae1 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801ac8:	84 d2                	test   %dl,%dl
  801aca:	74 c6                	je     801a92 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801acc:	8b 51 58             	mov    0x58(%ecx),%edx
  801acf:	50                   	push   %eax
  801ad0:	52                   	push   %edx
  801ad1:	53                   	push   %ebx
  801ad2:	68 cf 27 80 00       	push   $0x8027cf
  801ad7:	e8 65 e6 ff ff       	call   800141 <cprintf>
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	eb b1                	jmp    801a92 <_pipeisclosed+0xe>
	}
}
  801ae1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae4:	5b                   	pop    %ebx
  801ae5:	5e                   	pop    %esi
  801ae6:	5f                   	pop    %edi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	57                   	push   %edi
  801aed:	56                   	push   %esi
  801aee:	53                   	push   %ebx
  801aef:	83 ec 28             	sub    $0x28,%esp
  801af2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801af5:	56                   	push   %esi
  801af6:	e8 78 f2 ff ff       	call   800d73 <fd2data>
  801afb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	bf 00 00 00 00       	mov    $0x0,%edi
  801b05:	eb 4b                	jmp    801b52 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b07:	89 da                	mov    %ebx,%edx
  801b09:	89 f0                	mov    %esi,%eax
  801b0b:	e8 74 ff ff ff       	call   801a84 <_pipeisclosed>
  801b10:	85 c0                	test   %eax,%eax
  801b12:	75 48                	jne    801b5c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b14:	e8 99 ef ff ff       	call   800ab2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b19:	8b 43 04             	mov    0x4(%ebx),%eax
  801b1c:	8b 0b                	mov    (%ebx),%ecx
  801b1e:	8d 51 20             	lea    0x20(%ecx),%edx
  801b21:	39 d0                	cmp    %edx,%eax
  801b23:	73 e2                	jae    801b07 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b28:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b2c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b2f:	89 c2                	mov    %eax,%edx
  801b31:	c1 fa 1f             	sar    $0x1f,%edx
  801b34:	89 d1                	mov    %edx,%ecx
  801b36:	c1 e9 1b             	shr    $0x1b,%ecx
  801b39:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b3c:	83 e2 1f             	and    $0x1f,%edx
  801b3f:	29 ca                	sub    %ecx,%edx
  801b41:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b45:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b49:	83 c0 01             	add    $0x1,%eax
  801b4c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4f:	83 c7 01             	add    $0x1,%edi
  801b52:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b55:	75 c2                	jne    801b19 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b57:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5a:	eb 05                	jmp    801b61 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b5c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b64:	5b                   	pop    %ebx
  801b65:	5e                   	pop    %esi
  801b66:	5f                   	pop    %edi
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	57                   	push   %edi
  801b6d:	56                   	push   %esi
  801b6e:	53                   	push   %ebx
  801b6f:	83 ec 18             	sub    $0x18,%esp
  801b72:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b75:	57                   	push   %edi
  801b76:	e8 f8 f1 ff ff       	call   800d73 <fd2data>
  801b7b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b85:	eb 3d                	jmp    801bc4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b87:	85 db                	test   %ebx,%ebx
  801b89:	74 04                	je     801b8f <devpipe_read+0x26>
				return i;
  801b8b:	89 d8                	mov    %ebx,%eax
  801b8d:	eb 44                	jmp    801bd3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b8f:	89 f2                	mov    %esi,%edx
  801b91:	89 f8                	mov    %edi,%eax
  801b93:	e8 ec fe ff ff       	call   801a84 <_pipeisclosed>
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	75 32                	jne    801bce <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b9c:	e8 11 ef ff ff       	call   800ab2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ba1:	8b 06                	mov    (%esi),%eax
  801ba3:	3b 46 04             	cmp    0x4(%esi),%eax
  801ba6:	74 df                	je     801b87 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ba8:	99                   	cltd   
  801ba9:	c1 ea 1b             	shr    $0x1b,%edx
  801bac:	01 d0                	add    %edx,%eax
  801bae:	83 e0 1f             	and    $0x1f,%eax
  801bb1:	29 d0                	sub    %edx,%eax
  801bb3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bbe:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc1:	83 c3 01             	add    $0x1,%ebx
  801bc4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bc7:	75 d8                	jne    801ba1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bc9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bcc:	eb 05                	jmp    801bd3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bce:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd6:	5b                   	pop    %ebx
  801bd7:	5e                   	pop    %esi
  801bd8:	5f                   	pop    %edi
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	56                   	push   %esi
  801bdf:	53                   	push   %ebx
  801be0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801be3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be6:	50                   	push   %eax
  801be7:	e8 9e f1 ff ff       	call   800d8a <fd_alloc>
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	89 c2                	mov    %eax,%edx
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	0f 88 2c 01 00 00    	js     801d25 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf9:	83 ec 04             	sub    $0x4,%esp
  801bfc:	68 07 04 00 00       	push   $0x407
  801c01:	ff 75 f4             	pushl  -0xc(%ebp)
  801c04:	6a 00                	push   $0x0
  801c06:	e8 c6 ee ff ff       	call   800ad1 <sys_page_alloc>
  801c0b:	83 c4 10             	add    $0x10,%esp
  801c0e:	89 c2                	mov    %eax,%edx
  801c10:	85 c0                	test   %eax,%eax
  801c12:	0f 88 0d 01 00 00    	js     801d25 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c18:	83 ec 0c             	sub    $0xc,%esp
  801c1b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c1e:	50                   	push   %eax
  801c1f:	e8 66 f1 ff ff       	call   800d8a <fd_alloc>
  801c24:	89 c3                	mov    %eax,%ebx
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	0f 88 e2 00 00 00    	js     801d13 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c31:	83 ec 04             	sub    $0x4,%esp
  801c34:	68 07 04 00 00       	push   $0x407
  801c39:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3c:	6a 00                	push   $0x0
  801c3e:	e8 8e ee ff ff       	call   800ad1 <sys_page_alloc>
  801c43:	89 c3                	mov    %eax,%ebx
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	0f 88 c3 00 00 00    	js     801d13 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c50:	83 ec 0c             	sub    $0xc,%esp
  801c53:	ff 75 f4             	pushl  -0xc(%ebp)
  801c56:	e8 18 f1 ff ff       	call   800d73 <fd2data>
  801c5b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5d:	83 c4 0c             	add    $0xc,%esp
  801c60:	68 07 04 00 00       	push   $0x407
  801c65:	50                   	push   %eax
  801c66:	6a 00                	push   $0x0
  801c68:	e8 64 ee ff ff       	call   800ad1 <sys_page_alloc>
  801c6d:	89 c3                	mov    %eax,%ebx
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	85 c0                	test   %eax,%eax
  801c74:	0f 88 89 00 00 00    	js     801d03 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7a:	83 ec 0c             	sub    $0xc,%esp
  801c7d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c80:	e8 ee f0 ff ff       	call   800d73 <fd2data>
  801c85:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c8c:	50                   	push   %eax
  801c8d:	6a 00                	push   $0x0
  801c8f:	56                   	push   %esi
  801c90:	6a 00                	push   $0x0
  801c92:	e8 7d ee ff ff       	call   800b14 <sys_page_map>
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	83 c4 20             	add    $0x20,%esp
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	78 55                	js     801cf5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ca0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cae:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cb5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbe:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cca:	83 ec 0c             	sub    $0xc,%esp
  801ccd:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd0:	e8 8e f0 ff ff       	call   800d63 <fd2num>
  801cd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cda:	83 c4 04             	add    $0x4,%esp
  801cdd:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce0:	e8 7e f0 ff ff       	call   800d63 <fd2num>
  801ce5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf3:	eb 30                	jmp    801d25 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cf5:	83 ec 08             	sub    $0x8,%esp
  801cf8:	56                   	push   %esi
  801cf9:	6a 00                	push   $0x0
  801cfb:	e8 56 ee ff ff       	call   800b56 <sys_page_unmap>
  801d00:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d03:	83 ec 08             	sub    $0x8,%esp
  801d06:	ff 75 f0             	pushl  -0x10(%ebp)
  801d09:	6a 00                	push   $0x0
  801d0b:	e8 46 ee ff ff       	call   800b56 <sys_page_unmap>
  801d10:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d13:	83 ec 08             	sub    $0x8,%esp
  801d16:	ff 75 f4             	pushl  -0xc(%ebp)
  801d19:	6a 00                	push   $0x0
  801d1b:	e8 36 ee ff ff       	call   800b56 <sys_page_unmap>
  801d20:	83 c4 10             	add    $0x10,%esp
  801d23:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d25:	89 d0                	mov    %edx,%eax
  801d27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d2a:	5b                   	pop    %ebx
  801d2b:	5e                   	pop    %esi
  801d2c:	5d                   	pop    %ebp
  801d2d:	c3                   	ret    

00801d2e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d37:	50                   	push   %eax
  801d38:	ff 75 08             	pushl  0x8(%ebp)
  801d3b:	e8 99 f0 ff ff       	call   800dd9 <fd_lookup>
  801d40:	89 c2                	mov    %eax,%edx
  801d42:	83 c4 10             	add    $0x10,%esp
  801d45:	85 d2                	test   %edx,%edx
  801d47:	78 18                	js     801d61 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d49:	83 ec 0c             	sub    $0xc,%esp
  801d4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4f:	e8 1f f0 ff ff       	call   800d73 <fd2data>
	return _pipeisclosed(fd, p);
  801d54:	89 c2                	mov    %eax,%edx
  801d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d59:	e8 26 fd ff ff       	call   801a84 <_pipeisclosed>
  801d5e:	83 c4 10             	add    $0x10,%esp
}
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    

00801d63 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d66:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    

00801d6d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d6d:	55                   	push   %ebp
  801d6e:	89 e5                	mov    %esp,%ebp
  801d70:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d73:	68 e7 27 80 00       	push   $0x8027e7
  801d78:	ff 75 0c             	pushl  0xc(%ebp)
  801d7b:	e8 48 e9 ff ff       	call   8006c8 <strcpy>
	return 0;
}
  801d80:	b8 00 00 00 00       	mov    $0x0,%eax
  801d85:	c9                   	leave  
  801d86:	c3                   	ret    

00801d87 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	57                   	push   %edi
  801d8b:	56                   	push   %esi
  801d8c:	53                   	push   %ebx
  801d8d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d93:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d98:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d9e:	eb 2d                	jmp    801dcd <devcons_write+0x46>
		m = n - tot;
  801da0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801da3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801da5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801da8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dad:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db0:	83 ec 04             	sub    $0x4,%esp
  801db3:	53                   	push   %ebx
  801db4:	03 45 0c             	add    0xc(%ebp),%eax
  801db7:	50                   	push   %eax
  801db8:	57                   	push   %edi
  801db9:	e8 9c ea ff ff       	call   80085a <memmove>
		sys_cputs(buf, m);
  801dbe:	83 c4 08             	add    $0x8,%esp
  801dc1:	53                   	push   %ebx
  801dc2:	57                   	push   %edi
  801dc3:	e8 4d ec ff ff       	call   800a15 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc8:	01 de                	add    %ebx,%esi
  801dca:	83 c4 10             	add    $0x10,%esp
  801dcd:	89 f0                	mov    %esi,%eax
  801dcf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dd2:	72 cc                	jb     801da0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd7:	5b                   	pop    %ebx
  801dd8:	5e                   	pop    %esi
  801dd9:	5f                   	pop    %edi
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    

00801ddc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801de2:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801de7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801deb:	75 07                	jne    801df4 <devcons_read+0x18>
  801ded:	eb 28                	jmp    801e17 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801def:	e8 be ec ff ff       	call   800ab2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801df4:	e8 3a ec ff ff       	call   800a33 <sys_cgetc>
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	74 f2                	je     801def <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	78 16                	js     801e17 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e01:	83 f8 04             	cmp    $0x4,%eax
  801e04:	74 0c                	je     801e12 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e06:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e09:	88 02                	mov    %al,(%edx)
	return 1;
  801e0b:	b8 01 00 00 00       	mov    $0x1,%eax
  801e10:	eb 05                	jmp    801e17 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e12:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e17:	c9                   	leave  
  801e18:	c3                   	ret    

00801e19 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e22:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e25:	6a 01                	push   $0x1
  801e27:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2a:	50                   	push   %eax
  801e2b:	e8 e5 eb ff ff       	call   800a15 <sys_cputs>
  801e30:	83 c4 10             	add    $0x10,%esp
}
  801e33:	c9                   	leave  
  801e34:	c3                   	ret    

00801e35 <getchar>:

int
getchar(void)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e3b:	6a 01                	push   $0x1
  801e3d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e40:	50                   	push   %eax
  801e41:	6a 00                	push   $0x0
  801e43:	e8 00 f2 ff ff       	call   801048 <read>
	if (r < 0)
  801e48:	83 c4 10             	add    $0x10,%esp
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	78 0f                	js     801e5e <getchar+0x29>
		return r;
	if (r < 1)
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	7e 06                	jle    801e59 <getchar+0x24>
		return -E_EOF;
	return c;
  801e53:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e57:	eb 05                	jmp    801e5e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e59:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e5e:	c9                   	leave  
  801e5f:	c3                   	ret    

00801e60 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e69:	50                   	push   %eax
  801e6a:	ff 75 08             	pushl  0x8(%ebp)
  801e6d:	e8 67 ef ff ff       	call   800dd9 <fd_lookup>
  801e72:	83 c4 10             	add    $0x10,%esp
  801e75:	85 c0                	test   %eax,%eax
  801e77:	78 11                	js     801e8a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e82:	39 10                	cmp    %edx,(%eax)
  801e84:	0f 94 c0             	sete   %al
  801e87:	0f b6 c0             	movzbl %al,%eax
}
  801e8a:	c9                   	leave  
  801e8b:	c3                   	ret    

00801e8c <opencons>:

int
opencons(void)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e95:	50                   	push   %eax
  801e96:	e8 ef ee ff ff       	call   800d8a <fd_alloc>
  801e9b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e9e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	78 3e                	js     801ee2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea4:	83 ec 04             	sub    $0x4,%esp
  801ea7:	68 07 04 00 00       	push   $0x407
  801eac:	ff 75 f4             	pushl  -0xc(%ebp)
  801eaf:	6a 00                	push   $0x0
  801eb1:	e8 1b ec ff ff       	call   800ad1 <sys_page_alloc>
  801eb6:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	78 23                	js     801ee2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ebf:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ed4:	83 ec 0c             	sub    $0xc,%esp
  801ed7:	50                   	push   %eax
  801ed8:	e8 86 ee ff ff       	call   800d63 <fd2num>
  801edd:	89 c2                	mov    %eax,%edx
  801edf:	83 c4 10             	add    $0x10,%esp
}
  801ee2:	89 d0                	mov    %edx,%eax
  801ee4:	c9                   	leave  
  801ee5:	c3                   	ret    

00801ee6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	56                   	push   %esi
  801eea:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801eeb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801eee:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ef4:	e8 9a eb ff ff       	call   800a93 <sys_getenvid>
  801ef9:	83 ec 0c             	sub    $0xc,%esp
  801efc:	ff 75 0c             	pushl  0xc(%ebp)
  801eff:	ff 75 08             	pushl  0x8(%ebp)
  801f02:	56                   	push   %esi
  801f03:	50                   	push   %eax
  801f04:	68 f4 27 80 00       	push   $0x8027f4
  801f09:	e8 33 e2 ff ff       	call   800141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f0e:	83 c4 18             	add    $0x18,%esp
  801f11:	53                   	push   %ebx
  801f12:	ff 75 10             	pushl  0x10(%ebp)
  801f15:	e8 d6 e1 ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  801f1a:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  801f21:	e8 1b e2 ff ff       	call   800141 <cprintf>
  801f26:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f29:	cc                   	int3   
  801f2a:	eb fd                	jmp    801f29 <_panic+0x43>

00801f2c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	56                   	push   %esi
  801f30:	53                   	push   %ebx
  801f31:	8b 75 08             	mov    0x8(%ebp),%esi
  801f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f41:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f44:	83 ec 0c             	sub    $0xc,%esp
  801f47:	50                   	push   %eax
  801f48:	e8 34 ed ff ff       	call   800c81 <sys_ipc_recv>
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	85 c0                	test   %eax,%eax
  801f52:	79 16                	jns    801f6a <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801f54:	85 f6                	test   %esi,%esi
  801f56:	74 06                	je     801f5e <ipc_recv+0x32>
  801f58:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801f5e:	85 db                	test   %ebx,%ebx
  801f60:	74 2c                	je     801f8e <ipc_recv+0x62>
  801f62:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f68:	eb 24                	jmp    801f8e <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801f6a:	85 f6                	test   %esi,%esi
  801f6c:	74 0a                	je     801f78 <ipc_recv+0x4c>
  801f6e:	a1 08 40 80 00       	mov    0x804008,%eax
  801f73:	8b 40 74             	mov    0x74(%eax),%eax
  801f76:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801f78:	85 db                	test   %ebx,%ebx
  801f7a:	74 0a                	je     801f86 <ipc_recv+0x5a>
  801f7c:	a1 08 40 80 00       	mov    0x804008,%eax
  801f81:	8b 40 78             	mov    0x78(%eax),%eax
  801f84:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801f86:	a1 08 40 80 00       	mov    0x804008,%eax
  801f8b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f91:	5b                   	pop    %ebx
  801f92:	5e                   	pop    %esi
  801f93:	5d                   	pop    %ebp
  801f94:	c3                   	ret    

00801f95 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	57                   	push   %edi
  801f99:	56                   	push   %esi
  801f9a:	53                   	push   %ebx
  801f9b:	83 ec 0c             	sub    $0xc,%esp
  801f9e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801fa7:	85 db                	test   %ebx,%ebx
  801fa9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fae:	0f 44 d8             	cmove  %eax,%ebx
  801fb1:	eb 1c                	jmp    801fcf <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801fb3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fb6:	74 12                	je     801fca <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801fb8:	50                   	push   %eax
  801fb9:	68 18 28 80 00       	push   $0x802818
  801fbe:	6a 39                	push   $0x39
  801fc0:	68 33 28 80 00       	push   $0x802833
  801fc5:	e8 1c ff ff ff       	call   801ee6 <_panic>
                 sys_yield();
  801fca:	e8 e3 ea ff ff       	call   800ab2 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801fcf:	ff 75 14             	pushl  0x14(%ebp)
  801fd2:	53                   	push   %ebx
  801fd3:	56                   	push   %esi
  801fd4:	57                   	push   %edi
  801fd5:	e8 84 ec ff ff       	call   800c5e <sys_ipc_try_send>
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	78 d2                	js     801fb3 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801fe1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe4:	5b                   	pop    %ebx
  801fe5:	5e                   	pop    %esi
  801fe6:	5f                   	pop    %edi
  801fe7:	5d                   	pop    %ebp
  801fe8:	c3                   	ret    

00801fe9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fef:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ff4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ff7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ffd:	8b 52 50             	mov    0x50(%edx),%edx
  802000:	39 ca                	cmp    %ecx,%edx
  802002:	75 0d                	jne    802011 <ipc_find_env+0x28>
			return envs[i].env_id;
  802004:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802007:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80200c:	8b 40 08             	mov    0x8(%eax),%eax
  80200f:	eb 0e                	jmp    80201f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802011:	83 c0 01             	add    $0x1,%eax
  802014:	3d 00 04 00 00       	cmp    $0x400,%eax
  802019:	75 d9                	jne    801ff4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80201b:	66 b8 00 00          	mov    $0x0,%ax
}
  80201f:	5d                   	pop    %ebp
  802020:	c3                   	ret    

00802021 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802021:	55                   	push   %ebp
  802022:	89 e5                	mov    %esp,%ebp
  802024:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802027:	89 d0                	mov    %edx,%eax
  802029:	c1 e8 16             	shr    $0x16,%eax
  80202c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802033:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802038:	f6 c1 01             	test   $0x1,%cl
  80203b:	74 1d                	je     80205a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80203d:	c1 ea 0c             	shr    $0xc,%edx
  802040:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802047:	f6 c2 01             	test   $0x1,%dl
  80204a:	74 0e                	je     80205a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80204c:	c1 ea 0c             	shr    $0xc,%edx
  80204f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802056:	ef 
  802057:	0f b7 c0             	movzwl %ax,%eax
}
  80205a:	5d                   	pop    %ebp
  80205b:	c3                   	ret    
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	83 ec 10             	sub    $0x10,%esp
  802066:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80206a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80206e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802072:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802076:	85 d2                	test   %edx,%edx
  802078:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80207c:	89 34 24             	mov    %esi,(%esp)
  80207f:	89 c8                	mov    %ecx,%eax
  802081:	75 35                	jne    8020b8 <__udivdi3+0x58>
  802083:	39 f1                	cmp    %esi,%ecx
  802085:	0f 87 bd 00 00 00    	ja     802148 <__udivdi3+0xe8>
  80208b:	85 c9                	test   %ecx,%ecx
  80208d:	89 cd                	mov    %ecx,%ebp
  80208f:	75 0b                	jne    80209c <__udivdi3+0x3c>
  802091:	b8 01 00 00 00       	mov    $0x1,%eax
  802096:	31 d2                	xor    %edx,%edx
  802098:	f7 f1                	div    %ecx
  80209a:	89 c5                	mov    %eax,%ebp
  80209c:	89 f0                	mov    %esi,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f5                	div    %ebp
  8020a2:	89 c6                	mov    %eax,%esi
  8020a4:	89 f8                	mov    %edi,%eax
  8020a6:	f7 f5                	div    %ebp
  8020a8:	89 f2                	mov    %esi,%edx
  8020aa:	83 c4 10             	add    $0x10,%esp
  8020ad:	5e                   	pop    %esi
  8020ae:	5f                   	pop    %edi
  8020af:	5d                   	pop    %ebp
  8020b0:	c3                   	ret    
  8020b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	3b 14 24             	cmp    (%esp),%edx
  8020bb:	77 7b                	ja     802138 <__udivdi3+0xd8>
  8020bd:	0f bd f2             	bsr    %edx,%esi
  8020c0:	83 f6 1f             	xor    $0x1f,%esi
  8020c3:	0f 84 97 00 00 00    	je     802160 <__udivdi3+0x100>
  8020c9:	bd 20 00 00 00       	mov    $0x20,%ebp
  8020ce:	89 d7                	mov    %edx,%edi
  8020d0:	89 f1                	mov    %esi,%ecx
  8020d2:	29 f5                	sub    %esi,%ebp
  8020d4:	d3 e7                	shl    %cl,%edi
  8020d6:	89 c2                	mov    %eax,%edx
  8020d8:	89 e9                	mov    %ebp,%ecx
  8020da:	d3 ea                	shr    %cl,%edx
  8020dc:	89 f1                	mov    %esi,%ecx
  8020de:	09 fa                	or     %edi,%edx
  8020e0:	8b 3c 24             	mov    (%esp),%edi
  8020e3:	d3 e0                	shl    %cl,%eax
  8020e5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020e9:	89 e9                	mov    %ebp,%ecx
  8020eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ef:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020f3:	89 fa                	mov    %edi,%edx
  8020f5:	d3 ea                	shr    %cl,%edx
  8020f7:	89 f1                	mov    %esi,%ecx
  8020f9:	d3 e7                	shl    %cl,%edi
  8020fb:	89 e9                	mov    %ebp,%ecx
  8020fd:	d3 e8                	shr    %cl,%eax
  8020ff:	09 c7                	or     %eax,%edi
  802101:	89 f8                	mov    %edi,%eax
  802103:	f7 74 24 08          	divl   0x8(%esp)
  802107:	89 d5                	mov    %edx,%ebp
  802109:	89 c7                	mov    %eax,%edi
  80210b:	f7 64 24 0c          	mull   0xc(%esp)
  80210f:	39 d5                	cmp    %edx,%ebp
  802111:	89 14 24             	mov    %edx,(%esp)
  802114:	72 11                	jb     802127 <__udivdi3+0xc7>
  802116:	8b 54 24 04          	mov    0x4(%esp),%edx
  80211a:	89 f1                	mov    %esi,%ecx
  80211c:	d3 e2                	shl    %cl,%edx
  80211e:	39 c2                	cmp    %eax,%edx
  802120:	73 5e                	jae    802180 <__udivdi3+0x120>
  802122:	3b 2c 24             	cmp    (%esp),%ebp
  802125:	75 59                	jne    802180 <__udivdi3+0x120>
  802127:	8d 47 ff             	lea    -0x1(%edi),%eax
  80212a:	31 f6                	xor    %esi,%esi
  80212c:	89 f2                	mov    %esi,%edx
  80212e:	83 c4 10             	add    $0x10,%esp
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	31 f6                	xor    %esi,%esi
  80213a:	31 c0                	xor    %eax,%eax
  80213c:	89 f2                	mov    %esi,%edx
  80213e:	83 c4 10             	add    $0x10,%esp
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	89 f2                	mov    %esi,%edx
  80214a:	31 f6                	xor    %esi,%esi
  80214c:	89 f8                	mov    %edi,%eax
  80214e:	f7 f1                	div    %ecx
  802150:	89 f2                	mov    %esi,%edx
  802152:	83 c4 10             	add    $0x10,%esp
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802164:	76 0b                	jbe    802171 <__udivdi3+0x111>
  802166:	31 c0                	xor    %eax,%eax
  802168:	3b 14 24             	cmp    (%esp),%edx
  80216b:	0f 83 37 ff ff ff    	jae    8020a8 <__udivdi3+0x48>
  802171:	b8 01 00 00 00       	mov    $0x1,%eax
  802176:	e9 2d ff ff ff       	jmp    8020a8 <__udivdi3+0x48>
  80217b:	90                   	nop
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 f8                	mov    %edi,%eax
  802182:	31 f6                	xor    %esi,%esi
  802184:	e9 1f ff ff ff       	jmp    8020a8 <__udivdi3+0x48>
  802189:	66 90                	xchg   %ax,%ax
  80218b:	66 90                	xchg   %ax,%ax
  80218d:	66 90                	xchg   %ax,%ax
  80218f:	90                   	nop

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	83 ec 20             	sub    $0x20,%esp
  802196:	8b 44 24 34          	mov    0x34(%esp),%eax
  80219a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80219e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a2:	89 c6                	mov    %eax,%esi
  8021a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021a8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021ac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  8021b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021b4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8021b8:	89 74 24 18          	mov    %esi,0x18(%esp)
  8021bc:	85 c0                	test   %eax,%eax
  8021be:	89 c2                	mov    %eax,%edx
  8021c0:	75 1e                	jne    8021e0 <__umoddi3+0x50>
  8021c2:	39 f7                	cmp    %esi,%edi
  8021c4:	76 52                	jbe    802218 <__umoddi3+0x88>
  8021c6:	89 c8                	mov    %ecx,%eax
  8021c8:	89 f2                	mov    %esi,%edx
  8021ca:	f7 f7                	div    %edi
  8021cc:	89 d0                	mov    %edx,%eax
  8021ce:	31 d2                	xor    %edx,%edx
  8021d0:	83 c4 20             	add    $0x20,%esp
  8021d3:	5e                   	pop    %esi
  8021d4:	5f                   	pop    %edi
  8021d5:	5d                   	pop    %ebp
  8021d6:	c3                   	ret    
  8021d7:	89 f6                	mov    %esi,%esi
  8021d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021e0:	39 f0                	cmp    %esi,%eax
  8021e2:	77 5c                	ja     802240 <__umoddi3+0xb0>
  8021e4:	0f bd e8             	bsr    %eax,%ebp
  8021e7:	83 f5 1f             	xor    $0x1f,%ebp
  8021ea:	75 64                	jne    802250 <__umoddi3+0xc0>
  8021ec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8021f0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8021f4:	0f 86 f6 00 00 00    	jbe    8022f0 <__umoddi3+0x160>
  8021fa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8021fe:	0f 82 ec 00 00 00    	jb     8022f0 <__umoddi3+0x160>
  802204:	8b 44 24 14          	mov    0x14(%esp),%eax
  802208:	8b 54 24 18          	mov    0x18(%esp),%edx
  80220c:	83 c4 20             	add    $0x20,%esp
  80220f:	5e                   	pop    %esi
  802210:	5f                   	pop    %edi
  802211:	5d                   	pop    %ebp
  802212:	c3                   	ret    
  802213:	90                   	nop
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	85 ff                	test   %edi,%edi
  80221a:	89 fd                	mov    %edi,%ebp
  80221c:	75 0b                	jne    802229 <__umoddi3+0x99>
  80221e:	b8 01 00 00 00       	mov    $0x1,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f7                	div    %edi
  802227:	89 c5                	mov    %eax,%ebp
  802229:	8b 44 24 10          	mov    0x10(%esp),%eax
  80222d:	31 d2                	xor    %edx,%edx
  80222f:	f7 f5                	div    %ebp
  802231:	89 c8                	mov    %ecx,%eax
  802233:	f7 f5                	div    %ebp
  802235:	eb 95                	jmp    8021cc <__umoddi3+0x3c>
  802237:	89 f6                	mov    %esi,%esi
  802239:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 20             	add    $0x20,%esp
  802247:	5e                   	pop    %esi
  802248:	5f                   	pop    %edi
  802249:	5d                   	pop    %ebp
  80224a:	c3                   	ret    
  80224b:	90                   	nop
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	b8 20 00 00 00       	mov    $0x20,%eax
  802255:	89 e9                	mov    %ebp,%ecx
  802257:	29 e8                	sub    %ebp,%eax
  802259:	d3 e2                	shl    %cl,%edx
  80225b:	89 c7                	mov    %eax,%edi
  80225d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802261:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802265:	89 f9                	mov    %edi,%ecx
  802267:	d3 e8                	shr    %cl,%eax
  802269:	89 c1                	mov    %eax,%ecx
  80226b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80226f:	09 d1                	or     %edx,%ecx
  802271:	89 fa                	mov    %edi,%edx
  802273:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802277:	89 e9                	mov    %ebp,%ecx
  802279:	d3 e0                	shl    %cl,%eax
  80227b:	89 f9                	mov    %edi,%ecx
  80227d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802281:	89 f0                	mov    %esi,%eax
  802283:	d3 e8                	shr    %cl,%eax
  802285:	89 e9                	mov    %ebp,%ecx
  802287:	89 c7                	mov    %eax,%edi
  802289:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80228d:	d3 e6                	shl    %cl,%esi
  80228f:	89 d1                	mov    %edx,%ecx
  802291:	89 fa                	mov    %edi,%edx
  802293:	d3 e8                	shr    %cl,%eax
  802295:	89 e9                	mov    %ebp,%ecx
  802297:	09 f0                	or     %esi,%eax
  802299:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80229d:	f7 74 24 10          	divl   0x10(%esp)
  8022a1:	d3 e6                	shl    %cl,%esi
  8022a3:	89 d1                	mov    %edx,%ecx
  8022a5:	f7 64 24 0c          	mull   0xc(%esp)
  8022a9:	39 d1                	cmp    %edx,%ecx
  8022ab:	89 74 24 14          	mov    %esi,0x14(%esp)
  8022af:	89 d7                	mov    %edx,%edi
  8022b1:	89 c6                	mov    %eax,%esi
  8022b3:	72 0a                	jb     8022bf <__umoddi3+0x12f>
  8022b5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  8022b9:	73 10                	jae    8022cb <__umoddi3+0x13b>
  8022bb:	39 d1                	cmp    %edx,%ecx
  8022bd:	75 0c                	jne    8022cb <__umoddi3+0x13b>
  8022bf:	89 d7                	mov    %edx,%edi
  8022c1:	89 c6                	mov    %eax,%esi
  8022c3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  8022c7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  8022cb:	89 ca                	mov    %ecx,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022d3:	29 f0                	sub    %esi,%eax
  8022d5:	19 fa                	sbb    %edi,%edx
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8022de:	89 d7                	mov    %edx,%edi
  8022e0:	d3 e7                	shl    %cl,%edi
  8022e2:	89 e9                	mov    %ebp,%ecx
  8022e4:	09 f8                	or     %edi,%eax
  8022e6:	d3 ea                	shr    %cl,%edx
  8022e8:	83 c4 20             	add    $0x20,%esp
  8022eb:	5e                   	pop    %esi
  8022ec:	5f                   	pop    %edi
  8022ed:	5d                   	pop    %ebp
  8022ee:	c3                   	ret    
  8022ef:	90                   	nop
  8022f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022f4:	29 f9                	sub    %edi,%ecx
  8022f6:	19 c6                	sbb    %eax,%esi
  8022f8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8022fc:	89 74 24 18          	mov    %esi,0x18(%esp)
  802300:	e9 ff fe ff ff       	jmp    802204 <__umoddi3+0x74>
