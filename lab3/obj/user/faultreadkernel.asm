
obj/user/faultreadkernel:     file format elf32-i386


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
  80003f:	68 c0 0d 80 00       	push   $0x800dc0
  800044:	e8 f3 00 00 00       	call   80013c <cprintf>
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
  800059:	e8 30 0a 00 00       	call   800a8e <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800066:	c1 e0 05             	shl    $0x5,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x30>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 0a 00 00 00       	call   800097 <exit>
  80008d:	83 c4 10             	add    $0x10,%esp
}
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009d:	6a 00                	push   $0x0
  80009f:	e8 a9 09 00 00       	call   800a4d <sys_env_destroy>
  8000a4:	83 c4 10             	add    $0x10,%esp
}
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    

008000a9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	53                   	push   %ebx
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b3:	8b 13                	mov    (%ebx),%edx
  8000b5:	8d 42 01             	lea    0x1(%edx),%eax
  8000b8:	89 03                	mov    %eax,(%ebx)
  8000ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000bd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c6:	75 1a                	jne    8000e2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c8:	83 ec 08             	sub    $0x8,%esp
  8000cb:	68 ff 00 00 00       	push   $0xff
  8000d0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d3:	50                   	push   %eax
  8000d4:	e8 37 09 00 00       	call   800a10 <sys_cputs>
		b->idx = 0;
  8000d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000df:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    

008000eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fb:	00 00 00 
	b.cnt = 0;
  8000fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800105:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800108:	ff 75 0c             	pushl  0xc(%ebp)
  80010b:	ff 75 08             	pushl  0x8(%ebp)
  80010e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800114:	50                   	push   %eax
  800115:	68 a9 00 80 00       	push   $0x8000a9
  80011a:	e8 4f 01 00 00       	call   80026e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011f:	83 c4 08             	add    $0x8,%esp
  800122:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800128:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012e:	50                   	push   %eax
  80012f:	e8 dc 08 00 00       	call   800a10 <sys_cputs>

	return b.cnt;
}
  800134:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800142:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800145:	50                   	push   %eax
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	e8 9d ff ff ff       	call   8000eb <vcprintf>
	va_end(ap);

	return cnt;
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
  800156:	83 ec 1c             	sub    $0x1c,%esp
  800159:	89 c7                	mov    %eax,%edi
  80015b:	89 d6                	mov    %edx,%esi
  80015d:	8b 45 08             	mov    0x8(%ebp),%eax
  800160:	8b 55 0c             	mov    0xc(%ebp),%edx
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800168:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80016b:	8b 45 10             	mov    0x10(%ebp),%eax
  80016e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800171:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800174:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80017b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80017e:	72 05                	jb     800185 <printnum+0x35>
  800180:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800183:	77 3e                	ja     8001c3 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	ff 75 18             	pushl  0x18(%ebp)
  80018b:	83 eb 01             	sub    $0x1,%ebx
  80018e:	53                   	push   %ebx
  80018f:	50                   	push   %eax
  800190:	83 ec 08             	sub    $0x8,%esp
  800193:	ff 75 e4             	pushl  -0x1c(%ebp)
  800196:	ff 75 e0             	pushl  -0x20(%ebp)
  800199:	ff 75 dc             	pushl  -0x24(%ebp)
  80019c:	ff 75 d8             	pushl  -0x28(%ebp)
  80019f:	e8 5c 09 00 00       	call   800b00 <__udivdi3>
  8001a4:	83 c4 18             	add    $0x18,%esp
  8001a7:	52                   	push   %edx
  8001a8:	50                   	push   %eax
  8001a9:	89 f2                	mov    %esi,%edx
  8001ab:	89 f8                	mov    %edi,%eax
  8001ad:	e8 9e ff ff ff       	call   800150 <printnum>
  8001b2:	83 c4 20             	add    $0x20,%esp
  8001b5:	eb 13                	jmp    8001ca <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b7:	83 ec 08             	sub    $0x8,%esp
  8001ba:	56                   	push   %esi
  8001bb:	ff 75 18             	pushl  0x18(%ebp)
  8001be:	ff d7                	call   *%edi
  8001c0:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c3:	83 eb 01             	sub    $0x1,%ebx
  8001c6:	85 db                	test   %ebx,%ebx
  8001c8:	7f ed                	jg     8001b7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ca:	83 ec 08             	sub    $0x8,%esp
  8001cd:	56                   	push   %esi
  8001ce:	83 ec 04             	sub    $0x4,%esp
  8001d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001da:	ff 75 d8             	pushl  -0x28(%ebp)
  8001dd:	e8 4e 0a 00 00       	call   800c30 <__umoddi3>
  8001e2:	83 c4 14             	add    $0x14,%esp
  8001e5:	0f be 80 f1 0d 80 00 	movsbl 0x800df1(%eax),%eax
  8001ec:	50                   	push   %eax
  8001ed:	ff d7                	call   *%edi
  8001ef:	83 c4 10             	add    $0x10,%esp
}
  8001f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f5:	5b                   	pop    %ebx
  8001f6:	5e                   	pop    %esi
  8001f7:	5f                   	pop    %edi
  8001f8:	5d                   	pop    %ebp
  8001f9:	c3                   	ret    

008001fa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8001fd:	83 fa 01             	cmp    $0x1,%edx
  800200:	7e 0e                	jle    800210 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800202:	8b 10                	mov    (%eax),%edx
  800204:	8d 4a 08             	lea    0x8(%edx),%ecx
  800207:	89 08                	mov    %ecx,(%eax)
  800209:	8b 02                	mov    (%edx),%eax
  80020b:	8b 52 04             	mov    0x4(%edx),%edx
  80020e:	eb 22                	jmp    800232 <getuint+0x38>
	else if (lflag)
  800210:	85 d2                	test   %edx,%edx
  800212:	74 10                	je     800224 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800214:	8b 10                	mov    (%eax),%edx
  800216:	8d 4a 04             	lea    0x4(%edx),%ecx
  800219:	89 08                	mov    %ecx,(%eax)
  80021b:	8b 02                	mov    (%edx),%eax
  80021d:	ba 00 00 00 00       	mov    $0x0,%edx
  800222:	eb 0e                	jmp    800232 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800224:	8b 10                	mov    (%eax),%edx
  800226:	8d 4a 04             	lea    0x4(%edx),%ecx
  800229:	89 08                	mov    %ecx,(%eax)
  80022b:	8b 02                	mov    (%edx),%eax
  80022d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    

