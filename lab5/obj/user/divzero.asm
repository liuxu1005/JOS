
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
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 40 1e 80 00       	push   $0x801e40
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
  80007d:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8000ac:	e8 f0 0d 00 00       	call   800ea1 <close_all>
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
  8001b6:	e8 a5 19 00 00       	call   801b60 <__udivdi3>
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
  8001f4:	e8 97 1a 00 00       	call   801c90 <__umoddi3>
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	0f be 80 58 1e 80 00 	movsbl 0x801e58(%eax),%eax
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
  8002f8:	ff 24 85 c0 1f 80 00 	jmp    *0x801fc0(,%eax,4)
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
  8003bc:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  8003c3:	85 d2                	test   %edx,%edx
  8003c5:	75 18                	jne    8003df <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003c7:	50                   	push   %eax
  8003c8:	68 70 1e 80 00       	push   $0x801e70
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
  8003e0:	68 71 22 80 00       	push   $0x802271
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
  80040d:	ba 69 1e 80 00       	mov    $0x801e69,%edx
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
  800a8c:	68 9f 21 80 00       	push   $0x80219f
  800a91:	6a 23                	push   $0x23
  800a93:	68 bc 21 80 00       	push   $0x8021bc
  800a98:	e8 44 0f 00 00       	call   8019e1 <_panic>

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
  800b0d:	68 9f 21 80 00       	push   $0x80219f
  800b12:	6a 23                	push   $0x23
  800b14:	68 bc 21 80 00       	push   $0x8021bc
  800b19:	e8 c3 0e 00 00       	call   8019e1 <_panic>

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
  800b4f:	68 9f 21 80 00       	push   $0x80219f
  800b54:	6a 23                	push   $0x23
  800b56:	68 bc 21 80 00       	push   $0x8021bc
  800b5b:	e8 81 0e 00 00       	call   8019e1 <_panic>

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
  800b91:	68 9f 21 80 00       	push   $0x80219f
  800b96:	6a 23                	push   $0x23
  800b98:	68 bc 21 80 00       	push   $0x8021bc
  800b9d:	e8 3f 0e 00 00       	call   8019e1 <_panic>

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
  800bd3:	68 9f 21 80 00       	push   $0x80219f
  800bd8:	6a 23                	push   $0x23
  800bda:	68 bc 21 80 00       	push   $0x8021bc
  800bdf:	e8 fd 0d 00 00       	call   8019e1 <_panic>
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
  800c15:	68 9f 21 80 00       	push   $0x80219f
  800c1a:	6a 23                	push   $0x23
  800c1c:	68 bc 21 80 00       	push   $0x8021bc
  800c21:	e8 bb 0d 00 00       	call   8019e1 <_panic>

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
  800c57:	68 9f 21 80 00       	push   $0x80219f
  800c5c:	6a 23                	push   $0x23
  800c5e:	68 bc 21 80 00       	push   $0x8021bc
  800c63:	e8 79 0d 00 00       	call   8019e1 <_panic>

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
  800cbb:	68 9f 21 80 00       	push   $0x80219f
  800cc0:	6a 23                	push   $0x23
  800cc2:	68 bc 21 80 00       	push   $0x8021bc
  800cc7:	e8 15 0d 00 00       	call   8019e1 <_panic>

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

00800cd4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cda:	05 00 00 00 30       	add    $0x30000000,%eax
  800cdf:	c1 e8 0c             	shr    $0xc,%eax
}
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cea:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800cef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800cf4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d01:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d06:	89 c2                	mov    %eax,%edx
  800d08:	c1 ea 16             	shr    $0x16,%edx
  800d0b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d12:	f6 c2 01             	test   $0x1,%dl
  800d15:	74 11                	je     800d28 <fd_alloc+0x2d>
  800d17:	89 c2                	mov    %eax,%edx
  800d19:	c1 ea 0c             	shr    $0xc,%edx
  800d1c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d23:	f6 c2 01             	test   $0x1,%dl
  800d26:	75 09                	jne    800d31 <fd_alloc+0x36>
			*fd_store = fd;
  800d28:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2f:	eb 17                	jmp    800d48 <fd_alloc+0x4d>
  800d31:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d36:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d3b:	75 c9                	jne    800d06 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d3d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d43:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d50:	83 f8 1f             	cmp    $0x1f,%eax
  800d53:	77 36                	ja     800d8b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d55:	c1 e0 0c             	shl    $0xc,%eax
  800d58:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d5d:	89 c2                	mov    %eax,%edx
  800d5f:	c1 ea 16             	shr    $0x16,%edx
  800d62:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d69:	f6 c2 01             	test   $0x1,%dl
  800d6c:	74 24                	je     800d92 <fd_lookup+0x48>
  800d6e:	89 c2                	mov    %eax,%edx
  800d70:	c1 ea 0c             	shr    $0xc,%edx
  800d73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d7a:	f6 c2 01             	test   $0x1,%dl
  800d7d:	74 1a                	je     800d99 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d82:	89 02                	mov    %eax,(%edx)
	return 0;
  800d84:	b8 00 00 00 00       	mov    $0x0,%eax
  800d89:	eb 13                	jmp    800d9e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d90:	eb 0c                	jmp    800d9e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d97:	eb 05                	jmp    800d9e <fd_lookup+0x54>
  800d99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	83 ec 08             	sub    $0x8,%esp
  800da6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da9:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dae:	eb 13                	jmp    800dc3 <dev_lookup+0x23>
  800db0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800db3:	39 08                	cmp    %ecx,(%eax)
  800db5:	75 0c                	jne    800dc3 <dev_lookup+0x23>
			*dev = devtab[i];
  800db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dba:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc1:	eb 2e                	jmp    800df1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dc3:	8b 02                	mov    (%edx),%eax
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	75 e7                	jne    800db0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dc9:	a1 08 40 80 00       	mov    0x804008,%eax
  800dce:	8b 40 48             	mov    0x48(%eax),%eax
  800dd1:	83 ec 04             	sub    $0x4,%esp
  800dd4:	51                   	push   %ecx
  800dd5:	50                   	push   %eax
  800dd6:	68 cc 21 80 00       	push   $0x8021cc
  800ddb:	e8 73 f3 ff ff       	call   800153 <cprintf>
	*dev = 0;
  800de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800de9:	83 c4 10             	add    $0x10,%esp
  800dec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    

00800df3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 10             	sub    $0x10,%esp
  800dfb:	8b 75 08             	mov    0x8(%ebp),%esi
  800dfe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e04:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e05:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e0b:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e0e:	50                   	push   %eax
  800e0f:	e8 36 ff ff ff       	call   800d4a <fd_lookup>
  800e14:	83 c4 08             	add    $0x8,%esp
  800e17:	85 c0                	test   %eax,%eax
  800e19:	78 05                	js     800e20 <fd_close+0x2d>
	    || fd != fd2)
  800e1b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e1e:	74 0c                	je     800e2c <fd_close+0x39>
		return (must_exist ? r : 0);
  800e20:	84 db                	test   %bl,%bl
  800e22:	ba 00 00 00 00       	mov    $0x0,%edx
  800e27:	0f 44 c2             	cmove  %edx,%eax
  800e2a:	eb 41                	jmp    800e6d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e2c:	83 ec 08             	sub    $0x8,%esp
  800e2f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e32:	50                   	push   %eax
  800e33:	ff 36                	pushl  (%esi)
  800e35:	e8 66 ff ff ff       	call   800da0 <dev_lookup>
  800e3a:	89 c3                	mov    %eax,%ebx
  800e3c:	83 c4 10             	add    $0x10,%esp
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	78 1a                	js     800e5d <fd_close+0x6a>
		if (dev->dev_close)
  800e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e46:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e49:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	74 0b                	je     800e5d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e52:	83 ec 0c             	sub    $0xc,%esp
  800e55:	56                   	push   %esi
  800e56:	ff d0                	call   *%eax
  800e58:	89 c3                	mov    %eax,%ebx
  800e5a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e5d:	83 ec 08             	sub    $0x8,%esp
  800e60:	56                   	push   %esi
  800e61:	6a 00                	push   $0x0
  800e63:	e8 00 fd ff ff       	call   800b68 <sys_page_unmap>
	return r;
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	89 d8                	mov    %ebx,%eax
}
  800e6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7d:	50                   	push   %eax
  800e7e:	ff 75 08             	pushl  0x8(%ebp)
  800e81:	e8 c4 fe ff ff       	call   800d4a <fd_lookup>
  800e86:	89 c2                	mov    %eax,%edx
  800e88:	83 c4 08             	add    $0x8,%esp
  800e8b:	85 d2                	test   %edx,%edx
  800e8d:	78 10                	js     800e9f <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	6a 01                	push   $0x1
  800e94:	ff 75 f4             	pushl  -0xc(%ebp)
  800e97:	e8 57 ff ff ff       	call   800df3 <fd_close>
  800e9c:	83 c4 10             	add    $0x10,%esp
}
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    

