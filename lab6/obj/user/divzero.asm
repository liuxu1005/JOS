
obj/user/divzero.debug:     file format elf32-i386


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
  800039:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 40 23 80 00       	push   $0x802340
  800056:	e8 f8 00 00 00       	call   800153 <cprintf>
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
  80006b:	e8 35 0a 00 00       	call   800aa5 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000a9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ac:	e8 96 0e 00 00       	call   800f47 <close_all>
	sys_env_destroy(0);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 a9 09 00 00       	call   800a64 <sys_env_destroy>
  8000bb:	83 c4 10             	add    $0x10,%esp
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	75 1a                	jne    8000f9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	68 ff 00 00 00       	push   $0xff
  8000e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ea:	50                   	push   %eax
  8000eb:	e8 37 09 00 00       	call   800a27 <sys_cputs>
		b->idx = 0;
  8000f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800100:	c9                   	leave  
  800101:	c3                   	ret    

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	ff 75 0c             	pushl  0xc(%ebp)
  800122:	ff 75 08             	pushl  0x8(%ebp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	68 c0 00 80 00       	push   $0x8000c0
  800131:	e8 4f 01 00 00       	call   800285 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800136:	83 c4 08             	add    $0x8,%esp
  800139:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	e8 dc 08 00 00       	call   800a27 <sys_cputs>

	return b.cnt;
}
  80014b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	50                   	push   %eax
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	e8 9d ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 1c             	sub    $0x1c,%esp
  800170:	89 c7                	mov    %eax,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 d1                	mov    %edx,%ecx
  80017c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800182:	8b 45 10             	mov    0x10(%ebp),%eax
  800185:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800188:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800192:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800195:	72 05                	jb     80019c <printnum+0x35>
  800197:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80019a:	77 3e                	ja     8001da <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	ff 75 18             	pushl  0x18(%ebp)
  8001a2:	83 eb 01             	sub    $0x1,%ebx
  8001a5:	53                   	push   %ebx
  8001a6:	50                   	push   %eax
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b6:	e8 b5 1e 00 00       	call   802070 <__udivdi3>
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	52                   	push   %edx
  8001bf:	50                   	push   %eax
  8001c0:	89 f2                	mov    %esi,%edx
  8001c2:	89 f8                	mov    %edi,%eax
  8001c4:	e8 9e ff ff ff       	call   800167 <printnum>
  8001c9:	83 c4 20             	add    $0x20,%esp
  8001cc:	eb 13                	jmp    8001e1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	56                   	push   %esi
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	ff d7                	call   *%edi
  8001d7:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001da:	83 eb 01             	sub    $0x1,%ebx
  8001dd:	85 db                	test   %ebx,%ebx
  8001df:	7f ed                	jg     8001ce <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	56                   	push   %esi
  8001e5:	83 ec 04             	sub    $0x4,%esp
  8001e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f4:	e8 a7 1f 00 00       	call   8021a0 <__umoddi3>
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	0f be 80 58 23 80 00 	movsbl 0x802358(%eax),%eax
  800203:	50                   	push   %eax
  800204:	ff d7                	call   *%edi
  800206:	83 c4 10             	add    $0x10,%esp
}
  800209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020c:	5b                   	pop    %ebx
  80020d:	5e                   	pop    %esi
  80020e:	5f                   	pop    %edi
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    