00800234 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	3b 50 04             	cmp    0x4(%eax),%edx
  800243:	73 0a                	jae    80024f <sprintputch+0x1b>
		*b->buf++ = ch;
  800245:	8d 4a 01             	lea    0x1(%edx),%ecx
  800248:	89 08                	mov    %ecx,(%eax)
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	88 02                	mov    %al,(%edx)
}
  80024f:	5d                   	pop    %ebp
  800250:	c3                   	ret    

00800251 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800257:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025a:	50                   	push   %eax
  80025b:	ff 75 10             	pushl  0x10(%ebp)
  80025e:	ff 75 0c             	pushl  0xc(%ebp)
  800261:	ff 75 08             	pushl  0x8(%ebp)
  800264:	e8 05 00 00 00       	call   80026e <vprintfmt>
	va_end(ap);
  800269:	83 c4 10             	add    $0x10,%esp
}
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	57                   	push   %edi
  800272:	56                   	push   %esi
  800273:	53                   	push   %ebx
  800274:	83 ec 2c             	sub    $0x2c,%esp
  800277:	8b 75 08             	mov    0x8(%ebp),%esi
  80027a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800280:	eb 12                	jmp    800294 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800282:	85 c0                	test   %eax,%eax
  800284:	0f 84 90 03 00 00    	je     80061a <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	53                   	push   %ebx
  80028e:	50                   	push   %eax
  80028f:	ff d6                	call   *%esi
  800291:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800294:	83 c7 01             	add    $0x1,%edi
  800297:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80029b:	83 f8 25             	cmp    $0x25,%eax
  80029e:	75 e2                	jne    800282 <vprintfmt+0x14>
  8002a0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002a4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ab:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002b2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002be:	eb 07                	jmp    8002c7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002c3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c7:	8d 47 01             	lea    0x1(%edi),%eax
  8002ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cd:	0f b6 07             	movzbl (%edi),%eax
  8002d0:	0f b6 c8             	movzbl %al,%ecx
  8002d3:	83 e8 23             	sub    $0x23,%eax
  8002d6:	3c 55                	cmp    $0x55,%al
  8002d8:	0f 87 21 03 00 00    	ja     8005ff <vprintfmt+0x391>
  8002de:	0f b6 c0             	movzbl %al,%eax
  8002e1:	ff 24 85 80 0e 80 00 	jmp    *0x800e80(,%eax,4)
  8002e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002eb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002ef:	eb d6                	jmp    8002c7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002fc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ff:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800303:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800306:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800309:	83 fa 09             	cmp    $0x9,%edx
  80030c:	77 39                	ja     800347 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80030e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800311:	eb e9                	jmp    8002fc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800313:	8b 45 14             	mov    0x14(%ebp),%eax
  800316:	8d 48 04             	lea    0x4(%eax),%ecx
  800319:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80031c:	8b 00                	mov    (%eax),%eax
  80031e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800321:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800324:	eb 27                	jmp    80034d <vprintfmt+0xdf>
  800326:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800329:	85 c0                	test   %eax,%eax
  80032b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800330:	0f 49 c8             	cmovns %eax,%ecx
  800333:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800339:	eb 8c                	jmp    8002c7 <vprintfmt+0x59>
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80033e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800345:	eb 80                	jmp    8002c7 <vprintfmt+0x59>
  800347:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80034a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80034d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800351:	0f 89 70 ff ff ff    	jns    8002c7 <vprintfmt+0x59>
				width = precision, precision = -1;
  800357:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80035a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800364:	e9 5e ff ff ff       	jmp    8002c7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800369:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80036f:	e9 53 ff ff ff       	jmp    8002c7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800374:	8b 45 14             	mov    0x14(%ebp),%eax
  800377:	8d 50 04             	lea    0x4(%eax),%edx
  80037a:	89 55 14             	mov    %edx,0x14(%ebp)
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	53                   	push   %ebx
  800381:	ff 30                	pushl  (%eax)
  800383:	ff d6                	call   *%esi
			break;
  800385:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80038b:	e9 04 ff ff ff       	jmp    800294 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 50 04             	lea    0x4(%eax),%edx
  800396:	89 55 14             	mov    %edx,0x14(%ebp)
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	99                   	cltd   
  80039c:	31 d0                	xor    %edx,%eax
  80039e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a0:	83 f8 07             	cmp    $0x7,%eax
  8003a3:	7f 0b                	jg     8003b0 <vprintfmt+0x142>
  8003a5:	8b 14 85 e0 0f 80 00 	mov    0x800fe0(,%eax,4),%edx
  8003ac:	85 d2                	test   %edx,%edx
  8003ae:	75 18                	jne    8003c8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003b0:	50                   	push   %eax
  8003b1:	68 09 0e 80 00       	push   $0x800e09
  8003b6:	53                   	push   %ebx
  8003b7:	56                   	push   %esi
  8003b8:	e8 94 fe ff ff       	call   800251 <printfmt>
  8003bd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003c3:	e9 cc fe ff ff       	jmp    800294 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003c8:	52                   	push   %edx
  8003c9:	68 12 0e 80 00       	push   $0x800e12
  8003ce:	53                   	push   %ebx
  8003cf:	56                   	push   %esi
  8003d0:	e8 7c fe ff ff       	call   800251 <printfmt>
  8003d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003db:	e9 b4 fe ff ff       	jmp    800294 <vprintfmt+0x26>
  8003e0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e6:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 50 04             	lea    0x4(%eax),%edx
  8003ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f4:	85 ff                	test   %edi,%edi
  8003f6:	ba 02 0e 80 00       	mov    $0x800e02,%edx
  8003fb:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  8003fe:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800402:	0f 84 92 00 00 00    	je     80049a <vprintfmt+0x22c>
  800408:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80040c:	0f 8e 96 00 00 00    	jle    8004a8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	51                   	push   %ecx
  800416:	57                   	push   %edi
  800417:	e8 86 02 00 00       	call   8006a2 <strnlen>
  80041c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80041f:	29 c1                	sub    %eax,%ecx
  800421:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800424:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800427:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80042b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800431:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800433:	eb 0f                	jmp    800444 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	53                   	push   %ebx
  800439:	ff 75 e0             	pushl  -0x20(%ebp)
  80043c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043e:	83 ef 01             	sub    $0x1,%edi
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	85 ff                	test   %edi,%edi
  800446:	7f ed                	jg     800435 <vprintfmt+0x1c7>
  800448:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80044b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80044e:	85 c9                	test   %ecx,%ecx
  800450:	b8 00 00 00 00       	mov    $0x0,%eax
  800455:	0f 49 c1             	cmovns %ecx,%eax
  800458:	29 c1                	sub    %eax,%ecx
  80045a:	89 75 08             	mov    %esi,0x8(%ebp)
  80045d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800460:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800463:	89 cb                	mov    %ecx,%ebx
  800465:	eb 4d                	jmp    8004b4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800467:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046b:	74 1b                	je     800488 <vprintfmt+0x21a>
  80046d:	0f be c0             	movsbl %al,%eax
  800470:	83 e8 20             	sub    $0x20,%eax
  800473:	83 f8 5e             	cmp    $0x5e,%eax
  800476:	76 10                	jbe    800488 <vprintfmt+0x21a>
					putch('?', putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	ff 75 0c             	pushl  0xc(%ebp)
  80047e:	6a 3f                	push   $0x3f
  800480:	ff 55 08             	call   *0x8(%ebp)
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	eb 0d                	jmp    800495 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	ff 75 0c             	pushl  0xc(%ebp)
  80048e:	52                   	push   %edx
  80048f:	ff 55 08             	call   *0x8(%ebp)
  800492:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800495:	83 eb 01             	sub    $0x1,%ebx
  800498:	eb 1a                	jmp    8004b4 <vprintfmt+0x246>
  80049a:	89 75 08             	mov    %esi,0x8(%ebp)
  80049d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a6:	eb 0c                	jmp    8004b4 <vprintfmt+0x246>
  8004a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b4:	83 c7 01             	add    $0x1,%edi
  8004b7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004bb:	0f be d0             	movsbl %al,%edx
  8004be:	85 d2                	test   %edx,%edx
  8004c0:	74 23                	je     8004e5 <vprintfmt+0x277>
  8004c2:	85 f6                	test   %esi,%esi
  8004c4:	78 a1                	js     800467 <vprintfmt+0x1f9>
  8004c6:	83 ee 01             	sub    $0x1,%esi
  8004c9:	79 9c                	jns    800467 <vprintfmt+0x1f9>
  8004cb:	89 df                	mov    %ebx,%edi
  8004cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d3:	eb 18                	jmp    8004ed <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	53                   	push   %ebx
  8004d9:	6a 20                	push   $0x20
  8004db:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004dd:	83 ef 01             	sub    $0x1,%edi
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	eb 08                	jmp    8004ed <vprintfmt+0x27f>
  8004e5:	89 df                	mov    %ebx,%edi
  8004e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	7f e4                	jg     8004d5 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f4:	e9 9b fd ff ff       	jmp    800294 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004f9:	83 fa 01             	cmp    $0x1,%edx
  8004fc:	7e 16                	jle    800514 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 50 08             	lea    0x8(%eax),%edx
  800504:	89 55 14             	mov    %edx,0x14(%ebp)
  800507:	8b 50 04             	mov    0x4(%eax),%edx
  80050a:	8b 00                	mov    (%eax),%eax
  80050c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800512:	eb 32                	jmp    800546 <vprintfmt+0x2d8>
	else if (lflag)
  800514:	85 d2                	test   %edx,%edx
  800516:	74 18                	je     800530 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 50 04             	lea    0x4(%eax),%edx
  80051e:	89 55 14             	mov    %edx,0x14(%ebp)
  800521:	8b 00                	mov    (%eax),%eax
  800523:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800526:	89 c1                	mov    %eax,%ecx
  800528:	c1 f9 1f             	sar    $0x1f,%ecx
  80052b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80052e:	eb 16                	jmp    800546 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 04             	lea    0x4(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053e:	89 c1                	mov    %eax,%ecx
  800540:	c1 f9 1f             	sar    $0x1f,%ecx
  800543:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800546:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800549:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800551:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800555:	79 74                	jns    8005cb <vprintfmt+0x35d>
				putch('-', putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	53                   	push   %ebx
  80055b:	6a 2d                	push   $0x2d
  80055d:	ff d6                	call   *%esi
				num = -(long long) num;
  80055f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800562:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800565:	f7 d8                	neg    %eax
  800567:	83 d2 00             	adc    $0x0,%edx
  80056a:	f7 da                	neg    %edx
  80056c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80056f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800574:	eb 55                	jmp    8005cb <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800576:	8d 45 14             	lea    0x14(%ebp),%eax
  800579:	e8 7c fc ff ff       	call   8001fa <getuint>
			base = 10;
  80057e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800583:	eb 46                	jmp    8005cb <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800585:	8d 45 14             	lea    0x14(%ebp),%eax
  800588:	e8 6d fc ff ff       	call   8001fa <getuint>
                        base = 8;
  80058d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800592:	eb 37                	jmp    8005cb <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	53                   	push   %ebx
  800598:	6a 30                	push   $0x30
  80059a:	ff d6                	call   *%esi
			putch('x', putdat);
  80059c:	83 c4 08             	add    $0x8,%esp
  80059f:	53                   	push   %ebx
  8005a0:	6a 78                	push   $0x78
  8005a2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ad:	8b 00                	mov    (%eax),%eax
  8005af:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005b4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005b7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005bc:	eb 0d                	jmp    8005cb <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005be:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c1:	e8 34 fc ff ff       	call   8001fa <getuint>
			base = 16;
  8005c6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005cb:	83 ec 0c             	sub    $0xc,%esp
  8005ce:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005d2:	57                   	push   %edi
  8005d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d6:	51                   	push   %ecx
  8005d7:	52                   	push   %edx
  8005d8:	50                   	push   %eax
  8005d9:	89 da                	mov    %ebx,%edx
  8005db:	89 f0                	mov    %esi,%eax
  8005dd:	e8 6e fb ff ff       	call   800150 <printnum>
			break;
  8005e2:	83 c4 20             	add    $0x20,%esp
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e8:	e9 a7 fc ff ff       	jmp    800294 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	51                   	push   %ecx
  8005f2:	ff d6                	call   *%esi
			break;
  8005f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8005fa:	e9 95 fc ff ff       	jmp    800294 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	6a 25                	push   $0x25
  800605:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800607:	83 c4 10             	add    $0x10,%esp
  80060a:	eb 03                	jmp    80060f <vprintfmt+0x3a1>
  80060c:	83 ef 01             	sub    $0x1,%edi
  80060f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800613:	75 f7                	jne    80060c <vprintfmt+0x39e>
  800615:	e9 7a fc ff ff       	jmp    800294 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80061a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061d:	5b                   	pop    %ebx
  80061e:	5e                   	pop    %esi
  80061f:	5f                   	pop    %edi
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	83 ec 18             	sub    $0x18,%esp
  800628:	8b 45 08             	mov    0x8(%ebp),%eax
  80062b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80062e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800631:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800635:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800638:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80063f:	85 c0                	test   %eax,%eax
  800641:	74 26                	je     800669 <vsnprintf+0x47>
  800643:	85 d2                	test   %edx,%edx
  800645:	7e 22                	jle    800669 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800647:	ff 75 14             	pushl  0x14(%ebp)
  80064a:	ff 75 10             	pushl  0x10(%ebp)
  80064d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800650:	50                   	push   %eax
  800651:	68 34 02 80 00       	push   $0x800234
  800656:	e8 13 fc ff ff       	call   80026e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80065b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80065e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	eb 05                	jmp    80066e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800669:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80066e:	c9                   	leave  
  80066f:	c3                   	ret    

00800670 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800676:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800679:	50                   	push   %eax
  80067a:	ff 75 10             	pushl  0x10(%ebp)
  80067d:	ff 75 0c             	pushl  0xc(%ebp)
  800680:	ff 75 08             	pushl  0x8(%ebp)
  800683:	e8 9a ff ff ff       	call   800622 <vsnprintf>
	va_end(ap);

	return rc;
}
  800688:	c9                   	leave  
  800689:	c3                   	ret    

0080068a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800690:	b8 00 00 00 00       	mov    $0x0,%eax
  800695:	eb 03                	jmp    80069a <strlen+0x10>
		n++;
  800697:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80069a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80069e:	75 f7                	jne    800697 <strlen+0xd>
		n++;
	return n;
}
  8006a0:	5d                   	pop    %ebp
  8006a1:	c3                   	ret    

008006a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
  8006a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b0:	eb 03                	jmp    8006b5 <strnlen+0x13>
		n++;
  8006b2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b5:	39 c2                	cmp    %eax,%edx
  8006b7:	74 08                	je     8006c1 <strnlen+0x1f>
  8006b9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006bd:	75 f3                	jne    8006b2 <strnlen+0x10>
  8006bf:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006c1:	5d                   	pop    %ebp
  8006c2:	c3                   	ret    

008006c3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	53                   	push   %ebx
  8006c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006cd:	89 c2                	mov    %eax,%edx
  8006cf:	83 c2 01             	add    $0x1,%edx
  8006d2:	83 c1 01             	add    $0x1,%ecx
  8006d5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006d9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006dc:	84 db                	test   %bl,%bl
  8006de:	75 ef                	jne    8006cf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006e0:	5b                   	pop    %ebx
  8006e1:	5d                   	pop    %ebp
  8006e2:	c3                   	ret    

008006e3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	53                   	push   %ebx
  8006e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006ea:	53                   	push   %ebx
  8006eb:	e8 9a ff ff ff       	call   80068a <strlen>
  8006f0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8006f3:	ff 75 0c             	pushl  0xc(%ebp)
  8006f6:	01 d8                	add    %ebx,%eax
  8006f8:	50                   	push   %eax
  8006f9:	e8 c5 ff ff ff       	call   8006c3 <strcpy>
	return dst;
}
  8006fe:	89 d8                	mov    %ebx,%eax
  800700:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800703:	c9                   	leave  
  800704:	c3                   	ret    