00800ea1 <close_all>:

void
close_all(void)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ea8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ead:	83 ec 0c             	sub    $0xc,%esp
  800eb0:	53                   	push   %ebx
  800eb1:	e8 be ff ff ff       	call   800e74 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800eb6:	83 c3 01             	add    $0x1,%ebx
  800eb9:	83 c4 10             	add    $0x10,%esp
  800ebc:	83 fb 20             	cmp    $0x20,%ebx
  800ebf:	75 ec                	jne    800ead <close_all+0xc>
		close(i);
}
  800ec1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec4:	c9                   	leave  
  800ec5:	c3                   	ret    

00800ec6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 2c             	sub    $0x2c,%esp
  800ecf:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ed2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ed5:	50                   	push   %eax
  800ed6:	ff 75 08             	pushl  0x8(%ebp)
  800ed9:	e8 6c fe ff ff       	call   800d4a <fd_lookup>
  800ede:	89 c2                	mov    %eax,%edx
  800ee0:	83 c4 08             	add    $0x8,%esp
  800ee3:	85 d2                	test   %edx,%edx
  800ee5:	0f 88 c1 00 00 00    	js     800fac <dup+0xe6>
		return r;
	close(newfdnum);
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	56                   	push   %esi
  800eef:	e8 80 ff ff ff       	call   800e74 <close>

	newfd = INDEX2FD(newfdnum);
  800ef4:	89 f3                	mov    %esi,%ebx
  800ef6:	c1 e3 0c             	shl    $0xc,%ebx
  800ef9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800eff:	83 c4 04             	add    $0x4,%esp
  800f02:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f05:	e8 da fd ff ff       	call   800ce4 <fd2data>
  800f0a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f0c:	89 1c 24             	mov    %ebx,(%esp)
  800f0f:	e8 d0 fd ff ff       	call   800ce4 <fd2data>
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f1a:	89 f8                	mov    %edi,%eax
  800f1c:	c1 e8 16             	shr    $0x16,%eax
  800f1f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f26:	a8 01                	test   $0x1,%al
  800f28:	74 37                	je     800f61 <dup+0x9b>
  800f2a:	89 f8                	mov    %edi,%eax
  800f2c:	c1 e8 0c             	shr    $0xc,%eax
  800f2f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f36:	f6 c2 01             	test   $0x1,%dl
  800f39:	74 26                	je     800f61 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f3b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f42:	83 ec 0c             	sub    $0xc,%esp
  800f45:	25 07 0e 00 00       	and    $0xe07,%eax
  800f4a:	50                   	push   %eax
  800f4b:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f4e:	6a 00                	push   $0x0
  800f50:	57                   	push   %edi
  800f51:	6a 00                	push   $0x0
  800f53:	e8 ce fb ff ff       	call   800b26 <sys_page_map>
  800f58:	89 c7                	mov    %eax,%edi
  800f5a:	83 c4 20             	add    $0x20,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	78 2e                	js     800f8f <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f61:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f64:	89 d0                	mov    %edx,%eax
  800f66:	c1 e8 0c             	shr    $0xc,%eax
  800f69:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	25 07 0e 00 00       	and    $0xe07,%eax
  800f78:	50                   	push   %eax
  800f79:	53                   	push   %ebx
  800f7a:	6a 00                	push   $0x0
  800f7c:	52                   	push   %edx
  800f7d:	6a 00                	push   $0x0
  800f7f:	e8 a2 fb ff ff       	call   800b26 <sys_page_map>
  800f84:	89 c7                	mov    %eax,%edi
  800f86:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f89:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f8b:	85 ff                	test   %edi,%edi
  800f8d:	79 1d                	jns    800fac <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800f8f:	83 ec 08             	sub    $0x8,%esp
  800f92:	53                   	push   %ebx
  800f93:	6a 00                	push   $0x0
  800f95:	e8 ce fb ff ff       	call   800b68 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800f9a:	83 c4 08             	add    $0x8,%esp
  800f9d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fa0:	6a 00                	push   $0x0
  800fa2:	e8 c1 fb ff ff       	call   800b68 <sys_page_unmap>
	return r;
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	89 f8                	mov    %edi,%eax
}
  800fac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800faf:	5b                   	pop    %ebx
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	53                   	push   %ebx
  800fb8:	83 ec 14             	sub    $0x14,%esp
  800fbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fbe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	53                   	push   %ebx
  800fc3:	e8 82 fd ff ff       	call   800d4a <fd_lookup>
  800fc8:	83 c4 08             	add    $0x8,%esp
  800fcb:	89 c2                	mov    %eax,%edx
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 6d                	js     80103e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fd1:	83 ec 08             	sub    $0x8,%esp
  800fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fdb:	ff 30                	pushl  (%eax)
  800fdd:	e8 be fd ff ff       	call   800da0 <dev_lookup>
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	78 4c                	js     801035 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800fe9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fec:	8b 42 08             	mov    0x8(%edx),%eax
  800fef:	83 e0 03             	and    $0x3,%eax
  800ff2:	83 f8 01             	cmp    $0x1,%eax
  800ff5:	75 21                	jne    801018 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ff7:	a1 08 40 80 00       	mov    0x804008,%eax
  800ffc:	8b 40 48             	mov    0x48(%eax),%eax
  800fff:	83 ec 04             	sub    $0x4,%esp
  801002:	53                   	push   %ebx
  801003:	50                   	push   %eax
  801004:	68 0d 22 80 00       	push   $0x80220d
  801009:	e8 45 f1 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801016:	eb 26                	jmp    80103e <read+0x8a>
	}
	if (!dev->dev_read)
  801018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101b:	8b 40 08             	mov    0x8(%eax),%eax
  80101e:	85 c0                	test   %eax,%eax
  801020:	74 17                	je     801039 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801022:	83 ec 04             	sub    $0x4,%esp
  801025:	ff 75 10             	pushl  0x10(%ebp)
  801028:	ff 75 0c             	pushl  0xc(%ebp)
  80102b:	52                   	push   %edx
  80102c:	ff d0                	call   *%eax
  80102e:	89 c2                	mov    %eax,%edx
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	eb 09                	jmp    80103e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801035:	89 c2                	mov    %eax,%edx
  801037:	eb 05                	jmp    80103e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801039:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80103e:	89 d0                	mov    %edx,%eax
  801040:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801043:	c9                   	leave  
  801044:	c3                   	ret    

00801045 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	57                   	push   %edi
  801049:	56                   	push   %esi
  80104a:	53                   	push   %ebx
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801051:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801054:	bb 00 00 00 00       	mov    $0x0,%ebx
  801059:	eb 21                	jmp    80107c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80105b:	83 ec 04             	sub    $0x4,%esp
  80105e:	89 f0                	mov    %esi,%eax
  801060:	29 d8                	sub    %ebx,%eax
  801062:	50                   	push   %eax
  801063:	89 d8                	mov    %ebx,%eax
  801065:	03 45 0c             	add    0xc(%ebp),%eax
  801068:	50                   	push   %eax
  801069:	57                   	push   %edi
  80106a:	e8 45 ff ff ff       	call   800fb4 <read>
		if (m < 0)
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	85 c0                	test   %eax,%eax
  801074:	78 0c                	js     801082 <readn+0x3d>
			return m;
		if (m == 0)
  801076:	85 c0                	test   %eax,%eax
  801078:	74 06                	je     801080 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80107a:	01 c3                	add    %eax,%ebx
  80107c:	39 f3                	cmp    %esi,%ebx
  80107e:	72 db                	jb     80105b <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801080:	89 d8                	mov    %ebx,%eax
}
  801082:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801085:	5b                   	pop    %ebx
  801086:	5e                   	pop    %esi
  801087:	5f                   	pop    %edi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    

