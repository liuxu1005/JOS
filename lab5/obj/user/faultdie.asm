
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
  800045:	68 c0 1e 80 00       	push   $0x801ec0
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
  80006c:	e8 83 0c 00 00       	call   800cf4 <set_pgfault_handler>
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
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8000cc:	e8 83 0e 00 00       	call   800f54 <close_all>
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
  8001d6:	e8 35 1a 00 00       	call   801c10 <__udivdi3>
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
  800214:	e8 27 1b 00 00       	call   801d40 <__umoddi3>
  800219:	83 c4 14             	add    $0x14,%esp
  80021c:	0f be 80 e6 1e 80 00 	movsbl 0x801ee6(%eax),%eax
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
  800318:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
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
  8003dc:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8003e3:	85 d2                	test   %edx,%edx
  8003e5:	75 18                	jne    8003ff <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003e7:	50                   	push   %eax
  8003e8:	68 fe 1e 80 00       	push   $0x801efe
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
  800400:	68 61 23 80 00       	push   $0x802361
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
  80042d:	ba f7 1e 80 00       	mov    $0x801ef7,%edx
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
  800aac:	68 1f 22 80 00       	push   $0x80221f
  800ab1:	6a 23                	push   $0x23
  800ab3:	68 3c 22 80 00       	push   $0x80223c
  800ab8:	e8 d7 0f 00 00       	call   801a94 <_panic>

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
  800b2d:	68 1f 22 80 00       	push   $0x80221f
  800b32:	6a 23                	push   $0x23
  800b34:	68 3c 22 80 00       	push   $0x80223c
  800b39:	e8 56 0f 00 00       	call   801a94 <_panic>

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
  800b6f:	68 1f 22 80 00       	push   $0x80221f
  800b74:	6a 23                	push   $0x23
  800b76:	68 3c 22 80 00       	push   $0x80223c
  800b7b:	e8 14 0f 00 00       	call   801a94 <_panic>

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
  800bb1:	68 1f 22 80 00       	push   $0x80221f
  800bb6:	6a 23                	push   $0x23
  800bb8:	68 3c 22 80 00       	push   $0x80223c
  800bbd:	e8 d2 0e 00 00       	call   801a94 <_panic>

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
  800bf3:	68 1f 22 80 00       	push   $0x80221f
  800bf8:	6a 23                	push   $0x23
  800bfa:	68 3c 22 80 00       	push   $0x80223c
  800bff:	e8 90 0e 00 00       	call   801a94 <_panic>
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
  800c35:	68 1f 22 80 00       	push   $0x80221f
  800c3a:	6a 23                	push   $0x23
  800c3c:	68 3c 22 80 00       	push   $0x80223c
  800c41:	e8 4e 0e 00 00       	call   801a94 <_panic>

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
  800c77:	68 1f 22 80 00       	push   $0x80221f
  800c7c:	6a 23                	push   $0x23
  800c7e:	68 3c 22 80 00       	push   $0x80223c
  800c83:	e8 0c 0e 00 00       	call   801a94 <_panic>

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
  800cdb:	68 1f 22 80 00       	push   $0x80221f
  800ce0:	6a 23                	push   $0x23
  800ce2:	68 3c 22 80 00       	push   $0x80223c
  800ce7:	e8 a8 0d 00 00       	call   801a94 <_panic>

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

00800cf4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cfa:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d01:	75 2c                	jne    800d2f <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
              if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) != 0) 
  800d03:	83 ec 04             	sub    $0x4,%esp
  800d06:	6a 07                	push   $0x7
  800d08:	68 00 f0 bf ee       	push   $0xeebff000
  800d0d:	6a 00                	push   $0x0
  800d0f:	e8 ef fd ff ff       	call   800b03 <sys_page_alloc>
  800d14:	83 c4 10             	add    $0x10,%esp
  800d17:	85 c0                	test   %eax,%eax
  800d19:	74 14                	je     800d2f <set_pgfault_handler+0x3b>
                    panic("set_pgfault_handler:sys_page_alloc failed");
  800d1b:	83 ec 04             	sub    $0x4,%esp
  800d1e:	68 4c 22 80 00       	push   $0x80224c
  800d23:	6a 21                	push   $0x21
  800d25:	68 ae 22 80 00       	push   $0x8022ae
  800d2a:	e8 65 0d 00 00       	call   801a94 <_panic>
   
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	a3 08 40 80 00       	mov    %eax,0x804008
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800d37:	83 ec 08             	sub    $0x8,%esp
  800d3a:	68 63 0d 80 00       	push   $0x800d63
  800d3f:	6a 00                	push   $0x0
  800d41:	e8 08 ff ff ff       	call   800c4e <sys_env_set_pgfault_upcall>
  800d46:	83 c4 10             	add    $0x10,%esp
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	79 14                	jns    800d61 <set_pgfault_handler+0x6d>
                panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800d4d:	83 ec 04             	sub    $0x4,%esp
  800d50:	68 78 22 80 00       	push   $0x802278
  800d55:	6a 29                	push   $0x29
  800d57:	68 ae 22 80 00       	push   $0x8022ae
  800d5c:	e8 33 0d 00 00       	call   801a94 <_panic>
}
  800d61:	c9                   	leave  
  800d62:	c3                   	ret    

00800d63 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d63:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d64:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800d69:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d6b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        subl $0x4, 0x30(%esp)
  800d6e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        movl 0x30(%esp), %eax
  800d73:	8b 44 24 30          	mov    0x30(%esp),%eax
        movl 0x28(%esp), %edx
  800d77:	8b 54 24 28          	mov    0x28(%esp),%edx
        movl %edx, (%eax)
  800d7b:	89 10                	mov    %edx,(%eax)
        
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        addl $0x8, %esp
  800d7d:	83 c4 08             	add    $0x8,%esp
        popal
  800d80:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $0x4, %esp
  800d81:	83 c4 04             	add    $0x4,%esp
        popfl
  800d84:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        pop %esp
  800d85:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800d86:	c3                   	ret    

00800d87 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	05 00 00 00 30       	add    $0x30000000,%eax
  800d92:	c1 e8 0c             	shr    $0xc,%eax
}
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9d:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800da2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800da7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800db9:	89 c2                	mov    %eax,%edx
  800dbb:	c1 ea 16             	shr    $0x16,%edx
  800dbe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc5:	f6 c2 01             	test   $0x1,%dl
  800dc8:	74 11                	je     800ddb <fd_alloc+0x2d>
  800dca:	89 c2                	mov    %eax,%edx
  800dcc:	c1 ea 0c             	shr    $0xc,%edx
  800dcf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd6:	f6 c2 01             	test   $0x1,%dl
  800dd9:	75 09                	jne    800de4 <fd_alloc+0x36>
			*fd_store = fd;
  800ddb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ddd:	b8 00 00 00 00       	mov    $0x0,%eax
  800de2:	eb 17                	jmp    800dfb <fd_alloc+0x4d>
  800de4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800de9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dee:	75 c9                	jne    800db9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800df0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800df6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e03:	83 f8 1f             	cmp    $0x1f,%eax
  800e06:	77 36                	ja     800e3e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e08:	c1 e0 0c             	shl    $0xc,%eax
  800e0b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e10:	89 c2                	mov    %eax,%edx
  800e12:	c1 ea 16             	shr    $0x16,%edx
  800e15:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1c:	f6 c2 01             	test   $0x1,%dl
  800e1f:	74 24                	je     800e45 <fd_lookup+0x48>
  800e21:	89 c2                	mov    %eax,%edx
  800e23:	c1 ea 0c             	shr    $0xc,%edx
  800e26:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2d:	f6 c2 01             	test   $0x1,%dl
  800e30:	74 1a                	je     800e4c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e35:	89 02                	mov    %eax,(%edx)
	return 0;
  800e37:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3c:	eb 13                	jmp    800e51 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e43:	eb 0c                	jmp    800e51 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e4a:	eb 05                	jmp    800e51 <fd_lookup+0x54>
  800e4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	83 ec 08             	sub    $0x8,%esp
  800e59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5c:	ba 38 23 80 00       	mov    $0x802338,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e61:	eb 13                	jmp    800e76 <dev_lookup+0x23>
  800e63:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e66:	39 08                	cmp    %ecx,(%eax)
  800e68:	75 0c                	jne    800e76 <dev_lookup+0x23>
			*dev = devtab[i];
  800e6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e74:	eb 2e                	jmp    800ea4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e76:	8b 02                	mov    (%edx),%eax
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	75 e7                	jne    800e63 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e7c:	a1 04 40 80 00       	mov    0x804004,%eax
  800e81:	8b 40 48             	mov    0x48(%eax),%eax
  800e84:	83 ec 04             	sub    $0x4,%esp
  800e87:	51                   	push   %ecx
  800e88:	50                   	push   %eax
  800e89:	68 bc 22 80 00       	push   $0x8022bc
  800e8e:	e8 e0 f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e9c:	83 c4 10             	add    $0x10,%esp
  800e9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	56                   	push   %esi
  800eaa:	53                   	push   %ebx
  800eab:	83 ec 10             	sub    $0x10,%esp
  800eae:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb7:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ebe:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ec1:	50                   	push   %eax
  800ec2:	e8 36 ff ff ff       	call   800dfd <fd_lookup>
  800ec7:	83 c4 08             	add    $0x8,%esp
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	78 05                	js     800ed3 <fd_close+0x2d>
	    || fd != fd2)
  800ece:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ed1:	74 0c                	je     800edf <fd_close+0x39>
		return (must_exist ? r : 0);
  800ed3:	84 db                	test   %bl,%bl
  800ed5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eda:	0f 44 c2             	cmove  %edx,%eax
  800edd:	eb 41                	jmp    800f20 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800edf:	83 ec 08             	sub    $0x8,%esp
  800ee2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ee5:	50                   	push   %eax
  800ee6:	ff 36                	pushl  (%esi)
  800ee8:	e8 66 ff ff ff       	call   800e53 <dev_lookup>
  800eed:	89 c3                	mov    %eax,%ebx
  800eef:	83 c4 10             	add    $0x10,%esp
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	78 1a                	js     800f10 <fd_close+0x6a>
		if (dev->dev_close)
  800ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800efc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	74 0b                	je     800f10 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f05:	83 ec 0c             	sub    $0xc,%esp
  800f08:	56                   	push   %esi
  800f09:	ff d0                	call   *%eax
  800f0b:	89 c3                	mov    %eax,%ebx
  800f0d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f10:	83 ec 08             	sub    $0x8,%esp
  800f13:	56                   	push   %esi
  800f14:	6a 00                	push   $0x0
  800f16:	e8 6d fc ff ff       	call   800b88 <sys_page_unmap>
	return r;
  800f1b:	83 c4 10             	add    $0x10,%esp
  800f1e:	89 d8                	mov    %ebx,%eax
}
  800f20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f30:	50                   	push   %eax
  800f31:	ff 75 08             	pushl  0x8(%ebp)
  800f34:	e8 c4 fe ff ff       	call   800dfd <fd_lookup>
  800f39:	89 c2                	mov    %eax,%edx
  800f3b:	83 c4 08             	add    $0x8,%esp
  800f3e:	85 d2                	test   %edx,%edx
  800f40:	78 10                	js     800f52 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800f42:	83 ec 08             	sub    $0x8,%esp
  800f45:	6a 01                	push   $0x1
  800f47:	ff 75 f4             	pushl  -0xc(%ebp)
  800f4a:	e8 57 ff ff ff       	call   800ea6 <fd_close>
  800f4f:	83 c4 10             	add    $0x10,%esp
}
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <close_all>:

void
close_all(void)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	53                   	push   %ebx
  800f58:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f5b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f60:	83 ec 0c             	sub    $0xc,%esp
  800f63:	53                   	push   %ebx
  800f64:	e8 be ff ff ff       	call   800f27 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f69:	83 c3 01             	add    $0x1,%ebx
  800f6c:	83 c4 10             	add    $0x10,%esp
  800f6f:	83 fb 20             	cmp    $0x20,%ebx
  800f72:	75 ec                	jne    800f60 <close_all+0xc>
		close(i);
}
  800f74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f77:	c9                   	leave  
  800f78:	c3                   	ret    

00800f79 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	57                   	push   %edi
  800f7d:	56                   	push   %esi
  800f7e:	53                   	push   %ebx
  800f7f:	83 ec 2c             	sub    $0x2c,%esp
  800f82:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f85:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f88:	50                   	push   %eax
  800f89:	ff 75 08             	pushl  0x8(%ebp)
  800f8c:	e8 6c fe ff ff       	call   800dfd <fd_lookup>
  800f91:	89 c2                	mov    %eax,%edx
  800f93:	83 c4 08             	add    $0x8,%esp
  800f96:	85 d2                	test   %edx,%edx
  800f98:	0f 88 c1 00 00 00    	js     80105f <dup+0xe6>
		return r;
	close(newfdnum);
  800f9e:	83 ec 0c             	sub    $0xc,%esp
  800fa1:	56                   	push   %esi
  800fa2:	e8 80 ff ff ff       	call   800f27 <close>

	newfd = INDEX2FD(newfdnum);
  800fa7:	89 f3                	mov    %esi,%ebx
  800fa9:	c1 e3 0c             	shl    $0xc,%ebx
  800fac:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fb2:	83 c4 04             	add    $0x4,%esp
  800fb5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb8:	e8 da fd ff ff       	call   800d97 <fd2data>
  800fbd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fbf:	89 1c 24             	mov    %ebx,(%esp)
  800fc2:	e8 d0 fd ff ff       	call   800d97 <fd2data>
  800fc7:	83 c4 10             	add    $0x10,%esp
  800fca:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fcd:	89 f8                	mov    %edi,%eax
  800fcf:	c1 e8 16             	shr    $0x16,%eax
  800fd2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd9:	a8 01                	test   $0x1,%al
  800fdb:	74 37                	je     801014 <dup+0x9b>
  800fdd:	89 f8                	mov    %edi,%eax
  800fdf:	c1 e8 0c             	shr    $0xc,%eax
  800fe2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe9:	f6 c2 01             	test   $0x1,%dl
  800fec:	74 26                	je     801014 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	25 07 0e 00 00       	and    $0xe07,%eax
  800ffd:	50                   	push   %eax
  800ffe:	ff 75 d4             	pushl  -0x2c(%ebp)
  801001:	6a 00                	push   $0x0
  801003:	57                   	push   %edi
  801004:	6a 00                	push   $0x0
  801006:	e8 3b fb ff ff       	call   800b46 <sys_page_map>
  80100b:	89 c7                	mov    %eax,%edi
  80100d:	83 c4 20             	add    $0x20,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	78 2e                	js     801042 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801014:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801017:	89 d0                	mov    %edx,%eax
  801019:	c1 e8 0c             	shr    $0xc,%eax
  80101c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	25 07 0e 00 00       	and    $0xe07,%eax
  80102b:	50                   	push   %eax
  80102c:	53                   	push   %ebx
  80102d:	6a 00                	push   $0x0
  80102f:	52                   	push   %edx
  801030:	6a 00                	push   $0x0
  801032:	e8 0f fb ff ff       	call   800b46 <sys_page_map>
  801037:	89 c7                	mov    %eax,%edi
  801039:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80103c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80103e:	85 ff                	test   %edi,%edi
  801040:	79 1d                	jns    80105f <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801042:	83 ec 08             	sub    $0x8,%esp
  801045:	53                   	push   %ebx
  801046:	6a 00                	push   $0x0
  801048:	e8 3b fb ff ff       	call   800b88 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80104d:	83 c4 08             	add    $0x8,%esp
  801050:	ff 75 d4             	pushl  -0x2c(%ebp)
  801053:	6a 00                	push   $0x0
  801055:	e8 2e fb ff ff       	call   800b88 <sys_page_unmap>
	return r;
  80105a:	83 c4 10             	add    $0x10,%esp
  80105d:	89 f8                	mov    %edi,%eax
}
  80105f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801062:	5b                   	pop    %ebx
  801063:	5e                   	pop    %esi
  801064:	5f                   	pop    %edi
  801065:	5d                   	pop    %ebp
  801066:	c3                   	ret    

00801067 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	53                   	push   %ebx
  80106b:	83 ec 14             	sub    $0x14,%esp
  80106e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801071:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801074:	50                   	push   %eax
  801075:	53                   	push   %ebx
  801076:	e8 82 fd ff ff       	call   800dfd <fd_lookup>
  80107b:	83 c4 08             	add    $0x8,%esp
  80107e:	89 c2                	mov    %eax,%edx
  801080:	85 c0                	test   %eax,%eax
  801082:	78 6d                	js     8010f1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801084:	83 ec 08             	sub    $0x8,%esp
  801087:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80108a:	50                   	push   %eax
  80108b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80108e:	ff 30                	pushl  (%eax)
  801090:	e8 be fd ff ff       	call   800e53 <dev_lookup>
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	85 c0                	test   %eax,%eax
  80109a:	78 4c                	js     8010e8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80109c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80109f:	8b 42 08             	mov    0x8(%edx),%eax
  8010a2:	83 e0 03             	and    $0x3,%eax
  8010a5:	83 f8 01             	cmp    $0x1,%eax
  8010a8:	75 21                	jne    8010cb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8010af:	8b 40 48             	mov    0x48(%eax),%eax
  8010b2:	83 ec 04             	sub    $0x4,%esp
  8010b5:	53                   	push   %ebx
  8010b6:	50                   	push   %eax
  8010b7:	68 fd 22 80 00       	push   $0x8022fd
  8010bc:	e8 b2 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010c9:	eb 26                	jmp    8010f1 <read+0x8a>
	}
	if (!dev->dev_read)
  8010cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ce:	8b 40 08             	mov    0x8(%eax),%eax
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	74 17                	je     8010ec <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010d5:	83 ec 04             	sub    $0x4,%esp
  8010d8:	ff 75 10             	pushl  0x10(%ebp)
  8010db:	ff 75 0c             	pushl  0xc(%ebp)
  8010de:	52                   	push   %edx
  8010df:	ff d0                	call   *%eax
  8010e1:	89 c2                	mov    %eax,%edx
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	eb 09                	jmp    8010f1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e8:	89 c2                	mov    %eax,%edx
  8010ea:	eb 05                	jmp    8010f1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010f1:	89 d0                	mov    %edx,%eax
  8010f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f6:	c9                   	leave  
  8010f7:	c3                   	ret    

