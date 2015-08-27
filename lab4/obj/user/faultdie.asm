
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 40 10 80 00       	push   $0x801040
  80004a:	e8 1c 01 00 00       	call   80016b <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 69 0a 00 00       	call   800abd <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 20 0a 00 00       	call   800a7c <sys_env_destroy>
  80005c:	83 c4 10             	add    $0x10,%esp
}
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 39 0c 00 00       	call   800caa <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
  80007b:	83 c4 10             	add    $0x10,%esp
}
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  80008b:	e8 2d 0a 00 00       	call   800abd <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
  8000bc:	83 c4 10             	add    $0x10,%esp
}
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000cc:	6a 00                	push   $0x0
  8000ce:	e8 a9 09 00 00       	call   800a7c <sys_env_destroy>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 13                	mov    (%ebx),%edx
  8000e4:	8d 42 01             	lea    0x1(%edx),%eax
  8000e7:	89 03                	mov    %eax,(%ebx)
  8000e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f5:	75 1a                	jne    800111 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 ff 00 00 00       	push   $0xff
  8000ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800102:	50                   	push   %eax
  800103:	e8 37 09 00 00       	call   800a3f <sys_cputs>
		b->idx = 0;
  800108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800111:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800118:	c9                   	leave  
  800119:	c3                   	ret    

0080011a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800123:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012a:	00 00 00 
	b.cnt = 0;
  80012d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800134:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800137:	ff 75 0c             	pushl  0xc(%ebp)
  80013a:	ff 75 08             	pushl  0x8(%ebp)
  80013d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	68 d8 00 80 00       	push   $0x8000d8
  800149:	e8 4f 01 00 00       	call   80029d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014e:	83 c4 08             	add    $0x8,%esp
  800151:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800157:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	e8 dc 08 00 00       	call   800a3f <sys_cputs>

	return b.cnt;
}
  800163:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800171:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800174:	50                   	push   %eax
  800175:	ff 75 08             	pushl  0x8(%ebp)
  800178:	e8 9d ff ff ff       	call   80011a <vcprintf>
	va_end(ap);

	return cnt;
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	57                   	push   %edi
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 1c             	sub    $0x1c,%esp
  800188:	89 c7                	mov    %eax,%edi
  80018a:	89 d6                	mov    %edx,%esi
  80018c:	8b 45 08             	mov    0x8(%ebp),%eax
  80018f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800192:	89 d1                	mov    %edx,%ecx
  800194:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800197:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80019a:	8b 45 10             	mov    0x10(%ebp),%eax
  80019d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001aa:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001ad:	72 05                	jb     8001b4 <printnum+0x35>
  8001af:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001b2:	77 3e                	ja     8001f2 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 18             	pushl  0x18(%ebp)
  8001ba:	83 eb 01             	sub    $0x1,%ebx
  8001bd:	53                   	push   %ebx
  8001be:	50                   	push   %eax
  8001bf:	83 ec 08             	sub    $0x8,%esp
  8001c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ce:	e8 bd 0b 00 00       	call   800d90 <__udivdi3>
  8001d3:	83 c4 18             	add    $0x18,%esp
  8001d6:	52                   	push   %edx
  8001d7:	50                   	push   %eax
  8001d8:	89 f2                	mov    %esi,%edx
  8001da:	89 f8                	mov    %edi,%eax
  8001dc:	e8 9e ff ff ff       	call   80017f <printnum>
  8001e1:	83 c4 20             	add    $0x20,%esp
  8001e4:	eb 13                	jmp    8001f9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	56                   	push   %esi
  8001ea:	ff 75 18             	pushl  0x18(%ebp)
  8001ed:	ff d7                	call   *%edi
  8001ef:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f2:	83 eb 01             	sub    $0x1,%ebx
  8001f5:	85 db                	test   %ebx,%ebx
  8001f7:	7f ed                	jg     8001e6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	56                   	push   %esi
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	ff 75 e4             	pushl  -0x1c(%ebp)
  800203:	ff 75 e0             	pushl  -0x20(%ebp)
  800206:	ff 75 dc             	pushl  -0x24(%ebp)
  800209:	ff 75 d8             	pushl  -0x28(%ebp)
  80020c:	e8 af 0c 00 00       	call   800ec0 <__umoddi3>
  800211:	83 c4 14             	add    $0x14,%esp
  800214:	0f be 80 66 10 80 00 	movsbl 0x801066(%eax),%eax
  80021b:	50                   	push   %eax
  80021c:	ff d7                	call   *%edi
  80021e:	83 c4 10             	add    $0x10,%esp
}
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80022c:	83 fa 01             	cmp    $0x1,%edx
  80022f:	7e 0e                	jle    80023f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800231:	8b 10                	mov    (%eax),%edx
  800233:	8d 4a 08             	lea    0x8(%edx),%ecx
  800236:	89 08                	mov    %ecx,(%eax)
  800238:	8b 02                	mov    (%edx),%eax
  80023a:	8b 52 04             	mov    0x4(%edx),%edx
  80023d:	eb 22                	jmp    800261 <getuint+0x38>
	else if (lflag)
  80023f:	85 d2                	test   %edx,%edx
  800241:	74 10                	je     800253 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800243:	8b 10                	mov    (%eax),%edx
  800245:	8d 4a 04             	lea    0x4(%edx),%ecx
  800248:	89 08                	mov    %ecx,(%eax)
  80024a:	8b 02                	mov    (%edx),%eax
  80024c:	ba 00 00 00 00       	mov    $0x0,%edx
  800251:	eb 0e                	jmp    800261 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800253:	8b 10                	mov    (%eax),%edx
  800255:	8d 4a 04             	lea    0x4(%edx),%ecx
  800258:	89 08                	mov    %ecx,(%eax)
  80025a:	8b 02                	mov    (%edx),%eax
  80025c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800269:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80026d:	8b 10                	mov    (%eax),%edx
  80026f:	3b 50 04             	cmp    0x4(%eax),%edx
  800272:	73 0a                	jae    80027e <sprintputch+0x1b>
		*b->buf++ = ch;
  800274:	8d 4a 01             	lea    0x1(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 45 08             	mov    0x8(%ebp),%eax
  80027c:	88 02                	mov    %al,(%edx)
}
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800286:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800289:	50                   	push   %eax
  80028a:	ff 75 10             	pushl  0x10(%ebp)
  80028d:	ff 75 0c             	pushl  0xc(%ebp)
  800290:	ff 75 08             	pushl  0x8(%ebp)
  800293:	e8 05 00 00 00       	call   80029d <vprintfmt>
	va_end(ap);
  800298:	83 c4 10             	add    $0x10,%esp
}
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    

