
obj/user/faultdie.debug:     file format elf32-i386


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
  800045:	68 00 24 80 00       	push   $0x802400
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 71 0a 00 00       	call   800ac5 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 28 0a 00 00       	call   800a84 <sys_env_destroy>
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
  80006c:	e8 24 0d 00 00       	call   800d95 <set_pgfault_handler>
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
  80008b:	e8 35 0a 00 00       	call   800ac5 <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 29 0f 00 00       	call   800ffa <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 a9 09 00 00       	call   800a84 <sys_env_destroy>
  8000db:	83 c4 10             	add    $0x10,%esp
}
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 37 09 00 00       	call   800a47 <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 4f 01 00 00       	call   8002a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 dc 08 00 00       	call   800a47 <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 d1                	mov    %edx,%ecx
  80019c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001b2:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001b5:	72 05                	jb     8001bc <printnum+0x35>
  8001b7:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001ba:	77 3e                	ja     8001fa <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	ff 75 18             	pushl  0x18(%ebp)
  8001c2:	83 eb 01             	sub    $0x1,%ebx
  8001c5:	53                   	push   %ebx
  8001c6:	50                   	push   %eax
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 55 1f 00 00       	call   802130 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 13                	jmp    800201 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001fa:	83 eb 01             	sub    $0x1,%ebx
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7f ed                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	56                   	push   %esi
  800205:	83 ec 04             	sub    $0x4,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 47 20 00 00       	call   802260 <__umoddi3>
  800219:	83 c4 14             	add    $0x14,%esp
  80021c:	0f be 80 26 24 80 00 	movsbl 0x802426(%eax),%eax
  800223:	50                   	push   %eax
  800224:	ff d7                	call   *%edi
  800226:	83 c4 10             	add    $0x10,%esp
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800234:	83 fa 01             	cmp    $0x1,%edx
  800237:	7e 0e                	jle    800247 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800239:	8b 10                	mov    (%eax),%edx
  80023b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80023e:	89 08                	mov    %ecx,(%eax)
  800240:	8b 02                	mov    (%edx),%eax
  800242:	8b 52 04             	mov    0x4(%edx),%edx
  800245:	eb 22                	jmp    800269 <getuint+0x38>
	else if (lflag)
  800247:	85 d2                	test   %edx,%edx
  800249:	74 10                	je     80025b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80024b:	8b 10                	mov    (%eax),%edx
  80024d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800250:	89 08                	mov    %ecx,(%eax)
  800252:	8b 02                	mov    (%edx),%eax
  800254:	ba 00 00 00 00       	mov    $0x0,%edx
  800259:	eb 0e                	jmp    800269 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80025b:	8b 10                	mov    (%eax),%edx
  80025d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800260:	89 08                	mov    %ecx,(%eax)
  800262:	8b 02                	mov    (%edx),%eax
  800264:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800271:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800275:	8b 10                	mov    (%eax),%edx
  800277:	3b 50 04             	cmp    0x4(%eax),%edx
  80027a:	73 0a                	jae    800286 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 45 08             	mov    0x8(%ebp),%eax
  800284:	88 02                	mov    %al,(%edx)
}
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80028e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 10             	pushl  0x10(%ebp)
  800295:	ff 75 0c             	pushl  0xc(%ebp)
  800298:	ff 75 08             	pushl  0x8(%ebp)
  80029b:	e8 05 00 00 00       	call   8002a5 <vprintfmt>
	va_end(ap);
  8002a0:	83 c4 10             	add    $0x10,%esp
}
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 2c             	sub    $0x2c,%esp
  8002ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b7:	eb 12                	jmp    8002cb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b9:	85 c0                	test   %eax,%eax
  8002bb:	0f 84 90 03 00 00    	je     800651 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	53                   	push   %ebx
  8002c5:	50                   	push   %eax
  8002c6:	ff d6                	call   *%esi
  8002c8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cb:	83 c7 01             	add    $0x1,%edi
  8002ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d2:	83 f8 25             	cmp    $0x25,%eax
  8002d5:	75 e2                	jne    8002b9 <vprintfmt+0x14>
  8002d7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002db:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f5:	eb 07                	jmp    8002fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002fa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	8d 47 01             	lea    0x1(%edi),%eax
  800301:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800304:	0f b6 07             	movzbl (%edi),%eax
  800307:	0f b6 c8             	movzbl %al,%ecx
  80030a:	83 e8 23             	sub    $0x23,%eax
  80030d:	3c 55                	cmp    $0x55,%al
  80030f:	0f 87 21 03 00 00    	ja     800636 <vprintfmt+0x391>
  800315:	0f b6 c0             	movzbl %al,%eax
  800318:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800322:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800326:	eb d6                	jmp    8002fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032b:	b8 00 00 00 00       	mov    $0x0,%eax
  800330:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800333:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800336:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80033a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80033d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800340:	83 fa 09             	cmp    $0x9,%edx
  800343:	77 39                	ja     80037e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800345:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800348:	eb e9                	jmp    800333 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8d 48 04             	lea    0x4(%eax),%ecx
  800350:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800353:	8b 00                	mov    (%eax),%eax
  800355:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80035b:	eb 27                	jmp    800384 <vprintfmt+0xdf>
  80035d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800360:	85 c0                	test   %eax,%eax
  800362:	b9 00 00 00 00       	mov    $0x0,%ecx
  800367:	0f 49 c8             	cmovns %eax,%ecx
  80036a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800370:	eb 8c                	jmp    8002fe <vprintfmt+0x59>
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800375:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80037c:	eb 80                	jmp    8002fe <vprintfmt+0x59>
  80037e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800381:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800384:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800388:	0f 89 70 ff ff ff    	jns    8002fe <vprintfmt+0x59>
				width = precision, precision = -1;
  80038e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800391:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800394:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80039b:	e9 5e ff ff ff       	jmp    8002fe <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003a6:	e9 53 ff ff ff       	jmp    8002fe <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8d 50 04             	lea    0x4(%eax),%edx
  8003b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b4:	83 ec 08             	sub    $0x8,%esp
  8003b7:	53                   	push   %ebx
  8003b8:	ff 30                	pushl  (%eax)
  8003ba:	ff d6                	call   *%esi
			break;
  8003bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c2:	e9 04 ff ff ff       	jmp    8002cb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ca:	8d 50 04             	lea    0x4(%eax),%edx
  8003cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d0:	8b 00                	mov    (%eax),%eax
  8003d2:	99                   	cltd   
  8003d3:	31 d0                	xor    %edx,%eax
  8003d5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d7:	83 f8 0f             	cmp    $0xf,%eax
  8003da:	7f 0b                	jg     8003e7 <vprintfmt+0x142>
  8003dc:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  8003e3:	85 d2                	test   %edx,%edx
  8003e5:	75 18                	jne    8003ff <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003e7:	50                   	push   %eax
  8003e8:	68 3e 24 80 00       	push   $0x80243e
  8003ed:	53                   	push   %ebx
  8003ee:	56                   	push   %esi
  8003ef:	e8 94 fe ff ff       	call   800288 <printfmt>
  8003f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003fa:	e9 cc fe ff ff       	jmp    8002cb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ff:	52                   	push   %edx
  800400:	68 a5 28 80 00       	push   $0x8028a5
  800405:	53                   	push   %ebx
  800406:	56                   	push   %esi
  800407:	e8 7c fe ff ff       	call   800288 <printfmt>
  80040c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800412:	e9 b4 fe ff ff       	jmp    8002cb <vprintfmt+0x26>
  800417:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80041a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80041d:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80042b:	85 ff                	test   %edi,%edi
  80042d:	ba 37 24 80 00       	mov    $0x802437,%edx
  800432:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800435:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800439:	0f 84 92 00 00 00    	je     8004d1 <vprintfmt+0x22c>
  80043f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800443:	0f 8e 96 00 00 00    	jle    8004df <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	51                   	push   %ecx
  80044d:	57                   	push   %edi
  80044e:	e8 86 02 00 00       	call   8006d9 <strnlen>
  800453:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800456:	29 c1                	sub    %eax,%ecx
  800458:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80045b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800462:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800465:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800468:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046a:	eb 0f                	jmp    80047b <vprintfmt+0x1d6>
					putch(padc, putdat);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	53                   	push   %ebx
  800470:	ff 75 e0             	pushl  -0x20(%ebp)
  800473:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800475:	83 ef 01             	sub    $0x1,%edi
  800478:	83 c4 10             	add    $0x10,%esp
  80047b:	85 ff                	test   %edi,%edi
  80047d:	7f ed                	jg     80046c <vprintfmt+0x1c7>
  80047f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800482:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800485:	85 c9                	test   %ecx,%ecx
  800487:	b8 00 00 00 00       	mov    $0x0,%eax
  80048c:	0f 49 c1             	cmovns %ecx,%eax
  80048f:	29 c1                	sub    %eax,%ecx
  800491:	89 75 08             	mov    %esi,0x8(%ebp)
  800494:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800497:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049a:	89 cb                	mov    %ecx,%ebx
  80049c:	eb 4d                	jmp    8004eb <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a2:	74 1b                	je     8004bf <vprintfmt+0x21a>
  8004a4:	0f be c0             	movsbl %al,%eax
  8004a7:	83 e8 20             	sub    $0x20,%eax
  8004aa:	83 f8 5e             	cmp    $0x5e,%eax
  8004ad:	76 10                	jbe    8004bf <vprintfmt+0x21a>
					putch('?', putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	ff 75 0c             	pushl  0xc(%ebp)
  8004b5:	6a 3f                	push   $0x3f
  8004b7:	ff 55 08             	call   *0x8(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	eb 0d                	jmp    8004cc <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	ff 75 0c             	pushl  0xc(%ebp)
  8004c5:	52                   	push   %edx
  8004c6:	ff 55 08             	call   *0x8(%ebp)
  8004c9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004cc:	83 eb 01             	sub    $0x1,%ebx
  8004cf:	eb 1a                	jmp    8004eb <vprintfmt+0x246>
  8004d1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004da:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004dd:	eb 0c                	jmp    8004eb <vprintfmt+0x246>
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004eb:	83 c7 01             	add    $0x1,%edi
  8004ee:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f2:	0f be d0             	movsbl %al,%edx
  8004f5:	85 d2                	test   %edx,%edx
  8004f7:	74 23                	je     80051c <vprintfmt+0x277>
  8004f9:	85 f6                	test   %esi,%esi
  8004fb:	78 a1                	js     80049e <vprintfmt+0x1f9>
  8004fd:	83 ee 01             	sub    $0x1,%esi
  800500:	79 9c                	jns    80049e <vprintfmt+0x1f9>
  800502:	89 df                	mov    %ebx,%edi
  800504:	8b 75 08             	mov    0x8(%ebp),%esi
  800507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050a:	eb 18                	jmp    800524 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	6a 20                	push   $0x20
  800512:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800514:	83 ef 01             	sub    $0x1,%edi
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	eb 08                	jmp    800524 <vprintfmt+0x27f>
  80051c:	89 df                	mov    %ebx,%edi
  80051e:	8b 75 08             	mov    0x8(%ebp),%esi
  800521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800524:	85 ff                	test   %edi,%edi
  800526:	7f e4                	jg     80050c <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052b:	e9 9b fd ff ff       	jmp    8002cb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800530:	83 fa 01             	cmp    $0x1,%edx
  800533:	7e 16                	jle    80054b <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 08             	lea    0x8(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 50 04             	mov    0x4(%eax),%edx
  800541:	8b 00                	mov    (%eax),%eax
  800543:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800546:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800549:	eb 32                	jmp    80057d <vprintfmt+0x2d8>
	else if (lflag)
  80054b:	85 d2                	test   %edx,%edx
  80054d:	74 18                	je     800567 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055d:	89 c1                	mov    %eax,%ecx
  80055f:	c1 f9 1f             	sar    $0x1f,%ecx
  800562:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800565:	eb 16                	jmp    80057d <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800575:	89 c1                	mov    %eax,%ecx
  800577:	c1 f9 1f             	sar    $0x1f,%ecx
  80057a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800580:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800583:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800588:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058c:	79 74                	jns    800602 <vprintfmt+0x35d>
				putch('-', putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	53                   	push   %ebx
  800592:	6a 2d                	push   $0x2d
  800594:	ff d6                	call   *%esi
				num = -(long long) num;
  800596:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800599:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059c:	f7 d8                	neg    %eax
  80059e:	83 d2 00             	adc    $0x0,%edx
  8005a1:	f7 da                	neg    %edx
  8005a3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ab:	eb 55                	jmp    800602 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b0:	e8 7c fc ff ff       	call   800231 <getuint>
			base = 10;
  8005b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ba:	eb 46                	jmp    800602 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bf:	e8 6d fc ff ff       	call   800231 <getuint>
                        base = 8;
  8005c4:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005c9:	eb 37                	jmp    800602 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 30                	push   $0x30
  8005d1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d3:	83 c4 08             	add    $0x8,%esp
  8005d6:	53                   	push   %ebx
  8005d7:	6a 78                	push   $0x78
  8005d9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 50 04             	lea    0x4(%eax),%edx
  8005e1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005eb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ee:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f3:	eb 0d                	jmp    800602 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f8:	e8 34 fc ff ff       	call   800231 <getuint>
			base = 16;
  8005fd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800602:	83 ec 0c             	sub    $0xc,%esp
  800605:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800609:	57                   	push   %edi
  80060a:	ff 75 e0             	pushl  -0x20(%ebp)
  80060d:	51                   	push   %ecx
  80060e:	52                   	push   %edx
  80060f:	50                   	push   %eax
  800610:	89 da                	mov    %ebx,%edx
  800612:	89 f0                	mov    %esi,%eax
  800614:	e8 6e fb ff ff       	call   800187 <printnum>
			break;
  800619:	83 c4 20             	add    $0x20,%esp
  80061c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061f:	e9 a7 fc ff ff       	jmp    8002cb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	51                   	push   %ecx
  800629:	ff d6                	call   *%esi
			break;
  80062b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800631:	e9 95 fc ff ff       	jmp    8002cb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	53                   	push   %ebx
  80063a:	6a 25                	push   $0x25
  80063c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063e:	83 c4 10             	add    $0x10,%esp
  800641:	eb 03                	jmp    800646 <vprintfmt+0x3a1>
  800643:	83 ef 01             	sub    $0x1,%edi
  800646:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80064a:	75 f7                	jne    800643 <vprintfmt+0x39e>
  80064c:	e9 7a fc ff ff       	jmp    8002cb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800651:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800654:	5b                   	pop    %ebx
  800655:	5e                   	pop    %esi
  800656:	5f                   	pop    %edi
  800657:	5d                   	pop    %ebp
  800658:	c3                   	ret    

00800659 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	83 ec 18             	sub    $0x18,%esp
  80065f:	8b 45 08             	mov    0x8(%ebp),%eax
  800662:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800665:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800668:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800676:	85 c0                	test   %eax,%eax
  800678:	74 26                	je     8006a0 <vsnprintf+0x47>
  80067a:	85 d2                	test   %edx,%edx
  80067c:	7e 22                	jle    8006a0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067e:	ff 75 14             	pushl  0x14(%ebp)
  800681:	ff 75 10             	pushl  0x10(%ebp)
  800684:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800687:	50                   	push   %eax
  800688:	68 6b 02 80 00       	push   $0x80026b
  80068d:	e8 13 fc ff ff       	call   8002a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800692:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800695:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	eb 05                	jmp    8006a5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a5:	c9                   	leave  
  8006a6:	c3                   	ret    

008006a7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a7:	55                   	push   %ebp
  8006a8:	89 e5                	mov    %esp,%ebp
  8006aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ad:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b0:	50                   	push   %eax
  8006b1:	ff 75 10             	pushl  0x10(%ebp)
  8006b4:	ff 75 0c             	pushl  0xc(%ebp)
  8006b7:	ff 75 08             	pushl  0x8(%ebp)
  8006ba:	e8 9a ff ff ff       	call   800659 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cc:	eb 03                	jmp    8006d1 <strlen+0x10>
		n++;
  8006ce:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d5:	75 f7                	jne    8006ce <strlen+0xd>
		n++;
	return n;
}
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006df:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e7:	eb 03                	jmp    8006ec <strnlen+0x13>
		n++;
  8006e9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ec:	39 c2                	cmp    %eax,%edx
  8006ee:	74 08                	je     8006f8 <strnlen+0x1f>
  8006f0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f4:	75 f3                	jne    8006e9 <strnlen+0x10>
  8006f6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	53                   	push   %ebx
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800704:	89 c2                	mov    %eax,%edx
  800706:	83 c2 01             	add    $0x1,%edx
  800709:	83 c1 01             	add    $0x1,%ecx
  80070c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800710:	88 5a ff             	mov    %bl,-0x1(%edx)
  800713:	84 db                	test   %bl,%bl
  800715:	75 ef                	jne    800706 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800717:	5b                   	pop    %ebx
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	53                   	push   %ebx
  80071e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800721:	53                   	push   %ebx
  800722:	e8 9a ff ff ff       	call   8006c1 <strlen>
  800727:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80072a:	ff 75 0c             	pushl  0xc(%ebp)
  80072d:	01 d8                	add    %ebx,%eax
  80072f:	50                   	push   %eax
  800730:	e8 c5 ff ff ff       	call   8006fa <strcpy>
	return dst;
}
  800735:	89 d8                	mov    %ebx,%eax
  800737:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	56                   	push   %esi
  800740:	53                   	push   %ebx
  800741:	8b 75 08             	mov    0x8(%ebp),%esi
  800744:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800747:	89 f3                	mov    %esi,%ebx
  800749:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074c:	89 f2                	mov    %esi,%edx
  80074e:	eb 0f                	jmp    80075f <strncpy+0x23>
		*dst++ = *src;
  800750:	83 c2 01             	add    $0x1,%edx
  800753:	0f b6 01             	movzbl (%ecx),%eax
  800756:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800759:	80 39 01             	cmpb   $0x1,(%ecx)
  80075c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075f:	39 da                	cmp    %ebx,%edx
  800761:	75 ed                	jne    800750 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800763:	89 f0                	mov    %esi,%eax
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	5d                   	pop    %ebp
  800768:	c3                   	ret    

00800769 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	56                   	push   %esi
  80076d:	53                   	push   %ebx
  80076e:	8b 75 08             	mov    0x8(%ebp),%esi
  800771:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800774:	8b 55 10             	mov    0x10(%ebp),%edx
  800777:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800779:	85 d2                	test   %edx,%edx
  80077b:	74 21                	je     80079e <strlcpy+0x35>
  80077d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800781:	89 f2                	mov    %esi,%edx
  800783:	eb 09                	jmp    80078e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800785:	83 c2 01             	add    $0x1,%edx
  800788:	83 c1 01             	add    $0x1,%ecx
  80078b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078e:	39 c2                	cmp    %eax,%edx
  800790:	74 09                	je     80079b <strlcpy+0x32>
  800792:	0f b6 19             	movzbl (%ecx),%ebx
  800795:	84 db                	test   %bl,%bl
  800797:	75 ec                	jne    800785 <strlcpy+0x1c>
  800799:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80079b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079e:	29 f0                	sub    %esi,%eax
}
  8007a0:	5b                   	pop    %ebx
  8007a1:	5e                   	pop    %esi
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ad:	eb 06                	jmp    8007b5 <strcmp+0x11>
		p++, q++;
  8007af:	83 c1 01             	add    $0x1,%ecx
  8007b2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b5:	0f b6 01             	movzbl (%ecx),%eax
  8007b8:	84 c0                	test   %al,%al
  8007ba:	74 04                	je     8007c0 <strcmp+0x1c>
  8007bc:	3a 02                	cmp    (%edx),%al
  8007be:	74 ef                	je     8007af <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c0:	0f b6 c0             	movzbl %al,%eax
  8007c3:	0f b6 12             	movzbl (%edx),%edx
  8007c6:	29 d0                	sub    %edx,%eax
}
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	53                   	push   %ebx
  8007ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d4:	89 c3                	mov    %eax,%ebx
  8007d6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d9:	eb 06                	jmp    8007e1 <strncmp+0x17>
		n--, p++, q++;
  8007db:	83 c0 01             	add    $0x1,%eax
  8007de:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e1:	39 d8                	cmp    %ebx,%eax
  8007e3:	74 15                	je     8007fa <strncmp+0x30>
  8007e5:	0f b6 08             	movzbl (%eax),%ecx
  8007e8:	84 c9                	test   %cl,%cl
  8007ea:	74 04                	je     8007f0 <strncmp+0x26>
  8007ec:	3a 0a                	cmp    (%edx),%cl
  8007ee:	74 eb                	je     8007db <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f0:	0f b6 00             	movzbl (%eax),%eax
  8007f3:	0f b6 12             	movzbl (%edx),%edx
  8007f6:	29 d0                	sub    %edx,%eax
  8007f8:	eb 05                	jmp    8007ff <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007ff:	5b                   	pop    %ebx
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 45 08             	mov    0x8(%ebp),%eax
  800808:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080c:	eb 07                	jmp    800815 <strchr+0x13>
		if (*s == c)
  80080e:	38 ca                	cmp    %cl,%dl
  800810:	74 0f                	je     800821 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800812:	83 c0 01             	add    $0x1,%eax
  800815:	0f b6 10             	movzbl (%eax),%edx
  800818:	84 d2                	test   %dl,%dl
  80081a:	75 f2                	jne    80080e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80081c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
  800829:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082d:	eb 03                	jmp    800832 <strfind+0xf>
  80082f:	83 c0 01             	add    $0x1,%eax
  800832:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800835:	84 d2                	test   %dl,%dl
  800837:	74 04                	je     80083d <strfind+0x1a>
  800839:	38 ca                	cmp    %cl,%dl
  80083b:	75 f2                	jne    80082f <strfind+0xc>
			break;
	return (char *) s;
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	57                   	push   %edi
  800843:	56                   	push   %esi
  800844:	53                   	push   %ebx
  800845:	8b 7d 08             	mov    0x8(%ebp),%edi
  800848:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80084b:	85 c9                	test   %ecx,%ecx
  80084d:	74 36                	je     800885 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800855:	75 28                	jne    80087f <memset+0x40>
  800857:	f6 c1 03             	test   $0x3,%cl
  80085a:	75 23                	jne    80087f <memset+0x40>
		c &= 0xFF;
  80085c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800860:	89 d3                	mov    %edx,%ebx
  800862:	c1 e3 08             	shl    $0x8,%ebx
  800865:	89 d6                	mov    %edx,%esi
  800867:	c1 e6 18             	shl    $0x18,%esi
  80086a:	89 d0                	mov    %edx,%eax
  80086c:	c1 e0 10             	shl    $0x10,%eax
  80086f:	09 f0                	or     %esi,%eax
  800871:	09 c2                	or     %eax,%edx
  800873:	89 d0                	mov    %edx,%eax
  800875:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800877:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80087a:	fc                   	cld    
  80087b:	f3 ab                	rep stos %eax,%es:(%edi)
  80087d:	eb 06                	jmp    800885 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800882:	fc                   	cld    
  800883:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800885:	89 f8                	mov    %edi,%eax
  800887:	5b                   	pop    %ebx
  800888:	5e                   	pop    %esi
  800889:	5f                   	pop    %edi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	57                   	push   %edi
  800890:	56                   	push   %esi
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 75 0c             	mov    0xc(%ebp),%esi
  800897:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80089a:	39 c6                	cmp    %eax,%esi
  80089c:	73 35                	jae    8008d3 <memmove+0x47>
  80089e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a1:	39 d0                	cmp    %edx,%eax
  8008a3:	73 2e                	jae    8008d3 <memmove+0x47>
		s += n;
		d += n;
  8008a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008a8:	89 d6                	mov    %edx,%esi
  8008aa:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ac:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b2:	75 13                	jne    8008c7 <memmove+0x3b>
  8008b4:	f6 c1 03             	test   $0x3,%cl
  8008b7:	75 0e                	jne    8008c7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008b9:	83 ef 04             	sub    $0x4,%edi
  8008bc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bf:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008c2:	fd                   	std    
  8008c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c5:	eb 09                	jmp    8008d0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c7:	83 ef 01             	sub    $0x1,%edi
  8008ca:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008cd:	fd                   	std    
  8008ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d0:	fc                   	cld    
  8008d1:	eb 1d                	jmp    8008f0 <memmove+0x64>
  8008d3:	89 f2                	mov    %esi,%edx
  8008d5:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d7:	f6 c2 03             	test   $0x3,%dl
  8008da:	75 0f                	jne    8008eb <memmove+0x5f>
  8008dc:	f6 c1 03             	test   $0x3,%cl
  8008df:	75 0a                	jne    8008eb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008e1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008e4:	89 c7                	mov    %eax,%edi
  8008e6:	fc                   	cld    
  8008e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e9:	eb 05                	jmp    8008f0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008eb:	89 c7                	mov    %eax,%edi
  8008ed:	fc                   	cld    
  8008ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f0:	5e                   	pop    %esi
  8008f1:	5f                   	pop    %edi
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f7:	ff 75 10             	pushl  0x10(%ebp)
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	ff 75 08             	pushl  0x8(%ebp)
  800900:	e8 87 ff ff ff       	call   80088c <memmove>
}
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	56                   	push   %esi
  80090b:	53                   	push   %ebx
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800912:	89 c6                	mov    %eax,%esi
  800914:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800917:	eb 1a                	jmp    800933 <memcmp+0x2c>
		if (*s1 != *s2)
  800919:	0f b6 08             	movzbl (%eax),%ecx
  80091c:	0f b6 1a             	movzbl (%edx),%ebx
  80091f:	38 d9                	cmp    %bl,%cl
  800921:	74 0a                	je     80092d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800923:	0f b6 c1             	movzbl %cl,%eax
  800926:	0f b6 db             	movzbl %bl,%ebx
  800929:	29 d8                	sub    %ebx,%eax
  80092b:	eb 0f                	jmp    80093c <memcmp+0x35>
		s1++, s2++;
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800933:	39 f0                	cmp    %esi,%eax
  800935:	75 e2                	jne    800919 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800949:	89 c2                	mov    %eax,%edx
  80094b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80094e:	eb 07                	jmp    800957 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800950:	38 08                	cmp    %cl,(%eax)
  800952:	74 07                	je     80095b <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800954:	83 c0 01             	add    $0x1,%eax
  800957:	39 d0                	cmp    %edx,%eax
  800959:	72 f5                	jb     800950 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	57                   	push   %edi
  800961:	56                   	push   %esi
  800962:	53                   	push   %ebx
  800963:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800966:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800969:	eb 03                	jmp    80096e <strtol+0x11>
		s++;
  80096b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096e:	0f b6 01             	movzbl (%ecx),%eax
  800971:	3c 09                	cmp    $0x9,%al
  800973:	74 f6                	je     80096b <strtol+0xe>
  800975:	3c 20                	cmp    $0x20,%al
  800977:	74 f2                	je     80096b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800979:	3c 2b                	cmp    $0x2b,%al
  80097b:	75 0a                	jne    800987 <strtol+0x2a>
		s++;
  80097d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800980:	bf 00 00 00 00       	mov    $0x0,%edi
  800985:	eb 10                	jmp    800997 <strtol+0x3a>
  800987:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80098c:	3c 2d                	cmp    $0x2d,%al
  80098e:	75 07                	jne    800997 <strtol+0x3a>
		s++, neg = 1;
  800990:	8d 49 01             	lea    0x1(%ecx),%ecx
  800993:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800997:	85 db                	test   %ebx,%ebx
  800999:	0f 94 c0             	sete   %al
  80099c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a2:	75 19                	jne    8009bd <strtol+0x60>
  8009a4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a7:	75 14                	jne    8009bd <strtol+0x60>
  8009a9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ad:	0f 85 82 00 00 00    	jne    800a35 <strtol+0xd8>
		s += 2, base = 16;
  8009b3:	83 c1 02             	add    $0x2,%ecx
  8009b6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009bb:	eb 16                	jmp    8009d3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009bd:	84 c0                	test   %al,%al
  8009bf:	74 12                	je     8009d3 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009c1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c9:	75 08                	jne    8009d3 <strtol+0x76>
		s++, base = 8;
  8009cb:	83 c1 01             	add    $0x1,%ecx
  8009ce:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009db:	0f b6 11             	movzbl (%ecx),%edx
  8009de:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009e1:	89 f3                	mov    %esi,%ebx
  8009e3:	80 fb 09             	cmp    $0x9,%bl
  8009e6:	77 08                	ja     8009f0 <strtol+0x93>
			dig = *s - '0';
  8009e8:	0f be d2             	movsbl %dl,%edx
  8009eb:	83 ea 30             	sub    $0x30,%edx
  8009ee:	eb 22                	jmp    800a12 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009f0:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009f3:	89 f3                	mov    %esi,%ebx
  8009f5:	80 fb 19             	cmp    $0x19,%bl
  8009f8:	77 08                	ja     800a02 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009fa:	0f be d2             	movsbl %dl,%edx
  8009fd:	83 ea 57             	sub    $0x57,%edx
  800a00:	eb 10                	jmp    800a12 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a02:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a05:	89 f3                	mov    %esi,%ebx
  800a07:	80 fb 19             	cmp    $0x19,%bl
  800a0a:	77 16                	ja     800a22 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a0c:	0f be d2             	movsbl %dl,%edx
  800a0f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a12:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a15:	7d 0f                	jge    800a26 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a17:	83 c1 01             	add    $0x1,%ecx
  800a1a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a1e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a20:	eb b9                	jmp    8009db <strtol+0x7e>
  800a22:	89 c2                	mov    %eax,%edx
  800a24:	eb 02                	jmp    800a28 <strtol+0xcb>
  800a26:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a28:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a2c:	74 0d                	je     800a3b <strtol+0xde>
		*endptr = (char *) s;
  800a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a31:	89 0e                	mov    %ecx,(%esi)
  800a33:	eb 06                	jmp    800a3b <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a35:	84 c0                	test   %al,%al
  800a37:	75 92                	jne    8009cb <strtol+0x6e>
  800a39:	eb 98                	jmp    8009d3 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a3b:	f7 da                	neg    %edx
  800a3d:	85 ff                	test   %edi,%edi
  800a3f:	0f 45 c2             	cmovne %edx,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{    
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a55:	8b 55 08             	mov    0x8(%ebp),%edx
  800a58:	89 c3                	mov    %eax,%ebx
  800a5a:	89 c7                	mov    %eax,%edi
  800a5c:	89 c6                	mov    %eax,%esi
  800a5e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{    
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	57                   	push   %edi
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a70:	b8 01 00 00 00       	mov    $0x1,%eax
  800a75:	89 d1                	mov    %edx,%ecx
  800a77:	89 d3                	mov    %edx,%ebx
  800a79:	89 d7                	mov    %edx,%edi
  800a7b:	89 d6                	mov    %edx,%esi
  800a7d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800a8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a92:	b8 03 00 00 00       	mov    $0x3,%eax
  800a97:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9a:	89 cb                	mov    %ecx,%ebx
  800a9c:	89 cf                	mov    %ecx,%edi
  800a9e:	89 ce                	mov    %ecx,%esi
  800aa0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa2:	85 c0                	test   %eax,%eax
  800aa4:	7e 17                	jle    800abd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa6:	83 ec 0c             	sub    $0xc,%esp
  800aa9:	50                   	push   %eax
  800aaa:	6a 03                	push   $0x3
  800aac:	68 5f 27 80 00       	push   $0x80275f
  800ab1:	6a 22                	push   $0x22
  800ab3:	68 7c 27 80 00       	push   $0x80277c
  800ab8:	e8 ee 14 00 00       	call   801fab <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800abd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{                 
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800acb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad5:	89 d1                	mov    %edx,%ecx
  800ad7:	89 d3                	mov    %edx,%ebx
  800ad9:	89 d7                	mov    %edx,%edi
  800adb:	89 d6                	mov    %edx,%esi
  800add:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{                 
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <sys_yield>:

void
sys_yield(void)
{      
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800aea:	ba 00 00 00 00       	mov    $0x0,%edx
  800aef:	b8 0b 00 00 00       	mov    $0xb,%eax
  800af4:	89 d1                	mov    %edx,%ecx
  800af6:	89 d3                	mov    %edx,%ebx
  800af8:	89 d7                	mov    %edx,%edi
  800afa:	89 d6                	mov    %edx,%esi
  800afc:	cd 30                	int    $0x30

void
sys_yield(void)
{      
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b0c:	be 00 00 00 00       	mov    $0x0,%esi
  800b11:	b8 04 00 00 00       	mov    $0x4,%eax
  800b16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b19:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b1f:	89 f7                	mov    %esi,%edi
  800b21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b23:	85 c0                	test   %eax,%eax
  800b25:	7e 17                	jle    800b3e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b27:	83 ec 0c             	sub    $0xc,%esp
  800b2a:	50                   	push   %eax
  800b2b:	6a 04                	push   $0x4
  800b2d:	68 5f 27 80 00       	push   $0x80275f
  800b32:	6a 22                	push   $0x22
  800b34:	68 7c 27 80 00       	push   $0x80277c
  800b39:	e8 6d 14 00 00       	call   801fab <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
  800b4c:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b4f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b60:	8b 75 18             	mov    0x18(%ebp),%esi
  800b63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b65:	85 c0                	test   %eax,%eax
  800b67:	7e 17                	jle    800b80 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	50                   	push   %eax
  800b6d:	6a 05                	push   $0x5
  800b6f:	68 5f 27 80 00       	push   $0x80275f
  800b74:	6a 22                	push   $0x22
  800b76:	68 7c 27 80 00       	push   $0x80277c
  800b7b:	e8 2b 14 00 00       	call   801fab <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
  800b8e:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800b91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b96:	b8 06 00 00 00       	mov    $0x6,%eax
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	89 df                	mov    %ebx,%edi
  800ba3:	89 de                	mov    %ebx,%esi
  800ba5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	7e 17                	jle    800bc2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bab:	83 ec 0c             	sub    $0xc,%esp
  800bae:	50                   	push   %eax
  800baf:	6a 06                	push   $0x6
  800bb1:	68 5f 27 80 00       	push   $0x80275f
  800bb6:	6a 22                	push   $0x22
  800bb8:	68 7c 27 80 00       	push   $0x80277c
  800bbd:	e8 e9 13 00 00       	call   801fab <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
  800bd0:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800bd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be0:	8b 55 08             	mov    0x8(%ebp),%edx
  800be3:	89 df                	mov    %ebx,%edi
  800be5:	89 de                	mov    %ebx,%esi
  800be7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be9:	85 c0                	test   %eax,%eax
  800beb:	7e 17                	jle    800c04 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	50                   	push   %eax
  800bf1:	6a 08                	push   $0x8
  800bf3:	68 5f 27 80 00       	push   $0x80275f
  800bf8:	6a 22                	push   $0x22
  800bfa:	68 7c 27 80 00       	push   $0x80277c
  800bff:	e8 a7 13 00 00       	call   801fab <_panic>
sys_env_set_status(envid_t envid, int status)
{

	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
             
}
  800c04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	57                   	push   %edi
  800c10:	56                   	push   %esi
  800c11:	53                   	push   %ebx
  800c12:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	89 df                	mov    %ebx,%edi
  800c27:	89 de                	mov    %ebx,%esi
  800c29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	7e 17                	jle    800c46 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2f:	83 ec 0c             	sub    $0xc,%esp
  800c32:	50                   	push   %eax
  800c33:	6a 09                	push   $0x9
  800c35:	68 5f 27 80 00       	push   $0x80275f
  800c3a:	6a 22                	push   $0x22
  800c3c:	68 7c 27 80 00       	push   $0x80277c
  800c41:	e8 65 13 00 00       	call   801fab <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 df                	mov    %ebx,%edi
  800c69:	89 de                	mov    %ebx,%esi
  800c6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	7e 17                	jle    800c88 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c71:	83 ec 0c             	sub    $0xc,%esp
  800c74:	50                   	push   %eax
  800c75:	6a 0a                	push   $0xa
  800c77:	68 5f 27 80 00       	push   $0x80275f
  800c7c:	6a 22                	push   $0x22
  800c7e:	68 7c 27 80 00       	push   $0x80277c
  800c83:	e8 23 13 00 00       	call   801fab <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800c96:	be 00 00 00 00       	mov    $0x0,%esi
  800c9b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cac:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{  
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cbc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	89 cb                	mov    %ecx,%ebx
  800ccb:	89 cf                	mov    %ecx,%edi
  800ccd:	89 ce                	mov    %ecx,%esi
  800ccf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	7e 17                	jle    800cec <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd5:	83 ec 0c             	sub    $0xc,%esp
  800cd8:	50                   	push   %eax
  800cd9:	6a 0d                	push   $0xd
  800cdb:	68 5f 27 80 00       	push   $0x80275f
  800ce0:	6a 22                	push   $0x22
  800ce2:	68 7c 27 80 00       	push   $0x80277c
  800ce7:	e8 bf 12 00 00       	call   801fab <_panic>

int
sys_ipc_recv(void *dstva)
{  
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{       
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800cfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800cff:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d04:	89 d1                	mov    %edx,%ecx
  800d06:	89 d3                	mov    %edx,%ebx
  800d08:	89 d7                	mov    %edx,%edi
  800d0a:	89 d6                	mov    %edx,%esi
  800d0c:	cd 30                	int    $0x30
sys_time_msec(void)
{       
         
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
        
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_transmit>:

int
sys_transmit(void *addr)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d21:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	89 cb                	mov    %ecx,%ebx
  800d2b:	89 cf                	mov    %ecx,%edi
  800d2d:	89 ce                	mov    %ecx,%esi
  800d2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d31:	85 c0                	test   %eax,%eax
  800d33:	7e 17                	jle    800d4c <sys_transmit+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	50                   	push   %eax
  800d39:	6a 0f                	push   $0xf
  800d3b:	68 5f 27 80 00       	push   $0x80275f
  800d40:	6a 22                	push   $0x22
  800d42:	68 7c 27 80 00       	push   $0x80277c
  800d47:	e8 5f 12 00 00       	call   801fab <_panic>

int
sys_transmit(void *addr)
{
        return syscall(SYS_transmit, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_recv>:

int
sys_recv(void *addr)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	asm volatile("int %1\n"
  800d5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d62:	b8 10 00 00 00       	mov    $0x10,%eax
  800d67:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6a:	89 cb                	mov    %ecx,%ebx
  800d6c:	89 cf                	mov    %ecx,%edi
  800d6e:	89 ce                	mov    %ecx,%esi
  800d70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7e 17                	jle    800d8d <sys_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	50                   	push   %eax
  800d7a:	6a 10                	push   $0x10
  800d7c:	68 5f 27 80 00       	push   $0x80275f
  800d81:	6a 22                	push   $0x22
  800d83:	68 7c 27 80 00       	push   $0x80277c
  800d88:	e8 1e 12 00 00       	call   801fab <_panic>

int
sys_recv(void *addr)
{
        return syscall(SYS_recv, 1, (uint32_t)addr, 0, 0, 0, 0);
}
  800d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d9b:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800da2:	75 2c                	jne    800dd0 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  800da4:	83 ec 04             	sub    $0x4,%esp
  800da7:	6a 07                	push   $0x7
  800da9:	68 00 f0 bf ee       	push   $0xeebff000
  800dae:	6a 00                	push   $0x0
  800db0:	e8 4e fd ff ff       	call   800b03 <sys_page_alloc>
  800db5:	83 c4 10             	add    $0x10,%esp
  800db8:	85 c0                	test   %eax,%eax
  800dba:	74 14                	je     800dd0 <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  800dbc:	83 ec 04             	sub    $0x4,%esp
  800dbf:	68 8c 27 80 00       	push   $0x80278c
  800dc4:	6a 21                	push   $0x21
  800dc6:	68 ee 27 80 00       	push   $0x8027ee
  800dcb:	e8 db 11 00 00       	call   801fab <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd3:	a3 0c 40 80 00       	mov    %eax,0x80400c
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800dd8:	83 ec 08             	sub    $0x8,%esp
  800ddb:	68 04 0e 80 00       	push   $0x800e04
  800de0:	6a 00                	push   $0x0
  800de2:	e8 67 fe ff ff       	call   800c4e <sys_env_set_pgfault_upcall>
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	79 14                	jns    800e02 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	68 b8 27 80 00       	push   $0x8027b8
  800df6:	6a 29                	push   $0x29
  800df8:	68 ee 27 80 00       	push   $0x8027ee
  800dfd:	e8 a9 11 00 00       	call   801fab <_panic>
}
  800e02:	c9                   	leave  
  800e03:	c3                   	ret    

00800e04 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e04:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e05:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e0a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e0c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  800e0f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  800e14:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  800e18:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  800e1c:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  800e1e:	83 c4 08             	add    $0x8,%esp
        popal
  800e21:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800e22:	83 c4 04             	add    $0x4,%esp
        popfl
  800e25:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  800e26:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800e27:	c3                   	ret    

00800e28 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2e:	05 00 00 00 30       	add    $0x30000000,%eax
  800e33:	c1 e8 0c             	shr    $0xc,%eax
}
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3e:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800e43:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e48:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e55:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e5a:	89 c2                	mov    %eax,%edx
  800e5c:	c1 ea 16             	shr    $0x16,%edx
  800e5f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e66:	f6 c2 01             	test   $0x1,%dl
  800e69:	74 11                	je     800e7c <fd_alloc+0x2d>
  800e6b:	89 c2                	mov    %eax,%edx
  800e6d:	c1 ea 0c             	shr    $0xc,%edx
  800e70:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e77:	f6 c2 01             	test   $0x1,%dl
  800e7a:	75 09                	jne    800e85 <fd_alloc+0x36>
			*fd_store = fd;
  800e7c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e83:	eb 17                	jmp    800e9c <fd_alloc+0x4d>
  800e85:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e8a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e8f:	75 c9                	jne    800e5a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e91:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e97:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ea4:	83 f8 1f             	cmp    $0x1f,%eax
  800ea7:	77 36                	ja     800edf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ea9:	c1 e0 0c             	shl    $0xc,%eax
  800eac:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eb1:	89 c2                	mov    %eax,%edx
  800eb3:	c1 ea 16             	shr    $0x16,%edx
  800eb6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ebd:	f6 c2 01             	test   $0x1,%dl
  800ec0:	74 24                	je     800ee6 <fd_lookup+0x48>
  800ec2:	89 c2                	mov    %eax,%edx
  800ec4:	c1 ea 0c             	shr    $0xc,%edx
  800ec7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ece:	f6 c2 01             	test   $0x1,%dl
  800ed1:	74 1a                	je     800eed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed6:	89 02                	mov    %eax,(%edx)
	return 0;
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
  800edd:	eb 13                	jmp    800ef2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800edf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee4:	eb 0c                	jmp    800ef2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eeb:	eb 05                	jmp    800ef2 <fd_lookup+0x54>
  800eed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	83 ec 08             	sub    $0x8,%esp
  800efa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800efd:	ba 00 00 00 00       	mov    $0x0,%edx
  800f02:	eb 13                	jmp    800f17 <dev_lookup+0x23>
		if (devtab[i]->dev_id == dev_id) {
  800f04:	39 08                	cmp    %ecx,(%eax)
  800f06:	75 0c                	jne    800f14 <dev_lookup+0x20>
			*dev = devtab[i];
  800f08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f12:	eb 36                	jmp    800f4a <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f14:	83 c2 01             	add    $0x1,%edx
  800f17:	8b 04 95 78 28 80 00 	mov    0x802878(,%edx,4),%eax
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	75 e2                	jne    800f04 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f22:	a1 08 40 80 00       	mov    0x804008,%eax
  800f27:	8b 40 48             	mov    0x48(%eax),%eax
  800f2a:	83 ec 04             	sub    $0x4,%esp
  800f2d:	51                   	push   %ecx
  800f2e:	50                   	push   %eax
  800f2f:	68 fc 27 80 00       	push   $0x8027fc
  800f34:	e8 3a f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800f39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f42:	83 c4 10             	add    $0x10,%esp
  800f45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4a:	c9                   	leave  
  800f4b:	c3                   	ret    

00800f4c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	83 ec 10             	sub    $0x10,%esp
  800f54:	8b 75 08             	mov    0x8(%ebp),%esi
  800f57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5d:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f5e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f64:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f67:	50                   	push   %eax
  800f68:	e8 31 ff ff ff       	call   800e9e <fd_lookup>
  800f6d:	83 c4 08             	add    $0x8,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	78 05                	js     800f79 <fd_close+0x2d>
	    || fd != fd2)
  800f74:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f77:	74 0c                	je     800f85 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f79:	84 db                	test   %bl,%bl
  800f7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f80:	0f 44 c2             	cmove  %edx,%eax
  800f83:	eb 41                	jmp    800fc6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f85:	83 ec 08             	sub    $0x8,%esp
  800f88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f8b:	50                   	push   %eax
  800f8c:	ff 36                	pushl  (%esi)
  800f8e:	e8 61 ff ff ff       	call   800ef4 <dev_lookup>
  800f93:	89 c3                	mov    %eax,%ebx
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 1a                	js     800fb6 <fd_close+0x6a>
		if (dev->dev_close)
  800f9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f9f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fa2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	74 0b                	je     800fb6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	56                   	push   %esi
  800faf:	ff d0                	call   *%eax
  800fb1:	89 c3                	mov    %eax,%ebx
  800fb3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fb6:	83 ec 08             	sub    $0x8,%esp
  800fb9:	56                   	push   %esi
  800fba:	6a 00                	push   $0x0
  800fbc:	e8 c7 fb ff ff       	call   800b88 <sys_page_unmap>
	return r;
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	89 d8                	mov    %ebx,%eax
}
  800fc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd6:	50                   	push   %eax
  800fd7:	ff 75 08             	pushl  0x8(%ebp)
  800fda:	e8 bf fe ff ff       	call   800e9e <fd_lookup>
  800fdf:	89 c2                	mov    %eax,%edx
  800fe1:	83 c4 08             	add    $0x8,%esp
  800fe4:	85 d2                	test   %edx,%edx
  800fe6:	78 10                	js     800ff8 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800fe8:	83 ec 08             	sub    $0x8,%esp
  800feb:	6a 01                	push   $0x1
  800fed:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff0:	e8 57 ff ff ff       	call   800f4c <fd_close>
  800ff5:	83 c4 10             	add    $0x10,%esp
}
  800ff8:	c9                   	leave  
  800ff9:	c3                   	ret    

00800ffa <close_all>:

void
close_all(void)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	53                   	push   %ebx
  800ffe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801001:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801006:	83 ec 0c             	sub    $0xc,%esp
  801009:	53                   	push   %ebx
  80100a:	e8 be ff ff ff       	call   800fcd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80100f:	83 c3 01             	add    $0x1,%ebx
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	83 fb 20             	cmp    $0x20,%ebx
  801018:	75 ec                	jne    801006 <close_all+0xc>
		close(i);
}
  80101a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	57                   	push   %edi
  801023:	56                   	push   %esi
  801024:	53                   	push   %ebx
  801025:	83 ec 2c             	sub    $0x2c,%esp
  801028:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80102e:	50                   	push   %eax
  80102f:	ff 75 08             	pushl  0x8(%ebp)
  801032:	e8 67 fe ff ff       	call   800e9e <fd_lookup>
  801037:	89 c2                	mov    %eax,%edx
  801039:	83 c4 08             	add    $0x8,%esp
  80103c:	85 d2                	test   %edx,%edx
  80103e:	0f 88 c1 00 00 00    	js     801105 <dup+0xe6>
		return r;
	close(newfdnum);
  801044:	83 ec 0c             	sub    $0xc,%esp
  801047:	56                   	push   %esi
  801048:	e8 80 ff ff ff       	call   800fcd <close>

	newfd = INDEX2FD(newfdnum);
  80104d:	89 f3                	mov    %esi,%ebx
  80104f:	c1 e3 0c             	shl    $0xc,%ebx
  801052:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801058:	83 c4 04             	add    $0x4,%esp
  80105b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105e:	e8 d5 fd ff ff       	call   800e38 <fd2data>
  801063:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801065:	89 1c 24             	mov    %ebx,(%esp)
  801068:	e8 cb fd ff ff       	call   800e38 <fd2data>
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801073:	89 f8                	mov    %edi,%eax
  801075:	c1 e8 16             	shr    $0x16,%eax
  801078:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107f:	a8 01                	test   $0x1,%al
  801081:	74 37                	je     8010ba <dup+0x9b>
  801083:	89 f8                	mov    %edi,%eax
  801085:	c1 e8 0c             	shr    $0xc,%eax
  801088:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108f:	f6 c2 01             	test   $0x1,%dl
  801092:	74 26                	je     8010ba <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801094:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a3:	50                   	push   %eax
  8010a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a7:	6a 00                	push   $0x0
  8010a9:	57                   	push   %edi
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 95 fa ff ff       	call   800b46 <sys_page_map>
  8010b1:	89 c7                	mov    %eax,%edi
  8010b3:	83 c4 20             	add    $0x20,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	78 2e                	js     8010e8 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010bd:	89 d0                	mov    %edx,%eax
  8010bf:	c1 e8 0c             	shr    $0xc,%eax
  8010c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d1:	50                   	push   %eax
  8010d2:	53                   	push   %ebx
  8010d3:	6a 00                	push   $0x0
  8010d5:	52                   	push   %edx
  8010d6:	6a 00                	push   $0x0
  8010d8:	e8 69 fa ff ff       	call   800b46 <sys_page_map>
  8010dd:	89 c7                	mov    %eax,%edi
  8010df:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010e2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e4:	85 ff                	test   %edi,%edi
  8010e6:	79 1d                	jns    801105 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e8:	83 ec 08             	sub    $0x8,%esp
  8010eb:	53                   	push   %ebx
  8010ec:	6a 00                	push   $0x0
  8010ee:	e8 95 fa ff ff       	call   800b88 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f3:	83 c4 08             	add    $0x8,%esp
  8010f6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f9:	6a 00                	push   $0x0
  8010fb:	e8 88 fa ff ff       	call   800b88 <sys_page_unmap>
	return r;
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	89 f8                	mov    %edi,%eax
}
  801105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801108:	5b                   	pop    %ebx
  801109:	5e                   	pop    %esi
  80110a:	5f                   	pop    %edi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	53                   	push   %ebx
  801111:	83 ec 14             	sub    $0x14,%esp
  801114:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801117:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111a:	50                   	push   %eax
  80111b:	53                   	push   %ebx
  80111c:	e8 7d fd ff ff       	call   800e9e <fd_lookup>
  801121:	83 c4 08             	add    $0x8,%esp
  801124:	89 c2                	mov    %eax,%edx
  801126:	85 c0                	test   %eax,%eax
  801128:	78 6d                	js     801197 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801130:	50                   	push   %eax
  801131:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801134:	ff 30                	pushl  (%eax)
  801136:	e8 b9 fd ff ff       	call   800ef4 <dev_lookup>
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 4c                	js     80118e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801142:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801145:	8b 42 08             	mov    0x8(%edx),%eax
  801148:	83 e0 03             	and    $0x3,%eax
  80114b:	83 f8 01             	cmp    $0x1,%eax
  80114e:	75 21                	jne    801171 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801150:	a1 08 40 80 00       	mov    0x804008,%eax
  801155:	8b 40 48             	mov    0x48(%eax),%eax
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	53                   	push   %ebx
  80115c:	50                   	push   %eax
  80115d:	68 3d 28 80 00       	push   $0x80283d
  801162:	e8 0c f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116f:	eb 26                	jmp    801197 <read+0x8a>
	}
	if (!dev->dev_read)
  801171:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801174:	8b 40 08             	mov    0x8(%eax),%eax
  801177:	85 c0                	test   %eax,%eax
  801179:	74 17                	je     801192 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80117b:	83 ec 04             	sub    $0x4,%esp
  80117e:	ff 75 10             	pushl  0x10(%ebp)
  801181:	ff 75 0c             	pushl  0xc(%ebp)
  801184:	52                   	push   %edx
  801185:	ff d0                	call   *%eax
  801187:	89 c2                	mov    %eax,%edx
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	eb 09                	jmp    801197 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118e:	89 c2                	mov    %eax,%edx
  801190:	eb 05                	jmp    801197 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801192:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801197:	89 d0                	mov    %edx,%eax
  801199:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119c:	c9                   	leave  
  80119d:	c3                   	ret    

0080119e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 0c             	sub    $0xc,%esp
  8011a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b2:	eb 21                	jmp    8011d5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	89 f0                	mov    %esi,%eax
  8011b9:	29 d8                	sub    %ebx,%eax
  8011bb:	50                   	push   %eax
  8011bc:	89 d8                	mov    %ebx,%eax
  8011be:	03 45 0c             	add    0xc(%ebp),%eax
  8011c1:	50                   	push   %eax
  8011c2:	57                   	push   %edi
  8011c3:	e8 45 ff ff ff       	call   80110d <read>
		if (m < 0)
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	78 0c                	js     8011db <readn+0x3d>
			return m;
		if (m == 0)
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	74 06                	je     8011d9 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d3:	01 c3                	add    %eax,%ebx
  8011d5:	39 f3                	cmp    %esi,%ebx
  8011d7:	72 db                	jb     8011b4 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8011d9:	89 d8                	mov    %ebx,%eax
}
  8011db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011de:	5b                   	pop    %ebx
  8011df:	5e                   	pop    %esi
  8011e0:	5f                   	pop    %edi
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 14             	sub    $0x14,%esp
  8011ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f0:	50                   	push   %eax
  8011f1:	53                   	push   %ebx
  8011f2:	e8 a7 fc ff ff       	call   800e9e <fd_lookup>
  8011f7:	83 c4 08             	add    $0x8,%esp
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	78 68                	js     801268 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801200:	83 ec 08             	sub    $0x8,%esp
  801203:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801206:	50                   	push   %eax
  801207:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120a:	ff 30                	pushl  (%eax)
  80120c:	e8 e3 fc ff ff       	call   800ef4 <dev_lookup>
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	85 c0                	test   %eax,%eax
  801216:	78 47                	js     80125f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801218:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80121f:	75 21                	jne    801242 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801221:	a1 08 40 80 00       	mov    0x804008,%eax
  801226:	8b 40 48             	mov    0x48(%eax),%eax
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	53                   	push   %ebx
  80122d:	50                   	push   %eax
  80122e:	68 59 28 80 00       	push   $0x802859
  801233:	e8 3b ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801240:	eb 26                	jmp    801268 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801242:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801245:	8b 52 0c             	mov    0xc(%edx),%edx
  801248:	85 d2                	test   %edx,%edx
  80124a:	74 17                	je     801263 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80124c:	83 ec 04             	sub    $0x4,%esp
  80124f:	ff 75 10             	pushl  0x10(%ebp)
  801252:	ff 75 0c             	pushl  0xc(%ebp)
  801255:	50                   	push   %eax
  801256:	ff d2                	call   *%edx
  801258:	89 c2                	mov    %eax,%edx
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	eb 09                	jmp    801268 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125f:	89 c2                	mov    %eax,%edx
  801261:	eb 05                	jmp    801268 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801263:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801268:	89 d0                	mov    %edx,%eax
  80126a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <seek>:

int
seek(int fdnum, off_t offset)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801275:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	ff 75 08             	pushl  0x8(%ebp)
  80127c:	e8 1d fc ff ff       	call   800e9e <fd_lookup>
  801281:	83 c4 08             	add    $0x8,%esp
  801284:	85 c0                	test   %eax,%eax
  801286:	78 0e                	js     801296 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801288:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	53                   	push   %ebx
  80129c:	83 ec 14             	sub    $0x14,%esp
  80129f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a5:	50                   	push   %eax
  8012a6:	53                   	push   %ebx
  8012a7:	e8 f2 fb ff ff       	call   800e9e <fd_lookup>
  8012ac:	83 c4 08             	add    $0x8,%esp
  8012af:	89 c2                	mov    %eax,%edx
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 65                	js     80131a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b5:	83 ec 08             	sub    $0x8,%esp
  8012b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bb:	50                   	push   %eax
  8012bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bf:	ff 30                	pushl  (%eax)
  8012c1:	e8 2e fc ff ff       	call   800ef4 <dev_lookup>
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	78 44                	js     801311 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d4:	75 21                	jne    8012f7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012d6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012db:	8b 40 48             	mov    0x48(%eax),%eax
  8012de:	83 ec 04             	sub    $0x4,%esp
  8012e1:	53                   	push   %ebx
  8012e2:	50                   	push   %eax
  8012e3:	68 1c 28 80 00       	push   $0x80281c
  8012e8:	e8 86 ee ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f5:	eb 23                	jmp    80131a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012fa:	8b 52 18             	mov    0x18(%edx),%edx
  8012fd:	85 d2                	test   %edx,%edx
  8012ff:	74 14                	je     801315 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	ff 75 0c             	pushl  0xc(%ebp)
  801307:	50                   	push   %eax
  801308:	ff d2                	call   *%edx
  80130a:	89 c2                	mov    %eax,%edx
  80130c:	83 c4 10             	add    $0x10,%esp
  80130f:	eb 09                	jmp    80131a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801311:	89 c2                	mov    %eax,%edx
  801313:	eb 05                	jmp    80131a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801315:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80131a:	89 d0                	mov    %edx,%eax
  80131c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131f:	c9                   	leave  
  801320:	c3                   	ret    

00801321 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	53                   	push   %ebx
  801325:	83 ec 14             	sub    $0x14,%esp
  801328:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132e:	50                   	push   %eax
  80132f:	ff 75 08             	pushl  0x8(%ebp)
  801332:	e8 67 fb ff ff       	call   800e9e <fd_lookup>
  801337:	83 c4 08             	add    $0x8,%esp
  80133a:	89 c2                	mov    %eax,%edx
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 58                	js     801398 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801340:	83 ec 08             	sub    $0x8,%esp
  801343:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134a:	ff 30                	pushl  (%eax)
  80134c:	e8 a3 fb ff ff       	call   800ef4 <dev_lookup>
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	85 c0                	test   %eax,%eax
  801356:	78 37                	js     80138f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80135f:	74 32                	je     801393 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801361:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801364:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136b:	00 00 00 
	stat->st_isdir = 0;
  80136e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801375:	00 00 00 
	stat->st_dev = dev;
  801378:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80137e:	83 ec 08             	sub    $0x8,%esp
  801381:	53                   	push   %ebx
  801382:	ff 75 f0             	pushl  -0x10(%ebp)
  801385:	ff 50 14             	call   *0x14(%eax)
  801388:	89 c2                	mov    %eax,%edx
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	eb 09                	jmp    801398 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138f:	89 c2                	mov    %eax,%edx
  801391:	eb 05                	jmp    801398 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801393:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801398:	89 d0                	mov    %edx,%eax
  80139a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	56                   	push   %esi
  8013a3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	6a 00                	push   $0x0
  8013a9:	ff 75 08             	pushl  0x8(%ebp)
  8013ac:	e8 09 02 00 00       	call   8015ba <open>
  8013b1:	89 c3                	mov    %eax,%ebx
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	85 db                	test   %ebx,%ebx
  8013b8:	78 1b                	js     8013d5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	ff 75 0c             	pushl  0xc(%ebp)
  8013c0:	53                   	push   %ebx
  8013c1:	e8 5b ff ff ff       	call   801321 <fstat>
  8013c6:	89 c6                	mov    %eax,%esi
	close(fd);
  8013c8:	89 1c 24             	mov    %ebx,(%esp)
  8013cb:	e8 fd fb ff ff       	call   800fcd <close>
	return r;
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	89 f0                	mov    %esi,%eax
}
  8013d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d8:	5b                   	pop    %ebx
  8013d9:	5e                   	pop    %esi
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	89 c6                	mov    %eax,%esi
  8013e3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ec:	75 12                	jne    801400 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ee:	83 ec 0c             	sub    $0xc,%esp
  8013f1:	6a 01                	push   $0x1
  8013f3:	e8 b6 0c 00 00       	call   8020ae <ipc_find_env>
  8013f8:	a3 00 40 80 00       	mov    %eax,0x804000
  8013fd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801400:	6a 07                	push   $0x7
  801402:	68 00 50 80 00       	push   $0x805000
  801407:	56                   	push   %esi
  801408:	ff 35 00 40 80 00    	pushl  0x804000
  80140e:	e8 47 0c 00 00       	call   80205a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801413:	83 c4 0c             	add    $0xc,%esp
  801416:	6a 00                	push   $0x0
  801418:	53                   	push   %ebx
  801419:	6a 00                	push   $0x0
  80141b:	e8 d1 0b 00 00       	call   801ff1 <ipc_recv>
}
  801420:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801423:	5b                   	pop    %ebx
  801424:	5e                   	pop    %esi
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
  801430:	8b 40 0c             	mov    0xc(%eax),%eax
  801433:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801438:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801440:	ba 00 00 00 00       	mov    $0x0,%edx
  801445:	b8 02 00 00 00       	mov    $0x2,%eax
  80144a:	e8 8d ff ff ff       	call   8013dc <fsipc>
}
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801457:	8b 45 08             	mov    0x8(%ebp),%eax
  80145a:	8b 40 0c             	mov    0xc(%eax),%eax
  80145d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801462:	ba 00 00 00 00       	mov    $0x0,%edx
  801467:	b8 06 00 00 00       	mov    $0x6,%eax
  80146c:	e8 6b ff ff ff       	call   8013dc <fsipc>
}
  801471:	c9                   	leave  
  801472:	c3                   	ret    

00801473 <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	53                   	push   %ebx
  801477:	83 ec 04             	sub    $0x4,%esp
  80147a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80147d:	8b 45 08             	mov    0x8(%ebp),%eax
  801480:	8b 40 0c             	mov    0xc(%eax),%eax
  801483:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801488:	ba 00 00 00 00       	mov    $0x0,%edx
  80148d:	b8 05 00 00 00       	mov    $0x5,%eax
  801492:	e8 45 ff ff ff       	call   8013dc <fsipc>
  801497:	89 c2                	mov    %eax,%edx
  801499:	85 d2                	test   %edx,%edx
  80149b:	78 2c                	js     8014c9 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	68 00 50 80 00       	push   $0x805000
  8014a5:	53                   	push   %ebx
  8014a6:	e8 4f f2 ff ff       	call   8006fa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ab:	a1 80 50 80 00       	mov    0x805080,%eax
  8014b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b6:	a1 84 50 80 00       	mov    0x805084,%eax
  8014bb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cc:	c9                   	leave  
  8014cd:	c3                   	ret    

008014ce <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	57                   	push   %edi
  8014d2:	56                   	push   %esi
  8014d3:	53                   	push   %ebx
  8014d4:	83 ec 0c             	sub    $0xc,%esp
  8014d7:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  8014da:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e0:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  8014e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  8014e8:	eb 3d                	jmp    801527 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  8014ea:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  8014f0:	bf f8 0f 00 00       	mov    $0xff8,%edi
  8014f5:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	57                   	push   %edi
  8014fc:	53                   	push   %ebx
  8014fd:	68 08 50 80 00       	push   $0x805008
  801502:	e8 85 f3 ff ff       	call   80088c <memmove>
                fsipcbuf.write.req_n = tmp; 
  801507:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80150d:	ba 00 00 00 00       	mov    $0x0,%edx
  801512:	b8 04 00 00 00       	mov    $0x4,%eax
  801517:	e8 c0 fe ff ff       	call   8013dc <fsipc>
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 0d                	js     801530 <devfile_write+0x62>
		        return r;
                n -= tmp;
  801523:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  801525:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801527:	85 f6                	test   %esi,%esi
  801529:	75 bf                	jne    8014ea <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  80152b:	89 d8                	mov    %ebx,%eax
  80152d:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  801530:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801533:	5b                   	pop    %ebx
  801534:	5e                   	pop    %esi
  801535:	5f                   	pop    %edi
  801536:	5d                   	pop    %ebp
  801537:	c3                   	ret    

00801538 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	56                   	push   %esi
  80153c:	53                   	push   %ebx
  80153d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801540:	8b 45 08             	mov    0x8(%ebp),%eax
  801543:	8b 40 0c             	mov    0xc(%eax),%eax
  801546:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80154b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801551:	ba 00 00 00 00       	mov    $0x0,%edx
  801556:	b8 03 00 00 00       	mov    $0x3,%eax
  80155b:	e8 7c fe ff ff       	call   8013dc <fsipc>
  801560:	89 c3                	mov    %eax,%ebx
  801562:	85 c0                	test   %eax,%eax
  801564:	78 4b                	js     8015b1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801566:	39 c6                	cmp    %eax,%esi
  801568:	73 16                	jae    801580 <devfile_read+0x48>
  80156a:	68 8c 28 80 00       	push   $0x80288c
  80156f:	68 93 28 80 00       	push   $0x802893
  801574:	6a 7c                	push   $0x7c
  801576:	68 a8 28 80 00       	push   $0x8028a8
  80157b:	e8 2b 0a 00 00       	call   801fab <_panic>
	assert(r <= PGSIZE);
  801580:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801585:	7e 16                	jle    80159d <devfile_read+0x65>
  801587:	68 b3 28 80 00       	push   $0x8028b3
  80158c:	68 93 28 80 00       	push   $0x802893
  801591:	6a 7d                	push   $0x7d
  801593:	68 a8 28 80 00       	push   $0x8028a8
  801598:	e8 0e 0a 00 00       	call   801fab <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80159d:	83 ec 04             	sub    $0x4,%esp
  8015a0:	50                   	push   %eax
  8015a1:	68 00 50 80 00       	push   $0x805000
  8015a6:	ff 75 0c             	pushl  0xc(%ebp)
  8015a9:	e8 de f2 ff ff       	call   80088c <memmove>
	return r;
  8015ae:	83 c4 10             	add    $0x10,%esp
}
  8015b1:	89 d8                	mov    %ebx,%eax
  8015b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b6:	5b                   	pop    %ebx
  8015b7:	5e                   	pop    %esi
  8015b8:	5d                   	pop    %ebp
  8015b9:	c3                   	ret    

