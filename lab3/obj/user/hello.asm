
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
  800039:	68 c0 0d 80 00       	push   $0x800dc0
  80003e:	e8 09 01 00 00       	call   80014c <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ce 0d 80 00       	push   $0x800dce
  800054:	e8 f3 00 00 00       	call   80014c <cprintf>
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
  800069:	e8 30 0a 00 00       	call   800a9e <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800076:	c1 e0 05             	shl    $0x5,%eax
  800079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800083:	85 db                	test   %ebx,%ebx
  800085:	7e 07                	jle    80008e <libmain+0x30>
		binaryname = argv[0];
  800087:	8b 06                	mov    (%esi),%eax
  800089:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008e:	83 ec 08             	sub    $0x8,%esp
  800091:	56                   	push   %esi
  800092:	53                   	push   %ebx
  800093:	e8 9b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800098:	e8 0a 00 00 00       	call   8000a7 <exit>
  80009d:	83 c4 10             	add    $0x10,%esp
}
  8000a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a3:	5b                   	pop    %ebx
  8000a4:	5e                   	pop    %esi
  8000a5:	5d                   	pop    %ebp
  8000a6:	c3                   	ret    

008000a7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ad:	6a 00                	push   $0x0
  8000af:	e8 a9 09 00 00       	call   800a5d <sys_env_destroy>
  8000b4:	83 c4 10             	add    $0x10,%esp
}
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	53                   	push   %ebx
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c3:	8b 13                	mov    (%ebx),%edx
  8000c5:	8d 42 01             	lea    0x1(%edx),%eax
  8000c8:	89 03                	mov    %eax,(%ebx)
  8000ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d6:	75 1a                	jne    8000f2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d8:	83 ec 08             	sub    $0x8,%esp
  8000db:	68 ff 00 00 00       	push   $0xff
  8000e0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e3:	50                   	push   %eax
  8000e4:	e8 37 09 00 00       	call   800a20 <sys_cputs>
		b->idx = 0;
  8000e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ef:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f9:	c9                   	leave  
  8000fa:	c3                   	ret    

008000fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800104:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010b:	00 00 00 
	b.cnt = 0;
  80010e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800115:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800118:	ff 75 0c             	pushl  0xc(%ebp)
  80011b:	ff 75 08             	pushl  0x8(%ebp)
  80011e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800124:	50                   	push   %eax
  800125:	68 b9 00 80 00       	push   $0x8000b9
  80012a:	e8 4f 01 00 00       	call   80027e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012f:	83 c4 08             	add    $0x8,%esp
  800132:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800138:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013e:	50                   	push   %eax
  80013f:	e8 dc 08 00 00       	call   800a20 <sys_cputs>

	return b.cnt;
}
  800144:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800152:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800155:	50                   	push   %eax
  800156:	ff 75 08             	pushl  0x8(%ebp)
  800159:	e8 9d ff ff ff       	call   8000fb <vcprintf>
	va_end(ap);

	return cnt;
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 1c             	sub    $0x1c,%esp
  800169:	89 c7                	mov    %eax,%edi
  80016b:	89 d6                	mov    %edx,%esi
  80016d:	8b 45 08             	mov    0x8(%ebp),%eax
  800170:	8b 55 0c             	mov    0xc(%ebp),%edx
  800173:	89 d1                	mov    %edx,%ecx
  800175:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800178:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80017b:	8b 45 10             	mov    0x10(%ebp),%eax
  80017e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800181:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800184:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80018b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80018e:	72 05                	jb     800195 <printnum+0x35>
  800190:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800193:	77 3e                	ja     8001d3 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 18             	pushl  0x18(%ebp)
  80019b:	83 eb 01             	sub    $0x1,%ebx
  80019e:	53                   	push   %ebx
  80019f:	50                   	push   %eax
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ac:	ff 75 d8             	pushl  -0x28(%ebp)
  8001af:	e8 5c 09 00 00       	call   800b10 <__udivdi3>
  8001b4:	83 c4 18             	add    $0x18,%esp
  8001b7:	52                   	push   %edx
  8001b8:	50                   	push   %eax
  8001b9:	89 f2                	mov    %esi,%edx
  8001bb:	89 f8                	mov    %edi,%eax
  8001bd:	e8 9e ff ff ff       	call   800160 <printnum>
  8001c2:	83 c4 20             	add    $0x20,%esp
  8001c5:	eb 13                	jmp    8001da <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	56                   	push   %esi
  8001cb:	ff 75 18             	pushl  0x18(%ebp)
  8001ce:	ff d7                	call   *%edi
  8001d0:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d3:	83 eb 01             	sub    $0x1,%ebx
  8001d6:	85 db                	test   %ebx,%ebx
  8001d8:	7f ed                	jg     8001c7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001da:	83 ec 08             	sub    $0x8,%esp
  8001dd:	56                   	push   %esi
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ea:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ed:	e8 4e 0a 00 00       	call   800c40 <__umoddi3>
  8001f2:	83 c4 14             	add    $0x14,%esp
  8001f5:	0f be 80 ef 0d 80 00 	movsbl 0x800def(%eax),%eax
  8001fc:	50                   	push   %eax
  8001fd:	ff d7                	call   *%edi
  8001ff:	83 c4 10             	add    $0x10,%esp
}
  800202:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	5f                   	pop    %edi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    