008010f8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	53                   	push   %ebx
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	8b 7d 08             	mov    0x8(%ebp),%edi
  801104:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801107:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110c:	eb 21                	jmp    80112f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80110e:	83 ec 04             	sub    $0x4,%esp
  801111:	89 f0                	mov    %esi,%eax
  801113:	29 d8                	sub    %ebx,%eax
  801115:	50                   	push   %eax
  801116:	89 d8                	mov    %ebx,%eax
  801118:	03 45 0c             	add    0xc(%ebp),%eax
  80111b:	50                   	push   %eax
  80111c:	57                   	push   %edi
  80111d:	e8 45 ff ff ff       	call   801067 <read>
		if (m < 0)
  801122:	83 c4 10             	add    $0x10,%esp
  801125:	85 c0                	test   %eax,%eax
  801127:	78 0c                	js     801135 <readn+0x3d>
			return m;
		if (m == 0)
  801129:	85 c0                	test   %eax,%eax
  80112b:	74 06                	je     801133 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80112d:	01 c3                	add    %eax,%ebx
  80112f:	39 f3                	cmp    %esi,%ebx
  801131:	72 db                	jb     80110e <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801133:	89 d8                	mov    %ebx,%eax
}
  801135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5f                   	pop    %edi
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	53                   	push   %ebx
  801141:	83 ec 14             	sub    $0x14,%esp
  801144:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801147:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114a:	50                   	push   %eax
  80114b:	53                   	push   %ebx
  80114c:	e8 ac fc ff ff       	call   800dfd <fd_lookup>
  801151:	83 c4 08             	add    $0x8,%esp
  801154:	89 c2                	mov    %eax,%edx
  801156:	85 c0                	test   %eax,%eax
  801158:	78 68                	js     8011c2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115a:	83 ec 08             	sub    $0x8,%esp
  80115d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801160:	50                   	push   %eax
  801161:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801164:	ff 30                	pushl  (%eax)
  801166:	e8 e8 fc ff ff       	call   800e53 <dev_lookup>
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	78 47                	js     8011b9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801172:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801175:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801179:	75 21                	jne    80119c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80117b:	a1 04 40 80 00       	mov    0x804004,%eax
  801180:	8b 40 48             	mov    0x48(%eax),%eax
  801183:	83 ec 04             	sub    $0x4,%esp
  801186:	53                   	push   %ebx
  801187:	50                   	push   %eax
  801188:	68 19 23 80 00       	push   $0x802319
  80118d:	e8 e1 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80119a:	eb 26                	jmp    8011c2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80119c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80119f:	8b 52 0c             	mov    0xc(%edx),%edx
  8011a2:	85 d2                	test   %edx,%edx
  8011a4:	74 17                	je     8011bd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011a6:	83 ec 04             	sub    $0x4,%esp
  8011a9:	ff 75 10             	pushl  0x10(%ebp)
  8011ac:	ff 75 0c             	pushl  0xc(%ebp)
  8011af:	50                   	push   %eax
  8011b0:	ff d2                	call   *%edx
  8011b2:	89 c2                	mov    %eax,%edx
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	eb 09                	jmp    8011c2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b9:	89 c2                	mov    %eax,%edx
  8011bb:	eb 05                	jmp    8011c2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011c2:	89 d0                	mov    %edx,%eax
  8011c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c7:	c9                   	leave  
  8011c8:	c3                   	ret    

008011c9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011cf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011d2:	50                   	push   %eax
  8011d3:	ff 75 08             	pushl  0x8(%ebp)
  8011d6:	e8 22 fc ff ff       	call   800dfd <fd_lookup>
  8011db:	83 c4 08             	add    $0x8,%esp
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	78 0e                	js     8011f0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011f0:	c9                   	leave  
  8011f1:	c3                   	ret    

008011f2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	53                   	push   %ebx
  8011f6:	83 ec 14             	sub    $0x14,%esp
  8011f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ff:	50                   	push   %eax
  801200:	53                   	push   %ebx
  801201:	e8 f7 fb ff ff       	call   800dfd <fd_lookup>
  801206:	83 c4 08             	add    $0x8,%esp
  801209:	89 c2                	mov    %eax,%edx
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 65                	js     801274 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120f:	83 ec 08             	sub    $0x8,%esp
  801212:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801219:	ff 30                	pushl  (%eax)
  80121b:	e8 33 fc ff ff       	call   800e53 <dev_lookup>
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	78 44                	js     80126b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801227:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80122e:	75 21                	jne    801251 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801230:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801235:	8b 40 48             	mov    0x48(%eax),%eax
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	53                   	push   %ebx
  80123c:	50                   	push   %eax
  80123d:	68 dc 22 80 00       	push   $0x8022dc
  801242:	e8 2c ef ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124f:	eb 23                	jmp    801274 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801251:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801254:	8b 52 18             	mov    0x18(%edx),%edx
  801257:	85 d2                	test   %edx,%edx
  801259:	74 14                	je     80126f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80125b:	83 ec 08             	sub    $0x8,%esp
  80125e:	ff 75 0c             	pushl  0xc(%ebp)
  801261:	50                   	push   %eax
  801262:	ff d2                	call   *%edx
  801264:	89 c2                	mov    %eax,%edx
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	eb 09                	jmp    801274 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126b:	89 c2                	mov    %eax,%edx
  80126d:	eb 05                	jmp    801274 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80126f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801274:	89 d0                	mov    %edx,%eax
  801276:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801279:	c9                   	leave  
  80127a:	c3                   	ret    

0080127b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	53                   	push   %ebx
  80127f:	83 ec 14             	sub    $0x14,%esp
  801282:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801285:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801288:	50                   	push   %eax
  801289:	ff 75 08             	pushl  0x8(%ebp)
  80128c:	e8 6c fb ff ff       	call   800dfd <fd_lookup>
  801291:	83 c4 08             	add    $0x8,%esp
  801294:	89 c2                	mov    %eax,%edx
  801296:	85 c0                	test   %eax,%eax
  801298:	78 58                	js     8012f2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129a:	83 ec 08             	sub    $0x8,%esp
  80129d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a0:	50                   	push   %eax
  8012a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a4:	ff 30                	pushl  (%eax)
  8012a6:	e8 a8 fb ff ff       	call   800e53 <dev_lookup>
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	78 37                	js     8012e9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012b9:	74 32                	je     8012ed <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012bb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012be:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012c5:	00 00 00 
	stat->st_isdir = 0;
  8012c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012cf:	00 00 00 
	stat->st_dev = dev;
  8012d2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012d8:	83 ec 08             	sub    $0x8,%esp
  8012db:	53                   	push   %ebx
  8012dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8012df:	ff 50 14             	call   *0x14(%eax)
  8012e2:	89 c2                	mov    %eax,%edx
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	eb 09                	jmp    8012f2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	eb 05                	jmp    8012f2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012f2:	89 d0                	mov    %edx,%eax
  8012f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f7:	c9                   	leave  
  8012f8:	c3                   	ret    

008012f9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	56                   	push   %esi
  8012fd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	6a 00                	push   $0x0
  801303:	ff 75 08             	pushl  0x8(%ebp)
  801306:	e8 09 02 00 00       	call   801514 <open>
  80130b:	89 c3                	mov    %eax,%ebx
  80130d:	83 c4 10             	add    $0x10,%esp
  801310:	85 db                	test   %ebx,%ebx
  801312:	78 1b                	js     80132f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	ff 75 0c             	pushl  0xc(%ebp)
  80131a:	53                   	push   %ebx
  80131b:	e8 5b ff ff ff       	call   80127b <fstat>
  801320:	89 c6                	mov    %eax,%esi
	close(fd);
  801322:	89 1c 24             	mov    %ebx,(%esp)
  801325:	e8 fd fb ff ff       	call   800f27 <close>
	return r;
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	89 f0                	mov    %esi,%eax
}
  80132f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801332:	5b                   	pop    %ebx
  801333:	5e                   	pop    %esi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    