008015ba <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	53                   	push   %ebx
  8015be:	83 ec 20             	sub    $0x20,%esp
  8015c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015c4:	53                   	push   %ebx
  8015c5:	e8 f7 f0 ff ff       	call   8006c1 <strlen>
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015d2:	7f 67                	jg     80163b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	e8 6f f8 ff ff       	call   800e4f <fd_alloc>
  8015e0:	83 c4 10             	add    $0x10,%esp
		return r;
  8015e3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	78 57                	js     801640 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015e9:	83 ec 08             	sub    $0x8,%esp
  8015ec:	53                   	push   %ebx
  8015ed:	68 00 50 80 00       	push   $0x805000
  8015f2:	e8 03 f1 ff ff       	call   8006fa <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fa:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801602:	b8 01 00 00 00       	mov    $0x1,%eax
  801607:	e8 d0 fd ff ff       	call   8013dc <fsipc>
  80160c:	89 c3                	mov    %eax,%ebx
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	85 c0                	test   %eax,%eax
  801613:	79 14                	jns    801629 <open+0x6f>
		fd_close(fd, 0);
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	6a 00                	push   $0x0
  80161a:	ff 75 f4             	pushl  -0xc(%ebp)
  80161d:	e8 2a f9 ff ff       	call   800f4c <fd_close>
		return r;
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	89 da                	mov    %ebx,%edx
  801627:	eb 17                	jmp    801640 <open+0x86>
	}

	return fd2num(fd);
  801629:	83 ec 0c             	sub    $0xc,%esp
  80162c:	ff 75 f4             	pushl  -0xc(%ebp)
  80162f:	e8 f4 f7 ff ff       	call   800e28 <fd2num>
  801634:	89 c2                	mov    %eax,%edx
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	eb 05                	jmp    801640 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80163b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801640:	89 d0                	mov    %edx,%eax
  801642:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80164d:	ba 00 00 00 00       	mov    $0x0,%edx
  801652:	b8 08 00 00 00       	mov    $0x8,%eax
  801657:	e8 80 fd ff ff       	call   8013dc <fsipc>
}
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801664:	68 bf 28 80 00       	push   $0x8028bf
  801669:	ff 75 0c             	pushl  0xc(%ebp)
  80166c:	e8 89 f0 ff ff       	call   8006fa <strcpy>
	return 0;
}
  801671:	b8 00 00 00 00       	mov    $0x0,%eax
  801676:	c9                   	leave  
  801677:	c3                   	ret    