00800211 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800214:	83 fa 01             	cmp    $0x1,%edx
  800217:	7e 0e                	jle    800227 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800219:	8b 10                	mov    (%eax),%edx
  80021b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021e:	89 08                	mov    %ecx,(%eax)
  800220:	8b 02                	mov    (%edx),%eax
  800222:	8b 52 04             	mov    0x4(%edx),%edx
  800225:	eb 22                	jmp    800249 <getuint+0x38>
	else if (lflag)
  800227:	85 d2                	test   %edx,%edx
  800229:	74 10                	je     80023b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80022b:	8b 10                	mov    (%eax),%edx
  80022d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800230:	89 08                	mov    %ecx,(%eax)
  800232:	8b 02                	mov    (%edx),%eax
  800234:	ba 00 00 00 00       	mov    $0x0,%edx
  800239:	eb 0e                	jmp    800249 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80023b:	8b 10                	mov    (%eax),%edx
  80023d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800240:	89 08                	mov    %ecx,(%eax)
  800242:	8b 02                	mov    (%edx),%eax
  800244:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800251:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800255:	8b 10                	mov    (%eax),%edx
  800257:	3b 50 04             	cmp    0x4(%eax),%edx
  80025a:	73 0a                	jae    800266 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025f:	89 08                	mov    %ecx,(%eax)
  800261:	8b 45 08             	mov    0x8(%ebp),%eax
  800264:	88 02                	mov    %al,(%edx)
}
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80026e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800271:	50                   	push   %eax
  800272:	ff 75 10             	pushl  0x10(%ebp)
  800275:	ff 75 0c             	pushl  0xc(%ebp)
  800278:	ff 75 08             	pushl  0x8(%ebp)
  80027b:	e8 05 00 00 00       	call   800285 <vprintfmt>
	va_end(ap);
  800280:	83 c4 10             	add    $0x10,%esp
}
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	57                   	push   %edi
  800289:	56                   	push   %esi
  80028a:	53                   	push   %ebx
  80028b:	83 ec 2c             	sub    $0x2c,%esp
  80028e:	8b 75 08             	mov    0x8(%ebp),%esi
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800294:	8b 7d 10             	mov    0x10(%ebp),%edi
  800297:	eb 12                	jmp    8002ab <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800299:	85 c0                	test   %eax,%eax
  80029b:	0f 84 90 03 00 00    	je     800631 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	53                   	push   %ebx
  8002a5:	50                   	push   %eax
  8002a6:	ff d6                	call   *%esi
  8002a8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ab:	83 c7 01             	add    $0x1,%edi
  8002ae:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b2:	83 f8 25             	cmp    $0x25,%eax
  8002b5:	75 e2                	jne    800299 <vprintfmt+0x14>
  8002b7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002bb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002c9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d5:	eb 07                	jmp    8002de <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002da:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002de:	8d 47 01             	lea    0x1(%edi),%eax
  8002e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e4:	0f b6 07             	movzbl (%edi),%eax
  8002e7:	0f b6 c8             	movzbl %al,%ecx
  8002ea:	83 e8 23             	sub    $0x23,%eax
  8002ed:	3c 55                	cmp    $0x55,%al
  8002ef:	0f 87 21 03 00 00    	ja     800616 <vprintfmt+0x391>
  8002f5:	0f b6 c0             	movzbl %al,%eax
  8002f8:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  8002ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800302:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800306:	eb d6                	jmp    8002de <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030b:	b8 00 00 00 00       	mov    $0x0,%eax
  800310:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800313:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800316:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80031a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80031d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800320:	83 fa 09             	cmp    $0x9,%edx
  800323:	77 39                	ja     80035e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800325:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800328:	eb e9                	jmp    800313 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032a:	8b 45 14             	mov    0x14(%ebp),%eax
  80032d:	8d 48 04             	lea    0x4(%eax),%ecx
  800330:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800333:	8b 00                	mov    (%eax),%eax
  800335:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80033b:	eb 27                	jmp    800364 <vprintfmt+0xdf>
  80033d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800340:	85 c0                	test   %eax,%eax
  800342:	b9 00 00 00 00       	mov    $0x0,%ecx
  800347:	0f 49 c8             	cmovns %eax,%ecx
  80034a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800350:	eb 8c                	jmp    8002de <vprintfmt+0x59>
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800355:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80035c:	eb 80                	jmp    8002de <vprintfmt+0x59>
  80035e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800361:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800364:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800368:	0f 89 70 ff ff ff    	jns    8002de <vprintfmt+0x59>
				width = precision, precision = -1;
  80036e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800371:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800374:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037b:	e9 5e ff ff ff       	jmp    8002de <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800380:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800386:	e9 53 ff ff ff       	jmp    8002de <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038b:	8b 45 14             	mov    0x14(%ebp),%eax
  80038e:	8d 50 04             	lea    0x4(%eax),%edx
  800391:	89 55 14             	mov    %edx,0x14(%ebp)
  800394:	83 ec 08             	sub    $0x8,%esp
  800397:	53                   	push   %ebx
  800398:	ff 30                	pushl  (%eax)
  80039a:	ff d6                	call   *%esi
			break;
  80039c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a2:	e9 04 ff ff ff       	jmp    8002ab <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003aa:	8d 50 04             	lea    0x4(%eax),%edx
  8003ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b0:	8b 00                	mov    (%eax),%eax
  8003b2:	99                   	cltd   
  8003b3:	31 d0                	xor    %edx,%eax
  8003b5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b7:	83 f8 0f             	cmp    $0xf,%eax
  8003ba:	7f 0b                	jg     8003c7 <vprintfmt+0x142>
  8003bc:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8003c3:	85 d2                	test   %edx,%edx
  8003c5:	75 18                	jne    8003df <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003c7:	50                   	push   %eax
  8003c8:	68 70 23 80 00       	push   $0x802370
  8003cd:	53                   	push   %ebx
  8003ce:	56                   	push   %esi
  8003cf:	e8 94 fe ff ff       	call   800268 <printfmt>
  8003d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003da:	e9 cc fe ff ff       	jmp    8002ab <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003df:	52                   	push   %edx
  8003e0:	68 75 27 80 00       	push   $0x802775
  8003e5:	53                   	push   %ebx
  8003e6:	56                   	push   %esi
  8003e7:	e8 7c fe ff ff       	call   800268 <printfmt>
  8003ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f2:	e9 b4 fe ff ff       	jmp    8002ab <vprintfmt+0x26>
  8003f7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fd:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 50 04             	lea    0x4(%eax),%edx
  800406:	89 55 14             	mov    %edx,0x14(%ebp)
  800409:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80040b:	85 ff                	test   %edi,%edi
  80040d:	ba 69 23 80 00       	mov    $0x802369,%edx
  800412:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800415:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800419:	0f 84 92 00 00 00    	je     8004b1 <vprintfmt+0x22c>
  80041f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800423:	0f 8e 96 00 00 00    	jle    8004bf <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	51                   	push   %ecx
  80042d:	57                   	push   %edi
  80042e:	e8 86 02 00 00       	call   8006b9 <strnlen>
  800433:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800436:	29 c1                	sub    %eax,%ecx
  800438:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80043b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800442:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800445:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800448:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044a:	eb 0f                	jmp    80045b <vprintfmt+0x1d6>
					putch(padc, putdat);
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	53                   	push   %ebx
  800450:	ff 75 e0             	pushl  -0x20(%ebp)
  800453:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	83 ef 01             	sub    $0x1,%edi
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	85 ff                	test   %edi,%edi
  80045d:	7f ed                	jg     80044c <vprintfmt+0x1c7>
  80045f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800462:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800465:	85 c9                	test   %ecx,%ecx
  800467:	b8 00 00 00 00       	mov    $0x0,%eax
  80046c:	0f 49 c1             	cmovns %ecx,%eax
  80046f:	29 c1                	sub    %eax,%ecx
  800471:	89 75 08             	mov    %esi,0x8(%ebp)
  800474:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800477:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047a:	89 cb                	mov    %ecx,%ebx
  80047c:	eb 4d                	jmp    8004cb <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800482:	74 1b                	je     80049f <vprintfmt+0x21a>
  800484:	0f be c0             	movsbl %al,%eax
  800487:	83 e8 20             	sub    $0x20,%eax
  80048a:	83 f8 5e             	cmp    $0x5e,%eax
  80048d:	76 10                	jbe    80049f <vprintfmt+0x21a>
					putch('?', putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	ff 75 0c             	pushl  0xc(%ebp)
  800495:	6a 3f                	push   $0x3f
  800497:	ff 55 08             	call   *0x8(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	eb 0d                	jmp    8004ac <vprintfmt+0x227>
				else
					putch(ch, putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	ff 75 0c             	pushl  0xc(%ebp)
  8004a5:	52                   	push   %edx
  8004a6:	ff 55 08             	call   *0x8(%ebp)
  8004a9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ac:	83 eb 01             	sub    $0x1,%ebx
  8004af:	eb 1a                	jmp    8004cb <vprintfmt+0x246>
  8004b1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ba:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bd:	eb 0c                	jmp    8004cb <vprintfmt+0x246>
  8004bf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cb:	83 c7 01             	add    $0x1,%edi
  8004ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d2:	0f be d0             	movsbl %al,%edx
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	74 23                	je     8004fc <vprintfmt+0x277>
  8004d9:	85 f6                	test   %esi,%esi
  8004db:	78 a1                	js     80047e <vprintfmt+0x1f9>
  8004dd:	83 ee 01             	sub    $0x1,%esi
  8004e0:	79 9c                	jns    80047e <vprintfmt+0x1f9>
  8004e2:	89 df                	mov    %ebx,%edi
  8004e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ea:	eb 18                	jmp    800504 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	53                   	push   %ebx
  8004f0:	6a 20                	push   $0x20
  8004f2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f4:	83 ef 01             	sub    $0x1,%edi
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	eb 08                	jmp    800504 <vprintfmt+0x27f>
  8004fc:	89 df                	mov    %ebx,%edi
  8004fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800501:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800504:	85 ff                	test   %edi,%edi
  800506:	7f e4                	jg     8004ec <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050b:	e9 9b fd ff ff       	jmp    8002ab <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800510:	83 fa 01             	cmp    $0x1,%edx
  800513:	7e 16                	jle    80052b <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 50 08             	lea    0x8(%eax),%edx
  80051b:	89 55 14             	mov    %edx,0x14(%ebp)
  80051e:	8b 50 04             	mov    0x4(%eax),%edx
  800521:	8b 00                	mov    (%eax),%eax
  800523:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800526:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800529:	eb 32                	jmp    80055d <vprintfmt+0x2d8>
	else if (lflag)
  80052b:	85 d2                	test   %edx,%edx
  80052d:	74 18                	je     800547 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8d 50 04             	lea    0x4(%eax),%edx
  800535:	89 55 14             	mov    %edx,0x14(%ebp)
  800538:	8b 00                	mov    (%eax),%eax
  80053a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053d:	89 c1                	mov    %eax,%ecx
  80053f:	c1 f9 1f             	sar    $0x1f,%ecx
  800542:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800545:	eb 16                	jmp    80055d <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 50 04             	lea    0x4(%eax),%edx
  80054d:	89 55 14             	mov    %edx,0x14(%ebp)
  800550:	8b 00                	mov    (%eax),%eax
  800552:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800555:	89 c1                	mov    %eax,%ecx
  800557:	c1 f9 1f             	sar    $0x1f,%ecx
  80055a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800560:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800563:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800568:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056c:	79 74                	jns    8005e2 <vprintfmt+0x35d>
				putch('-', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	53                   	push   %ebx
  800572:	6a 2d                	push   $0x2d
  800574:	ff d6                	call   *%esi
				num = -(long long) num;
  800576:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800579:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80057c:	f7 d8                	neg    %eax
  80057e:	83 d2 00             	adc    $0x0,%edx
  800581:	f7 da                	neg    %edx
  800583:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800586:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80058b:	eb 55                	jmp    8005e2 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058d:	8d 45 14             	lea    0x14(%ebp),%eax
  800590:	e8 7c fc ff ff       	call   800211 <getuint>
			base = 10;
  800595:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80059a:	eb 46                	jmp    8005e2 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80059c:	8d 45 14             	lea    0x14(%ebp),%eax
  80059f:	e8 6d fc ff ff       	call   800211 <getuint>
                        base = 8;
  8005a4:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005a9:	eb 37                	jmp    8005e2 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	53                   	push   %ebx
  8005af:	6a 30                	push   $0x30
  8005b1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005b3:	83 c4 08             	add    $0x8,%esp
  8005b6:	53                   	push   %ebx
  8005b7:	6a 78                	push   $0x78
  8005b9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 04             	lea    0x4(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005cb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ce:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005d3:	eb 0d                	jmp    8005e2 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d8:	e8 34 fc ff ff       	call   800211 <getuint>
			base = 16;
  8005dd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005e9:	57                   	push   %edi
  8005ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ed:	51                   	push   %ecx
  8005ee:	52                   	push   %edx
  8005ef:	50                   	push   %eax
  8005f0:	89 da                	mov    %ebx,%edx
  8005f2:	89 f0                	mov    %esi,%eax
  8005f4:	e8 6e fb ff ff       	call   800167 <printnum>
			break;
  8005f9:	83 c4 20             	add    $0x20,%esp
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ff:	e9 a7 fc ff ff       	jmp    8002ab <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	53                   	push   %ebx
  800608:	51                   	push   %ecx
  800609:	ff d6                	call   *%esi
			break;
  80060b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800611:	e9 95 fc ff ff       	jmp    8002ab <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	6a 25                	push   $0x25
  80061c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	eb 03                	jmp    800626 <vprintfmt+0x3a1>
  800623:	83 ef 01             	sub    $0x1,%edi
  800626:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80062a:	75 f7                	jne    800623 <vprintfmt+0x39e>
  80062c:	e9 7a fc ff ff       	jmp    8002ab <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800631:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800634:	5b                   	pop    %ebx
  800635:	5e                   	pop    %esi
  800636:	5f                   	pop    %edi
  800637:	5d                   	pop    %ebp
  800638:	c3                   	ret    

00800639 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800639:	55                   	push   %ebp
  80063a:	89 e5                	mov    %esp,%ebp
  80063c:	83 ec 18             	sub    $0x18,%esp
  80063f:	8b 45 08             	mov    0x8(%ebp),%eax
  800642:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800645:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800648:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80064c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80064f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800656:	85 c0                	test   %eax,%eax
  800658:	74 26                	je     800680 <vsnprintf+0x47>
  80065a:	85 d2                	test   %edx,%edx
  80065c:	7e 22                	jle    800680 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80065e:	ff 75 14             	pushl  0x14(%ebp)
  800661:	ff 75 10             	pushl  0x10(%ebp)
  800664:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800667:	50                   	push   %eax
  800668:	68 4b 02 80 00       	push   $0x80024b
  80066d:	e8 13 fc ff ff       	call   800285 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800672:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800675:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800678:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80067b:	83 c4 10             	add    $0x10,%esp
  80067e:	eb 05                	jmp    800685 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800680:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800685:	c9                   	leave  
  800686:	c3                   	ret    

00800687 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80068d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800690:	50                   	push   %eax
  800691:	ff 75 10             	pushl  0x10(%ebp)
  800694:	ff 75 0c             	pushl  0xc(%ebp)
  800697:	ff 75 08             	pushl  0x8(%ebp)
  80069a:	e8 9a ff ff ff       	call   800639 <vsnprintf>
	va_end(ap);

	return rc;
}
  80069f:	c9                   	leave  
  8006a0:	c3                   	ret    

008006a1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006a1:	55                   	push   %ebp
  8006a2:	89 e5                	mov    %esp,%ebp
  8006a4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ac:	eb 03                	jmp    8006b1 <strlen+0x10>
		n++;
  8006ae:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006b5:	75 f7                	jne    8006ae <strlen+0xd>
		n++;
	return n;
}
  8006b7:	5d                   	pop    %ebp
  8006b8:	c3                   	ret    

008006b9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
  8006bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c7:	eb 03                	jmp    8006cc <strnlen+0x13>
		n++;
  8006c9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006cc:	39 c2                	cmp    %eax,%edx
  8006ce:	74 08                	je     8006d8 <strnlen+0x1f>
  8006d0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006d4:	75 f3                	jne    8006c9 <strnlen+0x10>
  8006d6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	53                   	push   %ebx
  8006de:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006e4:	89 c2                	mov    %eax,%edx
  8006e6:	83 c2 01             	add    $0x1,%edx
  8006e9:	83 c1 01             	add    $0x1,%ecx
  8006ec:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006f0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006f3:	84 db                	test   %bl,%bl
  8006f5:	75 ef                	jne    8006e6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006f7:	5b                   	pop    %ebx
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	53                   	push   %ebx
  8006fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800701:	53                   	push   %ebx
  800702:	e8 9a ff ff ff       	call   8006a1 <strlen>
  800707:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80070a:	ff 75 0c             	pushl  0xc(%ebp)
  80070d:	01 d8                	add    %ebx,%eax
  80070f:	50                   	push   %eax
  800710:	e8 c5 ff ff ff       	call   8006da <strcpy>
	return dst;
}
  800715:	89 d8                	mov    %ebx,%eax
  800717:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	56                   	push   %esi
  800720:	53                   	push   %ebx
  800721:	8b 75 08             	mov    0x8(%ebp),%esi
  800724:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800727:	89 f3                	mov    %esi,%ebx
  800729:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80072c:	89 f2                	mov    %esi,%edx
  80072e:	eb 0f                	jmp    80073f <strncpy+0x23>
		*dst++ = *src;
  800730:	83 c2 01             	add    $0x1,%edx
  800733:	0f b6 01             	movzbl (%ecx),%eax
  800736:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800739:	80 39 01             	cmpb   $0x1,(%ecx)
  80073c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073f:	39 da                	cmp    %ebx,%edx
  800741:	75 ed                	jne    800730 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800743:	89 f0                	mov    %esi,%eax
  800745:	5b                   	pop    %ebx
  800746:	5e                   	pop    %esi
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	56                   	push   %esi
  80074d:	53                   	push   %ebx
  80074e:	8b 75 08             	mov    0x8(%ebp),%esi
  800751:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800754:	8b 55 10             	mov    0x10(%ebp),%edx
  800757:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800759:	85 d2                	test   %edx,%edx
  80075b:	74 21                	je     80077e <strlcpy+0x35>
  80075d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800761:	89 f2                	mov    %esi,%edx
  800763:	eb 09                	jmp    80076e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800765:	83 c2 01             	add    $0x1,%edx
  800768:	83 c1 01             	add    $0x1,%ecx
  80076b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80076e:	39 c2                	cmp    %eax,%edx
  800770:	74 09                	je     80077b <strlcpy+0x32>
  800772:	0f b6 19             	movzbl (%ecx),%ebx
  800775:	84 db                	test   %bl,%bl
  800777:	75 ec                	jne    800765 <strlcpy+0x1c>
  800779:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80077b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80077e:	29 f0                	sub    %esi,%eax
}
  800780:	5b                   	pop    %ebx
  800781:	5e                   	pop    %esi
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80078d:	eb 06                	jmp    800795 <strcmp+0x11>
		p++, q++;
  80078f:	83 c1 01             	add    $0x1,%ecx
  800792:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800795:	0f b6 01             	movzbl (%ecx),%eax
  800798:	84 c0                	test   %al,%al
  80079a:	74 04                	je     8007a0 <strcmp+0x1c>
  80079c:	3a 02                	cmp    (%edx),%al
  80079e:	74 ef                	je     80078f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a0:	0f b6 c0             	movzbl %al,%eax
  8007a3:	0f b6 12             	movzbl (%edx),%edx
  8007a6:	29 d0                	sub    %edx,%eax
}
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	53                   	push   %ebx
  8007ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b4:	89 c3                	mov    %eax,%ebx
  8007b6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b9:	eb 06                	jmp    8007c1 <strncmp+0x17>
		n--, p++, q++;
  8007bb:	83 c0 01             	add    $0x1,%eax
  8007be:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007c1:	39 d8                	cmp    %ebx,%eax
  8007c3:	74 15                	je     8007da <strncmp+0x30>
  8007c5:	0f b6 08             	movzbl (%eax),%ecx
  8007c8:	84 c9                	test   %cl,%cl
  8007ca:	74 04                	je     8007d0 <strncmp+0x26>
  8007cc:	3a 0a                	cmp    (%edx),%cl
  8007ce:	74 eb                	je     8007bb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d0:	0f b6 00             	movzbl (%eax),%eax
  8007d3:	0f b6 12             	movzbl (%edx),%edx
  8007d6:	29 d0                	sub    %edx,%eax
  8007d8:	eb 05                	jmp    8007df <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007df:	5b                   	pop    %ebx
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007ec:	eb 07                	jmp    8007f5 <strchr+0x13>
		if (*s == c)
  8007ee:	38 ca                	cmp    %cl,%dl
  8007f0:	74 0f                	je     800801 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007f2:	83 c0 01             	add    $0x1,%eax
  8007f5:	0f b6 10             	movzbl (%eax),%edx
  8007f8:	84 d2                	test   %dl,%dl
  8007fa:	75 f2                	jne    8007ee <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080d:	eb 03                	jmp    800812 <strfind+0xf>
  80080f:	83 c0 01             	add    $0x1,%eax
  800812:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800815:	84 d2                	test   %dl,%dl
  800817:	74 04                	je     80081d <strfind+0x1a>
  800819:	38 ca                	cmp    %cl,%dl
  80081b:	75 f2                	jne    80080f <strfind+0xc>
			break;
	return (char *) s;
}
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	57                   	push   %edi
  800823:	56                   	push   %esi
  800824:	53                   	push   %ebx
  800825:	8b 7d 08             	mov    0x8(%ebp),%edi
  800828:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80082b:	85 c9                	test   %ecx,%ecx
  80082d:	74 36                	je     800865 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80082f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800835:	75 28                	jne    80085f <memset+0x40>
  800837:	f6 c1 03             	test   $0x3,%cl
  80083a:	75 23                	jne    80085f <memset+0x40>
		c &= 0xFF;
  80083c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800840:	89 d3                	mov    %edx,%ebx
  800842:	c1 e3 08             	shl    $0x8,%ebx
  800845:	89 d6                	mov    %edx,%esi
  800847:	c1 e6 18             	shl    $0x18,%esi
  80084a:	89 d0                	mov    %edx,%eax
  80084c:	c1 e0 10             	shl    $0x10,%eax
  80084f:	09 f0                	or     %esi,%eax
  800851:	09 c2                	or     %eax,%edx
  800853:	89 d0                	mov    %edx,%eax
  800855:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800857:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80085a:	fc                   	cld    
  80085b:	f3 ab                	rep stos %eax,%es:(%edi)
  80085d:	eb 06                	jmp    800865 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80085f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800862:	fc                   	cld    
  800863:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800865:	89 f8                	mov    %edi,%eax
  800867:	5b                   	pop    %ebx
  800868:	5e                   	pop    %esi
  800869:	5f                   	pop    %edi
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	57                   	push   %edi
  800870:	56                   	push   %esi
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	8b 75 0c             	mov    0xc(%ebp),%esi
  800877:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80087a:	39 c6                	cmp    %eax,%esi
  80087c:	73 35                	jae    8008b3 <memmove+0x47>
  80087e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800881:	39 d0                	cmp    %edx,%eax
  800883:	73 2e                	jae    8008b3 <memmove+0x47>
		s += n;
		d += n;
  800885:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800888:	89 d6                	mov    %edx,%esi
  80088a:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80088c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800892:	75 13                	jne    8008a7 <memmove+0x3b>
  800894:	f6 c1 03             	test   $0x3,%cl
  800897:	75 0e                	jne    8008a7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800899:	83 ef 04             	sub    $0x4,%edi
  80089c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80089f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008a2:	fd                   	std    
  8008a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a5:	eb 09                	jmp    8008b0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008a7:	83 ef 01             	sub    $0x1,%edi
  8008aa:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ad:	fd                   	std    
  8008ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008b0:	fc                   	cld    
  8008b1:	eb 1d                	jmp    8008d0 <memmove+0x64>
  8008b3:	89 f2                	mov    %esi,%edx
  8008b5:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b7:	f6 c2 03             	test   $0x3,%dl
  8008ba:	75 0f                	jne    8008cb <memmove+0x5f>
  8008bc:	f6 c1 03             	test   $0x3,%cl
  8008bf:	75 0a                	jne    8008cb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008c1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008c4:	89 c7                	mov    %eax,%edi
  8008c6:	fc                   	cld    
  8008c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c9:	eb 05                	jmp    8008d0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008cb:	89 c7                	mov    %eax,%edi
  8008cd:	fc                   	cld    
  8008ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008d0:	5e                   	pop    %esi
  8008d1:	5f                   	pop    %edi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008d7:	ff 75 10             	pushl  0x10(%ebp)
  8008da:	ff 75 0c             	pushl  0xc(%ebp)
  8008dd:	ff 75 08             	pushl  0x8(%ebp)
  8008e0:	e8 87 ff ff ff       	call   80086c <memmove>
}
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    