00801336 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	56                   	push   %esi
  80133a:	53                   	push   %ebx
  80133b:	89 c6                	mov    %eax,%esi
  80133d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80133f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801346:	75 12                	jne    80135a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801348:	83 ec 0c             	sub    $0xc,%esp
  80134b:	6a 01                	push   $0x1
  80134d:	e8 45 08 00 00       	call   801b97 <ipc_find_env>
  801352:	a3 00 40 80 00       	mov    %eax,0x804000
  801357:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80135a:	6a 07                	push   $0x7
  80135c:	68 00 50 80 00       	push   $0x805000
  801361:	56                   	push   %esi
  801362:	ff 35 00 40 80 00    	pushl  0x804000
  801368:	e8 d6 07 00 00       	call   801b43 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80136d:	83 c4 0c             	add    $0xc,%esp
  801370:	6a 00                	push   $0x0
  801372:	53                   	push   %ebx
  801373:	6a 00                	push   $0x0
  801375:	e8 60 07 00 00       	call   801ada <ipc_recv>
}
  80137a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5e                   	pop    %esi
  80137f:	5d                   	pop    %ebp
  801380:	c3                   	ret    

00801381 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801387:	8b 45 08             	mov    0x8(%ebp),%eax
  80138a:	8b 40 0c             	mov    0xc(%eax),%eax
  80138d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801392:	8b 45 0c             	mov    0xc(%ebp),%eax
  801395:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80139a:	ba 00 00 00 00       	mov    $0x0,%edx
  80139f:	b8 02 00 00 00       	mov    $0x2,%eax
  8013a4:	e8 8d ff ff ff       	call   801336 <fsipc>
}
  8013a9:	c9                   	leave  
  8013aa:	c3                   	ret    

008013ab <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c1:	b8 06 00 00 00       	mov    $0x6,%eax
  8013c6:	e8 6b ff ff ff       	call   801336 <fsipc>
}
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <devfile_stat>:
        return src_buf - buf;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 04             	sub    $0x4,%esp
  8013d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013da:	8b 40 0c             	mov    0xc(%eax),%eax
  8013dd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8013ec:	e8 45 ff ff ff       	call   801336 <fsipc>
  8013f1:	89 c2                	mov    %eax,%edx
  8013f3:	85 d2                	test   %edx,%edx
  8013f5:	78 2c                	js     801423 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	68 00 50 80 00       	push   $0x805000
  8013ff:	53                   	push   %ebx
  801400:	e8 f5 f2 ff ff       	call   8006fa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801405:	a1 80 50 80 00       	mov    0x805080,%eax
  80140a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801410:	a1 84 50 80 00       	mov    0x805084,%eax
  801415:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80141b:	83 c4 10             	add    $0x10,%esp
  80141e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801423:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801426:	c9                   	leave  
  801427:	c3                   	ret    

00801428 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	57                   	push   %edi
  80142c:	56                   	push   %esi
  80142d:	53                   	push   %ebx
  80142e:	83 ec 0c             	sub    $0xc,%esp
  801431:	8b 75 10             	mov    0x10(%ebp),%esi
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
  801434:	8b 45 08             	mov    0x8(%ebp),%eax
  801437:	8b 40 0c             	mov    0xc(%eax),%eax
  80143a:	a3 00 50 80 00       	mov    %eax,0x805000
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//panic("devfile_write not implemented");
        int r;
        const void *src_buf = buf;
  80143f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801442:	eb 3d                	jmp    801481 <devfile_write+0x59>
                size_t tmp = MIN(ipc_buf_size, n);
  801444:	81 fe f8 0f 00 00    	cmp    $0xff8,%esi
  80144a:	bf f8 0f 00 00       	mov    $0xff8,%edi
  80144f:	0f 46 fe             	cmovbe %esi,%edi
                memmove(fsipcbuf.write.req_buf, src_buf, tmp);
  801452:	83 ec 04             	sub    $0x4,%esp
  801455:	57                   	push   %edi
  801456:	53                   	push   %ebx
  801457:	68 08 50 80 00       	push   $0x805008
  80145c:	e8 2b f4 ff ff       	call   80088c <memmove>
                fsipcbuf.write.req_n = tmp; 
  801461:	89 3d 04 50 80 00    	mov    %edi,0x805004
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801467:	ba 00 00 00 00       	mov    $0x0,%edx
  80146c:	b8 04 00 00 00       	mov    $0x4,%eax
  801471:	e8 c0 fe ff ff       	call   801336 <fsipc>
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	85 c0                	test   %eax,%eax
  80147b:	78 0d                	js     80148a <devfile_write+0x62>
		        return r;
                n -= tmp;
  80147d:	29 fe                	sub    %edi,%esi
                src_buf += tmp;
  80147f:	01 fb                	add    %edi,%ebx
        int r;
        const void *src_buf = buf;
        size_t ipc_buf_size = PGSIZE - (sizeof(int) + sizeof(size_t));
 
        fsipcbuf.write.req_fileid = fd->fd_file.id;       
        while( n > 0) {
  801481:	85 f6                	test   %esi,%esi
  801483:	75 bf                	jne    801444 <devfile_write+0x1c>
                if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
		        return r;
                n -= tmp;
                src_buf += tmp;
        } 
        return src_buf - buf;
  801485:	89 d8                	mov    %ebx,%eax
  801487:	2b 45 0c             	sub    0xc(%ebp),%eax
}
  80148a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148d:	5b                   	pop    %ebx
  80148e:	5e                   	pop    %esi
  80148f:	5f                   	pop    %edi
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	56                   	push   %esi
  801496:	53                   	push   %ebx
  801497:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80149a:	8b 45 08             	mov    0x8(%ebp),%eax
  80149d:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014a5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b0:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b5:	e8 7c fe ff ff       	call   801336 <fsipc>
  8014ba:	89 c3                	mov    %eax,%ebx
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 4b                	js     80150b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014c0:	39 c6                	cmp    %eax,%esi
  8014c2:	73 16                	jae    8014da <devfile_read+0x48>
  8014c4:	68 48 23 80 00       	push   $0x802348
  8014c9:	68 4f 23 80 00       	push   $0x80234f
  8014ce:	6a 7c                	push   $0x7c
  8014d0:	68 64 23 80 00       	push   $0x802364
  8014d5:	e8 ba 05 00 00       	call   801a94 <_panic>
	assert(r <= PGSIZE);
  8014da:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014df:	7e 16                	jle    8014f7 <devfile_read+0x65>
  8014e1:	68 6f 23 80 00       	push   $0x80236f
  8014e6:	68 4f 23 80 00       	push   $0x80234f
  8014eb:	6a 7d                	push   $0x7d
  8014ed:	68 64 23 80 00       	push   $0x802364
  8014f2:	e8 9d 05 00 00       	call   801a94 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014f7:	83 ec 04             	sub    $0x4,%esp
  8014fa:	50                   	push   %eax
  8014fb:	68 00 50 80 00       	push   $0x805000
  801500:	ff 75 0c             	pushl  0xc(%ebp)
  801503:	e8 84 f3 ff ff       	call   80088c <memmove>
	return r;
  801508:	83 c4 10             	add    $0x10,%esp
}
  80150b:	89 d8                	mov    %ebx,%eax
  80150d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5d                   	pop    %ebp
  801513:	c3                   	ret    

00801514 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	53                   	push   %ebx
  801518:	83 ec 20             	sub    $0x20,%esp
  80151b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80151e:	53                   	push   %ebx
  80151f:	e8 9d f1 ff ff       	call   8006c1 <strlen>
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80152c:	7f 67                	jg     801595 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80152e:	83 ec 0c             	sub    $0xc,%esp
  801531:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	e8 74 f8 ff ff       	call   800dae <fd_alloc>
  80153a:	83 c4 10             	add    $0x10,%esp
		return r;
  80153d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 57                	js     80159a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	53                   	push   %ebx
  801547:	68 00 50 80 00       	push   $0x805000
  80154c:	e8 a9 f1 ff ff       	call   8006fa <strcpy>
	fsipcbuf.open.req_omode = mode;
  801551:	8b 45 0c             	mov    0xc(%ebp),%eax
  801554:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801559:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155c:	b8 01 00 00 00       	mov    $0x1,%eax
  801561:	e8 d0 fd ff ff       	call   801336 <fsipc>
  801566:	89 c3                	mov    %eax,%ebx
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	79 14                	jns    801583 <open+0x6f>
		fd_close(fd, 0);
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	6a 00                	push   $0x0
  801574:	ff 75 f4             	pushl  -0xc(%ebp)
  801577:	e8 2a f9 ff ff       	call   800ea6 <fd_close>
		return r;
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	89 da                	mov    %ebx,%edx
  801581:	eb 17                	jmp    80159a <open+0x86>
	}

	return fd2num(fd);
  801583:	83 ec 0c             	sub    $0xc,%esp
  801586:	ff 75 f4             	pushl  -0xc(%ebp)
  801589:	e8 f9 f7 ff ff       	call   800d87 <fd2num>
  80158e:	89 c2                	mov    %eax,%edx
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	eb 05                	jmp    80159a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801595:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80159a:	89 d0                	mov    %edx,%eax
  80159c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8015b1:	e8 80 fd ff ff       	call   801336 <fsipc>
}
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	56                   	push   %esi
  8015bc:	53                   	push   %ebx
  8015bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015c0:	83 ec 0c             	sub    $0xc,%esp
  8015c3:	ff 75 08             	pushl  0x8(%ebp)
  8015c6:	e8 cc f7 ff ff       	call   800d97 <fd2data>
  8015cb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015cd:	83 c4 08             	add    $0x8,%esp
  8015d0:	68 7b 23 80 00       	push   $0x80237b
  8015d5:	53                   	push   %ebx
  8015d6:	e8 1f f1 ff ff       	call   8006fa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015db:	8b 56 04             	mov    0x4(%esi),%edx
  8015de:	89 d0                	mov    %edx,%eax
  8015e0:	2b 06                	sub    (%esi),%eax
  8015e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015e8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ef:	00 00 00 
	stat->st_dev = &devpipe;
  8015f2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015f9:	30 80 00 
	return 0;
}
  8015fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801601:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801604:	5b                   	pop    %ebx
  801605:	5e                   	pop    %esi
  801606:	5d                   	pop    %ebp
  801607:	c3                   	ret    