0080020a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80020d:	83 fa 01             	cmp    $0x1,%edx
  800210:	7e 0e                	jle    800220 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800212:	8b 10                	mov    (%eax),%edx
  800214:	8d 4a 08             	lea    0x8(%edx),%ecx
  800217:	89 08                	mov    %ecx,(%eax)
  800219:	8b 02                	mov    (%edx),%eax
  80021b:	8b 52 04             	mov    0x4(%edx),%edx
  80021e:	eb 22                	jmp    800242 <getuint+0x38>
	else if (lflag)
  800220:	85 d2                	test   %edx,%edx
  800222:	74 10                	je     800234 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800224:	8b 10                	mov    (%eax),%edx
  800226:	8d 4a 04             	lea    0x4(%edx),%ecx
  800229:	89 08                	mov    %ecx,(%eax)
  80022b:	8b 02                	mov    (%edx),%eax
  80022d:	ba 00 00 00 00       	mov    $0x0,%edx
  800232:	eb 0e                	jmp    800242 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800234:	8b 10                	mov    (%eax),%edx
  800236:	8d 4a 04             	lea    0x4(%edx),%ecx
  800239:	89 08                	mov    %ecx,(%eax)
  80023b:	8b 02                	mov    (%edx),%eax
  80023d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    

00800244 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80024e:	8b 10                	mov    (%eax),%edx
  800250:	3b 50 04             	cmp    0x4(%eax),%edx
  800253:	73 0a                	jae    80025f <sprintputch+0x1b>
		*b->buf++ = ch;
  800255:	8d 4a 01             	lea    0x1(%edx),%ecx
  800258:	89 08                	mov    %ecx,(%eax)
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	88 02                	mov    %al,(%edx)
}
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800267:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026a:	50                   	push   %eax
  80026b:	ff 75 10             	pushl  0x10(%ebp)
  80026e:	ff 75 0c             	pushl  0xc(%ebp)
  800271:	ff 75 08             	pushl  0x8(%ebp)
  800274:	e8 05 00 00 00       	call   80027e <vprintfmt>
	va_end(ap);
  800279:	83 c4 10             	add    $0x10,%esp
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    