00801678 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	53                   	push   %ebx
  80167c:	83 ec 10             	sub    $0x10,%esp
  80167f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801682:	53                   	push   %ebx
  801683:	e8 5e 0a 00 00       	call   8020e6 <pageref>
  801688:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80168b:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801690:	83 f8 01             	cmp    $0x1,%eax
  801693:	75 10                	jne    8016a5 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801695:	83 ec 0c             	sub    $0xc,%esp
  801698:	ff 73 0c             	pushl  0xc(%ebx)
  80169b:	e8 ca 02 00 00       	call   80196a <nsipc_close>
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8016a5:	89 d0                	mov    %edx,%eax
  8016a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016b2:	6a 00                	push   $0x0
  8016b4:	ff 75 10             	pushl  0x10(%ebp)
  8016b7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bd:	ff 70 0c             	pushl  0xc(%eax)
  8016c0:	e8 82 03 00 00       	call   801a47 <nsipc_send>
}
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016cd:	6a 00                	push   $0x0
  8016cf:	ff 75 10             	pushl  0x10(%ebp)
  8016d2:	ff 75 0c             	pushl  0xc(%ebp)
  8016d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d8:	ff 70 0c             	pushl  0xc(%eax)
  8016db:	e8 fb 02 00 00       	call   8019db <nsipc_recv>
}
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    