008008e7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	56                   	push   %esi
  8008eb:	53                   	push   %ebx
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f2:	89 c6                	mov    %eax,%esi
  8008f4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f7:	eb 1a                	jmp    800913 <memcmp+0x2c>
		if (*s1 != *s2)
  8008f9:	0f b6 08             	movzbl (%eax),%ecx
  8008fc:	0f b6 1a             	movzbl (%edx),%ebx
  8008ff:	38 d9                	cmp    %bl,%cl
  800901:	74 0a                	je     80090d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800903:	0f b6 c1             	movzbl %cl,%eax
  800906:	0f b6 db             	movzbl %bl,%ebx
  800909:	29 d8                	sub    %ebx,%eax
  80090b:	eb 0f                	jmp    80091c <memcmp+0x35>
		s1++, s2++;
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800913:	39 f0                	cmp    %esi,%eax
  800915:	75 e2                	jne    8008f9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091c:	5b                   	pop    %ebx
  80091d:	5e                   	pop    %esi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800929:	89 c2                	mov    %eax,%edx
  80092b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80092e:	eb 07                	jmp    800937 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800930:	38 08                	cmp    %cl,(%eax)
  800932:	74 07                	je     80093b <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800934:	83 c0 01             	add    $0x1,%eax
  800937:	39 d0                	cmp    %edx,%eax
  800939:	72 f5                	jb     800930 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	53                   	push   %ebx
  800943:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800946:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800949:	eb 03                	jmp    80094e <strtol+0x11>
		s++;
  80094b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80094e:	0f b6 01             	movzbl (%ecx),%eax
  800951:	3c 09                	cmp    $0x9,%al
  800953:	74 f6                	je     80094b <strtol+0xe>
  800955:	3c 20                	cmp    $0x20,%al
  800957:	74 f2                	je     80094b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800959:	3c 2b                	cmp    $0x2b,%al
  80095b:	75 0a                	jne    800967 <strtol+0x2a>
		s++;
  80095d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800960:	bf 00 00 00 00       	mov    $0x0,%edi
  800965:	eb 10                	jmp    800977 <strtol+0x3a>
  800967:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80096c:	3c 2d                	cmp    $0x2d,%al
  80096e:	75 07                	jne    800977 <strtol+0x3a>
		s++, neg = 1;
  800970:	8d 49 01             	lea    0x1(%ecx),%ecx
  800973:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800977:	85 db                	test   %ebx,%ebx
  800979:	0f 94 c0             	sete   %al
  80097c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800982:	75 19                	jne    80099d <strtol+0x60>
  800984:	80 39 30             	cmpb   $0x30,(%ecx)
  800987:	75 14                	jne    80099d <strtol+0x60>
  800989:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80098d:	0f 85 82 00 00 00    	jne    800a15 <strtol+0xd8>
		s += 2, base = 16;
  800993:	83 c1 02             	add    $0x2,%ecx
  800996:	bb 10 00 00 00       	mov    $0x10,%ebx
  80099b:	eb 16                	jmp    8009b3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80099d:	84 c0                	test   %al,%al
  80099f:	74 12                	je     8009b3 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009a1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009a6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a9:	75 08                	jne    8009b3 <strtol+0x76>
		s++, base = 8;
  8009ab:	83 c1 01             	add    $0x1,%ecx
  8009ae:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009bb:	0f b6 11             	movzbl (%ecx),%edx
  8009be:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009c1:	89 f3                	mov    %esi,%ebx
  8009c3:	80 fb 09             	cmp    $0x9,%bl
  8009c6:	77 08                	ja     8009d0 <strtol+0x93>
			dig = *s - '0';
  8009c8:	0f be d2             	movsbl %dl,%edx
  8009cb:	83 ea 30             	sub    $0x30,%edx
  8009ce:	eb 22                	jmp    8009f2 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009d0:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009d3:	89 f3                	mov    %esi,%ebx
  8009d5:	80 fb 19             	cmp    $0x19,%bl
  8009d8:	77 08                	ja     8009e2 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009da:	0f be d2             	movsbl %dl,%edx
  8009dd:	83 ea 57             	sub    $0x57,%edx
  8009e0:	eb 10                	jmp    8009f2 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009e2:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009e5:	89 f3                	mov    %esi,%ebx
  8009e7:	80 fb 19             	cmp    $0x19,%bl
  8009ea:	77 16                	ja     800a02 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009ec:	0f be d2             	movsbl %dl,%edx
  8009ef:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009f2:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009f5:	7d 0f                	jge    800a06 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009f7:	83 c1 01             	add    $0x1,%ecx
  8009fa:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009fe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a00:	eb b9                	jmp    8009bb <strtol+0x7e>
  800a02:	89 c2                	mov    %eax,%edx
  800a04:	eb 02                	jmp    800a08 <strtol+0xcb>
  800a06:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0c:	74 0d                	je     800a1b <strtol+0xde>
		*endptr = (char *) s;
  800a0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a11:	89 0e                	mov    %ecx,(%esi)
  800a13:	eb 06                	jmp    800a1b <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a15:	84 c0                	test   %al,%al
  800a17:	75 92                	jne    8009ab <strtol+0x6e>
  800a19:	eb 98                	jmp    8009b3 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a1b:	f7 da                	neg    %edx
  800a1d:	85 ff                	test   %edi,%edi
  800a1f:	0f 45 c2             	cmovne %edx,%eax
}
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5f                   	pop    %edi
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a35:	8b 55 08             	mov    0x8(%ebp),%edx
  800a38:	89 c3                	mov    %eax,%ebx
  800a3a:	89 c7                	mov    %eax,%edi
  800a3c:	89 c6                	mov    %eax,%esi
  800a3e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	5f                   	pop    %edi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	57                   	push   %edi
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800a4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a50:	b8 01 00 00 00       	mov    $0x1,%eax
  800a55:	89 d1                	mov    %edx,%ecx
  800a57:	89 d3                	mov    %edx,%ebx
  800a59:	89 d7                	mov    %edx,%edi
  800a5b:	89 d6                	mov    %edx,%esi
  800a5d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5f                   	pop    %edi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800a6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a72:	b8 03 00 00 00       	mov    $0x3,%eax
  800a77:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7a:	89 cb                	mov    %ecx,%ebx
  800a7c:	89 cf                	mov    %ecx,%edi
  800a7e:	89 ce                	mov    %ecx,%esi
  800a80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a82:	85 c0                	test   %eax,%eax
  800a84:	7e 17                	jle    800a9d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a86:	83 ec 0c             	sub    $0xc,%esp
  800a89:	50                   	push   %eax
  800a8a:	6a 03                	push   $0x3
  800a8c:	68 9f 26 80 00       	push   $0x80269f
  800a91:	6a 22                	push   $0x22
  800a93:	68 bc 26 80 00       	push   $0x8026bc
  800a98:	e8 5b 14 00 00       	call   801ef8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800aab:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ab5:	89 d1                	mov    %edx,%ecx
  800ab7:	89 d3                	mov    %edx,%ebx
  800ab9:	89 d7                	mov    %edx,%edi
  800abb:	89 d6                	mov    %edx,%esi
  800abd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <sys_yield>:

void
sys_yield(void)
{      
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800aca:	ba 00 00 00 00       	mov    $0x0,%edx
  800acf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ad4:	89 d1                	mov    %edx,%ecx
  800ad6:	89 d3                	mov    %edx,%ebx
  800ad8:	89 d7                	mov    %edx,%edi
  800ada:	89 d6                	mov    %edx,%esi
  800adc:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800aec:	be 00 00 00 00       	mov    $0x0,%esi
  800af1:	b8 04 00 00 00       	mov    $0x4,%eax
  800af6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af9:	8b 55 08             	mov    0x8(%ebp),%edx
  800afc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800aff:	89 f7                	mov    %esi,%edi
  800b01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b03:	85 c0                	test   %eax,%eax
  800b05:	7e 17                	jle    800b1e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b07:	83 ec 0c             	sub    $0xc,%esp
  800b0a:	50                   	push   %eax
  800b0b:	6a 04                	push   $0x4
  800b0d:	68 9f 26 80 00       	push   $0x80269f
  800b12:	6a 22                	push   $0x22
  800b14:	68 bc 26 80 00       	push   $0x8026bc
  800b19:	e8 da 13 00 00       	call   801ef8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
  800b2c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b2f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b37:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b40:	8b 75 18             	mov    0x18(%ebp),%esi
  800b43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b45:	85 c0                	test   %eax,%eax
  800b47:	7e 17                	jle    800b60 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b49:	83 ec 0c             	sub    $0xc,%esp
  800b4c:	50                   	push   %eax
  800b4d:	6a 05                	push   $0x5
  800b4f:	68 9f 26 80 00       	push   $0x80269f
  800b54:	6a 22                	push   $0x22
  800b56:	68 bc 26 80 00       	push   $0x8026bc
  800b5b:	e8 98 13 00 00       	call   801ef8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5f                   	pop    %edi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
  800b6e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b76:	b8 06 00 00 00       	mov    $0x6,%eax
  800b7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b81:	89 df                	mov    %ebx,%edi
  800b83:	89 de                	mov    %ebx,%esi
  800b85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b87:	85 c0                	test   %eax,%eax
  800b89:	7e 17                	jle    800ba2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8b:	83 ec 0c             	sub    $0xc,%esp
  800b8e:	50                   	push   %eax
  800b8f:	6a 06                	push   $0x6
  800b91:	68 9f 26 80 00       	push   $0x80269f
  800b96:	6a 22                	push   $0x22
  800b98:	68 bc 26 80 00       	push   $0x8026bc
  800b9d:	e8 56 13 00 00       	call   801ef8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ba2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
  800bb0:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc3:	89 df                	mov    %ebx,%edi
  800bc5:	89 de                	mov    %ebx,%esi
  800bc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc9:	85 c0                	test   %eax,%eax
  800bcb:	7e 17                	jle    800be4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcd:	83 ec 0c             	sub    $0xc,%esp
  800bd0:	50                   	push   %eax
  800bd1:	6a 08                	push   $0x8
  800bd3:	68 9f 26 80 00       	push   $0x80269f
  800bd8:	6a 22                	push   $0x22
  800bda:	68 bc 26 80 00       	push   $0x8026bc
  800bdf:	e8 14 13 00 00       	call   801ef8 <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfa:	b8 09 00 00 00       	mov    $0x9,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	89 df                	mov    %ebx,%edi
  800c07:	89 de                	mov    %ebx,%esi
  800c09:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	7e 17                	jle    800c26 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0f:	83 ec 0c             	sub    $0xc,%esp
  800c12:	50                   	push   %eax
  800c13:	6a 09                	push   $0x9
  800c15:	68 9f 26 80 00       	push   $0x80269f
  800c1a:	6a 22                	push   $0x22
  800c1c:	68 bc 26 80 00       	push   $0x8026bc
  800c21:	e8 d2 12 00 00       	call   801ef8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	89 df                	mov    %ebx,%edi
  800c49:	89 de                	mov    %ebx,%esi
  800c4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	7e 17                	jle    800c68 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c51:	83 ec 0c             	sub    $0xc,%esp
  800c54:	50                   	push   %eax
  800c55:	6a 0a                	push   $0xa
  800c57:	68 9f 26 80 00       	push   $0x80269f
  800c5c:	6a 22                	push   $0x22
  800c5e:	68 bc 26 80 00       	push   $0x8026bc
  800c63:	e8 90 12 00 00       	call   801ef8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c76:	be 00 00 00 00       	mov    $0x0,%esi
  800c7b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	89 cb                	mov    %ecx,%ebx
  800cab:	89 cf                	mov    %ecx,%edi
  800cad:	89 ce                	mov    %ecx,%esi
  800caf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	7e 17                	jle    800ccc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb5:	83 ec 0c             	sub    $0xc,%esp
  800cb8:	50                   	push   %eax
  800cb9:	6a 0d                	push   $0xd
  800cbb:	68 9f 26 80 00       	push   $0x80269f
  800cc0:	6a 22                	push   $0x22
  800cc2:	68 bc 26 80 00       	push   $0x8026bc
  800cc7:	e8 2c 12 00 00       	call   801ef8 <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cda:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdf:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ce4:	89 d1                	mov    %edx,%ecx
  800ce6:	89 d3                	mov    %edx,%ebx
  800ce8:	89 d7                	mov    %edx,%edi
  800cea:	89 d6                	mov    %edx,%esi
  800cec:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d01:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	89 cb                	mov    %ecx,%ebx
  800d0b:	89 cf                	mov    %ecx,%edi
  800d0d:	89 ce                	mov    %ecx,%esi
  800d0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 17                	jle    800d2c <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 0f                	push   $0xf
  800d1b:	68 9f 26 80 00       	push   $0x80269f
  800d20:	6a 22                	push   $0x22
  800d22:	68 bc 26 80 00       	push   $0x8026bc
  800d27:	e8 cc 11 00 00       	call   801ef8 <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_recv>:

int
sys_recv(void *addr)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d42:	b8 10 00 00 00       	mov    $0x10,%eax
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	89 cb                	mov    %ecx,%ebx
  800d4c:	89 cf                	mov    %ecx,%edi
  800d4e:	89 ce                	mov    %ecx,%esi
  800d50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7e 17                	jle    800d6d <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	83 ec 0c             	sub    $0xc,%esp
  800d59:	50                   	push   %eax
  800d5a:	6a 10                	push   $0x10
  800d5c:	68 9f 26 80 00       	push   $0x80269f
  800d61:	6a 22                	push   $0x22
  800d63:	68 bc 26 80 00       	push   $0x8026bc
  800d68:	e8 8b 11 00 00       	call   801ef8 <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d78:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7b:	05 00 00 00 30       	add    $0x30000000,%eax
  800d80:	c1 e8 0c             	shr    $0xc,%eax
}
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800d90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d95:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800da7:	89 c2                	mov    %eax,%edx
  800da9:	c1 ea 16             	shr    $0x16,%edx
  800dac:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db3:	f6 c2 01             	test   $0x1,%dl
  800db6:	74 11                	je     800dc9 <fd_alloc+0x2d>
  800db8:	89 c2                	mov    %eax,%edx
  800dba:	c1 ea 0c             	shr    $0xc,%edx
  800dbd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc4:	f6 c2 01             	test   $0x1,%dl
  800dc7:	75 09                	jne    800dd2 <fd_alloc+0x36>
			*fd_store = fd;
  800dc9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd0:	eb 17                	jmp    800de9 <fd_alloc+0x4d>
  800dd2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dd7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ddc:	75 c9                	jne    800da7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dde:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800de4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800df1:	83 f8 1f             	cmp    $0x1f,%eax
  800df4:	77 36                	ja     800e2c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df6:	c1 e0 0c             	shl    $0xc,%eax
  800df9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dfe:	89 c2                	mov    %eax,%edx
  800e00:	c1 ea 16             	shr    $0x16,%edx
  800e03:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e0a:	f6 c2 01             	test   $0x1,%dl
  800e0d:	74 24                	je     800e33 <fd_lookup+0x48>
  800e0f:	89 c2                	mov    %eax,%edx
  800e11:	c1 ea 0c             	shr    $0xc,%edx
  800e14:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1b:	f6 c2 01             	test   $0x1,%dl
  800e1e:	74 1a                	je     800e3a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e23:	89 02                	mov    %eax,(%edx)
	return 0;
  800e25:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2a:	eb 13                	jmp    800e3f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e31:	eb 0c                	jmp    800e3f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e38:	eb 05                	jmp    800e3f <fd_lookup+0x54>
  800e3a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	83 ec 08             	sub    $0x8,%esp
  800e47:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800e4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4f:	eb 13                	jmp    800e64 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800e51:	39 08                	cmp    %ecx,(%eax)
  800e53:	75 0c                	jne    800e61 <dev_lookup+0x20>
			*dev = devtab[i];
  800e55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e58:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5f:	eb 36                	jmp    800e97 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e61:	83 c2 01             	add    $0x1,%edx
  800e64:	8b 04 95 48 27 80 00 	mov    0x802748(,%edx,4),%eax
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	75 e2                	jne    800e51 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e6f:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800e74:	8b 40 48             	mov    0x48(%eax),%eax
  800e77:	83 ec 04             	sub    $0x4,%esp
  800e7a:	51                   	push   %ecx
  800e7b:	50                   	push   %eax
  800e7c:	68 cc 26 80 00       	push   $0x8026cc
  800e81:	e8 cd f2 ff ff       	call   800153 <cprintf>
	*dev = 0;
  800e86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e89:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e8f:	83 c4 10             	add    $0x10,%esp
  800e92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e97:	c9                   	leave  
  800e98:	c3                   	ret    