0080027e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	57                   	push   %edi
  800282:	56                   	push   %esi
  800283:	53                   	push   %ebx
  800284:	83 ec 2c             	sub    $0x2c,%esp
  800287:	8b 75 08             	mov    0x8(%ebp),%esi
  80028a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80028d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800290:	eb 12                	jmp    8002a4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800292:	85 c0                	test   %eax,%eax
  800294:	0f 84 90 03 00 00    	je     80062a <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	53                   	push   %ebx
  80029e:	50                   	push   %eax
  80029f:	ff d6                	call   *%esi
  8002a1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a4:	83 c7 01             	add    $0x1,%edi
  8002a7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ab:	83 f8 25             	cmp    $0x25,%eax
  8002ae:	75 e2                	jne    800292 <vprintfmt+0x14>
  8002b0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002bb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002c2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ce:	eb 07                	jmp    8002d7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d7:	8d 47 01             	lea    0x1(%edi),%eax
  8002da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dd:	0f b6 07             	movzbl (%edi),%eax
  8002e0:	0f b6 c8             	movzbl %al,%ecx
  8002e3:	83 e8 23             	sub    $0x23,%eax
  8002e6:	3c 55                	cmp    $0x55,%al
  8002e8:	0f 87 21 03 00 00    	ja     80060f <vprintfmt+0x391>
  8002ee:	0f b6 c0             	movzbl %al,%eax
  8002f1:	ff 24 85 80 0e 80 00 	jmp    *0x800e80(,%eax,4)
  8002f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002fb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002ff:	eb d6                	jmp    8002d7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800301:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80030c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80030f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800313:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800316:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800319:	83 fa 09             	cmp    $0x9,%edx
  80031c:	77 39                	ja     800357 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80031e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800321:	eb e9                	jmp    80030c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800323:	8b 45 14             	mov    0x14(%ebp),%eax
  800326:	8d 48 04             	lea    0x4(%eax),%ecx
  800329:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80032c:	8b 00                	mov    (%eax),%eax
  80032e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800334:	eb 27                	jmp    80035d <vprintfmt+0xdf>
  800336:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800339:	85 c0                	test   %eax,%eax
  80033b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800340:	0f 49 c8             	cmovns %eax,%ecx
  800343:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800349:	eb 8c                	jmp    8002d7 <vprintfmt+0x59>
  80034b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80034e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800355:	eb 80                	jmp    8002d7 <vprintfmt+0x59>
  800357:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80035a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80035d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800361:	0f 89 70 ff ff ff    	jns    8002d7 <vprintfmt+0x59>
				width = precision, precision = -1;
  800367:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80036a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800374:	e9 5e ff ff ff       	jmp    8002d7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800379:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80037f:	e9 53 ff ff ff       	jmp    8002d7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8d 50 04             	lea    0x4(%eax),%edx
  80038a:	89 55 14             	mov    %edx,0x14(%ebp)
  80038d:	83 ec 08             	sub    $0x8,%esp
  800390:	53                   	push   %ebx
  800391:	ff 30                	pushl  (%eax)
  800393:	ff d6                	call   *%esi
			break;
  800395:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039b:	e9 04 ff ff ff       	jmp    8002a4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8d 50 04             	lea    0x4(%eax),%edx
  8003a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a9:	8b 00                	mov    (%eax),%eax
  8003ab:	99                   	cltd   
  8003ac:	31 d0                	xor    %edx,%eax
  8003ae:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b0:	83 f8 07             	cmp    $0x7,%eax
  8003b3:	7f 0b                	jg     8003c0 <vprintfmt+0x142>
  8003b5:	8b 14 85 e0 0f 80 00 	mov    0x800fe0(,%eax,4),%edx
  8003bc:	85 d2                	test   %edx,%edx
  8003be:	75 18                	jne    8003d8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003c0:	50                   	push   %eax
  8003c1:	68 07 0e 80 00       	push   $0x800e07
  8003c6:	53                   	push   %ebx
  8003c7:	56                   	push   %esi
  8003c8:	e8 94 fe ff ff       	call   800261 <printfmt>
  8003cd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d3:	e9 cc fe ff ff       	jmp    8002a4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d8:	52                   	push   %edx
  8003d9:	68 10 0e 80 00       	push   $0x800e10
  8003de:	53                   	push   %ebx
  8003df:	56                   	push   %esi
  8003e0:	e8 7c fe ff ff       	call   800261 <printfmt>
  8003e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003eb:	e9 b4 fe ff ff       	jmp    8002a4 <vprintfmt+0x26>
  8003f0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f6:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 50 04             	lea    0x4(%eax),%edx
  8003ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800402:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800404:	85 ff                	test   %edi,%edi
  800406:	ba 00 0e 80 00       	mov    $0x800e00,%edx
  80040b:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80040e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800412:	0f 84 92 00 00 00    	je     8004aa <vprintfmt+0x22c>
  800418:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80041c:	0f 8e 96 00 00 00    	jle    8004b8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800422:	83 ec 08             	sub    $0x8,%esp
  800425:	51                   	push   %ecx
  800426:	57                   	push   %edi
  800427:	e8 86 02 00 00       	call   8006b2 <strnlen>
  80042c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80042f:	29 c1                	sub    %eax,%ecx
  800431:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800434:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800437:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80043b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800441:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800443:	eb 0f                	jmp    800454 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	53                   	push   %ebx
  800449:	ff 75 e0             	pushl  -0x20(%ebp)
  80044c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044e:	83 ef 01             	sub    $0x1,%edi
  800451:	83 c4 10             	add    $0x10,%esp
  800454:	85 ff                	test   %edi,%edi
  800456:	7f ed                	jg     800445 <vprintfmt+0x1c7>
  800458:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80045b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80045e:	85 c9                	test   %ecx,%ecx
  800460:	b8 00 00 00 00       	mov    $0x0,%eax
  800465:	0f 49 c1             	cmovns %ecx,%eax
  800468:	29 c1                	sub    %eax,%ecx
  80046a:	89 75 08             	mov    %esi,0x8(%ebp)
  80046d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800470:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800473:	89 cb                	mov    %ecx,%ebx
  800475:	eb 4d                	jmp    8004c4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800477:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047b:	74 1b                	je     800498 <vprintfmt+0x21a>
  80047d:	0f be c0             	movsbl %al,%eax
  800480:	83 e8 20             	sub    $0x20,%eax
  800483:	83 f8 5e             	cmp    $0x5e,%eax
  800486:	76 10                	jbe    800498 <vprintfmt+0x21a>
					putch('?', putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	ff 75 0c             	pushl  0xc(%ebp)
  80048e:	6a 3f                	push   $0x3f
  800490:	ff 55 08             	call   *0x8(%ebp)
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	eb 0d                	jmp    8004a5 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	ff 75 0c             	pushl  0xc(%ebp)
  80049e:	52                   	push   %edx
  80049f:	ff 55 08             	call   *0x8(%ebp)
  8004a2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a5:	83 eb 01             	sub    $0x1,%ebx
  8004a8:	eb 1a                	jmp    8004c4 <vprintfmt+0x246>
  8004aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b6:	eb 0c                	jmp    8004c4 <vprintfmt+0x246>
  8004b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c4:	83 c7 01             	add    $0x1,%edi
  8004c7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004cb:	0f be d0             	movsbl %al,%edx
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	74 23                	je     8004f5 <vprintfmt+0x277>
  8004d2:	85 f6                	test   %esi,%esi
  8004d4:	78 a1                	js     800477 <vprintfmt+0x1f9>
  8004d6:	83 ee 01             	sub    $0x1,%esi
  8004d9:	79 9c                	jns    800477 <vprintfmt+0x1f9>
  8004db:	89 df                	mov    %ebx,%edi
  8004dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e3:	eb 18                	jmp    8004fd <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	53                   	push   %ebx
  8004e9:	6a 20                	push   $0x20
  8004eb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ed:	83 ef 01             	sub    $0x1,%edi
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	eb 08                	jmp    8004fd <vprintfmt+0x27f>
  8004f5:	89 df                	mov    %ebx,%edi
  8004f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fd:	85 ff                	test   %edi,%edi
  8004ff:	7f e4                	jg     8004e5 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800504:	e9 9b fd ff ff       	jmp    8002a4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800509:	83 fa 01             	cmp    $0x1,%edx
  80050c:	7e 16                	jle    800524 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	8d 50 08             	lea    0x8(%eax),%edx
  800514:	89 55 14             	mov    %edx,0x14(%ebp)
  800517:	8b 50 04             	mov    0x4(%eax),%edx
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800522:	eb 32                	jmp    800556 <vprintfmt+0x2d8>
	else if (lflag)
  800524:	85 d2                	test   %edx,%edx
  800526:	74 18                	je     800540 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	8b 00                	mov    (%eax),%eax
  800533:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800536:	89 c1                	mov    %eax,%ecx
  800538:	c1 f9 1f             	sar    $0x1f,%ecx
  80053b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80053e:	eb 16                	jmp    800556 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054e:	89 c1                	mov    %eax,%ecx
  800550:	c1 f9 1f             	sar    $0x1f,%ecx
  800553:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800556:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800559:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800561:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800565:	79 74                	jns    8005db <vprintfmt+0x35d>
				putch('-', putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	53                   	push   %ebx
  80056b:	6a 2d                	push   $0x2d
  80056d:	ff d6                	call   *%esi
				num = -(long long) num;
  80056f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800572:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800575:	f7 d8                	neg    %eax
  800577:	83 d2 00             	adc    $0x0,%edx
  80057a:	f7 da                	neg    %edx
  80057c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80057f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800584:	eb 55                	jmp    8005db <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800586:	8d 45 14             	lea    0x14(%ebp),%eax
  800589:	e8 7c fc ff ff       	call   80020a <getuint>
			base = 10;
  80058e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800593:	eb 46                	jmp    8005db <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800595:	8d 45 14             	lea    0x14(%ebp),%eax
  800598:	e8 6d fc ff ff       	call   80020a <getuint>
                        base = 8;
  80059d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005a2:	eb 37                	jmp    8005db <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	53                   	push   %ebx
  8005a8:	6a 30                	push   $0x30
  8005aa:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ac:	83 c4 08             	add    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 78                	push   $0x78
  8005b2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005cc:	eb 0d                	jmp    8005db <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 34 fc ff ff       	call   80020a <getuint>
			base = 16;
  8005d6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005db:	83 ec 0c             	sub    $0xc,%esp
  8005de:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005e2:	57                   	push   %edi
  8005e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e6:	51                   	push   %ecx
  8005e7:	52                   	push   %edx
  8005e8:	50                   	push   %eax
  8005e9:	89 da                	mov    %ebx,%edx
  8005eb:	89 f0                	mov    %esi,%eax
  8005ed:	e8 6e fb ff ff       	call   800160 <printnum>
			break;
  8005f2:	83 c4 20             	add    $0x20,%esp
  8005f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f8:	e9 a7 fc ff ff       	jmp    8002a4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	51                   	push   %ecx
  800602:	ff d6                	call   *%esi
			break;
  800604:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800607:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80060a:	e9 95 fc ff ff       	jmp    8002a4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 25                	push   $0x25
  800615:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800617:	83 c4 10             	add    $0x10,%esp
  80061a:	eb 03                	jmp    80061f <vprintfmt+0x3a1>
  80061c:	83 ef 01             	sub    $0x1,%edi
  80061f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800623:	75 f7                	jne    80061c <vprintfmt+0x39e>
  800625:	e9 7a fc ff ff       	jmp    8002a4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80062a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062d:	5b                   	pop    %ebx
  80062e:	5e                   	pop    %esi
  80062f:	5f                   	pop    %edi
  800630:	5d                   	pop    %ebp
  800631:	c3                   	ret    

00800632 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
  800635:	83 ec 18             	sub    $0x18,%esp
  800638:	8b 45 08             	mov    0x8(%ebp),%eax
  80063b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80063e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800641:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800645:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800648:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80064f:	85 c0                	test   %eax,%eax
  800651:	74 26                	je     800679 <vsnprintf+0x47>
  800653:	85 d2                	test   %edx,%edx
  800655:	7e 22                	jle    800679 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800657:	ff 75 14             	pushl  0x14(%ebp)
  80065a:	ff 75 10             	pushl  0x10(%ebp)
  80065d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800660:	50                   	push   %eax
  800661:	68 44 02 80 00       	push   $0x800244
  800666:	e8 13 fc ff ff       	call   80027e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80066b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80066e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800671:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	eb 05                	jmp    80067e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800679:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80067e:	c9                   	leave  
  80067f:	c3                   	ret    

00800680 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
  800683:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800689:	50                   	push   %eax
  80068a:	ff 75 10             	pushl  0x10(%ebp)
  80068d:	ff 75 0c             	pushl  0xc(%ebp)
  800690:	ff 75 08             	pushl  0x8(%ebp)
  800693:	e8 9a ff ff ff       	call   800632 <vsnprintf>
	va_end(ap);

	return rc;
}
  800698:	c9                   	leave  
  800699:	c3                   	ret    

0080069a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a5:	eb 03                	jmp    8006aa <strlen+0x10>
		n++;
  8006a7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ae:	75 f7                	jne    8006a7 <strlen+0xd>
		n++;
	return n;
}
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c0:	eb 03                	jmp    8006c5 <strnlen+0x13>
		n++;
  8006c2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c5:	39 c2                	cmp    %eax,%edx
  8006c7:	74 08                	je     8006d1 <strnlen+0x1f>
  8006c9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006cd:	75 f3                	jne    8006c2 <strnlen+0x10>
  8006cf:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006d1:	5d                   	pop    %ebp
  8006d2:	c3                   	ret    