00800705 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	56                   	push   %esi
  800709:	53                   	push   %ebx
  80070a:	8b 75 08             	mov    0x8(%ebp),%esi
  80070d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800710:	89 f3                	mov    %esi,%ebx
  800712:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800715:	89 f2                	mov    %esi,%edx
  800717:	eb 0f                	jmp    800728 <strncpy+0x23>
		*dst++ = *src;
  800719:	83 c2 01             	add    $0x1,%edx
  80071c:	0f b6 01             	movzbl (%ecx),%eax
  80071f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800722:	80 39 01             	cmpb   $0x1,(%ecx)
  800725:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800728:	39 da                	cmp    %ebx,%edx
  80072a:	75 ed                	jne    800719 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80072c:	89 f0                	mov    %esi,%eax
  80072e:	5b                   	pop    %ebx
  80072f:	5e                   	pop    %esi
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	56                   	push   %esi
  800736:	53                   	push   %ebx
  800737:	8b 75 08             	mov    0x8(%ebp),%esi
  80073a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073d:	8b 55 10             	mov    0x10(%ebp),%edx
  800740:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800742:	85 d2                	test   %edx,%edx
  800744:	74 21                	je     800767 <strlcpy+0x35>
  800746:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80074a:	89 f2                	mov    %esi,%edx
  80074c:	eb 09                	jmp    800757 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80074e:	83 c2 01             	add    $0x1,%edx
  800751:	83 c1 01             	add    $0x1,%ecx
  800754:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800757:	39 c2                	cmp    %eax,%edx
  800759:	74 09                	je     800764 <strlcpy+0x32>
  80075b:	0f b6 19             	movzbl (%ecx),%ebx
  80075e:	84 db                	test   %bl,%bl
  800760:	75 ec                	jne    80074e <strlcpy+0x1c>
  800762:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800764:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800767:	29 f0                	sub    %esi,%eax
}
  800769:	5b                   	pop    %ebx
  80076a:	5e                   	pop    %esi
  80076b:	5d                   	pop    %ebp
  80076c:	c3                   	ret    

