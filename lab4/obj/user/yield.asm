
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 20 80 00       	mov    0x802004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 c0 0f 80 00       	push   $0x800fc0
  800048:	e8 38 01 00 00       	call   800185 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 9c 0a 00 00       	call   800af6 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 e0 0f 80 00       	push   $0x800fe0
  80006c:	e8 14 01 00 00       	call   800185 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 20 80 00       	mov    0x802004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 0c 10 80 00       	push   $0x80100c
  80008d:	e8 f3 00 00 00       	call   800185 <cprintf>
  800092:	83 c4 10             	add    $0x10,%esp
}
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs+ENVX(sys_getenvid());
  8000a5:	e8 2d 0a 00 00       	call   800ad7 <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
  8000d6:	83 c4 10             	add    $0x10,%esp
}
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000e6:	6a 00                	push   $0x0
  8000e8:	e8 a9 09 00 00       	call   800a96 <sys_env_destroy>
  8000ed:	83 c4 10             	add    $0x10,%esp
}
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fc:	8b 13                	mov    (%ebx),%edx
  8000fe:	8d 42 01             	lea    0x1(%edx),%eax
  800101:	89 03                	mov    %eax,(%ebx)
  800103:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800106:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010f:	75 1a                	jne    80012b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 ff 00 00 00       	push   $0xff
  800119:	8d 43 08             	lea    0x8(%ebx),%eax
  80011c:	50                   	push   %eax
  80011d:	e8 37 09 00 00       	call   800a59 <sys_cputs>
		b->idx = 0;
  800122:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800128:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80012b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80013d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800144:	00 00 00 
	b.cnt = 0;
  800147:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800151:	ff 75 0c             	pushl  0xc(%ebp)
  800154:	ff 75 08             	pushl  0x8(%ebp)
  800157:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	68 f2 00 80 00       	push   $0x8000f2
  800163:	e8 4f 01 00 00       	call   8002b7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800168:	83 c4 08             	add    $0x8,%esp
  80016b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800171:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800177:	50                   	push   %eax
  800178:	e8 dc 08 00 00       	call   800a59 <sys_cputs>

	return b.cnt;
}
  80017d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80018e:	50                   	push   %eax
  80018f:	ff 75 08             	pushl  0x8(%ebp)
  800192:	e8 9d ff ff ff       	call   800134 <vcprintf>
	va_end(ap);

	return cnt;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 1c             	sub    $0x1c,%esp
  8001a2:	89 c7                	mov    %eax,%edi
  8001a4:	89 d6                	mov    %edx,%esi
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ac:	89 d1                	mov    %edx,%ecx
  8001ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001c4:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8001c7:	72 05                	jb     8001ce <printnum+0x35>
  8001c9:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001cc:	77 3e                	ja     80020c <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 18             	pushl  0x18(%ebp)
  8001d4:	83 eb 01             	sub    $0x1,%ebx
  8001d7:	53                   	push   %ebx
  8001d8:	50                   	push   %eax
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001df:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e8:	e8 23 0b 00 00       	call   800d10 <__udivdi3>
  8001ed:	83 c4 18             	add    $0x18,%esp
  8001f0:	52                   	push   %edx
  8001f1:	50                   	push   %eax
  8001f2:	89 f2                	mov    %esi,%edx
  8001f4:	89 f8                	mov    %edi,%eax
  8001f6:	e8 9e ff ff ff       	call   800199 <printnum>
  8001fb:	83 c4 20             	add    $0x20,%esp
  8001fe:	eb 13                	jmp    800213 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	56                   	push   %esi
  800204:	ff 75 18             	pushl  0x18(%ebp)
  800207:	ff d7                	call   *%edi
  800209:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020c:	83 eb 01             	sub    $0x1,%ebx
  80020f:	85 db                	test   %ebx,%ebx
  800211:	7f ed                	jg     800200 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800213:	83 ec 08             	sub    $0x8,%esp
  800216:	56                   	push   %esi
  800217:	83 ec 04             	sub    $0x4,%esp
  80021a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021d:	ff 75 e0             	pushl  -0x20(%ebp)
  800220:	ff 75 dc             	pushl  -0x24(%ebp)
  800223:	ff 75 d8             	pushl  -0x28(%ebp)
  800226:	e8 15 0c 00 00       	call   800e40 <__umoddi3>
  80022b:	83 c4 14             	add    $0x14,%esp
  80022e:	0f be 80 35 10 80 00 	movsbl 0x801035(%eax),%eax
  800235:	50                   	push   %eax
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
}
  80023b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023e:	5b                   	pop    %ebx
  80023f:	5e                   	pop    %esi
  800240:	5f                   	pop    %edi
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    

00800243 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800246:	83 fa 01             	cmp    $0x1,%edx
  800249:	7e 0e                	jle    800259 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80024b:	8b 10                	mov    (%eax),%edx
  80024d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800250:	89 08                	mov    %ecx,(%eax)
  800252:	8b 02                	mov    (%edx),%eax
  800254:	8b 52 04             	mov    0x4(%edx),%edx
  800257:	eb 22                	jmp    80027b <getuint+0x38>
	else if (lflag)
  800259:	85 d2                	test   %edx,%edx
  80025b:	74 10                	je     80026d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80025d:	8b 10                	mov    (%eax),%edx
  80025f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800262:	89 08                	mov    %ecx,(%eax)
  800264:	8b 02                	mov    (%edx),%eax
  800266:	ba 00 00 00 00       	mov    $0x0,%edx
  80026b:	eb 0e                	jmp    80027b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80026d:	8b 10                	mov    (%eax),%edx
  80026f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800272:	89 08                	mov    %ecx,(%eax)
  800274:	8b 02                	mov    (%edx),%eax
  800276:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    

0080027d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800283:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800287:	8b 10                	mov    (%eax),%edx
  800289:	3b 50 04             	cmp    0x4(%eax),%edx
  80028c:	73 0a                	jae    800298 <sprintputch+0x1b>
		*b->buf++ = ch;
  80028e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800291:	89 08                	mov    %ecx,(%eax)
  800293:	8b 45 08             	mov    0x8(%ebp),%eax
  800296:	88 02                	mov    %al,(%edx)
}
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    

0080029a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a3:	50                   	push   %eax
  8002a4:	ff 75 10             	pushl  0x10(%ebp)
  8002a7:	ff 75 0c             	pushl  0xc(%ebp)
  8002aa:	ff 75 08             	pushl  0x8(%ebp)
  8002ad:	e8 05 00 00 00       	call   8002b7 <vprintfmt>
	va_end(ap);
  8002b2:	83 c4 10             	add    $0x10,%esp
}
  8002b5:	c9                   	leave  
  8002b6:	c3                   	ret    