00801608 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	53                   	push   %ebx
  80160c:	83 ec 0c             	sub    $0xc,%esp
  80160f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801612:	53                   	push   %ebx
  801613:	6a 00                	push   $0x0
  801615:	e8 6e f5 ff ff       	call   800b88 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80161a:	89 1c 24             	mov    %ebx,(%esp)
  80161d:	e8 75 f7 ff ff       	call   800d97 <fd2data>
  801622:	83 c4 08             	add    $0x8,%esp
  801625:	50                   	push   %eax
  801626:	6a 00                	push   $0x0
  801628:	e8 5b f5 ff ff       	call   800b88 <sys_page_unmap>
}
  80162d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	57                   	push   %edi
  801636:	56                   	push   %esi
  801637:	53                   	push   %ebx
  801638:	83 ec 1c             	sub    $0x1c,%esp
  80163b:	89 c6                	mov    %eax,%esi
  80163d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801640:	a1 04 40 80 00       	mov    0x804004,%eax
  801645:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	56                   	push   %esi
  80164c:	e8 7e 05 00 00       	call   801bcf <pageref>
  801651:	89 c7                	mov    %eax,%edi
  801653:	83 c4 04             	add    $0x4,%esp
  801656:	ff 75 e4             	pushl  -0x1c(%ebp)
  801659:	e8 71 05 00 00       	call   801bcf <pageref>
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	39 c7                	cmp    %eax,%edi
  801663:	0f 94 c2             	sete   %dl
  801666:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801669:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  80166f:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801672:	39 fb                	cmp    %edi,%ebx
  801674:	74 19                	je     80168f <_pipeisclosed+0x5d>
			return ret;
		if (n != nn && ret == 1)
  801676:	84 d2                	test   %dl,%dl
  801678:	74 c6                	je     801640 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80167a:	8b 51 58             	mov    0x58(%ecx),%edx
  80167d:	50                   	push   %eax
  80167e:	52                   	push   %edx
  80167f:	53                   	push   %ebx
  801680:	68 82 23 80 00       	push   $0x802382
  801685:	e8 e9 ea ff ff       	call   800173 <cprintf>
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	eb b1                	jmp    801640 <_pipeisclosed+0xe>
	}
}
  80168f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801692:	5b                   	pop    %ebx
  801693:	5e                   	pop    %esi
  801694:	5f                   	pop    %edi
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	57                   	push   %edi
  80169b:	56                   	push   %esi
  80169c:	53                   	push   %ebx
  80169d:	83 ec 28             	sub    $0x28,%esp
  8016a0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016a3:	56                   	push   %esi
  8016a4:	e8 ee f6 ff ff       	call   800d97 <fd2data>
  8016a9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ab:	83 c4 10             	add    $0x10,%esp
  8016ae:	bf 00 00 00 00       	mov    $0x0,%edi
  8016b3:	eb 4b                	jmp    801700 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016b5:	89 da                	mov    %ebx,%edx
  8016b7:	89 f0                	mov    %esi,%eax
  8016b9:	e8 74 ff ff ff       	call   801632 <_pipeisclosed>
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	75 48                	jne    80170a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016c2:	e8 1d f4 ff ff       	call   800ae4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016c7:	8b 43 04             	mov    0x4(%ebx),%eax
  8016ca:	8b 0b                	mov    (%ebx),%ecx
  8016cc:	8d 51 20             	lea    0x20(%ecx),%edx
  8016cf:	39 d0                	cmp    %edx,%eax
  8016d1:	73 e2                	jae    8016b5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016da:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016dd:	89 c2                	mov    %eax,%edx
  8016df:	c1 fa 1f             	sar    $0x1f,%edx
  8016e2:	89 d1                	mov    %edx,%ecx
  8016e4:	c1 e9 1b             	shr    $0x1b,%ecx
  8016e7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016ea:	83 e2 1f             	and    $0x1f,%edx
  8016ed:	29 ca                	sub    %ecx,%edx
  8016ef:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016f3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016f7:	83 c0 01             	add    $0x1,%eax
  8016fa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016fd:	83 c7 01             	add    $0x1,%edi
  801700:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801703:	75 c2                	jne    8016c7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801705:	8b 45 10             	mov    0x10(%ebp),%eax
  801708:	eb 05                	jmp    80170f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80170a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80170f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801712:	5b                   	pop    %ebx
  801713:	5e                   	pop    %esi
  801714:	5f                   	pop    %edi
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	57                   	push   %edi
  80171b:	56                   	push   %esi
  80171c:	53                   	push   %ebx
  80171d:	83 ec 18             	sub    $0x18,%esp
  801720:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801723:	57                   	push   %edi
  801724:	e8 6e f6 ff ff       	call   800d97 <fd2data>
  801729:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801733:	eb 3d                	jmp    801772 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801735:	85 db                	test   %ebx,%ebx
  801737:	74 04                	je     80173d <devpipe_read+0x26>
				return i;
  801739:	89 d8                	mov    %ebx,%eax
  80173b:	eb 44                	jmp    801781 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80173d:	89 f2                	mov    %esi,%edx
  80173f:	89 f8                	mov    %edi,%eax
  801741:	e8 ec fe ff ff       	call   801632 <_pipeisclosed>
  801746:	85 c0                	test   %eax,%eax
  801748:	75 32                	jne    80177c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80174a:	e8 95 f3 ff ff       	call   800ae4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80174f:	8b 06                	mov    (%esi),%eax
  801751:	3b 46 04             	cmp    0x4(%esi),%eax
  801754:	74 df                	je     801735 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801756:	99                   	cltd   
  801757:	c1 ea 1b             	shr    $0x1b,%edx
  80175a:	01 d0                	add    %edx,%eax
  80175c:	83 e0 1f             	and    $0x1f,%eax
  80175f:	29 d0                	sub    %edx,%eax
  801761:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801769:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80176c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80176f:	83 c3 01             	add    $0x1,%ebx
  801772:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801775:	75 d8                	jne    80174f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801777:	8b 45 10             	mov    0x10(%ebp),%eax
  80177a:	eb 05                	jmp    801781 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80177c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801781:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801784:	5b                   	pop    %ebx
  801785:	5e                   	pop    %esi
  801786:	5f                   	pop    %edi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	56                   	push   %esi
  80178d:	53                   	push   %ebx
  80178e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801791:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801794:	50                   	push   %eax
  801795:	e8 14 f6 ff ff       	call   800dae <fd_alloc>
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	89 c2                	mov    %eax,%edx
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	0f 88 2c 01 00 00    	js     8018d3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a7:	83 ec 04             	sub    $0x4,%esp
  8017aa:	68 07 04 00 00       	push   $0x407
  8017af:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b2:	6a 00                	push   $0x0
  8017b4:	e8 4a f3 ff ff       	call   800b03 <sys_page_alloc>
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	89 c2                	mov    %eax,%edx
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	0f 88 0d 01 00 00    	js     8018d3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017c6:	83 ec 0c             	sub    $0xc,%esp
  8017c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017cc:	50                   	push   %eax
  8017cd:	e8 dc f5 ff ff       	call   800dae <fd_alloc>
  8017d2:	89 c3                	mov    %eax,%ebx
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	0f 88 e2 00 00 00    	js     8018c1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017df:	83 ec 04             	sub    $0x4,%esp
  8017e2:	68 07 04 00 00       	push   $0x407
  8017e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ea:	6a 00                	push   $0x0
  8017ec:	e8 12 f3 ff ff       	call   800b03 <sys_page_alloc>
  8017f1:	89 c3                	mov    %eax,%ebx
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	0f 88 c3 00 00 00    	js     8018c1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017fe:	83 ec 0c             	sub    $0xc,%esp
  801801:	ff 75 f4             	pushl  -0xc(%ebp)
  801804:	e8 8e f5 ff ff       	call   800d97 <fd2data>
  801809:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180b:	83 c4 0c             	add    $0xc,%esp
  80180e:	68 07 04 00 00       	push   $0x407
  801813:	50                   	push   %eax
  801814:	6a 00                	push   $0x0
  801816:	e8 e8 f2 ff ff       	call   800b03 <sys_page_alloc>
  80181b:	89 c3                	mov    %eax,%ebx
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	85 c0                	test   %eax,%eax
  801822:	0f 88 89 00 00 00    	js     8018b1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801828:	83 ec 0c             	sub    $0xc,%esp
  80182b:	ff 75 f0             	pushl  -0x10(%ebp)
  80182e:	e8 64 f5 ff ff       	call   800d97 <fd2data>
  801833:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80183a:	50                   	push   %eax
  80183b:	6a 00                	push   $0x0
  80183d:	56                   	push   %esi
  80183e:	6a 00                	push   $0x0
  801840:	e8 01 f3 ff ff       	call   800b46 <sys_page_map>
  801845:	89 c3                	mov    %eax,%ebx
  801847:	83 c4 20             	add    $0x20,%esp
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 55                	js     8018a3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80184e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801854:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801857:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801859:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801863:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80186e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801871:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801878:	83 ec 0c             	sub    $0xc,%esp
  80187b:	ff 75 f4             	pushl  -0xc(%ebp)
  80187e:	e8 04 f5 ff ff       	call   800d87 <fd2num>
  801883:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801886:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801888:	83 c4 04             	add    $0x4,%esp
  80188b:	ff 75 f0             	pushl  -0x10(%ebp)
  80188e:	e8 f4 f4 ff ff       	call   800d87 <fd2num>
  801893:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801896:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a1:	eb 30                	jmp    8018d3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018a3:	83 ec 08             	sub    $0x8,%esp
  8018a6:	56                   	push   %esi
  8018a7:	6a 00                	push   $0x0
  8018a9:	e8 da f2 ff ff       	call   800b88 <sys_page_unmap>
  8018ae:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018b1:	83 ec 08             	sub    $0x8,%esp
  8018b4:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b7:	6a 00                	push   $0x0
  8018b9:	e8 ca f2 ff ff       	call   800b88 <sys_page_unmap>
  8018be:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018c1:	83 ec 08             	sub    $0x8,%esp
  8018c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c7:	6a 00                	push   $0x0
  8018c9:	e8 ba f2 ff ff       	call   800b88 <sys_page_unmap>
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018d3:	89 d0                	mov    %edx,%eax
  8018d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5e                   	pop    %esi
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    