00800e99 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	56                   	push   %esi
  800e9d:	53                   	push   %ebx
  800e9e:	83 ec 10             	sub    $0x10,%esp
  800ea1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eaa:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eab:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eb1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb4:	50                   	push   %eax
  800eb5:	e8 31 ff ff ff       	call   800deb <fd_lookup>
  800eba:	83 c4 08             	add    $0x8,%esp
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	78 05                	js     800ec6 <fd_close+0x2d>
	    || fd != fd2)
  800ec1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ec4:	74 0c                	je     800ed2 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ec6:	84 db                	test   %bl,%bl
  800ec8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ecd:	0f 44 c2             	cmove  %edx,%eax
  800ed0:	eb 41                	jmp    800f13 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ed2:	83 ec 08             	sub    $0x8,%esp
  800ed5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ed8:	50                   	push   %eax
  800ed9:	ff 36                	pushl  (%esi)
  800edb:	e8 61 ff ff ff       	call   800e41 <dev_lookup>
  800ee0:	89 c3                	mov    %eax,%ebx
  800ee2:	83 c4 10             	add    $0x10,%esp
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	78 1a                	js     800f03 <fd_close+0x6a>
		if (dev->dev_close)
  800ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eec:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800eef:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	74 0b                	je     800f03 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ef8:	83 ec 0c             	sub    $0xc,%esp
  800efb:	56                   	push   %esi
  800efc:	ff d0                	call   *%eax
  800efe:	89 c3                	mov    %eax,%ebx
  800f00:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f03:	83 ec 08             	sub    $0x8,%esp
  800f06:	56                   	push   %esi
  800f07:	6a 00                	push   $0x0
  800f09:	e8 5a fc ff ff       	call   800b68 <sys_page_unmap>
	return r;
  800f0e:	83 c4 10             	add    $0x10,%esp
  800f11:	89 d8                	mov    %ebx,%eax
}
  800f13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f23:	50                   	push   %eax
  800f24:	ff 75 08             	pushl  0x8(%ebp)
  800f27:	e8 bf fe ff ff       	call   800deb <fd_lookup>
  800f2c:	89 c2                	mov    %eax,%edx
  800f2e:	83 c4 08             	add    $0x8,%esp
  800f31:	85 d2                	test   %edx,%edx
  800f33:	78 10                	js     800f45 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800f35:	83 ec 08             	sub    $0x8,%esp
  800f38:	6a 01                	push   $0x1
  800f3a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f3d:	e8 57 ff ff ff       	call   800e99 <fd_close>
  800f42:	83 c4 10             	add    $0x10,%esp
}
  800f45:	c9                   	leave  
  800f46:	c3                   	ret    

00800f47 <close_all>:

void
close_all(void)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f4e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f53:	83 ec 0c             	sub    $0xc,%esp
  800f56:	53                   	push   %ebx
  800f57:	e8 be ff ff ff       	call   800f1a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f5c:	83 c3 01             	add    $0x1,%ebx
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	83 fb 20             	cmp    $0x20,%ebx
  800f65:	75 ec                	jne    800f53 <close_all+0xc>
		close(i);
}
  800f67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    

00800f6c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	57                   	push   %edi
  800f70:	56                   	push   %esi
  800f71:	53                   	push   %ebx
  800f72:	83 ec 2c             	sub    $0x2c,%esp
  800f75:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f78:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f7b:	50                   	push   %eax
  800f7c:	ff 75 08             	pushl  0x8(%ebp)
  800f7f:	e8 67 fe ff ff       	call   800deb <fd_lookup>
  800f84:	89 c2                	mov    %eax,%edx
  800f86:	83 c4 08             	add    $0x8,%esp
  800f89:	85 d2                	test   %edx,%edx
  800f8b:	0f 88 c1 00 00 00    	js     801052 <dup+0xe6>
		return r;
	close(newfdnum);
  800f91:	83 ec 0c             	sub    $0xc,%esp
  800f94:	56                   	push   %esi
  800f95:	e8 80 ff ff ff       	call   800f1a <close>

	newfd = INDEX2FD(newfdnum);
  800f9a:	89 f3                	mov    %esi,%ebx
  800f9c:	c1 e3 0c             	shl    $0xc,%ebx
  800f9f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fa5:	83 c4 04             	add    $0x4,%esp
  800fa8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fab:	e8 d5 fd ff ff       	call   800d85 <fd2data>
  800fb0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fb2:	89 1c 24             	mov    %ebx,(%esp)
  800fb5:	e8 cb fd ff ff       	call   800d85 <fd2data>
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fc0:	89 f8                	mov    %edi,%eax
  800fc2:	c1 e8 16             	shr    $0x16,%eax
  800fc5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcc:	a8 01                	test   $0x1,%al
  800fce:	74 37                	je     801007 <dup+0x9b>
  800fd0:	89 f8                	mov    %edi,%eax
  800fd2:	c1 e8 0c             	shr    $0xc,%eax
  800fd5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fdc:	f6 c2 01             	test   $0x1,%dl
  800fdf:	74 26                	je     801007 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fe1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe8:	83 ec 0c             	sub    $0xc,%esp
  800feb:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff0:	50                   	push   %eax
  800ff1:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ff4:	6a 00                	push   $0x0
  800ff6:	57                   	push   %edi
  800ff7:	6a 00                	push   $0x0
  800ff9:	e8 28 fb ff ff       	call   800b26 <sys_page_map>
  800ffe:	89 c7                	mov    %eax,%edi
  801000:	83 c4 20             	add    $0x20,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	78 2e                	js     801035 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801007:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80100a:	89 d0                	mov    %edx,%eax
  80100c:	c1 e8 0c             	shr    $0xc,%eax
  80100f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	25 07 0e 00 00       	and    $0xe07,%eax
  80101e:	50                   	push   %eax
  80101f:	53                   	push   %ebx
  801020:	6a 00                	push   $0x0
  801022:	52                   	push   %edx
  801023:	6a 00                	push   $0x0
  801025:	e8 fc fa ff ff       	call   800b26 <sys_page_map>
  80102a:	89 c7                	mov    %eax,%edi
  80102c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80102f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801031:	85 ff                	test   %edi,%edi
  801033:	79 1d                	jns    801052 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801035:	83 ec 08             	sub    $0x8,%esp
  801038:	53                   	push   %ebx
  801039:	6a 00                	push   $0x0
  80103b:	e8 28 fb ff ff       	call   800b68 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801040:	83 c4 08             	add    $0x8,%esp
  801043:	ff 75 d4             	pushl  -0x2c(%ebp)
  801046:	6a 00                	push   $0x0
  801048:	e8 1b fb ff ff       	call   800b68 <sys_page_unmap>
	return r;
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	89 f8                	mov    %edi,%eax
}
  801052:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801055:	5b                   	pop    %ebx
  801056:	5e                   	pop    %esi
  801057:	5f                   	pop    %edi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    