008002b7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	57                   	push   %edi
  8002bb:	56                   	push   %esi
  8002bc:	53                   	push   %ebx
  8002bd:	83 ec 2c             	sub    $0x2c,%esp
  8002c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c9:	eb 12                	jmp    8002dd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	0f 84 90 03 00 00    	je     800663 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  8002d3:	83 ec 08             	sub    $0x8,%esp
  8002d6:	53                   	push   %ebx
  8002d7:	50                   	push   %eax
  8002d8:	ff d6                	call   *%esi
  8002da:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002dd:	83 c7 01             	add    $0x1,%edi
  8002e0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002e4:	83 f8 25             	cmp    $0x25,%eax
  8002e7:	75 e2                	jne    8002cb <vprintfmt+0x14>
  8002e9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002ed:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002f4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002fb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800302:	ba 00 00 00 00       	mov    $0x0,%edx
  800307:	eb 07                	jmp    800310 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800309:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80030c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800310:	8d 47 01             	lea    0x1(%edi),%eax
  800313:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800316:	0f b6 07             	movzbl (%edi),%eax
  800319:	0f b6 c8             	movzbl %al,%ecx
  80031c:	83 e8 23             	sub    $0x23,%eax
  80031f:	3c 55                	cmp    $0x55,%al
  800321:	0f 87 21 03 00 00    	ja     800648 <vprintfmt+0x391>
  800327:	0f b6 c0             	movzbl %al,%eax
  80032a:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800334:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800338:	eb d6                	jmp    800310 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033d:	b8 00 00 00 00       	mov    $0x0,%eax
  800342:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800345:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800348:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80034c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80034f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800352:	83 fa 09             	cmp    $0x9,%edx
  800355:	77 39                	ja     800390 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800357:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80035a:	eb e9                	jmp    800345 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80035c:	8b 45 14             	mov    0x14(%ebp),%eax
  80035f:	8d 48 04             	lea    0x4(%eax),%ecx
  800362:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800365:	8b 00                	mov    (%eax),%eax
  800367:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80036d:	eb 27                	jmp    800396 <vprintfmt+0xdf>
  80036f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800372:	85 c0                	test   %eax,%eax
  800374:	b9 00 00 00 00       	mov    $0x0,%ecx
  800379:	0f 49 c8             	cmovns %eax,%ecx
  80037c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800382:	eb 8c                	jmp    800310 <vprintfmt+0x59>
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800387:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80038e:	eb 80                	jmp    800310 <vprintfmt+0x59>
  800390:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800393:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800396:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80039a:	0f 89 70 ff ff ff    	jns    800310 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ad:	e9 5e ff ff ff       	jmp    800310 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b8:	e9 53 ff ff ff       	jmp    800310 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 50 04             	lea    0x4(%eax),%edx
  8003c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c6:	83 ec 08             	sub    $0x8,%esp
  8003c9:	53                   	push   %ebx
  8003ca:	ff 30                	pushl  (%eax)
  8003cc:	ff d6                	call   *%esi
			break;
  8003ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d4:	e9 04 ff ff ff       	jmp    8002dd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dc:	8d 50 04             	lea    0x4(%eax),%edx
  8003df:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e2:	8b 00                	mov    (%eax),%eax
  8003e4:	99                   	cltd   
  8003e5:	31 d0                	xor    %edx,%eax
  8003e7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e9:	83 f8 09             	cmp    $0x9,%eax
  8003ec:	7f 0b                	jg     8003f9 <vprintfmt+0x142>
  8003ee:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  8003f5:	85 d2                	test   %edx,%edx
  8003f7:	75 18                	jne    800411 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003f9:	50                   	push   %eax
  8003fa:	68 4d 10 80 00       	push   $0x80104d
  8003ff:	53                   	push   %ebx
  800400:	56                   	push   %esi
  800401:	e8 94 fe ff ff       	call   80029a <printfmt>
  800406:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80040c:	e9 cc fe ff ff       	jmp    8002dd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800411:	52                   	push   %edx
  800412:	68 56 10 80 00       	push   $0x801056
  800417:	53                   	push   %ebx
  800418:	56                   	push   %esi
  800419:	e8 7c fe ff ff       	call   80029a <printfmt>
  80041e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800424:	e9 b4 fe ff ff       	jmp    8002dd <vprintfmt+0x26>
  800429:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80042c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042f:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 50 04             	lea    0x4(%eax),%edx
  800438:	89 55 14             	mov    %edx,0x14(%ebp)
  80043b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80043d:	85 ff                	test   %edi,%edi
  80043f:	ba 46 10 80 00       	mov    $0x801046,%edx
  800444:	0f 44 fa             	cmove  %edx,%edi
			if (width > 0 && padc != '-')
  800447:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044b:	0f 84 92 00 00 00    	je     8004e3 <vprintfmt+0x22c>
  800451:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800455:	0f 8e 96 00 00 00    	jle    8004f1 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	51                   	push   %ecx
  80045f:	57                   	push   %edi
  800460:	e8 86 02 00 00       	call   8006eb <strnlen>
  800465:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800468:	29 c1                	sub    %eax,%ecx
  80046a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80046d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800470:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800474:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800477:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80047a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047c:	eb 0f                	jmp    80048d <vprintfmt+0x1d6>
					putch(padc, putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	53                   	push   %ebx
  800482:	ff 75 e0             	pushl  -0x20(%ebp)
  800485:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	83 ef 01             	sub    $0x1,%edi
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	85 ff                	test   %edi,%edi
  80048f:	7f ed                	jg     80047e <vprintfmt+0x1c7>
  800491:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800494:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800497:	85 c9                	test   %ecx,%ecx
  800499:	b8 00 00 00 00       	mov    $0x0,%eax
  80049e:	0f 49 c1             	cmovns %ecx,%eax
  8004a1:	29 c1                	sub    %eax,%ecx
  8004a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ac:	89 cb                	mov    %ecx,%ebx
  8004ae:	eb 4d                	jmp    8004fd <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b4:	74 1b                	je     8004d1 <vprintfmt+0x21a>
  8004b6:	0f be c0             	movsbl %al,%eax
  8004b9:	83 e8 20             	sub    $0x20,%eax
  8004bc:	83 f8 5e             	cmp    $0x5e,%eax
  8004bf:	76 10                	jbe    8004d1 <vprintfmt+0x21a>
					putch('?', putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	ff 75 0c             	pushl  0xc(%ebp)
  8004c7:	6a 3f                	push   $0x3f
  8004c9:	ff 55 08             	call   *0x8(%ebp)
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	eb 0d                	jmp    8004de <vprintfmt+0x227>
				else
					putch(ch, putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	ff 75 0c             	pushl  0xc(%ebp)
  8004d7:	52                   	push   %edx
  8004d8:	ff 55 08             	call   *0x8(%ebp)
  8004db:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004de:	83 eb 01             	sub    $0x1,%ebx
  8004e1:	eb 1a                	jmp    8004fd <vprintfmt+0x246>
  8004e3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ec:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ef:	eb 0c                	jmp    8004fd <vprintfmt+0x246>
  8004f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fd:	83 c7 01             	add    $0x1,%edi
  800500:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800504:	0f be d0             	movsbl %al,%edx
  800507:	85 d2                	test   %edx,%edx
  800509:	74 23                	je     80052e <vprintfmt+0x277>
  80050b:	85 f6                	test   %esi,%esi
  80050d:	78 a1                	js     8004b0 <vprintfmt+0x1f9>
  80050f:	83 ee 01             	sub    $0x1,%esi
  800512:	79 9c                	jns    8004b0 <vprintfmt+0x1f9>
  800514:	89 df                	mov    %ebx,%edi
  800516:	8b 75 08             	mov    0x8(%ebp),%esi
  800519:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051c:	eb 18                	jmp    800536 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	53                   	push   %ebx
  800522:	6a 20                	push   $0x20
  800524:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800526:	83 ef 01             	sub    $0x1,%edi
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	eb 08                	jmp    800536 <vprintfmt+0x27f>
  80052e:	89 df                	mov    %ebx,%edi
  800530:	8b 75 08             	mov    0x8(%ebp),%esi
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800536:	85 ff                	test   %edi,%edi
  800538:	7f e4                	jg     80051e <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053d:	e9 9b fd ff ff       	jmp    8002dd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800542:	83 fa 01             	cmp    $0x1,%edx
  800545:	7e 16                	jle    80055d <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 50 08             	lea    0x8(%eax),%edx
  80054d:	89 55 14             	mov    %edx,0x14(%ebp)
  800550:	8b 50 04             	mov    0x4(%eax),%edx
  800553:	8b 00                	mov    (%eax),%eax
  800555:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800558:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055b:	eb 32                	jmp    80058f <vprintfmt+0x2d8>
	else if (lflag)
  80055d:	85 d2                	test   %edx,%edx
  80055f:	74 18                	je     800579 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8d 50 04             	lea    0x4(%eax),%edx
  800567:	89 55 14             	mov    %edx,0x14(%ebp)
  80056a:	8b 00                	mov    (%eax),%eax
  80056c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056f:	89 c1                	mov    %eax,%ecx
  800571:	c1 f9 1f             	sar    $0x1f,%ecx
  800574:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800577:	eb 16                	jmp    80058f <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 50 04             	lea    0x4(%eax),%edx
  80057f:	89 55 14             	mov    %edx,0x14(%ebp)
  800582:	8b 00                	mov    (%eax),%eax
  800584:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800587:	89 c1                	mov    %eax,%ecx
  800589:	c1 f9 1f             	sar    $0x1f,%ecx
  80058c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80058f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800592:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800595:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059e:	79 74                	jns    800614 <vprintfmt+0x35d>
				putch('-', putdat);
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	53                   	push   %ebx
  8005a4:	6a 2d                	push   $0x2d
  8005a6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ae:	f7 d8                	neg    %eax
  8005b0:	83 d2 00             	adc    $0x0,%edx
  8005b3:	f7 da                	neg    %edx
  8005b5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005b8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005bd:	eb 55                	jmp    800614 <vprintfmt+0x35d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c2:	e8 7c fc ff ff       	call   800243 <getuint>
			base = 10;
  8005c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005cc:	eb 46                	jmp    800614 <vprintfmt+0x35d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 6d fc ff ff       	call   800243 <getuint>
                        base = 8;
  8005d6:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005db:	eb 37                	jmp    800614 <vprintfmt+0x35d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	6a 30                	push   $0x30
  8005e3:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e5:	83 c4 08             	add    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	6a 78                	push   $0x78
  8005eb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 50 04             	lea    0x4(%eax),%edx
  8005f3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005fd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800600:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800605:	eb 0d                	jmp    800614 <vprintfmt+0x35d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800607:	8d 45 14             	lea    0x14(%ebp),%eax
  80060a:	e8 34 fc ff ff       	call   800243 <getuint>
			base = 16;
  80060f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800614:	83 ec 0c             	sub    $0xc,%esp
  800617:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80061b:	57                   	push   %edi
  80061c:	ff 75 e0             	pushl  -0x20(%ebp)
  80061f:	51                   	push   %ecx
  800620:	52                   	push   %edx
  800621:	50                   	push   %eax
  800622:	89 da                	mov    %ebx,%edx
  800624:	89 f0                	mov    %esi,%eax
  800626:	e8 6e fb ff ff       	call   800199 <printnum>
			break;
  80062b:	83 c4 20             	add    $0x20,%esp
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800631:	e9 a7 fc ff ff       	jmp    8002dd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	53                   	push   %ebx
  80063a:	51                   	push   %ecx
  80063b:	ff d6                	call   *%esi
			break;
  80063d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800643:	e9 95 fc ff ff       	jmp    8002dd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 25                	push   $0x25
  80064e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	eb 03                	jmp    800658 <vprintfmt+0x3a1>
  800655:	83 ef 01             	sub    $0x1,%edi
  800658:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80065c:	75 f7                	jne    800655 <vprintfmt+0x39e>
  80065e:	e9 7a fc ff ff       	jmp    8002dd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800663:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800666:	5b                   	pop    %ebx
  800667:	5e                   	pop    %esi
  800668:	5f                   	pop    %edi
  800669:	5d                   	pop    %ebp
  80066a:	c3                   	ret    

0080066b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80066b:	55                   	push   %ebp
  80066c:	89 e5                	mov    %esp,%ebp
  80066e:	83 ec 18             	sub    $0x18,%esp
  800671:	8b 45 08             	mov    0x8(%ebp),%eax
  800674:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800677:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80067e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800681:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800688:	85 c0                	test   %eax,%eax
  80068a:	74 26                	je     8006b2 <vsnprintf+0x47>
  80068c:	85 d2                	test   %edx,%edx
  80068e:	7e 22                	jle    8006b2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800690:	ff 75 14             	pushl  0x14(%ebp)
  800693:	ff 75 10             	pushl  0x10(%ebp)
  800696:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800699:	50                   	push   %eax
  80069a:	68 7d 02 80 00       	push   $0x80027d
  80069f:	e8 13 fc ff ff       	call   8002b7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ad:	83 c4 10             	add    $0x10,%esp
  8006b0:	eb 05                	jmp    8006b7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b7:	c9                   	leave  
  8006b8:	c3                   	ret    

008006b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
  8006bc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c2:	50                   	push   %eax
  8006c3:	ff 75 10             	pushl  0x10(%ebp)
  8006c6:	ff 75 0c             	pushl  0xc(%ebp)
  8006c9:	ff 75 08             	pushl  0x8(%ebp)
  8006cc:	e8 9a ff ff ff       	call   80066b <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d1:	c9                   	leave  
  8006d2:	c3                   	ret    

008006d3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006de:	eb 03                	jmp    8006e3 <strlen+0x10>
		n++;
  8006e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e7:	75 f7                	jne    8006e0 <strlen+0xd>
		n++;
	return n;
}
  8006e9:	5d                   	pop    %ebp
  8006ea:	c3                   	ret    

008006eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f9:	eb 03                	jmp    8006fe <strnlen+0x13>
		n++;
  8006fb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fe:	39 c2                	cmp    %eax,%edx
  800700:	74 08                	je     80070a <strnlen+0x1f>
  800702:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800706:	75 f3                	jne    8006fb <strnlen+0x10>
  800708:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	53                   	push   %ebx
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800716:	89 c2                	mov    %eax,%edx
  800718:	83 c2 01             	add    $0x1,%edx
  80071b:	83 c1 01             	add    $0x1,%ecx
  80071e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800722:	88 5a ff             	mov    %bl,-0x1(%edx)
  800725:	84 db                	test   %bl,%bl
  800727:	75 ef                	jne    800718 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800729:	5b                   	pop    %ebx
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	53                   	push   %ebx
  800730:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800733:	53                   	push   %ebx
  800734:	e8 9a ff ff ff       	call   8006d3 <strlen>
  800739:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80073c:	ff 75 0c             	pushl  0xc(%ebp)
  80073f:	01 d8                	add    %ebx,%eax
  800741:	50                   	push   %eax
  800742:	e8 c5 ff ff ff       	call   80070c <strcpy>
	return dst;
}
  800747:	89 d8                	mov    %ebx,%eax
  800749:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80074c:	c9                   	leave  
  80074d:	c3                   	ret    

0080074e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	56                   	push   %esi
  800752:	53                   	push   %ebx
  800753:	8b 75 08             	mov    0x8(%ebp),%esi
  800756:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800759:	89 f3                	mov    %esi,%ebx
  80075b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075e:	89 f2                	mov    %esi,%edx
  800760:	eb 0f                	jmp    800771 <strncpy+0x23>
		*dst++ = *src;
  800762:	83 c2 01             	add    $0x1,%edx
  800765:	0f b6 01             	movzbl (%ecx),%eax
  800768:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80076b:	80 39 01             	cmpb   $0x1,(%ecx)
  80076e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800771:	39 da                	cmp    %ebx,%edx
  800773:	75 ed                	jne    800762 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800775:	89 f0                	mov    %esi,%eax
  800777:	5b                   	pop    %ebx
  800778:	5e                   	pop    %esi
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	56                   	push   %esi
  80077f:	53                   	push   %ebx
  800780:	8b 75 08             	mov    0x8(%ebp),%esi
  800783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800786:	8b 55 10             	mov    0x10(%ebp),%edx
  800789:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078b:	85 d2                	test   %edx,%edx
  80078d:	74 21                	je     8007b0 <strlcpy+0x35>
  80078f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800793:	89 f2                	mov    %esi,%edx
  800795:	eb 09                	jmp    8007a0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800797:	83 c2 01             	add    $0x1,%edx
  80079a:	83 c1 01             	add    $0x1,%ecx
  80079d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a0:	39 c2                	cmp    %eax,%edx
  8007a2:	74 09                	je     8007ad <strlcpy+0x32>
  8007a4:	0f b6 19             	movzbl (%ecx),%ebx
  8007a7:	84 db                	test   %bl,%bl
  8007a9:	75 ec                	jne    800797 <strlcpy+0x1c>
  8007ab:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ad:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b0:	29 f0                	sub    %esi,%eax
}
  8007b2:	5b                   	pop    %ebx
  8007b3:	5e                   	pop    %esi
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007bf:	eb 06                	jmp    8007c7 <strcmp+0x11>
		p++, q++;
  8007c1:	83 c1 01             	add    $0x1,%ecx
  8007c4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c7:	0f b6 01             	movzbl (%ecx),%eax
  8007ca:	84 c0                	test   %al,%al
  8007cc:	74 04                	je     8007d2 <strcmp+0x1c>
  8007ce:	3a 02                	cmp    (%edx),%al
  8007d0:	74 ef                	je     8007c1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d2:	0f b6 c0             	movzbl %al,%eax
  8007d5:	0f b6 12             	movzbl (%edx),%edx
  8007d8:	29 d0                	sub    %edx,%eax
}
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	53                   	push   %ebx
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e6:	89 c3                	mov    %eax,%ebx
  8007e8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007eb:	eb 06                	jmp    8007f3 <strncmp+0x17>
		n--, p++, q++;
  8007ed:	83 c0 01             	add    $0x1,%eax
  8007f0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f3:	39 d8                	cmp    %ebx,%eax
  8007f5:	74 15                	je     80080c <strncmp+0x30>
  8007f7:	0f b6 08             	movzbl (%eax),%ecx
  8007fa:	84 c9                	test   %cl,%cl
  8007fc:	74 04                	je     800802 <strncmp+0x26>
  8007fe:	3a 0a                	cmp    (%edx),%cl
  800800:	74 eb                	je     8007ed <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800802:	0f b6 00             	movzbl (%eax),%eax
  800805:	0f b6 12             	movzbl (%edx),%edx
  800808:	29 d0                	sub    %edx,%eax
  80080a:	eb 05                	jmp    800811 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800811:	5b                   	pop    %ebx
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80081e:	eb 07                	jmp    800827 <strchr+0x13>
		if (*s == c)
  800820:	38 ca                	cmp    %cl,%dl
  800822:	74 0f                	je     800833 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800824:	83 c0 01             	add    $0x1,%eax
  800827:	0f b6 10             	movzbl (%eax),%edx
  80082a:	84 d2                	test   %dl,%dl
  80082c:	75 f2                	jne    800820 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80082e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083f:	eb 03                	jmp    800844 <strfind+0xf>
  800841:	83 c0 01             	add    $0x1,%eax
  800844:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800847:	84 d2                	test   %dl,%dl
  800849:	74 04                	je     80084f <strfind+0x1a>
  80084b:	38 ca                	cmp    %cl,%dl
  80084d:	75 f2                	jne    800841 <strfind+0xc>
			break;
	return (char *) s;
}
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	57                   	push   %edi
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80085d:	85 c9                	test   %ecx,%ecx
  80085f:	74 36                	je     800897 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800861:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800867:	75 28                	jne    800891 <memset+0x40>
  800869:	f6 c1 03             	test   $0x3,%cl
  80086c:	75 23                	jne    800891 <memset+0x40>
		c &= 0xFF;
  80086e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800872:	89 d3                	mov    %edx,%ebx
  800874:	c1 e3 08             	shl    $0x8,%ebx
  800877:	89 d6                	mov    %edx,%esi
  800879:	c1 e6 18             	shl    $0x18,%esi
  80087c:	89 d0                	mov    %edx,%eax
  80087e:	c1 e0 10             	shl    $0x10,%eax
  800881:	09 f0                	or     %esi,%eax
  800883:	09 c2                	or     %eax,%edx
  800885:	89 d0                	mov    %edx,%eax
  800887:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800889:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80088c:	fc                   	cld    
  80088d:	f3 ab                	rep stos %eax,%es:(%edi)
  80088f:	eb 06                	jmp    800897 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800891:	8b 45 0c             	mov    0xc(%ebp),%eax
  800894:	fc                   	cld    
  800895:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800897:	89 f8                	mov    %edi,%eax
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	5f                   	pop    %edi
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	57                   	push   %edi
  8008a2:	56                   	push   %esi
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ac:	39 c6                	cmp    %eax,%esi
  8008ae:	73 35                	jae    8008e5 <memmove+0x47>
  8008b0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b3:	39 d0                	cmp    %edx,%eax
  8008b5:	73 2e                	jae    8008e5 <memmove+0x47>
		s += n;
		d += n;
  8008b7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008ba:	89 d6                	mov    %edx,%esi
  8008bc:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008be:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c4:	75 13                	jne    8008d9 <memmove+0x3b>
  8008c6:	f6 c1 03             	test   $0x3,%cl
  8008c9:	75 0e                	jne    8008d9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008cb:	83 ef 04             	sub    $0x4,%edi
  8008ce:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d1:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008d4:	fd                   	std    
  8008d5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d7:	eb 09                	jmp    8008e2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008d9:	83 ef 01             	sub    $0x1,%edi
  8008dc:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008df:	fd                   	std    
  8008e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e2:	fc                   	cld    
  8008e3:	eb 1d                	jmp    800902 <memmove+0x64>
  8008e5:	89 f2                	mov    %esi,%edx
  8008e7:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e9:	f6 c2 03             	test   $0x3,%dl
  8008ec:	75 0f                	jne    8008fd <memmove+0x5f>
  8008ee:	f6 c1 03             	test   $0x3,%cl
  8008f1:	75 0a                	jne    8008fd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008f3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008f6:	89 c7                	mov    %eax,%edi
  8008f8:	fc                   	cld    
  8008f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fb:	eb 05                	jmp    800902 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008fd:	89 c7                	mov    %eax,%edi
  8008ff:	fc                   	cld    
  800900:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800902:	5e                   	pop    %esi
  800903:	5f                   	pop    %edi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800909:	ff 75 10             	pushl  0x10(%ebp)
  80090c:	ff 75 0c             	pushl  0xc(%ebp)
  80090f:	ff 75 08             	pushl  0x8(%ebp)
  800912:	e8 87 ff ff ff       	call   80089e <memmove>
}
  800917:	c9                   	leave  
  800918:	c3                   	ret    