0080076d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800773:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800776:	eb 06                	jmp    80077e <strcmp+0x11>
		p++, q++;
  800778:	83 c1 01             	add    $0x1,%ecx
  80077b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80077e:	0f b6 01             	movzbl (%ecx),%eax
  800781:	84 c0                	test   %al,%al
  800783:	74 04                	je     800789 <strcmp+0x1c>
  800785:	3a 02                	cmp    (%edx),%al
  800787:	74 ef                	je     800778 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800789:	0f b6 c0             	movzbl %al,%eax
  80078c:	0f b6 12             	movzbl (%edx),%edx
  80078f:	29 d0                	sub    %edx,%eax
}
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 45 08             	mov    0x8(%ebp),%eax
  80079a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079d:	89 c3                	mov    %eax,%ebx
  80079f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007a2:	eb 06                	jmp    8007aa <strncmp+0x17>
		n--, p++, q++;
  8007a4:	83 c0 01             	add    $0x1,%eax
  8007a7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007aa:	39 d8                	cmp    %ebx,%eax
  8007ac:	74 15                	je     8007c3 <strncmp+0x30>
  8007ae:	0f b6 08             	movzbl (%eax),%ecx
  8007b1:	84 c9                	test   %cl,%cl
  8007b3:	74 04                	je     8007b9 <strncmp+0x26>
  8007b5:	3a 0a                	cmp    (%edx),%cl
  8007b7:	74 eb                	je     8007a4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b9:	0f b6 00             	movzbl (%eax),%eax
  8007bc:	0f b6 12             	movzbl (%edx),%edx
  8007bf:	29 d0                	sub    %edx,%eax
  8007c1:	eb 05                	jmp    8007c8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007d5:	eb 07                	jmp    8007de <strchr+0x13>
		if (*s == c)
  8007d7:	38 ca                	cmp    %cl,%dl
  8007d9:	74 0f                	je     8007ea <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007db:	83 c0 01             	add    $0x1,%eax
  8007de:	0f b6 10             	movzbl (%eax),%edx
  8007e1:	84 d2                	test   %dl,%dl
  8007e3:	75 f2                	jne    8007d7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f6:	eb 03                	jmp    8007fb <strfind+0xf>
  8007f8:	83 c0 01             	add    $0x1,%eax
  8007fb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007fe:	84 d2                	test   %dl,%dl
  800800:	74 04                	je     800806 <strfind+0x1a>
  800802:	38 ca                	cmp    %cl,%dl
  800804:	75 f2                	jne    8007f8 <strfind+0xc>
			break;
	return (char *) s;
}
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	57                   	push   %edi
  80080c:	56                   	push   %esi
  80080d:	53                   	push   %ebx
  80080e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800811:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800814:	85 c9                	test   %ecx,%ecx
  800816:	74 36                	je     80084e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800818:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80081e:	75 28                	jne    800848 <memset+0x40>
  800820:	f6 c1 03             	test   $0x3,%cl
  800823:	75 23                	jne    800848 <memset+0x40>
		c &= 0xFF;
  800825:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800829:	89 d3                	mov    %edx,%ebx
  80082b:	c1 e3 08             	shl    $0x8,%ebx
  80082e:	89 d6                	mov    %edx,%esi
  800830:	c1 e6 18             	shl    $0x18,%esi
  800833:	89 d0                	mov    %edx,%eax
  800835:	c1 e0 10             	shl    $0x10,%eax
  800838:	09 f0                	or     %esi,%eax
  80083a:	09 c2                	or     %eax,%edx
  80083c:	89 d0                	mov    %edx,%eax
  80083e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800840:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800843:	fc                   	cld    
  800844:	f3 ab                	rep stos %eax,%es:(%edi)
  800846:	eb 06                	jmp    80084e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084b:	fc                   	cld    
  80084c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80084e:	89 f8                	mov    %edi,%eax
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5f                   	pop    %edi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	57                   	push   %edi
  800859:	56                   	push   %esi
  80085a:	8b 45 08             	mov    0x8(%ebp),%eax
  80085d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800860:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800863:	39 c6                	cmp    %eax,%esi
  800865:	73 35                	jae    80089c <memmove+0x47>
  800867:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80086a:	39 d0                	cmp    %edx,%eax
  80086c:	73 2e                	jae    80089c <memmove+0x47>
		s += n;
		d += n;
  80086e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800871:	89 d6                	mov    %edx,%esi
  800873:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800875:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80087b:	75 13                	jne    800890 <memmove+0x3b>
  80087d:	f6 c1 03             	test   $0x3,%cl
  800880:	75 0e                	jne    800890 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800882:	83 ef 04             	sub    $0x4,%edi
  800885:	8d 72 fc             	lea    -0x4(%edx),%esi
  800888:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80088b:	fd                   	std    
  80088c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80088e:	eb 09                	jmp    800899 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800890:	83 ef 01             	sub    $0x1,%edi
  800893:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800896:	fd                   	std    
  800897:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800899:	fc                   	cld    
  80089a:	eb 1d                	jmp    8008b9 <memmove+0x64>
  80089c:	89 f2                	mov    %esi,%edx
  80089e:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a0:	f6 c2 03             	test   $0x3,%dl
  8008a3:	75 0f                	jne    8008b4 <memmove+0x5f>
  8008a5:	f6 c1 03             	test   $0x3,%cl
  8008a8:	75 0a                	jne    8008b4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008aa:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008ad:	89 c7                	mov    %eax,%edi
  8008af:	fc                   	cld    
  8008b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b2:	eb 05                	jmp    8008b9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008b4:	89 c7                	mov    %eax,%edi
  8008b6:	fc                   	cld    
  8008b7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008b9:	5e                   	pop    %esi
  8008ba:	5f                   	pop    %edi
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008c0:	ff 75 10             	pushl  0x10(%ebp)
  8008c3:	ff 75 0c             	pushl  0xc(%ebp)
  8008c6:	ff 75 08             	pushl  0x8(%ebp)
  8008c9:	e8 87 ff ff ff       	call   800855 <memmove>
}
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	56                   	push   %esi
  8008d4:	53                   	push   %ebx
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008db:	89 c6                	mov    %eax,%esi
  8008dd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008e0:	eb 1a                	jmp    8008fc <memcmp+0x2c>
		if (*s1 != *s2)
  8008e2:	0f b6 08             	movzbl (%eax),%ecx
  8008e5:	0f b6 1a             	movzbl (%edx),%ebx
  8008e8:	38 d9                	cmp    %bl,%cl
  8008ea:	74 0a                	je     8008f6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008ec:	0f b6 c1             	movzbl %cl,%eax
  8008ef:	0f b6 db             	movzbl %bl,%ebx
  8008f2:	29 d8                	sub    %ebx,%eax
  8008f4:	eb 0f                	jmp    800905 <memcmp+0x35>
		s1++, s2++;
  8008f6:	83 c0 01             	add    $0x1,%eax
  8008f9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008fc:	39 f0                	cmp    %esi,%eax
  8008fe:	75 e2                	jne    8008e2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800905:	5b                   	pop    %ebx
  800906:	5e                   	pop    %esi
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800912:	89 c2                	mov    %eax,%edx
  800914:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800917:	eb 07                	jmp    800920 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800919:	38 08                	cmp    %cl,(%eax)
  80091b:	74 07                	je     800924 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80091d:	83 c0 01             	add    $0x1,%eax
  800920:	39 d0                	cmp    %edx,%eax
  800922:	72 f5                	jb     800919 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	57                   	push   %edi
  80092a:	56                   	push   %esi
  80092b:	53                   	push   %ebx
  80092c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800932:	eb 03                	jmp    800937 <strtol+0x11>
		s++;
  800934:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800937:	0f b6 01             	movzbl (%ecx),%eax
  80093a:	3c 09                	cmp    $0x9,%al
  80093c:	74 f6                	je     800934 <strtol+0xe>
  80093e:	3c 20                	cmp    $0x20,%al
  800940:	74 f2                	je     800934 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800942:	3c 2b                	cmp    $0x2b,%al
  800944:	75 0a                	jne    800950 <strtol+0x2a>
		s++;
  800946:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800949:	bf 00 00 00 00       	mov    $0x0,%edi
  80094e:	eb 10                	jmp    800960 <strtol+0x3a>
  800950:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800955:	3c 2d                	cmp    $0x2d,%al
  800957:	75 07                	jne    800960 <strtol+0x3a>
		s++, neg = 1;
  800959:	8d 49 01             	lea    0x1(%ecx),%ecx
  80095c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800960:	85 db                	test   %ebx,%ebx
  800962:	0f 94 c0             	sete   %al
  800965:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80096b:	75 19                	jne    800986 <strtol+0x60>
  80096d:	80 39 30             	cmpb   $0x30,(%ecx)
  800970:	75 14                	jne    800986 <strtol+0x60>
  800972:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800976:	0f 85 82 00 00 00    	jne    8009fe <strtol+0xd8>
		s += 2, base = 16;
  80097c:	83 c1 02             	add    $0x2,%ecx
  80097f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800984:	eb 16                	jmp    80099c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800986:	84 c0                	test   %al,%al
  800988:	74 12                	je     80099c <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80098a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80098f:	80 39 30             	cmpb   $0x30,(%ecx)
  800992:	75 08                	jne    80099c <strtol+0x76>
		s++, base = 8;
  800994:	83 c1 01             	add    $0x1,%ecx
  800997:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009a4:	0f b6 11             	movzbl (%ecx),%edx
  8009a7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009aa:	89 f3                	mov    %esi,%ebx
  8009ac:	80 fb 09             	cmp    $0x9,%bl
  8009af:	77 08                	ja     8009b9 <strtol+0x93>
			dig = *s - '0';
  8009b1:	0f be d2             	movsbl %dl,%edx
  8009b4:	83 ea 30             	sub    $0x30,%edx
  8009b7:	eb 22                	jmp    8009db <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009b9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009bc:	89 f3                	mov    %esi,%ebx
  8009be:	80 fb 19             	cmp    $0x19,%bl
  8009c1:	77 08                	ja     8009cb <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009c3:	0f be d2             	movsbl %dl,%edx
  8009c6:	83 ea 57             	sub    $0x57,%edx
  8009c9:	eb 10                	jmp    8009db <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009cb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009ce:	89 f3                	mov    %esi,%ebx
  8009d0:	80 fb 19             	cmp    $0x19,%bl
  8009d3:	77 16                	ja     8009eb <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009d5:	0f be d2             	movsbl %dl,%edx
  8009d8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009db:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009de:	7d 0f                	jge    8009ef <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009e0:	83 c1 01             	add    $0x1,%ecx
  8009e3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009e7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009e9:	eb b9                	jmp    8009a4 <strtol+0x7e>
  8009eb:	89 c2                	mov    %eax,%edx
  8009ed:	eb 02                	jmp    8009f1 <strtol+0xcb>
  8009ef:	89 c2                	mov    %eax,%edx

	if (endptr)
  8009f1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009f5:	74 0d                	je     800a04 <strtol+0xde>
		*endptr = (char *) s;
  8009f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fa:	89 0e                	mov    %ecx,(%esi)
  8009fc:	eb 06                	jmp    800a04 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009fe:	84 c0                	test   %al,%al
  800a00:	75 92                	jne    800994 <strtol+0x6e>
  800a02:	eb 98                	jmp    80099c <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a04:	f7 da                	neg    %edx
  800a06:	85 ff                	test   %edi,%edi
  800a08:	0f 45 c2             	cmovne %edx,%eax
}
  800a0b:	5b                   	pop    %ebx
  800a0c:	5e                   	pop    %esi
  800a0d:	5f                   	pop    %edi
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a21:	89 c3                	mov    %eax,%ebx
  800a23:	89 c7                	mov    %eax,%edi
  800a25:	89 c6                	mov    %eax,%esi
  800a27:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a29:	5b                   	pop    %ebx
  800a2a:	5e                   	pop    %esi
  800a2b:	5f                   	pop    %edi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	57                   	push   %edi
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a34:	ba 00 00 00 00       	mov    $0x0,%edx
  800a39:	b8 01 00 00 00       	mov    $0x1,%eax
  800a3e:	89 d1                	mov    %edx,%ecx
  800a40:	89 d3                	mov    %edx,%ebx
  800a42:	89 d7                	mov    %edx,%edi
  800a44:	89 d6                	mov    %edx,%esi
  800a46:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5f                   	pop    %edi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	57                   	push   %edi
  800a51:	56                   	push   %esi
  800a52:	53                   	push   %ebx
  800a53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a5b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a60:	8b 55 08             	mov    0x8(%ebp),%edx
  800a63:	89 cb                	mov    %ecx,%ebx
  800a65:	89 cf                	mov    %ecx,%edi
  800a67:	89 ce                	mov    %ecx,%esi
  800a69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a6b:	85 c0                	test   %eax,%eax
  800a6d:	7e 17                	jle    800a86 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a6f:	83 ec 0c             	sub    $0xc,%esp
  800a72:	50                   	push   %eax
  800a73:	6a 03                	push   $0x3
  800a75:	68 00 10 80 00       	push   $0x801000
  800a7a:	6a 23                	push   $0x23
  800a7c:	68 1d 10 80 00       	push   $0x80101d
  800a81:	e8 27 00 00 00       	call   800aad <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	57                   	push   %edi
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a94:	ba 00 00 00 00       	mov    $0x0,%edx
  800a99:	b8 02 00 00 00       	mov    $0x2,%eax
  800a9e:	89 d1                	mov    %edx,%ecx
  800aa0:	89 d3                	mov    %edx,%ebx
  800aa2:	89 d7                	mov    %edx,%edi
  800aa4:	89 d6                	mov    %edx,%esi
  800aa6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ab2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ab5:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800abb:	e8 ce ff ff ff       	call   800a8e <sys_getenvid>
  800ac0:	83 ec 0c             	sub    $0xc,%esp
  800ac3:	ff 75 0c             	pushl  0xc(%ebp)
  800ac6:	ff 75 08             	pushl  0x8(%ebp)
  800ac9:	56                   	push   %esi
  800aca:	50                   	push   %eax
  800acb:	68 2c 10 80 00       	push   $0x80102c
  800ad0:	e8 67 f6 ff ff       	call   80013c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ad5:	83 c4 18             	add    $0x18,%esp
  800ad8:	53                   	push   %ebx
  800ad9:	ff 75 10             	pushl  0x10(%ebp)
  800adc:	e8 0a f6 ff ff       	call   8000eb <vcprintf>
	cprintf("\n");
  800ae1:	c7 04 24 50 10 80 00 	movl   $0x801050,(%esp)
  800ae8:	e8 4f f6 ff ff       	call   80013c <cprintf>
  800aed:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800af0:	cc                   	int3   
  800af1:	eb fd                	jmp    800af0 <_panic+0x43>
  800af3:	66 90                	xchg   %ax,%ax
  800af5:	66 90                	xchg   %ax,%ax
  800af7:	66 90                	xchg   %ax,%ax
  800af9:	66 90                	xchg   %ax,%ax
  800afb:	66 90                	xchg   %ax,%ax
  800afd:	66 90                	xchg   %ax,%ax
  800aff:	90                   	nop