0080105a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	53                   	push   %ebx
  80105e:	83 ec 14             	sub    $0x14,%esp
  801061:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801064:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801067:	50                   	push   %eax
  801068:	53                   	push   %ebx
  801069:	e8 7d fd ff ff       	call   800deb <fd_lookup>
  80106e:	83 c4 08             	add    $0x8,%esp
  801071:	89 c2                	mov    %eax,%edx
  801073:	85 c0                	test   %eax,%eax
  801075:	78 6d                	js     8010e4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801077:	83 ec 08             	sub    $0x8,%esp
  80107a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107d:	50                   	push   %eax
  80107e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801081:	ff 30                	pushl  (%eax)
  801083:	e8 b9 fd ff ff       	call   800e41 <dev_lookup>
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	78 4c                	js     8010db <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80108f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801092:	8b 42 08             	mov    0x8(%edx),%eax
  801095:	83 e0 03             	and    $0x3,%eax
  801098:	83 f8 01             	cmp    $0x1,%eax
  80109b:	75 21                	jne    8010be <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80109d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8010a2:	8b 40 48             	mov    0x48(%eax),%eax
  8010a5:	83 ec 04             	sub    $0x4,%esp
  8010a8:	53                   	push   %ebx
  8010a9:	50                   	push   %eax
  8010aa:	68 0d 27 80 00       	push   $0x80270d
  8010af:	e8 9f f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010bc:	eb 26                	jmp    8010e4 <read+0x8a>
	}
	if (!dev->dev_read)
  8010be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c1:	8b 40 08             	mov    0x8(%eax),%eax
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	74 17                	je     8010df <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010c8:	83 ec 04             	sub    $0x4,%esp
  8010cb:	ff 75 10             	pushl  0x10(%ebp)
  8010ce:	ff 75 0c             	pushl  0xc(%ebp)
  8010d1:	52                   	push   %edx
  8010d2:	ff d0                	call   *%eax
  8010d4:	89 c2                	mov    %eax,%edx
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	eb 09                	jmp    8010e4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010db:	89 c2                	mov    %eax,%edx
  8010dd:	eb 05                	jmp    8010e4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010df:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010e4:	89 d0                	mov    %edx,%eax
  8010e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	57                   	push   %edi
  8010ef:	56                   	push   %esi
  8010f0:	53                   	push   %ebx
  8010f1:	83 ec 0c             	sub    $0xc,%esp
  8010f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ff:	eb 21                	jmp    801122 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801101:	83 ec 04             	sub    $0x4,%esp
  801104:	89 f0                	mov    %esi,%eax
  801106:	29 d8                	sub    %ebx,%eax
  801108:	50                   	push   %eax
  801109:	89 d8                	mov    %ebx,%eax
  80110b:	03 45 0c             	add    0xc(%ebp),%eax
  80110e:	50                   	push   %eax
  80110f:	57                   	push   %edi
  801110:	e8 45 ff ff ff       	call   80105a <read>
		if (m < 0)
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	85 c0                	test   %eax,%eax
  80111a:	78 0c                	js     801128 <readn+0x3d>
			return m;
		if (m == 0)
  80111c:	85 c0                	test   %eax,%eax
  80111e:	74 06                	je     801126 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801120:	01 c3                	add    %eax,%ebx
  801122:	39 f3                	cmp    %esi,%ebx
  801124:	72 db                	jb     801101 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801126:	89 d8                	mov    %ebx,%eax
}
  801128:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112b:	5b                   	pop    %ebx
  80112c:	5e                   	pop    %esi
  80112d:	5f                   	pop    %edi
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	53                   	push   %ebx
  801134:	83 ec 14             	sub    $0x14,%esp
  801137:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80113a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113d:	50                   	push   %eax
  80113e:	53                   	push   %ebx
  80113f:	e8 a7 fc ff ff       	call   800deb <fd_lookup>
  801144:	83 c4 08             	add    $0x8,%esp
  801147:	89 c2                	mov    %eax,%edx
  801149:	85 c0                	test   %eax,%eax
  80114b:	78 68                	js     8011b5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114d:	83 ec 08             	sub    $0x8,%esp
  801150:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801153:	50                   	push   %eax
  801154:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801157:	ff 30                	pushl  (%eax)
  801159:	e8 e3 fc ff ff       	call   800e41 <dev_lookup>
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	85 c0                	test   %eax,%eax
  801163:	78 47                	js     8011ac <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801165:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801168:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80116c:	75 21                	jne    80118f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80116e:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801173:	8b 40 48             	mov    0x48(%eax),%eax
  801176:	83 ec 04             	sub    $0x4,%esp
  801179:	53                   	push   %ebx
  80117a:	50                   	push   %eax
  80117b:	68 29 27 80 00       	push   $0x802729
  801180:	e8 ce ef ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80118d:	eb 26                	jmp    8011b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80118f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801192:	8b 52 0c             	mov    0xc(%edx),%edx
  801195:	85 d2                	test   %edx,%edx
  801197:	74 17                	je     8011b0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801199:	83 ec 04             	sub    $0x4,%esp
  80119c:	ff 75 10             	pushl  0x10(%ebp)
  80119f:	ff 75 0c             	pushl  0xc(%ebp)
  8011a2:	50                   	push   %eax
  8011a3:	ff d2                	call   *%edx
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	83 c4 10             	add    $0x10,%esp
  8011aa:	eb 09                	jmp    8011b5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	eb 05                	jmp    8011b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011b5:	89 d0                	mov    %edx,%eax
  8011b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ba:	c9                   	leave  
  8011bb:	c3                   	ret    

008011bc <seek>:

int
seek(int fdnum, off_t offset)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011c5:	50                   	push   %eax
  8011c6:	ff 75 08             	pushl  0x8(%ebp)
  8011c9:	e8 1d fc ff ff       	call   800deb <fd_lookup>
  8011ce:	83 c4 08             	add    $0x8,%esp
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	78 0e                	js     8011e3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011db:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e3:	c9                   	leave  
  8011e4:	c3                   	ret    

008011e5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	53                   	push   %ebx
  8011e9:	83 ec 14             	sub    $0x14,%esp
  8011ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f2:	50                   	push   %eax
  8011f3:	53                   	push   %ebx
  8011f4:	e8 f2 fb ff ff       	call   800deb <fd_lookup>
  8011f9:	83 c4 08             	add    $0x8,%esp
  8011fc:	89 c2                	mov    %eax,%edx
  8011fe:	85 c0                	test   %eax,%eax
  801200:	78 65                	js     801267 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801202:	83 ec 08             	sub    $0x8,%esp
  801205:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801208:	50                   	push   %eax
  801209:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120c:	ff 30                	pushl  (%eax)
  80120e:	e8 2e fc ff ff       	call   800e41 <dev_lookup>
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	78 44                	js     80125e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801221:	75 21                	jne    801244 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801223:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801228:	8b 40 48             	mov    0x48(%eax),%eax
  80122b:	83 ec 04             	sub    $0x4,%esp
  80122e:	53                   	push   %ebx
  80122f:	50                   	push   %eax
  801230:	68 ec 26 80 00       	push   $0x8026ec
  801235:	e8 19 ef ff ff       	call   800153 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801242:	eb 23                	jmp    801267 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801244:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801247:	8b 52 18             	mov    0x18(%edx),%edx
  80124a:	85 d2                	test   %edx,%edx
  80124c:	74 14                	je     801262 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80124e:	83 ec 08             	sub    $0x8,%esp
  801251:	ff 75 0c             	pushl  0xc(%ebp)
  801254:	50                   	push   %eax
  801255:	ff d2                	call   *%edx
  801257:	89 c2                	mov    %eax,%edx
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	eb 09                	jmp    801267 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125e:	89 c2                	mov    %eax,%edx
  801260:	eb 05                	jmp    801267 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801262:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801267:	89 d0                	mov    %edx,%eax
  801269:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	53                   	push   %ebx
  801272:	83 ec 14             	sub    $0x14,%esp
  801275:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801278:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 67 fb ff ff       	call   800deb <fd_lookup>
  801284:	83 c4 08             	add    $0x8,%esp
  801287:	89 c2                	mov    %eax,%edx
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 58                	js     8012e5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801293:	50                   	push   %eax
  801294:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801297:	ff 30                	pushl  (%eax)
  801299:	e8 a3 fb ff ff       	call   800e41 <dev_lookup>
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	78 37                	js     8012dc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012ac:	74 32                	je     8012e0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ae:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012b1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012b8:	00 00 00 
	stat->st_isdir = 0;
  8012bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012c2:	00 00 00 
	stat->st_dev = dev;
  8012c5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012cb:	83 ec 08             	sub    $0x8,%esp
  8012ce:	53                   	push   %ebx
  8012cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d2:	ff 50 14             	call   *0x14(%eax)
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	eb 09                	jmp    8012e5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012dc:	89 c2                	mov    %eax,%edx
  8012de:	eb 05                	jmp    8012e5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012e5:	89 d0                	mov    %edx,%eax
  8012e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ea:	c9                   	leave  
  8012eb:	c3                   	ret    

008012ec <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	56                   	push   %esi
  8012f0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	6a 00                	push   $0x0
  8012f6:	ff 75 08             	pushl  0x8(%ebp)
  8012f9:	e8 09 02 00 00       	call   801507 <open>
  8012fe:	89 c3                	mov    %eax,%ebx
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	85 db                	test   %ebx,%ebx
  801305:	78 1b                	js     801322 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	ff 75 0c             	pushl  0xc(%ebp)
  80130d:	53                   	push   %ebx
  80130e:	e8 5b ff ff ff       	call   80126e <fstat>
  801313:	89 c6                	mov    %eax,%esi
	close(fd);
  801315:	89 1c 24             	mov    %ebx,(%esp)
  801318:	e8 fd fb ff ff       	call   800f1a <close>
	return r;
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	89 f0                	mov    %esi,%eax
}
  801322:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801325:	5b                   	pop    %ebx
  801326:	5e                   	pop    %esi
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    

00801329 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	56                   	push   %esi
  80132d:	53                   	push   %ebx
  80132e:	89 c6                	mov    %eax,%esi
  801330:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801332:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801339:	75 12                	jne    80134d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	6a 01                	push   $0x1
  801340:	e8 b6 0c 00 00       	call   801ffb <ipc_find_env>
  801345:	a3 00 40 80 00       	mov    %eax,0x804000
  80134a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80134d:	6a 07                	push   $0x7
  80134f:	68 00 50 80 00       	push   $0x805000
  801354:	56                   	push   %esi
  801355:	ff 35 00 40 80 00    	pushl  0x804000
  80135b:	e8 47 0c 00 00       	call   801fa7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801360:	83 c4 0c             	add    $0xc,%esp
  801363:	6a 00                	push   $0x0
  801365:	53                   	push   %ebx
  801366:	6a 00                	push   $0x0
  801368:	e8 d1 0b 00 00       	call   801f3e <ipc_recv>
}
  80136d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80137a:	8b 45 08             	mov    0x8(%ebp),%eax
  80137d:	8b 40 0c             	mov    0xc(%eax),%eax
  801380:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801385:	8b 45 0c             	mov    0xc(%ebp),%eax
  801388:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80138d:	ba 00 00 00 00       	mov    $0x0,%edx
  801392:	b8 02 00 00 00       	mov    $0x2,%eax
  801397:	e8 8d ff ff ff       	call   801329 <fsipc>
}
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013aa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013af:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8013b9:	e8 6b ff ff ff       	call   801329 <fsipc>
}
  8013be:	c9                   	leave  
  8013bf:	c3                   	ret    

008013c0 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 04             	sub    $0x4,%esp
  8013c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013da:	b8 05 00 00 00       	mov    $0x5,%eax
  8013df:	e8 45 ff ff ff       	call   801329 <fsipc>
  8013e4:	89 c2                	mov    %eax,%edx
  8013e6:	85 d2                	test   %edx,%edx
  8013e8:	78 2c                	js     801416 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013ea:	83 ec 08             	sub    $0x8,%esp
  8013ed:	68 00 50 80 00       	push   $0x805000
  8013f2:	53                   	push   %ebx
  8013f3:	e8 e2 f2 ff ff       	call   8006da <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013f8:	a1 80 50 80 00       	mov    0x805080,%eax
  8013fd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801403:	a1 84 50 80 00       	mov    0x805084,%eax
  801408:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801416:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801419:	c9                   	leave  
  80141a:	c3                   	ret    

0080141b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	57                   	push   %edi
  80141f:	56                   	push   %esi
  801420:	53                   	push   %ebx
  801421:	83 ec 0c             	sub    $0xc,%esp
  801424:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801427:	8b 45 08             	mov    0x8(%ebp),%eax
  80142a:	8b 40 0c             	mov    0xc(%eax),%eax
  80142d:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  801432:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801435:	eb 3d                	jmp    801474 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801437:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80143d:	bf f8 0f 00 00       	mov    $0xff8,%edi
  801442:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801445:	83 ec 04             	sub    $0x4,%esp
  801448:	57                   	push   %edi
  801449:	53                   	push   %ebx
  80144a:	68 08 50 80 00       	push   $0x805008
  80144f:	e8 18 f4 ff ff       	call   80086c <memmove>
                fsipcbuf.write.req_n = tmp; 
  801454:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80145a:	ba 00 00 00 00       	mov    $0x0,%edx
  80145f:	b8 04 00 00 00       	mov    $0x4,%eax
  801464:	e8 c0 fe ff ff       	call   801329 <fsipc>
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 0d                	js     80147d <devfile_write+0x62>
		        return r;
                n -= tmp;
  801470:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801472:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801474:	85 f6                	test   %esi,%esi
  801476:	75 bf                	jne    801437 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80147d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801480:	5b                   	pop    %ebx
  801481:	5e                   	pop    %esi
  801482:	5f                   	pop    %edi
  801483:	5d                   	pop    %ebp
  801484:	c3                   	ret    

00801485 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	56                   	push   %esi
  801489:	53                   	push   %ebx
  80148a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80148d:	8b 45 08             	mov    0x8(%ebp),%eax
  801490:	8b 40 0c             	mov    0xc(%eax),%eax
  801493:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801498:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80149e:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a3:	b8 03 00 00 00       	mov    $0x3,%eax
  8014a8:	e8 7c fe ff ff       	call   801329 <fsipc>
  8014ad:	89 c3                	mov    %eax,%ebx
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	78 4b                	js     8014fe <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014b3:	39 c6                	cmp    %eax,%esi
  8014b5:	73 16                	jae    8014cd <devfile_read+0x48>
  8014b7:	68 5c 27 80 00       	push   $0x80275c
  8014bc:	68 63 27 80 00       	push   $0x802763
  8014c1:	6a 7c                	push   $0x7c
  8014c3:	68 78 27 80 00       	push   $0x802778
  8014c8:	e8 2b 0a 00 00       	call   801ef8 <_panic>
	assert(r <= PGSIZE);
  8014cd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014d2:	7e 16                	jle    8014ea <devfile_read+0x65>
  8014d4:	68 83 27 80 00       	push   $0x802783
  8014d9:	68 63 27 80 00       	push   $0x802763
  8014de:	6a 7d                	push   $0x7d
  8014e0:	68 78 27 80 00       	push   $0x802778
  8014e5:	e8 0e 0a 00 00       	call   801ef8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014ea:	83 ec 04             	sub    $0x4,%esp
  8014ed:	50                   	push   %eax
  8014ee:	68 00 50 80 00       	push   $0x805000
  8014f3:	ff 75 0c             	pushl  0xc(%ebp)
  8014f6:	e8 71 f3 ff ff       	call   80086c <memmove>
	return r;
  8014fb:	83 c4 10             	add    $0x10,%esp
}
  8014fe:	89 d8                	mov    %ebx,%eax
  801500:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801503:	5b                   	pop    %ebx
  801504:	5e                   	pop    %esi
  801505:	5d                   	pop    %ebp
  801506:	c3                   	ret    