00800919 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	56                   	push   %esi
  80091d:	53                   	push   %ebx
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	8b 55 0c             	mov    0xc(%ebp),%edx
  800924:	89 c6                	mov    %eax,%esi
  800926:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800929:	eb 1a                	jmp    800945 <memcmp+0x2c>
		if (*s1 != *s2)
  80092b:	0f b6 08             	movzbl (%eax),%ecx
  80092e:	0f b6 1a             	movzbl (%edx),%ebx
  800931:	38 d9                	cmp    %bl,%cl
  800933:	74 0a                	je     80093f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800935:	0f b6 c1             	movzbl %cl,%eax
  800938:	0f b6 db             	movzbl %bl,%ebx
  80093b:	29 d8                	sub    %ebx,%eax
  80093d:	eb 0f                	jmp    80094e <memcmp+0x35>
		s1++, s2++;
  80093f:	83 c0 01             	add    $0x1,%eax
  800942:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800945:	39 f0                	cmp    %esi,%eax
  800947:	75 e2                	jne    80092b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800949:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094e:	5b                   	pop    %ebx
  80094f:	5e                   	pop    %esi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80095b:	89 c2                	mov    %eax,%edx
  80095d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800960:	eb 07                	jmp    800969 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800962:	38 08                	cmp    %cl,(%eax)
  800964:	74 07                	je     80096d <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800966:	83 c0 01             	add    $0x1,%eax
  800969:	39 d0                	cmp    %edx,%eax
  80096b:	72 f5                	jb     800962 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800978:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097b:	eb 03                	jmp    800980 <strtol+0x11>
		s++;
  80097d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800980:	0f b6 01             	movzbl (%ecx),%eax
  800983:	3c 09                	cmp    $0x9,%al
  800985:	74 f6                	je     80097d <strtol+0xe>
  800987:	3c 20                	cmp    $0x20,%al
  800989:	74 f2                	je     80097d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80098b:	3c 2b                	cmp    $0x2b,%al
  80098d:	75 0a                	jne    800999 <strtol+0x2a>
		s++;
  80098f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800992:	bf 00 00 00 00       	mov    $0x0,%edi
  800997:	eb 10                	jmp    8009a9 <strtol+0x3a>
  800999:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80099e:	3c 2d                	cmp    $0x2d,%al
  8009a0:	75 07                	jne    8009a9 <strtol+0x3a>
		s++, neg = 1;
  8009a2:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009a5:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a9:	85 db                	test   %ebx,%ebx
  8009ab:	0f 94 c0             	sete   %al
  8009ae:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b4:	75 19                	jne    8009cf <strtol+0x60>
  8009b6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b9:	75 14                	jne    8009cf <strtol+0x60>
  8009bb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009bf:	0f 85 82 00 00 00    	jne    800a47 <strtol+0xd8>
		s += 2, base = 16;
  8009c5:	83 c1 02             	add    $0x2,%ecx
  8009c8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009cd:	eb 16                	jmp    8009e5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009cf:	84 c0                	test   %al,%al
  8009d1:	74 12                	je     8009e5 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009d8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009db:	75 08                	jne    8009e5 <strtol+0x76>
		s++, base = 8;
  8009dd:	83 c1 01             	add    $0x1,%ecx
  8009e0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009ed:	0f b6 11             	movzbl (%ecx),%edx
  8009f0:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009f3:	89 f3                	mov    %esi,%ebx
  8009f5:	80 fb 09             	cmp    $0x9,%bl
  8009f8:	77 08                	ja     800a02 <strtol+0x93>
			dig = *s - '0';
  8009fa:	0f be d2             	movsbl %dl,%edx
  8009fd:	83 ea 30             	sub    $0x30,%edx
  800a00:	eb 22                	jmp    800a24 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a02:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a05:	89 f3                	mov    %esi,%ebx
  800a07:	80 fb 19             	cmp    $0x19,%bl
  800a0a:	77 08                	ja     800a14 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a0c:	0f be d2             	movsbl %dl,%edx
  800a0f:	83 ea 57             	sub    $0x57,%edx
  800a12:	eb 10                	jmp    800a24 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a14:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a17:	89 f3                	mov    %esi,%ebx
  800a19:	80 fb 19             	cmp    $0x19,%bl
  800a1c:	77 16                	ja     800a34 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a1e:	0f be d2             	movsbl %dl,%edx
  800a21:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a24:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a27:	7d 0f                	jge    800a38 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a30:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a32:	eb b9                	jmp    8009ed <strtol+0x7e>
  800a34:	89 c2                	mov    %eax,%edx
  800a36:	eb 02                	jmp    800a3a <strtol+0xcb>
  800a38:	89 c2                	mov    %eax,%edx

	if (endptr)
  800a3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3e:	74 0d                	je     800a4d <strtol+0xde>
		*endptr = (char *) s;
  800a40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a43:	89 0e                	mov    %ecx,(%esi)
  800a45:	eb 06                	jmp    800a4d <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a47:	84 c0                	test   %al,%al
  800a49:	75 92                	jne    8009dd <strtol+0x6e>
  800a4b:	eb 98                	jmp    8009e5 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a4d:	f7 da                	neg    %edx
  800a4f:	85 ff                	test   %edi,%edi
  800a51:	0f 45 c2             	cmovne %edx,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a67:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6a:	89 c3                	mov    %eax,%ebx
  800a6c:	89 c7                	mov    %eax,%edi
  800a6e:	89 c6                	mov    %eax,%esi
  800a70:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	b8 01 00 00 00       	mov    $0x1,%eax
  800a87:	89 d1                	mov    %edx,%ecx
  800a89:	89 d3                	mov    %edx,%ebx
  800a8b:	89 d7                	mov    %edx,%edi
  800a8d:	89 d6                	mov    %edx,%esi
  800a8f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5f                   	pop    %edi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa4:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aac:	89 cb                	mov    %ecx,%ebx
  800aae:	89 cf                	mov    %ecx,%edi
  800ab0:	89 ce                	mov    %ecx,%esi
  800ab2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ab4:	85 c0                	test   %eax,%eax
  800ab6:	7e 17                	jle    800acf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab8:	83 ec 0c             	sub    $0xc,%esp
  800abb:	50                   	push   %eax
  800abc:	6a 03                	push   $0x3
  800abe:	68 88 12 80 00       	push   $0x801288
  800ac3:	6a 23                	push   $0x23
  800ac5:	68 a5 12 80 00       	push   $0x8012a5
  800aca:	e8 f5 01 00 00       	call   800cc4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800acf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae7:	89 d1                	mov    %edx,%ecx
  800ae9:	89 d3                	mov    %edx,%ebx
  800aeb:	89 d7                	mov    %edx,%edi
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_yield>:

void
sys_yield(void)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b06:	89 d1                	mov    %edx,%ecx
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	be 00 00 00 00       	mov    $0x0,%esi
  800b23:	b8 04 00 00 00       	mov    $0x4,%eax
  800b28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b31:	89 f7                	mov    %esi,%edi
  800b33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	7e 17                	jle    800b50 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b39:	83 ec 0c             	sub    $0xc,%esp
  800b3c:	50                   	push   %eax
  800b3d:	6a 04                	push   $0x4
  800b3f:	68 88 12 80 00       	push   $0x801288
  800b44:	6a 23                	push   $0x23
  800b46:	68 a5 12 80 00       	push   $0x8012a5
  800b4b:	e8 74 01 00 00       	call   800cc4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	b8 05 00 00 00       	mov    $0x5,%eax
  800b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b72:	8b 75 18             	mov    0x18(%ebp),%esi
  800b75:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	7e 17                	jle    800b92 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	50                   	push   %eax
  800b7f:	6a 05                	push   $0x5
  800b81:	68 88 12 80 00       	push   $0x801288
  800b86:	6a 23                	push   $0x23
  800b88:	68 a5 12 80 00       	push   $0x8012a5
  800b8d:	e8 32 01 00 00       	call   800cc4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba8:	b8 06 00 00 00       	mov    $0x6,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	89 df                	mov    %ebx,%edi
  800bb5:	89 de                	mov    %ebx,%esi
  800bb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 17                	jle    800bd4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 06                	push   $0x6
  800bc3:	68 88 12 80 00       	push   $0x801288
  800bc8:	6a 23                	push   $0x23
  800bca:	68 a5 12 80 00       	push   $0x8012a5
  800bcf:	e8 f0 00 00 00       	call   800cc4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bea:	b8 08 00 00 00       	mov    $0x8,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 df                	mov    %ebx,%edi
  800bf7:	89 de                	mov    %ebx,%esi
  800bf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 08                	push   $0x8
  800c05:	68 88 12 80 00       	push   $0x801288
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 a5 12 80 00       	push   $0x8012a5
  800c11:	e8 ae 00 00 00       	call   800cc4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 df                	mov    %ebx,%edi
  800c39:	89 de                	mov    %ebx,%esi
  800c3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 09                	push   $0x9
  800c47:	68 88 12 80 00       	push   $0x801288
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 a5 12 80 00       	push   $0x8012a5
  800c53:	e8 6c 00 00 00       	call   800cc4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	be 00 00 00 00       	mov    $0x0,%esi
  800c6b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 cb                	mov    %ecx,%ebx
  800c9b:	89 cf                	mov    %ecx,%edi
  800c9d:	89 ce                	mov    %ecx,%esi
  800c9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 0c                	push   $0xc
  800cab:	68 88 12 80 00       	push   $0x801288
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 a5 12 80 00       	push   $0x8012a5
  800cb7:	e8 08 00 00 00       	call   800cc4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cc9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ccc:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cd2:	e8 00 fe ff ff       	call   800ad7 <sys_getenvid>
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	ff 75 0c             	pushl  0xc(%ebp)
  800cdd:	ff 75 08             	pushl  0x8(%ebp)
  800ce0:	56                   	push   %esi
  800ce1:	50                   	push   %eax
  800ce2:	68 b4 12 80 00       	push   $0x8012b4
  800ce7:	e8 99 f4 ff ff       	call   800185 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cec:	83 c4 18             	add    $0x18,%esp
  800cef:	53                   	push   %ebx
  800cf0:	ff 75 10             	pushl  0x10(%ebp)
  800cf3:	e8 3c f4 ff ff       	call   800134 <vcprintf>
	cprintf("\n");
  800cf8:	c7 04 24 d8 12 80 00 	movl   $0x8012d8,(%esp)
  800cff:	e8 81 f4 ff ff       	call   800185 <cprintf>
  800d04:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d07:	cc                   	int3   
  800d08:	eb fd                	jmp    800d07 <_panic+0x43>
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