0080029d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
  8002a3:	83 ec 2c             	sub    $0x2c,%esp
  8002a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ac:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002af:	eb 12                	jmp    8002c3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b1:	85 c0                	test   %eax,%eax
  8002b3:	0f 84 90 03 00 00    	je     800649 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	53                   	push   %ebx
  8002bd:	50                   	push   %eax
  8002be:	ff d6                	call   *%esi
  8002c0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c3:	83 c7 01             	add    $0x1,%edi
  8002c6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ca:	83 f8 25             	cmp    $0x25,%eax
  8002cd:	75 e2                	jne    8002b1 <vprintfmt+0x14>
  8002cf:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002d3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ed:	eb 07                	jmp    8002f6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f6:	8d 47 01             	lea    0x1(%edi),%eax
  8002f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fc:	0f b6 07             	movzbl (%edi),%eax
  8002ff:	0f b6 c8             	movzbl %al,%ecx
  800302:	83 e8 23             	sub    $0x23,%eax
  800305:	3c 55                	cmp    $0x55,%al
  800307:	0f 87 21 03 00 00    	ja     80062e <vprintfmt+0x391>
  80030d:	0f b6 c0             	movzbl %al,%eax
  800310:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  800317:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80031a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80031e:	eb d6                	jmp    8002f6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800323:	b8 00 00 00 00       	mov    $0x0,%eax
  800328:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80032b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800332:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800335:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800338:	83 fa 09             	cmp    $0x9,%edx
  80033b:	77 39                	ja     800376 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80033d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800340:	eb e9                	jmp    80032b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800342:	8b 45 14             	mov    0x14(%ebp),%eax
  800345:	8d 48 04             	lea    0x4(%eax),%ecx
  800348:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80034b:	8b 00                	mov    (%eax),%eax
  80034d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800353:	eb 27                	jmp    80037c <vprintfmt+0xdf>
  800355:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800358:	85 c0                	test   %eax,%eax
  80035a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035f:	0f 49 c8             	cmovns %eax,%ecx
  800362:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800368:	eb 8c                	jmp    8002f6 <vprintfmt+0x59>
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80036d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800374:	eb 80                	jmp    8002f6 <vprintfmt+0x59>
  800376:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800379:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80037c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800380:	0f 89 70 ff ff ff    	jns    8002f6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800386:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800389:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80038c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800393:	e9 5e ff ff ff       	jmp    8002f6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800398:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80039e:	e9 53 ff ff ff       	jmp    8002f6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a6:	8d 50 04             	lea    0x4(%eax),%edx
  8003a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ac:	83 ec 08             	sub    $0x8,%esp
  8003af:	53                   	push   %ebx
  8003b0:	ff 30                	pushl  (%eax)
  8003b2:	ff d6                	call   *%esi
			break;
  8003b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ba:	e9 04 ff ff ff       	jmp    8002c3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c2:	8d 50 04             	lea    0x4(%eax),%edx
  8003c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c8:	8b 00                	mov    (%eax),%eax
  8003ca:	99                   	cltd   
  8003cb:	31 d0                	xor    %edx,%eax
  8003cd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003cf:	83 f8 09             	cmp    $0x9,%eax
  8003d2:	7f 0b                	jg     8003df <vprintfmt+0x142>
  8003d4:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  8003db:	85 d2                	test   %edx,%edx
  8003dd:	75 18                	jne    8003f7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003df:	50                   	push   %eax
  8003e0:	68 7e 10 80 00       	push   $0x80107e
  8003e5:	53                   	push   %ebx
  8003e6:	56                   	push   %esi
  8003e7:	e8 94 fe ff ff       	call   800280 <printfmt>
  8003ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f2:	e9 cc fe ff ff       	jmp    8002c3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f7:	52                   	push   %edx
  8003f8:	68 87 10 80 00       	push   $0x801087
  8003fd:	53                   	push   %ebx
  8003fe:	56                   	push   %esi
  8003ff:	e8 7c fe ff ff       	call   800280 <printfmt>
  800404:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040a:	e9 b4 fe ff ff       	jmp    8002c3 <vprintfmt+0x26>
  80040f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800412:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800415:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 50 04             	lea    0x4(%eax),%edx
  80041e:	89 55 14             	mov    %edx,0x14(%ebp)
  800421:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800423:	85 ff                	test   %edi,%edi
  800425:	ba 77 10 80 00       	mov    $0x801077,%edx
  80042a:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  80042d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800431:	0f 84 92 00 00 00    	je     8004c9 <vprintfmt+0x22c>
  800437:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80043b:	0f 8e 96 00 00 00    	jle    8004d7 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	51                   	push   %ecx
  800445:	57                   	push   %edi
  800446:	e8 86 02 00 00       	call   8006d1 <strnlen>
  80044b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80044e:	29 c1                	sub    %eax,%ecx
  800450:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800453:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800456:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80045a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800460:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800462:	eb 0f                	jmp    800473 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	53                   	push   %ebx
  800468:	ff 75 e0             	pushl  -0x20(%ebp)
  80046b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046d:	83 ef 01             	sub    $0x1,%edi
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	85 ff                	test   %edi,%edi
  800475:	7f ed                	jg     800464 <vprintfmt+0x1c7>
  800477:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80047a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80047d:	85 c9                	test   %ecx,%ecx
  80047f:	b8 00 00 00 00       	mov    $0x0,%eax
  800484:	0f 49 c1             	cmovns %ecx,%eax
  800487:	29 c1                	sub    %eax,%ecx
  800489:	89 75 08             	mov    %esi,0x8(%ebp)
  80048c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800492:	89 cb                	mov    %ecx,%ebx
  800494:	eb 4d                	jmp    8004e3 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800496:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049a:	74 1b                	je     8004b7 <vprintfmt+0x21a>
  80049c:	0f be c0             	movsbl %al,%eax
  80049f:	83 e8 20             	sub    $0x20,%eax
  8004a2:	83 f8 5e             	cmp    $0x5e,%eax
  8004a5:	76 10                	jbe    8004b7 <vprintfmt+0x21a>
					putch('?', putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	ff 75 0c             	pushl  0xc(%ebp)
  8004ad:	6a 3f                	push   $0x3f
  8004af:	ff 55 08             	call   *0x8(%ebp)
  8004b2:	83 c4 10             	add    $0x10,%esp
  8004b5:	eb 0d                	jmp    8004c4 <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	ff 75 0c             	pushl  0xc(%ebp)
  8004bd:	52                   	push   %edx
  8004be:	ff 55 08             	call   *0x8(%ebp)
  8004c1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c4:	83 eb 01             	sub    $0x1,%ebx
  8004c7:	eb 1a                	jmp    8004e3 <vprintfmt+0x246>
  8004c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d5:	eb 0c                	jmp    8004e3 <vprintfmt+0x246>
  8004d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e3:	83 c7 01             	add    $0x1,%edi
  8004e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ea:	0f be d0             	movsbl %al,%edx
  8004ed:	85 d2                	test   %edx,%edx
  8004ef:	74 23                	je     800514 <vprintfmt+0x277>
  8004f1:	85 f6                	test   %esi,%esi
  8004f3:	78 a1                	js     800496 <vprintfmt+0x1f9>
  8004f5:	83 ee 01             	sub    $0x1,%esi
  8004f8:	79 9c                	jns    800496 <vprintfmt+0x1f9>
  8004fa:	89 df                	mov    %ebx,%edi
  8004fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800502:	eb 18                	jmp    80051c <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	6a 20                	push   $0x20
  80050a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050c:	83 ef 01             	sub    $0x1,%edi
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	eb 08                	jmp    80051c <vprintfmt+0x27f>
  800514:	89 df                	mov    %ebx,%edi
  800516:	8b 75 08             	mov    0x8(%ebp),%esi
  800519:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051c:	85 ff                	test   %edi,%edi
  80051e:	7f e4                	jg     800504 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800520:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800523:	e9 9b fd ff ff       	jmp    8002c3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800528:	83 fa 01             	cmp    $0x1,%edx
  80052b:	7e 16                	jle    800543 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 08             	lea    0x8(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	8b 50 04             	mov    0x4(%eax),%edx
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800541:	eb 32                	jmp    800575 <vprintfmt+0x2d8>
	else if (lflag)
  800543:	85 d2                	test   %edx,%edx
  800545:	74 18                	je     80055f <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 50 04             	lea    0x4(%eax),%edx
  80054d:	89 55 14             	mov    %edx,0x14(%ebp)
  800550:	8b 00                	mov    (%eax),%eax
  800552:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800555:	89 c1                	mov    %eax,%ecx
  800557:	c1 f9 1f             	sar    $0x1f,%ecx
  80055a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80055d:	eb 16                	jmp    800575 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 50 04             	lea    0x4(%eax),%edx
  800565:	89 55 14             	mov    %edx,0x14(%ebp)
  800568:	8b 00                	mov    (%eax),%eax
  80056a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056d:	89 c1                	mov    %eax,%ecx
  80056f:	c1 f9 1f             	sar    $0x1f,%ecx
  800572:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800575:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800578:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80057b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800580:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800584:	79 74                	jns    8005fa <vprintfmt+0x35d>
				putch('-', putdat);
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	53                   	push   %ebx
  80058a:	6a 2d                	push   $0x2d
  80058c:	ff d6                	call   *%esi
				num = -(long long) num;
  80058e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800591:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800594:	f7 d8                	neg    %eax
  800596:	83 d2 00             	adc    $0x0,%edx
  800599:	f7 da                	neg    %edx
  80059b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80059e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005a3:	eb 55                	jmp    8005fa <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a8:	e8 7c fc ff ff       	call   800229 <getuint>
			base = 10;
  8005ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005b2:	eb 46                	jmp    8005fa <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b7:	e8 6d fc ff ff       	call   800229 <getuint>
                        base = 8;
  8005bc:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005c1:	eb 37                	jmp    8005fa <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	53                   	push   %ebx
  8005c7:	6a 30                	push   $0x30
  8005c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005cb:	83 c4 08             	add    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 78                	push   $0x78
  8005d1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 50 04             	lea    0x4(%eax),%edx
  8005d9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005dc:	8b 00                	mov    (%eax),%eax
  8005de:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005e6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005eb:	eb 0d                	jmp    8005fa <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f0:	e8 34 fc ff ff       	call   800229 <getuint>
			base = 16;
  8005f5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005fa:	83 ec 0c             	sub    $0xc,%esp
  8005fd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800601:	57                   	push   %edi
  800602:	ff 75 e0             	pushl  -0x20(%ebp)
  800605:	51                   	push   %ecx
  800606:	52                   	push   %edx
  800607:	50                   	push   %eax
  800608:	89 da                	mov    %ebx,%edx
  80060a:	89 f0                	mov    %esi,%eax
  80060c:	e8 6e fb ff ff       	call   80017f <printnum>
			break;
  800611:	83 c4 20             	add    $0x20,%esp
  800614:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800617:	e9 a7 fc ff ff       	jmp    8002c3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	51                   	push   %ecx
  800621:	ff d6                	call   *%esi
			break;
  800623:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800629:	e9 95 fc ff ff       	jmp    8002c3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 25                	push   $0x25
  800634:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb 03                	jmp    80063e <vprintfmt+0x3a1>
  80063b:	83 ef 01             	sub    $0x1,%edi
  80063e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800642:	75 f7                	jne    80063b <vprintfmt+0x39e>
  800644:	e9 7a fc ff ff       	jmp    8002c3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800649:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064c:	5b                   	pop    %ebx
  80064d:	5e                   	pop    %esi
  80064e:	5f                   	pop    %edi
  80064f:	5d                   	pop    %ebp
  800650:	c3                   	ret    

00800651 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800651:	55                   	push   %ebp
  800652:	89 e5                	mov    %esp,%ebp
  800654:	83 ec 18             	sub    $0x18,%esp
  800657:	8b 45 08             	mov    0x8(%ebp),%eax
  80065a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80065d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800660:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800664:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800667:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80066e:	85 c0                	test   %eax,%eax
  800670:	74 26                	je     800698 <vsnprintf+0x47>
  800672:	85 d2                	test   %edx,%edx
  800674:	7e 22                	jle    800698 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800676:	ff 75 14             	pushl  0x14(%ebp)
  800679:	ff 75 10             	pushl  0x10(%ebp)
  80067c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80067f:	50                   	push   %eax
  800680:	68 63 02 80 00       	push   $0x800263
  800685:	e8 13 fc ff ff       	call   80029d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80068a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80068d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800690:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	eb 05                	jmp    80069d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800698:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80069d:	c9                   	leave  
  80069e:	c3                   	ret    

0080069f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a8:	50                   	push   %eax
  8006a9:	ff 75 10             	pushl  0x10(%ebp)
  8006ac:	ff 75 0c             	pushl  0xc(%ebp)
  8006af:	ff 75 08             	pushl  0x8(%ebp)
  8006b2:	e8 9a ff ff ff       	call   800651 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b7:	c9                   	leave  
  8006b8:	c3                   	ret    

008006b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
  8006bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c4:	eb 03                	jmp    8006c9 <strlen+0x10>
		n++;
  8006c6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006cd:	75 f7                	jne    8006c6 <strlen+0xd>
		n++;
	return n;
}
  8006cf:	5d                   	pop    %ebp
  8006d0:	c3                   	ret    

008006d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006da:	ba 00 00 00 00       	mov    $0x0,%edx
  8006df:	eb 03                	jmp    8006e4 <strnlen+0x13>
		n++;
  8006e1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e4:	39 c2                	cmp    %eax,%edx
  8006e6:	74 08                	je     8006f0 <strnlen+0x1f>
  8006e8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006ec:	75 f3                	jne    8006e1 <strnlen+0x10>
  8006ee:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	53                   	push   %ebx
  8006f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006fc:	89 c2                	mov    %eax,%edx
  8006fe:	83 c2 01             	add    $0x1,%edx
  800701:	83 c1 01             	add    $0x1,%ecx
  800704:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800708:	88 5a ff             	mov    %bl,-0x1(%edx)
  80070b:	84 db                	test   %bl,%bl
  80070d:	75 ef                	jne    8006fe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80070f:	5b                   	pop    %ebx
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    

00800712 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	53                   	push   %ebx
  800716:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800719:	53                   	push   %ebx
  80071a:	e8 9a ff ff ff       	call   8006b9 <strlen>
  80071f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800722:	ff 75 0c             	pushl  0xc(%ebp)
  800725:	01 d8                	add    %ebx,%eax
  800727:	50                   	push   %eax
  800728:	e8 c5 ff ff ff       	call   8006f2 <strcpy>
	return dst;
}
  80072d:	89 d8                	mov    %ebx,%eax
  80072f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800732:	c9                   	leave  
  800733:	c3                   	ret    