008018dc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e5:	50                   	push   %eax
  8018e6:	ff 75 08             	pushl  0x8(%ebp)
  8018e9:	e8 0f f5 ff ff       	call   800dfd <fd_lookup>
  8018ee:	89 c2                	mov    %eax,%edx
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	85 d2                	test   %edx,%edx
  8018f5:	78 18                	js     80190f <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018f7:	83 ec 0c             	sub    $0xc,%esp
  8018fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fd:	e8 95 f4 ff ff       	call   800d97 <fd2data>
	return _pipeisclosed(fd, p);
  801902:	89 c2                	mov    %eax,%edx
  801904:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801907:	e8 26 fd ff ff       	call   801632 <_pipeisclosed>
  80190c:	83 c4 10             	add    $0x10,%esp
}
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801914:	b8 00 00 00 00       	mov    $0x0,%eax
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    

0080191b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801921:	68 9a 23 80 00       	push   $0x80239a
  801926:	ff 75 0c             	pushl  0xc(%ebp)
  801929:	e8 cc ed ff ff       	call   8006fa <strcpy>
	return 0;
}
  80192e:	b8 00 00 00 00       	mov    $0x0,%eax
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	57                   	push   %edi
  801939:	56                   	push   %esi
  80193a:	53                   	push   %ebx
  80193b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801941:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801946:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80194c:	eb 2d                	jmp    80197b <devcons_write+0x46>
		m = n - tot;
  80194e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801951:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801953:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801956:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80195b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80195e:	83 ec 04             	sub    $0x4,%esp
  801961:	53                   	push   %ebx
  801962:	03 45 0c             	add    0xc(%ebp),%eax
  801965:	50                   	push   %eax
  801966:	57                   	push   %edi
  801967:	e8 20 ef ff ff       	call   80088c <memmove>
		sys_cputs(buf, m);
  80196c:	83 c4 08             	add    $0x8,%esp
  80196f:	53                   	push   %ebx
  801970:	57                   	push   %edi
  801971:	e8 d1 f0 ff ff       	call   800a47 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801976:	01 de                	add    %ebx,%esi
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	89 f0                	mov    %esi,%eax
  80197d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801980:	72 cc                	jb     80194e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801982:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801985:	5b                   	pop    %ebx
  801986:	5e                   	pop    %esi
  801987:	5f                   	pop    %edi
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801990:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801995:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801999:	75 07                	jne    8019a2 <devcons_read+0x18>
  80199b:	eb 28                	jmp    8019c5 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80199d:	e8 42 f1 ff ff       	call   800ae4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019a2:	e8 be f0 ff ff       	call   800a65 <sys_cgetc>
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	74 f2                	je     80199d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	78 16                	js     8019c5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019af:	83 f8 04             	cmp    $0x4,%eax
  8019b2:	74 0c                	je     8019c0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b7:	88 02                	mov    %al,(%edx)
	return 1;
  8019b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8019be:	eb 05                	jmp    8019c5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019c0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019c5:	c9                   	leave  
  8019c6:	c3                   	ret    

008019c7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019d3:	6a 01                	push   $0x1
  8019d5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019d8:	50                   	push   %eax
  8019d9:	e8 69 f0 ff ff       	call   800a47 <sys_cputs>
  8019de:	83 c4 10             	add    $0x10,%esp
}
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <getchar>:

int
getchar(void)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019e9:	6a 01                	push   $0x1
  8019eb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019ee:	50                   	push   %eax
  8019ef:	6a 00                	push   $0x0
  8019f1:	e8 71 f6 ff ff       	call   801067 <read>
	if (r < 0)
  8019f6:	83 c4 10             	add    $0x10,%esp
  8019f9:	85 c0                	test   %eax,%eax
  8019fb:	78 0f                	js     801a0c <getchar+0x29>
		return r;
	if (r < 1)
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	7e 06                	jle    801a07 <getchar+0x24>
		return -E_EOF;
	return c;
  801a01:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a05:	eb 05                	jmp    801a0c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a07:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a0c:	c9                   	leave  
  801a0d:	c3                   	ret    

00801a0e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a17:	50                   	push   %eax
  801a18:	ff 75 08             	pushl  0x8(%ebp)
  801a1b:	e8 dd f3 ff ff       	call   800dfd <fd_lookup>
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	85 c0                	test   %eax,%eax
  801a25:	78 11                	js     801a38 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a30:	39 10                	cmp    %edx,(%eax)
  801a32:	0f 94 c0             	sete   %al
  801a35:	0f b6 c0             	movzbl %al,%eax
}
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    

00801a3a <opencons>:

int
opencons(void)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a43:	50                   	push   %eax
  801a44:	e8 65 f3 ff ff       	call   800dae <fd_alloc>
  801a49:	83 c4 10             	add    $0x10,%esp
		return r;
  801a4c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	78 3e                	js     801a90 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a52:	83 ec 04             	sub    $0x4,%esp
  801a55:	68 07 04 00 00       	push   $0x407
  801a5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5d:	6a 00                	push   $0x0
  801a5f:	e8 9f f0 ff ff       	call   800b03 <sys_page_alloc>
  801a64:	83 c4 10             	add    $0x10,%esp
		return r;
  801a67:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 23                	js     801a90 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a6d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a76:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	50                   	push   %eax
  801a86:	e8 fc f2 ff ff       	call   800d87 <fd2num>
  801a8b:	89 c2                	mov    %eax,%edx
  801a8d:	83 c4 10             	add    $0x10,%esp
}
  801a90:	89 d0                	mov    %edx,%eax
  801a92:	c9                   	leave  
  801a93:	c3                   	ret    

00801a94 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	56                   	push   %esi
  801a98:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a99:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a9c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801aa2:	e8 1e f0 ff ff       	call   800ac5 <sys_getenvid>
  801aa7:	83 ec 0c             	sub    $0xc,%esp
  801aaa:	ff 75 0c             	pushl  0xc(%ebp)
  801aad:	ff 75 08             	pushl  0x8(%ebp)
  801ab0:	56                   	push   %esi
  801ab1:	50                   	push   %eax
  801ab2:	68 a8 23 80 00       	push   $0x8023a8
  801ab7:	e8 b7 e6 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801abc:	83 c4 18             	add    $0x18,%esp
  801abf:	53                   	push   %ebx
  801ac0:	ff 75 10             	pushl  0x10(%ebp)
  801ac3:	e8 5a e6 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801ac8:	c7 04 24 93 23 80 00 	movl   $0x802393,(%esp)
  801acf:	e8 9f e6 ff ff       	call   800173 <cprintf>
  801ad4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ad7:	cc                   	int3   
  801ad8:	eb fd                	jmp    801ad7 <_panic+0x43>