00800b00 <__udivdi3>:
  800b00:	55                   	push   %ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	83 ec 10             	sub    $0x10,%esp
  800b06:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800b0a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800b0e:	8b 74 24 24          	mov    0x24(%esp),%esi
  800b12:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b16:	85 d2                	test   %edx,%edx
  800b18:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b1c:	89 34 24             	mov    %esi,(%esp)
  800b1f:	89 c8                	mov    %ecx,%eax
  800b21:	75 35                	jne    800b58 <__udivdi3+0x58>
  800b23:	39 f1                	cmp    %esi,%ecx
  800b25:	0f 87 bd 00 00 00    	ja     800be8 <__udivdi3+0xe8>
  800b2b:	85 c9                	test   %ecx,%ecx
  800b2d:	89 cd                	mov    %ecx,%ebp
  800b2f:	75 0b                	jne    800b3c <__udivdi3+0x3c>
  800b31:	b8 01 00 00 00       	mov    $0x1,%eax
  800b36:	31 d2                	xor    %edx,%edx
  800b38:	f7 f1                	div    %ecx
  800b3a:	89 c5                	mov    %eax,%ebp
  800b3c:	89 f0                	mov    %esi,%eax
  800b3e:	31 d2                	xor    %edx,%edx
  800b40:	f7 f5                	div    %ebp
  800b42:	89 c6                	mov    %eax,%esi
  800b44:	89 f8                	mov    %edi,%eax
  800b46:	f7 f5                	div    %ebp
  800b48:	89 f2                	mov    %esi,%edx
  800b4a:	83 c4 10             	add    $0x10,%esp
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    
  800b51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b58:	3b 14 24             	cmp    (%esp),%edx
  800b5b:	77 7b                	ja     800bd8 <__udivdi3+0xd8>
  800b5d:	0f bd f2             	bsr    %edx,%esi
  800b60:	83 f6 1f             	xor    $0x1f,%esi
  800b63:	0f 84 97 00 00 00    	je     800c00 <__udivdi3+0x100>
  800b69:	bd 20 00 00 00       	mov    $0x20,%ebp
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 f1                	mov    %esi,%ecx
  800b72:	29 f5                	sub    %esi,%ebp
  800b74:	d3 e7                	shl    %cl,%edi
  800b76:	89 c2                	mov    %eax,%edx
  800b78:	89 e9                	mov    %ebp,%ecx
  800b7a:	d3 ea                	shr    %cl,%edx
  800b7c:	89 f1                	mov    %esi,%ecx
  800b7e:	09 fa                	or     %edi,%edx
  800b80:	8b 3c 24             	mov    (%esp),%edi
  800b83:	d3 e0                	shl    %cl,%eax
  800b85:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b89:	89 e9                	mov    %ebp,%ecx
  800b8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b8f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800b93:	89 fa                	mov    %edi,%edx
  800b95:	d3 ea                	shr    %cl,%edx
  800b97:	89 f1                	mov    %esi,%ecx
  800b99:	d3 e7                	shl    %cl,%edi
  800b9b:	89 e9                	mov    %ebp,%ecx
  800b9d:	d3 e8                	shr    %cl,%eax
  800b9f:	09 c7                	or     %eax,%edi
  800ba1:	89 f8                	mov    %edi,%eax
  800ba3:	f7 74 24 08          	divl   0x8(%esp)
  800ba7:	89 d5                	mov    %edx,%ebp
  800ba9:	89 c7                	mov    %eax,%edi
  800bab:	f7 64 24 0c          	mull   0xc(%esp)
  800baf:	39 d5                	cmp    %edx,%ebp
  800bb1:	89 14 24             	mov    %edx,(%esp)
  800bb4:	72 11                	jb     800bc7 <__udivdi3+0xc7>
  800bb6:	8b 54 24 04          	mov    0x4(%esp),%edx
  800bba:	89 f1                	mov    %esi,%ecx
  800bbc:	d3 e2                	shl    %cl,%edx
  800bbe:	39 c2                	cmp    %eax,%edx
  800bc0:	73 5e                	jae    800c20 <__udivdi3+0x120>
  800bc2:	3b 2c 24             	cmp    (%esp),%ebp
  800bc5:	75 59                	jne    800c20 <__udivdi3+0x120>
  800bc7:	8d 47 ff             	lea    -0x1(%edi),%eax
  800bca:	31 f6                	xor    %esi,%esi
  800bcc:	89 f2                	mov    %esi,%edx
  800bce:	83 c4 10             	add    $0x10,%esp
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    
  800bd5:	8d 76 00             	lea    0x0(%esi),%esi
  800bd8:	31 f6                	xor    %esi,%esi
  800bda:	31 c0                	xor    %eax,%eax
  800bdc:	89 f2                	mov    %esi,%edx
  800bde:	83 c4 10             	add    $0x10,%esp
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    
  800be5:	8d 76 00             	lea    0x0(%esi),%esi
  800be8:	89 f2                	mov    %esi,%edx
  800bea:	31 f6                	xor    %esi,%esi
  800bec:	89 f8                	mov    %edi,%eax
  800bee:	f7 f1                	div    %ecx
  800bf0:	89 f2                	mov    %esi,%edx
  800bf2:	83 c4 10             	add    $0x10,%esp
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    
  800bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c00:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800c04:	76 0b                	jbe    800c11 <__udivdi3+0x111>
  800c06:	31 c0                	xor    %eax,%eax
  800c08:	3b 14 24             	cmp    (%esp),%edx
  800c0b:	0f 83 37 ff ff ff    	jae    800b48 <__udivdi3+0x48>
  800c11:	b8 01 00 00 00       	mov    $0x1,%eax
  800c16:	e9 2d ff ff ff       	jmp    800b48 <__udivdi3+0x48>
  800c1b:	90                   	nop
  800c1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c20:	89 f8                	mov    %edi,%eax
  800c22:	31 f6                	xor    %esi,%esi
  800c24:	e9 1f ff ff ff       	jmp    800b48 <__udivdi3+0x48>
  800c29:	66 90                	xchg   %ax,%ax
  800c2b:	66 90                	xchg   %ax,%ax
  800c2d:	66 90                	xchg   %ax,%ax
  800c2f:	90                   	nop