008016e2 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016e8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016eb:	52                   	push   %edx
  8016ec:	50                   	push   %eax
  8016ed:	e8 ac f7 ff ff       	call   800e9e <fd_lookup>
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 17                	js     801710 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8016f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fc:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801702:	39 08                	cmp    %ecx,(%eax)
  801704:	75 05                	jne    80170b <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801706:	8b 40 0c             	mov    0xc(%eax),%eax
  801709:	eb 05                	jmp    801710 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80170b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	56                   	push   %esi
  801716:	53                   	push   %ebx
  801717:	83 ec 1c             	sub    $0x1c,%esp
  80171a:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80171c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171f:	50                   	push   %eax
  801720:	e8 2a f7 ff ff       	call   800e4f <fd_alloc>
  801725:	89 c3                	mov    %eax,%ebx
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 1b                	js     801749 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80172e:	83 ec 04             	sub    $0x4,%esp
  801731:	68 07 04 00 00       	push   $0x407
  801736:	ff 75 f4             	pushl  -0xc(%ebp)
  801739:	6a 00                	push   $0x0
  80173b:	e8 c3 f3 ff ff       	call   800b03 <sys_page_alloc>
  801740:	89 c3                	mov    %eax,%ebx
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	85 c0                	test   %eax,%eax
  801747:	79 10                	jns    801759 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801749:	83 ec 0c             	sub    $0xc,%esp
  80174c:	56                   	push   %esi
  80174d:	e8 18 02 00 00       	call   80196a <nsipc_close>
		return r;
  801752:	83 c4 10             	add    $0x10,%esp
  801755:	89 d8                	mov    %ebx,%eax
  801757:	eb 24                	jmp    80177d <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801759:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80175f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801762:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801764:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801767:	c7 42 08 02 00 00 00 	movl   $0x2,0x8(%edx)
	sfd->fd_sock.sockid = sockid;
  80176e:	89 72 0c             	mov    %esi,0xc(%edx)
	return fd2num(sfd);
  801771:	83 ec 0c             	sub    $0xc,%esp
  801774:	52                   	push   %edx
  801775:	e8 ae f6 ff ff       	call   800e28 <fd2num>
  80177a:	83 c4 10             	add    $0x10,%esp
}
  80177d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801780:	5b                   	pop    %ebx
  801781:	5e                   	pop    %esi
  801782:	5d                   	pop    %ebp
  801783:	c3                   	ret    