00801ada <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	56                   	push   %esi
  801ade:	53                   	push   %ebx
  801adf:	8b 75 08             	mov    0x8(%ebp),%esi
  801ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg) pg = (void *)UTOP;
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801aef:	0f 44 c2             	cmove  %edx,%eax
        int r;
        if((r = sys_ipc_recv(pg)) < 0) {
  801af2:	83 ec 0c             	sub    $0xc,%esp
  801af5:	50                   	push   %eax
  801af6:	e8 b8 f1 ff ff       	call   800cb3 <sys_ipc_recv>
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	85 c0                	test   %eax,%eax
  801b00:	79 16                	jns    801b18 <ipc_recv+0x3e>
                if(from_env_store) *from_env_store = 0;
  801b02:	85 f6                	test   %esi,%esi
  801b04:	74 06                	je     801b0c <ipc_recv+0x32>
  801b06:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
                if(perm_store) *perm_store = 0;
  801b0c:	85 db                	test   %ebx,%ebx
  801b0e:	74 2c                	je     801b3c <ipc_recv+0x62>
  801b10:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b16:	eb 24                	jmp    801b3c <ipc_recv+0x62>
                return r;
        }
        if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801b18:	85 f6                	test   %esi,%esi
  801b1a:	74 0a                	je     801b26 <ipc_recv+0x4c>
  801b1c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b21:	8b 40 74             	mov    0x74(%eax),%eax
  801b24:	89 06                	mov    %eax,(%esi)
        if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801b26:	85 db                	test   %ebx,%ebx
  801b28:	74 0a                	je     801b34 <ipc_recv+0x5a>
  801b2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2f:	8b 40 78             	mov    0x78(%eax),%eax
  801b32:	89 03                	mov    %eax,(%ebx)
         
	return thisenv->env_ipc_value;
  801b34:	a1 04 40 80 00       	mov    0x804004,%eax
  801b39:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	57                   	push   %edi
  801b47:	56                   	push   %esi
  801b48:	53                   	push   %ebx
  801b49:	83 ec 0c             	sub    $0xc,%esp
  801b4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
  801b55:	85 db                	test   %ebx,%ebx
  801b57:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b5c:	0f 44 d8             	cmove  %eax,%ebx
  801b5f:	eb 1c                	jmp    801b7d <ipc_send+0x3a>
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
                 if(r != -E_IPC_NOT_RECV)
  801b61:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b64:	74 12                	je     801b78 <ipc_send+0x35>
                         panic("sys_ipc_try_send fails %e\n", r);
  801b66:	50                   	push   %eax
  801b67:	68 cc 23 80 00       	push   $0x8023cc
  801b6c:	6a 39                	push   $0x39
  801b6e:	68 e7 23 80 00       	push   $0x8023e7
  801b73:	e8 1c ff ff ff       	call   801a94 <_panic>
                 sys_yield();
  801b78:	e8 67 ef ff ff       	call   800ae4 <sys_yield>
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg) pg = (void *)UTOP;
        int r;
        while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b7d:	ff 75 14             	pushl  0x14(%ebp)
  801b80:	53                   	push   %ebx
  801b81:	56                   	push   %esi
  801b82:	57                   	push   %edi
  801b83:	e8 08 f1 ff ff       	call   800c90 <sys_ipc_try_send>
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	78 d2                	js     801b61 <ipc_send+0x1e>
                 if(r != -E_IPC_NOT_RECV)
                         panic("sys_ipc_try_send fails %e\n", r);
                 sys_yield();
        }
                
}
  801b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	5f                   	pop    %edi
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    

00801b97 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b9d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ba2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ba5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bab:	8b 52 50             	mov    0x50(%edx),%edx
  801bae:	39 ca                	cmp    %ecx,%edx
  801bb0:	75 0d                	jne    801bbf <ipc_find_env+0x28>
			return envs[i].env_id;
  801bb2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bb5:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801bba:	8b 40 08             	mov    0x8(%eax),%eax
  801bbd:	eb 0e                	jmp    801bcd <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bbf:	83 c0 01             	add    $0x1,%eax
  801bc2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bc7:	75 d9                	jne    801ba2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bc9:	66 b8 00 00          	mov    $0x0,%ax
}
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    

00801bcf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd5:	89 d0                	mov    %edx,%eax
  801bd7:	c1 e8 16             	shr    $0x16,%eax
  801bda:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801be1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be6:	f6 c1 01             	test   $0x1,%cl
  801be9:	74 1d                	je     801c08 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801beb:	c1 ea 0c             	shr    $0xc,%edx
  801bee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bf5:	f6 c2 01             	test   $0x1,%dl
  801bf8:	74 0e                	je     801c08 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bfa:	c1 ea 0c             	shr    $0xc,%edx
  801bfd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c04:	ef 
  801c05:	0f b7 c0             	movzwl %ax,%eax
}
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    
  801c0a:	66 90                	xchg   %ax,%ax
  801c0c:	66 90                	xchg   %ax,%ax
  801c0e:	66 90                	xchg   %ax,%ax

00801c10 <__udivdi3>:
  801c10:	55                   	push   %ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	83 ec 10             	sub    $0x10,%esp
  801c16:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801c1a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801c1e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801c22:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801c26:	85 d2                	test   %edx,%edx
  801c28:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c2c:	89 34 24             	mov    %esi,(%esp)
  801c2f:	89 c8                	mov    %ecx,%eax
  801c31:	75 35                	jne    801c68 <__udivdi3+0x58>
  801c33:	39 f1                	cmp    %esi,%ecx
  801c35:	0f 87 bd 00 00 00    	ja     801cf8 <__udivdi3+0xe8>
  801c3b:	85 c9                	test   %ecx,%ecx
  801c3d:	89 cd                	mov    %ecx,%ebp
  801c3f:	75 0b                	jne    801c4c <__udivdi3+0x3c>
  801c41:	b8 01 00 00 00       	mov    $0x1,%eax
  801c46:	31 d2                	xor    %edx,%edx
  801c48:	f7 f1                	div    %ecx
  801c4a:	89 c5                	mov    %eax,%ebp
  801c4c:	89 f0                	mov    %esi,%eax
  801c4e:	31 d2                	xor    %edx,%edx
  801c50:	f7 f5                	div    %ebp
  801c52:	89 c6                	mov    %eax,%esi
  801c54:	89 f8                	mov    %edi,%eax
  801c56:	f7 f5                	div    %ebp
  801c58:	89 f2                	mov    %esi,%edx
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	5e                   	pop    %esi
  801c5e:	5f                   	pop    %edi
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    
  801c61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c68:	3b 14 24             	cmp    (%esp),%edx
  801c6b:	77 7b                	ja     801ce8 <__udivdi3+0xd8>
  801c6d:	0f bd f2             	bsr    %edx,%esi
  801c70:	83 f6 1f             	xor    $0x1f,%esi
  801c73:	0f 84 97 00 00 00    	je     801d10 <__udivdi3+0x100>
  801c79:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c7e:	89 d7                	mov    %edx,%edi
  801c80:	89 f1                	mov    %esi,%ecx
  801c82:	29 f5                	sub    %esi,%ebp
  801c84:	d3 e7                	shl    %cl,%edi
  801c86:	89 c2                	mov    %eax,%edx
  801c88:	89 e9                	mov    %ebp,%ecx
  801c8a:	d3 ea                	shr    %cl,%edx
  801c8c:	89 f1                	mov    %esi,%ecx
  801c8e:	09 fa                	or     %edi,%edx
  801c90:	8b 3c 24             	mov    (%esp),%edi
  801c93:	d3 e0                	shl    %cl,%eax
  801c95:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c99:	89 e9                	mov    %ebp,%ecx
  801c9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c9f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ca3:	89 fa                	mov    %edi,%edx
  801ca5:	d3 ea                	shr    %cl,%edx
  801ca7:	89 f1                	mov    %esi,%ecx
  801ca9:	d3 e7                	shl    %cl,%edi
  801cab:	89 e9                	mov    %ebp,%ecx
  801cad:	d3 e8                	shr    %cl,%eax
  801caf:	09 c7                	or     %eax,%edi
  801cb1:	89 f8                	mov    %edi,%eax
  801cb3:	f7 74 24 08          	divl   0x8(%esp)
  801cb7:	89 d5                	mov    %edx,%ebp
  801cb9:	89 c7                	mov    %eax,%edi
  801cbb:	f7 64 24 0c          	mull   0xc(%esp)
  801cbf:	39 d5                	cmp    %edx,%ebp
  801cc1:	89 14 24             	mov    %edx,(%esp)
  801cc4:	72 11                	jb     801cd7 <__udivdi3+0xc7>
  801cc6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cca:	89 f1                	mov    %esi,%ecx
  801ccc:	d3 e2                	shl    %cl,%edx
  801cce:	39 c2                	cmp    %eax,%edx
  801cd0:	73 5e                	jae    801d30 <__udivdi3+0x120>
  801cd2:	3b 2c 24             	cmp    (%esp),%ebp
  801cd5:	75 59                	jne    801d30 <__udivdi3+0x120>
  801cd7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801cda:	31 f6                	xor    %esi,%esi
  801cdc:	89 f2                	mov    %esi,%edx
  801cde:	83 c4 10             	add    $0x10,%esp
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    
  801ce5:	8d 76 00             	lea    0x0(%esi),%esi
  801ce8:	31 f6                	xor    %esi,%esi
  801cea:	31 c0                	xor    %eax,%eax
  801cec:	89 f2                	mov    %esi,%edx
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	5e                   	pop    %esi
  801cf2:	5f                   	pop    %edi
  801cf3:	5d                   	pop    %ebp
  801cf4:	c3                   	ret    
  801cf5:	8d 76 00             	lea    0x0(%esi),%esi
  801cf8:	89 f2                	mov    %esi,%edx
  801cfa:	31 f6                	xor    %esi,%esi
  801cfc:	89 f8                	mov    %edi,%eax
  801cfe:	f7 f1                	div    %ecx
  801d00:	89 f2                	mov    %esi,%edx
  801d02:	83 c4 10             	add    $0x10,%esp
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d14:	76 0b                	jbe    801d21 <__udivdi3+0x111>
  801d16:	31 c0                	xor    %eax,%eax
  801d18:	3b 14 24             	cmp    (%esp),%edx
  801d1b:	0f 83 37 ff ff ff    	jae    801c58 <__udivdi3+0x48>
  801d21:	b8 01 00 00 00       	mov    $0x1,%eax
  801d26:	e9 2d ff ff ff       	jmp    801c58 <__udivdi3+0x48>
  801d2b:	90                   	nop
  801d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d30:	89 f8                	mov    %edi,%eax
  801d32:	31 f6                	xor    %esi,%esi
  801d34:	e9 1f ff ff ff       	jmp    801c58 <__udivdi3+0x48>
  801d39:	66 90                	xchg   %ax,%ax
  801d3b:	66 90                	xchg   %ax,%ax
  801d3d:	66 90                	xchg   %ax,%ax
  801d3f:	90                   	nop