00800734 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	56                   	push   %esi
  800738:	53                   	push   %ebx
  800739:	8b 75 08             	mov    0x8(%ebp),%esi
  80073c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073f:	89 f3                	mov    %esi,%ebx
  800741:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800744:	89 f2                	mov    %esi,%edx
  800746:	eb 0f                	jmp    800757 <strncpy+0x23>
		*dst++ = *src;
  800748:	83 c2 01             	add    $0x1,%edx
  80074b:	0f b6 01             	movzbl (%ecx),%eax
  80074e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800751:	80 39 01             	cmpb   $0x1,(%ecx)
  800754:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800757:	39 da                	cmp    %ebx,%edx
  800759:	75 ed                	jne    800748 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80075b:	89 f0                	mov    %esi,%eax
  80075d:	5b                   	pop    %ebx
  80075e:	5e                   	pop    %esi
  80075f:	5d                   	pop    %ebp
  800760:	c3                   	ret    

00800761 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	56                   	push   %esi
  800765:	53                   	push   %ebx
  800766:	8b 75 08             	mov    0x8(%ebp),%esi
  800769:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076c:	8b 55 10             	mov    0x10(%ebp),%edx
  80076f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800771:	85 d2                	test   %edx,%edx
  800773:	74 21                	je     800796 <strlcpy+0x35>
  800775:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800779:	89 f2                	mov    %esi,%edx
  80077b:	eb 09                	jmp    800786 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80077d:	83 c2 01             	add    $0x1,%edx
  800780:	83 c1 01             	add    $0x1,%ecx
  800783:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800786:	39 c2                	cmp    %eax,%edx
  800788:	74 09                	je     800793 <strlcpy+0x32>
  80078a:	0f b6 19             	movzbl (%ecx),%ebx
  80078d:	84 db                	test   %bl,%bl
  80078f:	75 ec                	jne    80077d <strlcpy+0x1c>
  800791:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800793:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800796:	29 f0                	sub    %esi,%eax
}
  800798:	5b                   	pop    %ebx
  800799:	5e                   	pop    %esi
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007a5:	eb 06                	jmp    8007ad <strcmp+0x11>
		p++, q++;
  8007a7:	83 c1 01             	add    $0x1,%ecx
  8007aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ad:	0f b6 01             	movzbl (%ecx),%eax
  8007b0:	84 c0                	test   %al,%al
  8007b2:	74 04                	je     8007b8 <strcmp+0x1c>
  8007b4:	3a 02                	cmp    (%edx),%al
  8007b6:	74 ef                	je     8007a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b8:	0f b6 c0             	movzbl %al,%eax
  8007bb:	0f b6 12             	movzbl (%edx),%edx
  8007be:	29 d0                	sub    %edx,%eax
}
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cc:	89 c3                	mov    %eax,%ebx
  8007ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d1:	eb 06                	jmp    8007d9 <strncmp+0x17>
		n--, p++, q++;
  8007d3:	83 c0 01             	add    $0x1,%eax
  8007d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007d9:	39 d8                	cmp    %ebx,%eax
  8007db:	74 15                	je     8007f2 <strncmp+0x30>
  8007dd:	0f b6 08             	movzbl (%eax),%ecx
  8007e0:	84 c9                	test   %cl,%cl
  8007e2:	74 04                	je     8007e8 <strncmp+0x26>
  8007e4:	3a 0a                	cmp    (%edx),%cl
  8007e6:	74 eb                	je     8007d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e8:	0f b6 00             	movzbl (%eax),%eax
  8007eb:	0f b6 12             	movzbl (%edx),%edx
  8007ee:	29 d0                	sub    %edx,%eax
  8007f0:	eb 05                	jmp    8007f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007f7:	5b                   	pop    %ebx
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800800:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800804:	eb 07                	jmp    80080d <strchr+0x13>
		if (*s == c)
  800806:	38 ca                	cmp    %cl,%dl
  800808:	74 0f                	je     800819 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80080a:	83 c0 01             	add    $0x1,%eax
  80080d:	0f b6 10             	movzbl (%eax),%edx
  800810:	84 d2                	test   %dl,%dl
  800812:	75 f2                	jne    800806 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800814:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 45 08             	mov    0x8(%ebp),%eax
  800821:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800825:	eb 03                	jmp    80082a <strfind+0xf>
  800827:	83 c0 01             	add    $0x1,%eax
  80082a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80082d:	84 d2                	test   %dl,%dl
  80082f:	74 04                	je     800835 <strfind+0x1a>
  800831:	38 ca                	cmp    %cl,%dl
  800833:	75 f2                	jne    800827 <strfind+0xc>
			break;
	return (char *) s;
}
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	57                   	push   %edi
  80083b:	56                   	push   %esi
  80083c:	53                   	push   %ebx
  80083d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800840:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800843:	85 c9                	test   %ecx,%ecx
  800845:	74 36                	je     80087d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800847:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80084d:	75 28                	jne    800877 <memset+0x40>
  80084f:	f6 c1 03             	test   $0x3,%cl
  800852:	75 23                	jne    800877 <memset+0x40>
		c &= 0xFF;
  800854:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800858:	89 d3                	mov    %edx,%ebx
  80085a:	c1 e3 08             	shl    $0x8,%ebx
  80085d:	89 d6                	mov    %edx,%esi
  80085f:	c1 e6 18             	shl    $0x18,%esi
  800862:	89 d0                	mov    %edx,%eax
  800864:	c1 e0 10             	shl    $0x10,%eax
  800867:	09 f0                	or     %esi,%eax
  800869:	09 c2                	or     %eax,%edx
  80086b:	89 d0                	mov    %edx,%eax
  80086d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80086f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800872:	fc                   	cld    
  800873:	f3 ab                	rep stos %eax,%es:(%edi)
  800875:	eb 06                	jmp    80087d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087a:	fc                   	cld    
  80087b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80087d:	89 f8                	mov    %edi,%eax
  80087f:	5b                   	pop    %ebx
  800880:	5e                   	pop    %esi
  800881:	5f                   	pop    %edi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	57                   	push   %edi
  800888:	56                   	push   %esi
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800892:	39 c6                	cmp    %eax,%esi
  800894:	73 35                	jae    8008cb <memmove+0x47>
  800896:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800899:	39 d0                	cmp    %edx,%eax
  80089b:	73 2e                	jae    8008cb <memmove+0x47>
		s += n;
		d += n;
  80089d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008a0:	89 d6                	mov    %edx,%esi
  8008a2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008aa:	75 13                	jne    8008bf <memmove+0x3b>
  8008ac:	f6 c1 03             	test   $0x3,%cl
  8008af:	75 0e                	jne    8008bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008b1:	83 ef 04             	sub    $0x4,%edi
  8008b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008ba:	fd                   	std    
  8008bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008bd:	eb 09                	jmp    8008c8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008bf:	83 ef 01             	sub    $0x1,%edi
  8008c2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c5:	fd                   	std    
  8008c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c8:	fc                   	cld    
  8008c9:	eb 1d                	jmp    8008e8 <memmove+0x64>
  8008cb:	89 f2                	mov    %esi,%edx
  8008cd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cf:	f6 c2 03             	test   $0x3,%dl
  8008d2:	75 0f                	jne    8008e3 <memmove+0x5f>
  8008d4:	f6 c1 03             	test   $0x3,%cl
  8008d7:	75 0a                	jne    8008e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008d9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008dc:	89 c7                	mov    %eax,%edi
  8008de:	fc                   	cld    
  8008df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e1:	eb 05                	jmp    8008e8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e3:	89 c7                	mov    %eax,%edi
  8008e5:	fc                   	cld    
  8008e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008e8:	5e                   	pop    %esi
  8008e9:	5f                   	pop    %edi
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008ef:	ff 75 10             	pushl  0x10(%ebp)
  8008f2:	ff 75 0c             	pushl  0xc(%ebp)
  8008f5:	ff 75 08             	pushl  0x8(%ebp)
  8008f8:	e8 87 ff ff ff       	call   800884 <memmove>
}
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    