008006d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	53                   	push   %ebx
  8006d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006dd:	89 c2                	mov    %eax,%edx
  8006df:	83 c2 01             	add    $0x1,%edx
  8006e2:	83 c1 01             	add    $0x1,%ecx
  8006e5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006e9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006ec:	84 db                	test   %bl,%bl
  8006ee:	75 ef                	jne    8006df <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006f0:	5b                   	pop    %ebx
  8006f1:	5d                   	pop    %ebp
  8006f2:	c3                   	ret    

008006f3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	53                   	push   %ebx
  8006f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006fa:	53                   	push   %ebx
  8006fb:	e8 9a ff ff ff       	call   80069a <strlen>
  800700:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800703:	ff 75 0c             	pushl  0xc(%ebp)
  800706:	01 d8                	add    %ebx,%eax
  800708:	50                   	push   %eax
  800709:	e8 c5 ff ff ff       	call   8006d3 <strcpy>
	return dst;
}
  80070e:	89 d8                	mov    %ebx,%eax
  800710:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800713:	c9                   	leave  
  800714:	c3                   	ret    

00800715 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	56                   	push   %esi
  800719:	53                   	push   %ebx
  80071a:	8b 75 08             	mov    0x8(%ebp),%esi
  80071d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800720:	89 f3                	mov    %esi,%ebx
  800722:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800725:	89 f2                	mov    %esi,%edx
  800727:	eb 0f                	jmp    800738 <strncpy+0x23>
		*dst++ = *src;
  800729:	83 c2 01             	add    $0x1,%edx
  80072c:	0f b6 01             	movzbl (%ecx),%eax
  80072f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800732:	80 39 01             	cmpb   $0x1,(%ecx)
  800735:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800738:	39 da                	cmp    %ebx,%edx
  80073a:	75 ed                	jne    800729 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80073c:	89 f0                	mov    %esi,%eax
  80073e:	5b                   	pop    %ebx
  80073f:	5e                   	pop    %esi
  800740:	5d                   	pop    %ebp
  800741:	c3                   	ret    