00801507 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	53                   	push   %ebx
  80150b:	83 ec 20             	sub    $0x20,%esp
  80150e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801511:	53                   	push   %ebx
  801512:	e8 8a f1 ff ff       	call   8006a1 <strlen>
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80151f:	7f 67                	jg     801588 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801527:	50                   	push   %eax
  801528:	e8 6f f8 ff ff       	call   800d9c <fd_alloc>
  80152d:	83 c4 10             	add    $0x10,%esp
		return r;
  801530:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801532:	85 c0                	test   %eax,%eax
  801534:	78 57                	js     80158d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	53                   	push   %ebx
  80153a:	68 00 50 80 00       	push   $0x805000
  80153f:	e8 96 f1 ff ff       	call   8006da <strcpy>
	fsipcbuf.open.req_omode = mode;
  801544:	8b 45 0c             	mov    0xc(%ebp),%eax
  801547:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80154c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154f:	b8 01 00 00 00       	mov    $0x1,%eax
  801554:	e8 d0 fd ff ff       	call   801329 <fsipc>
  801559:	89 c3                	mov    %eax,%ebx
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	85 c0                	test   %eax,%eax
  801560:	79 14                	jns    801576 <open+0x6f>
		fd_close(fd, 0);
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	6a 00                	push   $0x0
  801567:	ff 75 f4             	pushl  -0xc(%ebp)
  80156a:	e8 2a f9 ff ff       	call   800e99 <fd_close>
		return r;
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	89 da                	mov    %ebx,%edx
  801574:	eb 17                	jmp    80158d <open+0x86>
	}

	return fd2num(fd);
  801576:	83 ec 0c             	sub    $0xc,%esp
  801579:	ff 75 f4             	pushl  -0xc(%ebp)
  80157c:	e8 f4 f7 ff ff       	call   800d75 <fd2num>
  801581:	89 c2                	mov    %eax,%edx
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	eb 05                	jmp    80158d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801588:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80158d:	89 d0                	mov    %edx,%eax
  80158f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801592:	c9                   	leave  
  801593:	c3                   	ret    

00801594 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80159a:	ba 00 00 00 00       	mov    $0x0,%edx
  80159f:	b8 08 00 00 00       	mov    $0x8,%eax
  8015a4:	e8 80 fd ff ff       	call   801329 <fsipc>
}
  8015a9:	c9                   	leave  
  8015aa:	c3                   	ret    

008015ab <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015b1:	68 8f 27 80 00       	push   $0x80278f
  8015b6:	ff 75 0c             	pushl  0xc(%ebp)
  8015b9:	e8 1c f1 ff ff       	call   8006da <strcpy>
	return 0;
}
  8015be:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c3:	c9                   	leave  
  8015c4:	c3                   	ret    

008015c5 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 10             	sub    $0x10,%esp
  8015cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015cf:	53                   	push   %ebx
  8015d0:	e8 5e 0a 00 00       	call   802033 <pageref>
  8015d5:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015d8:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8015dd:	83 f8 01             	cmp    $0x1,%eax
  8015e0:	75 10                	jne    8015f2 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015e2:	83 ec 0c             	sub    $0xc,%esp
  8015e5:	ff 73 0c             	pushl  0xc(%ebx)
  8015e8:	e8 ca 02 00 00       	call   8018b7 <nsipc_close>
  8015ed:	89 c2                	mov    %eax,%edx
  8015ef:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015f2:	89 d0                	mov    %edx,%eax
  8015f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f7:	c9                   	leave  
  8015f8:	c3                   	ret    

008015f9 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015ff:	6a 00                	push   $0x0
  801601:	ff 75 10             	pushl  0x10(%ebp)
  801604:	ff 75 0c             	pushl  0xc(%ebp)
  801607:	8b 45 08             	mov    0x8(%ebp),%eax
  80160a:	ff 70 0c             	pushl  0xc(%eax)
  80160d:	e8 82 03 00 00       	call   801994 <nsipc_send>
}
  801612:	c9                   	leave  
  801613:	c3                   	ret    

00801614 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80161a:	6a 00                	push   $0x0
  80161c:	ff 75 10             	pushl  0x10(%ebp)
  80161f:	ff 75 0c             	pushl  0xc(%ebp)
  801622:	8b 45 08             	mov    0x8(%ebp),%eax
  801625:	ff 70 0c             	pushl  0xc(%eax)
  801628:	e8 fb 02 00 00       	call   801928 <nsipc_recv>
}
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801635:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801638:	52                   	push   %edx
  801639:	50                   	push   %eax
  80163a:	e8 ac f7 ff ff       	call   800deb <fd_lookup>
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	85 c0                	test   %eax,%eax
  801644:	78 17                	js     80165d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801649:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80164f:	39 08                	cmp    %ecx,(%eax)
  801651:	75 05                	jne    801658 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801653:	8b 40 0c             	mov    0xc(%eax),%eax
  801656:	eb 05                	jmp    80165d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801658:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	56                   	push   %esi
  801663:	53                   	push   %ebx
  801664:	83 ec 1c             	sub    $0x1c,%esp
  801667:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801669:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	e8 2a f7 ff ff       	call   800d9c <fd_alloc>
  801672:	89 c3                	mov    %eax,%ebx
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	78 1b                	js     801696 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80167b:	83 ec 04             	sub    $0x4,%esp
  80167e:	68 07 04 00 00       	push   $0x407
  801683:	ff 75 f4             	pushl  -0xc(%ebp)
  801686:	6a 00                	push   $0x0
  801688:	e8 56 f4 ff ff       	call   800ae3 <sys_page_alloc>
  80168d:	89 c3                	mov    %eax,%ebx
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	79 10                	jns    8016a6 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	56                   	push   %esi
  80169a:	e8 18 02 00 00       	call   8018b7 <nsipc_close>
		return r;
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	89 d8                	mov    %ebx,%eax
  8016a4:	eb 24                	jmp    8016ca <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8016a6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8016ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016af:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b4:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  8016bb:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	52                   	push   %edx
  8016c2:	e8 ae f6 ff ff       	call   800d75 <fd2num>
  8016c7:	83 c4 10             	add    $0x10,%esp
}
  8016ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5d                   	pop    %ebp
  8016d0:	c3                   	ret    

008016d1 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016da:	e8 50 ff ff ff       	call   80162f <fd2sockid>
		return r;
  8016df:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 1f                	js     801704 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016e5:	83 ec 04             	sub    $0x4,%esp
  8016e8:	ff 75 10             	pushl  0x10(%ebp)
  8016eb:	ff 75 0c             	pushl  0xc(%ebp)
  8016ee:	50                   	push   %eax
  8016ef:	e8 1c 01 00 00       	call   801810 <nsipc_accept>
  8016f4:	83 c4 10             	add    $0x10,%esp
		return r;
  8016f7:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 07                	js     801704 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016fd:	e8 5d ff ff ff       	call   80165f <alloc_sockfd>
  801702:	89 c1                	mov    %eax,%ecx
}
  801704:	89 c8                	mov    %ecx,%eax
  801706:	c9                   	leave  
  801707:	c3                   	ret    

00801708 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80170e:	8b 45 08             	mov    0x8(%ebp),%eax
  801711:	e8 19 ff ff ff       	call   80162f <fd2sockid>
  801716:	89 c2                	mov    %eax,%edx
  801718:	85 d2                	test   %edx,%edx
  80171a:	78 12                	js     80172e <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  80171c:	83 ec 04             	sub    $0x4,%esp
  80171f:	ff 75 10             	pushl  0x10(%ebp)
  801722:	ff 75 0c             	pushl  0xc(%ebp)
  801725:	52                   	push   %edx
  801726:	e8 35 01 00 00       	call   801860 <nsipc_bind>
  80172b:	83 c4 10             	add    $0x10,%esp
}
  80172e:	c9                   	leave  
  80172f:	c3                   	ret    

00801730 <shutdown>:

int
shutdown(int s, int how)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801736:	8b 45 08             	mov    0x8(%ebp),%eax
  801739:	e8 f1 fe ff ff       	call   80162f <fd2sockid>
  80173e:	89 c2                	mov    %eax,%edx
  801740:	85 d2                	test   %edx,%edx
  801742:	78 0f                	js     801753 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  801744:	83 ec 08             	sub    $0x8,%esp
  801747:	ff 75 0c             	pushl  0xc(%ebp)
  80174a:	52                   	push   %edx
  80174b:	e8 45 01 00 00       	call   801895 <nsipc_shutdown>
  801750:	83 c4 10             	add    $0x10,%esp
}
  801753:	c9                   	leave  
  801754:	c3                   	ret    

00801755 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80175b:	8b 45 08             	mov    0x8(%ebp),%eax
  80175e:	e8 cc fe ff ff       	call   80162f <fd2sockid>
  801763:	89 c2                	mov    %eax,%edx
  801765:	85 d2                	test   %edx,%edx
  801767:	78 12                	js     80177b <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  801769:	83 ec 04             	sub    $0x4,%esp
  80176c:	ff 75 10             	pushl  0x10(%ebp)
  80176f:	ff 75 0c             	pushl  0xc(%ebp)
  801772:	52                   	push   %edx
  801773:	e8 59 01 00 00       	call   8018d1 <nsipc_connect>
  801778:	83 c4 10             	add    $0x10,%esp
}
  80177b:	c9                   	leave  
  80177c:	c3                   	ret    

0080177d <listen>:

int
listen(int s, int backlog)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801783:	8b 45 08             	mov    0x8(%ebp),%eax
  801786:	e8 a4 fe ff ff       	call   80162f <fd2sockid>
  80178b:	89 c2                	mov    %eax,%edx
  80178d:	85 d2                	test   %edx,%edx
  80178f:	78 0f                	js     8017a0 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801791:	83 ec 08             	sub    $0x8,%esp
  801794:	ff 75 0c             	pushl  0xc(%ebp)
  801797:	52                   	push   %edx
  801798:	e8 69 01 00 00       	call   801906 <nsipc_listen>
  80179d:	83 c4 10             	add    $0x10,%esp
}
  8017a0:	c9                   	leave  
  8017a1:	c3                   	ret    

008017a2 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017a8:	ff 75 10             	pushl  0x10(%ebp)
  8017ab:	ff 75 0c             	pushl  0xc(%ebp)
  8017ae:	ff 75 08             	pushl  0x8(%ebp)
  8017b1:	e8 3c 02 00 00       	call   8019f2 <nsipc_socket>
  8017b6:	89 c2                	mov    %eax,%edx
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	85 d2                	test   %edx,%edx
  8017bd:	78 05                	js     8017c4 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  8017bf:	e8 9b fe ff ff       	call   80165f <alloc_sockfd>
}
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    

008017c6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 04             	sub    $0x4,%esp
  8017cd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017cf:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017d6:	75 12                	jne    8017ea <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017d8:	83 ec 0c             	sub    $0xc,%esp
  8017db:	6a 02                	push   $0x2
  8017dd:	e8 19 08 00 00       	call   801ffb <ipc_find_env>
  8017e2:	a3 04 40 80 00       	mov    %eax,0x804004
  8017e7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017ea:	6a 07                	push   $0x7
  8017ec:	68 00 60 80 00       	push   $0x806000
  8017f1:	53                   	push   %ebx
  8017f2:	ff 35 04 40 80 00    	pushl  0x804004
  8017f8:	e8 aa 07 00 00       	call   801fa7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017fd:	83 c4 0c             	add    $0xc,%esp
  801800:	6a 00                	push   $0x0
  801802:	6a 00                	push   $0x0
  801804:	6a 00                	push   $0x0
  801806:	e8 33 07 00 00       	call   801f3e <ipc_recv>
}
  80180b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	56                   	push   %esi
  801814:	53                   	push   %ebx
  801815:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801820:	8b 06                	mov    (%esi),%eax
  801822:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801827:	b8 01 00 00 00       	mov    $0x1,%eax
  80182c:	e8 95 ff ff ff       	call   8017c6 <nsipc>
  801831:	89 c3                	mov    %eax,%ebx
  801833:	85 c0                	test   %eax,%eax
  801835:	78 20                	js     801857 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801837:	83 ec 04             	sub    $0x4,%esp
  80183a:	ff 35 10 60 80 00    	pushl  0x806010
  801840:	68 00 60 80 00       	push   $0x806000
  801845:	ff 75 0c             	pushl  0xc(%ebp)
  801848:	e8 1f f0 ff ff       	call   80086c <memmove>
		*addrlen = ret->ret_addrlen;
  80184d:	a1 10 60 80 00       	mov    0x806010,%eax
  801852:	89 06                	mov    %eax,(%esi)
  801854:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801857:	89 d8                	mov    %ebx,%eax
  801859:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185c:	5b                   	pop    %ebx
  80185d:	5e                   	pop    %esi
  80185e:	5d                   	pop    %ebp
  80185f:	c3                   	ret    

00801860 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	53                   	push   %ebx
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801872:	53                   	push   %ebx
  801873:	ff 75 0c             	pushl  0xc(%ebp)
  801876:	68 04 60 80 00       	push   $0x806004
  80187b:	e8 ec ef ff ff       	call   80086c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801880:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801886:	b8 02 00 00 00       	mov    $0x2,%eax
  80188b:	e8 36 ff ff ff       	call   8017c6 <nsipc>
}
  801890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80189b:	8b 45 08             	mov    0x8(%ebp),%eax
  80189e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018ab:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b0:	e8 11 ff ff ff       	call   8017c6 <nsipc>
}
  8018b5:	c9                   	leave  
  8018b6:	c3                   	ret    