0080108a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	53                   	push   %ebx
  80108e:	83 ec 14             	sub    $0x14,%esp
  801091:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801094:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801097:	50                   	push   %eax
  801098:	53                   	push   %ebx
  801099:	e8 ac fc ff ff       	call   800d4a <fd_lookup>
  80109e:	83 c4 08             	add    $0x8,%esp
  8010a1:	89 c2                	mov    %eax,%edx
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	78 68                	js     80110f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a7:	83 ec 08             	sub    $0x8,%esp
  8010aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ad:	50                   	push   %eax
  8010ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b1:	ff 30                	pushl  (%eax)
  8010b3:	e8 e8 fc ff ff       	call   800da0 <dev_lookup>
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	78 47                	js     801106 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010c6:	75 21                	jne    8010e9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010c8:	a1 08 40 80 00       	mov    0x804008,%eax
  8010cd:	8b 40 48             	mov    0x48(%eax),%eax
  8010d0:	83 ec 04             	sub    $0x4,%esp
  8010d3:	53                   	push   %ebx
  8010d4:	50                   	push   %eax
  8010d5:	68 29 22 80 00       	push   $0x802229
  8010da:	e8 74 f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  8010df:	83 c4 10             	add    $0x10,%esp
  8010e2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010e7:	eb 26                	jmp    80110f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010ec:	8b 52 0c             	mov    0xc(%edx),%edx
  8010ef:	85 d2                	test   %edx,%edx
  8010f1:	74 17                	je     80110a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010f3:	83 ec 04             	sub    $0x4,%esp
  8010f6:	ff 75 10             	pushl  0x10(%ebp)
  8010f9:	ff 75 0c             	pushl  0xc(%ebp)
  8010fc:	50                   	push   %eax
  8010fd:	ff d2                	call   *%edx
  8010ff:	89 c2                	mov    %eax,%edx
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	eb 09                	jmp    80110f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801106:	89 c2                	mov    %eax,%edx
  801108:	eb 05                	jmp    80110f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80110a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80110f:	89 d0                	mov    %edx,%eax
  801111:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801114:	c9                   	leave  
  801115:	c3                   	ret    

00801116 <seek>:

int
seek(int fdnum, off_t offset)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80111c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80111f:	50                   	push   %eax
  801120:	ff 75 08             	pushl  0x8(%ebp)
  801123:	e8 22 fc ff ff       	call   800d4a <fd_lookup>
  801128:	83 c4 08             	add    $0x8,%esp
  80112b:	85 c0                	test   %eax,%eax
  80112d:	78 0e                	js     80113d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80112f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801132:	8b 55 0c             	mov    0xc(%ebp),%edx
  801135:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801138:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	53                   	push   %ebx
  801143:	83 ec 14             	sub    $0x14,%esp
  801146:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801149:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114c:	50                   	push   %eax
  80114d:	53                   	push   %ebx
  80114e:	e8 f7 fb ff ff       	call   800d4a <fd_lookup>
  801153:	83 c4 08             	add    $0x8,%esp
  801156:	89 c2                	mov    %eax,%edx
  801158:	85 c0                	test   %eax,%eax
  80115a:	78 65                	js     8011c1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115c:	83 ec 08             	sub    $0x8,%esp
  80115f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801162:	50                   	push   %eax
  801163:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801166:	ff 30                	pushl  (%eax)
  801168:	e8 33 fc ff ff       	call   800da0 <dev_lookup>
  80116d:	83 c4 10             	add    $0x10,%esp
  801170:	85 c0                	test   %eax,%eax
  801172:	78 44                	js     8011b8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801174:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801177:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80117b:	75 21                	jne    80119e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80117d:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801182:	8b 40 48             	mov    0x48(%eax),%eax
  801185:	83 ec 04             	sub    $0x4,%esp
  801188:	53                   	push   %ebx
  801189:	50                   	push   %eax
  80118a:	68 ec 21 80 00       	push   $0x8021ec
  80118f:	e8 bf ef ff ff       	call   800153 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80119c:	eb 23                	jmp    8011c1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80119e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011a1:	8b 52 18             	mov    0x18(%edx),%edx
  8011a4:	85 d2                	test   %edx,%edx
  8011a6:	74 14                	je     8011bc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011a8:	83 ec 08             	sub    $0x8,%esp
  8011ab:	ff 75 0c             	pushl  0xc(%ebp)
  8011ae:	50                   	push   %eax
  8011af:	ff d2                	call   *%edx
  8011b1:	89 c2                	mov    %eax,%edx
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	eb 09                	jmp    8011c1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	eb 05                	jmp    8011c1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011c1:	89 d0                	mov    %edx,%eax
  8011c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c6:	c9                   	leave  
  8011c7:	c3                   	ret    

008011c8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 14             	sub    $0x14,%esp
  8011cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	ff 75 08             	pushl  0x8(%ebp)
  8011d9:	e8 6c fb ff ff       	call   800d4a <fd_lookup>
  8011de:	83 c4 08             	add    $0x8,%esp
  8011e1:	89 c2                	mov    %eax,%edx
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	78 58                	js     80123f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e7:	83 ec 08             	sub    $0x8,%esp
  8011ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ed:	50                   	push   %eax
  8011ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f1:	ff 30                	pushl  (%eax)
  8011f3:	e8 a8 fb ff ff       	call   800da0 <dev_lookup>
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 37                	js     801236 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8011ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801202:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801206:	74 32                	je     80123a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801208:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80120b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801212:	00 00 00 
	stat->st_isdir = 0;
  801215:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80121c:	00 00 00 
	stat->st_dev = dev;
  80121f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801225:	83 ec 08             	sub    $0x8,%esp
  801228:	53                   	push   %ebx
  801229:	ff 75 f0             	pushl  -0x10(%ebp)
  80122c:	ff 50 14             	call   *0x14(%eax)
  80122f:	89 c2                	mov    %eax,%edx
  801231:	83 c4 10             	add    $0x10,%esp
  801234:	eb 09                	jmp    80123f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801236:	89 c2                	mov    %eax,%edx
  801238:	eb 05                	jmp    80123f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80123a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80123f:	89 d0                	mov    %edx,%eax
  801241:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801244:	c9                   	leave  
  801245:	c3                   	ret    

00801246 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	56                   	push   %esi
  80124a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80124b:	83 ec 08             	sub    $0x8,%esp
  80124e:	6a 00                	push   $0x0
  801250:	ff 75 08             	pushl  0x8(%ebp)
  801253:	e8 09 02 00 00       	call   801461 <open>
  801258:	89 c3                	mov    %eax,%ebx
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 db                	test   %ebx,%ebx
  80125f:	78 1b                	js     80127c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801261:	83 ec 08             	sub    $0x8,%esp
  801264:	ff 75 0c             	pushl  0xc(%ebp)
  801267:	53                   	push   %ebx
  801268:	e8 5b ff ff ff       	call   8011c8 <fstat>
  80126d:	89 c6                	mov    %eax,%esi
	close(fd);
  80126f:	89 1c 24             	mov    %ebx,(%esp)
  801272:	e8 fd fb ff ff       	call   800e74 <close>
	return r;
  801277:	83 c4 10             	add    $0x10,%esp
  80127a:	89 f0                	mov    %esi,%eax
}
  80127c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80127f:	5b                   	pop    %ebx
  801280:	5e                   	pop    %esi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	56                   	push   %esi
  801287:	53                   	push   %ebx
  801288:	89 c6                	mov    %eax,%esi
  80128a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80128c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801293:	75 12                	jne    8012a7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801295:	83 ec 0c             	sub    $0xc,%esp
  801298:	6a 01                	push   $0x1
  80129a:	e8 45 08 00 00       	call   801ae4 <ipc_find_env>
  80129f:	a3 00 40 80 00       	mov    %eax,0x804000
  8012a4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012a7:	6a 07                	push   $0x7
  8012a9:	68 00 50 80 00       	push   $0x805000
  8012ae:	56                   	push   %esi
  8012af:	ff 35 00 40 80 00    	pushl  0x804000
  8012b5:	e8 d6 07 00 00       	call   801a90 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012ba:	83 c4 0c             	add    $0xc,%esp
  8012bd:	6a 00                	push   $0x0
  8012bf:	53                   	push   %ebx
  8012c0:	6a 00                	push   $0x0
  8012c2:	e8 60 07 00 00       	call   801a27 <ipc_recv>
}
  8012c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ca:	5b                   	pop    %ebx
  8012cb:	5e                   	pop    %esi
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8012da:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ec:	b8 02 00 00 00       	mov    $0x2,%eax
  8012f1:	e8 8d ff ff ff       	call   801283 <fsipc>
}
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8012fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801301:	8b 40 0c             	mov    0xc(%eax),%eax
  801304:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801309:	ba 00 00 00 00       	mov    $0x0,%edx
  80130e:	b8 06 00 00 00       	mov    $0x6,%eax
  801313:	e8 6b ff ff ff       	call   801283 <fsipc>
}
  801318:	c9                   	leave  
  801319:	c3                   	ret    