00801784 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80178a:	8b 45 08             	mov    0x8(%ebp),%eax
  80178d:	e8 50 ff ff ff       	call   8016e2 <fd2sockid>
		return r;
  801792:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801794:	85 c0                	test   %eax,%eax
  801796:	78 1f                	js     8017b7 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801798:	83 ec 04             	sub    $0x4,%esp
  80179b:	ff 75 10             	pushl  0x10(%ebp)
  80179e:	ff 75 0c             	pushl  0xc(%ebp)
  8017a1:	50                   	push   %eax
  8017a2:	e8 1c 01 00 00       	call   8018c3 <nsipc_accept>
  8017a7:	83 c4 10             	add    $0x10,%esp
		return r;
  8017aa:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 07                	js     8017b7 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8017b0:	e8 5d ff ff ff       	call   801712 <alloc_sockfd>
  8017b5:	89 c1                	mov    %eax,%ecx
}
  8017b7:	89 c8                	mov    %ecx,%eax
  8017b9:	c9                   	leave  
  8017ba:	c3                   	ret    

008017bb <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c4:	e8 19 ff ff ff       	call   8016e2 <fd2sockid>
  8017c9:	89 c2                	mov    %eax,%edx
  8017cb:	85 d2                	test   %edx,%edx
  8017cd:	78 12                	js     8017e1 <bind+0x26>
		return r;
	return nsipc_bind(r, name, namelen);
  8017cf:	83 ec 04             	sub    $0x4,%esp
  8017d2:	ff 75 10             	pushl  0x10(%ebp)
  8017d5:	ff 75 0c             	pushl  0xc(%ebp)
  8017d8:	52                   	push   %edx
  8017d9:	e8 35 01 00 00       	call   801913 <nsipc_bind>
  8017de:	83 c4 10             	add    $0x10,%esp
}
  8017e1:	c9                   	leave  
  8017e2:	c3                   	ret    

008017e3 <shutdown>:

int
shutdown(int s, int how)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ec:	e8 f1 fe ff ff       	call   8016e2 <fd2sockid>
  8017f1:	89 c2                	mov    %eax,%edx
  8017f3:	85 d2                	test   %edx,%edx
  8017f5:	78 0f                	js     801806 <shutdown+0x23>
		return r;
	return nsipc_shutdown(r, how);
  8017f7:	83 ec 08             	sub    $0x8,%esp
  8017fa:	ff 75 0c             	pushl  0xc(%ebp)
  8017fd:	52                   	push   %edx
  8017fe:	e8 45 01 00 00       	call   801948 <nsipc_shutdown>
  801803:	83 c4 10             	add    $0x10,%esp
}
  801806:	c9                   	leave  
  801807:	c3                   	ret    