008008ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090a:	89 c6                	mov    %eax,%esi
  80090c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090f:	eb 1a                	jmp    80092b <memcmp+0x2c>
		if (*s1 != *s2)
  800911:	0f b6 08             	movzbl (%eax),%ecx
  800914:	0f b6 1a             	movzbl (%edx),%ebx
  800917:	38 d9                	cmp    %bl,%cl
  800919:	74 0a                	je     800925 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80091b:	0f b6 c1             	movzbl %cl,%eax
  80091e:	0f b6 db             	movzbl %bl,%ebx
  800921:	29 d8                	sub    %ebx,%eax
  800923:	eb 0f                	jmp    800934 <memcmp+0x35>
		s1++, s2++;
  800925:	83 c0 01             	add    $0x1,%eax
  800928:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092b:	39 f0                	cmp    %esi,%eax
  80092d:	75 e2                	jne    800911 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800934:	5b                   	pop    %ebx
  800935:	5e                   	pop    %esi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800941:	89 c2                	mov    %eax,%edx
  800943:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800946:	eb 07                	jmp    80094f <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800948:	38 08                	cmp    %cl,(%eax)
  80094a:	74 07                	je     800953 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	39 d0                	cmp    %edx,%eax
  800951:	72 f5                	jb     800948 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	57                   	push   %edi
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800961:	eb 03                	jmp    800966 <strtol+0x11>
		s++;
  800963:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800966:	0f b6 01             	movzbl (%ecx),%eax
  800969:	3c 09                	cmp    $0x9,%al
  80096b:	74 f6                	je     800963 <strtol+0xe>
  80096d:	3c 20                	cmp    $0x20,%al
  80096f:	74 f2                	je     800963 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800971:	3c 2b                	cmp    $0x2b,%al
  800973:	75 0a                	jne    80097f <strtol+0x2a>
		s++;
  800975:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800978:	bf 00 00 00 00       	mov    $0x0,%edi
  80097d:	eb 10                	jmp    80098f <strtol+0x3a>
  80097f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800984:	3c 2d                	cmp    $0x2d,%al
  800986:	75 07                	jne    80098f <strtol+0x3a>
		s++, neg = 1;
  800988:	8d 49 01             	lea    0x1(%ecx),%ecx
  80098b:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80098f:	85 db                	test   %ebx,%ebx
  800991:	0f 94 c0             	sete   %al
  800994:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80099a:	75 19                	jne    8009b5 <strtol+0x60>
  80099c:	80 39 30             	cmpb   $0x30,(%ecx)
  80099f:	75 14                	jne    8009b5 <strtol+0x60>
  8009a1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009a5:	0f 85 82 00 00 00    	jne    800a2d <strtol+0xd8>
		s += 2, base = 16;
  8009ab:	83 c1 02             	add    $0x2,%ecx
  8009ae:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b3:	eb 16                	jmp    8009cb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009b5:	84 c0                	test   %al,%al
  8009b7:	74 12                	je     8009cb <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009b9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009be:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c1:	75 08                	jne    8009cb <strtol+0x76>
		s++, base = 8;
  8009c3:	83 c1 01             	add    $0x1,%ecx
  8009c6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d3:	0f b6 11             	movzbl (%ecx),%edx
  8009d6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009d9:	89 f3                	mov    %esi,%ebx
  8009db:	80 fb 09             	cmp    $0x9,%bl
  8009de:	77 08                	ja     8009e8 <strtol+0x93>
			dig = *s - '0';
  8009e0:	0f be d2             	movsbl %dl,%edx
  8009e3:	83 ea 30             	sub    $0x30,%edx
  8009e6:	eb 22                	jmp    800a0a <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009e8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009eb:	89 f3                	mov    %esi,%ebx
  8009ed:	80 fb 19             	cmp    $0x19,%bl
  8009f0:	77 08                	ja     8009fa <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009f2:	0f be d2             	movsbl %dl,%edx
  8009f5:	83 ea 57             	sub    $0x57,%edx
  8009f8:	eb 10                	jmp    800a0a <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009fa:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009fd:	89 f3                	mov    %esi,%ebx
  8009ff:	80 fb 19             	cmp    $0x19,%bl
  800a02:	77 16                	ja     800a1a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a04:	0f be d2             	movsbl %dl,%edx
  800a07:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a0a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a0d:	7d 0f                	jge    800a1e <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a0f:	83 c1 01             	add    $0x1,%ecx
  800a12:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a16:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a18:	eb b9                	jmp    8009d3 <strtol+0x7e>
  800a1a:	89 c2                	mov    %eax,%edx
  800a1c:	eb 02                	jmp    800a20 <strtol+0xcb>
  800a1e:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a24:	74 0d                	je     800a33 <strtol+0xde>
		*endptr = (char *) s;
  800a26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a29:	89 0e                	mov    %ecx,(%esi)
  800a2b:	eb 06                	jmp    800a33 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2d:	84 c0                	test   %al,%al
  800a2f:	75 92                	jne    8009c3 <strtol+0x6e>
  800a31:	eb 98                	jmp    8009cb <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a33:	f7 da                	neg    %edx
  800a35:	85 ff                	test   %edi,%edi
  800a37:	0f 45 c2             	cmovne %edx,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a50:	89 c3                	mov    %eax,%ebx
  800a52:	89 c7                	mov    %eax,%edi
  800a54:	89 c6                	mov    %eax,%esi
  800a56:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6d:	89 d1                	mov    %edx,%ecx
  800a6f:	89 d3                	mov    %edx,%ebx
  800a71:	89 d7                	mov    %edx,%edi
  800a73:	89 d6                	mov    %edx,%esi
  800a75:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a92:	89 cb                	mov    %ecx,%ebx
  800a94:	89 cf                	mov    %ecx,%edi
  800a96:	89 ce                	mov    %ecx,%esi
  800a98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	7e 17                	jle    800ab5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9e:	83 ec 0c             	sub    $0xc,%esp
  800aa1:	50                   	push   %eax
  800aa2:	6a 03                	push   $0x3
  800aa4:	68 a8 12 80 00       	push   $0x8012a8
  800aa9:	6a 23                	push   $0x23
  800aab:	68 c5 12 80 00       	push   $0x8012c5
  800ab0:	e8 88 02 00 00       	call   800d3d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac8:	b8 02 00 00 00       	mov    $0x2,%eax
  800acd:	89 d1                	mov    %edx,%ecx
  800acf:	89 d3                	mov    %edx,%ebx
  800ad1:	89 d7                	mov    %edx,%edi
  800ad3:	89 d6                	mov    %edx,%esi
  800ad5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_yield>:

void
sys_yield(void)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aec:	89 d1                	mov    %edx,%ecx
  800aee:	89 d3                	mov    %edx,%ebx
  800af0:	89 d7                	mov    %edx,%edi
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	be 00 00 00 00       	mov    $0x0,%esi
  800b09:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b17:	89 f7                	mov    %esi,%edi
  800b19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7e 17                	jle    800b36 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	6a 04                	push   $0x4
  800b25:	68 a8 12 80 00       	push   $0x8012a8
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 c5 12 80 00       	push   $0x8012c5
  800b31:	e8 07 02 00 00       	call   800d3d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	b8 05 00 00 00       	mov    $0x5,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b58:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	7e 17                	jle    800b78 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	50                   	push   %eax
  800b65:	6a 05                	push   $0x5
  800b67:	68 a8 12 80 00       	push   $0x8012a8
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 c5 12 80 00       	push   $0x8012c5
  800b73:	e8 c5 01 00 00       	call   800d3d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 df                	mov    %ebx,%edi
  800b9b:	89 de                	mov    %ebx,%esi
  800b9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7e 17                	jle    800bba <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	50                   	push   %eax
  800ba7:	6a 06                	push   $0x6
  800ba9:	68 a8 12 80 00       	push   $0x8012a8
  800bae:	6a 23                	push   $0x23
  800bb0:	68 c5 12 80 00       	push   $0x8012c5
  800bb5:	e8 83 01 00 00       	call   800d3d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	89 df                	mov    %ebx,%edi
  800bdd:	89 de                	mov    %ebx,%esi
  800bdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 08                	push   $0x8
  800beb:	68 a8 12 80 00       	push   $0x8012a8
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 c5 12 80 00       	push   $0x8012c5
  800bf7:	e8 41 01 00 00       	call   800d3d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 09 00 00 00       	mov    $0x9,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 09                	push   $0x9
  800c2d:	68 a8 12 80 00       	push   $0x8012a8
  800c32:	6a 23                	push   $0x23
  800c34:	68 c5 12 80 00       	push   $0x8012c5
  800c39:	e8 ff 00 00 00       	call   800d3d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	be 00 00 00 00       	mov    $0x0,%esi
  800c51:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c62:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c77:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	89 cb                	mov    %ecx,%ebx
  800c81:	89 cf                	mov    %ecx,%edi
  800c83:	89 ce                	mov    %ecx,%esi
  800c85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c87:	85 c0                	test   %eax,%eax
  800c89:	7e 17                	jle    800ca2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	50                   	push   %eax
  800c8f:	6a 0c                	push   $0xc
  800c91:	68 a8 12 80 00       	push   $0x8012a8
  800c96:	6a 23                	push   $0x23
  800c98:	68 c5 12 80 00       	push   $0x8012c5
  800c9d:	e8 9b 00 00 00       	call   800d3d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cb0:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cb7:	75 2c                	jne    800ce5 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  800cb9:	83 ec 04             	sub    $0x4,%esp
  800cbc:	6a 07                	push   $0x7
  800cbe:	68 00 f0 bf ee       	push   $0xeebff000
  800cc3:	6a 00                	push   $0x0
  800cc5:	e8 31 fe ff ff       	call   800afb <sys_page_alloc>
  800cca:	83 c4 10             	add    $0x10,%esp
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	74 14                	je     800ce5 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  800cd1:	83 ec 04             	sub    $0x4,%esp
  800cd4:	68 d4 12 80 00       	push   $0x8012d4
  800cd9:	6a 21                	push   $0x21
  800cdb:	68 36 13 80 00       	push   $0x801336
  800ce0:	e8 58 00 00 00       	call   800d3d <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce8:	a3 08 20 80 00       	mov    %eax,0x802008
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800ced:	83 ec 08             	sub    $0x8,%esp
  800cf0:	68 19 0d 80 00       	push   $0x800d19
  800cf5:	6a 00                	push   $0x0
  800cf7:	e8 08 ff ff ff       	call   800c04 <sys_env_set_pgfault_upcall>
  800cfc:	83 c4 10             	add    $0x10,%esp
  800cff:	85 c0                	test   %eax,%eax
  800d01:	79 14                	jns    800d17 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800d03:	83 ec 04             	sub    $0x4,%esp
  800d06:	68 00 13 80 00       	push   $0x801300
  800d0b:	6a 29                	push   $0x29
  800d0d:	68 36 13 80 00       	push   $0x801336
  800d12:	e8 26 00 00 00       	call   800d3d <_panic>
}
  800d17:	c9                   	leave  
  800d18:	c3                   	ret    