0080131a <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	53                   	push   %ebx
  80131e:	83 ec 04             	sub    $0x4,%esp
  801321:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801324:	8b 45 08             	mov    0x8(%ebp),%eax
  801327:	8b 40 0c             	mov    0xc(%eax),%eax
  80132a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80132f:	ba 00 00 00 00       	mov    $0x0,%edx
  801334:	b8 05 00 00 00       	mov    $0x5,%eax
  801339:	e8 45 ff ff ff       	call   801283 <fsipc>
  80133e:	89 c2                	mov    %eax,%edx
  801340:	85 d2                	test   %edx,%edx
  801342:	78 2c                	js     801370 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	68 00 50 80 00       	push   $0x805000
  80134c:	53                   	push   %ebx
  80134d:	e8 88 f3 ff ff       	call   8006da <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801352:	a1 80 50 80 00       	mov    0x805080,%eax
  801357:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80135d:	a1 84 50 80 00       	mov    0x805084,%eax
  801362:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801370:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801373:	c9                   	leave  
  801374:	c3                   	ret    

00801375 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	57                   	push   %edi
  801379:	56                   	push   %esi
  80137a:	53                   	push   %ebx
  80137b:	83 ec 0c             	sub    $0xc,%esp
  80137e:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801381:	8b 45 08             	mov    0x8(%ebp),%eax
  801384:	8b 40 0c             	mov    0xc(%eax),%eax
  801387:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80138c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  80138f:	eb 3d                	jmp    8013ce <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801391:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  801397:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80139c:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  80139f:	83 ec 04             	sub    $0x4,%esp
  8013a2:	57                   	push   %edi
  8013a3:	53                   	push   %ebx
  8013a4:	68 08 50 80 00       	push   $0x805008
  8013a9:	e8 be f4 ff ff       	call   80086c <memmove>
                fsipcbuf.write.req_n = tmp; 
  8013ae:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8013b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b9:	b8 04 00 00 00       	mov    $0x4,%eax
  8013be:	e8 c0 fe ff ff       	call   801283 <fsipc>
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 0d                	js     8013d7 <devfile_write+0x62>
		        return r;
                n -= tmp;
  8013ca:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  8013cc:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8013ce:	85 f6                	test   %esi,%esi
  8013d0:	75 bf                	jne    801391 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  8013d2:	89 d8                	mov    %ebx,%eax
  8013d4:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  8013d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013da:	5b                   	pop    %ebx
  8013db:	5e                   	pop    %esi
  8013dc:	5f                   	pop    %edi
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
  8013e4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ed:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013f2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fd:	b8 03 00 00 00       	mov    $0x3,%eax
  801402:	e8 7c fe ff ff       	call   801283 <fsipc>
  801407:	89 c3                	mov    %eax,%ebx
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 4b                	js     801458 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80140d:	39 c6                	cmp    %eax,%esi
  80140f:	73 16                	jae    801427 <devfile_read+0x48>
  801411:	68 58 22 80 00       	push   $0x802258
  801416:	68 5f 22 80 00       	push   $0x80225f
  80141b:	6a 7c                	push   $0x7c
  80141d:	68 74 22 80 00       	push   $0x802274
  801422:	e8 ba 05 00 00       	call   8019e1 <_panic>
	assert(r <= PGSIZE);
  801427:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80142c:	7e 16                	jle    801444 <devfile_read+0x65>
  80142e:	68 7f 22 80 00       	push   $0x80227f
  801433:	68 5f 22 80 00       	push   $0x80225f
  801438:	6a 7d                	push   $0x7d
  80143a:	68 74 22 80 00       	push   $0x802274
  80143f:	e8 9d 05 00 00       	call   8019e1 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801444:	83 ec 04             	sub    $0x4,%esp
  801447:	50                   	push   %eax
  801448:	68 00 50 80 00       	push   $0x805000
  80144d:	ff 75 0c             	pushl  0xc(%ebp)
  801450:	e8 17 f4 ff ff       	call   80086c <memmove>
	return r;
  801455:	83 c4 10             	add    $0x10,%esp
}
  801458:	89 d8                	mov    %ebx,%eax
  80145a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145d:	5b                   	pop    %ebx
  80145e:	5e                   	pop    %esi
  80145f:	5d                   	pop    %ebp
  801460:	c3                   	ret    

00801461 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	53                   	push   %ebx
  801465:	83 ec 20             	sub    $0x20,%esp
  801468:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80146b:	53                   	push   %ebx
  80146c:	e8 30 f2 ff ff       	call   8006a1 <strlen>
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801479:	7f 67                	jg     8014e2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80147b:	83 ec 0c             	sub    $0xc,%esp
  80147e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	e8 74 f8 ff ff       	call   800cfb <fd_alloc>
  801487:	83 c4 10             	add    $0x10,%esp
		return r;
  80148a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 57                	js     8014e7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	53                   	push   %ebx
  801494:	68 00 50 80 00       	push   $0x805000
  801499:	e8 3c f2 ff ff       	call   8006da <strcpy>
	fsipcbuf.open.req_omode = mode;
  80149e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ae:	e8 d0 fd ff ff       	call   801283 <fsipc>
  8014b3:	89 c3                	mov    %eax,%ebx
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	79 14                	jns    8014d0 <open+0x6f>
		fd_close(fd, 0);
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	6a 00                	push   $0x0
  8014c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c4:	e8 2a f9 ff ff       	call   800df3 <fd_close>
		return r;
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	89 da                	mov    %ebx,%edx
  8014ce:	eb 17                	jmp    8014e7 <open+0x86>
	}

	return fd2num(fd);
  8014d0:	83 ec 0c             	sub    $0xc,%esp
  8014d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d6:	e8 f9 f7 ff ff       	call   800cd4 <fd2num>
  8014db:	89 c2                	mov    %eax,%edx
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	eb 05                	jmp    8014e7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014e2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014e7:	89 d0                	mov    %edx,%eax
  8014e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ec:	c9                   	leave  
  8014ed:	c3                   	ret    

008014ee <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f9:	b8 08 00 00 00       	mov    $0x8,%eax
  8014fe:	e8 80 fd ff ff       	call   801283 <fsipc>
}
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	56                   	push   %esi
  801509:	53                   	push   %ebx
  80150a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	ff 75 08             	pushl  0x8(%ebp)
  801513:	e8 cc f7 ff ff       	call   800ce4 <fd2data>
  801518:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80151a:	83 c4 08             	add    $0x8,%esp
  80151d:	68 8b 22 80 00       	push   $0x80228b
  801522:	53                   	push   %ebx
  801523:	e8 b2 f1 ff ff       	call   8006da <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801528:	8b 56 04             	mov    0x4(%esi),%edx
  80152b:	89 d0                	mov    %edx,%eax
  80152d:	2b 06                	sub    (%esi),%eax
  80152f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801535:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80153c:	00 00 00 
	stat->st_dev = &devpipe;
  80153f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801546:	30 80 00 
	return 0;
}
  801549:	b8 00 00 00 00       	mov    $0x0,%eax
  80154e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801551:	5b                   	pop    %ebx
  801552:	5e                   	pop    %esi
  801553:	5d                   	pop    %ebp
  801554:	c3                   	ret    