00801808 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	e8 cc fe ff ff       	call   8016e2 <fd2sockid>
  801816:	89 c2                	mov    %eax,%edx
  801818:	85 d2                	test   %edx,%edx
  80181a:	78 12                	js     80182e <connect+0x26>
		return r;
	return nsipc_connect(r, name, namelen);
  80181c:	83 ec 04             	sub    $0x4,%esp
  80181f:	ff 75 10             	pushl  0x10(%ebp)
  801822:	ff 75 0c             	pushl  0xc(%ebp)
  801825:	52                   	push   %edx
  801826:	e8 59 01 00 00       	call   801984 <nsipc_connect>
  80182b:	83 c4 10             	add    $0x10,%esp
}
  80182e:	c9                   	leave  
  80182f:	c3                   	ret    

00801830 <listen>:

int
listen(int s, int backlog)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801836:	8b 45 08             	mov    0x8(%ebp),%eax
  801839:	e8 a4 fe ff ff       	call   8016e2 <fd2sockid>
  80183e:	89 c2                	mov    %eax,%edx
  801840:	85 d2                	test   %edx,%edx
  801842:	78 0f                	js     801853 <listen+0x23>
		return r;
	return nsipc_listen(r, backlog);
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	ff 75 0c             	pushl  0xc(%ebp)
  80184a:	52                   	push   %edx
  80184b:	e8 69 01 00 00       	call   8019b9 <nsipc_listen>
  801850:	83 c4 10             	add    $0x10,%esp
}
  801853:	c9                   	leave  
  801854:	c3                   	ret    

00801855 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80185b:	ff 75 10             	pushl  0x10(%ebp)
  80185e:	ff 75 0c             	pushl  0xc(%ebp)
  801861:	ff 75 08             	pushl  0x8(%ebp)
  801864:	e8 3c 02 00 00       	call   801aa5 <nsipc_socket>
  801869:	89 c2                	mov    %eax,%edx
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	85 d2                	test   %edx,%edx
  801870:	78 05                	js     801877 <socket+0x22>
		return r;
	return alloc_sockfd(r);
  801872:	e8 9b fe ff ff       	call   801712 <alloc_sockfd>
}
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	53                   	push   %ebx
  80187d:	83 ec 04             	sub    $0x4,%esp
  801880:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801882:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801889:	75 12                	jne    80189d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80188b:	83 ec 0c             	sub    $0xc,%esp
  80188e:	6a 02                	push   $0x2
  801890:	e8 19 08 00 00       	call   8020ae <ipc_find_env>
  801895:	a3 04 40 80 00       	mov    %eax,0x804004
  80189a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80189d:	6a 07                	push   $0x7
  80189f:	68 00 60 80 00       	push   $0x806000
  8018a4:	53                   	push   %ebx
  8018a5:	ff 35 04 40 80 00    	pushl  0x804004
  8018ab:	e8 aa 07 00 00       	call   80205a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018b0:	83 c4 0c             	add    $0xc,%esp
  8018b3:	6a 00                	push   $0x0
  8018b5:	6a 00                	push   $0x0
  8018b7:	6a 00                	push   $0x0
  8018b9:	e8 33 07 00 00       	call   801ff1 <ipc_recv>
}
  8018be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	56                   	push   %esi
  8018c7:	53                   	push   %ebx
  8018c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ce:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018d3:	8b 06                	mov    (%esi),%eax
  8018d5:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018da:	b8 01 00 00 00       	mov    $0x1,%eax
  8018df:	e8 95 ff ff ff       	call   801879 <nsipc>
  8018e4:	89 c3                	mov    %eax,%ebx
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 20                	js     80190a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018ea:	83 ec 04             	sub    $0x4,%esp
  8018ed:	ff 35 10 60 80 00    	pushl  0x806010
  8018f3:	68 00 60 80 00       	push   $0x806000
  8018f8:	ff 75 0c             	pushl  0xc(%ebp)
  8018fb:	e8 8c ef ff ff       	call   80088c <memmove>
		*addrlen = ret->ret_addrlen;
  801900:	a1 10 60 80 00       	mov    0x806010,%eax
  801905:	89 06                	mov    %eax,(%esi)
  801907:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80190a:	89 d8                	mov    %ebx,%eax
  80190c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190f:	5b                   	pop    %ebx
  801910:	5e                   	pop    %esi
  801911:	5d                   	pop    %ebp
  801912:	c3                   	ret    

00801913 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	53                   	push   %ebx
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80191d:	8b 45 08             	mov    0x8(%ebp),%eax
  801920:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801925:	53                   	push   %ebx
  801926:	ff 75 0c             	pushl  0xc(%ebp)
  801929:	68 04 60 80 00       	push   $0x806004
  80192e:	e8 59 ef ff ff       	call   80088c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801933:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801939:	b8 02 00 00 00       	mov    $0x2,%eax
  80193e:	e8 36 ff ff ff       	call   801879 <nsipc>
}
  801943:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801946:	c9                   	leave  
  801947:	c3                   	ret    

00801948 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801956:	8b 45 0c             	mov    0xc(%ebp),%eax
  801959:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80195e:	b8 03 00 00 00       	mov    $0x3,%eax
  801963:	e8 11 ff ff ff       	call   801879 <nsipc>
}
  801968:	c9                   	leave  
  801969:	c3                   	ret    

0080196a <nsipc_close>:

int
nsipc_close(int s)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801970:	8b 45 08             	mov    0x8(%ebp),%eax
  801973:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801978:	b8 04 00 00 00       	mov    $0x4,%eax
  80197d:	e8 f7 fe ff ff       	call   801879 <nsipc>
}
  801982:	c9                   	leave  
  801983:	c3                   	ret    

00801984 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	53                   	push   %ebx
  801988:	83 ec 08             	sub    $0x8,%esp
  80198b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80198e:	8b 45 08             	mov    0x8(%ebp),%eax
  801991:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801996:	53                   	push   %ebx
  801997:	ff 75 0c             	pushl  0xc(%ebp)
  80199a:	68 04 60 80 00       	push   $0x806004
  80199f:	e8 e8 ee ff ff       	call   80088c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019a4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8019aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8019af:	e8 c5 fe ff ff       	call   801879 <nsipc>
}
  8019b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8019c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ca:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019cf:	b8 06 00 00 00       	mov    $0x6,%eax
  8019d4:	e8 a0 fe ff ff       	call   801879 <nsipc>
}
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	56                   	push   %esi
  8019df:	53                   	push   %ebx
  8019e0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019eb:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f4:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019f9:	b8 07 00 00 00       	mov    $0x7,%eax
  8019fe:	e8 76 fe ff ff       	call   801879 <nsipc>
  801a03:	89 c3                	mov    %eax,%ebx
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 35                	js     801a3e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a09:	39 f0                	cmp    %esi,%eax
  801a0b:	7f 07                	jg     801a14 <nsipc_recv+0x39>
  801a0d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a12:	7e 16                	jle    801a2a <nsipc_recv+0x4f>
  801a14:	68 cb 28 80 00       	push   $0x8028cb
  801a19:	68 93 28 80 00       	push   $0x802893
  801a1e:	6a 62                	push   $0x62
  801a20:	68 e0 28 80 00       	push   $0x8028e0
  801a25:	e8 81 05 00 00       	call   801fab <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a2a:	83 ec 04             	sub    $0x4,%esp
  801a2d:	50                   	push   %eax
  801a2e:	68 00 60 80 00       	push   $0x806000
  801a33:	ff 75 0c             	pushl  0xc(%ebp)
  801a36:	e8 51 ee ff ff       	call   80088c <memmove>
  801a3b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a3e:	89 d8                	mov    %ebx,%eax
  801a40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a43:	5b                   	pop    %ebx
  801a44:	5e                   	pop    %esi
  801a45:	5d                   	pop    %ebp
  801a46:	c3                   	ret    

00801a47 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	53                   	push   %ebx
  801a4b:	83 ec 04             	sub    $0x4,%esp
  801a4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a51:	8b 45 08             	mov    0x8(%ebp),%eax
  801a54:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a59:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a5f:	7e 16                	jle    801a77 <nsipc_send+0x30>
  801a61:	68 ec 28 80 00       	push   $0x8028ec
  801a66:	68 93 28 80 00       	push   $0x802893
  801a6b:	6a 6d                	push   $0x6d
  801a6d:	68 e0 28 80 00       	push   $0x8028e0
  801a72:	e8 34 05 00 00       	call   801fab <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a77:	83 ec 04             	sub    $0x4,%esp
  801a7a:	53                   	push   %ebx
  801a7b:	ff 75 0c             	pushl  0xc(%ebp)
  801a7e:	68 0c 60 80 00       	push   $0x80600c
  801a83:	e8 04 ee ff ff       	call   80088c <memmove>
	nsipcbuf.send.req_size = size;
  801a88:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a8e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a91:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a96:	b8 08 00 00 00       	mov    $0x8,%eax
  801a9b:	e8 d9 fd ff ff       	call   801879 <nsipc>
}
  801aa0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    

00801aa5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801aab:	8b 45 08             	mov    0x8(%ebp),%eax
  801aae:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab6:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801abb:	8b 45 10             	mov    0x10(%ebp),%eax
  801abe:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ac3:	b8 09 00 00 00       	mov    $0x9,%eax
  801ac8:	e8 ac fd ff ff       	call   801879 <nsipc>
}
  801acd:	c9                   	leave  
  801ace:	c3                   	ret    

00801acf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	56                   	push   %esi
  801ad3:	53                   	push   %ebx
  801ad4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ad7:	83 ec 0c             	sub    $0xc,%esp
  801ada:	ff 75 08             	pushl  0x8(%ebp)
  801add:	e8 56 f3 ff ff       	call   800e38 <fd2data>
  801ae2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ae4:	83 c4 08             	add    $0x8,%esp
  801ae7:	68 f8 28 80 00       	push   $0x8028f8
  801aec:	53                   	push   %ebx
  801aed:	e8 08 ec ff ff       	call   8006fa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801af2:	8b 56 04             	mov    0x4(%esi),%edx
  801af5:	89 d0                	mov    %edx,%eax
  801af7:	2b 06                	sub    (%esi),%eax
  801af9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aff:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b06:	00 00 00 
	stat->st_dev = &devpipe;
  801b09:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b10:	30 80 00 
	return 0;
}
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
  801b18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b1b:	5b                   	pop    %ebx
  801b1c:	5e                   	pop    %esi
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    

00801b1f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	53                   	push   %ebx
  801b23:	83 ec 0c             	sub    $0xc,%esp
  801b26:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b29:	53                   	push   %ebx
  801b2a:	6a 00                	push   $0x0
  801b2c:	e8 57 f0 ff ff       	call   800b88 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b31:	89 1c 24             	mov    %ebx,(%esp)
  801b34:	e8 ff f2 ff ff       	call   800e38 <fd2data>
  801b39:	83 c4 08             	add    $0x8,%esp
  801b3c:	50                   	push   %eax
  801b3d:	6a 00                	push   $0x0
  801b3f:	e8 44 f0 ff ff       	call   800b88 <sys_page_unmap>
}
  801b44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	57                   	push   %edi
  801b4d:	56                   	push   %esi
  801b4e:	53                   	push   %ebx
  801b4f:	83 ec 1c             	sub    $0x1c,%esp
  801b52:	89 c6                	mov    %eax,%esi
  801b54:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b57:	a1 08 40 80 00       	mov    0x804008,%eax
  801b5c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b5f:	83 ec 0c             	sub    $0xc,%esp
  801b62:	56                   	push   %esi
  801b63:	e8 7e 05 00 00       	call   8020e6 <pageref>
  801b68:	89 c7                	mov    %eax,%edi
  801b6a:	83 c4 04             	add    $0x4,%esp
  801b6d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b70:	e8 71 05 00 00       	call   8020e6 <pageref>
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	39 c7                	cmp    %eax,%edi
  801b7a:	0f 94 c2             	sete   %dl
  801b7d:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801b80:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801b86:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801b89:	39 fb                	cmp    %edi,%ebx
  801b8b:	74 19                	je     801ba6 <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801b8d:	84 d2                	test   %dl,%dl
  801b8f:	74 c6                	je     801b57 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b91:	8b 51 58             	mov    0x58(%ecx),%edx
  801b94:	50                   	push   %eax
  801b95:	52                   	push   %edx
  801b96:	53                   	push   %ebx
  801b97:	68 ff 28 80 00       	push   $0x8028ff
  801b9c:	e8 d2 e5 ff ff       	call   800173 <cprintf>
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	eb b1                	jmp    801b57 <_pipeisclosed+0xe>
	}
}
  801ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba9:	5b                   	pop    %ebx
  801baa:	5e                   	pop    %esi
  801bab:	5f                   	pop    %edi
  801bac:	5d                   	pop    %ebp
  801bad:	c3                   	ret    

00801bae <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	57                   	push   %edi
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 28             	sub    $0x28,%esp
  801bb7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bba:	56                   	push   %esi
  801bbb:	e8 78 f2 ff ff       	call   800e38 <fd2data>
  801bc0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	bf 00 00 00 00       	mov    $0x0,%edi
  801bca:	eb 4b                	jmp    801c17 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bcc:	89 da                	mov    %ebx,%edx
  801bce:	89 f0                	mov    %esi,%eax
  801bd0:	e8 74 ff ff ff       	call   801b49 <_pipeisclosed>
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	75 48                	jne    801c21 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bd9:	e8 06 ef ff ff       	call   800ae4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bde:	8b 43 04             	mov    0x4(%ebx),%eax
  801be1:	8b 0b                	mov    (%ebx),%ecx
  801be3:	8d 51 20             	lea    0x20(%ecx),%edx
  801be6:	39 d0                	cmp    %edx,%eax
  801be8:	73 e2                	jae    801bcc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bed:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bf1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bf4:	89 c2                	mov    %eax,%edx
  801bf6:	c1 fa 1f             	sar    $0x1f,%edx
  801bf9:	89 d1                	mov    %edx,%ecx
  801bfb:	c1 e9 1b             	shr    $0x1b,%ecx
  801bfe:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c01:	83 e2 1f             	and    $0x1f,%edx
  801c04:	29 ca                	sub    %ecx,%edx
  801c06:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c0a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c0e:	83 c0 01             	add    $0x1,%eax
  801c11:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c14:	83 c7 01             	add    $0x1,%edi
  801c17:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c1a:	75 c2                	jne    801bde <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c1c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c1f:	eb 05                	jmp    801c26 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c21:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c29:	5b                   	pop    %ebx
  801c2a:	5e                   	pop    %esi
  801c2b:	5f                   	pop    %edi
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	57                   	push   %edi
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	83 ec 18             	sub    $0x18,%esp
  801c37:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c3a:	57                   	push   %edi
  801c3b:	e8 f8 f1 ff ff       	call   800e38 <fd2data>
  801c40:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c4a:	eb 3d                	jmp    801c89 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c4c:	85 db                	test   %ebx,%ebx
  801c4e:	74 04                	je     801c54 <devpipe_read+0x26>
				return i;
  801c50:	89 d8                	mov    %ebx,%eax
  801c52:	eb 44                	jmp    801c98 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c54:	89 f2                	mov    %esi,%edx
  801c56:	89 f8                	mov    %edi,%eax
  801c58:	e8 ec fe ff ff       	call   801b49 <_pipeisclosed>
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	75 32                	jne    801c93 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c61:	e8 7e ee ff ff       	call   800ae4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c66:	8b 06                	mov    (%esi),%eax
  801c68:	3b 46 04             	cmp    0x4(%esi),%eax
  801c6b:	74 df                	je     801c4c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c6d:	99                   	cltd   
  801c6e:	c1 ea 1b             	shr    $0x1b,%edx
  801c71:	01 d0                	add    %edx,%eax
  801c73:	83 e0 1f             	and    $0x1f,%eax
  801c76:	29 d0                	sub    %edx,%eax
  801c78:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c80:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c83:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c86:	83 c3 01             	add    $0x1,%ebx
  801c89:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c8c:	75 d8                	jne    801c66 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c8e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c91:	eb 05                	jmp    801c98 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c93:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9b:	5b                   	pop    %ebx
  801c9c:	5e                   	pop    %esi
  801c9d:	5f                   	pop    %edi
  801c9e:	5d                   	pop    %ebp
  801c9f:	c3                   	ret    