00800d19 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d19:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d1a:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d1f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d21:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  800d24:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  800d29:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  800d2d:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  800d31:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  800d33:	83 c4 08             	add    $0x8,%esp
        popal
  800d36:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800d37:	83 c4 04             	add    $0x4,%esp
        popfl
  800d3a:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  800d3b:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800d3c:	c3                   	ret    

00800d3d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d42:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d45:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d4b:	e8 6d fd ff ff       	call   800abd <sys_getenvid>
  800d50:	83 ec 0c             	sub    $0xc,%esp
  800d53:	ff 75 0c             	pushl  0xc(%ebp)
  800d56:	ff 75 08             	pushl  0x8(%ebp)
  800d59:	56                   	push   %esi
  800d5a:	50                   	push   %eax
  800d5b:	68 44 13 80 00       	push   $0x801344
  800d60:	e8 06 f4 ff ff       	call   80016b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d65:	83 c4 18             	add    $0x18,%esp
  800d68:	53                   	push   %ebx
  800d69:	ff 75 10             	pushl  0x10(%ebp)
  800d6c:	e8 a9 f3 ff ff       	call   80011a <vcprintf>
	cprintf("\n");
  800d71:	c7 04 24 5a 10 80 00 	movl   $0x80105a,(%esp)
  800d78:	e8 ee f3 ff ff       	call   80016b <cprintf>
  800d7d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d80:	cc                   	int3   
  800d81:	eb fd                	jmp    800d80 <_panic+0x43>
  800d83:	66 90                	xchg   %ax,%ax
  800d85:	66 90                	xchg   %ax,%ax
  800d87:	66 90                	xchg   %ax,%ax
  800d89:	66 90                	xchg   %ax,%ax
  800d8b:	66 90                	xchg   %ax,%ax
  800d8d:	66 90                	xchg   %ax,%ax
  800d8f:	90                   	nop