00801555 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	53                   	push   %ebx
  801559:	83 ec 0c             	sub    $0xc,%esp
  80155c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80155f:	53                   	push   %ebx
  801560:	6a 00                	push   $0x0
  801562:	e8 01 f6 ff ff       	call   800b68 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801567:	89 1c 24             	mov    %ebx,(%esp)
  80156a:	e8 75 f7 ff ff       	call   800ce4 <fd2data>
  80156f:	83 c4 08             	add    $0x8,%esp
  801572:	50                   	push   %eax
  801573:	6a 00                	push   $0x0
  801575:	e8 ee f5 ff ff       	call   800b68 <sys_page_unmap>
}
  80157a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	57                   	push   %edi
  801583:	56                   	push   %esi
  801584:	53                   	push   %ebx
  801585:	83 ec 1c             	sub    $0x1c,%esp
  801588:	89 c6                	mov    %eax,%esi
  80158a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80158d:	a1 08 40 80 00       	mov    0x804008,%eax
  801592:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801595:	83 ec 0c             	sub    $0xc,%esp
  801598:	56                   	push   %esi
  801599:	e8 7e 05 00 00       	call   801b1c <pageref>
  80159e:	89 c7                	mov    %eax,%edi
  8015a0:	83 c4 04             	add    $0x4,%esp
  8015a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015a6:	e8 71 05 00 00       	call   801b1c <pageref>
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	39 c7                	cmp    %eax,%edi
  8015b0:	0f 94 c2             	sete   %dl
  8015b3:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8015b6:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  8015bc:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8015bf:	39 fb                	cmp    %edi,%ebx
  8015c1:	74 19                	je     8015dc <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  8015c3:	84 d2                	test   %dl,%dl
  8015c5:	74 c6                	je     80158d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015c7:	8b 51 58             	mov    0x58(%ecx),%edx
  8015ca:	50                   	push   %eax
  8015cb:	52                   	push   %edx
  8015cc:	53                   	push   %ebx
  8015cd:	68 92 22 80 00       	push   $0x802292
  8015d2:	e8 7c eb ff ff       	call   800153 <cprintf>
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	eb b1                	jmp    80158d <_pipeisclosed+0xe>
	}
}
  8015dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015df:	5b                   	pop    %ebx
  8015e0:	5e                   	pop    %esi
  8015e1:	5f                   	pop    %edi
  8015e2:	5d                   	pop    %ebp
  8015e3:	c3                   	ret    

008015e4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	57                   	push   %edi
  8015e8:	56                   	push   %esi
  8015e9:	53                   	push   %ebx
  8015ea:	83 ec 28             	sub    $0x28,%esp
  8015ed:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015f0:	56                   	push   %esi
  8015f1:	e8 ee f6 ff ff       	call   800ce4 <fd2data>
  8015f6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	bf 00 00 00 00       	mov    $0x0,%edi
  801600:	eb 4b                	jmp    80164d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801602:	89 da                	mov    %ebx,%edx
  801604:	89 f0                	mov    %esi,%eax
  801606:	e8 74 ff ff ff       	call   80157f <_pipeisclosed>
  80160b:	85 c0                	test   %eax,%eax
  80160d:	75 48                	jne    801657 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80160f:	e8 b0 f4 ff ff       	call   800ac4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801614:	8b 43 04             	mov    0x4(%ebx),%eax
  801617:	8b 0b                	mov    (%ebx),%ecx
  801619:	8d 51 20             	lea    0x20(%ecx),%edx
  80161c:	39 d0                	cmp    %edx,%eax
  80161e:	73 e2                	jae    801602 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801620:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801623:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801627:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	c1 fa 1f             	sar    $0x1f,%edx
  80162f:	89 d1                	mov    %edx,%ecx
  801631:	c1 e9 1b             	shr    $0x1b,%ecx
  801634:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801637:	83 e2 1f             	and    $0x1f,%edx
  80163a:	29 ca                	sub    %ecx,%edx
  80163c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801640:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801644:	83 c0 01             	add    $0x1,%eax
  801647:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80164a:	83 c7 01             	add    $0x1,%edi
  80164d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801650:	75 c2                	jne    801614 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801652:	8b 45 10             	mov    0x10(%ebp),%eax
  801655:	eb 05                	jmp    80165c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801657:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80165c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165f:	5b                   	pop    %ebx
  801660:	5e                   	pop    %esi
  801661:	5f                   	pop    %edi
  801662:	5d                   	pop    %ebp
  801663:	c3                   	ret    

00801664 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	57                   	push   %edi
  801668:	56                   	push   %esi
  801669:	53                   	push   %ebx
  80166a:	83 ec 18             	sub    $0x18,%esp
  80166d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801670:	57                   	push   %edi
  801671:	e8 6e f6 ff ff       	call   800ce4 <fd2data>
  801676:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801680:	eb 3d                	jmp    8016bf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801682:	85 db                	test   %ebx,%ebx
  801684:	74 04                	je     80168a <devpipe_read+0x26>
				return i;
  801686:	89 d8                	mov    %ebx,%eax
  801688:	eb 44                	jmp    8016ce <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80168a:	89 f2                	mov    %esi,%edx
  80168c:	89 f8                	mov    %edi,%eax
  80168e:	e8 ec fe ff ff       	call   80157f <_pipeisclosed>
  801693:	85 c0                	test   %eax,%eax
  801695:	75 32                	jne    8016c9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801697:	e8 28 f4 ff ff       	call   800ac4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80169c:	8b 06                	mov    (%esi),%eax
  80169e:	3b 46 04             	cmp    0x4(%esi),%eax
  8016a1:	74 df                	je     801682 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016a3:	99                   	cltd   
  8016a4:	c1 ea 1b             	shr    $0x1b,%edx
  8016a7:	01 d0                	add    %edx,%eax
  8016a9:	83 e0 1f             	and    $0x1f,%eax
  8016ac:	29 d0                	sub    %edx,%eax
  8016ae:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016b9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016bc:	83 c3 01             	add    $0x1,%ebx
  8016bf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016c2:	75 d8                	jne    80169c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8016c7:	eb 05                	jmp    8016ce <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016c9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d1:	5b                   	pop    %ebx
  8016d2:	5e                   	pop    %esi
  8016d3:	5f                   	pop    %edi
  8016d4:	5d                   	pop    %ebp
  8016d5:	c3                   	ret    

008016d6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	56                   	push   %esi
  8016da:	53                   	push   %ebx
  8016db:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e1:	50                   	push   %eax
  8016e2:	e8 14 f6 ff ff       	call   800cfb <fd_alloc>
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	0f 88 2c 01 00 00    	js     801820 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016f4:	83 ec 04             	sub    $0x4,%esp
  8016f7:	68 07 04 00 00       	push   $0x407
  8016fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ff:	6a 00                	push   $0x0
  801701:	e8 dd f3 ff ff       	call   800ae3 <sys_page_alloc>
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	89 c2                	mov    %eax,%edx
  80170b:	85 c0                	test   %eax,%eax
  80170d:	0f 88 0d 01 00 00    	js     801820 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801713:	83 ec 0c             	sub    $0xc,%esp
  801716:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801719:	50                   	push   %eax
  80171a:	e8 dc f5 ff ff       	call   800cfb <fd_alloc>
  80171f:	89 c3                	mov    %eax,%ebx
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	85 c0                	test   %eax,%eax
  801726:	0f 88 e2 00 00 00    	js     80180e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80172c:	83 ec 04             	sub    $0x4,%esp
  80172f:	68 07 04 00 00       	push   $0x407
  801734:	ff 75 f0             	pushl  -0x10(%ebp)
  801737:	6a 00                	push   $0x0
  801739:	e8 a5 f3 ff ff       	call   800ae3 <sys_page_alloc>
  80173e:	89 c3                	mov    %eax,%ebx
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	85 c0                	test   %eax,%eax
  801745:	0f 88 c3 00 00 00    	js     80180e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80174b:	83 ec 0c             	sub    $0xc,%esp
  80174e:	ff 75 f4             	pushl  -0xc(%ebp)
  801751:	e8 8e f5 ff ff       	call   800ce4 <fd2data>
  801756:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801758:	83 c4 0c             	add    $0xc,%esp
  80175b:	68 07 04 00 00       	push   $0x407
  801760:	50                   	push   %eax
  801761:	6a 00                	push   $0x0
  801763:	e8 7b f3 ff ff       	call   800ae3 <sys_page_alloc>
  801768:	89 c3                	mov    %eax,%ebx
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	85 c0                	test   %eax,%eax
  80176f:	0f 88 89 00 00 00    	js     8017fe <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801775:	83 ec 0c             	sub    $0xc,%esp
  801778:	ff 75 f0             	pushl  -0x10(%ebp)
  80177b:	e8 64 f5 ff ff       	call   800ce4 <fd2data>
  801780:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801787:	50                   	push   %eax
  801788:	6a 00                	push   $0x0
  80178a:	56                   	push   %esi
  80178b:	6a 00                	push   $0x0
  80178d:	e8 94 f3 ff ff       	call   800b26 <sys_page_map>
  801792:	89 c3                	mov    %eax,%ebx
  801794:	83 c4 20             	add    $0x20,%esp
  801797:	85 c0                	test   %eax,%eax
  801799:	78 55                	js     8017f0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80179b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017b0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017be:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017c5:	83 ec 0c             	sub    $0xc,%esp
  8017c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017cb:	e8 04 f5 ff ff       	call   800cd4 <fd2num>
  8017d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017d5:	83 c4 04             	add    $0x4,%esp
  8017d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017db:	e8 f4 f4 ff ff       	call   800cd4 <fd2num>
  8017e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ee:	eb 30                	jmp    801820 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017f0:	83 ec 08             	sub    $0x8,%esp
  8017f3:	56                   	push   %esi
  8017f4:	6a 00                	push   $0x0
  8017f6:	e8 6d f3 ff ff       	call   800b68 <sys_page_unmap>
  8017fb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017fe:	83 ec 08             	sub    $0x8,%esp
  801801:	ff 75 f0             	pushl  -0x10(%ebp)
  801804:	6a 00                	push   $0x0
  801806:	e8 5d f3 ff ff       	call   800b68 <sys_page_unmap>
  80180b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	ff 75 f4             	pushl  -0xc(%ebp)
  801814:	6a 00                	push   $0x0
  801816:	e8 4d f3 ff ff       	call   800b68 <sys_page_unmap>
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801820:	89 d0                	mov    %edx,%eax
  801822:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801825:	5b                   	pop    %ebx
  801826:	5e                   	pop    %esi
  801827:	5d                   	pop    %ebp
  801828:	c3                   	ret    