00801ca0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	56                   	push   %esi
  801ca4:	53                   	push   %ebx
  801ca5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ca8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cab:	50                   	push   %eax
  801cac:	e8 9e f1 ff ff       	call   800e4f <fd_alloc>
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	89 c2                	mov    %eax,%edx
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	0f 88 2c 01 00 00    	js     801dea <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbe:	83 ec 04             	sub    $0x4,%esp
  801cc1:	68 07 04 00 00       	push   $0x407
  801cc6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc9:	6a 00                	push   $0x0
  801ccb:	e8 33 ee ff ff       	call   800b03 <sys_page_alloc>
  801cd0:	83 c4 10             	add    $0x10,%esp
  801cd3:	89 c2                	mov    %eax,%edx
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	0f 88 0d 01 00 00    	js     801dea <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cdd:	83 ec 0c             	sub    $0xc,%esp
  801ce0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce3:	50                   	push   %eax
  801ce4:	e8 66 f1 ff ff       	call   800e4f <fd_alloc>
  801ce9:	89 c3                	mov    %eax,%ebx
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	0f 88 e2 00 00 00    	js     801dd8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf6:	83 ec 04             	sub    $0x4,%esp
  801cf9:	68 07 04 00 00       	push   $0x407
  801cfe:	ff 75 f0             	pushl  -0x10(%ebp)
  801d01:	6a 00                	push   $0x0
  801d03:	e8 fb ed ff ff       	call   800b03 <sys_page_alloc>
  801d08:	89 c3                	mov    %eax,%ebx
  801d0a:	83 c4 10             	add    $0x10,%esp
  801d0d:	85 c0                	test   %eax,%eax
  801d0f:	0f 88 c3 00 00 00    	js     801dd8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d15:	83 ec 0c             	sub    $0xc,%esp
  801d18:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1b:	e8 18 f1 ff ff       	call   800e38 <fd2data>
  801d20:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d22:	83 c4 0c             	add    $0xc,%esp
  801d25:	68 07 04 00 00       	push   $0x407
  801d2a:	50                   	push   %eax
  801d2b:	6a 00                	push   $0x0
  801d2d:	e8 d1 ed ff ff       	call   800b03 <sys_page_alloc>
  801d32:	89 c3                	mov    %eax,%ebx
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	85 c0                	test   %eax,%eax
  801d39:	0f 88 89 00 00 00    	js     801dc8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3f:	83 ec 0c             	sub    $0xc,%esp
  801d42:	ff 75 f0             	pushl  -0x10(%ebp)
  801d45:	e8 ee f0 ff ff       	call   800e38 <fd2data>
  801d4a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d51:	50                   	push   %eax
  801d52:	6a 00                	push   $0x0
  801d54:	56                   	push   %esi
  801d55:	6a 00                	push   $0x0
  801d57:	e8 ea ed ff ff       	call   800b46 <sys_page_map>
  801d5c:	89 c3                	mov    %eax,%ebx
  801d5e:	83 c4 20             	add    $0x20,%esp
  801d61:	85 c0                	test   %eax,%eax
  801d63:	78 55                	js     801dba <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d65:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d73:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d7a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d83:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d88:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d8f:	83 ec 0c             	sub    $0xc,%esp
  801d92:	ff 75 f4             	pushl  -0xc(%ebp)
  801d95:	e8 8e f0 ff ff       	call   800e28 <fd2num>
  801d9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d9d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d9f:	83 c4 04             	add    $0x4,%esp
  801da2:	ff 75 f0             	pushl  -0x10(%ebp)
  801da5:	e8 7e f0 ff ff       	call   800e28 <fd2num>
  801daa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dad:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	ba 00 00 00 00       	mov    $0x0,%edx
  801db8:	eb 30                	jmp    801dea <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dba:	83 ec 08             	sub    $0x8,%esp
  801dbd:	56                   	push   %esi
  801dbe:	6a 00                	push   $0x0
  801dc0:	e8 c3 ed ff ff       	call   800b88 <sys_page_unmap>
  801dc5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dc8:	83 ec 08             	sub    $0x8,%esp
  801dcb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dce:	6a 00                	push   $0x0
  801dd0:	e8 b3 ed ff ff       	call   800b88 <sys_page_unmap>
  801dd5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dd8:	83 ec 08             	sub    $0x8,%esp
  801ddb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dde:	6a 00                	push   $0x0
  801de0:	e8 a3 ed ff ff       	call   800b88 <sys_page_unmap>
  801de5:	83 c4 10             	add    $0x10,%esp
  801de8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dea:	89 d0                	mov    %edx,%eax
  801dec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801def:	5b                   	pop    %ebx
  801df0:	5e                   	pop    %esi
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    

00801df3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfc:	50                   	push   %eax
  801dfd:	ff 75 08             	pushl  0x8(%ebp)
  801e00:	e8 99 f0 ff ff       	call   800e9e <fd_lookup>
  801e05:	89 c2                	mov    %eax,%edx
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	85 d2                	test   %edx,%edx
  801e0c:	78 18                	js     801e26 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e0e:	83 ec 0c             	sub    $0xc,%esp
  801e11:	ff 75 f4             	pushl  -0xc(%ebp)
  801e14:	e8 1f f0 ff ff       	call   800e38 <fd2data>
	return _pipeisclosed(fd, p);
  801e19:	89 c2                	mov    %eax,%edx
  801e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1e:	e8 26 fd ff ff       	call   801b49 <_pipeisclosed>
  801e23:	83 c4 10             	add    $0x10,%esp
}
  801e26:	c9                   	leave  
  801e27:	c3                   	ret    

00801e28 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e30:	5d                   	pop    %ebp
  801e31:	c3                   	ret    

00801e32 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e38:	68 17 29 80 00       	push   $0x802917
  801e3d:	ff 75 0c             	pushl  0xc(%ebp)
  801e40:	e8 b5 e8 ff ff       	call   8006fa <strcpy>
	return 0;
}
  801e45:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	57                   	push   %edi
  801e50:	56                   	push   %esi
  801e51:	53                   	push   %ebx
  801e52:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e58:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e5d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e63:	eb 2d                	jmp    801e92 <devcons_write+0x46>
		m = n - tot;
  801e65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e68:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e6a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e6d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e72:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e75:	83 ec 04             	sub    $0x4,%esp
  801e78:	53                   	push   %ebx
  801e79:	03 45 0c             	add    0xc(%ebp),%eax
  801e7c:	50                   	push   %eax
  801e7d:	57                   	push   %edi
  801e7e:	e8 09 ea ff ff       	call   80088c <memmove>
		sys_cputs(buf, m);
  801e83:	83 c4 08             	add    $0x8,%esp
  801e86:	53                   	push   %ebx
  801e87:	57                   	push   %edi
  801e88:	e8 ba eb ff ff       	call   800a47 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e8d:	01 de                	add    %ebx,%esi
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	89 f0                	mov    %esi,%eax
  801e94:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e97:	72 cc                	jb     801e65 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9c:	5b                   	pop    %ebx
  801e9d:	5e                   	pop    %esi
  801e9e:	5f                   	pop    %edi
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    

00801ea1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801ea7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801eac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eb0:	75 07                	jne    801eb9 <devcons_read+0x18>
  801eb2:	eb 28                	jmp    801edc <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801eb4:	e8 2b ec ff ff       	call   800ae4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801eb9:	e8 a7 eb ff ff       	call   800a65 <sys_cgetc>
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	74 f2                	je     801eb4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	78 16                	js     801edc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ec6:	83 f8 04             	cmp    $0x4,%eax
  801ec9:	74 0c                	je     801ed7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ece:	88 02                	mov    %al,(%edx)
	return 1;
  801ed0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed5:	eb 05                	jmp    801edc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ed7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eea:	6a 01                	push   $0x1
  801eec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eef:	50                   	push   %eax
  801ef0:	e8 52 eb ff ff       	call   800a47 <sys_cputs>
  801ef5:	83 c4 10             	add    $0x10,%esp
}
  801ef8:	c9                   	leave  
  801ef9:	c3                   	ret    

00801efa <getchar>:

int
getchar(void)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f00:	6a 01                	push   $0x1
  801f02:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f05:	50                   	push   %eax
  801f06:	6a 00                	push   $0x0
  801f08:	e8 00 f2 ff ff       	call   80110d <read>
	if (r < 0)
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 0f                	js     801f23 <getchar+0x29>
		return r;
	if (r < 1)
  801f14:	85 c0                	test   %eax,%eax
  801f16:	7e 06                	jle    801f1e <getchar+0x24>
		return -E_EOF;
	return c;
  801f18:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f1c:	eb 05                	jmp    801f23 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f1e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f23:	c9                   	leave  
  801f24:	c3                   	ret    

00801f25 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2e:	50                   	push   %eax
  801f2f:	ff 75 08             	pushl  0x8(%ebp)
  801f32:	e8 67 ef ff ff       	call   800e9e <fd_lookup>
  801f37:	83 c4 10             	add    $0x10,%esp
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	78 11                	js     801f4f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f41:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f47:	39 10                	cmp    %edx,(%eax)
  801f49:	0f 94 c0             	sete   %al
  801f4c:	0f b6 c0             	movzbl %al,%eax
}
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    

00801f51 <opencons>:

int
opencons(void)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5a:	50                   	push   %eax
  801f5b:	e8 ef ee ff ff       	call   800e4f <fd_alloc>
  801f60:	83 c4 10             	add    $0x10,%esp
		return r;
  801f63:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f65:	85 c0                	test   %eax,%eax
  801f67:	78 3e                	js     801fa7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f69:	83 ec 04             	sub    $0x4,%esp
  801f6c:	68 07 04 00 00       	push   $0x407
  801f71:	ff 75 f4             	pushl  -0xc(%ebp)
  801f74:	6a 00                	push   $0x0
  801f76:	e8 88 eb ff ff       	call   800b03 <sys_page_alloc>
  801f7b:	83 c4 10             	add    $0x10,%esp
		return r;
  801f7e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f80:	85 c0                	test   %eax,%eax
  801f82:	78 23                	js     801fa7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f84:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f92:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f99:	83 ec 0c             	sub    $0xc,%esp
  801f9c:	50                   	push   %eax
  801f9d:	e8 86 ee ff ff       	call   800e28 <fd2num>
  801fa2:	89 c2                	mov    %eax,%edx
  801fa4:	83 c4 10             	add    $0x10,%esp
}
  801fa7:	89 d0                	mov    %edx,%eax
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    

00801fab <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	56                   	push   %esi
  801faf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fb0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fb3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fb9:	e8 07 eb ff ff       	call   800ac5 <sys_getenvid>
  801fbe:	83 ec 0c             	sub    $0xc,%esp
  801fc1:	ff 75 0c             	pushl  0xc(%ebp)
  801fc4:	ff 75 08             	pushl  0x8(%ebp)
  801fc7:	56                   	push   %esi
  801fc8:	50                   	push   %eax
  801fc9:	68 24 29 80 00       	push   $0x802924
  801fce:	e8 a0 e1 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fd3:	83 c4 18             	add    $0x18,%esp
  801fd6:	53                   	push   %ebx
  801fd7:	ff 75 10             	pushl  0x10(%ebp)
  801fda:	e8 43 e1 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801fdf:	c7 04 24 10 29 80 00 	movl   $0x802910,(%esp)
  801fe6:	e8 88 e1 ff ff       	call   800173 <cprintf>
  801feb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fee:	cc                   	int3   
  801fef:	eb fd                	jmp    801fee <_panic+0x43>

00801ff1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ff1:	55                   	push   %ebp
  801ff2:	89 e5                	mov    %esp,%ebp
  801ff4:	56                   	push   %esi
  801ff5:	53                   	push   %ebx
  801ff6:	8b 75 08             	mov    0x8(%ebp),%esi
  801ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ffc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801fff:	85 c0                	test   %eax,%eax
  802001:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802006:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  802009:	83 ec 0c             	sub    $0xc,%esp
  80200c:	50                   	push   %eax
  80200d:	e8 a1 ec ff ff       	call   800cb3 <sys_ipc_recv>
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	85 c0                	test   %eax,%eax
  802017:	79 16                	jns    80202f <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  802019:	85 f6                	test   %esi,%esi
  80201b:	74 06                	je     802023 <ipc_recv+0x32>
  80201d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  802023:	85 db                	test   %ebx,%ebx
  802025:	74 2c                	je     802053 <ipc_recv+0x62>
  802027:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80202d:	eb 24                	jmp    802053 <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  80202f:	85 f6                	test   %esi,%esi
  802031:	74 0a                	je     80203d <ipc_recv+0x4c>
  802033:	a1 08 40 80 00       	mov    0x804008,%eax
  802038:	8b 40 74             	mov    0x74(%eax),%eax
  80203b:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80203d:	85 db                	test   %ebx,%ebx
  80203f:	74 0a                	je     80204b <ipc_recv+0x5a>
  802041:	a1 08 40 80 00       	mov    0x804008,%eax
  802046:	8b 40 78             	mov    0x78(%eax),%eax
  802049:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  80204b:	a1 08 40 80 00       	mov    0x804008,%eax
  802050:	8b 40 70             	mov    0x70(%eax),%eax
}
  802053:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802056:	5b                   	pop    %ebx
  802057:	5e                   	pop    %esi
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    

0080205a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	57                   	push   %edi
  80205e:	56                   	push   %esi
  80205f:	53                   	push   %ebx
  802060:	83 ec 0c             	sub    $0xc,%esp
  802063:	8b 7d 08             	mov    0x8(%ebp),%edi
  802066:	8b 75 0c             	mov    0xc(%ebp),%esi
  802069:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  80206c:	85 db                	test   %ebx,%ebx
  80206e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802073:	0f 44 d8             	cmove  %eax,%ebx
  802076:	eb 1c                	jmp    802094 <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  802078:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80207b:	74 12                	je     80208f <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  80207d:	50                   	push   %eax
  80207e:	68 48 29 80 00       	push   $0x802948
  802083:	6a 39                	push   $0x39
  802085:	68 63 29 80 00       	push   $0x802963
  80208a:	e8 1c ff ff ff       	call   801fab <_panic>
                 sys_yield();
  80208f:	e8 50 ea ff ff       	call   800ae4 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802094:	ff 75 14             	pushl  0x14(%ebp)
  802097:	53                   	push   %ebx
  802098:	56                   	push   %esi
  802099:	57                   	push   %edi
  80209a:	e8 f1 eb ff ff       	call   800c90 <sys_ipc_try_send>
  80209f:	83 c4 10             	add    $0x10,%esp
  8020a2:	85 c0                	test   %eax,%eax
  8020a4:	78 d2                	js     802078 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  8020a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a9:	5b                   	pop    %ebx
  8020aa:	5e                   	pop    %esi
  8020ab:	5f                   	pop    %edi
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    