008018b7 <nsipc_close>:

int
nsipc_close(int s)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018c5:	b8 04 00 00 00       	mov    $0x4,%eax
  8018ca:	e8 f7 fe ff ff       	call   8017c6 <nsipc>
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	53                   	push   %ebx
  8018d5:	83 ec 08             	sub    $0x8,%esp
  8018d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018db:	8b 45 08             	mov    0x8(%ebp),%eax
  8018de:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018e3:	53                   	push   %ebx
  8018e4:	ff 75 0c             	pushl  0xc(%ebp)
  8018e7:	68 04 60 80 00       	push   $0x806004
  8018ec:	e8 7b ef ff ff       	call   80086c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018f1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018f7:	b8 05 00 00 00       	mov    $0x5,%eax
  8018fc:	e8 c5 fe ff ff       	call   8017c6 <nsipc>
}
  801901:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80190c:	8b 45 08             	mov    0x8(%ebp),%eax
  80190f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801914:	8b 45 0c             	mov    0xc(%ebp),%eax
  801917:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80191c:	b8 06 00 00 00       	mov    $0x6,%eax
  801921:	e8 a0 fe ff ff       	call   8017c6 <nsipc>
}
  801926:	c9                   	leave  
  801927:	c3                   	ret    

00801928 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801938:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80193e:	8b 45 14             	mov    0x14(%ebp),%eax
  801941:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801946:	b8 07 00 00 00       	mov    $0x7,%eax
  80194b:	e8 76 fe ff ff       	call   8017c6 <nsipc>
  801950:	89 c3                	mov    %eax,%ebx
  801952:	85 c0                	test   %eax,%eax
  801954:	78 35                	js     80198b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801956:	39 f0                	cmp    %esi,%eax
  801958:	7f 07                	jg     801961 <nsipc_recv+0x39>
  80195a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80195f:	7e 16                	jle    801977 <nsipc_recv+0x4f>
  801961:	68 9b 27 80 00       	push   $0x80279b
  801966:	68 63 27 80 00       	push   $0x802763
  80196b:	6a 62                	push   $0x62
  80196d:	68 b0 27 80 00       	push   $0x8027b0
  801972:	e8 81 05 00 00       	call   801ef8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801977:	83 ec 04             	sub    $0x4,%esp
  80197a:	50                   	push   %eax
  80197b:	68 00 60 80 00       	push   $0x806000
  801980:	ff 75 0c             	pushl  0xc(%ebp)
  801983:	e8 e4 ee ff ff       	call   80086c <memmove>
  801988:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80198b:	89 d8                	mov    %ebx,%eax
  80198d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801990:	5b                   	pop    %ebx
  801991:	5e                   	pop    %esi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	53                   	push   %ebx
  801998:	83 ec 04             	sub    $0x4,%esp
  80199b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80199e:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a1:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8019a6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8019ac:	7e 16                	jle    8019c4 <nsipc_send+0x30>
  8019ae:	68 bc 27 80 00       	push   $0x8027bc
  8019b3:	68 63 27 80 00       	push   $0x802763
  8019b8:	6a 6d                	push   $0x6d
  8019ba:	68 b0 27 80 00       	push   $0x8027b0
  8019bf:	e8 34 05 00 00       	call   801ef8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019c4:	83 ec 04             	sub    $0x4,%esp
  8019c7:	53                   	push   %ebx
  8019c8:	ff 75 0c             	pushl  0xc(%ebp)
  8019cb:	68 0c 60 80 00       	push   $0x80600c
  8019d0:	e8 97 ee ff ff       	call   80086c <memmove>
	nsipcbuf.send.req_size = size;
  8019d5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019db:	8b 45 14             	mov    0x14(%ebp),%eax
  8019de:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019e3:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e8:	e8 d9 fd ff ff       	call   8017c6 <nsipc>
}
  8019ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a03:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a08:	8b 45 10             	mov    0x10(%ebp),%eax
  801a0b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a10:	b8 09 00 00 00       	mov    $0x9,%eax
  801a15:	e8 ac fd ff ff       	call   8017c6 <nsipc>
}
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	56                   	push   %esi
  801a20:	53                   	push   %ebx
  801a21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a24:	83 ec 0c             	sub    $0xc,%esp
  801a27:	ff 75 08             	pushl  0x8(%ebp)
  801a2a:	e8 56 f3 ff ff       	call   800d85 <fd2data>
  801a2f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a31:	83 c4 08             	add    $0x8,%esp
  801a34:	68 c8 27 80 00       	push   $0x8027c8
  801a39:	53                   	push   %ebx
  801a3a:	e8 9b ec ff ff       	call   8006da <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a3f:	8b 56 04             	mov    0x4(%esi),%edx
  801a42:	89 d0                	mov    %edx,%eax
  801a44:	2b 06                	sub    (%esi),%eax
  801a46:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a4c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a53:	00 00 00 
	stat->st_dev = &devpipe;
  801a56:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a5d:	30 80 00 
	return 0;
}
  801a60:	b8 00 00 00 00       	mov    $0x0,%eax
  801a65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a68:	5b                   	pop    %ebx
  801a69:	5e                   	pop    %esi
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	53                   	push   %ebx
  801a70:	83 ec 0c             	sub    $0xc,%esp
  801a73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a76:	53                   	push   %ebx
  801a77:	6a 00                	push   $0x0
  801a79:	e8 ea f0 ff ff       	call   800b68 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a7e:	89 1c 24             	mov    %ebx,(%esp)
  801a81:	e8 ff f2 ff ff       	call   800d85 <fd2data>
  801a86:	83 c4 08             	add    $0x8,%esp
  801a89:	50                   	push   %eax
  801a8a:	6a 00                	push   $0x0
  801a8c:	e8 d7 f0 ff ff       	call   800b68 <sys_page_unmap>
}
  801a91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a94:	c9                   	leave  
  801a95:	c3                   	ret    

00801a96 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	57                   	push   %edi
  801a9a:	56                   	push   %esi
  801a9b:	53                   	push   %ebx
  801a9c:	83 ec 1c             	sub    $0x1c,%esp
  801a9f:	89 c6                	mov    %eax,%esi
  801aa1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aa4:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801aa9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801aac:	83 ec 0c             	sub    $0xc,%esp
  801aaf:	56                   	push   %esi
  801ab0:	e8 7e 05 00 00       	call   802033 <pageref>
  801ab5:	89 c7                	mov    %eax,%edi
  801ab7:	83 c4 04             	add    $0x4,%esp
  801aba:	ff 75 e4             	pushl  -0x1c(%ebp)
  801abd:	e8 71 05 00 00       	call   802033 <pageref>
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	39 c7                	cmp    %eax,%edi
  801ac7:	0f 94 c2             	sete   %dl
  801aca:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801acd:	8b 0d 0c 40 80 00    	mov    0x80400c,%ecx
  801ad3:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801ad6:	39 fb                	cmp    %edi,%ebx
  801ad8:	74 19                	je     801af3 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801ada:	84 d2                	test   %dl,%dl
  801adc:	74 c6                	je     801aa4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ade:	8b 51 58             	mov    0x58(%ecx),%edx
  801ae1:	50                   	push   %eax
  801ae2:	52                   	push   %edx
  801ae3:	53                   	push   %ebx
  801ae4:	68 cf 27 80 00       	push   $0x8027cf
  801ae9:	e8 65 e6 ff ff       	call   800153 <cprintf>
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	eb b1                	jmp    801aa4 <_pipeisclosed+0xe>
	}
}
  801af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5f                   	pop    %edi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	57                   	push   %edi
  801aff:	56                   	push   %esi
  801b00:	53                   	push   %ebx
  801b01:	83 ec 28             	sub    $0x28,%esp
  801b04:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b07:	56                   	push   %esi
  801b08:	e8 78 f2 ff ff       	call   800d85 <fd2data>
  801b0d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	bf 00 00 00 00       	mov    $0x0,%edi
  801b17:	eb 4b                	jmp    801b64 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b19:	89 da                	mov    %ebx,%edx
  801b1b:	89 f0                	mov    %esi,%eax
  801b1d:	e8 74 ff ff ff       	call   801a96 <_pipeisclosed>
  801b22:	85 c0                	test   %eax,%eax
  801b24:	75 48                	jne    801b6e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b26:	e8 99 ef ff ff       	call   800ac4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b2b:	8b 43 04             	mov    0x4(%ebx),%eax
  801b2e:	8b 0b                	mov    (%ebx),%ecx
  801b30:	8d 51 20             	lea    0x20(%ecx),%edx
  801b33:	39 d0                	cmp    %edx,%eax
  801b35:	73 e2                	jae    801b19 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b3a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b3e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b41:	89 c2                	mov    %eax,%edx
  801b43:	c1 fa 1f             	sar    $0x1f,%edx
  801b46:	89 d1                	mov    %edx,%ecx
  801b48:	c1 e9 1b             	shr    $0x1b,%ecx
  801b4b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b4e:	83 e2 1f             	and    $0x1f,%edx
  801b51:	29 ca                	sub    %ecx,%edx
  801b53:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b57:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b5b:	83 c0 01             	add    $0x1,%eax
  801b5e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b61:	83 c7 01             	add    $0x1,%edi
  801b64:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b67:	75 c2                	jne    801b2b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b69:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6c:	eb 05                	jmp    801b73 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b6e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b76:	5b                   	pop    %ebx
  801b77:	5e                   	pop    %esi
  801b78:	5f                   	pop    %edi
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	57                   	push   %edi
  801b7f:	56                   	push   %esi
  801b80:	53                   	push   %ebx
  801b81:	83 ec 18             	sub    $0x18,%esp
  801b84:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b87:	57                   	push   %edi
  801b88:	e8 f8 f1 ff ff       	call   800d85 <fd2data>
  801b8d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b97:	eb 3d                	jmp    801bd6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b99:	85 db                	test   %ebx,%ebx
  801b9b:	74 04                	je     801ba1 <devpipe_read+0x26>
				return i;
  801b9d:	89 d8                	mov    %ebx,%eax
  801b9f:	eb 44                	jmp    801be5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ba1:	89 f2                	mov    %esi,%edx
  801ba3:	89 f8                	mov    %edi,%eax
  801ba5:	e8 ec fe ff ff       	call   801a96 <_pipeisclosed>
  801baa:	85 c0                	test   %eax,%eax
  801bac:	75 32                	jne    801be0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bae:	e8 11 ef ff ff       	call   800ac4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bb3:	8b 06                	mov    (%esi),%eax
  801bb5:	3b 46 04             	cmp    0x4(%esi),%eax
  801bb8:	74 df                	je     801b99 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bba:	99                   	cltd   
  801bbb:	c1 ea 1b             	shr    $0x1b,%edx
  801bbe:	01 d0                	add    %edx,%eax
  801bc0:	83 e0 1f             	and    $0x1f,%eax
  801bc3:	29 d0                	sub    %edx,%eax
  801bc5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bd0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd3:	83 c3 01             	add    $0x1,%ebx
  801bd6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bd9:	75 d8                	jne    801bb3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bdb:	8b 45 10             	mov    0x10(%ebp),%eax
  801bde:	eb 05                	jmp    801be5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801be5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be8:	5b                   	pop    %ebx
  801be9:	5e                   	pop    %esi
  801bea:	5f                   	pop    %edi
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    

00801bed <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	56                   	push   %esi
  801bf1:	53                   	push   %ebx
  801bf2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf8:	50                   	push   %eax
  801bf9:	e8 9e f1 ff ff       	call   800d9c <fd_alloc>
  801bfe:	83 c4 10             	add    $0x10,%esp
  801c01:	89 c2                	mov    %eax,%edx
  801c03:	85 c0                	test   %eax,%eax
  801c05:	0f 88 2c 01 00 00    	js     801d37 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0b:	83 ec 04             	sub    $0x4,%esp
  801c0e:	68 07 04 00 00       	push   $0x407
  801c13:	ff 75 f4             	pushl  -0xc(%ebp)
  801c16:	6a 00                	push   $0x0
  801c18:	e8 c6 ee ff ff       	call   800ae3 <sys_page_alloc>
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	89 c2                	mov    %eax,%edx
  801c22:	85 c0                	test   %eax,%eax
  801c24:	0f 88 0d 01 00 00    	js     801d37 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c2a:	83 ec 0c             	sub    $0xc,%esp
  801c2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c30:	50                   	push   %eax
  801c31:	e8 66 f1 ff ff       	call   800d9c <fd_alloc>
  801c36:	89 c3                	mov    %eax,%ebx
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	0f 88 e2 00 00 00    	js     801d25 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c43:	83 ec 04             	sub    $0x4,%esp
  801c46:	68 07 04 00 00       	push   $0x407
  801c4b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4e:	6a 00                	push   $0x0
  801c50:	e8 8e ee ff ff       	call   800ae3 <sys_page_alloc>
  801c55:	89 c3                	mov    %eax,%ebx
  801c57:	83 c4 10             	add    $0x10,%esp
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	0f 88 c3 00 00 00    	js     801d25 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c62:	83 ec 0c             	sub    $0xc,%esp
  801c65:	ff 75 f4             	pushl  -0xc(%ebp)
  801c68:	e8 18 f1 ff ff       	call   800d85 <fd2data>
  801c6d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6f:	83 c4 0c             	add    $0xc,%esp
  801c72:	68 07 04 00 00       	push   $0x407
  801c77:	50                   	push   %eax
  801c78:	6a 00                	push   $0x0
  801c7a:	e8 64 ee ff ff       	call   800ae3 <sys_page_alloc>
  801c7f:	89 c3                	mov    %eax,%ebx
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	85 c0                	test   %eax,%eax
  801c86:	0f 88 89 00 00 00    	js     801d15 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8c:	83 ec 0c             	sub    $0xc,%esp
  801c8f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c92:	e8 ee f0 ff ff       	call   800d85 <fd2data>
  801c97:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c9e:	50                   	push   %eax
  801c9f:	6a 00                	push   $0x0
  801ca1:	56                   	push   %esi
  801ca2:	6a 00                	push   $0x0
  801ca4:	e8 7d ee ff ff       	call   800b26 <sys_page_map>
  801ca9:	89 c3                	mov    %eax,%ebx
  801cab:	83 c4 20             	add    $0x20,%esp
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	78 55                	js     801d07 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cb2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cc7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ccd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cdc:	83 ec 0c             	sub    $0xc,%esp
  801cdf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce2:	e8 8e f0 ff ff       	call   800d75 <fd2num>
  801ce7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cea:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cec:	83 c4 04             	add    $0x4,%esp
  801cef:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf2:	e8 7e f0 ff ff       	call   800d75 <fd2num>
  801cf7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cfa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	ba 00 00 00 00       	mov    $0x0,%edx
  801d05:	eb 30                	jmp    801d37 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d07:	83 ec 08             	sub    $0x8,%esp
  801d0a:	56                   	push   %esi
  801d0b:	6a 00                	push   $0x0
  801d0d:	e8 56 ee ff ff       	call   800b68 <sys_page_unmap>
  801d12:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d15:	83 ec 08             	sub    $0x8,%esp
  801d18:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1b:	6a 00                	push   $0x0
  801d1d:	e8 46 ee ff ff       	call   800b68 <sys_page_unmap>
  801d22:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d25:	83 ec 08             	sub    $0x8,%esp
  801d28:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2b:	6a 00                	push   $0x0
  801d2d:	e8 36 ee ff ff       	call   800b68 <sys_page_unmap>
  801d32:	83 c4 10             	add    $0x10,%esp
  801d35:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d37:	89 d0                	mov    %edx,%eax
  801d39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3c:	5b                   	pop    %ebx
  801d3d:	5e                   	pop    %esi
  801d3e:	5d                   	pop    %ebp
  801d3f:	c3                   	ret    