00800d90 <__udivdi3>:
  800d90:	55                   	push   %ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	83 ec 10             	sub    $0x10,%esp
  800d96:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800d9a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800d9e:	8b 74 24 24          	mov    0x24(%esp),%esi
  800da2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800da6:	85 d2                	test   %edx,%edx
  800da8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800dac:	89 34 24             	mov    %esi,(%esp)
  800daf:	89 c8                	mov    %ecx,%eax
  800db1:	75 35                	jne    800de8 <__udivdi3+0x58>
  800db3:	39 f1                	cmp    %esi,%ecx
  800db5:	0f 87 bd 00 00 00    	ja     800e78 <__udivdi3+0xe8>
  800dbb:	85 c9                	test   %ecx,%ecx
  800dbd:	89 cd                	mov    %ecx,%ebp
  800dbf:	75 0b                	jne    800dcc <__udivdi3+0x3c>
  800dc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc6:	31 d2                	xor    %edx,%edx
  800dc8:	f7 f1                	div    %ecx
  800dca:	89 c5                	mov    %eax,%ebp
  800dcc:	89 f0                	mov    %esi,%eax
  800dce:	31 d2                	xor    %edx,%edx
  800dd0:	f7 f5                	div    %ebp
  800dd2:	89 c6                	mov    %eax,%esi
  800dd4:	89 f8                	mov    %edi,%eax
  800dd6:	f7 f5                	div    %ebp
  800dd8:	89 f2                	mov    %esi,%edx
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    
  800de1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800de8:	3b 14 24             	cmp    (%esp),%edx
  800deb:	77 7b                	ja     800e68 <__udivdi3+0xd8>
  800ded:	0f bd f2             	bsr    %edx,%esi
  800df0:	83 f6 1f             	xor    $0x1f,%esi
  800df3:	0f 84 97 00 00 00    	je     800e90 <__udivdi3+0x100>
  800df9:	bd 20 00 00 00       	mov    $0x20,%ebp
  800dfe:	89 d7                	mov    %edx,%edi
  800e00:	89 f1                	mov    %esi,%ecx
  800e02:	29 f5                	sub    %esi,%ebp
  800e04:	d3 e7                	shl    %cl,%edi
  800e06:	89 c2                	mov    %eax,%edx
  800e08:	89 e9                	mov    %ebp,%ecx
  800e0a:	d3 ea                	shr    %cl,%edx
  800e0c:	89 f1                	mov    %esi,%ecx
  800e0e:	09 fa                	or     %edi,%edx
  800e10:	8b 3c 24             	mov    (%esp),%edi
  800e13:	d3 e0                	shl    %cl,%eax
  800e15:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e19:	89 e9                	mov    %ebp,%ecx
  800e1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e1f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e23:	89 fa                	mov    %edi,%edx
  800e25:	d3 ea                	shr    %cl,%edx
  800e27:	89 f1                	mov    %esi,%ecx
  800e29:	d3 e7                	shl    %cl,%edi
  800e2b:	89 e9                	mov    %ebp,%ecx
  800e2d:	d3 e8                	shr    %cl,%eax
  800e2f:	09 c7                	or     %eax,%edi
  800e31:	89 f8                	mov    %edi,%eax
  800e33:	f7 74 24 08          	divl   0x8(%esp)
  800e37:	89 d5                	mov    %edx,%ebp
  800e39:	89 c7                	mov    %eax,%edi
  800e3b:	f7 64 24 0c          	mull   0xc(%esp)
  800e3f:	39 d5                	cmp    %edx,%ebp
  800e41:	89 14 24             	mov    %edx,(%esp)
  800e44:	72 11                	jb     800e57 <__udivdi3+0xc7>
  800e46:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e4a:	89 f1                	mov    %esi,%ecx
  800e4c:	d3 e2                	shl    %cl,%edx
  800e4e:	39 c2                	cmp    %eax,%edx
  800e50:	73 5e                	jae    800eb0 <__udivdi3+0x120>
  800e52:	3b 2c 24             	cmp    (%esp),%ebp
  800e55:	75 59                	jne    800eb0 <__udivdi3+0x120>
  800e57:	8d 47 ff             	lea    -0x1(%edi),%eax
  800e5a:	31 f6                	xor    %esi,%esi
  800e5c:	89 f2                	mov    %esi,%edx
  800e5e:	83 c4 10             	add    $0x10,%esp
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    
  800e65:	8d 76 00             	lea    0x0(%esi),%esi
  800e68:	31 f6                	xor    %esi,%esi
  800e6a:	31 c0                	xor    %eax,%eax
  800e6c:	89 f2                	mov    %esi,%edx
  800e6e:	83 c4 10             	add    $0x10,%esp
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    
  800e75:	8d 76 00             	lea    0x0(%esi),%esi
  800e78:	89 f2                	mov    %esi,%edx
  800e7a:	31 f6                	xor    %esi,%esi
  800e7c:	89 f8                	mov    %edi,%eax
  800e7e:	f7 f1                	div    %ecx
  800e80:	89 f2                	mov    %esi,%edx
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e94:	76 0b                	jbe    800ea1 <__udivdi3+0x111>
  800e96:	31 c0                	xor    %eax,%eax
  800e98:	3b 14 24             	cmp    (%esp),%edx
  800e9b:	0f 83 37 ff ff ff    	jae    800dd8 <__udivdi3+0x48>
  800ea1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea6:	e9 2d ff ff ff       	jmp    800dd8 <__udivdi3+0x48>
  800eab:	90                   	nop
  800eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 f8                	mov    %edi,%eax
  800eb2:	31 f6                	xor    %esi,%esi
  800eb4:	e9 1f ff ff ff       	jmp    800dd8 <__udivdi3+0x48>
  800eb9:	66 90                	xchg   %ax,%ax
  800ebb:	66 90                	xchg   %ax,%ax
  800ebd:	66 90                	xchg   %ax,%ax
  800ebf:	90                   	nop