008020ae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020b4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020b9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020bc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020c2:	8b 52 50             	mov    0x50(%edx),%edx
  8020c5:	39 ca                	cmp    %ecx,%edx
  8020c7:	75 0d                	jne    8020d6 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020c9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020cc:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8020d1:	8b 40 08             	mov    0x8(%eax),%eax
  8020d4:	eb 0e                	jmp    8020e4 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020d6:	83 c0 01             	add    $0x1,%eax
  8020d9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020de:	75 d9                	jne    8020b9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020e0:	66 b8 00 00          	mov    $0x0,%ax
}
  8020e4:	5d                   	pop    %ebp
  8020e5:	c3                   	ret    

008020e6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ec:	89 d0                	mov    %edx,%eax
  8020ee:	c1 e8 16             	shr    $0x16,%eax
  8020f1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020f8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020fd:	f6 c1 01             	test   $0x1,%cl
  802100:	74 1d                	je     80211f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802102:	c1 ea 0c             	shr    $0xc,%edx
  802105:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80210c:	f6 c2 01             	test   $0x1,%dl
  80210f:	74 0e                	je     80211f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802111:	c1 ea 0c             	shr    $0xc,%edx
  802114:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80211b:	ef 
  80211c:	0f b7 c0             	movzwl %ax,%eax
}
  80211f:	5d                   	pop    %ebp
  802120:	c3                   	ret    
  802121:	66 90                	xchg   %ax,%ax
  802123:	66 90                	xchg   %ax,%ax
  802125:	66 90                	xchg   %ax,%ax
  802127:	66 90                	xchg   %ax,%ax
  802129:	66 90                	xchg   %ax,%ax
  80212b:	66 90                	xchg   %ax,%ax
  80212d:	66 90                	xchg   %ax,%ax
  80212f:	90                   	nop

00802130 <__udivdi3>:
  802130:	55                   	push   %ebp
  802131:	57                   	push   %edi
  802132:	56                   	push   %esi
  802133:	83 ec 10             	sub    $0x10,%esp
  802136:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80213a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80213e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802142:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802146:	85 d2                	test   %edx,%edx
  802148:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80214c:	89 34 24             	mov    %esi,(%esp)
  80214f:	89 c8                	mov    %ecx,%eax
  802151:	75 35                	jne    802188 <__udivdi3+0x58>
  802153:	39 f1                	cmp    %esi,%ecx
  802155:	0f 87 bd 00 00 00    	ja     802218 <__udivdi3+0xe8>
  80215b:	85 c9                	test   %ecx,%ecx
  80215d:	89 cd                	mov    %ecx,%ebp
  80215f:	75 0b                	jne    80216c <__udivdi3+0x3c>
  802161:	b8 01 00 00 00       	mov    $0x1,%eax
  802166:	31 d2                	xor    %edx,%edx
  802168:	f7 f1                	div    %ecx
  80216a:	89 c5                	mov    %eax,%ebp
  80216c:	89 f0                	mov    %esi,%eax
  80216e:	31 d2                	xor    %edx,%edx
  802170:	f7 f5                	div    %ebp
  802172:	89 c6                	mov    %eax,%esi
  802174:	89 f8                	mov    %edi,%eax
  802176:	f7 f5                	div    %ebp
  802178:	89 f2                	mov    %esi,%edx
  80217a:	83 c4 10             	add    $0x10,%esp
  80217d:	5e                   	pop    %esi
  80217e:	5f                   	pop    %edi
  80217f:	5d                   	pop    %ebp
  802180:	c3                   	ret    
  802181:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802188:	3b 14 24             	cmp    (%esp),%edx
  80218b:	77 7b                	ja     802208 <__udivdi3+0xd8>
  80218d:	0f bd f2             	bsr    %edx,%esi
  802190:	83 f6 1f             	xor    $0x1f,%esi
  802193:	0f 84 97 00 00 00    	je     802230 <__udivdi3+0x100>
  802199:	bd 20 00 00 00       	mov    $0x20,%ebp
  80219e:	89 d7                	mov    %edx,%edi
  8021a0:	89 f1                	mov    %esi,%ecx
  8021a2:	29 f5                	sub    %esi,%ebp
  8021a4:	d3 e7                	shl    %cl,%edi
  8021a6:	89 c2                	mov    %eax,%edx
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	d3 ea                	shr    %cl,%edx
  8021ac:	89 f1                	mov    %esi,%ecx
  8021ae:	09 fa                	or     %edi,%edx
  8021b0:	8b 3c 24             	mov    (%esp),%edi
  8021b3:	d3 e0                	shl    %cl,%eax
  8021b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021bf:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021c3:	89 fa                	mov    %edi,%edx
  8021c5:	d3 ea                	shr    %cl,%edx
  8021c7:	89 f1                	mov    %esi,%ecx
  8021c9:	d3 e7                	shl    %cl,%edi
  8021cb:	89 e9                	mov    %ebp,%ecx
  8021cd:	d3 e8                	shr    %cl,%eax
  8021cf:	09 c7                	or     %eax,%edi
  8021d1:	89 f8                	mov    %edi,%eax
  8021d3:	f7 74 24 08          	divl   0x8(%esp)
  8021d7:	89 d5                	mov    %edx,%ebp
  8021d9:	89 c7                	mov    %eax,%edi
  8021db:	f7 64 24 0c          	mull   0xc(%esp)
  8021df:	39 d5                	cmp    %edx,%ebp
  8021e1:	89 14 24             	mov    %edx,(%esp)
  8021e4:	72 11                	jb     8021f7 <__udivdi3+0xc7>
  8021e6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021ea:	89 f1                	mov    %esi,%ecx
  8021ec:	d3 e2                	shl    %cl,%edx
  8021ee:	39 c2                	cmp    %eax,%edx
  8021f0:	73 5e                	jae    802250 <__udivdi3+0x120>
  8021f2:	3b 2c 24             	cmp    (%esp),%ebp
  8021f5:	75 59                	jne    802250 <__udivdi3+0x120>
  8021f7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8021fa:	31 f6                	xor    %esi,%esi
  8021fc:	89 f2                	mov    %esi,%edx
  8021fe:	83 c4 10             	add    $0x10,%esp
  802201:	5e                   	pop    %esi
  802202:	5f                   	pop    %edi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    
  802205:	8d 76 00             	lea    0x0(%esi),%esi
  802208:	31 f6                	xor    %esi,%esi
  80220a:	31 c0                	xor    %eax,%eax
  80220c:	89 f2                	mov    %esi,%edx
  80220e:	83 c4 10             	add    $0x10,%esp
  802211:	5e                   	pop    %esi
  802212:	5f                   	pop    %edi
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    
  802215:	8d 76 00             	lea    0x0(%esi),%esi
  802218:	89 f2                	mov    %esi,%edx
  80221a:	31 f6                	xor    %esi,%esi
  80221c:	89 f8                	mov    %edi,%eax
  80221e:	f7 f1                	div    %ecx
  802220:	89 f2                	mov    %esi,%edx
  802222:	83 c4 10             	add    $0x10,%esp
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802234:	76 0b                	jbe    802241 <__udivdi3+0x111>
  802236:	31 c0                	xor    %eax,%eax
  802238:	3b 14 24             	cmp    (%esp),%edx
  80223b:	0f 83 37 ff ff ff    	jae    802178 <__udivdi3+0x48>
  802241:	b8 01 00 00 00       	mov    $0x1,%eax
  802246:	e9 2d ff ff ff       	jmp    802178 <__udivdi3+0x48>
  80224b:	90                   	nop
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 f8                	mov    %edi,%eax
  802252:	31 f6                	xor    %esi,%esi
  802254:	e9 1f ff ff ff       	jmp    802178 <__udivdi3+0x48>
  802259:	66 90                	xchg   %ax,%ax
  80225b:	66 90                	xchg   %ax,%ax
  80225d:	66 90                	xchg   %ax,%ax
  80225f:	90                   	nop

00802260 <__umoddi3>:
  802260:	55                   	push   %ebp
  802261:	57                   	push   %edi
  802262:	56                   	push   %esi
  802263:	83 ec 20             	sub    $0x20,%esp
  802266:	8b 44 24 34          	mov    0x34(%esp),%eax
  80226a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80226e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802272:	89 c6                	mov    %eax,%esi
  802274:	89 44 24 10          	mov    %eax,0x10(%esp)
  802278:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80227c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802280:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802284:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802288:	89 74 24 18          	mov    %esi,0x18(%esp)
  80228c:	85 c0                	test   %eax,%eax
  80228e:	89 c2                	mov    %eax,%edx
  802290:	75 1e                	jne    8022b0 <__umoddi3+0x50>
  802292:	39 f7                	cmp    %esi,%edi
  802294:	76 52                	jbe    8022e8 <__umoddi3+0x88>
  802296:	89 c8                	mov    %ecx,%eax
  802298:	89 f2                	mov    %esi,%edx
  80229a:	f7 f7                	div    %edi
  80229c:	89 d0                	mov    %edx,%eax
  80229e:	31 d2                	xor    %edx,%edx
  8022a0:	83 c4 20             	add    $0x20,%esp
  8022a3:	5e                   	pop    %esi
  8022a4:	5f                   	pop    %edi
  8022a5:	5d                   	pop    %ebp
  8022a6:	c3                   	ret    
  8022a7:	89 f6                	mov    %esi,%esi
  8022a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022b0:	39 f0                	cmp    %esi,%eax
  8022b2:	77 5c                	ja     802310 <__umoddi3+0xb0>
  8022b4:	0f bd e8             	bsr    %eax,%ebp
  8022b7:	83 f5 1f             	xor    $0x1f,%ebp
  8022ba:	75 64                	jne    802320 <__umoddi3+0xc0>
  8022bc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8022c0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8022c4:	0f 86 f6 00 00 00    	jbe    8023c0 <__umoddi3+0x160>
  8022ca:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8022ce:	0f 82 ec 00 00 00    	jb     8023c0 <__umoddi3+0x160>
  8022d4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022d8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8022dc:	83 c4 20             	add    $0x20,%esp
  8022df:	5e                   	pop    %esi
  8022e0:	5f                   	pop    %edi
  8022e1:	5d                   	pop    %ebp
  8022e2:	c3                   	ret    
  8022e3:	90                   	nop
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	85 ff                	test   %edi,%edi
  8022ea:	89 fd                	mov    %edi,%ebp
  8022ec:	75 0b                	jne    8022f9 <__umoddi3+0x99>
  8022ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f3:	31 d2                	xor    %edx,%edx
  8022f5:	f7 f7                	div    %edi
  8022f7:	89 c5                	mov    %eax,%ebp
  8022f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8022fd:	31 d2                	xor    %edx,%edx
  8022ff:	f7 f5                	div    %ebp
  802301:	89 c8                	mov    %ecx,%eax
  802303:	f7 f5                	div    %ebp
  802305:	eb 95                	jmp    80229c <__umoddi3+0x3c>
  802307:	89 f6                	mov    %esi,%esi
  802309:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802310:	89 c8                	mov    %ecx,%eax
  802312:	89 f2                	mov    %esi,%edx
  802314:	83 c4 20             	add    $0x20,%esp
  802317:	5e                   	pop    %esi
  802318:	5f                   	pop    %edi
  802319:	5d                   	pop    %ebp
  80231a:	c3                   	ret    
  80231b:	90                   	nop
  80231c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802320:	b8 20 00 00 00       	mov    $0x20,%eax
  802325:	89 e9                	mov    %ebp,%ecx
  802327:	29 e8                	sub    %ebp,%eax
  802329:	d3 e2                	shl    %cl,%edx
  80232b:	89 c7                	mov    %eax,%edi
  80232d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802331:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802335:	89 f9                	mov    %edi,%ecx
  802337:	d3 e8                	shr    %cl,%eax
  802339:	89 c1                	mov    %eax,%ecx
  80233b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80233f:	09 d1                	or     %edx,%ecx
  802341:	89 fa                	mov    %edi,%edx
  802343:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802347:	89 e9                	mov    %ebp,%ecx
  802349:	d3 e0                	shl    %cl,%eax
  80234b:	89 f9                	mov    %edi,%ecx
  80234d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802351:	89 f0                	mov    %esi,%eax
  802353:	d3 e8                	shr    %cl,%eax
  802355:	89 e9                	mov    %ebp,%ecx
  802357:	89 c7                	mov    %eax,%edi
  802359:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80235d:	d3 e6                	shl    %cl,%esi
  80235f:	89 d1                	mov    %edx,%ecx
  802361:	89 fa                	mov    %edi,%edx
  802363:	d3 e8                	shr    %cl,%eax
  802365:	89 e9                	mov    %ebp,%ecx
  802367:	09 f0                	or     %esi,%eax
  802369:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80236d:	f7 74 24 10          	divl   0x10(%esp)
  802371:	d3 e6                	shl    %cl,%esi
  802373:	89 d1                	mov    %edx,%ecx
  802375:	f7 64 24 0c          	mull   0xc(%esp)
  802379:	39 d1                	cmp    %edx,%ecx
  80237b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80237f:	89 d7                	mov    %edx,%edi
  802381:	89 c6                	mov    %eax,%esi
  802383:	72 0a                	jb     80238f <__umoddi3+0x12f>
  802385:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802389:	73 10                	jae    80239b <__umoddi3+0x13b>
  80238b:	39 d1                	cmp    %edx,%ecx
  80238d:	75 0c                	jne    80239b <__umoddi3+0x13b>
  80238f:	89 d7                	mov    %edx,%edi
  802391:	89 c6                	mov    %eax,%esi
  802393:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802397:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80239b:	89 ca                	mov    %ecx,%edx
  80239d:	89 e9                	mov    %ebp,%ecx
  80239f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023a3:	29 f0                	sub    %esi,%eax
  8023a5:	19 fa                	sbb    %edi,%edx
  8023a7:	d3 e8                	shr    %cl,%eax
  8023a9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8023ae:	89 d7                	mov    %edx,%edi
  8023b0:	d3 e7                	shl    %cl,%edi
  8023b2:	89 e9                	mov    %ebp,%ecx
  8023b4:	09 f8                	or     %edi,%eax
  8023b6:	d3 ea                	shr    %cl,%edx
  8023b8:	83 c4 20             	add    $0x20,%esp
  8023bb:	5e                   	pop    %esi
  8023bc:	5f                   	pop    %edi
  8023bd:	5d                   	pop    %ebp
  8023be:	c3                   	ret    
  8023bf:	90                   	nop
  8023c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8023c4:	29 f9                	sub    %edi,%ecx
  8023c6:	19 c6                	sbb    %eax,%esi
  8023c8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8023cc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8023d0:	e9 ff fe ff ff       	jmp    8022d4 <__umoddi3+0x74>