00801d40 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d49:	50                   	push   %eax
  801d4a:	ff 75 08             	pushl  0x8(%ebp)
  801d4d:	e8 99 f0 ff ff       	call   800deb <fd_lookup>
  801d52:	89 c2                	mov    %eax,%edx
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	85 d2                	test   %edx,%edx
  801d59:	78 18                	js     801d73 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d5b:	83 ec 0c             	sub    $0xc,%esp
  801d5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d61:	e8 1f f0 ff ff       	call   800d85 <fd2data>
	return _pipeisclosed(fd, p);
  801d66:	89 c2                	mov    %eax,%edx
  801d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6b:	e8 26 fd ff ff       	call   801a96 <_pipeisclosed>
  801d70:	83 c4 10             	add    $0x10,%esp
}
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    

00801d75 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d78:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7d:	5d                   	pop    %ebp
  801d7e:	c3                   	ret    

00801d7f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d85:	68 e7 27 80 00       	push   $0x8027e7
  801d8a:	ff 75 0c             	pushl  0xc(%ebp)
  801d8d:	e8 48 e9 ff ff       	call   8006da <strcpy>
	return 0;
}
  801d92:	b8 00 00 00 00       	mov    $0x0,%eax
  801d97:	c9                   	leave  
  801d98:	c3                   	ret    

00801d99 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	57                   	push   %edi
  801d9d:	56                   	push   %esi
  801d9e:	53                   	push   %ebx
  801d9f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801daa:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db0:	eb 2d                	jmp    801ddf <devcons_write+0x46>
		m = n - tot;
  801db2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801db7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dba:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dbf:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc2:	83 ec 04             	sub    $0x4,%esp
  801dc5:	53                   	push   %ebx
  801dc6:	03 45 0c             	add    0xc(%ebp),%eax
  801dc9:	50                   	push   %eax
  801dca:	57                   	push   %edi
  801dcb:	e8 9c ea ff ff       	call   80086c <memmove>
		sys_cputs(buf, m);
  801dd0:	83 c4 08             	add    $0x8,%esp
  801dd3:	53                   	push   %ebx
  801dd4:	57                   	push   %edi
  801dd5:	e8 4d ec ff ff       	call   800a27 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dda:	01 de                	add    %ebx,%esi
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	89 f0                	mov    %esi,%eax
  801de1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801de4:	72 cc                	jb     801db2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801de6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de9:	5b                   	pop    %ebx
  801dea:	5e                   	pop    %esi
  801deb:	5f                   	pop    %edi
  801dec:	5d                   	pop    %ebp
  801ded:	c3                   	ret    

00801dee <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801df4:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801df9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dfd:	75 07                	jne    801e06 <devcons_read+0x18>
  801dff:	eb 28                	jmp    801e29 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e01:	e8 be ec ff ff       	call   800ac4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e06:	e8 3a ec ff ff       	call   800a45 <sys_cgetc>
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	74 f2                	je     801e01 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	78 16                	js     801e29 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e13:	83 f8 04             	cmp    $0x4,%eax
  801e16:	74 0c                	je     801e24 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e18:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1b:	88 02                	mov    %al,(%edx)
	return 1;
  801e1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e22:	eb 05                	jmp    801e29 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e24:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    

00801e2b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e31:	8b 45 08             	mov    0x8(%ebp),%eax
  801e34:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e37:	6a 01                	push   $0x1
  801e39:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e3c:	50                   	push   %eax
  801e3d:	e8 e5 eb ff ff       	call   800a27 <sys_cputs>
  801e42:	83 c4 10             	add    $0x10,%esp
}
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    

00801e47 <getchar>:

int
getchar(void)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e4d:	6a 01                	push   $0x1
  801e4f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e52:	50                   	push   %eax
  801e53:	6a 00                	push   $0x0
  801e55:	e8 00 f2 ff ff       	call   80105a <read>
	if (r < 0)
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	78 0f                	js     801e70 <getchar+0x29>
		return r;
	if (r < 1)
  801e61:	85 c0                	test   %eax,%eax
  801e63:	7e 06                	jle    801e6b <getchar+0x24>
		return -E_EOF;
	return c;
  801e65:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e69:	eb 05                	jmp    801e70 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e6b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e70:	c9                   	leave  
  801e71:	c3                   	ret    

00801e72 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7b:	50                   	push   %eax
  801e7c:	ff 75 08             	pushl  0x8(%ebp)
  801e7f:	e8 67 ef ff ff       	call   800deb <fd_lookup>
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	85 c0                	test   %eax,%eax
  801e89:	78 11                	js     801e9c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e94:	39 10                	cmp    %edx,(%eax)
  801e96:	0f 94 c0             	sete   %al
  801e99:	0f b6 c0             	movzbl %al,%eax
}
  801e9c:	c9                   	leave  
  801e9d:	c3                   	ret    

00801e9e <opencons>:

int
opencons(void)
{
  801e9e:	55                   	push   %ebp
  801e9f:	89 e5                	mov    %esp,%ebp
  801ea1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea7:	50                   	push   %eax
  801ea8:	e8 ef ee ff ff       	call   800d9c <fd_alloc>
  801ead:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb2:	85 c0                	test   %eax,%eax
  801eb4:	78 3e                	js     801ef4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb6:	83 ec 04             	sub    $0x4,%esp
  801eb9:	68 07 04 00 00       	push   $0x407
  801ebe:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec1:	6a 00                	push   $0x0
  801ec3:	e8 1b ec ff ff       	call   800ae3 <sys_page_alloc>
  801ec8:	83 c4 10             	add    $0x10,%esp
		return r;
  801ecb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	78 23                	js     801ef4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ed1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eda:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ee6:	83 ec 0c             	sub    $0xc,%esp
  801ee9:	50                   	push   %eax
  801eea:	e8 86 ee ff ff       	call   800d75 <fd2num>
  801eef:	89 c2                	mov    %eax,%edx
  801ef1:	83 c4 10             	add    $0x10,%esp
}
  801ef4:	89 d0                	mov    %edx,%eax
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    

00801ef8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	56                   	push   %esi
  801efc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801efd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f00:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f06:	e8 9a eb ff ff       	call   800aa5 <sys_getenvid>
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	ff 75 0c             	pushl  0xc(%ebp)
  801f11:	ff 75 08             	pushl  0x8(%ebp)
  801f14:	56                   	push   %esi
  801f15:	50                   	push   %eax
  801f16:	68 f4 27 80 00       	push   $0x8027f4
  801f1b:	e8 33 e2 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f20:	83 c4 18             	add    $0x18,%esp
  801f23:	53                   	push   %ebx
  801f24:	ff 75 10             	pushl  0x10(%ebp)
  801f27:	e8 d6 e1 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801f2c:	c7 04 24 4c 23 80 00 	movl   $0x80234c,(%esp)
  801f33:	e8 1b e2 ff ff       	call   800153 <cprintf>
  801f38:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f3b:	cc                   	int3   
  801f3c:	eb fd                	jmp    801f3b <_panic+0x43>

00801f3e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	56                   	push   %esi
  801f42:	53                   	push   %ebx
  801f43:	8b 75 08             	mov    0x8(%ebp),%esi
  801f46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f53:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801f56:	83 ec 0c             	sub    $0xc,%esp
  801f59:	50                   	push   %eax
  801f5a:	e8 34 ed ff ff       	call   800c93 <sys_ipc_recv>
  801f5f:	83 c4 10             	add    $0x10,%esp
  801f62:	85 c0                	test   %eax,%eax
  801f64:	79 16                	jns    801f7c <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801f66:	85 f6                	test   %esi,%esi
  801f68:	74 06                	je     801f70 <ipc_recv+0x32>
  801f6a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801f70:	85 db                	test   %ebx,%ebx
  801f72:	74 2c                	je     801fa0 <ipc_recv+0x62>
  801f74:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f7a:	eb 24                	jmp    801fa0 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801f7c:	85 f6                	test   %esi,%esi
  801f7e:	74 0a                	je     801f8a <ipc_recv+0x4c>
  801f80:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f85:	8b 40 74             	mov    0x74(%eax),%eax
  801f88:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801f8a:	85 db                	test   %ebx,%ebx
  801f8c:	74 0a                	je     801f98 <ipc_recv+0x5a>
  801f8e:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f93:	8b 40 78             	mov    0x78(%eax),%eax
  801f96:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801f98:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f9d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fa0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa3:	5b                   	pop    %ebx
  801fa4:	5e                   	pop    %esi
  801fa5:	5d                   	pop    %ebp
  801fa6:	c3                   	ret    

00801fa7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	57                   	push   %edi
  801fab:	56                   	push   %esi
  801fac:	53                   	push   %ebx
  801fad:	83 ec 0c             	sub    $0xc,%esp
  801fb0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fb3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801fb9:	85 db                	test   %ebx,%ebx
  801fbb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fc0:	0f 44 d8             	cmove  %eax,%ebx
  801fc3:	eb 1c                	jmp    801fe1 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801fc5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fc8:	74 12                	je     801fdc <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801fca:	50                   	push   %eax
  801fcb:	68 18 28 80 00       	push   $0x802818
  801fd0:	6a 39                	push   $0x39
  801fd2:	68 33 28 80 00       	push   $0x802833
  801fd7:	e8 1c ff ff ff       	call   801ef8 <_panic>
                 sys_yield();
  801fdc:	e8 e3 ea ff ff       	call   800ac4 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801fe1:	ff 75 14             	pushl  0x14(%ebp)
  801fe4:	53                   	push   %ebx
  801fe5:	56                   	push   %esi
  801fe6:	57                   	push   %edi
  801fe7:	e8 84 ec ff ff       	call   800c70 <sys_ipc_try_send>
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	78 d2                	js     801fc5 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801ff3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff6:	5b                   	pop    %ebx
  801ff7:	5e                   	pop    %esi
  801ff8:	5f                   	pop    %edi
  801ff9:	5d                   	pop    %ebp
  801ffa:	c3                   	ret    

00801ffb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802001:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802006:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802009:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80200f:	8b 52 50             	mov    0x50(%edx),%edx
  802012:	39 ca                	cmp    %ecx,%edx
  802014:	75 0d                	jne    802023 <ipc_find_env+0x28>
			return envs[i].env_id;
  802016:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802019:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80201e:	8b 40 08             	mov    0x8(%eax),%eax
  802021:	eb 0e                	jmp    802031 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802023:	83 c0 01             	add    $0x1,%eax
  802026:	3d 00 04 00 00       	cmp    $0x400,%eax
  80202b:	75 d9                	jne    802006 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80202d:	66 b8 00 00          	mov    $0x0,%ax
}
  802031:	5d                   	pop    %ebp
  802032:	c3                   	ret    

00802033 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802039:	89 d0                	mov    %edx,%eax
  80203b:	c1 e8 16             	shr    $0x16,%eax
  80203e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802045:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204a:	f6 c1 01             	test   $0x1,%cl
  80204d:	74 1d                	je     80206c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80204f:	c1 ea 0c             	shr    $0xc,%edx
  802052:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802059:	f6 c2 01             	test   $0x1,%dl
  80205c:	74 0e                	je     80206c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80205e:	c1 ea 0c             	shr    $0xc,%edx
  802061:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802068:	ef 
  802069:	0f b7 c0             	movzwl %ax,%eax
}
  80206c:	5d                   	pop    %ebp
  80206d:	c3                   	ret    
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