00800d10 <__udivdi3>:
  800d10:	55                   	push   %ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	83 ec 10             	sub    $0x10,%esp
  800d16:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800d1a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800d1e:	8b 74 24 24          	mov    0x24(%esp),%esi
  800d22:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d26:	85 d2                	test   %edx,%edx
  800d28:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d2c:	89 34 24             	mov    %esi,(%esp)
  800d2f:	89 c8                	mov    %ecx,%eax
  800d31:	75 35                	jne    800d68 <__udivdi3+0x58>
  800d33:	39 f1                	cmp    %esi,%ecx
  800d35:	0f 87 bd 00 00 00    	ja     800df8 <__udivdi3+0xe8>
  800d3b:	85 c9                	test   %ecx,%ecx
  800d3d:	89 cd                	mov    %ecx,%ebp
  800d3f:	75 0b                	jne    800d4c <__udivdi3+0x3c>
  800d41:	b8 01 00 00 00       	mov    $0x1,%eax
  800d46:	31 d2                	xor    %edx,%edx
  800d48:	f7 f1                	div    %ecx
  800d4a:	89 c5                	mov    %eax,%ebp
  800d4c:	89 f0                	mov    %esi,%eax
  800d4e:	31 d2                	xor    %edx,%edx
  800d50:	f7 f5                	div    %ebp
  800d52:	89 c6                	mov    %eax,%esi
  800d54:	89 f8                	mov    %edi,%eax
  800d56:	f7 f5                	div    %ebp
  800d58:	89 f2                	mov    %esi,%edx
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    
  800d61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d68:	3b 14 24             	cmp    (%esp),%edx
  800d6b:	77 7b                	ja     800de8 <__udivdi3+0xd8>
  800d6d:	0f bd f2             	bsr    %edx,%esi
  800d70:	83 f6 1f             	xor    $0x1f,%esi
  800d73:	0f 84 97 00 00 00    	je     800e10 <__udivdi3+0x100>
  800d79:	bd 20 00 00 00       	mov    $0x20,%ebp
  800d7e:	89 d7                	mov    %edx,%edi
  800d80:	89 f1                	mov    %esi,%ecx
  800d82:	29 f5                	sub    %esi,%ebp
  800d84:	d3 e7                	shl    %cl,%edi
  800d86:	89 c2                	mov    %eax,%edx
  800d88:	89 e9                	mov    %ebp,%ecx
  800d8a:	d3 ea                	shr    %cl,%edx
  800d8c:	89 f1                	mov    %esi,%ecx
  800d8e:	09 fa                	or     %edi,%edx
  800d90:	8b 3c 24             	mov    (%esp),%edi
  800d93:	d3 e0                	shl    %cl,%eax
  800d95:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d99:	89 e9                	mov    %ebp,%ecx
  800d9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800da3:	89 fa                	mov    %edi,%edx
  800da5:	d3 ea                	shr    %cl,%edx
  800da7:	89 f1                	mov    %esi,%ecx
  800da9:	d3 e7                	shl    %cl,%edi
  800dab:	89 e9                	mov    %ebp,%ecx
  800dad:	d3 e8                	shr    %cl,%eax
  800daf:	09 c7                	or     %eax,%edi
  800db1:	89 f8                	mov    %edi,%eax
  800db3:	f7 74 24 08          	divl   0x8(%esp)
  800db7:	89 d5                	mov    %edx,%ebp
  800db9:	89 c7                	mov    %eax,%edi
  800dbb:	f7 64 24 0c          	mull   0xc(%esp)
  800dbf:	39 d5                	cmp    %edx,%ebp
  800dc1:	89 14 24             	mov    %edx,(%esp)
  800dc4:	72 11                	jb     800dd7 <__udivdi3+0xc7>
  800dc6:	8b 54 24 04          	mov    0x4(%esp),%edx
  800dca:	89 f1                	mov    %esi,%ecx
  800dcc:	d3 e2                	shl    %cl,%edx
  800dce:	39 c2                	cmp    %eax,%edx
  800dd0:	73 5e                	jae    800e30 <__udivdi3+0x120>
  800dd2:	3b 2c 24             	cmp    (%esp),%ebp
  800dd5:	75 59                	jne    800e30 <__udivdi3+0x120>
  800dd7:	8d 47 ff             	lea    -0x1(%edi),%eax
  800dda:	31 f6                	xor    %esi,%esi
  800ddc:	89 f2                	mov    %esi,%edx
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    
  800de5:	8d 76 00             	lea    0x0(%esi),%esi
  800de8:	31 f6                	xor    %esi,%esi
  800dea:	31 c0                	xor    %eax,%eax
  800dec:	89 f2                	mov    %esi,%edx
  800dee:	83 c4 10             	add    $0x10,%esp
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
  800df8:	89 f2                	mov    %esi,%edx
  800dfa:	31 f6                	xor    %esi,%esi
  800dfc:	89 f8                	mov    %edi,%eax
  800dfe:	f7 f1                	div    %ecx
  800e00:	89 f2                	mov    %esi,%edx
  800e02:	83 c4 10             	add    $0x10,%esp
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e14:	76 0b                	jbe    800e21 <__udivdi3+0x111>
  800e16:	31 c0                	xor    %eax,%eax
  800e18:	3b 14 24             	cmp    (%esp),%edx
  800e1b:	0f 83 37 ff ff ff    	jae    800d58 <__udivdi3+0x48>
  800e21:	b8 01 00 00 00       	mov    $0x1,%eax
  800e26:	e9 2d ff ff ff       	jmp    800d58 <__udivdi3+0x48>
  800e2b:	90                   	nop
  800e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e30:	89 f8                	mov    %edi,%eax
  800e32:	31 f6                	xor    %esi,%esi
  800e34:	e9 1f ff ff ff       	jmp    800d58 <__udivdi3+0x48>
  800e39:	66 90                	xchg   %ax,%ax
  800e3b:	66 90                	xchg   %ax,%ax
  800e3d:	66 90                	xchg   %ax,%ax
  800e3f:	90                   	nop