00800ec0 <__umoddi3>:
  800ec0:	55                   	push   %ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	83 ec 20             	sub    $0x20,%esp
  800ec6:	8b 44 24 34          	mov    0x34(%esp),%eax
  800eca:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800ece:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ed2:	89 c6                	mov    %eax,%esi
  800ed4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800edc:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800ee0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ee4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800ee8:	89 74 24 18          	mov    %esi,0x18(%esp)
  800eec:	85 c0                	test   %eax,%eax
  800eee:	89 c2                	mov    %eax,%edx
  800ef0:	75 1e                	jne    800f10 <__umoddi3+0x50>
  800ef2:	39 f7                	cmp    %esi,%edi
  800ef4:	76 52                	jbe    800f48 <__umoddi3+0x88>
  800ef6:	89 c8                	mov    %ecx,%eax
  800ef8:	89 f2                	mov    %esi,%edx
  800efa:	f7 f7                	div    %edi
  800efc:	89 d0                	mov    %edx,%eax
  800efe:	31 d2                	xor    %edx,%edx
  800f00:	83 c4 20             	add    $0x20,%esp
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    
  800f07:	89 f6                	mov    %esi,%esi
  800f09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f10:	39 f0                	cmp    %esi,%eax
  800f12:	77 5c                	ja     800f70 <__umoddi3+0xb0>
  800f14:	0f bd e8             	bsr    %eax,%ebp
  800f17:	83 f5 1f             	xor    $0x1f,%ebp
  800f1a:	75 64                	jne    800f80 <__umoddi3+0xc0>
  800f1c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800f20:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800f24:	0f 86 f6 00 00 00    	jbe    801020 <__umoddi3+0x160>
  800f2a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800f2e:	0f 82 ec 00 00 00    	jb     801020 <__umoddi3+0x160>
  800f34:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f38:	8b 54 24 18          	mov    0x18(%esp),%edx
  800f3c:	83 c4 20             	add    $0x20,%esp
  800f3f:	5e                   	pop    %esi
  800f40:	5f                   	pop    %edi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    
  800f43:	90                   	nop
  800f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f48:	85 ff                	test   %edi,%edi
  800f4a:	89 fd                	mov    %edi,%ebp
  800f4c:	75 0b                	jne    800f59 <__umoddi3+0x99>
  800f4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	f7 f7                	div    %edi
  800f57:	89 c5                	mov    %eax,%ebp
  800f59:	8b 44 24 10          	mov    0x10(%esp),%eax
  800f5d:	31 d2                	xor    %edx,%edx
  800f5f:	f7 f5                	div    %ebp
  800f61:	89 c8                	mov    %ecx,%eax
  800f63:	f7 f5                	div    %ebp
  800f65:	eb 95                	jmp    800efc <__umoddi3+0x3c>
  800f67:	89 f6                	mov    %esi,%esi
  800f69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f70:	89 c8                	mov    %ecx,%eax
  800f72:	89 f2                	mov    %esi,%edx
  800f74:	83 c4 20             	add    $0x20,%esp
  800f77:	5e                   	pop    %esi
  800f78:	5f                   	pop    %edi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    
  800f7b:	90                   	nop
  800f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f80:	b8 20 00 00 00       	mov    $0x20,%eax
  800f85:	89 e9                	mov    %ebp,%ecx
  800f87:	29 e8                	sub    %ebp,%eax
  800f89:	d3 e2                	shl    %cl,%edx
  800f8b:	89 c7                	mov    %eax,%edi
  800f8d:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f91:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f95:	89 f9                	mov    %edi,%ecx
  800f97:	d3 e8                	shr    %cl,%eax
  800f99:	89 c1                	mov    %eax,%ecx
  800f9b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f9f:	09 d1                	or     %edx,%ecx
  800fa1:	89 fa                	mov    %edi,%edx
  800fa3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fa7:	89 e9                	mov    %ebp,%ecx
  800fa9:	d3 e0                	shl    %cl,%eax
  800fab:	89 f9                	mov    %edi,%ecx
  800fad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fb1:	89 f0                	mov    %esi,%eax
  800fb3:	d3 e8                	shr    %cl,%eax
  800fb5:	89 e9                	mov    %ebp,%ecx
  800fb7:	89 c7                	mov    %eax,%edi
  800fb9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800fbd:	d3 e6                	shl    %cl,%esi
  800fbf:	89 d1                	mov    %edx,%ecx
  800fc1:	89 fa                	mov    %edi,%edx
  800fc3:	d3 e8                	shr    %cl,%eax
  800fc5:	89 e9                	mov    %ebp,%ecx
  800fc7:	09 f0                	or     %esi,%eax
  800fc9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800fcd:	f7 74 24 10          	divl   0x10(%esp)
  800fd1:	d3 e6                	shl    %cl,%esi
  800fd3:	89 d1                	mov    %edx,%ecx
  800fd5:	f7 64 24 0c          	mull   0xc(%esp)
  800fd9:	39 d1                	cmp    %edx,%ecx
  800fdb:	89 74 24 14          	mov    %esi,0x14(%esp)
  800fdf:	89 d7                	mov    %edx,%edi
  800fe1:	89 c6                	mov    %eax,%esi
  800fe3:	72 0a                	jb     800fef <__umoddi3+0x12f>
  800fe5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800fe9:	73 10                	jae    800ffb <__umoddi3+0x13b>
  800feb:	39 d1                	cmp    %edx,%ecx
  800fed:	75 0c                	jne    800ffb <__umoddi3+0x13b>
  800fef:	89 d7                	mov    %edx,%edi
  800ff1:	89 c6                	mov    %eax,%esi
  800ff3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800ff7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800ffb:	89 ca                	mov    %ecx,%edx
  800ffd:	89 e9                	mov    %ebp,%ecx
  800fff:	8b 44 24 14          	mov    0x14(%esp),%eax
  801003:	29 f0                	sub    %esi,%eax
  801005:	19 fa                	sbb    %edi,%edx
  801007:	d3 e8                	shr    %cl,%eax
  801009:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80100e:	89 d7                	mov    %edx,%edi
  801010:	d3 e7                	shl    %cl,%edi
  801012:	89 e9                	mov    %ebp,%ecx
  801014:	09 f8                	or     %edi,%eax
  801016:	d3 ea                	shr    %cl,%edx
  801018:	83 c4 20             	add    $0x20,%esp
  80101b:	5e                   	pop    %esi
  80101c:	5f                   	pop    %edi
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    
  80101f:	90                   	nop
  801020:	8b 74 24 10          	mov    0x10(%esp),%esi
  801024:	29 f9                	sub    %edi,%ecx
  801026:	19 c6                	sbb    %eax,%esi
  801028:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80102c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801030:	e9 ff fe ff ff       	jmp    800f34 <__umoddi3+0x74>