00801829 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80182f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801832:	50                   	push   %eax
  801833:	ff 75 08             	pushl  0x8(%ebp)
  801836:	e8 0f f5 ff ff       	call   800d4a <fd_lookup>
  80183b:	89 c2                	mov    %eax,%edx
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	85 d2                	test   %edx,%edx
  801842:	78 18                	js     80185c <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801844:	83 ec 0c             	sub    $0xc,%esp
  801847:	ff 75 f4             	pushl  -0xc(%ebp)
  80184a:	e8 95 f4 ff ff       	call   800ce4 <fd2data>
	return _pipeisclosed(fd, p);
  80184f:	89 c2                	mov    %eax,%edx
  801851:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801854:	e8 26 fd ff ff       	call   80157f <_pipeisclosed>
  801859:	83 c4 10             	add    $0x10,%esp
}
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801861:	b8 00 00 00 00       	mov    $0x0,%eax
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80186e:	68 aa 22 80 00       	push   $0x8022aa
  801873:	ff 75 0c             	pushl  0xc(%ebp)
  801876:	e8 5f ee ff ff       	call   8006da <strcpy>
	return 0;
}
  80187b:	b8 00 00 00 00       	mov    $0x0,%eax
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	57                   	push   %edi
  801886:	56                   	push   %esi
  801887:	53                   	push   %ebx
  801888:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80188e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801893:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801899:	eb 2d                	jmp    8018c8 <devcons_write+0x46>
		m = n - tot;
  80189b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80189e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018a0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018a3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018a8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	53                   	push   %ebx
  8018af:	03 45 0c             	add    0xc(%ebp),%eax
  8018b2:	50                   	push   %eax
  8018b3:	57                   	push   %edi
  8018b4:	e8 b3 ef ff ff       	call   80086c <memmove>
		sys_cputs(buf, m);
  8018b9:	83 c4 08             	add    $0x8,%esp
  8018bc:	53                   	push   %ebx
  8018bd:	57                   	push   %edi
  8018be:	e8 64 f1 ff ff       	call   800a27 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c3:	01 de                	add    %ebx,%esi
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	89 f0                	mov    %esi,%eax
  8018ca:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018cd:	72 cc                	jb     80189b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d2:	5b                   	pop    %ebx
  8018d3:	5e                   	pop    %esi
  8018d4:	5f                   	pop    %edi
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    

008018d7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8018dd:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8018e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018e6:	75 07                	jne    8018ef <devcons_read+0x18>
  8018e8:	eb 28                	jmp    801912 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018ea:	e8 d5 f1 ff ff       	call   800ac4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018ef:	e8 51 f1 ff ff       	call   800a45 <sys_cgetc>
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	74 f2                	je     8018ea <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	78 16                	js     801912 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018fc:	83 f8 04             	cmp    $0x4,%eax
  8018ff:	74 0c                	je     80190d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801901:	8b 55 0c             	mov    0xc(%ebp),%edx
  801904:	88 02                	mov    %al,(%edx)
	return 1;
  801906:	b8 01 00 00 00       	mov    $0x1,%eax
  80190b:	eb 05                	jmp    801912 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80190d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801920:	6a 01                	push   $0x1
  801922:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801925:	50                   	push   %eax
  801926:	e8 fc f0 ff ff       	call   800a27 <sys_cputs>
  80192b:	83 c4 10             	add    $0x10,%esp
}
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <getchar>:

int
getchar(void)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801936:	6a 01                	push   $0x1
  801938:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80193b:	50                   	push   %eax
  80193c:	6a 00                	push   $0x0
  80193e:	e8 71 f6 ff ff       	call   800fb4 <read>
	if (r < 0)
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	85 c0                	test   %eax,%eax
  801948:	78 0f                	js     801959 <getchar+0x29>
		return r;
	if (r < 1)
  80194a:	85 c0                	test   %eax,%eax
  80194c:	7e 06                	jle    801954 <getchar+0x24>
		return -E_EOF;
	return c;
  80194e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801952:	eb 05                	jmp    801959 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801954:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801964:	50                   	push   %eax
  801965:	ff 75 08             	pushl  0x8(%ebp)
  801968:	e8 dd f3 ff ff       	call   800d4a <fd_lookup>
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	85 c0                	test   %eax,%eax
  801972:	78 11                	js     801985 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801974:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801977:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80197d:	39 10                	cmp    %edx,(%eax)
  80197f:	0f 94 c0             	sete   %al
  801982:	0f b6 c0             	movzbl %al,%eax
}
  801985:	c9                   	leave  
  801986:	c3                   	ret    

00801987 <opencons>:

int
opencons(void)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80198d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801990:	50                   	push   %eax
  801991:	e8 65 f3 ff ff       	call   800cfb <fd_alloc>
  801996:	83 c4 10             	add    $0x10,%esp
		return r;
  801999:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 3e                	js     8019dd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80199f:	83 ec 04             	sub    $0x4,%esp
  8019a2:	68 07 04 00 00       	push   $0x407
  8019a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019aa:	6a 00                	push   $0x0
  8019ac:	e8 32 f1 ff ff       	call   800ae3 <sys_page_alloc>
  8019b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8019b4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 23                	js     8019dd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019ba:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019cf:	83 ec 0c             	sub    $0xc,%esp
  8019d2:	50                   	push   %eax
  8019d3:	e8 fc f2 ff ff       	call   800cd4 <fd2num>
  8019d8:	89 c2                	mov    %eax,%edx
  8019da:	83 c4 10             	add    $0x10,%esp
}
  8019dd:	89 d0                	mov    %edx,%eax
  8019df:	c9                   	leave  
  8019e0:	c3                   	ret    

008019e1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	56                   	push   %esi
  8019e5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019e6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019e9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019ef:	e8 b1 f0 ff ff       	call   800aa5 <sys_getenvid>
  8019f4:	83 ec 0c             	sub    $0xc,%esp
  8019f7:	ff 75 0c             	pushl  0xc(%ebp)
  8019fa:	ff 75 08             	pushl  0x8(%ebp)
  8019fd:	56                   	push   %esi
  8019fe:	50                   	push   %eax
  8019ff:	68 b8 22 80 00       	push   $0x8022b8
  801a04:	e8 4a e7 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a09:	83 c4 18             	add    $0x18,%esp
  801a0c:	53                   	push   %ebx
  801a0d:	ff 75 10             	pushl  0x10(%ebp)
  801a10:	e8 ed e6 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801a15:	c7 04 24 4c 1e 80 00 	movl   $0x801e4c,(%esp)
  801a1c:	e8 32 e7 ff ff       	call   800153 <cprintf>
  801a21:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a24:	cc                   	int3   
  801a25:	eb fd                	jmp    801a24 <_panic+0x43>