00800e40 <__umoddi3>:
  800e40:	55                   	push   %ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	83 ec 20             	sub    $0x20,%esp
  800e46:	8b 44 24 34          	mov    0x34(%esp),%eax
  800e4a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e4e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e52:	89 c6                	mov    %eax,%esi
  800e54:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e58:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800e5c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800e60:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e64:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800e68:	89 74 24 18          	mov    %esi,0x18(%esp)
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	89 c2                	mov    %eax,%edx
  800e70:	75 1e                	jne    800e90 <__umoddi3+0x50>
  800e72:	39 f7                	cmp    %esi,%edi
  800e74:	76 52                	jbe    800ec8 <__umoddi3+0x88>
  800e76:	89 c8                	mov    %ecx,%eax
  800e78:	89 f2                	mov    %esi,%edx
  800e7a:	f7 f7                	div    %edi
  800e7c:	89 d0                	mov    %edx,%eax
  800e7e:	31 d2                	xor    %edx,%edx
  800e80:	83 c4 20             	add    $0x20,%esp
  800e83:	5e                   	pop    %esi
  800e84:	5f                   	pop    %edi
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    
  800e87:	89 f6                	mov    %esi,%esi
  800e89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e90:	39 f0                	cmp    %esi,%eax
  800e92:	77 5c                	ja     800ef0 <__umoddi3+0xb0>
  800e94:	0f bd e8             	bsr    %eax,%ebp
  800e97:	83 f5 1f             	xor    $0x1f,%ebp
  800e9a:	75 64                	jne    800f00 <__umoddi3+0xc0>
  800e9c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800ea0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800ea4:	0f 86 f6 00 00 00    	jbe    800fa0 <__umoddi3+0x160>
  800eaa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800eae:	0f 82 ec 00 00 00    	jb     800fa0 <__umoddi3+0x160>
  800eb4:	8b 44 24 14          	mov    0x14(%esp),%eax
  800eb8:	8b 54 24 18          	mov    0x18(%esp),%edx
  800ebc:	83 c4 20             	add    $0x20,%esp
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    
  800ec3:	90                   	nop
  800ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	85 ff                	test   %edi,%edi
  800eca:	89 fd                	mov    %edi,%ebp
  800ecc:	75 0b                	jne    800ed9 <__umoddi3+0x99>
  800ece:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	f7 f7                	div    %edi
  800ed7:	89 c5                	mov    %eax,%ebp
  800ed9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800edd:	31 d2                	xor    %edx,%edx
  800edf:	f7 f5                	div    %ebp
  800ee1:	89 c8                	mov    %ecx,%eax
  800ee3:	f7 f5                	div    %ebp
  800ee5:	eb 95                	jmp    800e7c <__umoddi3+0x3c>
  800ee7:	89 f6                	mov    %esi,%esi
  800ee9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	83 c4 20             	add    $0x20,%esp
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    
  800efb:	90                   	nop
  800efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f00:	b8 20 00 00 00       	mov    $0x20,%eax
  800f05:	89 e9                	mov    %ebp,%ecx
  800f07:	29 e8                	sub    %ebp,%eax
  800f09:	d3 e2                	shl    %cl,%edx
  800f0b:	89 c7                	mov    %eax,%edi
  800f0d:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f11:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f15:	89 f9                	mov    %edi,%ecx
  800f17:	d3 e8                	shr    %cl,%eax
  800f19:	89 c1                	mov    %eax,%ecx
  800f1b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f1f:	09 d1                	or     %edx,%ecx
  800f21:	89 fa                	mov    %edi,%edx
  800f23:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f27:	89 e9                	mov    %ebp,%ecx
  800f29:	d3 e0                	shl    %cl,%eax
  800f2b:	89 f9                	mov    %edi,%ecx
  800f2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f31:	89 f0                	mov    %esi,%eax
  800f33:	d3 e8                	shr    %cl,%eax
  800f35:	89 e9                	mov    %ebp,%ecx
  800f37:	89 c7                	mov    %eax,%edi
  800f39:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f3d:	d3 e6                	shl    %cl,%esi
  800f3f:	89 d1                	mov    %edx,%ecx
  800f41:	89 fa                	mov    %edi,%edx
  800f43:	d3 e8                	shr    %cl,%eax
  800f45:	89 e9                	mov    %ebp,%ecx
  800f47:	09 f0                	or     %esi,%eax
  800f49:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800f4d:	f7 74 24 10          	divl   0x10(%esp)
  800f51:	d3 e6                	shl    %cl,%esi
  800f53:	89 d1                	mov    %edx,%ecx
  800f55:	f7 64 24 0c          	mull   0xc(%esp)
  800f59:	39 d1                	cmp    %edx,%ecx
  800f5b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800f5f:	89 d7                	mov    %edx,%edi
  800f61:	89 c6                	mov    %eax,%esi
  800f63:	72 0a                	jb     800f6f <__umoddi3+0x12f>
  800f65:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800f69:	73 10                	jae    800f7b <__umoddi3+0x13b>
  800f6b:	39 d1                	cmp    %edx,%ecx
  800f6d:	75 0c                	jne    800f7b <__umoddi3+0x13b>
  800f6f:	89 d7                	mov    %edx,%edi
  800f71:	89 c6                	mov    %eax,%esi
  800f73:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800f77:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800f7b:	89 ca                	mov    %ecx,%edx
  800f7d:	89 e9                	mov    %ebp,%ecx
  800f7f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f83:	29 f0                	sub    %esi,%eax
  800f85:	19 fa                	sbb    %edi,%edx
  800f87:	d3 e8                	shr    %cl,%eax
  800f89:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800f8e:	89 d7                	mov    %edx,%edi
  800f90:	d3 e7                	shl    %cl,%edi
  800f92:	89 e9                	mov    %ebp,%ecx
  800f94:	09 f8                	or     %edi,%eax
  800f96:	d3 ea                	shr    %cl,%edx
  800f98:	83 c4 20             	add    $0x20,%esp
  800f9b:	5e                   	pop    %esi
  800f9c:	5f                   	pop    %edi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    
  800f9f:	90                   	nop
  800fa0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fa4:	29 f9                	sub    %edi,%ecx
  800fa6:	19 c6                	sbb    %eax,%esi
  800fa8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800fac:	89 74 24 18          	mov    %esi,0x18(%esp)
  800fb0:	e9 ff fe ff ff       	jmp    800eb4 <__umoddi3+0x74>