00800742 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	56                   	push   %esi
  800746:	53                   	push   %ebx
  800747:	8b 75 08             	mov    0x8(%ebp),%esi
  80074a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074d:	8b 55 10             	mov    0x10(%ebp),%edx
  800750:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800752:	85 d2                	test   %edx,%edx
  800754:	74 21                	je     800777 <strlcpy+0x35>
  800756:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80075a:	89 f2                	mov    %esi,%edx
  80075c:	eb 09                	jmp    800767 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80075e:	83 c2 01             	add    $0x1,%edx
  800761:	83 c1 01             	add    $0x1,%ecx
  800764:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800767:	39 c2                	cmp    %eax,%edx
  800769:	74 09                	je     800774 <strlcpy+0x32>
  80076b:	0f b6 19             	movzbl (%ecx),%ebx
  80076e:	84 db                	test   %bl,%bl
  800770:	75 ec                	jne    80075e <strlcpy+0x1c>
  800772:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800774:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800777:	29 f0                	sub    %esi,%eax
}
  800779:	5b                   	pop    %ebx
  80077a:	5e                   	pop    %esi
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800783:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800786:	eb 06                	jmp    80078e <strcmp+0x11>
		p++, q++;
  800788:	83 c1 01             	add    $0x1,%ecx
  80078b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80078e:	0f b6 01             	movzbl (%ecx),%eax
  800791:	84 c0                	test   %al,%al
  800793:	74 04                	je     800799 <strcmp+0x1c>
  800795:	3a 02                	cmp    (%edx),%al
  800797:	74 ef                	je     800788 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800799:	0f b6 c0             	movzbl %al,%eax
  80079c:	0f b6 12             	movzbl (%edx),%edx
  80079f:	29 d0                	sub    %edx,%eax
}
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	53                   	push   %ebx
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ad:	89 c3                	mov    %eax,%ebx
  8007af:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b2:	eb 06                	jmp    8007ba <strncmp+0x17>
		n--, p++, q++;
  8007b4:	83 c0 01             	add    $0x1,%eax
  8007b7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ba:	39 d8                	cmp    %ebx,%eax
  8007bc:	74 15                	je     8007d3 <strncmp+0x30>
  8007be:	0f b6 08             	movzbl (%eax),%ecx
  8007c1:	84 c9                	test   %cl,%cl
  8007c3:	74 04                	je     8007c9 <strncmp+0x26>
  8007c5:	3a 0a                	cmp    (%edx),%cl
  8007c7:	74 eb                	je     8007b4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c9:	0f b6 00             	movzbl (%eax),%eax
  8007cc:	0f b6 12             	movzbl (%edx),%edx
  8007cf:	29 d0                	sub    %edx,%eax
  8007d1:	eb 05                	jmp    8007d8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e5:	eb 07                	jmp    8007ee <strchr+0x13>
		if (*s == c)
  8007e7:	38 ca                	cmp    %cl,%dl
  8007e9:	74 0f                	je     8007fa <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007eb:	83 c0 01             	add    $0x1,%eax
  8007ee:	0f b6 10             	movzbl (%eax),%edx
  8007f1:	84 d2                	test   %dl,%dl
  8007f3:	75 f2                	jne    8007e7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800806:	eb 03                	jmp    80080b <strfind+0xf>
  800808:	83 c0 01             	add    $0x1,%eax
  80080b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80080e:	84 d2                	test   %dl,%dl
  800810:	74 04                	je     800816 <strfind+0x1a>
  800812:	38 ca                	cmp    %cl,%dl
  800814:	75 f2                	jne    800808 <strfind+0xc>
			break;
	return (char *) s;
}
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	57                   	push   %edi
  80081c:	56                   	push   %esi
  80081d:	53                   	push   %ebx
  80081e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800821:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800824:	85 c9                	test   %ecx,%ecx
  800826:	74 36                	je     80085e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800828:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80082e:	75 28                	jne    800858 <memset+0x40>
  800830:	f6 c1 03             	test   $0x3,%cl
  800833:	75 23                	jne    800858 <memset+0x40>
		c &= 0xFF;
  800835:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800839:	89 d3                	mov    %edx,%ebx
  80083b:	c1 e3 08             	shl    $0x8,%ebx
  80083e:	89 d6                	mov    %edx,%esi
  800840:	c1 e6 18             	shl    $0x18,%esi
  800843:	89 d0                	mov    %edx,%eax
  800845:	c1 e0 10             	shl    $0x10,%eax
  800848:	09 f0                	or     %esi,%eax
  80084a:	09 c2                	or     %eax,%edx
  80084c:	89 d0                	mov    %edx,%eax
  80084e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800850:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800853:	fc                   	cld    
  800854:	f3 ab                	rep stos %eax,%es:(%edi)
  800856:	eb 06                	jmp    80085e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800858:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085b:	fc                   	cld    
  80085c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80085e:	89 f8                	mov    %edi,%eax
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5f                   	pop    %edi
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	57                   	push   %edi
  800869:	56                   	push   %esi
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800870:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800873:	39 c6                	cmp    %eax,%esi
  800875:	73 35                	jae    8008ac <memmove+0x47>
  800877:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80087a:	39 d0                	cmp    %edx,%eax
  80087c:	73 2e                	jae    8008ac <memmove+0x47>
		s += n;
		d += n;
  80087e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800881:	89 d6                	mov    %edx,%esi
  800883:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800885:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088b:	75 13                	jne    8008a0 <memmove+0x3b>
  80088d:	f6 c1 03             	test   $0x3,%cl
  800890:	75 0e                	jne    8008a0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800892:	83 ef 04             	sub    $0x4,%edi
  800895:	8d 72 fc             	lea    -0x4(%edx),%esi
  800898:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80089b:	fd                   	std    
  80089c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80089e:	eb 09                	jmp    8008a9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008a0:	83 ef 01             	sub    $0x1,%edi
  8008a3:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008a6:	fd                   	std    
  8008a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008a9:	fc                   	cld    
  8008aa:	eb 1d                	jmp    8008c9 <memmove+0x64>
  8008ac:	89 f2                	mov    %esi,%edx
  8008ae:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b0:	f6 c2 03             	test   $0x3,%dl
  8008b3:	75 0f                	jne    8008c4 <memmove+0x5f>
  8008b5:	f6 c1 03             	test   $0x3,%cl
  8008b8:	75 0a                	jne    8008c4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008ba:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008bd:	89 c7                	mov    %eax,%edi
  8008bf:	fc                   	cld    
  8008c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c2:	eb 05                	jmp    8008c9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c4:	89 c7                	mov    %eax,%edi
  8008c6:	fc                   	cld    
  8008c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008c9:	5e                   	pop    %esi
  8008ca:	5f                   	pop    %edi
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008d0:	ff 75 10             	pushl  0x10(%ebp)
  8008d3:	ff 75 0c             	pushl  0xc(%ebp)
  8008d6:	ff 75 08             	pushl  0x8(%ebp)
  8008d9:	e8 87 ff ff ff       	call   800865 <memmove>
}
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008eb:	89 c6                	mov    %eax,%esi
  8008ed:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f0:	eb 1a                	jmp    80090c <memcmp+0x2c>
		if (*s1 != *s2)
  8008f2:	0f b6 08             	movzbl (%eax),%ecx
  8008f5:	0f b6 1a             	movzbl (%edx),%ebx
  8008f8:	38 d9                	cmp    %bl,%cl
  8008fa:	74 0a                	je     800906 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008fc:	0f b6 c1             	movzbl %cl,%eax
  8008ff:	0f b6 db             	movzbl %bl,%ebx
  800902:	29 d8                	sub    %ebx,%eax
  800904:	eb 0f                	jmp    800915 <memcmp+0x35>
		s1++, s2++;
  800906:	83 c0 01             	add    $0x1,%eax
  800909:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090c:	39 f0                	cmp    %esi,%eax
  80090e:	75 e2                	jne    8008f2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800922:	89 c2                	mov    %eax,%edx
  800924:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800927:	eb 07                	jmp    800930 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800929:	38 08                	cmp    %cl,(%eax)
  80092b:	74 07                	je     800934 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	39 d0                	cmp    %edx,%eax
  800932:	72 f5                	jb     800929 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800942:	eb 03                	jmp    800947 <strtol+0x11>
		s++;
  800944:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800947:	0f b6 01             	movzbl (%ecx),%eax
  80094a:	3c 09                	cmp    $0x9,%al
  80094c:	74 f6                	je     800944 <strtol+0xe>
  80094e:	3c 20                	cmp    $0x20,%al
  800950:	74 f2                	je     800944 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800952:	3c 2b                	cmp    $0x2b,%al
  800954:	75 0a                	jne    800960 <strtol+0x2a>
		s++;
  800956:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800959:	bf 00 00 00 00       	mov    $0x0,%edi
  80095e:	eb 10                	jmp    800970 <strtol+0x3a>
  800960:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800965:	3c 2d                	cmp    $0x2d,%al
  800967:	75 07                	jne    800970 <strtol+0x3a>
		s++, neg = 1;
  800969:	8d 49 01             	lea    0x1(%ecx),%ecx
  80096c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800970:	85 db                	test   %ebx,%ebx
  800972:	0f 94 c0             	sete   %al
  800975:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80097b:	75 19                	jne    800996 <strtol+0x60>
  80097d:	80 39 30             	cmpb   $0x30,(%ecx)
  800980:	75 14                	jne    800996 <strtol+0x60>
  800982:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800986:	0f 85 82 00 00 00    	jne    800a0e <strtol+0xd8>
		s += 2, base = 16;
  80098c:	83 c1 02             	add    $0x2,%ecx
  80098f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800994:	eb 16                	jmp    8009ac <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800996:	84 c0                	test   %al,%al
  800998:	74 12                	je     8009ac <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80099a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80099f:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a2:	75 08                	jne    8009ac <strtol+0x76>
		s++, base = 8;
  8009a4:	83 c1 01             	add    $0x1,%ecx
  8009a7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b4:	0f b6 11             	movzbl (%ecx),%edx
  8009b7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ba:	89 f3                	mov    %esi,%ebx
  8009bc:	80 fb 09             	cmp    $0x9,%bl
  8009bf:	77 08                	ja     8009c9 <strtol+0x93>
			dig = *s - '0';
  8009c1:	0f be d2             	movsbl %dl,%edx
  8009c4:	83 ea 30             	sub    $0x30,%edx
  8009c7:	eb 22                	jmp    8009eb <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009c9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009cc:	89 f3                	mov    %esi,%ebx
  8009ce:	80 fb 19             	cmp    $0x19,%bl
  8009d1:	77 08                	ja     8009db <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009d3:	0f be d2             	movsbl %dl,%edx
  8009d6:	83 ea 57             	sub    $0x57,%edx
  8009d9:	eb 10                	jmp    8009eb <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009db:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009de:	89 f3                	mov    %esi,%ebx
  8009e0:	80 fb 19             	cmp    $0x19,%bl
  8009e3:	77 16                	ja     8009fb <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009e5:	0f be d2             	movsbl %dl,%edx
  8009e8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009eb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009ee:	7d 0f                	jge    8009ff <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009f0:	83 c1 01             	add    $0x1,%ecx
  8009f3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009f9:	eb b9                	jmp    8009b4 <strtol+0x7e>
  8009fb:	89 c2                	mov    %eax,%edx
  8009fd:	eb 02                	jmp    800a01 <strtol+0xcb>
  8009ff:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a05:	74 0d                	je     800a14 <strtol+0xde>
		*endptr = (char *) s;
  800a07:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0a:	89 0e                	mov    %ecx,(%esi)
  800a0c:	eb 06                	jmp    800a14 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0e:	84 c0                	test   %al,%al
  800a10:	75 92                	jne    8009a4 <strtol+0x6e>
  800a12:	eb 98                	jmp    8009ac <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a14:	f7 da                	neg    %edx
  800a16:	85 ff                	test   %edi,%edi
  800a18:	0f 45 c2             	cmovne %edx,%eax
}
  800a1b:	5b                   	pop    %ebx
  800a1c:	5e                   	pop    %esi
  800a1d:	5f                   	pop    %edi
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a31:	89 c3                	mov    %eax,%ebx
  800a33:	89 c7                	mov    %eax,%edi
  800a35:	89 c6                	mov    %eax,%esi
  800a37:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	57                   	push   %edi
  800a42:	56                   	push   %esi
  800a43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a44:	ba 00 00 00 00       	mov    $0x0,%edx
  800a49:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4e:	89 d1                	mov    %edx,%ecx
  800a50:	89 d3                	mov    %edx,%ebx
  800a52:	89 d7                	mov    %edx,%edi
  800a54:	89 d6                	mov    %edx,%esi
  800a56:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a70:	8b 55 08             	mov    0x8(%ebp),%edx
  800a73:	89 cb                	mov    %ecx,%ebx
  800a75:	89 cf                	mov    %ecx,%edi
  800a77:	89 ce                	mov    %ecx,%esi
  800a79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a7b:	85 c0                	test   %eax,%eax
  800a7d:	7e 17                	jle    800a96 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a7f:	83 ec 0c             	sub    $0xc,%esp
  800a82:	50                   	push   %eax
  800a83:	6a 03                	push   $0x3
  800a85:	68 00 10 80 00       	push   $0x801000
  800a8a:	6a 23                	push   $0x23
  800a8c:	68 1d 10 80 00       	push   $0x80101d
  800a91:	e8 27 00 00 00       	call   800abd <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa9:	b8 02 00 00 00       	mov    $0x2,%eax
  800aae:	89 d1                	mov    %edx,%ecx
  800ab0:	89 d3                	mov    %edx,%ebx
  800ab2:	89 d7                	mov    %edx,%edi
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ac2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ac5:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800acb:	e8 ce ff ff ff       	call   800a9e <sys_getenvid>
  800ad0:	83 ec 0c             	sub    $0xc,%esp
  800ad3:	ff 75 0c             	pushl  0xc(%ebp)
  800ad6:	ff 75 08             	pushl  0x8(%ebp)
  800ad9:	56                   	push   %esi
  800ada:	50                   	push   %eax
  800adb:	68 2c 10 80 00       	push   $0x80102c
  800ae0:	e8 67 f6 ff ff       	call   80014c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ae5:	83 c4 18             	add    $0x18,%esp
  800ae8:	53                   	push   %ebx
  800ae9:	ff 75 10             	pushl  0x10(%ebp)
  800aec:	e8 0a f6 ff ff       	call   8000fb <vcprintf>
	cprintf("\n");
  800af1:	c7 04 24 cc 0d 80 00 	movl   $0x800dcc,(%esp)
  800af8:	e8 4f f6 ff ff       	call   80014c <cprintf>
  800afd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b00:	cc                   	int3   
  800b01:	eb fd                	jmp    800b00 <_panic+0x43>
  800b03:	66 90                	xchg   %ax,%ax
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