00801a27 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	56                   	push   %esi
  801a2b:	53                   	push   %ebx
  801a2c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801a35:	85 c0                	test   %eax,%eax
  801a37:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a3c:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801a3f:	83 ec 0c             	sub    $0xc,%esp
  801a42:	50                   	push   %eax
  801a43:	e8 4b f2 ff ff       	call   800c93 <sys_ipc_recv>
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	79 16                	jns    801a65 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801a4f:	85 f6                	test   %esi,%esi
  801a51:	74 06                	je     801a59 <ipc_recv+0x32>
  801a53:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801a59:	85 db                	test   %ebx,%ebx
  801a5b:	74 2c                	je     801a89 <ipc_recv+0x62>
  801a5d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a63:	eb 24                	jmp    801a89 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a65:	85 f6                	test   %esi,%esi
  801a67:	74 0a                	je     801a73 <ipc_recv+0x4c>
  801a69:	a1 08 40 80 00       	mov    0x804008,%eax
  801a6e:	8b 40 74             	mov    0x74(%eax),%eax
  801a71:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801a73:	85 db                	test   %ebx,%ebx
  801a75:	74 0a                	je     801a81 <ipc_recv+0x5a>
  801a77:	a1 08 40 80 00       	mov    0x804008,%eax
  801a7c:	8b 40 78             	mov    0x78(%eax),%eax
  801a7f:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801a81:	a1 08 40 80 00       	mov    0x804008,%eax
  801a86:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8c:	5b                   	pop    %ebx
  801a8d:	5e                   	pop    %esi
  801a8e:	5d                   	pop    %ebp
  801a8f:	c3                   	ret    

00801a90 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	57                   	push   %edi
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	83 ec 0c             	sub    $0xc,%esp
  801a99:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801aa2:	85 db                	test   %ebx,%ebx
  801aa4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801aa9:	0f 44 d8             	cmove  %eax,%ebx
  801aac:	eb 1c                	jmp    801aca <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801aae:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ab1:	74 12                	je     801ac5 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801ab3:	50                   	push   %eax
  801ab4:	68 dc 22 80 00       	push   $0x8022dc
  801ab9:	6a 39                	push   $0x39
  801abb:	68 f7 22 80 00       	push   $0x8022f7
  801ac0:	e8 1c ff ff ff       	call   8019e1 <_panic>
                 sys_yield();
  801ac5:	e8 fa ef ff ff       	call   800ac4 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801aca:	ff 75 14             	pushl  0x14(%ebp)
  801acd:	53                   	push   %ebx
  801ace:	56                   	push   %esi
  801acf:	57                   	push   %edi
  801ad0:	e8 9b f1 ff ff       	call   800c70 <sys_ipc_try_send>
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	78 d2                	js     801aae <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801adc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adf:	5b                   	pop    %ebx
  801ae0:	5e                   	pop    %esi
  801ae1:	5f                   	pop    %edi
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    

00801ae4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801aea:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aef:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801af2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af8:	8b 52 50             	mov    0x50(%edx),%edx
  801afb:	39 ca                	cmp    %ecx,%edx
  801afd:	75 0d                	jne    801b0c <ipc_find_env+0x28>
			return envs[i].env_id;
  801aff:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b02:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801b07:	8b 40 08             	mov    0x8(%eax),%eax
  801b0a:	eb 0e                	jmp    801b1a <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b0c:	83 c0 01             	add    $0x1,%eax
  801b0f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b14:	75 d9                	jne    801aef <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b16:	66 b8 00 00          	mov    $0x0,%ax
}
  801b1a:	5d                   	pop    %ebp
  801b1b:	c3                   	ret    

00801b1c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b22:	89 d0                	mov    %edx,%eax
  801b24:	c1 e8 16             	shr    $0x16,%eax
  801b27:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b2e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b33:	f6 c1 01             	test   $0x1,%cl
  801b36:	74 1d                	je     801b55 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b38:	c1 ea 0c             	shr    $0xc,%edx
  801b3b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b42:	f6 c2 01             	test   $0x1,%dl
  801b45:	74 0e                	je     801b55 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b47:	c1 ea 0c             	shr    $0xc,%edx
  801b4a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b51:	ef 
  801b52:	0f b7 c0             	movzwl %ax,%eax
}
  801b55:	5d                   	pop    %ebp
  801b56:	c3                   	ret    
  801b57:	66 90                	xchg   %ax,%ax
  801b59:	66 90                	xchg   %ax,%ax
  801b5b:	66 90                	xchg   %ax,%ax
  801b5d:	66 90                	xchg   %ax,%ax
  801b5f:	90                   	nop

00801b60 <__udivdi3>:
  801b60:	55                   	push   %ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	83 ec 10             	sub    $0x10,%esp
  801b66:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b6a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b6e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b72:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b76:	85 d2                	test   %edx,%edx
  801b78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b7c:	89 34 24             	mov    %esi,(%esp)
  801b7f:	89 c8                	mov    %ecx,%eax
  801b81:	75 35                	jne    801bb8 <__udivdi3+0x58>
  801b83:	39 f1                	cmp    %esi,%ecx
  801b85:	0f 87 bd 00 00 00    	ja     801c48 <__udivdi3+0xe8>
  801b8b:	85 c9                	test   %ecx,%ecx
  801b8d:	89 cd                	mov    %ecx,%ebp
  801b8f:	75 0b                	jne    801b9c <__udivdi3+0x3c>
  801b91:	b8 01 00 00 00       	mov    $0x1,%eax
  801b96:	31 d2                	xor    %edx,%edx
  801b98:	f7 f1                	div    %ecx
  801b9a:	89 c5                	mov    %eax,%ebp
  801b9c:	89 f0                	mov    %esi,%eax
  801b9e:	31 d2                	xor    %edx,%edx
  801ba0:	f7 f5                	div    %ebp
  801ba2:	89 c6                	mov    %eax,%esi
  801ba4:	89 f8                	mov    %edi,%eax
  801ba6:	f7 f5                	div    %ebp
  801ba8:	89 f2                	mov    %esi,%edx
  801baa:	83 c4 10             	add    $0x10,%esp
  801bad:	5e                   	pop    %esi
  801bae:	5f                   	pop    %edi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    
  801bb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bb8:	3b 14 24             	cmp    (%esp),%edx
  801bbb:	77 7b                	ja     801c38 <__udivdi3+0xd8>
  801bbd:	0f bd f2             	bsr    %edx,%esi
  801bc0:	83 f6 1f             	xor    $0x1f,%esi
  801bc3:	0f 84 97 00 00 00    	je     801c60 <__udivdi3+0x100>
  801bc9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801bce:	89 d7                	mov    %edx,%edi
  801bd0:	89 f1                	mov    %esi,%ecx
  801bd2:	29 f5                	sub    %esi,%ebp
  801bd4:	d3 e7                	shl    %cl,%edi
  801bd6:	89 c2                	mov    %eax,%edx
  801bd8:	89 e9                	mov    %ebp,%ecx
  801bda:	d3 ea                	shr    %cl,%edx
  801bdc:	89 f1                	mov    %esi,%ecx
  801bde:	09 fa                	or     %edi,%edx
  801be0:	8b 3c 24             	mov    (%esp),%edi
  801be3:	d3 e0                	shl    %cl,%eax
  801be5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801be9:	89 e9                	mov    %ebp,%ecx
  801beb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bef:	8b 44 24 04          	mov    0x4(%esp),%eax
  801bf3:	89 fa                	mov    %edi,%edx
  801bf5:	d3 ea                	shr    %cl,%edx
  801bf7:	89 f1                	mov    %esi,%ecx
  801bf9:	d3 e7                	shl    %cl,%edi
  801bfb:	89 e9                	mov    %ebp,%ecx
  801bfd:	d3 e8                	shr    %cl,%eax
  801bff:	09 c7                	or     %eax,%edi
  801c01:	89 f8                	mov    %edi,%eax
  801c03:	f7 74 24 08          	divl   0x8(%esp)
  801c07:	89 d5                	mov    %edx,%ebp
  801c09:	89 c7                	mov    %eax,%edi
  801c0b:	f7 64 24 0c          	mull   0xc(%esp)
  801c0f:	39 d5                	cmp    %edx,%ebp
  801c11:	89 14 24             	mov    %edx,(%esp)
  801c14:	72 11                	jb     801c27 <__udivdi3+0xc7>
  801c16:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c1a:	89 f1                	mov    %esi,%ecx
  801c1c:	d3 e2                	shl    %cl,%edx
  801c1e:	39 c2                	cmp    %eax,%edx
  801c20:	73 5e                	jae    801c80 <__udivdi3+0x120>
  801c22:	3b 2c 24             	cmp    (%esp),%ebp
  801c25:	75 59                	jne    801c80 <__udivdi3+0x120>
  801c27:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c2a:	31 f6                	xor    %esi,%esi
  801c2c:	89 f2                	mov    %esi,%edx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    
  801c35:	8d 76 00             	lea    0x0(%esi),%esi
  801c38:	31 f6                	xor    %esi,%esi
  801c3a:	31 c0                	xor    %eax,%eax
  801c3c:	89 f2                	mov    %esi,%edx
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	5e                   	pop    %esi
  801c42:	5f                   	pop    %edi
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    
  801c45:	8d 76 00             	lea    0x0(%esi),%esi
  801c48:	89 f2                	mov    %esi,%edx
  801c4a:	31 f6                	xor    %esi,%esi
  801c4c:	89 f8                	mov    %edi,%eax
  801c4e:	f7 f1                	div    %ecx
  801c50:	89 f2                	mov    %esi,%edx
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	5e                   	pop    %esi
  801c56:	5f                   	pop    %edi
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    
  801c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c60:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c64:	76 0b                	jbe    801c71 <__udivdi3+0x111>
  801c66:	31 c0                	xor    %eax,%eax
  801c68:	3b 14 24             	cmp    (%esp),%edx
  801c6b:	0f 83 37 ff ff ff    	jae    801ba8 <__udivdi3+0x48>
  801c71:	b8 01 00 00 00       	mov    $0x1,%eax
  801c76:	e9 2d ff ff ff       	jmp    801ba8 <__udivdi3+0x48>
  801c7b:	90                   	nop
  801c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c80:	89 f8                	mov    %edi,%eax
  801c82:	31 f6                	xor    %esi,%esi
  801c84:	e9 1f ff ff ff       	jmp    801ba8 <__udivdi3+0x48>
  801c89:	66 90                	xchg   %ax,%ax
  801c8b:	66 90                	xchg   %ax,%ax
  801c8d:	66 90                	xchg   %ax,%ax
  801c8f:	90                   	nop