00801d40 <__umoddi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	83 ec 20             	sub    $0x20,%esp
  801d46:	8b 44 24 34          	mov    0x34(%esp),%eax
  801d4a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d4e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d52:	89 c6                	mov    %eax,%esi
  801d54:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d58:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d5c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801d60:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d64:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d68:	89 74 24 18          	mov    %esi,0x18(%esp)
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	89 c2                	mov    %eax,%edx
  801d70:	75 1e                	jne    801d90 <__umoddi3+0x50>
  801d72:	39 f7                	cmp    %esi,%edi
  801d74:	76 52                	jbe    801dc8 <__umoddi3+0x88>
  801d76:	89 c8                	mov    %ecx,%eax
  801d78:	89 f2                	mov    %esi,%edx
  801d7a:	f7 f7                	div    %edi
  801d7c:	89 d0                	mov    %edx,%eax
  801d7e:	31 d2                	xor    %edx,%edx
  801d80:	83 c4 20             	add    $0x20,%esp
  801d83:	5e                   	pop    %esi
  801d84:	5f                   	pop    %edi
  801d85:	5d                   	pop    %ebp
  801d86:	c3                   	ret    
  801d87:	89 f6                	mov    %esi,%esi
  801d89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d90:	39 f0                	cmp    %esi,%eax
  801d92:	77 5c                	ja     801df0 <__umoddi3+0xb0>
  801d94:	0f bd e8             	bsr    %eax,%ebp
  801d97:	83 f5 1f             	xor    $0x1f,%ebp
  801d9a:	75 64                	jne    801e00 <__umoddi3+0xc0>
  801d9c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801da0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801da4:	0f 86 f6 00 00 00    	jbe    801ea0 <__umoddi3+0x160>
  801daa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801dae:	0f 82 ec 00 00 00    	jb     801ea0 <__umoddi3+0x160>
  801db4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801db8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801dbc:	83 c4 20             	add    $0x20,%esp
  801dbf:	5e                   	pop    %esi
  801dc0:	5f                   	pop    %edi
  801dc1:	5d                   	pop    %ebp
  801dc2:	c3                   	ret    
  801dc3:	90                   	nop
  801dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc8:	85 ff                	test   %edi,%edi
  801dca:	89 fd                	mov    %edi,%ebp
  801dcc:	75 0b                	jne    801dd9 <__umoddi3+0x99>
  801dce:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f7                	div    %edi
  801dd7:	89 c5                	mov    %eax,%ebp
  801dd9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801ddd:	31 d2                	xor    %edx,%edx
  801ddf:	f7 f5                	div    %ebp
  801de1:	89 c8                	mov    %ecx,%eax
  801de3:	f7 f5                	div    %ebp
  801de5:	eb 95                	jmp    801d7c <__umoddi3+0x3c>
  801de7:	89 f6                	mov    %esi,%esi
  801de9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801df0:	89 c8                	mov    %ecx,%eax
  801df2:	89 f2                	mov    %esi,%edx
  801df4:	83 c4 20             	add    $0x20,%esp
  801df7:	5e                   	pop    %esi
  801df8:	5f                   	pop    %edi
  801df9:	5d                   	pop    %ebp
  801dfa:	c3                   	ret    
  801dfb:	90                   	nop
  801dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e00:	b8 20 00 00 00       	mov    $0x20,%eax
  801e05:	89 e9                	mov    %ebp,%ecx
  801e07:	29 e8                	sub    %ebp,%eax
  801e09:	d3 e2                	shl    %cl,%edx
  801e0b:	89 c7                	mov    %eax,%edi
  801e0d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e11:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e15:	89 f9                	mov    %edi,%ecx
  801e17:	d3 e8                	shr    %cl,%eax
  801e19:	89 c1                	mov    %eax,%ecx
  801e1b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e1f:	09 d1                	or     %edx,%ecx
  801e21:	89 fa                	mov    %edi,%edx
  801e23:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801e27:	89 e9                	mov    %ebp,%ecx
  801e29:	d3 e0                	shl    %cl,%eax
  801e2b:	89 f9                	mov    %edi,%ecx
  801e2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e31:	89 f0                	mov    %esi,%eax
  801e33:	d3 e8                	shr    %cl,%eax
  801e35:	89 e9                	mov    %ebp,%ecx
  801e37:	89 c7                	mov    %eax,%edi
  801e39:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e3d:	d3 e6                	shl    %cl,%esi
  801e3f:	89 d1                	mov    %edx,%ecx
  801e41:	89 fa                	mov    %edi,%edx
  801e43:	d3 e8                	shr    %cl,%eax
  801e45:	89 e9                	mov    %ebp,%ecx
  801e47:	09 f0                	or     %esi,%eax
  801e49:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801e4d:	f7 74 24 10          	divl   0x10(%esp)
  801e51:	d3 e6                	shl    %cl,%esi
  801e53:	89 d1                	mov    %edx,%ecx
  801e55:	f7 64 24 0c          	mull   0xc(%esp)
  801e59:	39 d1                	cmp    %edx,%ecx
  801e5b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801e5f:	89 d7                	mov    %edx,%edi
  801e61:	89 c6                	mov    %eax,%esi
  801e63:	72 0a                	jb     801e6f <__umoddi3+0x12f>
  801e65:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801e69:	73 10                	jae    801e7b <__umoddi3+0x13b>
  801e6b:	39 d1                	cmp    %edx,%ecx
  801e6d:	75 0c                	jne    801e7b <__umoddi3+0x13b>
  801e6f:	89 d7                	mov    %edx,%edi
  801e71:	89 c6                	mov    %eax,%esi
  801e73:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801e77:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801e7b:	89 ca                	mov    %ecx,%edx
  801e7d:	89 e9                	mov    %ebp,%ecx
  801e7f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e83:	29 f0                	sub    %esi,%eax
  801e85:	19 fa                	sbb    %edi,%edx
  801e87:	d3 e8                	shr    %cl,%eax
  801e89:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801e8e:	89 d7                	mov    %edx,%edi
  801e90:	d3 e7                	shl    %cl,%edi
  801e92:	89 e9                	mov    %ebp,%ecx
  801e94:	09 f8                	or     %edi,%eax
  801e96:	d3 ea                	shr    %cl,%edx
  801e98:	83 c4 20             	add    $0x20,%esp
  801e9b:	5e                   	pop    %esi
  801e9c:	5f                   	pop    %edi
  801e9d:	5d                   	pop    %ebp
  801e9e:	c3                   	ret    
  801e9f:	90                   	nop
  801ea0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801ea4:	29 f9                	sub    %edi,%ecx
  801ea6:	19 c6                	sbb    %eax,%esi
  801ea8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801eac:	89 74 24 18          	mov    %esi,0x18(%esp)
  801eb0:	e9 ff fe ff ff       	jmp    801db4 <__umoddi3+0x74>