00800c30 <__umoddi3>:
  800c30:	55                   	push   %ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	83 ec 20             	sub    $0x20,%esp
  800c36:	8b 44 24 34          	mov    0x34(%esp),%eax
  800c3a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c3e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c42:	89 c6                	mov    %eax,%esi
  800c44:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c48:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c4c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800c50:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c54:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800c58:	89 74 24 18          	mov    %esi,0x18(%esp)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	89 c2                	mov    %eax,%edx
  800c60:	75 1e                	jne    800c80 <__umoddi3+0x50>
  800c62:	39 f7                	cmp    %esi,%edi
  800c64:	76 52                	jbe    800cb8 <__umoddi3+0x88>
  800c66:	89 c8                	mov    %ecx,%eax
  800c68:	89 f2                	mov    %esi,%edx
  800c6a:	f7 f7                	div    %edi
  800c6c:	89 d0                	mov    %edx,%eax
  800c6e:	31 d2                	xor    %edx,%edx
  800c70:	83 c4 20             	add    $0x20,%esp
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    
  800c77:	89 f6                	mov    %esi,%esi
  800c79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800c80:	39 f0                	cmp    %esi,%eax
  800c82:	77 5c                	ja     800ce0 <__umoddi3+0xb0>
  800c84:	0f bd e8             	bsr    %eax,%ebp
  800c87:	83 f5 1f             	xor    $0x1f,%ebp
  800c8a:	75 64                	jne    800cf0 <__umoddi3+0xc0>
  800c8c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800c90:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800c94:	0f 86 f6 00 00 00    	jbe    800d90 <__umoddi3+0x160>
  800c9a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800c9e:	0f 82 ec 00 00 00    	jb     800d90 <__umoddi3+0x160>
  800ca4:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ca8:	8b 54 24 18          	mov    0x18(%esp),%edx
  800cac:	83 c4 20             	add    $0x20,%esp
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    
  800cb3:	90                   	nop
  800cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb8:	85 ff                	test   %edi,%edi
  800cba:	89 fd                	mov    %edi,%ebp
  800cbc:	75 0b                	jne    800cc9 <__umoddi3+0x99>
  800cbe:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc3:	31 d2                	xor    %edx,%edx
  800cc5:	f7 f7                	div    %edi
  800cc7:	89 c5                	mov    %eax,%ebp
  800cc9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800ccd:	31 d2                	xor    %edx,%edx
  800ccf:	f7 f5                	div    %ebp
  800cd1:	89 c8                	mov    %ecx,%eax
  800cd3:	f7 f5                	div    %ebp
  800cd5:	eb 95                	jmp    800c6c <__umoddi3+0x3c>
  800cd7:	89 f6                	mov    %esi,%esi
  800cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ce0:	89 c8                	mov    %ecx,%eax
  800ce2:	89 f2                	mov    %esi,%edx
  800ce4:	83 c4 20             	add    $0x20,%esp
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    
  800ceb:	90                   	nop
  800cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	b8 20 00 00 00       	mov    $0x20,%eax
  800cf5:	89 e9                	mov    %ebp,%ecx
  800cf7:	29 e8                	sub    %ebp,%eax
  800cf9:	d3 e2                	shl    %cl,%edx
  800cfb:	89 c7                	mov    %eax,%edi
  800cfd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800d01:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d05:	89 f9                	mov    %edi,%ecx
  800d07:	d3 e8                	shr    %cl,%eax
  800d09:	89 c1                	mov    %eax,%ecx
  800d0b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d0f:	09 d1                	or     %edx,%ecx
  800d11:	89 fa                	mov    %edi,%edx
  800d13:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d17:	89 e9                	mov    %ebp,%ecx
  800d19:	d3 e0                	shl    %cl,%eax
  800d1b:	89 f9                	mov    %edi,%ecx
  800d1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d21:	89 f0                	mov    %esi,%eax
  800d23:	d3 e8                	shr    %cl,%eax
  800d25:	89 e9                	mov    %ebp,%ecx
  800d27:	89 c7                	mov    %eax,%edi
  800d29:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d2d:	d3 e6                	shl    %cl,%esi
  800d2f:	89 d1                	mov    %edx,%ecx
  800d31:	89 fa                	mov    %edi,%edx
  800d33:	d3 e8                	shr    %cl,%eax
  800d35:	89 e9                	mov    %ebp,%ecx
  800d37:	09 f0                	or     %esi,%eax
  800d39:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800d3d:	f7 74 24 10          	divl   0x10(%esp)
  800d41:	d3 e6                	shl    %cl,%esi
  800d43:	89 d1                	mov    %edx,%ecx
  800d45:	f7 64 24 0c          	mull   0xc(%esp)
  800d49:	39 d1                	cmp    %edx,%ecx
  800d4b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800d4f:	89 d7                	mov    %edx,%edi
  800d51:	89 c6                	mov    %eax,%esi
  800d53:	72 0a                	jb     800d5f <__umoddi3+0x12f>
  800d55:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800d59:	73 10                	jae    800d6b <__umoddi3+0x13b>
  800d5b:	39 d1                	cmp    %edx,%ecx
  800d5d:	75 0c                	jne    800d6b <__umoddi3+0x13b>
  800d5f:	89 d7                	mov    %edx,%edi
  800d61:	89 c6                	mov    %eax,%esi
  800d63:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800d67:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800d6b:	89 ca                	mov    %ecx,%edx
  800d6d:	89 e9                	mov    %ebp,%ecx
  800d6f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d73:	29 f0                	sub    %esi,%eax
  800d75:	19 fa                	sbb    %edi,%edx
  800d77:	d3 e8                	shr    %cl,%eax
  800d79:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800d7e:	89 d7                	mov    %edx,%edi
  800d80:	d3 e7                	shl    %cl,%edi
  800d82:	89 e9                	mov    %ebp,%ecx
  800d84:	09 f8                	or     %edi,%eax
  800d86:	d3 ea                	shr    %cl,%edx
  800d88:	83 c4 20             	add    $0x20,%esp
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    
  800d8f:	90                   	nop
  800d90:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d94:	29 f9                	sub    %edi,%ecx
  800d96:	19 c6                	sbb    %eax,%esi
  800d98:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800d9c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800da0:	e9 ff fe ff ff       	jmp    800ca4 <__umoddi3+0x74>