00801c90 <__umoddi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	83 ec 20             	sub    $0x20,%esp
  801c96:	8b 44 24 34          	mov    0x34(%esp),%eax
  801c9a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c9e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca2:	89 c6                	mov    %eax,%esi
  801ca4:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ca8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801cb0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801cb4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801cb8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	89 c2                	mov    %eax,%edx
  801cc0:	75 1e                	jne    801ce0 <__umoddi3+0x50>
  801cc2:	39 f7                	cmp    %esi,%edi
  801cc4:	76 52                	jbe    801d18 <__umoddi3+0x88>
  801cc6:	89 c8                	mov    %ecx,%eax
  801cc8:	89 f2                	mov    %esi,%edx
  801cca:	f7 f7                	div    %edi
  801ccc:	89 d0                	mov    %edx,%eax
  801cce:	31 d2                	xor    %edx,%edx
  801cd0:	83 c4 20             	add    $0x20,%esp
  801cd3:	5e                   	pop    %esi
  801cd4:	5f                   	pop    %edi
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    
  801cd7:	89 f6                	mov    %esi,%esi
  801cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801ce0:	39 f0                	cmp    %esi,%eax
  801ce2:	77 5c                	ja     801d40 <__umoddi3+0xb0>
  801ce4:	0f bd e8             	bsr    %eax,%ebp
  801ce7:	83 f5 1f             	xor    $0x1f,%ebp
  801cea:	75 64                	jne    801d50 <__umoddi3+0xc0>
  801cec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801cf0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801cf4:	0f 86 f6 00 00 00    	jbe    801df0 <__umoddi3+0x160>
  801cfa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cfe:	0f 82 ec 00 00 00    	jb     801df0 <__umoddi3+0x160>
  801d04:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d08:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d0c:	83 c4 20             	add    $0x20,%esp
  801d0f:	5e                   	pop    %esi
  801d10:	5f                   	pop    %edi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    
  801d13:	90                   	nop
  801d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d18:	85 ff                	test   %edi,%edi
  801d1a:	89 fd                	mov    %edi,%ebp
  801d1c:	75 0b                	jne    801d29 <__umoddi3+0x99>
  801d1e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d23:	31 d2                	xor    %edx,%edx
  801d25:	f7 f7                	div    %edi
  801d27:	89 c5                	mov    %eax,%ebp
  801d29:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d2d:	31 d2                	xor    %edx,%edx
  801d2f:	f7 f5                	div    %ebp
  801d31:	89 c8                	mov    %ecx,%eax
  801d33:	f7 f5                	div    %ebp
  801d35:	eb 95                	jmp    801ccc <__umoddi3+0x3c>
  801d37:	89 f6                	mov    %esi,%esi
  801d39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d40:	89 c8                	mov    %ecx,%eax
  801d42:	89 f2                	mov    %esi,%edx
  801d44:	83 c4 20             	add    $0x20,%esp
  801d47:	5e                   	pop    %esi
  801d48:	5f                   	pop    %edi
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    
  801d4b:	90                   	nop
  801d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d50:	b8 20 00 00 00       	mov    $0x20,%eax
  801d55:	89 e9                	mov    %ebp,%ecx
  801d57:	29 e8                	sub    %ebp,%eax
  801d59:	d3 e2                	shl    %cl,%edx
  801d5b:	89 c7                	mov    %eax,%edi
  801d5d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d61:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d65:	89 f9                	mov    %edi,%ecx
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 c1                	mov    %eax,%ecx
  801d6b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d6f:	09 d1                	or     %edx,%ecx
  801d71:	89 fa                	mov    %edi,%edx
  801d73:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d77:	89 e9                	mov    %ebp,%ecx
  801d79:	d3 e0                	shl    %cl,%eax
  801d7b:	89 f9                	mov    %edi,%ecx
  801d7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	d3 e8                	shr    %cl,%eax
  801d85:	89 e9                	mov    %ebp,%ecx
  801d87:	89 c7                	mov    %eax,%edi
  801d89:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d8d:	d3 e6                	shl    %cl,%esi
  801d8f:	89 d1                	mov    %edx,%ecx
  801d91:	89 fa                	mov    %edi,%edx
  801d93:	d3 e8                	shr    %cl,%eax
  801d95:	89 e9                	mov    %ebp,%ecx
  801d97:	09 f0                	or     %esi,%eax
  801d99:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801d9d:	f7 74 24 10          	divl   0x10(%esp)
  801da1:	d3 e6                	shl    %cl,%esi
  801da3:	89 d1                	mov    %edx,%ecx
  801da5:	f7 64 24 0c          	mull   0xc(%esp)
  801da9:	39 d1                	cmp    %edx,%ecx
  801dab:	89 74 24 14          	mov    %esi,0x14(%esp)
  801daf:	89 d7                	mov    %edx,%edi
  801db1:	89 c6                	mov    %eax,%esi
  801db3:	72 0a                	jb     801dbf <__umoddi3+0x12f>
  801db5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801db9:	73 10                	jae    801dcb <__umoddi3+0x13b>
  801dbb:	39 d1                	cmp    %edx,%ecx
  801dbd:	75 0c                	jne    801dcb <__umoddi3+0x13b>
  801dbf:	89 d7                	mov    %edx,%edi
  801dc1:	89 c6                	mov    %eax,%esi
  801dc3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801dc7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801dcb:	89 ca                	mov    %ecx,%edx
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801dd3:	29 f0                	sub    %esi,%eax
  801dd5:	19 fa                	sbb    %edi,%edx
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801dde:	89 d7                	mov    %edx,%edi
  801de0:	d3 e7                	shl    %cl,%edi
  801de2:	89 e9                	mov    %ebp,%ecx
  801de4:	09 f8                	or     %edi,%eax
  801de6:	d3 ea                	shr    %cl,%edx
  801de8:	83 c4 20             	add    $0x20,%esp
  801deb:	5e                   	pop    %esi
  801dec:	5f                   	pop    %edi
  801ded:	5d                   	pop    %ebp
  801dee:	c3                   	ret    
  801def:	90                   	nop
  801df0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801df4:	29 f9                	sub    %edi,%ecx
  801df6:	19 c6                	sbb    %eax,%esi
  801df8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801dfc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e00:	e9 ff fe ff ff       	jmp    801d04 <__umoddi3+0x74>
